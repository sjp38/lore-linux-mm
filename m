Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0BB426B026D
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 20:53:56 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p2so7677177pfk.0
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 17:53:56 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id c23si11831751plk.413.2017.10.11.17.53.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 17:53:54 -0700 (PDT)
Subject: [PATCH v9 4/6] xfs: prepare xfs_break_layouts() for reuse with
 MAP_DIRECT
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 11 Oct 2017 17:47:29 -0700
Message-ID: <150776924929.9144.16449134013197374286.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

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
 fs/xfs/xfs_file.c   |    1 +
 fs/xfs/xfs_ioctl.c  |    1 +
 fs/xfs/xfs_iops.c   |    1 +
 fs/xfs/xfs_layout.c |   42 ++++++++++++++++++++++++++++++++++++++++++
 fs/xfs/xfs_layout.h |   13 +++++++++++++
 fs/xfs/xfs_pnfs.c   |   31 +------------------------------
 fs/xfs/xfs_pnfs.h   |    8 --------
 9 files changed, 64 insertions(+), 38 deletions(-)
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
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 309e26c9dddb..3cc7292b2e9f 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -39,6 +39,7 @@
 #include "xfs_pnfs.h"
 #include "xfs_iomap.h"
 #include "xfs_reflink.h"
+#include "xfs_layout.h"
 
 #include <linux/dcache.h>
 #include <linux/falloc.h>
diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index aa75389be8cf..8bfd6db4f06d 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -44,6 +44,7 @@
 #include "xfs_btree.h"
 #include <linux/fsmap.h>
 #include "xfs_fsmap.h"
+#include "xfs_layout.h"
 
 #include <linux/capability.h>
 #include <linux/cred.h>
diff --git a/fs/xfs/xfs_iops.c b/fs/xfs/xfs_iops.c
index 17081c77ef86..4bc2e5ef1a3a 100644
--- a/fs/xfs/xfs_iops.c
+++ b/fs/xfs/xfs_iops.c
@@ -39,6 +39,7 @@
 #include "xfs_trans_space.h"
 #include "xfs_pnfs.h"
 #include "xfs_iomap.h"
+#include "xfs_layout.h"
 
 #include <linux/capability.h>
 #include <linux/xattr.h>
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
index 4246876df7b7..ee9de16d7672 100644
--- a/fs/xfs/xfs_pnfs.c
+++ b/fs/xfs/xfs_pnfs.c
@@ -18,36 +18,7 @@
 #include "xfs_shared.h"
 #include "xfs_bit.h"
 #include "xfs_pnfs.h"
-
-/*
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
+#include "xfs_layout.h"
 
 /*
  * Get a unique ID including its location so that the client can identify
diff --git a/fs/xfs/xfs_pnfs.h b/fs/xfs/xfs_pnfs.h
index b587cb99b2b7..5a2710dd5478 100644
--- a/fs/xfs/xfs_pnfs.h
+++ b/fs/xfs/xfs_pnfs.h
@@ -7,13 +7,5 @@ int xfs_fs_map_blocks(struct inode *inode, loff_t offset, u64 length,
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
