From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070418135356.27180.27106.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070418135336.27180.32695.sendpatchset@skynet.skynet.ie>
References: <20070418135336.27180.32695.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 1/2] Back out add-a-configure-option-to-group-pages-by-mobility
Date: Wed, 18 Apr 2007 14:53:56 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Grouping pages by mobility can be disabled at compile-time. This was
considered undesirable by a number of people. However, in the current stack of
patches, it is not a simple case of just dropping the configurable patch as it
would cause merge conflicts.  This patch backs out the configuration option.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 include/linux/mmzone.h |    9 ---------
 init/Kconfig           |   13 -------------
 mm/page_alloc.c        |   42 ++----------------------------------------
 3 files changed, 2 insertions(+), 62 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc6-mm1-001_latest/include/linux/mmzone.h linux-2.6.21-rc6-mm1-002_backout_configurable/include/linux/mmzone.h
--- linux-2.6.21-rc6-mm1-001_latest/include/linux/mmzone.h	2007-04-17 14:49:33.000000000 +0100
+++ linux-2.6.21-rc6-mm1-002_backout_configurable/include/linux/mmzone.h	2007-04-17 16:35:48.000000000 +0100
@@ -25,21 +25,12 @@
 #endif
 #define MAX_ORDER_NR_PAGES (1 << (MAX_ORDER - 1))
 
-#ifdef CONFIG_PAGE_GROUP_BY_MOBILITY
 #define MIGRATE_UNMOVABLE     0
 #define MIGRATE_RECLAIMABLE   1
 #define MIGRATE_MOVABLE       2
 #define MIGRATE_HIGHATOMIC    3
 #define MIGRATE_RESERVE       4
 #define MIGRATE_TYPES         5
-#else
-#define MIGRATE_UNMOVABLE     0
-#define MIGRATE_UNRECLAIMABLE 0
-#define MIGRATE_MOVABLE       0
-#define MIGRATE_HIGHATOMIC    0
-#define MIGRATE_RESERVE       0
-#define MIGRATE_TYPES         1
-#endif
 
 #define for_each_migratetype_order(order, type) \
 	for (order = 0; order < MAX_ORDER; order++) \
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc6-mm1-001_latest/init/Kconfig linux-2.6.21-rc6-mm1-002_backout_configurable/init/Kconfig
--- linux-2.6.21-rc6-mm1-001_latest/init/Kconfig	2007-04-17 14:32:03.000000000 +0100
+++ linux-2.6.21-rc6-mm1-002_backout_configurable/init/Kconfig	2007-04-17 16:35:48.000000000 +0100
@@ -636,19 +636,6 @@ config BASE_SMALL
 	default 0 if BASE_FULL
 	default 1 if !BASE_FULL
 
-config PAGE_GROUP_BY_MOBILITY
-	bool "Group pages based on their mobility in the page allocator"
-	def_bool y
-	help
-	  The standard allocator will fragment memory over time which means
-	  that high order allocations will fail even if kswapd is running. If
-	  this option is set, the allocator will try and group page types
-	  based on their ability to migrate or reclaim. This is a best effort
-	  attempt at lowering fragmentation which a few workloads care about.
-	  The loss is a more complex allocator that may perform slower. If
-	  you are interested in working with large pages, say Y and set
-	  /proc/sys/vm/min_free_bytes to 16374. Otherwise say N
-
 menu "Loadable module support"
 
 config MODULES
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc6-mm1-001_latest/mm/page_alloc.c linux-2.6.21-rc6-mm1-002_backout_configurable/mm/page_alloc.c
--- linux-2.6.21-rc6-mm1-001_latest/mm/page_alloc.c	2007-04-17 16:33:48.000000000 +0100
+++ linux-2.6.21-rc6-mm1-002_backout_configurable/mm/page_alloc.c	2007-04-17 16:35:48.000000000 +0100
@@ -144,7 +144,6 @@ static unsigned long __meminitdata dma_r
   EXPORT_SYMBOL(movable_zone);
 #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
 
-#ifdef CONFIG_PAGE_GROUP_BY_MOBILITY
 int page_group_by_mobility_disabled __read_mostly;
 
 static inline int get_pageblock_migratetype(struct page *page)
