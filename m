Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id D4261828F4
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:46:54 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id u190so238302842pfb.3
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:46:54 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id qx12si13425508pab.169.2016.03.20.11.41.49
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:49 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 37/71] fuse: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:44 +0300
Message-Id: <1458499278-1516-38-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Miklos Szeredi <miklos@szeredi.hu>

PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
with promise that one day it will be possible to implement page cache with
bigger chunks than PAGE_SIZE.

This promise never materialized. And unlikely will.

We have many places where PAGE_CACHE_SIZE assumed to be equal to
PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
or PAGE_* constant should be used in a particular case, especially on the
border between fs and mm.

Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
breakage to be doable.

Let's stop pretending that pages in page cache are special. They are not.

The changes are pretty straight-forward:

 - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};

 - page_cache_get() -> get_page();

 - page_cache_release() -> put_page();

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>
---
 fs/fuse/dev.c   | 26 ++++++++++-----------
 fs/fuse/file.c  | 72 ++++++++++++++++++++++++++++-----------------------------
 fs/fuse/inode.c | 16 ++++++-------
 3 files changed, 57 insertions(+), 57 deletions(-)

diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
index ebb5e37455a0..cbece1221417 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -897,7 +897,7 @@ static int fuse_try_move_page(struct fuse_copy_state *cs, struct page **pagep)
 		return err;
 	}
 
-	page_cache_get(newpage);
+	get_page(newpage);
 
 	if (!(buf->flags & PIPE_BUF_FLAG_LRU))
 		lru_cache_add_file(newpage);
@@ -912,12 +912,12 @@ static int fuse_try_move_page(struct fuse_copy_state *cs, struct page **pagep)
 
 	if (err) {
 		unlock_page(newpage);
-		page_cache_release(newpage);
+		put_page(newpage);
 		return err;
 	}
 
 	unlock_page(oldpage);
-	page_cache_release(oldpage);
+	put_page(oldpage);
 	cs->len = 0;
 
 	return 0;
