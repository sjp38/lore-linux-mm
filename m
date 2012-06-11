Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 3C54D6B006C
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 22:07:35 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: clean up __count_immobile_pages
Date: Mon, 11 Jun 2012 11:07:22 +0900
Message-Id: <1339380442-1137-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

__count_immobile_pages naming is rather awkward.
This patch clean up the function and add comment.

Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/page_alloc.c |   33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 019c4fe..2c71ac9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5467,26 +5467,27 @@ void set_pageblock_flags_group(struct page *page, unsigned long flags,
 }
 
 /*
- * This is designed as sub function...plz see page_isolation.c also.
- * set/clear page block's type to be ISOLATE.
- * page allocater never alloc memory from ISOLATE block.
+ * This function checks whether pageblock includes unmovable pages or not.
+ * If @count is not zero, it is okay to include less @count unmovable pages
+ *
+ * This function can race in PageLRU and MIGRATE_MOVABLE can have unmovable
+ * pages so that it might be not exact.
  */
-
-static int
-__count_immobile_pages(struct zone *zone, struct page *page, int count)
+static bool
+__has_unmovable_pages(struct zone *zone, struct page *page, int count)
 {
 	unsigned long pfn, iter, found;
 	int mt;
 
 	/*
 	 * For avoiding noise data, lru_add_drain_all() should be called
-	 * If ZONE_MOVABLE, the zone never contains immobile pages
+	 * If ZONE_MOVABLE, the zone never contains unmovable pages
 	 */
 	if (zone_idx(zone) == ZONE_MOVABLE)
-		return true;
+		return false;
 	mt = get_pageblock_migratetype(page);
 	if (mt == MIGRATE_MOVABLE || is_migrate_cma(mt))
-		return true;
+		return false;
 
 	pfn = page_to_pfn(page);
 	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
@@ -5521,9 +5522,9 @@ __count_immobile_pages(struct zone *zone, struct page *page, int count)
 		 * page at boot.
 		 */
 		if (found > count)
-			return false;
+			return true;
 	}
-	return true;
+	return false;
 }
 
 bool is_pageblock_removable_nolock(struct page *page)
@@ -5547,7 +5548,7 @@ bool is_pageblock_removable_nolock(struct page *page)
 			zone->zone_start_pfn + zone->spanned_pages <= pfn)
 		return false;
 
-	return __count_immobile_pages(zone, page, 0);
+	return !__has_unmovable_pages(zone, page, 0);
 }
 
 int set_migratetype_isolate(struct page *page)
@@ -5586,12 +5587,12 @@ int set_migratetype_isolate(struct page *page)
 	 * FIXME: Now, memory hotplug doesn't call shrink_slab() by itself.
 	 * We just check MOVABLE pages.
 	 */
-	if (__count_immobile_pages(zone, page, arg.pages_found))
+	if (!__has_unmovable_pages(zone, page, arg.pages_found))
 		ret = 0;
-
 	/*
-	 * immobile means "not-on-lru" paes. If immobile is larger than
-	 * removable-by-driver pages reported by notifier, we'll fail.
+	 * Unmovable means "not-on-lru" pages. If Unmovable pages are
+	 * larger than removable-by-driver pages reported by notifier,
+	 * we'll fail.
 	 */
 
 out:
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
