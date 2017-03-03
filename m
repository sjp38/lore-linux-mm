Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF106B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 06:14:57 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id r1so5142597pgr.2
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 03:14:57 -0800 (PST)
Received: from dggrg03-dlp.huawei.com ([45.249.212.189])
        by mx.google.com with ESMTP id g13si7236546pgf.56.2017.03.03.03.14.55
        for <linux-mm@kvack.org>;
        Fri, 03 Mar 2017 03:14:56 -0800 (PST)
Message-ID: <58B94F15.6060606@huawei.com>
Date: Fri, 3 Mar 2017 19:10:13 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 1/2] mm: use is_migrate_highatomic() to simplify the code
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Introduce two helpers, is_migrate_highatomic() and is_migrate_highatomic_page().
Simplify the code, no functional changes.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 include/linux/mmzone.h |  5 +++++
 mm/page_alloc.c        | 14 ++++++--------
 2 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 8e02b37..8124440 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -66,6 +66,11 @@ enum {
 /* In mm/page_alloc.c; keep in sync also with show_migration_types() there */
 extern char * const migratetype_names[MIGRATE_TYPES];
 
+#define is_migrate_highatomic(migratetype)				\
+	(migratetype == MIGRATE_HIGHATOMIC)
+#define is_migrate_highatomic_page(_page)				\
+	(get_pageblock_migratetype(_page) == MIGRATE_HIGHATOMIC)
+
 #ifdef CONFIG_CMA
 #  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
 #  define is_migrate_cma_page(_page) (get_pageblock_migratetype(_page) == MIGRATE_CMA)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9f9623d..40d79a6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2040,8 +2040,8 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
 
 	/* Yoink! */
 	mt = get_pageblock_migratetype(page);
-	if (mt != MIGRATE_HIGHATOMIC &&
-			!is_migrate_isolate(mt) && !is_migrate_cma(mt)) {
+	if (!is_migrate_highatomic(mt) && !is_migrate_isolate(mt)
+	    && !is_migrate_cma(mt)) {
 		zone->nr_reserved_highatomic += pageblock_nr_pages;
 		set_pageblock_migratetype(page, MIGRATE_HIGHATOMIC);
 		move_freepages_block(zone, page, MIGRATE_HIGHATOMIC);
@@ -2098,8 +2098,7 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
 			 * from highatomic to ac->migratetype. So we should
 			 * adjust the count once.
 			 */
-			if (get_pageblock_migratetype(page) ==
-							MIGRATE_HIGHATOMIC) {
+			if (is_migrate_highatomic_page(page)) {
 				/*
 				 * It should never happen but changes to
 				 * locking could inadvertently allow a per-cpu
@@ -2156,8 +2155,7 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
 
 		page = list_first_entry(&area->free_list[fallback_mt],
 						struct page, lru);
-		if (can_steal &&
-			get_pageblock_migratetype(page) != MIGRATE_HIGHATOMIC)
+		if (can_steal && !is_migrate_highatomic_page(page))
 			steal_suitable_fallback(zone, page, start_migratetype);
 
 		/* Remove the page from the freelists */
@@ -2494,7 +2492,7 @@ void free_hot_cold_page(struct page *page, bool cold)
 	/*
 	 * We only track unmovable, reclaimable and movable on pcp lists.
 	 * Free ISOLATE pages back to the allocator because they are being
-	 * offlined but treat RESERVE as movable pages so we can get those
+	 * offlined but treat HIGHATOMIC as movable pages so we can get those
 	 * areas back if necessary. Otherwise, we may have to free
 	 * excessively into the page allocator
 	 */
@@ -2605,7 +2603,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
 		for (; page < endpage; page += pageblock_nr_pages) {
 			int mt = get_pageblock_migratetype(page);
 			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt)
-				&& mt != MIGRATE_HIGHATOMIC)
+			    && !is_migrate_highatomic(mt))
 				set_pageblock_migratetype(page,
 							  MIGRATE_MOVABLE);
 		}
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
