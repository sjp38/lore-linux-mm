Date: Fri, 2 Jun 2000 15:53:08 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] (#2) VM kswapd autotuning vs. -ac7
Message-ID: <Pine.LNX.4.21.0006021544260.14259-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi Alan,

This patch improves a number of things over yesterday's
version:
- in do_try_to_free_pages, initialise swap_count to the number
  of pages we still have to free, this is more friendly to the
  running processes in the system and should improve IO performance
- also in do_try_to_free_pages, if both shrink_mmap *and* swap_out
  were having a hard time, we make the function more agressive ...
- "beautify" the async swap case in shrink_mmap  (thanks quintela)
- refine the kswapd_pause logic, now we waste less memory and
  swapping is a little bit smoother
- low-priority (niced, cpu hog, ...) processes will reschedule
  after waking up kswapd in very low memory situations, hopefully
  this will slow them down a bit under memory pressure, leading
  to less memory load

I've been stressing this test like crazy for the last few hours
and stuff seems to run fine.

[Under my .sig: 1) the patch  2) yesterday's message]

Regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

---------------------[ the patch ]-------------------------

--- linux-2.4.0-t1-ac7/fs/buffer.c.orig	Thu Jun  1 10:37:59 2000
+++ linux-2.4.0-t1-ac7/fs/buffer.c	Thu Jun  1 14:51:14 2000
@@ -1868,6 +1868,7 @@
 	}
 	
 	spin_unlock(&unused_list_lock);
+	wake_up(&buffer_wait);
 
 	return iosize;
 }
@@ -2004,6 +2005,8 @@
 		__put_unused_buffer_head(bh[bhind]);
 	}
 	spin_unlock(&unused_list_lock);
+	wake_up(&buffer_wait);
+
 	goto finished;
 }
 
@@ -2181,6 +2184,12 @@
 }
 
 /*
+ * Can the buffer be thrown out?
+ */
+#define BUFFER_BUSY_BITS	((1<<BH_Dirty) | (1<<BH_Lock) | (1<<BH_Protected))
+#define buffer_busy(bh)		(atomic_read(&(bh)->b_count) | ((bh)->b_state & BUFFER_BUSY_BITS))
+
+/*
  * Sync all the buffers on one page..
  *
  * If we have old buffers that are locked, we'll
@@ -2190,7 +2199,7 @@
  * This all is required so that we can free up memory
  * later.
  */
-static void sync_page_buffers(struct buffer_head *bh, int wait)
+static int sync_page_buffers(struct buffer_head *bh, int wait)
 {
 	struct buffer_head * tmp = bh;
 
@@ -2203,13 +2212,17 @@
 		} else if (buffer_dirty(p))
 			ll_rw_block(WRITE, 1, &p);
 	} while (tmp != bh);
-}
 
-/*
- * Can the buffer be thrown out?
- */
-#define BUFFER_BUSY_BITS	((1<<BH_Dirty) | (1<<BH_Lock) | (1<<BH_Protected))
-#define buffer_busy(bh)		(atomic_read(&(bh)->b_count) | ((bh)->b_state & BUFFER_BUSY_BITS))
+	do {
+		struct buffer_head *p = tmp;
+		tmp = tmp->b_this_page;
+		if (buffer_busy(p))
+			return 0;
+	} while (tmp != bh);
+
+	/* Success. Now try_to_free_buffers can free the page. */
+	return 1;
+}
 
 /*
  * try_to_free_buffers() checks if all the buffers on this particular page
@@ -2227,6 +2240,7 @@
 	struct buffer_head * tmp, * bh = page->buffers;
 	int index = BUFSIZE_INDEX(bh->b_size);
 
+again:
 	spin_lock(&lru_list_lock);
 	write_lock(&hash_table_lock);
 	spin_lock(&free_list[index].lock);
@@ -2272,7 +2286,8 @@
 	spin_unlock(&free_list[index].lock);
 	write_unlock(&hash_table_lock);
 	spin_unlock(&lru_list_lock);	
-	sync_page_buffers(bh, wait);
+	if (sync_page_buffers(bh, wait))
+		goto again;
 	return 0;
 }
 
--- linux-2.4.0-t1-ac7/mm/vmscan.c.orig	Wed May 31 14:08:50 2000
+++ linux-2.4.0-t1-ac7/mm/vmscan.c	Fri Jun  2 15:39:53 2000
@@ -439,12 +439,12 @@
  * latency.
  */
 #define FREE_COUNT	8
