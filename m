Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA06566
	for <linux-mm@kvack.org>; Thu, 3 Dec 1998 12:58:39 -0500
Date: Thu, 3 Dec 1998 18:56:34 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: [PATCH] swapin readahead and fixes
Message-ID: <Pine.LNX.3.96.981203184928.2886A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
Cc: Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

here is a patch (against 2.1.130, but vs. 2.1.131 should
be trivial) that improves the swapping performance both
during swapout and swapin and contains a few minor fixes.

The swapout enhancement is in the fact that now kswapd
tries to free memory when it has a few swapout requests
pending in order to avoid a swapout frenzy -- and also
without avoiding too much pressure on the caches.

The swapin enhancement consists of a simple swapin readahead.
I have extensively tortured this version of the patch and it
should survive the most extreme things now. It is only a
primitive readahead thingy and can probably be improved
quite a lot; that, however, is something to do later when
it is proven stable and the bugfix parts are included in
the kernel.

Future versions of this (and other) patches can be grabbed
from http://linux-patches.rock-projects.com/ or from my
home page...     <hint> check out Linux-patches! </hint>

regards,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--- ./mm/vmscan.c.orig	Thu Nov 26 11:26:50 1998
+++ ./mm/vmscan.c	Tue Dec  1 07:12:28 1998
@@ -431,6 +431,8 @@
 	kmem_cache_reap(gfp_mask);
 
 	if (buffer_over_borrow() || pgcache_over_borrow())
+		state = 0;		
+	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster / 2)
 		shrink_mmap(i, gfp_mask);
 
 	switch (state) {
--- ./mm/page_io.c.orig	Thu Nov 26 11:26:49 1998
+++ ./mm/page_io.c	Thu Nov 26 11:30:43 1998
@@ -60,7 +60,7 @@
 	}
 
 	/* Don't allow too many pending pages in flight.. */
-	if (atomic_read(&nr_async_pages) > SWAP_CLUSTER_MAX)
+	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster)
 		wait = 1;
 
 	p = &swap_info[type];
--- ./mm/page_alloc.c.orig	Thu Nov 26 11:26:49 1998
+++ ./mm/page_alloc.c	Thu Dec  3 15:40:48 1998
@@ -370,9 +370,32 @@
 	pte_t * page_table, unsigned long entry, int write_access)
 {
 	unsigned long page;
-	struct page *page_map;
-	
+	int i;
+	struct page *new_page, *page_map = lookup_swap_cache(entry);
+	unsigned long offset = SWP_OFFSET(entry);
+	struct swap_info_struct *swapdev = SWP_TYPE(entry) + swap_info;
+
+	if (!page_map) {	
 	page_map = read_swap_cache(entry);
+
+	/*
+	 * Primitive swap readahead code. We simply read the
+	 * next 16 entries in the swap area. The break below
+	 * is needed or else the request queue will explode :)
+	 */
+	  for (i = 1; i++ < 16;) {
+		offset++;
+		if (!swapdev->swap_map[offset] || offset >= swapdev->max
+			|| nr_free_pages - atomic_read(&nr_async_pages) <
+				(freepages.high + freepages.low)/2)
+			break;
+		if (test_bit(offset, swapdev->swap_lockmap))
+			continue;
+		new_page = read_swap_cache_async(SWP_ENTRY(SWP_TYPE(entry), offset), 0);
+		if (new_page != NULL)
+			__free_page(new_page);
+	  }
+	}
 
 	if (pte_val(*page_table) != entry) {
 		if (page_map)
--- ./mm/swap_state.c.orig	Thu Nov 26 11:26:49 1998
+++ ./mm/swap_state.c	Thu Dec  3 15:40:34 1998
@@ -258,9 +258,10 @@
  * incremented.
  */
 
-static struct page * lookup_swap_cache(unsigned long entry)
+struct page * lookup_swap_cache(unsigned long entry)
 {
 	struct page *found;
+	swap_cache_find_total++;
 	
 	while (1) {
 		found = find_page(&swapper_inode, entry);
@@ -268,8 +269,10 @@
 			return 0;
 		if (found->inode != &swapper_inode || !PageSwapCache(found))
 			goto out_bad;
-		if (!PageLocked(found))
+		if (!PageLocked(found)) {
+			swap_cache_find_success++;
 			return found;
+		}
 		__free_page(found);
 		__wait_on_page(found);
 	}
--- ./include/linux/swap.h.orig	Tue Dec  1 07:29:56 1998
+++ ./include/linux/swap.h	Tue Dec  1 07:31:03 1998
@@ -90,6 +90,7 @@
 extern struct page * read_swap_cache_async(unsigned long, int);
 #define read_swap_cache(entry) read_swap_cache_async(entry, 1);
 extern int FASTCALL(swap_count(unsigned long));
+extern struct page * lookup_swap_cache(unsigned long); 
 /*
  * Make these inline later once they are working properly.
  */

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
