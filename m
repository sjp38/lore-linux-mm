Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3CA5C6B005D
	for <linux-mm@kvack.org>; Fri, 29 May 2009 17:35:24 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <200905291135.124267638@firstfloor.org>
In-Reply-To: <200905291135.124267638@firstfloor.org>
Subject: [PATCH] [12/16] HWPOISON: check and isolate corrupted free pages
Message-Id: <20090529213538.318C61D0295@basil.firstfloor.org>
Date: Fri, 29 May 2009 23:35:38 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.orgfengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>


From: Wu Fengguang <fengguang.wu@intel.com>

If memory corruption hits the free buddy pages, we can safely ignore them.
No one will access them until page allocation time, then prep_new_page()
will automatically check and isolate PG_hwpoison page for us (for 0-order
allocation).

This patch expands prep_new_page() to check every component page in a high
order page allocation, in order to completely stop PG_hwpoison pages from
being recirculated.

Note that the common case -- only allocating a single page, doesn't
do any more work than before. Allocating > order 0 does a bit more work,
but that's relatively uncommon.

This simple implementation may drop some innocent neighbor pages, hopefully
it is not a big problem because the event should be rare enough.

This patch adds some runtime costs to high order page users.

[AK: Improved description]
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/page_alloc.c |   22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c	2009-05-29 23:32:08.000000000 +0200
+++ linux/mm/page_alloc.c	2009-05-29 23:32:11.000000000 +0200
@@ -633,12 +633,22 @@
  */
 static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
 {
-	if (unlikely(page_mapcount(page) |
-		(page->mapping != NULL)  |
-		(page_count(page) != 0)  |
-		(page->flags & PAGE_FLAGS_CHECK_AT_PREP))) {
-		bad_page(page);
-		return 1;
+	int i;
+
+	for (i = 0; i < (1 << order); i++) {
+		struct page *p = page + i;
+
+		if (unlikely(page_mapcount(p) |
+			(p->mapping != NULL)  |
+			(page_count(p) != 0)  |
+			(p->flags & PAGE_FLAGS_CHECK_AT_PREP))) {
+			/*
+			 * The whole array of pages will be dropped,
+			 * hopefully this is a rare and abnormal event.
+			 */
+			bad_page(p);
+			return 1;
+		}
 	}
 
 	set_page_private(page, 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
