Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 10C8A6B026F
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 09:25:40 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d22-v6so1105565pfn.3
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 06:25:40 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d130-v6si19657838pgc.189.2018.10.09.06.25.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Oct 2018 06:25:38 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 07/33] powerpc/dma: untangle vio_dma_mapping_ops from dma_iommu_ops
Date: Tue,  9 Oct 2018 15:24:34 +0200
Message-Id: <20181009132500.17643-8-hch@lst.de>
In-Reply-To: <20181009132500.17643-1-hch@lst.de>
References: <20181009132500.17643-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

vio_dma_mapping_ops currently does a lot of indirect calls through
dma_iommu_ops, which not only make the code harder to follow but are
also expensive in the post-spectre world.  Unwind the indirect calls
by calling the ppc_iommu_* or iommu_* APIs directly applicable, or
just use the dma_iommu_* methods directly where we can.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/include/asm/iommu.h     |  1 +
 arch/powerpc/kernel/dma-iommu.c      |  2 +-
 arch/powerpc/platforms/pseries/vio.c | 87 ++++++++++++----------------
 3 files changed, 38 insertions(+), 52 deletions(-)

diff --git a/arch/powerpc/include/asm/iommu.h b/arch/powerpc/include/asm/iommu.h
index ab3a4fba38e3..26b7cc176a99 100644
--- a/arch/powerpc/include/asm/iommu.h
+++ b/arch/powerpc/include/asm/iommu.h
@@ -244,6 +244,7 @@ static inline int __init tce_iommu_bus_notifier_init(void)
 }
 #endif /* !CONFIG_IOMMU_API */
 
+u64 dma_iommu_get_required_mask(struct device *dev);
 int dma_iommu_mapping_error(struct device *dev, dma_addr_t dma_addr);
 
 #else
diff --git a/arch/powerpc/kernel/dma-iommu.c b/arch/powerpc/kernel/dma-iommu.c
index 2ca6cfaebf65..0613278abf9f 100644
--- a/arch/powerpc/kernel/dma-iommu.c
+++ b/arch/powerpc/kernel/dma-iommu.c
@@ -92,7 +92,7 @@ int dma_iommu_dma_supported(struct device *dev, u64 mask)
 		return 1;
 }
 
