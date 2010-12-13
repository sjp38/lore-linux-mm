From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 29/35] nfs: in-commit pages accounting and wait queue
Date: Mon, 13 Dec 2010 22:47:15 +0800
Message-ID: <20101213150329.831955132@intel.com>
References: <20101213144646.341970461@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PSA2w-0002Xg-0l
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 16:10:38 +0100
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9C8DB6B00B3
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 10:09:04 -0500 (EST)
Content-Disposition: inline; filename=writeback-nfs-in-commit.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Trond Myklebust <Trond.Myklebust@netapp.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

When doing 10+ concurrent dd's, I observed very bumpy commits submission
(partly because the dd's are started at the same time, and hence reached
4MB to-commit pages at the same time). Basically we rely on the server
to complete and return write/commit requests, and want both to progress
smoothly and not consume too many pages. The write request wait queue is
not enough as it's mainly network bounded. So add another commit request
wait queue. Only async writes need to sleep on this queue.

cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/client.c           |    1 
 fs/nfs/write.c            |   51 ++++++++++++++++++++++++++++++------
 include/linux/nfs_fs_sb.h |    2 +
 3 files changed, 46 insertions(+), 8 deletions(-)

--- linux-next.orig/fs/nfs/write.c	2010-12-13 21:46:21.000000000 +0800
+++ linux-next/fs/nfs/write.c	2010-12-13 21:46:21.000000000 +0800
@@ -516,7 +516,7 @@ nfs_mark_request_commit(struct nfs_page 
 }
 
 static int
