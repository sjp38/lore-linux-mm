Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA26393
	for <linux-mm@kvack.org>; Wed, 7 Apr 1999 08:32:49 -0400
Date: Wed, 7 Apr 1999 13:28:33 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: [patch] only-one-cache-query [was Re: [patch] arca-vm-2.2.5]
In-Reply-To: <Pine.LNX.4.05.9904051723490.507-100000@laser.random>
Message-ID: <Pine.LNX.4.05.9904070243310.222-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mark Hemment <markhe@sco.COM>, Chuck Lever <cel@monkey.org>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 5 Apr 1999, Andrea Arcangeli wrote:

>>  This does double the size of the page-hash, and would require profiling
>>to determine if it is worthwhile.
>
>I don't think it's worthwhile simply because most of the time you'll have
>only to pass as _worse_ one or two chains of the hash entry. And passing
>one or two chains will be far more ligther than the new mechanism.

Last night I had a new idea on how to cleanly and trivially avoid the two
cache query. We only need to know if we slept or not in GFP. We don't ever
need to think if some pages are been added to our hash bucket. It's far
simpler and the real-world case will perform better (yes while swapping
out heavily we'll lose a bit of performances, but when we are I/O bound an
additional query on the cache won't harm at all, and due the simpler
desing we'll get more performances and memory for all the good not
swapping time). And last but not the least: it will work without changes
even if the page-cache will change it's internal structure ;)).

Changing GFP is not an option (it would add overhead to the normal case
when we are not interested about such info), so I had the idea of adding a
gfp_sleeping_cookie increased every time GFP _may_ sleeps. It will add
zero overhead but it will let us know if we _may_ have slept or not.

I am running the code while writing this and I'll release very soon a
2.2.5_arca8.bz2 with this new improvement included.

Here it is the diff against clean 2.2.5:

