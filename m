Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 14BBD6B027C
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 17:38:10 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x70so101079545pfk.0
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 14:38:10 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id t84si22734706pfa.214.2016.10.25.14.38.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Oct 2016 14:38:09 -0700 (PDT)
Subject: [net-next PATCH 08/27] arch/c6x: Add option to skip sync on DMA map
 and unmap
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Tue, 25 Oct 2016 11:37:30 -0400
Message-ID: <20161025153730.4815.48964.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: brouer@redhat.com, Mark Salter <msalter@redhat.com>, davem@davemloft.net, Aurelien Jacquiot <a-jacquiot@ti.com>

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
later via a sync_for_cpu or sync_for_device call.

Cc: Mark Salter <msalter@redhat.com>
Cc: Aurelien Jacquiot <a-jacquiot@ti.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/c6x/kernel/dma.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/arch/c6x/kernel/dma.c b/arch/c6x/kernel/dma.c
index db4a6a3..6752df3 100644
--- a/arch/c6x/kernel/dma.c
+++ b/arch/c6x/kernel/dma.c
@@ -42,14 +42,17 @@ static dma_addr_t c6x_dma_map_page(struct device *dev, struct page *page,
 {
 	dma_addr_t handle = virt_to_phys(page_address(page) + offset);
 
-	c6x_dma_sync(handle, size, dir);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		c6x_dma_sync(handle, size, dir);
+
 	return handle;
 }
 
 static void c6x_dma_unmap_page(struct device *dev, dma_addr_t handle,
 		size_t size, enum dma_data_direction dir, unsigned long attrs)
 {
-	c6x_dma_sync(handle, size, dir);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		c6x_dma_sync(handle, size, dir);
 }
 
 static int c6x_dma_map_sg(struct device *dev, struct scatterlist *sglist,
@@ -60,7 +63,8 @@ static int c6x_dma_map_sg(struct device *dev, struct scatterlist *sglist,
 
 	for_each_sg(sglist, sg, nents, i) {
 		sg->dma_address = sg_phys(sg);
-		c6x_dma_sync(sg->dma_address, sg->length, dir);
+		if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+			c6x_dma_sync(sg->dma_address, sg->length, dir);
 	}
 
 	return nents;
@@ -72,9 +76,11 @@ static void c6x_dma_unmap_sg(struct device *dev, struct scatterlist *sglist,
 	struct scatterlist *sg;
 	int i;
 
+	if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+		return;
+
 	for_each_sg(sglist, sg, nents, i)
 		c6x_dma_sync(sg_dma_address(sg), sg->length, dir);
-
 }
 
 static void c6x_dma_sync_single_for_cpu(struct device *dev, dma_addr_t handle,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
