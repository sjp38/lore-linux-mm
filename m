Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 94BDA6B003D
	for <linux-mm@kvack.org>; Sat, 29 Jun 2013 13:45:43 -0400 (EDT)
Subject: [PATCH 10/16] fuse: Implement writepages callback
From: Maxim Patlasov <MPatlasov@parallels.com>
Date: Sat, 29 Jun 2013 21:45:29 +0400
Message-ID: <20130629174525.20175.18987.stgit@maximpc.sw.ru>
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

The .writepages one is required to make each writeback request carry more than
one page on it. The patch enables optimized behaviour unconditionally,
i.e. mmap-ed writes will benefit from the patch even if fc->writeback_cache=0.

Signed-off-by: Maxim Patlasov <MPatlasov@parallels.com>
---
 fs/fuse/file.c |  170 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 170 insertions(+), 0 deletions(-)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index e693e35..ad3bb8a 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1657,6 +1657,175 @@ static int fuse_writepage(struct page *page, struct writeback_control *wbc)
 	return err;
 }
 
+struct fuse_fill_wb_data {
+	struct fuse_req *req;
+	struct fuse_file *ff;
+	struct inode *inode;
+	unsigned nr_pages;
+};
+
+static int fuse_send_writepages(struct fuse_fill_wb_data *data)
+{
+	int i, all_ok = 1;
+	struct fuse_req *req = data->req;
+	struct inode *inode = data->inode;
+	struct backing_dev_info *bdi = inode->i_mapping->backing_dev_info;
+	struct fuse_conn *fc = get_fuse_conn(inode);
+	struct fuse_inode *fi = get_fuse_inode(inode);
+	loff_t off = -1;
+
+	if (!data->ff)
+		data->ff = fuse_write_file(fc, fi);
+
+	if (!data->ff) {
+		for (i = 0; i < req->num_pages; i++)
+			end_page_writeback(req->pages[i]);
+		return -EIO;
+	}
+
+	req->inode = inode;
+	req->misc.write.in.offset = page_offset(req->pages[0]);
+
+	spin_lock(&fc->lock);
+	list_add(&req->writepages_entry, &fi->writepages);
+	spin_unlock(&fc->lock);
+
+	for (i = 0; i < req->num_pages; i++) {
+		struct page *page = req->pages[i];
+		struct page *tmp_page;
+
+		tmp_page = alloc_page(GFP_NOFS | __GFP_HIGHMEM);
+		if (tmp_page) {
+			copy_highpage(tmp_page, page);
+			inc_bdi_stat(bdi, BDI_WRITEBACK);
+			inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
+		} else
+			all_ok = 0;
+		req->pages[i] = tmp_page;
+		if (i == 0)
+			off = page_offset(page);
+
+		end_page_writeback(page);
+	}
+
+	if (!all_ok) {
+		for (i = 0; i < req->num_pages; i++) {
+			struct page *page = req->pages[i];
+			if (page) {
+				dec_bdi_stat(bdi, BDI_WRITEBACK);
+				dec_zone_page_state(page, NR_WRITEBACK_TEMP);
+				__free_page(page);
+				req->pages[i] = NULL;
+			}
+		}
+
+		spin_lock(&fc->lock);
+		list_del(&req->writepages_entry);
+		wake_up(&fi->page_waitq);
+		spin_unlock(&fc->lock);
+		return -ENOMEM;
+	}
+
+	__fuse_get_request(req);
+	req->ff = fuse_file_get(data->ff);
+	fuse_write_fill(req, data->ff, off, 0);
+
+	req->misc.write.in.write_flags |= FUSE_WRITE_CACHE;
+	req->in.argpages = 1;
+	fuse_page_descs_length_init(req, 0, req->num_pages);
+	req->end = fuse_writepage_end;
+	req->background = 1;
+
+	spin_lock(&fc->lock);
+	list_add_tail(&req->list, &fi->queued_writes);
+	fuse_flush_writepages(data->inode);
+	spin_unlock(&fc->lock);
+
+	return 0;
+}
+
+static int fuse_writepages_fill(struct page *page,
+		struct writeback_control *wbc, void *_data)
+{
+	struct fuse_fill_wb_data *data = _data;
+	struct fuse_req *req = data->req;
+	struct inode *inode = data->inode;
+	struct fuse_conn *fc = get_fuse_conn(inode);
+
+	if (fuse_page_is_writeback(inode, page->index)) {
+		if (wbc->sync_mode != WB_SYNC_ALL) {
+			redirty_page_for_writepage(wbc, page);
+			unlock_page(page);
+			return 0;
+		}
+		fuse_wait_on_page_writeback(inode, page->index);
+	}
+
+	if (req->num_pages &&
+	    (req->num_pages == FUSE_MAX_PAGES_PER_REQ ||
+	     (req->num_pages + 1) * PAGE_CACHE_SIZE > fc->max_write ||
+	     req->pages[req->num_pages - 1]->index + 1 != page->index)) {
+		int err;
+
+		err = fuse_send_writepages(data);
+		if (err) {
+			unlock_page(page);
+			return err;
+		}
+		fuse_put_request(fc, req);
+
+		data->req = req =
+			fuse_request_alloc_nofs(FUSE_MAX_PAGES_PER_REQ);
+		if (!req) {
+			unlock_page(page);
+			return -ENOMEM;
+		}
+	}
+
+	req->pages[req->num_pages] = page;
+	req->num_pages++;
+
+	if (test_set_page_writeback(page))
+		BUG();
+
+	unlock_page(page);
+
+	return 0;
+}
+
+static int fuse_writepages(struct address_space *mapping,
+			   struct writeback_control *wbc)
+{
+	struct inode *inode = mapping->host;
+	struct fuse_conn *fc = get_fuse_conn(inode);
+	struct fuse_fill_wb_data data;
+	int err;
+
+	err = -EIO;
+	if (is_bad_inode(inode))
+		goto out;
+
+	data.ff = NULL;
+	data.inode = inode;
+	data.req = fuse_request_alloc_nofs(FUSE_MAX_PAGES_PER_REQ);
+	err = -ENOMEM;
+	if (!data.req)
+		goto out_put;
+
+	err = write_cache_pages(mapping, wbc, fuse_writepages_fill, &data);
+	if (data.req) {
+		if (!err && data.req->num_pages)
+			err = fuse_send_writepages(&data);
+
+		fuse_put_request(fc, data.req);
+	}
+out_put:
+	if (data.ff)
+		fuse_file_put(data.ff, false);
+out:
+	return err;
+}
+
 static int fuse_launder_page(struct page *page)
 {
 	int err = 0;
@@ -2663,6 +2832,7 @@ static const struct file_operations fuse_direct_io_file_operations = {
 static const struct address_space_operations fuse_file_aops  = {
 	.readpage	= fuse_readpage,
 	.writepage	= fuse_writepage,
+	.writepages	= fuse_writepages,
 	.launder_page	= fuse_launder_page,
 	.readpages	= fuse_readpages,
 	.set_page_dirty	= __set_page_dirty_nobuffers,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
