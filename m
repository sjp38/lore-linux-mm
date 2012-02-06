Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 1EA606B1409
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 17:56:52 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 07/11] nfs: teach the NFS client how to treat PG_swapcache pages
Date: Mon,  6 Feb 2012 22:56:37 +0000
Message-Id: <1328569001-17599-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1328569001-17599-1-git-send-email-mgorman@suse.de>
References: <1328569001-17599-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

Replace all relevant occurences of page->index and page->mapping in
the NFS client with the new page_file_index() and page_file_mapping()
functions.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/nfs/file.c     |    6 +++---
 fs/nfs/internal.h |    7 ++++---
 fs/nfs/pagelist.c |    6 +++---
 fs/nfs/read.c     |    6 +++---
 fs/nfs/write.c    |   43 +++++++++++++++++++++++--------------------
 5 files changed, 36 insertions(+), 32 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index c43a452..2a0a750 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -435,7 +435,7 @@ static void nfs_invalidate_page(struct page *page, unsigned long offset)
 	if (offset != 0)
 		return;
 	/* Cancel any unstarted writes on this page */
-	nfs_wb_page_cancel(page->mapping->host, page);
+	nfs_wb_page_cancel(page_file_mapping(page)->host, page);
 
 	nfs_fscache_invalidate_page(page, page->mapping->host);
 }
