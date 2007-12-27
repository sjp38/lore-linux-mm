Message-Id: <20071227053402.565164972@sgi.com>
References: <20071227053246.902699851@sgi.com>
Date: Wed, 26 Dec 2007 21:32:59 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 13/18] Use page_cache_xxx in fs/splice.c
Content-Disposition: inline; filename=0014-Use-page_cache_xxx-in-fs-splice.c.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, David Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

Use page_cache_xxx in fs/splice.c

Reviewed-by: Dave Chinner <dgc@sgi.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/splice.c |   27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

Index: linux-2.6.24-rc6-mm1/fs/splice.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/splice.c	2007-12-26 17:47:05.535424632 -0800
+++ linux-2.6.24-rc6-mm1/fs/splice.c	2007-12-26 19:51:07.954144671 -0800
@@ -285,9 +285,9 @@ __generic_file_splice_read(struct file *
 		.spd_release = spd_release_page,
 	};
 
-	index = *ppos >> PAGE_CACHE_SHIFT;
-	loff = *ppos & ~PAGE_CACHE_MASK;
-	req_pages = (len + loff + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	index = page_cache_index(mapping, *ppos);
+	loff = page_cache_offset(mapping, *ppos);
+	req_pages = page_cache_next(mapping, len + loff);
 	nr_pages = min(req_pages, (unsigned)PIPE_BUFFERS);
 
 	/*
@@ -342,7 +342,7 @@ __generic_file_splice_read(struct file *
 	 * Now loop over the map and see if we need to start IO on any
 	 * pages, fill in the partial map, etc.
 	 */
-	index = *ppos >> PAGE_CACHE_SHIFT;
+	index = page_cache_index(mapping, *ppos);
 	nr_pages = spd.nr_pages;
 	spd.nr_pages = 0;
 	for (page_nr = 0; page_nr < nr_pages; page_nr++) {
@@ -354,7 +354,8 @@ __generic_file_splice_read(struct file *
 		/*
 		 * this_len is the max we'll use from this page
 		 */
-		this_len = min_t(unsigned long, len, PAGE_CACHE_SIZE - loff);
+		this_len = min_t(unsigned long, len,
+					page_cache_size(mapping) - loff);
 		page = pages[page_nr];
 
 		if (PageReadahead(page))
@@ -414,7 +415,7 @@ fill_it:
 		 * i_size must be checked after PageUptodate.
 		 */
 		isize = i_size_read(mapping->host);
-		end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
+		end_index = page_cache_index(mapping, isize - 1);
 		if (unlikely(!isize || index > end_index))
 			break;
 
@@ -428,7 +429,7 @@ fill_it:
 			/*
 			 * max good bytes in this page
 			 */
-			plen = ((isize - 1) & ~PAGE_CACHE_MASK) + 1;
+			plen = page_cache_offset(mapping, isize - 1) + 1;
 			if (plen <= loff)
 				break;
 
@@ -453,7 +454,7 @@ fill_it:
 	 */
 	while (page_nr < nr_pages)
 		page_cache_release(pages[page_nr++]);
-	in->f_ra.prev_pos = (loff_t)index << PAGE_CACHE_SHIFT;
+	in->f_ra.prev_pos = page_cache_pos(mapping, index, 0);
 
 	if (spd.nr_pages)
 		return splice_to_pipe(pipe, &spd);
@@ -579,11 +580,11 @@ static int pipe_to_file(struct pipe_inod
 	if (unlikely(ret))
 		return ret;
 
-	offset = sd->pos & ~PAGE_CACHE_MASK;
+	offset = page_cache_offset(mapping, sd->pos);
 
 	this_len = sd->len;
-	if (this_len + offset > PAGE_CACHE_SIZE)
-		this_len = PAGE_CACHE_SIZE - offset;
+	if (this_len + offset > page_cache_size(mapping))
+		this_len = page_cache_size(mapping) - offset;
 
 	ret = pagecache_write_begin(file, mapping, sd->pos, this_len,
 				AOP_FLAG_UNINTERRUPTIBLE, &page, &fsdata);
@@ -790,7 +791,7 @@ generic_file_splice_write_nolock(struct 
 		unsigned long nr_pages;
 
 		*ppos += ret;
-		nr_pages = (ret + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+		nr_pages = page_cache_next(mapping, ret);
 
 		/*
 		 * If file or inode is SYNC and we actually wrote some data,
@@ -852,7 +853,7 @@ generic_file_splice_write(struct pipe_in
 		unsigned long nr_pages;
 
 		*ppos += ret;
-		nr_pages = (ret + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+		nr_pages = page_cache_next(mapping, ret);
 
 		/*
 		 * If file or inode is SYNC and we actually wrote some data,

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
