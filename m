Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 9686D6B009C
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 07:39:18 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LWY0003JTTHVK80@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 29 Dec 2011 12:39:17 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LWY0086OTTGYC@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 29 Dec 2011 12:39:16 +0000 (GMT)
Date: Thu, 29 Dec 2011 13:39:06 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 05/11] mm: mmzone: MIGRATE_CMA migration type added
In-reply-to: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1325162352-24709-6-git-send-email-m.szyprowski@samsung.com>
References: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

From: Michal Nazarewicz <mina86@mina86.com>

The MIGRATE_CMA migration type has two main characteristics:
(i) only movable pages can be allocated from MIGRATE_CMA
pageblocks and (ii) page allocator will never change migration
type of MIGRATE_CMA pageblocks.

This guarantees (to some degree) that page in a MIGRATE_CMA page
block can always be migrated somewhere else (unless there's no
memory left in the system).

It is designed to be used for allocating big chunks (eg. 10MiB)
of physically contiguous memory.  Once driver requests
contiguous memory, pages from MIGRATE_CMA pageblocks may be
migrated away to create a contiguous block.

To minimise number of migrations, MIGRATE_CMA migration type
is the last type tried when page allocator falls back to other
migration types then requested.

Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
[m.szyprowski: removed CONFIG_CMA_MIGRATE_TYPE]
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 include/linux/mmzone.h         |   41 ++++++++++++++++++++----
 include/linux/page-isolation.h |    3 ++
 mm/Kconfig                     |    2 +-
 mm/compaction.c                |   11 +++++--
 mm/page_alloc.c                |   68 ++++++++++++++++++++++++++++++---------
 mm/vmstat.c                    |    1 +
 6 files changed, 99 insertions(+), 27 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 188cb2f..e38b85d 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -35,13 +35,35 @@
  */
 #define PAGE_ALLOC_COSTLY_ORDER 3
 
-#define MIGRATE_UNMOVABLE     0
-#define MIGRATE_RECLAIMABLE   1
-#define MIGRATE_MOVABLE       2
-#define MIGRATE_PCPTYPES      3 /* the number of types on the pcp lists */
-#define MIGRATE_RESERVE       3
-#define MIGRATE_ISOLATE       4 /* can't allocate from here */
-#define MIGRATE_TYPES         5
+enum {
+	MIGRATE_UNMOVABLE,
+	MIGRATE_RECLAIMABLE,
+	MIGRATE_MOVABLE,
+	MIGRATE_PCPTYPES,	/* the number of types on the pcp lists */
+	MIGRATE_RESERVE = MIGRATE_PCPTYPES,
+	/*
+	 * MIGRATE_CMA migration type is designed to mimic the way
+	 * ZONE_MOVABLE works.  Only movable pages can be allocated
+	 * from MIGRATE_CMA pageblocks and page allocator never
+	 * implicitly change migration type of MIGRATE_CMA pageblock.
+	 *
+	 * The way to use it is to change migratetype of a range of
+	 * pageblocks to MIGRATE_CMA which can be done by
+	 * __free_pageblock_cma() function.  What is important though
+	 * is that a range of pageblocks must be aligned to
+	 * MAX_ORDER_NR_PAGES should biggest page be bigger then
+	 * a single pageblock.
+	 */
+	MIGRATE_CMA,
+	MIGRATE_ISOLATE,	/* can't allocate from here */
+	MIGRATE_TYPES
+};
+
+#ifdef CONFIG_CMA
+#  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
+#else
+#  define is_migrate_cma(migratetype) false
+#endif
 
 #define for_each_migratetype_order(order, type) \
 	for (order = 0; order < MAX_ORDER; order++) \
@@ -54,6 +76,11 @@ static inline int get_pageblock_migratetype(struct page *page)
 	return get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);
 }
 
