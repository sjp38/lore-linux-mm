Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 0E0B86B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 02:11:13 -0400 (EDT)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Subject: [v2 2/4] ARM: dma-mapping: Use kzalloc() with GFP_ATOMIC
Date: Thu, 23 Aug 2012 09:10:27 +0300
Message-ID: <1345702229-9539-3-git-send-email-hdoyu@nvidia.com>
In-Reply-To: <1345702229-9539-1-git-send-email-hdoyu@nvidia.com>
References: <1345702229-9539-1-git-send-email-hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: m.szyprowski@samsung.com
Cc: Hiroshi Doyu <hdoyu@nvidia.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com, arnd@arndb.de, linux@arm.linux.org.uk, chunsang.jeong@linaro.org, vdumpa@nvidia.com, konrad.wilk@oracle.com, subashrp@gmail.com, minchan@kernel.org, pullip.cho@samsung.com

Use kzalloc() with GFP_ATOMIC instead of vzalloc(). At freeing,
__in_atomic_pool() checks if it comes from atomic_pool or not.

Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
---
 arch/arm/mm/dma-mapping.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index aca2fd0..b64475a 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1029,7 +1029,7 @@ static struct page **__iommu_alloc_buffer(struct device *dev, size_t size, gfp_t
 	int array_size = count * sizeof(struct page *);
 	int i = 0;
 
-	if (array_size <= PAGE_SIZE)
+	if ((array_size <= PAGE_SIZE) || (gfp & GFP_ATOMIC))
 		pages = kzalloc(array_size, gfp);
 	else
 		pages = vzalloc(array_size);
@@ -1061,7 +1061,7 @@ error:
 	while (i--)
 		if (pages[i])
 			__free_pages(pages[i], 0);
-	if (array_size <= PAGE_SIZE)
+	if ((array_size <= PAGE_SIZE) || (gfp & GFP_ATOMIC))
 		kfree(pages);
 	else
 		vfree(pages);
@@ -1076,7 +1076,8 @@ static int __iommu_free_buffer(struct device *dev, struct page **pages, size_t s
 	for (i = 0; i < count; i++)
 		if (pages[i])
 			__free_pages(pages[i], 0);
-	if (array_size <= PAGE_SIZE)
+	if ((array_size <= PAGE_SIZE) ||
+	    __in_atomic_pool(page_address(pages[0]), size))
 		kfree(pages);
 	else
 		vfree(pages);
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
