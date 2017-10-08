Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BC8736B0260
	for <linux-mm@kvack.org>; Sun,  8 Oct 2017 00:09:11 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t10so8899545pgo.2
        for <linux-mm@kvack.org>; Sat, 07 Oct 2017 21:09:11 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id s187si4218967pfb.220.2017.10.07.21.09.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Oct 2017 21:09:10 -0700 (PDT)
Subject: [PATCH v8 1/2] iommu: up-level sg_num_pages() from amd-iommu
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 07 Oct 2017 21:02:45 -0700
Message-ID: <150743535284.13602.15352862726070248486.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150732937720.22363.1037155753760964267.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150732937720.22363.1037155753760964267.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-rdma@vger.kernel.org, linux-api@vger.kernel.org, Joerg Roedel <joro@8bytes.org>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org

iommu_sg_num_pages() is a helper that walks a scattlerlist and counts
pages taking segment boundaries and iommu_num_pages() into account.
Up-level it for determining the IOVA range that dma_map_ops established
at dma_map_sg() time. The intent is to iommu_unmap() the IOVA range in
advance of freeing IOVA range.

Cc: Joerg Roedel <joro@8bytes.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
New patch in v8.

 drivers/iommu/amd_iommu.c |   30 ++----------------------------
 drivers/iommu/iommu.c     |   27 +++++++++++++++++++++++++++
 include/linux/iommu.h     |    2 ++
 3 files changed, 31 insertions(+), 28 deletions(-)

diff --git a/drivers/iommu/amd_iommu.c b/drivers/iommu/amd_iommu.c
index c8e1a45af182..4795b0823469 100644
--- a/drivers/iommu/amd_iommu.c
+++ b/drivers/iommu/amd_iommu.c
@@ -2459,32 +2459,6 @@ static void unmap_page(struct device *dev, dma_addr_t dma_addr, size_t size,
 	__unmap_single(dma_dom, dma_addr, size, dir);
 }
 
-static int sg_num_pages(struct device *dev,
-			struct scatterlist *sglist,
-			int nelems)
-{
-	unsigned long mask, boundary_size;
-	struct scatterlist *s;
-	int i, npages = 0;
-
-	mask          = dma_get_seg_boundary(dev);
-	boundary_size = mask + 1 ? ALIGN(mask + 1, PAGE_SIZE) >> PAGE_SHIFT :
-				   1UL << (BITS_PER_LONG - PAGE_SHIFT);
-
-	for_each_sg(sglist, s, nelems, i) {
-		int p, n;
-
-		s->dma_address = npages << PAGE_SHIFT;
-		p = npages % boundary_size;
-		n = iommu_num_pages(sg_phys(s), s->length, PAGE_SIZE);
-		if (p + n > boundary_size)
-			npages += boundary_size - p;
-		npages += n;
-	}
-
-	return npages;
-}
-
 /*
  * The exported map_sg function for dma_ops (handles scatter-gather
  * lists).
@@ -2507,7 +2481,7 @@ static int map_sg(struct device *dev, struct scatterlist *sglist,
 	dma_dom  = to_dma_ops_domain(domain);
 	dma_mask = *dev->dma_mask;
 
-	npages = sg_num_pages(dev, sglist, nelems);
+	npages = iommu_sg_num_pages(dev, sglist, nelems);
 
 	address = dma_ops_alloc_iova(dev, dma_dom, npages, dma_mask);
 	if (address == AMD_IOMMU_MAPPING_ERROR)
@@ -2585,7 +2559,7 @@ static void unmap_sg(struct device *dev, struct scatterlist *sglist,
 
 	startaddr = sg_dma_address(sglist) & PAGE_MASK;
 	dma_dom   = to_dma_ops_domain(domain);
-	npages    = sg_num_pages(dev, sglist, nelems);
+	npages    = iommu_sg_num_pages(dev, sglist, nelems);
 
 	__unmap_single(dma_dom, startaddr, npages << PAGE_SHIFT, dir);
 }
diff --git a/drivers/iommu/iommu.c b/drivers/iommu/iommu.c
index 3de5c0bcb5cc..cfe6eeea3578 100644
--- a/drivers/iommu/iommu.c
+++ b/drivers/iommu/iommu.c
@@ -33,6 +33,7 @@
 #include <linux/bitops.h>
 #include <linux/property.h>
 #include <trace/events/iommu.h>
+#include <linux/iommu-helper.h>
 
 static struct kset *iommu_group_kset;
 static DEFINE_IDA(iommu_group_ida);
@@ -1631,6 +1632,32 @@ size_t iommu_unmap_fast(struct iommu_domain *domain,
 }
 EXPORT_SYMBOL_GPL(iommu_unmap_fast);
 
+int iommu_sg_num_pages(struct device *dev, struct scatterlist *sglist,
+		int nelems)
+{
+	unsigned long mask, boundary_size;
+	struct scatterlist *s;
+	int i, npages = 0;
+
+	mask = dma_get_seg_boundary(dev);
+	boundary_size = mask + 1 ? ALIGN(mask + 1, PAGE_SIZE) >> PAGE_SHIFT
+		: 1UL << (BITS_PER_LONG - PAGE_SHIFT);
+
+	for_each_sg(sglist, s, nelems, i) {
+		int p, n;
+
+		s->dma_address = npages << PAGE_SHIFT;
+		p = npages % boundary_size;
+		n = iommu_num_pages(sg_phys(s), s->length, PAGE_SIZE);
+		if (p + n > boundary_size)
+			npages += boundary_size - p;
+		npages += n;
+	}
+
+	return npages;
+}
+EXPORT_SYMBOL_GPL(iommu_sg_num_pages);
+
 size_t default_iommu_map_sg(struct iommu_domain *domain, unsigned long iova,
 			 struct scatterlist *sg, unsigned int nents, int prot)
 {
diff --git a/include/linux/iommu.h b/include/linux/iommu.h
index a7f2ac689d29..5b2d20e1475a 100644
--- a/include/linux/iommu.h
+++ b/include/linux/iommu.h
@@ -303,6 +303,8 @@ extern size_t iommu_unmap(struct iommu_domain *domain, unsigned long iova,
 			  size_t size);
 extern size_t iommu_unmap_fast(struct iommu_domain *domain,
 			       unsigned long iova, size_t size);
+extern int iommu_sg_num_pages(struct device *dev, struct scatterlist *sglist,
+		int nelems);
 extern size_t default_iommu_map_sg(struct iommu_domain *domain, unsigned long iova,
 				struct scatterlist *sg,unsigned int nents,
 				int prot);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