@@ -951,7 +951,7 @@ static int fuse_ref_page(struct fuse_copy_state *cs, struct page *page,
 	fuse_copy_finish(cs);
 
 	buf = cs->pipebufs;
-	page_cache_get(page);
+	get_page(page);
 	buf->page = page;
 	buf->offset = offset;
 	buf->len = count;
@@ -1435,7 +1435,7 @@ out_unlock:
 
 out:
 	for (; page_nr < cs.nr_segs; page_nr++)
-		page_cache_release(bufs[page_nr].page);
+		put_page(bufs[page_nr].page);
 
 	kfree(bufs);
 	return ret;
@@ -1632,8 +1632,8 @@ static int fuse_notify_store(struct fuse_conn *fc, unsigned int size,
 		goto out_up_killsb;
 
 	mapping = inode->i_mapping;
-	index = outarg.offset >> PAGE_CACHE_SHIFT;
-	offset = outarg.offset & ~PAGE_CACHE_MASK;
+	index = outarg.offset >> PAGE_SHIFT;
+	offset = outarg.offset & ~PAGE_MASK;
 	file_size = i_size_read(inode);
 	end = outarg.offset + outarg.size;
 	if (end > file_size) {
@@ -1652,13 +1652,13 @@ static int fuse_notify_store(struct fuse_conn *fc, unsigned int size,
 		if (!page)
 			goto out_iput;
 
-		this_num = min_t(unsigned, num, PAGE_CACHE_SIZE - offset);
+		this_num = min_t(unsigned, num, PAGE_SIZE - offset);
 		err = fuse_copy_page(cs, &page, offset, this_num, 0);
 		if (!err && offset == 0 &&
-		    (this_num == PAGE_CACHE_SIZE || file_size == end))
+		    (this_num == PAGE_SIZE || file_size == end))
 			SetPageUptodate(page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 
 		if (err)
 			goto out_iput;
@@ -1697,7 +1697,7 @@ static int fuse_retrieve(struct fuse_conn *fc, struct inode *inode,
 	size_t total_len = 0;
 	int num_pages;
 
-	offset = outarg->offset & ~PAGE_CACHE_MASK;
+	offset = outarg->offset & ~PAGE_MASK;
 	file_size = i_size_read(inode);
 
 	num = outarg->size;
@@ -1720,7 +1720,7 @@ static int fuse_retrieve(struct fuse_conn *fc, struct inode *inode,
 	req->page_descs[0].offset = offset;
 	req->end = fuse_retrieve_end;
 
-	index = outarg->offset >> PAGE_CACHE_SHIFT;
+	index = outarg->offset >> PAGE_SHIFT;
 
 	while (num && req->num_pages < num_pages) {
 		struct page *page;
@@ -1730,7 +1730,7 @@ static int fuse_retrieve(struct fuse_conn *fc, struct inode *inode,
 		if (!page)
 			break;
 
-		this_num = min_t(unsigned, num, PAGE_CACHE_SIZE - offset);
+		this_num = min_t(unsigned, num, PAGE_SIZE - offset);
 		req->pages[req->num_pages] = page;
 		req->page_descs[req->num_pages].length = this_num;
 		req->num_pages++;
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index b03d253ece15..6fc09c6fc80c 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -348,7 +348,7 @@ static bool fuse_range_is_writeback(struct inode *inode, pgoff_t idx_from,
 		pgoff_t curr_index;
 
 		BUG_ON(req->inode != inode);
-		curr_index = req->misc.write.in.offset >> PAGE_CACHE_SHIFT;
+		curr_index = req->misc.write.in.offset >> PAGE_SHIFT;
 		if (idx_from < curr_index + req->num_pages &&
 		    curr_index <= idx_to) {
 			found = true;
@@ -676,11 +676,11 @@ static void fuse_short_read(struct fuse_req *req, struct inode *inode,
 		 * present there.
 		 */
 		int i;
-		int start_idx = num_read >> PAGE_CACHE_SHIFT;
-		size_t off = num_read & (PAGE_CACHE_SIZE - 1);
+		int start_idx = num_read >> PAGE_SHIFT;
+		size_t off = num_read & (PAGE_SIZE - 1);
 
 		for (i = start_idx; i < req->num_pages; i++) {
-			zero_user_segment(req->pages[i], off, PAGE_CACHE_SIZE);
+			zero_user_segment(req->pages[i], off, PAGE_SIZE);
 			off = 0;
 		}
 	} else {
@@ -697,7 +697,7 @@ static int fuse_do_readpage(struct file *file, struct page *page)
 	struct fuse_req *req;
 	size_t num_read;
 	loff_t pos = page_offset(page);
-	size_t count = PAGE_CACHE_SIZE;
+	size_t count = PAGE_SIZE;
 	u64 attr_ver;
 	int err;
 
@@ -782,7 +782,7 @@ static void fuse_readpages_end(struct fuse_conn *fc, struct fuse_req *req)
 		else
 			SetPageError(page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	if (req->ff)
 		fuse_file_put(req->ff, false);
@@ -793,7 +793,7 @@ static void fuse_send_readpages(struct fuse_req *req, struct file *file)
 	struct fuse_file *ff = file->private_data;
 	struct fuse_conn *fc = ff->fc;
 	loff_t pos = page_offset(req->pages[0]);
-	size_t count = req->num_pages << PAGE_CACHE_SHIFT;
+	size_t count = req->num_pages << PAGE_SHIFT;
 
 	req->out.argpages = 1;
 	req->out.page_zeroing = 1;
@@ -829,7 +829,7 @@ static int fuse_readpages_fill(void *_data, struct page *page)
 
 	if (req->num_pages &&
 	    (req->num_pages == FUSE_MAX_PAGES_PER_REQ ||
-	     (req->num_pages + 1) * PAGE_CACHE_SIZE > fc->max_read ||
+	     (req->num_pages + 1) * PAGE_SIZE > fc->max_read ||
 	     req->pages[req->num_pages - 1]->index + 1 != page->index)) {
 		int nr_alloc = min_t(unsigned, data->nr_pages,
 				     FUSE_MAX_PAGES_PER_REQ);
@@ -851,7 +851,7 @@ static int fuse_readpages_fill(void *_data, struct page *page)
 		return -EIO;
 	}
 
-	page_cache_get(page);
+	get_page(page);
 	req->pages[req->num_pages] = page;
 	req->page_descs[req->num_pages].length = PAGE_SIZE;
 	req->num_pages++;
@@ -996,17 +996,17 @@ static size_t fuse_send_write_pages(struct fuse_req *req, struct file *file,
 	for (i = 0; i < req->num_pages; i++) {
 		struct page *page = req->pages[i];
 
-		if (!req->out.h.error && !offset && count >= PAGE_CACHE_SIZE)
+		if (!req->out.h.error && !offset && count >= PAGE_SIZE)
 			SetPageUptodate(page);
 
-		if (count > PAGE_CACHE_SIZE - offset)
-			count -= PAGE_CACHE_SIZE - offset;
+		if (count > PAGE_SIZE - offset)
+			count -= PAGE_SIZE - offset;
 		else
 			count = 0;
 		offset = 0;
 
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	return res;
@@ -1017,7 +1017,7 @@ static ssize_t fuse_fill_write_pages(struct fuse_req *req,
 			       struct iov_iter *ii, loff_t pos)
 {
 	struct fuse_conn *fc = get_fuse_conn(mapping->host);
-	unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned offset = pos & (PAGE_SIZE - 1);
 	size_t count = 0;
 	int err;
 
@@ -1027,8 +1027,8 @@ static ssize_t fuse_fill_write_pages(struct fuse_req *req,
 	do {
 		size_t tmp;
 		struct page *page;
-		pgoff_t index = pos >> PAGE_CACHE_SHIFT;
-		size_t bytes = min_t(size_t, PAGE_CACHE_SIZE - offset,
+		pgoff_t index = pos >> PAGE_SHIFT;
+		size_t bytes = min_t(size_t, PAGE_SIZE - offset,
 				     iov_iter_count(ii));
 
 		bytes = min_t(size_t, bytes, fc->max_write - count);
@@ -1052,7 +1052,7 @@ static ssize_t fuse_fill_write_pages(struct fuse_req *req,
 		iov_iter_advance(ii, tmp);
 		if (!tmp) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			bytes = min(bytes, iov_iter_single_seg_count(ii));
 			goto again;
 		}
@@ -1065,7 +1065,7 @@ static ssize_t fuse_fill_write_pages(struct fuse_req *req,
 		count += tmp;
 		pos += tmp;
 		offset += tmp;
-		if (offset == PAGE_CACHE_SIZE)
+		if (offset == PAGE_SIZE)
 			offset = 0;
 
 		if (!fc->big_writes)
@@ -1079,8 +1079,8 @@ static ssize_t fuse_fill_write_pages(struct fuse_req *req,
 static inline unsigned fuse_wr_pages(loff_t pos, size_t len)
 {
 	return min_t(unsigned,
-		     ((pos + len - 1) >> PAGE_CACHE_SHIFT) -
-		     (pos >> PAGE_CACHE_SHIFT) + 1,
+		     ((pos + len - 1) >> PAGE_SHIFT) -
+		     (pos >> PAGE_SHIFT) + 1,
 		     FUSE_MAX_PAGES_PER_REQ);
 }
 
@@ -1198,8 +1198,8 @@ static ssize_t fuse_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 			goto out;
 
 		invalidate_mapping_pages(file->f_mapping,
-					 pos >> PAGE_CACHE_SHIFT,
-					 endbyte >> PAGE_CACHE_SHIFT);
+					 pos >> PAGE_SHIFT,
+					 endbyte >> PAGE_SHIFT);
 
 		written += written_buffered;
 		iocb->ki_pos = pos + written_buffered;
@@ -1308,8 +1308,8 @@ ssize_t fuse_direct_io(struct fuse_io_priv *io, struct iov_iter *iter,
 	size_t nmax = write ? fc->max_write : fc->max_read;
 	loff_t pos = *ppos;
 	size_t count = iov_iter_count(iter);
-	pgoff_t idx_from = pos >> PAGE_CACHE_SHIFT;
-	pgoff_t idx_to = (pos + count - 1) >> PAGE_CACHE_SHIFT;
+	pgoff_t idx_from = pos >> PAGE_SHIFT;
+	pgoff_t idx_to = (pos + count - 1) >> PAGE_SHIFT;
 	ssize_t res = 0;
 	struct fuse_req *req;
 
@@ -1460,7 +1460,7 @@ __acquires(fc->lock)
 {
 	struct fuse_inode *fi = get_fuse_inode(req->inode);
 	struct fuse_write_in *inarg = &req->misc.write.in;
-	__u64 data_size = req->num_pages * PAGE_CACHE_SIZE;
+	__u64 data_size = req->num_pages * PAGE_SIZE;
 
 	if (!fc->connected)
 		goto out_free;
@@ -1721,7 +1721,7 @@ static bool fuse_writepage_in_flight(struct fuse_req *new_req,
 	list_del(&new_req->writepages_entry);
 	list_for_each_entry(old_req, &fi->writepages, writepages_entry) {
 		BUG_ON(old_req->inode != new_req->inode);
-		curr_index = old_req->misc.write.in.offset >> PAGE_CACHE_SHIFT;
+		curr_index = old_req->misc.write.in.offset >> PAGE_SHIFT;
 		if (curr_index <= page->index &&
 		    page->index < curr_index + old_req->num_pages) {
 			found = true;
@@ -1736,7 +1736,7 @@ static bool fuse_writepage_in_flight(struct fuse_req *new_req,
 	new_req->num_pages = 1;
 	for (tmp = old_req; tmp != NULL; tmp = tmp->misc.write.next) {
 		BUG_ON(tmp->inode != new_req->inode);
-		curr_index = tmp->misc.write.in.offset >> PAGE_CACHE_SHIFT;
+		curr_index = tmp->misc.write.in.offset >> PAGE_SHIFT;
 		if (tmp->num_pages == 1 &&
 		    curr_index == page->index) {
 			old_req = tmp;
@@ -1793,7 +1793,7 @@ static int fuse_writepages_fill(struct page *page,
 
 	if (req && req->num_pages &&
 	    (is_writeback || req->num_pages == FUSE_MAX_PAGES_PER_REQ ||
-	     (req->num_pages + 1) * PAGE_CACHE_SIZE > fc->max_write ||
+	     (req->num_pages + 1) * PAGE_SIZE > fc->max_write ||
 	     data->orig_pages[req->num_pages - 1]->index + 1 != page->index)) {
 		fuse_writepages_send(data);
 		data->req = NULL;
@@ -1918,7 +1918,7 @@ static int fuse_write_begin(struct file *file, struct address_space *mapping,
 		loff_t pos, unsigned len, unsigned flags,
 		struct page **pagep, void **fsdata)
 {
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 	struct fuse_conn *fc = get_fuse_conn(file_inode(file));
 	struct page *page;
 	loff_t fsize;
@@ -1932,15 +1932,15 @@ static int fuse_write_begin(struct file *file, struct address_space *mapping,
 
 	fuse_wait_on_page_writeback(mapping->host, page->index);
 
-	if (PageUptodate(page) || len == PAGE_CACHE_SIZE)
+	if (PageUptodate(page) || len == PAGE_SIZE)
 		goto success;
 	/*
 	 * Check if the start this page comes after the end of file, in which
 	 * case the readpage can be optimized away.
 	 */
 	fsize = i_size_read(mapping->host);
-	if (fsize <= (pos & PAGE_CACHE_MASK)) {
-		size_t off = pos & ~PAGE_CACHE_MASK;
+	if (fsize <= (pos & PAGE_MASK)) {
+		size_t off = pos & ~PAGE_MASK;
 		if (off)
 			zero_user_segment(page, 0, off);
 		goto success;
@@ -1954,7 +1954,7 @@ success:
 
 cleanup:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 error:
 	return err;
 }
@@ -1967,16 +1967,16 @@ static int fuse_write_end(struct file *file, struct address_space *mapping,
 
 	if (!PageUptodate(page)) {
 		/* Zero any unwritten bytes at the end of the page */
-		size_t endoff = (pos + copied) & ~PAGE_CACHE_MASK;
+		size_t endoff = (pos + copied) & ~PAGE_MASK;
 		if (endoff)
-			zero_user_segment(page, endoff, PAGE_CACHE_SIZE);
+			zero_user_segment(page, endoff, PAGE_SIZE);
 		SetPageUptodate(page);
 	}
 
 	fuse_write_update_size(inode, pos + copied);
 	set_page_dirty(page);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return copied;
 }
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index 4d69d5c0bedc..1ce67668a8e1 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -339,11 +339,11 @@ int fuse_reverse_inval_inode(struct super_block *sb, u64 nodeid,
 
 	fuse_invalidate_attr(inode);
 	if (offset >= 0) {
-		pg_start = offset >> PAGE_CACHE_SHIFT;
+		pg_start = offset >> PAGE_SHIFT;
 		if (len <= 0)
 			pg_end = -1;
 		else
-			pg_end = (offset + len - 1) >> PAGE_CACHE_SHIFT;
+			pg_end = (offset + len - 1) >> PAGE_SHIFT;
 		invalidate_inode_pages2_range(inode->i_mapping,
 					      pg_start, pg_end);
 	}
@@ -864,7 +864,7 @@ static void process_init_reply(struct fuse_conn *fc, struct fuse_req *req)
 		process_init_limits(fc, arg);
 
 		if (arg->minor >= 6) {
-			ra_pages = arg->max_readahead / PAGE_CACHE_SIZE;
+			ra_pages = arg->max_readahead / PAGE_SIZE;
 			if (arg->flags & FUSE_ASYNC_READ)
 				fc->async_read = 1;
 			if (!(arg->flags & FUSE_POSIX_LOCKS))
@@ -901,7 +901,7 @@ static void process_init_reply(struct fuse_conn *fc, struct fuse_req *req)
 			if (arg->time_gran && arg->time_gran <= 1000000000)
 				fc->sb->s_time_gran = arg->time_gran;
 		} else {
-			ra_pages = fc->max_read / PAGE_CACHE_SIZE;
+			ra_pages = fc->max_read / PAGE_SIZE;
 			fc->no_lock = 1;
 			fc->no_flock = 1;
 		}
@@ -922,7 +922,7 @@ static void fuse_send_init(struct fuse_conn *fc, struct fuse_req *req)
 
 	arg->major = FUSE_KERNEL_VERSION;
 	arg->minor = FUSE_KERNEL_MINOR_VERSION;
-	arg->max_readahead = fc->bdi.ra_pages * PAGE_CACHE_SIZE;
+	arg->max_readahead = fc->bdi.ra_pages * PAGE_SIZE;
 	arg->flags |= FUSE_ASYNC_READ | FUSE_POSIX_LOCKS | FUSE_ATOMIC_O_TRUNC |
 		FUSE_EXPORT_SUPPORT | FUSE_BIG_WRITES | FUSE_DONT_MASK |
 		FUSE_SPLICE_WRITE | FUSE_SPLICE_MOVE | FUSE_SPLICE_READ |
@@ -955,7 +955,7 @@ static int fuse_bdi_init(struct fuse_conn *fc, struct super_block *sb)
 	int err;
 
 	fc->bdi.name = "fuse";
-	fc->bdi.ra_pages = (VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
+	fc->bdi.ra_pages = (VM_MAX_READAHEAD * 1024) / PAGE_SIZE;
 	/* fuse does it's own writeback accounting */
 	fc->bdi.capabilities = BDI_CAP_NO_ACCT_WB | BDI_CAP_STRICTLIMIT;
 
@@ -1053,8 +1053,8 @@ static int fuse_fill_super(struct super_block *sb, void *data, int silent)
 			goto err;
 #endif
 	} else {
-		sb->s_blocksize = PAGE_CACHE_SIZE;
-		sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+		sb->s_blocksize = PAGE_SIZE;
+		sb->s_blocksize_bits = PAGE_SHIFT;
 	}
 	sb->s_magic = FUSE_SUPER_MAGIC;
 	sb->s_op = &fuse_super_operations;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
