Message-Id: <20080320202125.333112000@chello.nl>
References: <20080320201042.675090000@chello.nl>
Date: Thu, 20 Mar 2008 21:11:09 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 27/30] nfs: teach the NFS client how to treat PG_swapcache pages
Content-Disposition: inline; filename=nfs-swapcache.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, neilb@suse.de, miklos@szeredi.hu, penberg@cs.helsinki.fi, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Replace all relevant occurences of page->index and page->mapping in the NFS
client with the new page_file_index() and page_file_mapping() functions.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/nfs/file.c     |    6 ++---
 fs/nfs/internal.h |    7 +++---
 fs/nfs/pagelist.c |    6 ++---
 fs/nfs/read.c     |    6 ++---
 fs/nfs/write.c    |   57 +++++++++++++++++++++++++++---------------------------
 5 files changed, 42 insertions(+), 40 deletions(-)

Index: linux-2.6/fs/nfs/file.c
===================================================================
--- linux-2.6.orig/fs/nfs/file.c
+++ linux-2.6/fs/nfs/file.c
@@ -359,7 +359,7 @@ static void nfs_invalidate_page(struct p
 	if (offset != 0)
 		return;
 	/* Cancel any unstarted writes on this page */
-	nfs_wb_page_cancel(page->mapping->host, page);
+	nfs_wb_page_cancel(page_file_mapping(page)->host, page);
 }
 
 static int nfs_release_page(struct page *page, gfp_t gfp)
