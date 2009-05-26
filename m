Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 462E46B005C
	for <linux-mm@kvack.org>; Tue, 26 May 2009 12:58:02 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0EEB282C895
	for <linux-mm@kvack.org>; Tue, 26 May 2009 13:12:49 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id m7LMtUVLHwvr for <linux-mm@kvack.org>;
	Tue, 26 May 2009 13:12:48 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 545FD82C8F4
	for <linux-mm@kvack.org>; Tue, 26 May 2009 13:12:42 -0400 (EDT)
Date: Tue, 26 May 2009 12:58:34 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] Use integer fields lookup for gfp_zone and check for
 errors in flags passed to the page allocator
In-Reply-To: <20090525105105.b760aba5.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0905261255040.3438@gentwo.org>
References: <alpine.DEB.1.10.0905221438120.5515@qirst.com> <20090525105105.b760aba5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Mon, 25 May 2009, KAMEZAWA Hiroyuki wrote:

> Could you add a comment to explain this as..

Ok. I added your comments and reworked them a bit:



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
 include/linux/gfp.h |  111 ++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 96 insertions(+), 15 deletions(-)

Index: linux-2.6/include/linux/gfp.h
===================================================================
--- linux-2.6.orig/include/linux/gfp.h	2009-05-22 14:03:37.000000000 -0500
+++ linux-2.6/include/linux/gfp.h	2009-05-26 11:56:48.000000000 -0500
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
@@ -112,24 +112,105 @@ static inline int allocflags_to_migratet
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
+#endif
+
+/*
+ * GFP_ZONE_TABLE is a word size bitstring that is used for looking up the
+ * zone to use given the lowest 4 bits of gfp_t. Entries are ZONE_SHIFT long
+ * and there are 16 of them to cover all possible combinations of
+ * __GFP_DMA, __GFP_DMA32, __GFP_MOVABLE and __GFP_HIGHMEM
+ *
+ * The zone fallback order is MOVABLE=>HIGHMEM=>NORMAL=>DMA32=>DMA.
+ * But GFP_MOVABLE is not only a zone specifier but also an allocation
+ * policy. Therefore __GFP_MOVABLE plus another zone selector is valid.
+ * Only 1bit of the lowest 3 bit (DMA,DMA32,HIGHMEM) can be set to "1".
+ *
+ *       bit       result
+ *       =================
+ *       0x0    => NORMAL
+ *       0x1    => DMA or NORMAL
+ *       0x2    => HIGHMEM or NORMAL
+ *       0x3    => BAD (DMA+HIGHMEM)
+ *       0x4    => DMA32 or DMA or NORMAL
+ *       0x5    => BAD (DMA+DMA32)
+ *       0x6    => BAD (HIGHMEM+DMA32)
+ *       0x7    => BAD (HIGHMEM+DMA32+DMA)
+ *       0x8    => NORMAL (MOVABLE+0)
+ *       0x9    => DMA or NORMAL (MOVABLE+DMA)
+ *       0xa    => MOVABLE (Movable is valid only if HIGHMEM is set too)
+ *       0xb    => BAD (MOVABLE+HIGHMEM+DMA)
+ *       0xc    => DMA32 (MOVABLE+HIGHMEM+DMA32)
+ *       0xd    => BAD (MOVABLE+DMA32+DMA)
+ *       0xe    => BAD (MOVABLE+DMA32+HIGHMEM)
+ *       0xf    => BAD (MOVABLE+DMA32+HIGHMEM+DMA)
+ *
+ * ZONES_SHIFT must be <= 2 on 32 bit platforms.
+ */
+
+#if 16 * ZONES_SHIFT > BITS_PER_LONG
+#error ZONES_SHIFT too large to create GFP_ZONE_TABLE integer
 #endif
-	if ((flags & (__GFP_HIGHMEM | __GFP_MOVABLE)) ==
-			(__GFP_HIGHMEM | __GFP_MOVABLE))
-		return ZONE_MOVABLE;
-#ifdef CONFIG_HIGHMEM
-	if (flags & __GFP_HIGHMEM)
-		return ZONE_HIGHMEM;
+
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
