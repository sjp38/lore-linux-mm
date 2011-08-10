Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 0923790013B
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 06:47:30 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 5/7] mm: vmscan: Do not writeback filesystem pages in kswapd except in high priority
Date: Wed, 10 Aug 2011 11:47:18 +0100
Message-Id: <1312973240-32576-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1312973240-32576-1-git-send-email-mgorman@suse.de>
References: <1312973240-32576-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>

It is preferable that no dirty pages are dispatched for cleaning from
the page reclaim path. At normal priorities, this patch prevents kswapd
writing pages.

However, page reclaim does have a requirement that pages be freed
in a particular zone. If it is failing to make sufficient progress
(reclaiming < SWAP_CLUSTER_MAX at any priority priority), the priority
is raised to scan more pages. A priority of DEF_PRIORITY - 3 is
considered to be the point where kswapd is getting into trouble
reclaiming pages. If this priority is reached, kswapd will dispatch
pages for writing.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/vmscan.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7863f8e..6d7c696 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -710,7 +710,8 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
 				      struct zone *zone,
-				      struct scan_control *sc)
+				      struct scan_control *sc,
+				      int priority)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
@@ -816,9 +817,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 			/*
 			 * Only kswapd can writeback filesystem pages to
-			 * avoid risk of stack overflow
+			 * avoid risk of stack overflow but do not writeback
+			 * unless under significant pressure.
 			 */
-			if (page_is_file_cache(page) && !current_is_kswapd()) {
+			if (page_is_file_cache(page) &&
+					(!current_is_kswapd() || priority >= DEF_PRIORITY - 2)) {
 				inc_zone_page_state(page, NR_VMSCAN_WRITE_SKIP);
 				goto keep_locked;
 			}
@@ -1454,12 +1457,12 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
 	spin_unlock_irq(&zone->lru_lock);
 
-	nr_reclaimed = shrink_page_list(&page_list, zone, sc);
+	nr_reclaimed = shrink_page_list(&page_list, zone, sc, priority);
 
 	/* Check if we should syncronously wait for writeback */
 	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
 		set_reclaim_mode(priority, sc, true);
-		nr_reclaimed += shrink_page_list(&page_list, zone, sc);
+		nr_reclaimed += shrink_page_list(&page_list, zone, sc, priority);
 	}
 
 	local_irq_disable();
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
