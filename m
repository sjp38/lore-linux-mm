Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7D73D6B004A
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 18:33:37 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p59MXZWl007222
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 15:33:35 -0700
Received: from pzk4 (pzk4.prod.google.com [10.243.19.132])
	by wpaz1.hot.corp.google.com with ESMTP id p59MXXZx030980
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 15:33:34 -0700
Received: by pzk4 with SMTP id 4so1015468pzk.28
        for <linux-mm@kvack.org>; Thu, 09 Jun 2011 15:33:33 -0700 (PDT)
Date: Thu, 9 Jun 2011 15:33:32 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 2/7] tmpfs: refine shmem_file_splice_read
In-Reply-To: <alpine.LSU.2.00.1106091529060.2200@sister.anvils>
Message-ID: <alpine.LSU.2.00.1106091532370.2200@sister.anvils>
References: <alpine.LSU.2.00.1106091529060.2200@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Tidy up shmem_file_splice_read():

Remove readahead: okay, we could implement shmem readahead on swap,
but have never done so before, swap being the slow exceptional path.

Use shmem_getpage() instead of find_or_create_page() plus ->readpage().

Remove several comments: sorry, I found them more distracting than
helpful, and this will not be the reference version of splice_read().

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/shmem.c |  138 +++++++--------------------------------------------
 1 file changed, 19 insertions(+), 119 deletions(-)

--- linux.orig/mm/shmem.c	2011-06-09 11:38:05.232808448 -0700
+++ linux/mm/shmem.c	2011-06-09 11:38:13.436849182 -0700
@@ -1850,6 +1850,7 @@ static ssize_t shmem_file_splice_read(st
 				unsigned int flags)
 {
 	struct address_space *mapping = in->f_mapping;
+	struct inode *inode = mapping->host;
 	unsigned int loff, nr_pages, req_pages;
 	struct page *pages[PIPE_DEF_BUFFERS];
 	struct partial_page partial[PIPE_DEF_BUFFERS];
@@ -1865,7 +1866,7 @@ static ssize_t shmem_file_splice_read(st
 		.spd_release = spd_release_page,
 	};
 
-	isize = i_size_read(in->f_mapping->host);
+	isize = i_size_read(inode);
 	if (unlikely(*ppos >= isize))
 		return 0;
 
@@ -1881,153 +1882,57 @@ static ssize_t shmem_file_splice_read(st
 	req_pages = (len + loff + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	nr_pages = min(req_pages, pipe->buffers);
 
-	/*
-	 * Lookup the (hopefully) full range of pages we need.
-	 */
 	spd.nr_pages = find_get_pages_contig(mapping, index,
 						nr_pages, spd.pages);
 	index += spd.nr_pages;
-
-	/*
-	 * If find_get_pages_contig() returned fewer pages than we needed,
-	 * readahead/allocate the rest and fill in the holes.
-	 */
-	if (spd.nr_pages < nr_pages)
-		page_cache_sync_readahead(mapping, &in->f_ra, in,
-				index, req_pages - spd.nr_pages);
-
 	error = 0;
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
-						GFP_KERNEL);
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
 
+	while (spd.nr_pages < nr_pages) {
+		page = NULL;
+		error = shmem_getpage(inode, index, &page, SGP_CACHE, NULL);
+		if (error)
+			break;
+		unlock_page(page);
 		spd.pages[spd.nr_pages++] = page;
 		index++;
 	}
 
-	/*
-	 * Now loop over the map and see if we need to start IO on any
-	 * pages, fill in the partial map, etc.
-	 */
 	index = *ppos >> PAGE_CACHE_SHIFT;
 	nr_pages = spd.nr_pages;
 	spd.nr_pages = 0;
+
 	for (page_nr = 0; page_nr < nr_pages; page_nr++) {
 		unsigned int this_len;
 
 		if (!len)
 			break;
 
-		/*
-		 * this_len is the max we'll use from this page
-		 */
 		this_len = min_t(unsigned long, len, PAGE_CACHE_SIZE - loff);
 		page = spd.pages[page_nr];
 
-		if (PageReadahead(page))
-			page_cache_async_readahead(mapping, &in->f_ra, in,
-					page, index, req_pages - page_nr);
-
-		/*
-		 * If the page isn't uptodate, we may need to start io on it
-		 */
-		if (!PageUptodate(page)) {
-			lock_page(page);
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
-				page_cache_release(spd.pages[page_nr]);
-				spd.pages[page_nr] = page;
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
+		if (!PageUptodate(page) || page->mapping != mapping) {
+			page = NULL;
+			error = shmem_getpage(inode, index, &page,
+							SGP_CACHE, NULL);
+			if (error)
 				break;
-			}
+			unlock_page(page);
+			page_cache_release(spd.pages[page_nr]);
+			spd.pages[page_nr] = page;
 		}
-fill_it:
-		/*
-		 * i_size must be checked after PageUptodate.
-		 */
-		isize = i_size_read(mapping->host);
+
+		isize = i_size_read(inode);
 		end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
 		if (unlikely(!isize || index > end_index))
 			break;
 
-		/*
-		 * if this is the last page, see if we need to shrink
-		 * the length and stop
-		 */
 		if (end_index == index) {
 			unsigned int plen;
 
-			/*
-			 * max good bytes in this page
-			 */
 			plen = ((isize - 1) & ~PAGE_CACHE_MASK) + 1;
 			if (plen <= loff)
 				break;
 
-			/*
-			 * force quit after adding this page
-			 */
 			this_len = min(this_len, plen - loff);
 			len = this_len;
 		}
@@ -2040,13 +1945,8 @@ fill_it:
 		index++;
 	}
 
-	/*
-	 * Release any pages at the end, if we quit early. 'page_nr' is how far
-	 * we got, 'nr_pages' is how many pages are in the map.
-	 */
 	while (page_nr < nr_pages)
 		page_cache_release(spd.pages[page_nr++]);
-	in->f_ra.prev_pos = (loff_t)index << PAGE_CACHE_SHIFT;
 
 	if (spd.nr_pages)
 		error = splice_to_pipe(pipe, &spd);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
