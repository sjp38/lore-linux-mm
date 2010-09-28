Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2CDA66B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 08:23:56 -0400 (EDT)
Received: by pwj6 with SMTP id 6so2345497pwj.14
        for <linux-mm@kvack.org>; Tue, 28 Sep 2010 05:23:56 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH] mm: cleanup gfp_zone()
Date: Tue, 28 Sep 2010 21:23:44 +0900
Message-Id: <1285676624-1300-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Use Z[TB]_SHIFT() macro to calculate GFP_ZONE_TABLE and GFP_ZONE_BAD.
This also removes lots of warnings from sparse like following:

 warning: restricted gfp_t degrades to integer

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 include/linux/gfp.h |   43 ++++++++++++++++++++++++-------------------
 1 files changed, 24 insertions(+), 19 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 975609c..cebfee1 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -185,15 +185,16 @@ static inline int allocflags_to_migratetype(gfp_t gfp_flags)
 #error ZONES_SHIFT too large to create GFP_ZONE_TABLE integer
 #endif
 
+#define ZT_SHIFT(gfp) ((__force int) (gfp) * ZONES_SHIFT)
 #define GFP_ZONE_TABLE ( \
-	(ZONE_NORMAL << 0 * ZONES_SHIFT)				\
-	| (OPT_ZONE_DMA << __GFP_DMA * ZONES_SHIFT)			\
-	| (OPT_ZONE_HIGHMEM << __GFP_HIGHMEM * ZONES_SHIFT)		\
-	| (OPT_ZONE_DMA32 << __GFP_DMA32 * ZONES_SHIFT)			\
-	| (ZONE_NORMAL << __GFP_MOVABLE * ZONES_SHIFT)			\
-	| (OPT_ZONE_DMA << (__GFP_MOVABLE | __GFP_DMA) * ZONES_SHIFT)	\
-	| (ZONE_MOVABLE << (__GFP_MOVABLE | __GFP_HIGHMEM) * ZONES_SHIFT)\
-	| (OPT_ZONE_DMA32 << (__GFP_MOVABLE | __GFP_DMA32) * ZONES_SHIFT)\
+	(ZONE_NORMAL        << ZT_SHIFT(0))				\
+	| (OPT_ZONE_DMA     << ZT_SHIFT(__GFP_DMA))			\
+	| (OPT_ZONE_HIGHMEM << ZT_SHIFT(__GFP_HIGHMEM))			\
+	| (OPT_ZONE_DMA32   << ZT_SHIFT(__GFP_DMA32))			\
+	| (ZONE_NORMAL      << ZT_SHIFT(__GFP_MOVABLE))			\
+	| (OPT_ZONE_DMA     << ZT_SHIFT(__GFP_MOVABLE | __GFP_DMA))	\
+	| (ZONE_MOVABLE     << ZT_SHIFT(__GFP_MOVABLE | __GFP_HIGHMEM)) \
+	| (OPT_ZONE_DMA32   << ZT_SHIFT(__GFP_MOVABLE | __GFP_DMA32))	\
 )
 
 /*
@@ -202,24 +203,25 @@ static inline int allocflags_to_migratetype(gfp_t gfp_flags)
  * entry starting with bit 0. Bit is set if the combination is not
  * allowed.
  */
+#define ZB_SHIFT(gfp) ((__force int) (gfp))
 #define GFP_ZONE_BAD ( \
-	1 << (__GFP_DMA | __GFP_HIGHMEM)				\
-	| 1 << (__GFP_DMA | __GFP_DMA32)				\
-	| 1 << (__GFP_DMA32 | __GFP_HIGHMEM)				\
-	| 1 << (__GFP_DMA | __GFP_DMA32 | __GFP_HIGHMEM)		\
-	| 1 << (__GFP_MOVABLE | __GFP_HIGHMEM | __GFP_DMA)		\
-	| 1 << (__GFP_MOVABLE | __GFP_DMA32 | __GFP_DMA)		\
-	| 1 << (__GFP_MOVABLE | __GFP_DMA32 | __GFP_HIGHMEM)		\
-	| 1 << (__GFP_MOVABLE | __GFP_DMA32 | __GFP_DMA | __GFP_HIGHMEM)\
+	1   << ZB_SHIFT(__GFP_DMA | __GFP_HIGHMEM)			\
+	| 1 << ZB_SHIFT(__GFP_DMA | __GFP_DMA32)			\
+	| 1 << ZB_SHIFT(__GFP_DMA32 | __GFP_HIGHMEM)			\
+	| 1 << ZB_SHIFT(__GFP_DMA | __GFP_DMA32 | __GFP_HIGHMEM)	\
+	| 1 << ZB_SHIFT(__GFP_MOVABLE | __GFP_HIGHMEM | __GFP_DMA)	\
+	| 1 << ZB_SHIFT(__GFP_MOVABLE | __GFP_DMA32 | __GFP_DMA)	\
+	| 1 << ZB_SHIFT(__GFP_MOVABLE | __GFP_DMA32 | __GFP_HIGHMEM)	\
+	| 1 << ZB_SHIFT(__GFP_MOVABLE | __GFP_DMA32 | __GFP_DMA |	\
+			__GFP_HIGHMEM)					\
 )
 
 static inline enum zone_type gfp_zone(gfp_t flags)
 {
 	enum zone_type z;
-	int bit = flags & GFP_ZONEMASK;
+	int bit = (__force int) (flags & GFP_ZONEMASK);
 
-	z = (GFP_ZONE_TABLE >> (bit * ZONES_SHIFT)) &
-					 ((1 << ZONES_SHIFT) - 1);
+	z = (GFP_ZONE_TABLE >> ZT_SHIFT(bit)) & ((1 << ZONES_SHIFT) - 1);
 
 	if (__builtin_constant_p(bit))
 		MAYBE_BUILD_BUG_ON((GFP_ZONE_BAD >> bit) & 1);
@@ -231,6 +233,9 @@ static inline enum zone_type gfp_zone(gfp_t flags)
 	return z;
 }
 
+#undef ZT_SHIFT
+#undef ZB_SHIFT
+
 /*
  * There is only one page-allocator function, and two main namespaces to
  * it. The alloc_page*() variants return 'struct page *' and as such
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
