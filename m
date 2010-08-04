Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7728466002B
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 22:45:34 -0400 (EDT)
Message-Id: <20100804024533.630677170@linux.com>
Date: Tue, 03 Aug 2010 21:45:31 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q3 17/23] slub: Remove MAX_OBJS limitation
References: <20100804024514.139976032@linux.com>
Content-Disposition: inline; filename=unified_unlimited
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

There is no need anymore for the "inuse" field in the page struct.
Extend the objects field to 32 bit allowing a practically unlimited
number of objects.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/mm_types.h |    5 +----
 mm/slub.c                |    7 -------
 2 files changed, 1 insertion(+), 11 deletions(-)

Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h	2010-07-30 18:37:56.171016883 -0500
+++ linux-2.6/include/linux/mm_types.h	2010-07-30 18:45:28.624439565 -0500
@@ -40,10 +40,7 @@
 					 * to show when page is mapped
 					 * & limit reverse map searches.
 					 */
-		struct {		/* SLUB */
-			u16 inuse;
-			u16 objects;
-		};
+		u32 objects;		/* SLUB */
 	};
 	union {
 	    struct {
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-07-30 18:45:24.248349179 -0500
+++ linux-2.6/mm/slub.c	2010-07-30 18:45:28.628439648 -0500
@@ -144,7 +144,6 @@
 
 #define OO_SHIFT	16
 #define OO_MASK		((1 << OO_SHIFT) - 1)
-#define MAX_OBJS_PER_PAGE	65535 /* since page.objects is u16 */
 
 /* Internal SLUB flags */
 #define __OBJECT_POISON		0x80000000UL /* Poison object */
@@ -791,9 +790,6 @@
 			max_objects = ((void *)page->freelist - start) / s->size;
 	}
 
-	if (max_objects > MAX_OBJS_PER_PAGE)
-		max_objects = MAX_OBJS_PER_PAGE;
-
 	if (page->objects != max_objects) {
 		slab_err(s, page, "Wrong number of objects. Found %d but "
 			"should be %d", page->objects, max_objects);
@@ -2060,9 +2056,6 @@
 	int rem;
 	int min_order = slub_min_order;
 
-	if ((PAGE_SIZE << min_order) / size > MAX_OBJS_PER_PAGE)
-		return get_order(size * MAX_OBJS_PER_PAGE) - 1;
-
 	for (order = max(min_order,
 				fls(min_objects * size - 1) - PAGE_SHIFT);
 			order <= max_order; order++) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
