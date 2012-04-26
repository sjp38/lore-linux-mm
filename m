Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id A88926B007E
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 09:17:47 -0400 (EDT)
Received: by lagz14 with SMTP id z14so1285604lag.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 06:17:45 -0700 (PDT)
Subject: [PATCH v2 05/12] mm/vmscan: remove update_isolated_counts()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 26 Apr 2012 17:17:43 +0400
Message-ID: <20120426131743.9008.52231.stgit@zurg>
In-Reply-To: <20120426075408.18961.80580.stgit@zurg>
References: <20120426075408.18961.80580.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>

update_isolated_counts() no longer required, because lumpy-reclaim was removed.
Insanity is over, now here only one kind of inactive pages.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/vmscan.c |   60 ++++++-----------------------------------------------------
 1 file changed, 6 insertions(+), 54 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 44d5821..6f617c4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1205,52 +1205,6 @@ putback_inactive_pages(struct mem_cgroup_zone *mz,
 	list_splice(&pages_to_free, page_list);
 }
 
-static noinline_for_stack void
-update_isolated_counts(struct mem_cgroup_zone *mz,
-		       struct list_head *page_list,
-		       unsigned long *nr_anon,
-		       unsigned long *nr_file)
-{
-	struct zone *zone = mz->zone;
-	unsigned int count[NR_LRU_LISTS] = { 0, };
-	unsigned long nr_active = 0;
-	struct page *page;
-	int lru;
-
-	/*
-	 * Count pages and clear active flags
-	 */
-	list_for_each_entry(page, page_list, lru) {
-		int numpages = hpage_nr_pages(page);
-		lru = page_lru_base_type(page);
-		if (PageActive(page)) {
-			lru += LRU_ACTIVE;
-			ClearPageActive(page);
-			nr_active += numpages;
-		}
-		count[lru] += numpages;
-	}
-
-	preempt_disable();
-	__count_vm_events(PGDEACTIVATE, nr_active);
-
-	__mod_zone_page_state(zone, NR_ACTIVE_FILE,
-			      -count[LRU_ACTIVE_FILE]);
-	__mod_zone_page_state(zone, NR_INACTIVE_FILE,
-			      -count[LRU_INACTIVE_FILE]);
-	__mod_zone_page_state(zone, NR_ACTIVE_ANON,
-			      -count[LRU_ACTIVE_ANON]);
-	__mod_zone_page_state(zone, NR_INACTIVE_ANON,
-			      -count[LRU_INACTIVE_ANON]);
-
-	*nr_anon = count[LRU_ACTIVE_ANON] + count[LRU_INACTIVE_ANON];
-	*nr_file = count[LRU_ACTIVE_FILE] + count[LRU_INACTIVE_FILE];
-
-	__mod_zone_page_state(zone, NR_ISOLATED_ANON, *nr_anon);
-	__mod_zone_page_state(zone, NR_ISOLATED_FILE, *nr_file);
-	preempt_enable();
-}
-
 /*
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
@@ -1263,8 +1217,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 	unsigned long nr_scanned;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_taken;
-	unsigned long nr_anon;
-	unsigned long nr_file;
 	unsigned long nr_dirty = 0;
 	unsigned long nr_writeback = 0;
 	isolate_mode_t isolate_mode = 0;
@@ -1292,6 +1244,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
 				     &nr_scanned, sc, isolate_mode, lru);
+
+	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -nr_taken);
+	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
+
 	if (global_reclaim(sc)) {
 		zone->pages_scanned += nr_scanned;
 		if (current_is_kswapd())
@@ -1306,15 +1262,12 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 	if (nr_taken == 0)
 		return 0;
 
-	update_isolated_counts(mz, &page_list, &nr_anon, &nr_file);
-
 	nr_reclaimed = shrink_page_list(&page_list, zone, sc,
 						&nr_dirty, &nr_writeback);
 
 	spin_lock_irq(&zone->lru_lock);
 
-	reclaim_stat->recent_scanned[0] += nr_anon;
-	reclaim_stat->recent_scanned[1] += nr_file;
+	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	if (current_is_kswapd())
 		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
@@ -1322,8 +1275,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 
 	putback_inactive_pages(mz, &page_list);
 
-	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
-	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
+	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
 
 	spin_unlock_irq(&zone->lru_lock);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
