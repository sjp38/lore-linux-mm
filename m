Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA04327
	for <linux-mm@kvack.org>; Thu, 3 Dec 1998 05:40:12 -0500
Received: from mirkwood.dummy.home (root@anx1p8.phys.uu.nl [131.211.33.97])
	by max.phys.uu.nl (8.8.7/8.8.7/hjm) with ESMTP id LAA02642
	for <linux-mm@kvack.org>; Thu, 3 Dec 1998 11:39:23 +0100 (MET)
Received: from localhost (riel@localhost) by mirkwood.dummy.home (8.9.0/8.8.3) with SMTP id LAA05367 for <linux-mm@kvack.org>; Thu, 3 Dec 1998 11:21:31 +0100
Date: Thu, 3 Dec 1998 11:21:30 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: [PATCH] swapin readahead v4
Message-ID: <Pine.LNX.3.96.981203111953.4894B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

Stephen's messages gave away the clue to something I was just
about to track down myself. Anyway, here is the 4th version of
my swapin readahead patch.

cheers,

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
+++ ./mm/page_alloc.c	Tue Dec  1 18:11:22 1998
@@ -370,9 +370,32 @@
 	pte_t * page_table, unsigned long entry, int write_access)
 {
 	unsigned long page;
-	struct page *page_map;
-	
+	int i;
+	struct page *page_map = lookup_swap_cache(entry);
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
+		read_swap_cache_async(SWP_ENTRY(SWP_TYPE(entry), offset),
+0);
+			break;
+	  }
+	} else {
+	  page_map = read_swap_cache(entry);
+	}
 
 	if (pte_val(*page_table) != entry) {
 		if (page_map)
--- ./mm/swap_state.c.orig	Thu Nov 26 11:26:49 1998
+++ ./mm/swap_state.c	Thu Dec  3 11:11:31 1998
@@ -258,7 +258,7 @@
  * incremented.
  */
 
-static struct page * lookup_swap_cache(unsigned long entry)
+struct page * lookup_swap_cache(unsigned long entry)
 {
 	struct page *found;
 	
@@ -329,6 +329,8 @@
 
 	set_bit(PG_locked, &new_page->flags);
 	rw_swap_page(READ, entry, (char *) new_page_addr, wait);
+	if (!wait)
+		__free_page(new_page);
 #ifdef DEBUG_SWAP
 	printk("DebugVM: read_swap_cache_async created "
 	       "entry %08lx at %p\n",
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
