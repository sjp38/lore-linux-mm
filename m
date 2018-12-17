Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Tue, 18 Dec 2018 01:54:48 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH v4 6/9] iommu/dma-iommu.c: Convert to use vm_insert_range
Message-ID: <20181217202448.GA14918@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, joro@8bytes.org
Cc: iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Convert to use vm_insert_range() to map range of kernel
memory to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Matthew Wilcox <willy@infradead.org>
---
 drivers/iommu/dma-iommu.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
index d1b0475..de7ffd8 100644
--- a/drivers/iommu/dma-iommu.c
+++ b/drivers/iommu/dma-iommu.c
@@ -622,17 +622,10 @@ struct page **iommu_dma_alloc(struct device *dev, size_t size, gfp_t gfp,
 
 int iommu_dma_mmap(struct page **pages, size_t size, struct vm_area_struct *vma)
 {
-	unsigned long uaddr = vma->vm_start;
-	unsigned int i, count = PAGE_ALIGN(size) >> PAGE_SHIFT;
-	int ret = -ENXIO;
+	unsigned long count = PAGE_ALIGN(size) >> PAGE_SHIFT;
 
-	for (i = vma->vm_pgoff; i < count && uaddr < vma->vm_end; i++) {
-		ret = vm_insert_page(vma, uaddr, pages[i]);
-		if (ret)
-			break;
-		uaddr += PAGE_SIZE;
-	}
-	return ret;
+	return vm_insert_range(vma, vma->vm_start, pages + vma->vm_pgoff,
+				count - vma->vm_pgoff);
 }
 
 static dma_addr_t __iommu_dma_map(struct device *dev, phys_addr_t phys,
-- 
1.9.1
