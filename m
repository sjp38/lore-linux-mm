Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9074D9003C7
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 16:29:50 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so57725930pdr.2
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 13:29:50 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id g3si16068892pdo.21.2015.07.10.13.29.36
        for <linux-mm@kvack.org>;
        Fri, 10 Jul 2015 13:29:36 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 10/10] xfs: Huge page fault support
Date: Fri, 10 Jul 2015 16:29:25 -0400
Message-Id: <1436560165-8943-11-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1436560165-8943-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1436560165-8943-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

Use DAX to provide support for huge pages.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 fs/xfs/xfs_file.c  | 30 +++++++++++++++++++++++++++++-
 fs/xfs/xfs_trace.h |  1 +
 2 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index a212b7b..d3ea50c 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1534,8 +1534,36 @@ xfs_filemap_fault(
 	return ret;
 }
 
+STATIC int
+xfs_filemap_pmd_fault(
+	struct vm_area_struct	*vma,
+	unsigned long		addr,
+	pmd_t			*pmd,
+	unsigned int		flags)
+{
+	struct inode		*inode = file_inode(vma->vm_file);
+	struct xfs_inode	*ip = XFS_I(inode);
+	int			ret;
+
+	if (!IS_DAX(inode))
+		return VM_FAULT_FALLBACK;
+
+	trace_xfs_filemap_pmd_fault(ip);
+
+	sb_start_pagefault(inode->i_sb);
+	file_update_time(vma->vm_file);
+	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
+	ret = __dax_pmd_fault(vma, addr, pmd, flags, xfs_get_blocks_direct,
+				    xfs_end_io_dax_write);
+	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
+	sb_end_pagefault(inode->i_sb);
+
+	return ret;
+}
+
 static const struct vm_operations_struct xfs_file_vm_ops = {
 	.fault		= xfs_filemap_fault,
+	.pmd_fault	= xfs_filemap_pmd_fault,
 	.map_pages	= filemap_map_pages,
 	.page_mkwrite	= xfs_filemap_page_mkwrite,
 };
@@ -1548,7 +1576,7 @@ xfs_file_mmap(
 	file_accessed(filp);
 	vma->vm_ops = &xfs_file_vm_ops;
 	if (IS_DAX(file_inode(filp)))
-		vma->vm_flags |= VM_MIXEDMAP;
+		vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;
 	return 0;
 }
 
diff --git a/fs/xfs/xfs_trace.h b/fs/xfs/xfs_trace.h
index 8d916d3..8229cae 100644
--- a/fs/xfs/xfs_trace.h
+++ b/fs/xfs/xfs_trace.h
@@ -687,6 +687,7 @@ DEFINE_INODE_EVENT(xfs_inode_clear_eofblocks_tag);
 DEFINE_INODE_EVENT(xfs_inode_free_eofblocks_invalid);
 
 DEFINE_INODE_EVENT(xfs_filemap_fault);
+DEFINE_INODE_EVENT(xfs_filemap_pmd_fault);
 DEFINE_INODE_EVENT(xfs_filemap_page_mkwrite);
 
 DECLARE_EVENT_CLASS(xfs_iref_class,
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
