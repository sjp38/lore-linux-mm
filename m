Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BC1A26B0028
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 23:29:44 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d19so3134783pgn.20
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 20:29:44 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 2-v6si1573367ple.387.2018.02.26.20.29.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 20:29:43 -0800 (PST)
Subject: [PATCH v4 08/12] xfs, dax: replace IS_DAX() with IS_FSDAX()
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 26 Feb 2018 20:20:37 -0800
Message-ID: <151970523724.26729.2708434307206092584.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151970519370.26729.1011551137381425076.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151970519370.26729.1011551137381425076.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>

In preparation for fixing the broken definition of S_DAX in the
CONFIG_FS_DAX=n + CONFIG_DEV_DAX=y case, convert all IS_DAX() usages to
use explicit tests for FSDAX since DAX is ambiguous.

Cc: Jan Kara <jack@suse.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: <stable@vger.kernel.org>
Fixes: dee410792419 ("/dev/dax, core: file operations and dax-mmap")
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/xfs/xfs_file.c    |   14 +++++++-------
 fs/xfs/xfs_ioctl.c   |    4 ++--
 fs/xfs/xfs_iomap.c   |    6 +++---
 fs/xfs/xfs_reflink.c |    2 +-
 4 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 9ea08326f876..46a098b90fd0 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -288,7 +288,7 @@ xfs_file_read_iter(
 	if (XFS_FORCED_SHUTDOWN(mp))
 		return -EIO;
 
-	if (IS_DAX(inode))
+	if (IS_FSDAX(inode))
 		ret = xfs_file_dax_read(iocb, to);
 	else if (iocb->ki_flags & IOCB_DIRECT)
 		ret = xfs_file_dio_aio_read(iocb, to);
@@ -726,7 +726,7 @@ xfs_file_write_iter(
 	if (XFS_FORCED_SHUTDOWN(ip->i_mount))
 		return -EIO;
 
-	if (IS_DAX(inode))
+	if (IS_FSDAX(inode))
 		ret = xfs_file_dax_write(iocb, from);
 	else if (iocb->ki_flags & IOCB_DIRECT) {
 		/*
@@ -1045,7 +1045,7 @@ __xfs_filemap_fault(
 	}
 
 	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
-	if (IS_DAX(inode)) {
+	if (IS_FSDAX(inode)) {
 		pfn_t pfn;
 
 		ret = dax_iomap_fault(vmf, pe_size, &pfn, NULL, &xfs_iomap_ops);
@@ -1070,7 +1070,7 @@ xfs_filemap_fault(
 {
 	/* DAX can shortcut the normal fault path on write faults! */
 	return __xfs_filemap_fault(vmf, PE_SIZE_PTE,
-			IS_DAX(file_inode(vmf->vma->vm_file)) &&
+			IS_FSDAX(file_inode(vmf->vma->vm_file)) &&
 			(vmf->flags & FAULT_FLAG_WRITE));
 }
 
@@ -1079,7 +1079,7 @@ xfs_filemap_huge_fault(
 	struct vm_fault		*vmf,
 	enum page_entry_size	pe_size)
 {
-	if (!IS_DAX(file_inode(vmf->vma->vm_file)))
+	if (!IS_FSDAX(file_inode(vmf->vma->vm_file)))
 		return VM_FAULT_FALLBACK;
 
 	/* DAX can shortcut the normal fault path on write faults! */
@@ -1124,12 +1124,12 @@ xfs_file_mmap(
 	 * We don't support synchronous mappings for non-DAX files. At least
 	 * until someone comes with a sensible use case.
 	 */
-	if (!IS_DAX(file_inode(filp)) && (vma->vm_flags & VM_SYNC))
+	if (!IS_FSDAX(file_inode(filp)) && (vma->vm_flags & VM_SYNC))
 		return -EOPNOTSUPP;
 
 	file_accessed(filp);
 	vma->vm_ops = &xfs_file_vm_ops;
-	if (IS_DAX(file_inode(filp)))
+	if (IS_FSDAX(file_inode(filp)))
 		vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;
 	return 0;
 }
diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index 89fb1eb80aae..234279ff66ce 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -1108,9 +1108,9 @@ xfs_ioctl_setattr_dax_invalidate(
 	}
 
 	/* If the DAX state is not changing, we have nothing to do here. */
-	if ((fa->fsx_xflags & FS_XFLAG_DAX) && IS_DAX(inode))
+	if ((fa->fsx_xflags & FS_XFLAG_DAX) && IS_FSDAX(inode))
 		return 0;
-	if (!(fa->fsx_xflags & FS_XFLAG_DAX) && !IS_DAX(inode))
+	if (!(fa->fsx_xflags & FS_XFLAG_DAX) && !IS_FSDAX(inode))
 		return 0;
 
 	/* lock, flush and invalidate mapping in preparation for flag change */
diff --git a/fs/xfs/xfs_iomap.c b/fs/xfs/xfs_iomap.c
index 66e1edbfb2b2..cf794d429aec 100644
--- a/fs/xfs/xfs_iomap.c
+++ b/fs/xfs/xfs_iomap.c
@@ -241,7 +241,7 @@ xfs_iomap_write_direct(
 	 * the reserve block pool for bmbt block allocation if there is no space
 	 * left but we need to do unwritten extent conversion.
 	 */
-	if (IS_DAX(VFS_I(ip))) {
+	if (IS_FSDAX(VFS_I(ip))) {
 		bmapi_flags = XFS_BMAPI_CONVERT | XFS_BMAPI_ZERO;
 		if (imap->br_state == XFS_EXT_UNWRITTEN) {
 			tflags |= XFS_TRANS_RESERVE;
@@ -952,7 +952,7 @@ static inline bool imap_needs_alloc(struct inode *inode,
 	return !nimaps ||
 		imap->br_startblock == HOLESTARTBLOCK ||
 		imap->br_startblock == DELAYSTARTBLOCK ||
-		(IS_DAX(inode) && imap->br_state == XFS_EXT_UNWRITTEN);
+		(IS_FSDAX(inode) && imap->br_state == XFS_EXT_UNWRITTEN);
 }
 
 static inline bool need_excl_ilock(struct xfs_inode *ip, unsigned flags)
@@ -988,7 +988,7 @@ xfs_file_iomap_begin(
 		return -EIO;
 
 	if (((flags & (IOMAP_WRITE | IOMAP_DIRECT)) == IOMAP_WRITE) &&
-			!IS_DAX(inode) && !xfs_get_extsz_hint(ip)) {
+			!IS_FSDAX(inode) && !xfs_get_extsz_hint(ip)) {
 		/* Reserve delalloc blocks for regular writeback. */
 		return xfs_file_iomap_begin_delay(inode, offset, length, iomap);
 	}
diff --git a/fs/xfs/xfs_reflink.c b/fs/xfs/xfs_reflink.c
index 270246943a06..a126e00e05e3 100644
--- a/fs/xfs/xfs_reflink.c
+++ b/fs/xfs/xfs_reflink.c
@@ -1351,7 +1351,7 @@ xfs_reflink_remap_range(
 		goto out_unlock;
 
 	/* Don't share DAX file data for now. */
-	if (IS_DAX(inode_in) || IS_DAX(inode_out))
+	if (IS_FSDAX(inode_in) || IS_FSDAX(inode_out))
 		goto out_unlock;
 
 	ret = vfs_clone_file_prep_inodes(inode_in, pos_in, inode_out, pos_out,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
