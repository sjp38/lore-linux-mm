Message-Id: <200008080036.RAA03032@eng2.sequent.com>
Reply-To: Gerrit.Huizenga@us.ibm.com
From: Gerrit.Huizenga@us.ibm.com
Subject: Re: RFC: design for new VM 
In-reply-to: Your message of Mon, 07 Aug 2000 16:55:32 EDT.
             <87256934.0072FA16.00@d53mta04h.boulder.ibm.com>
Date: Mon, 07 Aug 2000 17:36:43 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: chucklever@bigfoot.com
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi Chuck,

> 1.  kswapd runs in the background and wakes up every so often to handle
> the corner cases that smooth bursty memory request workloads.  it executes
> the same code that is invoked from the kernel's memory allocator to
> reclaim pages.
 
 yep...  We do the same, although primarily through RSS management and our
 pageout deamon (separate from swapout).

 One possible difference - dirty pages are schedule for asynchronous
 flush to disk and then moved to the end of the free list after IO
 is complete.  If the process faults on that page, either before it is
 paged out or aftewrwards, it can be "reclaimed" either from the dirty
 list or the free list , without re-reading from disk.  The pageout daemon
 runs with the dirty list reaches a tuneable size, and the pageout deamon
 shrinks the list to a tuneable size, moving all written pages to the
 free list.

 In many ways, similar to what Rik is proposing, although I don't see any
 "fast reclaim" capability.  Also, the method by which pages are aged
 is quite different (global phys memory scan vs. processes maintaining
 their own LRU set).  Having a list of prime candidates to flush makes
 the kswapd/pageout overhead lower than using a global clock hand, but
 the global clock hand *may* more perform better global optimisation
 of page aging.

> 2.  i agree with you that when the system exhausts memory, it hits a hard
> knee; it would be better to soften this.  however, the VM system is
> designed to optimize the case where the system has enough memory.  in
> other words, it is designed to avoid unnecessary work when there is no
> need to reclaim memory.  this design was optimized for a desktop workload,
> like the scheduler or ext2 "async" mode.  if i can paraphrase other
> comments i've heard on these lists, it epitomizes a basic design
> philosophy: "to optimize the common case gains the most performance
> advantage."
 
 This works fine until I have a stable load on my system and then
 start {Netscape, StarOffice, VMware, etc.} which then causes IO for
 demand paging of the executable, as well as paging/swapping activity
 to make room for the piggish footprints of these bigger applications.

 This is where it might help to pre-write dirty pages when the system
 is more idle, without fully returning those pages to the free list.

> can a soft-knee swapping algorithm be demonstrated that doesn't impact the
> performance of applications running on a system that hasn't exhausted its
> memory?
> 
>      - Chuck Lever

 Our VM doesn't exhibit a strong knee, but its method of avoiding that
 is again the flexing RSS management.  Inactive processes tend to shrink
 to their working footprint, larger processes tend to grow to expand
 their footprint but still self-manage within the limits of available
 memory.  I think it is possible to soften the knee on a per-workload
 basis, and that's probably a spot for some tuneables.  E.g. when to
 flush dirty old pages, how many to flush, and I think Rik has already
 talked about having those tunables.

 Despite the fact that our systems have been primarily deployed for
 a single workload type (databases), we still have found that (the
 right!) VM tuneables can have an enormous impact on performance. I
 think the same will be much more true of an OS like Linux which tries
 to be many things to all people.

gerrit
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
