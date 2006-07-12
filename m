From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:44:27 +0200
Message-Id: <20060712144427.16998.19462.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 38/39] mm: use-once: use the generic shrinker logic
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Makes the use-once policy use the generic shrinker.
Based on ideas from Wu Fengguang.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

 include/linux/mm_use_once_data.h   |    2 
 include/linux/mm_use_once_policy.h |    5 -
 mm/useonce.c                       |  156 +++++++++----------------------------
 3 files changed, 45 insertions(+), 118 deletions(-)

Index: linux-2.6/mm/useonce.c
===================================================================
--- linux-2.6.orig/mm/useonce.c	2006-07-12 16:10:56.000000000 +0200
+++ linux-2.6/mm/useonce.c	2006-07-12 16:11:07.000000000 +0200
@@ -16,7 +16,7 @@ void __init pgrep_init_zone(struct zone 
 	INIT_LIST_HEAD(&zone->policy.active_list);
 	INIT_LIST_HEAD(&zone->policy.inactive_list);
 	zone->policy.nr_scan_active = 0;
-	zone->policy.nr_scan_inactive = 0;
+	zone->policy.nr_scan = 0;
 	zone->policy.nr_active = 0;
 	zone->policy.nr_inactive = 0;
 }
@@ -78,73 +78,6 @@ void pgrep_reinsert(struct list_head *pa
 	}
 }
 /*
- * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
- * of reclaimed pages
- */
-static unsigned long shrink_inactive_list(unsigned long max_scan,
-				struct zone *zone, struct scan_control *sc)
-{
-	LIST_HEAD(page_list);
-	struct pagevec pvec;
-	unsigned long nr_scanned = 0;
-	unsigned long nr_reclaimed = 0;
-	pagevec_init(&pvec, 1);
-
-	pgrep_add_drain();
-	spin_lock_irq(&zone->lru_lock);
-	do {
-		struct page *page;
-		unsigned long nr_taken;
-		unsigned long nr_scan;
-		unsigned long nr_freed;
-
-		nr_taken = isolate_lru_pages(zone, sc->swap_cluster_max,
-					     &zone->policy.inactive_list,
-					     &page_list, &nr_scan);
-		spin_unlock_irq(&zone->lru_lock);
-
-		nr_scanned += nr_scan;
-		nr_freed = shrink_page_list(&page_list, sc);
-		nr_reclaimed += nr_freed;
-		local_irq_disable();
-		if (current_is_kswapd()) {
-			__mod_page_state_zone(zone, pgscan_kswapd, nr_scan);
-			__mod_page_state(kswapd_steal, nr_freed);
-		} else
-			__mod_page_state_zone(zone, pgscan_direct, nr_scan);
-		__mod_page_state_zone(zone, pgsteal, nr_freed);
-
-		if (nr_taken == 0)
-			goto done;
-
-		spin_lock(&zone->lru_lock);
-		/*
-		 * Put back any unfreeable pages.
-		 */
-		while (!list_empty(&page_list)) {
-			page = lru_to_page(&page_list);
-			BUG_ON(PageLRU(page));
-			SetPageLRU(page);
-			list_del(&page->lru);
-			if (PageActive(page))
-				add_page_to_active_list(zone, page);
-			else
-				add_page_to_inactive_list(zone, page);
-			if (!pagevec_add(&pvec, page)) {
-				spin_unlock_irq(&zone->lru_lock);
-				__pagevec_release(&pvec);
-				spin_lock_irq(&zone->lru_lock);
-			}
-		}
-  	} while (nr_scanned < max_scan);
-	spin_unlock(&zone->lru_lock);
-done:
-	local_irq_enable();
-	pagevec_release(&pvec);
-	return nr_reclaimed;
-}
-
-/*
  * This moves pages from the active list to the inactive list.
  *
  * We move them the other way if the page is referenced by one or more
@@ -162,7 +95,7 @@ done:
  * But we had to alter page->flags anyway.
  */
 static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