-#define SWAP_COUNT	16
 static int do_try_to_free_pages(unsigned int gfp_mask)
 {
 	int priority;
 	int count = FREE_COUNT;
 	int swap_count;
+	int ret = 0;
 
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
@@ -452,6 +452,7 @@
 	priority = 64;
 	do {
 		while (shrink_mmap(priority, gfp_mask)) {
+			ret = 1;
 			if (!--count)
 				goto done;
 		}
@@ -467,8 +468,10 @@
 			count -= shrink_dcache_memory(priority, gfp_mask);
 			count -= shrink_icache_memory(priority, gfp_mask);
 			if (count <= 0)
+				ret = 1;
 				goto done;
 			while (shm_swap(priority, gfp_mask)) {
+				ret = 1;
 				if (!--count)
 					goto done;
 			}
@@ -480,24 +483,28 @@
 		 * This will not actually free any pages (they get
 		 * put in the swap cache), so we must not count this
 		 * as a "count" success.
+		 *
+		 * The amount we page out is the amount of pages we're
+		 * short freeing.
 		 */
-		swap_count = SWAP_COUNT;
+		swap_count = count;
 		while (swap_out(priority, gfp_mask))
 			if (--swap_count < 0)
 				break;
+		/* It was difficult?  Push harder... */
+		count += swap_count;
 
 	} while (--priority >= 0);
 
 	/* Always end on a shrink_mmap.. */
 	while (shrink_mmap(0, gfp_mask)) {
+		ret = 1;
 		if (!--count)
 			goto done;
 	}
-	/* We return 1 if we are freed some page */
-	return (count != FREE_COUNT);
 
 done:
-	return 1;
+	return ret;
 }
 
 DECLARE_WAIT_QUEUE_HEAD(kswapd_wait);
--- linux-2.4.0-t1-ac7/mm/page_alloc.c.orig	Wed May 31 14:08:50 2000
+++ linux-2.4.0-t1-ac7/mm/page_alloc.c	Fri Jun  2 15:29:21 2000
@@ -222,6 +222,9 @@
 {
 	zone_t **zone = zonelist->zones;
 	extern wait_queue_head_t kswapd_wait;
+	static int last_woke_kswapd;
+	static int kswapd_pause = HZ;
+	int gfp_mask = zonelist->gfp_mask;
 
 	/*
 	 * (If anyone calls gfp from interrupts nonatomically then it
@@ -248,14 +251,28 @@
 		}
 	}
 
-	/* All zones are in need of kswapd. */
-	if (waitqueue_active(&kswapd_wait))
+	/*
+	 * Kswapd should be freeing enough memory to satisfy all allocations
+	 * immediately.  Calling try_to_free_pages from processes will slow
+	 * down the system a lot.  On the other hand, waking up kswapd too
+	 * often means wasted memory and cpu time.
+	 *
+	 * We tune the kswapd pause interval in such a way that kswapd is
+	 * always just agressive enough to free the amount of memory we
+	 * want freed.
+	 */
+	if (waitqueue_active(&kswapd_wait) &&
+			time_after(jiffies, last_woke_kswapd + kswapd_pause)) {
+		kswapd_pause++;
+		last_woke_kswapd = jiffies;
 		wake_up_interruptible(&kswapd_wait);
+	}
 
 	/*
 	 * Ok, we don't have any zones that don't need some
 	 * balancing.. See if we have any that aren't critical..
 	 */
+again:
 	zone = zonelist->zones;
 	for (;;) {
 		zone_t *z = *(zone++);
@@ -267,16 +284,29 @@
 				z->low_on_memory = 1;
 			if (page)
 				return page;
+		} else {
+			if (kswapd_pause > 0)
+				kswapd_pause--;
 		}
 	}
 
