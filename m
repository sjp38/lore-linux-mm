Date: Mon, 2 Oct 2000 00:42:47 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] fix for VM  test9-pre7
Message-ID: <Pine.LNX.4.21.0010020038090.30717-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.redhat.com
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

The attached patch seems to fix all the reported deadlock
problems with the new VM. Basically they could be grouped
into 2 categories:

1) __GFP_IO related locking issues
2) something sleeps on a free/clean/inactive page goal
   that isn't worked towards

The patch has survived some heavy stresstesting on both
SMP and UP machines. I hope nobody will be able to find
a way to still crash this one ;)

A second change is a more dynamic free memory target
(now freepages.high + inactive_target / 3), this seems
to help a little bit in some loads.

If your mailer messes up the patch, you can grab it from
http://www.surriel.com/patches/2.4.0-t9p7-vmpatch

Linus, if this patch turns out to work fine for the people
testing it, could you please apply it to your tree?

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/



--- linux-2.4.0-test9-pre7/fs/buffer.c.orig	Sat Sep 30 18:09:18 2000
+++ linux-2.4.0-test9-pre7/fs/buffer.c	Mon Oct  2 00:19:41 2000
@@ -706,7 +706,9 @@
 static void refill_freelist(int size)
 {
 	if (!grow_buffers(size)) {
-		try_to_free_pages(GFP_BUFFER);
+		wakeup_bdflush(1);
+		current->policy |= SCHED_YIELD;
+		schedule();
 	}
 }
 
@@ -859,6 +861,7 @@
 int balance_dirty_state(kdev_t dev)
 {
 	unsigned long dirty, tot, hard_dirty_limit, soft_dirty_limit;
+	int shortage;
 
 	dirty = size_buffers_type[BUF_DIRTY] >> PAGE_SHIFT;
 	tot = nr_free_buffer_pages();
@@ -869,21 +872,20 @@
 
 	/* First, check for the "real" dirty limit. */
 	if (dirty > soft_dirty_limit) {
-		if (dirty > hard_dirty_limit || inactive_shortage())
+		if (dirty > hard_dirty_limit)
 			return 1;
 		return 0;
 	}
 
 	/*
-	 * Then, make sure the number of inactive pages won't overwhelm
-	 * page replacement ... this should avoid stalls.
+	 * If we are about to get low on free pages and
+	 * cleaning the inactive_dirty pages would help
+	 * fix this, wake up bdflush.
 	 */
-	if (nr_inactive_dirty_pages >
-				nr_free_pages() + nr_inactive_clean_pages()) {
-		if (free_shortage() > freepages.min)
-			return 1;
+	if (free_shortage() && nr_inactive_dirty_pages > free_shortage() &&
+			nr_inactive_dirty_pages > freepages.high)
 		return 0;
-	}
+
 	return -1;
 }
 
@@ -2663,9 +2665,8 @@
 		CHECK_EMERGENCY_SYNC
 
 		flushed = flush_dirty_buffers(0);
-		if (nr_inactive_dirty_pages > nr_free_pages() +
-						nr_inactive_clean_pages())
-			flushed += page_launder(GFP_KSWAPD, 0);
+		if (free_shortage())
+			flushed += page_launder(GFP_BUFFER, 0);
 
 		/* If wakeup_bdflush will wakeup us
 		   after our bdflush_done wakeup, then
--- linux-2.4.0-test9-pre7/mm/filemap.c.orig	Sat Sep 30 18:16:28 2000
+++ linux-2.4.0-test9-pre7/mm/filemap.c	Mon Oct  2 00:11:45 2000
@@ -44,7 +44,6 @@
 atomic_t page_cache_size = ATOMIC_INIT(0);
 unsigned int page_hash_bits;
 struct page **page_hash_table;
-struct list_head lru_cache;
 
 spinlock_t pagecache_lock = SPIN_LOCK_UNLOCKED;
 /*
--- linux-2.4.0-test9-pre7/mm/page_alloc.c.orig	Sat Sep 30 18:16:28 2000
+++ linux-2.4.0-test9-pre7/mm/page_alloc.c	Mon Oct  2 00:31:15 2000
@@ -258,13 +258,13 @@
 		 */
 		switch (limit) {
 			default:
-			case 0:
+			case PAGES_MIN:
 				water_mark = z->pages_min;
 				break;
-			case 1:
+			case PAGES_LOW:
 				water_mark = z->pages_low;
 				break;
-			case 2:
+			case PAGES_HIGH:
 				water_mark = z->pages_high;
 		}
 
@@ -318,10 +318,19 @@
 		direct_reclaim = 1;
 
 	/*
-	 * Are we low on inactive pages?
+	 * If we are about to get low on free pages and we also have
+	 * an inactive page shortage, wake up kswapd.
 	 */
 	if (inactive_shortage() > inactive_target / 2 && free_shortage())
 		wakeup_kswapd(0);
