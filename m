Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id B28246B0073
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 03:25:59 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [RFC PATCH 2/3 V1] mm, page migrate: add MIGRATE_HOTREMOVE type
Date: Wed, 4 Jul 2012 15:26:17 +0800
Message-Id: <1341386778-8002-3-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1341386778-8002-1-git-send-email-laijs@cn.fujitsu.com>
References: <1341386778-8002-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Chris Metcalf <cmetcalf@tilera.com>, --@kvack.org, Len Brown <lenb@kernel.org>--@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>--@kvack.org, Andi Kleen <andi@firstfloor.org>--@kvack.org, Julia Lawall <julia@diku.dk>--@kvack.org, David Howells <dhowells@redhat.com>--@kvack.org, Lai Jiangshan <laijs@cn.fujitsu.com>--@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>--@kvack.org, Kay Sievers <kay.sievers@vrfy.org>--@kvack.org, Ingo Molnar <mingo@elte.hu>--@kvack.org, Paul Gortmaker <paul.gortmaker@windriver.com>--@kvack.org, Daniel Kiper <dkiper@net-space.pl>--@kvack.org, Andrew Morton <akpm@linux-foundation.org>--@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>--@kvack.org, Michal Hocko <mhocko@suse.cz>--@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>--@kvack.org, Minchan Kim <minchan@kernel.org>--@kvack.org, Michal Nazarewicz <mina86@mina86.com>--@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>--@kvack.org, Rik van Riel <riel@redhat.com>--@kvack.org, Bjorn Helgaas <bhelgaas@google.com>--@kvack.org, Christoph Lameter <cl@linux.com>--@kvack.org, David Rientjes <rientjes@google.com>--@kvack.org, linux-kernel@vger.kernel.org--, linux-acpi@vger.kernel.org--, linux-mm@kvack.org

MIGRATE_HOTREMOVE is a special kind of MIGRATE_MOVABLE, but it is stable:
any page of the type can NOT be changed to the other type nor be moved to
the other free list.

So the pages of MIGRATE_HOTREMOVE are always movable, this ability is
useful for hugepages and hotremove ...etc.

MIGRATE_HOTREMOVE pages is the used as the first candidate when
we allocate movable pages.

1) add small routine is_migrate_movable() for movable-like types
2) add small routine is_migrate_stable() for stable types
3) fix some comments
4) fix get_any_page(). The get_any_page() may change
   MIGRATE_CMA/HOTREMOVE types page to MOVABLE which may cause this page
   to be changed to UNMOVABLE.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 include/linux/mmzone.h         |   34 ++++++++++++++++++++++++++++++++++
 include/linux/page-isolation.h |    2 +-
 mm/compaction.c                |    6 +++---
 mm/memory-failure.c            |    8 +++++++-
 mm/page_alloc.c                |   21 +++++++++++++--------
 mm/vmstat.c                    |    3 +++
 6 files changed, 61 insertions(+), 13 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 979c333..872f430 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -58,6 +58,15 @@ enum {
 	 */
 	MIGRATE_CMA,
 #endif
+#ifdef CONFIG_MEMORY_HOTREMOVE
+	/*
+	 * MIGRATE_HOTREMOVE migration type is designed to mimic the way
+	 * ZONE_MOVABLE works.  Only movable pages can be allocated
+	 * from MIGRATE_HOTREMOVE pageblocks and page allocator never
+	 * implicitly change migration type of MIGRATE_HOTREMOVE pageblock.
+	 */
+	MIGRATE_HOTREMOVE,
+#endif
 	MIGRATE_ISOLATE,	/* can't allocate from here */
 	MIGRATE_TYPES
 };
@@ -70,6 +79,31 @@ enum {
 #  define cma_wmark_pages(zone) 0
 #endif
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+#define is_migrate_hotremove(migratetype) ((migratetype) == MIGRATE_HOTREMOVE)
+#else
+#define is_migrate_hotremove(migratetype) false
+#endif
+
+/* Is it one of the movable types */
+static inline bool is_migrate_movable(int migratetype)
+{
+	return is_migrate_hotremove(migratetype) ||
+	       migratetype == MIGRATE_MOVABLE ||
+	       is_migrate_cma(migratetype);
+}
+
+/*
+ * Stable types: any page of the type can NOT be changed to
+ * the other type nor be moved to the other free list.
+ */
+static inline bool is_migrate_stable(int migratetype)
+{
+	return is_migrate_hotremove(migratetype) ||
+	       is_migrate_cma(migratetype) ||
+	       migratetype == MIGRATE_RESERVE;
+}
+
 #define for_each_migratetype_order(order, type) \
 	for (order = 0; order < MAX_ORDER; order++) \
 		for (type = 0; type < MIGRATE_TYPES; type++)
diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 3bdcab3..b1d6d92 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -15,7 +15,7 @@ start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 			 unsigned migratetype);
 
 /*
- * Changes MIGRATE_ISOLATE to MIGRATE_MOVABLE.
+ * Changes MIGRATE_ISOLATE to migratetype.
  * target range is [start_pfn, end_pfn)
  */
 extern int
