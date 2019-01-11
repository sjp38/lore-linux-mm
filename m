Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 325338E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 10:07:12 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id b17so10490592pfc.11
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 07:07:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l12sor3909024pfb.43.2019.01.11.07.07.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 07:07:11 -0800 (PST)
Date: Fri, 11 Jan 2019 20:41:11 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH 6/9] iommu/dma-iommu.c: Convert to use vm_insert_range
Message-ID: <20190111151110.GA2798@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, joro@8bytes.org, linux@armlinux.org.uk, robin.murphy@arm.com
Cc: iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Convert to use vm_insert_range() to map range of kernel
memory to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 drivers/iommu/dma-iommu.c | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
index d1b0475..802de67 100644
--- a/drivers/iommu/dma-iommu.c
+++ b/drivers/iommu/dma-iommu.c
@@ -622,17 +622,7 @@ struct page **iommu_dma_alloc(struct device *dev, size_t size, gfp_t gfp,
 
 int iommu_dma_mmap(struct page **pages, size_t size, struct vm_area_struct *vma)
 {
-	unsigned long uaddr = vma->vm_start;
-	unsigned int i, count = PAGE_ALIGN(size) >> PAGE_SHIFT;
-	int ret = -ENXIO;
-
-	for (i = vma->vm_pgoff; i < count && uaddr < vma->vm_end; i++) {
-		ret = vm_insert_page(vma, uaddr, pages[i]);
-		if (ret)
-			break;
-		uaddr += PAGE_SIZE;
-	}
-	return ret;
+	return vm_insert_range(vma, pages, PAGE_ALIGN(size) >> PAGE_SHIFT);
 }
 
 static dma_addr_t __iommu_dma_map(struct device *dev, phys_addr_t phys,
-- 
1.9.1
