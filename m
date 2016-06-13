Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id B943E6B025F
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 03:51:07 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id jt9so79147525obc.2
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 00:51:07 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id g128si6236724ioa.99.2016.06.13.00.51.04
        for <linux-mm@kvack.org>;
        Mon, 13 Jun 2016 00:51:05 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 2/3] mm: vmscan: shrink_page_list with multiple zones
Date: Mon, 13 Jun 2016 16:50:57 +0900
Message-Id: <1465804259-29345-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1465804259-29345-1-git-send-email-minchan@kernel.org>
References: <1465804259-29345-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>

We have been reclaimed pages per zone but upcoming patch will
pass pages from multiple zones into shrink_page_list so this patch
prepares it.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 05119983c92e..d20c9e863d35 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -881,7 +881,6 @@ static void page_check_dirty_writeback(struct page *page,
  * shrink_page_list() returns the number of reclaimed pages
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
-				      struct zone *zone,
 				      struct scan_control *sc,
 				      enum ttu_flags ttu_flags,
 				      unsigned long *ret_nr_dirty,
@@ -910,6 +909,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		bool dirty, writeback;
 		bool lazyfree = false;
 		int ret = SWAP_SUCCESS;
+		struct zone *zone;
 
 		cond_resched();
 
@@ -919,8 +919,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (!trylock_page(page))
 			goto keep;
 
+		zone = page_zone(page);
 		VM_BUG_ON_PAGE(PageActive(page), page);
-		VM_BUG_ON_PAGE(page_zone(page) != zone, page);
 
 		sc->nr_scanned++;
 
@@ -933,6 +933,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
 			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
 
+		mapping = page_mapping(page);
 		if (sc->force_reclaim)
 			goto force_reclaim;
 
@@ -958,7 +959,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * pages marked for immediate reclaim are making it to the
 		 * end of the LRU a second time.
 		 */
-		mapping = page_mapping(page);
 		if (((dirty || writeback) && mapping &&
 		     inode_write_congested(mapping->host)) ||
 		    (writeback && PageReclaim(page)))
@@ -1272,7 +1272,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 		}
 	}
 
-	ret = shrink_page_list(&clean_pages, zone, &sc,
+	ret = shrink_page_list(&clean_pages, &sc,
 			TTU_UNMAP|TTU_IGNORE_ACCESS,
 			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5);
 	list_splice(&clean_pages, page_list);
@@ -1627,7 +1627,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	if (nr_taken == 0)
 		return 0;
 
-	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
+	nr_reclaimed = shrink_page_list(&page_list, sc, TTU_UNMAP,
 				&nr_dirty, &nr_unqueued_dirty, &nr_congested,
 				&nr_writeback, &nr_immediate);
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
