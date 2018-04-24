Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D644E6B0010
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 19:43:44 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c25so1249958pfi.19
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 16:43:44 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id d30-v6si14589650pld.92.2018.04.24.16.43.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 16:43:42 -0700 (PDT)
Subject: [PATCH v9 8/9] xfs: prepare xfs_break_layouts() for another layout
 type
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 24 Apr 2018 16:33:45 -0700
Message-ID: <152461282522.17530.3412820006999654385.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152461278149.17530.2867511144531572045.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152461278149.17530.2867511144531572045.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>Christoph Hellwig <hch@lst.de>, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, jack@suse.czhch@lst.de

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
 fs/xfs/xfs_file.c  |   30 ++++++++++++++++++++++++++++--
 fs/xfs/xfs_inode.h |   16 ++++++++++++++++
 fs/xfs/xfs_ioctl.c |    3 +--
 fs/xfs/xfs_iops.c  |    6 +++---
 fs/xfs/xfs_pnfs.c  |   13 +++++++------
 fs/xfs/xfs_pnfs.h  |    6 ++++--
 6 files changed, 59 insertions(+), 15 deletions(-)

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 35309bd046be..1a5176b21803 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -312,7 +312,7 @@ xfs_file_aio_write_checks(
 	if (error <= 0)
 		return error;
 
-	error = xfs_break_layouts(inode, iolock);
+	error = xfs_break_layouts(inode, iolock, BREAK_WRITE);
 	if (error)
 		return error;
 
@@ -718,6 +718,32 @@ xfs_file_write_iter(
 	return ret;
 }
 
+int
+xfs_break_layouts(
+	struct inode		*inode,
+	uint			*iolock,
+	enum layout_break_reason reason)
+{
+	bool			retry = false;
+	int			error = 0;
+
+	ASSERT(xfs_isilocked(XFS_I(inode), XFS_IOLOCK_SHARED|XFS_IOLOCK_EXCL));
+
+	switch (reason) {
+	case BREAK_UNMAP:
+		ASSERT(xfs_isilocked(XFS_I(inode), XFS_MMAPLOCK_EXCL));
+		/* fall through */
+	case BREAK_WRITE:
+		error = xfs_break_leased_layouts(inode, iolock, &retry);
+		break;
+	default:
+		WARN_ON_ONCE(1);
+		return -EINVAL;
+	}
+
+	return error;
+}
+
 #define	XFS_FALLOC_FL_SUPPORTED						\
 		(FALLOC_FL_KEEP_SIZE | FALLOC_FL_PUNCH_HOLE |		\
 		 FALLOC_FL_COLLAPSE_RANGE | FALLOC_FL_ZERO_RANGE |	\
@@ -744,7 +770,7 @@ xfs_file_fallocate(
 		return -EOPNOTSUPP;
 
 	xfs_ilock(ip, iolock);
-	error = xfs_break_layouts(inode, &iolock);
+	error = xfs_break_layouts(inode, &iolock, BREAK_UNMAP);
 	if (error)
 		goto out_unlock;
 
diff --git a/fs/xfs/xfs_inode.h b/fs/xfs/xfs_inode.h
index 1eebc53df7d7..31401cc9d0e6 100644
--- a/fs/xfs/xfs_inode.h
+++ b/fs/xfs/xfs_inode.h
@@ -379,6 +379,20 @@ static inline void xfs_ifunlock(struct xfs_inode *ip)
 					>> XFS_ILOCK_SHIFT)
 
 /*
+ * Layouts are broken in the BREAK_WRITE case to ensure that
+ * layout-holders do not collide with local writes. Additionally,
+ * layouts are broken in the BREAK_UNMAP case to make sure the
+ * layout-holder has a consistent view of the file's extent map. While
+ * BREAK_WRITE breaks can be satisfied be recalling FL_LAYOUT leases,
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
index 6ea7b0b55d02..40e69edb7e2e 100644
--- a/fs/xfs/xfs_pnfs.c
+++ b/fs/xfs/xfs_pnfs.c
@@ -31,17 +31,18 @@
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
+	*did_unlock = false;
 	while ((error = break_layout(inode, false) == -EWOULDBLOCK)) {
 		xfs_iunlock(ip, *iolock);
+		*did_unlock = true;
 		error = break_layout(inode, true);
 		*iolock &= ~XFS_IOLOCK_SHARED;
 		*iolock |= XFS_IOLOCK_EXCL;
@@ -121,8 +122,8 @@ xfs_fs_map_blocks(
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
index bf45951e28fe..0f2f51037064 100644
--- a/fs/xfs/xfs_pnfs.h
+++ b/fs/xfs/xfs_pnfs.h
@@ -9,11 +9,13 @@ int xfs_fs_map_blocks(struct inode *inode, loff_t offset, u64 length,
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
+	*did_unlock = false;
 	return 0;
 }
 #endif /* CONFIG_EXPORTFS_BLOCK_OPS */
