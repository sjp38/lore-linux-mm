Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DEE786B01F4
	for <linux-mm@kvack.org>; Fri, 14 May 2010 14:43:08 -0400 (EDT)
Message-Id: <20100514183947.245341215@quilx.com>
References: <20100514183908.118952419@quilx.com>
Date: Fri, 14 May 2010 13:39:17 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC SLEB 09/10] SLEB: Remove MAX_OBJS limitation
Content-Disposition: inline; filename=sled_unlimited_objects
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

There is no need anymore for the inuse field. Extend the objects field
to 32 bit allowing a practically unlimited number of objects.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/mm_types.h |    5 +----
 mm/slub.c                |    7 -------
 2 files changed, 1 insertion(+), 11 deletions(-)

Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h	2010-04-29 11:40:59.000000000 -0500
+++ linux-2.6/include/linux/mm_types.h	2010-04-29 16:18:43.000000000 -0500
@@ -40,10 +40,7 @@ struct page {
 					 * to show when page is mapped
 					 * & limit reverse map searches.
 					 */
-		struct {		/* SLUB */
-			u16 inuse;
-			u16 objects;
-		};
+		u32 objects;		/* SLEB */
 	};
 	union {
 	    struct {
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-04-29 16:18:32.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-04-29 16:18:43.000000000 -0500
@@ -152,7 +152,6 @@ static inline int debug_on(struct kmem_c
 
 #define OO_SHIFT	16
 #define OO_MASK		((1 << OO_SHIFT) - 1)
-#define MAX_OBJS_PER_PAGE	65535 /* since page.objects is u16 */
 
 /* Internal SLUB flags */
 #define __OBJECT_POISON		0x80000000UL /* Poison object */
@@ -771,9 +770,6 @@ static int verify_slab(struct kmem_cache
 			max_objects = ((void *)page->freelist - start) / s->size;
 	}
 
-	if (max_objects > MAX_OBJS_PER_PAGE)
-		max_objects = MAX_OBJS_PER_PAGE;
-
 	if (page->objects != max_objects) {
 		slab_err(s, page, "Wrong number of objects. Found %d but "
 			"should be %d", page->objects, max_objects);
@@ -1931,9 +1927,6 @@ static inline int slab_order(int size, i
 	int rem;
 	int min_order = slub_min_order;
 
-	if ((PAGE_SIZE << min_order) / size > MAX_OBJS_PER_PAGE)
-		return get_order(size * MAX_OBJS_PER_PAGE) - 1;
-
 	for (order = max(min_order,
 				fls(min_objects * size - 1) - PAGE_SHIFT);
 			order <= max_order; order++) {

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
