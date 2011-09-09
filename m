Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3E4C36B0250
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 07:01:08 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 07/10] nfs: disable data cache revalidation for swapfiles
Date: Fri,  9 Sep 2011 12:00:51 +0100
Message-Id: <1315566054-17209-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1315566054-17209-1-git-send-email-mgorman@suse.de>
References: <1315566054-17209-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

The VM does not like PG_private set on PG_swapcache pages. As suggested
by Trond in http://lkml.org/lkml/2006/8/25/348, this patch disables
NFS data cache revalidation on swap files.  as it does not make
sense to have other clients change the file while it is being used as
swap. This avoids setting PG_private on swap pages, since there ought
to be no further races with invalidate_inode_pages2() to deal with.

Since we cannot set PG_private we cannot use page->private which
is already used by PG_swapcache pages to store the nfs_page. Thus
augment the new nfs_page_find_request logic.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/nfs/inode.c |    6 ++++
 fs/nfs/write.c |   77 +++++++++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 68 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index fe12037..fa25e2c 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -877,6 +877,12 @@ int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
 	struct nfs_inode *nfsi = NFS_I(inode);
 	int ret = 0;
 
+	/*
+	 * swapfiles are not supposed to be shared.
+	 */
+	if (IS_SWAPFILE(inode))
+		goto out;
+
 	if ((nfsi->cache_validity & NFS_INO_REVAL_PAGECACHE)
 			|| nfs_attribute_cache_expired(inode)
 			|| NFS_STALE(inode)) {
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ffd95d1..15e3b7a 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -111,25 +111,64 @@ static void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
 	set_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
 }
 
-static struct nfs_page *nfs_page_find_request_locked(struct page *page)
+static struct nfs_page *
+__nfs_page_find_request_locked(struct nfs_inode *nfsi, struct page *page,
+		int get)
 {
 	struct nfs_page *req = NULL;
 
-	if (PagePrivate(page)) {
+	if (PagePrivate(page))
 		req = (struct nfs_page *)page_private(page);
-		if (req != NULL)
-			kref_get(&req->wb_kref);
-	}
+	else if (unlikely(PageSwapCache(page)))
+		req = radix_tree_lookup(&nfsi->nfs_page_tree,
+				page_file_index(page));
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
@@ -232,7 +271,7 @@ static struct nfs_page *nfs_find_and_lock_request(struct page *page, bool nonblo
 
 	spin_lock(&inode->i_lock);
 	for (;;) {
-		req = nfs_page_find_request_locked(page);
+		req = nfs_page_find_request_locked(NFS_I(inode), page);
 		if (req == NULL)
 			break;
 		if (nfs_set_page_tag_locked(req))
@@ -392,9 +431,15 @@ static int nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 	BUG_ON(error);
 	if (!nfsi->npages && nfs_have_delegation(inode, FMODE_WRITE))
 		nfsi->change_attr++;
-	set_bit(PG_MAPPED, &req->wb_flags);
-	SetPagePrivate(req->wb_page);
-	set_page_private(req->wb_page, (unsigned long)req);
+	/*
+	 * Swap-space should not get truncated. Hence no need to plug the race
+	 * with invalidate/truncate.
+	 */
+	if (likely(!PageSwapCache(req->wb_page))) {
+		set_bit(PG_MAPPED, &req->wb_flags);
+		SetPagePrivate(req->wb_page);
+		set_page_private(req->wb_page, (unsigned long)req);
+	}
 	nfsi->npages++;
 	kref_get(&req->wb_kref);
 	radix_tree_tag_set(&nfsi->nfs_page_tree, req->wb_index,
@@ -416,9 +461,11 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 	BUG_ON (!NFS_WBACK_BUSY(req));
 
 	spin_lock(&inode->i_lock);
-	set_page_private(req->wb_page, 0);
-	ClearPagePrivate(req->wb_page);
-	clear_bit(PG_MAPPED, &req->wb_flags);
+	if (likely(!PageSwapCache(req->wb_page))) {
+		set_page_private(req->wb_page, 0);
+		ClearPagePrivate(req->wb_page);
+		clear_bit(PG_MAPPED, &req->wb_flags);
+	}
 	radix_tree_delete(&nfsi->nfs_page_tree, req->wb_index);
 	nfsi->npages--;
 	spin_unlock(&inode->i_lock);
@@ -593,7 +640,7 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 	spin_lock(&inode->i_lock);
 
 	for (;;) {
-		req = nfs_page_find_request_locked(page);
+		req = nfs_page_find_request_locked(NFS_I(inode), page);
 		if (req == NULL)
 			goto out_unlock;
 
@@ -1657,7 +1704,7 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
  */
 int nfs_wb_page(struct inode *inode, struct page *page)
 {
-	loff_t range_start = page_offset(page);
+	loff_t range_start = page_file_offset(page);
 	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
 	struct writeback_control wbc = {
 		.sync_mode = WB_SYNC_ALL,
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
