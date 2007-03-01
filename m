From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070301100430.29753.55673.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070301100229.29753.86342.sendpatchset@skynet.skynet.ie>
References: <20070301100229.29753.86342.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 6/12] Add a configure option to group pages by mobility
Date: Thu,  1 Mar 2007 10:04:30 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The grouping mechanism has some memory overhead and a more complex allocation
path. This patch allows the strategy to be disabled for small memory systems
or if it is known the workload is suffering because of the strategy. It also
acts to show where the page groupings strategy interacts with the standard
buddy allocator.


Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Joel Schopp <jschopp@austin.ibm.com>
---

 include/linux/mmzone.h |    6 ++++++
 init/Kconfig           |   13 +++++++++++++
 mm/page_alloc.c        |   31 +++++++++++++++++++++++++++++++
 3 files changed, 50 insertions(+)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-005_percpu/include/linux/mmzone.h linux-2.6.20-mm2-006_configurable/include/linux/mmzone.h
--- linux-2.6.20-mm2-005_percpu/include/linux/mmzone.h	2007-02-20 18:29:42.000000000 +0000
+++ linux-2.6.20-mm2-006_configurable/include/linux/mmzone.h	2007-02-20 18:33:41.000000000 +0000
@@ -25,9 +25,15 @@
 #endif
 #define MAX_ORDER_NR_PAGES (1 << (MAX_ORDER - 1))
 
+#ifdef CONFIG_PAGE_GROUP_BY_MOBILITY
 #define MIGRATE_UNMOVABLE     0
 #define MIGRATE_MOVABLE       1
 #define MIGRATE_TYPES         2
+#else
+#define MIGRATE_UNMOVABLE     0
+#define MIGRATE_MOVABLE       0
+#define MIGRATE_TYPES         1
+#endif
 
 #define for_each_migratetype_order(order, type) \
 	for (order = 0; order < MAX_ORDER; order++) \
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-005_percpu/init/Kconfig linux-2.6.20-mm2-006_configurable/init/Kconfig
--- linux-2.6.20-mm2-005_percpu/init/Kconfig	2007-02-19 01:22:33.000000000 +0000
+++ linux-2.6.20-mm2-006_configurable/init/Kconfig	2007-02-20 18:33:41.000000000 +0000
@@ -556,6 +556,19 @@ config SLOB
 	default !SLAB
 	bool
 
+config PAGE_GROUP_BY_MOBILITY
+	bool "Group pages based on their mobility in the page allocator"
+	def_bool y
+	help
+	  The standard allocator will fragment memory over time which means
+	  that high order allocations will fail even if kswapd is running. If
+	  this option is set, the allocator will try and group page types
+	  based on their ability to migrate or reclaim. This is a best effort
+	  attempt at lowering fragmentation which a few workloads care about.
+	  The loss is a more complex allocator that may perform slower. If
+	  you are interested in working with large pages, say Y and set
+	  /proc/sys/vm/min_free_bytes to 16374. Otherwise say N
+
 menu "Loadable module support"
 
 config MODULES
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-005_percpu/mm/page_alloc.c linux-2.6.20-mm2-006_configurable/mm/page_alloc.c
--- linux-2.6.20-mm2-005_percpu/mm/page_alloc.c	2007-02-20 18:31:48.000000000 +0000
+++ linux-2.6.20-mm2-006_configurable/mm/page_alloc.c	2007-02-20 18:33:41.000000000 +0000
@@ -136,6 +136,7 @@ static unsigned long __initdata dma_rese
 #endif /* CONFIG_MEMORY_HOTPLUG_RESERVE */
 #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
 
+#ifdef CONFIG_PAGE_GROUP_BY_MOBILITY
 static inline int get_pageblock_migratetype(struct page *page)
 {
 	return get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);
@@ -152,6 +153,22 @@ static inline int gfpflags_to_migratetyp
 	return ((gfp_flags & __GFP_MOVABLE) != 0);
 }
 
+#else
+static inline int get_pageblock_migratetype(struct page *page)
+{
+	return MIGRATE_UNMOVABLE;
+}
+
+static void set_pageblock_migratetype(struct page *page, int migratetype)
+{
+}
+
+static inline int gfpflags_to_migratetype(gfp_t gfp_flags)
+{
+	return MIGRATE_UNMOVABLE;
+}
+#endif /* CONFIG_PAGE_GROUP_BY_MOBILITY */
+
 #ifdef CONFIG_DEBUG_VM
 static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
 {
@@ -655,6 +672,7 @@ static int prep_new_page(struct page *pa
 	return 0;
 }
 
+#ifdef CONFIG_PAGE_GROUP_BY_MOBILITY
 /*
  * This array describes the order lists are fallen back to when
  * the free lists for the desirable migrate type are depleted
@@ -711,6 +729,13 @@ static struct page *__rmqueue_fallback(s
 
 	return NULL;
 }
+#else
+static struct page *__rmqueue_fallback(struct zone *zone, int order,
+						int start_migratetype)
+{
+	return NULL;
+}
+#endif /* CONFIG_PAGE_GROUP_BY_MOBILITY */
 
 /* 
  * Do the hard work of removing an element from the buddy allocator.
@@ -993,6 +1018,7 @@ again:
 			if (unlikely(!pcp->count))
 				goto failed;
 		}
+#ifdef CONFIG_PAGE_GROUP_BY_MOBILITY
 		/* Find a page of the appropriate migrate type */
 		list_for_each_entry(page, &pcp->list, lru) {
 			if (page_private(page) == migratetype) {
@@ -1014,6 +1040,11 @@ again:
 			list_del(&page->lru);
 			pcp->count--;
 		}
+#else
+		page = list_entry(pcp->list.next, struct page, lru);
+		list_del(&page->lru);
+		pcp->count--;
+#endif /* CONFIG_PAGE_GROUP_BY_MOBILITY */
 	} else {
 		spin_lock_irqsave(&zone->lock, flags);
 		page = __rmqueue(zone, order, migratetype);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
