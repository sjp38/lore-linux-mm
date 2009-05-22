Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0EFA36B005C
	for <linux-mm@kvack.org>; Fri, 22 May 2009 14:42:03 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id EFB8582C807
	for <linux-mm@kvack.org>; Fri, 22 May 2009 14:56:17 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id qXDzk7+d8hoM for <linux-mm@kvack.org>;
	Fri, 22 May 2009 14:56:13 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 25FD082C799
	for <linux-mm@kvack.org>; Fri, 22 May 2009 14:56:11 -0400 (EDT)
Date: Fri, 22 May 2009 14:42:32 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [PATCH] Use integer fields lookup for gfp_zone and check for errors
 in flags passed to the page allocator
Message-ID: <alpine.DEB.1.10.0905221438120.5515@qirst.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, npiggin@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


Subject: Use integer fields lookup for gfp_zone and check for errors in flags passed to the page allocator

This simplifies the code in gfp_zone() and also keeps the ability of the
compiler to use constant folding to get rid of gfp_zone processing.

The lookup of the zone is done using a bitfield stored in an integer. So
the code in gfp_zone is a simple extraction of bits from a constant bitfield.
The compiler is generating a load of a constant into a register and then
performs a shift and mask operation to get the zone from a gfp_t.

No cachelines are touched and no branches have to be predicted by the
compiler.

We are doing some macro tricks here to convince the compiler to always do the
constant folding if possible.

Tested on:
i386 (kvm), x86_64(native)

Compile tested on:
s390 arm sparc sparc64 mips ia64

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/gfp.h |   85 ++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 70 insertions(+), 15 deletions(-)

Index: linux-2.6/include/linux/gfp.h
===================================================================
--- linux-2.6.orig/include/linux/gfp.h	2009-04-13 14:04:29.000000000 -0500
+++ linux-2.6/include/linux/gfp.h	2009-04-24 14:21:59.000000000 -0500
@@ -20,7 +20,8 @@ struct vm_area_struct;
 #define __GFP_DMA	((__force gfp_t)0x01u)
 #define __GFP_HIGHMEM	((__force gfp_t)0x02u)
 #define __GFP_DMA32	((__force gfp_t)0x04u)
-
+#define __GFP_MOVABLE	((__force gfp_t)0x08u)  /* Page is movable */
+#define GFP_ZONEMASK	(__GFP_DMA|__GFP_HIGHMEM|__GFP_DMA32|__GFP_MOVABLE)
 /*
  * Action modifiers - doesn't change the zoning
  *
@@ -50,7 +51,6 @@ struct vm_area_struct;
 #define __GFP_HARDWALL   ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
 #define __GFP_THISNODE	((__force gfp_t)0x40000u)/* No fallback, no policies */
 #define __GFP_RECLAIMABLE ((__force gfp_t)0x80000u) /* Page is reclaimable */
-#define __GFP_MOVABLE	((__force gfp_t)0x100000u)  /* Page is movable */

 #define __GFP_BITS_SHIFT 21	/* Room for 21 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
@@ -112,24 +112,79 @@ static inline int allocflags_to_migratet
 		((gfp_flags & __GFP_RECLAIMABLE) != 0);
 }

