Received: from subspace.cistron-office.nl ([62.216.29.200])
	by smtp.cistron-office.nl with esmtp (Exim 3.35 #1 (Debian))
	id 1Cax90-0000UB-00
	for <linux-mm@kvack.org>; Sun, 05 Dec 2004 15:13:46 +0100
Received: from miquels by subspace.cistron-office.nl with local (Exim 3.35 #1 (Debian))
	id 1Cax8x-0007mR-00
	for <linux-mm@kvack.org>; Sun, 05 Dec 2004 15:13:43 +0100
Date: Sun, 5 Dec 2004 15:13:43 +0100
From: Miquel van Smoorenburg <miquels@cistron.nl>
Subject: pages not marked as accessed on non-page boundaries
Message-ID: <20041205141342.GA29174@cistron.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(Not sure if this should go to linux-kernel or linux-mm,
 I'll try the latter first)

In the current kernel (I used 2.6.9), pages read into memory
through read() are only marked as accessed if the read
started at offset 0 of the page.

When you have a database accessing small amounts of data
in an index file randomly, then most of those pages will
not be marked as read and will be thrown out too soon.

I noticed this when I was writing a patch for something else-
posix_fadvise(LINUX_FADV_STICKY) support, with which you can
ask the kernel to try to keep the pages of a file in core
a bit more aggressively than normal. I'l probably post that later.

Would it be a good thing to fix this ? Patch is below.


=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

PATCH: mark_page_accessed() for read()s on non-page boundaries

When reading a (partial) page from disk using read(), the kernel only
marks the page as "accessed" if the read started at a page boundary.
This means that files that are accessed randomly at non-page boundaries
(usually database style files) will not be cached properly.

The patch below uses the readahead state instead. If a page is read(),
it is marked as "accessed" if the previous read() was for a different
page, whatever the offset in the page.

Signed-Off-By: Miquel van Smoorenburg <miquels@cistron.nl>

diff --exclude-from=exclude -ruN linux-2.6.9-rc4-tw.ORIG/mm/filemap.c linux-2.6.9-rc4-tw/mm/filemap.c
--- linux-2.6.9-rc4.ORIG/mm/filemap.c	2004-10-23 22:21:18.000000000 +0200
+++ linux-2.6.9-rc4/mm/filemap.c	2004-10-25 12:58:26.000000000 +0200
@@ -718,6 +718,7 @@
 {
 	struct inode *inode = mapping->host;
 	unsigned long index, end_index, offset;
+	unsigned long prev_page;
 	loff_t isize;
 	struct page *cached_page;
 	int error;
@@ -748,6 +749,8 @@
 		}
 		nr = nr - offset;
 
+		prev_page = ra.next_size ? ra.prev_page : (unsigned long)-1;
+
 		cond_resched();
 		page_cache_readahead(mapping, &ra, filp, index);
 
@@ -755,10 +758,13 @@
 		page = find_get_page(mapping, index);
 		if (unlikely(page == NULL)) {
 			handle_ra_miss(mapping, &ra, index);
+			prev_page = (unsigned long)-1;
 			goto no_cached_page;
 		}
-		if (!PageUptodate(page))
+		if (!PageUptodate(page)) {
+			prev_page = (unsigned long)-1;
 			goto page_not_up_to_date;
+		}
 page_ok:
 
 		/* If users can be writing to this page using arbitrary
@@ -769,9 +775,10 @@
 			flush_dcache_page(page);
 
 		/*
-		 * Mark the page accessed if we read the beginning.
+		 * Mark the page accessed only if this was the initial
+		 * read, not for subsequential sub-page sized reads.
 		 */
-		if (!offset)
+		if (prev_page != index)
 			mark_page_accessed(page);
 
 		/*
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
