Subject: [patch v3] splice: fix race with page invalidation
Message-Id: <E1KO8DV-0004E4-6H@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 30 Jul 2008 11:43:33 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jens.axboe@oracle.com
Cc: akpm@linux-foundation.org, nickpiggin@yahoo.com.au, torvalds@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jens,

Please apply or ack this for 2.6.27.

[v3: respun against 2.6.27-rc1]

Thanks,
Miklos

----
From: Miklos Szeredi <mszeredi@suse.cz>

Brian Wang reported that a FUSE filesystem exported through NFS could return
I/O errors on read.  This was traced to splice_direct_to_actor() returning a
short or zero count when racing with page invalidation.

However this is not FUSE or NFSD specific, other filesystems (notably NFS)
also call invalidate_inode_pages2() to purge stale data from the cache.

If this happens while such pages are sitting in a pipe buffer, then splice(2)
from the pipe can return zero, and read(2) from the pipe can return ENODATA.

The zero return is especially bad, since it implies end-of-file or
disconnected pipe/socket, and is documented as such for splice.  But returning
an error for read() is also nasty, when in fact there was no error (data
becoming stale is not an error).

The same problems can be triggered by "hole punching" with
madvise(MADV_REMOVE).

This patch simply reuses the do_generic_file_read() infrastructure to collect
pages to be spliced into the pipe buffer.  This has the advantage of using
very well tested codepaths.  Other than fixing the above problem it also fixes
smaller issues with the previous generic_file_splice_read() implementation:

 - error handling bugs for some corner cases
 - AOP_TRUNCATED_PAGE handling

There are no real disadvantages: splice() from a file was originally meant to
be asynchronous, but in reality it only did that for non-readahead pages,
which happen rarely.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

 fs/splice.c        |  295 ++++++-----------------------------------------------
 include/linux/fs.h |    2 
 mm/filemap.c       |    2 
 3 files changed, 41 insertions(+), 258 deletions(-)

Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c	2008-07-30 10:06:11.000000000 +0200
+++ linux-2.6/fs/splice.c	2008-07-30 11:26:23.000000000 +0200
@@ -87,53 +87,11 @@ static void page_cache_pipe_buf_release(
 	buf->flags &= ~PIPE_BUF_FLAG_LRU;
 }
 
