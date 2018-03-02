Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 05E056B0055
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 23:03:46 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id j6-v6so4442920pll.10
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 20:03:45 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id 73-v6si4088485ple.829.2018.03.01.20.03.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Mar 2018 20:03:44 -0800 (PST)
Subject: [PATCH v5 12/12] vfio: disable filesystem-dax page pinning
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 01 Mar 2018 19:54:39 -0800
Message-ID: <151996287917.28483.16157329534570989926.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151996281307.28483.12343847096989509127.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151996281307.28483.12343847096989509127.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Alex Williamson <alex.williamson@redhat.com>, Michal Hocko <mhocko@suse.com>, Christoph Hellwig <hch@lst.de>, kvm@vger.kernel.org, stable@vger.kernel.org, Haozhong Zhang <haozhong.zhang@intel.com>Haozhong Zhang <haozhong.zhang@intel.com>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Filesystem-DAX is incompatible with 'longterm' page pinning. Without
page cache indirection a DAX mapping maps filesystem blocks directly.
This means that the filesystem must not modify a file's block map while
any page in a mapping is pinned. In order to prevent the situation of
userspace holding of filesystem operations indefinitely, disallow
'longterm' Filesystem-DAX mappings.

RDMA has the same conflict and the plan there is to add a 'with lease'
mechanism to allow the kernel to notify userspace that the mapping is
being torn down for block-map maintenance. Perhaps something similar can
be put in place for vfio.

Note that xfs and ext4 still report:

   "DAX enabled. Warning: EXPERIMENTAL, use at your own risk"

...at mount time, and resolving the dax-dma-vs-truncate problem is one
of the last hurdles to remove that designation.

Acked-by: Alex Williamson <alex.williamson@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: kvm@vger.kernel.org
Cc: <stable@vger.kernel.org>
Reported-by: Haozhong Zhang <haozhong.zhang@intel.com>
Tested-by: Haozhong Zhang <haozhong.zhang@intel.com>
Fixes: d475c6346a38 ("dax,ext2: replace XIP read and write with DAX I/O")
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/vfio/vfio_iommu_type1.c |   18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index e30e29ae4819..45657e2b1ff7 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -338,11 +338,12 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 {
 	struct page *page[1];
 	struct vm_area_struct *vma;
+	struct vm_area_struct *vmas[1];
 	int ret;
 
 	if (mm == current->mm) {
-		ret = get_user_pages_fast(vaddr, 1, !!(prot & IOMMU_WRITE),
-					  page);
+		ret = get_user_pages_longterm(vaddr, 1, !!(prot & IOMMU_WRITE),
+					      page, vmas);
 	} else {
 		unsigned int flags = 0;
 
@@ -351,7 +352,18 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 
 		down_read(&mm->mmap_sem);
 		ret = get_user_pages_remote(NULL, mm, vaddr, 1, flags, page,
-					    NULL, NULL);
+					    vmas, NULL);
+		/*
+		 * The lifetime of a vaddr_get_pfn() page pin is
+		 * userspace-controlled. In the fs-dax case this could
+		 * lead to indefinite stalls in filesystem operations.
+		 * Disallow attempts to pin fs-dax pages via this
+		 * interface.
+		 */
+		if (ret > 0 && vma_is_fsdax(vmas[0])) {
+			ret = -EOPNOTSUPP;
+			put_page(page[0]);
+		}
 		up_read(&mm->mmap_sem);
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
