Message-ID: <4020BE25.9050908@cyberone.com.au>
Date: Wed, 04 Feb 2004 20:40:53 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: [PATCH 2/5] mm improvements
References: <4020BDCB.8030707@cyberone.com.au>
In-Reply-To: <4020BDCB.8030707@cyberone.com.au>
Content-Type: multipart/mixed;
 boundary="------------020602050509080607030702"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------020602050509080607030702
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Nick Piggin wrote:

> 2/5: vm-dont-rotate-active-list.patch
>     Nikita's patch to keep more page ordering info in the active list.
>     Also should improve system time due to less useless scanning
>     Helps swapping loads significantly.
>



--------------020602050509080607030702
Content-Type: text/plain;
 name="vm-dont-rotate-active-list.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-dont-rotate-active-list.patch"

 linux-2.6-npiggin/include/linux/mmzone.h |    6 +
 linux-2.6-npiggin/mm/page_alloc.c        |   20 ++++
 linux-2.6-npiggin/mm/vmscan.c            |  144 ++++++++++++++++++++-----------
 3 files changed, 119 insertions(+), 51 deletions(-)

diff -puN include/linux/mmzone.h~vm-dont-rotate-active-list include/linux/mmzone.h
--- linux-2.6/include/linux/mmzone.h~vm-dont-rotate-active-list	2004-02-04 14:09:44.000000000 +1100
+++ linux-2.6-npiggin/include/linux/mmzone.h	2004-02-04 14:09:44.000000000 +1100
@@ -149,6 +149,12 @@ struct zone {
 	unsigned long		zone_start_pfn;
 
 	/*
+	 * dummy page used as place holder during scanning of
+	 * active_list in refill_inactive_zone()
+	 */
+	struct page *scan_page;
+
+	/*
 	 * rarely used fields:
 	 */
 	char			*name;
diff -puN mm/page_alloc.c~vm-dont-rotate-active-list mm/page_alloc.c
--- linux-2.6/mm/page_alloc.c~vm-dont-rotate-active-list	2004-02-04 14:09:44.000000000 +1100
+++ linux-2.6-npiggin/mm/page_alloc.c	2004-02-04 14:09:44.000000000 +1100
@@ -1213,6 +1213,9 @@ void __init memmap_init_zone(struct page
 	memmap_init_zone((start), (size), (nid), (zone), (start_pfn))
 #endif
 
+/* dummy pages used to scan active lists */
+static struct page scan_pages[MAX_NUMNODES][MAX_NR_ZONES];
+
 /*
  * Set up the zone data structures:
  *   - mark all pages reserved
@@ -1235,6 +1238,7 @@ static void __init free_area_init_core(s
 		struct zone *zone = pgdat->node_zones + j;
 		unsigned long size, realsize;
 		unsigned long batch;
+		struct page *scan_page;
 
 		zone_table[NODEZONE(nid, j)] = zone;
 		realsize = size = zones_size[j];
@@ -1289,6 +1293,22 @@ static void __init free_area_init_core(s
 		atomic_set(&zone->refill_counter, 0);
 		zone->nr_active = 0;
 		zone->nr_inactive = 0;
+
+		/* initialize dummy page used for scanning */
+		scan_page = &scan_pages[nid][j];
+		zone->scan_page = scan_page;
+		memset(scan_page, 0, sizeof *scan_page);
+		scan_page->flags =
+			(1 << PG_locked) |
+			(1 << PG_error) |
+			(1 << PG_lru) |
+			(1 << PG_active) |
+			(1 << PG_reserved);
+		set_page_zone(scan_page, j);
+		page_cache_get(scan_page);
+		INIT_LIST_HEAD(&scan_page->list);
+		list_add(&scan_page->lru, &zone->active_list);
+
 		if (!size)
 			continue;
 
diff -puN mm/vmscan.c~vm-dont-rotate-active-list mm/vmscan.c
--- linux-2.6/mm/vmscan.c~vm-dont-rotate-active-list	2004-02-04 14:09:44.000000000 +1100
+++ linux-2.6-npiggin/mm/vmscan.c	2004-02-04 14:09:44.000000000 +1100
@@ -45,14 +45,15 @@
 int vm_swappiness = 60;
 static long total_memory;
 
+#define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
+
 #ifdef ARCH_HAS_PREFETCH
 #define prefetch_prev_lru_page(_page, _base, _field)			\
 	do {								\
 		if ((_page)->lru.prev != _base) {			\
 			struct page *prev;				\
 									\
-			prev = list_entry(_page->lru.prev,		\
-					struct page, lru);		\
+			prev = lru_to_page(&(_page)->lru);		\
 			prefetch(&prev->_field);			\
 		}							\
 	} while (0)
@@ -66,8 +67,7 @@ static long total_memory;
 		if ((_page)->lru.prev != _base) {			\
 			struct page *prev;				\
 									\
-			prev = list_entry(_page->lru.prev,		\
-					struct page, lru);		\
+			prev = lru_to_page(&(_page)->lru);		\
 			prefetchw(&prev->_field);			\
 		}							\
 	} while (0)
@@ -262,7 +262,7 @@ shrink_list(struct list_head *page_list,
 		int may_enter_fs;
 		int referenced;
 
-		page = list_entry(page_list->prev, struct page, lru);
+		page = lru_to_page(page_list);
 		list_del(&page->lru);
 
 		if (TestSetPageLocked(page))
@@ -507,8 +507,7 @@ shrink_cache(const int nr_pages, struct 
 
 		while (nr_scan++ < nr_to_process &&
 				!list_empty(&zone->inactive_list)) {
-			page = list_entry(zone->inactive_list.prev,
-						struct page, lru);
+			page = lru_to_page(&zone->inactive_list);
 
 			prefetchw_prev_lru_page(page,
 						&zone->inactive_list, flags);
@@ -546,7 +545,7 @@ shrink_cache(const int nr_pages, struct 
 		 * Put back any unfreeable pages.
 		 */
 		while (!list_empty(&page_list)) {
-			page = list_entry(page_list.prev, struct page, lru);
+			page = lru_to_page(&page_list);
 			if (TestSetPageLRU(page))
 				BUG();
 			list_del(&page->lru);
@@ -567,6 +566,39 @@ done:
 	return ret;
 }
 
+
+/* move pages from @page_list to the @spot, that should be somewhere on the
+ * @zone->active_list */
+static int
+spill_on_spot(struct zone *zone,
+	      struct list_head *page_list, struct list_head *spot,
+	      struct pagevec *pvec)
+{
+	struct page *page;
+	int          moved;
+
+	moved = 0;
+	while (!list_empty(page_list)) {
+		page = lru_to_page(page_list);
+		prefetchw_prev_lru_page(page, page_list, flags);
+		if (TestSetPageLRU(page))
+			BUG();
+		BUG_ON(!PageActive(page));
+		list_move(&page->lru, spot);
+		moved++;
+		if (!pagevec_add(pvec, page)) {
+			zone->nr_active += moved;
+			moved = 0;
+			spin_unlock_irq(&zone->lru_lock);
+			__pagevec_release(pvec);
+			spin_lock_irq(&zone->lru_lock);
+		}
+	}
+	return moved;
+}
+
+
+
 /*
  * This moves pages from the active list to the inactive list.
  *
@@ -593,37 +625,18 @@ refill_inactive_zone(struct zone *zone, 
 	int nr_pages = nr_pages_in;
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
 	LIST_HEAD(l_inactive);	/* Pages to go onto the inactive_list */
-	LIST_HEAD(l_active);	/* Pages to go onto the active_list */
+	LIST_HEAD(l_ignore);	/* Pages to be returned to the active_list */
+	LIST_HEAD(l_active);	/* Pages to go onto the head of the
+				 * active_list */
+
 	struct page *page;
+	struct page *scan;
 	struct pagevec pvec;
 	int reclaim_mapped = 0;
 	long mapped_ratio;
 	long distress;
 	long swap_tendency;
 
-	lru_add_drain();
-	pgmoved = 0;
-	spin_lock_irq(&zone->lru_lock);
-	while (nr_pages && !list_empty(&zone->active_list)) {
-		page = list_entry(zone->active_list.prev, struct page, lru);
-		prefetchw_prev_lru_page(page, &zone->active_list, flags);
-		if (!TestClearPageLRU(page))
-			BUG();
-		list_del(&page->lru);
-		if (page_count(page) == 0) {
-			/* It is currently in pagevec_release() */
-			SetPageLRU(page);
-			list_add(&page->lru, &zone->active_list);
-		} else {
-			page_cache_get(page);
-			list_add(&page->lru, &l_hold);
-			pgmoved++;
-		}
-		nr_pages--;
-	}
-	zone->nr_active -= pgmoved;
-	spin_unlock_irq(&zone->lru_lock);
-
 	/*
 	 * `distress' is a measure of how much trouble we're having reclaiming
 	 * pages.  0 -> no problems.  100 -> great trouble.
@@ -655,10 +668,53 @@ refill_inactive_zone(struct zone *zone, 
 	if (swap_tendency >= 100)
 		reclaim_mapped = 1;
 
+	scan = zone->scan_page;
+	lru_add_drain();
+	pgmoved = 0;
+	spin_lock_irq(&zone->lru_lock);
+	if (reclaim_mapped) {
+		/*
+		 * When scanning active_list with !reclaim_mapped mapped
+		 * inactive pages are left behind zone->scan_page. If zone is
+		 * switched to reclaim_mapped mode reset zone->scan_page to
+		 * the end of inactive list so that inactive mapped pages are
+		 * re-scanned.
+		 */
+		list_move_tail(&scan->lru, &zone->active_list);
+	}
+	while (nr_pages && zone->active_list.prev != zone->active_list.next) {
+		/*
+		 * if head of active list reached---wrap to the tail
+		 */
+		if (scan->lru.prev == &zone->active_list)
+			list_move_tail(&scan->lru, &zone->active_list);
+		page = lru_to_page(&scan->lru);
+		prefetchw_prev_lru_page(page, &zone->active_list, flags);
+		if (!TestClearPageLRU(page))
+			BUG();
+		list_del(&page->lru);
+		if (page_count(page) == 0) {
+			/* It is currently in pagevec_release() */
+			SetPageLRU(page);
+			list_add(&page->lru, &zone->active_list);
+		} else {
+			page_cache_get(page);
+			list_add(&page->lru, &l_hold);
+			pgmoved++;
+		}
+		nr_pages--;
+	}
+	zone->nr_active -= pgmoved;
+	spin_unlock_irq(&zone->lru_lock);
+
 	while (!list_empty(&l_hold)) {
-		page = list_entry(l_hold.prev, struct page, lru);
+		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
 		if (page_mapped(page)) {
+			/*
+			 * probably it would be useful to transfer dirty bit
+			 * from pte to the @page here.
+			 */
 			pte_chain_lock(page);
 			if (page_mapped(page) && page_referenced(page)) {
 				pte_chain_unlock(page);
@@ -667,7 +723,7 @@ refill_inactive_zone(struct zone *zone, 
 			}
 			pte_chain_unlock(page);
 			if (!reclaim_mapped) {
-				list_add(&page->lru, &l_active);
+				list_add(&page->lru, &l_ignore);
 				continue;
 			}
 		}
@@ -687,7 +743,7 @@ refill_inactive_zone(struct zone *zone, 
 	pgmoved = 0;
 	spin_lock_irq(&zone->lru_lock);
 	while (!list_empty(&l_inactive)) {
-		page = list_entry(l_inactive.prev, struct page, lru);
+		page = lru_to_page(&l_inactive);
 		prefetchw_prev_lru_page(page, &l_inactive, flags);
 		if (TestSetPageLRU(page))
 			BUG();
@@ -714,23 +770,9 @@ refill_inactive_zone(struct zone *zone, 
 		spin_lock_irq(&zone->lru_lock);
 	}
 
-	pgmoved = 0;
-	while (!list_empty(&l_active)) {
-		page = list_entry(l_active.prev, struct page, lru);
-		prefetchw_prev_lru_page(page, &l_active, flags);
-		if (TestSetPageLRU(page))
-			BUG();
-		BUG_ON(!PageActive(page));
-		list_move(&page->lru, &zone->active_list);
-		pgmoved++;
-		if (!pagevec_add(&pvec, page)) {
+	pgmoved = spill_on_spot(zone, &l_active, &zone->active_list, &pvec);
 			zone->nr_active += pgmoved;
-			pgmoved = 0;
-			spin_unlock_irq(&zone->lru_lock);
-			__pagevec_release(&pvec);
-			spin_lock_irq(&zone->lru_lock);
-		}
-	}
+	pgmoved = spill_on_spot(zone, &l_ignore, &scan->lru, &pvec);
 	zone->nr_active += pgmoved;
 	spin_unlock_irq(&zone->lru_lock);
 	pagevec_release(&pvec);

_

--------------020602050509080607030702--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
