From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16994.40620.892220.121182@gargle.gargle.HOWL>
Date: Sun, 17 Apr 2005 21:36:44 +0400
Subject: [PATCH]: VM 4/8 dont-rotate-active-list
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <AKPM@Osdl.ORG>
List-ID: <linux-mm.kvack.org>

Currently, if zone is short on free pages, refill_inactive_zone() starts
moving pages from active_list to inactive_list, rotating active_list as it
goes. That is, pages from the tail of active_list are transferred to its head,
thus destroying lru ordering, exactly when we need it most --- when system is
low on free memory and page replacement has to be performed.

This patch modifies refill_inactive_zone() so that it scans active_list
without rotating it. To achieve this, special dummy page zone->scan_page
is maintained for each zone. This page marks a place in the active_list
reached during scanning.

As an additional bonus, if memory pressure is not so big as to start swapping
mapped pages (reclaim_mapped == 0 in refill_inactive_zone()), then not
referenced mapped pages can be left behind zone->scan_page instead of moving
them to the head of active_list. When reclaim_mapped mode is activated,
zone->scan_page is reset back to the tail of active_list so that these pages
can be re-scanned.

Signed-off-by: Nikita Danilov <nikita@clusterfs.com>


 include/linux/mmzone.h |    6 ++
 mm/page_alloc.c        |   20 ++++++++
 mm/vmscan.c            |  119 +++++++++++++++++++++++++++++++++++++------------
 3 files changed, 118 insertions(+), 27 deletions(-)

