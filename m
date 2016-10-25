Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE4B6B0282
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 17:38:38 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u84so146458032pfj.6
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 14:38:38 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id g80si22701150pfb.126.2016.10.25.14.38.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 14:38:37 -0700 (PDT)
Subject: [net-next PATCH 13/27] arch/microblaze: Add option to skip DMA sync
 as a part of map and unmap
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Tue, 25 Oct 2016 11:37:57 -0400
Message-ID: <20161025153757.4815.8960.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Michal Simek <monstr@monstr.eu>, davem@davemloft.net, brouer@redhat.com

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
