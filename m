Received: from timlap ([24.161.37.51]) by mail4.nycap.rr.com
          (Post.Office MTA v3.5.3 release 223
          ID# 0-59787U250000L250000S0V35) with SMTP id com
          for <Linux-MM@kvack.org>; Mon, 15 May 2000 11:12:54 -0400
Message-ID: <001a01bfbe7f$b7c70220$3325a118@timlap>
From: "T. C. Raymond" <tc.raymond@ieee.org>
Subject: [patch] active/inactive lists
Date: Mon, 15 May 2000 11:10:33 -0400
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Below is Rik van Riel's active/inactive list lunch snapshot dated 12 May
2000 applied to pre9-1.  I am not a linux mm expert, so there may have been
a mistake or two in porting from 7-4 to 9-1.  This patch does compile and
runs, however it goes belly up after a few minutes under moderate load on a
132MB machine.  I did not attempt anything stressful.  It simply begins
killing processes when memory runs low.  At any rate, I thought it might
save someone some time, so here it is.  Use it or toss it at your will.

T. C. Raymond

diff -u --recursive --new-file linux-2.3.99/include/linux/mm.h
linux-2.3.99_expvm/include/linux/mm.h
--- linux-2.3.99/include/linux/mm.h	Sun May 14 19:03:44 2000
+++ linux-2.3.99_expvm/include/linux/mm.h	Sun May 14 14:51:37 2000
@@ -168,7 +168,7 @@
 #define PG_uptodate		 3
 #define PG_dirty		 4
 #define PG_decr_after		 5
-#define PG_unused_01		 6
+#define PG_inactive		 6
 #define PG__unused_02		 7
 #define PG_slab			 8
 #define PG_swap_cache		 9
@@ -215,6 +215,11 @@

 #define PageTestandClearSwapCache(page)	test_and_clear_bit(PG_swap_cache,
&(page)->flags)

+#define PageInactive(page)             test_bit(PG_inactive,
&(page)->flags)
+#define PageSetInactive(page)          set_bit(PG_inactive, &(page)->flags)
+#define PageClearInactive(page)                clear_bit(PG_inactive,
&(page)->flags)
+#define PageTestandClearInactive(page) test_and_clear_bit(PG_inactive,
&(page)->flags)
+
 #ifdef CONFIG_HIGHMEM
 #define PageHighMem(page)		test_bit(PG_highmem, &(page)->flags)
 #else
@@ -455,7 +460,9 @@
 /* filemap.c */
 extern void remove_inode_page(struct page *);
 extern unsigned long page_unuse(struct page *);
-extern int shrink_mmap(int, int);
+extern void page_reactivate(struct page *);
+extern int free_inactive_pages(int, int, zone_t *);
+extern int refill_inactive(int, zone_t *);
 extern void truncate_inode_pages(struct address_space *, loff_t);

 /* generic vm_area_ops exported for stackable file systems */
diff -u --recursive --new-file linux-2.3.99/include/linux/mmzone.h
linux-2.3.99_expvm/include/linux/mmzone.h
--- linux-2.3.99/include/linux/mmzone.h	Sun May 14 19:03:44 2000
+++ linux-2.3.99_expvm/include/linux/mmzone.h	Sun May 14 14:51:37 2000
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
+       unsigned long active_pages, inactive_pages, inactive_target;
+       unsigned long inactive_freed, inactive_reactivated;
+       struct list_head active_list, inactive_list;
 	struct pglist_data *node_next;
 } pg_data_t;

diff -u --recursive --new-file linux-2.3.99/include/linux/swap.h
linux-2.3.99_expvm/include/linux/swap.h
--- linux-2.3.99/include/linux/swap.h	Sun May 14 19:03:46 2000
+++ linux-2.3.99_expvm/include/linux/swap.h	Sun May 14 17:50:28 2000
@@ -67,7 +67,7 @@
 FASTCALL(unsigned int nr_free_pages(void));
 FASTCALL(unsigned int nr_free_buffer_pages(void));
 FASTCALL(unsigned int nr_free_highpages(void));
-extern int nr_lru_pages;
+//extern int nr_lru_pages;
 extern atomic_t nr_async_pages;
 extern struct address_space swapper_space;
 extern atomic_t page_cache_size;
@@ -79,14 +79,17 @@
 struct sysinfo;

 struct zone_t;
+struct pg_data_t;
 /* linux/ipc/shm.c */
 extern int shm_swap(int, int);

 /* linux/mm/swap.c */
