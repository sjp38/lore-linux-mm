Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA22405
	for <linux-mm@kvack.org>; Tue, 1 Dec 1998 01:00:56 -0500
Date: Tue, 1 Dec 1998 00:11:18 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [2.1.130-3] Page cache DEFINATELY too persistant... feature?
In-Reply-To: <87sof0ke9w.fsf@atlas.CARNet.hr>
Message-ID: <Pine.LNX.3.96.981201000736.781B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 30 Nov 1998, Zlatko Calusic wrote:
> Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:
> 
> > I am now trying:
> > 	if (buffer_over_borrow() || pgcache_over_borrow() ||
> > 			atomic_read(&nr_async_pages)
> > 		shrink_mmap(i, gfp_mask);
> 
> This still slows down swapping somewhat (20-30%) in my tests.

I changed it in the next version of the patch (attached).
There are also a few swapin readahead and kswapd fixes in
it.

> > Note that I'm running with my experimentas swapin readahead
> > patch enabled so the system should be stressed even more
> > than normally :)
> 
> I tried your swapin_readahead patch but it didn't work right:
> 
> swap_duplicate at c012054b: entry 00011904, unused page 

I get those too, but I don't know why since I use the same
test to decide whether or not to call read_swap_cache_async()
or not...

> Memory gets eaten when I bang MM, and after sometime system blocks.
> I also had one FS corruption, thanks to that. Didn't investigate
> further. 

The system blockage was most likely caused by swapping in
stuff while we were tight on memory. This should be fixed
now.

have fun,

Rik -- now completely used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--- linux/mm/page_alloc.c.orig	Thu Nov 26 11:26:49 1998
+++ linux/mm/page_alloc.c	Mon Nov 30 23:14:16 1998
@@ -370,9 +370,28 @@
 	pte_t * page_table, unsigned long entry, int write_access)
 {
 	unsigned long page;
+	int i;
 	struct page *page_map;
+	unsigned long offset = SWP_OFFSET(entry);
+	struct swap_info_struct *swapdev = SWP_TYPE(entry) + swap_info;
 	
 	page_map = read_swap_cache(entry);
+
+	/*
+	 * Primitive swap readahead code. We simply read the
+	 * next 16 entries in the swap area. The break below
+	 * is needed or else the request queue will explode :)
+	 */
+	for (i = 1; i++ < 16;) {
+		offset++;
+		if (!swapdev->swap_map[offset] || offset >= swapdev->max
+			|| nr_free_pages - atomic_read(&nr_async_pages) <
+				(freepages.high + freepages.low)/2)
+			break;
+		read_swap_cache_async(SWP_ENTRY(SWP_TYPE(entry), offset),
+0);
+			break;
+	}
 
 	if (pte_val(*page_table) != entry) {
 		if (page_map)
--- linux/mm/page_io.c.orig	Thu Nov 26 11:26:49 1998
+++ linux/mm/page_io.c	Thu Nov 26 11:30:43 1998
@@ -60,7 +60,7 @@
 	}
 
 	/* Don't allow too many pending pages in flight.. */
-	if (atomic_read(&nr_async_pages) > SWAP_CLUSTER_MAX)
+	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster)
 		wait = 1;
 
 	p = &swap_info[type];
--- linux/mm/vmscan.c.orig	Thu Nov 26 11:26:50 1998
+++ linux/mm/vmscan.c	Mon Nov 30 23:11:09 1998
@@ -430,7 +430,9 @@
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
 
-	if (buffer_over_borrow() || pgcache_over_borrow())
+	if (buffer_over_borrow() || pgcache_over_borrow() ||
+			atomic_read(&nr_async_pages) > 
+			(pager_daemon.swap_cluster * 3) / 4)
 		shrink_mmap(i, gfp_mask);
 
 	switch (state) {

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
