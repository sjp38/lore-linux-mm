Message-ID: <39121A22.BA0BA852@sgi.com>
Date: Thu, 04 May 2000 17:47:30 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: 7-4 VM killing (A solution)
References: <Pine.LNX.4.10.10005041517310.878-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: riel@nl.linux.org, Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Thu, 4 May 2000, Rajagopal Ananthanarayanan wrote:
> >
> > One clarification: In the case I reported only
> > dbench was running, presumably doing a lot of read/write. So, why
> > isn't shrink_mmap able to find freeable pages? Is it because
> > the shrink_mmap() is too conservative about implementing LRU?
> 
> Probably. One of the things that has changed is exactly _which_ pages are
> on the LRU list, so the old heuristics from shrink_mmap() may need some
> tweaking too. In fact, as with vmscan, we should probably scan the LRU
> list at least _twice_ when the priority level reaches zero (in order to
> defeat the aging).

Ok, I may have a solution after having asked, mostly to myself,
why doesn't shrink_mmap() find pages to free?

The answer apparenlty is because in 7-4 shrink_mmap(),
unreferenced pages get filed as "young" if the zone has
enough pages in it (free_pages > pages_high).

Because of this bug, if we examine a zone which already
has enough free pages, all referenced pages now go to
the "back" of the lru list.

On a subsequent scan, we may never get to these pages in time.
Comments?

Here's the new code to shrink_mmap:

------------
		[ ... ]
		 dispose = &young;
                if (test_and_clear_bit(PG_referenced, &page->flags))
                        goto dispose_continue;

                if (!page->buffers && page_count(page) > 1)
                        goto dispose_continue;

                dispose = &old;
                if (p_zone->free_pages > p_zone->pages_high)
                        goto dispose_continue;

                count--;
                /* Page not used -> free it or put it on the old list
                 * so it gets freed first the next time */
                if (TryLockPage(page))
                        goto dispose_continue;
		[ ... ]
-------------------

With this I'm able to run dbench upto 16 threads (using over
0.5 GB of disk). For reference, without the fix,
dbench wouldn't run even with as few as 4 threads (using
much less disk space).

> 
> This is also an area where the secondary effects of the vmscan page
> lockedness changes could start showing up - the page being locked on the
> LRU list makes a difference to the shrink_mmap() algorithm..
> 
>                 Linus

Kanoj & I looked over your changes (lot easier to do over
the phone!) ... and didn't find any thing wrong with it.

Again, with the above fix things look good. Since
7-4 is badly broken in this respect, do you want a patch?
Since it is a small change, you can put it in "by hand" ...


-- 
--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
