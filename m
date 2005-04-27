Date: Wed, 27 Apr 2005 11:09:32 -0400
From: Martin Hicks <mort@sgi.com>
Subject: [PATCH/RFC 2/4] VM: page cache reclaim core
Message-ID: <20050427150932.GT8018@localhost>
References: <20050427145734.GL8018@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050427145734.GL8018@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Linux-MM <linux-mm@kvack.org>
Cc: Ray Bryant <raybry@sgi.com>, ak@suse.de
List-ID: <linux-mm.kvack.org>


The core of the local reclaim code.  It contains a few modifications
to the current reclaim code to support scanning for easily freed
Active pages. The core routine for reclaiming easily freed pages
is reclaim_clean_pages().

The motivation for this patch is for NUMA systems that would much
prefer to get local memory allocations if possible.  Large performance
regressions have been seen in situations as simple as compiling
kernels on a busy build server with a lot of memory trapped in page
cache.

The feature adds the core mechanism to free up caches, although page cache
freeing is the only one implemented currently.  Cleaning the slab
cache is a future goal.

The follow-on patches provide a manual reclaim and automatic reclaim method.

Signed-off-by:  Martin Hicks <mort@sgi.com>
---

 include/linux/mmzone.h |   13 +++
 include/linux/swap.h   |   15 +++
 mm/page_alloc.c        |    8 +-
 mm/vmscan.c            |  185 +++++++++++++++++++++++++++++++++++++++++++++----
 4 files changed, 205 insertions(+), 16 deletions(-)

