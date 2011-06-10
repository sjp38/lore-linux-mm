Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D6D986B0012
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 16:01:41 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p5AK1aqv031999
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 13:01:39 -0700
Received: from pxi20 (pxi20.prod.google.com [10.243.27.20])
	by hpaq5.eem.corp.google.com with ESMTP id p5AK1L7c025219
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 13:01:35 -0700
Received: by pxi20 with SMTP id 20so2216461pxi.27
        for <linux-mm@kvack.org>; Fri, 10 Jun 2011 13:01:29 -0700 (PDT)
Date: Fri, 10 Jun 2011 13:01:28 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/7] tmpfs: clone shmem_file_splice_read
In-Reply-To: <4DF1E1B0.2090907@fusionio.com>
Message-ID: <alpine.LSU.2.00.1106101220450.26945@sister.anvils>
References: <alpine.LSU.2.00.1106091529060.2200@sister.anvils> <alpine.LSU.2.00.1106091531120.2200@sister.anvils> <4DF1E1B0.2090907@fusionio.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <jaxboe@fusionio.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 10 Jun 2011, Jens Axboe wrote:
> On 2011-06-10 00:32, Hugh Dickins wrote:
> > Copy __generic_file_splice_read() and generic_file_splice_read()
> > from fs/splice.c to shmem_file_splice_read() in mm/shmem.c.  Make
> > page_cache_pipe_buf_ops and spd_release_page() accessible to it.
> 
> That's a lot of fairly complicated and convoluted code to have
> duplicated. Yes, I know I know, it's already largely duplicated from the
> normal file read, but still... Really no easy way to share this?

I hadn't thought in that direction at all, to be honest: imagined you
had already factored out what could be factored out, splice_to_pipe()
and the spd helpers.  I just copied the code over in this patch, then
trimmed it down for tmpfs in the next.

(I didn't Cc you on that second patch because it was local to shmem.c:
maybe you looked it up on the list, maybe you didn't - here it is below.
It would be very unfair to claim that it halves the size, since I took
out some comments; compiled size goes down from 1219 to 897 bytes.)

What tmpfs wants to avoid is outsiders inserting pages into its filecache
then calling ->readpage on them (because tmpfs may already have those
pages in swapcache - though I've another reason to avoid it coming soon).
Since the interesting uses of tmpfs go through its ->splice_read nowadays,
I just switched that over not to use ->readpage.

You ask, no easy way to share this?  I guess we could make a little
library-like function of the isize, this_len code at fill_it; but
that doesn't really seem worth much.

I could drop shmem.c's find_get_pages_contig() and combine the other
two loops to make just a single shmem_getpage()ing loop; or even
resort to using default_file_splice_read() with its page allocation
and copying.  But crippling the shmem splice just seems a retrograde
step, which might be noticed by sendfile users: I don't think that's
what you intend.

Ever since birth, shmem had to have its own file_read and file_write:
your splice work with Nick's write_begin changes let it use generic
splice for writing, but I do need to avoid readpage in reading.

If I thought I had my finger on the pulse of what modern filesystems
want, I might propose a readpage replacement for all; but, frankly,
the notion that I have my finger on any pulse at all is laughable ;)

Any suggestions?

Hugh

[PATCH 2/7] tmpfs: refine shmem_file_splice_read

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