+static inline bool is_pageblock_cma(struct page *page)
+{
+	return is_migrate_cma(get_pageblock_migratetype(page));
+}
+
 struct free_area {
 	struct list_head	free_list[MIGRATE_TYPES];
 	unsigned long		nr_free;
diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index d305080..af650db 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -37,4 +37,7 @@ extern void unset_migratetype_isolate(struct page *page);
 int alloc_contig_range(unsigned long start, unsigned long end);
 void free_contig_range(unsigned long pfn, unsigned nr_pages);
 
+/* CMA stuff */
+extern void init_cma_reserved_pageblock(struct page *page);
+
 #endif
diff --git a/mm/Kconfig b/mm/Kconfig
index 011b110..e080cac 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -192,7 +192,7 @@ config COMPACTION
 config MIGRATION
 	bool "Page migration"
 	def_bool y
-	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION
+	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION || CMA
 	help
 	  Allows the migration of the physical location of pages of processes
 	  while the virtual addresses are not changed. This is useful in
diff --git a/mm/compaction.c b/mm/compaction.c
index 8733441..46783b4 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -21,6 +21,11 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/compaction.h>
 
+static inline bool is_migrate_cma_or_movable(int migratetype)
+{
+	return is_migrate_cma(migratetype) || migratetype == MIGRATE_MOVABLE;
+}
+
 /**
  * isolate_freepages_range() - isolate free pages, must hold zone->lock.
  * @zone:	Zone pages are in.
@@ -213,7 +218,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		 */
 		pageblock_nr = low_pfn >> pageblock_order;
 		if (!cc->sync && last_pageblock_nr != pageblock_nr &&
-				get_pageblock_migratetype(page) != MIGRATE_MOVABLE) {
+		    is_migrate_cma_or_movable(get_pageblock_migratetype(page))) {
 			low_pfn += pageblock_nr_pages;
 			low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
 			last_pageblock_nr = pageblock_nr;
@@ -295,8 +300,8 @@ static bool suitable_migration_target(struct page *page)
 	if (PageBuddy(page) && page_order(page) >= pageblock_order)
 		return true;
 
-	/* If the block is MIGRATE_MOVABLE, allow migration */
-	if (migratetype == MIGRATE_MOVABLE)
+	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
+	if (is_migrate_cma_or_movable(migratetype))
 		return true;
 
 	/* Otherwise skip the block */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 47b0a85..06a7861 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -722,6 +722,26 @@ void __meminit __free_pages_bootmem(struct page *page, unsigned int order)
 	}
 }
 
+#ifdef CONFIG_CMA
+/*
+ * Free whole pageblock and set it's migration type to MIGRATE_CMA.
+ */
+void __init init_cma_reserved_pageblock(struct page *page)
+{
+	unsigned i = pageblock_nr_pages;
+	struct page *p = page;
+
+	do {
+		__ClearPageReserved(p);
+		set_page_count(p, 0);
+	} while (++p, --i);
+
+	set_page_refcounted(page);
+	set_pageblock_migratetype(page, MIGRATE_CMA);
+	__free_pages(page, pageblock_order);
+	totalram_pages += pageblock_nr_pages;
+}
+#endif
 
 /*
  * The order of subdivision here is critical for the IO subsystem.
@@ -830,11 +850,10 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
  * This array describes the order lists are fallen back to when
  * the free lists for the desirable migrate type are depleted
  */
-static int fallbacks[MIGRATE_TYPES][MIGRATE_TYPES-1] = {
+static int fallbacks[MIGRATE_PCPTYPES][4] = {
 	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,   MIGRATE_RESERVE },
 	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,   MIGRATE_RESERVE },
