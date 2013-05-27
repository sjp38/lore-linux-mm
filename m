Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 83EB16B00FB
	for <linux-mm@kvack.org>; Mon, 27 May 2013 09:03:05 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/4] mm: vmscan: Stall page reclaim and writeback pages based on dirty/writepage pages encountered
Date: Mon, 27 May 2013 14:02:56 +0100
Message-Id: <1369659778-6772-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1369659778-6772-1-git-send-email-mgorman@suse.de>
References: <1369659778-6772-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The patch "mm: vmscan: Have kswapd writeback pages based on dirty pages
encountered, not priority" decides whether to writeback pages from reclaim
context based on the number of dirty pages encountered. This situation
is flagged too easily and flushers are not given the chance to catch up
resulting in more pages being written from reclaim context and potentially
impacting IO performance. The check for PageWriteback is also misplaced
as it happens within a PageDirty check which is nonsense as the dirty may
have been cleared for IO. The accounting is updated very late and pages
that are already under writeback, were reactivated, could not unmapped or
could not be released are all missed. Finally, it considers stalling and
writing back filesystem pages due to encountering dirty anonymous pages
at the tail of the LRU which is dumb.

This patch causes kswapd to begin writing filesystem pages from reclaim
context only if page reclaim found that all filesystem pages at the tail of
the LRU were unqueued dirty pages. Before it starts writing filesystem pages,
it will stall to give flushers a chance to catch up. The decision on whether
wait_iff_congested is also now determined by dirty filesystem pages only.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 52 ++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 42 insertions(+), 10 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4a43c28..be8e445 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -669,6 +669,27 @@ static enum page_references page_check_references(struct page *page,
 	return PAGEREF_RECLAIM;
 }
 
+/* Check if a page is dirty or under writeback */
+static void page_check_dirty_writeback(struct page *page,
+				       bool *dirty, bool *writeback)
+{
+	struct address_space *mapping;
+
+	/*
+	 * Anonymous pages are not handled by flushers and must be written
+	 * from reclaim context. Do not stall reclaim based on them
+	 */
+	if (!page_is_file_cache(page)) {
+		*dirty = false;
+		*writeback = false;
+		return;
+	}
+
+	/* By default assume that the page flags are accurate */
+	*dirty = PageDirty(page);
+	*writeback = PageWriteback(page);
+}
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -697,6 +718,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		struct page *page;
 		int may_enter_fs;
 		enum page_references references = PAGEREF_RECLAIM_CLEAN;
+		bool dirty, writeback;
 
 		cond_resched();
 
@@ -725,6 +747,19 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
 
 		/*
+		 * The number of dirty pages determines if a zone is marked
+		 * reclaim_congested which affects wait_iff_congested. kswapd
+		 * will stall and start writing pages if the tail of the LRU
+		 * is all dirty unqueued pages.
+		 */
+		page_check_dirty_writeback(page, &dirty, &writeback);
+		if (dirty || writeback)
+			nr_dirty++;
+
+		if (dirty && !writeback)
+			nr_unqueued_dirty++;
+
+		/*
 		 * If a page at the tail of the LRU is under writeback, there
 		 * are three cases to consider.
 		 *
@@ -841,11 +876,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		}
 
 		if (PageDirty(page)) {
-			nr_dirty++;
-
-			if (!PageWriteback(page))
-				nr_unqueued_dirty++;
-
 			/*
 			 * Only kswapd can writeback filesystem pages to
 			 * avoid risk of stack overflow but only writeback
@@ -1318,7 +1348,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	unsigned long nr_scanned;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_taken;
-	unsigned long nr_dirty = 0;
+	unsigned long nr_unqueued_dirty = 0;
 	unsigned long nr_writeback = 0;
 	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
@@ -1361,7 +1391,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		return 0;
 
 	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
-					&nr_dirty, &nr_writeback, false);
+				&nr_unqueued_dirty, &nr_writeback, false);
 
 	spin_lock_irq(&zone->lru_lock);
 
@@ -1416,11 +1446,13 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	/*
 	 * Similarly, if many dirty pages are encountered that are not
 	 * currently being written then flag that kswapd should start
-	 * writing back pages.
+	 * writing back pages and stall to give a chance for flushers
+	 * to catch up.
 	 */
-	if (global_reclaim(sc) && nr_dirty &&
-			nr_dirty >= (nr_taken >> (DEF_PRIORITY - sc->priority)))
+	if (global_reclaim(sc) && nr_unqueued_dirty == nr_taken) {
+		congestion_wait(BLK_RW_ASYNC, HZ/10);
 		zone_set_flag(zone, ZONE_TAIL_LRU_DIRTY);
+	}
 
 	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
 		zone_idx(zone),
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
