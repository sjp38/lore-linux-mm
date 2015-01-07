Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 785EA6B0073
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 17:26:18 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so7643856pab.0
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 14:26:18 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id sj1si5447303pbc.68.2015.01.07.14.26.12
        for <linux-mm@kvack.org>;
        Wed, 07 Jan 2015 14:26:14 -0800 (PST)
From: Dave Chinner <david@fromorbit.com>
Subject: [RFC PATCH 4/6] xfs: take i_mmap_lock on extent manipulation operations
Date: Thu,  8 Jan 2015 09:25:41 +1100
Message-Id: <1420669543-8093-5-git-send-email-david@fromorbit.com>
In-Reply-To: <1420669543-8093-1-git-send-email-david@fromorbit.com>
References: <1420669543-8093-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xfs@oss.sgi.com
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

From: Dave Chinner <dchinner@redhat.com>

Now we have the i_mmap_lock being held across the page fault IO
path, we now add extent manipulation operation exclusion by adding
the lock to the paths that directly modify extent maps. This
includes truncate, hole punching and other fallocate based
operations. The operations will now take both the i_iolock and the
i_mmaplock in exclusive mode, thereby ensuring that all IO and page
faults block without holding any page locks while the extent
manipulation is in progress.

This gives us the lock order during truncate of i_iolock ->
i_mmaplock -> page_lock -> i_lock, hence providing the same
lock order as the iolock provides the normal IO path without
involving the mmap_sem.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_file.c  | 4 ++--
 fs/xfs/xfs_ioctl.c | 4 ++--
 fs/xfs/xfs_iops.c  | 6 +++---
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index e6e7e75..b08c9e6 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -794,7 +794,7 @@ xfs_file_fallocate(
 		     FALLOC_FL_COLLAPSE_RANGE | FALLOC_FL_ZERO_RANGE))
 		return -EOPNOTSUPP;
 
-	xfs_ilock(ip, XFS_IOLOCK_EXCL);
+	xfs_ilock(ip, XFS_IOLOCK_EXCL|XFS_MMAPLOCK_EXCL);
 	if (mode & FALLOC_FL_PUNCH_HOLE) {
 		error = xfs_free_file_space(ip, offset, len);
 		if (error)
@@ -874,7 +874,7 @@ xfs_file_fallocate(
 	}
 
 out_unlock:
-	xfs_iunlock(ip, XFS_IOLOCK_EXCL);
+	xfs_iunlock(ip, XFS_IOLOCK_EXCL|XFS_MMAPLOCK_EXCL);
 	return error;
 }
 
diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index a183198..8810959 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -634,7 +634,7 @@ xfs_ioc_space(
 	if (error)
 		return error;
 
-	xfs_ilock(ip, XFS_IOLOCK_EXCL);
+	xfs_ilock(ip, XFS_IOLOCK_EXCL|XFS_MMAPLOCK_EXCL);
 
 	switch (bf->l_whence) {
 	case 0: /*SEEK_SET*/
@@ -751,7 +751,7 @@ xfs_ioc_space(
 	error = xfs_trans_commit(tp, 0);
 
 out_unlock:
-	xfs_iunlock(ip, XFS_IOLOCK_EXCL);
+	xfs_iunlock(ip, XFS_IOLOCK_EXCL|XFS_MMAPLOCK_EXCL);
 	mnt_drop_write_file(filp);
 	return error;
 }
diff --git a/fs/xfs/xfs_iops.c b/fs/xfs/xfs_iops.c
index 8be5bb5..f491860 100644
--- a/fs/xfs/xfs_iops.c
+++ b/fs/xfs/xfs_iops.c
@@ -768,7 +768,7 @@ xfs_setattr_size(
 	if (error)
 		return error;
 
-	ASSERT(xfs_isilocked(ip, XFS_IOLOCK_EXCL));
+	ASSERT(xfs_isilocked(ip, XFS_IOLOCK_EXCL|XFS_MMAPLOCK_EXCL));
 	ASSERT(S_ISREG(ip->i_d.di_mode));
 	ASSERT((iattr->ia_valid & (ATTR_UID|ATTR_GID|ATTR_ATIME|ATTR_ATIME_SET|
 		ATTR_MTIME_SET|ATTR_KILL_PRIV|ATTR_TIMES_SET)) == 0);
@@ -984,9 +984,9 @@ xfs_vn_setattr(
 	int			error;
 
 	if (iattr->ia_valid & ATTR_SIZE) {
-		xfs_ilock(ip, XFS_IOLOCK_EXCL);
+		xfs_ilock(ip, XFS_IOLOCK_EXCL|XFS_MMAPLOCK_EXCL);
 		error = xfs_setattr_size(ip, iattr);
-		xfs_iunlock(ip, XFS_IOLOCK_EXCL);
+		xfs_iunlock(ip, XFS_IOLOCK_EXCL|XFS_MMAPLOCK_EXCL);
 	} else {
 		error = xfs_setattr_nonsize(ip, iattr, 0);
 	}
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
