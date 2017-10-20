Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 363586B026B
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 22:46:13 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a8so8055723pfc.6
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 19:46:13 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id y9si10544697pli.598.2017.10.19.19.46.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 19:46:12 -0700 (PDT)
Subject: [PATCH v3 09/13] IB/core: disable memory registration of
 fileystem-dax vmas
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 19 Oct 2017 19:39:45 -0700
Message-ID: <150846718583.24336.7817353741483230017.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Sean Hefty <sean.hefty@intel.com>, linux-xfs@vger.kernel.org, linux-nvdimm@lists.01.org, linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org, Jeff Moyer <jmoyer@redhat.com>, hch@lst.de, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, linux-mm@kvack.org, Doug Ledford <dledford@redhat.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>

Until there is a solution to the dma-to-dax vs truncate problem it is
not safe to allow RDMA to create long standing memory registrations
against filesytem-dax vmas. Device-dax vmas do not have this problem and
are explicitly allowed.

This is temporary until a "memory registration with layout-lease"
mechanism can be implemented, and is limited to non-ODP (On Demand
Paging) capable RDMA devices.

Cc: Sean Hefty <sean.hefty@intel.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Hal Rosenstock <hal.rosenstock@gmail.com>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: <linux-rdma@vger.kernel.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/infiniband/core/umem.c |   49 +++++++++++++++++++++++++++++++---------
 1 file changed, 38 insertions(+), 11 deletions(-)

diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index 21e60b1e2ff4..c30d286c1f24 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -147,19 +147,21 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
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
+	 * If DAX is enabled we need the vma to protect against
+	 * registering filesystem-dax memory. Otherwise we can tolerate
+	 * a failure to allocate the vma_list and just assume that all
+	 * vmas are not hugetlb-vmas.
 	 */
 	vma_list = (struct vm_area_struct **) __get_free_page(GFP_KERNEL);
-	if (!vma_list)
+	if (!vma_list) {
+		if (IS_ENABLED(CONFIG_FS_DAX))
+			goto err_vmalist;
 		umem->hugetlb = 0;
+	}
 
 	npages = ib_umem_num_pages(umem);
 
@@ -199,15 +201,34 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 		if (ret < 0)
 			goto out;
 
-		umem->npages += ret;
 		cur_base += ret * PAGE_SIZE;
 		npages   -= ret;
 
 		for_each_sg(sg_list_start, sg, ret, i) {
-			if (vma_list && !is_vm_hugetlb_page(vma_list[i]))
-				umem->hugetlb = 0;
+			struct vm_area_struct *vma;
+			struct inode *inode;
 
 			sg_set_page(sg, page_list[i], PAGE_SIZE, 0);
+			umem->npages++;
+
+			if (!vma_list)
+				continue;
+			vma = vma_list[i];
+
+			if (!is_vm_hugetlb_page(vma))
+				umem->hugetlb = 0;
+
+			if (!vma_is_dax(vma))
+				continue;
+
+			/* device-dax is safe for rdma... */
+			inode = file_inode(vma->vm_file);
+			if (inode->i_mode == S_IFCHR)
+				continue;
+
+			/* ...filesystem-dax is not. */
+			ret = -EOPNOTSUPP;
+			goto out;
 		}
 
 		/* preparing for next loop */
@@ -242,6 +263,12 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
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
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
