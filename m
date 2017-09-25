Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 18C6D6B025F
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 19:14:30 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p5so18496724pgn.7
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 16:14:30 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 142si4752383pgg.395.2017.09.25.16.14.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 16:14:28 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH 4/7] xfs: protect S_DAX transitions in XFS write path
Date: Mon, 25 Sep 2017 17:14:01 -0600
Message-Id: <20170925231404.32723-5-ross.zwisler@linux.intel.com>
In-Reply-To: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

In the current XFS write I/O path we check IS_DAX() in
xfs_file_write_iter() to decide whether to do DAX I/O, direct I/O or
buffered I/O.  This check is done without holding the XFS_IOLOCK, though,
which means that if we allow S_DAX to be manipulated via the inode flag we
can run into this race:

CPU 0                           CPU 1
-----                           -----
xfs_file_write_iter()
  IS_DAX() << returns false
			    xfs_ioctl_setattr()
			      xfs_ioctl_setattr_dax_invalidate()
			       xfs_ilock(XFS_MMAPLOCK|XFS_IOLOCK)
			      sets S_DAX
			      releases XFS_MMAPLOCK and XFS_IOLOCK
  xfs_file_buffered_aio_write()
  does buffered I/O to DAX inode, death

Fix this by ensuring that we only check S_DAX when we hold the XFS_IOLOCK
in the write path.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/xfs/xfs_file.c | 115 +++++++++++++++++++++---------------------------------
 1 file changed, 44 insertions(+), 71 deletions(-)

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index ca4c8fd..2816858 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -308,9 +308,7 @@ xfs_zero_eof(
 /*
  * Common pre-write limit and setup checks.
  *
- * Called with the iolocked held either shared and exclusive according to
- * @iolock, and returns with it held.  Might upgrade the iolock to exclusive
- * if called for a direct write beyond i_size.
+ * Called with the iolock held in exclusive mode.
  */
 STATIC ssize_t
 xfs_file_aio_write_checks(
@@ -322,7 +320,6 @@ xfs_file_aio_write_checks(
 	struct inode		*inode = file->f_mapping->host;
 	struct xfs_inode	*ip = XFS_I(inode);
 	ssize_t			error = 0;
-	size_t			count = iov_iter_count(from);
 	bool			drained_dio = false;
 
 restart:
@@ -335,21 +332,9 @@ xfs_file_aio_write_checks(
 		return error;
 
 	/*
-	 * For changing security info in file_remove_privs() we need i_rwsem
-	 * exclusively.
-	 */
-	if (*iolock == XFS_IOLOCK_SHARED && !IS_NOSEC(inode)) {
-		xfs_iunlock(ip, *iolock);
-		*iolock = XFS_IOLOCK_EXCL;
-		xfs_ilock(ip, *iolock);
-		goto restart;
-	}
-	/*
 	 * If the offset is beyond the size of the file, we need to zero any
 	 * blocks that fall between the existing EOF and the start of this
-	 * write.  If zeroing is needed and we are currently holding the
-	 * iolock shared, we need to update it to exclusive which implies
-	 * having to redo all checks before.
+	 * write.
 	 *
 	 * We need to serialise against EOF updates that occur in IO
 	 * completions here. We want to make sure that nobody is changing the
@@ -365,12 +350,6 @@ xfs_file_aio_write_checks(
 
 		spin_unlock(&ip->i_flags_lock);
 		if (!drained_dio) {
-			if (*iolock == XFS_IOLOCK_SHARED) {
-				xfs_iunlock(ip, *iolock);
-				*iolock = XFS_IOLOCK_EXCL;
-				xfs_ilock(ip, *iolock);
-				iov_iter_reexpand(from, count);
-			}
 			/*
 			 * We now have an IO submission barrier in place, but
 			 * AIO can do EOF updates during IO completion and hence
@@ -491,7 +470,8 @@ xfs_dio_write_end_io(
 STATIC ssize_t
 xfs_file_dio_aio_write(
 	struct kiocb		*iocb,
-	struct iov_iter		*from)
+	struct iov_iter		*from,
+	int			*iolock)
 {
 	struct file		*file = iocb->ki_filp;
 	struct address_space	*mapping = file->f_mapping;
@@ -500,7 +480,6 @@ xfs_file_dio_aio_write(
 	struct xfs_mount	*mp = ip->i_mount;
 	ssize_t			ret = 0;
 	int			unaligned_io = 0;
-	int			iolock;
 	size_t			count = iov_iter_count(from);
 	struct xfs_buftarg      *target = XFS_IS_REALTIME_INODE(ip) ?
 					mp->m_rtdev_targp : mp->m_ddev_targp;
@@ -510,11 +489,12 @@ xfs_file_dio_aio_write(
 		return -EINVAL;
 
 	/*
-	 * Don't take the exclusive iolock here unless the I/O is unaligned to
-	 * the file system block size.  We don't need to consider the EOF
-	 * extension case here because xfs_file_aio_write_checks() will relock
-	 * the inode as necessary for EOF zeroing cases and fill out the new
-	 * inode size as appropriate.
+	 * We hold the exclusive iolock via our caller.  After the common
+	 * write checks we will demote it to a shared iolock unless the I/O is
+	 * unaligned to the file system block size.  We don't need to consider
+	 * the EOF extension case here because xfs_file_aio_write_checks()
+	 * will deal with EOF zeroing cases and fill out the new inode size as
+	 * appropriate.
 	 */
 	if ((iocb->ki_pos & mp->m_blockmask) ||
 	    ((iocb->ki_pos + count) & mp->m_blockmask)) {
@@ -528,26 +508,17 @@ xfs_file_dio_aio_write(
 			trace_xfs_reflink_bounce_dio_write(ip, iocb->ki_pos, count);
 			return -EREMCHG;
 		}
-		iolock = XFS_IOLOCK_EXCL;
-	} else {
-		iolock = XFS_IOLOCK_SHARED;
 	}
 
-	if (!xfs_ilock_nowait(ip, iolock)) {
-		if (iocb->ki_flags & IOCB_NOWAIT)
-			return -EAGAIN;
-		xfs_ilock(ip, iolock);
-	}
 
-	ret = xfs_file_aio_write_checks(iocb, from, &iolock);
+	ret = xfs_file_aio_write_checks(iocb, from, iolock);
 	if (ret)
 		goto out;
 	count = iov_iter_count(from);
 
 	/*
 	 * If we are doing unaligned IO, wait for all other IO to drain,
-	 * otherwise demote the lock if we had to take the exclusive lock
-	 * for other reasons in xfs_file_aio_write_checks.
+	 * otherwise demote the lock.
 	 */
 	if (unaligned_io) {
 		/* If we are going to wait for other DIO to finish, bail */
@@ -557,15 +528,14 @@ xfs_file_dio_aio_write(
 		} else {
 			inode_dio_wait(inode);
 		}
-	} else if (iolock == XFS_IOLOCK_EXCL) {
+	} else if (*iolock == XFS_IOLOCK_EXCL) {
 		xfs_ilock_demote(ip, XFS_IOLOCK_EXCL);
-		iolock = XFS_IOLOCK_SHARED;
+		*iolock = XFS_IOLOCK_SHARED;
 	}
 
 	trace_xfs_file_direct_write(ip, count, iocb->ki_pos);
 	ret = iomap_dio_rw(iocb, from, &xfs_iomap_ops, xfs_dio_write_end_io);
 out:
-	xfs_iunlock(ip, iolock);
 
 	/*
 	 * No fallback to buffered IO on errors for XFS, direct IO will either
@@ -578,22 +548,16 @@ xfs_file_dio_aio_write(
 static noinline ssize_t
 xfs_file_dax_write(
 	struct kiocb		*iocb,
-	struct iov_iter		*from)
+	struct iov_iter		*from,
+	int			*iolock)
 {
 	struct inode		*inode = iocb->ki_filp->f_mapping->host;
 	struct xfs_inode	*ip = XFS_I(inode);
-	int			iolock = XFS_IOLOCK_EXCL;
 	ssize_t			ret, error = 0;
 	size_t			count;
 	loff_t			pos;
 
-	if (!xfs_ilock_nowait(ip, iolock)) {
-		if (iocb->ki_flags & IOCB_NOWAIT)
-			return -EAGAIN;
-		xfs_ilock(ip, iolock);
-	}
-
-	ret = xfs_file_aio_write_checks(iocb, from, &iolock);
+	ret = xfs_file_aio_write_checks(iocb, from, iolock);
 	if (ret)
 		goto out;
 
@@ -607,14 +571,14 @@ xfs_file_dax_write(
 		error = xfs_setfilesize(ip, pos, ret);
 	}
 out:
-	xfs_iunlock(ip, iolock);
 	return error ? error : ret;
 }
 
 STATIC ssize_t
 xfs_file_buffered_aio_write(
 	struct kiocb		*iocb,
-	struct iov_iter		*from)
+	struct iov_iter		*from,
+	int			*iolock)
 {
 	struct file		*file = iocb->ki_filp;
 	struct address_space	*mapping = file->f_mapping;
@@ -622,16 +586,12 @@ xfs_file_buffered_aio_write(
 	struct xfs_inode	*ip = XFS_I(inode);
 	ssize_t			ret;
 	int			enospc = 0;
-	int			iolock;
 
 	if (iocb->ki_flags & IOCB_NOWAIT)
 		return -EOPNOTSUPP;
 
 write_retry:
-	iolock = XFS_IOLOCK_EXCL;
-	xfs_ilock(ip, iolock);
-
-	ret = xfs_file_aio_write_checks(iocb, from, &iolock);
+	ret = xfs_file_aio_write_checks(iocb, from, iolock);
 	if (ret)
 		goto out;
 
@@ -653,32 +613,35 @@ xfs_file_buffered_aio_write(
 	 * running at the same time.
 	 */
 	if (ret == -EDQUOT && !enospc) {
-		xfs_iunlock(ip, iolock);
+		xfs_iunlock(ip, *iolock);
 		enospc = xfs_inode_free_quota_eofblocks(ip);
 		if (enospc)
-			goto write_retry;
+			goto lock_retry;
 		enospc = xfs_inode_free_quota_cowblocks(ip);
 		if (enospc)
-			goto write_retry;
-		iolock = 0;
+			goto lock_retry;
+		*iolock = 0;
 	} else if (ret == -ENOSPC && !enospc) {
 		struct xfs_eofblocks eofb = {0};
 
 		enospc = 1;
 		xfs_flush_inodes(ip->i_mount);
 
-		xfs_iunlock(ip, iolock);
+		xfs_iunlock(ip, *iolock);
 		eofb.eof_flags = XFS_EOF_FLAGS_SYNC;
 		xfs_icache_free_eofblocks(ip->i_mount, &eofb);
 		xfs_icache_free_cowblocks(ip->i_mount, &eofb);
-		goto write_retry;
+		goto lock_retry;
 	}
 
 	current->backing_dev_info = NULL;
 out:
-	if (iolock)
-		xfs_iunlock(ip, iolock);
 	return ret;
+lock_retry:
+	xfs_ilock(ip, *iolock);
+	if (IS_DAX(inode))
+		return -EAGAIN;
+	goto write_retry;
 }
 
 STATIC ssize_t
@@ -692,6 +655,7 @@ xfs_file_write_iter(
 	struct xfs_inode	*ip = XFS_I(inode);
 	ssize_t			ret;
 	size_t			ocount = iov_iter_count(from);
+	int			iolock = XFS_IOLOCK_EXCL;
 
 	XFS_STATS_INC(ip->i_mount, xs_write_calls);
 
@@ -701,8 +665,14 @@ xfs_file_write_iter(
 	if (XFS_FORCED_SHUTDOWN(ip->i_mount))
 		return -EIO;
 
+	if (!xfs_ilock_nowait(ip, iolock)) {
+		if (iocb->ki_flags & IOCB_NOWAIT)
+			return -EAGAIN;
+		xfs_ilock(ip, iolock);
+	}
+
 	if (IS_DAX(inode))
-		ret = xfs_file_dax_write(iocb, from);
+		ret = xfs_file_dax_write(iocb, from, &iolock);
 	else if (iocb->ki_flags & IOCB_DIRECT) {
 		/*
 		 * Allow a directio write to fall back to a buffered
@@ -710,14 +680,17 @@ xfs_file_write_iter(
 		 * CoW.  In all other directio scenarios we do not
 		 * allow an operation to fall back to buffered mode.
 		 */
-		ret = xfs_file_dio_aio_write(iocb, from);
+		ret = xfs_file_dio_aio_write(iocb, from, &iolock);
 		if (ret == -EREMCHG)
 			goto buffered;
 	} else {
 buffered:
-		ret = xfs_file_buffered_aio_write(iocb, from);
+		ret = xfs_file_buffered_aio_write(iocb, from, &iolock);
 	}
 
+	if (iolock)
+		xfs_iunlock(ip, iolock);
+
 	if (ret > 0) {
 		XFS_STATS_ADD(ip->i_mount, xs_write_bytes, ret);
 
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
