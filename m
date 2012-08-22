Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id F3E276B006C
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 06:21:25 -0400 (EDT)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Subject: [RFC 1/4] ARM: dma-mapping: Refactor out to introduce __alloc_fill_pages
Date: Wed, 22 Aug 2012 13:20:27 +0300
Message-ID: <1345630830-9586-2-git-send-email-hdoyu@nvidia.com>
In-Reply-To: <1345630830-9586-1-git-send-email-hdoyu@nvidia.com>
References: <1345630830-9586-1-git-send-email-hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Hiroshi Doyu <hdoyu@nvidia.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "arnd@arndb.de" <arnd@arndb.de>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "subashrp@gmail.com" <subashrp@gmail.com>, "minchan@kernel.org" <minchan@kernel.org>

__alloc_fill_pages() allocates power of 2 page number allocation at
most repeatedly.

Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
---
 arch/arm/mm/dma-mapping.c |   40 ++++++++++++++++++++++++++++------------
 1 files changed, 28 insertions(+), 12 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 7dc61ed..aec0c06 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -988,19 +988,10 @@ static inline void __free_iova(struct dma_iommu_mapping *mapping,
 	spin_unlock_irqrestore(&mapping->lock, flags);
 }
 
-static struct page **__iommu_alloc_buffer(struct device *dev, size_t size, gfp_t gfp)
+static int __alloc_fill_pages(struct page ***ppages, int count, gfp_t gfp)
 {
-	struct page **pages;
-	int count = size >> PAGE_SHIFT;
-	int array_size = count * sizeof(struct page *);
 	int i = 0;
-
-	if (array_size <= PAGE_SIZE)
-		pages = kzalloc(array_size, gfp);
-	else
-		pages = vzalloc(array_size);
-	if (!pages)
-		return NULL;
+	struct page **pages = *ppages;
 
 	while (count) {
 		int j, order = __fls(count);
@@ -1022,11 +1013,36 @@ static struct page **__iommu_alloc_buffer(struct device *dev, size_t size, gfp_t
 		count -= 1 << order;
 	}
 
-	return pages;
+	return 0;
+
 error:
 	while (i--)
 		if (pages[i])
 			__free_pages(pages[i], 0);
+	return -ENOMEM;
+}
+
+static struct page **__iommu_alloc_buffer(struct device *dev, size_t size,
+					  gfp_t gfp)
+{
+	struct page **pages;
+	int count = size >> PAGE_SHIFT;
+	int array_size = count * sizeof(struct page *);
+	int err;
+
+	if (array_size <= PAGE_SIZE)
+		pages = kzalloc(array_size, gfp);
+	else
+		pages = vzalloc(array_size);
+	if (!pages)
+		return NULL;
+
+	err = __alloc_fill_pages(&pages, count, gfp);
+	if (err)
+		goto error
+
+	return pages;
+error:
 	if (array_size <= PAGE_SIZE)
 		kfree(pages);
 	else
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
