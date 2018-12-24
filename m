Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Mon, 24 Dec 2018 18:51:42 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH v5 2/9] arch/arm/mm/dma-mapping.c: Convert to use
 vm_insert_range
Message-ID: <20181224132142.GA22070@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, linux@armlinux.org.uk, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, treding@nvidia.com, keescook@chromium.org, m.szyprowski@samsung.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

Convert to use vm_insert_range() to map range of kernel
memory to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 arch/arm/mm/dma-mapping.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 661fe48..63467b6 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1582,11 +1582,12 @@ static int __arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct *vma
 		    void *cpu_addr, dma_addr_t dma_addr, size_t size,
 		    unsigned long attrs)
 {
-	unsigned long uaddr = vma->vm_start;
 	unsigned long usize = vma->vm_end - vma->vm_start;
+	unsigned long page_count = vma_pages(vma);
 	struct page **pages = __iommu_get_pages(cpu_addr, attrs);
 	unsigned long nr_pages = PAGE_ALIGN(size) >> PAGE_SHIFT;
 	unsigned long off = vma->vm_pgoff;
+	int err;
 
 	if (!pages)
 		return -ENXIO;
@@ -1595,18 +1596,11 @@ static int __arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct *vma
 		return -ENXIO;
 
 	pages += off;
+	err = vm_insert_range(vma, vma->vm_start, pages, page_count);
+	if (err)
+		pr_err("Remapping memory failed: %d\n", err);
 
-	do {
-		int ret = vm_insert_page(vma, uaddr, *pages++);
-		if (ret) {
-			pr_err("Remapping memory failed: %d\n", ret);
-			return ret;
-		}
-		uaddr += PAGE_SIZE;
-		usize -= PAGE_SIZE;
-	} while (usize > 0);
-
-	return 0;
+	return err;
 }
 static int arm_iommu_mmap_attrs(struct device *dev,
 		struct vm_area_struct *vma, void *cpu_addr,
-- 
1.9.1
