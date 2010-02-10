Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B244E6B0083
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 12:03:52 -0500 (EST)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 08/13] NFS: Simplify nfs_wb_page_cancel()
Date: Wed, 10 Feb 2010 12:03:28 -0500
Message-Id: <1265821413-21618-9-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1265821413-21618-8-git-send-email-Trond.Myklebust@netapp.com>
References: <1265821413-21618-1-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-2-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-3-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-4-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-5-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-6-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-7-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-8-git-send-email-Trond.Myklebust@netapp.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
List-ID: <linux-mm.kvack.org>

In all cases we should be able to just remove the request and call
cancel_dirty_page().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/write.c         |   39 +--------------------------------------
 include/linux/nfs_fs.h |    2 --
 2 files changed, 1 insertions(+), 40 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e027f66..1251555 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -539,19 +539,6 @@ static int nfs_wait_on_requests_locked(struct inode *inode, pgoff_t idx_start, u
 	return res;
 }
 
-static void nfs_cancel_commit_list(struct list_head *head)
-{
-	struct nfs_page *req;
-
-	while(!list_empty(head)) {
-		req = nfs_list_entry(head->next);
-		nfs_list_remove_request(req);
-		nfs_clear_request_commit(req);
-		nfs_inode_remove_request(req);
-		nfs_unlock_request(req);
-	}
-}
-
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 static int
 nfs_need_commit(struct nfs_inode *nfsi)
@@ -1484,13 +1471,6 @@ long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_contr
 		pages = nfs_scan_commit(inode, &head, idx_start, npages);
 		if (pages == 0)
 			break;
-		if (how & FLUSH_INVALIDATE) {
-			spin_unlock(&inode->i_lock);
-			nfs_cancel_commit_list(&head);
-			ret = pages;
-			spin_lock(&inode->i_lock);
-			continue;
-		}
 		pages += nfs_scan_commit(inode, &head, 0, 0);
 		spin_unlock(&inode->i_lock);
 		ret = nfs_commit_list(inode, &head, how);
@@ -1547,26 +1527,13 @@ int nfs_wb_nocommit(struct inode *inode)
 int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 {
 	struct nfs_page *req;
-	loff_t range_start = page_offset(page);
-	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
-	struct writeback_control wbc = {
-		.bdi = page->mapping->backing_dev_info,
-		.sync_mode = WB_SYNC_ALL,
-		.nr_to_write = LONG_MAX,
-		.range_start = range_start,
-		.range_end = range_end,
-	};
 	int ret = 0;
 
 	BUG_ON(!PageLocked(page));
 	for (;;) {
 		req = nfs_page_find_request(page);
 		if (req == NULL)
-			goto out;
-		if (test_bit(PG_CLEAN, &req->wb_flags)) {
-			nfs_release_request(req);
 			break;
-		}
 		if (nfs_lock_request_dontget(req)) {
 			nfs_inode_remove_request(req);
 			/*
@@ -1580,12 +1547,8 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 		ret = nfs_wait_on_request(req);
 		nfs_release_request(req);
 		if (ret < 0)
-			goto out;
+			break;
 	}
-	if (!PagePrivate(page))
-		return 0;
-	ret = nfs_sync_mapping_wait(page->mapping, &wbc, FLUSH_INVALIDATE);
-out:
 	return ret;
 }
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 384ea3e..1eec414 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -34,8 +34,6 @@
 #define FLUSH_LOWPRI		8	/* low priority background flush */
 #define FLUSH_HIGHPRI		16	/* high priority memory reclaim flush */
 #define FLUSH_NOCOMMIT		32	/* Don't send the NFSv3/v4 COMMIT */
-#define FLUSH_INVALIDATE	64	/* Invalidate the page cache */
-#define FLUSH_NOWRITEPAGE	128	/* Don't call writepage() */
 
 #ifdef __KERNEL__
 
-- 
1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
