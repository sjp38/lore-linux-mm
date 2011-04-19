Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 31C7F900086
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 02:03:24 -0400 (EDT)
Date: Mon, 18 Apr 2011 23:06:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 33682] New: mprotect got stuck when THP is
 "always" enabled
Message-Id: <20110418230651.54da5b82.akpm@linux-foundation.org>
In-Reply-To: <bug-33682-10286@https.bugzilla.kernel.org/>
References: <bug-33682-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>
Cc: bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, bugs@casparzhang.com


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 19 Apr 2011 05:25:41 GMT bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=33682
> 
>            Summary: mprotect got stuck when THP is "always" enabled
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 2.6.38-r1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: bugs@casparzhang.com
>         Regression: No
> 
> 
> Created an attachment (id=54662)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=54662)
> mprotect test program 
> 
> Description of problem:
> 
> see attached test program. This program can be run like this:
> 
> ./mprotect <times> <length> <flag>
> 
> times: how many times the mprotect() function execute;
> length: same as the "length" option in mprotect() function;
> flag: when flag is set to 1, the program would touch every page within the
> range [addr, addr+length-1] before it calls mprotect().
> 
> to reproduce the stuck, execute: ./mprotect 50 128 1
> 
> Note that the stuck only happens when the following conditions are all
> satisfied:
> 
> flag == 1, i.e. touch page before mprotect()
> proto = PROT_NONE in mprotect()
> THP is enabled with "always" option
> 
> Version-Release number of selected component (if applicable):
> 
> Linux version 2.6.39-rc3 (caspar@caspar-gentoo) (gcc version 4.5.2 (Gentoo
> 4.5.2 p1.0, pie-0.4.5) ) #1 SMP Tue Apr 19 12:32:20 CST 2011
> 
> How reproducible:
> very often
> 
> Actual results:
> test program got stuck when touching pages + THP always enabled:
> 
> caspar-gentoo tmp # echo always > /sys/kernel/mm/transparent_hugepage/enabled 
> caspar-gentoo tmp # ./mprotect 50 128 1
> ^C <- stuck
> caspar-gentoo tmp # ./mprotect 50 128 1
> ^C
> caspar-gentoo tmp # ./mprotect 50 128 1
> ^C
> caspar-gentoo tmp # ./mprotect 50 128 1
> ^C
> caspar-gentoo tmp # echo madvise > /sys/kernel/mm/transparent_hugepage/enabled 
> caspar-gentoo tmp # ./mprotect 50 128 1
> done caspar-gentoo tmp # ./mprotect 50 128 1
> done caspar-gentoo tmp # ./mprotect 50 128 1
> done caspar-gentoo tmp # ./mprotect 50 128 1
> done caspar-gentoo tmp # echo never >
> /sys/kernel/mm/transparent_hugepage/enabled 
> caspar-gentoo tmp # ./mprotect 50 128 1
> done caspar-gentoo tmp # ./mprotect 50 128 1
> done caspar-gentoo tmp # ./mprotect 50 128 1
> done caspar-gentoo tmp # ./mprotect 50 128 1
> done caspar-gentoo tmp # ./mprotect 50 128 1
> done caspar-gentoo tmp # ./mprotect 50 128 1
> done caspar-gentoo tmp # ./mprotect 50 128 1
> 
> Expected results:
> test program exit normally
> 
> Additional info:
> 
> This reproducer was similar to a test program in upstream test suite: libMicro
> (http://hub.opensolaris.org/bin/view/Project+libmicro/)
> 
> strace ouput: 
> 
> # strace ./mprotect 50 128 1
> execve("./mprotect", ["./mprotect", "50", "128", "1"], [/* 35 vars */]) = 0
> brk(0)                                  = 0x16ad000
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =
> 0x7ffa0c266000
> access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
> open("/etc/ld.so.cache", O_RDONLY)      = 3
> fstat(3, {st_mode=S_IFREG|0644, st_size=163815, ...}) = 0
> mmap(NULL, 163815, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7ffa0c23e000
> close(3)                                = 0
> open("/lib64/libc.so.6", O_RDONLY)      = 3
> read(3,
> "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\320\357\1\0\0\0\0\0"..., 832) =
> 832
> fstat(3, {st_mode=S_IFREG|0755, st_size=1608912, ...}) = 0
> mmap(NULL, 3718152, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) =
> 0x7ffa0bcbc000
> mprotect(0x7ffa0be3f000, 2093056, PROT_NONE) = 0
> mmap(0x7ffa0c03e000, 20480, PROT_READ|PROT_WRITE,
> MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x182000) = 0x7ffa0c03e000
> mmap(0x7ffa0c043000, 19464, PROT_READ|PROT_WRITE,
> MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ffa0c043000
> close(3)                                = 0
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =
> 0x7ffa0c23d000
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =
> 0x7ffa0c23c000
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =
> 0x7ffa0c23b000
> arch_prctl(ARCH_SET_FS, 0x7ffa0c23c700) = 0
> mprotect(0x7ffa0c03e000, 16384, PROT_READ) = 0
> mprotect(0x600000, 4096, PROT_READ)     = 0
> mprotect(0x7ffa0c267000, 4096, PROT_READ) = 0
> munmap(0x7ffa0c23e000, 163815)          = 0
> open("/dev/zero", O_RDWR)               = 3
> mmap(NULL, 6553600, PROT_READ|PROT_WRITE, MAP_PRIVATE, 3, 0) = 0x7ffa0b67c000
> mprotect(0x7ffa0b67c000, 131072, PROT_NONE) = 0
> mprotect(0x7ffa0b69c000, 131072, PROT_NONE) = 0
> mprotect(0x7ffa0b6bc000, 131072, PROT_NONE) = 0
> mprotect(0x7ffa0b6dc000, 131072, PROT_NONE) = 0
> mprotect(0x7ffa0b6fc000, 131072, PROT_NONE) = 0
> mprotect(0x7ffa0b71c000, 131072, PROT_NONE) = 0
> mprotect(0x7ffa0b73c000, 131072, PROT_NONE) = 0
> mprotect(0x7ffa0b75c000, 131072, PROT_NONE) = 0
> <repeated random times, snip>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
