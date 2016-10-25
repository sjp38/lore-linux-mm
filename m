Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 821A26B0276
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 17:37:45 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n85so7284145pfi.4
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 14:37:45 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id b7si22806064pfl.65.2016.10.25.14.37.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Oct 2016 14:37:44 -0700 (PDT)
Subject: [net-next PATCH 03/27] swiotlb: Add support for
 DMA_ATTR_SKIP_CPU_SYNC
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Tue, 25 Oct 2016 11:37:03 -0400
Message-ID: <20161025153703.4815.13673.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: brouer@redhat.com, davem@davemloft.net, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

As a first step to making DMA_ATTR_SKIP_CPU_SYNC apply to architectures
beyond just ARM I need to make it so that the swiotlb will respect the
flag.  In order to do that I also need to update the swiotlb-xen since it
heavily makes use of the functionality.

Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/xen/swiotlb-xen.c |   11 +++++++---
 include/linux/swiotlb.h   |    6 ++++--
 lib/swiotlb.c             |   48 +++++++++++++++++++++++++++------------------
 3 files changed, 40 insertions(+), 25 deletions(-)

diff --git a/drivers/xen/swiotlb-xen.c b/drivers/xen/swiotlb-xen.c
index b8014bf..3d048af 100644
--- a/drivers/xen/swiotlb-xen.c
+++ b/drivers/xen/swiotlb-xen.c
@@ -405,7 +405,8 @@ dma_addr_t xen_swiotlb_map_page(struct device *dev, struct page *page,
 	 */
 	trace_swiotlb_bounced(dev, dev_addr, size, swiotlb_force);
 
-	map = swiotlb_tbl_map_single(dev, start_dma_addr, phys, size, dir);
+	map = swiotlb_tbl_map_single(dev, start_dma_addr, phys, size, dir,
+				     attrs);
 	if (map == SWIOTLB_MAP_ERROR)
 		return DMA_ERROR_CODE;
 
@@ -419,7 +420,8 @@ dma_addr_t xen_swiotlb_map_page(struct device *dev, struct page *page,
 	if (dma_capable(dev, dev_addr, size))
 		return dev_addr;
 
-	swiotlb_tbl_unmap_single(dev, map, size, dir);
+	swiotlb_tbl_unmap_single(dev, map, size, dir,
+				 attrs | DMA_ATTR_SKIP_CPU_SYNC);
 
 	return DMA_ERROR_CODE;
 }
@@ -445,7 +447,7 @@ static void xen_unmap_single(struct device *hwdev, dma_addr_t dev_addr,
 
 	/* NOTE: We use dev_addr here, not paddr! */
 	if (is_xen_swiotlb_buffer(dev_addr)) {
-		swiotlb_tbl_unmap_single(hwdev, paddr, size, dir);
+		swiotlb_tbl_unmap_single(hwdev, paddr, size, dir, attrs);
 		return;
 	}
 
@@ -558,11 +560,12 @@ void xen_swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
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
index e237b6f..4517be9 100644
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
index 47aad37..b538d39 100644
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
@@ -526,7 +527,8 @@ phys_addr_t swiotlb_tbl_map_single(struct device *hwdev,
 	 */
 	for (i = 0; i < nslots; i++)
 		io_tlb_orig_addr[index+i] = orig_addr + (i << IO_TLB_SHIFT);
-	if (dir == DMA_TO_DEVICE || dir == DMA_BIDIRECTIONAL)
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC) &&
+	    (dir == DMA_TO_DEVICE || dir == DMA_BIDIRECTIONAL))
 		swiotlb_bounce(orig_addr, tlb_addr, size, DMA_TO_DEVICE);
 
 	return tlb_addr;
@@ -539,18 +541,20 @@ phys_addr_t swiotlb_tbl_map_single(struct device *hwdev,
 
 static phys_addr_t
 map_single(struct device *hwdev, phys_addr_t phys, size_t size,
-	   enum dma_data_direction dir)
+	   enum dma_data_direction dir, unsigned long attrs)
 {
 	dma_addr_t start_dma_addr = phys_to_dma(hwdev, io_tlb_start);
 
-	return swiotlb_tbl_map_single(hwdev, start_dma_addr, phys, size, dir);
+	return swiotlb_tbl_map_single(hwdev, start_dma_addr, phys, size,
+				      dir, attrs);
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
@@ -561,6 +565,7 @@ void swiotlb_tbl_unmap_single(struct device *hwdev, phys_addr_t tlb_addr,
 	 * First, sync the memory before unmapping the entry
 	 */
 	if (orig_addr != INVALID_PHYS_ADDR &&
+	    !(attrs & DMA_ATTR_SKIP_CPU_SYNC) &&
 	    ((dir == DMA_FROM_DEVICE) || (dir == DMA_BIDIRECTIONAL)))
 		swiotlb_bounce(orig_addr, tlb_addr, size, DMA_FROM_DEVICE);
 
@@ -654,7 +659,8 @@ void swiotlb_tbl_sync_single(struct device *hwdev, phys_addr_t tlb_addr,
 		 * GFP_DMA memory; fall back on map_single(), which
 		 * will grab memory from the lowest available address range.
 		 */
-		phys_addr_t paddr = map_single(hwdev, 0, size, DMA_FROM_DEVICE);
+		phys_addr_t paddr = map_single(hwdev, 0, size,
+					       DMA_FROM_DEVICE, 0);
 		if (paddr == SWIOTLB_MAP_ERROR)
 			goto err_warn;
 
@@ -669,7 +675,8 @@ void swiotlb_tbl_sync_single(struct device *hwdev, phys_addr_t tlb_addr,
 
 			/* DMA_TO_DEVICE to avoid memcpy in unmap_single */
 			swiotlb_tbl_unmap_single(hwdev, paddr,
-						 size, DMA_TO_DEVICE);
+						 size, DMA_TO_DEVICE,
+						 DMA_ATTR_SKIP_CPU_SYNC);
 			goto err_warn;
 		}
 	}
@@ -699,7 +706,7 @@ void swiotlb_tbl_sync_single(struct device *hwdev, phys_addr_t tlb_addr,
 		free_pages((unsigned long)vaddr, get_order(size));
 	else
 		/* DMA_TO_DEVICE to avoid memcpy in swiotlb_tbl_unmap_single */
-		swiotlb_tbl_unmap_single(hwdev, paddr, size, DMA_TO_DEVICE);
+		swiotlb_tbl_unmap_single(hwdev, paddr, size, DMA_TO_DEVICE, 0);
 }
 EXPORT_SYMBOL(swiotlb_free_coherent);
 
@@ -755,7 +762,7 @@ dma_addr_t swiotlb_map_page(struct device *dev, struct page *page,
 	trace_swiotlb_bounced(dev, dev_addr, size, swiotlb_force);
 
 	/* Oh well, have to allocate and map a bounce buffer. */
-	map = map_single(dev, phys, size, dir);
+	map = map_single(dev, phys, size, dir, attrs);
 	if (map == SWIOTLB_MAP_ERROR) {
 		swiotlb_full(dev, size, dir, 1);
 		return phys_to_dma(dev, io_tlb_overflow_buffer);
@@ -764,12 +771,13 @@ dma_addr_t swiotlb_map_page(struct device *dev, struct page *page,
 	dev_addr = phys_to_dma(dev, map);
 
 	/* Ensure that the address returned is DMA'ble */
-	if (!dma_capable(dev, dev_addr, size)) {
-		swiotlb_tbl_unmap_single(dev, map, size, dir);
-		return phys_to_dma(dev, io_tlb_overflow_buffer);
-	}
+	if (dma_capable(dev, dev_addr, size))
+		return dev_addr;
+
+	swiotlb_tbl_unmap_single(dev, map, size, dir,
+				 attrs | DMA_ATTR_SKIP_CPU_SYNC);
 
-	return dev_addr;
+	return phys_to_dma(dev, io_tlb_overflow_buffer);
 }
 EXPORT_SYMBOL_GPL(swiotlb_map_page);
 
@@ -782,14 +790,15 @@ dma_addr_t swiotlb_map_page(struct device *dev, struct page *page,
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
 
@@ -809,7 +818,7 @@ void swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
 			size_t size, enum dma_data_direction dir,
 			unsigned long attrs)
 {
-	unmap_single(hwdev, dev_addr, size, dir);
+	unmap_single(hwdev, dev_addr, size, dir, attrs);
 }
 EXPORT_SYMBOL_GPL(swiotlb_unmap_page);
 
@@ -891,7 +900,7 @@ void swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
 		if (swiotlb_force ||
 		    !dma_capable(hwdev, dev_addr, sg->length)) {
 			phys_addr_t map = map_single(hwdev, sg_phys(sg),
-						     sg->length, dir);
+						     sg->length, dir, attrs);
 			if (map == SWIOTLB_MAP_ERROR) {
 				/* Don't panic here, we expect map_sg users
 				   to do proper error handling. */
@@ -925,7 +934,8 @@ void swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
 	BUG_ON(dir == DMA_NONE);
 
 	for_each_sg(sgl, sg, nelems, i)
-		unmap_single(hwdev, sg->dma_address, sg_dma_len(sg), dir);
+		unmap_single(hwdev, sg->dma_address, sg_dma_len(sg), dir,
+			     attrs);
 
 }
 EXPORT_SYMBOL(swiotlb_unmap_sg_attrs);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
