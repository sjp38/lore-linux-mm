Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id E49376B0260
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 19:07:51 -0500 (EST)
Received: by padhx2 with SMTP id hx2so114508311pad.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 16:07:51 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id z4si30586026pbv.39.2015.11.13.16.07.46
        for <linux-mm@kvack.org>;
        Fri, 13 Nov 2015 16:07:46 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 11/11] xfs: add support for DAX fsync/msync
Date: Fri, 13 Nov 2015 17:06:50 -0700
Message-Id: <1447459610-14259-12-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

To properly support the new DAX fsync/msync infrastructure filesystems
need to call dax_pfn_mkwrite() so that DAX can properly track when a user
write faults on a previously cleaned address.  They also need to call
dax_fsync() in the filesystem fsync() path.  This dax_fsync() call uses
addresses retrieved from get_block() so it needs to be ordered with
respect to truncate.  This is accomplished by using the same locking that
was set up for DAX page faults.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/xfs/xfs_file.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 39743ef..2b490a1 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -209,7 +209,8 @@ xfs_file_fsync(
 	loff_t			end,
 	int			datasync)
 {
-	struct inode		*inode = file->f_mapping->host;
+	struct address_space	*mapping = file->f_mapping;
+	struct inode		*inode = mapping->host;
 	struct xfs_inode	*ip = XFS_I(inode);
 	struct xfs_mount	*mp = ip->i_mount;
 	int			error = 0;
@@ -218,7 +219,13 @@ xfs_file_fsync(
 
 	trace_xfs_file_fsync(ip);
 
-	error = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	if (dax_mapping(mapping)) {
+		xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
+		dax_fsync(mapping, start, end);
+		xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
+	}
+
+	error = filemap_write_and_wait_range(mapping, start, end);
 	if (error)
 		return error;
 
@@ -1603,9 +1610,8 @@ xfs_filemap_pmd_fault(
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
@@ -1628,6 +1634,8 @@ xfs_filemap_pfn_mkwrite(
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (vmf->pgoff >= size)
 		ret = VM_FAULT_SIGBUS;
+	else if (IS_DAX(inode))
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
