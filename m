Date: Wed, 24 May 2000 12:11:35 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [RFC] 2.3/4 VM queues idea
Message-ID: <Pine.LNX.4.21.0005240833390.24993-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Dillon <dillon@apollo.backplane.com>, "Stephen C. Tweedie" <sct@redhat.com>, Arnaldo Carvalho de Melo <acme@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

Hi,

I've been talking with some people lately and have come up with
the following plan for short-term changes to the Linux VM subsystem.

The goals of this design:
- robustness, currently small changes to the design usually result
  in breaking VM performance for everybody and there doesn't seem
  to be any particular version of the VM subsystem which works right 
  for everybody ... having a design that is more robust to both
  changes and wildly variable workloads would be better
- somewhat better page aging
- making sure we always have a "buffer" around to do allocations
  from
- treat all pages in the system equally wrt. page aging and flushing
- keeping changes to the code base simple, since we're already
  at the 2.4-pre stage !!


	DESIGN IDEAS

- have three LRU queues instead of the current one queue
  - a cache/scavenge queue, which contains clean, unmapped pages
  - a laundry queue, which contains dirty, unmapped pages
  - an inactive queue, which contains both dirty and clean unmapped
    pages
  - an active queue, which contains active and/or mapped pages
- keep a decaying average of the number of allocations per second
  around
- try to keep about one second worth of allocations around in
  the inactive queue (we do 100 allocations/second -> at least
  100 inactive pages), we do this in order to:
  - get some aging in that queue (one second to be reclaimed)
  - have enough old pages around to free
- keep zone->pages_high of free pages + cache pages around,
  with at least pages_min of really free pages for atomic
  allocations   // FIXME: buddy fragmentation and defragmentation
- pages_min can be a lot lower than what it is now, since we only
  need to use pages from the free list for atomic allocations
- non-atomic allocations take a free page if we have a lot of free
  pages, they take a page from the cache queue otherwise
- when the number of free+cache pages gets too low:
  - scan the inactive queue
	- put clean pages on the cache list
	- put dirty pages on the laundry list
	- stop when we have enough cache pages
  - the page cleaner will clean the dirty pages asynchronously
    and put them on the cache list when they are clean
	- stop when we have no more dirty pages
	- if we have dirty pages, sync them to disk,
	  periodically scanning the list to see if
	  pages are clean now

(hmm, the page cleaning thing doesn't sound completely right ...
what should I change here?)


	CODE CHANGES

- try_to_swap_out() will no longer queue a swapout, but allocate
  the swap entry and mark the page dirty
- shrink_mmap() will be split into multiple functions
	- reclaim_cache() to reclaim pages from the cache list
	- kflushd (???) could get the task of laundering pages
	- reclaim_inactive() to move inactive pages to the cached
	  and dirty list
	- refill_inactive(), which scans the active list to refill
	  the inactive list and calls swap_out() if needed
	- kswapd will refill the free list by freeing pages it
	  gets using reclaim_cache()
- __alloc_pages() will call reclaim_cache() to fulfill non-atomic
  allocations and do rmqueue() if:
	- we're dealing with an atomic allocation, or
	- we have "too many" free pages
- if an inactive, laundry or cache page is faulted back into a
  process, we reactivate the page, move the page to the active
  list, adjust the statistics and wake up kswapd if needed

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
