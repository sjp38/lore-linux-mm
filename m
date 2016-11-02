Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id F3E0A6B02AC
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 13:15:37 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j198so46605991oih.5
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 10:15:37 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id tl4si3475949pac.41.2016.11.02.10.15.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Nov 2016 10:15:37 -0700 (PDT)
Subject: [mm PATCH v2 14/26] arch/mips: Add option to skip DMA sync as a
 part of map and unmap
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 02 Nov 2016 07:14:39 -0400
Message-ID: <20161102111437.79519.6389.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: linux-mips@linux-mips.org, Keguang Zhang <keguang.zhang@gmail.com>, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, netdev@vger.kernel.org

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
via a sync_for_cpu or sync_for_device call.

Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Keguang Zhang <keguang.zhang@gmail.com>
Cc: linux-mips@linux-mips.org
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/mips/loongson64/common/dma-swiotlb.c |    2 +-
 arch/mips/mm/dma-default.c                |    8 +++++---
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/arch/mips/loongson64/common/dma-swiotlb.c b/arch/mips/loongson64/common/dma-swiotlb.c
index 1a80b6f..aab4fd6 100644
--- a/arch/mips/loongson64/common/dma-swiotlb.c
+++ b/arch/mips/loongson64/common/dma-swiotlb.c
@@ -61,7 +61,7 @@ static int loongson_dma_map_sg(struct device *dev, struct scatterlist *sg,
 				int nents, enum dma_data_direction dir,
 				unsigned long attrs)
 {
-	int r = swiotlb_map_sg_attrs(dev, sg, nents, dir, 0);
+	int r = swiotlb_map_sg_attrs(dev, sg, nents, dir, attrs);
 	mb();
 
 	return r;
diff --git a/arch/mips/mm/dma-default.c b/arch/mips/mm/dma-default.c
index 46d5696..a39c36a 100644
--- a/arch/mips/mm/dma-default.c
+++ b/arch/mips/mm/dma-default.c
@@ -293,7 +293,7 @@ static inline void __dma_sync(struct page *page,
 static void mips_dma_unmap_page(struct device *dev, dma_addr_t dma_addr,
 	size_t size, enum dma_data_direction direction, unsigned long attrs)
 {
-	if (cpu_needs_post_dma_flush(dev))
+	if (cpu_needs_post_dma_flush(dev) && !(attrs & DMA_ATTR_SKIP_CPU_SYNC))
 		__dma_sync(dma_addr_to_page(dev, dma_addr),
 			   dma_addr & ~PAGE_MASK, size, direction);
 	plat_post_dma_flush(dev);
@@ -307,7 +307,8 @@ static int mips_dma_map_sg(struct device *dev, struct scatterlist *sglist,
 	struct scatterlist *sg;
 
 	for_each_sg(sglist, sg, nents, i) {
-		if (!plat_device_is_coherent(dev))
+		if (!plat_device_is_coherent(dev) &&
+		    !(attrs & DMA_ATTR_SKIP_CPU_SYNC))
 			__dma_sync(sg_page(sg), sg->offset, sg->length,
 				   direction);
 #ifdef CONFIG_NEED_SG_DMA_LENGTH
@@ -324,7 +325,7 @@ static dma_addr_t mips_dma_map_page(struct device *dev, struct page *page,
 	unsigned long offset, size_t size, enum dma_data_direction direction,
 	unsigned long attrs)
 {
-	if (!plat_device_is_coherent(dev))
+	if (!plat_device_is_coherent(dev) && !(attrs & DMA_ATTR_SKIP_CPU_SYNC))
 		__dma_sync(page, offset, size, direction);
 
 	return plat_map_dma_mem_page(dev, page) + offset;
@@ -339,6 +340,7 @@ static void mips_dma_unmap_sg(struct device *dev, struct scatterlist *sglist,
 
 	for_each_sg(sglist, sg, nhwentries, i) {
 		if (!plat_device_is_coherent(dev) &&
+		    !(attrs & DMA_ATTR_SKIP_CPU_SYNC) &&
 		    direction != DMA_TO_DEVICE)
 			__dma_sync(sg_page(sg), sg->offset, sg->length,
 				   direction);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
