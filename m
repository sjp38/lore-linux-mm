Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2770A6B01F4
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:21:44 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 03/10] vmscan: simplify shrink_inactive_list()
Date: Thu, 15 Apr 2010 18:21:36 +0100
Message-Id: <1271352103-2280-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1271352103-2280-1-git-send-email-mel@csn.ul.ie>
References: <1271352103-2280-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Now, max_scan of shrink_inactive_list() is always passed less than
SWAP_CLUSTER_MAX. then, we can remove scanning pages loop in it.
This patch also help stack diet.

detail
 - remove "while (nr_scanned < max_scan)" loop
 - remove nr_freed (now, we use nr_reclaimed directly)
 - remove nr_scan (now, we use nr_scanned directly)
 - rename max_scan to nr_to_scan
 - pass nr_to_scan into isolate_pages() directly instead
   using SWAP_CLUSTER_MAX

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |  190 ++++++++++++++++++++++++++++-------------------------------
 1 files changed, 89 insertions(+), 101 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5c276f0..76c2b03 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1123,16 +1123,22 @@ static int too_many_isolated(struct zone *zone, int file,
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
  */
-static unsigned long shrink_inactive_list(unsigned long max_scan,
+static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
 			struct zone *zone, struct scan_control *sc,
 			int file)
 {
 	LIST_HEAD(page_list);
 	struct pagevec pvec;
-	unsigned long nr_scanned = 0;
+	unsigned long nr_scanned;
 	unsigned long nr_reclaimed = 0;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 	int lumpy_reclaim = 0;
+	struct page *page;
+	unsigned long nr_taken;
+	unsigned long nr_active;
+	unsigned int count[NR_LRU_LISTS] = { 0, };
+	unsigned long nr_anon;
+	unsigned long nr_file;
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1158,119 +1164,101 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
-	do {
-		struct page *page;
-		unsigned long nr_taken;
-		unsigned long nr_scan;
-		unsigned long nr_freed;
-		unsigned long nr_active;
-		unsigned int count[NR_LRU_LISTS] = { 0, };
-		int mode = lumpy_reclaim ? ISOLATE_BOTH : ISOLATE_INACTIVE;
-		unsigned long nr_anon;
-		unsigned long nr_file;
-
-		nr_taken = sc->isolate_pages(SWAP_CLUSTER_MAX,
-			     &page_list, &nr_scan, sc->order, mode,
-				zone, sc->mem_cgroup, 0, file);
+	nr_taken = sc->isolate_pages(nr_to_scan,
+				     &page_list, &nr_scanned, sc->order,
+				     lumpy_reclaim ? ISOLATE_BOTH : ISOLATE_INACTIVE,
+				     zone, sc->mem_cgroup, 0, file);
 
-		if (scanning_global_lru(sc)) {
-			zone->pages_scanned += nr_scan;
-			if (current_is_kswapd())
-				__count_zone_vm_events(PGSCAN_KSWAPD, zone,
-						       nr_scan);
-			else
-				__count_zone_vm_events(PGSCAN_DIRECT, zone,
-						       nr_scan);
-		}
+	if (scanning_global_lru(sc)) {
+		zone->pages_scanned += nr_scanned;
+		if (current_is_kswapd())
+			__count_zone_vm_events(PGSCAN_KSWAPD, zone, nr_scanned);
+		else
+			__count_zone_vm_events(PGSCAN_DIRECT, zone, nr_scanned);
+	}
 
-		if (nr_taken == 0)
-			goto done;
+	if (nr_taken == 0)
+		goto done;
 
-		nr_active = clear_active_flags(&page_list, count);
-		__count_vm_events(PGDEACTIVATE, nr_active);
+	nr_active = clear_active_flags(&page_list, count);
+	__count_vm_events(PGDEACTIVATE, nr_active);
 
-		__mod_zone_page_state(zone, NR_ACTIVE_FILE,
-						-count[LRU_ACTIVE_FILE]);
-		__mod_zone_page_state(zone, NR_INACTIVE_FILE,
-						-count[LRU_INACTIVE_FILE]);
-		__mod_zone_page_state(zone, NR_ACTIVE_ANON,
-						-count[LRU_ACTIVE_ANON]);
-		__mod_zone_page_state(zone, NR_INACTIVE_ANON,
-						-count[LRU_INACTIVE_ANON]);
+	__mod_zone_page_state(zone, NR_ACTIVE_FILE,
+			      -count[LRU_ACTIVE_FILE]);
+	__mod_zone_page_state(zone, NR_INACTIVE_FILE,
+			      -count[LRU_INACTIVE_FILE]);
+	__mod_zone_page_state(zone, NR_ACTIVE_ANON,
+			      -count[LRU_ACTIVE_ANON]);
+	__mod_zone_page_state(zone, NR_INACTIVE_ANON,
+			      -count[LRU_INACTIVE_ANON]);
 
-		nr_anon = count[LRU_ACTIVE_ANON] + count[LRU_INACTIVE_ANON];
-		nr_file = count[LRU_ACTIVE_FILE] + count[LRU_INACTIVE_FILE];
-		__mod_zone_page_state(zone, NR_ISOLATED_ANON, nr_anon);
-		__mod_zone_page_state(zone, NR_ISOLATED_FILE, nr_file);
+	nr_anon = count[LRU_ACTIVE_ANON] + count[LRU_INACTIVE_ANON];
+	nr_file = count[LRU_ACTIVE_FILE] + count[LRU_INACTIVE_FILE];
+	__mod_zone_page_state(zone, NR_ISOLATED_ANON, nr_anon);
+	__mod_zone_page_state(zone, NR_ISOLATED_FILE, nr_file);
 
-		reclaim_stat->recent_scanned[0] += nr_anon;
-		reclaim_stat->recent_scanned[1] += nr_file;
+	reclaim_stat->recent_scanned[0] += nr_anon;
+	reclaim_stat->recent_scanned[1] += nr_file;
 
-		spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(&zone->lru_lock);
 
-		nr_scanned += nr_scan;
-		nr_freed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
+	nr_reclaimed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
+
+	/*
+	 * If we are direct reclaiming for contiguous pages and we do
+	 * not reclaim everything in the list, try again and wait
+	 * for IO to complete. This will stall high-order allocations
+	 * but that should be acceptable to the caller
+	 */
+	if (nr_reclaimed < nr_taken && !current_is_kswapd() && lumpy_reclaim) {
+		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		/*
-		 * If we are direct reclaiming for contiguous pages and we do
-		 * not reclaim everything in the list, try again and wait
-		 * for IO to complete. This will stall high-order allocations
-		 * but that should be acceptable to the caller
+		 * The attempt at page out may have made some
+		 * of the pages active, mark them inactive again.
 		 */
-		if (nr_freed < nr_taken && !current_is_kswapd() &&
-		    lumpy_reclaim) {
-			congestion_wait(BLK_RW_ASYNC, HZ/10);
-
-			/*
-			 * The attempt at page out may have made some
-			 * of the pages active, mark them inactive again.
-			 */
-			nr_active = clear_active_flags(&page_list, count);
-			count_vm_events(PGDEACTIVATE, nr_active);
-
-			nr_freed += shrink_page_list(&page_list, sc,
-							PAGEOUT_IO_SYNC);
-		}
+		nr_active = clear_active_flags(&page_list, count);
+		count_vm_events(PGDEACTIVATE, nr_active);
 
-		nr_reclaimed += nr_freed;
+		nr_reclaimed += shrink_page_list(&page_list, sc,
+						 PAGEOUT_IO_SYNC);
+	}
 
-		local_irq_disable();
-		if (current_is_kswapd())
-			__count_vm_events(KSWAPD_STEAL, nr_freed);
-		__count_zone_vm_events(PGSTEAL, zone, nr_freed);
+	local_irq_disable();
+	if (current_is_kswapd())
+		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
+	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
 
-		spin_lock(&zone->lru_lock);
-		/*
-		 * Put back any unfreeable pages.
-		 */
-		while (!list_empty(&page_list)) {
-			int lru;
-			page = lru_to_page(&page_list);
-			VM_BUG_ON(PageLRU(page));
-			list_del(&page->lru);
-			if (unlikely(!page_evictable(page, NULL))) {
-				spin_unlock_irq(&zone->lru_lock);
-				putback_lru_page(page);
-				spin_lock_irq(&zone->lru_lock);
-				continue;
-			}
-			SetPageLRU(page);
-			lru = page_lru(page);
-			add_page_to_lru_list(zone, page, lru);
-			if (is_active_lru(lru)) {
-				int file = is_file_lru(lru);
-				reclaim_stat->recent_rotated[file]++;
-			}
-			if (!pagevec_add(&pvec, page)) {
-				spin_unlock_irq(&zone->lru_lock);
-				__pagevec_release(&pvec);
-				spin_lock_irq(&zone->lru_lock);
-			}
+	spin_lock(&zone->lru_lock);
+	/*
+	 * Put back any unfreeable pages.
+	 */
+	while (!list_empty(&page_list)) {
+		int lru;
+		page = lru_to_page(&page_list);
+		VM_BUG_ON(PageLRU(page));
+		list_del(&page->lru);
+		if (unlikely(!page_evictable(page, NULL))) {
+			spin_unlock_irq(&zone->lru_lock);
+			putback_lru_page(page);
+			spin_lock_irq(&zone->lru_lock);
+			continue;
 		}
-		__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
-		__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
-
-  	} while (nr_scanned < max_scan);
+		SetPageLRU(page);
+		lru = page_lru(page);
+		add_page_to_lru_list(zone, page, lru);
+		if (is_active_lru(lru)) {
+			int file = is_file_lru(lru);
+			reclaim_stat->recent_rotated[file]++;
+		}
+		if (!pagevec_add(&pvec, page)) {
+			spin_unlock_irq(&zone->lru_lock);
+			__pagevec_release(&pvec);
+			spin_lock_irq(&zone->lru_lock);
+		}
+	}
+	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
+	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
 
 done:
 	spin_unlock_irq(&zone->lru_lock);
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