-static inline enum zone_type gfp_zone(gfp_t flags)
-{
+#ifdef CONFIG_ZONE_HIGHMEM
+#define OPT_ZONE_HIGHMEM ZONE_HIGHMEM
+#else
+#define OPT_ZONE_HIGHMEM ZONE_NORMAL
+#endif
+
 #ifdef CONFIG_ZONE_DMA
-	if (flags & __GFP_DMA)
-		return ZONE_DMA;
+#define OPT_ZONE_DMA ZONE_DMA
+#else
+#define OPT_ZONE_DMA ZONE_NORMAL
 #endif
+
 #ifdef CONFIG_ZONE_DMA32
-	if (flags & __GFP_DMA32)
-		return ZONE_DMA32;
+#define OPT_ZONE_DMA32 ZONE_DMA32
+#else
+#define OPT_ZONE_DMA32 OPT_ZONE_DMA
 #endif
-	if ((flags & (__GFP_HIGHMEM | __GFP_MOVABLE)) ==
-			(__GFP_HIGHMEM | __GFP_MOVABLE))
-		return ZONE_MOVABLE;
-#ifdef CONFIG_HIGHMEM
-	if (flags & __GFP_HIGHMEM)
-		return ZONE_HIGHMEM;
+
+#if 16 * ZONES_SHIFT > BITS_PER_LONG
+#error ZONES_SHIFT too large to create GFP_ZONE_TABLE integer
+#endif
+
+/*
+ * GFP_ZONE_TABLE is a word size bitstring that is used for looking up the
+ * zone to use given the lowest 4 bits of gfp_t. Entries are ZONE_SHIFT long
+ * and there are 16 of them to cover all possible combinations of
+ * __GFP_DMA, __GFP_DMA32, __GFP_MOVABLE and __GFP_HIGHMEM
+ *
+ */
+#define GFP_ZONE_TABLE ( \
+	(ZONE_NORMAL << 0 * ZONES_SHIFT)				\
+	| (OPT_ZONE_DMA << __GFP_DMA * ZONES_SHIFT) 			\
+	| (OPT_ZONE_HIGHMEM << __GFP_HIGHMEM * ZONES_SHIFT)		\
+	| (OPT_ZONE_DMA32 << __GFP_DMA32 * ZONES_SHIFT)			\
+	| (ZONE_NORMAL << __GFP_MOVABLE * ZONES_SHIFT)			\
+	| (OPT_ZONE_DMA << (__GFP_MOVABLE | __GFP_DMA) * ZONES_SHIFT)	\
+	| (ZONE_MOVABLE << (__GFP_MOVABLE | __GFP_HIGHMEM) * ZONES_SHIFT)\
+	| (OPT_ZONE_DMA32 << (__GFP_MOVABLE | __GFP_DMA32) * ZONES_SHIFT)\
+)
+
+/*
+ * GFP_ZONE_BAD is a bitmap for all combination of __GFP_DMA, __GFP_DMA32
+ * __GFP_HIGHMEM and __GFP_MOVABLE that are not permitted. One flag per
+ * entry starting with bit 0. Bit is set if the combination is not
+ * allowed.
+ */
+#define GFP_ZONE_BAD ( \
+	1 << (__GFP_DMA | __GFP_HIGHMEM)				\
+	| 1 << (__GFP_DMA | __GFP_DMA32)				\
+	| 1 << (__GFP_DMA32 | __GFP_HIGHMEM)				\
+	| 1 << (__GFP_DMA | __GFP_DMA32 | __GFP_HIGHMEM)		\
+	| 1 << (__GFP_MOVABLE | __GFP_HIGHMEM | __GFP_DMA)		\
+	| 1 << (__GFP_MOVABLE | __GFP_DMA32 | __GFP_DMA)		\
+	| 1 << (__GFP_MOVABLE | __GFP_DMA32 | __GFP_HIGHMEM)		\
+	| 1 << (__GFP_MOVABLE | __GFP_DMA32 | __GFP_DMA | __GFP_HIGHMEM)\
+)
+
+static inline enum zone_type gfp_zone(gfp_t flags)
+{
+	enum zone_type z;
+	int bit = flags & GFP_ZONEMASK;
+
+	z = (GFP_ZONE_TABLE >> (bit * ZONES_SHIFT)) &
+					 ((1 << ZONES_SHIFT) - 1);
+
+	if (__builtin_constant_p(bit))
+		BUILD_BUG_ON((GFP_ZONE_BAD >> bit) & 1);
+	else {
+#ifdef CONFIG_DEBUG_VM
+		BUG_ON((GFP_ZONE_BAD >> bit) & 1);
 #endif
-	return ZONE_NORMAL;
+	}
+	return z;
 }

 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
