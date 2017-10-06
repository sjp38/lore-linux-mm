Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7856B0260
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 18:42:10 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v78so16170356pgb.4
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 15:42:10 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id j15si1984032pfh.420.2017.10.06.15.42.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 15:42:09 -0700 (PDT)
Subject: [PATCH v7 05/12] xfs: prepare xfs_break_layouts() for reuse with
 MAP_DIRECT
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 06 Oct 2017 15:35:44 -0700
Message-ID: <150732934398.22363.13678051504899020159.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

Move xfs_break_layouts() to its own compilation unit so that it can be
used for both pnfs layouts and MAP_DIRECT mappings.

Cc: Jan Kara <jack@suse.cz>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/xfs/Kconfig      |    4 ++++
 fs/xfs/Makefile     |    1 +
 fs/xfs/xfs_layout.c |   42 ++++++++++++++++++++++++++++++++++++++++++
 fs/xfs/xfs_layout.h |   13 +++++++++++++
 fs/xfs/xfs_pnfs.c   |   30 ------------------------------
 fs/xfs/xfs_pnfs.h   |   10 ++--------
 6 files changed, 62 insertions(+), 38 deletions(-)
 create mode 100644 fs/xfs/xfs_layout.c
 create mode 100644 fs/xfs/xfs_layout.h

diff --git a/fs/xfs/Kconfig b/fs/xfs/Kconfig
index 1b98cfa342ab..f62fc6629abb 100644
--- a/fs/xfs/Kconfig
+++ b/fs/xfs/Kconfig
@@ -109,3 +109,7 @@ config XFS_ASSERT_FATAL
 	  result in warnings.
 
 	  This behavior can be modified at runtime via sysfs.
+
+config XFS_LAYOUT
+	def_bool y
+	depends on EXPORTFS_BLOCK_OPS
diff --git a/fs/xfs/Makefile b/fs/xfs/Makefile
index a6e955bfead8..d44135107490 100644
--- a/fs/xfs/Makefile
+++ b/fs/xfs/Makefile
@@ -135,3 +135,4 @@ xfs-$(CONFIG_XFS_POSIX_ACL)	+= xfs_acl.o
 xfs-$(CONFIG_SYSCTL)		+= xfs_sysctl.o
 xfs-$(CONFIG_COMPAT)		+= xfs_ioctl32.o
 xfs-$(CONFIG_EXPORTFS_BLOCK_OPS)	+= xfs_pnfs.o
