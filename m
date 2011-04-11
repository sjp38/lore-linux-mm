Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 61E7D8D0040
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 18:03:59 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3BM19u6002757
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 16:01:09 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p3BM3pcW110398
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 16:03:51 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3BM3nk3018857
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 16:03:51 -0600
Subject: [PATCH 3/3] reuse __free_pages_exact() in __alloc_pages_exact()
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Mon, 11 Apr 2011 15:03:48 -0700
References: <20110411220345.9B95067C@kernel>
In-Reply-To: <20110411220345.9B95067C@kernel>
Message-Id: <20110411220348.D0280E4D@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>


Michal Nazarewicz noticed that __alloc_pages_exact()'s
__free_page() loop was really close to something he was
using in one of his patches.   That made me realize that
it was actually very similar to __free_pages_exact().

This uses __free_pages_exact() in place of the loop
that we had in __alloc_pages_exact().  Since we had to
change the temporary variables around anyway, I gave
them some better names to hopefully address some other
review comments.

---

 linux-2.6.git-dave/mm/page_alloc.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff -puN mm/page_alloc.c~reuse-free-exact mm/page_alloc.c
--- linux-2.6.git/mm/page_alloc.c~reuse-free-exact	2011-04-11 15:01:17.701822598 -0700
+++ linux-2.6.git-dave/mm/page_alloc.c	2011-04-11 15:01:17.713822594 -0700
@@ -2338,14 +2338,11 @@ struct page *__alloc_pages_exact(gfp_t g
 
 	page = alloc_pages(gfp_mask, order);
 	if (page) {
-		struct page *alloc_end = page + (1 << order);
-		struct page *used = page + nr_pages;
+		struct page *unused_start = page + nr_pages;
+		int nr_unused = (1 << order) - nr_pages;
 
 		split_page(page, order);
-		while (used < alloc_end) {
-			__free_page(used);
-			used++;
-		}
+		__free_pages_exact(unused_start, nr_unused);
 	}
 
 	return page;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
