Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 951EA6B0260
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 16:21:54 -0500 (EST)
Received: by mail-pa0-f70.google.com with SMTP id kr7so9821952pab.5
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 13:21:54 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id pf5si1038870pac.312.2016.11.09.13.21.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Nov 2016 13:21:53 -0800 (PST)
Subject: [swiotlb PATCH v3 3/3] swiotlb: Add support for
 DMA_ATTR_SKIP_CPU_SYNC
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 09 Nov 2016 10:20:49 -0500
Message-ID: <20161109152039.25151.37018.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161109151639.25151.24290.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161109151639.25151.24290.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, konrad.wilk@oracle.com
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org

As a first step to making DMA_ATTR_SKIP_CPU_SYNC apply to architectures
beyond just ARM I need to make it so that the swiotlb will respect the
flag.  In order to do that I also need to update the swiotlb-xen since it
heavily makes use of the functionality.

In addition I am applying the attribute to the unmap calls in the case of
map_single or map_sg has to later destroy a buffer because the device is
not able to access the DMA region.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

v1: Found different fix for avoiding lines longer than 80 characters
    Dropped code that moved section to a label at end of function.
    Split out mapping error fix to separate patch.
v3: Used 0 where applying DMA_ATTR_SKIP_CPU_SYNC is redundant
    Applied DMA_ATTR_SKIP_CPU_SYNC to attr instead of ORing in parameter
    Unwrap a few lines that are more readable as a single line
    Updated patch to work with changes in xen_swiotlb_map_page code flow

 drivers/xen/swiotlb-xen.c |   10 ++++++----
 include/linux/swiotlb.h   |    6 ++++--
 lib/swiotlb.c             |   37 ++++++++++++++++++++++---------------
 3 files changed, 32 insertions(+), 21 deletions(-)

