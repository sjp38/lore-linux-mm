Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BCCED6B01DA
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 07:23:40 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 10/12] vmscan: Update isolated page counters outside of main path in shrink_inactive_list()
Date: Mon, 14 Jun 2010 12:17:51 +0100
Message-Id: <1276514273-27693-11-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

When shrink_inactive_list() isolates pages, it updates a number of
counters using temporary variables to gather them. These consume stack
and it's in the main path that calls ->writepage(). This patch moves the
accounting updates outside of the main path to reduce stack usage.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c |   63 +++++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 38 insertions(+), 25 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 165c2f5..019f0af 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1073,7 +1073,8 @@ static unsigned long clear_active_flags(struct list_head *page_list,
 			ClearPageActive(page);
 			nr_active++;
 		}
-		count[lru]++;
+		if (count)
+			count[lru]++;
 	}
 
 	return nr_active;
@@ -1153,12 +1154,13 @@ static int too_many_isolated(struct zone *zone, int file,
  * TODO: Try merging with migrations version of putback_lru_pages
  */
 static noinline_for_stack void putback_lru_pages(struct zone *zone,
-				struct zone_reclaim_stat *reclaim_stat,
+				struct scan_control *sc,
 				unsigned long nr_anon, unsigned long nr_file,
  				struct list_head *page_list)
 {
 	struct page *page;
 	struct pagevec pvec;
+	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 
 	pagevec_init(&pvec, 1);
 
@@ -1197,6 +1199,37 @@ static noinline_for_stack void putback_lru_pages(struct zone *zone,
 	pagevec_release(&pvec);
 }
 
+static noinline_for_stack void update_isolated_counts(struct zone *zone, 
+					struct scan_control *sc,
+					unsigned long *nr_anon,
+					unsigned long *nr_file,
+					struct list_head *isolated_list)
+{
+	unsigned long nr_active;
+	unsigned int count[NR_LRU_LISTS] = { 0, };
+	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
+
+	nr_active = clear_active_flags(isolated_list, count);
+	__count_vm_events(PGDEACTIVATE, nr_active);
+
+	__mod_zone_page_state(zone, NR_ACTIVE_FILE,
+			      -count[LRU_ACTIVE_FILE]);
+	__mod_zone_page_state(zone, NR_INACTIVE_FILE,
+			      -count[LRU_INACTIVE_FILE]);
+	__mod_zone_page_state(zone, NR_ACTIVE_ANON,
+			      -count[LRU_ACTIVE_ANON]);
+	__mod_zone_page_state(zone, NR_INACTIVE_ANON,
+			      -count[LRU_INACTIVE_ANON]);
+
+	*nr_anon = count[LRU_ACTIVE_ANON] + count[LRU_INACTIVE_ANON];
+	*nr_file = count[LRU_ACTIVE_FILE] + count[LRU_INACTIVE_FILE];
+	__mod_zone_page_state(zone, NR_ISOLATED_ANON, *nr_anon);
+	__mod_zone_page_state(zone, NR_ISOLATED_FILE, *nr_file);
+
+	reclaim_stat->recent_scanned[0] += *nr_anon;
+	reclaim_stat->recent_scanned[1] += *nr_file;
+}
+
 /*
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
@@ -1208,10 +1241,8 @@ static noinline_for_stack unsigned long shrink_inactive_list(unsigned long nr_to
 	LIST_HEAD(page_list);
 	unsigned long nr_scanned;
 	unsigned long nr_reclaimed = 0;
-	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 	unsigned long nr_taken;
 	unsigned long nr_active;
-	unsigned int count[NR_LRU_LISTS] = { 0, };
 	unsigned long nr_anon;
 	unsigned long nr_file;
 
@@ -1256,25 +1287,7 @@ static noinline_for_stack unsigned long shrink_inactive_list(unsigned long nr_to
 		return 0;
 	}
 
-	nr_active = clear_active_flags(&page_list, count);
-	__count_vm_events(PGDEACTIVATE, nr_active);
-
-	__mod_zone_page_state(zone, NR_ACTIVE_FILE,
-					-count[LRU_ACTIVE_FILE]);
-	__mod_zone_page_state(zone, NR_INACTIVE_FILE,
-					-count[LRU_INACTIVE_FILE]);
-	__mod_zone_page_state(zone, NR_ACTIVE_ANON,
-					-count[LRU_ACTIVE_ANON]);
-	__mod_zone_page_state(zone, NR_INACTIVE_ANON,
-					-count[LRU_INACTIVE_ANON]);
-
-	nr_anon = count[LRU_ACTIVE_ANON] + count[LRU_INACTIVE_ANON];
-	nr_file = count[LRU_ACTIVE_FILE] + count[LRU_INACTIVE_FILE];
-	__mod_zone_page_state(zone, NR_ISOLATED_ANON, nr_anon);
-	__mod_zone_page_state(zone, NR_ISOLATED_FILE, nr_file);
-
-	reclaim_stat->recent_scanned[0] += nr_anon;
-	reclaim_stat->recent_scanned[1] += nr_file;
+	update_isolated_counts(zone, sc, &nr_anon, &nr_file, &page_list);
 
 	spin_unlock_irq(&zone->lru_lock);
 
@@ -1293,7 +1306,7 @@ static noinline_for_stack unsigned long shrink_inactive_list(unsigned long nr_to
 		 * The attempt at page out may have made some
 		 * of the pages active, mark them inactive again.
 		 */
-		nr_active = clear_active_flags(&page_list, count);
+		nr_active = clear_active_flags(&page_list, NULL);
 		count_vm_events(PGDEACTIVATE, nr_active);
 
 		nr_reclaimed += shrink_page_list(&page_list, sc, PAGEOUT_IO_SYNC);
@@ -1304,7 +1317,7 @@ static noinline_for_stack unsigned long shrink_inactive_list(unsigned long nr_to
 		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
 	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
 
-	putback_lru_pages(zone, reclaim_stat, nr_anon, nr_file, &page_list);
+	putback_lru_pages(zone, sc, nr_anon, nr_file, &page_list);
 	return nr_reclaimed;
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
