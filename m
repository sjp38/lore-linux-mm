Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 84B496B0069
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 00:25:55 -0500 (EST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: compare MIGRATE_ISOLATE selectively
Date: Thu, 20 Dec 2012 14:25:52 +0900
Message-Id: <1355981152-2505-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

Now mm several functions test MIGRATE_ISOLATE and some of those
are hotpath but MIGRATE_ISOLATE is used only if we enable
CONFIG_MEMORY_ISOLATION(ie, CMA, memory-hotplug and memory-failure)
which are not common config option. So let's not add unnecessary
overhead and code.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/mmzone.h         |    2 ++
 include/linux/page-isolation.h |   19 +++++++++++++++++++
 mm/compaction.c                |    6 +++++-
 mm/page_alloc.c                |   16 ++++++++++------
 mm/vmstat.c                    |    2 ++
 5 files changed, 38 insertions(+), 7 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 73b64a3..4f4c8c2 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -57,7 +57,9 @@ enum {
 	 */
 	MIGRATE_CMA,
 #endif
+#ifdef CONFIG_MEMORY_ISOLATION
 	MIGRATE_ISOLATE,	/* can't allocate from here */
+#endif
 	MIGRATE_TYPES
 };
 
diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index a92061e..4ada4ef 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -1,6 +1,25 @@
 #ifndef __LINUX_PAGEISOLATION_H
 #define __LINUX_PAGEISOLATION_H
 
+#ifdef CONFIG_MEMORY_ISOLATION
+static inline bool page_isolated_pageblock(struct page *page)
+{
+	return get_pageblock_migratetype(page) == MIGRATE_ISOLATE;
+}
+static inline bool mt_isolated_pageblock(int migratetype)
+{
+	return migratetype == MIGRATE_ISOLATE;
+}
+#else
+static inline bool page_isolated_pageblock(struct page *page)
+{
+	return false;
+}
+static inline bool mt_isolated_pageblock(int migratetype)
+{
+	return false;
+}
+#endif
 
 bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 			 bool skip_hwpoisoned_pages);
diff --git a/mm/compaction.c b/mm/compaction.c
index 70f4443..dc2a6c7 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -15,6 +15,7 @@
 #include <linux/sysctl.h>
 #include <linux/sysfs.h>
 #include <linux/balloon_compaction.h>
+#include <linux/page-isolation.h>
 #include "internal.h"
 
 #ifdef CONFIG_COMPACTION
@@ -215,7 +216,10 @@ static bool suitable_migration_target(struct page *page)
 	int migratetype = get_pageblock_migratetype(page);
 
 	/* Don't interfere with memory hot-remove or the min_free_kbytes blocks */
-	if (migratetype == MIGRATE_ISOLATE || migratetype == MIGRATE_RESERVE)
+	if (migratetype == MIGRATE_RESERVE)
+		return false;
+
+	if (mt_isolated_pageblock(migratetype))
 		return false;
 
 	/* If the page is a large free page, then allow migration */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0939417..5450815 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -668,7 +668,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
 			__free_one_page(page, zone, 0, mt);
 			trace_mm_page_pcpu_drain(page, 0, mt);
-			if (likely(get_pageblock_migratetype(page) != MIGRATE_ISOLATE)) {
+			if (likely(!page_isolated_pageblock(page))) {
 				__mod_zone_page_state(zone, NR_FREE_PAGES, 1);
 				if (is_migrate_cma(mt))
 					__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, 1);
@@ -686,7 +686,7 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
 	zone->pages_scanned = 0;
 
 	__free_one_page(page, zone, order, migratetype);
-	if (unlikely(migratetype != MIGRATE_ISOLATE))
+	if (unlikely(!mt_isolated_pageblock(migratetype)))
 		__mod_zone_freepage_state(zone, 1 << order, migratetype);
 	spin_unlock(&zone->lock);
 }
@@ -914,7 +914,9 @@ static int fallbacks[MIGRATE_TYPES][4] = {
 	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE,   MIGRATE_RESERVE },
 #endif
 	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE }, /* Never used */
+#ifdef CONFIG_MEMORY_ISOLATION
 	[MIGRATE_ISOLATE]     = { MIGRATE_RESERVE }, /* Never used */
+#endif
 };
 
 /*
@@ -1140,7 +1142,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 			list_add_tail(&page->lru, list);
 		if (IS_ENABLED(CONFIG_CMA)) {
 			mt = get_pageblock_migratetype(page);
-			if (!is_migrate_cma(mt) && mt != MIGRATE_ISOLATE)
+			if (!is_migrate_cma(mt) && !mt_isolated_pageblock(mt))
 				mt = migratetype;
 		}
 		set_freepage_migratetype(page, mt);
@@ -1324,7 +1326,7 @@ void free_hot_cold_page(struct page *page, int cold)
 	 * excessively into the page allocator
 	 */
 	if (migratetype >= MIGRATE_PCPTYPES) {
-		if (unlikely(migratetype == MIGRATE_ISOLATE)) {
+		if (unlikely(mt_isolated_pageblock(migratetype))) {
 			free_one_page(zone, page, 0, migratetype);
 			goto out;
 		}
@@ -1405,7 +1407,7 @@ int capture_free_page(struct page *page, int alloc_order, int migratetype)
 	order = page_order(page);
 	mt = get_pageblock_migratetype(page);
 
-	if (mt != MIGRATE_ISOLATE) {
+	if (!mt_isolated_pageblock(mt)) {
 		/* Obey watermarks as if the page was being allocated */
 		watermark = low_wmark_pages(zone) + (1 << order);
 		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
@@ -1428,7 +1430,7 @@ int capture_free_page(struct page *page, int alloc_order, int migratetype)
 		struct page *endpage = page + (1 << order) - 1;
 		for (; page < endpage; page += pageblock_nr_pages) {
 			int mt = get_pageblock_migratetype(page);
-			if (mt != MIGRATE_ISOLATE && !is_migrate_cma(mt))
+			if (!mt_isolated_pageblock(mt) && !is_migrate_cma(mt))
 				set_pageblock_migratetype(page,
 							  MIGRATE_MOVABLE);
 		}
@@ -2937,7 +2939,9 @@ static void show_migration_types(unsigned char type)
 #ifdef CONFIG_CMA
 		[MIGRATE_CMA]		= 'C',
 #endif
+#ifdef CONFIG_MEMORY_ISOLATION
 		[MIGRATE_ISOLATE]	= 'I',
+#endif
 	};
 	char tmp[MIGRATE_TYPES + 1];
 	char *p = tmp;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 58e3da5..2e6094f 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -629,7 +629,9 @@ static char * const migratetype_names[MIGRATE_TYPES] = {
 #ifdef CONFIG_CMA
 	"CMA",
 #endif
+#ifdef CONFIG_MEMORY_ISOLATION
 	"Isolate",
+#endif
 };
 
 static void *frag_start(struct seq_file *m, loff_t *pos)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
