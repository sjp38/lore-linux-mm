Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8098D6B06B5
	for <linux-mm@kvack.org>; Fri, 18 May 2018 21:45:28 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id i1-v6so6098634pld.11
        for <linux-mm@kvack.org>; Fri, 18 May 2018 18:45:28 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id b19-v6si8696723pfh.358.2018.05.18.18.45.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 18:45:27 -0700 (PDT)
Subject: [PATCH v11 7/7] xfs, dax: introduce xfs_break_dax_layouts()
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 18 May 2018 18:35:29 -0700
Message-ID: <152669372916.34337.4066620800998291994.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152669369110.34337.14271778212195820353.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152669369110.34337.14271778212195820353.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Dave Chinner <david@fromorbit.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

xfs_break_dax_layouts(), similar to xfs_break_leased_layouts(), scans
for busy / pinned dax pages and waits for those pages to go idle before
any potential extent unmap operation.

dax_layout_busy_page() handles synchronizing against new page-busy
events (get_user_pages). It invalidates all mappings to trigger the
get_user_pages slow path which will eventually block on the xfs inode
lock held in XFS_MMAPLOCK_EXCL mode. If dax_layout_busy_page() finds a
busy page it returns it for xfs to wait for the page-idle event that
will fire when the page reference count reaches 1 (recall ZONE_DEVICE
pages are idle at count 1, see generic_dax_pagefree()).

While waiting, the XFS_MMAPLOCK_EXCL lock is dropped in order to not
deadlock the process that might be trying to elevate the page count of
more pages before arranging for any of them to go idle. I.e. the typical
case of submitting I/O is that iov_iter_get_pages() elevates the
reference count of all pages in the I/O before starting I/O on the first
page. The process of elevating the reference count of all pages involved
in an I/O may cause faults that need to take XFS_MMAPLOCK_EXCL.

Although XFS_MMAPLOCK_EXCL is dropped while waiting, XFS_IOLOCK_EXCL is
held while sleeping. We need this to prevent starvation of the truncate
path as continuous submission of direct-I/O could starve the truncate
path indefinitely if the lock is dropped.

Cc: Dave Chinner <david@fromorbit.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Reported-by: Jan Kara <jack@suse.cz>
Reviewed-by: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@lst.de>
Acked-by: Darrick J. Wong <darrick.wong@oracle.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/xfs/xfs_file.c |   61 ++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 51 insertions(+), 10 deletions(-)

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 4774c7172ef4..f5695dc314f1 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -718,6 +718,38 @@ xfs_file_write_iter(
 	return ret;
 }
 
+static void
+xfs_wait_dax_page(
+	struct inode		*inode,
+	bool			*did_unlock)
+{
+	struct xfs_inode        *ip = XFS_I(inode);
+
+	*did_unlock = true;
+	xfs_iunlock(ip, XFS_MMAPLOCK_EXCL);
+	schedule();
+	xfs_ilock(ip, XFS_MMAPLOCK_EXCL);
+}
+
+static int
+xfs_break_dax_layouts(
+	struct inode		*inode,
+	uint			iolock,
+	bool			*did_unlock)
+{
+	struct page		*page;
+
+	ASSERT(xfs_isilocked(XFS_I(inode), XFS_MMAPLOCK_EXCL));
+
+	page = dax_layout_busy_page(inode->i_mapping);
+	if (!page)
+		return 0;
+
+	return ___wait_var_event(&page->_refcount,
+			atomic_read(&page->_refcount) == 1, TASK_INTERRUPTIBLE,
+			0, 0, xfs_wait_dax_page(inode, did_unlock));
+}
+
 int
 xfs_break_layouts(
 	struct inode		*inode,
@@ -725,19 +757,28 @@ xfs_break_layouts(
 	enum layout_break_reason reason)
 {
 	bool			retry;
+	int			error;
 
 	ASSERT(xfs_isilocked(XFS_I(inode), XFS_IOLOCK_SHARED|XFS_IOLOCK_EXCL));
 
-	switch (reason) {
-	case BREAK_UNMAP:
-		ASSERT(xfs_isilocked(XFS_I(inode), XFS_MMAPLOCK_EXCL));
-		/* fall through */
-	case BREAK_WRITE:
-		return xfs_break_leased_layouts(inode, iolock, &retry);
-	default:
-		WARN_ON_ONCE(1);
-		return -EINVAL;
-	}
+	do {
+		retry = false;
+		switch (reason) {
+		case BREAK_UNMAP:
+			error = xfs_break_dax_layouts(inode, *iolock, &retry);
+			if (error || retry)
+				break;
+			/* fall through */
+		case BREAK_WRITE:
+			error = xfs_break_leased_layouts(inode, iolock, &retry);
+			break;
+		default:
+			WARN_ON_ONCE(1);
+			error = -EINVAL;
+		}
+	} while (error == 0 && retry);
+
+	return error;
 }
 
 #define	XFS_FALLOC_FL_SUPPORTED						\
