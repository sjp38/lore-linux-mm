Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0A66B0088
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 06:47:42 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 09/10] vmscan: Do not writeback filesystem pages in direct reclaim
Date: Mon,  6 Sep 2010 11:47:32 +0100
Message-Id: <1283770053-18833-10-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

When memory is under enough pressure, a process may enter direct
reclaim to free pages in the same manner kswapd does. If a dirty page is
encountered during the scan, this page is written to backing storage using
mapping->writepage. This can result in very deep call stacks, particularly
if the target storage or filesystem are complex. It has already been observed
on XFS that the stack overflows but the problem is not XFS-specific.

This patch prevents direct reclaim writing back filesystem pages by checking
if current is kswapd or the page is anonymous before writing back.  If the
dirty pages cannot be written back, they are placed back on the LRU lists
for either background writing by the BDI threads or kswapd. If in direct
lumpy reclaim and dirty pages are encountered, the process will stall for
the background flusher before trying to reclaim the pages again.

As the call-chain for writing anonymous pages is not expected to be deep
and they are not cleaned by flusher threads, anonymous pages are still
written back in direct reclaim.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c |   49 ++++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 46 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index ff52b46..408c101 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -145,6 +145,9 @@ static DECLARE_RWSEM(shrinker_rwsem);
 #define scanning_global_lru(sc)	(1)
 #endif
 
+/* Direct lumpy reclaim waits up to five seconds for background cleaning */
+#define MAX_SWAP_CLEAN_WAIT 50
+
 static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
 						  struct scan_control *sc)
 {
@@ -682,11 +685,13 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
  * shrink_page_list() returns the number of reclaimed pages
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
-				      struct scan_control *sc)
+					struct scan_control *sc,
+					unsigned long *nr_still_dirty)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
 	int pgactivate = 0;
+	unsigned long nr_dirty = 0;
 	unsigned long nr_reclaimed = 0;
 
 	cond_resched();
@@ -785,6 +790,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		}
 
 		if (PageDirty(page)) {
+			/*
+			 * Only kswapd can writeback filesystem pages to
+			 * avoid risk of stack overflow
+			 */
+			if (page_is_file_cache(page) && !current_is_kswapd()) {
+				nr_dirty++;
+				goto keep_locked;
+			}
+
 			if (references == PAGEREF_RECLAIM_CLEAN)
 				goto keep_locked;
 			if (!may_enter_fs)
@@ -908,6 +922,8 @@ keep_lumpy:
 	free_page_list(&free_pages);
 
 	list_splice(&ret_pages, page_list);
+
+	*nr_still_dirty = nr_dirty;
 	count_vm_events(PGACTIVATE, pgactivate);
 	return nr_reclaimed;
 }
@@ -1312,6 +1328,10 @@ static inline bool should_reclaim_stall(unsigned long nr_taken,
 	if (sc->lumpy_reclaim_mode == LUMPY_MODE_NONE)
 		return false;
 
+	/* If we cannot writeback, there is no point stalling */
+	if (!sc->may_writepage)
+		return false;
+
 	/* If we have relaimed everything on the isolated list, no stall */
 	if (nr_freed == nr_taken)
 		return false;
@@ -1339,11 +1359,13 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 			struct scan_control *sc, int priority, int file)
 {
 	LIST_HEAD(page_list);
+	LIST_HEAD(putback_list);
 	unsigned long nr_scanned;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_taken;
 	unsigned long nr_anon;
 	unsigned long nr_file;
+	unsigned long nr_dirty;
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1392,14 +1414,35 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
 	spin_unlock_irq(&zone->lru_lock);
 
-	nr_reclaimed = shrink_page_list(&page_list, sc);
+	nr_reclaimed = shrink_page_list(&page_list, sc, &nr_dirty);
 
 	/* Check if we should syncronously wait for writeback */
 	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
+		int dirty_retry = MAX_SWAP_CLEAN_WAIT;
 		set_lumpy_reclaim_mode(priority, sc, true);
-		nr_reclaimed += shrink_page_list(&page_list, sc);
+
+		while (nr_reclaimed < nr_taken && nr_dirty && dirty_retry--) {
+			struct page *page, *tmp;
+
+			/* Take off the clean pages marked for activation */
+			list_for_each_entry_safe(page, tmp, &page_list, lru) {
+				if (PageDirty(page) || PageWriteback(page))
+					continue;
+
+				list_del(&page->lru);
+				list_add(&page->lru, &putback_list);
+			}
+
+			wakeup_flusher_threads(laptop_mode ? 0 : nr_dirty);
+			wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
+
+			nr_reclaimed = shrink_page_list(&page_list, sc,
+							&nr_dirty);
+		}
 	}
 
+	list_splice(&putback_list, &page_list);
+
 	local_irq_disable();
 	if (current_is_kswapd())
 		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
