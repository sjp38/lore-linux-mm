Message-ID: <3D73CB28.D2F7C7B0@zip.com.au>
Date: Mon, 02 Sep 2002 13:33:44 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: About the free page pool
References: <47FD65E3-BEAD-11D6-A3BE-000393829FA4@cs.amherst.edu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Scott Kaplan <sfkaplan@cs.amherst.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Scott Kaplan wrote:
> 
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Yet another question as I try to get a clear picture of the nitty-gritty
> details of the VM...
> 
> How important is it to maintain a list of free pages?  That is, how
> critical is it that there be some pool of free pages from which the only
> bookkeeping required is the removal of that page from the free list.

There are several reasons, all messy.

- We need to be able to allocate pages at interrupt time.  Mainly
  for networking receive.

  Similarly, we sometimes need to be able to allocate pages from under
  spinlocks.  In a context where we cannot legally take the locks or
  perform the functions which page reclaim wants to do.

- We sometimes need to allocate memory from *within* the context of
  page reclaim: find a dirty page on the LRU, need to write it out,
  need to allocate some memory to start the IO.  Where does that
  memory come from.

- The kernel frequently needs to perform higher-order allocations:
  two or more physically-contiguous pages.  The way we agglomerate
  0-order pages into higher-order pages is by coalescing them in the
  buddy.  If _all_ "free" pages are out on an LRU somewhere, we don't
  have a higher-order pool to draw from.

> In contrast, how awful would the following be:  Keep no free list, but
> instead ensure that some portion of the trailing end of the inactive list
> contains clean pages that are ready to be reclaimed.  When a free page is
> needed, just unmap that clean, inactive page and use *that* as your free
> page.  Clearly some more bookkeeping is required to unmap the page (assume
> that rmap is available to make that a straightforward task) than there
> would be simply to remove the page from the free list.  However, for every
> page on the free list, that unmapping work had to happen previously anyway.
> ..

It's feasible.  It'd take some work.  Probably it would best be implemented
via a third list.  That list would be protected by an IRQ-safe lock,
so reclaim from interrupt context would be OK.  The rmap unmapping code
would need to be interrupt-safe too (probably).  That's fairly straightforward,
but has subtleties between SMP and uniprocessor.  spin_trylock() doesn't do
anything on UP.

The higher-order page thing seems to be the biggest problem.

> Are there moments at which pages need to be allocated *so quickly* that
> unmapping the page at allocation time is too costly?  Or is there some
> other reason for maintaining a free list that I'm completely missing?

Interrupt-time allocations need to have minimum latency.  Incremental
latency in the page allocator will add directly to interrupt latency.
 
> Also, how large is the free list of pages now?  5% of the main memory
> space?  A fixed number of page frames?
> 

It's a ratio of the zone size, and there are a few thresholds in there,
for hysteresis, for emergency allocations, etc.  See free_area_init_core()
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
