Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5303E6B0276
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 10:56:38 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a7so75029142pfj.3
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 07:56:38 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 38si9354538plc.417.2017.10.10.07.56.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 07:56:37 -0700 (PDT)
Subject: [PATCH v8 13/14] IB/core: use MAP_DIRECT to fix / enable RDMA to
 DAX mappings
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 10 Oct 2017 07:50:12 -0700
Message-ID: <150764701194.16882.9682569707416653741.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150764693502.16882.15848797003793552156.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150764693502.16882.15848797003793552156.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Sean Hefty <sean.hefty@intel.com>, linux-xfs@vger.kernel.org, Jan Kara <jack@suse.cz>, Ashok Raj <ashok.raj@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, linux-api@vger.kernel.org, Joerg Roedel <joro@8bytes.org>, Dave Chinner <david@fromorbit.com>, Jeff Moyer <jmoyer@redhat.com>, iommu@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm@kvack.org, Doug Ledford <dledford@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>, David Woodhouse <dwmw2@infradead.org>, Hal Rosenstock <hal.rosenstock@gmail.com>

Currently the ibverbs core in the kernel is completely unaware of the
dangers of filesystem-DAX mappings. Specifically, the filesystem is free
to move file blocks at will. In the case of DAX, it means that RDMA to a
given file offset can dynamically switch to another file offset, another
file, or free space with no notification to RDMA device to cease
operations. Historically, this lack of communication between the ibverbs
core and filesystem was not a problem because RDMA always targeted
dynamically allocated page cache, so at least the RDMA device would have
valid memory to target even if the file was being modified. With DAX we
need to add coordination since RDMA is bypassing page-cache and going
direct to on-media pages of the file. RDMA to DAX can cause damage if
filesystem blocks move / change state.

Use the new ->lease_direct() operation to get a notification when the
filesystem is invalidating the block map of the file and needs RDMA
operations to stop. Given that the kernel can not be in a position where
it needs to wait indefinitely for userspace to stop a device we need a
mechanism where the kernel can force-revoke access. Towards that end, use
the dma_get_iommu_domain() to both check if the device has domain
mappings that can be invalidated and retrieve the iommu_domain for use
with iommu_unmap.

Once we have that assurance that we can block in-flight I/O when the
file's block map changes then we can safely allow RDMA to DAX.

Cc: Sean Hefty <sean.hefty@intel.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Hal Rosenstock <hal.rosenstock@gmail.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Joerg Roedel <joro@8bytes.org>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Ashok Raj <ashok.raj@intel.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jeff Layton <jlayton@poochiereds.net>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/infiniband/core/umem.c |   90 +++++++++++++++++++++++++++++++++++-----
 include/rdma/ib_umem.h         |    8 ++++
 2 files changed, 86 insertions(+), 12 deletions(-)

diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index 21e60b1e2ff4..5e4598982359 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -36,6 +36,7 @@
 #include <linux/dma-mapping.h>
 #include <linux/sched/signal.h>
 #include <linux/sched/mm.h>
+#include <linux/mapdirect.h>
 #include <linux/export.h>
 #include <linux/hugetlb.h>
 #include <linux/slab.h>
