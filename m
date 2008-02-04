Message-Id: <20080204170529.622970833@szeredi.hu>
References: <20080204170409.991123259@szeredi.hu>
Date: Mon, 04 Feb 2008 18:04:13 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 3/3] fuse: implement perform_write
Content-Disposition: inline; filename=fuse_perform_write.patch
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Introduce fuse_perform_write. With fusexmp (a passthrough filesystem), large
(1MB) writes into a backing tmpfs filesystem are sped up by almost 4 times
(256MB/s vs 71MB/s).

[mszeredi@suse.cz]:

 - split into smaller functions
 - testing

Signed-off-by: Nick Piggin <npiggin@suse.de>
Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux/fs/fuse/file.c
===================================================================
--- linux.orig/fs/fuse/file.c	2008-02-04 17:11:18.000000000 +0100
+++ linux/fs/fuse/file.c	2008-02-04 17:11:59.000000000 +0100
@@ -677,6 +677,148 @@ static int fuse_write_end(struct file *f
 	return res;
 }
 
+static size_t fuse_send_write_pages(struct fuse_req *req, struct file *file,
+				    struct inode *inode, loff_t pos,
+				    size_t count)
+{
+	size_t res;
+	unsigned offset;
+	unsigned i;
+
+	for (i = 0; i < req->num_pages; i++)
+		fuse_wait_on_page_writeback(inode, req->pages[i]->index);
+
+	res = fuse_send_write(req, file, inode, pos, count, NULL);
+
+	offset = req->page_offset;
+	count = res;
+	for (i = 0; i < req->num_pages; i++) {
+		struct page *page = req->pages[i];
+
+		if (!req->out.h.error && !offset && count >= PAGE_CACHE_SIZE)
+			SetPageUptodate(page);
+
+		/* Just ignore count underflow on last page */
+		count -= PAGE_CACHE_SIZE - offset;
+		offset = 0;
+
+		unlock_page(page);
+		page_cache_release(page);
+	}
+
+	return res;
+}
+
+static ssize_t fuse_fill_write_pages(struct fuse_req *req,
+			       struct address_space *mapping,
+			       struct iov_iter *ii, loff_t pos)
+{
+	struct fuse_conn *fc = get_fuse_conn(mapping->host);
+	unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
+	size_t count = 0;
+	int err;
+
+	req->page_offset = offset;
+
+	do {
+		size_t tmp;
+		struct page *page;
+		pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+		size_t bytes = min_t(size_t, PAGE_CACHE_SIZE - offset,
+				     iov_iter_count(ii));
+
+		bytes = min_t(size_t, bytes, fc->max_write - count);
+
+ again:
+		err = -EFAULT;
+		if (iov_iter_fault_in_readable(ii, bytes))
+			break;
+
+		err = -ENOMEM;
+		page = __grab_cache_page(mapping, index);
+		if (!page)
+			break;
+
+		pagefault_disable();
+		tmp = iov_iter_copy_from_user_atomic(page, ii, offset, bytes);
+		pagefault_enable();
+		flush_dcache_page(page);
+
+		if (!tmp) {
+			unlock_page(page);
+			page_cache_release(page);
+			bytes = min(bytes, iov_iter_single_seg_count(ii));
+			goto again;
+		}
+
+		err = 0;
+		req->pages[req->num_pages] = page;
+		req->num_pages++;
+
+		iov_iter_advance(ii, tmp);
+		count += tmp;
+		pos += tmp;
+		offset += tmp;
+		if (offset == PAGE_CACHE_SIZE)
+			offset = 0;
+
+	} while (iov_iter_count(ii) && count < fc->max_write &&
+		 req->num_pages < FUSE_MAX_PAGES_PER_REQ && offset == 0);
+
+	return count > 0 ? count : err;
+}
+
+static ssize_t fuse_perform_write(struct file *file,
+				  struct address_space *mapping,
+				  struct iov_iter *ii, loff_t pos)
+{
+	struct inode *inode = mapping->host;
+	struct fuse_conn *fc = get_fuse_conn(inode);
+	int err = 0;
+	ssize_t res = 0;
+
+	if (is_bad_inode(inode))
+		return -EIO;
+
+	do {
+		struct fuse_req *req;
+		ssize_t count;
+
+		req = fuse_get_req(fc);
+		if (IS_ERR(req)) {
+			err = PTR_ERR(req);
+			break;
+		}
+
+		count = fuse_fill_write_pages(req, mapping, ii, pos);
+		if (count <= 0) {
+			err = count;
+		} else {
+			size_t num_written;
+
+			num_written = fuse_send_write_pages(req, file, inode,
+							    pos, count);
+			err = req->out.h.error;
+			if (!err) {
+				res += num_written;
+				pos += num_written;
+
+				/* break out of the loop on short write */
+				if (num_written != count)
+					err = -EIO;
+			}
+		}
+		fuse_put_request(fc, req);
+	} while (!err && iov_iter_count(ii));
+
+	if (res > 0)
+		fuse_write_update_size(inode, pos);
+
+	fuse_invalidate_attr(inode);
+
+	return res > 0 ? res : err;
+}
+
 static void fuse_release_user_pages(struct fuse_req *req, int write)
 {
 	unsigned i;
@@ -1247,6 +1389,7 @@ static const struct address_space_operat
 	.launder_page	= fuse_launder_page,
 	.write_begin	= fuse_write_begin,
 	.write_end	= fuse_write_end,
+	.perform_write	= fuse_perform_write,
 	.readpages	= fuse_readpages,
 	.set_page_dirty	= __set_page_dirty_nobuffers,
 	.bmap		= fuse_bmap,

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
