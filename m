Message-Id: <20080108210000.932935848@redhat.com>
References: <20080108205939.323955454@redhat.com>
Date: Tue, 08 Jan 2008 15:59:43 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [patch 04/19] Use an indexed array for LRU variables
Content-Disposition: inline; filename=cl-use-indexed-array-of-lru-lists.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

V1 -> V2 [lts]:
+ Remove extraneous  __dec_zone_state(zone, NR_ACTIVE) pointed
  out by Mel G.

>From clameter@sgi.com Wed Aug 29 11:39:51 2007

Currently we are defining explicit variables for the inactive
and active list. An indexed array can be more generic and avoid
repeating similar code in several places in the reclaim code.

We are saving a few bytes in terms of code size:

Before:

   text    data     bss     dec     hex filename
4097753  573120 4092484 8763357  85b7dd vmlinux

After:

   text    data     bss     dec     hex filename
4097729  573120 4092484 8763333  85b7c5 vmlinux

Having an easy way to add new lru lists may ease future work on
the reclaim code.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>

 include/linux/mm_inline.h |   34 ++++++++---
 include/linux/mmzone.h    |   17 +++--
 mm/page_alloc.c           |    9 +--
 mm/swap.c                 |    2 
 mm/vmscan.c               |  132 ++++++++++++++++++++++------------------------
 mm/vmstat.c               |    3 -
 6 files changed, 107 insertions(+), 90 deletions(-)