-	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
-	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE,     MIGRATE_RESERVE,   MIGRATE_RESERVE }, /* Never used */
+	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_CMA    , MIGRATE_RESERVE },
 };
 
 /*
@@ -929,12 +948,12 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 	/* Find the largest possible block of pages in the other list */
 	for (current_order = MAX_ORDER-1; current_order >= order;
 						--current_order) {
-		for (i = 0; i < MIGRATE_TYPES - 1; i++) {
+		for (i = 0; i < ARRAY_SIZE(fallbacks[0]); i++) {
 			migratetype = fallbacks[start_migratetype][i];
 
 			/* MIGRATE_RESERVE handled later if necessary */
 			if (migratetype == MIGRATE_RESERVE)
-				continue;
+				break;
 
 			area = &(zone->free_area[current_order]);
 			if (list_empty(&area->free_list[migratetype]))
@@ -949,11 +968,18 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 			 * pages to the preferred allocation list. If falling
 			 * back for a reclaimable kernel allocation, be more
 			 * aggressive about taking ownership of free pages
+			 *
+			 * On the other hand, never change migration
+			 * type of MIGRATE_CMA pageblocks nor move CMA
+			 * pages on different free lists. We don't
+			 * want unmovable pages to be allocated from
+			 * MIGRATE_CMA areas.
 			 */
-			if (unlikely(current_order >= (pageblock_order >> 1)) ||
-					start_migratetype == MIGRATE_RECLAIMABLE ||
-					page_group_by_mobility_disabled) {
-				unsigned long pages;
+			if (!is_pageblock_cma(page) &&
+			    (unlikely(current_order >= pageblock_order / 2) ||
+			     start_migratetype == MIGRATE_RECLAIMABLE ||
+			     page_group_by_mobility_disabled)) {
+				int pages;
 				pages = move_freepages_block(zone, page,
 								start_migratetype);
 
@@ -971,11 +997,14 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 			rmv_page_order(page);
 
 			/* Take ownership for orders >= pageblock_order */
-			if (current_order >= pageblock_order)
+			if (current_order >= pageblock_order &&
+			    !is_pageblock_cma(page))
 				change_pageblock_range(page, current_order,
 							start_migratetype);
 
-			expand(zone, page, order, current_order, area, migratetype);
+			expand(zone, page, order, current_order, area,
+			       is_migrate_cma(start_migratetype)
+			     ? start_migratetype : migratetype);
 
 			trace_mm_page_alloc_extfrag(page, order, current_order,
 				start_migratetype, migratetype);
@@ -1047,7 +1076,10 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 			list_add(&page->lru, list);
 		else
 			list_add_tail(&page->lru, list);
-		set_page_private(page, migratetype);
+		if (is_pageblock_cma(page))
+			set_page_private(page, MIGRATE_CMA);
+		else
+			set_page_private(page, migratetype);
 		list = &page->lru;
 	}
 	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
@@ -1308,8 +1340,12 @@ int split_free_page(struct page *page)
 
 	if (order >= pageblock_order - 1) {
 		struct page *endpage = page + (1 << order) - 1;
-		for (; page < endpage; page += pageblock_nr_pages)
-			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
+		for (; page < endpage; page += pageblock_nr_pages) {
+			int mt = get_pageblock_migratetype(page);
+			if (mt != MIGRATE_ISOLATE && !is_migrate_cma(mt))
+				set_pageblock_migratetype(page,
+							  MIGRATE_MOVABLE);
+		}
 	}
 
 	return 1 << order;
@@ -5599,8 +5635,8 @@ __count_immobile_pages(struct zone *zone, struct page *page, int count)
 	 */
 	if (zone_idx(zone) == ZONE_MOVABLE)
 		return true;
-
-	if (get_pageblock_migratetype(page) == MIGRATE_MOVABLE)
+	if (get_pageblock_migratetype(page) == MIGRATE_MOVABLE ||
+	    is_pageblock_cma(page))
 		return true;
 
 	pfn = page_to_pfn(page);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 8fd603b..9fb1789 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -613,6 +613,7 @@ static char * const migratetype_names[MIGRATE_TYPES] = {
 	"Reclaimable",
 	"Movable",
 	"Reserve",
+	"Cma",
 	"Isolate",
 };
 
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
