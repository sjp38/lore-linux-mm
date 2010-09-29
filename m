Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D66526B0047
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 03:06:12 -0400 (EDT)
Received: by pzk26 with SMTP id 26so129835pzk.14
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 00:06:09 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH v2] mm: fix sparse warnings on GFP_ZONE_TABLE/BAD
Date: Wed, 29 Sep 2010 16:06:01 +0900
Message-Id: <1285743961-12432-1-git-send-email-namhyung@gmail.com>
In-Reply-To: <20100928221546.GI19804@ZenIV.linux.org.uk>
References: <20100928221546.GI19804@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Introduce ___GFP_* masks in order for gfp_t not to mixed with
plain integers which causes a lot of warnings like following:

 warning: restricted gfp_t degrades to integer

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 include/linux/gfp.h |  105 ++++++++++++++++++++++++++++++--------------------
 1 files changed, 63 insertions(+), 42 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 975609c..e8713d5 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -9,6 +9,32 @@
 
 struct vm_area_struct;
 
+/* Plain integer GFP bitmasks. Do not use this directly. */
+#define ___GFP_DMA		0x01u
+#define ___GFP_HIGHMEM		0x02u
+#define ___GFP_DMA32		0x04u
+#define ___GFP_MOVABLE		0x08u
+#define ___GFP_WAIT		0x10u
+#define ___GFP_HIGH		0x20u
+#define ___GFP_IO		0x40u
+#define ___GFP_FS		0x80u
+#define ___GFP_COLD		0x100u
+#define ___GFP_NOWARN		0x200u
+#define ___GFP_REPEAT		0x400u
+#define ___GFP_NOFAIL		0x800u
+#define ___GFP_NORETRY		0x1000u
+#define ___GFP_COMP		0x4000u
+#define ___GFP_ZERO		0x8000u
+#define ___GFP_NOMEMALLOC	0x10000u
+#define ___GFP_HARDWALL		0x20000u
+#define ___GFP_THISNODE		0x40000u
+#define ___GFP_RECLAIMABLE	0x80000u
+#ifdef CONFIG_KMEMCHECK
+#define ___GFP_NOTRACK		0x200000u
+#else
+#define ___GFP_NOTRACK		0
+#endif
+
 /*
  * GFP bitmasks..
  *
@@ -18,10 +44,10 @@ struct vm_area_struct;
  * without the underscores and use them consistently. The definitions here may
  * be used in bit comparisons.
  */
-#define __GFP_DMA	((__force gfp_t)0x01u)
-#define __GFP_HIGHMEM	((__force gfp_t)0x02u)
-#define __GFP_DMA32	((__force gfp_t)0x04u)
-#define __GFP_MOVABLE	((__force gfp_t)0x08u)  /* Page is movable */
+#define __GFP_DMA	((__force gfp_t)___GFP_DMA)
+#define __GFP_HIGHMEM	((__force gfp_t)___GFP_HIGHMEM)
+#define __GFP_DMA32	((__force gfp_t)___GFP_DMA32)
+#define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE)  /* Page is movable */
 #define GFP_ZONEMASK	(__GFP_DMA|__GFP_HIGHMEM|__GFP_DMA32|__GFP_MOVABLE)
 /*
  * Action modifiers - doesn't change the zoning
@@ -38,27 +64,22 @@ struct vm_area_struct;
  * __GFP_MOVABLE: Flag that this page will be movable by the page migration
  * mechanism or reclaimed
  */
