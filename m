Date: Tue, 8 Aug 2000 18:00:44 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [prePATCH] new VM for 2.4.0-test6-pre*
Message-ID: <Pine.LNX.4.21.0008081757050.5200-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

here is an early version of the new VM patch for 2.4.
The patch mostly works but has some issues left...

What it changes:
- adds page aging
- adds inactive_dirty and inactive_clean queues
- __alloc_pages can directly reclaim inactive_clean pages
- dynamic inactive target

What doesn't work right (probably related):
- kswapd uses far too much CPU time
- sometimes the system cannot age the active pages fast
  enough to refill the inactive queues

The patch is in an early stage because it doesn't work
(well) under heavy VM loads, but the basic structure
seems to be all-right ... primarily because of careful
design and very defensive coding.

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/



--- linux-2.4.0-t6-p1/fs/proc/proc_misc.c.orig	Thu Aug  3 20:22:29 2000
+++ linux-2.4.0-t6-p1/fs/proc/proc_misc.c	Tue Aug  8 16:27:11 2000
@@ -156,22 +156,30 @@
          * have been updated.
          */
         len += sprintf(page+len,
-                "MemTotal:  %8lu kB\n"
-                "MemFree:   %8lu kB\n"
-                "MemShared: %8lu kB\n"
-                "Buffers:   %8lu kB\n"
-                "Cached:    %8u kB\n"
-                "HighTotal: %8lu kB\n"
-                "HighFree:  %8lu kB\n"
-                "LowTotal:  %8lu kB\n"
-                "LowFree:   %8lu kB\n"
-                "SwapTotal: %8lu kB\n"
-                "SwapFree:  %8lu kB\n",
+                "MemTotal:     %8lu kB\n"
+                "MemFree:      %8lu kB\n"
+                "MemShared:    %8lu kB\n"
+                "Buffers:      %8lu kB\n"
+                "Cached:       %8lu kB\n"
+		"Active:       %8lu kB\n"
+		"Inact_dirty:  %8lu kB\n"
+		"Inact_clean:  %8lu kB\n"
+		"Inact_target: %8lu kB\n"
+                "HighTotal:    %8lu kB\n"
+                "HighFree:     %8lu kB\n"
+                "LowTotal:     %8lu kB\n"
+                "LowFree:      %8lu kB\n"
+                "SwapTotal:    %8lu kB\n"
+                "SwapFree:     %8lu kB\n",
                 K(i.totalram),
                 K(i.freeram),
                 K(i.sharedram),
                 K(i.bufferram),
                 K(atomic_read(&page_cache_size)),
+		K(nr_active_pages),
+		K(nr_inactive_dirty_pages),
+		K(nr_free_pages()),
+		K(inactive_target),
                 K(i.totalhigh),
                 K(i.freehigh),
                 K(i.totalram-i.totalhigh),
--- linux-2.4.0-t6-p1/mm/filemap.c.orig	Thu Aug  3 19:37:24 2000
+++ linux-2.4.0-t6-p1/mm/filemap.c	Tue Aug  8 12:52:40 2000
@@ -46,7 +46,7 @@
 struct page **page_hash_table;
 struct list_head lru_cache;
 
-static spinlock_t pagecache_lock = SPIN_LOCK_UNLOCKED;
+spinlock_t pagecache_lock = SPIN_LOCK_UNLOCKED;
 /*
  * NOTE: to avoid deadlocking you must never acquire the pagecache_lock with
  *       the pagemap_lru_lock held.
@@ -92,7 +92,7 @@
  * sure the page is locked and that nobody else uses it - or that usage
  * is safe.
  */
-static inline void __remove_inode_page(struct page *page)
+void __remove_inode_page(struct page *page)
 {
 	remove_page_from_inode_queue(page);
 	remove_page_from_hash_queue(page);
@@ -245,135 +245,6 @@
 	spin_unlock(&pagecache_lock);
 }
 
-/*
- * nr_dirty represents the number of dirty pages that we will write async
- * before doing sync writes.  We can only do sync writes if we can
- * wait for IO (__GFP_IO set).
- */
-int shrink_mmap(int priority, int gfp_mask)
-{
-	int ret = 0, count, nr_dirty;
-	struct list_head * page_lru;
-	struct page * page = NULL;
-	
-	count = nr_lru_pages / (priority + 1);
-	nr_dirty = priority;
-
-	/* we need pagemap_lru_lock for list_del() ... subtle code below */
-	spin_lock(&pagemap_lru_lock);
-	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
-		page = list_entry(page_lru, struct page, lru);
-		list_del(page_lru);
-
-		if (PageTestandClearReferenced(page))
-			goto dispose_continue;
-
-		count--;
-		/*
-		 * Avoid unscalable SMP locking for pages we can
-		 * immediate tell are untouchable..
-		 */
-		if (!page->buffers && page_count(page) > 1)
-			goto dispose_continue;
-
-		if (TryLockPage(page))
-			goto dispose_continue;
-
-		/* Release the pagemap_lru lock even if the page is not yet
-		   queued in any lru queue since we have just locked down
-		   the page so nobody else may SMP race with us running
-		   a lru_cache_del() (lru_cache_del() always run with the
-		   page locked down ;). */
-		spin_unlock(&pagemap_lru_lock);
-
-		/* avoid freeing the page while it's locked */
-		page_cache_get(page);
-
-		/*
-		 * Is it a buffer page? Try to clean it up regardless
-		 * of zone - it's old.
-		 */
-		if (page->buffers) {
-			int wait = ((gfp_mask & __GFP_IO) && (nr_dirty-- < 0));
-			if (!try_to_free_buffers(page, wait))
-				goto unlock_continue;
-			/* page was locked, inode can't go away under us */
-			if (!page->mapping) {
-				atomic_dec(&buffermem_pages);
-				goto made_buffer_progress;
-			}
-		}
-
-		/* Take the pagecache_lock spinlock held to avoid
-		   other tasks to notice the page while we are looking at its
-		   page count. If it's a pagecache-page we'll free it
-		   in one atomic transaction after checking its page count. */
-		spin_lock(&pagecache_lock);
-
-		/*
-		 * We can't free pages unless there's just one user
-		 * (count == 2 because we added one ourselves above).
-		 */
-		if (page_count(page) != 2)
-			goto cache_unlock_continue;
-
-		/*
-		 * Is it a page swap page? If so, we want to
-		 * drop it if it is no longer used, even if it
-		 * were to be marked referenced..
-		 */
-		if (PageSwapCache(page)) {
-			spin_unlock(&pagecache_lock);
-			__delete_from_swap_cache(page);
-			goto made_inode_progress;
-		}	
-
-		/*
-		 * Page is from a zone we don't care about.
-		 * Don't drop page cache entries in vain.
-		 */
-		if (page->zone->free_pages > page->zone->pages_high)
-			goto cache_unlock_continue;
-
-		/* is it a page-cache page? */
-		if (page->mapping) {
-			if (!PageDirty(page) && !pgcache_under_min()) {
-				__remove_inode_page(page);
-				spin_unlock(&pagecache_lock);
-				goto made_inode_progress;
-			}
-			goto cache_unlock_continue;
-		}
-
-		printk(KERN_ERR "shrink_mmap: unknown LRU page!\n");
-
-cache_unlock_continue:
-		spin_unlock(&pagecache_lock);
-unlock_continue:
-		spin_lock(&pagemap_lru_lock);
-		UnlockPage(page);
-		page_cache_release(page);
-dispose_continue:
-		list_add(page_lru, &lru_cache);
-	}
-	goto out;
-
-made_inode_progress:
-	page_cache_release(page);
-made_buffer_progress:
-	UnlockPage(page);
-	page_cache_release(page);
-	ret = 1;
-	spin_lock(&pagemap_lru_lock);
-	/* nr_lru_pages needs the spinlock */
-	nr_lru_pages--;
-
-out:
-	spin_unlock(&pagemap_lru_lock);
-
-	return ret;
-}
-
 static inline struct page * __find_page_nolock(struct address_space *mapping, unsigned long offset, struct page *page)
 {
 	goto inside;
@@ -388,7 +259,15 @@
 		if (page->index == offset)
 			break;
 	}