-nfs_clear_request_commit(struct nfs_page *req)
+nfs_clear_request_commit(struct inode *inode, struct nfs_page *req)
 {
 	struct page *page = req->wb_page;
 
@@ -554,7 +554,7 @@ nfs_mark_request_commit(struct nfs_page 
 }
 
 static inline int
-nfs_clear_request_commit(struct nfs_page *req)
+nfs_clear_request_commit(struct inode *inode, struct nfs_page *req)
 {
 	return 0;
 }
@@ -599,8 +599,10 @@ nfs_scan_commit(struct inode *inode, str
 		return 0;
 
 	ret = nfs_scan_list(nfsi, dst, idx_start, npages, NFS_PAGE_TAG_COMMIT);
-	if (ret > 0)
+	if (ret > 0) {
 		nfsi->ncommit -= ret;
+		atomic_long_add(ret, &NFS_SERVER(inode)->in_commit);
+	}
 	if (nfs_need_commit(NFS_I(inode)))
 		__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 	return ret;
@@ -668,7 +670,7 @@ static struct nfs_page *nfs_try_to_updat
 		spin_lock(&inode->i_lock);
 	}
 
-	if (nfs_clear_request_commit(req) &&
+	if (nfs_clear_request_commit(inode, req) &&
 			radix_tree_tag_clear(&NFS_I(inode)->nfs_page_tree,
 				req->wb_index, NFS_PAGE_TAG_COMMIT) != NULL)
 		NFS_I(inode)->ncommit--;
@@ -1271,6 +1273,34 @@ int nfs_writeback_done(struct rpc_task *
 
 
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+static void nfs_commit_wait(struct nfs_server *nfss)
+{
+	long limit = nfs_congestion_kb >> (PAGE_SHIFT - 10);
+	DEFINE_WAIT(wait);
+
+	if (atomic_long_read(&nfss->in_commit) < limit)
+		return;
+
+	for (;;) {
+		prepare_to_wait(&nfss->in_commit_wait, &wait,
+				TASK_UNINTERRUPTIBLE);
+		if (atomic_long_read(&nfss->in_commit) < limit)
+			break;
+
+		io_schedule();
+	}
+	finish_wait(&nfss->in_commit_wait, &wait);
+}
+
+static void nfs_commit_wakeup(struct nfs_server *nfss)
+{
+	long limit = nfs_congestion_kb >> (PAGE_SHIFT - 10);
+
+	if (atomic_long_read(&nfss->in_commit) < limit - limit / 8 &&
+	    waitqueue_active(&nfss->in_commit_wait))
+		wake_up(&nfss->in_commit_wait);
+}
+
 static int nfs_commit_set_lock(struct nfs_inode *nfsi, int may_wait)
 {
 	if (!test_and_set_bit(NFS_INO_COMMIT, &nfsi->flags))
@@ -1376,6 +1406,7 @@ nfs_commit_list(struct inode *inode, str
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_mark_request_commit(req);
+		atomic_long_dec(&NFS_SERVER(inode)->in_commit);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
 				BDI_RECLAIMABLE);
@@ -1409,7 +1440,8 @@ static void nfs_commit_release(void *cal
 	while (!list_empty(&data->pages)) {
 		req = nfs_list_entry(data->pages.next);
 		nfs_list_remove_request(req);
-		nfs_clear_request_commit(req);
+		nfs_clear_request_commit(data->inode, req);
+		atomic_long_dec(&NFS_SERVER(data->inode)->in_commit);
 
 		dprintk("NFS:       commit (%s/%lld %d@%lld)",
 			req->wb_context->path.dentry->d_inode->i_sb->s_id,
@@ -1438,6 +1470,7 @@ static void nfs_commit_release(void *cal
 		nfs_clear_page_tag_locked(req);
 	}
 	nfs_commit_clear_lock(NFS_I(data->inode));
+	nfs_commit_wakeup(NFS_SERVER(data->inode));
 	nfs_commitdata_release(calldata);
 }
 
@@ -1452,11 +1485,13 @@ static const struct rpc_call_ops nfs_com
 int nfs_commit_inode(struct inode *inode, int how)
 {
 	LIST_HEAD(head);
-	int may_wait = how & FLUSH_SYNC;
+	int sync = how & FLUSH_SYNC;
 	int res = 0;
 
-	if (!nfs_commit_set_lock(NFS_I(inode), may_wait))
+	if (!nfs_commit_set_lock(NFS_I(inode), sync))
 		goto out_mark_dirty;
+	if (!sync)
+		nfs_commit_wait(NFS_SERVER(inode));
 	spin_lock(&inode->i_lock);
 	res = nfs_scan_commit(inode, &head, 0, 0);
 	spin_unlock(&inode->i_lock);
@@ -1464,7 +1499,7 @@ int nfs_commit_inode(struct inode *inode
 		int error = nfs_commit_list(inode, &head, how);
 		if (error < 0)
 			return error;
-		if (may_wait)
+		if (sync)
 			wait_on_bit(&NFS_I(inode)->flags, NFS_INO_COMMIT,
 					nfs_wait_bit_killable,
 					TASK_KILLABLE);
--- linux-next.orig/include/linux/nfs_fs_sb.h	2010-12-13 21:46:21.000000000 +0800
+++ linux-next/include/linux/nfs_fs_sb.h	2010-12-13 21:46:21.000000000 +0800
@@ -107,6 +107,8 @@ struct nfs_server {
 	struct backing_dev_info	backing_dev_info;
 	atomic_long_t		writeback;	/* number of writeback pages */
 	wait_queue_head_t	writeback_wait[2];
+	atomic_long_t		in_commit;	/* number of in-commit pages */
+	wait_queue_head_t	in_commit_wait;
 	int			flags;		/* various flags */
 	unsigned int		caps;		/* server capabilities */
 	unsigned int		rsize;		/* read size */
--- linux-next.orig/fs/nfs/client.c	2010-12-13 21:46:21.000000000 +0800
+++ linux-next/fs/nfs/client.c	2010-12-13 21:46:21.000000000 +0800
@@ -1008,6 +1008,7 @@ static struct nfs_server *nfs_alloc_serv
 	atomic_set(&server->active, 0);
 	init_waitqueue_head(&server->writeback_wait[BLK_RW_SYNC]);
 	init_waitqueue_head(&server->writeback_wait[BLK_RW_ASYNC]);
+	init_waitqueue_head(&server->in_commit_wait);
 
 	server->io_stats = nfs_alloc_iostats();
 	if (!server->io_stats) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