diff --git a/drivers/xen/swiotlb-xen.c b/drivers/xen/swiotlb-xen.c
index c36caa5..b0d5d27 100644
--- a/drivers/xen/swiotlb-xen.c
+++ b/drivers/xen/swiotlb-xen.c
@@ -405,7 +405,7 @@ dma_addr_t xen_swiotlb_map_page(struct device *dev, struct page *page,
 	 */
 	trace_swiotlb_bounced(dev, dev_addr, size, swiotlb_force);
 
-	map = swiotlb_tbl_map_single(dev, start_dma_addr, phys, size, dir);
+	map = swiotlb_tbl_map_single(dev, start_dma_addr, phys, size, dir, attrs);
 	if (map == SWIOTLB_MAP_ERROR)
 		return DMA_ERROR_CODE;
 
@@ -417,7 +417,8 @@ dma_addr_t xen_swiotlb_map_page(struct device *dev, struct page *page,
 	 * Ensure that the address returned is DMA'ble
 	 */
 	if (!dma_capable(dev, dev_addr, size)) {
-		swiotlb_tbl_unmap_single(dev, map, size, dir);
+		attrs |= DMA_ATTR_SKIP_CPU_SYNC;
+		swiotlb_tbl_unmap_single(dev, map, size, dir, attrs);
 		return DMA_ERROR_CODE;
 	}
 	return dev_addr;
@@ -444,7 +445,7 @@ static void xen_unmap_single(struct device *hwdev, dma_addr_t dev_addr,
 
 	/* NOTE: We use dev_addr here, not paddr! */
 	if (is_xen_swiotlb_buffer(dev_addr)) {
-		swiotlb_tbl_unmap_single(hwdev, paddr, size, dir);
+		swiotlb_tbl_unmap_single(hwdev, paddr, size, dir, attrs);
 		return;
 	}
 
@@ -557,11 +558,12 @@ xen_swiotlb_map_sg_attrs(struct device *hwdev, struct scatterlist *sgl,
 								 start_dma_addr,
 								 sg_phys(sg),
 								 sg->length,
-								 dir);
+								 dir, attrs);
 			if (map == SWIOTLB_MAP_ERROR) {
 				dev_warn(hwdev, "swiotlb buffer is full\n");
 				/* Don't panic here, we expect map_sg users
 				   to do proper error handling. */
+				attrs |= DMA_ATTR_SKIP_CPU_SYNC;
 				xen_swiotlb_unmap_sg_attrs(hwdev, sgl, i, dir,
 							   attrs);
 				sg_dma_len(sgl) = 0;
diff --git a/include/linux/swiotlb.h b/include/linux/swiotlb.h
index f0d2589..183f37c 100644
--- a/include/linux/swiotlb.h
+++ b/include/linux/swiotlb.h
@@ -44,11 +44,13 @@ enum dma_sync_target {
 extern phys_addr_t swiotlb_tbl_map_single(struct device *hwdev,
 					  dma_addr_t tbl_dma_addr,
 					  phys_addr_t phys, size_t size,
-					  enum dma_data_direction dir);
+					  enum dma_data_direction dir,
+					  unsigned long attrs);
 
 extern void swiotlb_tbl_unmap_single(struct device *hwdev,
 				     phys_addr_t tlb_addr,
-				     size_t size, enum dma_data_direction dir);
+				     size_t size, enum dma_data_direction dir,
+				     unsigned long attrs);
 
 extern void swiotlb_tbl_sync_single(struct device *hwdev,
 				    phys_addr_t tlb_addr,
diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index 5005316..1fa0491 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -425,7 +425,8 @@ static void swiotlb_bounce(phys_addr_t orig_addr, phys_addr_t tlb_addr,
 phys_addr_t swiotlb_tbl_map_single(struct device *hwdev,
 				   dma_addr_t tbl_dma_addr,
 				   phys_addr_t orig_addr, size_t size,
-				   enum dma_data_direction dir)
+				   enum dma_data_direction dir,
+				   unsigned long attrs)
 {
 	unsigned long flags;
 	phys_addr_t tlb_addr;
@@ -526,7 +527,8 @@ found:
 	 */
 	for (i = 0; i < nslots; i++)
 		io_tlb_orig_addr[index+i] = orig_addr + (i << IO_TLB_SHIFT);
-	if (dir == DMA_TO_DEVICE || dir == DMA_BIDIRECTIONAL)
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC) &&
+	    (dir == DMA_TO_DEVICE || dir == DMA_BIDIRECTIONAL))
 		swiotlb_bounce(orig_addr, tlb_addr, size, DMA_TO_DEVICE);
 
 	return tlb_addr;
@@ -539,18 +541,19 @@ EXPORT_SYMBOL_GPL(swiotlb_tbl_map_single);
 
 static phys_addr_t
 map_single(struct device *hwdev, phys_addr_t phys, size_t size,
-	   enum dma_data_direction dir)
+	   enum dma_data_direction dir, unsigned long attrs)
 {
 	dma_addr_t start_dma_addr = phys_to_dma(hwdev, io_tlb_start);
 
-	return swiotlb_tbl_map_single(hwdev, start_dma_addr, phys, size, dir);
+	return swiotlb_tbl_map_single(hwdev, start_dma_addr, phys, size, dir, attrs);
 }
 
 /*
  * dma_addr is the kernel virtual address of the bounce buffer to unmap.
  */
 void swiotlb_tbl_unmap_single(struct device *hwdev, phys_addr_t tlb_addr,
-			      size_t size, enum dma_data_direction dir)
+			      size_t size, enum dma_data_direction dir,
+			      unsigned long attrs)
 {
 	unsigned long flags;
 	int i, count, nslots = ALIGN(size, 1 << IO_TLB_SHIFT) >> IO_TLB_SHIFT;
@@ -561,6 +564,7 @@ void swiotlb_tbl_unmap_single(struct device *hwdev, phys_addr_t tlb_addr,
 	 * First, sync the memory before unmapping the entry
 	 */
 	if (orig_addr != INVALID_PHYS_ADDR &&
+	    !(attrs & DMA_ATTR_SKIP_CPU_SYNC) &&
 	    ((dir == DMA_FROM_DEVICE) || (dir == DMA_BIDIRECTIONAL)))
 		swiotlb_bounce(orig_addr, tlb_addr, size, DMA_FROM_DEVICE);
 
@@ -654,7 +658,7 @@ swiotlb_alloc_coherent(struct device *hwdev, size_t size,
 		 * GFP_DMA memory; fall back on map_single(), which
 		 * will grab memory from the lowest available address range.
 		 */
-		phys_addr_t paddr = map_single(hwdev, 0, size, DMA_FROM_DEVICE);
+		phys_addr_t paddr = map_single(hwdev, 0, size, DMA_FROM_DEVICE, 0);
 		if (paddr == SWIOTLB_MAP_ERROR)
 			goto err_warn;
 
@@ -669,7 +673,7 @@ swiotlb_alloc_coherent(struct device *hwdev, size_t size,
 
 			/* DMA_TO_DEVICE to avoid memcpy in unmap_single */
 			swiotlb_tbl_unmap_single(hwdev, paddr,
-						 size, DMA_TO_DEVICE);
+						 size, DMA_TO_DEVICE, 0);
 			goto err_warn;
 		}
 	}
@@ -699,7 +703,7 @@ swiotlb_free_coherent(struct device *hwdev, size_t size, void *vaddr,
 		free_pages((unsigned long)vaddr, get_order(size));
 	else
 		/* DMA_TO_DEVICE to avoid memcpy in swiotlb_tbl_unmap_single */
-		swiotlb_tbl_unmap_single(hwdev, paddr, size, DMA_TO_DEVICE);
+		swiotlb_tbl_unmap_single(hwdev, paddr, size, DMA_TO_DEVICE, 0);
 }
 EXPORT_SYMBOL(swiotlb_free_coherent);
 
@@ -755,7 +759,7 @@ dma_addr_t swiotlb_map_page(struct device *dev, struct page *page,
 	trace_swiotlb_bounced(dev, dev_addr, size, swiotlb_force);
 
 	/* Oh well, have to allocate and map a bounce buffer. */
-	map = map_single(dev, phys, size, dir);
+	map = map_single(dev, phys, size, dir, attrs);
 	if (map == SWIOTLB_MAP_ERROR) {
 		swiotlb_full(dev, size, dir, 1);
 		return phys_to_dma(dev, io_tlb_overflow_buffer);
@@ -765,7 +769,8 @@ dma_addr_t swiotlb_map_page(struct device *dev, struct page *page,
 
 	/* Ensure that the address returned is DMA'ble */
 	if (!dma_capable(dev, dev_addr, size)) {
-		swiotlb_tbl_unmap_single(dev, map, size, dir);
+		attrs |= DMA_ATTR_SKIP_CPU_SYNC;
+		swiotlb_tbl_unmap_single(dev, map, size, dir, attrs);
 		return phys_to_dma(dev, io_tlb_overflow_buffer);
 	}
 
@@ -782,14 +787,15 @@ EXPORT_SYMBOL_GPL(swiotlb_map_page);
  * whatever the device wrote there.
  */
 static void unmap_single(struct device *hwdev, dma_addr_t dev_addr,
-			 size_t size, enum dma_data_direction dir)
+			 size_t size, enum dma_data_direction dir,
+			 unsigned long attrs)
 {
 	phys_addr_t paddr = dma_to_phys(hwdev, dev_addr);
 
 	BUG_ON(dir == DMA_NONE);
 
 	if (is_swiotlb_buffer(paddr)) {
-		swiotlb_tbl_unmap_single(hwdev, paddr, size, dir);
+		swiotlb_tbl_unmap_single(hwdev, paddr, size, dir, attrs);
 		return;
 	}
 
@@ -809,7 +815,7 @@ void swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
 			size_t size, enum dma_data_direction dir,
 			unsigned long attrs)
 {
-	unmap_single(hwdev, dev_addr, size, dir);
+	unmap_single(hwdev, dev_addr, size, dir, attrs);
 }
 EXPORT_SYMBOL_GPL(swiotlb_unmap_page);
 
@@ -891,11 +897,12 @@ swiotlb_map_sg_attrs(struct device *hwdev, struct scatterlist *sgl, int nelems,
 		if (swiotlb_force ||
 		    !dma_capable(hwdev, dev_addr, sg->length)) {
 			phys_addr_t map = map_single(hwdev, sg_phys(sg),
-						     sg->length, dir);
+						     sg->length, dir, attrs);
 			if (map == SWIOTLB_MAP_ERROR) {
 				/* Don't panic here, we expect map_sg users
 				   to do proper error handling. */
 				swiotlb_full(hwdev, sg->length, dir, 0);
+				attrs |= DMA_ATTR_SKIP_CPU_SYNC;
 				swiotlb_unmap_sg_attrs(hwdev, sgl, i, dir,
 						       attrs);
 				sg_dma_len(sgl) = 0;
@@ -925,7 +932,7 @@ swiotlb_unmap_sg_attrs(struct device *hwdev, struct scatterlist *sgl,
 	BUG_ON(dir == DMA_NONE);
 
 	for_each_sg(sgl, sg, nelems, i)
-		unmap_single(hwdev, sg->dma_address, sg_dma_len(sg), dir);
+		unmap_single(hwdev, sg->dma_address, sg_dma_len(sg), dir, attrs);
 
 }
 EXPORT_SYMBOL(swiotlb_unmap_sg_attrs);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
