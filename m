Subject: Re: [RFC] 2.3/4 VM queues idea
References: <Pine.LNX.4.21.0005240833390.24993-100000@duckman.distro.conectiva>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Rik van Riel's message of "Wed, 24 May 2000 12:11:35 -0300 (BRST)"
Date: 25 May 2000 00:44:09 +0200
Message-ID: <ytt66s3muva.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, Matthew Dillon <dillon@apollo.backplane.com>, "Stephen C. Tweedie" <sct@redhat.com>, Arnaldo Carvalho de Melo <acme@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

>>>>> "rik" == Rik van Riel <riel@conectiva.com.br> writes:

Hi 

rik> The goals of this design:
rik> - robustness, currently small changes to the design usually result
rik>   in breaking VM performance for everybody and there doesn't seem
rik>   to be any particular version of the VM subsystem which works right 
rik>   for everybody ... having a design that is more robust to both
rik>   changes and wildly variable workloads would be better
rik> - somewhat better page aging
rik> - making sure we always have a "buffer" around to do allocations
rik>   from
rik> - treat all pages in the system equally wrt. page aging and
rik> flushing

This point is important, just now we are having a *lot* of problems
with dirty pages from mmaped files, we find dirty buffers in
shrink_mmap, we need to skip them, and wait that swap_out find them,
but it can be a lot of time before swap_out find them.  But that
moment they are at the end of the LRU list, then we found more dirty
pages, .... This process repeats until we begin to found the pages
that have been selected for swap_out, and have buffes entries.  In
that moment we send a *lot* of async disk writes to the disk, causing
the actuals slowdowns of until 5 seconds here.

rik> - keeping changes to the code base simple, since we're already
rik>   at the 2.4-pre stage !!

rik> 	DESIGN IDEAS

rik> - have three LRU queues instead of the current one queue
rik>   - a cache/scavenge queue, which contains clean, unmapped pages
rik>   - a laundry queue, which contains dirty, unmapped pages
rik>   - an inactive queue, which contains both dirty and clean unmapped
rik>     pages
rik>   - an active queue, which contains active and/or mapped pages

This are four queues :)

rik> - keep a decaying average of the number of allocations per second
rik>   around
rik> - try to keep about one second worth of allocations around in
rik>   the inactive queue (we do 100 allocations/second -> at least
rik>   100 inactive pages), we do this in order to:
rik>   - get some aging in that queue (one second to be reclaimed)
rik>   - have enough old pages around to free
rik> - keep zone->pages_high of free pages + cache pages around,
rik>   with at least pages_min of really free pages for atomic
rik>   allocations   // FIXME: buddy fragmentation and defragmentation
rik> - pages_min can be a lot lower than what it is now, since we only
rik>   need to use pages from the free list for atomic allocations
rik> - non-atomic allocations take a free page if we have a lot of free
rik>   pages, they take a page from the cache queue otherwise
rik> - when the number of free+cache pages gets too low:
rik>   - scan the inactive queue
rik> 	- put clean pages on the cache list
rik> 	- put dirty pages on the laundry list
rik> 	- stop when we have enough cache pages
rik>   - the page cleaner will clean the dirty pages asynchronously
rik>     and put them on the cache list when they are clean
rik> 	- stop when we have no more dirty pages
rik> 	- if we have dirty pages, sync them to disk,
rik> 	  periodically scanning the list to see if
rik> 	  pages are clean now

we need to be able to write pages syncronously to disk if they are
dirty, there are no free pages around, and we can sleep.

Other question, who do you write the pages from the laundry disk to
disk if they are dirty pages, not dirty buffers.  You need to look at
the ptes to be able to do a swap_entry.  Or I am loosing something
evident here?

rik> 	CODE CHANGES

rik> - try_to_swap_out() will no longer queue a swapout, but allocate
rik>   the swap entry and mark the page dirty
rik> - shrink_mmap() will be split into multiple functions
rik> 	- reclaim_cache() to reclaim pages from the cache list
rik> 	- kflushd (???) could get the task of laundering pages
rik> 	- reclaim_inactive() to move inactive pages to the cached
rik> 	  and dirty list
              laundry 
rik> 	- refill_inactive(), which scans the active list to refill
rik> 	  the inactive list and calls swap_out() if needed
rik> 	- kswapd will refill the free list by freeing pages it
rik> 	  gets using reclaim_cache()
rik> - __alloc_pages() will call reclaim_cache() to fulfill non-atomic
rik>   allocations and do rmqueue() if:
rik> 	- we're dealing with an atomic allocation, or
rik> 	- we have "too many" free pages
rik> - if an inactive, laundry or cache page is faulted back into a
rik>   process, we reactivate the page, move the page to the active
rik>   list, adjust the statistics and wake up kswapd if needed

I continue with my problem, how do you write one page for the dirty
page that has not a swap_entry defined.

I think that the desing is quite right, but I have that problem just
now with the current design, we jump over dirty pages in shrink_mmap
due to the fact that we don't know what to do with them, I see the
same problem here.

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