+extern void recalculate_inactive_target (pg_data_t *);
+extern int low_on_inactive_pages (struct zone_struct *);
 extern void swap_setup(void);

 /* linux/mm/vmscan.c */
-extern int try_to_free_pages(unsigned int gfp_mask);
+extern int try_to_free_pages(unsigned int gfp_mask, zone_t *);

 /* linux/mm/page_io.c */
 extern void rw_swap_page(int, struct page *, int);
@@ -158,32 +161,42 @@
 	return  count > 1;
 }

-extern spinlock_t pagemap_lru_lock;
+//extern spinlock_t pagemap_lru_lock;

 /*
  * Helper macros for lru_pages handling.
  */
 #define	lru_cache_add(page)			\
 do {						\
-	spin_lock(&pagemap_lru_lock);		\
-	list_add(&(page)->lru, &lru_cache);	\
-	nr_lru_pages++;				\
-	spin_unlock(&pagemap_lru_lock);		\
+       pg_data_t * lca_pgdat = page->zone->zone_pgdat; \
+       spin_lock(&lca_pgdat->page_list_lock);          \
+       list_add(&(page)->lru, &lca_pgdat->active_list);        \
+               lca_pgdat->active_pages++;              \
+               page->zone->active_pages++;             \
+       spin_unlock(&lca_pgdat->page_list_lock);        \
 } while (0)

 #define	__lru_cache_del(page)			\
 do {						\
+	pg_data_t * lcd_pgdat = page->zone->zone_pgdat; \
 	list_del(&(page)->lru);			\
-	nr_lru_pages--;				\
+	if (PageTestandClearInactive(page)) {   \
+                lcd_pgdat->inactive_pages--;    \
+                page->zone->inactive_pages--;   \
+        } else { /* active page */              \
+                lcd_pgdat->active_pages--;      \
+                page->zone->active_pages--;     \
+        }                                       \
 } while (0)

 #define	lru_cache_del(page)			\
 do {						\
+	pg_data_t * lcd_pgdat = page->zone->zone_pgdat; \
 	if (!PageLocked(page))			\
 		BUG();				\
-	spin_lock(&pagemap_lru_lock);		\
+	spin_lock(&(lcd_pgdat)->page_list_lock);		\
 	__lru_cache_del(page);			\
-	spin_unlock(&pagemap_lru_lock);		\
+        spin_unlock(&(lcd_pgdat)->page_list_lock); \
 } while (0)

 extern spinlock_t swaplock;
diff -u --recursive --new-file linux-2.3.99/mm/filemap.c
linux-2.3.99_expvm/mm/filemap.c
--- linux-2.3.99/mm/filemap.c	Thu May 11 22:10:53 2000
+++ linux-2.3.99_expvm/mm/filemap.c	Sun May 14 14:27:10 2000
@@ -244,24 +244,168 @@
 	spin_unlock(&pagecache_lock);
 }

