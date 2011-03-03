Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D62088D0051
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 03:17:59 -0500 (EST)
Message-Id: <20110303074949.665428259@intel.com>
Date: Thu, 03 Mar 2011 14:45:13 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 08/27] nfs: dirty livelock prevention is now done in VFS
References: <20110303064505.718671603@intel.com>
Content-Disposition: inline; filename=nfs-revert-livelock-72cb77f4a5ac.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Trond Myklebust <Trond.Myklebust@netapp.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

This reverts commit 72cb77f4a5 ("NFS: Throttle page dirtying while we're
flushing to disk"). The two problems it tries to address

- sync live lock
- out of order writes

are now all addressed in the VFS

- PAGECACHE_TAG_TOWRITE prevents sync live lock
- IO-less balance_dirty_pages() avoids concurrent writes

CC: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/file.c          |    9 ---------
 fs/nfs/write.c         |   11 -----------
 include/linux/nfs_fs.h |    1 -
 3 files changed, 21 deletions(-)

--- linux-next.orig/fs/nfs/file.c	2011-02-21 14:21:13.000000000 +0800
+++ linux-next/fs/nfs/file.c	2011-02-21 14:28:57.000000000 +0800
@@ -392,15 +392,6 @@ static int nfs_write_begin(struct file *
 			   IOMODE_RW);
 
 start:
-	/*
-	 * Prevent starvation issues if someone is doing a consistency
-	 * sync-to-disk
-	 */
-	ret = wait_on_bit(&NFS_I(mapping->host)->flags, NFS_INO_FLUSHING,
-			nfs_wait_bit_killable, TASK_KILLABLE);
-	if (ret)
-		return ret;
-
 	page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page)
 		return -ENOMEM;
--- linux-next.orig/fs/nfs/write.c	2011-02-21 14:24:57.000000000 +0800
+++ linux-next/fs/nfs/write.c	2011-02-21 14:28:57.000000000 +0800
@@ -337,26 +337,15 @@ static int nfs_writepages_callback(struc
 int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 {
 	struct inode *inode = mapping->host;
-	unsigned long *bitlock = &NFS_I(inode)->flags;
 	struct nfs_pageio_descriptor pgio;
 	int err;
 
-	/* Stop dirtying of new pages while we sync */
-	err = wait_on_bit_lock(bitlock, NFS_INO_FLUSHING,
-			nfs_wait_bit_killable, TASK_KILLABLE);
-	if (err)
-		goto out_err;
-
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGES);
 
 	nfs_pageio_init_write(&pgio, inode, wb_priority(wbc));
 	err = write_cache_pages(mapping, wbc, nfs_writepages_callback, &pgio);
 	nfs_pageio_complete(&pgio);
 
-	clear_bit_unlock(NFS_INO_FLUSHING, bitlock);
-	smp_mb__after_clear_bit();
-	wake_up_bit(bitlock, NFS_INO_FLUSHING);
-
 	if (err < 0)
 		goto out_err;
 	err = pgio.pg_error;
--- linux-next.orig/include/linux/nfs_fs.h	2011-02-21 14:24:59.000000000 +0800
+++ linux-next/include/linux/nfs_fs.h	2011-02-21 14:29:00.000000000 +0800
@@ -215,7 +215,6 @@ struct nfs_inode {
 #define NFS_INO_ADVISE_RDPLUS	(0)		/* advise readdirplus */
 #define NFS_INO_STALE		(1)		/* possible stale inode */
 #define NFS_INO_ACL_LRU_SET	(2)		/* Inode is on the LRU list */
-#define NFS_INO_FLUSHING	(4)		/* inode is flushing out data */
 #define NFS_INO_FSCACHE		(5)		/* inode can be cached by FS-Cache */
 #define NFS_INO_FSCACHE_LOCK	(6)		/* FS-Cache cookie management lock */
 #define NFS_INO_COMMIT		(7)		/* inode is committing unstable writes */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
