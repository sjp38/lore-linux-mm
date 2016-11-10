Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 016AB28025B
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 12:37:02 -0500 (EST)
Received: by mail-pa0-f69.google.com with SMTP id rf5so93518813pab.3
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 09:37:01 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id a3si5982571pgc.167.2016.11.10.09.37.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 09:37:01 -0800 (PST)
Subject: [mm PATCH v3 18/23] arch/tile: Add option to skip DMA sync as a
 part of map and unmap
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Thu, 10 Nov 2016 06:35:50 -0500
Message-ID: <20161110113550.76501.73060.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: netdev@vger.kernel.org, Chris Metcalf <cmetcalf@mellanox.com>, linux-kernel@vger.kernel.org

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
via a sync_for_cpu or sync_for_device call.

Cc: Chris Metcalf <cmetcalf@mellanox.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/tile/kernel/pci-dma.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/arch/tile/kernel/pci-dma.c b/arch/tile/kernel/pci-dma.c
index 09bb774..24e0f8c 100644
--- a/arch/tile/kernel/pci-dma.c
+++ b/arch/tile/kernel/pci-dma.c
@@ -213,10 +213,12 @@ static int tile_dma_map_sg(struct device *dev, struct scatterlist *sglist,
 
 	for_each_sg(sglist, sg, nents, i) {
 		sg->dma_address = sg_phys(sg);
-		__dma_prep_pa_range(sg->dma_address, sg->length, direction);
 #ifdef CONFIG_NEED_SG_DMA_LENGTH
 		sg->dma_length = sg->length;
 #endif
+		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+			continue;
+		__dma_prep_pa_range(sg->dma_address, sg->length, direction);
 	}
 
 	return nents;
@@ -232,6 +234,8 @@ static void tile_dma_unmap_sg(struct device *dev, struct scatterlist *sglist,
 	BUG_ON(!valid_dma_direction(direction));
 	for_each_sg(sglist, sg, nents, i) {
 		sg->dma_address = sg_phys(sg);
+		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+			continue;
 		__dma_complete_pa_range(sg->dma_address, sg->length,
 					direction);
 	}
@@ -245,7 +249,8 @@ static dma_addr_t tile_dma_map_page(struct device *dev, struct page *page,
 	BUG_ON(!valid_dma_direction(direction));
 
 	BUG_ON(offset + size > PAGE_SIZE);
-	__dma_prep_page(page, offset, size, direction);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		__dma_prep_page(page, offset, size, direction);
 
 	return page_to_pa(page) + offset;
 }
@@ -256,6 +261,9 @@ static void tile_dma_unmap_page(struct device *dev, dma_addr_t dma_address,
 {
 	BUG_ON(!valid_dma_direction(direction));
 
+	if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+		return;
+
 	__dma_complete_page(pfn_to_page(PFN_DOWN(dma_address)),
 			    dma_address & (PAGE_SIZE - 1), size, direction);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
