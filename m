Date: Mon, 18 Sep 2006 11:36:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060918183619.19679.67911.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060918183614.19679.50359.sendpatchset@schroedinger.engr.sgi.com>
References: <20060918183614.19679.50359.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 1/8] Deal with cases of ZONE_DMA meaning the first zone
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-arch@vger.kernel.org
Cc: Paul Mundt <lethal@linux-sh.org>, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@SteelEye.com>, Arjan van de Ven <arjan@infradead.org>, linux-mm@kvack.org, Russell King <rmk@arm.linux.org.uk>, Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
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

Acked-by: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc6-mm2/mm/mempolicy.c
===================================================================
--- linux-2.6.18-rc6-mm2.orig/mm/mempolicy.c	2006-09-18 13:07:53.318935179 -0500
+++ linux-2.6.18-rc6-mm2/mm/mempolicy.c	2006-09-18 13:16:18.929008279 -0500
@@ -105,7 +105,7 @@ static struct kmem_cache *sn_cache;
 
 /* Highest zone. An specific allocation for a zone below that is not
    policied. */
-enum zone_type policy_zone = ZONE_DMA;
+enum zone_type policy_zone = 0;
 
 struct mempolicy default_policy = {
 	.refcnt = ATOMIC_INIT(1), /* never free it */
Index: linux-2.6.18-rc6-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.18-rc6-mm2.orig/mm/page_alloc.c	2006-09-18 13:16:14.463795639 -0500
+++ linux-2.6.18-rc6-mm2/mm/page_alloc.c	2006-09-18 13:27:53.271625765 -0500
@@ -2486,11 +2486,11 @@ static void __meminit free_area_init_cor
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
Index: linux-2.6.18-rc6-mm2/include/linux/mm.h
===================================================================
--- linux-2.6.18-rc6-mm2.orig/include/linux/mm.h	2006-09-18 13:16:14.000000000 -0500
+++ linux-2.6.18-rc6-mm2/include/linux/mm.h	2006-09-18 13:28:52.406396556 -0500
@@ -416,7 +416,7 @@ void split_page(struct page *page, unsig
 #else
 #define ZONETABLE_SHIFT		(SECTIONS_SHIFT + ZONES_SHIFT)
 #endif
-#define ZONETABLE_PGSHIFT	ZONES_PGSHIFT
+#define ZONETABLE_PGSHIFT	ZONES_PGOFF
 
 #if SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
 #error SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
