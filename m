Received: from localhost (root@localhost)
	by ppp-pat135.tee.gr (8.8.5/8.8.5) with SMTP id FAA00334
	for <linux-mm@kvack.org>; Sat, 17 Jun 2000 05:14:44 +0300
Date: Sat, 17 Jun 2000 05:14:42 +0300 (EEST)
From: Stelios Xanthakis <root@ppp-pat135.tee.gr>
Reply-To: axanth@tee.gr
Subject: Stack syscall is here
Message-ID: <Pine.LNX.3.95.1000617050450.328A-100000@ppp-pat135.tee.gr>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

A while ago we were discussing possible ways to shrink the stack segment
of a process. A solution was to read the base of the stack segment from
/proc/self/maps and explictly unmap part of the unused stack (unused stack
is esp - vm_start).

This is a *hack*. Unmapping something maintained by the kernel is
definately a hack and has no future in serious portable applications.

I had free time recently and I wrote & tested a new system call,
adjstack().

adjstack (void *sp, size_t max_unused)
will find the stack area (VM_GROWSDOWN) which includes <sp> and release part
of the unused stack with respect to <max_unused>.
 

Please see the man page (which possibly needs corrections):
http://students.ceid.upatras.gr/~sxanth/lst/ADJSTACK.1
 or
http://students.ceid.upatras.gr/~sxanth/lst/ADJSTACK.txt


Do we need Yet Another Syscall ?
If people start using more of the stack segment for temporary allocations
with alloca(), the world will be a better place to live!
Much less fragmentation and less work for the kernel -- but a way to shrink
extreme stack bursts will have to be there.


The code is terribly small and can be found at:

http://students.ceid.upatras.gr/~sxanth/lst/adjstack.c

I didn't want to give Yet Another Patch which will mess with unistd.h so
adjstack.c is just the system call code which I include to mmap.c.

It is tested with 2.2.x kernel and works fine.
For >= 2.3.x kernels adjstack will use madvise with MADV_DONTNEED instead of
munmap, but I did not test that. It would be interesting to see the better
performance in the 2.4.x series.

Tests were done for x86. Is the code generic indeed (HP PA?).


A sample test program at:

http://studens.ceid.upatras.gr/~sxanth/lst/padjstack.c

Is a multithreaded application in which threads call a function foo () that
allocates temporary space with alloca() using a Reyleigh-like distribution
for the size of the allocated space. adjstack is called after every call to
this foo () function to /possibly/ shrink the stack.

It works Ok, but more experienced kernel hackers will have to look at the
lock_kernel() and friends.


On the other hand, adjstack can serve as a sample of how could we manage
the stack according to the application's directives.


Cheers

Stelios

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