diff --git a/mm/compaction.c b/mm/compaction.c
index 7ea259d..e8da894 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -47,7 +47,7 @@ static void map_pages(struct list_head *list)
 
 static inline bool migrate_async_suitable(int migratetype)
 {
-	return is_migrate_cma(migratetype) || migratetype == MIGRATE_MOVABLE;
+	return is_migrate_movable(migratetype);
 }
 
 /*
@@ -375,8 +375,8 @@ static bool suitable_migration_target(struct page *page)
 	if (PageBuddy(page) && page_order(page) >= pageblock_order)
 		return true;
 
-	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
-	if (migrate_async_suitable(migratetype))
+	/* If the block is movable, allow migration */
+	if (is_migrate_movable(migratetype))
 		return true;
 
 	/* Otherwise skip the block */
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index ab1e714..f5e300d 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1367,6 +1367,7 @@ static struct page *new_page(struct page *p, unsigned long private, int **x)
 static int get_any_page(struct page *p, unsigned long pfn, int flags)
 {
 	int ret;
+	int mt;
 
 	if (flags & MF_COUNT_INCREASED)
 		return 1;
@@ -1377,6 +1378,11 @@ static int get_any_page(struct page *p, unsigned long pfn, int flags)
 	 */
 	lock_memory_hotplug();
 
+	/* Don't move page of stable type to MIGRATE_MOVABLE */
+	mt = get_pageblock_migratetype(p);
+	if (!is_migrate_stable(mt))
+		mt = MIGRATE_MOVABLE;
+
 	/*
 	 * Isolate the page, so that it doesn't get reallocated if it
 	 * was free.
@@ -1404,7 +1410,7 @@ static int get_any_page(struct page *p, unsigned long pfn, int flags)
 		/* Not a free page */
 		ret = 1;
 	}
-	unset_migratetype_isolate(p, MIGRATE_MOVABLE);
+	unset_migratetype_isolate(p, mt);
 	unlock_memory_hotplug();
 	return ret;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index efc327f..7a4a03b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -667,7 +667,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			page = list_entry(list->prev, struct page, lru);
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
-			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
+			/* MIGRATE_MOVABLE list may include other types */
 			__free_one_page(page, zone, 0, page_private(page));
 			trace_mm_page_pcpu_drain(page, 0, page_private(page));
 		} while (--to_free && --batch_free && !list_empty(list));
@@ -1058,6 +1058,14 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
 {
 	struct page *page;
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+	if (migratetype == MIGRATE_MOVABLE) {
+		page = __rmqueue_smallest(zone, order, MIGRATE_HOTREMOVE);
+		if (likely(page))
+			goto done;
+	}
+#endif
+
 	page = __rmqueue_smallest(zone, order, migratetype);
 
 #ifdef CONFIG_CMA
@@ -1071,6 +1079,7 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
 	if (unlikely(!page))
 		page = __rmqueue_smallest(zone, order, MIGRATE_RESERVE);
 
+done:
 	trace_mm_page_alloc_zone_locked(page, order, migratetype);
 	return page;
 }
@@ -1105,11 +1114,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 			list_add(&page->lru, list);
 		else
 			list_add_tail(&page->lru, list);
-		if (IS_ENABLED(CONFIG_CMA)) {
-			mt = get_pageblock_migratetype(page);
-			if (!is_migrate_cma(mt) && mt != MIGRATE_ISOLATE)
-				mt = migratetype;
-		}
+		mt = get_pageblock_migratetype(page);
 		set_page_private(page, mt);
 		list = &page->lru;
 	}
@@ -1392,7 +1397,7 @@ int split_free_page(struct page *page)
 		struct page *endpage = page + (1 << order) - 1;
 		for (; page < endpage; page += pageblock_nr_pages) {
 			int mt = get_pageblock_migratetype(page);
-			if (mt != MIGRATE_ISOLATE && !is_migrate_cma(mt))
+			if (mt != MIGRATE_ISOLATE && !is_migrate_stable(mt))
 				set_pageblock_migratetype(page,
 							  MIGRATE_MOVABLE);
 		}
@@ -5465,7 +5470,7 @@ __count_immobile_pages(struct zone *zone, struct page *page, int count)
 	if (zone_idx(zone) == ZONE_MOVABLE)
 		return true;
 	mt = get_pageblock_migratetype(page);
-	if (mt == MIGRATE_MOVABLE || is_migrate_cma(mt))
+	if (is_migrate_movable(mt))
 		return true;
 
 	pfn = page_to_pfn(page);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 1bbbbd9..44a3b7f 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -616,6 +616,9 @@ static char * const migratetype_names[MIGRATE_TYPES] = {
 #ifdef CONFIG_CMA
 	"CMA",
 #endif
+#ifdef CONFIG_MEMORY_HOTREMOVE
+	"Hotremove",
+#endif
 	"Isolate",
 };
 
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
