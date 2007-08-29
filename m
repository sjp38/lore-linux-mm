Date: Wed, 29 Aug 2007 10:39:04 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: RFC:  Noreclaim with "Keep Mlocked Pages off the LRU"
In-Reply-To: <1188398451.5121.9.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708291035080.21184@schroedinger.engr.sgi.com>
References: <20070823041137.GH18788@wotan.suse.de>  <1187988218.5869.64.camel@localhost>
 <20070827013525.GA23894@wotan.suse.de>  <1188225247.5952.41.camel@localhost>
 <20070828000648.GB14109@wotan.suse.de>  <1188312766.5079.77.camel@localhost>
  <Pine.LNX.4.64.0708281448440.17464@schroedinger.engr.sgi.com>
 <1188398451.5121.9.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 29 Aug 2007, Lee Schermerhorn wrote:

> > I think that is the right approach. Do not forget that ramfs and other 
> > ram based filesystems create unmapped unreclaimable pages.
> 
> They don't go on the LRU lists now, do they?  The primary function of
> the noreclaim infrastructure is to hide non-reclaimable pages that would
> otherwise go on the [in]active lists from vmscan.  So, if pages used by
> the ram base file systems don't go onto the LRU, we probably don't need
> to put them on the noreclaim list which is conceptually another LRU
> list.

They do go into the LRU. When attempts are made to write them out they are 
put back onto the active lists via a strange return code 
AOP_WRITEPAGE_ACTIVATE. So they circle round and round and round...

> > Right. I posted a patch a week ago that generalized LRU handling and would 
> > allow the adding of additional lists as needed by such an approach.
> 
> Which one was that? 

This one

[RECLAIM] Use an indexed array for active/inactive variables

Currently we are defining explicit variables for the inactive and active
list. An indexed array can be more generic and avoid repeating similar
code in several places in the reclaim code.

We are saving a few bytes in terms of code size:

Before:

   text    data     bss     dec     hex filename
4097753  573120 4092484 8763357  85b7dd vmlinux

After:

   text    data     bss     dec     hex filename
4097729  573120 4092484 8763333  85b7c5 vmlinux

Having an easy way to add new lru lists may ease future work on the reclaim
code.

---
 include/linux/mm_inline.h |   34 +++++++----
 include/linux/mmzone.h    |   13 +++-
 mm/page_alloc.c           |    9 +--
 mm/swap.c                 |    2 
 mm/vmscan.c               |  132 ++++++++++++++++++++++------------------------
 mm/vmstat.c               |    3 -
 6 files changed, 104 insertions(+), 89 deletions(-)

Index: linux-2.6/include/linux/mmzone.h
===================================================================
--- linux-2.6.orig/include/linux/mmzone.h	2007-08-20 20:43:35.000000000 -0700
+++ linux-2.6/include/linux/mmzone.h	2007-08-20 21:39:48.000000000 -0700
@@ -82,6 +82,13 @@ enum zone_stat_item {
 #endif
 	NR_VM_ZONE_STAT_ITEMS };
 