@@ -178,22 +177,6 @@ static inline int allocflags_to_migratet
 		((gfp_flags & __GFP_RECLAIMABLE) != 0);
 }
 
-#else
-static inline int get_pageblock_migratetype(struct page *page)
-{
-	return MIGRATE_UNMOVABLE;
-}
-
-static void set_pageblock_migratetype(struct page *page, int migratetype)
-{
-}
-
-static inline int allocflags_to_migratetype(gfp_t gfp_flags, int order)
-{
-	return MIGRATE_UNMOVABLE;
-}
-#endif /* CONFIG_PAGE_GROUP_BY_MOBILITY */
-
 #ifdef CONFIG_DEBUG_VM
 static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
 {
@@ -728,7 +711,6 @@ static struct page *__rmqueue_smallest(s
 }
 
 
-#ifdef CONFIG_PAGE_GROUP_BY_MOBILITY
 /*
  * This array describes the order lists are fallen back to when
  * the free lists for the desirable migrate type are depleted
@@ -760,7 +742,7 @@ int move_freepages(struct zone *zone,
 	 * CONFIG_HOLES_IN_ZONE is set. This bug check is probably redundant
 	 * anyway as we check zone boundaries in move_freepages_block().
 	 * Remove at a later date when no bug reports exist related to
-	 * CONFIG_PAGE_GROUP_BY_MOBILITY
+	 * grouping pages by mobility
 	 */
 	BUG_ON(page_zone(start_page) != page_zone(end_page));
 #endif
@@ -909,13 +891,6 @@ retry:
 	/* Use MIGRATE_RESERVE rather than fail an allocation */
 	return __rmqueue_smallest(zone, order, MIGRATE_RESERVE);
 }
-#else
-static struct page *__rmqueue_fallback(struct zone *zone, int order,
-						int start_migratetype)
-{
-	return NULL;
-}
-#endif /* CONFIG_PAGE_GROUP_BY_MOBILITY */
 
 /*
  * Do the hard work of removing an element from the buddy allocator.
@@ -1081,7 +1056,6 @@ void mark_free_pages(struct zone *zone)
 }
 #endif /* CONFIG_PM */
 
-#if defined(CONFIG_PM) || defined(CONFIG_PAGE_GROUP_BY_MOBILITY)
 /*
  * Spill all of this CPU's per-cpu pages back into the buddy allocator.
  */
@@ -1112,9 +1086,6 @@ void drain_all_local_pages(void)
 
 	smp_call_function(smp_drain_local_pages, NULL, 0, 1);
 }
-#else
-void drain_all_local_pages(void) {}
-#endif /* CONFIG_PM || CONFIG_PAGE_GROUP_BY_MOBILITY */
 
 /*
  * Free a 0-order page
@@ -1205,7 +1176,6 @@ again:
 				goto failed;
 		}
 
-#ifdef CONFIG_PAGE_GROUP_BY_MOBILITY
 		/* Find a page of the appropriate migrate type */
 		list_for_each_entry(page, &pcp->list, lru)
 			if (page_private(page) == migratetype)
@@ -1217,9 +1187,6 @@ again:
 					pcp->batch, &pcp->list, migratetype);
 			page = list_entry(pcp->list.next, struct page, lru);
 		}
-#else
-		page = list_entry(pcp->list.next, struct page, lru);
-#endif /* CONFIG_PAGE_GROUP_BY_MOBILITY */
 
 		list_del(&page->lru);
 		pcp->count--;
@@ -2385,7 +2352,6 @@ static inline unsigned long wait_table_b
 
 #define LONG_ALIGN(x) (((x)+(sizeof(long))-1)&~((sizeof(long))-1))
 
-#ifdef CONFIG_PAGE_GROUP_BY_MOBILITY
 /*
  * Mark a number of MAX_ORDER_NR_PAGES blocks as MIGRATE_RESERVE. The number
  * of blocks reserved is based on zone->pages_min. The memory within the
@@ -2439,11 +2405,7 @@ static void setup_zone_migrate_reserve(s
 		}
 	}
 }
-#else
-static inline void setup_zone_migrate_reserve(struct zone *zone)
-{
-}
-#endif /* CONFIG_PAGE_GROUP_BY_MOBILITY */
+
 /*
  * Initially all pages are reserved - free ones are freed
  * up by free_all_bootmem() once the early boot process is

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
