Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 00DF56B000A
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 19:52:34 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id q11so4994258pff.19
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 16:52:33 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id 3-v6si2602715plx.463.2018.02.23.16.52.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Feb 2018 16:52:32 -0800 (PST)
Subject: [PATCH v3 3/6] xfs, dax: introduce IS_FSDAX()
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 23 Feb 2018 16:43:27 -0800
Message-ID: <151943300713.29249.545330864711927648.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151943298533.29249.14597996053028346159.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151943298533.29249.14597996053028346159.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, kbuild test robot <fengguang.wu@intel.com>

Given that S_DAX is non-zero in the FS_DAX=n + DEV_DAX=y case, another
mechanism besides the plain IS_DAX() check to compile out dead
filesystem-dax code paths. Without IS_FSDAX() xfs will fail at link time
with:

    ERROR: "dax_finish_sync_fault" [fs/xfs/xfs.ko] undefined!
    ERROR: "dax_iomap_fault" [fs/xfs/xfs.ko] undefined!
    ERROR: "dax_iomap_rw" [fs/xfs/xfs.ko] undefined!

This compile failure was previously hidden by the fact that S_DAX was
erroneously defined to '0' in the FS_DAX=n + DEV_DAX=y case.

Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org
Cc: <stable@vger.kernel.org>
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/xfs/xfs_file.c    |   14 +++++++-------
 fs/xfs/xfs_ioctl.c   |    4 ++--
 fs/xfs/xfs_iomap.c   |    6 +++---
 fs/xfs/xfs_reflink.c |    2 +-
 include/linux/fs.h   |    2 ++
 5 files changed, 15 insertions(+), 13 deletions(-)

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
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 79c413985305..a4310a95011b 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1909,6 +1909,8 @@ static inline bool sb_rdonly(const struct super_block *sb) { return sb->s_flags
 #define IS_WHITEOUT(inode)	(S_ISCHR(inode->i_mode) && \
 				 (inode)->i_rdev == WHITEOUT_DEV)
 
+#define IS_FSDAX(inode) (IS_ENABLED(CONFIG_FS_DAX) && IS_DAX(inode))
+
 static inline bool HAS_UNMAPPED_ID(struct inode *inode)
 {
 	return !uid_valid(inode->i_uid) || !gid_valid(inode->i_gid);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