Index: fs/dcache.c
===================================================================
RCS file: /var/cvs/linux/fs/dcache.c,v
retrieving revision 1.1.1.6
diff -u -r1.1.1.6 dcache.c
--- dcache.c	1999/03/24 00:47:09	1.1.1.6
+++ linux/fs/dcache.c	1999/04/07 01:12:46
@@ -285,6 +285,7 @@
  */
 void prune_dcache(int count)
 {
+	gfp_sleeping_cookie++;
 	for (;;) {
 		struct dentry *dentry;
 		struct list_head *tmp = dentry_unused.prev;
Index: include/linux/mm.h
===================================================================
RCS file: /var/cvs/linux/include/linux/mm.h,v
retrieving revision 1.1.1.4
diff -u -r1.1.1.4 mm.h
--- mm.h	1999/03/09 00:55:28	1.1.1.4
+++ linux/include/linux/mm.h	1999/04/07 01:11:43
@@ -259,6 +259,9 @@
 #define __get_dma_pages(gfp_mask, order) __get_free_pages((gfp_mask) | GFP_DMA,(order))
 extern unsigned long FASTCALL(__get_free_pages(int gfp_mask, unsigned long gfp_order));
 
+/* automagically increase the gfp-cookie if GFP slept -arca */
+extern int gfp_sleeping_cookie;
+
 extern inline unsigned long get_free_page(int gfp_mask)
 {
 	unsigned long page;
Index: ipc/shm.c
===============================================================ile: /var/cvs/linux/ipc/shm.c,v
retrieving revision 1.1.1.1
diff -u -r1.1.1.1 shm.c
--- shm.c	1999/01/18 01:27:58	1.1.1.1
+++ linux/ipc/shm.c	1999/04/07 01:11:43
@@ -800,6 +800,7 @@
 	if (atomic_read(&mem_map[MAP_NR(pte_page(page))].count) != 1)
 		goto check_table;
 	shp->shm_pages[idx] = swap_nr;
+	gfp_sleeping_cookie++;
 	rw_swap_page_nocache (WRITE, swap_nr, (char *) pte_page(page));
 	free_page(pte_page(page));
 	swap_successes++;
Index: mm/filemap.c
===================================================================
RCS file: /var/cvs/linux/mm/filemap.c,v
retrieving revision 1.1.1.8
diff -u -r1.1.1.8 filemap.c
--- filemap.c	1999/03/24 00:53:22	1.1.1.8
+++ linux/mm/filemap.c	1999/04/07 01:11:43
@@ -272,16 +272,29 @@
 	struct page ** hash;
 
 	offset &= PAGE_MASK;
+	if (offset >= inode->i_size)
+		goto out;
+
+	hash = page_hash(inode, offset);
+	page = __find_page(inode, offset, *hash);
+
+	if (page)
+	{
+		/* fast path -arca */
+		release_page(page);
+		return page_cache;
+	}
+
 	switch (page_cache) {
+		int gfp_cookie;
 	case 0:
+		gfp_cookie = gfp_sleeping_cookie;
 		page_cache = __get_free_page(GFP_USER);
 		if (!page_cache)
 			break;
+		if (gfp_cookie != gfp_sleeping_cookie)
+			page = __find_page(inode, offset, *hash);
 	default:
-		if (offset >= inode->i_size)
-			break;
-		hash = page_hash(inode, offset);
-		page = __find_page(inode, offset, *hash);
 		if (!page) {
 			/*
 			 * Ok, add the new page to the hash-queues...
@@ -293,6 +306,7 @@
 		}
 		release_page(page);
 	}
+ out:
 	return page_cache;
 }
 
@@ -586,6 +600,7 @@
 	size_t pos, pgpos, page_cache;
 	int reada_ok;
 	int max_readahead = get_max_readahead(inode);
+	struct page **hash;
 
 	page_cache = 0;
 
@@ -630,8 +645,9 @@
 			filp->f_ramax = max_readahead;
 	}
 
+	hash = page_hash(inode, pos & PAGE_MASK);
 	for (;;) {
-		struct page *page, **hash;
+		struct page *page;
 
 		if (pos >= inode->i_size)
 			break;
@@ -639,7 +655,6 @@
 		/*
 		 * Try to find the data in the page cache..
 		 */
-		hash = page_hash(inode, pos & PAGE_MASK);
 		page = __find_page(inode, pos & PAGE_MASK, *hash);
 		if (!page)
 			goto no_cached_page;
@@ -696,15 +711,19 @@
 		 * page..
 		 */
 		if (!page_cache) {
+			int gfp_cookie = gfp_sleeping_cookie;
 			page_cache = __get_free_page(GFP_USER);
-			/*
-			 * That could have slept, so go around to the
-			 * very beginning..
-			 */
-			if (page_cache)
+			if (!page_cache)
+			{
+				desc->error = -ENOMEM;
+				break;
+			}
+			if (gfp_cookie != gfp_sleeping_cookie)
+				/*
+				 * We slept, so go around to the
+				 * very beginning..
+				 */
 				continue;
-			desc->error = -ENOMEM;
-			break;
 		}
 
 		/*
@@ -941,6 +960,7 @@
 	unsigned long offset, reada, i;
 	struct page * page, **hash;
 	unsigned long old_page, new_page;
+	int gfp_cookie;
 
 	new_page = 0;
 	offset = (address & PAGE_MASK) - area->vm_start + area->vm_offset;
@@ -999,18 +1019,8 @@
 	return new_page;
 
 no_cached_page:
-	/*
-	 * Try to read in an entire cluster at once.
-	 */
-	reada   = offset;
-	reada >>= PAGE_SHIFT + page_cluster;
-	reada <<= PAGE_SHIFT + page_cluster;
-
-	for (i = 1 << page_cluster; i > 0; --i, reada += PAGE_SIZE)
-		new_page = try_to_read_ahead(file, reada, new_page);
-
-	if (!new_page)
-		new_page = __get_free_page(GFP_USER);
+	gfp_cookie = gfp_sleeping_cookie;
+	new_page = __get_free_page(GFP_USER);
 	if (!new_page)
 		goto no_page;
 
@@ -1020,19 +1030,29 @@
 	 * cache.. The page we just got may be useful if we
 	 * can't share, so don't get rid of it here.
 	 */
-	page = find_page(inode, offset);
-	if (page)
-		goto found_page;
+	if (gfp_cookie == gfp_sleeping_cookie ||
+	    !(page = __find_page(inode, offset, *hash)))
+	{
+		/*
+		 * Now, create a new page-cache page from the page we got
+		 */
+		page = mem_map + MAP_NR(new_page);
+		new_page = 0;
+		add_to_page_cache(page, inode, offset, hash);
 
+		if (inode->i_op->readpage(file, page) != 0)
+			goto failure;
+	}
+
 	/*
-	 * Now, create a new page-cache page from the page we got
+	 * Try to read in an entire cluster at once.
 	 */
-	page = mem_map + MAP_NR(new_page);
-	new_page = 0;
-	add_to_page_cache(page, inode, offset, hash);
+	reada   = offset;
+	reada >>= PAGE_SHIFT + page_cluster;
+	reada <<= PAGE_SHIFT + page_cluster;
 
-	if (inode->i_op->readpage(file, page) != 0)
-		goto failure;
+	for (i = 1 << page_cluster; i > 0; --i, reada += PAGE_SIZE)
+		new_page = try_to_read_ahead(file, reada, new_page);
 
 	goto found_page;
 
Index: mm/swap_state.c
===================================================================
RCS file: /var/cvs/linux/mm/swap_state.c,v
retrieving revision 1.1.1.1
diff -u -r1.1.1.1 swap_state.c
--- swap_state.c	1999/01/18 01:27:02	1.1.1.1
+++ linux/mm/swap_state.c	1999/04/07 01:11:43
@@ -285,6 +285,7 @@
 {
 	struct page *found_page = 0, *new_page;
 	unsigned long new_page_addr;
+	int gfp_cookie;
 	
 #ifdef DEBUG_SWAP
 	printk("DebugVM: read_swap_cache_async entry %08lx%s\n",
@@ -302,6 +303,7 @@
 	if (found_page)
 		goto out_free_swap;
 
+	gfp_cookie = gfp_sleeping_cookie;
 	new_page_addr = __get_free_page(GFP_USER);
 	if (!new_page_addr)
 		goto out_free_swap;	/* Out of memory */
@@ -310,8 +312,8 @@
 	/*
 	 * Check the swap cache again, in case we stalled above.
 	 */
-	found_page = lookup_swap_cache(entry);
-	if (found_page)
+	if (gfp_cookie != gfp_sleeping_cookie &&
+	    (found_page = lookup_swap_cache(entry)))
 		goto out_free_page;
 	/* 
 	 * Add it to the swap cache and read its contents.
Index: mm/vmscan.c
===================================================================
RCS file: /var/cvs/linux/mm/vmscan.c,v
retrieving revision 1.1.1.5
diff -u -r1.1.1.5 vmscan.c
--- vmscan.c	1999/02/06 13:22:09	1.1.1.5
+++ linux/mm/vmscan.c	1999/04/07 01:11:43
@@ -20,6 +20,8 @@
 
 #include <asm/pgtable.h>
 
+int gfp_sleeping_cookie;
+
 /*
  * The swap-out functions return 1 if they successfully
  * threw something out, and we got a free page. It returns
@@ -106,6 +108,8 @@
 	 */
 	if (!(gfp_mask & __GFP_IO))
 		return 0;
+
+	gfp_sleeping_cookie++;
 
 	/*
 	 * Ok, it's really dirty. That means that


I would ask Chuck to bench this my new code (it should be an obvious
improvement).

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
