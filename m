Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id ABA39900088
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 16:02:11 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3EJbtIU018393
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 15:37:55 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3EK1ivS2441388
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 16:01:44 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3EK1h9f019458
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 16:01:44 -0400
Subject: [PATCH 3/3] reuse __free_pages_exact() in __alloc_pages_exact()
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Thu, 14 Apr 2011 13:01:42 -0700
References: <20110414200139.ABD98551@kernel>
In-Reply-To: <20110414200139.ABD98551@kernel>
Message-Id: <20110414200141.09C3AA5F@kernel>
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
--- linux-2.6.git/mm/page_alloc.c~reuse-free-exact	2011-04-14 12:03:10.132795021 -0700
+++ linux-2.6.git-dave/mm/page_alloc.c	2011-04-14 12:03:10.144795019 -0700
@@ -2338,14 +2338,11 @@ struct page *__alloc_pages_exact(gfp_t g
 
 	page = alloc_pages(gfp_mask, order);
 	if (page) {
-		struct page *alloc_end = page + (1 << order);
-		struct page *used = page + nr_pages;
+		struct page *unused_start = page + nr_pages;
+		unsigned long nr_unused = (1 << order) - nr_pages;
 
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
