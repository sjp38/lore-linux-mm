Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 07E306B007E
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 12:03:51 -0500 (EST)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 03/13] NFS: Cleanup - move nfs_write_inode() into fs/nfs/write.c
Date: Wed, 10 Feb 2010 12:03:23 -0500
Message-Id: <1265821413-21618-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1265821413-21618-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1265821413-21618-1-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-2-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
List-ID: <linux-mm.kvack.org>

The sole purpose of nfs_write_inode is to commit unstable writes, so
move it into fs/nfs/write.c, and make nfs_commit_inode static.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c         |   12 ------------
 fs/nfs/write.c         |   24 +++++++++++++++++++++++-
 include/linux/nfs_fs.h |    7 -------
 3 files changed, 23 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index df0d68e..8819ce2 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -97,18 +97,6 @@ u64 nfs_compat_user_ino64(u64 fileid)
 	return ino;
 }
 
-int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
-{
-	int ret;
-
-	ret = nfs_commit_inode(inode,
-			wbc->sync_mode == WB_SYNC_ALL ? FLUSH_SYNC : 0);
-	if (ret >= 0)
-		return 0;
-	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
-	return ret;
-}
-
 void nfs_clear_inode(struct inode *inode)
 {
 	/*
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d5411e2..9e87612 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1391,7 +1391,7 @@ static const struct rpc_call_ops nfs_commit_ops = {
 	.rpc_release = nfs_commit_release,
 };
 
-int nfs_commit_inode(struct inode *inode, int how)
+static int nfs_commit_inode(struct inode *inode, int how)
 {
 	LIST_HEAD(head);
 	int res;
@@ -1406,13 +1406,35 @@ int nfs_commit_inode(struct inode *inode, int how)
 	}
 	return res;
 }
+
+static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_control *wbc)
+{
+	int ret;
+
+	ret = nfs_commit_inode(inode,
+			wbc->sync_mode == WB_SYNC_ALL ? FLUSH_SYNC : 0);
+	if (ret >= 0)
+		return 0;
+	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
+	return ret;
+}
 #else
 static inline int nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 {
 	return 0;
 }
+
+static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_control *wbc)
+{
+	return 0;
+}
 #endif
 
+int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
+{
+	return nfs_commit_unstable_pages(inode, wbc);
+}
+
 long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_control *wbc, int how)
 {
 	struct inode *inode = mapping->host;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index d09db1b..384ea3e 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -483,15 +483,8 @@ extern int nfs_wb_nocommit(struct inode *inode);
 extern int nfs_wb_page(struct inode *inode, struct page* page);
 extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-extern int  nfs_commit_inode(struct inode *, int);
 extern struct nfs_write_data *nfs_commitdata_alloc(void);
 extern void nfs_commit_free(struct nfs_write_data *wdata);
-#else
-static inline int
-nfs_commit_inode(struct inode *inode, int how)
-{
-	return 0;
-}
 #endif
 
 static inline int
-- 
1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
