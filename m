Received: from mailhost.uni-koblenz.de (mailhost.uni-koblenz.de [141.26.64.1])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA02070
	for <linux-mm@kvack.org>; Thu, 27 May 1999 15:54:15 -0400
Received: from lappi.waldorf-gmbh.de (cacc-28.uni-koblenz.de [141.26.131.28])
	by mailhost.uni-koblenz.de (8.9.1/8.9.1) with ESMTP id VAA01691
	for <linux-mm@kvack.org>; Thu, 27 May 1999 21:54:06 +0200 (MET DST)
Date: Thu, 27 May 1999 21:50:27 +0200
From: Ralf Baechle <ralf@uni-koblenz.de>
Subject: Re: dso loading question
Message-ID: <19990527215027.E4058@uni-koblenz.de>
References: <199905270444.VAA30288@google.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <199905270444.VAA30288@google.engr.sgi.com>; from Kanoj Sarcar on Wed, May 26, 1999 at 09:44:41PM -0700
Sender: owner-linux-mm@kvack.org
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 1999 at 09:44:41PM -0700, Kanoj Sarcar wrote:

> I am trying to understand how the glibc ld-linux code works just after
> program startup. I have a small program
> 
> main()
> {
> }
> 
> on which I ran strace to get the following output:
> 
> [kanoj@entity /tmp]$ strace ./a.out
> execve("./a.out", ["./a.out"], [/* 18 vars */]) = 0
> brk(0)                                  = 0x8049558
> open("/etc/ld.so.preload", O_RDONLY)    = -1 ENOENT (No such file or directory)
> open("/etc/ld.so.cache", O_RDONLY)      = 3
> fstat(3, {st_mode=0, st_size=0, ...})   = 0
> mmap(0, 11908, PROT_READ, MAP_PRIVATE, 3, 0) = 0x4000b000
> close(3)                                = 0
> open("/lib/libc.so.6", O_RDONLY)        = 3
> mmap(0, 4096, PROT_READ, MAP_PRIVATE, 3, 0) = 0x4000e000
> munmap(0x4000e000, 4096)                = 0
> mmap(0, 670420, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) = 0x4000e000
> mprotect(0x4009f000, 76500, PROT_NONE)  = 0
> mmap(0x4009f000, 28672, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, 3, 0x90000) = 0x4009f000
> mmap(0x400a6000, 47828, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x400a6000
> close(3)                                = 0
> personality(PER_LINUX)                  = 0
> getpid()                                = 9822
> _exit(134513792)                        = ?
> 
> Here are the questions I would like to get answers to:
> 1. What is the purpose of the /etc/ld.so.cache? Where can I learn more
> about it?

Libraries may be spread of a large number of directories.  ld.so.cache
is used to shorten this search process.

> 2. I assume the first 4K mmap of libc is to read section headers etc ...
> or is there something more going on there?

Only the ELF header is guaranteed to be at offset 0.  All there rest
is accessed via the segment map.  My libc looks like:

Program Header:
    PHDR off    0x00000034 vaddr 0x00000034 paddr 0x00000034 align 2**2
         filesz 0x000000a0 memsz 0x000000a0 flags r-x
  INTERP off    0x000d408d vaddr 0x000d408d paddr 0x000d408d align 2**0
         filesz 0x00000013 memsz 0x00000013 flags r--
    LOAD off    0x00000000 vaddr 0x00000000 paddr 0x00000000 align 2**12
         filesz 0x000d40a0 memsz 0x000d40a0 flags r-x
    LOAD off    0x000d40a0 vaddr 0x000d50a0 paddr 0x000d50a0 align 2**12
         filesz 0x00004068 memsz 0x00006f48 flags rw-
 DYNAMIC off    0x000d8058 vaddr 0x000d9058 paddr 0x000d9058 align 2**2
         filesz 0x000000b0 memsz 0x000000b0 flags rw-

Best enjoy this with an ELF spec on your desk.

> 3. How are the libc mmap/munmap calls made by the loading code? Basically,
> how does the code decide on the offset/length to mmap? Why is an mprotect
> being done?

mprotect calls may be necessary for mapping areas which are mapped without
write access but where relocations need to be applied to.

> 4. Are the .init sections of the dso's executed before the close() of
> the fd referencing the dso?
> 5. At what point is the personality(PER_LINUX) call made?
> 
> I am trying to understand how dso loading works in Linux, specially at
> program startup time.

Read glibc/sysdeps/unix/sysv/linux/init-first.c.  Actually the entire
startuped & libc initialization code.  It's quite complex.

Btw, this all is done in userspace, therefore nothing for linux-kernel or
linux-mm.

  Ralf
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
