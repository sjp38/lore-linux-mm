Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5053C6B026F
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 20:54:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u27so7616931pfg.3
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 17:54:01 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id a33si3580620pli.144.2017.10.11.17.53.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 17:53:59 -0700 (PDT)
Subject: [PATCH v9 5/6] fs, xfs, iomap: introduce break_layout_nowait()
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 11 Oct 2017 17:47:35 -0700
Message-ID: <150776925510.9144.2117153288971353589.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

In preparation for using FL_LAYOUT leases to allow coordination between
the kernel and processes doing userspace flushes / RDMA with DAX
mappings, add this helper that can be used to start the lease break
process in contexts where we can not sleep waiting for the lease break
timeout.

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
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Suggested-by: Dave Chinner <david@fromorbit.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/xfs/xfs_iomap.c  |    3 +++
 fs/xfs/xfs_layout.c |    5 ++++-
 include/linux/fs.h  |    9 +++++++++
 3 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/fs/xfs/xfs_iomap.c b/fs/xfs/xfs_iomap.c
index f179bdf1644d..840e4080afb5 100644
--- a/fs/xfs/xfs_iomap.c
+++ b/fs/xfs/xfs_iomap.c
@@ -1055,6 +1055,9 @@ xfs_file_iomap_begin(
 			error = -EAGAIN;
 			goto out_unlock;
 		}
+		error = break_layout_nowait(inode);
+		if (error)
+			goto out_unlock;
 		/*
 		 * We cap the maximum length we map here to MAX_WRITEBACK_PAGES
 		 * pages to keep the chunks of work done where somewhat symmetric
diff --git a/fs/xfs/xfs_layout.c b/fs/xfs/xfs_layout.c
index 71d95e1a910a..7a633b6e9397 100644
--- a/fs/xfs/xfs_layout.c
+++ b/fs/xfs/xfs_layout.c
@@ -19,7 +19,10 @@
  * about exposing unallocated blocks but just want to provide basic
  * synchronization between a local writer and pNFS clients.  mmap writes would
  * also benefit from this sort of synchronization, but due to the tricky locking
- * rules in the page fault path we don't bother.
+ * rules in the page fault path all we can do is start the lease break
+ * timeout. See usage of break_layout_nowait in xfs_file_iomap_begin to
+ * prevent write-faults from allocating blocks or performing extent
+ * conversion.
  */
 int
 xfs_break_layouts(
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 17e0e899e184..2b030a2fccc7 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2364,6 +2364,15 @@ static inline int break_layout(struct inode *inode, bool wait)
 
 #endif /* CONFIG_FILE_LOCKING */
 
+/*
+ * For use in paths where we can not wait for the layout to be recalled,
+ * for example when we are holding mmap_sem.
+ */
+static inline int break_layout_nowait(struct inode *inode)
+{
+	return break_layout(inode, false);
+}
+
 /* fs/open.c */
 struct audit_names;
 struct filename {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
