Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA11047
	for <linux-mm@kvack.org>; Tue, 14 Apr 1998 18:47:42 -0400
Date: Tue, 14 Apr 1998 23:38:50 +0200 (MET DST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: H.H.vanRiel@phys.uu.nl
Subject: [PATCH] low/high water marks in free_memory_available()
Message-ID: <Pine.LNX.3.91.980414233503.20137A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Linus,

it seems that most of the thrashing in recent kernels comes
from the fact that kswapd is busy continuously.
Adding a very simple high/low water mark should help in most
cases, since kswapd won't run all of the time and the disk
will be idle more, giving other disk processes better performance.

Also, since a value is added to (num_physpages >> 5), it
isn't shifted by 4 anymore... On large-mem machines, >>5
is enough, and on small machines the added value will make
up for the difference (I hope).

The patch below is a very rough patch against 2.1.95.

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+

--- linux/mm/page_alloc.c.orig	Tue Apr 14 23:27:23 1998
+++ linux/mm/page_alloc.c	Tue Apr 14 23:34:21 1998
@@ -134,8 +134,10 @@
 	 * It may not be, due to fragmentation, but we
 	 * don't want to keep on forever trying to find
 	 * free unfragmented memory.
+	 * Added low/high water marks so the disk will be idle
+	 * more of the time -- Rik, 14.4.98.
 	 */
-	if (nr_free_pages > num_physpages >> 4)
+	if (nr_free_pages > (num_physpages >> 5) + (NR_MEM_LISTS - nr) * SWAP_CLUSTER_MAX)
 		return nr+1;
 
 	list = free_area + NR_MEM_LISTS;
