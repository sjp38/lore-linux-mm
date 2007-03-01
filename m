From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070301100550.29753.64145.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070301100229.29753.86342.sendpatchset@skynet.skynet.ie>
References: <20070301100229.29753.86342.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 10/12] Group high-order atomic allocations
Date: Thu,  1 Mar 2007 10:05:50 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In rare cases, the kernel needs to allocate a high-order block of pages
without sleeping. For example, this is the case with e1000 cards configured
to use jumbo frames.  Migrating or reclaiming pages in this situation is
not an option.

This patch groups these allocations together as much as possible by adding
a new MIGRATE_TYPE. The MIGRATE_HIGHATOMIC type are exactly what they sound
like. Care is taken that pages of other migrate types do not use the same
blocks as high-order atomic allocations.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 include/linux/mmzone.h |    4 +++-
 mm/page_alloc.c        |   36 ++++++++++++++++++++++++++++++------
 2 files changed, 33 insertions(+), 7 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-009_cluster_reclaimable/include/linux/mmzone.h linux-2.6.20-mm2-010_cluster_atomic/include/linux/mmzone.h
--- linux-2.6.20-mm2-009_cluster_reclaimable/include/linux/mmzone.h	2007-02-20 18:46:51.000000000 +0000
+++ linux-2.6.20-mm2-010_cluster_atomic/include/linux/mmzone.h	2007-02-20 18:50:00.000000000 +0000
@@ -29,11 +29,13 @@
 #define MIGRATE_UNMOVABLE     0
 #define MIGRATE_RECLAIMABLE   1
 #define MIGRATE_MOVABLE       2
-#define MIGRATE_TYPES         3
+#define MIGRATE_HIGHATOMIC    3
+#define MIGRATE_TYPES         4
 #else
 #define MIGRATE_UNMOVABLE     0
 #define MIGRATE_UNRECLAIMABLE 0
 #define MIGRATE_MOVABLE       0
+#define MIGRATE_HIGHATOMIC    0
 #define MIGRATE_TYPES         1
 #endif
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-009_cluster_reclaimable/mm/page_alloc.c linux-2.6.20-mm2-010_cluster_atomic/mm/page_alloc.c
--- linux-2.6.20-mm2-009_cluster_reclaimable/mm/page_alloc.c	2007-02-20 18:46:51.000000000 +0000
+++ linux-2.6.20-mm2-010_cluster_atomic/mm/page_alloc.c	2007-02-20 18:50:00.000000000 +0000
@@ -148,10 +148,16 @@ static void set_pageblock_migratetype(st
 					PB_migrate, PB_migrate_end);
 }
 
-static inline int gfpflags_to_migratetype(gfp_t gfp_flags)
+static inline int allocflags_to_migratetype(gfp_t gfp_flags, int order)
 {
 	WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
 
+	/* Cluster high-order atomic allocations together */
+	if (unlikely(order > 0) &&
+			(!(gfp_flags & __GFP_WAIT) || in_interrupt()))
+		return MIGRATE_HIGHATOMIC;
+
+	/* Cluster based on mobility */
 	return (((gfp_flags & __GFP_MOVABLE) != 0) << 1) |
 		((gfp_flags & __GFP_RECLAIMABLE) != 0);
 }
@@ -166,7 +172,7 @@ static void set_pageblock_migratetype(st
 {
 }
 
-static inline int gfpflags_to_migratetype(gfp_t gfp_flags)
+static inline int allocflags_to_migratetype(gfp_t gfp_flags, int order)
 {
 	return MIGRATE_UNMOVABLE;
 }
@@ -681,9 +687,10 @@ static int prep_new_page(struct page *pa
  * the free lists for the desirable migrate type are depleted
  */
 static int fallbacks[MIGRATE_TYPES][MIGRATE_TYPES-1] = {
-	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE   },
-	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE   },
-	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE },
+	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,  MIGRATE_HIGHATOMIC },
+	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,  MIGRATE_HIGHATOMIC },
+	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE,MIGRATE_HIGHATOMIC },
+	[MIGRATE_HIGHATOMIC]  = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE,MIGRATE_MOVABLE},
 };
 
 /*
@@ -751,13 +758,24 @@ static struct page *__rmqueue_fallback(s
 	int current_order;
 	struct page *page;
 	int migratetype, i;
+	int nonatomic_fallback_atomic = 0;
 
+retry:
 	/* Find the largest possible block of pages in the other list */
 	for (current_order = MAX_ORDER-1; current_order >= order;
 						--current_order) {
 		for (i = 0; i < MIGRATE_TYPES - 1; i++) {
 			migratetype = fallbacks[start_migratetype][i];
 
+			/*
+			 * Make it hard to fallback to blocks used for
+			 * high-order atomic allocations
+			 */
+			if (migratetype == MIGRATE_HIGHATOMIC &&
+				start_migratetype != MIGRATE_UNMOVABLE &&
+				!nonatomic_fallback_atomic)
+				continue;
+
 			area = &(zone->free_area[current_order]);
 			if (list_empty(&area->free_list[migratetype]))
 				continue;
@@ -790,6 +808,12 @@ static struct page *__rmqueue_fallback(s
 		}
 	}
 
+	/* Allow fallback to high-order atomic blocks if memory is that low */
+	if (!nonatomic_fallback_atomic) {
+		nonatomic_fallback_atomic = 1;
+		goto retry;
+	}
+
 	return NULL;
 }
 #else
@@ -1089,7 +1113,7 @@ static struct page *buffered_rmqueue(str
 	struct page *page;
 	int cold = !!(gfp_flags & __GFP_COLD);
 	int cpu;
-	int migratetype = gfpflags_to_migratetype(gfp_flags);
+	int migratetype = allocflags_to_migratetype(gfp_flags, order);
 
 again:
 	cpu  = get_cpu();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
