Message-Id: <20070504103201.534543650@chello.nl>
References: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:27:17 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 26/40] nfs: teach the NFS client how to treat PG_swapcache pages
Content-Disposition: inline; filename=nfs-swapcache.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

Replace all relevant occurences of page->index and page->mapping in the NFS
client with the new page_file_index() and page_file_mapping() functions.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
---
 fs/nfs/file.c     |    4 ++--
 fs/nfs/internal.h |    7 ++++---
 fs/nfs/pagelist.c |    6 +++---
 fs/nfs/read.c     |    6 +++---
 fs/nfs/write.c    |   36 ++++++++++++++++++------------------
 5 files changed, 30 insertions(+), 29 deletions(-)

Index: linux-2.6-git/fs/nfs/file.c
===================================================================
--- linux-2.6-git.orig/fs/nfs/file.c
+++ linux-2.6-git/fs/nfs/file.c
@@ -310,7 +310,7 @@ static void nfs_invalidate_page(struct p
 	if (offset != 0)
 		return;
 	/* Cancel any unstarted writes on this page */
-	nfs_wb_page_priority(page->mapping->host, page, FLUSH_INVALIDATE);
+	nfs_wb_page_priority(page_file_mapping(page)->host, page, FLUSH_INVALIDATE);
 }
 
 static int nfs_release_page(struct page *page, gfp_t gfp)
