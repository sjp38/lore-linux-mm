Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5261082F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 16:12:50 -0400 (EDT)
Received: by igvi2 with SMTP id i2so32139065igv.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 13:12:50 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id x8si4630009igg.87.2015.10.29.13.12.38
        for <linux-mm@kvack.org>;
        Thu, 29 Oct 2015 13:12:38 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [RFC 10/11] xfs, ext2: call dax_pfn_mkwrite() on write fault
Date: Thu, 29 Oct 2015 14:12:14 -0600
Message-Id: <1446149535-16200-11-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

Previously the functionality offered by dax_pfn_mkwrite() was open-coded in
XFS and ext2.  With the addition of DAX msync/fsync support we need to call
dax_pfn_mkwrite() so that the newly writeable page can be added to the
radix tree and marked as dirty.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/ext2/file.c    | 4 +++-
 fs/xfs/xfs_file.c | 9 +++++----
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index fc1418c..5741e29 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -102,8 +102,8 @@ static int ext2_dax_pfn_mkwrite(struct vm_area_struct *vma,
 {
 	struct inode *inode = file_inode(vma->vm_file);
 	struct ext2_inode_info *ei = EXT2_I(inode);
-	int ret = VM_FAULT_NOPAGE;
 	loff_t size;
+	int ret;
 
 	sb_start_pagefault(inode->i_sb);
 	file_update_time(vma->vm_file);
@@ -113,6 +113,8 @@ static int ext2_dax_pfn_mkwrite(struct vm_area_struct *vma,
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (vmf->pgoff >= size)
 		ret = VM_FAULT_SIGBUS;
+	else
+		ret = dax_pfn_mkwrite(vma, vmf);
 
 	up_read(&ei->dax_sem);
 	sb_end_pagefault(inode->i_sb);
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index f429662..584e4eb 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1575,9 +1575,8 @@ xfs_filemap_pmd_fault(
 /*
  * pfn_mkwrite was originally inteneded to ensure we capture time stamp
  * updates on write faults. In reality, it's need to serialise against
- * truncate similar to page_mkwrite. Hence we open-code dax_pfn_mkwrite()
- * here and cycle the XFS_MMAPLOCK_SHARED to ensure we serialise the fault
- * barrier in place.
+ * truncate similar to page_mkwrite. Hence we cycle the XFS_MMAPLOCK_SHARED
+ * to ensure we serialise the fault barrier in place.
  */
 static int
 xfs_filemap_pfn_mkwrite(
@@ -1587,7 +1586,7 @@ xfs_filemap_pfn_mkwrite(
 
 	struct inode		*inode = file_inode(vma->vm_file);
 	struct xfs_inode	*ip = XFS_I(inode);
-	int			ret = VM_FAULT_NOPAGE;
+	int			ret;
 	loff_t			size;
 
 	trace_xfs_filemap_pfn_mkwrite(ip);
@@ -1600,6 +1599,8 @@ xfs_filemap_pfn_mkwrite(
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (vmf->pgoff >= size)
 		ret = VM_FAULT_SIGBUS;
+	else
+		ret = dax_pfn_mkwrite(vma, vmf);
 	xfs_iunlock(ip, XFS_MMAPLOCK_SHARED);
 	sb_end_pagefault(inode->i_sb);
 	return ret;
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
