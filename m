From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 39/47] nfs: livelock prevention is now done in VFS
Date: Mon, 13 Dec 2010 14:43:28 +0800
Message-ID: <20101213064841.798403700@intel.com>
References: <20101213064249.648862451@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=nfs-revert-livelock-72cb77f4a5ac.patch
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Trond Myklebust <Trond.Myklebust@netapp.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

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

--- linux-next.orig/fs/nfs/file.c	2010-12-09 12:21:03.000000000 +0800
+++ linux-next/fs/nfs/file.c	2010-12-09 12:25:01.000000000 +0800
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
--- linux-next.orig/fs/nfs/write.c	2010-12-09 12:21:03.000000000 +0800
+++ linux-next/fs/nfs/write.c	2010-12-09 12:25:01.000000000 +0800
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
--- linux-next.orig/include/linux/nfs_fs.h	2010-12-09 12:21:03.000000000 +0800
+++ linux-next/include/linux/nfs_fs.h	2010-12-09 12:25:01.000000000 +0800
@@ -216,7 +216,6 @@ struct nfs_inode {
 #define NFS_INO_STALE		(1)		/* possible stale inode */
 #define NFS_INO_ACL_LRU_SET	(2)		/* Inode is on the LRU list */
 #define NFS_INO_MOUNTPOINT	(3)		/* inode is remote mountpoint */
-#define NFS_INO_FLUSHING	(4)		/* inode is flushing out data */
 #define NFS_INO_FSCACHE		(5)		/* inode can be cached by FS-Cache */
 #define NFS_INO_FSCACHE_LOCK	(6)		/* FS-Cache cookie management lock */
 #define NFS_INO_COMMIT		(7)		/* inode is committing unstable writes */