-				struct scan_control *sc, int reclaim_mapped)
+		int reclaim_mapped)
 {
 	unsigned long pgmoved;
 	int pgdeactivate = 0;
@@ -174,9 +107,6 @@ static void shrink_active_list(unsigned 
 	struct pagevec pvec;
 	int referenced;
 
-	if (!sc->may_swap)
-		reclaim_mapped = 0;
-
 	pgrep_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 	pgmoved = isolate_lru_pages(zone, nr_pages, &zone->policy.active_list,
@@ -257,59 +187,53 @@ static void shrink_active_list(unsigned 
 	pagevec_release(&pvec);
 }
 
-/*
- * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
- */
-unsigned long pgrep_shrink_zone(int priority, struct zone *zone,
-				struct scan_control *sc)
+void __pgrep_get_candidates(struct zone *zone, int priority,
+		unsigned long nr_to_scan, struct list_head *pages,
+		unsigned long *nr_scanned)
 {
-	unsigned long nr_active;
-	unsigned long nr_inactive;
-	unsigned long nr_to_scan;
-	unsigned long nr_reclaimed = 0;
-	int reclaim_mapped = should_reclaim_mapped(zone);
+	unsigned long nr_taken;
+	unsigned long long nr_scan_active;
 
-	atomic_inc(&zone->reclaim_in_progress);
+	nr_taken = isolate_lru_pages(zone, nr_to_scan,
+			&zone->policy.inactive_list, pages, nr_scanned);
 
-	/*
-	 * Add one to `nr_to_scan' just to make sure that the kernel will
-	 * slowly sift through the active list.
-	 */
-	zone->policy.nr_scan_active += (zone->policy.nr_active >> priority) + 1;
-	nr_active = zone->policy.nr_scan_active;
-	if (nr_active >= sc->swap_cluster_max)
-		zone->policy.nr_scan_active = 0;
-	else
-		nr_active = 0;
+	nr_scan_active = nr_to_scan * zone->policy.nr_active * 1024ULL;
+	do_div(nr_scan_active, zone->policy.nr_inactive + nr_taken + 1UL);
+	zone->policy.nr_scan_active += nr_scan_active;
+}
 
-	zone->policy.nr_scan_inactive += (zone->policy.nr_inactive >> priority) + 1;
-	nr_inactive = zone->policy.nr_scan_inactive;
-	if (nr_inactive >= sc->swap_cluster_max)
-		zone->policy.nr_scan_inactive = 0;
-	else
-		nr_inactive = 0;
+void pgrep_put_candidates(struct zone *zone, struct list_head *pages,
+		unsigned long nr_freed, int may_swap)
+{
+	int reclaim_mapped = should_reclaim_mapped(zone);
+	struct pagevec pvec;
 
-	while (nr_active || nr_inactive) {
-		if (nr_active) {
-			nr_to_scan = min(nr_active,
-					(unsigned long)sc->swap_cluster_max);
-			nr_active -= nr_to_scan;
-			shrink_active_list(nr_to_scan, zone, sc, reclaim_mapped);
-		}
+	pagevec_init(&pvec, 1);
 
-		if (nr_inactive) {
-			nr_to_scan = min(nr_inactive,
-					(unsigned long)sc->swap_cluster_max);
-			nr_inactive -= nr_to_scan;
-			nr_reclaimed += shrink_inactive_list(nr_to_scan, zone,
-								sc);
+	spin_lock_irq(&zone->lru_lock);
+	while (!list_empty(pages)) {
+		struct page *page = lru_to_page(pages);
+		BUG_ON(PageLRU(page));
+		SetPageLRU(page);
+		list_del(&page->lru);
+		if (PageActive(page))
+			add_page_to_active_list(zone, page);
+		else
+			add_page_to_inactive_list(zone, page);
+		if (!pagevec_add(&pvec, page)) {
+			spin_unlock_irq(&zone->lru_lock);
+			__pagevec_release(&pvec);
+			spin_lock_irq(&zone->lru_lock);
 		}
 	}
+	spin_unlock_irq(&zone->lru_lock);
 
-	throttle_vm_writeout();
+	pagevec_release(&pvec);
 
-	atomic_dec(&zone->reclaim_in_progress);
-	return nr_reclaimed;
+	while (zone->policy.nr_scan_active >= SWAP_CLUSTER_MAX * 1024UL) {
+		zone->policy.nr_scan_active -= SWAP_CLUSTER_MAX * 1024UL;
+		shrink_active_list(SWAP_CLUSTER_MAX, zone, reclaim_mapped);
+	}
 }
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
@@ -359,7 +283,7 @@ void pgrep_zoneinfo(struct zone *zone, s
 		   zone->policy.nr_active,
 		   zone->policy.nr_inactive,
 		   zone->pages_scanned,
-		   zone->policy.nr_scan_active, zone->policy.nr_scan_inactive,
+		   zone->policy.nr_scan_active / 1024, zone->policy.nr_scan,
 		   zone->spanned_pages,
 		   zone->present_pages);
 }
Index: linux-2.6/include/linux/mm_use_once_policy.h
===================================================================
--- linux-2.6.orig/include/linux/mm_use_once_policy.h	2006-07-12 16:10:56.000000000 +0200
+++ linux-2.6/include/linux/mm_use_once_policy.h	2006-07-12 16:10:56.000000000 +0200
@@ -147,7 +147,10 @@ static inline unsigned long __pgrep_nr_p
 	return zone->policy.nr_active + zone->policy.nr_inactive;
 }
 
-#define MM_POLICY_HAS_SHRINKER
+static inline unsigned long __pgrep_nr_scan(struct zone *zone)
+{
+	return zone->policy.nr_inactive;
+}
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_USEONCE_POLICY_H */
Index: linux-2.6/include/linux/mm_use_once_data.h
===================================================================
--- linux-2.6.orig/include/linux/mm_use_once_data.h	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/include/linux/mm_use_once_data.h	2006-07-12 16:10:56.000000000 +0200
@@ -7,7 +7,7 @@ struct pgrep_data {
 	struct list_head	active_list;
 	struct list_head	inactive_list;
 	unsigned long		nr_scan_active;
-	unsigned long		nr_scan_inactive;
+	unsigned long		nr_scan;
 	unsigned long		nr_active;
 	unsigned long		nr_inactive;
 };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
