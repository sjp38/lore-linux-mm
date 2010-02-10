Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8566D6B007E
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 12:03:54 -0500 (EST)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 07/13] NFS: Ensure inode is always marked I_DIRTY_DATASYNC, if it has unstable pages
Date: Wed, 10 Feb 2010 12:03:27 -0500
Message-Id: <1265821413-21618-8-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1265821413-21618-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1265821413-21618-1-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-2-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-3-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-4-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-5-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-6-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-7-git-send-email-Trond.Myklebust@netapp.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
List-ID: <linux-mm.kvack.org>

Since nfs_scan_list() doesn't wait for locked pages, we have a race in
which it is possible to end up with an inode that needs to send a COMMIT,
but which does not have the I_DIRTY_DATASYNC flag set.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/write.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 8533a2f..e027f66 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -573,11 +573,15 @@ static int
 nfs_scan_commit(struct inode *inode, struct list_head *dst, pgoff_t idx_start, unsigned int npages)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
+	int ret;
 
 	if (!nfs_need_commit(nfsi))
 		return 0;
 
-	return nfs_scan_list(nfsi, dst, idx_start, npages, NFS_PAGE_TAG_COMMIT);
+	ret = nfs_scan_list(nfsi, dst, idx_start, npages, NFS_PAGE_TAG_COMMIT);
+	if (nfs_need_commit(NFS_I(inode)))
+		__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
+	return ret;
 }
 #else
 static inline int nfs_need_commit(struct nfs_inode *nfsi)
-- 
1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
