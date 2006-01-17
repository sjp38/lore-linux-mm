Date: Tue, 17 Jan 2006 15:52:27 +0000
Subject: [PATCH] zone gfp_flags generate from ZONE_ constants
Message-ID: <20060117155227.GA16176@shadowen.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Andy Whitcroft <apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

zone gfp_flags generate from ZONE_ constants

Change the allocation of the __GFP_zone style zone modifiers so that
they are generated from the values of the ZONE_zone definitions.
Note that when no zone modifiers are specified select the default
zone, typically ZONE_NORMAL.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 gfp.h    |   22 ++++++++++++++++------
 mmzone.h |    2 ++
 2 files changed, 18 insertions(+), 6 deletions(-)
diff -upN reference/include/linux/gfp.h current/include/linux/gfp.h
--- reference/include/linux/gfp.h
+++ current/include/linux/gfp.h
@@ -11,15 +11,25 @@ struct vm_area_struct;
 /*
  * GFP bitmasks..
  */
-/* Zone modifiers in GFP_ZONEMASK (see linux/mmzone.h - low three bits) */
-#define __GFP_DMA	((__force gfp_t)0x01u)
-#define __GFP_HIGHMEM	((__force gfp_t)0x02u)
+
+/*
+ * Generate the zone modifier bit.  Zone ZONE_DEFAULT doesn't require a bit
+ * as the absence of all zone modifiers implies this zone.  Renormalise the
+ * zone number such that ZONE_DEFAULT is at the bottom and discard it.
+ * These must fit within the bitmask GFP_ZONEMASK defined in linux/mmzone.h.
+ */
+#define __ZONE_BIT(x) (((x) ^ ZONE_DEFAULT) - 1)
+#define ZONE_MODIFIER(x) ((__force gfp_t)(((x) == ZONE_DEFAULT)? (0) : \
+							1UL << __ZONE_BIT(x)))
+
+#define __GFP_DMA	ZONE_MODIFIER(ZONE_DMA)
+#define __GFP_HIGHMEM	ZONE_MODIFIER(ZONE_HIGHMEM)
 #ifdef CONFIG_DMA_IS_DMA32
-#define __GFP_DMA32	((__force gfp_t)0x01)	/* ZONE_DMA is ZONE_DMA32 */
+#define __GFP_DMA32	ZONE_MODIFIER(ZONE_DMA)	/* ZONE_DMA is ZONE_DMA32 */
 #elif BITS_PER_LONG < 64
-#define __GFP_DMA32	((__force gfp_t)0x00)	/* ZONE_NORMAL is ZONE_DMA32 */
+#define __GFP_DMA32	ZONE_MODIFIER(ZONE_NORMAL) /* ZONE_NORMAL is ZONE_DMA32 */
 #else
-#define __GFP_DMA32	((__force gfp_t)0x04)	/* Has own ZONE_DMA32 */
+#define __GFP_DMA32	ZONE_MODIFIER(ZONE_DMA32) /* Has own ZONE_DMA32 */
 #endif
 
 /*
diff -upN reference/include/linux/mmzone.h current/include/linux/mmzone.h
--- reference/include/linux/mmzone.h
+++ current/include/linux/mmzone.h
@@ -77,6 +77,8 @@ struct per_cpu_pageset {
 #define MAX_NR_ZONES		4	/* Sync this with ZONES_SHIFT */
 #define ZONES_SHIFT		2	/* ceil(log2(MAX_NR_ZONES)) */
 
+/* Select the zone to use when no __GFP flags are selected. */
+#define ZONE_DEFAULT           ZONE_NORMAL
 
 /*
  * When a memory allocation must conform to specific limitations (such

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
