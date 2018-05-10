Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id E99E16B0622
	for <linux-mm@kvack.org>; Thu, 10 May 2018 11:58:37 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id a14-v6so1429928plt.7
        for <linux-mm@kvack.org>; Thu, 10 May 2018 08:58:37 -0700 (PDT)
Received: from dev31.localdomain ([103.244.59.4])
        by mx.google.com with ESMTP id t76-v6si929899pgc.627.2018.05.10.08.58.36
        for <linux-mm@kvack.org>;
        Thu, 10 May 2018 08:58:36 -0700 (PDT)
From: Huaisheng Ye <yehs1@lenovo.com>
Subject: [PATCH v1] include/linux/gfp.h: getting rid of GFP_ZONE_TABLE/BAD
Date: Fri, 11 May 2018 00:10:25 +0800
Message-Id: <1525968625-40825-1-git-send-email-yehs1@lenovo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: mhocko@suse.com, willy@infradead.org, vbabka@suse.cz, mgorman@techsingularity.net, alexander.levin@verizon.com, colyli@suse.de, chengnt@lenovo.com, linux-kernel@vger.kernel.org, Huaisheng Ye <yehs1@lenovo.com>

Replace GFP_ZONE_TABLE and GFP_ZONE_BAD with encoded zone
number.

Delete ___GFP_DMA, ___GFP_HIGHMEM and ___GFP_DMA32 from GFP bitmasks,
the bottom three bits of GFP mask is reserved for storing encoded
zone number.

The encoding method is XOR. Get zone number from enum zone_type,
then encode the number with ZONE_NORMAL by XOR operation.
The goal is to make sure ZONE_NORMAL can be encoded to zero. So,
the compatibility can be guaranteed, such as GFP_KERNEL and GFP_ATOMIC
can be used as before.

Reserve __GFP_MOVABLE in bit 3, so that it can continue to be used as
a flag. Same as before, __GFP_MOVABLE respresents movable migrate type
for ZONE_DMA, ZONE_DMA32, and ZONE_NORMAL. But when it is enabled with
__GFP_HIGHMEM, ZONE_MOVABLE shall be returned instead of ZONE_HIGHMEM.

Decode zone number within gfp_zone, firstly decode its number with
bottom three bits of flags. Then, return correct zone_type according
to flag movable if zone type is larger than OPT_ZONE_HIGHMEM.

The theory of encoding and decoding is,
	A ^ B ^ B = A

Suggested-by: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
---
 include/linux/gfp.h | 94 +++++++----------------------------------------------
 1 file changed, 11 insertions(+), 83 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 1a4582b..578cef7 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -16,9 +16,7 @@
  */
 
 /* Plain integer GFP bitmasks. Do not use this directly. */
-#define ___GFP_DMA		0x01u
-#define ___GFP_HIGHMEM		0x02u
-#define ___GFP_DMA32		0x04u
+#define ___GFP_ZONE_MASK	0x07u
 #define ___GFP_MOVABLE		0x08u
 #define ___GFP_RECLAIMABLE	0x10u
 #define ___GFP_HIGH		0x20u
@@ -53,11 +51,11 @@
  * without the underscores and use them consistently. The definitions here may
  * be used in bit comparisons.
  */
-#define __GFP_DMA	((__force gfp_t)___GFP_DMA)
-#define __GFP_HIGHMEM	((__force gfp_t)___GFP_HIGHMEM)
-#define __GFP_DMA32	((__force gfp_t)___GFP_DMA32)
+#define __GFP_DMA	((__force gfp_t)OPT_ZONE_DMA ^ ZONE_NORMAL)
+#define __GFP_HIGHMEM	((__force gfp_t)ZONE_MOVABLE ^ ZONE_NORMAL)
+#define __GFP_DMA32	((__force gfp_t)OPT_ZONE_DMA32 ^ ZONE_NORMAL)
 #define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE)  /* ZONE_MOVABLE allowed */
