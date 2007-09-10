Date: Mon, 10 Sep 2007 19:21:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [26/35] changes in NFS
Message-Id: <20070910192153.4d684408.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: trond.myklebust@fys.uio.no, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Changes page->mapping handling in NFS

Singed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 fs/nfs/file.c     |   11 ++++++-----
 fs/nfs/internal.h |    2 +-
 fs/nfs/pagelist.c |    2 +-
 fs/nfs/read.c     |    4 ++--
 fs/nfs/write.c    |   35 ++++++++++++++++++-----------------
 5 files changed, 28 insertions(+), 26 deletions(-)

Index: test-2.6.23-rc4-mm1/fs/nfs/file.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/nfs/file.c
+++ test-2.6.23-rc4-mm1/fs/nfs/file.c
@@ -357,7 +357,7 @@ static void nfs_invalidate_page(struct p
 	if (offset != 0)
 		return;
 	/* Cancel any unstarted writes on this page */
-	nfs_wb_page_cancel(page->mapping->host, page);
+	nfs_wb_page_cancel(page_inode(page), page);
 }
 
 static int nfs_release_page(struct page *page, gfp_t gfp)
@@ -368,7 +368,7 @@ static int nfs_release_page(struct page 
 
 static int nfs_launder_page(struct page *page)
 {
-	return nfs_wb_page(page->mapping->host, page);
+	return nfs_wb_page(page_inode(page), page);
 }
 
 const struct address_space_operations nfs_file_aops = {
@@ -395,16 +395,17 @@ static int nfs_vm_page_mkwrite(struct vm
 	void *fsdata;
 
 	lock_page(page);
-	if (page->mapping != vma->vm_file->f_path.dentry->d_inode->i_mapping)
+	if (!pagecache_consistent(page,
+			vma->vm_file->f_path.dentry->d_inode->i_mapping))
 		goto out_unlock;
 	pagelen = nfs_page_length(page);
 	if (pagelen == 0)
 		goto out_unlock;
-	ret = nfs_write_begin(filp, page->mapping,
+	ret = nfs_write_begin(filp, page_mapping_cache(page),
 				(loff_t)page->index << PAGE_CACHE_SHIFT,
 				pagelen, 0, &page, &fsdata);
 	if (!ret)
-		ret = nfs_write_end(filp, page->mapping,
+		ret = nfs_write_end(filp, page_mapping_cache(page),
 				(loff_t)page->index << PAGE_CACHE_SHIFT,
 				pagelen, pagelen, page, fsdata);
 out_unlock:
Index: test-2.6.23-rc4-mm1/fs/nfs/internal.h
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/nfs/internal.h
+++ test-2.6.23-rc4-mm1/fs/nfs/internal.h
@@ -220,7 +220,7 @@ void nfs_super_set_maxbytes(struct super
 static inline
 unsigned int nfs_page_length(struct page *page)
 {
-	loff_t i_size = i_size_read(page->mapping->host);
+	loff_t i_size = i_size_read(page_inode(page));
 
 	if (i_size > 0) {
 		pgoff_t end_index = (i_size - 1) >> PAGE_CACHE_SHIFT;
Index: test-2.6.23-rc4-mm1/fs/nfs/read.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/nfs/read.c
+++ test-2.6.23-rc4-mm1/fs/nfs/read.c
@@ -466,7 +466,7 @@ static const struct rpc_call_ops nfs_rea
 int nfs_readpage(struct file *file, struct page *page)
 {
 	struct nfs_open_context *ctx;
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	int		error;
 
 	dprintk("NFS: nfs_readpage (%p %ld@%lu)\n",
@@ -517,7 +517,7 @@ static int
 readpage_async_filler(void *data, struct page *page)
 {
 	struct nfs_readdesc *desc = (struct nfs_readdesc *)data;
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct nfs_page *new;
 	unsigned int len;
 	int error;
Index: test-2.6.23-rc4-mm1/fs/nfs/write.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/nfs/write.c
+++ test-2.6.23-rc4-mm1/fs/nfs/write.c
@@ -131,7 +131,7 @@ static struct nfs_page *nfs_page_find_re
 
 static struct nfs_page *nfs_page_find_request(struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct nfs_page *req = NULL;
 
 	spin_lock(&inode->i_lock);
@@ -143,7 +143,7 @@ static struct nfs_page *nfs_page_find_re
 /* Adjust the file length if we're writing beyond the end */
 static void nfs_grow_file(struct page *page, unsigned int offset, unsigned int count)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	loff_t end, i_size = i_size_read(inode);
 	pgoff_t end_index = (i_size - 1) >> PAGE_CACHE_SHIFT;
 
@@ -160,7 +160,7 @@ static void nfs_grow_file(struct page *p
 static void nfs_set_pageerror(struct page *page)
 {
 	SetPageError(page);
-	nfs_zap_mapping(page->mapping->host, page->mapping);
+	nfs_zap_mapping(page_inode(page), page_mapping_cache(page));
 }
 
 /* We can set the PG_uptodate flag if we see that a write request
@@ -192,7 +192,7 @@ static int nfs_writepage_setup(struct nf
 		ret = PTR_ERR(req);
 		if (ret != -EBUSY)
 			return ret;
-		ret = nfs_wb_page(page->mapping->host, page);
+		ret = nfs_wb_page(page_inode(page), page);
 		if (ret != 0)
 			return ret;
 	}
@@ -226,7 +226,7 @@ static int nfs_set_page_writeback(struct
 	int ret = test_set_page_writeback(page);
 
 	if (!ret) {
-		struct inode *inode = page->mapping->host;
+		struct inode *inode = page_inode(page);
 		struct nfs_server *nfss = NFS_SERVER(inode);
 
 		if (atomic_long_inc_return(&nfss->writeback) >
@@ -238,7 +238,7 @@ static int nfs_set_page_writeback(struct
 
 static void nfs_end_page_writeback(struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct nfs_server *nfss = NFS_SERVER(inode);
 
 	end_page_writeback(page);
@@ -255,7 +255,7 @@ static void nfs_end_page_writeback(struc
 static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 				struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_page *req;
 	int ret;
@@ -301,7 +301,7 @@ static int nfs_page_async_flush(struct n
 
 static int nfs_do_writepage(struct page *page, struct writeback_control *wbc, struct nfs_pageio_descriptor *pgio)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGE);
 	nfs_add_stats(inode, NFSIOS_WRITEPAGES, 1);
@@ -318,7 +318,7 @@ static int nfs_writepage_locked(struct p
 	struct nfs_pageio_descriptor pgio;
 	int err;
 
-	nfs_pageio_init_write(&pgio, page->mapping->host, wb_priority(wbc));
+	nfs_pageio_init_write(&pgio, page_inode(page), wb_priority(wbc));
 	err = nfs_do_writepage(page, wbc, &pgio);
 	nfs_pageio_complete(&pgio);
 	if (err < 0)
@@ -585,7 +585,7 @@ static inline int nfs_scan_commit(struct
 static struct nfs_page * nfs_update_request(struct nfs_open_context* ctx,
 		struct page *page, unsigned int offset, unsigned int bytes)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping_cache(page);
 	struct inode *inode = mapping->host;
 	struct nfs_page		*req, *new = NULL;
 	pgoff_t		rqend, end;
@@ -687,7 +687,7 @@ int nfs_flush_incompatible(struct file *
 		nfs_release_request(req);
 		if (!do_flush)
 			return 0;
-		status = nfs_wb_page(page->mapping->host, page);
+		status = nfs_wb_page(page_inode(page), page);
 	} while (status == 0);
 	return status;
 }
@@ -702,7 +702,7 @@ int nfs_updatepage(struct file *file, st
 		unsigned int offset, unsigned int count)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
-	struct inode	*inode = page->mapping->host;
+	struct inode	*inode = page_inode(page);
 	int		status = 0;
 
 	nfs_inc_stats(inode, NFSIOS_VFSUPDATEPAGE);
@@ -958,7 +958,7 @@ static void nfs_writeback_done_partial(s
 	}
 
 	if (nfs_write_need_commit(data)) {
-		struct inode *inode = page->mapping->host;
+		struct inode *inode = page_inode(page);
 
 		spin_lock(&inode->i_lock);
 		if (test_bit(PG_NEED_RESCHED, &req->wb_flags)) {
@@ -1386,7 +1386,7 @@ int nfs_wb_page_cancel(struct inode *ino
 	loff_t range_start = page_offset(page);
 	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
 	struct writeback_control wbc = {
-		.bdi = page->mapping->backing_dev_info,
+		.bdi = page_mapping_cache(page)->backing_dev_info,
 		.sync_mode = WB_SYNC_ALL,
 		.nr_to_write = LONG_MAX,
 		.range_start = range_start,
@@ -1419,7 +1419,8 @@ int nfs_wb_page_cancel(struct inode *ino
 	}
 	if (!PagePrivate(page))
 		return 0;
-	ret = nfs_sync_mapping_wait(page->mapping, &wbc, FLUSH_INVALIDATE);
+	ret = nfs_sync_mapping_wait(page_mapping_cache(page),
+					&wbc, FLUSH_INVALIDATE);
 out:
 	return ret;
 }
@@ -1429,7 +1430,7 @@ int nfs_wb_page_priority(struct inode *i
 	loff_t range_start = page_offset(page);
 	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
 	struct writeback_control wbc = {
-		.bdi = page->mapping->backing_dev_info,
+		.bdi = page_mapping_cache(page)->backing_dev_info,
 		.sync_mode = WB_SYNC_ALL,
 		.nr_to_write = LONG_MAX,
 		.range_start = range_start,
@@ -1445,7 +1446,7 @@ int nfs_wb_page_priority(struct inode *i
 	}
 	if (!PagePrivate(page))
 		return 0;
-	ret = nfs_sync_mapping_wait(page->mapping, &wbc, how);
+	ret = nfs_sync_mapping_wait(page_mapping_cache(page), &wbc, how);
 	if (ret >= 0)
 		return 0;
 out:
Index: test-2.6.23-rc4-mm1/fs/nfs/pagelist.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/nfs/pagelist.c
+++ test-2.6.23-rc4-mm1/fs/nfs/pagelist.c
@@ -81,7 +81,7 @@ nfs_create_request(struct nfs_open_conte
 	page_cache_get(page);
 	BUG_ON(PagePrivate(page));
 	BUG_ON(!PageLocked(page));
-	BUG_ON(page->mapping->host != inode);
+	BUG_ON(page_inode(page) != inode);
 	req->wb_offset  = offset;
 	req->wb_pgbase	= offset;
 	req->wb_bytes   = count;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
