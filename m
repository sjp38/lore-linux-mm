Date: Mon, 25 Jun 2001 12:22:23 -0400
From: Pete Wyckoff <pw@osc.edu>
Subject: Re: memory problems:  mlockall() w/ pthreads on 2.4
Message-ID: <20010625122223.E22296@osc.edu>
References: <XFMail.20010624150303.mhw6@cornell.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <XFMail.20010624150303.mhw6@cornell.edu>; from mhw6@cornell.edu on Sun, Jun 24, 2001 at 03:03:03PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Koni <mhw6@cornell.edu>
Cc: linux-mm@kvack.org, wireless@ithacaweb.com
List-ID: <linux-mm.kvack.org>

mhw6@cornell.edu said:
> After a whole day of head scratching, I tracked this down to the
> combination of using mlockall() and pthread_create(). Any combination
> bleeds a little over 2M (as reported by top or ps) per thread created.
> It is not shown in a profiling tool such as memprof.
[..]
> However, calling after pthread_create() with just mlockall(MCL_FUTURE), does
> NOT bleed memory. calling with mlockall(MCL_CURRENT) does. 
> 
> My interpretation of that: mlockall(MCL_CURRENT) is locking the entire
> possible stack space of every running thread (and if MCL_FUTURE is also given,
> then the entire stack of every new thread created as well).

All cloned process share the same memory space, but each thread is
allocated its own stack area in which to play.  Look at /proc/<pid>/maps
to see these:  1 page of guard, then about 2 MB of stack per thread.
(Not sure why you get 8 MB without DETACHED.)

The way mlockall(MCL_CURRENT) works is to go through the current memory
space and ensure that each page is available.  When you do this, only
the currently used stack (of a non-threaded process) is locked down.
Future stack (and heap) growth will be locked as it is used, if you use
MCL_FUTURE.

In the case of threads, though, each thread stack is allocated using
mmap before the clone() to create the thread.  The mmap system call does
not know you will be using the area as a "stack", and thus locks in the
entire region immediately.

> Any ideas? I'll have to be a bit more clever I guess to keep the
> memory size down for the SLAN programs running on 2.4, while still
> having pages locked. It was certainly nice (from the development point
> of view) to just call mlockall() at program startup and then forget
> about it. Trying to pick and choose which pages to lock looks very
> difficult since the public key stuff is all done with gmp and I
> haven't control over how those functions allocate (stack vs. heap)
> memory and pass parameters to internal functions.

You might start each thread with an explicit stack which is much
smaller than 2MB, if you can get away with that.  You might investigate
changing pthreads to mmap() just a single stack page at a calculated
offset, but with the MAP_GROWSDOWN flag, and see if the kernel will take
care of mapping/locking pages as the thread stacks grow.

		-- Pete
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
