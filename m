Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id B8FDB6B06B3
	for <linux-mm@kvack.org>; Fri, 18 May 2018 21:45:22 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f35-v6so6102600plb.10
        for <linux-mm@kvack.org>; Fri, 18 May 2018 18:45:22 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 61-v6si8358170plc.173.2018.05.18.18.45.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 18:45:20 -0700 (PDT)
Subject: [PATCH v11 6/7] xfs: prepare xfs_break_layouts() for another layout
 type
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 18 May 2018 18:35:24 -0700
Message-ID: <152669372402.34337.768265797419905210.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152669369110.34337.14271778212195820353.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152669369110.34337.14271778212195820353.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>Christoph Hellwig <hch@lst.de>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

When xfs is operating as the back-end of a pNFS block server, it
prevents collisions between local and remote operations by requiring a
lease to be held for remotely accessed blocks. Local filesystem
operations break those leases before writing or mutating the extent map
of the file.

A similar mechanism is needed to prevent operations on pinned dax
mappings, like device-DMA, from colliding with extent unmap operations.

BREAK_WRITE and BREAK_UNMAP are introduced as two distinct levels of
layout breaking.

Layouts are broken in the BREAK_WRITE case to ensure that layout-holders
do not collide with local writes. Additionally, layouts are broken in
the BREAK_UNMAP case to make sure the layout-holder has a consistent
view of the file's extent map. While BREAK_WRITE breaks can be satisfied
be recalling FL_LAYOUT leases, BREAK_UNMAP breaks additionally require
waiting for busy dax-pages to go idle while holding XFS_MMAPLOCK_EXCL.

After this refactoring xfs_break_layouts() becomes the entry point for
coordinating both types of breaks. Finally, xfs_break_leased_layouts()
becomes just the BREAK_WRITE handler.

