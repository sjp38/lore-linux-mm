Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA20310
	for <linux-mm@kvack.org>; Thu, 10 Dec 1998 20:05:28 -0500
Date: Fri, 11 Dec 1998 01:38:47 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: 2.1.130 mem usage.
In-Reply-To: <199812021749.RAA04575@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981210235427.309E-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2 Dec 1998, Stephen C. Tweedie wrote:

>>> +		/* 
>>> +		 * If the page we looked at was recyclable but we didn't
>>> +		 * reclaim it (presumably due to PG_referenced), don't
>>> +		 * count it as scanned.  This way, the more referenced
>>> +		 * page cache pages we encounter, the more rapidly we
>>> +		 * will age them. 
>>> +		 */
>>> +		if (atomic_read(&page->count) != 1 ||
>>> +		    (!page->inode && !page->buffers))
>>> count_min--;
>
>> I don' t think count_min should count the number of tries on pages we have
>> no chance to free. It should be the opposite according to me.
>
>No, the objective is not to swap unnecessarily, but still to start
>swapping if there is too much pressure on the cache.

My idea is that your patch works well due subtle reason. The effect of the
patch is that we try on a few freeable pages so we remove only a few
refernce bits and so we don' t throw away aging (just the opposite you
wrote in the comment :). The reason it works is that there are many more
not freeable pages than orphaned not-used ones. 

shrink_mmap 30628, 0
shrink_mmap 30705, 0
shrink_mmap 30705, 0
shrink_mmap 30705, 0
shrink_mmap 30644, 0
shrink_mmap 30705, 0
shrink_mmap 30705, 0
shrink_mmap 30705, 0
shrink_mmap 30705, 0
shrink_mmap 30705, 0
shrink_mmap 30705, 0

The two numbers are the count_max and count_min a bit before returning
from shrink_mmap() with your patch applyed (with the mm subsystem stressed
a lot from my leak proggy). Basically your patch cause shrink_mmap() to
play only on a very very little portion of memory every time. This give
you a way to reference the page again and to reset the referenced flag on
it again and avoing the kernel to really drop the page and having to do IO
to pagein again then... 

So basically it' s the same of setting count_min to 100 200 (instead of
10000/20000) pages and decrease count_min when we don' t decrease it with
your patch.

That' s the only reason that you can switch from two virtual desktop
without IO. The old shrink_mmap was used to throw out also our minimal
cached working set. With the patch applyed instead we fail very more
easily in shrink_mmap() and our working set is preserved (cool!). 
Basically without the patch with all older kernels do_try_to_free_pages
exit from state ==0 (because shrink_mmap failed) only when we are then
just forced to do IO to regain pages from disk.

There are still two mm cycles:

top:
	swapout == cache++ == state 1
	swapout == cache++ == state 1
	swapout == cache++ == state 1
	swapout == cache++ == state 1
	swapout == cache++ == state 1
	swapout == cache++ == state 1
	swapout == cache++ == state 1
	last time I checked swapout was not able to fail but since we are \
	over pg_borrow, state is now been set to 0 by me
	shrink_mmap() == cache-- == state 0
	shrink_mmap() == cache-- == state 0
	shrink_mmap() == cache-- == state 0
	shrink_mmap() == cache-- == state 0
	shrink_mmap() == cache-- == state 0
	shrink_mmap() == cache-- == state 0
	here with the old shrink_mmap pressure we was used to lose our working\
	set and so everything was bad... with your patch the working set\
	is preserved because you have the time to reference the pages
	shrink_mmap() failed so state == 1
	goto top

but as you can see at the end of the mmap cycle with your patch the cached
working set is preserved. I think the natural way to do that is to decrease
the pressure but decreasing very fast count_min has the same effect.

Pratically we can also drop count_max since it never happens (at least
here) that we stop because it' s 0. 

I am very tired :( so now my mind refuse to think if it would be better to
set count_min to something like (limit >> 2) >> (priority >> 1) and
reverse the check.

For the s/free_page_and_swap_cache/free_page/ I agree with it completly. I
only want to be sure that other mm parts are well balanced with the
change.

I guess that joining the filemap patch + the s/free.../free../ patch, we
cause do_try_to_free_pages to switch more easly from one state to the next
and the system is probably more balanced than 2.1.130 that way. 

It would also be nice to not have two separate mm cycles (one that grow the
cache until borrow percentage and the other one that shrink and that reach
very near the limit of the working set). We should have always the same level
of cache in the system if the mm stress is constant. This could be easily done
by a state++ inside do_try_to_free_pages() after some (how many??) susccesfully
returns.
We should also take care of not decrease i (priority) if we switched due
a balancing factor (and not because we failed). I' ll try that in my next very
little spare time...

Comments? (Today I am really very tired so my mind can fail right now..)

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
