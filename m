Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DF1C16B01F8
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 12:17:38 -0400 (EDT)
Message-Id: <20100428161722.896102829@szeredi.hu>
References: <20100428161636.272097923@szeredi.hu>
Date: Wed, 28 Apr 2010 18:16:42 +0200
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [RFC PATCH 6/6] fuse: allow splice to move pages
Content-Disposition: inline; filename=fuse-dev-steal-page.patch
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: jens.axboe@oracle.com, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

When splicing buffers to the fuse device with SPLICE_F_MOVE, try to
move pages from the pipe buffer into the page cache.  This allows
populating the fuse filesystem's cache without ever touching the page
contents, i.e. zero copy read capability.

The following steps are performed when trying to move a page into the
page cache:

 - buf->ops->confirm() to make sure the new page is uptodate
 - buf->ops->steal() to try to remove the new page from it's previous place
 - remove_from_page_cache() on the old page
 - add_to_page_cache_locked() on the new page

If any of the above steps fail (non fatally) then the code falls back
to copying the page.  In particular ->steal() will fail if there are
external references (other than the page cache and the pipe buffer) to
the page.

Also since the remove_from_page_cache() + add_to_page_cache_locked()
are non-atomic it is possible that the page cache is repopulated in
between the two and add_to_page_cache_locked() will fail.  This could
be fixed by creating a new atomic replace_page_cache_page() function.

fuse_readpages_end() needed to be reworked so it works even if
page->mapping is NULL for some or all pages which can happen if the
add_to_page_cache_locked() failed.

A number of sanity checks were added to make sure the stolen pages
don't have weird flags set, etc...  These could be moved into generic
splice/steal code.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 fs/fuse/dev.c    |  151 ++++++++++++++++++++++++++++++++++++++++++++++++++++---
 fs/fuse/file.c   |   28 ++++++----
 fs/fuse/fuse_i.h |    3 +
 3 files changed, 167 insertions(+), 15 deletions(-)

Index: linux-2.6/fs/fuse/dev.c
===================================================================
--- linux-2.6.orig/fs/fuse/dev.c	2010-04-28 15:51:09.000000000 +0200
+++ linux-2.6/fs/fuse/dev.c	2010-04-28 17:14:35.000000000 +0200
@@ -17,6 +17,8 @@
 #include <linux/file.h>
 #include <linux/slab.h>
 #include <linux/pipe_fs_i.h>
+#include <linux/swap.h>
+#include <linux/splice.h>
 
 MODULE_ALIAS_MISCDEV(FUSE_MINOR);
 
