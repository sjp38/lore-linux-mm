Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA20404
	for <linux-mm@kvack.org>; Sun, 5 Jul 1998 15:37:15 -0400
Date: Sun, 5 Jul 1998 21:31:56 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <Pine.LNX.3.96.980705202128.12985B-100000@dragon.bogus>
Message-ID: <Pine.LNX.3.96.980705212422.2416D-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <arcangeli@mbox.queen.it>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Sun, 5 Jul 1998, Andrea Arcangeli wrote:
> On Sun, 5 Jul 1998, Rik van Riel wrote:
> 
> >The cache is also mapped into a process'es address space.
> >Currently we would have to walk all pagetables to find a
> >specific page ;(
> 
> I start to think that the problem is kswapd. Running cp file /dev/null the
> system remains fluid (when press a key I see the char on the _console_) 
> until there is free (wasted because not used) memory. While there is free
> memory the swap is 0. When the free memory finish, the system die and when
> I press a key I don' t see the character on the screen immediatly. I think
> that it' s kswapd that is irratiting me. So now I am trying to fuck kswapd
> (I am starting to hate it since I really hate swap ;-). kswapd must swap
> _nothing_ if _freeable_ cache memory is allocated.  kswapd _must_ consider
> freeable cache memory as _free_ not used memory and so it must not start
> swapping out useful code and data for make space for allocating more
> cache.  With 2.0.34 when the cache eat all free memory nothing gone
> swapped out and all perform better.

A few months ago someone (who?) posted a patch that modified
kswapd's internals to only unmap clean pages when told to.

If I can find the patch, I'll integrate it and let kswapd
only swap clean pages when:
- page_cache_size * 100 > num_physpages * page_cache.borrow_percent
or
- (buffer_mem >> PAGE_SHIFT) * 100 > num_physpages * buffermem.borrow_percent

> >shrink_mmap() can only shrink unlocked and clean buffer pages
> >and unmapped cache pages. We need to go through either bdflush
> ...unmapped cache pages. Good.

Not good, it means that kswapd needs to unmap the pages
first, using the try_to_swap_out() function. [which really
needs to be renamed to try_to_unmap()]

> >(for buffer) or try_to_swap_out() first, in order to make some
> try_to_swap_out() should unmap the cache pages? Then I had to recall
> shrink_mmap()?

Shrink_mmap() frees the pages that are already unmapped
by try_to_swap_out(). This means that the pages need to
be handled by both functions (which is good, because it
gives us a second 'timeout' for page aging).

> Rik reading vmscan.c I noticed that you are the one that worked on kswapd
> (for example removing hard page limits and checking instead
> free_memory_available(nr)). Could you tell me what you changed (or in
> which kernel-patch I can find the kswapd patches) to force kswapd to swap
> so much? 

Most of the patches are on my homepage, you can get
and read them there...

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
