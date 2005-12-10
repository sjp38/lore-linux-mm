Date: Sat, 10 Dec 2005 20:02:42 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch] New zone ZONE_EASY_RECLAIM take 3. (define gfp_easy_relcaim)[1/5]
Message-Id: <20051210193701.4826.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
Cc: Joel Schopp <jschopp@austin.ibm.com>
List-ID: <linux-mm.kvack.org>

This defines __GFP flag for new zone with GFP_DMA32.


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: zone_reclaim/include/linux/gfp.h
===================================================================
--- zone_reclaim.orig/include/linux/gfp.h	2005-12-06 12:07:33.000000000 +0900
+++ zone_reclaim/include/linux/gfp.h	2005-12-06 13:51:33.000000000 +0900
@@ -16,10 +16,13 @@ struct vm_area_struct;
 #define __GFP_HIGHMEM	((__force gfp_t)0x02u)
 #ifdef CONFIG_DMA_IS_DMA32
 #define __GFP_DMA32	((__force gfp_t)0x01)	/* ZONE_DMA is ZONE_DMA32 */
+#define __GFP_EASY_RECLAIM ((__force gfp_t)0x04u)
 #elif BITS_PER_LONG < 64
 #define __GFP_DMA32	((__force gfp_t)0x00)	/* ZONE_NORMAL is ZONE_DMA32 */
+#define __GFP_EASY_RECLAIM ((__force gfp_t)0x04u)
 #else
 #define __GFP_DMA32	((__force gfp_t)0x04)	/* Has own ZONE_DMA32 */
+#define __GFP_EASY_RECLAIM ((__force gfp_t)0x08u)
 #endif
 
 /*
@@ -64,7 +67,7 @@ struct vm_area_struct;
 #define GFP_KERNEL	(__GFP_WAIT | __GFP_IO | __GFP_FS)
 #define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
 #define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL | \
-			 __GFP_HIGHMEM)
+			 __GFP_HIGHMEM | __GFP_EASY_RECLAIM)
 
 /* Flag - indicates that the buffer will be suitable for DMA.  Ignored on some
    platforms, used as appropriate on others */
Index: zone_reclaim/include/linux/mmzone.h
===================================================================
--- zone_reclaim.orig/include/linux/mmzone.h	2005-12-06 12:07:34.000000000 +0900
+++ zone_reclaim/include/linux/mmzone.h	2005-12-06 13:52:04.000000000 +0900
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