-int shrink_mmap(int priority, int gfp_mask)
+//int shrink_mmap(int priority, int gfp_mask)
+/* basically lru_cache_del() and lru_cache_add() merged together */
+void __page_reactivate(struct page *page)
+{
+       struct zone_struct * zone = page->zone;
+       pg_data_t * pgdat = zone->zone_pgdat;
+
+       list_del(&(page)->lru);
+       pgdat->inactive_pages--;
+       zone->inactive_pages--;
+       PageClearInactive(page);
+
+       list_add(&(page)->lru, &pgdat->active_list);
+       pgdat->active_pages++;
+       zone->active_pages++;
+       pgdat->inactive_reactivated++;
+
+       /* Low on inactive pages => wake up kswapd. */
+//     if (low_on_inactive_pages(zone)) {
+               /* We are kswapd, no need to wake ourselves up. */
+//             if (!(current->flags & PF_MEMALLOC))
+//                     wake_up_interruptible(&kswapd_wait);
+//     }
+}
+
+void page_reactivate(struct page *page)
+{
+       pg_data_t * pgdat = page->zone->zone_pgdat;
+       spin_lock(&pgdat->page_list_lock);
+       __page_reactivate(page);
+       spin_unlock(&pgdat->page_list_lock);
+}
+
+/**
+ *     refill_inactive -       kswapd
+ *     @priority: how hard we should try
+ *     @zone: memory zone to pay extra attention to
+ *
+ *     Called from do_try_to_free_pages, we refill the
+ *     inactive list for the pgdat (NUMA node) zone belongs
+ *     to. We must fail in time so that the active list is
+ *     refilled by swap_out.
+ */
+int refill_inactive(int priority, zone_t *zone)
 {
 	int ret = 0, count;
-	LIST_HEAD(old);
-	struct list_head * page_lru, * dispose;
-	struct page * page = NULL;
+	//LIST_HEAD(old);
+	struct list_head * page_lru;
+	struct page * page;
+	pg_data_t * pgdat = zone->zone_pgdat;

-	count = nr_lru_pages / (priority + 1);
+	count = pgdat->active_pages;

 	/* we need pagemap_lru_lock for list_del() ... subtle code below */
-	spin_lock(&pagemap_lru_lock);
-	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
+	spin_lock(&pgdat->page_list_lock);
+	//while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
+	for (page_lru = pgdat->active_list.prev;  count > 0;
+                        page_lru = page_lru->prev ) {
+                /* Catch it if we loop back to the list head. */
+                if (page_lru == &pgdat->active_list)
+                        break;
 		page = list_entry(page_lru, struct page, lru);
-		list_del(page_lru);
-
-		dispose = &lru_cache;
+		/* The page is in use, or was used very recently
+                 * so we will leave it on the active list.
+                 * Old buffer pages fall through. -- Rik
+                 */
 		if (PageTestandClearReferenced(page))
-			goto dispose_continue;
+			continue;
+
+		if (!page->buffers && page_count(page) > 1)
+			continue;
+
+                /* Page locked?  Somebody must be using it */
+                if (PageLocked(page))
+                        continue;
+
+                /* Move the page; make sure not to clobber page_lru. */
+                page_lru = page_lru->prev;
+
+                /* Move the page to the inactive list and update stats, etc
*/
+                list_del(&(page)->lru);
+                pgdat->active_pages--;
+                zone->active_pages--;
+                PageSetInactive(page);
+
+                list_add(&(page)->lru, &pgdat->inactive_list);
+                pgdat->inactive_pages++;
+                zone->inactive_pages++;
+ //             UnlockPage(page);
+
+                ret = 1;
+
+                /* Damn, we ran out of active pages... */
+                if (!zone->active_pages)
+                        break;
+        }
+        /* move the list head so we start at the right place next time */
+        list_del(&pgdat->active_list);
+        list_add(&pgdat->active_list, page_lru); /* <== Subtle */
+        spin_unlock(&pgdat->page_list_lock);
+
+        if (zone->free_pages > zone->pages_high &&
+                        !low_on_inactive_pages(zone)) {
+                zone->zone_wake_kswapd = 0;
+                zone->low_on_memory = 0;
+        }
+
+        return ret;
+}
+
+ /**
+  *     free_inactive_pages -   kswapd
+  *     @priority: how hard we should try
+  *     @zone: memory zone to pay extra attention to
+  *
+  *     This is the function that actually frees memory.
+  *     We scan the inactive list and free every page that
+  *     we can, with the exception of recently touched pages,
+  *     which are moved to the active list.
+  */
+int free_inactive_pages(int priority, int gfp_mask, zone_t *zone)
+{
+        int ret = 0, count;
+        struct list_head * page_lru;
+        struct page * page = NULL;
+        pg_data_t * pgdat = zone->zone_pgdat;
+
+        count = pgdat->inactive_pages / (priority + 1);
+
+        spin_lock(&pgdat->page_list_lock);
+roll_again:
+        for (page_lru = pgdat->inactive_list.prev;  count > 0;
+                        page_lru = page_lru->prev ) {
+next_page:
+                if (!page_lru) {
+                        spin_unlock(&pgdat->page_list_lock);
+                        BUG();
+                }
+                /* Catch it if we loop back to the list head. */
+                if (page_lru == &pgdat->inactive_list)
+                        break;
+                page = list_entry(page_lru, struct page, lru);
+
+                /* The page is/was used => move it to the active list.
+                 * Make sure to assign the next 'page_lru' *before* we
+                 * move the page to another list.
+                 */
+                if (test_and_clear_bit(PG_referenced, &page->flags)) {
+                        page_lru = page_lru->prev;
+                        __page_reactivate(page);
+                        goto next_page;
+                }
+
+                if (!page->buffers && page_count(page) > 1) {
+                        page_lru = page_lru->prev;
+                        __page_reactivate(page);
+                        goto next_page;
+                }
+
+                /* Enough free pages in this zone?  Never mind... */
+                if (page->zone->free_pages > page->zone->pages_high)
+                        continue;

 		count--;

@@ -282,18 +426,31 @@
 		 * Avoid unscalable SMP locking for pages we can
 		 * immediate tell are untouchable..
 		 */
-		if (!page->buffers && page_count(page) > 1)
-			goto dispose_continue;
-
+
 		if (TryLockPage(page))
-			goto dispose_continue;
+			continue;

-		/* Release the pagemap_lru lock even if the page is not yet
-		   queued in any lru queue since we have just locked down
-		   the page so nobody else may SMP race with us running
-		   a lru_cache_del() (lru_cache_del() always run with the
-		   page locked down ;). */
-		spin_unlock(&pagemap_lru_lock);
+
+                /* move list head so we start at the right place next time
*/
+                list_del(&pgdat->active_list);
+                list_add(&pgdat->active_list, page_lru); /* <== Subtle */
+                /* We want to try to free this page ... remove from list.
*/
+                list_del(&(page)->lru);
+                pgdat->inactive_pages--;
+                zone->inactive_pages--;
+                PageClearInactive(page);
+
+                if (pgdat->active_list.next == &pgdat->active_list &&
+                                pgdat->inactive_pages)
+                        BUG();
+
+                /* LOCK MAGIC ALERT:
+                 * We have to drop the pgdat->page_list_lock here in order
+                 * to avoid a deadlock when we take the pagecache_lock.
+                 * After this point, we cannot make any assumption except
+                 * that the list head will still be in place!!! -- Rik
+                 */
+                spin_unlock(&pgdat->page_list_lock);

 		/* avoid freeing the page while it's locked */
 		page_cache_get(page);
@@ -353,34 +510,38 @@
 			goto cache_unlock_continue;
 		}

-		printk(KERN_ERR "shrink_mmap: unknown LRU page!\n");
-
 cache_unlock_continue:
 		spin_unlock(&pagecache_lock);
 unlock_continue:
-		spin_lock(&pagemap_lru_lock);
+		/* Damn, failed ... re-take lock and put page back the list. */
+               spin_lock(&pgdat->page_list_lock);
+               list_add(&(page)->lru, &pgdat->inactive_list);
+               pgdat->inactive_pages++;
+               zone->inactive_pages++;
+               PageSetInactive(page);
 		UnlockPage(page);
-		page_cache_release(page);
-dispose_continue:
-		list_add(page_lru, dispose);
+		put_page(page);
+		/* The list may have changed, we have to start at the head. */
+                goto roll_again;
 	}
