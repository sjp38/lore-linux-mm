Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6FB8F6B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 07:55:22 -0400 (EDT)
Date: Fri, 3 Jun 2011 07:55:19 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Setting of the PageReadahed bit
Message-ID: <20110603115519.GI4061@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

The exact definition of PageReadahead doesn't seem to be documented
anywhere.  I'm assuming it means "This page was not directly requested;
it is being read for prefetching purposes", exactly like the READA
semantics.

If my interpretation is correct, then the implementation in 
__do_page_cache_readahead is wrong:

		if (page_idx == nr_to_read - lookahead_size)
			SetPageReadahead(page);

It'll only set the PageReadahead bit on one page.  The patch below fixes
this ... if my understanding is correct.

If my understanding is wrong, then how are readpage/readpages
implementations supposed to know that the VM is only prefetching these
pages, and they're not as important as metadata (dependent) reads?

commit 7b1a00ae0ecc327bab9ce467dcd7bd7fe2a31fab
Author: Matthew Wilcox <matthew.r.wilcox@intel.com>
Date:   Fri Jun 3 03:49:45 2011 -0400

    mm: Fix PageReadahead flag setting in readahead code
    
    The current code sets the PageReadahead bit on at most one page in each
    batch.  Worse, it can set the PageReadahead bit on the exact page that
    was requested.  What it should be doing is setting the PageReadahead
    bit on every page except the one which is really demanded.
    
    Passing the page offset to the __do_page_cache_readahead() function
    lets it know which page to not set the Readahead bit on.  That implies
    passing the offset into ra_submit as well.

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9670f71..3e32a17 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1480,6 +1480,7 @@ void page_cache_async_readahead(struct address_space *mapping,
 
 unsigned long max_sane_readahead(unsigned long nr);
 unsigned long ra_submit(struct file_ra_state *ra,
+			pgoff_t offset,
 			struct address_space *mapping,
 			struct file *filp);
 
diff --git a/mm/filemap.c b/mm/filemap.c
index d7b1057..1a1ab1b 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1594,7 +1594,7 @@ static void do_sync_mmap_readahead(struct vm_area_struct *vma,
 	ra->start = max_t(long, 0, offset - ra_pages / 2);
 	ra->size = ra_pages;
 	ra->async_size = ra_pages / 4;
-	ra_submit(ra, mapping, file);
+	ra_submit(ra, offset, mapping, file);
 }
 
 /*
diff --git a/mm/readahead.c b/mm/readahead.c
index 867f9dd..9202533 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -150,7 +150,7 @@ out:
 static int
 __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 			pgoff_t offset, unsigned long nr_to_read,
-			unsigned long lookahead_size)
+			pgoff_t wanted)
 {
 	struct inode *inode = mapping->host;
 	struct page *page;
@@ -185,7 +185,7 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 			break;
 		page->index = page_offset;
 		list_add(&page->lru, &page_pool);
-		if (page_idx == nr_to_read - lookahead_size)
+		if (page_offset != wanted)
 			SetPageReadahead(page);
 		ret++;
 	}
@@ -210,6 +210,7 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		pgoff_t offset, unsigned long nr_to_read)
 {
 	int ret = 0;
+	pgoff_t wanted = offset;
 
 	if (unlikely(!mapping->a_ops->readpage && !mapping->a_ops->readpages))
 		return -EINVAL;
@@ -223,7 +224,7 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		if (this_chunk > nr_to_read)
 			this_chunk = nr_to_read;
 		err = __do_page_cache_readahead(mapping, filp,
-						offset, this_chunk, 0);
+						offset, this_chunk, wanted);
 		if (err < 0) {
 			ret = err;
 			break;
@@ -248,13 +249,13 @@ unsigned long max_sane_readahead(unsigned long nr)
 /*
  * Submit IO for the read-ahead request in file_ra_state.
  */
-unsigned long ra_submit(struct file_ra_state *ra,
+unsigned long ra_submit(struct file_ra_state *ra, pgoff_t offset,
 		       struct address_space *mapping, struct file *filp)
 {
 	int actual;
 
 	actual = __do_page_cache_readahead(mapping, filp,
-					ra->start, ra->size, ra->async_size);
+					ra->start, ra->size, offset);
 
 	return actual;
 }
@@ -465,7 +466,8 @@ ondemand_readahead(struct address_space *mapping,
 	 * standalone, small random read
 	 * Read as is, and do not pollute the readahead state.
 	 */
-	return __do_page_cache_readahead(mapping, filp, offset, req_size, 0);
+	return __do_page_cache_readahead(mapping, filp, offset, req_size,
+								offset);
 
 initial_readahead:
 	ra->start = offset;
@@ -483,7 +485,7 @@ readit:
 		ra->size += ra->async_size;
 	}
 
-	return ra_submit(ra, mapping, filp);
+	return ra_submit(ra, offset, mapping, filp);
 }
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
