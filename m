Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5596E6B002C
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 11:55:49 -0400 (EDT)
Date: Thu, 20 Oct 2011 23:55:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 1/2] nfs: writeback pages wait queue
Message-ID: <20111020155542.GA7054@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

The generic writeback routines are departing from congestion_wait()
in preference of get_request_wait(), aka. waiting on the block queues.

Introduce the missing writeback wait queue for NFS, otherwise its
writeback pages will grow out of control, exhausting all PG_dirty pages.

Feng: do more coarse grained throttle on each ->writepages rather than
on each page, for better performance and avoid throttled-before-send-rpc
deadlock

CC: Jens Axboe <axboe@kernel.dk>
CC: Chris Mason <chris.mason@oracle.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Feng Tang <feng.tang@intel.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/client.c           |    2 
 fs/nfs/write.c            |   84 +++++++++++++++++++++++++++++++-----
 include/linux/nfs_fs_sb.h |    1 
 3 files changed, 77 insertions(+), 10 deletions(-)

--- linux-next.orig/fs/nfs/write.c	2011-10-20 23:08:17.000000000 +0800
+++ linux-next/fs/nfs/write.c	2011-10-20 23:45:59.000000000 +0800
@@ -190,11 +190,64 @@ static int wb_priority(struct writeback_
  * NFS congestion control
  */
 
+#define NFS_WAIT_PAGES	(1024L >> (PAGE_SHIFT - 10))
 int nfs_congestion_kb;
 
-#define NFS_CONGESTION_ON_THRESH 	(nfs_congestion_kb >> (PAGE_SHIFT-10))
-#define NFS_CONGESTION_OFF_THRESH	\
-	(NFS_CONGESTION_ON_THRESH - (NFS_CONGESTION_ON_THRESH >> 2))
+/*
+ * SYNC requests will block on (2*limit) and wakeup on (2*limit-NFS_WAIT_PAGES)
+ * ASYNC requests will block on (limit) and wakeup on (limit - NFS_WAIT_PAGES)
+ * In this way SYNC writes will never be blocked by ASYNC ones.
+ */
+
+static void nfs_set_congested(long nr, struct backing_dev_info *bdi)
+{
+	long limit = nfs_congestion_kb >> (PAGE_SHIFT - 10);
+
+	if (nr > limit && !test_bit(BDI_async_congested, &bdi->state))
+		set_bdi_congested(bdi, BLK_RW_ASYNC);
+	else if (nr > 2 * limit && !test_bit(BDI_sync_congested, &bdi->state))
+		set_bdi_congested(bdi, BLK_RW_SYNC);
+}
+
+static void nfs_wait_congested(int is_sync,
+			       struct backing_dev_info *bdi,
+			       wait_queue_head_t *wqh)
+{
+	int waitbit = is_sync ? BDI_sync_congested : BDI_async_congested;
+	DEFINE_WAIT(wait);
+
+	if (!test_bit(waitbit, &bdi->state))
+		return;
+
+	for (;;) {
+		prepare_to_wait(&wqh[is_sync], &wait, TASK_UNINTERRUPTIBLE);
+		if (!test_bit(waitbit, &bdi->state))
+			break;
+
+		io_schedule();
+	}
+	finish_wait(&wqh[is_sync], &wait);
+}
+
+static void nfs_wakeup_congested(long nr,
+				 struct backing_dev_info *bdi,
+				 wait_queue_head_t *wqh)
+{
+	long limit = nfs_congestion_kb >> (PAGE_SHIFT - 10);
+
+	if (nr < 2 * limit - min(limit / 8, NFS_WAIT_PAGES)) {
+		if (test_bit(BDI_sync_congested, &bdi->state))
+			clear_bdi_congested(bdi, BLK_RW_SYNC);
+		if (waitqueue_active(&wqh[BLK_RW_SYNC]))
+			wake_up(&wqh[BLK_RW_SYNC]);
+	}
+	if (nr < limit - min(limit / 8, NFS_WAIT_PAGES)) {
+		if (test_bit(BDI_async_congested, &bdi->state))
+			clear_bdi_congested(bdi, BLK_RW_ASYNC);
+		if (waitqueue_active(&wqh[BLK_RW_ASYNC]))
+			wake_up(&wqh[BLK_RW_ASYNC]);
+	}
+}
 
 static int nfs_set_page_writeback(struct page *page)
 {
@@ -205,11 +258,8 @@ static int nfs_set_page_writeback(struct
 		struct nfs_server *nfss = NFS_SERVER(inode);
 
 		page_cache_get(page);
-		if (atomic_long_inc_return(&nfss->writeback) >
-				NFS_CONGESTION_ON_THRESH) {
-			set_bdi_congested(&nfss->backing_dev_info,
-						BLK_RW_ASYNC);
-		}
+		nfs_set_congested(atomic_long_inc_return(&nfss->writeback),
+				  &nfss->backing_dev_info);
 	}
 	return ret;
 }
@@ -221,8 +271,10 @@ static void nfs_end_page_writeback(struc
 
 	end_page_writeback(page);
 	page_cache_release(page);
-	if (atomic_long_dec_return(&nfss->writeback) < NFS_CONGESTION_OFF_THRESH)
-		clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
+
+	nfs_wakeup_congested(atomic_long_dec_return(&nfss->writeback),
+			     &nfss->backing_dev_info,
+			     nfss->writeback_wait);
 }
 
 static struct nfs_page *nfs_find_and_lock_request(struct page *page, bool nonblock)
@@ -323,10 +375,17 @@ static int nfs_writepage_locked(struct p
 
 int nfs_writepage(struct page *page, struct writeback_control *wbc)
 {
+	struct inode *inode = page->mapping->host;
+	struct nfs_server *nfss = NFS_SERVER(inode);
 	int ret;
 
 	ret = nfs_writepage_locked(page, wbc);
 	unlock_page(page);
+
+	nfs_wait_congested(wbc->sync_mode == WB_SYNC_ALL,
+			   &nfss->backing_dev_info,
+			   nfss->writeback_wait);
+
 	return ret;
 }
 
@@ -342,6 +401,7 @@ static int nfs_writepages_callback(struc
 int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 {
 	struct inode *inode = mapping->host;
+	struct nfs_server *nfss = NFS_SERVER(inode);
 	unsigned long *bitlock = &NFS_I(inode)->flags;
 	struct nfs_pageio_descriptor pgio;
 	int err;
@@ -358,6 +418,10 @@ int nfs_writepages(struct address_space 
 	err = write_cache_pages(mapping, wbc, nfs_writepages_callback, &pgio);
 	nfs_pageio_complete(&pgio);
 
+	nfs_wait_congested(wbc->sync_mode == WB_SYNC_ALL,
+			   &nfss->backing_dev_info,
+			   nfss->writeback_wait);
+
 	clear_bit_unlock(NFS_INO_FLUSHING, bitlock);
 	smp_mb__after_clear_bit();
 	wake_up_bit(bitlock, NFS_INO_FLUSHING);
--- linux-next.orig/include/linux/nfs_fs_sb.h	2011-10-20 23:08:17.000000000 +0800
+++ linux-next/include/linux/nfs_fs_sb.h	2011-10-20 23:45:12.000000000 +0800
@@ -102,6 +102,7 @@ struct nfs_server {
 	struct nfs_iostats __percpu *io_stats;	/* I/O statistics */
 	struct backing_dev_info	backing_dev_info;
 	atomic_long_t		writeback;	/* number of writeback pages */
+	wait_queue_head_t	writeback_wait[2];
 	int			flags;		/* various flags */
 	unsigned int		caps;		/* server capabilities */
 	unsigned int		rsize;		/* read size */
--- linux-next.orig/fs/nfs/client.c	2011-10-20 23:08:17.000000000 +0800
+++ linux-next/fs/nfs/client.c	2011-10-20 23:45:12.000000000 +0800
@@ -1066,6 +1066,8 @@ static struct nfs_server *nfs_alloc_serv
 	INIT_LIST_HEAD(&server->layouts);
 
 	atomic_set(&server->active, 0);
+	init_waitqueue_head(&server->writeback_wait[BLK_RW_SYNC]);
+	init_waitqueue_head(&server->writeback_wait[BLK_RW_ASYNC]);
 
 	server->io_stats = nfs_alloc_iostats();
 	if (!server->io_stats) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
