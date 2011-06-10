Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 7FE42900117
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 05:55:06 -0400 (EDT)
Received: from eu_spt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LMK009BWJJPZ9@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 10 Jun 2011 10:55:01 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LMK00MP3JJOVW@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 10 Jun 2011 10:55:01 +0100 (BST)
Date: Fri, 10 Jun 2011 11:54:54 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 06/10] mm: MIGRATE_CMA migration type added
In-reply-to: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1307699698-29369-7-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>

From: Michal Nazarewicz <m.nazarewicz@samsung.com>

The MIGRATE_CMA migration type has two main characteristics:
(i) only movable pages can be allocated from MIGRATE_CMA
pageblocks and (ii) page allocator will never change migration
type of MIGRATE_CMA pageblocks.

This guarantees that page in a MIGRATE_CMA page block can
always be migrated somewhere else (unless there's no memory left
in the system).

It is designed to be used with Contiguous Memory Allocator
(CMA) for allocating big chunks (eg. 10MiB) of physically
contiguous memory.  Once driver requests contiguous memory,
CMA will migrate pages from MIGRATE_CMA pageblocks.

To minimise number of migrations, MIGRATE_CMA migration type
is the last type tried when page allocator falls back to other
migration types then requested.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
[m.szyprowski: cleaned up Kconfig]
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
CC: Michal Nazarewicz <mina86@mina86.com>
---
 include/linux/mmzone.h |   43 ++++++++++++++++++----
 mm/Kconfig             |    8 ++++-
 mm/compaction.c        |   10 +++++
 mm/internal.h          |    3 ++
 mm/page_alloc.c        |   93 ++++++++++++++++++++++++++++++++++++++----------
 5 files changed, 130 insertions(+), 27 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c928dac..a2eeacf 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -35,13 +35,37 @@
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
+#ifdef CONFIG_CMA_MIGRATE_TYPE
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
+#endif
+	MIGRATE_ISOLATE,	/* can't allocate from here */
+	MIGRATE_TYPES
+};
+
+#ifdef CONFIG_CMA_MIGRATE_TYPE
+#  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
+#else
+#  define is_migrate_cma(migratetype) false
+#endif
 
 #define for_each_migratetype_order(order, type) \
 	for (order = 0; order < MAX_ORDER; order++) \
@@ -54,6 +78,11 @@ static inline int get_pageblock_migratetype(struct page *page)
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
diff --git a/mm/Kconfig b/mm/Kconfig
index 8ca47a5..6ffedd8 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -189,7 +189,7 @@ config COMPACTION
 config MIGRATION
 	bool "Page migration"
 	def_bool y
-	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION
+	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION || CMA_MIGRATE_TYPE
 	help
 	  Allows the migration of the physical location of pages of processes
 	  while the virtual addresses are not changed. This is useful in
@@ -198,6 +198,12 @@ config MIGRATION
 	  pages as migration can relocate pages to satisfy a huge page
 	  allocation instead of reclaiming.
 
+config CMA_MIGRATE_TYPE
+	bool
+	help
+	  This enables the use the MIGRATE_CMA migrate type, which lets lets CMA
+	  work on almost arbitrary memory range and not only inside ZONE_MOVABLE.
+
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
 
diff --git a/mm/compaction.c b/mm/compaction.c
index 021a296..6d013c3 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -119,6 +119,16 @@ static bool suitable_migration_target(struct page *page)
 	if (migratetype == MIGRATE_ISOLATE || migratetype == MIGRATE_RESERVE)
 		return false;
 
+	/* Keep MIGRATE_CMA alone as well. */
+	/*
+	 * XXX Revisit.  We currently cannot let compaction touch CMA
+	 * pages since compaction insists on changing their migration
+	 * type to MIGRATE_MOVABLE (see split_free_page() called from
+	 * isolate_freepages_block() above).
+	 */
+	if (is_migrate_cma(migratetype))
+		return false;
+
 	/* If the page is a large free page, then allow migration */
 	if (PageBuddy(page) && page_order(page) >= pageblock_order)
 		return true;
diff --git a/mm/internal.h b/mm/internal.h
index d071d380..b44566c 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -49,6 +49,9 @@ extern void putback_lru_page(struct page *page);
  * in mm/page_alloc.c
  */
 extern void __free_pages_bootmem(struct page *page, unsigned int order);
+#ifdef CONFIG_CMA_MIGRATE_TYPE
+extern void __free_pageblock_cma(struct page *page);
+#endif
 extern void prep_compound_page(struct page *page, unsigned long order);
 #ifdef CONFIG_MEMORY_FAILURE
 extern bool is_free_buddy_page(struct page *page);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2cea044..c13c0dc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -719,6 +719,30 @@ void __meminit __free_pages_bootmem(struct page *page, unsigned int order)
 	}
 }
 
