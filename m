Date: Sun, 4 Jul 1999 19:38:26 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] fix for OOM deadlock in swap_in (2.2.10) [Re: [test
 program] for OOM situations ]
In-Reply-To: <Pine.LNX.4.10.9907041002520.1352-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.10.9907041920040.6789-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@nl.linux.org>, Bernd Kaindl <bk@suse.de>, Linux Kernel <linux-kernel@vger.rutgers.edu>, kernel@suse.de, linux-mm@kvack.org, Alan Cox <alan@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 4 Jul 1999, Linus Torvalds wrote:

>Andreas patch has a much more serious problem: it changes accepted UNIX
>semantics. Try this before and after the patch:
>
>#include <unistd.h>
>#include <fcntl.h>
>#include <sys/mman.h>
>
>#define PAGE_SIZE 4096
>
>int main(int argc, char **argv)
>{
>        int fd;
>        char * map;
>
>        fd = open("/tmp/duh", O_RDWR | O_CREAT, 0666);
>        if (fd < 0)
>                exit(1);
>        ftruncate(fd, PAGE_SIZE);
>        map = mmap(NULL, PAGE_SIZE*2, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
>        *(volatile char *)(map+PAGE_SIZE);
>        return 0;
>}

On stock 2.2.10:

andrea@black:~$ strace ./a.out 
execve("./a.out", ["./a.out"], [/* 24 vars */]) = 0
brk(0)                                  = 0x804a69c
open("/etc/ld.so.preload", O_RDONLY)    = -1 ENOENT (No such file or
directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat(3, {st_mode=0, st_size=0, ...})   = 0
mmap(0, 6184, PROT_READ, MAP_PRIVATE, 3, 0) = 0x4000c000
close(3)                                = 0
open("/lib/libc.so.6", O_RDONLY)        = 3
mmap(0, 4096, PROT_READ, MAP_PRIVATE, 3, 0) = 0x4000e000
munmap(0x4000e000, 4096)                = 0
mmap(0, 672848, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) = 0x4000e000
mprotect(0x400a0000, 74832, PROT_NONE)  = 0
mmap(0x400a0000, 28672, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, 3,
0x91000) = 0x400a0000
mmap(0x400a7000, 46160, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x400a7000
close(3)                                = 0
personality(PER_LINUX)                  = 0
getpid()                                = 130
open("/tmp/duh", O_RDWR|O_CREAT, 0666)  = 3
ftruncate(3, 4096)                      = 0
mmap(0, 8192, PROT_READ|PROT_WRITE, MAP_SHARED, 3, 0) = 0x400b3000
--- SIGBUS (Bus error) ---
+++ killed by SIGBUS +++

On 2.2.10 + my oom patch:

andrea@black:~$ strace ./a.out          
execve("./a.out", ["./a.out"], [/* 24 vars */]) = 0
brk(0)                                  = 0x804a69c
open("/etc/ld.so.preload", O_RDONLY)    = -1 ENOENT (No such file or
directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat(3, {st_mode=0, st_size=0, ...})   = 0
mmap(0, 6184, PROT_READ, MAP_PRIVATE, 3, 0) = 0x4000c000
close(3)                                = 0
open("/lib/libc.so.6", O_RDONLY)        = 3
mmap(0, 4096, PROT_READ, MAP_PRIVATE, 3, 0) = 0x4000e000
munmap(0x4000e000, 4096)                = 0
mmap(0, 672848, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) = 0x4000e000
mprotect(0x400a0000, 74832, PROT_NONE)  = 0
mmap(0x400a0000, 28672, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, 3,
0x91000) = 0x400a0000
mmap(0x400a7000, 46160, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x400a7000
close(3)                                = 0
personality(PER_LINUX)                  = 0
getpid()                                = 131
open("/tmp/duh", O_RDWR|O_CREAT, 0666)  = 3
ftruncate(3, 4096)                      = 0
mmap(0, 8192, PROT_READ|PROT_WRITE, MAP_SHARED, 3, 0) = 0x400b3000
--- SIGBUS (Bus error) ---
+++ killed by SIGBUS +++

>and see the difference..

I can't see differences:

andrea@black:~$ diff 2.2.10 2.2.10- 
17c17
< getpid()                                = 134
---
> getpid()                                = 128

>And Andrea, I told you this once already in private email. I told you why.

Yes, the first patch I sent to you privately some week ago was plain buggy
(I wasn't aware of the shared-mmap-sigbugs UNIX semantic). And I really
thank you very much for have spent some time teaching me why it was buggy.

>Why don't you listen? "Fixing" a bug badly is worse than leaving it as a
>known bug.

I think I listen, I remeber well your emails. I written the new patch with
your emails in mind. Now I send a sigbus and _nothing_ more when somebody
access beyond the end of the file in a shared mmap.

The first patch I sent you some time ago was buggy since I replaced the
sigbus with a sigkill in do_page_fault, but now I force the signals only
at the lower level (as shm and other places was just doing) and the retval
of handle_mm_fault now _only_ tells do_page_fault if it has to fixup or
not.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
