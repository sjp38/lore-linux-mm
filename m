Received: from cs.utexas.edu (root@cs.utexas.edu [128.83.139.9])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA16222
	for <linux-mm@kvack.org>; Sat, 9 Jan 1999 21:01:36 -0500
Message-Id: <199901100201.UAA14684@feta.cs.utexas.edu>
From: "Paul R. Wilson" <wilson@cs.utexas.edu>
Date: Sat, 9 Jan 1999 20:01:20 -0600
Subject: eviction from shrink_mmap() (was re: 2.2.0-pre5)
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, riel@humbolt.geo.uu.nl
Cc: wilson@cs.utexas.edu
List-ID: <linux-mm.kvack.org>

[Rik:]
>while browsing the pre5 patch I saw quite a bit of
>VM changes that made a lot of sense, but there was
>one statement that really worried me (in vmscan.c)
>
>+        * NOTE NOTE NOTE! This should just set a
>+        * dirty bit in page_map, and just drop the
>+        * pte. All the hard work would be done by
>+        * shrink_mmap().
>+        *
>+        * That would get rid of a lot of problems.
>+        */
>
>Of course we should never do this since it would mean
>we'd loose the benefit of clustered swapout (and
>consequently clustered swapin).

I think Linus is right about this.

I pretty sure it's the right thing to do, if people
want to revamp the VM system a bit to make it more
elegant.

>The only way this could ever be implemented is by
>using a linked list of things-to-swap-out that:
>- is swapped out in the correct order and resorted
>  if needs be (to preserve or actually improve the
>  locality of reference in the swap area)
>- can never be longer than X entries, to avoid ending
>  up in all kinds of nasty situations

You are right that it will require something like this,
but it shouldn't be hard.

Here's the way I'd do it if I was feeling radical (and
competent as a kernel hacker).  (I'll suggesting something
simpler after sketching the righteous thing.)

radical version:

   * mark each page with some kind
     of unambiguous identifier, maybe the process ID (or some
     proxy for it, like a dummy inode) and the page offset
     within the VM address space.

   * run the kswapd/try_to_free_pages() clock significantly
     faster, and use the swap cache as an aging area for
     both clean and dirty pages. 

   * keep a FIFO queue of the stuff in the swap cache,
     so you don't need the secondary clock in shrink_mmap.
     (Maybe keep a timestamp on each page frame recording
     which kswapd clock cycle evicted it to the fifo.
     This could just be a few bits, and a crude timestamp
     could help in coordinating the main cache with 
     other caches & prefetching.)

   * use the FIFO queue as a reservoir of clean or
     cleanable pages, and clean pages opportunistically
     when the disk is idle for more than a few jiffies,
     to build up slack pages (clean, trivially freeable
     ones in the swap cache) ahead of crunch times

   * order the pages to be cleaned by whatever heuristic
     you like, probably including:

       1. PID, to avoid mixing pages that were touched
          by different processes which may only have
          been accidentally related.

       2. approximate time of last touch, to group
          pages that were touched together at about
          the same time

       3. nearness to each other in the virtual address
          ordering.
   
      I think #2 would work pretty well if the ages
      were known to about 2 bits of precision, but may
      not with a simple NUR (1-bit) clock---too many
      pages all look equally old.  That's why I think
      it's good to run the clock faster and use a
      FIFO back end, or timestamps, or both.

   The sorting of pages by these principles can be
   very, very fast.  Sorting by pid can be done by
   hashing, then sorting by crude time can also be
   done by hashing.  (Or if you don't bother with the
   timestamps, just grabbing the stuff at the end of
   the FIFO would do the same thing.)  This leaves only 
   sorting by address to a more general sort.

   That sorting can be a bucket sort, sorting pages by
   the middle bits of the page numbers first (fast constant
   time), and then separating out the things whose high
   bits are different within each bucket.

   For disk prefetching, you don't need to cluster things
   that are touched *very* closely together in time.  Given
   the timescales that virtual memory works at, almost any
   ordering will be as good as any other, so long as
   you group together things that are touched within
   a few million instruction cycles of each other---or
   a few hundred page faults of each other, whichever is
   worse.   A VM prefetch is a very good one if the page you
   fetch is one the next few hundred pages you would
   otherwise have faulted on.  Details of clustering are
   very non-critical as long as you have a passable
   predictor of what's touched "at about the same time"
   on the timescales of virtual memory replacement.

   I think the sorting could be done in about 25 to 50
   instructions per page, if you really wanted to bum
   instructions---we do tense things like that for fast
   compression algorithms, and I can explain how. (It's
   not at all complicated---you just have to know a
   couple of tricks.)   But that would be overkill.
   A couple of hundred instructions would be plenty fast,
   and easy to do cleanly and simply.

   (Once all this is done, you could dispense with the
   kswapd clock entirely, and use the shrink_mmap() clock
   to do all the work.  The clock over process address
   spaces is doing something very good---clustering
   related pages---but the architecture would be cleaner
   and more efficient if you just maintained page/process
   identities and let the swapper use and explicit heuristic
   for clustering.  Dispensing with the kswapd clock would
   require some kind of inverse pte map, but I really don't
   think the space costs should be significant---I'd be
   more worried about the implementation hassles.)

   This kind of architecture has important applications
   to per-process page allocation:

   This kind of arrangement would be very good for intelligent
   rss tradeoff stuff.  To decide which processes should get
   more or fewer pages, you have to know which ones are touching
   a lot of pages that have been evicted recently, and which ones
   are touching a lot of pages that would have been evicted if
   they had fewer page frames.

   To do that, you have to know roughly how old old each page
   is, to a few bits of precision, and what process it belongs
   to.  Then you can keep a couple of counters per process to
   tell you whether giving it more page frames would cut its
   fault rate significantly, or whether taking page frames away
   would increase its fault rate signficantly.  This lets you
   estimate the costs and benefits of taking pages away from a
   given process, or giving it more, and put the memory where
   it will do the most good.

   (We have a paper out on a similar technique that beats LRU
   at it's own game, even for a single process.   You notice
   when a process is touching more recently-evicted pages than
   soon-to-be evicted pages, which is where LRU screws up; 
   typically, that's for a loop over more data than will fit in
   RAM, so that you keep faulting on them shortly after evicting
   them.  In that case, you switch from LRU to something more like
   MRU---you evict part of the loop early so that other
   stuff can stay in "late."   Having a few bits of age
   information lets you detect the bad cases for LRU, and
   avoid using LRU when it would hose you.  Mostly our algorithm
   defaults to LRU, but occasionally notices the worst pitfall
   of LRU, and neatly avoids it.  This is a very hard game
   to play, because we're taking pages away from one process
   and giving them back to the *same* process.  Arbitrating
   between multiple processes with significantly different
   locality characteristics should be a lot easier, and get
   bigger improvements more often.)