@@ -477,7 +477,7 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
  */
 static int nfs_launder_page(struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_inode *nfsi = NFS_I(inode);
 
 	dfprintk(PAGECACHE, "NFS: launder_page(%ld, %llu)\n",
@@ -526,7 +526,7 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	nfs_fscache_wait_on_page_write(NFS_I(dentry->d_inode), page);
 
 	lock_page(page);
-	mapping = page->mapping;
+	mapping = page_file_mapping(page);
 	if (mapping != dentry->d_inode->i_mapping)
 		goto out_unlock;
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 8102db9..0740dab 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -429,13 +429,14 @@ void nfs_super_set_maxbytes(struct super_block *sb, __u64 maxfilesize)
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
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 5668f7c..5ab80e3 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -76,11 +76,11 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
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
@@ -430,7 +430,7 @@ void nfs_pageio_cond_complete(struct nfs_pageio_descriptor *desc, pgoff_t index)
  * nfs_scan_list - Scan a list for matching requests
  * @nfsi: NFS inode
  * @dst: Destination list
- * @idx_start: lower bound of page->index to scan
+ * @idx_start: lower bound of page_file_index(page) to scan
  * @npages: idx_start + npages sets the upper bound to scan.
  * @tag: tag to scan for
  *
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index cfa175c..075c64c 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -561,11 +561,11 @@ static const struct rpc_call_ops nfs_read_full_ops = {
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
 
@@ -619,7 +619,7 @@ static int
 readpage_async_filler(void *data, struct page *page)
 {
 	struct nfs_readdesc *desc = (struct nfs_readdesc *)data;
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_page *new;
 	unsigned int len;
 	int error;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 834f0fe..9bd8cf6 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -126,7 +126,7 @@ static struct nfs_page *nfs_page_find_request_locked(struct page *page)
 
 static struct nfs_page *nfs_page_find_request(struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_page *req = NULL;
 
 	spin_lock(&inode->i_lock);
@@ -138,16 +138,16 @@ static struct nfs_page *nfs_page_find_request(struct page *page)
 /* Adjust the file length if we're writing beyond the end */
 static void nfs_grow_file(struct page *page, unsigned int offset, unsigned int count)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	loff_t end, i_size;
 	pgoff_t end_index;
 
 	spin_lock(&inode->i_lock);
 	i_size = i_size_read(inode);
 	end_index = (i_size - 1) >> PAGE_CACHE_SHIFT;
-	if (i_size > 0 && page->index < end_index)
+	if (i_size > 0 && page_file_index(page) < end_index)
 		goto out;
-	end = ((loff_t)page->index << PAGE_CACHE_SHIFT) + ((loff_t)offset+count);
+	end = page_file_offset(page) + ((loff_t)offset+count);
 	if (i_size >= end)
 		goto out;
 	i_size_write(inode, end);
@@ -160,7 +160,7 @@ out:
 static void nfs_set_pageerror(struct page *page)
 {
 	SetPageError(page);
-	nfs_zap_mapping(page->mapping->host, page->mapping);
+	nfs_zap_mapping(page_file_mapping(page)->host, page_file_mapping(page));
 }
 
 /* We can set the PG_uptodate flag if we see that a write request
@@ -201,7 +201,7 @@ static int nfs_set_page_writeback(struct page *page)
 	int ret = test_set_page_writeback(page);
 
 	if (!ret) {
-		struct inode *inode = page->mapping->host;
+		struct inode *inode = page_file_mapping(page)->host;
 		struct nfs_server *nfss = NFS_SERVER(inode);
 
 		page_cache_get(page);
@@ -216,7 +216,7 @@ static int nfs_set_page_writeback(struct page *page)
 
 static void nfs_end_page_writeback(struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_server *nfss = NFS_SERVER(inode);
 
 	end_page_writeback(page);
@@ -227,7 +227,7 @@ static void nfs_end_page_writeback(struct page *page)
 
 static struct nfs_page *nfs_find_and_lock_request(struct page *page, bool nonblock)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_page *req;
 	int ret;
 
@@ -288,13 +288,13 @@ out:
 
 static int nfs_do_writepage(struct page *page, struct writeback_control *wbc, struct nfs_pageio_descriptor *pgio)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	int ret;
 
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGE);
 	nfs_add_stats(inode, NFSIOS_WRITEPAGES, 1);
 
-	nfs_pageio_cond_complete(pgio, page->index);
+	nfs_pageio_cond_complete(pgio, page_file_index(page));
 	ret = nfs_page_async_flush(pgio, page, wbc->sync_mode == WB_SYNC_NONE);
 	if (ret == -EAGAIN) {
 		redirty_page_for_writepage(wbc, page);
@@ -311,7 +311,8 @@ static int nfs_writepage_locked(struct page *page, struct writeback_control *wbc
 	struct nfs_pageio_descriptor pgio;
 	int err;
 
-	nfs_pageio_init_write(&pgio, page->mapping->host, wb_priority(wbc));
+	nfs_pageio_init_write(&pgio, page_file_mapping(page)->host,
+			wb_priority(wbc));
 	err = nfs_do_writepage(page, wbc, &pgio);
 	nfs_pageio_complete(&pgio);
 	if (err < 0)
@@ -450,7 +451,8 @@ nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg)
 	spin_unlock(&inode->i_lock);
 	pnfs_mark_request_commit(req, lseg);
 	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
+	inc_bdi_stat(page_file_mapping(req->wb_page)->backing_dev_info,
+			BDI_RECLAIMABLE);
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 }
 
@@ -461,7 +463,8 @@ nfs_clear_request_commit(struct nfs_page *req)
 
 	if (test_and_clear_bit(PG_CLEAN, &(req)->wb_flags)) {
 		dec_zone_page_state(page, NR_UNSTABLE_NFS);
-		dec_bdi_stat(page->mapping->backing_dev_info, BDI_RECLAIMABLE);
+		dec_bdi_stat(page_file_mapping(page)->backing_dev_info,
+				BDI_RECLAIMABLE);
 		return 1;
 	}
 	return 0;
@@ -527,7 +530,7 @@ nfs_need_commit(struct nfs_inode *nfsi)
  * nfs_scan_commit - Scan an inode for commit requests
  * @inode: NFS inode to scan
  * @dst: destination list
- * @idx_start: lower bound of page->index to scan.
+ * @idx_start: lower bound of page_file_index(page) to scan.
  * @npages: idx_start + npages sets the upper bound to scan.
  *
  * Moves requests from the inode's 'commit' request list.
@@ -653,7 +656,7 @@ out_err:
 static struct nfs_page * nfs_setup_write_request(struct nfs_open_context* ctx,
 		struct page *page, unsigned int offset, unsigned int bytes)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_page	*req;
 	int error;
 
@@ -711,7 +714,7 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
 		nfs_release_request(req);
 		if (!do_flush)
 			return 0;
-		status = nfs_wb_page(page->mapping->host, page);
+		status = nfs_wb_page(page_file_mapping(page)->host, page);
 	} while (status == 0);
 	return status;
 }
@@ -737,7 +740,7 @@ int nfs_updatepage(struct file *file, struct page *page,
 		unsigned int offset, unsigned int count)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
-	struct inode	*inode = page->mapping->host;
+	struct inode	*inode = page_file_mapping(page)->host;
 	int		status = 0;
 
 	nfs_inc_stats(inode, NFSIOS_VFSUPDATEPAGE);
@@ -745,7 +748,7 @@ int nfs_updatepage(struct file *file, struct page *page,
 	dprintk("NFS:       nfs_updatepage(%s/%s %d@%lld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
 		file->f_path.dentry->d_name.name, count,
-		(long long)(page_offset(page) + offset));
+		(long long)(page_file_offset(page) + offset));
 
 	/* If we're not using byte range locks, and we know the page
 	 * is up to date, it may be more efficient to extend the write
@@ -1105,7 +1108,7 @@ static void nfs_writeback_release_partial(void *calldata)
 	}
 
 	if (nfs_write_need_commit(data)) {
-		struct inode *inode = page->mapping->host;
+		struct inode *inode = page_file_mapping(page)->host;
 
 		spin_lock(&inode->i_lock);
 		if (test_bit(PG_NEED_RESCHED, &req->wb_flags)) {
@@ -1409,7 +1412,7 @@ void nfs_retry_commit(struct list_head *page_list,
 		nfs_list_remove_request(req);
 		nfs_mark_request_commit(req, lseg);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
+		dec_bdi_stat(page_file_mapping(req->wb_page)->backing_dev_info,
 			     BDI_RECLAIMABLE);
 		nfs_clear_page_tag_locked(req);
 	}
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
