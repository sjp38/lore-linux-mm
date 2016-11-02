Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6C6C96B02AB
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 13:13:45 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id yt9so9787932pac.0
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 10:13:45 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id c8si2547818pay.43.2016.11.02.10.13.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 10:13:44 -0700 (PDT)
Subject: [mm PATCH v2 02/26] swiotlb-xen: Enforce return of DMA_ERROR_CODE
 in mapping function
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 02 Nov 2016 07:12:47 -0400
Message-ID: <20161102111236.79519.72615.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

The mapping function should always return DMA_ERROR_CODE when a mapping has
failed as this is what the DMA API expects when a DMA error has occurred.
The current function for mapping a page in Xen was returning either
DMA_ERROR_CODE or 0 depending on where it failed.

On x86 DMA_ERROR_CODE is 0, but on other architectures such as ARM it is
~0. We need to make sure we return the same error value if either the
mapping failed or the device is not capable of accessing the mapping.

If we are returning DMA_ERROR_CODE as our error value we can drop the
function for checking the error code as the default is to compare the
return value against DMA_ERROR_CODE if no function is defined.

Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

v1: Added this patch which was part of an earlier patch.

 arch/arm/xen/mm.c              |    1 -
 arch/x86/xen/pci-swiotlb-xen.c |    1 -
 drivers/xen/swiotlb-xen.c      |   18 ++++++------------
 include/xen/swiotlb-xen.h      |    3 ---
 4 files changed, 6 insertions(+), 17 deletions(-)

diff --git a/arch/arm/xen/mm.c b/arch/arm/xen/mm.c
index d062f08..bd62d94 100644
--- a/arch/arm/xen/mm.c
+++ b/arch/arm/xen/mm.c
@@ -186,7 +186,6 @@ void xen_destroy_contiguous_region(phys_addr_t pstart, unsigned int order)
 EXPORT_SYMBOL(xen_dma_ops);
 
 static struct dma_map_ops xen_swiotlb_dma_ops = {
-	.mapping_error = xen_swiotlb_dma_mapping_error,
 	.alloc = xen_swiotlb_alloc_coherent,
 	.free = xen_swiotlb_free_coherent,
 	.sync_single_for_cpu = xen_swiotlb_sync_single_for_cpu,
diff --git a/arch/x86/xen/pci-swiotlb-xen.c b/arch/x86/xen/pci-swiotlb-xen.c
index 0e98e5d..a9fafb5 100644
--- a/arch/x86/xen/pci-swiotlb-xen.c
+++ b/arch/x86/xen/pci-swiotlb-xen.c
@@ -19,7 +19,6 @@
 int xen_swiotlb __read_mostly;
 
 static struct dma_map_ops xen_swiotlb_dma_ops = {
-	.mapping_error = xen_swiotlb_dma_mapping_error,
 	.alloc = xen_swiotlb_alloc_coherent,
 	.free = xen_swiotlb_free_coherent,
 	.sync_single_for_cpu = xen_swiotlb_sync_single_for_cpu,
diff --git a/drivers/xen/swiotlb-xen.c b/drivers/xen/swiotlb-xen.c
index 87e6035..b8014bf 100644
--- a/drivers/xen/swiotlb-xen.c
+++ b/drivers/xen/swiotlb-xen.c
@@ -416,11 +416,12 @@ dma_addr_t xen_swiotlb_map_page(struct device *dev, struct page *page,
 	/*
 	 * Ensure that the address returned is DMA'ble
 	 */
-	if (!dma_capable(dev, dev_addr, size)) {
-		swiotlb_tbl_unmap_single(dev, map, size, dir);
-		dev_addr = 0;
-	}
-	return dev_addr;
+	if (dma_capable(dev, dev_addr, size))
+		return dev_addr;
+
+	swiotlb_tbl_unmap_single(dev, map, size, dir);
+
+	return DMA_ERROR_CODE;
 }
 EXPORT_SYMBOL_GPL(xen_swiotlb_map_page);
 
@@ -648,13 +649,6 @@ void xen_swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
 }
 EXPORT_SYMBOL_GPL(xen_swiotlb_sync_sg_for_device);
 
-int
-xen_swiotlb_dma_mapping_error(struct device *hwdev, dma_addr_t dma_addr)
-{
-	return !dma_addr;
-}
-EXPORT_SYMBOL_GPL(xen_swiotlb_dma_mapping_error);
-
 /*
  * Return whether the given device DMA address mask can be supported
  * properly.  For example, if your device can only drive the low 24-bits
diff --git a/include/xen/swiotlb-xen.h b/include/xen/swiotlb-xen.h
index 7c35e27..a0083be 100644
--- a/include/xen/swiotlb-xen.h
+++ b/include/xen/swiotlb-xen.h
@@ -51,9 +51,6 @@ extern void xen_swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
 			       int nelems, enum dma_data_direction dir);
 
 extern int
-xen_swiotlb_dma_mapping_error(struct device *hwdev, dma_addr_t dma_addr);
-
-extern int
 xen_swiotlb_dma_supported(struct device *hwdev, u64 mask);
 
 extern int

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