@@ -370,7 +370,7 @@ static int nfs_release_page(struct page 
 
 static int nfs_launder_page(struct page *page)
 {
-	return nfs_wb_page(page->mapping->host, page);
+	return nfs_wb_page(page_file_mapping(page)->host, page);
 }
 
 const struct address_space_operations nfs_file_aops = {
@@ -397,7 +397,7 @@ static int nfs_vm_page_mkwrite(struct vm
 	struct address_space *mapping;
 
 	lock_page(page);
-	mapping = page->mapping;
+	mapping = page_file_mapping(page);
 	if (mapping != vma->vm_file->f_path.dentry->d_inode->i_mapping)
 		goto out_unlock;
 
Index: linux-2.6/fs/nfs/pagelist.c
===================================================================
--- linux-2.6.orig/fs/nfs/pagelist.c
+++ linux-2.6/fs/nfs/pagelist.c
@@ -76,11 +76,11 @@ nfs_create_request(struct nfs_open_conte
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
@@ -376,7 +376,7 @@ void nfs_pageio_cond_complete(struct nfs
  * nfs_scan_list - Scan a list for matching requests
  * @nfsi: NFS inode
  * @dst: Destination list
- * @idx_start: lower bound of page->index to scan
+ * @idx_start: lower bound of page_file_index(page) to scan
  * @npages: idx_start + npages sets the upper bound to scan.
  * @tag: tag to scan for
  *
Index: linux-2.6/fs/nfs/read.c
===================================================================
--- linux-2.6.orig/fs/nfs/read.c
+++ linux-2.6/fs/nfs/read.c
@@ -458,11 +458,11 @@ static const struct rpc_call_ops nfs_rea
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
 
@@ -509,7 +509,7 @@ static int
 readpage_async_filler(void *data, struct page *page)
 {
 	struct nfs_readdesc *desc = (struct nfs_readdesc *)data;
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_page *new;
 	unsigned int len;
 	int error;
Index: linux-2.6/fs/nfs/write.c
===================================================================
--- linux-2.6.orig/fs/nfs/write.c
+++ linux-2.6/fs/nfs/write.c
@@ -126,7 +126,7 @@ static struct nfs_page *nfs_page_find_re
 
 static struct nfs_page *nfs_page_find_request(struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_page *req = NULL;
 
 	spin_lock(&inode->i_lock);
@@ -138,13 +138,13 @@ static struct nfs_page *nfs_page_find_re
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
+	end = page_file_offset(page) + ((loff_t)offset+count);
 	if (i_size >= end)
 		return;
 	nfs_inc_stats(inode, NFSIOS_EXTENDWRITE);
@@ -155,7 +155,7 @@ static void nfs_grow_file(struct page *p
 static void nfs_set_pageerror(struct page *page)
 {
 	SetPageError(page);
-	nfs_zap_mapping(page->mapping->host, page->mapping);
+	nfs_zap_mapping(page_file_mapping(page)->host, page_file_mapping(page));
 }
 
 /* We can set the PG_uptodate flag if we see that a write request
@@ -185,7 +185,7 @@ static int nfs_writepage_setup(struct nf
 		ret = PTR_ERR(req);
 		if (ret != -EBUSY)
 			return ret;
-		ret = nfs_wb_page(page->mapping->host, page);
+		ret = nfs_wb_page(page_file_mapping(page)->host, page);
 		if (ret != 0)
 			return ret;
 	}
@@ -219,7 +219,7 @@ static int nfs_set_page_writeback(struct
 	int ret = test_set_page_writeback(page);
 
 	if (!ret) {
-		struct inode *inode = page->mapping->host;
+		struct inode *inode = page_file_mapping(page)->host;
 		struct nfs_server *nfss = NFS_SERVER(inode);
 
 		if (atomic_long_inc_return(&nfss->writeback) >
@@ -231,7 +231,7 @@ static int nfs_set_page_writeback(struct
 
 static void nfs_end_page_writeback(struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_server *nfss = NFS_SERVER(inode);
 
 	end_page_writeback(page);
@@ -246,7 +246,7 @@ static void nfs_end_page_writeback(struc
 static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 				struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_page *req;
 	int ret;
 
@@ -289,12 +289,12 @@ static int nfs_page_async_flush(struct n
 
 static int nfs_do_writepage(struct page *page, struct writeback_control *wbc, struct nfs_pageio_descriptor *pgio)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGE);
 	nfs_add_stats(inode, NFSIOS_WRITEPAGES, 1);
 
-	nfs_pageio_cond_complete(pgio, page->index);
+	nfs_pageio_cond_complete(pgio, page_file_index(page));
 	return nfs_page_async_flush(pgio, page);
 }
 
@@ -306,7 +306,7 @@ static int nfs_writepage_locked(struct p
 	struct nfs_pageio_descriptor pgio;
 	int err;
 
-	nfs_pageio_init_write(&pgio, page->mapping->host, wb_priority(wbc));
+	nfs_pageio_init_write(&pgio, page_file_mapping(page)->host, wb_priority(wbc));
 	err = nfs_do_writepage(page, wbc, &pgio);
 	nfs_pageio_complete(&pgio);
 	if (err < 0)
@@ -436,7 +436,8 @@ nfs_mark_request_commit(struct nfs_page 
 			NFS_PAGE_TAG_COMMIT);
 	spin_unlock(&inode->i_lock);
 	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
+	inc_bdi_stat(page_file_mapping(req->wb_page)->backing_dev_info,
+			BDI_RECLAIMABLE);
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 }
 
@@ -523,7 +524,7 @@ static void nfs_cancel_commit_list(struc
 	while(!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
+		dec_bdi_stat(page_file_mapping(req->wb_page)->backing_dev_info,
 				BDI_RECLAIMABLE);
 		nfs_list_remove_request(req);
 		clear_bit(PG_NEED_COMMIT, &(req)->wb_flags);
@@ -537,7 +538,7 @@ static void nfs_cancel_commit_list(struc
  * nfs_scan_commit - Scan an inode for commit requests
  * @inode: NFS inode to scan
  * @dst: destination list
- * @idx_start: lower bound of page->index to scan.
+ * @idx_start: lower bound of page_file_index(page) to scan.
  * @npages: idx_start + npages sets the upper bound to scan.
  *
  * Moves requests from the inode's 'commit' request list.
@@ -573,7 +574,7 @@ static inline int nfs_scan_commit(struct
 static struct nfs_page * nfs_update_request(struct nfs_open_context* ctx,
 		struct page *page, unsigned int offset, unsigned int bytes)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_file_mapping(page);
 	struct inode *inode = mapping->host;
 	struct nfs_page		*req, *new = NULL;
 	pgoff_t		rqend, end;
@@ -690,7 +691,7 @@ int nfs_flush_incompatible(struct file *
 		nfs_release_request(req);
 		if (!do_flush)
 			return 0;
-		status = nfs_wb_page(page->mapping->host, page);
+		status = nfs_wb_page(page_file_mapping(page)->host, page);
 	} while (status == 0);
 	return status;
 }
@@ -716,7 +717,7 @@ int nfs_updatepage(struct file *file, st
 		unsigned int offset, unsigned int count)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
-	struct inode	*inode = page->mapping->host;
+	struct inode	*inode = page_file_mapping(page)->host;
 	int		status = 0;
 
 	nfs_inc_stats(inode, NFSIOS_VFSUPDATEPAGE);
@@ -724,7 +725,7 @@ int nfs_updatepage(struct file *file, st
 	dprintk("NFS:      nfs_updatepage(%s/%s %d@%Ld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
 		file->f_path.dentry->d_name.name, count,
-		(long long)(page_offset(page) +offset));
+		(long long)(page_file_offset(page) + offset));
 
 	/* If we're not using byte range locks, and we know the page
 	 * is up to date, it may be more efficient to extend the write
@@ -984,7 +985,7 @@ static void nfs_writeback_done_partial(s
 	}
 
 	if (nfs_write_need_commit(data)) {
-		struct inode *inode = page->mapping->host;
+		struct inode *inode = page_file_mapping(page)->host;
 
 		spin_lock(&inode->i_lock);
 		if (test_bit(PG_NEED_RESCHED, &req->wb_flags)) {
@@ -1235,7 +1236,7 @@ nfs_commit_list(struct inode *inode, str
 		nfs_list_remove_request(req);
 		nfs_mark_request_commit(req);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
+		dec_bdi_stat(page_file_mapping(req->wb_page)->backing_dev_info,
 				BDI_RECLAIMABLE);
 		nfs_clear_page_tag_locked(req);
 	}
@@ -1262,7 +1263,7 @@ static void nfs_commit_done(struct rpc_t
 		nfs_list_remove_request(req);
 		clear_bit(PG_NEED_COMMIT, &(req)->wb_flags);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
+		dec_bdi_stat(page_file_mapping(req->wb_page)->backing_dev_info,
 				BDI_RECLAIMABLE);
 
 		dprintk("NFS: commit (%s/%Ld %d@%Ld)",
@@ -1425,10 +1426,10 @@ int nfs_wb_nocommit(struct inode *inode)
 int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 {
 	struct nfs_page *req;
-	loff_t range_start = page_offset(page);
+	loff_t range_start = page_file_offset(page);
 	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
 	struct writeback_control wbc = {
-		.bdi = page->mapping->backing_dev_info,
+		.bdi = page_file_mapping(page)->backing_dev_info,
 		.sync_mode = WB_SYNC_ALL,
 		.nr_to_write = LONG_MAX,
 		.range_start = range_start,
@@ -1461,7 +1462,7 @@ int nfs_wb_page_cancel(struct inode *ino
 	}
 	if (!PagePrivate(page))
 		return 0;
-	ret = nfs_sync_mapping_wait(page->mapping, &wbc, FLUSH_INVALIDATE);
+	ret = nfs_sync_mapping_wait(page_file_mapping(page), &wbc, FLUSH_INVALIDATE);
 out:
 	return ret;
 }
@@ -1469,10 +1470,10 @@ out:
 static int nfs_wb_page_priority(struct inode *inode, struct page *page,
 				int how)
 {
-	loff_t range_start = page_offset(page);
+	loff_t range_start = page_file_offset(page);
 	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
 	struct writeback_control wbc = {
-		.bdi = page->mapping->backing_dev_info,
+		.bdi = page_file_mapping(page)->backing_dev_info,
 		.sync_mode = WB_SYNC_ALL,
 		.nr_to_write = LONG_MAX,
 		.range_start = range_start,
@@ -1488,7 +1489,7 @@ static int nfs_wb_page_priority(struct i
 	}
 	if (!PagePrivate(page))
 		return 0;
-	ret = nfs_sync_mapping_wait(page->mapping, &wbc, how);
+	ret = nfs_sync_mapping_wait(page_file_mapping(page), &wbc, how);
 	if (ret >= 0)
 		return 0;
 out:
Index: linux-2.6/fs/nfs/internal.h
===================================================================
--- linux-2.6.orig/fs/nfs/internal.h
+++ linux-2.6/fs/nfs/internal.h
@@ -255,13 +255,14 @@ void nfs_super_set_maxbytes(struct super
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
