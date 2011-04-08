Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 41F7C8D0040
	for <linux-mm@kvack.org>; Fri,  8 Apr 2011 16:23:00 -0400 (EDT)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p38K22Tt023912
	for <linux-mm@kvack.org>; Fri, 8 Apr 2011 16:02:02 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 44F4E38C8039
	for <linux-mm@kvack.org>; Fri,  8 Apr 2011 16:22:49 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p38KMuPJ2203732
	for <linux-mm@kvack.org>; Fri, 8 Apr 2011 16:22:56 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p38KMueT005527
	for <linux-mm@kvack.org>; Fri, 8 Apr 2011 16:22:56 -0400
Subject: [PATCH 2/2] print vmalloc() state after allocation failures
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Fri, 08 Apr 2011 13:22:55 -0700
References: <20110408202253.6D6D231C@kernel>
In-Reply-To: <20110408202253.6D6D231C@kernel>
Message-Id: <20110408202255.9EE67DC9@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@linux.vnet.ibm.com>


I was tracking down a page allocation failure that ended up in vmalloc().
Since vmalloc() uses 0-order pages, if somebody asks for an insane amount
of memory, we'll still get a warning with "order:0" in it.  That's not
very useful.

During recovery, vmalloc() also nicely frees all of the memory that it
got up to the point of the failure.  That is wonderful, but it also
quickly hides any issues.  We have a much different sitation if vmalloc()
repeatedly fails 10GB in to:

	vmalloc(100 * 1<<30);

versus repeatedly failing 4096 bytes in to a:

	vmalloc(8192);

This patch will print out messages that look like this:

[   30.040774] bash: vmalloc failure allocating after 0 / 73728 bytes

As a side issue, I also noticed that ctl_ioctl() does vmalloc() based
solely on an unverified value passed in from userspace.  Granted, it's
under CAP_SYS_ADMIN, but it still frightens me a bit.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/mm/vmalloc.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff -puN mm/vmalloc.c~vmalloc-warn mm/vmalloc.c
--- linux-2.6.git/mm/vmalloc.c~vmalloc-warn	2011-04-08 09:36:05.877020199 -0700
+++ linux-2.6.git-dave/mm/vmalloc.c	2011-04-08 09:38:00.373093593 -0700
@@ -1534,6 +1534,7 @@ static void *__vmalloc_node(unsigned lon
 static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 				 pgprot_t prot, int node, void *caller)
 {
+	int order = 0;
 	struct page **pages;
 	unsigned int nr_pages, array_size, i;
 	gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
@@ -1560,11 +1561,12 @@ static void *__vmalloc_area_node(struct 
 
 	for (i = 0; i < area->nr_pages; i++) {
 		struct page *page;
+		gfp_t tmp_mask = gfp_mask | __GFP_NOWARN;
 
 		if (node < 0)
-			page = alloc_page(gfp_mask);
+			page = alloc_page(tmp_mask);
 		else
-			page = alloc_pages_node(node, gfp_mask, 0);
+			page = alloc_pages_node(node, tmp_mask, order);
 
 		if (unlikely(!page)) {
 			/* Successfully allocated i pages, free them in __vunmap() */
@@ -1579,6 +1581,9 @@ static void *__vmalloc_area_node(struct 
 	return area->addr;
 
 fail:
+	nopage_warning(gfp_mask, order, "vmalloc: allocation failure, "
+			"allocated %ld of %ld bytes\n",
+			(area->nr_pages*PAGE_SIZE), area->size);
 	vfree(area->addr);
 	return NULL;
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