+	/*
+	 * If we are about to get low on free pages and cleaning
+	 * the inactive_dirty pages would fix the situation,
+	 * wake up bdflush.
+	 */
+	else if (free_shortage() && nr_inactive_dirty_pages > free_shortage()
+			&& nr_inactive_dirty_pages > freepages.high)
+		wakeup_bdflush(0);
 
 try_again:
 	/*
@@ -378,8 +387,23 @@
 	 *
 	 * We wake up kswapd, in the hope that kswapd will
 	 * resolve this situation before memory gets tight.
+	 *
+	 * We also yield the CPU, because that:
+	 * - gives kswapd a chance to do something
+	 * - slows down allocations, in particular the
+	 *   allocations from the fast allocator that's
+	 *   causing the problems ...
+	 * - ... which minimises the impact the "bad guys"
+	 *   have on the rest of the system
+	 * - if we don't have __GFP_IO set, kswapd may be
+	 *   able to free some memory we can't free ourselves
 	 */
 	wakeup_kswapd(0);
+	if (gfp_mask & __GFP_WAIT) {
+		__set_current_state(TASK_RUNNING);
+		current->policy |= SCHED_YIELD;
+		schedule();
+	}
 
 	/*
 	 * After waking up kswapd, we try to allocate a page
@@ -440,28 +464,43 @@
 		 * up again. After that we loop back to the start.
 		 *
 		 * We have to do this because something else might eat
-		 * the memory kswapd frees for us (interrupts, other
-		 * processes, etc).
+		 * the memory kswapd frees for us and we need to be
+		 * reliable. Note that we don't loop back for higher
+		 * order allocations since it is possible that kswapd
+		 * simply cannot free a large enough contiguous area
+		 * of memory *ever*.
 		 */
-		if (gfp_mask & __GFP_WAIT) {
-			/*
-			 * Give other processes a chance to run:
-			 */
-			if (current->need_resched) {
-				__set_current_state(TASK_RUNNING);
-				schedule();
-			}
+		if (gfp_mask & (__GFP_WAIT|__GFP_IO) == (__GFP_WAIT|__GFP_IO)) {
+			wakeup_kswapd(1);
+			memory_pressure++;
+			if (!order)
+				goto try_again;
+		/*
+		 * If __GFP_IO isn't set, we can't wait on kswapd because
+		 * kswapd just might need some IO locks /we/ are holding ...
+		 *
+		 * SUBTLE: The scheduling point above makes sure that
+		 * kswapd does get the chance to free memory we can't
+		 * free ourselves...
+		 */
+		} else if (gfp_mask & __GFP_WAIT) {
 			try_to_free_pages(gfp_mask);
 			memory_pressure++;
-			goto try_again;
+			if (!order)
+				goto try_again;
 		}
+
 	}
 
 	/*
 	 * Final phase: allocate anything we can!
 	 *
-	 * This is basically reserved for PF_MEMALLOC and
-	 * GFP_ATOMIC allocations...
+	 * Higher order allocations, GFP_ATOMIC allocations and
+	 * recursive allocations (PF_MEMALLOC) end up here.
+	 *
+	 * Only recursive allocations can use the very last pages
+	 * in the system, otherwise it would be just too easy to
+	 * deadlock the system...
 	 */
 	zone = zonelist->zones;
 	for (;;) {
@@ -472,8 +511,21 @@
 		if (!z->size)
 			BUG();
 
+		/*
+		 * SUBTLE: direct_reclaim is only possible if the task
+		 * becomes PF_MEMALLOC while looping above. This will
+		 * happen when the OOM killer selects this task for
+		 * instant execution...
+		 */
 		if (direct_reclaim)
 			page = reclaim_page(z);
+		if (page)
+			return page;
+
+		/* XXX: is pages_min/4 a good amount to reserve for this? */
+		if (z->free_pages < z->pages_min / 4 &&
+				!(current->flags & PF_MEMALLOC))
+			continue;
 		if (!page)
 			page = rmqueue(z, order);
 		if (page)
@@ -481,8 +533,7 @@
 	}
 
 	/* No luck.. */
-	if (!order)
-		show_free_areas();
+	printk(KERN_ERR "__alloc_pages: %d-order allocation failed.\n", order);
 	return NULL;
 }
 
@@ -572,6 +623,13 @@
 	sum = nr_free_pages();
 	sum += nr_inactive_clean_pages();
 	sum += nr_inactive_dirty_pages;
