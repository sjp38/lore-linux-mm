Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E83C56B0260
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 15:34:44 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h24so3600624pfh.0
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 12:34:44 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id bo7si34909782pab.241.2016.10.19.12.34.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Oct 2016 12:34:44 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v8 03/16] ext2: remove support for DAX PMD faults
Date: Wed, 19 Oct 2016 13:34:22 -0600
Message-Id: <1476905675-32581-4-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1476905675-32581-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1476905675-32581-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

DAX PMD support was added via the following commit:

commit e7b1ea2ad658 ("ext2: huge page fault support")

I believe this path to be untested as ext2 doesn't reliably provide block
allocations that are aligned to 2MiB.  In my testing I've been unable to
get ext2 to actually fault in a PMD.  It always fails with a "pfn
unaligned" message because the sector returned by ext2_get_block() isn't
aligned.

I've tried various settings for the "stride" and "stripe_width" extended
options to mkfs.ext2, without any luck.

Since we can't reliably get PMDs, remove support so that we don't have an
untested code path that we may someday traverse when we happen to get an
aligned block allocation.  This should also make 4k DAX faults in ext2 a
bit faster since they will no longer have to call the PMD fault handler
only to get a response of VM_FAULT_FALLBACK.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 fs/ext2/file.c | 29 ++++++-----------------------
 1 file changed, 6 insertions(+), 23 deletions(-)

diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index a0e1478..fb88b51 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -107,27 +107,6 @@ static int ext2_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return ret;
 }
 
-static int ext2_dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
-						pmd_t *pmd, unsigned int flags)
-{
-	struct inode *inode = file_inode(vma->vm_file);
-	struct ext2_inode_info *ei = EXT2_I(inode);
-	int ret;
-
-	if (flags & FAULT_FLAG_WRITE) {
-		sb_start_pagefault(inode->i_sb);
-		file_update_time(vma->vm_file);
-	}
-	down_read(&ei->dax_sem);
-
-	ret = dax_pmd_fault(vma, addr, pmd, flags, ext2_get_block);
-
-	up_read(&ei->dax_sem);
-	if (flags & FAULT_FLAG_WRITE)
-		sb_end_pagefault(inode->i_sb);
-	return ret;
-}
-
 static int ext2_dax_pfn_mkwrite(struct vm_area_struct *vma,
 		struct vm_fault *vmf)
 {
@@ -154,7 +133,11 @@ static int ext2_dax_pfn_mkwrite(struct vm_area_struct *vma,
 
 static const struct vm_operations_struct ext2_dax_vm_ops = {
 	.fault		= ext2_dax_fault,
-	.pmd_fault	= ext2_dax_pmd_fault,
+	/*
+	 * .pmd_fault is not supported for DAX because allocation in ext2
+	 * cannot be reliably aligned to huge page sizes and so pmd faults
+	 * will always fail and fail back to regular faults.
+	 */
 	.page_mkwrite	= ext2_dax_fault,
 	.pfn_mkwrite	= ext2_dax_pfn_mkwrite,
 };
@@ -166,7 +149,7 @@ static int ext2_file_mmap(struct file *file, struct vm_area_struct *vma)
 
 	file_accessed(file);
 	vma->vm_ops = &ext2_dax_vm_ops;
-	vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;
+	vma->vm_flags |= VM_MIXEDMAP;
 	return 0;
 }
 #else
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