-	SetPageReferenced(page);
+	/*
+	 * Touching the page may move it to the active list.
+	 * If we end up with too few inactive pages, we wake
+	 * up kswapd.
+	 */
+	age_page_up(page, 0);
+	if ((inactive_shortage() > inactive_target / 2) &&
+				waitqueue_active(&kswapd_wait))
+		wake_up_interruptible(&kswapd_wait);
 not_found:
 	return page;
 }
--- linux-2.4.0-t6-p1/mm/memory.c.orig	Thu Aug  3 19:37:24 2000
+++ linux-2.4.0-t6-p1/mm/memory.c	Tue Aug  8 06:43:45 2000
@@ -1033,7 +1033,8 @@
 	num = valid_swaphandles(entry, &offset);
 	for (i = 0; i < num; offset++, i++) {
 		/* Don't block on I/O for read-ahead */
-		if (atomic_read(&nr_async_pages) >= pager_daemon.swap_cluster) {
+		if (atomic_read(&nr_async_pages) >= pager_daemon.swap_cluster
+				* (1 << page_cluster)) {
 			while (i++ < num)
 				swap_free(SWP_ENTRY(SWP_TYPE(entry), offset++));
 			break;
--- linux-2.4.0-t6-p1/mm/page_alloc.c.orig	Thu Aug  3 19:37:24 2000
+++ linux-2.4.0-t6-p1/mm/page_alloc.c	Tue Aug  8 16:18:29 2000
@@ -25,7 +25,8 @@
 #endif
 
 int nr_swap_pages;
-int nr_lru_pages;
+int nr_active_pages;
+int nr_inactive_dirty_pages;
 pg_data_t *pgdat_list;
 
 static char *zone_names[MAX_NR_ZONES] = { "DMA", "Normal", "HighMem" };
@@ -33,6 +34,8 @@
 static int zone_balance_min[MAX_NR_ZONES] = { 10 , 10, 10, };
 static int zone_balance_max[MAX_NR_ZONES] = { 255 , 255, 255, };
 
+struct list_head active_list;
+struct list_head inactive_dirty_list;
 /*
  * Free_page() adds the page to the free lists. This is optimized for
  * fast normal cases (no error jumps taken normally).
@@ -96,7 +99,16 @@
 		BUG();
 	if (PageDirty(page))
 		BUG();
+	if (PageActive(page))
+		BUG();
+	if (PageInactiveDirty(page))
+		BUG();
+	if (PageInactiveClean(page))
+		BUG();
 
+	page->flags &= ~(1<<PG_referenced);
+	page->age = PAGE_AGE_START;
+	
 	zone = page->zone;
 
 	mask = (~0UL) << order;
@@ -142,10 +154,13 @@
 
 	spin_unlock_irqrestore(&zone->lock, flags);
 
-	if (zone->free_pages > zone->pages_high) {
-		zone->zone_wake_kswapd = 0;
-		zone->low_on_memory = 0;
-	}
+	/*
+	 * We don't want to protect this variable from race conditions
+	 * since it's nothing important, but we do want to make sure
+	 * it never gets negative.
+	 */
+	if (memory_pressure > NR_CPUS)
+		memory_pressure--;
 }
 
 #define MARK_USED(index, order, area) \
@@ -219,7 +234,10 @@
 struct page * __alloc_pages(zonelist_t *zonelist, unsigned long order)
 {
 	zone_t **zone;
-	extern wait_queue_head_t kswapd_wait;
+	int direct_reclaim = 0;
+	unsigned int gfp_mask = zonelist->gfp_mask;
+
+	memory_pressure++;
 
 	/*
 	 * (If anyone calls gfp from interrupts nonatomically then it
@@ -229,6 +247,28 @@
 	 * in a higher zone fails.
 	 */
 
+	/*
+	 * Can we take pages directly from the inactive_clean
+	 * list?
+	 */
+	if (order == 0 && (gfp_mask & __GFP_WAIT) &&
+			!(current->flags & PF_MEMALLOC))
+		direct_reclaim = 1;
+
+	/*
+	 * Are we low on inactive pages?
+	 */
+	if ((inactive_shortage() > (inactive_target / 2) ||
+			free_shortage() > (freepages.min / 2)) &&
+			waitqueue_active(&kswapd_wait))
+		wake_up_interruptible(&kswapd_wait);
+
+	/*
+	 * First, look for zones with large amounts of free
+	 * pages. We start allocating here because inactive
+	 * pages still contain useful data, whereas free pages
+	 * do not.
+	 */
 	zone = zonelist->zones;
 	for (;;) {
 		zone_t *z = *(zone++);
@@ -236,48 +276,106 @@
 			break;
 		if (!z->size)
 			BUG();
-
-		/* Are we supposed to free memory? Don't make it worse.. */
-		if (!z->zone_wake_kswapd) {
+		if (z->free_pages > z->pages_min) {
 			struct page *page = rmqueue(z, order);
-			if (z->free_pages < z->pages_low) {
-				z->zone_wake_kswapd = 1;
-				if (waitqueue_active(&kswapd_wait))
-					wake_up_interruptible(&kswapd_wait);
+			if (page)
+				return page;
+		}
+	}
+
+	/*
+	 * Now look at zones which have a high amount of
+	 * free + inactive_clean pages. This is a real
+	 * possibility because of the dynamic inactive_target.
+	 * When there's a lot of VM activity, the inactive_target
+	 * will be high and some zones will have a lot of pages
+	 * on their inactive_clean list. In that situation, most
+	 * allocations will succeed here and the >zone->pages_high
+	 * test will be effective in balancing activity between zones.
+	 */
+	zone = zonelist->zones;
+	for (;;) {
+		zone_t *z = *(zone++);
+		if (!z)
+			break;
+		if (!z->size)
+			BUG();
+
+		/*
+		 * If the zone is low on free pages, wake up kswapd.
+		 * This is needed to keep atomic allocations going.
+		 */
+		if ((z->free_pages < z->pages_min / 2) &&
+				waitqueue_active(&kswapd_wait))
+			wake_up_interruptible(&kswapd_wait);
+
+		if (z->free_pages + z->inactive_clean_pages > z->pages_high) {
+			struct page * page = NULL;
+			if (direct_reclaim && z->inactive_clean_pages) {
+				page = reclaim_page(z);
+			} else {
+				page = rmqueue(z, order);
 			}
 			if (page)
 				return page;
 		}
 	}
 
-	/* Three possibilities to get here
-	 * - Previous alloc_pages resulted in last zone set to have
-	 *   zone_wake_kswapd and start it. kswapd has not been able
-	 *   to release enough pages so that one zone does not have
-	 *   zone_wake_kswapd set.
-	 * - Different sets of zones (zonelist)
-	 *   previous did not have all zones with zone_wake_kswapd but
-	 *   this one has... should kswapd be woken up? it will run once.
-	 * - SMP race, kswapd went to sleep slightly after it as running
-	 *   in 'if (waitqueue_active(...))' above.
-	 * + anyway the test is very cheap to do...
+	/*
+	 * Now look for zones with a decent amount of free +
+	 * inactive_clean pages. When there is little VM activity,
+	 * the inactive_target will be very low and most of the
+	 * allocations should succeed here.
+	 */
+	zone = zonelist->zones;
+	for (;;) {
+		zone_t *z = *(zone++);
+		if (!z)
+			break;
+		if (!z->size)
+			BUG();
+
+		if (z->free_pages + z->inactive_clean_pages > z->pages_low) {
+			struct page * page = NULL;
+			if (direct_reclaim && z->inactive_clean_pages) {
+				page = reclaim_page(z);
+			} else {
+				page = rmqueue(z, order);
+			}
+			if (page)
+				return page;
+		}
+	}
+
+	/*
+	 * OK, none of the zones has lots of pages free.
+	 * We wake up kswapd, which should solve this
+	 * in the background. 
 	 */
 	if (waitqueue_active(&kswapd_wait))
 		wake_up_interruptible(&kswapd_wait);
 
 	/*
-	 * Ok, we don't have any zones that don't need some
-	 * balancing.. See if we have any that aren't critical..
+	 * All zones need balancing, look for a zone that
+	 * isn't critical. Hopefully kswapd will rebalance
+	 * some zones in the background before we start
+	 * failing here...
 	 */
 	zone = zonelist->zones;
 	for (;;) {
 		zone_t *z = *(zone++);
 		if (!z)
 			break;
-		if (!z->low_on_memory) {
-			struct page *page = rmqueue(z, order);
-			if (z->free_pages < z->pages_min)
-				z->low_on_memory = 1;
+		if (!z->size)
+			BUG();
+
+		if (z->free_pages + z->inactive_clean_pages > z->pages_min) {
+			struct page * page = NULL;
+			if (direct_reclaim && z->inactive_clean_pages) {
+				page = reclaim_page(z);
+			} else {
+				page = rmqueue(z, order);
+			}
 			if (page)
 				return page;
 		}
@@ -285,13 +383,52 @@
 
 	/*
 	 * Uhhuh. All the zones have been critical, which means that
-	 * we'd better do some synchronous swap-out. kswapd has not
+	 * we'd better do some synchronous swap-out. Kswapd has not
 	 * been able to cope..
 	 */
 	if (!(current->flags & PF_MEMALLOC)) {
-		int gfp_mask = zonelist->gfp_mask;
-		if (!try_to_free_pages(gfp_mask)) {
-			if (!(gfp_mask & __GFP_HIGH))
+		/*
+		 * Are we dealing with a higher order allocation?
+		 * If so, our allocation may well be failing because
+		 * we don't have enough contiguous free pages.
+		 *
+		 * A solution is to move pages from the inactive_clean
+		 * list to the free list until we do have enough free
+		 * contiguous pages for the allocation to succeed.
+		 */
+		if (order > 0 && (gfp_mask & __GFP_WAIT)) {
+			zone = zonelist->zones;
+			/* First, clean some dirty pages. */
+			page_launder(gfp_mask, 1);
+			for (;;) {
+				zone_t *z = *(zone++);
+				if (!z)
+					break;
+				if (!z->size)
+					continue;
+				while (z->inactive_clean_pages) {
+					struct page * page;
+					/* Move one page to the free list. */
+					page = reclaim_page(z);
+					if (!page)
+						break;
+					__free_page(page);
+					/* Try if the allocation succeeds. */
+					page = rmqueue(z, order);
+					if (page)
+						return page;
+				}
+			}
+		}
+		/*
+		 * Try to free pages ourselves, since kswapd wasn't
+		 * fast enough for us.
+		 */
+		if (gfp_mask & __GFP_WAIT) {
+			int ret = 0;
+			ret = try_to_free_pages(gfp_mask);
+			ret += page_launder(gfp_mask, 1);
+			if (!ret && !(gfp_mask & __GFP_HIGH))
 				goto fail;
 		}
 	}
@@ -301,12 +438,18 @@
 	 */
 	zone = zonelist->zones;
 	for (;;) {
-		struct page *page;
-
 		zone_t *z = *(zone++);
+		struct page * page = NULL;
 		if (!z)
 			break;
-		page = rmqueue(z, order);
+		if (!z->size)
+			BUG();
+
+		if (direct_reclaim && z->inactive_clean_pages) {
+			page = reclaim_page(z);
+		} else if (z->free_pages) {
+			page = rmqueue(z, order);
+		}
 		if (page)
 			return page;
 	}
@@ -373,6 +516,7 @@
 	for (i = 0; i < NUMNODES; i++)
 		for (zone = NODE_DATA(i)->node_zones; zone < NODE_DATA(i)->node_zones + MAX_NR_ZONES; zone++)
 			sum += zone->free_pages;
+			sum += zone->inactive_clean_pages;
 	return sum;
 }
 
@@ -381,14 +525,11 @@
  */
 unsigned int nr_free_buffer_pages (void)
 {
-	unsigned int sum;
-	zone_t *zone;
-	int i;
+	int sum;
+
+	sum = nr_free_pages();
+	sum += nr_inactive_dirty_pages / 4;
 
-	sum = nr_lru_pages;
-	for (i = 0; i < NUMNODES; i++)
-		for (zone = NODE_DATA(i)->node_zones; zone <= NODE_DATA(i)->node_zones+ZONE_NORMAL; zone++)
-			sum += zone->free_pages;
 	return sum;
 }
 
@@ -418,9 +559,10 @@
 		nr_free_pages() << (PAGE_SHIFT-10),
 		nr_free_highpages() << (PAGE_SHIFT-10));
 
-	printk("( Free: %d, lru_cache: %d (%d %d %d) )\n",
+	printk("( Active: %d, inactive_dirty: %d, free: %d (%d %d %d) )\n",
+		nr_active_pages,
+		nr_inactive_dirty_pages,
 		nr_free_pages(),
-		nr_lru_pages,
 		freepages.min,
 		freepages.low,
 		freepages.high);
@@ -561,7 +703,8 @@
 	freepages.min += i;
 	freepages.low += i * 2;
 	freepages.high += i * 3;
-	memlist_init(&lru_cache);
+	memlist_init(&active_list);
+	memlist_init(&inactive_dirty_list);
 
 	/*
 	 * Some architectures (with lots of mem and discontinous memory
@@ -607,6 +750,9 @@
 		zone->lock = SPIN_LOCK_UNLOCKED;
 		zone->zone_pgdat = pgdat;
 		zone->free_pages = 0;
+		zone->inactive_clean_pages = 0;
+		zone->inactive_dirty_pages = 0;
+		memlist_init(&zone->inactive_clean_list);
 		if (!size)
 			continue;
 
@@ -620,8 +766,6 @@
 		zone->pages_min = mask;
 		zone->pages_low = mask*2;
 		zone->pages_high = mask*3;
-		zone->low_on_memory = 0;
-		zone->zone_wake_kswapd = 0;
 		zone->zone_mem_map = mem_map + offset;
 		zone->zone_start_mapnr = offset;
 		zone->zone_start_paddr = zone_start_paddr;
--- linux-2.4.0-t6-p1/mm/page_io.c.orig	Thu Aug  3 19:37:24 2000
+++ linux-2.4.0-t6-p1/mm/page_io.c	Tue Aug  8 06:44:31 2000
@@ -43,7 +43,8 @@
 	struct inode *swapf = 0;
 
 	/* Don't allow too many pending pages in flight.. */
-	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster)
+	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster *
+			(1 << page_cluster))
 		wait = 1;
 
 	if (rw == READ) {
--- linux-2.4.0-t6-p1/mm/swap.c.orig	Thu Aug  3 19:37:24 2000
+++ linux-2.4.0-t6-p1/mm/swap.c	Tue Aug  8 07:30:14 2000
@@ -40,7 +40,18 @@
 };
 
 /* How many pages do we try to swap or page in/out together? */
-int page_cluster = 4; /* Default value modified in swap_setup() */
+int page_cluster;
+
+/*
+ * This variable contains the amount of page steals the system
+ * is doing, averaged over a minute. We use this to determine how
+ * many inactive pages we should have.
+ *
+ * In reclaim_page and __alloc_pages: memory_pressure++
+ * In __free_pages_ok: memory_pressure--
+ * In recalculate_vm_stats the value is decayed (once a second)
+ */
+int memory_pressure;
 
 /* We track the number of pages currently being asynchronously swapped
    out, so that we don't try to swap TOO many pages out at once */
@@ -61,13 +72,229 @@
 pager_daemon_t pager_daemon = {
 	512,	/* base number for calculating the number of tries */
 	SWAP_CLUSTER_MAX,	/* minimum number of tries */
-	SWAP_CLUSTER_MAX,	/* do swap I/O in clusters of this size */
+	8,	/* do swap I/O in clusters of this size */
 };
 
+/**
+ * age_page_{up,down} - page aging helper functions
+ * @page - the page we want to age
+ * @nolock - are we already holding the pagelist_lru_lock?
+ *
+ * If the page is on one of the lists (active, inactive_dirty or
+ * inactive_clean), we will grab the pagelist_lru_lock as needed.
+ * If you're already holding the lock, call this function with the
+ * nolock argument non-zero.
+ */
+void age_page_up(struct page * page, int nolock)
+{
+	/*
+	 * We're dealing with an inactive page, move the page
+	 * to the active list.
+	 */
+	if (!page->age)
+		activate_page(page, nolock);
+
+	/* The actual page aging bit */
+	page->age += PAGE_AGE_ADV;
+	if (page->age > PAGE_AGE_MAX)
+		page->age = PAGE_AGE_MAX;
+}
+
+void age_page_down(struct page * page, int nolock)
+{
+	/* The actual page aging bit */
+	page->age /= 2;
+
+	/*
+	 * The page is now an old page. Move to the inactive
+	 * list (if possible ... see below).
+	 */
+	if (!page->age)
+	       deactivate_page(page, nolock);
+}
+
+
+/**
+ * (de)activate_page - move pages from/to active and inactive lists
+ * @page: the page we want to move
+ * @nolock - are we already holding the pagemap_lru_lock?
+ *
+ * Deactivate_page will move an active page to the right
+ * inactive list, while activate_page will move a page back
+ * from one of the inactive lists to the active list. If
+ * called on a page which is not on any of the lists, the
+ * page is left alone.
+ */
+void deactivate_page(struct page * page, int nolock)
+{
+	page->age = 0;
+
+	if (!nolock)
+		spin_lock(&pagemap_lru_lock);
+	/*
+	 * Don't touch it if it's not on the active list.
+	 * (some pages aren't on any list at all)
+	 */
+	if (PageActive(page) && (page_count(page) == 1 || page->buffers) &&
+			!page_ramdisk(page)) {
+		struct list_head * page_lru = &page->lru;
+		/*
+		 * Remove the page from the active list.
+		 */
+		list_del(page_lru);
+		ClearPageActive(page);
+		nr_active_pages--;
+		/*
+		 * If the page is dirty *and* there is backing store
+		 * available, move it to the inactive_dirty list.
+		 */
+		if (page->buffers) {
+			SetPageInactiveDirty(page);
+			list_add(page_lru, &inactive_dirty_list);
+			nr_inactive_dirty_pages++;
+			page->zone->inactive_dirty_pages++;
+		/*
+		 * If the page is clean and immediately reusable,
+		 * move it to the right inactive_clean list.
+		 */
+		} else if (page->mapping && !PageDirty(page)) {
+			zone_t *zone = page->zone;
+			SetPageInactiveClean(page);
+			list_add(page_lru, &zone->inactive_clean_list);
+			zone->inactive_clean_pages++;
+		/*
+		 * Damn, we don't have backing store for this page.
+		 * Put it back on the active list.
+		 */
+		} else {			
+			SetPageActive(page);
+			list_add(page_lru, &active_list);
+			nr_active_pages++;
+		}
+	}
+	if (!nolock)
+		spin_unlock(&pagemap_lru_lock);
+}	
+
 /*
- * Perform any setup for the swap system
+ * Move an inactive page to the active list.
  */
+void activate_page(struct page * page, int nolock)
+{
+	if (!nolock)
+		spin_lock(&pagemap_lru_lock);
+	/*
+	 * Don't touch it if it's not on an inactive list.
+	 * (some pages aren't on any list at all)
+	 */
+	if (PageInactiveDirty(page) || PageInactiveClean(page)) {
+		struct list_head * page_lru = &page->lru;
+		/* remove page from list, update stats */
+		list_del(page_lru);
+		if (PageInactiveDirty(page)) {
+			nr_inactive_dirty_pages--;
+			page->zone->inactive_dirty_pages--;
+			ClearPageInactiveDirty(page);
+		} else /* PageInactiveClean(page) */ {
+			page->zone->inactive_clean_pages--;
+			ClearPageInactiveClean(page);
+		}
+		/* Add the page to the active list. */
+		page->age = 0;
+		SetPageActive(page);
+		list_add(page_lru, &active_list);
+		nr_active_pages++;
+	}
+	if (!nolock)
+		spin_unlock(&pagemap_lru_lock);
+}
+
+/**
+ * lru_cache_add: add a page to the page lists
+ * @page: the page to add
+ */
+void lru_cache_add(struct page * page)
+{
+	struct list_head * page_lru = &page->lru;
+	zone_t *zone = page->zone;
+	spin_lock(&pagemap_lru_lock);
+	if (page->age == 0 && page->buffers && !page_ramdisk(page)) {
+		SetPageInactiveDirty(page);
+		list_add(page_lru, &inactive_dirty_list);
+		nr_inactive_dirty_pages++;
+		zone->inactive_dirty_pages++;
+	} else if (page->age == 0 && page_count(page) <= 2 &&
+			!PageDirty(page)) {
+		SetPageInactiveClean(page);
+		list_add(page_lru, &zone->inactive_clean_list);
+		zone->inactive_clean_pages++;
+	} else {
+		SetPageActive(page);
+		list_add(page_lru, &active_list);
+		nr_active_pages++;
+	}
+	spin_unlock(&pagemap_lru_lock);
+}
+
+/**
+ * __lru_cache_del: remove a page from the page lists
+ * @page: the page to add
+ *
+ * This function is for when the caller already holds
+ * the pagemap_lru_lock.
+ */
+void __lru_cache_del(struct page * page)
+{
+	struct list_head * page_lru = &page->lru;
+	zone_t *zone = page->zone;
+	list_del(page_lru);
+	if (PageActive(page)) {
+		ClearPageActive(page);
+		nr_active_pages--;
+	} else if (PageInactiveDirty(page)) {
+		ClearPageInactiveDirty(page);
+		nr_inactive_dirty_pages--;
+		zone->inactive_dirty_pages--;
+	} else if (PageInactiveClean(page)) {
+		ClearPageInactiveClean(page);
+		zone->inactive_clean_pages--;
+	} else {
+		printk("VM: __lru_cache_del, found unknown page ?!\n");
+	}
+}
+
+/**
+ * lru_cache_add: remove a page from the page lists
+ * @page: the page to remove
+ */
+void lru_cache_del(struct page * page)
+{
+	if (!PageLocked(page))
+		BUG();
+	spin_lock(&pagemap_lru_lock);
+	__lru_cache_del(page);
+	spin_unlock(&pagemap_lru_lock);
+}
+
+/**
+ * recalculate_vm_stats - recalculate VM statistics
+ *
+ * This function should be called once a second to recalculate
+ * some useful statistics the VM subsystem uses to determine
+ * its behaviour.
+ */
+void recalculate_vm_stats(void)
+{
+	/*
+	 * Substract one second worth of memory_pressure from
+	 * memory_pressure.
+	 */
+	memory_pressure -= (memory_pressure >> INACTIVE_SHIFT);
+}
 
+/*
+ * Perform any setup for the swap system
+ */
 void __init swap_setup(void)
 {
 	/* Use a smaller cluster for memory <16MB or <32MB */
--- linux-2.4.0-t6-p1/mm/vmscan.c.orig	Thu Aug  3 19:37:24 2000
+++ linux-2.4.0-t6-p1/mm/vmscan.c	Tue Aug  8 17:55:28 2000
@@ -9,6 +9,7 @@
  *  to bring the system back to freepages.high: 2.4.97, Rik van Riel.
  *  Version: $Id: vmscan.c,v 1.5 1998/02/23 22:14:28 sct Exp $
  *  Zone aware kswapd started 02/00, Kanoj Sarcar (kanoj@sgi.com).
+ *  Multiqueue VM started 5.8.00, Rik van Riel.
  */
 
 #include <linux/slab.h>
@@ -55,12 +56,28 @@
 	if (pte_young(pte)) {
 		/*
 		 * Transfer the "accessed" bit from the page
-		 * tables to the global page map.
+		 * tables to the global page map, except when
+		 * the page isn't on the active list and we'll
+		 * do the page aging ourselves.
 		 */
 		set_pte(page_table, pte_mkold(pte));
-                SetPageReferenced(page);
+		if (PageActive(page)) {
+                	SetPageReferenced(page);
+		} else {
+			age_page_up(page, 0);
+		}
 		goto out_failed;
 	}
+	if (!PageActive(page))
+		age_page_down(page, 0);
+
+	/*
+	 * If the page is in active use by us, or if the page
+	 * is in active use by others, don't unmap it or
+	 * (worse) start unneeded IO.
+	 */
+	if (page->age > 0)
+		goto out_failed;
 
 	if (TryLockPage(page))
 		goto out_failed;
@@ -82,6 +99,7 @@
 		vma->vm_mm->rss--;
 		flush_tlb_page(vma, address);
 		page_cache_release(page);
+		deactivate_page(page, 0);
 		goto out_failed;
 	}
 
@@ -116,7 +134,9 @@
 	 * Don't do any of the expensive stuff if
 	 * we're not really interested in this zone.
 	 */
-	if (page->zone->free_pages > page->zone->pages_high)
+	if (page->zone->free_pages + page->zone->inactive_clean_pages
+					+ page->zone->inactive_dirty_pages
+		      	> page->zone->pages_high + inactive_target)
 		goto out_unlock;
 
 	/*
@@ -182,6 +202,7 @@
 
 	/* OK, do a physical asynchronous write to swap.  */
 	rw_swap_page(WRITE, page, 0);
+	deactivate_page(page, 0);
 
 out_free_success:
 	page_cache_release(page);
@@ -363,7 +384,7 @@
 	 * Think of swap_cnt as a "shadow rss" - it tells us which process
 	 * we want to page out (always try largest first).
 	 */
-	counter = (nr_threads << 2) >> (priority >> 2);
+	counter = (nr_threads * PAGE_AGE_ADV) / (priority + 1);
 	if (counter < 1)
 		counter = 1;
 
@@ -418,46 +439,351 @@
 	return __ret;
 }
 
-/*
- * Check if there is any memory pressure (free_pages < pages_low)
+
+/**
+ * reclaim_page -	reclaims one page from the inactive_clean list
+ * @zone: reclaim a page from this zone
+ *
+ * The pages on the inactive_clean can be instantly reclaimed.
+ * The tests look impressive, but most of the time we'll grab
+ * the first page of the list and exit successfully.
  */
-static inline int memory_pressure(void)
+struct page * reclaim_page(zone_t * zone)
 {
-	pg_data_t *pgdat = pgdat_list;
+	struct page * page = NULL;
+	struct list_head * page_lru;
+	int maxscan;
 
-	do {
-		int i;
-		for(i = 0; i < MAX_NR_ZONES; i++) {
-			zone_t *zone = pgdat->node_zones+ i;
-			if (zone->size &&
-			    zone->free_pages < zone->pages_low)
-				return 1;
+	/*
+	 * We only need the pagecache_lock if we don't reclaim the page,
+	 * but we have to grab the pagecache_lock before the pagemap_lru_lock
+	 * to avoid deadlocks and most of the time we'll succeed anyway.
+	 */
+	spin_lock(&pagecache_lock);
+	spin_lock(&pagemap_lru_lock);
+	maxscan = zone->inactive_clean_pages;
+	while ((page_lru = zone->inactive_clean_list.prev) !=
+			&zone->inactive_clean_list && maxscan--) {
+		page = list_entry(page_lru, struct page, lru);
+
+		/* Wrong page on list?! (list corruption, should not happen) */
+		if (!PageInactiveClean(page)) {
+			printk("VM: reclaim_page, wrong page on list.\n");
+			list_del(page_lru);
+			page->zone->inactive_clean_pages--;
+			continue;
 		}
-		pgdat = pgdat->node_next;
-	} while (pgdat);
 
-	return 0;
+		/* Page is or was in use?  Move it to the active list. */
+		if (PageTestandClearReferenced(page) || page->age > 0 ||
+				(!page->buffers && page_count(page) > 1)) {
+			activate_page(page, 1);
+			continue;
+		}
+
+		/* The page is dirty, we put it on the inactive list. */
+		if (page->buffers) {
+			deactivate_page(page, 1);
+			continue;
+		}
+
+		/* We can't free the page right now. */
+		if (TryLockPage(page)) {
+			list_del(page_lru);
+			list_add(page_lru, &zone->inactive_clean_list);
+		}
+
+		/* OK, remove the page from the caches. */
+                if (PageSwapCache(page)) {
+			__delete_from_swap_cache(page);
+			goto found_page;
+		}
+
+		if (page->mapping) {
+			__remove_inode_page(page);
+			goto found_page;
+		}
+
+		/* We should never ever get here. */
+		printk(KERN_ERR "VM: reclaim_page, found unknown page\n");
+		list_del(page_lru);
+		zone->inactive_clean_pages--;
+		UnlockPage(page);
+	}
+	/* Reset page pointer, maybe we encountered an unfreeable page. */
+	page = NULL;
+	goto out;
+
+found_page:
+	/* Like __lru_cache_del would do ... */
+	ClearPageInactiveClean(page);
+	list_del(page_lru);
+	zone->inactive_clean_pages--;
+	UnlockPage(page);
+out:
+	spin_unlock(&pagemap_lru_lock);
+	spin_unlock(&pagecache_lock);
+	memory_pressure++;
+	return page;
+}
+
+/**
+ * page_launder - clean dirty inactive pages, move to inactive_clean list
+ * @gfp_mask: what operations we are allowed to do
+ * @sync: should we wait synchronously for the cleaning of pages
+ *
+ * When this function is called, we are most likely low on free +
+ * inactive_clean pages. Since we want to refill those pages as
+ * soon as possible, we'll make two loops over the inactive list,
+ * one to move the already cleaned pages to the inactive_clean lists
+ * and one to (often asynchronously) clean the dirty inactive pages.
+ *
+ * In situations where kswapd cannot keep up, user processes will
+ * end up calling this function. Since the user process needs to
+ * have a page before it can continue with its allocation, we'll
+ * do synchronous page flushing in that case.
+ *
+ * This code is heavily inspired by the FreeBSD source code. Thanks
+ * go out to Matthew Dillon.
+ */
+#define MAX_SYNC_LAUNDER	(1 << page_cluster)
+int page_launder(int gfp_mask, int sync)
+{
+	int synclaunder, launder_loop, maxscan, cleaned_pages;
+	struct list_head * page_lru;
+	struct page * page;
+
+	launder_loop = 0;
+	synclaunder = 0;
+	cleaned_pages = 0;
+
+dirty_page_rescan:
+	spin_lock(&pagemap_lru_lock);
+	maxscan = nr_inactive_dirty_pages;
+	while ((page_lru = inactive_dirty_list.prev) != &inactive_dirty_list &&
+				maxscan-- > 0) {
+		page = list_entry(page_lru, struct page, lru);
+
+		/* Wrong page on list?! (list corruption, should not happen) */
+		if (!PageInactiveDirty(page)) {
+			printk("VM: page_launder, wrong page on list.\n");
+			list_del(page_lru);
+			nr_inactive_dirty_pages--;
+			page->zone->inactive_dirty_pages--;
+			continue;
+		}
+
+		/* Page is or was in use?  Move it to the active list. */
+		if (PageTestandClearReferenced(page) || page->age > 0 ||
+				(!page->buffers && page_count(page) > 1) ||
+				page_ramdisk(page)) {
+			activate_page(page, 1);
+			continue;
+		}
+
+		/*
+		 * The page is locked. IO in progress?
+		 * Move it to the back of the list.
+		 */
+		if (TryLockPage(page)) {
+			list_del(page_lru);
+			list_add(page_lru, &inactive_dirty_list);
+			continue;
+		}
+
+		/*
+		 * If the page has buffers, try to free the buffer mappings
+		 * associated with this page. If we succeed we either free
+		 * the page (in case it was a buffercache only page) or we
+		 * move the page to the inactive_clean list.
+		 *
+		 * On the first round, we should free all previously cleaned
+		 * buffer pages
+		 */
+		if (page->buffers) {
+			zone_t * zone = page->zone;
+			int wait;
+			/*
+			 * Since we might be doing disk IO, we have to
+			 * drop the spinlock and take an extra reference
+			 * on the page so it doesn't go away from under us.
+			 */
+			list_del(page_lru);
+			page_cache_get(page);
+			spin_unlock(&pagemap_lru_lock);
+			/* Will we do (asynchronous) IO? */
+			if (launder_loop && synclaunder-- > 0)
+				wait = 2;	/* Synchrounous IO */
+			else if (launder_loop)
+				wait = 1;	/* Async IO */
+			else
+				wait = 0;	/* No IO */
+
+			if (!try_to_free_buffers(page, wait)) {
+				/* We failed. Put the page back on the list. */
+				spin_lock(&pagemap_lru_lock);
+				UnlockPage(page);
+				page_cache_release(page);
+				list_add(page_lru, &inactive_dirty_list);
+				continue;
+			}
+			/* OK, the page is clean now. */
+			UnlockPage(page);
+			ClearPageInactiveDirty(page);
+			page_cache_release(page);
+			spin_lock(&pagemap_lru_lock);
+			if (!page->mapping) {
+				/* Move to freelist. */
+				atomic_dec(&buffermem_pages);
+				nr_inactive_dirty_pages--;
+				zone->inactive_dirty_pages--;
+			} else {
+				/* Add to inactive_clean_list, update stats. */
+				zone_t * zone = page->zone;
+				SetPageInactiveClean(page);
+				list_add(page_lru, &zone->inactive_clean_list);
+				nr_inactive_dirty_pages--;
+				zone->inactive_dirty_pages--;
+				zone->inactive_clean_pages++;
+			}
+			cleaned_pages++;
+			continue;
+		} else {
+			/*
+			 * Somebody else freed the bufferheads for us?
+			 * This really shouldn't happen, but we check
+			 * for it anyway.
+			 */
+			printk("VM: page_launder, found pre-cleaned page ?!\n");
+			UnlockPage(page);
+			if (page->mapping && !PageDirty(page)) {
+				zone_t * zone = page->zone;
+				ClearPageInactiveDirty(page);
+				list_del(page_lru);
+				list_add(page_lru, &zone->inactive_clean_list);
+				nr_inactive_dirty_pages--;
+				zone->inactive_dirty_pages--;
+				zone->inactive_clean_pages++;
+				cleaned_pages++;
+			}
+		}
+	}
+	spin_unlock(&pagemap_lru_lock);
+
+	/*
+	 * If we were have either too few clean pages _or_ too many
+	 * dirty pages, go back for a launder loop. If we were asked
+	 * to free pages synchronously, we do so only if we failed to
+	 * free any clean pages.
+	 */
+	if (!launder_loop && (nr_inactive_dirty_pages * 2 > nr_free_pages() ||
+				free_shortage())) {
+		launder_loop = 1;
+		if (sync && !cleaned_pages)
+			synclaunder = MAX_SYNC_LAUNDER;
+		goto dirty_page_rescan;
+	}
+
+	/* Return the number of pages moved to the inactive_clean list. */
+	return cleaned_pages;
+}
+
+/**
+ * refill_inactive_scan - scan the active list and find pages to deactivate
+ * @priority: the priority at which to scan
+ * @count: the number of pages we should try to deactivate
+ *
+ * This function will scan a portion of the active list to find
+ * unused pages, those pages will then be moved to the inactive list.
+ */
+int refill_inactive_scan(unsigned int priority)
+{
+	struct list_head * page_lru;
+	struct page * page;
+	int maxscan;
+	int ret = 0;
+
+	/* Take the lock while messing with the list... */
+	spin_lock(&pagemap_lru_lock);
+	maxscan = nr_active_pages >> priority;
+	while (maxscan-- > 0 && (page_lru = active_list.prev) != &active_list) {
+		page = list_entry(page_lru, struct page, lru);
+
+		/* Wrong page on list?! (list corruption, should not happen) */
+		if (!PageActive(page)) {
+			printk("VM: refill_inactive, wrong page on list.\n");
+			list_del(page_lru);
+			nr_active_pages--;
+			continue;
+		}
+
+		/* Do aging on the pages. */
+		if (PageTestandClearReferenced(page)) {
+			age_page_up(page, 1);
+			continue;
+		}
+		age_page_down(page, 1);
+		/*
+		 * If the page is moved from the active list
+		 * (to an inactive list), exit.
+		 */
+		if (!PageActive(page)) {
+			ret = 1;
+			break;
+		}
+	}
+	spin_unlock(&pagemap_lru_lock);
+
+	return ret;
 }
 
 /*
- * Check if all zones have recently had memory_pressure (zone_wake_kswapd)
+ * Check if there are zones with a severe shortage of free pages,
+ * or if all zones have a minor shortage.
  */
-static inline int keep_kswapd_awake(void)
+int free_shortage(void)
 {
 	pg_data_t *pgdat = pgdat_list;
+	int sum = 0;
 
+	/* Are we low on free pages over-all? */
+	if (nr_free_pages() < freepages.high)
+		return freepages.high - nr_free_pages();
+
+	/* If not, are we very low on any particular zone? */
 	do {
 		int i;
 		for(i = 0; i < MAX_NR_ZONES; i++) {
 			zone_t *zone = pgdat->node_zones+ i;
-			if (zone->size &&
-			    !zone->zone_wake_kswapd)
-				return 0;
+			if (zone->size && (zone->inactive_clean_pages +
+					zone->free_pages < zone->pages_min)) {
+				sum += zone->pages_min;
+				sum -= zone->free_pages;
+				sum -= zone->inactive_clean_pages;
+			}
 		}
 		pgdat = pgdat->node_next;
 	} while (pgdat);
 
-	return 1;
+	return sum;
+}
+
+/*
+ * How many inactive pages are we short?
+ */
+int inactive_shortage(void)
+{
+	int shortage = 0;
+
+	shortage += freepages.high;
+	shortage += inactive_target;
+	shortage -= nr_free_pages();
+	shortage -= nr_inactive_dirty_pages;
+
+	if (shortage > 0)
+		return shortage;
+
+	return 0;
 }
 
 /*
@@ -468,38 +794,41 @@
  * We want to try to free "count" pages, and we want to 
  * cluster them so that we get good swap-out behaviour.
  *
- * Don't try _too_ hard, though. We don't want to have bad
- * latency.
+ * OTOH, if we're a user process (and not kswapd), we
+ * really care about latency. In that case we don't try
+ * to free too many pages.
  */
-#define FREE_COUNT	8
-#define SWAP_COUNT	16
-static int do_try_to_free_pages(unsigned int gfp_mask)
-{
-	int priority;
-	int count = FREE_COUNT;
-	int swap_count;
+static int refill_inactive(unsigned int gfp_mask, int user)
+{
+	int priority, count, start_count, swap_count, made_progress;
+
+	count = inactive_shortage() + free_shortage();
+	if (user)
+		count = (1 << page_cluster);
+	if (!count)
+		return 1;
+	start_count = count;
 
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
 
-	priority = 64;
+	priority = 6;
 	do {
+		made_progress = 0;
+
 		if (current->need_resched) {
 			schedule();
-			/* time has passed - pressure too? */
-			if (!memory_pressure())
-				goto done;
+			/* We slept. Maybe the faeries did our work. */
+			if (!inactive_shortage() && !free_shortage())
+				return 1;
 		}
 
-		while (shrink_mmap(priority, gfp_mask)) {
+		while (refill_inactive_scan(priority)) {
+			made_progress = 1;
 			if (!--count)
 				goto done;
 		}
 
-		/* check if mission completed */
-		if (!keep_kswapd_awake())
-			goto done;
-
 		/* Try to get rid of some shared memory pages.. */
 		if (gfp_mask & __GFP_IO) {
 			/*
@@ -518,10 +847,11 @@
 			 *	if (count <= 0)
 			 *		goto done;
 			 */
-			if (!keep_kswapd_awake())
-				goto done;
+			if (!inactive_shortage() && !free_shortage())
+				return 1;
 
 			while (shm_swap(priority, gfp_mask)) {
+				made_progress = 1;
 				if (!--count)
 					goto done;
 			}
@@ -529,29 +859,88 @@
 
 		/*
 		 * Then, try to page stuff out..
-		 *
-		 * This will not actually free any pages (they get
-		 * put in the swap cache), so we must not count this
-		 * as a "count" success.
 		 */
-		swap_count = SWAP_COUNT;
-		while (swap_out(priority, gfp_mask))
-			if (--swap_count < 0)
-				break;
+		while (swap_out(priority, gfp_mask)) {
+			made_progress = 1;
+			if (!--count)
+				goto done;
+		}
 
-	} while (--priority >= 0);
+		/*
+		 * Only switch to a lower "priority" if we
+		 * didn't make any useful progress in the
+		 * last loop.
+		 */
+		if (!made_progress)
+			priority--;
+	} while (priority >= 0);
 
 	/* Always end on a shrink_mmap.., may sleep... */
-	while (shrink_mmap(0, gfp_mask)) {
+	while (refill_inactive_scan(0)) {
 		if (!--count)
 			goto done;
 	}
-	/* Return 1 if any page is freed, or
-	 * there are no more memory pressure   */
-	return (count < FREE_COUNT || !memory_pressure());
- 
+
 done:
-	return 1;
+	/* Did we make any progress? */
+	if (count == start_count)
+		printk("VM: refill_inactive, failed miserably\n");
+	return (count < start_count);
+}
+
+static int do_try_to_free_pages(unsigned int gfp_mask, int user)
+{
+	pg_data_t * pgdat;
+	int success = 0;
+	int old_free = nr_free_pages();
+
+	/*
+	 * First, move the just cleaned pages from the
+	 * inactive_dirty list to the inactive_clean
+	 * lists. This function will also start IO to
+	 * flush out the pages the dirty pages.
+	 */
+	success += page_launder(gfp_mask, user);
+
+	/*
+	 * Then (if needed), refill the inactive lists with
+	 * pages from the active list. If we're really short
+	 * on inactive pages, we take more drastic measures.
+	 */
+	success += refill_inactive(gfp_mask, user);
+	while (nr_active_pages > (inactive_shortage() * 2) &&
+			inactive_shortage() > (inactive_target / 2))
+		success += refill_inactive(gfp_mask, user);
+
+	if (nr_free_pages() > old_free)
+		success++;
+
+	/*
+	 * Now move some pages from the inactive_clean lists to
+	 * the free lists, if it is needed.
+	 */
+	pgdat = pgdat_list;
+	do {
+		int i;
+		for(i = 0; i < MAX_NR_ZONES; i++) {
+			zone_t *zone = pgdat->node_zones + i;
+			if (!zone->size)
+				continue;
+			/* Move pages to the free list, if needed. */
+			if (zone->free_pages < ((zone->pages_min * 3) / 4)) {
+				while (zone->free_pages < zone->pages_min) {
+					struct page * page;
+					page = reclaim_page(zone);
+					if (!page)
+						break;
+					__free_page(page);
+				}
+			}
+		}
+		pgdat = pgdat->node_next;
+	} while (pgdat);
+
+	return success;
 }
 
 DECLARE_WAIT_QUEUE_HEAD(kswapd_wait);
@@ -592,12 +981,33 @@
 	 */
 	tsk->flags |= PF_MEMALLOC;
 
+	/*
+	 * Kswapd main loop.
+	 */
 	for (;;) {
-		if (!keep_kswapd_awake()) {
-			interruptible_sleep_on(&kswapd_wait);
+		static int recalc = 0;
+		int timeout = HZ;
+
+		/* 
+		 * Go to sleep for a while. If there is more VM activity,
+		 * we make sure to sleep less...
+		 */
+		if (inactive_target > freepages.low || free_shortage()) {
+			timeout = HZ / 2;
+			if (inactive_target > freepages.high)
+				timeout = HZ / 4;
 		}
+		interruptible_sleep_on_timeout(&kswapd_wait, timeout);
 
-		do_try_to_free_pages(GFP_KSWAPD);
+		/* If needed, try to free some memory. */
+		if (inactive_shortage() || free_shortage())
+			do_try_to_free_pages(GFP_KSWAPD, 0);
+
+		/* Once a second, recalculate some VM stats. */
+		if (time_after(jiffies, recalc + HZ)) {
+			recalc = jiffies;
+			recalculate_vm_stats();
+		}
 	}
 }
 
@@ -623,7 +1033,7 @@
 	if (gfp_mask & __GFP_WAIT) {
 		current->state = TASK_RUNNING;
 		current->flags |= PF_MEMALLOC;
-		retval = do_try_to_free_pages(gfp_mask);
+		retval = do_try_to_free_pages(gfp_mask, 1);
 		current->flags &= ~PF_MEMALLOC;
 	}
 
--- linux-2.4.0-t6-p1/include/linux/mm.h.orig	Thu Aug  3 19:38:37 2000
+++ linux-2.4.0-t6-p1/include/linux/mm.h	Mon Aug  7 21:45:00 2000
@@ -15,7 +15,9 @@
 extern unsigned long num_physpages;
 extern void * high_memory;
 extern int page_cluster;
-extern struct list_head lru_cache;
+/* The inactive_clean lists are per zone. */
+extern struct list_head active_list;
+extern struct list_head inactive_dirty_list;
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -148,6 +150,7 @@
 	atomic_t count;
 	unsigned long flags;	/* atomic flags, some possibly updated asynchronously */
 	struct list_head lru;
+	unsigned long age;
 	wait_queue_head_t wait;
 	struct page **pprev_hash;
 	struct buffer_head * buffers;
@@ -168,12 +171,12 @@
 #define PG_uptodate		 3
 #define PG_dirty		 4
 #define PG_decr_after		 5
-#define PG_unused_01		 6
-#define PG__unused_02		 7
+#define PG_active		 6
+#define PG_inactive_dirty	 7
 #define PG_slab			 8
 #define PG_swap_cache		 9
 #define PG_skip			10
-#define PG_unused_03		11
+#define PG_inactive_clean	11
 #define PG_highmem		12
 				/* bits 21-30 unused */
 #define PG_reserved		31
@@ -198,6 +201,7 @@
 #define ClearPageError(page)	clear_bit(PG_error, &(page)->flags)
 #define PageReferenced(page)	test_bit(PG_referenced, &(page)->flags)
 #define SetPageReferenced(page)	set_bit(PG_referenced, &(page)->flags)
+#define ClearPageReferenced(page)	clear_bit(PG_referenced, &(page)->flags)
 #define PageTestandClearReferenced(page)	test_and_clear_bit(PG_referenced, &(page)->flags)
 #define PageDecrAfter(page)	test_bit(PG_decr_after, &(page)->flags)
 #define SetPageDecrAfter(page)	set_bit(PG_decr_after, &(page)->flags)
@@ -215,6 +219,18 @@
 #define PageClearSwapCache(page)	clear_bit(PG_swap_cache, &(page)->flags)
 
 #define PageTestandClearSwapCache(page)	test_and_clear_bit(PG_swap_cache, &(page)->flags)
+
+#define PageActive(page)	test_bit(PG_active, &(page)->flags)
+#define SetPageActive(page)	set_bit(PG_active, &(page)->flags)
+#define ClearPageActive(page)	clear_bit(PG_active, &(page)->flags)
+
+#define PageInactiveDirty(page)	test_bit(PG_inactive_dirty, &(page)->flags)
+#define SetPageInactiveDirty(page)	set_bit(PG_inactive_dirty, &(page)->flags)
+#define ClearPageInactiveDirty(page)	clear_bit(PG_inactive_dirty, &(page)->flags)
+
+#define PageInactiveClean(page)	test_bit(PG_inactive_clean, &(page)->flags)
+#define SetPageInactiveClean(page)	set_bit(PG_inactive_clean, &(page)->flags)
+#define ClearPageInactiveClean(page)	clear_bit(PG_inactive_clean, &(page)->flags)
 
 #ifdef CONFIG_HIGHMEM
 #define PageHighMem(page)		test_bit(PG_highmem, &(page)->flags)
--- linux-2.4.0-t6-p1/include/linux/mmzone.h.orig	Thu Aug  3 19:38:48 2000
+++ linux-2.4.0-t6-p1/include/linux/mmzone.h	Mon Aug  7 20:17:13 2000
@@ -28,13 +28,14 @@
 	spinlock_t		lock;
 	unsigned long		offset;
 	unsigned long		free_pages;
-	char			low_on_memory;
-	char			zone_wake_kswapd;
+	unsigned long		inactive_clean_pages;
+	unsigned long		inactive_dirty_pages;
 	unsigned long		pages_min, pages_low, pages_high;
 
 	/*
 	 * free areas of different sizes
 	 */
+	struct list_head	inactive_clean_list;
 	free_area_t		free_area[MAX_ORDER];
 
 	/*
--- linux-2.4.0-t6-p1/include/linux/swap.h.orig	Thu Aug  3 19:38:58 2000
+++ linux-2.4.0-t6-p1/include/linux/swap.h	Tue Aug  8 17:56:47 2000
@@ -67,11 +67,14 @@
 FASTCALL(unsigned int nr_free_pages(void));
 FASTCALL(unsigned int nr_free_buffer_pages(void));
 FASTCALL(unsigned int nr_free_highpages(void));
-extern int nr_lru_pages;
+extern int nr_active_pages;
+extern int nr_inactive_dirty_pages;
 extern atomic_t nr_async_pages;
 extern struct address_space swapper_space;
 extern atomic_t page_cache_size;
 extern atomic_t buffermem_pages;
+extern spinlock_t pagecache_lock;
+extern void __remove_inode_page(struct page *);
 
 /* Incomplete types for prototype declarations: */
 struct task_struct;
@@ -83,9 +86,23 @@
 extern int shm_swap(int, int);
 
 /* linux/mm/swap.c */
+extern int memory_pressure;
+extern void age_page_up(struct page *, int);
+extern void age_page_down(struct page *, int);
+extern void deactivate_page(struct page *, int);
+extern void activate_page(struct page *, int);
+extern void lru_cache_add(struct page *);
+extern void __lru_cache_del(struct page *);
+extern void lru_cache_del(struct page *);
+extern void recalculate_vm_stats(void);
 extern void swap_setup(void);
 
 /* linux/mm/vmscan.c */
+extern struct page * reclaim_page(zone_t *);
+extern wait_queue_head_t kswapd_wait;
+extern int page_launder(int, int);
+extern int free_shortage(void);
+extern int inactive_shortage(void);
 extern int try_to_free_pages(unsigned int gfp_mask);
 
 /* linux/mm/page_io.c */
@@ -161,30 +178,41 @@
 extern spinlock_t pagemap_lru_lock;
 
 /*
- * Helper macros for lru_pages handling.
+ * Page aging defines.
+ * Since we do exponential decay of the page age, we
+ * can chose a fairly large maximum.
  */
-#define	lru_cache_add(page)			\
-do {						\
-	spin_lock(&pagemap_lru_lock);		\
-	list_add(&(page)->lru, &lru_cache);	\
-	nr_lru_pages++;				\
-	spin_unlock(&pagemap_lru_lock);		\
-} while (0)
-
-#define	__lru_cache_del(page)			\
-do {						\
-	list_del(&(page)->lru);			\
-	nr_lru_pages--;				\
-} while (0)
-
-#define	lru_cache_del(page)			\
-do {						\
-	if (!PageLocked(page))			\
-		BUG();				\
-	spin_lock(&pagemap_lru_lock);		\
-	__lru_cache_del(page);			\
-	spin_unlock(&pagemap_lru_lock);		\
-} while (0)
+#define PAGE_AGE_START 2
+#define PAGE_AGE_ADV 3
+#define PAGE_AGE_MAX 64
+
+/*
+ * In mm/swap.c::recalculate_vm_stats(), we substract
+ * inactive_target from memory_pressure every second.
+ * This means that memory_pressure is smoothed over
+ * 64 (1 << INACTIVE_SHIFT) seconds.
+ */
+#define INACTIVE_SHIFT 6
+#define inactive_max(a,b) ((a) > (b) ? (a) : (b))
+#define inactive_target inactive_max((memory_pressure >> INACTIVE_SHIFT), \
+		(num_physpages / 8))
+
+/*
+ * Ugly ugly ugly HACK to make sure the inactive lists
+ * don't fill up with unfreeable ramdisk pages. We really
+ * want to fix the ramdisk driver to mark its pages as
+ * unfreeable instead of using dirty buffer magic, but the
+ * next code-change time is when 2.5 is forked...
+ */
+#ifndef _LINUX_KDEV_T_H
+#include <linux/kdev_t.h>
+#endif
+#ifndef _LINUX_MAJOR_H
+#include <linux/major.h>
+#endif
+
+#define page_ramdisk(page) \
+	(page->buffers && (MAJOR(page->buffers->b_dev) == RAMDISK_MAJOR))
 
 extern spinlock_t swaplock;
 
--- linux-2.4.0-t6-p1/ipc/shm.c.orig	Tue Aug  8 05:07:48 2000
+++ linux-2.4.0-t6-p1/ipc/shm.c	Tue Aug  8 05:09:07 2000
@@ -1522,7 +1522,7 @@
 }
 
 /*
- * Goes through counter = (shm_rss / (prio + 1)) present shm pages.
+ * Goes through counter = (shm_rss >> prio) present shm pages.
  */
 static unsigned long swap_id; /* currently being swapped */
 static unsigned long swap_idx; /* next to swap */
@@ -1537,7 +1537,7 @@
 	struct page * page_map;
 
 	zshm_swap(prio, gfp_mask);
-	counter = shm_rss / (prio + 1);
+	counter = shm_rss >> prio;
 	if (!counter)
 		return 0;
 	if (shm_swap_preop(&swap_entry))
@@ -1863,7 +1863,7 @@
 	int counter;
 	struct page * page_map;
 
-	counter = zshm_rss / (prio + 1);
+	counter = zshm_rss >> prio;
 	if (!counter)
 		return;
 next:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
