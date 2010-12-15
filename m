Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E0B186B009F
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 15:38:44 -0500 (EST)
Received: from eu_spt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LDH003FTLCCO0@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 15 Dec 2010 20:38:40 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LDH0008MLCC0F@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 15 Dec 2010 20:38:37 +0000 (GMT)
Date: Wed, 15 Dec 2010 21:34:28 +0100
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [PATCHv8 08/12] mm: MIGRATE_CMA migration type added
In-reply-to: <cover.1292443200.git.m.nazarewicz@samsung.com>
Message-id: 
 <cf5d348eabe3feeda65a2ee93467e29a674c6690.1292443200.git.m.nazarewicz@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <cover.1292443200.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

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
---
 include/linux/mmzone.h |   43 ++++++++++++++++++++----
 mm/Kconfig             |   14 ++++++++
 mm/compaction.c        |   10 +++++
 mm/internal.h          |    3 ++
 mm/page_alloc.c        |   87 +++++++++++++++++++++++++++++++++++++----------
 5 files changed, 131 insertions(+), 26 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 39c24eb..cc798b1 100644
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
+#ifdef CONFIG_MIGRATE_CMA
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
+#ifdef CONFIG_MIGRATE_CMA
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
index 2beab4d..32fb085 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -343,6 +343,20 @@ config CMA
 
 	  For more information see <include/linux/cma.h>.  If unsure, say "n".
 
+config MIGRATE_CMA
+	bool "Use MIGRATE_CMA migratetype"
+	depends on CMA
+	default y
+	help
+	  This enables the use the MIGRATE_CMA migrate type in the CMA.
+	  MIGRATE_CMA lets CMA work on almost arbitrary memory range and
+	  not only inside ZONE_MOVABLE.
+
+	  This option can also be selected by code that uses MIGRATE_CMA
+	  even if CMA is not present.
+
+	  If unsure, say "y".
+
 config CMA_DEBUG
 	bool "CMA debug messages (DEVELOPEMENT)"
 	depends on CMA
diff --git a/mm/compaction.c b/mm/compaction.c
index 4d709ee..c5e404b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -113,6 +113,16 @@ static bool suitable_migration_target(struct page *page)
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
index dedb0af..cc24e74 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -49,6 +49,9 @@ extern void putback_lru_page(struct page *page);
  * in mm/page_alloc.c
  */
 extern void __free_pages_bootmem(struct page *page, unsigned int order);
+#ifdef CONFIG_MIGRATE_CMA
+extern void __free_pageblock_cma(struct page *page);
+#endif
 extern void prep_compound_page(struct page *page, unsigned long order);
 #ifdef CONFIG_MEMORY_FAILURE
 extern bool is_free_buddy_page(struct page *page);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 008a6e8..e706282 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -717,6 +717,30 @@ void __meminit __free_pages_bootmem(struct page *page, unsigned int order)
 	}
 }
 
+#ifdef CONFIG_MIGRATE_CMA
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
@@ -824,11 +848,15 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
  * This array describes the order lists are fallen back to when
  * the free lists for the desirable migrate type are depleted
  */
-static int fallbacks[MIGRATE_TYPES][MIGRATE_TYPES-1] = {
+static int fallbacks[MIGRATE_TYPES][4] = {
 	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,   MIGRATE_RESERVE },
 	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,   MIGRATE_RESERVE },
+#ifdef CONFIG_MIGRATE_CMA
+	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_CMA    , MIGRATE_RESERVE },
+#else
 	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
-	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE,     MIGRATE_RESERVE,   MIGRATE_RESERVE }, /* Never used */
+#endif
+	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE }, /* Never used */
 };
 
 /*
@@ -924,12 +952,12 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
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
@@ -944,19 +972,29 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 			 * pages to the preferred allocation list. If falling
 			 * back for a reclaimable kernel allocation, be more
 			 * agressive about taking ownership of free pages
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
@@ -966,11 +1004,14 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
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
@@ -1042,7 +1083,12 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 			list_add(&page->lru, list);
 		else
 			list_add_tail(&page->lru, list);
-		set_page_private(page, migratetype);
+#ifdef CONFIG_MIGRATE_CMA
+		if (is_pageblock_cma(page))
+			set_page_private(page, MIGRATE_CMA);
+		else
+#endif
+			set_page_private(page, migratetype);
 		list = &page->lru;
 	}
 	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
@@ -1178,8 +1224,8 @@ void free_hot_cold_page(struct page *page, int cold)
 	/*
 	 * We only track unmovable, reclaimable and movable on pcp lists.
 	 * Free ISOLATE pages back to the allocator because they are being
-	 * offlined but treat RESERVE as movable pages so we can get those
-	 * areas back if necessary. Otherwise, we may have to free
+	 * offlined but treat RESERVE and CMA as movable pages so we can get
+	 * those areas back if necessary. Otherwise, we may have to free
 	 * excessively into the page allocator
 	 */
 	if (migratetype >= MIGRATE_PCPTYPES) {
@@ -1272,7 +1318,9 @@ int split_free_page(struct page *page)
 	if (order >= pageblock_order - 1) {
 		struct page *endpage = page + (1 << order) - 1;
 		for (; page < endpage; page += pageblock_nr_pages)
-			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
+			if (!is_pageblock_cma(page))
+				set_pageblock_migratetype(page,
+							  MIGRATE_MOVABLE);
 	}
 
 	return 1 << order;
@@ -5309,7 +5357,8 @@ __count_immobile_pages(struct zone *zone, struct page *page, int count)
 	if (zone_idx(zone) == ZONE_MOVABLE)
 		return true;
 
-	if (get_pageblock_migratetype(page) == MIGRATE_MOVABLE)
+	if (get_pageblock_migratetype(page) == MIGRATE_MOVABLE ||
+	    is_pageblock_cma(page))
 		return true;
 
 	pfn = page_to_pfn(page);
-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
