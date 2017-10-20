Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 254596B026E
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 22:46:35 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v2so8056989pfa.10
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 19:46:35 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id k76si255560pgc.819.2017.10.19.19.46.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 19:46:33 -0700 (PDT)
Subject: [PATCH v3 13/13] xfs: wire up FL_ALLOCATED support
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 19 Oct 2017 19:40:08 -0700
Message-ID: <150846720846.24336.10565514769202466327.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-xfs@vger.kernel.org, Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-nvdimm@lists.01.org, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, hch@lst.de, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>, Ross Zwisler <ross.zwisler@linux.intel.com>

Before xfs can be sure that it is safe to truncate it needs to hold
XFS_MMAP_LOCK_EXCL and flush any FL_ALLOCATED leases.  Introduce
xfs_break_allocated() modeled after xfs_break_layouts() for use in the
file space deletion path.

We also use a new address_space_operation for the fs/dax core to
coordinate reaping these leases in the case where there is no active
truncate process to reap them.

Cc: Jan Kara <jack@suse.cz>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jeff Layton <jlayton@poochiereds.net>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/xfs/xfs_aops.c  |   24 ++++++++++++++++++++
 fs/xfs/xfs_file.c  |   64 ++++++++++++++++++++++++++++++++++++++++++++++++----
 fs/xfs/xfs_inode.h |    1 +
 fs/xfs/xfs_ioctl.c |    7 ++----
 4 files changed, 86 insertions(+), 10 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index f18e5932aec4..00da08d0d6db 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -1455,6 +1455,29 @@ xfs_vm_set_page_dirty(
 	return newly_dirty;
 }
 
