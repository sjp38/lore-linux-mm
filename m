Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 331846B0032
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 12:50:39 -0400 (EDT)
Received: by mail-ea0-f170.google.com with SMTP id h10so2494822eaj.15
        for <linux-mm@kvack.org>; Fri, 19 Jul 2013 09:50:37 -0700 (PDT)
Date: Fri, 19 Jul 2013 18:50:37 +0200
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH 10/16] fuse: Implement writepages callback
Message-ID: <20130719165037.GA18358@tucsk.piliscsaba.szeredi.hu>
References: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
 <20130629174525.20175.18987.stgit@maximpc.sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130629174525.20175.18987.stgit@maximpc.sw.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Patlasov <MPatlasov@parallels.com>
Cc: riel@redhat.com, dev@parallels.com, xemul@parallels.com, fuse-devel@lists.sourceforge.net, bfoster@redhat.com, linux-kernel@vger.kernel.org, jbottomley@parallels.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, fengguang.wu@intel.com, devel@openvz.org, mgorman@suse.de

On Sat, Jun 29, 2013 at 09:45:29PM +0400, Maxim Patlasov wrote:
> From: Pavel Emelyanov <xemul@openvz.org>
> 
> The .writepages one is required to make each writeback request carry more than
> one page on it. The patch enables optimized behaviour unconditionally,
> i.e. mmap-ed writes will benefit from the patch even if fc->writeback_cache=0.

I rewrote this a bit, so we won't have to do the thing in two passes, which
makes it simpler and more robust.  Waiting for page writeback here is wrong
anyway, see comment above fuse_page_mkwrite().  BTW we had a race there because
fuse_page_mkwrite() didn't take the page lock.  I've also fixed that up and
pushed a series containing these patches up to implementing ->writepages() to

  git://git.kernel.org/pub/scm/linux/kernel/git/mszeredi/fuse.git writepages

Passed some trivial testing but more is needed.

I'll get to the rest of the patches next week.

Thanks,
Miklos


Subject: fuse: Implement writepages callback
From: Pavel Emelyanov <xemul@openvz.org>
Date: Sat, 29 Jun 2013 21:45:29 +0400

The .writepages one is required to make each writeback request carry more than
one page on it. The patch enables optimized behaviour unconditionally,
i.e. mmap-ed writes will benefit from the patch even if fc->writeback_cache=0.

[SzM: simplify, add comments]

Signed-off-by: Maxim Patlasov <MPatlasov@parallels.com>
Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 fs/fuse/file.c |  139 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 139 insertions(+)

--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1579,6 +1579,144 @@ static int fuse_writepage(struct page *p
 	return err;
 }
 
+struct fuse_fill_wb_data {
+	struct fuse_req *req;
+	struct fuse_file *ff;
+	struct inode *inode;
+};
+
+static void fuse_writepages_send(struct fuse_fill_wb_data *data)
+{
+	struct fuse_req *req = data->req;
+	struct inode *inode = data->inode;
+	struct fuse_conn *fc = get_fuse_conn(inode);
+	struct fuse_inode *fi = get_fuse_inode(inode);
+
+	req->ff = fuse_file_get(data->ff);
+	spin_lock(&fc->lock);
+	list_add_tail(&req->list, &fi->queued_writes);
+	fuse_flush_writepages(inode);
+	spin_unlock(&fc->lock);
+}
+
+static int fuse_writepages_fill(struct page *page,
+		struct writeback_control *wbc, void *_data)
+{
+	struct fuse_fill_wb_data *data = _data;
+	struct fuse_req *req = data->req;
+	struct inode *inode = data->inode;
+	struct fuse_conn *fc = get_fuse_conn(inode);
+	struct page *tmp_page;
+	int err;
+
+	if (req) {
+		BUG_ON(!req->num_pages);
+		if (req->num_pages == FUSE_MAX_PAGES_PER_REQ ||
+		    (req->num_pages + 1) * PAGE_CACHE_SIZE > fc->max_write ||
+		    req->pages[req->num_pages - 1]->index + 1 != page->index) {
+
+			fuse_writepages_send(data);
+			data->req = NULL;
+		}
+	}
+	err = -ENOMEM;
+	tmp_page = alloc_page(GFP_NOFS | __GFP_HIGHMEM);
+	if (!tmp_page)
+		goto out_unlock;
+
+	/*
+	 * The page must not be redirtied until the writeout is completed
+	 * (i.e. userspace has sent a reply to the write request).  Otherwise
+	 * there could be more than one temporary page instance for each real
+	 * page.
+	 *
+	 * This is ensured by holding the page lock in page_mkwrite() while
+	 * checking fuse_page_is_writeback().  We already hold the page lock
+	 * since clear_page_dirty_for_io() and keep it held until we add the
+	 * request to the fi->writepages list and increment req->num_pages.
+	 * After this fuse_page_is_writeback() will indicate that the page is
+	 * under writeback, so we can release the page lock.
+	 */
+	if (data->req == NULL) {
+		struct fuse_inode *fi = get_fuse_inode(inode);
+
+		err = -ENOMEM;
+		req = fuse_request_alloc_nofs(FUSE_MAX_PAGES_PER_REQ);
+		if (!req) {
+			__free_page(tmp_page);
+			goto out_unlock;
+		}
+
+		fuse_write_fill(req, data->ff, page_offset(page), 0);
+		req->misc.write.in.write_flags |= FUSE_WRITE_CACHE;
+		req->in.argpages = 1;
+		req->background = 1;
+		req->num_pages = 0;
+		req->end = fuse_writepage_end;
+		req->inode = inode;
+
+		spin_lock(&fc->lock);
+		list_add(&req->writepages_entry, &fi->writepages);
+		spin_unlock(&fc->lock);
+
+		data->req = req;
+	}
+	set_page_writeback(page);
+
+	copy_highpage(tmp_page, page);
+	req->pages[req->num_pages] = tmp_page;
+	req->page_descs[req->num_pages].offset = 0;
+	req->page_descs[req->num_pages].length = PAGE_SIZE;
+
+	inc_bdi_stat(page->mapping->backing_dev_info, BDI_WRITEBACK);
+	inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
+	end_page_writeback(page);
+
+	/*
+	 * Protected by fc->lock against concurrent access by
+	 * fuse_page_is_writeback().
+	 */
+	spin_lock(&fc->lock);
+	req->num_pages++;
+	spin_unlock(&fc->lock);
+
+	err = 0;
+out_unlock:
+	unlock_page(page);
+
+	return err;
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
+	data.req = NULL;
+	data.inode = inode;
+	data.ff = fuse_write_file(fc, get_fuse_inode(inode));
+	if (!data.ff)
+		goto out;
+
+	err = write_cache_pages(mapping, wbc, fuse_writepages_fill, &data);
+	if (data.req) {
+		/* Ignore errors if we can write at least one page */
+		BUG_ON(!data.req->num_pages);
+		fuse_writepages_send(&data);
+		err = 0;
+	}
+	fuse_file_put(data.ff, false);
+out:
+	return err;
+}
+
 static int fuse_launder_page(struct page *page)
 {
 	int err = 0;
@@ -2589,6 +2727,7 @@ static const struct file_operations fuse
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
