Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA03916
	for <linux-mm@kvack.org>; Thu, 26 Nov 1998 19:00:49 -0500
Received: from mirkwood.dummy.home (root@anx1p7.phys.uu.nl [131.211.33.96])
	by max.phys.uu.nl (8.8.7/8.8.7/hjm) with ESMTP id BAA22165
	for <linux-mm@kvack.org>; Fri, 27 Nov 1998 01:00:45 +0100 (MET)
Received: from localhost (riel@localhost) by mirkwood.dummy.home (8.9.0/8.8.3) with SMTP id AAA00557 for <linux-mm@kvack.org>; Fri, 27 Nov 1998 00:23:35 +0100
Date: Fri, 27 Nov 1998 00:23:33 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: [PATCH] swapin readahead
Message-ID: <Pine.LNX.3.96.981127001214.445A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

here is a very first primitive version of as swapin
readahead patch. It seems to give much increased
throughput to swap and the desktop switch time has
decreased noticably.

The checks are all needed. The first two checks are there
to avoid annoying messages from swap_state.c :)) The third
check is to make sure we always keep at least as much
swapout bandwidth as swapin bandwidth. We need that to keep
the system alive under heavy circumstances.

I am now testing the patch quite heavily (200+ swap IOs/second)
without any errors showing up in my xconsole, so I guess that
means you can have fun too :)

cheers,

Rik -- now completely used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--- mm/page_alloc.c.orig	Thu Nov 26 11:26:49 1998
+++ mm/page_alloc.c	Thu Nov 26 23:48:42 1998
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
+				|| atomic_read(&nr_async_pages) >
+				pager_daemon.swap_cluster / 2)
+			break;
+		read_swap_cache_async(SWP_ENTRY(SWP_TYPE(entry), offset),
+0);
+			break;
+	}
 
 	if (pte_val(*page_table) != entry) {
 		if (page_map)
--- mm/page_io.c.orig	Thu Nov 26 11:26:49 1998
+++ mm/page_io.c	Thu Nov 26 11:30:43 1998
@@ -60,7 +60,7 @@
 	}
 
 	/* Don't allow too many pending pages in flight.. */
-	if (atomic_read(&nr_async_pages) > SWAP_CLUSTER_MAX)
+	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster)
 		wait = 1;
 
 	p = &swap_info[type];

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