@@ -46,10 +47,16 @@
 
 static void __ib_umem_release(struct ib_device *dev, struct ib_umem *umem, int dirty)
 {
+	struct lease_direct *ld, *_ld;
 	struct scatterlist *sg;
 	struct page *page;
 	int i;
 
+	list_for_each_entry_safe(ld, _ld, &umem->leases, list) {
+		list_del_init(&ld->list);
+		map_direct_lease_destroy(ld);
+	}
+
 	if (umem->nmap > 0)
 		ib_dma_unmap_sg(dev, umem->sg_head.sgl,
 				umem->npages,
@@ -64,10 +71,20 @@ static void __ib_umem_release(struct ib_device *dev, struct ib_umem *umem, int d
 	}
 
 	sg_free_table(&umem->sg_head);
-	return;
 
 }
 
+static void ib_umem_lease_break(void *__umem)
+{
+	struct ib_umem *umem = umem;
+	struct ib_device *idev = umem->context->device;
+	struct device *dev = idev->dma_device;
+	struct scatterlist *sgl = umem->sg_head.sgl;
+
+	iommu_unmap(umem->iommu, sg_dma_address(sgl) & PAGE_MASK,
+			iommu_sg_num_pages(dev, sgl, umem->npages));
+}
+
 /**
  * ib_umem_get - Pin and DMA map userspace memory.
  *
@@ -96,7 +113,10 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 	struct scatterlist *sg, *sg_list_start;
 	int need_release = 0;
 	unsigned int gup_flags = FOLL_WRITE;
+	struct vm_area_struct *vma_prev = NULL;
+	struct device *dma_dev;
 
+	dma_dev = context->device->dma_device;
 	if (dmasync)
 		dma_attrs |= DMA_ATTR_WRITE_BARRIER;
 
@@ -120,6 +140,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 	umem->address    = addr;
 	umem->page_shift = PAGE_SHIFT;
 	umem->pid	 = get_task_pid(current, PIDTYPE_PID);
+	INIT_LIST_HEAD(&umem->leases);
 	/*
 	 * We ask for writable memory if any of the following
 	 * access flags are set.  "Local write" and "remote write"
@@ -147,19 +168,21 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 	umem->hugetlb   = 1;
 
 	page_list = (struct page **) __get_free_page(GFP_KERNEL);
-	if (!page_list) {
-		put_pid(umem->pid);
-		kfree(umem);
-		return ERR_PTR(-ENOMEM);
-	}
+	if (!page_list)
+		goto err_pagelist;
 
 	/*
-	 * if we can't alloc the vma_list, it's not so bad;
-	 * just assume the memory is not hugetlb memory
+	 * If DAX is enabled we need the vma to setup a ->lease_direct()
+	 * lease to protect against file modifications, otherwise we can
+	 * tolerate a failure to allocate the vma_list and just assume
+	 * that all vmas are not hugetlb-vmas.
 	 */
 	vma_list = (struct vm_area_struct **) __get_free_page(GFP_KERNEL);
-	if (!vma_list)
+	if (!vma_list) {
+		if (IS_ENABLED(CONFIG_DAX_MAP_DIRECT))
+			goto err_vmalist;
 		umem->hugetlb = 0;
+	}
 
 	npages = ib_umem_num_pages(umem);
 
@@ -199,15 +222,52 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 		if (ret < 0)
 			goto out;
 
-		umem->npages += ret;
 		cur_base += ret * PAGE_SIZE;
 		npages   -= ret;
 
 		for_each_sg(sg_list_start, sg, ret, i) {
-			if (vma_list && !is_vm_hugetlb_page(vma_list[i]))
-				umem->hugetlb = 0;
+			const struct vm_operations_struct *vm_ops;
+			struct vm_area_struct *vma;
+			struct lease_direct *ld;
 
 			sg_set_page(sg, page_list[i], PAGE_SIZE, 0);
+			umem->npages++;
+
+			if (!vma_list)
+				continue;
+			vma = vma_list[i];
+
+			if (vma == vma_prev)
+				continue;
+			vma_prev = vma;
+
+			if (!is_vm_hugetlb_page(vma))
+				umem->hugetlb = 0;
+
+			if (!vma_is_dax(vma))
+				continue;
+
+			vm_ops = vma->vm_ops;
+			if (!vm_ops->lease_direct) {
+				dev_info(dma_dev, "DAX-RDMA requires a MAP_DIRECT mapping\n");
+				ret = -EOPNOTSUPP;
+				goto out;
+			}
+
+			if (!umem->iommu)
+				umem->iommu = dma_get_iommu_domain(dma_dev);
+			if (!umem->iommu) {
+				dev_info(dma_dev, "DAX-RDMA requires an iommu protected device\n");
+				ret = -EOPNOTSUPP;
+				goto out;
+			}
+			ld = vm_ops->lease_direct(vma, ib_umem_lease_break,
+					umem);
+			if (IS_ERR(ld)) {
+				ret = PTR_ERR(ld);
+				goto out;
+			}
+			list_add(&ld->list, &umem->leases);
 		}
 
 		/* preparing for next loop */
@@ -242,6 +302,12 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 	free_page((unsigned long) page_list);
 
 	return ret < 0 ? ERR_PTR(ret) : umem;
+err_vmalist:
+	free_page((unsigned long) page_list);
+err_pagelist:
+	put_pid(umem->pid);
+	kfree(umem);
+	return ERR_PTR(-ENOMEM);
 }
 EXPORT_SYMBOL(ib_umem_get);
 
diff --git a/include/rdma/ib_umem.h b/include/rdma/ib_umem.h
index 23159dd5be18..5048be012f96 100644
--- a/include/rdma/ib_umem.h
+++ b/include/rdma/ib_umem.h
@@ -34,6 +34,7 @@
 #define IB_UMEM_H
 
 #include <linux/list.h>
+#include <linux/iommu.h>
 #include <linux/scatterlist.h>
 #include <linux/workqueue.h>
 
@@ -55,6 +56,13 @@ struct ib_umem {
 	struct sg_table sg_head;
 	int             nmap;
 	int             npages;
+	/*
+	 * Note: no lock protects this list since we assume memory
+	 * registration never races unregistration for a given ib_umem
+	 * instance.
+	 */
+	struct list_head	leases;
+	struct iommu_domain	*iommu;
 };
 
 /* Returns the offset of the umem start relative to the first page. */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