-#define __GFP_WAIT	((__force gfp_t)0x10u)	/* Can wait and reschedule? */
-#define __GFP_HIGH	((__force gfp_t)0x20u)	/* Should access emergency pools? */
-#define __GFP_IO	((__force gfp_t)0x40u)	/* Can start physical IO? */
-#define __GFP_FS	((__force gfp_t)0x80u)	/* Can call down to low-level FS? */
-#define __GFP_COLD	((__force gfp_t)0x100u)	/* Cache-cold page required */
-#define __GFP_NOWARN	((__force gfp_t)0x200u)	/* Suppress page allocation failure warning */
-#define __GFP_REPEAT	((__force gfp_t)0x400u)	/* See above */
-#define __GFP_NOFAIL	((__force gfp_t)0x800u)	/* See above */
-#define __GFP_NORETRY	((__force gfp_t)0x1000u)/* See above */
-#define __GFP_COMP	((__force gfp_t)0x4000u)/* Add compound page metadata */
-#define __GFP_ZERO	((__force gfp_t)0x8000u)/* Return zeroed page on success */
-#define __GFP_NOMEMALLOC ((__force gfp_t)0x10000u) /* Don't use emergency reserves */
-#define __GFP_HARDWALL   ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
-#define __GFP_THISNODE	((__force gfp_t)0x40000u)/* No fallback, no policies */
-#define __GFP_RECLAIMABLE ((__force gfp_t)0x80000u) /* Page is reclaimable */
-
-#ifdef CONFIG_KMEMCHECK
-#define __GFP_NOTRACK	((__force gfp_t)0x200000u)  /* Don't track with kmemcheck */
-#else
-#define __GFP_NOTRACK	((__force gfp_t)0)
-#endif
+#define __GFP_WAIT	((__force gfp_t)___GFP_WAIT)	/* Can wait and reschedule? */
+#define __GFP_HIGH	((__force gfp_t)___GFP_HIGH)	/* Should access emergency pools? */
+#define __GFP_IO	((__force gfp_t)___GFP_IO)	/* Can start physical IO? */
+#define __GFP_FS	((__force gfp_t)___GFP_FS)	/* Can call down to low-level FS? */
+#define __GFP_COLD	((__force gfp_t)___GFP_COLD)	/* Cache-cold page required */
+#define __GFP_NOWARN	((__force gfp_t)___GFP_NOWARN)	/* Suppress page allocation failure warning */
+#define __GFP_REPEAT	((__force gfp_t)___GFP_REPEAT)	/* See above */
+#define __GFP_NOFAIL	((__force gfp_t)___GFP_NOFAIL)	/* See above */
+#define __GFP_NORETRY	((__force gfp_t)___GFP_NORETRY) /* See above */
+#define __GFP_COMP	((__force gfp_t)___GFP_COMP)	/* Add compound page metadata */
+#define __GFP_ZERO	((__force gfp_t)___GFP_ZERO)	/* Return zeroed page on success */
+#define __GFP_NOMEMALLOC ((__force gfp_t)___GFP_NOMEMALLOC) /* Don't use emergency reserves */
+#define __GFP_HARDWALL   ((__force gfp_t)___GFP_HARDWALL) /* Enforce hardwall cpuset memory allocs */
+#define __GFP_THISNODE	((__force gfp_t)___GFP_THISNODE)/* No fallback, no policies */
+#define __GFP_RECLAIMABLE ((__force gfp_t)___GFP_RECLAIMABLE) /* Page is reclaimable */
+#define __GFP_NOTRACK	((__force gfp_t)___GFP_NOTRACK)  /* Don't track with kmemcheck */
 
 /*
  * This may seem redundant, but it's a way of annotating false positives vs.
@@ -186,14 +207,14 @@ static inline int allocflags_to_migratetype(gfp_t gfp_flags)
 #endif
 
 #define GFP_ZONE_TABLE ( \
-	(ZONE_NORMAL << 0 * ZONES_SHIFT)				\
-	| (OPT_ZONE_DMA << __GFP_DMA * ZONES_SHIFT)			\
-	| (OPT_ZONE_HIGHMEM << __GFP_HIGHMEM * ZONES_SHIFT)		\
-	| (OPT_ZONE_DMA32 << __GFP_DMA32 * ZONES_SHIFT)			\
-	| (ZONE_NORMAL << __GFP_MOVABLE * ZONES_SHIFT)			\
-	| (OPT_ZONE_DMA << (__GFP_MOVABLE | __GFP_DMA) * ZONES_SHIFT)	\
-	| (ZONE_MOVABLE << (__GFP_MOVABLE | __GFP_HIGHMEM) * ZONES_SHIFT)\
-	| (OPT_ZONE_DMA32 << (__GFP_MOVABLE | __GFP_DMA32) * ZONES_SHIFT)\
+	(ZONE_NORMAL << 0 * ZONES_SHIFT)				      \
+	| (OPT_ZONE_DMA << ___GFP_DMA * ZONES_SHIFT)			      \
+	| (OPT_ZONE_HIGHMEM << ___GFP_HIGHMEM * ZONES_SHIFT)		      \
+	| (OPT_ZONE_DMA32 << ___GFP_DMA32 * ZONES_SHIFT)		      \
+	| (ZONE_NORMAL << ___GFP_MOVABLE * ZONES_SHIFT)			      \
+	| (OPT_ZONE_DMA << (___GFP_MOVABLE | ___GFP_DMA) * ZONES_SHIFT)	      \
+	| (ZONE_MOVABLE << (___GFP_MOVABLE | ___GFP_HIGHMEM) * ZONES_SHIFT)   \
+	| (OPT_ZONE_DMA32 << (___GFP_MOVABLE | ___GFP_DMA32) * ZONES_SHIFT)   \
 )
 
 /*
@@ -203,20 +224,20 @@ static inline int allocflags_to_migratetype(gfp_t gfp_flags)
  * allowed.
  */
 #define GFP_ZONE_BAD ( \
-	1 << (__GFP_DMA | __GFP_HIGHMEM)				\
-	| 1 << (__GFP_DMA | __GFP_DMA32)				\
-	| 1 << (__GFP_DMA32 | __GFP_HIGHMEM)				\
-	| 1 << (__GFP_DMA | __GFP_DMA32 | __GFP_HIGHMEM)		\
-	| 1 << (__GFP_MOVABLE | __GFP_HIGHMEM | __GFP_DMA)		\
-	| 1 << (__GFP_MOVABLE | __GFP_DMA32 | __GFP_DMA)		\
-	| 1 << (__GFP_MOVABLE | __GFP_DMA32 | __GFP_HIGHMEM)		\
-	| 1 << (__GFP_MOVABLE | __GFP_DMA32 | __GFP_DMA | __GFP_HIGHMEM)\
+	1 << (___GFP_DMA | ___GFP_HIGHMEM)				      \
+	| 1 << (___GFP_DMA | ___GFP_DMA32)				      \
+	| 1 << (___GFP_DMA32 | ___GFP_HIGHMEM)				      \
+	| 1 << (___GFP_DMA | ___GFP_DMA32 | ___GFP_HIGHMEM)		      \
+	| 1 << (___GFP_MOVABLE | ___GFP_HIGHMEM | ___GFP_DMA)		      \
+	| 1 << (___GFP_MOVABLE | ___GFP_DMA32 | ___GFP_DMA)		      \
+	| 1 << (___GFP_MOVABLE | ___GFP_DMA32 | ___GFP_HIGHMEM)		      \
+	| 1 << (___GFP_MOVABLE | ___GFP_DMA32 | ___GFP_DMA | ___GFP_HIGHMEM)  \
 )
 
 static inline enum zone_type gfp_zone(gfp_t flags)
 {
 	enum zone_type z;
-	int bit = flags & GFP_ZONEMASK;
+	int bit = (__force int) (flags & GFP_ZONEMASK);
 
 	z = (GFP_ZONE_TABLE >> (bit * ZONES_SHIFT)) &
 					 ((1 << ZONES_SHIFT) - 1);
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
