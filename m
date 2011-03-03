Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 411648D003C
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 03:17:56 -0500 (EST)
Message-Id: <20110303074950.073028900@intel.com>
Date: Thu, 03 Mar 2011 14:45:16 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 11/27] nfs: limit the commit range
References: <20110303064505.718671603@intel.com>
Content-Disposition: inline; filename=nfs-commit-range.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Trond Myklebust <Trond.Myklebust@netapp.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Hopefully this will help limit the number of unstable pages to be synced
at one time, more timely return of the commit request and reduce dirty
throttle fluctuations.

CC: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/write.c |   20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

--- linux-next.orig/fs/nfs/write.c	2010-12-25 10:13:34.000000000 +0800
+++ linux-next/fs/nfs/write.c	2010-12-25 10:13:35.000000000 +0800
@@ -1304,7 +1304,7 @@ static void nfs_commitdata_release(void 
  */
 static int nfs_commit_rpcsetup(struct list_head *head,
 		struct nfs_write_data *data,
-		int how)
+		int how, pgoff_t offset, pgoff_t count)
 {
 	struct nfs_page *first = nfs_list_entry(head->next);
 	struct inode *inode = first->wb_context->path.dentry->d_inode;
@@ -1336,8 +1336,8 @@ static int nfs_commit_rpcsetup(struct li
 
 	data->args.fh     = NFS_FH(data->inode);
 	/* Note: we always request a commit of the entire inode */
-	data->args.offset = 0;
-	data->args.count  = 0;
+	data->args.offset = offset;
+	data->args.count  = count;
 	data->args.context = get_nfs_open_context(first->wb_context);
 	data->res.count   = 0;
 	data->res.fattr   = &data->fattr;
@@ -1360,7 +1360,8 @@ static int nfs_commit_rpcsetup(struct li
  * Commit dirty pages
  */
 static int
-nfs_commit_list(struct inode *inode, struct list_head *head, int how)
+nfs_commit_list(struct inode *inode, struct list_head *head, int how,
+		pgoff_t offset, pgoff_t count)
 {
 	struct nfs_write_data	*data;
 	struct nfs_page         *req;
@@ -1371,7 +1372,7 @@ nfs_commit_list(struct inode *inode, str
 		goto out_bad;
 
 	/* Set up the argument struct */
-	return nfs_commit_rpcsetup(head, data, how);
+	return nfs_commit_rpcsetup(head, data, how, offset, count);
  out_bad:
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
@@ -1453,6 +1454,8 @@ static const struct rpc_call_ops nfs_com
 int nfs_commit_inode(struct inode *inode, int how)
 {
 	LIST_HEAD(head);
+	pgoff_t first_index;
+	pgoff_t last_index;
 	int may_wait = how & FLUSH_SYNC;
 	int res = 0;
 
@@ -1460,9 +1463,14 @@ int nfs_commit_inode(struct inode *inode
 		goto out_mark_dirty;
 	spin_lock(&inode->i_lock);
 	res = nfs_scan_commit(inode, &head, 0, 0);
+	if (res) {
+		first_index = nfs_list_entry(head.next)->wb_index;
+		last_index  = nfs_list_entry(head.prev)->wb_index;
+	}
 	spin_unlock(&inode->i_lock);
 	if (res) {
-		int error = nfs_commit_list(inode, &head, how);
+		int error = nfs_commit_list(inode, &head, how, first_index,
+					    last_index - first_index + 1);
 		if (error < 0)
 			return error;
 		if (may_wait)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
