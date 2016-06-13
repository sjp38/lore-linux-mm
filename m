Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 105176B025E
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 03:51:05 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id f6so64801127ith.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 00:51:05 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 186si11352762ith.8.2016.06.13.00.51.03
        for <linux-mm@kvack.org>;
        Mon, 13 Jun 2016 00:51:03 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 1/3] mm: vmscan: refactoring force_reclaim
Date: Mon, 13 Jun 2016 16:50:56 +0900
Message-Id: <1465804259-29345-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1465804259-29345-1-git-send-email-minchan@kernel.org>
References: <1465804259-29345-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>

local variable references has PAGEREF_RECLAIM_CLEAN default value
so that it can prevent dirty page writeout effectively for reclaim
latency(introduced by [1]) if force_reclaim is true.

However, it is irony because user wanted *force reclaim* but
we prohibit dirty page writeout.

Let's make it more clear.
This patch is refactoring so it shouldn't change any behavior.

[1] <02c6de8d757c, mm: cma: discard clean pages during contiguous
allocation instead of migration>

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c | 35 ++++++++++++++++++++---------------
 1 file changed, 20 insertions(+), 15 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 21d417ccff69..05119983c92e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -95,6 +95,9 @@ struct scan_control {
 	/* Can cgroups be reclaimed below their normal consumption range? */
 	unsigned int may_thrash:1;
 
+	/* reclaim pages unconditionally */
+	unsigned int force_reclaim:1;
+
 	unsigned int hibernation_mode:1;
 
 	/* One of the zones is ready for compaction */
@@ -783,6 +786,7 @@ void putback_lru_page(struct page *page)
 }
 
 enum page_references {
+	PAGEREF_NONE,
 	PAGEREF_RECLAIM,
 	PAGEREF_RECLAIM_CLEAN,
 	PAGEREF_KEEP,
@@ -884,8 +888,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				      unsigned long *ret_nr_unqueued_dirty,
 				      unsigned long *ret_nr_congested,
 				      unsigned long *ret_nr_writeback,
-				      unsigned long *ret_nr_immediate,
-				      bool force_reclaim)
+				      unsigned long *ret_nr_immediate)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
@@ -903,7 +906,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		struct address_space *mapping;
 		struct page *page;
 		int may_enter_fs;
-		enum page_references references = PAGEREF_RECLAIM_CLEAN;
+		enum page_references references = PAGEREF_NONE;
 		bool dirty, writeback;
 		bool lazyfree = false;
 		int ret = SWAP_SUCCESS;
@@ -927,13 +930,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (!sc->may_unmap && page_mapped(page))
 			goto keep_locked;
 
-		/* Double the slab pressure for mapped and swapcache pages */
-		if (page_mapped(page) || PageSwapCache(page))
-			sc->nr_scanned++;
-
 		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
 			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
 
+		if (sc->force_reclaim)
+			goto force_reclaim;
+
+		/* Double the slab pressure for mapped and swapcache pages */
+		if (page_mapped(page) || PageSwapCache(page))
+			sc->nr_scanned++;
 		/*
 		 * The number of dirty pages determines if a zone is marked
 		 * reclaim_congested which affects wait_iff_congested. kswapd
@@ -1028,19 +1033,18 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		if (!force_reclaim)
-			references = page_check_references(page, sc);
+		references = page_check_references(page, sc);
 
 		switch (references) {
 		case PAGEREF_ACTIVATE:
 			goto activate_locked;
 		case PAGEREF_KEEP:
 			goto keep_locked;
-		case PAGEREF_RECLAIM:
-		case PAGEREF_RECLAIM_CLEAN:
-			; /* try to reclaim the page below */
+		default:
+			break; /* try to reclaim the page below */
 		}
 
+force_reclaim:
 		/*
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
@@ -1253,6 +1257,8 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 		.gfp_mask = GFP_KERNEL,
 		.priority = DEF_PRIORITY,
 		.may_unmap = 1,
+		.may_writepage = 0,
+		.force_reclaim = 1,
 	};
 	unsigned long ret, dummy1, dummy2, dummy3, dummy4, dummy5;
 	struct page *page, *next;
@@ -1268,7 +1274,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 
 	ret = shrink_page_list(&clean_pages, zone, &sc,
 			TTU_UNMAP|TTU_IGNORE_ACCESS,
-			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5, true);
+			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5);
 	list_splice(&clean_pages, page_list);
 	mod_zone_page_state(zone, NR_ISOLATED_FILE, -ret);
 	return ret;
@@ -1623,8 +1629,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
 				&nr_dirty, &nr_unqueued_dirty, &nr_congested,
-				&nr_writeback, &nr_immediate,
-				false);
+				&nr_writeback, &nr_immediate);
 
 	spin_lock_irq(&zone->lru_lock);
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