-/*
- * Check whether the contents of buf is OK to access. Since the content
- * is a page cache page, IO may be in flight.
- */
-static int page_cache_pipe_buf_confirm(struct pipe_inode_info *pipe,
-				       struct pipe_buffer *buf)
-{
-	struct page *page = buf->page;
-	int err;
-
-	if (!PageUptodate(page)) {
-		lock_page(page);
-
-		/*
-		 * Page got truncated/unhashed. This will cause a 0-byte
-		 * splice, if this is the first page.
-		 */
-		if (!page->mapping) {
-			err = -ENODATA;
-			goto error;
-		}
-
-		/*
-		 * Uh oh, read-error from disk.
-		 */
-		if (!PageUptodate(page)) {
-			err = -EIO;
-			goto error;
-		}
-
-		/*
-		 * Page is ok afterall, we are done.
-		 */
-		unlock_page(page);
-	}
-
-	return 0;
-error:
-	unlock_page(page);
-	return err;
-}
-
 static const struct pipe_buf_operations page_cache_pipe_buf_ops = {
 	.can_merge = 0,
 	.map = generic_pipe_buf_map,
 	.unmap = generic_pipe_buf_unmap,
-	.confirm = page_cache_pipe_buf_confirm,
+	.confirm = generic_pipe_buf_confirm,
 	.release = page_cache_pipe_buf_release,
 	.steal = page_cache_pipe_buf_steal,
 	.get = generic_pipe_buf_get,
@@ -265,212 +223,26 @@ static void spd_release_page(struct spli
 	page_cache_release(spd->pages[i]);
 }
 
-static int
-__generic_file_splice_read(struct file *in, loff_t *ppos,
-			   struct pipe_inode_info *pipe, size_t len,
-			   unsigned int flags)
+static int file_splice_read_actor(read_descriptor_t *desc, struct page *page,
+				  unsigned long offset, unsigned long size)
 {
-	struct address_space *mapping = in->f_mapping;
-	unsigned int loff, nr_pages, req_pages;
-	struct page *pages[PIPE_BUFFERS];
-	struct partial_page partial[PIPE_BUFFERS];
-	struct page *page;
-	pgoff_t index, end_index;
-	loff_t isize;
-	int error, page_nr;
-	struct splice_pipe_desc spd = {
-		.pages = pages,
-		.partial = partial,
-		.flags = flags,
-		.ops = &page_cache_pipe_buf_ops,
-		.spd_release = spd_release_page,
-	};
-
-	index = *ppos >> PAGE_CACHE_SHIFT;
-	loff = *ppos & ~PAGE_CACHE_MASK;
-	req_pages = (len + loff + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	nr_pages = min(req_pages, (unsigned)PIPE_BUFFERS);
-
-	/*
-	 * Lookup the (hopefully) full range of pages we need.
-	 */
-	spd.nr_pages = find_get_pages_contig(mapping, index, nr_pages, pages);
-	index += spd.nr_pages;
-
-	/*
-	 * If find_get_pages_contig() returned fewer pages than we needed,
-	 * readahead/allocate the rest and fill in the holes.
-	 */
-	if (spd.nr_pages < nr_pages)
-		page_cache_sync_readahead(mapping, &in->f_ra, in,
-				index, req_pages - spd.nr_pages);
-
-	error = 0;
-	while (spd.nr_pages < nr_pages) {
-		/*
-		 * Page could be there, find_get_pages_contig() breaks on
-		 * the first hole.
-		 */
-		page = find_get_page(mapping, index);
-		if (!page) {
-			/*
-			 * page didn't exist, allocate one.
-			 */
-			page = page_cache_alloc_cold(mapping);
-			if (!page)
-				break;
-
-			error = add_to_page_cache_lru(page, mapping, index,
-						mapping_gfp_mask(mapping));
-			if (unlikely(error)) {
-				page_cache_release(page);
-				if (error == -EEXIST)
-					continue;
-				break;
-			}
-			/*
-			 * add_to_page_cache() locks the page, unlock it
-			 * to avoid convoluting the logic below even more.
-			 */
-			unlock_page(page);
-		}
-
-		pages[spd.nr_pages++] = page;
-		index++;
-	}
-
-	/*
-	 * Now loop over the map and see if we need to start IO on any
-	 * pages, fill in the partial map, etc.
-	 */
-	index = *ppos >> PAGE_CACHE_SHIFT;
-	nr_pages = spd.nr_pages;
-	spd.nr_pages = 0;
-	for (page_nr = 0; page_nr < nr_pages; page_nr++) {
-		unsigned int this_len;
-
-		if (!len)
-			break;
-
-		/*
-		 * this_len is the max we'll use from this page
-		 */
-		this_len = min_t(unsigned long, len, PAGE_CACHE_SIZE - loff);
-		page = pages[page_nr];
-
-		if (PageReadahead(page))
-			page_cache_async_readahead(mapping, &in->f_ra, in,
-					page, index, req_pages - page_nr);
-
-		/*
-		 * If the page isn't uptodate, we may need to start io on it
-		 */
-		if (!PageUptodate(page)) {
-			/*
-			 * If in nonblock mode then dont block on waiting
-			 * for an in-flight io page
-			 */
-			if (flags & SPLICE_F_NONBLOCK) {
-				if (TestSetPageLocked(page)) {
-					error = -EAGAIN;
-					break;
-				}
-			} else
-				lock_page(page);
-
-			/*
-			 * Page was truncated, or invalidated by the
-			 * filesystem.  Redo the find/create, but this time the
-			 * page is kept locked, so there's no chance of another
-			 * race with truncate/invalidate.
-			 */
-			if (!page->mapping) {
-				unlock_page(page);
-				page = find_or_create_page(mapping, index,
-						mapping_gfp_mask(mapping));
-
-				if (!page) {
-					error = -ENOMEM;
-					break;
-				}
-				page_cache_release(pages[page_nr]);
-				pages[page_nr] = page;
-			}
-			/*
-			 * page was already under io and is now done, great
-			 */
-			if (PageUptodate(page)) {
-				unlock_page(page);
-				goto fill_it;
-			}
-
-			/*
-			 * need to read in the page
-			 */
-			error = mapping->a_ops->readpage(in, page);
-			if (unlikely(error)) {
-				/*
-				 * We really should re-lookup the page here,
-				 * but it complicates things a lot. Instead
-				 * lets just do what we already stored, and
-				 * we'll get it the next time we are called.
-				 */
-				if (error == AOP_TRUNCATED_PAGE)
-					error = 0;
-
-				break;
-			}
-		}
-fill_it:
-		/*
-		 * i_size must be checked after PageUptodate.
-		 */
-		isize = i_size_read(mapping->host);
-		end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
-		if (unlikely(!isize || index > end_index))
-			break;
-
-		/*
-		 * if this is the last page, see if we need to shrink
-		 * the length and stop
-		 */
-		if (end_index == index) {
-			unsigned int plen;
-
-			/*
-			 * max good bytes in this page
-			 */
-			plen = ((isize - 1) & ~PAGE_CACHE_MASK) + 1;
-			if (plen <= loff)
-				break;
+	struct splice_pipe_desc *spd = desc->arg.data;
+	unsigned long count = desc->count;
 
-			/*
-			 * force quit after adding this page
-			 */
-			this_len = min(this_len, plen - loff);
-			len = this_len;
-		}
+	BUG_ON(spd->nr_pages >= PIPE_BUFFERS);
 
-		partial[page_nr].offset = loff;
-		partial[page_nr].len = this_len;
-		len -= this_len;
-		loff = 0;
-		spd.nr_pages++;
-		index++;
-	}
+	if (size > count)
+		size = count;
 
-	/*
-	 * Release any pages at the end, if we quit early. 'page_nr' is how far
-	 * we got, 'nr_pages' is how many pages are in the map.
-	 */
-	while (page_nr < nr_pages)
-		page_cache_release(pages[page_nr++]);
-	in->f_ra.prev_pos = (loff_t)index << PAGE_CACHE_SHIFT;
+	page_cache_get(page);
+	spd->pages[spd->nr_pages] = page;
+	spd->partial[spd->nr_pages].offset = offset;
+	spd->partial[spd->nr_pages].len = size;
+	spd->nr_pages++;
 
-	if (spd.nr_pages)
-		return splice_to_pipe(pipe, &spd);
+	desc->count = count - size;
 
-	return error;
+	return size;
 }
 
 /**
@@ -491,24 +263,33 @@ ssize_t generic_file_splice_read(struct 
 				 struct pipe_inode_info *pipe, size_t len,
 				 unsigned int flags)
 {
-	loff_t isize, left;
-	int ret;
-
-	isize = i_size_read(in->f_mapping->host);
-	if (unlikely(*ppos >= isize))
-		return 0;
-
-	left = isize - *ppos;
-	if (unlikely(left < len))
-		len = left;
+	ssize_t ret;
+	loff_t pos = *ppos;
+	size_t offset = pos & ~PAGE_CACHE_MASK;
+	struct page *pages[PIPE_BUFFERS];
+	struct partial_page partial[PIPE_BUFFERS];
+	struct splice_pipe_desc spd = {
+		.pages = pages,
+		.partial = partial,
+		.flags = flags,
+		.ops = &page_cache_pipe_buf_ops,
+		.spd_release = spd_release_page,
+	};
+	read_descriptor_t desc = {
+		.count = min(len, (PIPE_BUFFERS << PAGE_CACHE_SHIFT) - offset),
+		.arg.data = &spd,
+	};
 
-	ret = __generic_file_splice_read(in, ppos, pipe, len, flags);
-	if (ret > 0)
-		*ppos += ret;
+	do_generic_file_read(in, &pos, &desc, file_splice_read_actor);
+	ret = desc.error;
+	if (spd.nr_pages) {
+		ret = splice_to_pipe(pipe, &spd);
+		if (ret > 0)
+			*ppos += ret;
+	}
 
 	return ret;
 }
-
 EXPORT_SYMBOL(generic_file_splice_read);
 
 /*
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h	2008-07-30 10:06:11.000000000 +0200
+++ linux-2.6/include/linux/fs.h	2008-07-30 11:26:23.000000000 +0200
@@ -1873,6 +1873,8 @@ extern ssize_t do_sync_read(struct file 
 extern ssize_t do_sync_write(struct file *filp, const char __user *buf, size_t len, loff_t *ppos);
 extern int generic_segment_checks(const struct iovec *iov,
 		unsigned long *nr_segs, size_t *count, int access_flags);
+extern void do_generic_file_read(struct file *filp, loff_t *ppos,
+				 read_descriptor_t *desc, read_actor_t actor);
 
 /* fs/splice.c */
 extern ssize_t generic_file_splice_read(struct file *, loff_t *,
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2008-07-30 10:06:11.000000000 +0200
+++ linux-2.6/mm/filemap.c	2008-07-30 11:26:23.000000000 +0200
@@ -982,7 +982,7 @@ static void shrink_readahead_size_eio(st
  * This is really ugly. But the goto's actually try to clarify some
  * of the logic when it comes to error handling etc.
  */
-static void do_generic_file_read(struct file *filp, loff_t *ppos,
+void do_generic_file_read(struct file *filp, loff_t *ppos,
 		read_descriptor_t *desc, read_actor_t actor)
 {
 	struct address_space *mapping = filp->f_mapping;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
