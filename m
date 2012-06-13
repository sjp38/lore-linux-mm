Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id F10E36B0072
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 07:50:54 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (mailout2.samsung.com [203.254.224.25])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M5K006RT0WJQY80@mailout2.samsung.com> for
 linux-mm@kvack.org; Wed, 13 Jun 2012 20:50:53 +0900 (KST)
Received: from mcdsrvbld02.digital.local ([106.116.37.23])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M5K00JMG0WB4X70@mmp1.samsung.com> for linux-mm@kvack.org;
 Wed, 13 Jun 2012 20:50:53 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv2 1/6] common: DMA-mapping: add DMA_ATTR_NO_KERNEL_MAPPING
 attribute
Date: Wed, 13 Jun 2012 13:50:13 +0200
Message-id: <1339588218-24398-2-git-send-email-m.szyprowski@samsung.com>
In-reply-to: <1339588218-24398-1-git-send-email-m.szyprowski@samsung.com>
References: <1339588218-24398-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subash.ramaswamy@linaro.org>, Sumit Semwal <sumit.semwal@linaro.org>, Abhinav Kochhar <abhinav.k@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>

This patch adds DMA_ATTR_NO_KERNEL_MAPPING attribute which lets the
platform to avoid creating a kernel virtual mapping for the allocated
buffer. On some architectures creating such mapping is non-trivial task
and consumes very limited resources (like kernel virtual address space
or dma consistent address space). Buffers allocated with this attribute
can be only passed to user space by calling dma_mmap_attrs().

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Reviewed-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 Documentation/DMA-attributes.txt |   18 ++++++++++++++++++
 include/linux/dma-attrs.h        |    1 +
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/Documentation/DMA-attributes.txt b/Documentation/DMA-attributes.txt
index 5c72eed..725580d 100644
--- a/Documentation/DMA-attributes.txt
+++ b/Documentation/DMA-attributes.txt
@@ -49,3 +49,21 @@ DMA_ATTR_NON_CONSISTENT lets the platform to choose to return either
 consistent or non-consistent memory as it sees fit.  By using this API,
 you are guaranteeing to the platform that you have all the correct and
 necessary sync points for this memory in the driver.
+
+DMA_ATTR_NO_KERNEL_MAPPING
+--------------------------
+
+DMA_ATTR_NO_KERNEL_MAPPING lets the platform to avoid creating a kernel
+virtual mapping for the allocated buffer. On some architectures creating
+such mapping is non-trivial task and consumes very limited resources
+(like kernel virtual address space or dma consistent address space).
+Buffers allocated with this attribute can be only passed to user space
+by calling dma_mmap_attrs(). By using this API, you are guaranteeing
+that you won't dereference the pointer returned by dma_alloc_attr(). You
+can threat it as a cookie that must be passed to dma_mmap_attrs() and
+dma_free_attrs(). Make sure that both of these also get this attribute
+set on each call.
+
+Since it is optional for platforms to implement
+DMA_ATTR_NO_KERNEL_MAPPING, those that do not will simply ignore the
+attribute and exhibit default behavior.
diff --git a/include/linux/dma-attrs.h b/include/linux/dma-attrs.h
index 547ab56..a37c10c 100644
--- a/include/linux/dma-attrs.h
+++ b/include/linux/dma-attrs.h
@@ -15,6 +15,7 @@ enum dma_attr {
 	DMA_ATTR_WEAK_ORDERING,
 	DMA_ATTR_WRITE_COMBINE,
 	DMA_ATTR_NON_CONSISTENT,
+	DMA_ATTR_NO_KERNEL_MAPPING,
 	DMA_ATTR_MAX,
 };
 
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
