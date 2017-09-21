Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9466B6B0274
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 05:00:25 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 11so10601080pge.4
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 02:00:25 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0055.outbound.protection.outlook.com. [104.47.34.55])
        by mx.google.com with ESMTPS id 138si740261pgf.572.2017.09.21.02.00.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 21 Sep 2017 02:00:24 -0700 (PDT)
From: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>
Subject: [PATCH 4/4] iommu/dma, numa: Use NUMA aware memory allocations in __iommu_dma_alloc_pages
Date: Thu, 21 Sep 2017 14:29:22 +0530
Message-Id: <20170921085922.11659-5-ganapatrao.kulkarni@cavium.com>
In-Reply-To: <20170921085922.11659-1-ganapatrao.kulkarni@cavium.com>
References: <20170921085922.11659-1-ganapatrao.kulkarni@cavium.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Will.Deacon@arm.com, robin.murphy@arm.com, lorenzo.pieralisi@arm.com, hanjun.guo@linaro.org, joro@8bytes.org, vbabka@suse.cz, akpm@linux-foundation.org, mhocko@suse.com, Tomasz.Nowicki@cavium.com, Robert.Richter@cavium.com, jnair@caviumnetworks.com, gklkml16@gmail.com

Change function __iommu_dma_alloc_pages to allocate memory/pages
for dma from respective device numa node.

Signed-off-by: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>
---
 drivers/iommu/dma-iommu.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
index 9d1cebe..0626b58 100644
--- a/drivers/iommu/dma-iommu.c
+++ b/drivers/iommu/dma-iommu.c
@@ -428,20 +428,21 @@ static void __iommu_dma_free_pages(struct page **pages, int count)
 	kvfree(pages);
 }
 
-static struct page **__iommu_dma_alloc_pages(unsigned int count,
-		unsigned long order_mask, gfp_t gfp)
+static struct page **__iommu_dma_alloc_pages(struct device *dev,
+		unsigned int count, unsigned long order_mask, gfp_t gfp)
 {
 	struct page **pages;
 	unsigned int i = 0, array_size = count * sizeof(*pages);
+	int numa_node = dev_to_node(dev);
 
 	order_mask &= (2U << MAX_ORDER) - 1;
 	if (!order_mask)
 		return NULL;
 
 	if (array_size <= PAGE_SIZE)
-		pages = kzalloc(array_size, GFP_KERNEL);
+		pages = kzalloc_node(array_size, GFP_KERNEL, numa_node);
 	else
-		pages = vzalloc(array_size);
+		pages = vzalloc_node(array_size, numa_node);
 	if (!pages)
 		return NULL;
 
@@ -462,8 +463,9 @@ static struct page **__iommu_dma_alloc_pages(unsigned int count,
 			unsigned int order = __fls(order_mask);
 
 			order_size = 1U << order;
-			page = alloc_pages((order_mask - order_size) ?
-					   gfp | __GFP_NORETRY : gfp, order);
+			page = alloc_pages_node(numa_node,
+					(order_mask - order_size) ?
+				   gfp | __GFP_NORETRY : gfp, order);
 			if (!page)
 				continue;
 			if (!order)
@@ -548,7 +550,8 @@ struct page **iommu_dma_alloc(struct device *dev, size_t size, gfp_t gfp,
 		alloc_sizes = min_size;
 
 	count = PAGE_ALIGN(size) >> PAGE_SHIFT;
-	pages = __iommu_dma_alloc_pages(count, alloc_sizes >> PAGE_SHIFT, gfp);
+	pages = __iommu_dma_alloc_pages(dev, count, alloc_sizes >> PAGE_SHIFT,
+			gfp);
 	if (!pages)
 		return NULL;
 
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
