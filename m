Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 06ADB280250
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:06:02 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id xx10so2564596pac.2
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:06:01 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id p5si6494280pax.322.2016.10.24.11.06.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 11:06:01 -0700 (PDT)
Subject: [net-next PATCH RFC 11/26] arch/metag: Add option to skip DMA sync
 as a part of map and unmap
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 24 Oct 2016 08:05:24 -0400
Message-ID: <20161024120524.16276.61479.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: brouer@redhat.com, James Hogan <james.hogan@imgtec.com>, linux-metag@vger.kernel.org, davem@davemloft.net

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
via a sync_for_cpu or sync_for_device call.

Cc: James Hogan <james.hogan@imgtec.com>
Cc: linux-metag@vger.kernel.org
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/metag/kernel/dma.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/arch/metag/kernel/dma.c b/arch/metag/kernel/dma.c
index 0db31e2..91968d9 100644
--- a/arch/metag/kernel/dma.c
+++ b/arch/metag/kernel/dma.c
@@ -484,8 +484,9 @@ static dma_addr_t metag_dma_map_page(struct device *dev, struct page *page,
 		unsigned long offset, size_t size,
 		enum dma_data_direction direction, unsigned long attrs)
 {
-	dma_sync_for_device((void *)(page_to_phys(page) + offset), size,
-			    direction);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		dma_sync_for_device((void *)(page_to_phys(page) + offset),
+				    size, direction);
 	return page_to_phys(page) + offset;
 }
 
@@ -493,7 +494,8 @@ static void metag_dma_unmap_page(struct device *dev, dma_addr_t dma_address,
 		size_t size, enum dma_data_direction direction,
 		unsigned long attrs)
 {
-	dma_sync_for_cpu(phys_to_virt(dma_address), size, direction);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		dma_sync_for_cpu(phys_to_virt(dma_address), size, direction);
 }
 
 static int metag_dma_map_sg(struct device *dev, struct scatterlist *sglist,
@@ -507,6 +509,10 @@ static int metag_dma_map_sg(struct device *dev, struct scatterlist *sglist,
 		BUG_ON(!sg_page(sg));
 
 		sg->dma_address = sg_phys(sg);
+
+		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+			continue;
+
 		dma_sync_for_device(sg_virt(sg), sg->length, direction);
 	}
 
@@ -525,6 +531,10 @@ static void metag_dma_unmap_sg(struct device *dev, struct scatterlist *sglist,
 		BUG_ON(!sg_page(sg));
 
 		sg->dma_address = sg_phys(sg);
+
+		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+			continue;
+
 		dma_sync_for_cpu(sg_virt(sg), sg->length, direction);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
