Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id E3EE66B02B7
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 13:15:44 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id r204so34433528ywb.0
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 10:15:44 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id hi7si3449821pac.149.2016.11.02.10.15.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 10:15:44 -0700 (PDT)
Subject: [mm PATCH v2 15/26] arch/nios2: Add option to skip DMA sync as a
 part of map and unmap
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 02 Nov 2016 07:14:47 -0400
Message-ID: <20161102111445.79519.84229.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Ley Foon Tan <lftan@altera.com>, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
via a sync_for_cpu or sync_for_device call.

Cc: Ley Foon Tan <lftan@altera.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/nios2/mm/dma-mapping.c |   26 ++++++++++++++++++--------
 1 file changed, 18 insertions(+), 8 deletions(-)

diff --git a/arch/nios2/mm/dma-mapping.c b/arch/nios2/mm/dma-mapping.c
index d800fad..f6a5dcf 100644
--- a/arch/nios2/mm/dma-mapping.c
+++ b/arch/nios2/mm/dma-mapping.c
@@ -98,13 +98,17 @@ static int nios2_dma_map_sg(struct device *dev, struct scatterlist *sg,
 	int i;
 
 	for_each_sg(sg, sg, nents, i) {
-		void *addr;
+		void *addr = sg_virt(sg);
 
-		addr = sg_virt(sg);
-		if (addr) {
-			__dma_sync_for_device(addr, sg->length, direction);
-			sg->dma_address = sg_phys(sg);
-		}
+		if (!addr)
+			continue;
+
+		sg->dma_address = sg_phys(sg);
+
+		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+			continue;
+
+		__dma_sync_for_device(addr, sg->length, direction);
 	}
 
 	return nents;
@@ -117,7 +121,9 @@ static dma_addr_t nios2_dma_map_page(struct device *dev, struct page *page,
 {
 	void *addr = page_address(page) + offset;
 
-	__dma_sync_for_device(addr, size, direction);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		__dma_sync_for_device(addr, size, direction);
+
 	return page_to_phys(page) + offset;
 }
 
@@ -125,7 +131,8 @@ static void nios2_dma_unmap_page(struct device *dev, dma_addr_t dma_address,
 		size_t size, enum dma_data_direction direction,
 		unsigned long attrs)
 {
-	__dma_sync_for_cpu(phys_to_virt(dma_address), size, direction);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		__dma_sync_for_cpu(phys_to_virt(dma_address), size, direction);
 }
 
 static void nios2_dma_unmap_sg(struct device *dev, struct scatterlist *sg,
@@ -138,6 +145,9 @@ static void nios2_dma_unmap_sg(struct device *dev, struct scatterlist *sg,
 	if (direction == DMA_TO_DEVICE)
 		return;
 
+	if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+		return;
+
 	for_each_sg(sg, sg, nhwentries, i) {
 		addr = sg_virt(sg);
 		if (addr)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
