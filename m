Date: Tue, 28 Nov 2006 16:45:08 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20061129004507.11682.73982.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20061129004426.11682.36688.sendpatchset@schroedinger.engr.sgi.com>
References: <20061129004426.11682.36688.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 8/8] Get rid of SLAB_DMA
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Get rid of SLAB_DMA

SLAB_DMA is an alias of GFP_DMA. This is the last one so we
remove the leftover comment too.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc6-mm1/drivers/atm/he.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/atm/he.c	2006-11-28 16:11:23.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/atm/he.c	2006-11-28 16:11:55.000000000 -0800
@@ -820,7 +820,7 @@
 		void *cpuaddr;
 
 #ifdef USE_RBPS_POOL 
-		cpuaddr = pci_pool_alloc(he_dev->rbps_pool, GFP_KERNEL|SLAB_DMA, &dma_handle);
+		cpuaddr = pci_pool_alloc(he_dev->rbps_pool, GFP_KERNEL|GFP_DMA, &dma_handle);
 		if (cpuaddr == NULL)
 			return -ENOMEM;
 #else
@@ -884,7 +884,7 @@
 		void *cpuaddr;
 
 #ifdef USE_RBPL_POOL
-		cpuaddr = pci_pool_alloc(he_dev->rbpl_pool, GFP_KERNEL|SLAB_DMA, &dma_handle);
+		cpuaddr = pci_pool_alloc(he_dev->rbpl_pool, GFP_KERNEL|GFP_DMA, &dma_handle);
 		if (cpuaddr == NULL)
 			return -ENOMEM;
 #else
@@ -1724,7 +1724,7 @@
 	struct he_tpd *tpd;
 	dma_addr_t dma_handle; 
 
-	tpd = pci_pool_alloc(he_dev->tpd_pool, GFP_ATOMIC|SLAB_DMA, &dma_handle);              
+	tpd = pci_pool_alloc(he_dev->tpd_pool, GFP_ATOMIC|GFP_DMA, &dma_handle);              
 	if (tpd == NULL)
 		return NULL;
 			
Index: linux-2.6.19-rc6-mm1/drivers/usb/core/buffer.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/core/buffer.c	2006-11-28 16:02:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/core/buffer.c	2006-11-28 16:11:55.000000000 -0800
@@ -93,7 +93,7 @@
 }
 
 
-/* sometimes alloc/free could use kmalloc with SLAB_DMA, for
+/* sometimes alloc/free could use kmalloc with GFP_DMA, for
  * better sharing and to leverage mm/slab.c intelligence.
  */
 
Index: linux-2.6.19-rc6-mm1/drivers/s390/block/dasd_eckd.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/s390/block/dasd_eckd.c	2006-11-28 16:02:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/s390/block/dasd_eckd.c	2006-11-28 16:11:55.000000000 -0800
@@ -1215,7 +1215,7 @@
 		dst = page_address(bv->bv_page) + bv->bv_offset;
 		if (dasd_page_cache) {
 			char *copy = kmem_cache_alloc(dasd_page_cache,
-						      SLAB_DMA | __GFP_NOWARN);
+						      GFP_DMA | __GFP_NOWARN);
 			if (copy && rq_data_dir(req) == WRITE)
 				memcpy(copy + bv->bv_offset, dst, bv->bv_len);
 			if (copy)
Index: linux-2.6.19-rc6-mm1/drivers/s390/block/dasd_fba.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/s390/block/dasd_fba.c	2006-11-28 16:02:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/s390/block/dasd_fba.c	2006-11-28 16:11:55.000000000 -0800
@@ -308,7 +308,7 @@
 		dst = page_address(bv->bv_page) + bv->bv_offset;
 		if (dasd_page_cache) {
 			char *copy = kmem_cache_alloc(dasd_page_cache,
-						      SLAB_DMA | __GFP_NOWARN);
+						      GFP_DMA | __GFP_NOWARN);
 			if (copy && rq_data_dir(req) == WRITE)
 				memcpy(copy + bv->bv_offset, dst, bv->bv_len);
 			if (copy)
Index: linux-2.6.19-rc6-mm1/include/linux/slab.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/linux/slab.h	2006-11-28 16:11:39.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/linux/slab.h	2006-11-28 16:12:11.000000000 -0800
@@ -16,9 +16,6 @@
 #include	<linux/init.h>
 #include	<linux/types.h>
 
-/* flags for kmem_cache_alloc() */
-#define	SLAB_DMA		GFP_DMA
-
 /* flags to pass to kmem_cache_create().
  * The first 3 are only valid when the allocator as been build
  * SLAB_DEBUG_SUPPORT.
Index: linux-2.6.19-rc6-mm1/mm/slab.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/mm/slab.c	2006-11-28 16:11:24.000000000 -0800
+++ linux-2.6.19-rc6-mm1/mm/slab.c	2006-11-28 16:12:48.000000000 -0800
@@ -2640,7 +2640,7 @@
 static void kmem_flagcheck(struct kmem_cache *cachep, gfp_t flags)
 {
 	if (CONFIG_ZONE_DMA_FLAG) {
-		if (flags & SLAB_DMA)
+		if (flags & GFP_DMA)
 			BUG_ON(!(cachep->gfpflags & GFP_DMA));
 		else
 			BUG_ON(cachep->gfpflags & GFP_DMA);
@@ -2725,7 +2725,7 @@
 	 * Be lazy and only check for valid flags here,  keeping it out of the
 	 * critical path in kmem_cache_alloc().
 	 */
-	BUG_ON(flags & ~(SLAB_DMA | GFP_LEVEL_MASK | __GFP_NO_GROW));
+	BUG_ON(flags & ~(GFP_DMA | GFP_LEVEL_MASK | __GFP_NO_GROW));
 	if (flags & __GFP_NO_GROW)
 		return 0;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
