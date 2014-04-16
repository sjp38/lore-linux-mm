Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 71AF86B003C
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 00:18:55 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id b57so8241742eek.21
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 21:18:54 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x46si28099371eea.299.2014.04.15.21.18.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 21:18:54 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Wed, 16 Apr 2014 14:03:36 +1000
Subject: [PATCH 09/19] XFS: ensure xfs_file_*_read cannot deadlock in memory
 allocation.
Message-ID: <20140416040336.10604.90380.stgit@notabene.brown>
In-Reply-To: <20140416033623.10604.69237.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: xfs@oss.sgi.com

xfs_file_*_read holds an inode lock while calling a generic 'read'
function.  These functions perform read-ahead and are quite likely to
allocate memory.
So set PF_FSTRANS to ensure they avoid __GFP_FS and so don't recurse
into a filesystem to free memory.

This can be a problem with loop-back NFS mounts, if free_pages ends up
wating in nfs_release_page(), and nfsd is blocked waiting for the lock
that this code holds.

This was found both by lockdep and as a real deadlock during testing.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/xfs/xfs_file.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 64b48eade91d..88b33ef64668 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -243,6 +243,7 @@ xfs_file_aio_read(
 	ssize_t			ret = 0;
 	int			ioflags = 0;
 	xfs_fsize_t		n;
+	unsigned int		pflags;
 
 	XFS_STATS_INC(xs_read_calls);
 
@@ -290,6 +291,10 @@ xfs_file_aio_read(
 	 * proceeed concurrently without serialisation.
 	 */
 	xfs_rw_ilock(ip, XFS_IOLOCK_SHARED);
+	/* As we hold a lock, we must ensure that any allocation
+	 * in generic_file_aio_read avoid __GFP_FS
+	 */
+	current_set_flags_nested(&pflags, PF_FSTRANS);
 	if ((ioflags & IO_ISDIRECT) && inode->i_mapping->nrpages) {
 		xfs_rw_iunlock(ip, XFS_IOLOCK_SHARED);
 		xfs_rw_ilock(ip, XFS_IOLOCK_EXCL);
@@ -313,6 +318,7 @@ xfs_file_aio_read(
 	if (ret > 0)
 		XFS_STATS_ADD(xs_read_bytes, ret);
 
+	current_restore_flags_nested(&pflags, PF_FSTRANS);
 	xfs_rw_iunlock(ip, XFS_IOLOCK_SHARED);
 	return ret;
 }
@@ -328,6 +334,7 @@ xfs_file_splice_read(
 	struct xfs_inode	*ip = XFS_I(infilp->f_mapping->host);
 	int			ioflags = 0;
 	ssize_t			ret;
+	unsigned int		pflags;
 
 	XFS_STATS_INC(xs_read_calls);
 
@@ -338,6 +345,10 @@ xfs_file_splice_read(
 		return -EIO;
 
 	xfs_rw_ilock(ip, XFS_IOLOCK_SHARED);
+	/* As we hold a lock, we must ensure that any allocation
+	 * in generic_file_splice_read avoid __GFP_FS
+	 */
+	current_set_flags_nested(&pflags, PF_FSTRANS);
 
 	trace_xfs_file_splice_read(ip, count, *ppos, ioflags);
 
@@ -345,6 +356,7 @@ xfs_file_splice_read(
 	if (ret > 0)
 		XFS_STATS_ADD(xs_read_bytes, ret);
 
+	current_restore_flags_nested(&pflags, PF_FSTRANS);
 	xfs_rw_iunlock(ip, XFS_IOLOCK_SHARED);
 	return ret;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