@@ -509,6 +511,7 @@ struct fuse_copy_state {
 	void *mapaddr;
 	void *buf;
 	unsigned len;
+	unsigned move_pages:1;
 };
 
 static void fuse_copy_init(struct fuse_copy_state *cs, struct fuse_conn *fc,
@@ -609,13 +612,135 @@ static int fuse_copy_do(struct fuse_copy
 	return ncpy;
 }
 
+static int fuse_check_page(struct page *page)
+{
+	if (page_mapcount(page) ||
+	    page->mapping != NULL ||
+	    page_count(page) != 1 ||
+	    (page->flags & PAGE_FLAGS_CHECK_AT_PREP &
+	     ~(1 << PG_locked |
+	       1 << PG_referenced |
+	       1 << PG_uptodate |
+	       1 << PG_lru |
+	       1 << PG_active |
+	       1 << PG_reclaim))) {
+		printk(KERN_WARNING "fuse: trying to steal weird page\n");
+		printk(KERN_WARNING "  page=%p index=%li flags=%08lx, count=%i, mapcount=%i, mapping=%p\n", page, page->index, page->flags, page_count(page), page_mapcount(page), page->mapping);
+		return 1;
+	}
+	return 0;
+}
+
+static int fuse_try_move_page(struct fuse_copy_state *cs, struct page **pagep)
+{
+	int err;
+	struct page *oldpage = *pagep;
+	struct page *newpage;
+	struct pipe_buffer *buf = cs->pipebufs;
+	struct address_space *mapping;
+	pgoff_t index;
+
+	unlock_request(cs->fc, cs->req);
+	fuse_copy_finish(cs);
+
+	err = buf->ops->confirm(cs->pipe, buf);
+	if (err)
+		return err;
+
+	BUG_ON(!cs->nr_segs);
+	cs->currbuf = buf;
+	cs->len = buf->len;
+	cs->pipebufs++;
+	cs->nr_segs--;
+
+	if (cs->len != PAGE_SIZE)
+		goto out_fallback;
+
+	if (buf->ops->steal(cs->pipe, buf) != 0)
+		goto out_fallback;
+
+	newpage = buf->page;
+
+	if (WARN_ON(!PageUptodate(newpage)))
+		return -EIO;
+
+	ClearPageMappedToDisk(newpage);
+
+	if (fuse_check_page(newpage) != 0)
+		goto out_fallback_unlock;
+
+	mapping = oldpage->mapping;
+	index = oldpage->index;
+
+	/*
+	 * This is a new and locked page, it shouldn't be mapped or
+	 * have any special flags on it
+	 */
+	if (WARN_ON(page_mapped(oldpage)))
+		goto out_fallback_unlock;
+	if (WARN_ON(page_has_private(oldpage)))
+		goto out_fallback_unlock;
+	if (WARN_ON(PageDirty(oldpage) || PageWriteback(oldpage)))
+		goto out_fallback_unlock;
+	if (WARN_ON(PageMlocked(oldpage)))
+		goto out_fallback_unlock;
+
+	remove_from_page_cache(oldpage);
+	page_cache_release(oldpage);
+
+	err = add_to_page_cache_locked(newpage, mapping, index, GFP_KERNEL);
+	if (err) {
+		printk(KERN_WARNING "fuse_try_move_page: failed to add page");
+		goto out_fallback_unlock;
+	}
+	page_cache_get(newpage);
+
+	if (!(buf->flags & PIPE_BUF_FLAG_LRU))
+		lru_cache_add_file(newpage);
+
+	err = 0;
+	spin_lock(&cs->fc->lock);
+	if (cs->req->aborted)
+		err = -ENOENT;
+	else
+		*pagep = newpage;
+	spin_unlock(&cs->fc->lock);
+
+	if (err) {
+		unlock_page(newpage);
+		page_cache_release(newpage);
+		return err;
+	}
+
+	unlock_page(oldpage);
+	page_cache_release(oldpage);
+	cs->len = 0;
+
+	return 0;
+
+out_fallback_unlock:
+	unlock_page(newpage);
+out_fallback:
+	cs->mapaddr = buf->ops->map(cs->pipe, buf, 1);
+	cs->buf = cs->mapaddr + buf->offset;
+
+	err = lock_request(cs->fc, cs->req);
+	if (err)
+		return err;
+
+	return 1;
+}
+
 /*
  * Copy a page in the request to/from the userspace buffer.  Must be
  * done atomically
  */
-static int fuse_copy_page(struct fuse_copy_state *cs, struct page *page,
+static int fuse_copy_page(struct fuse_copy_state *cs, struct page **pagep,
 			  unsigned offset, unsigned count, int zeroing)
 {
+	int err;
+	struct page *page = *pagep;
+
 	if (page && zeroing && count < PAGE_SIZE) {
 		void *mapaddr = kmap_atomic(page, KM_USER1);
 		memset(mapaddr, 0, PAGE_SIZE);
@@ -623,9 +748,16 @@ static int fuse_copy_page(struct fuse_co
 	}
 	while (count) {
 		if (!cs->len) {
-			int err = fuse_copy_fill(cs);
-			if (err)
-				return err;
+			if (cs->move_pages && page &&
+			    offset == 0 && count == PAGE_SIZE) {
+				err = fuse_try_move_page(cs, pagep);
+				if (err <= 0)
+					return err;
+			} else {
+				err = fuse_copy_fill(cs);
+				if (err)
+					return err;
+			}
 		}
 		if (page) {
 			void *mapaddr = kmap_atomic(page, KM_USER1);
@@ -650,8 +782,10 @@ static int fuse_copy_pages(struct fuse_c
 	unsigned count = min(nbytes, (unsigned) PAGE_SIZE - offset);
 
 	for (i = 0; i < req->num_pages && (nbytes || zeroing); i++) {
-		struct page *page = req->pages[i];
-		int err = fuse_copy_page(cs, page, offset, count, zeroing);
+		int err;
+
+		err = fuse_copy_page(cs, &req->pages[i], offset, count,
+				     zeroing);
 		if (err)
 			return err;
 
@@ -1079,6 +1213,8 @@ static ssize_t fuse_dev_do_write(struct
 	req->out.h = oh;
 	req->locked = 1;
 	cs->req = req;
+	if (!req->out.page_replace)
+		cs->move_pages = 0;
 	spin_unlock(&fc->lock);
 
 	err = copy_out_args(cs, &req->out, nbytes);
@@ -1177,6 +1313,9 @@ static ssize_t fuse_dev_splice_write(str
 	cs.nr_segs = nbuf;
 	cs.pipe = pipe;
 
+	if (flags & SPLICE_F_MOVE)
+		cs.move_pages = 1;
+
 	ret = fuse_dev_do_write(fc, &cs, len);
 
 	for (idx = 0; idx < nbuf; idx++) {
Index: linux-2.6/fs/fuse/file.c
===================================================================
--- linux-2.6.orig/fs/fuse/file.c	2010-04-28 15:50:35.000000000 +0200
+++ linux-2.6/fs/fuse/file.c	2010-04-28 17:14:35.000000000 +0200
@@ -517,17 +517,26 @@ static void fuse_readpages_end(struct fu
 	int i;
 	size_t count = req->misc.read.in.size;
 	size_t num_read = req->out.args[0].size;
-	struct inode *inode = req->pages[0]->mapping->host;
+	struct address_space *mapping = NULL;
 
-	/*
-	 * Short read means EOF.  If file size is larger, truncate it
-	 */
-	if (!req->out.h.error && num_read < count) {
-		loff_t pos = page_offset(req->pages[0]) + num_read;
-		fuse_read_update_size(inode, pos, req->misc.read.attr_ver);
-	}
+	for (i = 0; mapping == NULL && i < req->num_pages; i++)
+		mapping = req->pages[i]->mapping;
+
+	if (mapping) {
+		struct inode *inode = mapping->host;
 
-	fuse_invalidate_attr(inode); /* atime changed */
+		/*
+		 * Short read means EOF. If file size is larger, truncate it
+		 */
+		if (!req->out.h.error && num_read < count) {
+			loff_t pos;
+
+			pos = page_offset(req->pages[0]) + num_read;
+			fuse_read_update_size(inode, pos,
+					      req->misc.read.attr_ver);
+		}
+		fuse_invalidate_attr(inode); /* atime changed */
+	}
 
 	for (i = 0; i < req->num_pages; i++) {
 		struct page *page = req->pages[i];
@@ -551,6 +560,7 @@ static void fuse_send_readpages(struct f
 
 	req->out.argpages = 1;
 	req->out.page_zeroing = 1;
+	req->out.page_replace = 1;
 	fuse_read_fill(req, file, pos, count, FUSE_READ);
 	req->misc.read.attr_ver = fuse_get_attr_version(fc);
 	if (fc->async_read) {
Index: linux-2.6/fs/fuse/fuse_i.h
===================================================================
--- linux-2.6.orig/fs/fuse/fuse_i.h	2010-04-26 11:33:57.000000000 +0200
+++ linux-2.6/fs/fuse/fuse_i.h	2010-04-28 17:14:35.000000000 +0200
@@ -177,6 +177,9 @@ struct fuse_out {
 	/** Zero partially or not copied pages */
 	unsigned page_zeroing:1;
 
+	/** Pages may be replaced with new ones */
+	unsigned page_replace:1;
+
 	/** Number or arguments */
 	unsigned numargs;
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
