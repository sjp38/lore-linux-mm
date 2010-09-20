Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 745CB6B0047
	for <linux-mm@kvack.org>; Mon, 20 Sep 2010 09:05:22 -0400 (EDT)
Date: Mon, 20 Sep 2010 14:05:07 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] writeback: Do not sleep on the congestion queue if there
	are no congested BDIs or if significant congestion is not being
	encounted in the current zone fix
Message-ID: <20100920130506.GM1998@csn.ul.ie>
References: <1284553671-31574-1-git-send-email-mel@csn.ul.ie> <1284553671-31574-9-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1284553671-31574-9-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Based on feedback from Minchan Kim, I updated the patch
writeback-do-not-sleep-on-the-congestion-queue-if-there-are-no-congested-bdis-or-if-significant-congestion-is-not-being-encountered-in-the-current-zone.patch
currently in the mm tree in the following manner

1. Deleted the bdi_queue_status enum until such point as we distinguish
   between being unable to write to the IO queue and it being congested
2. Direct reclaimers consider congestion the first zone in the zonelist.
   In the mm version of the patch, it scans for a zone with the most
   pages in writeback. This made more sense for an earlier version of
   wait_iff_congested().

Tests did not show up any significant difference. This patch should be
merged with
writeback-do-not-sleep-on-the-congestion-queue-if-there-are-no-congested-bdis-or-if-significant-congestion-is-not-being-encountered-in-the-current-zone.patch

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |   57 ++++++++++++---------------------------------------------
 1 files changed, 12 insertions(+), 45 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5ef6294..aaf03ac 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -311,30 +311,20 @@ static inline int is_page_cache_freeable(struct page *page)
 	return page_count(page) - page_has_private(page) == 2;
 }
 
-enum bdi_queue_status {
-	QUEUEWRITE_DENIED,
-	QUEUEWRITE_CONGESTED,
-	QUEUEWRITE_ALLOWED,
-};
-
-static enum bdi_queue_status may_write_to_queue(struct backing_dev_info *bdi,
+static int may_write_to_queue(struct backing_dev_info *bdi,
 			      struct scan_control *sc)
 {
-	enum bdi_queue_status ret = QUEUEWRITE_DENIED;
-
 	if (current->flags & PF_SWAPWRITE)
-		return QUEUEWRITE_ALLOWED;
+		return 1;
 	if (!bdi_write_congested(bdi))
-		return QUEUEWRITE_ALLOWED;
-	else
-		ret = QUEUEWRITE_CONGESTED;
+		return 1;
 	if (bdi == current->backing_dev_info)
-		return QUEUEWRITE_ALLOWED;
+		return 1;
 
 	/* lumpy reclaim for hugepage often need a lot of write */
 	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
-		return QUEUEWRITE_ALLOWED;
-	return ret;
+		return 1;
+	return 0;
 }
 
 /*
@@ -362,8 +352,6 @@ static void handle_write_error(struct address_space *mapping,
 typedef enum {
 	/* failed to write page out, page is locked */
 	PAGE_KEEP,
-	/* failed to write page out due to congestion, page is locked */
-	PAGE_KEEP_CONGESTED,
 	/* move page to the active list, page is locked */
 	PAGE_ACTIVATE,
 	/* page has been sent to the disk successfully, page is unlocked */
@@ -413,15 +401,8 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 	}
 	if (mapping->a_ops->writepage == NULL)
 		return PAGE_ACTIVATE;
-	switch (may_write_to_queue(mapping->backing_dev_info, sc)) {
-	case QUEUEWRITE_CONGESTED:
-		return PAGE_KEEP_CONGESTED;
-	case QUEUEWRITE_DENIED:
-		disable_lumpy_reclaim_mode(sc);
+	if (!may_write_to_queue(mapping->backing_dev_info, sc))
 		return PAGE_KEEP;
-	case QUEUEWRITE_ALLOWED:
-		;
-	}
 
 	if (clear_page_dirty_for_io(page)) {
 		int res;
@@ -815,9 +796,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 			/* Page is dirty, try to write it out here */
 			switch (pageout(page, mapping, sc)) {
-			case PAGE_KEEP_CONGESTED:
-				nr_congested++;
 			case PAGE_KEEP:
+				nr_congested++;
 				goto keep_locked;
 			case PAGE_ACTIVATE:
 				goto activate_locked;
@@ -1975,24 +1955,11 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		/* Take a nap, wait for some writeback to complete */
 		if (!sc->hibernation_mode && sc->nr_scanned &&
 		    priority < DEF_PRIORITY - 2) {
-			struct zone *active_zone = NULL;
-			unsigned long max_writeback = 0;
-			for_each_zone_zonelist(zone, z, zonelist,
-					gfp_zone(sc->gfp_mask)) {
-				unsigned long writeback;
-
-				/* Initialise for first zone */
-				if (active_zone == NULL)
-					active_zone = zone;
-
-				writeback = zone_page_state(zone, NR_WRITEBACK);
-				if (writeback > max_writeback) {
-					max_writeback = writeback;
-					active_zone = zone;
-				}
-			}
+			struct zone *preferred_zone;
 
-			wait_iff_congested(active_zone, BLK_RW_ASYNC, HZ/10);
+			first_zones_zonelist(zonelist, gfp_zone(sc->gfp_mask),
+							NULL, &preferred_zone);
+			wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/10);
 		}
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