+        /* move the list head so we start at the right place next time */
+        list_del(&pgdat->active_list);
+        list_add(&pgdat->active_list, page_lru); /* <== Subtle */
+        spin_unlock(&pgdat->page_list_lock);
 	goto out;

+/* OK, here we actually free a page. */
 made_inode_progress:
 	page_cache_release(page);
 made_buffer_progress:
 	UnlockPage(page);
 	page_cache_release(page);
+	/* Not protected by a lock, it's just a statistic. */
+       pgdat->inactive_freed++;
 	ret = 1;
-	spin_lock(&pagemap_lru_lock);
-	/* nr_lru_pages needs the spinlock */
-	nr_lru_pages--;
+	printk ("VM: freed a page\n");

 out:
-	list_splice(&old, lru_cache.prev);
-
-	spin_unlock(&pagemap_lru_lock);
-
 	return ret;
 }

@@ -399,6 +560,9 @@
 			break;
 	}
 	SetPageReferenced(page);
+	if (PageInactive(page))
+                page_reactivate(page);
+
 not_found:
 	return page;
 }
diff -u --recursive --new-file linux-2.3.99/mm/page_alloc.c
linux-2.3.99_expvm/mm/page_alloc.c
--- linux-2.3.99/mm/page_alloc.c	Fri May 12 14:21:20 2000
+++ linux-2.3.99_expvm/mm/page_alloc.c	Sun May 14 18:04:11 2000
@@ -93,6 +93,8 @@
 		BUG();
 	if (PageDecrAfter(page))
 		BUG();
+	if (PageInactive(page))
+		BUG();

 	zone = page->zone;

@@ -139,7 +141,8 @@

 	spin_unlock_irqrestore(&zone->lock, flags);

