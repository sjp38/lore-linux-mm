Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D113A6B026D
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 10:55:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z80so32669750pff.1
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 07:55:50 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id z7si4506092pgp.424.2017.10.10.07.55.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 07:55:49 -0700 (PDT)
Subject: [PATCH v8 05/14] fs, xfs, iomap: introduce iomap_can_allocate()
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 10 Oct 2017 07:49:24 -0700
Message-ID: <150764696413.16882.17741758404259343219.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150764693502.16882.15848797003793552156.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150764693502.16882.15848797003793552156.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, iommu@lists.linux-foundation.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

In preparation for using FL_LAYOUT leases to allow coordination between
the kernel and processes doing userspace flushes / RDMA with DAX
mappings, add this helper that can be used to detect when block-map
updates are not allowed.

This is targeted to be used in an ->iomap_begin() implementation where
we may have various filesystem locks held and can not synchronously wait
for any FL_LAYOUT leases to be released. In particular an iomap mmap
fault handler running under mmap_sem can not unlock that semaphore and
wait for these leases to be unlocked. Instead, this signals the lease
holder(s) that a break is requested and immediately returns with an
error.

Cc: Jan Kara <jack@suse.cz>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Suggested-by: Dave Chinner <david@fromorbit.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/xfs/xfs_iomap.c    |    3 +++
 fs/xfs/xfs_layout.c   |    5 ++++-
 include/linux/iomap.h |   10 ++++++++++
 3 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/fs/xfs/xfs_iomap.c b/fs/xfs/xfs_iomap.c
index a1909bc064e9..b3cda11e9515 100644
--- a/fs/xfs/xfs_iomap.c
+++ b/fs/xfs/xfs_iomap.c
@@ -1052,6 +1052,9 @@ xfs_file_iomap_begin(
 			error = -EAGAIN;
 			goto out_unlock;
 		}
+		error = iomap_can_allocate(inode);
+		if (error)
+			goto out_unlock;
 		/*
 		 * We cap the maximum length we map here to MAX_WRITEBACK_PAGES
 		 * pages to keep the chunks of work done where somewhat symmetric
diff --git a/fs/xfs/xfs_layout.c b/fs/xfs/xfs_layout.c
index 71d95e1a910a..88c533bf5b7c 100644
--- a/fs/xfs/xfs_layout.c
+++ b/fs/xfs/xfs_layout.c
@@ -19,7 +19,10 @@
  * about exposing unallocated blocks but just want to provide basic
  * synchronization between a local writer and pNFS clients.  mmap writes would
  * also benefit from this sort of synchronization, but due to the tricky locking
- * rules in the page fault path we don't bother.
+ * rules in the page fault path all we can do is start the lease break
+ * timeout. See usage of iomap_can_allocate in xfs_file_iomap_begin to
+ * prevent write-faults from allocating blocks or performing extent
+ * conversion.
  */
 int
 xfs_break_layouts(
diff --git a/include/linux/iomap.h b/include/linux/iomap.h
index f64dc6ce5161..e24b4e81d41a 100644
--- a/include/linux/iomap.h
+++ b/include/linux/iomap.h
@@ -2,6 +2,7 @@
 #define LINUX_IOMAP_H 1
 
 #include <linux/types.h>
+#include <linux/fs.h>
 
 struct fiemap_extent_info;
 struct inode;
@@ -88,6 +89,15 @@ loff_t iomap_seek_hole(struct inode *inode, loff_t offset,
 		const struct iomap_ops *ops);
 loff_t iomap_seek_data(struct inode *inode, loff_t offset,
 		const struct iomap_ops *ops);
+/*
+ * Check if there are any file layout leases preventing block map
+ * changes and if so start the lease break process, but do not wait for
+ * it to complete (return -EWOULDBLOCK);
+ */
+static inline int iomap_can_allocate(struct inode *inode)
+{
+	return break_layout(inode, false);
+}
 
 /*
  * Flags for direct I/O ->end_io:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