Now for the simpler thing (maybe):

   Without bagging the current two-clock scheme, the first
   clock could record the order in which it reaches pages,
   so that the second (shrink_mmap()) clock could use it
   as a hint about eviction order.

   I think you could use the buffer list field of the page
   struct for this.  It's always zero for a normal swap page,
   so you could could add a "PG_has_buffers" flag to the flags
   field, and free up the buffer list field for ordering hints.

   This could be just a sequence number, giving the order
   in which the first clock swept through the page frames,
   i.e., the kswapd order.  In that case, you'd want to
   run the shrink_map clock fast enough to keep a list
   of evictable pages, which you could then sort on 
   (approximate) kswapd order.  

   Alternatively, kswapd could actually use the freed-up
   buffer list field of swappable pages to link swappable
   pages into an ordered list, which could be used by
   shrink_mmap() as an ordering directive or ordering
   hint.  The general version could use this ordering for
   shrink_mmap() to clock over, rather than using the mem_map
   array order, but that might require a backpointer field,
   too.

   (I think it'd be well worth it, because it'd allow the
   shrink_mmap() clock hand to "follow" the kswapd clock
   hand at a meaningful distance, giving a definite 
   FIFO effect, and a much more precise notion of page
   age---much better than any normal clock algorithm
   can provide.)

   If you don't want to go that way, you could use just the
   forward link set by kswapd as a hint to shrink_mmap(), 
   which would be used ONLY when it was about to evict
   a page, and only to eagerly look for other page frames
   holding evictable pages in kswapd() order.  That is,
   it would ignore the link field most of the time, but
   when it decides to evict a page to disk, it would scan
   ahead by those links to see if it finds other pages that
   it would normally evict whenever it happened to get
   to them in its usual scan order.

In general, I think that it's majoring in the minors to
worry about adding a field or two to the page struct.
If adding a link field would improve the architecture
by having a sane relationship between kswapd()
and shrink_mmap(), so be it.

Even adding 4 fields would only increase kernel memory usage
by 0.4 percent, which has a very small effect on miss rate. 
If making the arrangement more sane and elegant enables
*any* of several potentially useful improvements to the memory
management policy---a better approximation of LRU, smarter
clustering, smart rss arbitration between processes, compressed
paging, etc.---it's hard to imagine that it wouldn't be worth
it.  Even if it's not worth it, because none of that stuff gets
done and pans out, it just can't cost very much.  I think it's
worth the risk to make it cleaner.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
