Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 2855E8D0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 20:00:51 -0500 (EST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MFP00DNQUTDK680@mailout1.samsung.com> for
 linux-mm@kvack.org; Fri, 28 Dec 2012 10:00:49 +0900 (KST)
Received: from daeinki-desktop.10.32.193.11 ([10.90.51.53])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MFP00H0HUTD0A30@mmp1.samsung.com> for linux-mm@kvack.org;
 Fri, 28 Dec 2012 10:00:49 +0900 (KST)
From: daeinki@gmail.com
Subject: [RFC] ARM: DMA-Mapping: add a new attribute to clear buffer
Date: Fri, 28 Dec 2012 10:00:33 +0900
Message-id: <1356656433-2278-1-git-send-email-daeinki@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: m.szyprowski@samsung.com, kyungmin.park@samsung.com, Inki Dae <inki.dae@samsung.com>

From: Inki Dae <inki.dae@samsung.com>

This patch adds a new attribute, DMA_ATTR_SKIP_BUFFER_CLEAR
to skip buffer clearing. The buffer clearing also flushes CPU cache
so this operation has performance deterioration a little bit.

With this patch, allocated buffer region is cleared as default.
So if you want to skip the buffer clearing, just set this attribute.

But this flag should be used carefully because this use might get
access to some vulnerable content such as security data. So with this
patch, we make sure that all pages will be somehow cleared before
exposing to userspace.

For example, let's say that the security data had been stored
in some memory and freed without clearing it.
And then malicious process allocated the region though some buffer
allocator such as gem and ion without clearing it, and requested blit
operation with cleared another buffer though gpu or other drivers.
At this time, the malicious process could access the security data.

Signed-off-by: Inki Dae <inki.dae@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/mm/dma-mapping.c |    6 ++++--
 include/linux/dma-attrs.h |    1 +
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 6b2fb87..fbe9dff 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1058,7 +1058,8 @@ static struct page **__iommu_alloc_buffer(struct device *dev, size_t size,
 		if (!page)
 			goto error;
 
-		__dma_clear_buffer(page, size);
+		if (!dma_get_attr(DMA_ATTR_SKIP_BUFFER_CLEAR, attrs))
+			__dma_clear_buffer(page, size);
 
 		for (i = 0; i < count; i++)
 			pages[i] = page + i;
@@ -1082,7 +1083,8 @@ static struct page **__iommu_alloc_buffer(struct device *dev, size_t size,
 				pages[i + j] = pages[i] + j;
 		}
 
-		__dma_clear_buffer(pages[i], PAGE_SIZE << order);
+		if (!dma_get_attr(DMA_ATTR_SKIP_BUFFER_CLEAR, attrs))
+			__dma_clear_buffer(pages[i], PAGE_SIZE << order);
 		i += 1 << order;
 		count -= 1 << order;
 	}
diff --git a/include/linux/dma-attrs.h b/include/linux/dma-attrs.h
index c8e1831..2592c05 100644
--- a/include/linux/dma-attrs.h
+++ b/include/linux/dma-attrs.h
@@ -18,6 +18,7 @@ enum dma_attr {
 	DMA_ATTR_NO_KERNEL_MAPPING,
 	DMA_ATTR_SKIP_CPU_SYNC,
 	DMA_ATTR_FORCE_CONTIGUOUS,
+	DMA_ATTR_SKIP_BUFFER_CLEAR,
 	DMA_ATTR_MAX,
 };
 
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