-#define GFP_ZONEMASK	(__GFP_DMA|__GFP_HIGHMEM|__GFP_DMA32|__GFP_MOVABLE)
+#define GFP_ZONEMASK	((__force gfp_t)___GFP_ZONE_MASK | ___GFP_MOVABLE)
 
 /*
  * Page mobility and placement hints
@@ -326,86 +324,16 @@ static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
 #define OPT_ZONE_DMA32 ZONE_NORMAL
 #endif
 
-/*
- * GFP_ZONE_TABLE is a word size bitstring that is used for looking up the
- * zone to use given the lowest 4 bits of gfp_t. Entries are GFP_ZONES_SHIFT
- * bits long and there are 16 of them to cover all possible combinations of
- * __GFP_DMA, __GFP_DMA32, __GFP_MOVABLE and __GFP_HIGHMEM.
- *
- * The zone fallback order is MOVABLE=>HIGHMEM=>NORMAL=>DMA32=>DMA.
- * But GFP_MOVABLE is not only a zone specifier but also an allocation
- * policy. Therefore __GFP_MOVABLE plus another zone selector is valid.
- * Only 1 bit of the lowest 3 bits (DMA,DMA32,HIGHMEM) can be set to "1".
- *
- *       bit       result
- *       =================
- *       0x0    => NORMAL
- *       0x1    => DMA or NORMAL
- *       0x2    => HIGHMEM or NORMAL
- *       0x3    => BAD (DMA+HIGHMEM)
- *       0x4    => DMA32 or DMA or NORMAL
- *       0x5    => BAD (DMA+DMA32)
- *       0x6    => BAD (HIGHMEM+DMA32)
- *       0x7    => BAD (HIGHMEM+DMA32+DMA)
- *       0x8    => NORMAL (MOVABLE+0)
- *       0x9    => DMA or NORMAL (MOVABLE+DMA)
- *       0xa    => MOVABLE (Movable is valid only if HIGHMEM is set too)
- *       0xb    => BAD (MOVABLE+HIGHMEM+DMA)
- *       0xc    => DMA32 (MOVABLE+DMA32)
- *       0xd    => BAD (MOVABLE+DMA32+DMA)
- *       0xe    => BAD (MOVABLE+DMA32+HIGHMEM)
- *       0xf    => BAD (MOVABLE+DMA32+HIGHMEM+DMA)
- *
- * GFP_ZONES_SHIFT must be <= 2 on 32 bit platforms.
- */
-
-#if defined(CONFIG_ZONE_DEVICE) && (MAX_NR_ZONES-1) <= 4
-/* ZONE_DEVICE is not a valid GFP zone specifier */
-#define GFP_ZONES_SHIFT 2
-#else
-#define GFP_ZONES_SHIFT ZONES_SHIFT
-#endif
-
-#if 16 * GFP_ZONES_SHIFT > BITS_PER_LONG
-#error GFP_ZONES_SHIFT too large to create GFP_ZONE_TABLE integer
-#endif
-
-#define GFP_ZONE_TABLE ( \
-	(ZONE_NORMAL << 0 * GFP_ZONES_SHIFT)				       \
-	| (OPT_ZONE_DMA << ___GFP_DMA * GFP_ZONES_SHIFT)		       \
-	| (OPT_ZONE_HIGHMEM << ___GFP_HIGHMEM * GFP_ZONES_SHIFT)	       \
-	| (OPT_ZONE_DMA32 << ___GFP_DMA32 * GFP_ZONES_SHIFT)		       \
-	| (ZONE_NORMAL << ___GFP_MOVABLE * GFP_ZONES_SHIFT)		       \
-	| (OPT_ZONE_DMA << (___GFP_MOVABLE | ___GFP_DMA) * GFP_ZONES_SHIFT)    \
-	| (ZONE_MOVABLE << (___GFP_MOVABLE | ___GFP_HIGHMEM) * GFP_ZONES_SHIFT)\
-	| (OPT_ZONE_DMA32 << (___GFP_MOVABLE | ___GFP_DMA32) * GFP_ZONES_SHIFT)\
-)
-
-/*
- * GFP_ZONE_BAD is a bitmap for all combinations of __GFP_DMA, __GFP_DMA32
- * __GFP_HIGHMEM and __GFP_MOVABLE that are not permitted. One flag per
- * entry starting with bit 0. Bit is set if the combination is not
- * allowed.
- */
-#define GFP_ZONE_BAD ( \
-	1 << (___GFP_DMA | ___GFP_HIGHMEM)				      \
-	| 1 << (___GFP_DMA | ___GFP_DMA32)				      \
-	| 1 << (___GFP_DMA32 | ___GFP_HIGHMEM)				      \
-	| 1 << (___GFP_DMA | ___GFP_DMA32 | ___GFP_HIGHMEM)		      \
-	| 1 << (___GFP_MOVABLE | ___GFP_HIGHMEM | ___GFP_DMA)		      \
-	| 1 << (___GFP_MOVABLE | ___GFP_DMA32 | ___GFP_DMA)		      \
-	| 1 << (___GFP_MOVABLE | ___GFP_DMA32 | ___GFP_HIGHMEM)		      \
-	| 1 << (___GFP_MOVABLE | ___GFP_DMA32 | ___GFP_DMA | ___GFP_HIGHMEM)  \
-)
-
 static inline enum zone_type gfp_zone(gfp_t flags)
 {
 	enum zone_type z;
-	int bit = (__force int) (flags & GFP_ZONEMASK);
+	z = ((__force unsigned int)flags & ___GFP_ZONE_MASK) ^ ZONE_NORMAL;
+
+	if (z > OPT_ZONE_HIGHMEM)
+		z = OPT_ZONE_HIGHMEM +
+			!!((__force unsigned int)flags & ___GFP_MOVABLE);
 
-	z = (GFP_ZONE_TABLE >> (bit * GFP_ZONES_SHIFT)) &
-					 ((1 << GFP_ZONES_SHIFT) - 1);
-	VM_BUG_ON((GFP_ZONE_BAD >> bit) & 1);
+	VM_BUG_ON(z > ZONE_MOVABLE);
 	return z;
 }
 
-- 
1.8.3.1