+xfs-$(CONFIG_XFS_LAYOUT)	+= xfs_layout.o
diff --git a/fs/xfs/xfs_layout.c b/fs/xfs/xfs_layout.c
new file mode 100644
index 000000000000..71d95e1a910a
--- /dev/null
+++ b/fs/xfs/xfs_layout.c
@@ -0,0 +1,42 @@
+/*
+ * Copyright (c) 2014 Christoph Hellwig.
+ */
+#include "xfs.h"
+#include "xfs_format.h"
+#include "xfs_log_format.h"
+#include "xfs_trans_resv.h"
+#include "xfs_sb.h"
+#include "xfs_mount.h"
+#include "xfs_inode.h"
+
+#include <linux/fs.h>
+
+/*
+ * Ensure that we do not have any outstanding pNFS layouts that can be used by
+ * clients to directly read from or write to this inode.  This must be called
+ * before every operation that can remove blocks from the extent map.
+ * Additionally we call it during the write operation, where aren't concerned
+ * about exposing unallocated blocks but just want to provide basic
+ * synchronization between a local writer and pNFS clients.  mmap writes would
+ * also benefit from this sort of synchronization, but due to the tricky locking
+ * rules in the page fault path we don't bother.
+ */
+int
+xfs_break_layouts(
+	struct inode		*inode,
+	uint			*iolock)
+{
+	struct xfs_inode	*ip = XFS_I(inode);
+	int			error;
+
+	ASSERT(xfs_isilocked(ip, XFS_IOLOCK_SHARED|XFS_IOLOCK_EXCL));
+
+	while ((error = break_layout(inode, false) == -EWOULDBLOCK)) {
+		xfs_iunlock(ip, *iolock);
+		error = break_layout(inode, true);
+		*iolock = XFS_IOLOCK_EXCL;
+		xfs_ilock(ip, *iolock);
+	}
+
+	return error;
+}
diff --git a/fs/xfs/xfs_layout.h b/fs/xfs/xfs_layout.h
new file mode 100644
index 000000000000..f848ee78cc93
--- /dev/null
+++ b/fs/xfs/xfs_layout.h
@@ -0,0 +1,13 @@
+#ifndef _XFS_LAYOUT_H
+#define _XFS_LAYOUT_H 1
+
+#ifdef CONFIG_XFS_LAYOUT
+int xfs_break_layouts(struct inode *inode, uint *iolock);
+#else
+static inline int
+xfs_break_layouts(struct inode *inode, uint *iolock)
+{
+	return 0;
+}
+#endif /* CONFIG_XFS_LAYOUT */
+#endif /* _XFS_LAYOUT_H */
diff --git a/fs/xfs/xfs_pnfs.c b/fs/xfs/xfs_pnfs.c
index 2f2dc3c09ad0..8ec72220e73b 100644
--- a/fs/xfs/xfs_pnfs.c
+++ b/fs/xfs/xfs_pnfs.c
@@ -20,36 +20,6 @@
 #include "xfs_pnfs.h"
 
 /*
- * Ensure that we do not have any outstanding pNFS layouts that can be used by
- * clients to directly read from or write to this inode.  This must be called
- * before every operation that can remove blocks from the extent map.
- * Additionally we call it during the write operation, where aren't concerned
- * about exposing unallocated blocks but just want to provide basic
- * synchronization between a local writer and pNFS clients.  mmap writes would
- * also benefit from this sort of synchronization, but due to the tricky locking
- * rules in the page fault path we don't bother.
- */
-int
-xfs_break_layouts(
-	struct inode		*inode,
-	uint			*iolock)
-{
-	struct xfs_inode	*ip = XFS_I(inode);
-	int			error;
-
-	ASSERT(xfs_isilocked(ip, XFS_IOLOCK_SHARED|XFS_IOLOCK_EXCL));
-
-	while ((error = break_layout(inode, false) == -EWOULDBLOCK)) {
-		xfs_iunlock(ip, *iolock);
-		error = break_layout(inode, true);
-		*iolock = XFS_IOLOCK_EXCL;
-		xfs_ilock(ip, *iolock);
-	}
-
-	return error;
-}
-
-/*
  * Get a unique ID including its location so that the client can identify
  * the exported device.
  */
diff --git a/fs/xfs/xfs_pnfs.h b/fs/xfs/xfs_pnfs.h
index b587cb99b2b7..4135b2482697 100644
--- a/fs/xfs/xfs_pnfs.h
+++ b/fs/xfs/xfs_pnfs.h
@@ -1,19 +1,13 @@
 #ifndef _XFS_PNFS_H
 #define _XFS_PNFS_H 1
 
+#include "xfs_layout.h"
+
 #ifdef CONFIG_EXPORTFS_BLOCK_OPS
 int xfs_fs_get_uuid(struct super_block *sb, u8 *buf, u32 *len, u64 *offset);
 int xfs_fs_map_blocks(struct inode *inode, loff_t offset, u64 length,
 		struct iomap *iomap, bool write, u32 *device_generation);
 int xfs_fs_commit_blocks(struct inode *inode, struct iomap *maps, int nr_maps,
 		struct iattr *iattr);
-
-int xfs_break_layouts(struct inode *inode, uint *iolock);
-#else
-static inline int
-xfs_break_layouts(struct inode *inode, uint *iolock)
-{
-	return 0;
-}
 #endif /* CONFIG_EXPORTFS_BLOCK_OPS */
 #endif /* _XFS_PNFS_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