+/*
+ * Reap any in-flight FL_ALLOCATE leases when the pages represented by
+ * that lease are no longer under dma. We hold XFS_MMAPLOCK_EXCL to
+ * synchronize with the file space deletion path that may be doing the
+ * same operation.
+ */
+static void
+xfs_vm_dax_flush_dma(
+	struct inode		*inode)
+{
+	uint			iolock = XFS_MMAPLOCK_EXCL;
+
+	/*
+	 * try to catch cases where the inode dax mode was changed
+	 * without first synchronizing leases
+	 */
+	WARN_ON_ONCE(!IS_DAX(inode));
+
+	xfs_ilock(XFS_I(inode), iolock);
+	xfs_break_allocated(inode, &iolock);
+	xfs_iunlock(XFS_I(inode), iolock);
+}
+
 const struct address_space_operations xfs_address_space_operations = {
 	.readpage		= xfs_vm_readpage,
 	.readpages		= xfs_vm_readpages,
@@ -1468,4 +1491,5 @@ const struct address_space_operations xfs_address_space_operations = {
 	.migratepage		= buffer_migrate_page,
 	.is_partially_uptodate  = block_is_partially_uptodate,
 	.error_remove_page	= generic_error_remove_page,
+	.dax_flush_dma		= xfs_vm_dax_flush_dma,
 };
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index c6780743f8ec..5bc72f1da301 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -40,6 +40,7 @@
 #include "xfs_iomap.h"
 #include "xfs_reflink.h"
 
+#include <linux/dax.h>
 #include <linux/dcache.h>
 #include <linux/falloc.h>
 #include <linux/pagevec.h>
@@ -746,6 +747,39 @@ xfs_file_write_iter(
 	return ret;
 }
 
+/*
+ * DAX breaks the traditional truncate model that assumes in-flight DMA
+ * to a file-backed page can continue until the final put of the page
+ * regardless of that page's relationship to the file. In the case of
+ * DAX the page has 1:1 relationship with filesytem blocks. We need to
+ * hold off truncate while any DMA might be in-flight. This assumes that
+ * all DMA usage is transient, any non-transient usages of
+ * get_user_pages must be disallowed for DAX files.
+ *
+ * This also unlocks FL_LAYOUT leases.
+ */
+int
+xfs_break_allocated(
+	struct inode		*inode,
+	uint			*iolock)
+{
+	struct xfs_inode	*ip = XFS_I(inode);
+	int			error;
+
+	ASSERT(xfs_isilocked(ip, XFS_IOLOCK_SHARED|XFS_IOLOCK_EXCL
+				| XFS_MMAPLOCK_SHARED|XFS_MMAPLOCK_EXCL));
+
+	while ((error = break_allocated(inode, false) == -EWOULDBLOCK)) {
+		xfs_iunlock(ip, *iolock);
+		error = break_allocated(inode, true);
+		*iolock &= ~XFS_MMAPLOCK_SHARED|XFS_IOLOCK_SHARED;
+		*iolock |= XFS_MMAPLOCK_EXCL|XFS_IOLOCK_EXCL;
+		xfs_ilock(ip, *iolock);
+	}
+
+	return error;
+}
+
 #define	XFS_FALLOC_FL_SUPPORTED						\
 		(FALLOC_FL_KEEP_SIZE | FALLOC_FL_PUNCH_HOLE |		\
 		 FALLOC_FL_COLLAPSE_RANGE | FALLOC_FL_ZERO_RANGE |	\
@@ -762,7 +796,7 @@ xfs_file_fallocate(
 	struct xfs_inode	*ip = XFS_I(inode);
 	long			error;
 	enum xfs_prealloc_flags	flags = 0;
-	uint			iolock = XFS_IOLOCK_EXCL;
+	uint			iolock = XFS_IOLOCK_EXCL|XFS_MMAPLOCK_EXCL;
 	loff_t			new_size = 0;
 	bool			do_file_insert = 0;
 
@@ -772,13 +806,10 @@ xfs_file_fallocate(
 		return -EOPNOTSUPP;
 
 	xfs_ilock(ip, iolock);
-	error = xfs_break_layouts(inode, &iolock);
+	error = xfs_break_allocated(inode, &iolock);
 	if (error)
 		goto out_unlock;
 
-	xfs_ilock(ip, XFS_MMAPLOCK_EXCL);
-	iolock |= XFS_MMAPLOCK_EXCL;
-
 	if (mode & FALLOC_FL_PUNCH_HOLE) {
 		error = xfs_free_file_space(ip, offset, len);
 		if (error)
@@ -1136,6 +1167,28 @@ xfs_file_mmap(
 	return 0;
 }
 
+/*
+ * Any manipulation of FL_ALLOCATED leases need to be coordinated with
+ * XFS_MMAPLOCK_EXCL to synchronize get_user_pages() + DMA vs truncate.
+ */
+static int
+xfs_file_setlease(
+	struct file		*filp,
+	long			arg,
+	struct file_lock	**flp,
+	void			**priv)
+{
+	struct inode		*inode = file_inode(filp);
+	struct xfs_inode 	*ip = XFS_I(inode);
+	uint			iolock = XFS_MMAPLOCK_EXCL;
+	int			error;
+
+	xfs_ilock(ip, iolock);
+	error = generic_setlease(filp, arg, flp, priv);
+	xfs_iunlock(ip, iolock);
+	return error;
+}
+
 const struct file_operations xfs_file_operations = {
 	.llseek		= xfs_file_llseek,
 	.read_iter	= xfs_file_read_iter,
@@ -1154,6 +1207,7 @@ const struct file_operations xfs_file_operations = {
 	.fallocate	= xfs_file_fallocate,
 	.clone_file_range = xfs_file_clone_range,
 	.dedupe_file_range = xfs_file_dedupe_range,
+	.setlease	= xfs_file_setlease,
 };
 
 const struct file_operations xfs_dir_file_operations = {
diff --git a/fs/xfs/xfs_inode.h b/fs/xfs/xfs_inode.h
index 0ee453de239a..e0d421884fe4 100644
--- a/fs/xfs/xfs_inode.h
+++ b/fs/xfs/xfs_inode.h
@@ -445,6 +445,7 @@ int	xfs_zero_eof(struct xfs_inode *ip, xfs_off_t offset,
 		     xfs_fsize_t isize, bool *did_zeroing);
 int	xfs_zero_range(struct xfs_inode *ip, xfs_off_t pos, xfs_off_t count,
 		bool *did_zero);
+int	xfs_break_allocated(struct inode *inode, uint *iolock);
 
 /* from xfs_iops.c */
 extern void xfs_setup_inode(struct xfs_inode *ip);
diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index aa75389be8cf..5be60c74bede 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -612,7 +612,7 @@ xfs_ioc_space(
 	struct xfs_inode	*ip = XFS_I(inode);
 	struct iattr		iattr;
 	enum xfs_prealloc_flags	flags = 0;
-	uint			iolock = XFS_IOLOCK_EXCL;
+	uint			iolock = XFS_IOLOCK_EXCL|XFS_MMAPLOCK_EXCL;
 	int			error;
 
 	/*
@@ -642,13 +642,10 @@ xfs_ioc_space(
 		return error;
 
 	xfs_ilock(ip, iolock);
-	error = xfs_break_layouts(inode, &iolock);
+	error = xfs_break_allocated(inode, &iolock);
 	if (error)
 		goto out_unlock;
 
-	xfs_ilock(ip, XFS_MMAPLOCK_EXCL);
-	iolock |= XFS_MMAPLOCK_EXCL;
-
 	switch (bf->l_whence) {
 	case 0: /*SEEK_SET*/
 		break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
