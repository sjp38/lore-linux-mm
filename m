Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id F2ADE6B0044
	for <linux-mm@kvack.org>; Sat, 29 Jun 2013 13:46:00 -0400 (EDT)
Subject: [PATCH 11/16] fuse: Implement write_begin/write_end callbacks
From: Maxim Patlasov <MPatlasov@parallels.com>
Date: Sat, 29 Jun 2013 21:45:46 +0400
Message-ID: <20130629174535.20175.89175.stgit@maximpc.sw.ru>
In-Reply-To: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
References: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: miklos@szeredi.hu
Cc: riel@redhat.com, dev@parallels.com, xemul@parallels.com, fuse-devel@lists.sourceforge.net, bfoster@redhat.com, linux-kernel@vger.kernel.org, jbottomley@parallels.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, fengguang.wu@intel.com, devel@openvz.org, mgorman@suse.de

From: Pavel Emelyanov <xemul@openvz.org>

The .write_begin and .write_end are requiered to use generic routines
(generic_file_aio_write --> ... --> generic_perform_write) for buffered
writes.

Signed-off-by: Maxim Patlasov <MPatlasov@parallels.com>
---
 fs/fuse/file.c |   97 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 97 insertions(+), 0 deletions(-)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index ad3bb8a..89b08d6 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1826,6 +1826,101 @@ out:
 	return err;
 }
 
+/*
+ * Determine the number of bytes of data the page contains
+ */
+static inline unsigned fuse_page_length(struct page *page)
+{
+	loff_t i_size = i_size_read(page_file_mapping(page)->host);
+
+	if (i_size > 0) {
+		pgoff_t page_index = page_file_index(page);
+		pgoff_t end_index = (i_size - 1) >> PAGE_CACHE_SHIFT;
+		if (page_index < end_index)
+			return PAGE_CACHE_SIZE;
+		if (page_index == end_index)
+			return ((i_size - 1) & ~PAGE_CACHE_MASK) + 1;
+	}
+	return 0;
+}
+
+static int fuse_prepare_write(struct fuse_conn *fc, struct file *file,
+		struct page *page, loff_t pos, unsigned len)
+{
+	struct fuse_req *req = NULL;
+	unsigned num_read;
+	unsigned page_len;
+	int err;
+
+	if (PageUptodate(page) || (len == PAGE_CACHE_SIZE))
+		return 0;
+
+	page_len = fuse_page_length(page);
+	if (!page_len) {
+		zero_user(page, 0, PAGE_CACHE_SIZE);
+		return 0;
+	}
+
+	num_read = __fuse_readpage(file, page, page_len, &err, &req, NULL);
+	if (req)
+		fuse_put_request(fc, req);
+	if (err) {
+		unlock_page(page);
+		page_cache_release(page);
+	} else if (num_read != PAGE_CACHE_SIZE) {
+		zero_user_segment(page, num_read, PAGE_CACHE_SIZE);
+	}
+	return err;
+}
+
+/*
+ * It's worthy to make sure that space is reserved on disk for the write,
+ * but how to implement it without killing performance need more thinking.
+ */
+static int fuse_write_begin(struct file *file, struct address_space *mapping,
+		loff_t pos, unsigned len, unsigned flags,
+		struct page **pagep, void **fsdata)
+{
+	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	struct fuse_conn *fc = get_fuse_conn(file->f_dentry->d_inode);
+
+	BUG_ON(!fc->writeback_cache);
+
+	*pagep = grab_cache_page_write_begin(mapping, index, flags);
+	if (!*pagep)
+		return -ENOMEM;
+
+	return fuse_prepare_write(fc, file, *pagep, pos, len);
+}
+
+static int fuse_commit_write(struct file *file, struct page *page,
+		unsigned from, unsigned to)
+{
+	struct inode *inode = page->mapping->host;
+	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
+
+	if (!PageUptodate(page))
+		SetPageUptodate(page);
+
+	fuse_write_update_size(inode, pos);
+	set_page_dirty(page);
+	return 0;
+}
+
+static int fuse_write_end(struct file *file, struct address_space *mapping,
+		loff_t pos, unsigned len, unsigned copied,
+		struct page *page, void *fsdata)
+{
+	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+
+	fuse_commit_write(file, page, from, from+copied);
+
+	unlock_page(page);
+	page_cache_release(page);
+
+	return copied;
+}
+
 static int fuse_launder_page(struct page *page)
 {
 	int err = 0;
@@ -2838,6 +2933,8 @@ static const struct address_space_operations fuse_file_aops  = {
 	.set_page_dirty	= __set_page_dirty_nobuffers,
 	.bmap		= fuse_bmap,
 	.direct_IO	= fuse_direct_IO,
+	.write_begin	= fuse_write_begin,
+	.write_end	= fuse_write_end,
 };
 
 void fuse_init_file_inode(struct inode *inode)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
