Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id B14416B02A1
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 13:14:51 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id r13so9817302pag.1
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 10:14:51 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id cn3si3445032pad.137.2016.11.02.10.14.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 10:14:51 -0700 (PDT)
Subject: [mm PATCH v2 08/26] arch/c6x: Add option to skip sync on DMA map
 and unmap
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 02 Nov 2016 07:13:54 -0400
Message-ID: <20161102111342.79519.23149.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Mark Salter <msalter@redhat.com>

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
later via a sync_for_cpu or sync_for_device call.

Acked-by: Mark Salter <msalter@redhat.com>
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
