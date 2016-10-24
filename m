Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 565B8280250
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:06:18 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u84so128642711pfj.6
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:06:18 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id s8si3718199pac.245.2016.10.24.11.06.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 11:06:17 -0700 (PDT)
Subject: [net-next PATCH RFC 14/26] arch/nios2: Add option to skip DMA sync
 as a part of map and unmap
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 24 Oct 2016 08:05:40 -0400
Message-ID: <20161024120540.16276.15769.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ley Foon Tan <lftan@altera.com>, davem@davemloft.net, brouer@redhat.com

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
via a sync_for_cpu or sync_for_device call.

Cc: Ley Foon Tan <lftan@altera.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/nios2/mm/dma-mapping.c |   14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/arch/nios2/mm/dma-mapping.c b/arch/nios2/mm/dma-mapping.c
index d800fad..b83e723 100644
--- a/arch/nios2/mm/dma-mapping.c
+++ b/arch/nios2/mm/dma-mapping.c
@@ -102,7 +102,9 @@ static int nios2_dma_map_sg(struct device *dev, struct scatterlist *sg,
 
 		addr = sg_virt(sg);
 		if (addr) {
-			__dma_sync_for_device(addr, sg->length, direction);
+			if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+				__dma_sync_for_device(addr, sg->length,
+						      direction);
 			sg->dma_address = sg_phys(sg);
 		}
 	}
@@ -117,7 +119,9 @@ static dma_addr_t nios2_dma_map_page(struct device *dev, struct page *page,
 {
 	void *addr = page_address(page) + offset;
 
-	__dma_sync_for_device(addr, size, direction);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		__dma_sync_for_device(addr, size, direction);
+
 	return page_to_phys(page) + offset;
 }
 
@@ -125,7 +129,8 @@ static void nios2_dma_unmap_page(struct device *dev, dma_addr_t dma_address,
 		size_t size, enum dma_data_direction direction,
 		unsigned long attrs)
 {
-	__dma_sync_for_cpu(phys_to_virt(dma_address), size, direction);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		__dma_sync_for_cpu(phys_to_virt(dma_address), size, direction);
 }
 
 static void nios2_dma_unmap_sg(struct device *dev, struct scatterlist *sg,
@@ -138,6 +143,9 @@ static void nios2_dma_unmap_sg(struct device *dev, struct scatterlist *sg,
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
