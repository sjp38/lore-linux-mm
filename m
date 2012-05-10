Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 5DA036B0116
	for <linux-mm@kvack.org>; Thu, 10 May 2012 09:54:43 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 09/12] nfs: disable data cache revalidation for swapfiles
Date: Thu, 10 May 2012 14:54:22 +0100
Message-Id: <1336658065-24851-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1336658065-24851-1-git-send-email-mgorman@suse.de>
References: <1336658065-24851-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Mel Gorman <mgorman@suse.de>

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
 fs/nfs/inode.c |    6 ++++++
 fs/nfs/write.c |   49 +++++++++++++++++++++++++++++++++++--------------
 2 files changed, 41 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e8bbfa5..af43ef6 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -880,6 +880,12 @@ int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
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
index 8223b2c..21cfe71 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -111,15 +111,28 @@ static void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
 	set_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
 }
 
-static struct nfs_page *nfs_page_find_request_locked(struct page *page)
+static struct nfs_page *
+nfs_page_find_request_locked(struct nfs_inode *nfsi, struct page *page)
 {
 	struct nfs_page *req = NULL;
 
-	if (PagePrivate(page)) {
+	if (PagePrivate(page))
 		req = (struct nfs_page *)page_private(page);
-		if (req != NULL)
-			kref_get(&req->wb_kref);
+	else if (unlikely(PageSwapCache(page))) {
+		struct nfs_page *freq, *t;
+
+		/* Linearly search the commit list for the correct req */
+		list_for_each_entry_safe(freq, t, &nfsi->commit_list, wb_list) {
+			if (freq->wb_page == page) {
+				req = freq;
+				break;
+			}
+		}
 	}
+
+	if (req)
+		kref_get(&req->wb_kref);
+
 	return req;
 }
 
@@ -129,7 +142,7 @@ static struct nfs_page *nfs_page_find_request(struct page *page)
 	struct nfs_page *req = NULL;
 
 	spin_lock(&inode->i_lock);
-	req = nfs_page_find_request_locked(page);
+	req = nfs_page_find_request_locked(NFS_I(inode), page);
 	spin_unlock(&inode->i_lock);
 	return req;
 }
@@ -232,7 +245,7 @@ static struct nfs_page *nfs_find_and_lock_request(struct page *page, bool nonblo
 
 	spin_lock(&inode->i_lock);
 	for (;;) {
-		req = nfs_page_find_request_locked(page);
+		req = nfs_page_find_request_locked(NFS_I(inode), page);
 		if (req == NULL)
 			break;
 		if (nfs_lock_request_dontget(req))
@@ -385,9 +398,15 @@ static void nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 	spin_lock(&inode->i_lock);
 	if (!nfsi->npages && nfs_have_delegation(inode, FMODE_WRITE))
 		inode->i_version++;
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
 	spin_unlock(&inode->i_lock);
@@ -404,9 +423,11 @@ static void nfs_inode_remove_request(struct nfs_page *req)
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
 	nfsi->npages--;
 	spin_unlock(&inode->i_lock);
 	nfs_release_request(req);
@@ -646,7 +667,7 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 	spin_lock(&inode->i_lock);
 
 	for (;;) {
-		req = nfs_page_find_request_locked(page);
+		req = nfs_page_find_request_locked(NFS_I(inode), page);
 		if (req == NULL)
 			goto out_unlock;
 
@@ -1691,7 +1712,7 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
  */
 int nfs_wb_page(struct inode *inode, struct page *page)
 {
-	loff_t range_start = page_offset(page);
+	loff_t range_start = page_file_offset(page);
 	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
 	struct writeback_control wbc = {
 		.sync_mode = WB_SYNC_ALL,
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