Note that the unlock tracking is needed in a follow on change. That will
coordinate retrying either break handler until both successfully test
for a lease break while maintaining the lock state.

Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Reported-by: Dave Chinner <david@fromorbit.com>
Reported-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/xfs/xfs_file.c  |   26 ++++++++++++++++++++++++--
 fs/xfs/xfs_inode.h |   16 ++++++++++++++++
 fs/xfs/xfs_ioctl.c |    3 +--
 fs/xfs/xfs_iops.c  |    6 +++---
 fs/xfs/xfs_pnfs.c  |   12 ++++++------
 fs/xfs/xfs_pnfs.h  |    5 +++--
 6 files changed, 53 insertions(+), 15 deletions(-)

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 35309bd046be..4774c7172ef4 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -312,7 +312,7 @@ xfs_file_aio_write_checks(
 	if (error <= 0)
 		return error;
 
-	error = xfs_break_layouts(inode, iolock);
+	error = xfs_break_layouts(inode, iolock, BREAK_WRITE);
 	if (error)
 		return error;
 
@@ -718,6 +718,28 @@ xfs_file_write_iter(
 	return ret;
 }
 
+int
+xfs_break_layouts(
+	struct inode		*inode,
+	uint			*iolock,
+	enum layout_break_reason reason)
+{
+	bool			retry;
+
+	ASSERT(xfs_isilocked(XFS_I(inode), XFS_IOLOCK_SHARED|XFS_IOLOCK_EXCL));
+
+	switch (reason) {
+	case BREAK_UNMAP:
+		ASSERT(xfs_isilocked(XFS_I(inode), XFS_MMAPLOCK_EXCL));
+		/* fall through */
+	case BREAK_WRITE:
+		return xfs_break_leased_layouts(inode, iolock, &retry);
+	default:
+		WARN_ON_ONCE(1);
+		return -EINVAL;
+	}
+}
+
 #define	XFS_FALLOC_FL_SUPPORTED						\
 		(FALLOC_FL_KEEP_SIZE | FALLOC_FL_PUNCH_HOLE |		\
 		 FALLOC_FL_COLLAPSE_RANGE | FALLOC_FL_ZERO_RANGE |	\
@@ -744,7 +766,7 @@ xfs_file_fallocate(
 		return -EOPNOTSUPP;
 
 	xfs_ilock(ip, iolock);
-	error = xfs_break_layouts(inode, &iolock);
+	error = xfs_break_layouts(inode, &iolock, BREAK_UNMAP);
 	if (error)
 		goto out_unlock;
 
diff --git a/fs/xfs/xfs_inode.h b/fs/xfs/xfs_inode.h
index 1eebc53df7d7..e5b849815ce1 100644
--- a/fs/xfs/xfs_inode.h
+++ b/fs/xfs/xfs_inode.h
@@ -379,6 +379,20 @@ static inline void xfs_ifunlock(struct xfs_inode *ip)
 					>> XFS_ILOCK_SHIFT)
 
 /*
+ * Layouts are broken in the BREAK_WRITE case to ensure that
+ * layout-holders do not collide with local writes. Additionally,
+ * layouts are broken in the BREAK_UNMAP case to make sure the
+ * layout-holder has a consistent view of the file's extent map. While
+ * BREAK_WRITE breaks can be satisfied by recalling FL_LAYOUT leases,
+ * BREAK_UNMAP breaks additionally require waiting for busy dax-pages to
+ * go idle.
+ */
+enum layout_break_reason {
+        BREAK_WRITE,
+        BREAK_UNMAP,
+};
+
+/*
  * For multiple groups support: if S_ISGID bit is set in the parent
  * directory, group of new file is set to that of the parent, and
  * new subdirectory gets S_ISGID bit from parent.
@@ -443,6 +457,8 @@ enum xfs_prealloc_flags {
 
 int	xfs_update_prealloc_flags(struct xfs_inode *ip,
 				  enum xfs_prealloc_flags flags);
+int	xfs_break_layouts(struct inode *inode, uint *iolock,
+		enum layout_break_reason reason);
 
 /* from xfs_iops.c */
 extern void xfs_setup_inode(struct xfs_inode *ip);
diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index 4151fade4bb1..91e73d663099 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -39,7 +39,6 @@
 #include "xfs_icache.h"
 #include "xfs_symlink.h"
 #include "xfs_trans.h"
-#include "xfs_pnfs.h"
 #include "xfs_acl.h"
 #include "xfs_btree.h"
 #include <linux/fsmap.h>
@@ -644,7 +643,7 @@ xfs_ioc_space(
 		return error;
 
 	xfs_ilock(ip, iolock);
-	error = xfs_break_layouts(inode, &iolock);
+	error = xfs_break_layouts(inode, &iolock, BREAK_UNMAP);
 	if (error)
 		goto out_unlock;
 
diff --git a/fs/xfs/xfs_iops.c b/fs/xfs/xfs_iops.c
index 138fb36ca875..ce0c1f9466a8 100644
--- a/fs/xfs/xfs_iops.c
+++ b/fs/xfs/xfs_iops.c
@@ -37,7 +37,6 @@
 #include "xfs_da_btree.h"
 #include "xfs_dir2.h"
 #include "xfs_trans_space.h"
-#include "xfs_pnfs.h"
 #include "xfs_iomap.h"
 
 #include <linux/capability.h>
@@ -1030,13 +1029,14 @@ xfs_vn_setattr(
 	int			error;
 
 	if (iattr->ia_valid & ATTR_SIZE) {
-		struct xfs_inode	*ip = XFS_I(d_inode(dentry));
+		struct inode		*inode = d_inode(dentry);
+		struct xfs_inode	*ip = XFS_I(inode);
 		uint			iolock;
 
 		xfs_ilock(ip, XFS_MMAPLOCK_EXCL);
 		iolock = XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL;
 
-		error = xfs_break_layouts(d_inode(dentry), &iolock);
+		error = xfs_break_layouts(inode, &iolock, BREAK_UNMAP);
 		if (error) {
 			xfs_iunlock(ip, XFS_MMAPLOCK_EXCL);
 			return error;
diff --git a/fs/xfs/xfs_pnfs.c b/fs/xfs/xfs_pnfs.c
index 6ea7b0b55d02..f44c3599527d 100644
--- a/fs/xfs/xfs_pnfs.c
+++ b/fs/xfs/xfs_pnfs.c
@@ -31,17 +31,17 @@
  * rules in the page fault path we don't bother.
  */
 int
-xfs_break_layouts(
+xfs_break_leased_layouts(
 	struct inode		*inode,
-	uint			*iolock)
+	uint			*iolock,
+	bool			*did_unlock)
 {
 	struct xfs_inode	*ip = XFS_I(inode);
 	int			error;
 
-	ASSERT(xfs_isilocked(ip, XFS_IOLOCK_SHARED|XFS_IOLOCK_EXCL));
-
 	while ((error = break_layout(inode, false) == -EWOULDBLOCK)) {
 		xfs_iunlock(ip, *iolock);
+		*did_unlock = true;
 		error = break_layout(inode, true);
 		*iolock &= ~XFS_IOLOCK_SHARED;
 		*iolock |= XFS_IOLOCK_EXCL;
@@ -121,8 +121,8 @@ xfs_fs_map_blocks(
 	 * Lock out any other I/O before we flush and invalidate the pagecache,
 	 * and then hand out a layout to the remote system.  This is very
 	 * similar to direct I/O, except that the synchronization is much more
-	 * complicated.  See the comment near xfs_break_layouts for a detailed
-	 * explanation.
+	 * complicated.  See the comment near xfs_break_leased_layouts
+	 * for a detailed explanation.
 	 */
 	xfs_ilock(ip, XFS_IOLOCK_EXCL);
 
diff --git a/fs/xfs/xfs_pnfs.h b/fs/xfs/xfs_pnfs.h
index bf45951e28fe..940c6c2ad88c 100644
--- a/fs/xfs/xfs_pnfs.h
+++ b/fs/xfs/xfs_pnfs.h
@@ -9,10 +9,11 @@ int xfs_fs_map_blocks(struct inode *inode, loff_t offset, u64 length,
 int xfs_fs_commit_blocks(struct inode *inode, struct iomap *maps, int nr_maps,
 		struct iattr *iattr);
 
-int xfs_break_layouts(struct inode *inode, uint *iolock);
+int xfs_break_leased_layouts(struct inode *inode, uint *iolock,
+		bool *did_unlock);
 #else
 static inline int
-xfs_break_layouts(struct inode *inode, uint *iolock)
+xfs_break_leased_layouts(struct inode *inode, uint *iolock, bool *did_unlock)
 {
 	return 0;
 }
