Message-Id: <20070221144844.179417000@taijtu.programming.kicks-ass.net>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
Date: Wed, 21 Feb 2007 15:43:31 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 27/29] nfs: disable data cache revalidation for swapfiles
Content-Disposition: inline; filename=nfs-swapper.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
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
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
---
 fs/nfs/inode.c |    6 ++++++
 fs/nfs/write.c |   35 +++++++++++++++++++++++------------
 2 files changed, 29 insertions(+), 12 deletions(-)

Index: linux-2.6-git/fs/nfs/inode.c
===================================================================
--- linux-2.6-git.orig/fs/nfs/inode.c	2007-02-21 11:04:08.000000000 +0100
+++ linux-2.6-git/fs/nfs/inode.c	2007-02-21 11:52:21.000000000 +0100
@@ -719,6 +719,12 @@ int nfs_revalidate_mapping_nolock(struct
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
Index: linux-2.6-git/fs/nfs/write.c
===================================================================
--- linux-2.6-git.orig/fs/nfs/write.c	2007-02-21 11:52:17.000000000 +0100
+++ linux-2.6-git/fs/nfs/write.c	2007-02-21 11:53:18.000000000 +0100
@@ -107,7 +107,7 @@ void nfs_writedata_release(void *wdata)
 	nfs_writedata_free(wdata);
 }
 
-static struct nfs_page *nfs_page_find_request_locked(struct page *page)
+static struct nfs_page *nfs_page_find_request_locked(struct nfs_inode *nfsi, struct page *page)
 {
 	struct nfs_page *req = NULL;
 
@@ -115,6 +115,10 @@ static struct nfs_page *nfs_page_find_re
 		req = (struct nfs_page *)page_private(page);
 		if (req != NULL)
 			atomic_inc(&req->wb_count);
+	} else if (unlikely(PageSwapCache(page))) {
+		req = radix_tree_lookup(&nfsi->nfs_page_tree, page_file_index(page));
+		if (req != NULL)
+			atomic_inc(&req->wb_count);
 	}
 	return req;
 }
@@ -122,10 +126,11 @@ static struct nfs_page *nfs_page_find_re
 static struct nfs_page *nfs_page_find_request(struct page *page)
 {
 	struct nfs_page *req = NULL;
-	spinlock_t *req_lock = &NFS_I(page_file_mapping(page)->host)->req_lock;
+	struct nfs_inode *nfsi = NFS_I(page_file_mapping(page)->host);
+	spinlock_t *req_lock = &nfsi->req_lock;
 
 	spin_lock(req_lock);
-	req = nfs_page_find_request_locked(page);
+	req = nfs_page_find_request_locked(nfsi, page);
 	spin_unlock(req_lock);
 	return req;
 }
@@ -248,12 +253,13 @@ static void nfs_end_page_writeback(struc
 static int nfs_page_mark_flush(struct page *page)
 {
 	struct nfs_page *req;
-	spinlock_t *req_lock = &NFS_I(page_file_mapping(page)->host)->req_lock;
+	struct nfs_inode *nfsi = NFS_I(page_file_mapping(page)->host);
+	spinlock_t *req_lock = &nfsi->req_lock;
 	int ret;
 
 	spin_lock(req_lock);
 	for(;;) {
-		req = nfs_page_find_request_locked(page);
+		req = nfs_page_find_request_locked(nfsi, page);
 		if (req == NULL) {
 			spin_unlock(req_lock);
 			return 1;
@@ -368,8 +374,14 @@ static int nfs_inode_add_request(struct 
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
 	atomic_inc(&req->wb_count);
 	return 0;
@@ -386,8 +398,10 @@ static void nfs_inode_remove_request(str
 	BUG_ON (!NFS_WBACK_BUSY(req));
 
 	spin_lock(&nfsi->req_lock);
-	set_page_private(req->wb_page, 0);
-	ClearPagePrivate(req->wb_page);
+	if (likely(!PageSwapCache(req->wb_page))) {
+		set_page_private(req->wb_page, 0);
+		ClearPagePrivate(req->wb_page);
+	}
 	radix_tree_delete(&nfsi->nfs_page_tree, req->wb_index);
 	nfsi->npages--;
 	if (!nfsi->npages) {
@@ -600,7 +614,7 @@ static struct nfs_page * nfs_update_requ
 		 * A request for the page we wish to update
 		 */
 		spin_lock(&nfsi->req_lock);
-		req = nfs_page_find_request_locked(page);
+		req = nfs_page_find_request_locked(nfsi, page);
 		if (req) {
 			if (!nfs_lock_request_dontget(req)) {
 				int error;
@@ -1472,8 +1486,6 @@ int nfs_wb_page_priority(struct inode *i
 		if (ret < 0)
 			goto out;
 	}
-	if (!PagePrivate(page))
-		return 0;
 	ret = nfs_sync_mapping_wait(page_file_mapping(page), &wbc, how);
 	if (ret >= 0)
 		return 0;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
