" Copyright (c) 2014 Boucher, Antoni <bouanto@gmail.com>
" 
" All rights reserved.
" 
" Redistribution and use in source and binary forms, with or without
" modification, are permitted provided that the following conditions
" are met:
" 
" * Redistributions of source code must retain the above copyright
" notice, this list of conditions and the following disclaimer.
" 
" * Redistributions in binary form must reproduce the above copyright
" notice, this list of conditions and the following disclaimer in the
" documentation and/or other materials provided with the distribution.
" 
" * Neither the name of the copyright holder nor the names of its
" contributors may be used to endorse or promote products derived from
" this software without specific prior written permission.
" 
" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
" "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
" LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
" A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
" OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
" SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
" LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
" DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
" THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
" (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
" OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

" Vim plugin to insert licenses.
" Last Change: 2014 Feb 22
" Maintener: Antoni Boucher <bouanto@gmail.com>
" License: BSD

if exists('g:loaded_licenses')
    finish
endif
let g:loaded_licenses = 1

function! InsertLicense(name)
    " Check if the license is already in the buffer.
    let licenseFileName = '~/.vim/licenses/' . a:name . '.txt'
    if filereadable(expand(licenseFileName))
        let fileContent = readfile(expand(licenseFileName))

        if search(fileContent[-1:][0]) == 0
            " License insertion.
            let lineCounteBefore = line('$')
            normal gg

            let line1 = getline(1)

            if line1 =~# '^#!' || (&filetype == 'php' && line1 =~# '^<?php')
                if line('$') < 2
                    normal o
                    call setline('.', '')
                    normal o
                    call setline('.', '')
                endif

                let lineCounteBefore = line('$')

                execute '2read ' . expand(licenseFileName)
            else
                execute '0read ' . expand(licenseFileName)
            endif

            let lineCountAfter = line('$')
            let addedLineCount = lineCountAfter - lineCounteBefore

            " Reading of comment delimiter.
            let comments = split(&comments, ',')
            let commentsDict = {}
            for i in range(len(comments))
                let splitted = split(comments[i], ':')
                if len(splitted) > 1
                    let commentsDict[splitted[0]] = splitted[1]
                else
                    let commentsDict['sl'] = splitted[0]
                endif
            endfor

            " Comment the license.
            let isCMakeLists = expand('%:t') == 'CMakeLists.txt'
            if !has_key(commentsDict, 's1') || isCMakeLists
                " One line comment.
                normal gg
                if line1 =~# '^#!'
                    call cursor(line('.') + 2, 0)
                endif

                if !has_key(commentsDict, 'sl') || isCMakeLists
                    let commentChar = commentsDict['b']
                else
                    let commentChar = commentsDict['sl']
                endif

                for i in range(1, addedLineCount)
                    substitute /^/\=commentChar/
                    normal a 
                    call cursor(line('.') + 1, 0)
                endfor

                normal O
            else
                " Multiline comment.

                " Insert php open tag if filetype is php and first line does not
                " contain it.
                let hasInsertedPhpTag = 0
                if &filetype == 'php'
                    if line1 !~# '^<?php'
                        let hasInsertedPhpTag = 1
                        normal ggO<?php
                        normal o
                    else
                        normal ggo
                        call cursor(line('.') + 1, 0)
                    endif
                else
                    normal ggO
                endif

                put =commentsDict['s1']
                call cursor(line('.') - 1, 0)
                delete
                for i in range(1, addedLineCount)
                    call cursor(line('.') + 1, 0)
                    substitute /^/\=commentsDict['mb']/
                    normal I 
                    call cursor(0, col('.') + 1)
                    normal a 
                endfor
                put =commentsDict['ex']
                normal I 

                " Insert php close tag if filetype is php and first line did not
                " contain it.
                if &filetype == 'php' && hasInsertedPhpTag
                    normal o?>
                endif

                normal o
            endif
            " Substitute the year tag to the current year.
            let _ = search('<year>', 'b')
            substitute /<year>/\=strftime('%Y')/
        endif
    else
        echoerr 'Cannot find file ' . licenseFileName . '.'
    endif
endfunction

if !exists(':Bsd')
    command Bsd call InsertLicense('bsd')
endif

if !exists('Gpl')
    command Gpl call InsertLicense('gpl')
endif

if !exists('Lgpl')
    command Lgpl call InsertLicense('lgpl')
endif