-	if (zone->free_pages > zone->pages_high) {
+	if (zone->free_pages > zone->pages_high &&
+                       !low_on_inactive_pages(zone)) {
 		zone->zone_wake_kswapd = 0;
 		zone->low_on_memory = 0;
 	}
@@ -233,7 +236,8 @@
 			BUG();

 		/* Are we supposed to free memory? Don't make it worse.. */
-		if (!z->zone_wake_kswapd) {
+		if (!z->zone_wake_kswapd && z->free_pages > z->pages_low
+                               && !low_on_inactive_pages(z)) {
 			struct page *page = rmqueue(z, order);
 			if (z->free_pages < z->pages_low) {
 				z->zone_wake_kswapd = 1;
@@ -268,9 +272,10 @@
 	 * we'd better do some synchronous swap-out. kswapd has not
 	 * been able to cope..
 	 */
+	zone = zonelist->zones;
 	if (!(current->flags & PF_MEMALLOC)) {
 		int gfp_mask = zonelist->gfp_mask;
-		if (!try_to_free_pages(gfp_mask)) {
+		if (!try_to_free_pages(gfp_mask, (zone_t *)(zone))) {
 			if (!(gfp_mask & __GFP_HIGH))
 				goto fail;
 		}
@@ -497,7 +502,7 @@
 	freepages.min += i;
 	freepages.low += i * 2;
 	freepages.high += i * 3;
-	memlist_init(&lru_cache);
+	//memlist_init(&lru_cache);

 	/*
 	 * Some architectures (with lots of mem and discontinous memory
@@ -514,6 +519,15 @@
 	pgdat->node_size = totalpages;
 	pgdat->node_start_paddr = zone_start_paddr;
 	pgdat->node_start_mapnr = (lmem_map - mem_map);
+	/* Set up structures for the active / inactive memory lists. */
+        pgdat->page_list_lock = SPIN_LOCK_UNLOCKED;
+        pgdat->active_pages = 0;
+        pgdat->inactive_pages = 0;
+        pgdat->inactive_target = realtotalpages >> 5;
+        pgdat->inactive_freed = 0;
+        pgdat->inactive_reactivated = 0;
+        memlist_init(&pgdat->active_list);
+        memlist_init(&pgdat->inactive_list);

 	/*
 	 * Initially all pages are reserved - free ones are freed
@@ -558,6 +572,8 @@
 		zone->pages_high = mask*3;
 		zone->low_on_memory = 0;
 		zone->zone_wake_kswapd = 0;
+		zone->active_pages = 0;
+                zone->inactive_pages = 0;
 		zone->zone_mem_map = mem_map + offset;
 		zone->zone_start_mapnr = offset;
 		zone->zone_start_paddr = zone_start_paddr;
diff -u --recursive --new-file linux-2.3.99/mm/swap.c
linux-2.3.99_expvm/mm/swap.c
--- linux-2.3.99/mm/swap.c	Mon Dec  6 13:14:13 1999
+++ linux-2.3.99_expvm/mm/swap.c	Sun May 14 13:16:03 2000
@@ -5,7 +5,7 @@
  */

 /*
- * This file contains the default values for the opereation of the
+ * This file contains the default values for the operation of the
  * Linux VM subsystem. Fine-tuning documentation can be found in
  * linux/Documentation/sysctl/vm.txt.
  * Started 18.12.91
@@ -63,6 +63,57 @@
 	SWAP_CLUSTER_MAX,	/* minimum number of tries */
 	SWAP_CLUSTER_MAX,	/* do swap I/O in clusters of this size */
 };
+
+void recalculate_inactive_target(pg_data_t * pgdat)
+{
+       int delta = pgdat->inactive_target / 4;
+
+       /* More than 25% reactivations?  Shrink the inactive list a bit */
+       if (pgdat->inactive_freed < pgdat->inactive_reactivated * 3)
+               pgdat->inactive_target -= delta;
+       else
+               pgdat->inactive_target += delta;
+
+       pgdat->inactive_freed /= 2;
+       pgdat->inactive_reactivated /= 2;
+
+       /* Make sure the inactive target isn't too big or too small */
+       if (pgdat->inactive_target > pgdat->node_size >> 2)
+               pgdat->inactive_target = pgdat->node_size >> 2;
+       if (pgdat->inactive_target < pgdat->node_size >> 6)
+               pgdat->inactive_target = pgdat->node_size >> 6;
+}
+
+/**
+ *     low_on_inactive_pages - vm helper function
+ *     @zone: memory zone to investigate
+ *
+ *     low_on_inactive_pages returns 1 if the zone in question
+ *     does not have enough inactive pages, 0 otherwise. It will
+ *     also recalculate pgdat->inactive_target, if needed.
+ */
+int low_on_inactive_pages(struct zone_struct *zone)
+{
+       pg_data_t * pgdat = zone->zone_pgdat;
+       if (!pgdat)
+               BUG();
+
+       if (pgdat->inactive_freed + pgdat->inactive_reactivated >
+                       pgdat->inactive_target) {
+               recalculate_inactive_target(pgdat);
+       }
+
+       if (zone->free_pages + zone->inactive_pages > zone->pages_high * 2)
+               return 0;
+
+       if (zone->inactive_pages < zone->pages_low)
+               return 1;
+
+       if (pgdat->inactive_pages < pgdat->inactive_target)
+               return 1;
+
+       return 0;  /* else */
+}

 /*
  * Perform any setup for the swap system
diff -u --recursive --new-file linux-2.3.99/mm/vmscan.c
linux-2.3.99_expvm/mm/vmscan.c
--- linux-2.3.99/mm/vmscan.c	Sun May 14 18:59:40 2000
+++ linux-2.3.99_expvm/mm/vmscan.c	Sun May 14 17:36:23 2000
@@ -56,6 +56,8 @@
 		 */
 		set_pte(page_table, pte_mkold(pte));
                 SetPageReferenced(page);
+		if (PageInactive(page))
+                       page_reactivate(page);
 		goto out_failed;
 	}

@@ -431,21 +433,33 @@
  */
 #define FREE_COUNT	8
 #define SWAP_COUNT	8
-static int do_try_to_free_pages(unsigned int gfp_mask)
+static int do_try_to_free_pages(unsigned int gfp_mask, zone_t *zone)
 {
 	int priority;
 	int count = FREE_COUNT;
+	int ret = 0;
+        pg_data_t * pgdat = zone->zone_pgdat;
+
+	/* We hit a NULL zone... */
+        if (!pgdat)
+                return 0;

 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);

 	priority = 6;
 	do {
-		while (shrink_mmap(priority, gfp_mask)) {
-			if (!--count)
+		while (free_inactive_pages(priority, gfp_mask, zone)) {
+                        ret = 1;
+                        if (zone->free_pages > zone->pages_high)
+                                break;
+                        if (!--count && !low_on_inactive_pages(zone))
 				goto done;
 		}

+		if (pgdat->inactive_pages < pgdat->inactive_target ||
+                                zone->inactive_pages < zone->pages_high)
+                        refill_inactive(priority, zone);

 		/* Try to get rid of some shared memory pages.. */
 		if (gfp_mask & __GFP_IO) {
@@ -479,8 +493,14 @@
 		}
 	} while (--priority >= 0);

+
+        while (free_inactive_pages(priority, gfp_mask, zone) &&
+                        zone->free_pages < zone->pages_high &&
+                        !low_on_inactive_pages(zone))
+                /* nothing */;
+
 	/* Always end on a shrink_mmap.. */
-	while (shrink_mmap(0, gfp_mask)) {
+	while (free_inactive_pages(0, gfp_mask, zone)) {
 		if (!--count)
 			goto done;
 	}
@@ -540,11 +560,13 @@
 				zone_t *zone = pgdat->node_zones+ i;
 				if (tsk->need_resched)
 					schedule();
+				if (!zone || !zone->zone_pgdat)
+                                        continue;
 				if (!zone->size || !zone->zone_wake_kswapd)
 					continue;
 				if (zone->free_pages < zone->pages_low)
 					something_to_do = 1;
-				do_try_to_free_pages(GFP_KSWAPD);
+				do_try_to_free_pages(GFP_KSWAPD, zone);
 			}
 			run_task_queue(&tq_disk);
 			pgdat = pgdat->node_next;
@@ -572,13 +594,13 @@
  * can be done by just dropping cached pages without having
  * any deadlock issues.
  */
-int try_to_free_pages(unsigned int gfp_mask)
+int try_to_free_pages(unsigned int gfp_mask, zone_t *zone)
 {
 	int retval = 1;

 	if (gfp_mask & __GFP_WAIT) {
 		current->flags |= PF_MEMALLOC;
-		retval = do_try_to_free_pages(gfp_mask);
+		retval = do_try_to_free_pages(gfp_mask, zone);
 		current->flags &= ~PF_MEMALLOC;
 	}
 	return retval;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
