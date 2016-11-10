Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7393028025B
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 12:36:56 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 83so102907551pfx.1
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 09:36:56 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 20si5963957pgy.294.2016.11.10.09.36.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 09:36:55 -0800 (PST)
Subject: [mm PATCH v3 17/23] arch/sparc: Add option to skip DMA sync as a
 part of map and unmap
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Thu, 10 Nov 2016 06:35:45 -0500
Message-ID: <20161110113544.76501.40008.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: sparclinux@vger.kernel.org, netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
via a sync_for_cpu or sync_for_device call.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: sparclinux@vger.kernel.org
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/sparc/kernel/iommu.c  |    4 ++--
 arch/sparc/kernel/ioport.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/sparc/kernel/iommu.c b/arch/sparc/kernel/iommu.c
index 5c615ab..8fda4e4 100644
--- a/arch/sparc/kernel/iommu.c
+++ b/arch/sparc/kernel/iommu.c
@@ -415,7 +415,7 @@ static void dma_4u_unmap_page(struct device *dev, dma_addr_t bus_addr,
 		ctx = (iopte_val(*base) & IOPTE_CONTEXT) >> 47UL;
 
 	/* Step 1: Kick data out of streaming buffers if necessary. */
-	if (strbuf->strbuf_enabled)
+	if (strbuf->strbuf_enabled && !(attrs & DMA_ATTR_SKIP_CPU_SYNC))
 		strbuf_flush(strbuf, iommu, bus_addr, ctx,
 			     npages, direction);
 
@@ -640,7 +640,7 @@ static void dma_4u_unmap_sg(struct device *dev, struct scatterlist *sglist,
 		base = iommu->page_table + entry;
 
 		dma_handle &= IO_PAGE_MASK;
-		if (strbuf->strbuf_enabled)
+		if (strbuf->strbuf_enabled && !(attrs & DMA_ATTR_SKIP_CPU_SYNC))
 			strbuf_flush(strbuf, iommu, dma_handle, ctx,
 				     npages, direction);
 
diff --git a/arch/sparc/kernel/ioport.c b/arch/sparc/kernel/ioport.c
index 2344103..6ffaec4 100644
--- a/arch/sparc/kernel/ioport.c
+++ b/arch/sparc/kernel/ioport.c
@@ -527,7 +527,7 @@ static dma_addr_t pci32_map_page(struct device *dev, struct page *page,
 static void pci32_unmap_page(struct device *dev, dma_addr_t ba, size_t size,
 			     enum dma_data_direction dir, unsigned long attrs)
 {
-	if (dir != PCI_DMA_TODEVICE)
+	if (dir != PCI_DMA_TODEVICE && !(attrs & DMA_ATTR_SKIP_CPU_SYNC))
 		dma_make_coherent(ba, PAGE_ALIGN(size));
 }
 
@@ -572,7 +572,7 @@ static void pci32_unmap_sg(struct device *dev, struct scatterlist *sgl,
 	struct scatterlist *sg;
 	int n;
 
-	if (dir != PCI_DMA_TODEVICE) {
+	if (dir != PCI_DMA_TODEVICE && !(attrs & DMA_ATTR_SKIP_CPU_SYNC)) {
 		for_each_sg(sgl, sg, nents, n) {
 			dma_make_coherent(sg_phys(sg), PAGE_ALIGN(sg->length));
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
