Received: from deliverator.sgi.com (deliverator.sgi.com [204.94.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id AAA23141
	for <linux-mm@kvack.org>; Thu, 27 May 1999 00:45:12 -0400
From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199905270444.VAA30288@google.engr.sgi.com>
Subject: dso loading question
Date: Wed, 26 May 1999 21:44:41 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.rutgers.edu
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I am trying to understand how the glibc ld-linux code works just after
program startup. I have a small program

main()
{
}

on which I ran strace to get the following output:

[kanoj@entity /tmp]$ strace ./a.out
execve("./a.out", ["./a.out"], [/* 18 vars */]) = 0
brk(0)                                  = 0x8049558
open("/etc/ld.so.preload", O_RDONLY)    = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat(3, {st_mode=0, st_size=0, ...})   = 0
mmap(0, 11908, PROT_READ, MAP_PRIVATE, 3, 0) = 0x4000b000
close(3)                                = 0
open("/lib/libc.so.6", O_RDONLY)        = 3
mmap(0, 4096, PROT_READ, MAP_PRIVATE, 3, 0) = 0x4000e000
munmap(0x4000e000, 4096)                = 0
mmap(0, 670420, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) = 0x4000e000
mprotect(0x4009f000, 76500, PROT_NONE)  = 0
mmap(0x4009f000, 28672, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, 3, 0x90000) = 0x4009f000
mmap(0x400a6000, 47828, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x400a6000
close(3)                                = 0
personality(PER_LINUX)                  = 0
getpid()                                = 9822
_exit(134513792)                        = ?

Here are the questions I would like to get answers to:
1. What is the purpose of the /etc/ld.so.cache? Where can I learn more
about it?
2. I assume the first 4K mmap of libc is to read section headers etc ...
or is there something more going on there?
3. How are the libc mmap/munmap calls made by the loading code? Basically,
how does the code decide on the offset/length to mmap? Why is an mprotect
being done?
4. Are the .init sections of the dso's executed before the close() of
the fd referencing the dso?
5. At what point is the personality(PER_LINUX) call made?

I am trying to understand how dso loading works in Linux, specially at
program startup time.

Thanks for any input. Please CC me on any responses at kanoj@engr.sgi.com.

Kanoj
kanoj@engr.sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