+
+	/*
+	 * Keep our write behind queue filled, even if
+	 * kswapd lags a bit right now.
+	 */
+	if (sum < freepages.high + inactive_target)
+		sum = freepages.high + inactive_target;
 	/*
 	 * We don't want dirty page writebehind to put too
 	 * much pressure on the working set, but we want it
--- linux-2.4.0-test9-pre7/mm/swap.c.orig	Sat Sep 30 18:16:28 2000
+++ linux-2.4.0-test9-pre7/mm/swap.c	Sat Sep 30 20:49:27 2000
@@ -100,6 +100,15 @@
 		page->age = PAGE_AGE_MAX;
 }
 
+/*
+ * We use this (minimal) function in the case where we
+ * know we can't deactivate the page (yet).
+ */
+void age_page_down_ageonly(struct page * page)
+{
+	page->age /= 2;
+}
+
 void age_page_down_nolock(struct page * page)
 {
 	/* The actual page aging bit */
@@ -155,30 +164,39 @@
  */
 void deactivate_page_nolock(struct page * page)
 {
+	/*
+	 * One for the cache, one for the extra reference the
+	 * caller has and (maybe) one for the buffers.
+	 *
+	 * This isn't perfect, but works for just about everything.
+	 * Besides, as long as we don't move unfreeable pages to the
+	 * inactive_clean list it doesn't need to be perfect...
+	 */
+	int maxcount = (page->buffers ? 3 : 2);
 	page->age = 0;
 
 	/*
 	 * Don't touch it if it's not on the active list.
 	 * (some pages aren't on any list at all)
 	 */
-	if (PageActive(page) && (page_count(page) <= 2 || page->buffers) &&
+	if (PageActive(page) && page_count(page) <= maxcount &&
 			!page_ramdisk(page)) {
 
 		/*
 		 * We can move the page to the inactive_dirty list
-		 * if we know there is backing store available.
+		 * if we have the strong suspicion that they might
+		 * become freeable in the near future.
 		 *
-		 * We also move pages here that we cannot free yet,
-		 * but may be able to free later - because most likely
-		 * we're holding an extra reference on the page which
-		 * will be dropped right after deactivate_page().
+		 * That is, the page has buffer heads attached (that
+		 * need to be cleared away) and/or the function calling
+		 * us has an extra reference count on the page.
 		 */
 		if (page->buffers || page_count(page) == 2) {
 			del_page_from_active_list(page);
 			add_page_to_inactive_dirty_list(page);
 		/*
-		 * If the page is clean and immediately reusable,
-		 * we can move it to the inactive_clean list.
+		 * Only if we are SURE the page is clean and immediately
+		 * reusable, we move it to the inactive_clean list.
 		 */
 		} else if (page->mapping && !PageDirty(page) &&
 							!PageLocked(page)) {
@@ -215,6 +233,10 @@
 		 * not to do anything.
 		 */
 	}
+
+	/* Make sure the page gets a fair chance at staying active. */
+	if (page->age < PAGE_AGE_START)
+		page->age = PAGE_AGE_START;
 }
 
 void activate_page(struct page * page)
--- linux-2.4.0-test9-pre7/mm/vmscan.c.orig	Sat Sep 30 18:16:28 2000
+++ linux-2.4.0-test9-pre7/mm/vmscan.c	Sun Oct  1 19:19:56 2000
@@ -74,7 +74,8 @@
 		goto out_failed;
 	}
 	if (!onlist)
-		age_page_down(page);
+		/* The page is still mapped, so it can't be freeable... */
+		age_page_down_ageonly(page);
 
 	/*
 	 * If the page is in active use by us, or if the page
@@ -419,7 +420,7 @@
 				continue;
 			/* Skip tasks which haven't slept long enough yet when idle-swapping. */
 			if (idle_time && !assign && (!(p->state & TASK_INTERRUPTIBLE) ||
-					time_before(p->sleep_time + idle_time * HZ, jiffies)))
+					time_after(p->sleep_time + idle_time * HZ, jiffies)))
 				continue;
 			found_task++;
 			/* Refresh swap_cnt? */
@@ -536,6 +537,7 @@
 found_page:
 	del_page_from_inactive_clean_list(page);
 	UnlockPage(page);
+	page->age = PAGE_AGE_START;
 	if (page_count(page) != 1)
 		printk("VM: reclaim_page, found page with count %d!\n",
 				page_count(page));
@@ -565,22 +567,24 @@
  * This code is heavily inspired by the FreeBSD source code. Thanks
  * go out to Matthew Dillon.
  */