Index: linux-2.6.24-rc6-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/mmzone.h	2008-01-02 12:37:11.000000000 -0500
+++ linux-2.6.24-rc6-mm1/include/linux/mmzone.h	2008-01-02 12:37:32.000000000 -0500
@@ -80,8 +80,8 @@ struct zone_padding {
 enum zone_stat_item {
 	/* First 128 byte cacheline (assuming 64 bit words) */
 	NR_FREE_PAGES,
-	NR_INACTIVE,
-	NR_ACTIVE,
+	NR_INACTIVE,	/* must match order of LRU_[IN]ACTIVE */
+	NR_ACTIVE,	/*  "     "     "   "       "         */
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
@@ -105,6 +105,13 @@ enum zone_stat_item {
 #endif
 	NR_VM_ZONE_STAT_ITEMS };
 
+enum lru_list {
+	LRU_INACTIVE,	/* must match order of NR_[IN]ACTIVE */
+	LRU_ACTIVE,	/*  "     "     "   "       "        */
+	NR_LRU_LISTS };
+
+#define for_each_lru(l) for (l = 0; l < NR_LRU_LISTS; l++)
+
 struct per_cpu_pages {
 	int count;		/* number of pages in the list */
 	int high;		/* high watermark, emptying needed */
@@ -258,10 +265,8 @@ struct zone {
 
 	/* Fields commonly accessed by the page reclaim scanner */
 	spinlock_t		lru_lock;	
-	struct list_head	active_list;
-	struct list_head	inactive_list;
-	unsigned long		nr_scan_active;
-	unsigned long		nr_scan_inactive;
+	struct list_head	list[NR_LRU_LISTS];
+	unsigned long		nr_scan[NR_LRU_LISTS];
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	unsigned long		flags;		   /* zone flags, see below */
 
Index: linux-2.6.24-rc6-mm1/include/linux/mm_inline.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/mm_inline.h	2008-01-02 12:37:27.000000000 -0500
+++ linux-2.6.24-rc6-mm1/include/linux/mm_inline.h	2008-01-02 12:37:32.000000000 -0500
@@ -30,43 +30,55 @@ static inline int page_file_cache(struct
 }
 
 static inline void
+add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l)
+{
+	list_add(&page->lru, &zone->list[l]);
+	__inc_zone_state(zone, NR_INACTIVE + l);
+}
+
+static inline void
+del_page_from_lru_list(struct zone *zone, struct page *page, enum lru_list l)
+{
+	list_del(&page->lru);
+	__dec_zone_state(zone, NR_INACTIVE + l);
+}
+
+
+static inline void
 add_page_to_active_list(struct zone *zone, struct page *page)
 {
-	list_add(&page->lru, &zone->active_list);
-	__inc_zone_state(zone, NR_ACTIVE);
+	add_page_to_lru_list(zone, page, LRU_ACTIVE);
 }
 
 static inline void
 add_page_to_inactive_list(struct zone *zone, struct page *page)
 {
-	list_add(&page->lru, &zone->inactive_list);
-	__inc_zone_state(zone, NR_INACTIVE);
+	add_page_to_lru_list(zone, page, LRU_INACTIVE);
 }
 
 static inline void
 del_page_from_active_list(struct zone *zone, struct page *page)
 {
-	list_del(&page->lru);
-	__dec_zone_state(zone, NR_ACTIVE);
+	del_page_from_lru_list(zone, page, LRU_ACTIVE);
 }
 
 static inline void
 del_page_from_inactive_list(struct zone *zone, struct page *page)
 {
-	list_del(&page->lru);
-	__dec_zone_state(zone, NR_INACTIVE);
+	del_page_from_lru_list(zone, page, LRU_INACTIVE);
 }
 
 static inline void
 del_page_from_lru(struct zone *zone, struct page *page)
 {
+	enum lru_list l = LRU_INACTIVE;
+
 	list_del(&page->lru);
 	if (PageActive(page)) {
 		__ClearPageActive(page);
-		__dec_zone_state(zone, NR_ACTIVE);
-	} else {
-		__dec_zone_state(zone, NR_INACTIVE);
+		l = LRU_ACTIVE;
 	}
+	__dec_zone_state(zone, NR_INACTIVE + l);
 }
 
 #endif
Index: linux-2.6.24-rc6-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/page_alloc.c	2008-01-02 12:37:22.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/page_alloc.c	2008-01-02 12:37:32.000000000 -0500
@@ -3413,6 +3413,7 @@ static void __meminit free_area_init_cor
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
 		unsigned long size, realsize, memmap_pages;
+		enum lru_list l;
 
 		size = zone_spanned_pages_in_node(nid, j, zones_size);
 		realsize = size - zone_absent_pages_in_node(nid, j,
@@ -3462,10 +3463,10 @@ static void __meminit free_area_init_cor
 		zone->prev_priority = DEF_PRIORITY;
 
 		zone_pcp_init(zone);
-		INIT_LIST_HEAD(&zone->active_list);
-		INIT_LIST_HEAD(&zone->inactive_list);
-		zone->nr_scan_active = 0;
-		zone->nr_scan_inactive = 0;
+		for_each_lru(l) {
+			INIT_LIST_HEAD(&zone->list[l]);
+			zone->nr_scan[l] = 0;
+		}
 		zap_zone_vm_stats(zone);
 		zone->flags = 0;
 		if (!size)
Index: linux-2.6.24-rc6-mm1/mm/swap.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/swap.c	2008-01-02 12:37:18.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/swap.c	2008-01-02 12:37:32.000000000 -0500
@@ -118,7 +118,7 @@ static void pagevec_move_tail(struct pag
 			spin_lock(&zone->lru_lock);
 		}
 		if (PageLRU(page) && !PageActive(page)) {
-			list_move_tail(&page->lru, &zone->inactive_list);
+			list_move_tail(&page->lru, &zone->list[LRU_INACTIVE]);
 			pgmoved++;
 		}
 	}
Index: linux-2.6.24-rc6-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/vmscan.c	2008-01-02 12:37:18.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/vmscan.c	2008-01-02 12:37:32.000000000 -0500
@@ -807,10 +807,10 @@ static unsigned long isolate_pages_globa
 					int active)
 {
 	if (active)
-		return isolate_lru_pages(nr, &z->active_list, dst,
+		return isolate_lru_pages(nr, &z->list[LRU_ACTIVE], dst,
 						scanned, order, mode);
 	else
-		return isolate_lru_pages(nr, &z->inactive_list, dst,
+		return isolate_lru_pages(nr, &z->list[LRU_INACTIVE], dst,
 						scanned, order, mode);
 }
 
@@ -957,10 +957,7 @@ static unsigned long shrink_inactive_lis
 			VM_BUG_ON(PageLRU(page));
 			SetPageLRU(page);
 			list_del(&page->lru);
-			if (PageActive(page))
-				add_page_to_active_list(zone, page);
-			else
-				add_page_to_inactive_list(zone, page);
+			add_page_to_lru_list(zone, page, PageActive(page));
 			if (!pagevec_add(&pvec, page)) {
 				spin_unlock_irq(&zone->lru_lock);
 				__pagevec_release(&pvec);
@@ -1128,11 +1125,14 @@ static void shrink_active_list(unsigned 
 	int pgdeactivate = 0;
 	unsigned long pgscanned;
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
-	LIST_HEAD(l_inactive);	/* Pages to go onto the inactive_list */
-	LIST_HEAD(l_active);	/* Pages to go onto the active_list */
+	struct list_head list[NR_LRU_LISTS];
 	struct page *page;
 	struct pagevec pvec;
 	int reclaim_mapped = 0;
+	enum lru_list l;
+
+	for_each_lru(l)
+		INIT_LIST_HEAD(&list[l]);
 
 	if (sc->may_swap)
 		reclaim_mapped = calc_reclaim_mapped(sc, zone, priority);
@@ -1160,28 +1160,28 @@ static void shrink_active_list(unsigned 
 			if (!reclaim_mapped ||
 			    (total_swap_pages == 0 && PageAnon(page)) ||
 			    page_referenced(page, 0, sc->mem_cgroup)) {
-				list_add(&page->lru, &l_active);
+				list_add(&page->lru, &list[LRU_ACTIVE]);
 				continue;
 			}
 		} else if (TestClearPageReferenced(page)) {
-			list_add(&page->lru, &l_active);
+			list_add(&page->lru, &list[LRU_ACTIVE]);
 			continue;
 		}
-		list_add(&page->lru, &l_inactive);
+		list_add(&page->lru, &list[LRU_INACTIVE]);
 	}
 
 	pagevec_init(&pvec, 1);
 	pgmoved = 0;
 	spin_lock_irq(&zone->lru_lock);
-	while (!list_empty(&l_inactive)) {
-		page = lru_to_page(&l_inactive);
-		prefetchw_prev_lru_page(page, &l_inactive, flags);
+	while (!list_empty(&list[LRU_INACTIVE])) {
+		page = lru_to_page(&list[LRU_INACTIVE]);
+		prefetchw_prev_lru_page(page, &list[LRU_INACTIVE], flags);
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 		VM_BUG_ON(!PageActive(page));
 		ClearPageActive(page);
 
-		list_move(&page->lru, &zone->inactive_list);
+		list_move(&page->lru, &zone->list[LRU_INACTIVE]);
 		mem_cgroup_move_lists(page_get_page_cgroup(page), false);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
@@ -1204,13 +1204,13 @@ static void shrink_active_list(unsigned 
 	}
 
 	pgmoved = 0;
-	while (!list_empty(&l_active)) {
-		page = lru_to_page(&l_active);
-		prefetchw_prev_lru_page(page, &l_active, flags);
+	while (!list_empty(&list[LRU_ACTIVE])) {
+		page = lru_to_page(&list[LRU_ACTIVE]);
+		prefetchw_prev_lru_page(page, &list[LRU_ACTIVE], flags);
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 		VM_BUG_ON(!PageActive(page));
-		list_move(&page->lru, &zone->active_list);
+		list_move(&page->lru, &zone->list[LRU_ACTIVE]);
 		mem_cgroup_move_lists(page_get_page_cgroup(page), true);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
@@ -1234,65 +1234,64 @@ static void shrink_active_list(unsigned 
 	pagevec_release(&pvec);
 }
 
+static unsigned long shrink_list(enum lru_list l, unsigned long nr_to_scan,
+	struct zone *zone, struct scan_control *sc, int priority)
+{
+	if (l == LRU_ACTIVE) {
+		shrink_active_list(nr_to_scan, zone, sc, priority);
+		return 0;
+	}
+	return shrink_inactive_list(nr_to_scan, zone, sc);
+}
+
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
 static unsigned long shrink_zone(int priority, struct zone *zone,
 				struct scan_control *sc)
 {
-	unsigned long nr_active;
-	unsigned long nr_inactive;
+	unsigned long nr[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
 	unsigned long nr_reclaimed = 0;
+	enum lru_list l;
 
 	if (scan_global_lru(sc)) {
 		/*
 		 * Add one to nr_to_scan just to make sure that the kernel
 		 * will slowly sift through the active list.
 		 */
-		zone->nr_scan_active +=
-			(zone_page_state(zone, NR_ACTIVE) >> priority) + 1;
-		nr_active = zone->nr_scan_active;
-		zone->nr_scan_inactive +=
-			(zone_page_state(zone, NR_INACTIVE) >> priority) + 1;
-		nr_inactive = zone->nr_scan_inactive;
-		if (nr_inactive >= sc->swap_cluster_max)
-			zone->nr_scan_inactive = 0;
-		else
-			nr_inactive = 0;
-
-		if (nr_active >= sc->swap_cluster_max)
-			zone->nr_scan_active = 0;
-		else
-			nr_active = 0;
+		for_each_lru(l) {
+			zone->nr_scan[l] += (zone_page_state(zone,
+					NR_INACTIVE + l)  >> priority) + 1;
+			nr[l] = zone->nr_scan[l];
+			if (nr[l] >= sc->swap_cluster_max)
+				zone->nr_scan[l] = 0;
+			else
+				nr[l] = 0;
+		}
 	} else {
 		/*
 		 * This reclaim occurs not because zone memory shortage but
 		 * because memory controller hits its limit.
 		 * Then, don't modify zone reclaim related data.
 		 */
-		nr_active = mem_cgroup_calc_reclaim_active(sc->mem_cgroup,
+		nr[LRU_ACTIVE] = mem_cgroup_calc_reclaim_active(sc->mem_cgroup,
 					zone, priority);
 
-		nr_inactive = mem_cgroup_calc_reclaim_inactive(sc->mem_cgroup,
+		nr[LRU_INACTIVE] = mem_cgroup_calc_reclaim_inactive(sc->mem_cgroup,
 					zone, priority);
 	}
 
-
-	while (nr_active || nr_inactive) {
-		if (nr_active) {
-			nr_to_scan = min(nr_active,
+	while (nr[LRU_ACTIVE] || nr[LRU_INACTIVE]) {
+		for_each_lru(l) {
+			if (nr[l]) {
+				nr_to_scan = min(nr[l],
 					(unsigned long)sc->swap_cluster_max);
-			nr_active -= nr_to_scan;
-			shrink_active_list(nr_to_scan, zone, sc, priority);
-		}
+				nr[l] -= nr_to_scan;
 
-		if (nr_inactive) {
-			nr_to_scan = min(nr_inactive,
-					(unsigned long)sc->swap_cluster_max);
-			nr_inactive -= nr_to_scan;
-			nr_reclaimed += shrink_inactive_list(nr_to_scan, zone,
-								sc);
+				nr_reclaimed += shrink_list(l, nr_to_scan,
+							zone, sc, priority);
+			}
 		}
 	}
 
@@ -1809,6 +1808,7 @@ static unsigned long shrink_all_zones(un
 {
 	struct zone *zone;
 	unsigned long nr_to_scan, ret = 0;
+	enum lru_list l;
 
 	for_each_zone(zone) {
 
@@ -1818,28 +1818,25 @@ static unsigned long shrink_all_zones(un
 		if (zone_is_all_unreclaimable(zone) && prio != DEF_PRIORITY)
 			continue;
 
-		/* For pass = 0 we don't shrink the active list */
-		if (pass > 0) {
-			zone->nr_scan_active +=
-				(zone_page_state(zone, NR_ACTIVE) >> prio) + 1;
-			if (zone->nr_scan_active >= nr_pages || pass > 3) {
-				zone->nr_scan_active = 0;
+		for_each_lru(l) {
+			/* For pass = 0 we don't shrink the active list */
+			if (pass == 0 && l == LRU_ACTIVE)
+				continue;
+
+			zone->nr_scan[l] +=
+				(zone_page_state(zone, NR_INACTIVE + l)
+								>> prio) + 1;
+			if (zone->nr_scan[l] >= nr_pages || pass > 3) {
+				zone->nr_scan[l] = 0;
 				nr_to_scan = min(nr_pages,
-					zone_page_state(zone, NR_ACTIVE));
-				shrink_active_list(nr_to_scan, zone, sc, prio);
+					zone_page_state(zone,
+							NR_INACTIVE + l));
+				ret += shrink_list(l, nr_to_scan, zone,
+								sc, prio);
+				if (ret >= nr_pages)
+					return ret;
 			}
 		}
-
-		zone->nr_scan_inactive +=
-			(zone_page_state(zone, NR_INACTIVE) >> prio) + 1;
-		if (zone->nr_scan_inactive >= nr_pages || pass > 3) {
-			zone->nr_scan_inactive = 0;
-			nr_to_scan = min(nr_pages,
-				zone_page_state(zone, NR_INACTIVE));
-			ret += shrink_inactive_list(nr_to_scan, zone, sc);
-			if (ret >= nr_pages)
-				return ret;
-		}
 	}
 
 	return ret;
Index: linux-2.6.24-rc6-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/vmstat.c	2008-01-02 12:37:11.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/vmstat.c	2008-01-02 12:37:32.000000000 -0500
@@ -758,7 +758,8 @@ static void zoneinfo_show_print(struct s
 		   zone->pages_low,
 		   zone->pages_high,
 		   zone->pages_scanned,
-		   zone->nr_scan_active, zone->nr_scan_inactive,
+		   zone->nr_scan[LRU_ACTIVE],
+		   zone->nr_scan[LRU_INACTIVE],
 		   zone->spanned_pages,
 		   zone->present_pages);
 

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