+#ifdef CONFIG_CMA_MIGRATE_TYPE
+
+/*
+ * Free whole pageblock and set it's migration type to MIGRATE_CMA.
+ */
+void __init __free_pageblock_cma(struct page *page)
+{
+	struct page *p = page;
+	unsigned i = pageblock_nr_pages;
+
+	prefetchw(p);
+	do {
+		if (--i)
+			prefetchw(p + 1);
+		__ClearPageReserved(p);
+		set_page_count(p, 0);
+	} while (++p, i);
+
+	set_page_refcounted(page);
+	set_pageblock_migratetype(page, MIGRATE_CMA);
+	__free_pages(page, pageblock_order);
+}
+
+#endif
 
 /*
  * The order of subdivision here is critical for the IO subsystem.
@@ -827,11 +851,15 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
  * This array describes the order lists are fallen back to when
  * the free lists for the desirable migrate type are depleted
  */
-static int fallbacks[MIGRATE_TYPES][MIGRATE_TYPES-1] = {
+static int fallbacks[MIGRATE_TYPES][4] = {
 	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,   MIGRATE_RESERVE },
 	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,   MIGRATE_RESERVE },
+#ifdef CONFIG_CMA_MIGRATE_TYPE
+	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_CMA    , MIGRATE_RESERVE },
+#else
 	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
-	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE,     MIGRATE_RESERVE,   MIGRATE_RESERVE }, /* Never used */
+#endif
+	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE }, /* Never used */
 };
 
 /*
@@ -926,12 +954,12 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
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
@@ -946,19 +974,29 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
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
-								start_migratetype);
+							     start_migratetype);
 
-				/* Claim the whole block if over half of it is free */
+				/*
+				 * Claim the whole block if over half
+				 * of it is free
+				 */
 				if (pages >= (1 << (pageblock_order-1)) ||
-						page_group_by_mobility_disabled)
+				    page_group_by_mobility_disabled)
 					set_pageblock_migratetype(page,
-								start_migratetype);
+							start_migratetype);
 
 				migratetype = start_migratetype;
 			}
@@ -968,11 +1006,14 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
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
@@ -1044,7 +1085,12 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 			list_add(&page->lru, list);
 		else
 			list_add_tail(&page->lru, list);
-		set_page_private(page, migratetype);
+#ifdef CONFIG_CMA_MIGRATE_TYPE
+		if (is_pageblock_cma(page))
+			set_page_private(page, MIGRATE_CMA);
+		else
+#endif
+			set_page_private(page, migratetype);
 		list = &page->lru;
 	}
 	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
@@ -1185,9 +1231,16 @@ void free_hot_cold_page(struct page *page, int cold)
 	 * offlined but treat RESERVE as movable pages so we can get those
 	 * areas back if necessary. Otherwise, we may have to free
 	 * excessively into the page allocator
+	 *
+	 * Still, do not change migration type of MIGRATE_CMA pages (if
+	 * they'd be recorded as MIGRATE_MOVABLE an unmovable page could
+	 * be allocated from MIGRATE_CMA block and we don't want to allow
+	 * that).  In this respect, treat MIGRATE_CMA like
+	 * MIGRATE_ISOLATE.
 	 */
 	if (migratetype >= MIGRATE_PCPTYPES) {
-		if (unlikely(migratetype == MIGRATE_ISOLATE)) {
+		if (unlikely(migratetype == MIGRATE_ISOLATE
+			  || is_migrate_cma(migratetype))) {
 			free_one_page(zone, page, 0, migratetype);
 			goto out;
 		}
@@ -1276,7 +1329,9 @@ int split_free_page(struct page *page)
 	if (order >= pageblock_order - 1) {
 		struct page *endpage = page + (1 << order) - 1;
 		for (; page < endpage; page += pageblock_nr_pages)
-			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
+			if (!is_pageblock_cma(page))
+				set_pageblock_migratetype(page,
+							  MIGRATE_MOVABLE);
 	}
 
 	return 1 << order;
@@ -5486,8 +5541,8 @@ __count_immobile_pages(struct zone *zone, struct page *page, int count)
 	 */
 	if (zone_idx(zone) == ZONE_MOVABLE)
 		return true;
-
-	if (get_pageblock_migratetype(page) == MIGRATE_MOVABLE)
+	if (get_pageblock_migratetype(page) == MIGRATE_MOVABLE ||
+	    is_pageblock_cma(page))
 		return true;
 
 	pfn = page_to_pfn(page);
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