+enum lru_list {
+	LRU_INACTIVE,
+	LRU_ACTIVE,
+	NR_LRU_LISTS };
+
+#define for_each_lru(l) for (l = 0; l < NR_LRU_LISTS; l++)
+
 struct per_cpu_pages {
 	int count;		/* number of pages in the list */
 	int high;		/* high watermark, emptying needed */
@@ -227,10 +234,8 @@ struct zone {
 
 	/* Fields commonly accessed by the page reclaim scanner */
 	spinlock_t		lru_lock;	
-	struct list_head	active_list;
-	struct list_head	inactive_list;
-	unsigned long		nr_scan_active;
-	unsigned long		nr_scan_inactive;
+	struct list_head	list[NR_LRU_LISTS];
+	unsigned long		nr_scan[NR_LRU_LISTS];
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	int			all_unreclaimable; /* All pages pinned */
 
Index: linux-2.6/include/linux/mm_inline.h
===================================================================
--- linux-2.6.orig/include/linux/mm_inline.h	2007-08-20 20:43:35.000000000 -0700
+++ linux-2.6/include/linux/mm_inline.h	2007-08-20 21:39:48.000000000 -0700
@@ -1,40 +1,50 @@
 static inline void
-add_page_to_active_list(struct zone *zone, struct page *page)
+add_page_to_list(struct zone *zone, struct page *page, enum lru_list l)
 {
-	list_add(&page->lru, &zone->active_list);
-	__inc_zone_state(zone, NR_ACTIVE);
+	list_add(&page->lru, &zone->list[l]);
+	__inc_zone_state(zone, NR_INACTIVE + l);
+}
+
+static inline void
+add_page_to_active_list(struct zone *zone, struct page *page) {
+	add_page_to_list(zone, page, LRU_ACTIVE);
 }
 
 static inline void
 add_page_to_inactive_list(struct zone *zone, struct page *page)
 {
-	list_add(&page->lru, &zone->inactive_list);
-	__inc_zone_state(zone, NR_INACTIVE);
+	add_page_to_list(zone, page, LRU_INACTIVE);
 }
 
 static inline void
-del_page_from_active_list(struct zone *zone, struct page *page)
+del_page_from_list(struct zone *zone, struct page *page, enum lru_list l)
 {
 	list_del(&page->lru);
-	__dec_zone_state(zone, NR_ACTIVE);
+	__dec_zone_state(zone, NR_INACTIVE + l);
+}
+
+static inline void
+del_page_from_active_list(struct zone *zone, struct page *page)
+{
+	del_page_from_list(zone, page, LRU_ACTIVE);
 }
 
 static inline void
 del_page_from_inactive_list(struct zone *zone, struct page *page)
 {
-	list_del(&page->lru);
-	__dec_zone_state(zone, NR_INACTIVE);
+	del_page_from_list(zone, page, LRU_INACTIVE);
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
 
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2007-08-20 20:43:34.000000000 -0700
+++ linux-2.6/mm/page_alloc.c	2007-08-20 21:39:48.000000000 -0700
@@ -2908,6 +2908,7 @@ static void __meminit free_area_init_cor
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
 		unsigned long size, realsize, memmap_pages;
+		enum lru_list l;
 
 		size = zone_spanned_pages_in_node(nid, j, zones_size);
 		realsize = size - zone_absent_pages_in_node(nid, j,
@@ -2957,10 +2958,10 @@ static void __meminit free_area_init_cor
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
 		atomic_set(&zone->reclaim_in_progress, 0);
 		if (!size)
Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c	2007-08-20 20:43:34.000000000 -0700
+++ linux-2.6/mm/swap.c	2007-08-20 21:39:48.000000000 -0700
@@ -125,7 +125,7 @@ int rotate_reclaimable_page(struct page 
 	zone = page_zone(page);
 	spin_lock_irqsave(&zone->lru_lock, flags);
 	if (PageLRU(page) && !PageActive(page)) {
-		list_move_tail(&page->lru, &zone->inactive_list);
+		list_move_tail(&page->lru, &zone->list[LRU_INACTIVE]);
 		__count_vm_event(PGROTATED);
 	}
 	if (!test_clear_page_writeback(page))
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2007-08-20 20:43:35.000000000 -0700
+++ linux-2.6/mm/vmscan.c	2007-08-20 21:40:12.000000000 -0700
@@ -772,7 +772,7 @@ static unsigned long shrink_inactive_lis
 		unsigned long nr_active;
 
 		nr_taken = isolate_lru_pages(sc->swap_cluster_max,
-			     &zone->inactive_list,
+			     &zone->list[LRU_INACTIVE],
 			     &page_list, &nr_scan, sc->order,
 			     (sc->order > PAGE_ALLOC_COSTLY_ORDER)?
 					     ISOLATE_BOTH : ISOLATE_INACTIVE);
@@ -807,10 +807,7 @@ static unsigned long shrink_inactive_lis
 			VM_BUG_ON(PageLRU(page));
 			SetPageLRU(page);
 			list_del(&page->lru);
-			if (PageActive(page))
-				add_page_to_active_list(zone, page);
-			else
-				add_page_to_inactive_list(zone, page);
+			add_page_to_list(zone, page, PageActive(page));
 			if (!pagevec_add(&pvec, page)) {
 				spin_unlock_irq(&zone->lru_lock);
 				__pagevec_release(&pvec);
@@ -869,11 +866,14 @@ static void shrink_active_list(unsigned 
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
 
 	if (sc->may_swap) {
 		long mapped_ratio;
@@ -924,7 +924,7 @@ force_reclaim_mapped:
 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
-	pgmoved = isolate_lru_pages(nr_pages, &zone->active_list,
+	pgmoved = isolate_lru_pages(nr_pages, &zone->list[LRU_ACTIVE],
 			    &l_hold, &pgscanned, sc->order, ISOLATE_ACTIVE);
 	zone->pages_scanned += pgscanned;
 	__mod_zone_page_state(zone, NR_ACTIVE, -pgmoved);
@@ -938,25 +938,25 @@ force_reclaim_mapped:
 			if (!reclaim_mapped ||
 			    (total_swap_pages == 0 && PageAnon(page)) ||
 			    page_referenced(page, 0)) {
-				list_add(&page->lru, &l_active);
+				list_add(&page->lru, &list[LRU_ACTIVE]);
 				continue;
 			}
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
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
 			__mod_zone_page_state(zone, NR_INACTIVE, pgmoved);
@@ -978,13 +978,13 @@ force_reclaim_mapped:
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
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
 			__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
@@ -1003,16 +1003,26 @@ force_reclaim_mapped:
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
 
 	atomic_inc(&zone->reclaim_in_progress);
 
@@ -1020,36 +1030,26 @@ static unsigned long shrink_zone(int pri
 	 * Add one to `nr_to_scan' just to make sure that the kernel will
 	 * slowly sift through the active list.
 	 */
-	zone->nr_scan_active +=
-		(zone_page_state(zone, NR_ACTIVE) >> priority) + 1;
-	nr_active = zone->nr_scan_active;
-	if (nr_active >= sc->swap_cluster_max)
-		zone->nr_scan_active = 0;
-	else
-		nr_active = 0;
-
-	zone->nr_scan_inactive +=
-		(zone_page_state(zone, NR_INACTIVE) >> priority) + 1;
-	nr_inactive = zone->nr_scan_inactive;
-	if (nr_inactive >= sc->swap_cluster_max)
-		zone->nr_scan_inactive = 0;
-	else
-		nr_inactive = 0;
-
-	while (nr_active || nr_inactive) {
-		if (nr_active) {
-			nr_to_scan = min(nr_active,
-					(unsigned long)sc->swap_cluster_max);
-			nr_active -= nr_to_scan;
-			shrink_active_list(nr_to_scan, zone, sc, priority);
-		}
+	for_each_lru(l) {
+		zone->nr_scan[l] += (zone_page_state(zone, NR_INACTIVE + l)
+							>> priority) + 1;
+		nr[l] = zone->nr_scan[l];
+		if (nr[l] >= sc->swap_cluster_max)
+			zone->nr_scan[l] = 0;
+		else
+			nr[l] = 0;
+	}
 
-		if (nr_inactive) {
-			nr_to_scan = min(nr_inactive,
+	while (nr[LRU_ACTIVE] || nr[LRU_INACTIVE]) {
+		for_each_lru(l) {
+			if (nr[l]) {
+				nr_to_scan = min(nr[l],
 					(unsigned long)sc->swap_cluster_max);
-			nr_inactive -= nr_to_scan;
-			nr_reclaimed += shrink_inactive_list(nr_to_scan, zone,
-								sc);
+				nr[l] -= nr_to_scan;
+
+				nr_reclaimed += shrink_list(l, nr_to_scan,
+							zone, sc, priority);
+			}
 		}
 	}
 
@@ -1489,6 +1489,7 @@ static unsigned long shrink_all_zones(un
 {
 	struct zone *zone;
 	unsigned long nr_to_scan, ret = 0;
+	enum lru_list l;
 
 	for_each_zone(zone) {
 
@@ -1498,28 +1499,25 @@ static unsigned long shrink_all_zones(un
 		if (zone->all_unreclaimable && prio != DEF_PRIORITY)
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
Index: linux-2.6/mm/vmstat.c
===================================================================
--- linux-2.6.orig/mm/vmstat.c	2007-08-20 20:43:35.000000000 -0700
+++ linux-2.6/mm/vmstat.c	2007-08-20 21:39:48.000000000 -0700
@@ -563,7 +563,8 @@ static int zoneinfo_show(struct seq_file
 			   zone->pages_low,
 			   zone->pages_high,
 			   zone->pages_scanned,
-			   zone->nr_scan_active, zone->nr_scan_inactive,
+			   zone->nr_scan[LRU_ACTIVE],
+			   zone->nr_scan[LRU_INACTIVE],
 			   zone->spanned_pages,
 			   zone->present_pages);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
