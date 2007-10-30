Message-Id: <20071030160915.511012000@chello.nl>
References: <20071030160401.296770000@chello.nl>
Date: Tue, 30 Oct 2007 17:04:30 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 29/33] nfs: disable data cache revalidation for swapfiles
Content-Disposition: inline; filename=nfs-swapper.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Do as Trond suggested:
  http://lkml.org/lkml/2006/8/25/348

Disable NFS data cache revalidation on swap files since it doesn't really 
make sense to have other clients change the file while you are using it.

Thereby we can stop setting PG_private on swap pages, since there ought to
be no further races with invalidate_inode_pages2() to deal with.

And since we cannot set PG_private we cannot use page->private (which is
already used by PG_swapcache pages anyway) to store the nfs_page. Thus
augment the new nfs_page_find_request logic.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/nfs/inode.c |    6 ++++
 fs/nfs/write.c |   73 ++++++++++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 65 insertions(+), 14 deletions(-)

Index: linux-2.6/fs/nfs/inode.c
===================================================================
--- linux-2.6.orig/fs/nfs/inode.c
+++ linux-2.6/fs/nfs/inode.c
@@ -744,6 +744,12 @@ int nfs_revalidate_mapping_nolock(struct
 	struct nfs_inode *nfsi = NFS_I(inode);
 	int ret = 0;
 
+	/*
+	 * swapfiles are not supposed to be shared.
+	 */
+	if (IS_SWAPFILE(inode))
+		goto out;
+
 	if ((nfsi->cache_validity & NFS_INO_REVAL_PAGECACHE)
 			|| nfs_attribute_timeout(inode) || NFS_STALE(inode)) {
 		ret = __nfs_revalidate_inode(NFS_SERVER(inode), inode);
Index: linux-2.6/fs/nfs/write.c
===================================================================
--- linux-2.6.orig/fs/nfs/write.c
+++ linux-2.6/fs/nfs/write.c
@@ -112,25 +112,62 @@ static void nfs_context_set_write_error(
 	set_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
 }
 
-static struct nfs_page *nfs_page_find_request_locked(struct page *page)
+static struct nfs_page *
+__nfs_page_find_request_locked(struct nfs_inode *nfsi, struct page *page, int get)
 {
 	struct nfs_page *req = NULL;
 
-	if (PagePrivate(page)) {
+	if (PagePrivate(page))
 		req = (struct nfs_page *)page_private(page);
-		if (req != NULL)
-			kref_get(&req->wb_kref);
-	}
+	else if (unlikely(PageSwapCache(page)))
+		req = radix_tree_lookup(&nfsi->nfs_page_tree, page_file_index(page));
+
+	if (get && req)
+		kref_get(&req->wb_kref);
+
 	return req;
 }
 
+static inline struct nfs_page *
+nfs_page_find_request_locked(struct nfs_inode *nfsi, struct page *page)
+{
+	return __nfs_page_find_request_locked(nfsi, page, 1);
+}
+
+static int __nfs_page_has_request(struct page *page)
+{
+	struct inode *inode = page_file_mapping(page)->host;
+	struct nfs_page *req = NULL;
+
+	spin_lock(&inode->i_lock);
+	req = __nfs_page_find_request_locked(NFS_I(inode), page, 0);
+	spin_unlock(&inode->i_lock);
+
+	/*
+	 * hole here plugged by the caller holding onto PG_locked
+	 */
+
+	return req != NULL;
+}
+
+static inline int nfs_page_has_request(struct page *page)
+{
+	if (PagePrivate(page))
+		return 1;
+
+	if (unlikely(PageSwapCache(page)))
+		return __nfs_page_has_request(page);
+
+	return 0;
+}
+
 static struct nfs_page *nfs_page_find_request(struct page *page)
 {
 	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_page *req = NULL;
 
 	spin_lock(&inode->i_lock);
-	req = nfs_page_find_request_locked(page);
+	req = nfs_page_find_request_locked(NFS_I(inode), page);
 	spin_unlock(&inode->i_lock);
 	return req;
 }
@@ -255,7 +292,7 @@ static int nfs_page_async_flush(struct n
 
 	spin_lock(&inode->i_lock);
 	for(;;) {
-		req = nfs_page_find_request_locked(page);
+		req = nfs_page_find_request_locked(nfsi, page);
 		if (req == NULL) {
 			spin_unlock(&inode->i_lock);
 			return 0;
@@ -374,8 +411,14 @@ static int nfs_inode_add_request(struct 
 		if (nfs_have_delegation(inode, FMODE_WRITE))
 			nfsi->change_attr++;
 	}
-	SetPagePrivate(req->wb_page);
-	set_page_private(req->wb_page, (unsigned long)req);
+	/*
+	 * Swap-space should not get truncated. Hence no need to plug the race
+	 * with invalidate/truncate.
+	 */
+	if (likely(!PageSwapCache(req->wb_page))) {
+		SetPagePrivate(req->wb_page);
+		set_page_private(req->wb_page, (unsigned long)req);
+	}
 	nfsi->npages++;
 	kref_get(&req->wb_kref);
 	return 0;
@@ -392,8 +435,10 @@ static void nfs_inode_remove_request(str
 	BUG_ON (!NFS_WBACK_BUSY(req));
 
 	spin_lock(&inode->i_lock);
-	set_page_private(req->wb_page, 0);
-	ClearPagePrivate(req->wb_page);
+	if (likely(!PageSwapCache(req->wb_page))) {
+		set_page_private(req->wb_page, 0);
+		ClearPagePrivate(req->wb_page);
+	}
 	radix_tree_delete(&nfsi->nfs_page_tree, req->wb_index);
 	nfsi->npages--;
 	if (!nfsi->npages) {
@@ -592,7 +637,7 @@ static struct nfs_page * nfs_update_requ
 		 * A request for the page we wish to update
 		 */
 		spin_lock(&inode->i_lock);
-		req = nfs_page_find_request_locked(page);
+		req = nfs_page_find_request_locked(NFS_I(inode), page);
 		if (req) {
 			if (!nfs_lock_request_dontget(req)) {
 				int error;
@@ -1416,7 +1461,7 @@ int nfs_wb_page_cancel(struct inode *ino
 		if (ret < 0)
 			goto out;
 	}
-	if (!PagePrivate(page))
+	if (!nfs_page_has_request(page))
 		return 0;
 	ret = nfs_sync_mapping_wait(page_file_mapping(page), &wbc, FLUSH_INVALIDATE);
 out:
@@ -1443,7 +1488,7 @@ static int nfs_wb_page_priority(struct i
 		if (ret < 0)
 			goto out;
 	}
-	if (!PagePrivate(page))
+	if (!nfs_page_has_request(page))
 		return 0;
 	ret = nfs_sync_mapping_wait(page_file_mapping(page), &wbc, how);
 	if (ret >= 0)

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
