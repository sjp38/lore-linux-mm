Message-ID: <39472366.6E417A20@sgi.com>
Date: Tue, 13 Jun 2000 23:17:10 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
References: <8i3qe8$lltbv$1@fido.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
	[ ... ]
> 
> Indeed. And to be honest, the patch can be made even simpler.
> 
> We can simply move the test up to above the count--, so we won't
> start IO for the "wrong" zones either.

No, I think that leads to other problems. Almost a month ago,
when pre6-8 was having serious issues here, I also happened
to chance on the same set of problems. And here's the summary
of the discussions with Linus: (1) shrink_mmap should
not give up having tried one of the pages from a balanced zone
(2) regardless of zone being balanced or not, memory pressure
should trigger I/O. Otherwise the buffer-heads attached to the
pages in the balanced zones can never be recovered in time.
Here's a quote from Linus' message:

------------ Begin Quote ------------------------------------------
Linus Torvalds wrote:
> 
        [ ... ]
> 
> The "don't page out pages from zones that don't need it" test is a good
> test, but it turns out that it triggers a rather serious problem: the way
> the buffer cache dirty page handling is done is by having shrink_mmap() do
> a "try_to_free_buffers()" on the pages it encounters that have
> "page->buffer" set.
> 
> And doing that is quite important, because without that logic the buffers
> don't get written to disk in a timely manner, nor do already-written
> buffers get refiled to their proper lists. So you end up being "out of
> memory" - not because the machine is really out of memory, but because
> those buffers have a tendency to stick around if they aren't constantly
> looked after by "try_to_free_buffers()".
> 
> So the real fix ended up being to re-order the tests in shrink_mmap() a
> bit, so that try_to_free_buffers() is called even for pages that are on
> a good zone that doesn't need any real balancing..
------------------------- End Quote ------------------------

.... Back to Rik's message ....
> 
> There's only one serious bug left with the current shrink_mmap,
> a bug which appears to be easy to trigger with this patch, but
> still there without it.
> 
> Consider the case where only one zone has free_pages < pages_high,
> but all the pages in the LRU queue are from the other zone or not
> freeable (ie. with pagetable mapping)...
> 
> In those cases shrink_mmap() can loop forever. We probably want to
> add a "maxscan" variable, initialised to nr_lru_pages, which is
> decremented on every iteration through the loop to prevent us from
> triggering this bug.


This, I agree. And something I gave up trying to bring up earlier as well:
There should be some mechanism to check that enough pages have been examined
in the presence of pages from balanced zones.



--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
