Received: from imr2.americas.sgi.com (imr2.americas.sgi.com [198.149.16.18])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k8BMU7nx007999
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 17:30:07 -0500
Date: Mon, 11 Sep 2006 15:30:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060911223006.5032.33033.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060911223001.5032.24593.sendpatchset@schroedinger.engr.sgi.com>
References: <20060911223001.5032.24593.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 1/6] Deal with cases of ZONE_DMA meaning the first zone
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Optional DMA zone: Replace uses of ZONE_DMA as the first zone

In two places in the VM we use ZONE_DMA to refer to the first zone.
If ZONE_DMA is optional then other zones may be first. So simply
replace ZONE_DMA with zone 0.

This also fixes ZONETABLE_PGSHIFT. If we have only a single zone then
ZONES_PGSHIFT may become 0 because there is no need anymore to encode the
zone number related to a pgdat. However, we still need a zonetable to index
all the zones for each node if this is a NUMA system. Therefore define
ZONETABLE_SHIFT unconditionally as the offset of the ZONE field in page flags.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc6-mm1/include/linux/mm.h
===================================================================
--- linux-2.6.18-rc6-mm1.orig/include/linux/mm.h	2006-09-11 15:42:30.576324881 -0500
+++ linux-2.6.18-rc6-mm1/include/linux/mm.h	2006-09-11 15:57:17.451691199 -0500
@@ -476,7 +476,7 @@
 #else
 #define ZONETABLE_SHIFT		(SECTIONS_SHIFT + ZONES_SHIFT)
 #endif
-#define ZONETABLE_PGSHIFT	ZONES_PGSHIFT
+#define ZONETABLE_PGSHIFT	ZONES_PGOFF
 
 #if SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
 #error SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
Index: linux-2.6.18-rc6-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.18-rc6-mm1.orig/mm/mempolicy.c	2006-09-11 15:42:30.591951213 -0500
+++ linux-2.6.18-rc6-mm1/mm/mempolicy.c	2006-09-11 15:57:17.466340884 -0500
@@ -105,7 +105,7 @@
 
 /* Highest zone. An specific allocation for a zone below that is not
    policied. */
-enum zone_type policy_zone = ZONE_DMA;
+enum zone_type policy_zone = 0;
 
 struct mempolicy default_policy = {
 	.refcnt = ATOMIC_INIT(1), /* never free it */
Index: linux-2.6.18-rc6-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.18-rc6-mm1.orig/mm/page_alloc.c	2006-09-11 15:42:30.000000000 -0500
+++ linux-2.6.18-rc6-mm1/mm/page_alloc.c	2006-09-11 16:44:51.877934885 -0500
@@ -2486,11 +2486,11 @@
 				"  %s zone: %lu pages exceeds realsize %lu\n",
 				zone_names[j], memmap_pages, realsize);
 
-		/* Account for reserved DMA pages */
-		if (j == ZONE_DMA && realsize > dma_reserve) {
+		/* Account for reserved pages */
+		if (j == 0 && realsize > dma_reserve) {
 			realsize -= dma_reserve;
-			printk(KERN_DEBUG "  DMA zone: %lu pages reserved\n",
-								dma_reserve);
+			printk(KERN_DEBUG "  %s zone: %lu pages reserved\n",
+					zone_names[0], dma_reserve);
 		}
 
 		if (!is_highmem_idx(j))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
