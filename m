Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AA08C6B0169
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 16:35:40 -0400 (EDT)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 1/2] fuse: delete dead .write_begin and .write_end aops
Date: Mon, 25 Jul 2011 22:35:34 +0200
Message-Id: <1311626135-14279-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: fuse-devel@lists.sourceforge.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Ever since 'ea9b990 fuse: implement perform_write', the .write_begin
and .write_end aops have been dead code.

Their task - acquiring a page from the page cache, sending out a write
request and releasing the page again - is now done batch-wise to
maximize the number of pages send per userspace request.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---
 fs/fuse/file.c |   70 --------------------------------------------------------
 1 files changed, 0 insertions(+), 70 deletions(-)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 82a6646..5c48126 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -743,18 +743,6 @@ static size_t fuse_send_write(struct fuse_req *req, struct file *file,
 	return req->misc.write.out.size;
 }
 
-static int fuse_write_begin(struct file *file, struct address_space *mapping,
-			loff_t pos, unsigned len, unsigned flags,
-			struct page **pagep, void **fsdata)
-{
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
-
-	*pagep = grab_cache_page_write_begin(mapping, index, flags);
-	if (!*pagep)
-		return -ENOMEM;
-	return 0;
-}
-
 void fuse_write_update_size(struct inode *inode, loff_t pos)
 {
 	struct fuse_conn *fc = get_fuse_conn(inode);
@@ -767,62 +755,6 @@ void fuse_write_update_size(struct inode *inode, loff_t pos)
 	spin_unlock(&fc->lock);
 }
 
-static int fuse_buffered_write(struct file *file, struct inode *inode,
-			       loff_t pos, unsigned count, struct page *page)
-{
-	int err;
-	size_t nres;
-	struct fuse_conn *fc = get_fuse_conn(inode);
-	unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
-	struct fuse_req *req;
-
-	if (is_bad_inode(inode))
-		return -EIO;
-
-	/*
-	 * Make sure writepages on the same page are not mixed up with
-	 * plain writes.
-	 */
-	fuse_wait_on_page_writeback(inode, page->index);
-
-	req = fuse_get_req(fc);
-	if (IS_ERR(req))
-		return PTR_ERR(req);
-
-	req->in.argpages = 1;
-	req->num_pages = 1;
-	req->pages[0] = page;
-	req->page_offset = offset;
-	nres = fuse_send_write(req, file, pos, count, NULL);
-	err = req->out.h.error;
-	fuse_put_request(fc, req);
-	if (!err && !nres)
-		err = -EIO;
-	if (!err) {
-		pos += nres;
-		fuse_write_update_size(inode, pos);
-		if (count == PAGE_CACHE_SIZE)
-			SetPageUptodate(page);
-	}
-	fuse_invalidate_attr(inode);
-	return err ? err : nres;
-}
-
-static int fuse_write_end(struct file *file, struct address_space *mapping,
-			loff_t pos, unsigned len, unsigned copied,
-			struct page *page, void *fsdata)
-{
-	struct inode *inode = mapping->host;
-	int res = 0;
-
-	if (copied)
-		res = fuse_buffered_write(file, inode, pos, copied, page);
-
-	unlock_page(page);
-	page_cache_release(page);
-	return res;
-}
-
 static size_t fuse_send_write_pages(struct fuse_req *req, struct file *file,
 				    struct inode *inode, loff_t pos,
 				    size_t count)
@@ -2172,8 +2104,6 @@ static const struct address_space_operations fuse_file_aops  = {
 	.readpage	= fuse_readpage,
 	.writepage	= fuse_writepage,
 	.launder_page	= fuse_launder_page,
-	.write_begin	= fuse_write_begin,
-	.write_end	= fuse_write_end,
 	.readpages	= fuse_readpages,
 	.set_page_dirty	= __set_page_dirty_nobuffers,
 	.bmap		= fuse_bmap,
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