Index: linux-2.6.12-rc2.wk/mm/vmscan.c
===================================================================
--- linux-2.6.12-rc2.wk.orig/mm/vmscan.c	2005-04-27 06:56:48.000000000 -0700
+++ linux-2.6.12-rc2.wk/mm/vmscan.c	2005-04-27 06:56:57.000000000 -0700
@@ -73,6 +73,12 @@ struct scan_control {
 	unsigned int gfp_mask;
 
 	int may_writepage;
+	int may_swap;
+
+	/* Flags to indicate what kind of pages to free during
+	 * calls into reclaim_clean_pages() and shrink_list().
+	 */
+	int reclaim_flags;
 
 	/* This context's SWAP_CLUSTER_MAX. If freeing memory for
 	 * suspend, we effectively ignore SWAP_CLUSTER_MAX.
@@ -376,6 +382,10 @@ static int shrink_list(struct list_head 
 	struct pagevec freed_pvec;
 	int pgactivate = 0;
 	int reclaimed = 0;
+	int reclaim_active = sc->reclaim_flags &
+	     		(RECLAIM_ACTIVE_UNMAPPED | RECLAIM_ACTIVE_MAPPED);
+	int reclaim_mapped = sc->reclaim_flags &
+				(RECLAIM_MAPPED | RECLAIM_ACTIVE_MAPPED);
 
 	cond_resched();
 
@@ -394,7 +404,10 @@ static int shrink_list(struct list_head 
 		if (TestSetPageLocked(page))
 			goto keep;
 
-		BUG_ON(PageActive(page));
+		if (!reclaim_active)
+			BUG_ON(PageActive(page));
+		else
+			BUG_ON(!PageActive(page));
 
 		sc->nr_scanned++;
 		/* Double the slab pressure for mapped and swapcache pages */
@@ -414,7 +427,8 @@ static int shrink_list(struct list_head 
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
 		 */
-		if (PageAnon(page) && !PageSwapCache(page)) {
+		if (PageAnon(page) && !PageSwapCache(page) &&
+		    sc->may_swap) {
 			void *cookie = page->mapping;
 			pgoff_t index = page->index;
 
@@ -431,7 +445,7 @@ static int shrink_list(struct list_head 
 		 * The page is mapped into the page tables of one or more
 		 * processes. Try to unmap it here.
 		 */
-		if (page_mapped(page) && mapping) {
+		if (page_mapped(page) && mapping && reclaim_mapped) {
 			switch (try_to_unmap(page)) {
 			case SWAP_FAIL:
 				goto activate_locked;
@@ -537,6 +551,8 @@ static int shrink_list(struct list_head 
 		__put_page(page);
 
 free_it:
+		/* Clear the active bit before freeing the page */
+		ClearPageActive(page);
 		unlock_page(page);
 		reclaimed++;
 		if (!pagevec_add(&freed_pvec, page))
@@ -544,8 +560,10 @@ free_it:
 		continue;
 
 activate_locked:
-		SetPageActive(page);
-		pgactivate++;
+		if (!reclaim_active) {
+			SetPageActive(page);
+			pgactivate++;
+		}
 keep_locked:
 		unlock_page(page);
 keep:
@@ -705,7 +723,7 @@ static void shrink_cache(struct zone *zo
  * The downside is that we have to touch page->_count against each page.
  * But we had to alter page->flags anyway.
  */
-static void
+static int
 refill_inactive_zone(struct zone *zone, struct scan_control *sc)
 {
 	int pgmoved;
@@ -721,6 +739,7 @@ refill_inactive_zone(struct zone *zone, 
 	long mapped_ratio;
 	long distress;
 	long swap_tendency;
+	int ret;
 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
@@ -801,6 +820,7 @@ refill_inactive_zone(struct zone *zone, 
 	}
 	zone->nr_inactive += pgmoved;
 	pgdeactivate += pgmoved;
+	ret = pgmoved;
 	if (buffer_heads_over_limit) {
 		spin_unlock_irq(&zone->lru_lock);
 		pagevec_strip(&pvec);
@@ -830,6 +850,8 @@ refill_inactive_zone(struct zone *zone, 
 
 	mod_page_state_zone(zone, pgrefill, pgscanned);
 	mod_page_state(pgdeactivate, pgdeactivate);
+
+	return ret;
 }
 
 /*
@@ -916,7 +938,8 @@ shrink_caches(struct zone **zones, struc
 		if (zone->prev_priority > sc->priority)
 			zone->prev_priority = sc->priority;
 
-		if (zone->all_unreclaimable && sc->priority != DEF_PRIORITY)
+		if (zone->unreclaimable == ALL_UNRECL &&
+		    		sc->priority != DEF_PRIORITY)
 			continue;	/* Let kswapd poll it */
 
 		shrink_zone(zone, sc);
@@ -949,6 +972,8 @@ int try_to_free_pages(struct zone **zone
 
 	sc.gfp_mask = gfp_mask;
 	sc.may_writepage = 0;
+	sc.may_swap = 1;
+	sc.reclaim_flags = RECLAIM_UNMAPPED | RECLAIM_MAPPED;
 
 	inc_page_state(allocstall);
 
@@ -1049,6 +1074,8 @@ loop_again:
 	total_reclaimed = 0;
 	sc.gfp_mask = GFP_KERNEL;
 	sc.may_writepage = 0;
+	sc.may_swap = 1;
+	sc.reclaim_flags = RECLAIM_UNMAPPED | RECLAIM_MAPPED;
 	sc.nr_mapped = read_page_state(nr_mapped);
 
 	inc_page_state(pageoutrun);
@@ -1076,8 +1103,8 @@ loop_again:
 				if (zone->present_pages == 0)
 					continue;
 
-				if (zone->all_unreclaimable &&
-						priority != DEF_PRIORITY)
+				if (zone->unreclaimable == ALL_UNRECL &&
+				    		priority != DEF_PRIORITY)
 					continue;
 
 				if (!zone_watermark_ok(zone, order,
@@ -1113,7 +1140,8 @@ scan:
 			if (zone->present_pages == 0)
 				continue;
 
-			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
+			if (zone->unreclaimable == ALL_UNRECL &&
+			    		priority != DEF_PRIORITY)
 				continue;
 
 			if (nr_pages == 0) {	/* Not software suspend */
@@ -1135,11 +1163,11 @@ scan:
 			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
 			total_reclaimed += sc.nr_reclaimed;
 			total_scanned += sc.nr_scanned;
-			if (zone->all_unreclaimable)
+			if (zone->unreclaimable == ALL_UNRECL)
 				continue;
 			if (nr_slab == 0 && zone->pages_scanned >=
 				    (zone->nr_active + zone->nr_inactive) * 4)
-				zone->all_unreclaimable = 1;
+				zone->unreclaimable = ALL_UNRECL;
 			/*
 			 * If we've done a decent amount of scanning and
 			 * the reclaim ratio is low, start doing writepage
@@ -1340,3 +1368,136 @@ static int __init kswapd_init(void)
 }
 
 module_init(kswapd_init)
+
+/* How many pages are processed at a time. */
+#define MIN_RECLAIM 32
+#define MAX_BATCH_SIZE 128
+#define UNRECLAIMABLE_TIMEOUT 5
+
+unsigned int reclaim_clean_pages(struct zone *zone, long pages, int flags)
+{
+	int batch_size;
+	unsigned int total_reclaimed = 0;
+	LIST_HEAD(page_list);
+	struct scan_control sc;
+	int max_scan;
+	int manual = flags & RECLAIM_MANUAL;
+
+	/* Zone is marked dead */
+	if (zone->unreclaimable & CLEAN_UNRECL && !manual)
+		return 0;
+
+	/* We don't really want to call this too often */
+	if (get_jiffies_64() < zone->reclaim_timeout) {
+		/* check for jiffies overflow -- needed? */
+		if (zone->reclaim_timeout - get_jiffies_64() >
+		    UNRECLAIMABLE_TIMEOUT)
+			zone->reclaim_timeout = get_jiffies_64();
+		else if (!manual)
+			return 0;
+	}
+
+	/*
+	 * Only one reclaimer scanning the zone at a time.
+	 * Lie a bit with the return value, since another thread
+	 * is in the process of reclaiming pages.
+	 */
+	if (!manual && atomic_inc_and_test(&zone->reclaim_count))
+ 		return 1;
+
+	/* Don't go into the filesystem during this page freeing attempt */
+	sc.gfp_mask = 0;
+	sc.may_writepage = 0;
+	sc.may_swap = 0;
+	sc.reclaim_flags = flags;
+
+	/* make it worth our while to take the LRU lock */
+	if (pages < MIN_RECLAIM)
+		pages = MIN_RECLAIM;
+
+	/*
+	 * Also don't take too many pages at a time,
+	 * which can lead to a big overshoot in the 
+	 * number of pages that are freed.
+	 */
+	if (pages > MAX_BATCH_SIZE)
+		batch_size = MAX_BATCH_SIZE;
+	else
+		batch_size = pages;
+
+	if (flags & (RECLAIM_UNMAPPED | RECLAIM_MAPPED)) {
+		/* Doing inactive.  Clear the active flags for now. */
+		sc.reclaim_flags &= ~(RECLAIM_ACTIVE_UNMAPPED |
+				      RECLAIM_ACTIVE_MAPPED);
+
+		/* Not an exact count, but close enough */
+		max_scan = zone->nr_inactive;
+
+		while (pages > 0 && max_scan > 0) {
+			int moved = 0;
+			int reclaimed = 0;
+			int scanned;
+
+			spin_lock_irq(&zone->lru_lock);
+			moved = isolate_lru_pages(batch_size,
+						  &zone->inactive_list,
+						  &page_list, &scanned);
+			zone->nr_inactive -= moved;
+			spin_unlock_irq(&zone->lru_lock);
+			max_scan -= moved;
+
+			reclaimed = shrink_list(&page_list, &sc);
+
+			/* Put back the unfreeable pages */
+			spin_lock_irq(&zone->lru_lock);
+			merge_lru_pages(zone, &page_list);
+			spin_unlock_irq(&zone->lru_lock);
+
+			total_reclaimed += reclaimed;
+			pages -= reclaimed;
+		}
+	}
+
+	if (flags & (RECLAIM_ACTIVE_UNMAPPED | RECLAIM_ACTIVE_MAPPED)) {
+		/* Get flags for scan_control again, in case they were
+		 * cleared while doing inactive reclaim
+		 */
+		sc.reclaim_flags = flags;
+
+		max_scan = zone->nr_active;
+		while (pages > 0 && max_scan > 0) {
+			int moved = 0;
+			int reclaimed = 0;
+			int scanned;
+
+			spin_lock_irq(&zone->lru_lock);
+			moved = isolate_lru_pages(batch_size,
+						  &zone->active_list,
+						  &page_list, &scanned);
+			zone->nr_active -= moved;
+			spin_unlock_irq(&zone->lru_lock);
+			max_scan -= moved;
+
+			reclaimed = shrink_list(&page_list, &sc);
+
+			/* Put back the unfreeable pages */
+			spin_lock_irq(&zone->lru_lock);
+			merge_lru_pages(zone, &page_list);
+			spin_unlock_irq(&zone->lru_lock);
+
+			total_reclaimed += reclaimed;
+			pages -= reclaimed;
+		}
+	}
+
+	/* The goal wasn't met */
+	if (pages > 0) {
+		zone->reclaim_timeout = get_jiffies_64() +
+					UNRECLAIMABLE_TIMEOUT;
+		zone->unreclaimable |= CLEAN_UNRECL;
+	}
+
+	atomic_set(&zone->reclaim_count, -1);
+
+	return total_reclaimed;
+}
Index: linux-2.6.12-rc2.wk/include/linux/swap.h
===================================================================
--- linux-2.6.12-rc2.wk.orig/include/linux/swap.h	2005-04-27 06:56:48.000000000 -0700
+++ linux-2.6.12-rc2.wk/include/linux/swap.h	2005-04-27 06:56:57.000000000 -0700
@@ -144,6 +144,20 @@ struct swap_list_t {
 	int next;	/* swapfile to be used next */
 };
 
+/* Page cache reclaim definitions */
+#define RECLAIM_UNMAPPED	(1<<0)
+#define RECLAIM_MAPPED		(1<<1)
+#define RECLAIM_ACTIVE_UNMAPPED	(1<<2)
+#define RECLAIM_ACTIVE_MAPPED	(1<<3)
+#define RECLAIM_SLAB		(1<<4)
+#define RECLAIM_MANUAL		(1<<5)
+#define RECLAIM_MASK		~(RECLAIM_UNMAPPED      | \
+				  RECLAIM_MAPPED | \
+				  RECLAIM_ACTIVE_UNMAPPED | \
+				  RECLAIM_ACTIVE_MAPPED | \
+				  RECLAIM_SLAB | \
+				  RECLAIM_MANUAL)
+
 /* Swap 50% full? Release swapcache more aggressively.. */
 #define vm_swap_full() (nr_swap_pages*2 < total_swap_pages)
 
@@ -174,6 +188,7 @@ extern void swap_setup(void);
 /* linux/mm/vmscan.c */
 extern int try_to_free_pages(struct zone **, unsigned int, unsigned int);
 extern int shrink_all_memory(int);
+extern unsigned int reclaim_clean_pages(struct zone *, long, int);
 extern int vm_swappiness;
 
 #ifdef CONFIG_MMU
Index: linux-2.6.12-rc2.wk/mm/page_alloc.c
===================================================================
--- linux-2.6.12-rc2.wk.orig/mm/page_alloc.c	2005-04-27 06:56:48.000000000 -0700
+++ linux-2.6.12-rc2.wk/mm/page_alloc.c	2005-04-27 06:56:57.000000000 -0700
@@ -347,7 +347,7 @@ free_pages_bulk(struct zone *zone, int c
 	int ret = 0;
 
 	spin_lock_irqsave(&zone->lock, flags);
-	zone->all_unreclaimable = 0;
+	zone->unreclaimable = 0;
 	zone->pages_scanned = 0;
 	while (!list_empty(list) && count--) {
 		page = list_entry(list->prev, struct page, lru);
@@ -1328,7 +1328,7 @@ void show_free_areas(void)
 			" inactive:%lukB"
 			" present:%lukB"
 			" pages_scanned:%lu"
-			" all_unreclaimable? %s"
+			" unreclaimable: %d"
 			"\n",
 			zone->name,
 			K(zone->free_pages),
@@ -1339,7 +1339,7 @@ void show_free_areas(void)
 			K(zone->nr_inactive),
 			K(zone->present_pages),
 			zone->pages_scanned,
-			(zone->all_unreclaimable ? "yes" : "no")
+		        zone->unreclaimable
 			);
 		printk("lowmem_reserve[]:");
 		for (i = 0; i < MAX_NR_ZONES; i++)
@@ -1751,6 +1751,8 @@ static void __init free_area_init_core(s
 		zone->nr_scan_inactive = 0;
 		zone->nr_active = 0;
 		zone->nr_inactive = 0;
+		zone->reclaim_count = ATOMIC_INIT(-1);
+		zone->reclaim_timeout = get_jiffies_64();
 		if (!size)
 			continue;
 
Index: linux-2.6.12-rc2.wk/include/linux/mmzone.h
===================================================================
--- linux-2.6.12-rc2.wk.orig/include/linux/mmzone.h	2005-04-27 06:56:48.000000000 -0700
+++ linux-2.6.12-rc2.wk/include/linux/mmzone.h	2005-04-27 06:56:57.000000000 -0700
@@ -29,6 +29,15 @@ struct free_area {
 struct pglist_data;
 
 /*
+ * Information about reclaimability of a zone's pages.
+ * After we have scanned a zone and determined that there
+ * are no other pages to free of a certain type we can
+ * stop scanning it
+ */
+#define CLEAN_UNRECL		0x1
+#define ALL_UNRECL		0x3
+
+/*
  * zone->lock and zone->lru_lock are two of the hottest locks in the kernel.
  * So add a wild amount of padding here to ensure that they fall into separate
  * cachelines.  There are very few zone structures in the machine, so space
@@ -142,7 +151,9 @@ struct zone {
 	unsigned long		nr_active;
 	unsigned long		nr_inactive;
 	unsigned long		pages_scanned;	   /* since last reclaim */
-	int			all_unreclaimable; /* All pages pinned */
+	int			unreclaimable;     /* pinned pages marker */
+	atomic_t		reclaim_count;
+	unsigned long		reclaim_timeout;
 
 	/*
 	 * prev_priority holds the scanning priority for this zone.  It is
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
