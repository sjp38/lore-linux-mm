Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5FCE16B00EC
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 12:29:25 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 5/8] mm: vmscan: Do not writeback filesystem pages in kswapd except in high priority
Date: Thu, 21 Jul 2011 17:28:47 +0100
Message-Id: <1311265730-5324-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1311265730-5324-1-git-send-email-mgorman@suse.de>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
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
considered to tbe the point where kswapd is getting into trouble
reclaiming pages. If this priority is reached, kswapd will dispatch
pages for writing.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index ee00c94..cf7b501 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -719,7 +719,8 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
 				      struct zone *zone,
-				      struct scan_control *sc)
+				      struct scan_control *sc,
+				      int priority)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
@@ -827,9 +828,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
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
@@ -1465,12 +1468,12 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
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
