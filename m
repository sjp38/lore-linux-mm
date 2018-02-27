Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id CC65F6B0026
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 23:29:38 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id x6so8660594plr.7
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 20:29:38 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id i11-v6si8011269plr.671.2018.02.26.20.29.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 20:29:37 -0800 (PST)
Subject: [PATCH v4 07/12] ext4, dax: replace IS_DAX() with IS_FSDAX()
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 26 Feb 2018 20:20:32 -0800
Message-ID: <151970523209.26729.7690806551692959424.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151970519370.26729.1011551137381425076.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151970519370.26729.1011551137381425076.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-mm@kvack.org, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>

In preparation for fixing the broken definition of S_DAX in the
CONFIG_FS_DAX=n + CONFIG_DEV_DAX=y case, convert all IS_DAX() usages to
use explicit tests for FSDAX since DAX is ambiguous.

Cc: Jan Kara <jack@suse.com>
Cc: "Theodore Ts'o" <tytso@mit.edu>
Cc: Andreas Dilger <adilger.kernel@dilger.ca>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: <stable@vger.kernel.org>
Fixes: dee410792419 ("/dev/dax, core: file operations and dax-mmap")
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/ext4/file.c  |   12 +++++-------
 fs/ext4/inode.c |    4 ++--
 fs/ext4/ioctl.c |    2 +-
 fs/ext4/super.c |    2 +-
 4 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 51854e7608f0..561ea843b458 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -48,7 +48,7 @@ static ssize_t ext4_dax_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	 * Recheck under inode lock - at this point we are sure it cannot
 	 * change anymore
 	 */
-	if (!IS_DAX(inode)) {
+	if (!IS_FSDAX(inode)) {
 		inode_unlock_shared(inode);
 		/* Fallback to buffered IO in case we cannot support DAX */
 		return generic_file_read_iter(iocb, to);
@@ -68,7 +68,7 @@ static ssize_t ext4_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	if (!iov_iter_count(to))
 		return 0; /* skip atime */
 
-	if (IS_DAX(file_inode(iocb->ki_filp)))
+	if (IS_FSDAX(file_inode(iocb->ki_filp)))
 		return ext4_dax_read_iter(iocb, to);
 	return generic_file_read_iter(iocb, to);
 }
@@ -216,10 +216,8 @@ ext4_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	if (unlikely(ext4_forced_shutdown(EXT4_SB(inode->i_sb))))
 		return -EIO;
 
-#ifdef CONFIG_FS_DAX
-	if (IS_DAX(inode))
+	if (IS_FSDAX(inode))
 		return ext4_dax_write_iter(iocb, from);
-#endif
 	if (!o_direct && (iocb->ki_flags & IOCB_NOWAIT))
 		return -EOPNOTSUPP;
 
@@ -361,11 +359,11 @@ static int ext4_file_mmap(struct file *file, struct vm_area_struct *vma)
 	 * We don't support synchronous mappings for non-DAX files. At least
 	 * until someone comes with a sensible use case.
 	 */
-	if (!IS_DAX(file_inode(file)) && (vma->vm_flags & VM_SYNC))
+	if (!IS_FSDAX(file_inode(file)) && (vma->vm_flags & VM_SYNC))
 		return -EOPNOTSUPP;
 
 	file_accessed(file);
-	if (IS_DAX(file_inode(file))) {
+	if (IS_FSDAX(file_inode(file))) {
 		vma->vm_ops = &ext4_dax_vm_ops;
 		vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;
 	} else {
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index c94780075b04..1879b33aa391 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3858,7 +3858,7 @@ static ssize_t ext4_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 		return 0;
 
 	/* DAX uses iomap path now */
-	if (WARN_ON_ONCE(IS_DAX(inode)))
+	if (WARN_ON_ONCE(IS_FSDAX(inode)))
 		return 0;
 
 	trace_ext4_direct_IO_enter(inode, offset, count, iov_iter_rw(iter));
@@ -4076,7 +4076,7 @@ static int ext4_block_zero_page_range(handle_t *handle,
 	if (length > max || length < 0)
 		length = max;
 
-	if (IS_DAX(inode)) {
+	if (IS_FSDAX(inode)) {
 		return iomap_zero_range(inode, from, length, NULL,
 					&ext4_iomap_ops);
 	}
diff --git a/fs/ext4/ioctl.c b/fs/ext4/ioctl.c
index 7e99ad02f1ba..040fc6570ddb 100644
--- a/fs/ext4/ioctl.c
+++ b/fs/ext4/ioctl.c
@@ -790,7 +790,7 @@ long ext4_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 				 "Online defrag not supported with bigalloc");
 			err = -EOPNOTSUPP;
 			goto mext_out;
-		} else if (IS_DAX(inode)) {
+		} else if (IS_FSDAX(inode)) {
 			ext4_msg(sb, KERN_ERR,
 				 "Online defrag not supported with DAX");
 			err = -EOPNOTSUPP;
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 39bf464c35f1..933e12940181 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1161,7 +1161,7 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
 	if (inode->i_ino == EXT4_ROOT_INO)
 		return -EPERM;
 
-	if (WARN_ON_ONCE(IS_DAX(inode) && i_size_read(inode)))
+	if (WARN_ON_ONCE(IS_FSDAX(inode) && i_size_read(inode)))
 		return -EINVAL;
 
 	res = ext4_convert_inline_data(inode);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
