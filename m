Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 99B986B007B
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 12:03:52 -0500 (EST)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 04/13] NFS: Reduce the number of unnecessary COMMIT calls
Date: Wed, 10 Feb 2010 12:03:24 -0500
Message-Id: <1265821413-21618-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1265821413-21618-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1265821413-21618-1-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-2-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-3-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
List-ID: <linux-mm.kvack.org>

If the caller is doing a non-blocking flush, and there are still writebacks
pending on the wire, we can usually defer the COMMIT call until those
writes are done.

Also ensure that we honour the wbc->nonblocking flag.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/write.c |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9e87612..ed032c0 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1409,12 +1409,23 @@ static int nfs_commit_inode(struct inode *inode, int how)
 
 static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_control *wbc)
 {
-	int ret;
+	int flags = FLUSH_SYNC;
+	int ret = 0;
 
-	ret = nfs_commit_inode(inode,
-			wbc->sync_mode == WB_SYNC_ALL ? FLUSH_SYNC : 0);
+	/* Don't commit yet if this is a non-blocking flush and there are
+	 * outstanding writes for this mapping.
+	 */
+	if (wbc->sync_mode != WB_SYNC_ALL &&
+	    radix_tree_tagged(&NFS_I(inode)->nfs_page_tree,
+		    NFS_PAGE_TAG_LOCKED))
+		goto out_mark_dirty;
+
+	if (wbc->nonblocking)
+		flags = 0;
+	ret = nfs_commit_inode(inode, flags);
 	if (ret >= 0)
 		return 0;
+out_mark_dirty:
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 	return ret;
 }
-- 
1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
