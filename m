Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 06BE86B0286
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 17:38:47 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id py6so16752863pab.0
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 14:38:46 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id b8si10136750pao.287.2016.10.25.14.38.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Oct 2016 14:38:46 -0700 (PDT)
Subject: [net-next PATCH 15/27] arch/nios2: Add option to skip DMA sync as a
 part of map and unmap
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Tue, 25 Oct 2016 11:38:07 -0400
Message-ID: <20161025153807.4815.41509.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ley Foon Tan <lftan@altera.com>, davem@davemloft.net, brouer@redhat.com

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