-#define MAX_SYNC_LAUNDER	(1 << page_cluster)
-#define MAX_LAUNDER 		(MAX_SYNC_LAUNDER * 4)
+#define MAX_LAUNDER 		(4 * (1 << page_cluster))
 int page_launder(int gfp_mask, int sync)
 {
-	int synclaunder, launder_loop, maxscan, cleaned_pages, maxlaunder;
+	int launder_loop, maxscan, cleaned_pages, maxlaunder;
+	int can_get_io_locks;
 	struct list_head * page_lru;
 	struct page * page;
 
+	/*
+	 * We can only grab the IO locks (eg. for flushing dirty
+	 * buffers to disk) if __GFP_IO is set.
+	 */
+	can_get_io_locks = gfp_mask & __GFP_IO;
+
 	launder_loop = 0;
-	synclaunder = 0;
 	maxlaunder = 0;
 	cleaned_pages = 0;
 
-	if (!(gfp_mask & __GFP_IO))
-		return 0;
-
 dirty_page_rescan:
 	spin_lock(&pagemap_lru_lock);
 	maxscan = nr_inactive_dirty_pages;
@@ -638,7 +642,7 @@
 			spin_unlock(&pagemap_lru_lock);
 
 			/* Will we do (asynchronous) IO? */
-			if (launder_loop && synclaunder-- > 0)
+			if (launder_loop && maxlaunder == 0 && sync)
 				wait = 2;	/* Synchrounous IO */
 			else if (launder_loop && maxlaunder-- > 0)
 				wait = 1;	/* Async IO */
@@ -725,10 +729,11 @@
 	 * loads, flush out the dirty pages before we have to wait on
 	 * IO.
 	 */
-	if (!launder_loop && free_shortage()) {
+	if (can_get_io_locks && !launder_loop && free_shortage()) {
 		launder_loop = 1;
-		if (sync && !cleaned_pages)
-			synclaunder = MAX_SYNC_LAUNDER;
+		/* If we cleaned pages, never do synchronous IO. */
+		if (cleaned_pages)
+			sync = 0;
 		/* We only do a few "out of order" flushes. */
 		maxlaunder = MAX_LAUNDER;
 		/* Kflushd takes care of the rest. */
@@ -774,8 +779,23 @@
 			age_page_up_nolock(page);
 			page_active = 1;
 		} else {
-			age_page_down_nolock(page);
-			page_active = 0;
+			age_page_down_ageonly(page);
+			/*
+			 * Since we don't hold a reference on the page
+			 * ourselves, we have to do our test a bit more
+			 * strict then deactivate_page(). This is needed
+			 * since otherwise the system could hang shuffling
+			 * unfreeable pages from the active list to the
+			 * inactive_dirty list and back again...
+			 *
+			 * SUBTLE: we can have buffer pages with count 1.
+			 */
+			if (page_count(page) <= (page->buffers ? 2 : 1)) {
+				deactivate_page_nolock(page);
+				page_active = 0;
+			} else {
+				page_active = 1;
+			}
 		}
 		/*
 		 * If the page is still on the active list, move it
@@ -805,14 +825,11 @@
 	pg_data_t *pgdat = pgdat_list;
 	int sum = 0;
 	int freeable = nr_free_pages() + nr_inactive_clean_pages();
+	int freetarget = freepages.high + inactive_target / 3;
 
-	/* Are we low on truly free pages? */
-	if (nr_free_pages() < freepages.min)
-		return freepages.high - nr_free_pages();
-
-	/* Are we low on free pages over-all? */
-	if (freeable < freepages.high)
-		return freepages.high - freeable;
+	/* Are we low on free pages globally? */
+	if (freeable < freetarget)
+		return freetarget - freeable;
 
 	/* If not, are we very low on any particular zone? */
 	do {
@@ -1052,14 +1069,7 @@
 			/* Do we need to do some synchronous flushing? */
 			if (waitqueue_active(&kswapd_done))
 				wait = 1;
-			if (!do_try_to_free_pages(GFP_KSWAPD, wait)) {
-				/*
-				 * if (out_of_memory()) {
-				 * 	try again a few times;
-				 * 	oom_kill();
-				 * }
-				 */
-			}
+			do_try_to_free_pages(GFP_KSWAPD, wait);
 		}
 
 		/*
@@ -1096,6 +1106,10 @@
 		 */
 		if (!free_shortage() || !inactive_shortage())
 			interruptible_sleep_on_timeout(&kswapd_wait, HZ);
+		/*
+		 * TODO: insert out of memory check & oom killer
+		 * invocation in an else branch here.
+		 */
 	}
 }
 
--- linux-2.4.0-test9-pre7/include/linux/swap.h.orig	Sat Sep 30 20:42:01 2000
+++ linux-2.4.0-test9-pre7/include/linux/swap.h	Sun Oct  1 15:35:03 2000
@@ -91,6 +91,7 @@
 extern void age_page_up_nolock(struct page *);
 extern void age_page_down(struct page *);
 extern void age_page_down_nolock(struct page *);
+extern void age_page_down_ageonly(struct page *);
 extern void deactivate_page(struct page *);
 extern void deactivate_page_nolock(struct page *);
 extern void activate_page(struct page *);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
