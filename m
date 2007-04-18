From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070418135416.27180.1307.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070418135336.27180.32695.sendpatchset@skynet.skynet.ie>
References: <20070418135336.27180.32695.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 2/2] Back out group-high-order-atomic-allocations
Date: Wed, 18 Apr 2007 14:54:16 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Grouping high-order atomic allocations together was intended to allow
bursty users of atomic allocations to work such as e1000 in situations
where their preallocated buffers were depleted. This did not work in
at least one case with a wireless network adapter needing order-1
allocations frequently. To resolve that, the free pages used for
min_free_kbytes were moved to separate contiguous blocks with the patch
bias-the-location-of-pages-freed-for-min_free_kbytes-in-the-same-max_order_nr_pages-blocks.

It is felt that keeping the free pages in the same contiguous blocks should be
sufficient for bursty short-lived high-order atomic allocations to succeed,
maybe even with the e1000. Even if there is a failure, increasing the value
of min_free_kbytes will free pages as contiguous bloks in contrast to the
standard buddy allocator which makes no attempt to keep the minimum number
of free pages contiguous.

This patch backs out grouping high order atomic allocations together to
determine if it is really needed or not. If a new report comes in about
high-order atomic allocations failing, the feature can be reintroduced to
determine if it fixes the problem or not. As a side-effect, this patch
reduces by 1 the number of bits required to track the mobility type of
pages within a MAX_ORDER_NR_PAGES block.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 include/linux/mmzone.h          |    5 ++---
 include/linux/pageblock-flags.h |    2 +-
 mm/page_alloc.c                 |   33 +++++----------------------------
 3 files changed, 8 insertions(+), 32 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc6-mm1-002_backout_configurable/include/linux/mmzone.h linux-2.6.21-rc6-mm1-003_backout_highatomic/include/linux/mmzone.h
--- linux-2.6.21-rc6-mm1-002_backout_configurable/include/linux/mmzone.h	2007-04-17 16:35:48.000000000 +0100
+++ linux-2.6.21-rc6-mm1-003_backout_highatomic/include/linux/mmzone.h	2007-04-17 16:37:39.000000000 +0100
@@ -28,9 +28,8 @@
 #define MIGRATE_UNMOVABLE     0
 #define MIGRATE_RECLAIMABLE   1
 #define MIGRATE_MOVABLE       2
-#define MIGRATE_HIGHATOMIC    3
-#define MIGRATE_RESERVE       4
-#define MIGRATE_TYPES         5
+#define MIGRATE_RESERVE       3
+#define MIGRATE_TYPES         4
 
 #define for_each_migratetype_order(order, type) \
 	for (order = 0; order < MAX_ORDER; order++) \
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc6-mm1-002_backout_configurable/include/linux/pageblock-flags.h linux-2.6.21-rc6-mm1-003_backout_highatomic/include/linux/pageblock-flags.h
--- linux-2.6.21-rc6-mm1-002_backout_configurable/include/linux/pageblock-flags.h	2007-04-17 14:32:03.000000000 +0100
+++ linux-2.6.21-rc6-mm1-003_backout_highatomic/include/linux/pageblock-flags.h	2007-04-17 16:37:39.000000000 +0100
@@ -31,7 +31,7 @@
 
 /* Bit indices that affect a whole block of pages */
 enum pageblock_bits {
-	PB_range(PB_migrate, 3), /* 3 bits required for migrate types */
+	PB_range(PB_migrate, 2), /* 2 bits required for migrate types */
 	NR_PAGEBLOCK_BITS
 };
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc6-mm1-002_backout_configurable/mm/page_alloc.c linux-2.6.21-rc6-mm1-003_backout_highatomic/mm/page_alloc.c
--- linux-2.6.21-rc6-mm1-002_backout_configurable/mm/page_alloc.c	2007-04-17 16:35:48.000000000 +0100
+++ linux-2.6.21-rc6-mm1-003_backout_highatomic/mm/page_alloc.c	2007-04-17 16:37:39.000000000 +0100
@@ -167,11 +167,6 @@ static inline int allocflags_to_migratet
 	if (unlikely(page_group_by_mobility_disabled))
 		return MIGRATE_UNMOVABLE;
 
-	/* Cluster high-order atomic allocations together */
-	if (unlikely(order > 0) &&
-			(!(gfp_flags & __GFP_WAIT) || in_interrupt()))
-		return MIGRATE_HIGHATOMIC;
-
 	/* Cluster based on mobility */
 	return (((gfp_flags & __GFP_MOVABLE) != 0) << 1) |
 		((gfp_flags & __GFP_RECLAIMABLE) != 0);
@@ -716,11 +711,10 @@ static struct page *__rmqueue_smallest(s
  * the free lists for the desirable migrate type are depleted
  */
 static int fallbacks[MIGRATE_TYPES][MIGRATE_TYPES-1] = {
-	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,   MIGRATE_HIGHATOMIC, MIGRATE_RESERVE },
-	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,   MIGRATE_HIGHATOMIC, MIGRATE_RESERVE },
-	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_HIGHATOMIC, MIGRATE_RESERVE },
-	[MIGRATE_HIGHATOMIC]  = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_MOVABLE,    MIGRATE_RESERVE },
-	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE,     MIGRATE_RESERVE,   MIGRATE_RESERVE,    MIGRATE_RESERVE }, /* Never used */
+	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,   MIGRATE_RESERVE },
+	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,   MIGRATE_RESERVE },
+	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
+	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE,     MIGRATE_RESERVE,   MIGRATE_RESERVE }, /* Never used */
 };
 
 /*
@@ -814,9 +808,7 @@ static struct page *__rmqueue_fallback(s
 	int current_order;
 	struct page *page;
 	int migratetype, i;
-	int nonatomic_fallback_atomic = 0;
 
-retry:
 	/* Find the largest possible block of pages in the other list */
 	for (current_order = MAX_ORDER-1; current_order >= order;
 						--current_order) {
@@ -826,14 +818,6 @@ retry:
 			/* MIGRATE_RESERVE handled later if necessary */
 			if (migratetype == MIGRATE_RESERVE)
 				continue;
-			/*
-			 * Make it hard to fallback to blocks used for
-			 * high-order atomic allocations
-			 */
-			if (migratetype == MIGRATE_HIGHATOMIC &&
-				start_migratetype != MIGRATE_UNMOVABLE &&
-				!nonatomic_fallback_atomic)
-				continue;
 
 			area = &(zone->free_area[current_order]);
 			if (list_empty(&area->free_list[migratetype]))
@@ -859,8 +843,7 @@ retry:
 								start_migratetype);
 
 				/* Claim the whole block if over half of it is free */
-				if ((pages << current_order) >= (1 << (MAX_ORDER-2)) &&
-						migratetype != MIGRATE_HIGHATOMIC)
+				if ((pages << current_order) >= (1 << (MAX_ORDER-2)))
 					set_pageblock_migratetype(page,
 								start_migratetype);
 
@@ -882,12 +865,6 @@ retry:
 		}
 	}
 
-	/* Allow fallback to high-order atomic blocks if memory is that low */
-	if (!nonatomic_fallback_atomic) {
-		nonatomic_fallback_atomic = 1;
-		goto retry;
-	}
-
 	/* Use MIGRATE_RESERVE rather than fail an allocation */
 	return __rmqueue_smallest(zone, order, MIGRATE_RESERVE);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
