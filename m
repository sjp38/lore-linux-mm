Message-Id: <20080621154727.808329488@szeredi.hu>
References: <20080621154607.154640724@szeredi.hu>
Date: Sat, 21 Jun 2008 17:46:11 +0200
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [rfc patch 4/4] splice: use do_generic_file_read()
Content-Disposition: inline; filename=splice_generic_file_splice_read_cleanup.patch
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: jens.axboe@oracle.com
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

__generic_file_splice_read() duplicates a lot of stuff common with the
generic page cache reading.  So reuse that code instead to simplify
the page cache splice code.

This also fixes some corner cases which weren't properly handled in
the splice code because of complexity issues.  In particular it fixes
a problem when the filesystem (e.g. fuse) invalidates pages during the
splice operation.

There might be some slight fall in performance due to the removal of
the gang lookup for pages.  However I'm not sure if this is
significant enough to warrant the extra complication.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 fs/splice.c        |  248 +++++++----------------------------------------------
 include/linux/fs.h |    2 
 mm/filemap.c       |    2 
 3 files changed, 40 insertions(+), 212 deletions(-)

Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c	2008-06-21 15:19:49.000000000 +0200
+++ linux-2.6/fs/splice.c	2008-06-21 16:47:07.000000000 +0200
@@ -159,208 +159,25 @@ static void spd_release_page(struct spli
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
+	struct splice_pipe_desc *spd = desc->arg.data;
+	unsigned long count = desc->count;
 
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
+	if (size > count)
+		size = count;
 
-		pages[spd.nr_pages++] = page;
-		index++;
-	}
+	page_cache_get(page);
+	spd->pages[spd->nr_pages] = page;
+	spd->partial[spd->nr_pages].offset = offset;
+	spd->partial[spd->nr_pages].len = size;
+	spd->nr_pages++;
 
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
+	desc->count = count - size;
+	desc->written += size;
 
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
-			 * page was truncated, stop here. if this isn't the
-			 * first page, we'll just complete what we already
-			 * added
-			 */
-			if (!page->mapping) {
-				unlock_page(page);
-				break;
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
-			wait_on_page_locked(page);
-			if (!PageUptodate(page)) {
-				error = -EIO;
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
-
-			/*
-			 * force quit after adding this page
-			 */
-			this_len = min(this_len, plen - loff);
-			len = this_len;
-		}
-
-		partial[page_nr].offset = loff;
-		partial[page_nr].len = this_len;
-		len -= this_len;
-		loff = 0;
-		spd.nr_pages++;
-		index++;
-	}
-
-	/*
-	 * Release any pages at the end, if we quit early. 'page_nr' is how far
-	 * we got, 'nr_pages' is how many pages are in the map.
-	 */
-	while (page_nr < nr_pages)
-		page_cache_release(pages[page_nr++]);
-	in->f_ra.prev_pos = (loff_t)index << PAGE_CACHE_SHIFT;
-
-	if (spd.nr_pages)
-		return splice_to_pipe(pipe, &spd);
-
-	return error;
+	return size;
 }
 
 /**
@@ -381,24 +198,33 @@ ssize_t generic_file_splice_read(struct 
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
+	loff_t pos;
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
+		.count = len,
+		.arg.data = &spd,
+	};
 
-	ret = __generic_file_splice_read(in, ppos, pipe, len, flags);
-	if (ret > 0)
-		*ppos += ret;
+	pos = *ppos;
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
--- linux-2.6.orig/include/linux/fs.h	2008-06-21 15:14:26.000000000 +0200
+++ linux-2.6/include/linux/fs.h	2008-06-21 15:19:49.000000000 +0200
@@ -1854,6 +1854,8 @@ extern ssize_t do_sync_read(struct file 
 extern ssize_t do_sync_write(struct file *filp, const char __user *buf, size_t len, loff_t *ppos);
 extern int generic_segment_checks(const struct iovec *iov,
 		unsigned long *nr_segs, size_t *count, int access_flags);
+extern void do_generic_file_read(struct file *filp, loff_t *ppos,
+				 read_descriptor_t *desc, read_actor_t actor);
 
 /* fs/splice.c */
 extern ssize_t generic_file_splice_read(struct file *, loff_t *,
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2008-06-21 15:14:26.000000000 +0200
+++ linux-2.6/mm/filemap.c	2008-06-21 15:19:49.000000000 +0200
@@ -891,7 +891,7 @@ static void shrink_readahead_size_eio(st
  * This is really ugly. But the goto's actually try to clarify some
  * of the logic when it comes to error handling etc.
  */
-static void do_generic_file_read(struct file *filp, loff_t *ppos,
+void do_generic_file_read(struct file *filp, loff_t *ppos,
 		read_descriptor_t *desc, read_actor_t actor)
 {
 	struct address_space *mapping = filp->f_mapping;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
