Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA21150
	for <linux-mm@kvack.org>; Sat, 5 Dec 1998 19:35:00 -0500
Date: Sun, 6 Dec 1998 01:34:16 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: [PATCH] VM improvements for 2.1.131
Message-ID: <Pine.LNX.3.96.981206011441.13041A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
Cc: Linux Kernel <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

this patch contains all that's needed to turn 2.1.131
into the Linux kernel with the fastest VM system the
world has ever known:

- fixes the auto balancing between buffer, cache and
  other memory by means of a vmscan.c fix and a swap.c
  adjustment (borrow percentages only are for obscely
  large amounts of swap)
- swap I/O syncing has been restored to documented behaviour
  and now again gives the possibility of increasing swap
  bandwidth by increasing pager_daemon.swap_cluster
- fixes the stats reporting for swap_cache_find_*
- swapin readahead: this is a much requested feature that
  brings a huge performance increasement to VM performance.

  The last feature is not ready however, so Linus probably
  wants to remove it (the piece concerning page_alloc.c)
  before applying the patch to his tree. Note that the patch
  _is_ completely safe and has withstood 5000+ swaps/second
  without degrading interactive performance (under X) too much.

  I will be working on a more intelligent swapin readahead
  however, so performance could become still better in the
  future. :)

regards,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--- ./mm/vmscan.c.orig	Sat Dec  5 21:59:29 1998
+++ ./mm/vmscan.c	Sun Dec  6 00:55:11 1998
@@ -432,6 +432,8 @@
 
 	if (buffer_over_borrow() || pgcache_over_borrow())
 		state = 0;
+	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster / 2)
+		shrink_mmap(i, gfp_mask);
 
 	switch (state) {
 		do {
--- ./mm/swap.c.orig	Sun Dec  6 00:55:46 1998
+++ ./mm/swap.c	Sun Dec  6 00:56:53 1998
@@ -61,14 +61,14 @@
 swapstat_t swapstats = {0};
 
 buffer_mem_t buffer_mem = {
-	5,	/* minimum percent buffer */
-	10,	/* borrow percent buffer */
+	1,	/* minimum percent buffer */
+	20,	/* borrow percent buffer */
 	60	/* maximum percent buffer */
 };
 
 buffer_mem_t page_cache = {
-	5,	/* minimum percent page cache */
-	15,	/* borrow percent page cache */
+	1,	/* minimum percent page cache */
+	30,	/* borrow percent page cache */
 	75	/* maximum */
 };
 
--- ./mm/page_io.c.orig	Sat Dec  5 21:59:08 1998
+++ ./mm/page_io.c	Sun Dec  6 00:53:36 1998
@@ -60,7 +60,7 @@
 	}
 
 	/* Don't allow too many pending pages in flight.. */
-	if (atomic_read(&nr_async_pages) > SWAP_CLUSTER_MAX)
+	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster)
 		wait = 1;
 
 	p = &swap_info[type];
--- ./mm/page_alloc.c.orig	Sat Dec  5 21:59:08 1998
+++ ./mm/page_alloc.c	Sun Dec  6 00:53:36 1998
@@ -360,6 +360,35 @@
 }
 
 /*
+ * Primitive swap readahead code. We simply read the
+ * next 16 entries in the swap area. This method is
+ * chosen because it doesn't cost us any seek time.
+ * We also make sure to queue the 'original' request
+ * together with the readahead ones...
+ */
+void swapin_readahead(unsigned long entry) {
+        int i;
+        struct page *new_page;
+	unsigned long offset = SWP_OFFSET(entry);
+	struct swap_info_struct *swapdev = SWP_TYPE(entry) + swap_info;
+
+	for (i = 0; ++i < 16;) {
+	      if (offset >= swapdev->max
+		              || nr_free_pages - atomic_read(&nr_async_pages) <
+			      (freepages.high + freepages.low)/2)
+		      return;
+	      if (!swapdev->swap_map[offset] ||
+                              test_bit(offset, swapdev->swap_lockmap))
+		      continue;
+	      new_page = read_swap_cache_async(SWP_ENTRY(SWP_TYPE(entry), offset), 0);
+	      if (new_page != NULL)
+                      __free_page(new_page);
+	      offset++;
+	}
+	return;
+}
+
+/*
  * The tests may look silly, but it essentially makes sure that
  * no other process did a swap-in on us just as we were waiting.
  *
@@ -370,9 +399,15 @@
 	pte_t * page_table, unsigned long entry, int write_access)
 {
 	unsigned long page;
-	struct page *page_map;
-	
-	page_map = read_swap_cache(entry);
+	struct page *page_map = lookup_swap_cache(entry);
+
+	if (!page_map) {
+                swapin_readahead(entry);
+	        page_map = read_swap_cache(entry);
+	} else if (nr_free_pages > freepages.high || pgcache_over_borrow() ||
+                        buffer_over_borrow()) {
+                swapin_readahead(entry);
+        }
 
 	if (pte_val(*page_table) != entry) {
 		if (page_map)
--- ./mm/swap_state.c.orig	Sat Dec  5 21:59:08 1998
+++ ./mm/swap_state.c	Sun Dec  6 00:53:36 1998
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
--- ./include/linux/swap.h.orig	Sat Dec  5 21:59:29 1998
+++ ./include/linux/swap.h	Sun Dec  6 00:53:36 1998
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