diff -puN include/linux/mmzone.h~dont-rotate-active-list include/linux/mmzone.h
--- bk-linux/include/linux/mmzone.h~dont-rotate-active-list	2005-04-17 17:52:50.000000000 +0400
+++ bk-linux-nikita/include/linux/mmzone.h	2005-04-17 17:52:50.000000000 +0400
@@ -207,6 +207,12 @@ struct zone {
 	unsigned long		present_pages;	/* amount of memory (excluding holes) */
 
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
diff -puN mm/page_alloc.c~dont-rotate-active-list mm/page_alloc.c
--- bk-linux/mm/page_alloc.c~dont-rotate-active-list	2005-04-17 17:52:50.000000000 +0400
+++ bk-linux-nikita/mm/page_alloc.c	2005-04-17 17:52:50.000000000 +0400
@@ -1615,6 +1615,9 @@ void zone_init_free_lists(struct pglist_
 	memmap_init_zone((size), (nid), (zone), (start_pfn))
 #endif
 
+/* dummy pages used to scan active lists */
+static struct page scan_pages[MAX_NUMNODES][MAX_NR_ZONES];
+
 /*
  * Set up the zone data structures:
  *   - mark all pages reserved
@@ -1637,6 +1640,7 @@ static void __init free_area_init_core(s
 		struct zone *zone = pgdat->node_zones + j;
 		unsigned long size, realsize;
 		unsigned long batch;
+		struct page *scan_page;
 
 		zone_table[NODEZONE(nid, j)] = zone;
 		realsize = size = zones_size[j];
@@ -1696,6 +1700,22 @@ static void __init free_area_init_core(s
 		zone->nr_scan_inactive = 0;
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
+		INIT_LIST_HEAD(&scan_page->lru);
+		list_add(&scan_page->lru, &zone->active_list);
+
 		if (!size)
 			continue;
 
diff -puN mm/vmscan.c~dont-rotate-active-list mm/vmscan.c
--- bk-linux/mm/vmscan.c~dont-rotate-active-list	2005-04-17 17:52:50.000000000 +0400
+++ bk-linux-nikita/mm/vmscan.c	2005-04-17 17:52:50.000000000 +0400
@@ -690,6 +690,39 @@ done:
 	pagevec_release(&pvec);
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
@@ -716,22 +749,17 @@ refill_inactive_zone(struct zone *zone, 
 	int nr_pages = sc->nr_to_scan;
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
 	LIST_HEAD(l_inactive);	/* Pages to go onto the inactive_list */
-	LIST_HEAD(l_active);	/* Pages to go onto the active_list */
+	LIST_HEAD(l_ignore);	/* Pages to be returned to the active_list */
+	LIST_HEAD(l_active);	/* Pages to go onto the head of the
+				 * active_list */
 	struct page *page;
+	struct page *scan;
 	struct pagevec pvec;
 	int reclaim_mapped = 0;
 	long mapped_ratio;
 	long distress;
 	long swap_tendency;
 
-	lru_add_drain();
-	spin_lock_irq(&zone->lru_lock);
-	pgmoved = isolate_lru_pages(nr_pages, &zone->active_list,
-				    &l_hold, &pgscanned);
-	zone->pages_scanned += pgscanned;
-	zone->nr_active -= pgmoved;
-	spin_unlock_irq(&zone->lru_lock);
-
 	/*
 	 * `distress' is a measure of how much trouble we're having reclaiming
 	 * pages.  0 -> no problems.  100 -> great trouble.
@@ -763,15 +791,66 @@ refill_inactive_zone(struct zone *zone, 
 	if (swap_tendency >= 100)
 		reclaim_mapped = 1;
 
+	scan = zone->scan_page;
+	lru_add_drain();
+	pgmoved = 0;
+	pgscanned = 0;
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
+	while (pgscanned < nr_pages &&
+	       zone->active_list.prev != zone->active_list.next) {
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
+		if (get_page_testone(page)) {
+			/*
+			 * It was already free!  release_pages() or put_page()
+			 * are about to remove it from the LRU and free it. So
+			 * put the refcount back and put the page back on the
+			 * LRU
+			 */
+			__put_page(page);
+			SetPageLRU(page);
+			list_add(&page->lru, &zone->active_list);
+		} else {
+			list_add(&page->lru, &l_hold);
+			pgmoved++;
+		}
+		pgscanned++;
+	}
+	zone->nr_active -= pgmoved;
+	zone->pages_scanned += pgscanned;
+	spin_unlock_irq(&zone->lru_lock);
+
 	while (!list_empty(&l_hold)) {
 		cond_resched();
 		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
+		/*
+		 * probably it would be useful to transfer dirty bit from pte
+		 * to the @page here.
+		 */
 		if (page_mapped(page)) {
 			if (!reclaim_mapped ||
 			    (total_swap_pages == 0 && PageAnon(page)) ||
 			    page_referenced(page, 0, sc->priority <= 0)) {
-				list_add(&page->lru, &l_active);
+				list_add(&page->lru, &l_ignore);
 				continue;
 			}
 		}
@@ -810,23 +889,9 @@ refill_inactive_zone(struct zone *zone, 
 		spin_lock_irq(&zone->lru_lock);
 	}
 
-	pgmoved = 0;
-	while (!list_empty(&l_active)) {
-		page = lru_to_page(&l_active);
-		prefetchw_prev_lru_page(page, &l_active, flags);
-		if (TestSetPageLRU(page))
-			BUG();
-		BUG_ON(!PageActive(page));
-		list_move(&page->lru, &zone->active_list);
-		pgmoved++;
-		if (!pagevec_add(&pvec, page)) {
-			zone->nr_active += pgmoved;
-			pgmoved = 0;
-			spin_unlock_irq(&zone->lru_lock);
-			__pagevec_release(&pvec);
-			spin_lock_irq(&zone->lru_lock);
-		}
-	}
+	pgmoved = spill_on_spot(zone, &l_active, &zone->active_list, &pvec);
+	zone->nr_active += pgmoved;
+ 	pgmoved = spill_on_spot(zone, &l_ignore, &scan->lru, &pvec);
 	zone->nr_active += pgmoved;
 	spin_unlock_irq(&zone->lru_lock);
 	pagevec_release(&pvec);

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
