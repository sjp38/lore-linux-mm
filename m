Message-ID: <39149B81.B92C8741@sgi.com>
Date: Sat, 06 May 2000 15:24:01 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: [DATAPOINT] pre7-6 will not swap
References: <Pine.LNX.4.21.0005061844560.4627-100000@duckman.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Benjamin Redelings I <bredelin@ucla.edu>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Fri, 5 May 2000, Benjamin Redelings I wrote:
> 
> >       It looks like some processes (my unused daemons) are
> > scanned only once, and then get stuck at the end of some list?
> > Is that a possible explanation? <guessing> Perhaps Rik's moving
> > list-head idea is needed? </guessing>.
> 
> I'm busy implementing Davem's active/inactive list proposal
> to replace the current page/swapcache. I don't know if it'll
> work really well though, so research into other directions
> is very much welcome ;)
> 

Again my experience, with skipping pages whose zones have
(free_pages > pages_high) in try_to_swap_out, is similar to
Benajamin's ... the system behaves better than 7-4, but
isn't as good as without any zone skipping.

Once again, I'm back to asking, should we be swapping at all?
Shouldn't shrink_mmap() be finding pages to throw out?

I have a hunch. Follow this argument closely. In shrink_mmap we have:

------------
	if (p_zone->free_pages > p_zone->pages_high)
                        goto dispose_continue;
------

This page doesn't count against a valid try in shrink_mmap().
Soon, we run out of pages to look at, but "count" in shrink_mmap is
still high. So, we go back to scanning the lru list all over again.
If some pages' reference count was flipped in the first loop, good.
If it wasn't, and all that remained was unreferenced pages whose
zones have reached the high water mark, then they won't be victimized,
because the same test above will skip the page again!

Still on the second loop, shrink_mmap will look at other pages,
for instance because an I/O is in flight, and _those_ pages do tally
against "count" ... so, in essense, we have skipped unreferenced pages
belonging to zones with high water mark, for ever. This is wrong.

My solution is simple. Have a variable, "second_scan" initialized to zero,
at the top of shrink_mmap(). Set "second_scan = 1" at the bottom of the loop
in shrink_mmap:

---------------
	/* wrong zone?  not looped too often?    roll again... */
        if (page->zone != zone && count) {
		second_scan = 1;
                goto again;
	}
-------------

Now the pages_high test will be changed to:

-----------
	 if (p_zone->free_pages > p_zone->pages_high && !second_scan)
                        goto dispose_continue;
-----------

That is, victimize pages in zones with lots of free_pages if having
scanned once we didn't find anything.

If you are worried about unreferenced pages not being looked at in
the second_scan, we can change it to a third_scan.

Now, the final argument: since this page was skipped by shrink_mmap(),
the test in try_to_swap_out that Benjamin, I and Linus have been playing
around becomes important. Without it, pages in zones with lots of
free memory neither get "shrunk" nor get swapped.

What do you guys think?

--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
