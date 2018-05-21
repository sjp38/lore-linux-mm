Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Huaisheng Ye <yehs2007@gmail.com>
Subject: [RFC PATCH v2 01/12] include/linux/gfp.h: get rid of GFP_ZONE_TABLE/BAD
Date: Mon, 21 May 2018 23:20:22 +0800
Message-Id: <1526916033-4877-2-git-send-email-yehs2007@gmail.com>
In-Reply-To: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
References: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: mhocko@suse.com, willy@infradead.org, vbabka@suse.cz, mgorman@techsingularity.net, kstewart@linuxfoundation.org, alexander.levin@verizon.com, gregkh@linuxfoundation.org, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-btrfs@vger.kernel.org, Huaisheng Ye <yehs1@lenovo.com>
List-ID: <linux-mm.kvack.org>

From: Huaisheng Ye <yehs1@lenovo.com>

Replace GFP_ZONE_TABLE and GFP_ZONE_BAD with encoded zone number.

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
__GFP_ZONE_MOVABLE is created to realize it.

With this patch, just enabling __GFP_MOVABLE and __GFP_HIGHMEM is not
enough to get ZONE_MOVABLE from gfp_zone. All subsystems should use
GFP_HIGHUSER_MOVABLE directly to achieve that.

Decode zone number directly from bottom three bits of flags in gfp_zone.
The theory of encoding and decoding is,
        A ^ B ^ B = A

Suggested-by: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Kate Stewart <kstewart@linuxfoundation.org>
Cc: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 include/linux/gfp.h | 98 ++++++-----------------------------------------------
 1 file changed, 11 insertions(+), 87 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 1a4582b..ab0fb7f 100644
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
@@ -53,11 +51,15 @@
  * without the underscores and use them consistently. The definitions here may
  * be used in bit comparisons.
  */
-#define __GFP_DMA	((__force gfp_t)___GFP_DMA)
-#define __GFP_HIGHMEM	((__force gfp_t)___GFP_HIGHMEM)
-#define __GFP_DMA32	((__force gfp_t)___GFP_DMA32)
+#define __GFP_DMA	((__force gfp_t)OPT_ZONE_DMA ^ ZONE_NORMAL)
+#define __GFP_HIGHMEM	((__force gfp_t)OPT_ZONE_HIGHMEM ^ ZONE_NORMAL)
+#define __GFP_DMA32	((__force gfp_t)OPT_ZONE_DMA32 ^ ZONE_NORMAL)
 #define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE)  /* ZONE_MOVABLE allowed */
-#define GFP_ZONEMASK	(__GFP_DMA|__GFP_HIGHMEM|__GFP_DMA32|__GFP_MOVABLE)
+#define GFP_ZONEMASK	((__force gfp_t)___GFP_ZONE_MASK | ___GFP_MOVABLE)
+/* bottom 3 bits of GFP bitmasks are used for zone number encoded*/
+#define __GFP_ZONE_MASK ((__force gfp_t)___GFP_ZONE_MASK)
+#define __GFP_ZONE_MOVABLE	\
+		((__force gfp_t)(ZONE_MOVABLE ^ ZONE_NORMAL) | ___GFP_MOVABLE)
 
 /*
  * Page mobility and placement hints
@@ -279,7 +281,7 @@
 #define GFP_DMA		__GFP_DMA
 #define GFP_DMA32	__GFP_DMA32
 #define GFP_HIGHUSER	(GFP_USER | __GFP_HIGHMEM)
-#define GFP_HIGHUSER_MOVABLE	(GFP_HIGHUSER | __GFP_MOVABLE)
+#define GFP_HIGHUSER_MOVABLE	(GFP_USER | __GFP_ZONE_MOVABLE)
 #define GFP_TRANSHUGE_LIGHT	((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
 			 __GFP_NOMEMALLOC | __GFP_NOWARN) & ~__GFP_RECLAIM)
 #define GFP_TRANSHUGE	(GFP_TRANSHUGE_LIGHT | __GFP_DIRECT_RECLAIM)
@@ -326,87 +328,9 @@ static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
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
-	enum zone_type z;
-	int bit = (__force int) (flags & GFP_ZONEMASK);
-
-	z = (GFP_ZONE_TABLE >> (bit * GFP_ZONES_SHIFT)) &
-					 ((1 << GFP_ZONES_SHIFT) - 1);
-	VM_BUG_ON((GFP_ZONE_BAD >> bit) & 1);
-	return z;
+	return ((__force unsigned int)flags & __GFP_ZONE_MASK) ^ ZONE_NORMAL;
 }
 
 /*
-- 
1.8.3.1
