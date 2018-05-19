Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 066D56B06B1
	for <linux-mm@kvack.org>; Fri, 18 May 2018 21:45:17 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e20-v6so5731734pff.14
        for <linux-mm@kvack.org>; Fri, 18 May 2018 18:45:16 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 61-v6si8358170plc.173.2018.05.18.18.45.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 18:45:15 -0700 (PDT)
Subject: [PATCH v11 5/7] xfs: prepare xfs_break_layouts() to be called with
 XFS_MMAPLOCK_EXCL
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 18 May 2018 18:35:18 -0700
Message-ID: <152669371892.34337.6984922688445598813.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152669369110.34337.14271778212195820353.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152669369110.34337.14271778212195820353.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>Christoph Hellwig <hch@lst.de>"Darrick J. Wong" <darrick.wong@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

In preparation for adding coordination between extent unmap operations
and busy dax-pages, update xfs_break_layouts() to permit it to be called
with the mmap lock held. This lock scheme will be required for
coordinating the break of 'dax layouts' (non-idle dax (ZONE_DEVICE)
pages mapped into the file's address space). Breaking dax layouts will
be added to xfs_break_layouts() in a future patch, for now this preps
the unmap call sites to take and hold XFS_MMAPLOCK_EXCL over the call to
xfs_break_layouts().

Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Dave Chinner <david@fromorbit.com>
Suggested-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: "Darrick J. Wong" <darrick.wong@oracle.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/xfs/xfs_file.c  |    5 +----
 fs/xfs/xfs_ioctl.c |    5 +----
 fs/xfs/xfs_iops.c  |   10 +++++++---
 fs/xfs/xfs_pnfs.c  |    3 ++-
 4 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 299aee4b7b0b..35309bd046be 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -734,7 +734,7 @@ xfs_file_fallocate(
 	struct xfs_inode	*ip = XFS_I(inode);
 	long			error;
 	enum xfs_prealloc_flags	flags = 0;
-	uint			iolock = XFS_IOLOCK_EXCL;
+	uint			iolock = XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL;
 	loff_t			new_size = 0;
 	bool			do_file_insert = false;
 
@@ -748,9 +748,6 @@ xfs_file_fallocate(
 	if (error)
 		goto out_unlock;
 
-	xfs_ilock(ip, XFS_MMAPLOCK_EXCL);
-	iolock |= XFS_MMAPLOCK_EXCL;
-
 	if (mode & FALLOC_FL_PUNCH_HOLE) {
 		error = xfs_free_file_space(ip, offset, len);
 		if (error)
diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index 89fb1eb80aae..4151fade4bb1 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -614,7 +614,7 @@ xfs_ioc_space(
 	struct xfs_inode	*ip = XFS_I(inode);
 	struct iattr		iattr;
 	enum xfs_prealloc_flags	flags = 0;
-	uint			iolock = XFS_IOLOCK_EXCL;
+	uint			iolock = XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL;
 	int			error;
 
 	/*
@@ -648,9 +648,6 @@ xfs_ioc_space(
 	if (error)
 		goto out_unlock;
 
-	xfs_ilock(ip, XFS_MMAPLOCK_EXCL);
-	iolock |= XFS_MMAPLOCK_EXCL;
-
 	switch (bf->l_whence) {
 	case 0: /*SEEK_SET*/
 		break;
diff --git a/fs/xfs/xfs_iops.c b/fs/xfs/xfs_iops.c
index a3ed3c811dfa..138fb36ca875 100644
--- a/fs/xfs/xfs_iops.c
+++ b/fs/xfs/xfs_iops.c
@@ -1031,13 +1031,17 @@ xfs_vn_setattr(
 
 	if (iattr->ia_valid & ATTR_SIZE) {
 		struct xfs_inode	*ip = XFS_I(d_inode(dentry));
-		uint			iolock = XFS_IOLOCK_EXCL;
+		uint			iolock;
+
+		xfs_ilock(ip, XFS_MMAPLOCK_EXCL);
+		iolock = XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL;
 
 		error = xfs_break_layouts(d_inode(dentry), &iolock);
-		if (error)
+		if (error) {
+			xfs_iunlock(ip, XFS_MMAPLOCK_EXCL);
 			return error;
+		}
 
-		xfs_ilock(ip, XFS_MMAPLOCK_EXCL);
 		error = xfs_vn_setattr_size(dentry, iattr);
 		xfs_iunlock(ip, XFS_MMAPLOCK_EXCL);
 	} else {
diff --git a/fs/xfs/xfs_pnfs.c b/fs/xfs/xfs_pnfs.c
index aa6c5c193f45..6ea7b0b55d02 100644
--- a/fs/xfs/xfs_pnfs.c
+++ b/fs/xfs/xfs_pnfs.c
@@ -43,7 +43,8 @@ xfs_break_layouts(
 	while ((error = break_layout(inode, false) == -EWOULDBLOCK)) {
 		xfs_iunlock(ip, *iolock);
 		error = break_layout(inode, true);
-		*iolock = XFS_IOLOCK_EXCL;
+		*iolock &= ~XFS_IOLOCK_SHARED;
+		*iolock |= XFS_IOLOCK_EXCL;
 		xfs_ilock(ip, *iolock);
 	}
 
