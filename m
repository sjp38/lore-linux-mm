Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 558786B0074
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 14:21:56 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 21 Nov 2012 14:21:54 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 973536E8047
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 14:21:52 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qALJLqfQ343842
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 14:21:52 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qALJLqro007464
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 12:21:52 -0700
Subject: [PATCH] [3.7-rc] fix incorrect NR_FREE_PAGES accounting (appears like memory leak)
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Wed, 21 Nov 2012 14:21:51 -0500
Message-Id: <20121121192151.3FFE0A9A@kernel.stglabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>


This needs to make it in before 3.7 is released.

--

There have been some 3.7-rc reports of vm issues, including some
kswapd bugs and, more importantly, some memory "leaks":

	http://www.spinics.net/lists/linux-mm/msg46187.html
	https://bugzilla.kernel.org/show_bug.cgi?id=50181

The post-3.6 commit 1fb3f8ca took split_free_page() and reused
it for the compaction code.  It does something curious with
capture_free_page() (previously known as split_free_page()):

int capture_free_page(struct page *page, int alloc_order,
...
        __mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));

-       /* Split into individual pages */
-       set_page_refcounted(page);
-       split_page(page, order);
+       if (alloc_order != order)
+               expand(zone, page, alloc_order, order,
+                       &zone->free_area[order], migratetype);

Note that expand() puts the pages _back_ in the allocator, but it
does not bump NR_FREE_PAGES.  We "return" 'alloc_order' worth of
pages, but we accounted for removing 'order' in the
__mod_zone_page_state() call.  For the old split_page()-style use
(order==alloc_order) the bug will not trigger.  But, when called
from the compaction code where we occasionally get a larger page
out of the buddy allocator than we need, we will run in to this.

This patch simply changes the NR_FREE_PAGES manipulation to the
correct 'alloc_order' instead of 'order'.

I've been able to repeatedly trigger this in my testing
environment.  The amount "leaked" very closely tracks the
imbalance I see in buddy pages vs. NR_FREE_PAGES.  I have
confirmed that this patch fixes the imbalance

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
Acked-by: Mel Gorman <mgorman@suse.de>
---

 linux-2.6.git-dave/mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN mm/page_alloc.c~leak-fix-20121120-2 mm/page_alloc.c
--- linux-2.6.git/mm/page_alloc.c~leak-fix-20121120-2	2012-11-21 14:14:52.053714749 -0500
+++ linux-2.6.git-dave/mm/page_alloc.c	2012-11-21 14:14:52.069714883 -0500
@@ -1405,7 +1405,7 @@ int capture_free_page(struct page *page,
 
 	mt = get_pageblock_migratetype(page);
 	if (unlikely(mt != MIGRATE_ISOLATE))
-		__mod_zone_freepage_state(zone, -(1UL << order), mt);
+		__mod_zone_freepage_state(zone, -(1UL << alloc_order), mt);
 
 	if (alloc_order != order)
 		expand(zone, page, alloc_order, order,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
