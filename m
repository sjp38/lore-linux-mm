Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA22842
	for <linux-mm@kvack.org>; Tue, 1 Dec 1998 02:24:52 -0500
Received: from localhost (riel@localhost) by mirkwood.dummy.home (8.9.0/8.8.3) with SMTP id HAA00532 for <linux-mm@kvack.org>; Tue, 1 Dec 1998 07:55:48 +0100
Date: Tue, 1 Dec 1998 07:55:46 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: [PATCH] swapin readahead v3 + kswapd fixes
Message-ID: <Pine.LNX.3.96.981201075322.509A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
Cc: Linus Torvalds <torvalds@transmeta.com>, Linux-Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

I just created a third version of my swapin readahead patch.

It has all sorts of other kswapd fixes too, so you should
probably take a look even when you aren't interested in
swapin readahead at all. I'd really like your opinions on
this...

cheers,

Rik -- now completely used to dvorak kbd layout...
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
+++ ./mm/page_alloc.c	Tue Dec  1 07:25:51 1998
@@ -370,9 +370,30 @@
 	pte_t * page_table, unsigned long entry, int write_access)
 {
 	unsigned long page;
-	struct page *page_map;
-	
-	page_map = read_swap_cache(entry);
+	int i;
+	struct page *page_map = lookup_swap_cache(entry);
+	unsigned long offset = SWP_OFFSET(entry);
+	struct swap_info_struct *swapdev = SWP_TYPE(entry) + swap_info;
+
+	if (!page_map) {	
+	  page_map = read_swap_cache(entry);
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
+		read_swap_cache_async(SWP_ENTRY(SWP_TYPE(entry), offset),
+0);
+			break;
+	  }
+	}
 
 	if (pte_val(*page_table) != entry) {
 		if (page_map)
--- ./mm/swap_state.c.orig	Thu Nov 26 11:26:49 1998
+++ ./mm/swap_state.c	Tue Dec  1 07:33:31 1998
@@ -258,7 +258,7 @@
  * incremented.
  */
 
-static struct page * lookup_swap_cache(unsigned long entry)
+struct page * lookup_swap_cache(unsigned long entry)
 {
 	struct page *found;
 	
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
