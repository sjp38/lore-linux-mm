Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id E85406B0070
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 11:40:14 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LVY005CP3MX7770@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 09 Dec 2011 16:40:09 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LVY002LT3MWJQ@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 09 Dec 2011 16:40:09 +0000 (GMT)
Date: Fri, 09 Dec 2011 17:39:56 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 6/8] common: dma-mapping: change alloc/free_coherent method to
 more generic alloc/free_attrs
In-reply-to: <1323448798-18184-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1323448798-18184-7-git-send-email-m.szyprowski@samsung.com>
References: <1323448798-18184-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Introduce new alloc/free/mmap methods that take attributes argument.
alloc/free_coherent can be implemented on top of the new alloc/free
calls with NULL attributes. dma_alloc_non_coherent can be implemented
using DMA_ATTR_NONCOHERENT attribute, dma_alloc_writecombine can also
use separate DMA_ATTR_WRITECOMBINE attribute. This way the drivers will
get more generic, platform independent way of allocating dma memory
buffers with specific parameters.

One more attribute can be usefull: DMA_ATTR_NOKERNELVADDR. Buffers with
such attribute will not have valid kernel virtual address. They might be
usefull for drivers that only exports the DMA buffers to userspace (like
for example V4L2 or ALSA).

mmap method is introduced to let the drivers create a user space mapping
for a DMA buffer in generic, architecture independent way.

TODO: update all dma_map_ops clients for all architectures

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 include/linux/dma-mapping.h |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index e13117c..b903a20 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -9,10 +9,15 @@
 #include <linux/scatterlist.h>
 
 struct dma_map_ops {
-	void* (*alloc_coherent)(struct device *dev, size_t size,
-				dma_addr_t *dma_handle, gfp_t gfp);
-	void (*free_coherent)(struct device *dev, size_t size,
-			      void *vaddr, dma_addr_t dma_handle);
+	void* (*alloc)(struct device *dev, size_t size,
+				dma_addr_t *dma_handle, gfp_t gfp,
+				struct dma_attrs *attrs);
+	void (*free)(struct device *dev, size_t size,
+			      void *vaddr, dma_addr_t dma_handle,
+			      struct dma_attrs *attrs);
+	int (*mmap)(struct device *, struct vm_area_struct *,
+			  void *, dma_addr_t, size_t, struct dma_attrs *attrs);
+
 	dma_addr_t (*map_page)(struct device *dev, struct page *page,
 			       unsigned long offset, size_t size,
 			       enum dma_data_direction dir,
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