+	/* We didn't kick kswapd often enough... */
+	kswapd_pause /= 2;
+	if (waitqueue_active(&kswapd_wait))
+		wake_up_interruptible(&kswapd_wait);
+	/* If we're low priority, we just wait a bit and try again later. */
+	if ((gfp_mask & __GFP_WAIT) && current->need_resched &&
+				current->state == TASK_RUNNING) {
+		schedule();
+		goto again;
+	}
+
 	/*
 	 * Uhhuh. All the zones have been critical, which means that
 	 * we'd better do some synchronous swap-out. kswapd has not
 	 * been able to cope..
 	 */
 	if (!(current->flags & PF_MEMALLOC)) {
-		int gfp_mask = zonelist->gfp_mask;
 		if (!try_to_free_pages(gfp_mask)) {
 			if (!(gfp_mask & __GFP_HIGH))
 				goto fail;
@@ -303,7 +333,6 @@
 	zone = zonelist->zones;
 	for (;;) {
 		zone_t *z = *(zone++);
-		int gfp_mask = zonelist->gfp_mask;
 		if (!z)
 			break;
 		if (z->free_pages > z->pages_min) {
--- linux-2.4.0-t1-ac7/mm/filemap.c.orig	Wed May 31 14:08:50 2000
+++ linux-2.4.0-t1-ac7/mm/filemap.c	Fri Jun  2 15:42:25 2000
@@ -334,13 +334,6 @@
 
 		count--;
 		/*
-		 * Page is from a zone we don't care about.
-		 * Don't drop page cache entries in vain.
-		 */
-		if (page->zone->free_pages > page->zone->pages_high)
-			goto dispose_continue;
-
-		/*
 		 * Avoid unscalable SMP locking for pages we can
 		 * immediate tell are untouchable..
 		 */
@@ -375,6 +368,13 @@
 			}
 		}
 
+		/*
+		 * Page is from a zone we don't care about.
+		 * Don't drop page cache entries in vain.
+		 */
+		if (page->zone->free_pages > page->zone->pages_high)
+			goto unlock_continue;
+
 		/* Take the pagecache_lock spinlock held to avoid
 		   other tasks to notice the page while we are looking at its
 		   page count. If it's a pagecache-page we'll free it
@@ -400,8 +400,15 @@
 				goto made_inode_progress;
 			}
 			/* PageDeferswap -> we swap out the page now. */
-			if (gfp_mask & __GFP_IO)
-				goto async_swap_continue;
+			if (gfp_mask & __GFP_IO) {
+				spin_unlock(&pagecache_lock);
+				/* Do NOT unlock the page ... brw_page does. */
+				ClearPageDirty(page);
+				rw_swap_page(WRITE, page, 0);
+				spin_lock(&pagemap_lru_lock);
+				page_cache_release(page);
+				goto dispose_continue;
+			}
 			goto cache_unlock_continue;
 		}
 
@@ -422,14 +429,6 @@
 unlock_continue:
 		spin_lock(&pagemap_lru_lock);
 		UnlockPage(page);
-		page_cache_release(page);
-		goto dispose_continue;
-async_swap_continue:
-		spin_unlock(&pagecache_lock);
-		/* Do NOT unlock the page ... that is done after IO. */
-		ClearPageDirty(page);
-		rw_swap_page(WRITE, page, 0);
-		spin_lock(&pagemap_lru_lock);
 		page_cache_release(page);
 dispose_continue:
 		list_add(page_lru, &lru_cache);
--- linux-2.4.0-t1-ac7/include/linux/swap.h.orig	Wed May 31 21:00:06 2000
+++ linux-2.4.0-t1-ac7/include/linux/swap.h	Thu Jun  1 11:51:25 2000
@@ -166,7 +166,7 @@
  * The 2.4 code, however, is mostly simple and stable ;)
  */
 #define PG_AGE_MAX	64
-#define PG_AGE_START	5
+#define PG_AGE_START	2
 #define PG_AGE_ADV	3
 #define PG_AGE_DECL	1
 


----------------[ yesterday's message ]--------------------

this patch does the following things:
- move the starting page age to below the PG_AGE_ADV, so
  reclaimed pages have an advantage over pages which are
  new in the lru queue
- add two missing wake_up calls to buffer.c (I'm not 100%
  sure about these; I found them when digging through the
  classzone patch and they are consistent with other uses
  of the unused_list_lock
- if try_to_free_buffers waits on a page with buffers and
  succeeds in freeing them, return success (partly mined
  from classzone)
- __alloc_pages is responsible for waking up kswapd, however
  there seemed to be some flaws in the wakeup logic:
    - if kswapd is woken up too early, we free too much memory
      and waste CPU time
    - if kswapd is woken up too late, processes will call
      try_to_free_pages() themselves and stall; extremely
      bad for performance

The obvious solution is to have an auto-tuning algorithm where
the system tunes how often kswapd is woken up. To do that we
use the zone->zone_wake_kswapd and zone->low_on_memory flags.
Basically kswapd will always continue until no zone is low on
memory any more, sometimes resulting in one zone which has too
much free memory.

If we can keep all zones from being low on memory, allocations
can succeed immediately and applications can run fast. To ensure
that we must wake up kswapd often enough (but not too often).

The goal is to have every allocation happen in the second
"alloc loop" without any zones running low on memory. We achieve
this by waking up kswapd whenever we fall through the first loop
and it was longer than kswapd_pause ago that we last woke up
kswapd.

If we get a zone low on memory, we will half the value of
kswapd_pause so next time we'll wake up kswapd earlier. When
we never get low on memory, kswapd_pause will grow slowly over
time, balancing the halving of the period we did earlier.

I'm running some tests now and it seems that system performance
is good, kswapd overhead is quite a bit lower than before and
the amount of free memory is very stable (between freepages.low
and freepages.high, as it was called in 2.2 ;))

Please give this patch some exposure...

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
