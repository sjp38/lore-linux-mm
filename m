Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 630366B02AD
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 09:37:07 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 5/6] vmscan: Do not writeback filesystem pages in direct reclaim
Date: Fri, 30 Jul 2010 14:36:59 +0100
Message-Id: <1280497020-22816-6-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1280497020-22816-1-git-send-email-mel@csn.ul.ie>
References: <1280497020-22816-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
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
 mm/vmscan.c |   69 ++++++++++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 54 insertions(+), 15 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d83812a..2d2b588 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -139,6 +139,9 @@ static DECLARE_RWSEM(shrinker_rwsem);
 #define scanning_global_lru(sc)	(1)
 #endif
 
+/* Direct lumpy reclaim waits up to five seconds for background cleaning */
+#define MAX_SWAP_CLEAN_WAIT 50
+
 static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
 						  struct scan_control *sc)
 {
@@ -645,11 +648,13 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
 					struct scan_control *sc,
-					enum pageout_io sync_writeback)
+					enum pageout_io sync_writeback,
+					unsigned long *nr_still_dirty)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
 	int pgactivate = 0;
+	unsigned long nr_dirty = 0;
 	unsigned long nr_reclaimed = 0;
 
 	cond_resched();
@@ -743,6 +748,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
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
@@ -860,6 +874,8 @@ keep:
 	free_page_list(&free_pages);
 
 	list_splice(&ret_pages, page_list);
+
+	*nr_still_dirty = nr_dirty;
 	count_vm_events(PGACTIVATE, pgactivate);
 	return nr_reclaimed;
 }
@@ -1242,12 +1258,14 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 			struct scan_control *sc, int priority, int file)
 {
 	LIST_HEAD(page_list);
+	LIST_HEAD(putback_list);
 	unsigned long nr_scanned;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_taken;
 	unsigned long nr_active;
 	unsigned long nr_anon;
 	unsigned long nr_file;
+	unsigned long nr_dirty;
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1296,28 +1314,49 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
 	spin_unlock_irq(&zone->lru_lock);
 
-	nr_reclaimed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
+	nr_reclaimed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC,
+								&nr_dirty);
 
 	/*
-	 * If we are direct reclaiming for contiguous pages and we do
+	 * If specific pages are needed such as with direct reclaiming
+	 * for contiguous pages or for memory containers and we do
 	 * not reclaim everything in the list, try again and wait
-	 * for IO to complete. This will stall high-order allocations
-	 * but that should be acceptable to the caller
+	 * for IO to complete. This will stall callers that require
+	 * specific pages but it should be acceptable to the caller
 	 */
-	if (nr_reclaimed < nr_taken && !current_is_kswapd() &&
-			sc->lumpy_reclaim_mode) {
-		congestion_wait(BLK_RW_ASYNC, HZ/10);
+	if (sc->may_writepage && !current_is_kswapd() &&
+			(sc->lumpy_reclaim_mode || sc->mem_cgroup)) {
+		int dirty_retry = MAX_SWAP_CLEAN_WAIT;
 
-		/*
-		 * The attempt at page out may have made some
-		 * of the pages active, mark them inactive again.
-		 */
-		nr_active = clear_active_flags(&page_list, NULL);
-		count_vm_events(PGDEACTIVATE, nr_active);
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
+			congestion_wait(BLK_RW_ASYNC, HZ/10);
 
-		nr_reclaimed += shrink_page_list(&page_list, sc, PAGEOUT_IO_SYNC);
+			/*
+			 * The attempt at page out may have made some
+			 * of the pages active, mark them inactive again.
+			 */
+			nr_active = clear_active_flags(&page_list, NULL);
+			count_vm_events(PGDEACTIVATE, nr_active);
+
+			nr_reclaimed += shrink_page_list(&page_list, sc,
+						PAGEOUT_IO_SYNC, &nr_dirty);
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
