Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 706626B0039
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 02:22:05 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 3/4] mm: Remove shrink_page
Date: Mon, 25 Mar 2013 15:21:33 +0900
Message-Id: <1364192494-22185-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1364192494-22185-1-git-send-email-minchan@kernel.org>
References: <1364192494-22185-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Sangseok Lee <sangseok.lee@lge.com>, Minchan Kim <minchan@kernel.org>

By previous patch, shrink_page_list can handle pages from
multiple zone so let's remove shrink_page.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c | 47 ++++++++++++++---------------------------------
 1 file changed, 14 insertions(+), 33 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9434ba2..367d0f4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -923,6 +923,13 @@ free_it:
 		 * appear not as the counts should be low
 		 */
 		list_add(&page->lru, &free_pages);
+		/*
+		 * If pagelist are from multiple zones, we should decrease
+		 * NR_ISOLATED_ANON + x on freed pages in here.
+		 */
+		if (!zone)
+			dec_zone_page_state(page, NR_ISOLATED_ANON +
+					page_is_file_cache(page));
 		continue;
 
 cull_mlocked:
@@ -993,28 +1000,6 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 }
 
 #ifdef CONFIG_PROCESS_RECLAIM
-static unsigned long shrink_page(struct page *page,
-					struct zone *zone,
-					struct scan_control *sc,
-					enum ttu_flags ttu_flags,
-					unsigned long *ret_nr_dirty,
-					unsigned long *ret_nr_writeback,
-					bool force_reclaim,
-					struct list_head *ret_pages)
-{
-	int reclaimed;
-	LIST_HEAD(page_list);
-	list_add(&page->lru, &page_list);
-
-	reclaimed = shrink_page_list(&page_list, zone, sc, ttu_flags,
-				ret_nr_dirty, ret_nr_writeback,
-				force_reclaim);
-	if (!reclaimed)
-		list_splice(&page_list, ret_pages);
-
-	return reclaimed;
-}
-
 unsigned long reclaim_pages_from_list(struct list_head *page_list)
 {
 	struct scan_control sc = {
@@ -1024,23 +1009,19 @@ unsigned long reclaim_pages_from_list(struct list_head *page_list)
 		.may_swap = 1,
 	};
 
-	LIST_HEAD(ret_pages);
+	unsigned long nr_reclaimed;
 	struct page *page;
 	unsigned long dummy1, dummy2;
-	unsigned long nr_reclaimed = 0;
-
-	while (!list_empty(page_list)) {
-		page = lru_to_page(page_list);
-		list_del(&page->lru);
 
+	list_for_each_entry(page, page_list, lru)
 		ClearPageActive(page);
-		nr_reclaimed += shrink_page(page, page_zone(page), &sc,
+
+	nr_reclaimed = shrink_page_list(page_list, NULL, &sc,
 				TTU_UNMAP|TTU_IGNORE_ACCESS,
-				&dummy1, &dummy2, true, &ret_pages);
-	}
+				&dummy1, &dummy2, true);
 
-	while (!list_empty(&ret_pages)) {
-		page = lru_to_page(&ret_pages);
+	while (!list_empty(page_list)) {
+		page = lru_to_page(page_list);
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-- 
1.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
