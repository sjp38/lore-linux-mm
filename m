Date: Tue, 20 Dec 2005 17:52:08 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch] New zone ZONE_EASY_RECLAIM take 4. (define gfp_easy_relcaim)[1/8]
Message-Id: <20051220172720.1B08.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
Cc: Joel Schopp <jschopp@austin.ibm.com>
List-ID: <linux-mm.kvack.org>

This defines __GFP flag for new zone (with GFP_DMA32).

take3 -> take 4:
  take 3's modification was not enough. 
  __GFP_DMA32 is moved from 0x04 to 0x02 when it has own number
  to make it easier.
  __GFP_HIGHMEM and __GFP_EASY_RECLAIM become fixed value.


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: zone_reclaim/include/linux/gfp.h
===================================================================
--- zone_reclaim.orig/include/linux/gfp.h	2005-12-16 11:28:15.000000000 +0900
+++ zone_reclaim/include/linux/gfp.h	2005-12-19 20:20:51.000000000 +0900
@@ -11,17 +11,21 @@ struct vm_area_struct;
 /*
  * GFP bitmasks..
  */
-/* Zone modifiers in GFP_ZONEMASK (see linux/mmzone.h - low three bits) */
+/* Zone modifiers in GFP_ZONEMASK (see linux/mmzone.h - low four bits) */
 #define __GFP_DMA	((__force gfp_t)0x01u)
-#define __GFP_HIGHMEM	((__force gfp_t)0x02u)
+
 #ifdef CONFIG_DMA_IS_DMA32
 #define __GFP_DMA32	((__force gfp_t)0x01)	/* ZONE_DMA is ZONE_DMA32 */
 #elif BITS_PER_LONG < 64
 #define __GFP_DMA32	((__force gfp_t)0x00)	/* ZONE_NORMAL is ZONE_DMA32 */
 #else
-#define __GFP_DMA32	((__force gfp_t)0x04)	/* Has own ZONE_DMA32 */
+#define __GFP_DMA32	((__force gfp_t)0x02)	/* Has own ZONE_DMA32 */
 #endif
 
+#define __GFP_HIGHMEM	((__force gfp_t)0x04u)
+#define __GFP_EASY_RECLAIM ((__force gfp_t)0x08u)
+
+
 /*
  * Action modifiers - doesn't change the zoning
  *
@@ -64,7 +68,7 @@ struct vm_area_struct;
 #define GFP_KERNEL	(__GFP_WAIT | __GFP_IO | __GFP_FS)
 #define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
 #define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL | \
-			 __GFP_HIGHMEM)
+			 __GFP_HIGHMEM | __GFP_EASY_RECLAIM)
 
 /* Flag - indicates that the buffer will be suitable for DMA.  Ignored on some
    platforms, used as appropriate on others */
Index: zone_reclaim/include/linux/mmzone.h
===================================================================
--- zone_reclaim.orig/include/linux/mmzone.h	2005-12-16 11:28:15.000000000 +0900
+++ zone_reclaim/include/linux/mmzone.h	2005-12-19 20:16:29.000000000 +0900
@@ -93,7 +93,7 @@ struct per_cpu_pageset {
  *
  * NOTE! Make sure this matches the zones in <linux/gfp.h>
  */
-#define GFP_ZONEMASK	0x07
+#define GFP_ZONEMASK	0x0f
 #define GFP_ZONETYPES	5
 
 /*

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
