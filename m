Received: from localhost (riel@localhost)
	by duckman.conectiva (8.9.3/8.8.7) with ESMTP id VAA04864
	for <linux-mm@kvack.org>; Tue, 9 May 2000 21:29:22 -0300
Date: Tue, 9 May 2000 21:29:22 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [patch] active/inactive #3 vs pre7-4
Message-ID: <Pine.LNX.4.21.0005092128290.25637-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

the patch still doesn't work, but a bunch of people have asked
me if I could send it here so they could play with it ...

cheers,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/


--- linux-2.3.99-pre7-4/mm/page_alloc.c.orig	Thu May  4 11:38:24 2000
+++ linux-2.3.99-pre7-4/mm/page_alloc.c	Mon May  8 11:48:04 2000
@@ -110,6 +110,8 @@
 		BUG();
 	if (PageDecrAfter(page))
 		BUG();
+	if (PageInactive(page))
+		BUG();
 
 	zone = page->zone;
 
@@ -156,7 +158,8 @@
 
 	spin_unlock_irqrestore(&zone->lock, flags);
 
-	if (zone->free_pages > zone->pages_high) {
+	if (zone->free_pages > zone->pages_high &&
+			!low_on_inactive_pages(zone)) {
 		zone->zone_wake_kswapd = 0;
 		zone->low_on_memory = 0;
 	}
@@ -239,7 +242,8 @@
 		zone_t *z = *(zone++);
 		if (!z)
 			break;
-		if (z->free_pages > z->pages_low)
+		if (z->free_pages > z->pages_low &&
+				!low_on_inactive_pages(z))
 			continue;
 
 		z->zone_wake_kswapd = 1;
@@ -306,7 +310,8 @@
 			BUG();
 
 		/* Are we supposed to free memory? Don't make it worse.. */
-		if (!z->zone_wake_kswapd && z->free_pages > z->pages_low) {
+		if (!z->zone_wake_kswapd && z->free_pages > z->pages_low
+				&& !low_on_inactive_pages(z)) {
 			struct page *page = rmqueue(z, order);
 			low_on_memory = 0;
 			if (page)
@@ -541,7 +546,6 @@
 	freepages.min += i;
 	freepages.low += i * 2;
 	freepages.high += i * 3;
-	memlist_init(&lru_cache);
 
 	/*
 	 * Some architectures (with lots of mem and discontinous memory
@@ -559,6 +563,16 @@
 	pgdat->node_start_paddr = zone_start_paddr;
 	pgdat->node_start_mapnr = (lmem_map - mem_map);
 
+	/* Set up structures for the active / inactive memory lists. */
+	pgdat->page_list_lock = SPIN_LOCK_UNLOCKED;
+	pgdat->active_pages = 0;
+	pgdat->inactive_pages = 0;
+	pgdat->inactive_target = realtotalpages >> 5;
+	pgdat->inactive_freed = 0;
+	pgdat->inactive_reactivated = 0;
+	memlist_init(&pgdat->active_list);
+	memlist_init(&pgdat->inactive_list);
+
 	/*
 	 * Initially all pages are reserved - free ones are freed
 	 * up by free_all_bootmem() once the early boot process is
@@ -602,6 +616,8 @@
 		zone->pages_high = mask*3;
 		zone->low_on_memory = 0;
 		zone->zone_wake_kswapd = 0;
+		zone->active_pages = 0;
+		zone->inactive_pages = 0;
 		zone->zone_mem_map = mem_map + offset;
 		zone->zone_start_mapnr = offset;
 		zone->zone_start_paddr = zone_start_paddr;
--- linux-2.3.99-pre7-4/mm/swap.c.orig	Thu May  4 11:38:24 2000
+++ linux-2.3.99-pre7-4/mm/swap.c	Mon May  8 14:41:03 2000
@@ -64,6 +64,54 @@
 	SWAP_CLUSTER_MAX,	/* do swap I/O in clusters of this size */
 };
 
+void recalculate_inactive_target(pg_data_t * pgdat)
+{
+	int delta = pgdat->inactive_target / 4;
+
+	/* More than 25% reactivations?  Shrink the inactive list a bit */
+	if (pgdat->inactive_freed < pgdat->inactive_reactivated * 3)
+		pgdat->inactive_target -= delta;
+	else
+		pgdat->inactive_target += delta;
+
+	/* Make sure the inactive target isn't too big or too small */
+	if (pgdat->inactive_target > pgdat->node_size >> 2)
+		pgdat->inactive_target = pgdat->node_size >> 2;
+	if (pgdat->inactive_target < pgdat->node_size >> 6)
+		pgdat->inactive_target = pgdat->node_size >> 6;
+}
+
+/**
+ * 	low_on_inactive_pages - vm helper function
+ * 	@zone: memory zone to investigate
+ *
+ * 	low_on_inactive_pages returns 1 if the zone in question
+ * 	does not have enough inactive pages, 0 otherwise. It will
+ * 	also recalculate pgdat->inactive_target, if needed.
+ */
+int low_on_inactive_pages(struct zone_struct *zone)
+{
+	pg_data_t * pgdat = zone->zone_pgdat;
+	if (!pgdat)
+		BUG();
+
+	if (pgdat->inactive_freed + pgdat->inactive_reactivated >
+			pgdat->inactive_target) {
+		recalculate_inactive_target(pgdat);
+	}
+
+	if (zone->free_pages + zone->inactive_pages > zone->pages_high * 2)
+		return 0;
+
+	if (zone->inactive_pages < zone->pages_low)
+		return 1;
+
+	if (pgdat->inactive_pages < pgdat->inactive_target)
+		return 1;
+
+	return 0;  /* else */
+}
+
 /*
  * Perform any setup for the swap system
  */
--- linux-2.3.99-pre7-4/mm/vmscan.c.orig	Thu May  4 11:38:24 2000
+++ linux-2.3.99-pre7-4/mm/vmscan.c	Tue May  9 21:08:31 2000
@@ -392,9 +392,9 @@
 				if (!p->swappable || !mm || mm->rss <= 0)
 					continue;
 				/* small processes are swapped out less */
-				while ((mm->swap_cnt << 2 * (i + 1) < max_cnt) && i++ < 10)
+				while ((mm->rss << 2 * (i + 1) < max_cnt) && i++ < 10)
 					/* nothing */;
-				mm->swap_cnt >>= i;
+				mm->swap_cnt = mm->rss >> i;
 				mm->swap_cnt += i; /* if swap_cnt reaches 0 */
 				/* we're big -> hog treatment */
 				if (!i)
@@ -442,17 +442,30 @@
 {
 	int priority;
 	int count = SWAP_CLUSTER_MAX;
+	pg_data_t * pgdat = zone->zone_pgdat;
+	/* We hit a NULL zone... */
+	if (!pgdat)
+		return 0;
 
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
 
 	priority = 6;
 	do {
-		while (shrink_mmap(priority, gfp_mask, zone)) {
+		while (free_inactive_pages(priority, gfp_mask, zone)) {
+			if (zone->free_pages > zone->pages_high)
+				break;
 			if (!--count)
 				goto done;
 		}
 
+		while (refill_inactive(priority, zone)) {
+			if (pgdat->inactive_pages > pgdat->inactive_target &&
+					zone->inactive_pages > zone->pages_high)
+				break;
+			if (!--count)
+				goto done;
+		}
 
 		/* Try to get rid of some shared memory pages.. */
 		if (gfp_mask & __GFP_IO) {
@@ -534,6 +547,8 @@
 			for (i = 0; i < MAX_NR_ZONES; i++) {
 				int count = SWAP_CLUSTER_MAX;
 				zone = pgdat->node_zones + i;
+				if (!zone || !zone->zone_pgdat)
+					continue;
 				if ((!zone->size) || (!zone->zone_wake_kswapd))
 					continue;
 				do {
--- linux-2.3.99-pre7-4/mm/filemap.c.orig	Thu May  4 11:38:24 2000
+++ linux-2.3.99-pre7-4/mm/filemap.c	Tue May  9 21:20:36 2000
@@ -233,61 +233,191 @@
 	spin_unlock(&pagecache_lock);
 }
 
-int shrink_mmap(int priority, int gfp_mask, zone_t *zone)
+/* basically lru_cache_del() and lru_cache_add() merged together */
+static void __page_reactivate(struct page *page)
+{
+	struct zone_struct * zone = page->zone;
+	pg_data_t * pgdat = zone->zone_pgdat;
+	extern wait_queue_head_t kswapd_wait;
+
+	list_del(&(page)->lru);
+	pgdat->inactive_pages--;
+	zone->inactive_pages--;
+	PageClearInactive(page);
+
+	list_add(&(page)->lru, &pgdat->active_list);
+	pgdat->active_pages++;
+	zone->active_pages++;
+	pgdat->inactive_reactivated++;
+
+	/* Low on inactive pages => wake up kswapd. */
+	if (0 && low_on_inactive_pages(zone)) {
+		wake_up_interruptible(&kswapd_wait);
+	}
+}
+
+static void page_reactivate(struct page *page)
+{
+	pg_data_t * pgdat = page->zone->zone_pgdat;
+	spin_lock(&pgdat->page_list_lock);
+	__page_reactivate(page);
+	spin_unlock(&pgdat->page_list_lock);
+}
+
+/**
+ *	refill_inactive -	kswapd
+ *	@priority: how hard we should try
+ *	@zone: memory zone to pay extra attention to
+ *
+ *	Called from do_try_to_free_pages, we refill the
+ *	inactive list for the pgdat (NUMA node) zone belongs
+ *	to. We must fail in time so that the active list is
+ *	refilled by swap_out.
+ */
+int refill_inactive(int priority, zone_t *zone)
 {
 	int ret = 0, count;
-	LIST_HEAD(young);
-	LIST_HEAD(old);
-	LIST_HEAD(forget);
-	struct list_head * page_lru, * dispose;
-	struct page * page = NULL;
-	struct zone_struct * p_zone;
+	struct list_head * page_lru;
+	struct page * page;
+	pg_data_t * pgdat = zone->zone_pgdat;
 	
 	if (!zone)
 		BUG();
 
-	count = nr_lru_pages >> priority;
-	if (!count)
-		return ret;
-
-	spin_lock(&pagemap_lru_lock);
-again:
-	/* we need pagemap_lru_lock for list_del() ... subtle code below */
-	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
-		page = list_entry(page_lru, struct page, lru);
-		list_del(page_lru);
-		p_zone = page->zone;
+	count = pgdat->active_pages / (priority + 1);
 
-		/* This LRU list only contains a few pages from the system,
-		 * so we must fail and let swap_out() refill the list if
-		 * there aren't enough freeable pages on the list */
-
-		/* The page is in use, or was used very recently, put it in
-		 * &young to make sure that we won't try to free it the next
-		 * time */
-		dispose = &young;
-		if (test_and_clear_bit(PG_referenced, &page->flags))
-			goto dispose_continue;
+	spin_lock(&pgdat->page_list_lock);
+	for (page_lru = &pgdat->active_list;  count > 0;
+			page_lru = page_lru->prev ) {
+		/* Catch it if we loop back to the list head. */
+		if (page_lru == &pgdat->active_list)
+			break;
+		page = list_entry(page_lru, struct page, lru);
 
-		if (p_zone->free_pages > p_zone->pages_high)
-			goto dispose_continue;
+		/* The page is in use, or was used very recently
+		 * so we will leave it on the active list.
+		 * Old buffer pages fall through. -- Rik
+		 */
+		if (test_and_clear_bit(PG_referenced, &page->flags) &&
+				!page->buffers)
+			continue;
 
 		if (!page->buffers && page_count(page) > 1)
-			goto dispose_continue;
+			continue;
+
+		/* Page locked?  Somebody must be using it */
+//		if (TryLockPage(page))
+//			continue;
+
+		/* Move the page; make sure not to clobber page_lru. */
+		page_lru = page_lru->prev;
+
+		/* Move the page to the inactive list and update stats, etc */
+		list_del(&(page)->lru);
+		pgdat->active_pages--;
+		zone->active_pages--;
+		PageSetInactive(page);
+
+		list_add(&(page)->lru, &pgdat->inactive_list);
+		pgdat->inactive_pages++;
+		zone->inactive_pages++;
+//		UnlockPage(page);
+
+		ret = 1;
+		/* Is the inactive list big enough now? */
+		if (pgdat->inactive_pages > pgdat->inactive_target &&
+				zone->inactive_pages > zone->pages_high) {
+			break;
+		}
+		/* Damn, we ran out of active pages... */
+		if (!zone->active_pages)
+			break;
+	}
+	/* move the list head so we start at the right place next time */
+	list_del(&pgdat->active_list);
+	list_add(&pgdat->active_list, page_lru); /* <== Subtle */
+	spin_unlock(&pgdat->page_list_lock);
+
+	if (zone->free_pages > zone->pages_high &&
+			!low_on_inactive_pages(zone)) {
+		zone->zone_wake_kswapd = 0;
+		zone->low_on_memory = 0;
+	}
+	
+	return ret;
+}
+
+/**
+ * 	free_inactive_pages -	kswapd
+ * 	@priority: how hard we should try
+ * 	@zone: memory zone to pay extra attention to
+ *
+ * 	This is the function that actually frees memory.
+ * 	We scan the inactive list and free every page that
+ * 	we can, with the exception of recently touched pages,
+ * 	which are moved to the active list.
+ */
+int free_inactive_pages(int priority, int gfp_mask, zone_t *zone)
+{
+	int ret = 0, count;
+	struct list_head * page_lru;
+	struct page * page = NULL;
+	pg_data_t * pgdat = zone->zone_pgdat;
+	
+	count = pgdat->inactive_pages / (priority + 1);
+
+	spin_lock(&pgdat->page_list_lock);
+roll_again:
+	for (page_lru = &pgdat->inactive_list;  count > 0;
+			page_lru = page_lru->prev ) {
+next_page:
+		/* Catch it if we loop back to the list head. */
+		if (page_lru == &pgdat->inactive_list)
+			break;
+		page = list_entry(page_lru, struct page, lru);
+
+		/* The page is/was used => move it to the active list.
+		 * Make sure to assign the next 'page_lru' *before* we
+		 * move the page to another list.
+		 */
+		if (test_and_clear_bit(PG_referenced, &page->flags)) {
+			page_lru = page_lru->prev;
+			__page_reactivate(page);
+			goto next_page;
+		}
+
+		if (!page->buffers && page_count(page) > 1) {
+			page_lru = page_lru->prev;
+			__page_reactivate(page);
+			goto next_page;
+		}
+
+		/* Enough free pages in this zone?  Never mind... */
+		if (page->zone->free_pages > page->zone->pages_high)
+			continue;
 
 		count--;
 		/* Page not used -> free it or put it on the old list
 		 * so it gets freed first the next time */
-		dispose = &old;
 		if (TryLockPage(page))
-			goto dispose_continue;
+			continue;
 
-		/* Release the pagemap_lru lock even if the page is not yet
-		   queued in any lru queue since we have just locked down
-		   the page so nobody else may SMP race with us running
-		   a lru_cache_del() (lru_cache_del() always run with the
-		   page locked down ;). */
-		spin_unlock(&pagemap_lru_lock);
+		/* move list head so we start at the right place next time */
+		list_del(&pgdat->active_list);
+		list_add(&pgdat->active_list, page_lru); /* <== Subtle */
+		/* We want to try to free this page ... remove from list. */
+		list_del(&(page)->lru);
+		pgdat->inactive_pages--;
+		zone->inactive_pages--;
+		PageClearInactive(page);
+		
+		/* LOCK MAGIC ALERT:
+		 * We have to drop the pgdat->page_list_lock here in order
+		 * to avoid a deadlock when we take the pagecache_lock.
+		 * After this point, we cannot make any assumption except
+		 * that the list head will still be in place!!! -- Rik
+		 */
+		spin_unlock(&pgdat->page_list_lock);
 
 		/* avoid freeing the page while it's locked */
 		get_page(page);
@@ -339,44 +469,37 @@
 			goto cache_unlock_continue;
 		}
 
-		dispose = &forget;
-		printk(KERN_ERR "shrink_mmap: unknown LRU page!\n");
-
 cache_unlock_continue:
 		spin_unlock(&pagecache_lock);
 unlock_continue:
-		spin_lock(&pagemap_lru_lock);
+		/* Damn, failed ... re-take lock and put page back the list. */
+		spin_lock(&pgdat->page_list_lock);
+		list_add(&(page)->lru, &pgdat->inactive_list);
+		pgdat->inactive_pages++;
+		zone->inactive_pages++;
+		PageSetInactive(page);
 		UnlockPage(page);
 		put_page(page);
-		list_add(page_lru, dispose);
-		continue;
-
-		/* we're holding pagemap_lru_lock, so we can just loop again */
-dispose_continue:
-		list_add(page_lru, dispose);
+		/* The list may have changed, we have to start at the head. */
+		goto roll_again;
 	}
+	/* move the list head so we start at the right place next time */
+	list_del(&pgdat->active_list);
+	list_add(&pgdat->active_list, page_lru); /* <== Subtle */
+	spin_unlock(&pgdat->page_list_lock);
 	goto out;
 
+/* OK, here we actually free a page. */
 made_inode_progress:
 	page_cache_release(page);
 made_buffer_progress:
 	UnlockPage(page);
 	put_page(page);
+	/* Not protected by a lock, it's just a statistic. */
+	pgdat->inactive_freed++;
 	ret = 1;
-	spin_lock(&pagemap_lru_lock);
-	/* nr_lru_pages needs the spinlock */
-	nr_lru_pages--;
-
-	/* wrong zone?  not looped too often?    roll again... */
-	if (page->zone != zone && count)
-		goto again;
 
 out:
-	list_splice(&young, &lru_cache);
-	list_splice(&old, lru_cache.prev);
-
-	spin_unlock(&pagemap_lru_lock);
-
 	return ret;
 }
 
@@ -395,6 +518,9 @@
 			break;
 	}
 	set_bit(PG_referenced, &page->flags);
+	if (PageInactive(page))
+		page_reactivate(page);
+
 not_found:
 	return page;
 }
--- linux-2.3.99-pre7-4/include/linux/mm.h.orig	Thu May  4 11:37:37 2000
+++ linux-2.3.99-pre7-4/include/linux/mm.h	Mon May  8 11:17:20 2000
@@ -168,7 +168,7 @@
 #define PG_uptodate		 3
 #define PG_dirty		 4
 #define PG_decr_after		 5
-#define PG_unused_01		 6
+#define PG_inactive		 6
 #define PG__unused_02		 7
 #define PG_slab			 8
 #define PG_swap_cache		 9
@@ -211,6 +211,11 @@
 
 #define PageTestandClearSwapCache(page)	test_and_clear_bit(PG_swap_cache, &(page)->flags)
 
+#define PageInactive(page)		test_bit(PG_inactive, &(page)->flags)
+#define PageSetInactive(page)		set_bit(PG_inactive, &(page)->flags)
+#define PageClearInactive(page)		clear_bit(PG_inactive, &(page)->flags)
+#define PageTestandClearInactive(page)	test_and_clear_bit(PG_inactive, &(page)->flags)
+
 #ifdef CONFIG_HIGHMEM
 #define PageHighMem(page)		test_bit(PG_highmem, &(page)->flags)
 #else
@@ -451,7 +456,8 @@
 /* filemap.c */
 extern void remove_inode_page(struct page *);
 extern unsigned long page_unuse(struct page *);
-extern int shrink_mmap(int, int, zone_t *);
+extern int free_inactive_pages(int, int, zone_t *);
+extern int refill_inactive(int, zone_t *);
 extern void truncate_inode_pages(struct address_space *, loff_t);
 
 /* generic vm_area_ops exported for stackable file systems */
--- linux-2.3.99-pre7-4/include/linux/mmzone.h.orig	Thu May  4 11:37:41 2000
+++ linux-2.3.99-pre7-4/include/linux/mmzone.h	Mon May  8 11:17:20 2000
@@ -27,7 +27,7 @@
 	 */
 	spinlock_t		lock;
 	unsigned long		offset;
-	unsigned long		free_pages;
+	unsigned long		free_pages, active_pages, inactive_pages;
 	char			low_on_memory;
 	char			zone_wake_kswapd;
 	unsigned long		pages_min, pages_low, pages_high;
@@ -85,6 +85,10 @@
 	unsigned long node_start_mapnr;
 	unsigned long node_size;
 	int node_id;
+	spinlock_t page_list_lock;
+	unsigned long active_pages, inactive_pages, inactive_target;
+	unsigned long inactive_freed, inactive_reactivated;
+	struct list_head active_list, inactive_list;
 	struct pglist_data *node_next;
 } pg_data_t;
 
--- linux-2.3.99-pre7-4/include/linux/swap.h.orig	Thu May  4 11:37:49 2000
+++ linux-2.3.99-pre7-4/include/linux/swap.h	Mon May  8 11:17:48 2000
@@ -67,7 +67,6 @@
 FASTCALL(unsigned int nr_free_pages(void));
 FASTCALL(unsigned int nr_free_buffer_pages(void));
 FASTCALL(unsigned int nr_free_highpages(void));
-extern int nr_lru_pages;
 extern atomic_t nr_async_pages;
 extern struct address_space swapper_space;
 extern atomic_t page_cache_size;
@@ -79,10 +78,13 @@
 struct sysinfo;
 
 struct zone_t;
+struct pg_data_t;
 /* linux/ipc/shm.c */
 extern int shm_swap (int, int, zone_t *);
 
 /* linux/mm/swap.c */
+extern void recalculate_inactive_target (pg_data_t *);
+extern int low_on_inactive_pages (struct zone_struct *);
 extern void swap_setup (void);
 
 /* linux/mm/vmscan.c */
@@ -159,27 +161,34 @@
 	return  count > 1;
 }
 
-extern spinlock_t pagemap_lru_lock;
-
 /*
  * Helper macros for lru_pages handling.
  */
 #define	lru_cache_add(page)			\
 do {						\
-	spin_lock(&pagemap_lru_lock);		\
-	list_add(&(page)->lru, &lru_cache);	\
-	nr_lru_pages++;				\
-	spin_unlock(&pagemap_lru_lock);		\
+	pg_data_t * lca_pgdat = page->zone->zone_pgdat; \
+	spin_lock(&lca_pgdat->page_list_lock);		\
+	list_add(&(page)->lru, &lca_pgdat->active_list);	\
+		lca_pgdat->active_pages++;		\
+		page->zone->active_pages++;		\
+	spin_unlock(&lca_pgdat->page_list_lock);	\
 } while (0)
 
 #define	lru_cache_del(page)			\
 do {						\
+	pg_data_t * lcd_pgdat = page->zone->zone_pgdat; \
 	if (!PageLocked(page))			\
 		BUG();				\
-	spin_lock(&pagemap_lru_lock);		\
+	spin_lock(&(lcd_pgdat)->page_list_lock);	\
 	list_del(&(page)->lru);			\
-	nr_lru_pages--;				\
-	spin_unlock(&pagemap_lru_lock);		\
+	if (PageTestandClearInactive(page)) {	\
+		lcd_pgdat->inactive_pages--;	\
+		page->zone->inactive_pages--;	\
+	} else { /* active page */		\
+		lcd_pgdat->active_pages--;	\
+		page->zone->active_pages--;	\
+	}					\
+	spin_unlock(&(lcd_pgdat)->page_list_lock); \
 } while (0)
 
 extern spinlock_t swaplock;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
