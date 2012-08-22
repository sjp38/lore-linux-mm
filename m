Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 19CFA6B0069
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 06:21:06 -0400 (EDT)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Subject: [RFC 2/4] ARM: dma-mapping: IOMMU allocates pages from pool with GFP_ATOMIC
Date: Wed, 22 Aug 2012 13:20:28 +0300
Message-ID: <1345630830-9586-3-git-send-email-hdoyu@nvidia.com>
In-Reply-To: <1345630830-9586-1-git-send-email-hdoyu@nvidia.com>
References: <1345630830-9586-1-git-send-email-hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Hiroshi Doyu <hdoyu@nvidia.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "arnd@arndb.de" <arnd@arndb.de>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "subashrp@gmail.com" <subashrp@gmail.com>, "minchan@kernel.org" <minchan@kernel.org>

Makes use of the same atomic pool from DMA, and skips kernel page
mapping which can involves sleep'able operation at allocating a kernel
page table.

Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
---
 arch/arm/mm/dma-mapping.c |   22 ++++++++++++++++++----
 1 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index aec0c06..9260107 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1028,7 +1028,6 @@ static struct page **__iommu_alloc_buffer(struct device *dev, size_t size,
 	struct page **pages;
 	int count = size >> PAGE_SHIFT;
 	int array_size = count * sizeof(struct page *);
-	int err;
 
 	if (array_size <= PAGE_SIZE)
 		pages = kzalloc(array_size, gfp);
@@ -1037,9 +1036,20 @@ static struct page **__iommu_alloc_buffer(struct device *dev, size_t size,
 	if (!pages)
 		return NULL;
 
-	err = __alloc_fill_pages(&pages, count, gfp);
-	if (err)
-		goto error
+	if (gfp & GFP_ATOMIC) {
+		struct page *page;
+		int i;
+		void *addr = __alloc_from_pool(size, &page);
+		if (!addr)
+			goto err_out;
+
+		for (i = 0; i < count; i++)
+			pages[i] = page + i;
+	} else {
+		int err = __alloc_fill_pages(&pages, count, gfp);
+		if (err)
+			goto error;
+	}
 
 	return pages;
 error:
@@ -1055,6 +1065,10 @@ static int __iommu_free_buffer(struct device *dev, struct page **pages, size_t s
 	int count = size >> PAGE_SHIFT;
 	int array_size = count * sizeof(struct page *);
 	int i;
+
+	if (__free_from_pool(page_address(pages[0]), size))
+		return 0;
+
 	for (i = 0; i < count; i++)
 		if (pages[i])
 			__free_pages(pages[i], 0);
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
