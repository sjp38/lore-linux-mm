Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id ECC3228025B
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 12:36:19 -0500 (EST)
Received: by mail-pa0-f69.google.com with SMTP id hc3so85619515pac.4
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 09:36:19 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id p123si5995882pga.86.2016.11.10.09.36.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 09:36:19 -0800 (PST)
Subject: [mm PATCH v3 10/23] arch/microblaze: Add option to skip DMA sync as
 a part of map and unmap
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Thu, 10 Nov 2016 06:35:08 -0500
Message-ID: <20161110113508.76501.77583.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: netdev@vger.kernel.org, Michal Simek <monstr@monstr.eu>, linux-kernel@vger.kernel.org

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
via a sync_for_cpu or sync_for_device call.

Cc: Michal Simek <monstr@monstr.eu>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/microblaze/kernel/dma.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/arch/microblaze/kernel/dma.c b/arch/microblaze/kernel/dma.c
index ec04dc1..818daf2 100644
--- a/arch/microblaze/kernel/dma.c
+++ b/arch/microblaze/kernel/dma.c
@@ -61,6 +61,10 @@ static int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl,
 	/* FIXME this part of code is untested */
 	for_each_sg(sgl, sg, nents, i) {
 		sg->dma_address = sg_phys(sg);
+
+		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+			continue;
+
 		__dma_sync(page_to_phys(sg_page(sg)) + sg->offset,
 							sg->length, direction);
 	}
@@ -80,7 +84,8 @@ static inline dma_addr_t dma_direct_map_page(struct device *dev,
 					     enum dma_data_direction direction,
 					     unsigned long attrs)
 {
-	__dma_sync(page_to_phys(page) + offset, size, direction);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		__dma_sync(page_to_phys(page) + offset, size, direction);
 	return page_to_phys(page) + offset;
 }
 
@@ -95,7 +100,8 @@ static inline void dma_direct_unmap_page(struct device *dev,
  * phys_to_virt is here because in __dma_sync_page is __virt_to_phys and
  * dma_address is physical address
  */
-	__dma_sync(dma_address, size, direction);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		__dma_sync(dma_address, size, direction);
 }
 
 static inline void

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
