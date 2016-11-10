Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 88C6F28025B
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 12:36:40 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id o1so41341846ito.7
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 09:36:40 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id xz8si5039219pab.182.2016.11.10.09.36.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 09:36:39 -0800 (PST)
Subject: [mm PATCH v3 14/23] arch/parisc: Add option to skip DMA sync as a
 part of map and unmap
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Thu, 10 Nov 2016 06:35:29 -0500
Message-ID: <20161110113529.76501.44762.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: netdev@vger.kernel.org, Helge Deller <deller@gmx.de>, "James E.J. Bottomley" <jejb@parisc-linux.org>, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
via a sync_for_cpu or sync_for_device call.

Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: Helge Deller <deller@gmx.de>
Cc: linux-parisc@vger.kernel.org
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/parisc/kernel/pci-dma.c |   20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

diff --git a/arch/parisc/kernel/pci-dma.c b/arch/parisc/kernel/pci-dma.c
index 02d9ed0..be55ede 100644
--- a/arch/parisc/kernel/pci-dma.c
+++ b/arch/parisc/kernel/pci-dma.c
@@ -459,7 +459,9 @@ static dma_addr_t pa11_dma_map_page(struct device *dev, struct page *page,
 	void *addr = page_address(page) + offset;
 	BUG_ON(direction == DMA_NONE);
 
-	flush_kernel_dcache_range((unsigned long) addr, size);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		flush_kernel_dcache_range((unsigned long) addr, size);
+
 	return virt_to_phys(addr);
 }
 
@@ -469,8 +471,11 @@ static void pa11_dma_unmap_page(struct device *dev, dma_addr_t dma_handle,
 {
 	BUG_ON(direction == DMA_NONE);
 
+	if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+		return;
+
 	if (direction == DMA_TO_DEVICE)
-	    return;
+		return;
 
 	/*
 	 * For PCI_DMA_FROMDEVICE this flush is not necessary for the
@@ -479,7 +484,6 @@ static void pa11_dma_unmap_page(struct device *dev, dma_addr_t dma_handle,
 	 */
 
 	flush_kernel_dcache_range((unsigned long) phys_to_virt(dma_handle), size);
-	return;
 }
 
 static int pa11_dma_map_sg(struct device *dev, struct scatterlist *sglist,
@@ -496,6 +500,10 @@ static int pa11_dma_map_sg(struct device *dev, struct scatterlist *sglist,
 
 		sg_dma_address(sg) = (dma_addr_t) virt_to_phys(vaddr);
 		sg_dma_len(sg) = sg->length;
+
+		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+			continue;
+
 		flush_kernel_dcache_range(vaddr, sg->length);
 	}
 	return nents;
@@ -510,14 +518,16 @@ static void pa11_dma_unmap_sg(struct device *dev, struct scatterlist *sglist,
 
 	BUG_ON(direction == DMA_NONE);
 
+	if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+		return;
+
 	if (direction == DMA_TO_DEVICE)
-	    return;
+		return;
 
 	/* once we do combining we'll need to use phys_to_virt(sg_dma_address(sglist)) */
 
 	for_each_sg(sglist, sg, nents, i)
 		flush_kernel_vmap_range(sg_virt(sg), sg->length);
-	return;
 }
 
 static void pa11_dma_sync_single_for_cpu(struct device *dev,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