@@ -321,7 +321,7 @@ static int nfs_release_page(struct page 
 
 static int nfs_launder_page(struct page *page)
 {
-	return nfs_wb_page(page->mapping->host, page);
+	return nfs_wb_page(page_file_mapping(page)->host, page);
 }
 
 const struct address_space_operations nfs_file_aops = {
Index: linux-2.6-git/fs/nfs/pagelist.c
===================================================================
--- linux-2.6-git.orig/fs/nfs/pagelist.c
+++ linux-2.6-git/fs/nfs/pagelist.c
@@ -78,11 +78,11 @@ nfs_create_request(struct nfs_open_conte
 	 * update_nfs_request below if the region is not locked. */
 	req->wb_page    = page;
 	atomic_set(&req->wb_complete, 0);
-	req->wb_index	= page->index;
+	req->wb_index	= page_file_index(page);
 	page_cache_get(page);
 	BUG_ON(PagePrivate(page));
 	BUG_ON(!PageLocked(page));
-	BUG_ON(page->mapping->host != inode);
+	BUG_ON(page_file_mapping(page)->host != inode);
 	req->wb_offset  = offset;
 	req->wb_pgbase	= offset;
 	req->wb_bytes   = count;
@@ -367,7 +367,7 @@ void nfs_pageio_complete(struct nfs_page
  * @nfsi: NFS inode
  * @head: One of the NFS inode request lists
  * @dst: Destination list
- * @idx_start: lower bound of page->index to scan
+ * @idx_start: lower bound of page_file_index(page) to scan
  * @npages: idx_start + npages sets the upper bound to scan.
  *
  * Moves elements from one of the inode request lists.
Index: linux-2.6-git/fs/nfs/read.c
===================================================================
--- linux-2.6-git.orig/fs/nfs/read.c
+++ linux-2.6-git/fs/nfs/read.c
@@ -463,11 +463,11 @@ static const struct rpc_call_ops nfs_rea
 int nfs_readpage(struct file *file, struct page *page)
 {
 	struct nfs_open_context *ctx;
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	int		error;
 
 	dprintk("NFS: nfs_readpage (%p %ld@%lu)\n",
-		page, PAGE_CACHE_SIZE, page->index);
+		page, PAGE_CACHE_SIZE, page_file_index(page));
 	nfs_inc_stats(inode, NFSIOS_VFSREADPAGE);
 	nfs_add_stats(inode, NFSIOS_READPAGES, 1);
 
@@ -514,7 +514,7 @@ static int
 readpage_async_filler(void *data, struct page *page)
 {
 	struct nfs_readdesc *desc = (struct nfs_readdesc *)data;
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_page *new;
 	unsigned int len;
 
Index: linux-2.6-git/fs/nfs/write.c
===================================================================
--- linux-2.6-git.orig/fs/nfs/write.c
+++ linux-2.6-git/fs/nfs/write.c
@@ -121,7 +121,7 @@ static struct nfs_page *nfs_page_find_re
 static struct nfs_page *nfs_page_find_request(struct page *page)
 {
 	struct nfs_page *req = NULL;
-	spinlock_t *req_lock = &NFS_I(page->mapping->host)->req_lock;
+	spinlock_t *req_lock = &NFS_I(page_file_mapping(page)->host)->req_lock;
 
 	spin_lock(req_lock);
 	req = nfs_page_find_request_locked(page);
@@ -132,13 +132,13 @@ static struct nfs_page *nfs_page_find_re
 /* Adjust the file length if we're writing beyond the end */
 static void nfs_grow_file(struct page *page, unsigned int offset, unsigned int count)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	loff_t end, i_size = i_size_read(inode);
 	pgoff_t end_index = (i_size - 1) >> PAGE_CACHE_SHIFT;
 
-	if (i_size > 0 && page->index < end_index)
+	if (i_size > 0 && page_file_index(page) < end_index)
 		return;
-	end = ((loff_t)page->index << PAGE_CACHE_SHIFT) + ((loff_t)offset+count);
+	end = page_offset(page) + ((loff_t)offset+count);
 	if (i_size >= end)
 		return;
 	nfs_inc_stats(inode, NFSIOS_EXTENDWRITE);
@@ -149,7 +149,7 @@ static void nfs_grow_file(struct page *p
 static void nfs_set_pageerror(struct page *page)
 {
 	SetPageError(page);
-	nfs_zap_mapping(page->mapping->host, page->mapping);
+	nfs_zap_mapping(page_file_mapping(page)->host, page_file_mapping(page));
 }
 
 /* We can set the PG_uptodate flag if we see that a write request
@@ -181,7 +181,7 @@ static int nfs_writepage_setup(struct nf
 		ret = PTR_ERR(req);
 		if (ret != -EBUSY)
 			return ret;
-		ret = nfs_wb_page(page->mapping->host, page);
+		ret = nfs_wb_page(page_file_mapping(page)->host, page);
 		if (ret != 0)
 			return ret;
 	}
@@ -217,7 +217,7 @@ static int nfs_set_page_writeback(struct
 	int ret = test_set_page_writeback(page);
 
 	if (!ret) {
-		struct inode *inode = page->mapping->host;
+		struct inode *inode = page_file_mapping(page)->host;
 		struct nfs_server *nfss = NFS_SERVER(inode);
 
 		if (atomic_inc_return(&nfss->writeback) >
@@ -229,7 +229,7 @@ static int nfs_set_page_writeback(struct
 
 static void nfs_end_page_writeback(struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_server *nfss = NFS_SERVER(inode);
 
 	end_page_writeback(page);
@@ -250,7 +250,7 @@ static int nfs_page_async_flush(struct n
 				struct page *page)
 {
 	struct nfs_page *req;
-	struct nfs_inode *nfsi = NFS_I(page->mapping->host);
+	struct nfs_inode *nfsi = NFS_I(page_file_mapping(page)->host);
 	spinlock_t *req_lock = &nfsi->req_lock;
 	int ret;
 
@@ -303,7 +303,7 @@ static int nfs_writepage_locked(struct p
 {
 	struct nfs_pageio_descriptor mypgio, *pgio;
 	struct nfs_open_context *ctx;
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	unsigned offset;
 	int err;
 
@@ -558,7 +558,7 @@ static void nfs_cancel_commit_list(struc
  * nfs_scan_commit - Scan an inode for commit requests
  * @inode: NFS inode to scan
  * @dst: destination list
- * @idx_start: lower bound of page->index to scan.
+ * @idx_start: lower bound of page_file_index(page) to scan.
  * @npages: idx_start + npages sets the upper bound to scan.
  *
  * Moves requests from the inode's 'commit' request list.
@@ -595,7 +595,7 @@ static inline int nfs_scan_commit(struct
 static struct nfs_page * nfs_update_request(struct nfs_open_context* ctx,
 		struct page *page, unsigned int offset, unsigned int bytes)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_file_mapping(page);
 	struct inode *inode = mapping->host;
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_page		*req, *new = NULL;
@@ -698,7 +698,7 @@ int nfs_flush_incompatible(struct file *
 		nfs_release_request(req);
 		if (!do_flush)
 			return 0;
-		status = nfs_wb_page(page->mapping->host, page);
+		status = nfs_wb_page(page_file_mapping(page)->host, page);
 	} while (status == 0);
 	return status;
 }
@@ -713,7 +713,7 @@ int nfs_updatepage(struct file *file, st
 		unsigned int offset, unsigned int count)
 {
 	struct nfs_open_context *ctx = (struct nfs_open_context *)file->private_data;
-	struct inode	*inode = page->mapping->host;
+	struct inode	*inode = page_file_mapping(page)->host;
 	int		status = 0;
 
 	nfs_inc_stats(inode, NFSIOS_VFSUPDATEPAGE);
@@ -964,7 +964,7 @@ static void nfs_writeback_done_partial(s
 	}
 
 	if (nfs_write_need_commit(data)) {
-		spinlock_t *req_lock = &NFS_I(page->mapping->host)->req_lock;
+		spinlock_t *req_lock = &NFS_I(page_file_mapping(page)->host)->req_lock;
 
 		spin_lock(req_lock);
 		if (test_bit(PG_NEED_RESCHED, &req->wb_flags)) {
@@ -1388,7 +1388,7 @@ int nfs_wb_page_priority(struct inode *i
 	loff_t range_start = page_offset(page);
 	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
 	struct writeback_control wbc = {
-		.bdi = page->mapping->backing_dev_info,
+		.bdi = page_file_mapping(page)->backing_dev_info,
 		.sync_mode = WB_SYNC_ALL,
 		.nr_to_write = LONG_MAX,
 		.range_start = range_start,
@@ -1404,7 +1404,7 @@ int nfs_wb_page_priority(struct inode *i
 	}
 	if (!PagePrivate(page))
 		return 0;
-	ret = nfs_sync_mapping_wait(page->mapping, &wbc, how);
+	ret = nfs_sync_mapping_wait(page_file_mapping(page), &wbc, how);
 	if (ret >= 0)
 		return 0;
 out:
@@ -1422,7 +1422,7 @@ int nfs_wb_page(struct inode *inode, str
 
 int nfs_set_page_dirty(struct page *page)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_file_mapping(page);
 	struct inode *inode;
 	spinlock_t *req_lock;
 	struct nfs_page *req;
Index: linux-2.6-git/fs/nfs/internal.h
===================================================================
--- linux-2.6-git.orig/fs/nfs/internal.h
+++ linux-2.6-git/fs/nfs/internal.h
@@ -220,13 +220,14 @@ void nfs_super_set_maxbytes(struct super
 static inline
 unsigned int nfs_page_length(struct page *page)
 {
-	loff_t i_size = i_size_read(page->mapping->host);
+	loff_t i_size = i_size_read(page_file_mapping(page)->host);
 
 	if (i_size > 0) {
+		pgoff_t page_index = page_file_index(page);
 		pgoff_t end_index = (i_size - 1) >> PAGE_CACHE_SHIFT;
-		if (page->index < end_index)
+		if (page_index < end_index)
 			return PAGE_CACHE_SIZE;
-		if (page->index == end_index)
+		if (page_index == end_index)
 			return ((i_size - 1) & ~PAGE_CACHE_MASK) + 1;
 	}
 	return 0;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
