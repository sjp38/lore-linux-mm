Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3FA696B0085
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 12:03:53 -0500 (EST)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 09/13] NFS: Replace __nfs_write_mapping with sync_inode()
Date: Wed, 10 Feb 2010 12:03:29 -0500
Message-Id: <1265821413-21618-10-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1265821413-21618-9-git-send-email-Trond.Myklebust@netapp.com>
References: <1265821413-21618-1-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-2-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-3-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-4-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-5-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-6-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-7-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-8-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-9-git-send-email-Trond.Myklebust@netapp.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
List-ID: <linux-mm.kvack.org>

Now that we have correct COMMIT semantics in writeback_single_inode, we can
reduce and simplify nfs_wb_all(). Also replace nfs_wb_nocommit() with a
call to filemap_write_and_wait(), which doesn't need to hold the
inode->i_mutex.

With that done, we can eliminate nfs_write_mapping() altogether.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c         |   15 +++++----------
 fs/nfs/write.c         |   42 +++++-------------------------------------
 include/linux/nfs_fs.h |    2 --
 3 files changed, 10 insertions(+), 49 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 8819ce2..13fe0dc 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -495,17 +495,11 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 	int need_atime = NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME;
 	int err;
 
-	/*
-	 * Flush out writes to the server in order to update c/mtime.
-	 *
-	 * Hold the i_mutex to suspend application writes temporarily;
-	 * this prevents long-running writing applications from blocking
-	 * nfs_wb_nocommit.
-	 */
+	/* Flush out writes to the server in order to update c/mtime.  */
 	if (S_ISREG(inode->i_mode)) {
-		mutex_lock(&inode->i_mutex);
-		nfs_wb_nocommit(inode);
-		mutex_unlock(&inode->i_mutex);
+		err = filemap_write_and_wait(inode->i_mapping);
+		if (err)
+			goto out;
 	}
 
 	/*
@@ -529,6 +523,7 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 		generic_fillattr(inode, stat);
 		stat->ino = nfs_compat_user_ino64(NFS_FILEID(inode));
 	}
+out:
 	return err;
 }
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 1251555..da7f0c4 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1443,7 +1443,6 @@ long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_contr
 	pgoff_t idx_start, idx_end;
 	unsigned int npages = 0;
 	LIST_HEAD(head);
-	int nocommit = how & FLUSH_NOCOMMIT;
 	long pages, ret;
 
 	/* FIXME */
@@ -1460,14 +1459,11 @@ long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_contr
 				npages = 0;
 		}
 	}
-	how &= ~FLUSH_NOCOMMIT;
 	spin_lock(&inode->i_lock);
 	do {
 		ret = nfs_wait_on_requests_locked(inode, idx_start, npages);
 		if (ret != 0)
 			continue;
-		if (nocommit)
-			break;
 		pages = nfs_scan_commit(inode, &head, idx_start, npages);
 		if (pages == 0)
 			break;
@@ -1481,47 +1477,19 @@ long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_contr
 	return ret;
 }
 
-static int __nfs_write_mapping(struct address_space *mapping, struct writeback_control *wbc, int how)
-{
-	int ret;
-
-	ret = nfs_writepages(mapping, wbc);
-	if (ret < 0)
-		goto out;
-	ret = nfs_sync_mapping_wait(mapping, wbc, how);
-	if (ret < 0)
-		goto out;
-	return 0;
-out:
-	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
-	return ret;
-}
-
-/* Two pass sync: first using WB_SYNC_NONE, then WB_SYNC_ALL */
-static int nfs_write_mapping(struct address_space *mapping, int how)
+/*
+ * flush the inode to disk.
+ */
+int nfs_wb_all(struct inode *inode)
 {
 	struct writeback_control wbc = {
-		.bdi = mapping->backing_dev_info,
 		.sync_mode = WB_SYNC_ALL,
 		.nr_to_write = LONG_MAX,
 		.range_start = 0,
 		.range_end = LLONG_MAX,
 	};
 
-	return __nfs_write_mapping(mapping, &wbc, how);
-}
-
-/*
- * flush the inode to disk.
- */
-int nfs_wb_all(struct inode *inode)
-{
-	return nfs_write_mapping(inode->i_mapping, 0);
-}
-
-int nfs_wb_nocommit(struct inode *inode)
-{
-	return nfs_write_mapping(inode->i_mapping, FLUSH_NOCOMMIT);
+	return sync_inode(inode, &wbc);
 }
 
 int nfs_wb_page_cancel(struct inode *inode, struct page *page)
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 1eec414..3383622 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -33,7 +33,6 @@
 #define FLUSH_STABLE		4	/* commit to stable storage */
 #define FLUSH_LOWPRI		8	/* low priority background flush */
 #define FLUSH_HIGHPRI		16	/* high priority memory reclaim flush */
-#define FLUSH_NOCOMMIT		32	/* Don't send the NFSv3/v4 COMMIT */
 
 #ifdef __KERNEL__
 
@@ -477,7 +476,6 @@ extern int nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
  */
 extern long nfs_sync_mapping_wait(struct address_space *, struct writeback_control *, int);
 extern int nfs_wb_all(struct inode *inode);
-extern int nfs_wb_nocommit(struct inode *inode);
 extern int nfs_wb_page(struct inode *inode, struct page* page);
 extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-- 
1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
