Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6DD280250
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:05:41 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fl2so2586243pad.7
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:05:41 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 123si16642685pgj.89.2016.10.24.11.05.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 11:05:40 -0700 (PDT)
Subject: [net-next PATCH RFC 07/26] arch/c6x: Add option to skip sync on DMA
 map and unmap
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 24 Oct 2016 08:05:03 -0400
Message-ID: <20161024120503.16276.44357.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: brouer@redhat.com, davem@davemloft.net, Mark Salter <msalter@redhat.com>, linux-c6x-dev@linux-c6x.org, Aurelien Jacquiot <a-jacquiot@ti.com>

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
later via a sync_for_cpu or sync_for_device call.

Cc: Mark Salter <msalter@redhat.com>
Cc: Aurelien Jacquiot <a-jacquiot@ti.com>
Cc: linux-c6x-dev@linux-c6x.org
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/c6x/kernel/dma.c |   16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/arch/c6x/kernel/dma.c b/arch/c6x/kernel/dma.c
index db4a6a3..d28df74 100644
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
@@ -72,8 +76,10 @@ static void c6x_dma_unmap_sg(struct device *dev, struct scatterlist *sglist,
 	struct scatterlist *sg;
 	int i;
 
-	for_each_sg(sglist, sg, nents, i)
-		c6x_dma_sync(sg_dma_address(sg), sg->length, dir);
+	for_each_sg(sglist, sg, nents, i) {
+		if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+			c6x_dma_sync(sg_dma_address(sg), sg->length, dir);
+	}
 
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
