Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id E01B66B0044
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 04:30:13 -0400 (EDT)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Subject: [v3 3/4] ARM: dma-mapping: Introduce __atomic_get_pages() for __iommu_get_pages()
Date: Fri, 24 Aug 2012 11:29:04 +0300
Message-ID: <1345796945-21115-4-git-send-email-hdoyu@nvidia.com>
In-Reply-To: <1345796945-21115-1-git-send-email-hdoyu@nvidia.com>
References: <1345796945-21115-1-git-send-email-hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: m.szyprowski@samsung.com
Cc: Hiroshi Doyu <hdoyu@nvidia.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com, arnd@arndb.de, linux@arm.linux.org.uk, chunsang.jeong@linaro.org, vdumpa@nvidia.com, konrad.wilk@oracle.com, subashrp@gmail.com, minchan@kernel.org, pullip.cho@samsung.com

Support atomic allocation in __iommu_get_pages().

Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
---
 arch/arm/mm/dma-mapping.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 508fde1..58a852b 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -501,6 +501,15 @@ static void *__alloc_from_pool(size_t size, struct page **ret_page)
 	return ptr;
 }
 
+static struct page **__atomic_get_pages(void *addr)
+{
+	struct dma_pool *pool = &atomic_pool;
+	struct page **pages = pool->pages;
+	int offs = (addr - pool->vaddr) >> PAGE_SHIFT;
+
+	return pages + offs;
+}
+
 static bool __in_atomic_pool(void *start, size_t size)
 {
 	struct dma_pool *pool = &atomic_pool;
@@ -1184,6 +1193,9 @@ static struct page **__iommu_get_pages(void *cpu_addr, struct dma_attrs *attrs)
 {
 	struct vm_struct *area;
 
+	if (__in_atomic_pool(cpu_addr, PAGE_SIZE))
+		return __atomic_get_pages(cpu_addr);
+
 	if (dma_get_attr(DMA_ATTR_NO_KERNEL_MAPPING, attrs))
 		return cpu_addr;
 
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