-static u64 dma_iommu_get_required_mask(struct device *dev)
+u64 dma_iommu_get_required_mask(struct device *dev)
 {
 	struct iommu_table *tbl = get_iommu_table_base(dev);
 	u64 mask;
diff --git a/arch/powerpc/platforms/pseries/vio.c b/arch/powerpc/platforms/pseries/vio.c
index 49e04ec19238..1dfff53ebd7f 100644
--- a/arch/powerpc/platforms/pseries/vio.c
+++ b/arch/powerpc/platforms/pseries/vio.c
@@ -492,7 +492,9 @@ static void *vio_dma_iommu_alloc_coherent(struct device *dev, size_t size,
 		return NULL;
 	}
 
-	ret = dma_iommu_ops.alloc(dev, size, dma_handle, flag, attrs);
+	ret = iommu_alloc_coherent(dev, get_iommu_table_base(dev), size,
+				    dma_handle, dev->coherent_dma_mask, flag,
+				    dev_to_node(dev));
 	if (unlikely(ret == NULL)) {
 		vio_cmo_dealloc(viodev, roundup(size, PAGE_SIZE));
 		atomic_inc(&viodev->cmo.allocs_failed);
@@ -507,8 +509,7 @@ static void vio_dma_iommu_free_coherent(struct device *dev, size_t size,
 {
 	struct vio_dev *viodev = to_vio_dev(dev);
 
-	dma_iommu_ops.free(dev, size, vaddr, dma_handle, attrs);
-
+	iommu_free_coherent(get_iommu_table_base(dev), size, vaddr, dma_handle);
 	vio_cmo_dealloc(viodev, roundup(size, PAGE_SIZE));
 }
 
@@ -518,22 +519,22 @@ static dma_addr_t vio_dma_iommu_map_page(struct device *dev, struct page *page,
                                          unsigned long attrs)
 {
 	struct vio_dev *viodev = to_vio_dev(dev);
-	struct iommu_table *tbl;
+	struct iommu_table *tbl = get_iommu_table_base(dev);
 	dma_addr_t ret = IOMMU_MAPPING_ERROR;
 
-	tbl = get_iommu_table_base(dev);
-	if (vio_cmo_alloc(viodev, roundup(size, IOMMU_PAGE_SIZE(tbl)))) {
-		atomic_inc(&viodev->cmo.allocs_failed);
-		return ret;
-	}
-
-	ret = dma_iommu_ops.map_page(dev, page, offset, size, direction, attrs);
-	if (unlikely(dma_mapping_error(dev, ret))) {
-		vio_cmo_dealloc(viodev, roundup(size, IOMMU_PAGE_SIZE(tbl)));
-		atomic_inc(&viodev->cmo.allocs_failed);
-	}
-
+	if (vio_cmo_alloc(viodev, roundup(size, IOMMU_PAGE_SIZE(tbl))))
+		goto out_fail;
+	ret = iommu_map_page(dev, tbl, page, offset, size, device_to_mask(dev),
+			direction, attrs);
+	if (unlikely(ret == IOMMU_MAPPING_ERROR))
+		goto out_deallocate;
 	return ret;
+
+out_deallocate:
+	vio_cmo_dealloc(viodev, roundup(size, IOMMU_PAGE_SIZE(tbl)));
+out_fail:
+	atomic_inc(&viodev->cmo.allocs_failed);
+	return IOMMU_MAPPING_ERROR;
 }
 
 static void vio_dma_iommu_unmap_page(struct device *dev, dma_addr_t dma_handle,
@@ -542,11 +543,9 @@ static void vio_dma_iommu_unmap_page(struct device *dev, dma_addr_t dma_handle,
 				     unsigned long attrs)
 {
 	struct vio_dev *viodev = to_vio_dev(dev);
-	struct iommu_table *tbl;
-
-	tbl = get_iommu_table_base(dev);
-	dma_iommu_ops.unmap_page(dev, dma_handle, size, direction, attrs);
+	struct iommu_table *tbl = get_iommu_table_base(dev);
 
+	iommu_unmap_page(tbl, dma_handle, size, direction, attrs);
 	vio_cmo_dealloc(viodev, roundup(size, IOMMU_PAGE_SIZE(tbl)));
 }
 
@@ -555,34 +554,32 @@ static int vio_dma_iommu_map_sg(struct device *dev, struct scatterlist *sglist,
                                 unsigned long attrs)
 {
 	struct vio_dev *viodev = to_vio_dev(dev);
-	struct iommu_table *tbl;
+	struct iommu_table *tbl = get_iommu_table_base(dev);
 	struct scatterlist *sgl;
 	int ret, count;
 	size_t alloc_size = 0;
 
-	tbl = get_iommu_table_base(dev);
 	for_each_sg(sglist, sgl, nelems, count)
 		alloc_size += roundup(sgl->length, IOMMU_PAGE_SIZE(tbl));
 
-	if (vio_cmo_alloc(viodev, alloc_size)) {
-		atomic_inc(&viodev->cmo.allocs_failed);
-		return 0;
-	}
-
-	ret = dma_iommu_ops.map_sg(dev, sglist, nelems, direction, attrs);
-
-	if (unlikely(!ret)) {
-		vio_cmo_dealloc(viodev, alloc_size);
-		atomic_inc(&viodev->cmo.allocs_failed);
-		return ret;
-	}
+	if (vio_cmo_alloc(viodev, alloc_size))
+		goto out_fail;
+	ret = ppc_iommu_map_sg(dev, tbl, sglist, nelems, device_to_mask(dev),
+			direction, attrs);
+	if (unlikely(!ret))
+		goto out_deallocate;
 
 	for_each_sg(sglist, sgl, ret, count)
 		alloc_size -= roundup(sgl->dma_length, IOMMU_PAGE_SIZE(tbl));
 	if (alloc_size)
 		vio_cmo_dealloc(viodev, alloc_size);
-
 	return ret;
+
+out_deallocate:
+	vio_cmo_dealloc(viodev, alloc_size);
+out_fail:
+	atomic_inc(&viodev->cmo.allocs_failed);
+	return 0;
 }
 
 static void vio_dma_iommu_unmap_sg(struct device *dev,
@@ -591,30 +588,18 @@ static void vio_dma_iommu_unmap_sg(struct device *dev,
 		unsigned long attrs)
 {
 	struct vio_dev *viodev = to_vio_dev(dev);
-	struct iommu_table *tbl;
+	struct iommu_table *tbl = get_iommu_table_base(dev);
 	struct scatterlist *sgl;
 	size_t alloc_size = 0;
 	int count;
 
-	tbl = get_iommu_table_base(dev);
 	for_each_sg(sglist, sgl, nelems, count)
 		alloc_size += roundup(sgl->dma_length, IOMMU_PAGE_SIZE(tbl));
 
-	dma_iommu_ops.unmap_sg(dev, sglist, nelems, direction, attrs);
-
+	ppc_iommu_unmap_sg(tbl, sglist, nelems, direction, attrs);
 	vio_cmo_dealloc(viodev, alloc_size);
 }
 
-static int vio_dma_iommu_dma_supported(struct device *dev, u64 mask)
-{
-        return dma_iommu_ops.dma_supported(dev, mask);
-}
-
-static u64 vio_dma_get_required_mask(struct device *dev)
-{
-        return dma_iommu_ops.get_required_mask(dev);
-}
-
 static const struct dma_map_ops vio_dma_mapping_ops = {
 	.alloc             = vio_dma_iommu_alloc_coherent,
 	.free              = vio_dma_iommu_free_coherent,
@@ -623,8 +608,8 @@ static const struct dma_map_ops vio_dma_mapping_ops = {
 	.unmap_sg          = vio_dma_iommu_unmap_sg,
 	.map_page          = vio_dma_iommu_map_page,
 	.unmap_page        = vio_dma_iommu_unmap_page,
-	.dma_supported     = vio_dma_iommu_dma_supported,
-	.get_required_mask = vio_dma_get_required_mask,
+	.dma_supported     = dma_iommu_mapping_error,
+	.get_required_mask = dma_iommu_get_required_mask,
 	.mapping_error	   = dma_iommu_mapping_error,
 };
 
-- 
2.19.0
