Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 514B16B0087
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 12:03:53 -0500 (EST)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 10/13] NFS: Simplify nfs_wb_page()
Date: Wed, 10 Feb 2010 12:03:30 -0500
Message-Id: <1265821413-21618-11-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1265821413-21618-10-git-send-email-Trond.Myklebust@netapp.com>
References: <1265821413-21618-1-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-2-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-3-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-4-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-5-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-6-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-7-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-8-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-9-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-10-git-send-email-Trond.Myklebust@netapp.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/write.c         |  120 +++++++++--------------------------------------
 include/linux/nfs_fs.h |    1 -
 2 files changed, 23 insertions(+), 98 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index da7f0c4..f438d55 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -501,44 +501,6 @@ int nfs_reschedule_unstable_write(struct nfs_page *req)
 }
 #endif
 
-/*
- * Wait for a request to complete.
- *
- * Interruptible by fatal signals only.
- */
-static int nfs_wait_on_requests_locked(struct inode *inode, pgoff_t idx_start, unsigned int npages)
-{
-	struct nfs_inode *nfsi = NFS_I(inode);
-	struct nfs_page *req;
-	pgoff_t idx_end, next;
-	unsigned int		res = 0;
-	int			error;
-
-	if (npages == 0)
-		idx_end = ~0;
-	else
-		idx_end = idx_start + npages - 1;
-
-	next = idx_start;
-	while (radix_tree_gang_lookup_tag(&nfsi->nfs_page_tree, (void **)&req, next, 1, NFS_PAGE_TAG_LOCKED)) {
-		if (req->wb_index > idx_end)
-			break;
-
-		next = req->wb_index + 1;
-		BUG_ON(!NFS_WBACK_BUSY(req));
-
-		kref_get(&req->wb_kref);
-		spin_unlock(&inode->i_lock);
-		error = nfs_wait_on_request(req);
-		nfs_release_request(req);
-		spin_lock(&inode->i_lock);
-		if (error < 0)
-			return error;
-		res++;
-	}
-	return res;
-}
-
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 static int
 nfs_need_commit(struct nfs_inode *nfsi)
@@ -1421,7 +1383,7 @@ out_mark_dirty:
 	return ret;
 }
 #else
-static inline int nfs_commit_list(struct inode *inode, struct list_head *head, int how)
+static int nfs_commit_inode(struct inode *inode, int how)
 {
 	return 0;
 }
@@ -1437,46 +1399,6 @@ int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
 	return nfs_commit_unstable_pages(inode, wbc);
 }
 
-long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_control *wbc, int how)
-{
-	struct inode *inode = mapping->host;
-	pgoff_t idx_start, idx_end;
-	unsigned int npages = 0;
-	LIST_HEAD(head);
-	long pages, ret;
-
-	/* FIXME */
-	if (wbc->range_cyclic)
-		idx_start = 0;
-	else {
-		idx_start = wbc->range_start >> PAGE_CACHE_SHIFT;
-		idx_end = wbc->range_end >> PAGE_CACHE_SHIFT;
-		if (idx_end > idx_start) {
-			pgoff_t l_npages = 1 + idx_end - idx_start;
-			npages = l_npages;
-			if (sizeof(npages) != sizeof(l_npages) &&
-					(pgoff_t)npages != l_npages)
-				npages = 0;
-		}
-	}
-	spin_lock(&inode->i_lock);
-	do {
-		ret = nfs_wait_on_requests_locked(inode, idx_start, npages);
-		if (ret != 0)
-			continue;
-		pages = nfs_scan_commit(inode, &head, idx_start, npages);
-		if (pages == 0)
-			break;
-		pages += nfs_scan_commit(inode, &head, 0, 0);
-		spin_unlock(&inode->i_lock);
-		ret = nfs_commit_list(inode, &head, how);
-		spin_lock(&inode->i_lock);
-
-	} while (ret >= 0);
-	spin_unlock(&inode->i_lock);
-	return ret;
-}
-
 /*
  * flush the inode to disk.
  */
@@ -1520,45 +1442,49 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 	return ret;
 }
 
-static int nfs_wb_page_priority(struct inode *inode, struct page *page,
-				int how)
+/*
+ * Write back all requests on one page - we do this before reading it.
+ */
+int nfs_wb_page(struct inode *inode, struct page *page)
 {
 	loff_t range_start = page_offset(page);
 	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
 	struct writeback_control wbc = {
-		.bdi = page->mapping->backing_dev_info,
 		.sync_mode = WB_SYNC_ALL,
-		.nr_to_write = LONG_MAX,
+		.nr_to_write = 0,
 		.range_start = range_start,
 		.range_end = range_end,
 	};
+	struct nfs_page *req;
+	int need_commit;
 	int ret;
 
-	do {
+	while(PagePrivate(page)) {
 		if (clear_page_dirty_for_io(page)) {
 			ret = nfs_writepage_locked(page, &wbc);
 			if (ret < 0)
 				goto out_error;
-		} else if (!PagePrivate(page))
+		}
+		req = nfs_find_and_lock_request(page);
+		if (!req)
 			break;
-		ret = nfs_sync_mapping_wait(page->mapping, &wbc, how);
-		if (ret < 0)
+		if (IS_ERR(req)) {
+			ret = PTR_ERR(req);
 			goto out_error;
-	} while (PagePrivate(page));
+		}
+		need_commit = test_bit(PG_CLEAN, &req->wb_flags);
+		nfs_clear_page_tag_locked(req);
+		if (need_commit) {
+			ret = nfs_commit_inode(inode, FLUSH_SYNC);
+			if (ret < 0)
+				goto out_error;
+		}
+	}
 	return 0;
 out_error:
-	__mark_inode_dirty(inode, I_DIRTY_PAGES);
 	return ret;
 }
 
-/*
- * Write back all requests on one page - we do this before reading it.
- */
-int nfs_wb_page(struct inode *inode, struct page* page)
-{
-	return nfs_wb_page_priority(inode, page, FLUSH_STABLE);
-}
-
 #ifdef CONFIG_MIGRATION
 int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
 		struct page *page)
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 3383622..b1e0877 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -474,7 +474,6 @@ extern int nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
  * Try to write back everything synchronously (but check the
  * return value!)
  */
-extern long nfs_sync_mapping_wait(struct address_space *, struct writeback_control *, int);
 extern int nfs_wb_all(struct inode *inode);
 extern int nfs_wb_page(struct inode *inode, struct page* page);
 extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
-- 
1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
