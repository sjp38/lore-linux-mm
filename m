Date: Wed, 29 Aug 2007 16:36:37 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: speeding up swapoff
In-Reply-To: <1188394172.22156.67.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708291558480.27467@blonde.wat.veritas.com>
References: <1188394172.22156.67.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Drake <ddrake@brontes3d.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Aug 2007, Daniel Drake wrote:
> 
> I've spent some time trying to understand why swapoff is such a slow
> operation.
> 
> My experiments show that when there is not much free physical memory,
> swapoff moves pages out of swap at a rate of approximately 5mb/sec. When
> there is a lot of free physical memory, it is faster but still a slow
> CPU-intensive operation, purging swap at about 20mb/sec.

Yes, it can be shamefully slow.  But we've done nothing about it for
years, simply because very few actually suffer from its worst cases.
You're the first I've heard complain about it in a long time: perhaps
you'll be joined by a chorus, and we can have fun looking at it again.

> 
> I've read into the swap code and I have some understanding that this is
> an expensive operation (and has to be). This page was very helpful and
> also agrees:
> http://kernel.org/doc/gorman/html/understand/understand014.html
> 
> After reading that, I have an idea for a possible optimization. If we
> were to create a system call to disable ALL swap partitions (or modify
> the existing one to accept NULL for that purpose), could this process be
> signficantly less complex?

I'd be quite strongly against an additional system call: if we're
going to speed it up, let's speed up the common case, not your special
additional call.  But I don't think you need that anyway: the slowness
doesn't come from the limited number of swap areas, but from the much
greater numbers of processes and their pages.  Looping over the number
of swap areas (so often 1) isn't a problem.

> 
> I'm thinking we could do something like this:
>  1. Prevent any more pages from being swapped out from this point
>  2. Iterate through all process page tables, paging all swapped
>     pages back into physical memory and updating PTEs
>  3. Clear all swap tables and caches
> 
> Due to only iterating through process page tables once, does this sound
> like it would increase performance non-trivially? Is it feasible?

I'll ignore your steps 1 and 3, I don't see the advantage.  (We
do already prevent pages from being swapped out to the area we're
swapping off, and in general we need to allow for swapping out to
another area while swapping off.)  Step 2 is the core of your idea.

Feasible yes, and very much less CPU-intensive than the present method.
But... it would be reading in pages from swap in pretty much a random
order, whereas the present method is reading them in sequentially, to
minimize disk seek time.  So I doubt your way would actually work out
faster, except in those (exceptional, I'm afraid) cases where almost
all the swap pages are already in core swapcache when swapoff begins.

> 
> I'm happy to spend a few more hours looking into implementing this but
> would greatly appreciate any advice from those in-the-know on if my
> ideas are broken to start with...

Well, do give it a try if you're interested: I've never actually
timed doing it that way, and might be surprised.  I doubt you could
actually remove the present code, but it could become a fallback to
clear up the loose ends after some faster first pass.

Don't forget you'll also need to deal with tmpfs files (mm/shmem.c):
Christoph Rohland long ago had a patch to work on those in the way you
propose, but we never integrated it because of the random seek issue.

The speedups I've imagined making, were a need demonstrated, have
been more on the lines of batching (dealing with a range of pages
in one go) and hashing (using the swapmap's ushort, so often 1 or
2 or 3, to hold an indicator of where to look for its references).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
