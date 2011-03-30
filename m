Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9D9DA8D004D
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 16:24:21 -0400 (EDT)
Message-Id: <20110330202418.795427129@linux.com>
Date: Wed, 30 Mar 2011 15:23:48 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubll1 06/19] slub: Do not use frozen page flag but a bit in the page counters
References: <20110330202342.669400887@linux.com>
Content-Disposition: inline; filename=frozen_field
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>

Do not use a page flag for the frozen bit. It needs to be part
of the state that is handled with cmpxchg_double(). So use a bit
in the counter struct in the page struct for that purpose.

Also all page start out as frozen pages so set the bit
when the page is allocated.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 include/linux/mm_types.h   |    5 +++--
 include/linux/page-flags.h |    2 --
 mm/slub.c                  |   12 ++++++------
 3 files changed, 9 insertions(+), 10 deletions(-)

Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h	2011-03-30 14:29:23.000000000 -0500
+++ linux-2.6/include/linux/mm_types.h	2011-03-30 14:32:15.000000000 -0500
@@ -41,8 +41,9 @@ struct page {
 					 * & limit reverse map searches.
 					 */
 		struct {		/* SLUB */
-			u16 inuse;
-			u16 objects;
+			unsigned inuse:16;
+			unsigned objects:15;
+			unsigned frozen:1;
 		};
 	};
 	union {
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2011-03-30 14:29:23.000000000 -0500
+++ linux-2.6/include/linux/page-flags.h	2011-03-30 14:32:15.000000000 -0500
@@ -212,8 +212,6 @@ PAGEFLAG(SwapBacked, swapbacked) __CLEAR
 
 __PAGEFLAG(SlobFree, slob_free)
 
-__PAGEFLAG(SlubFrozen, slub_frozen)
-
 /*
  * Private page markings that may be used by the filesystem that owns the page
  * for its own purposes.
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-03-30 14:31:27.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-03-30 14:32:15.000000000 -0500
@@ -166,7 +166,7 @@ static inline int kmem_cache_debug(struc
 
 #define OO_SHIFT	16
 #define OO_MASK		((1 << OO_SHIFT) - 1)
-#define MAX_OBJS_PER_PAGE	65535 /* since page.objects is u16 */
+#define MAX_OBJS_PER_PAGE	32767 /* since page.objects is u15 */
 
 /* Internal SLUB flags */
 #define __OBJECT_POISON		0x80000000UL /* Poison object */
@@ -1013,7 +1013,7 @@ static noinline int free_debug_processin
 	}
 
 	/* Special debug activities for freeing objects */
-	if (!PageSlubFrozen(page) && !page->freelist)
+	if (!page->frozen && !page->freelist)
 		remove_full(s, page);
 	if (s->flags & SLAB_STORE_USER)
 		set_track(s, object, TRACK_FREE, addr);
@@ -1402,7 +1402,7 @@ static inline int lock_and_freeze_slab(s
 {
 	if (slab_trylock(page)) {
 		__remove_partial(n, page);
-		__SetPageSlubFrozen(page);
+		page->frozen = 1;
 		return 1;
 	}
 	return 0;
@@ -1516,7 +1516,7 @@ static void unfreeze_slab(struct kmem_ca
 {
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
 
-	__ClearPageSlubFrozen(page);
+	page->frozen = 0;
 	if (page->inuse) {
 
 		if (page->freelist) {
@@ -1867,7 +1867,7 @@ load_from_page:
 			flush_slab(s, c);
 
 		slab_lock(page);
-		__SetPageSlubFrozen(page);
+		page->frozen = 1;
 
 		goto load_from_page;
 	}
@@ -2065,7 +2065,7 @@ static void __slab_free(struct kmem_cach
 	page->freelist = object;
 	page->inuse--;
 
-	if (unlikely(PageSlubFrozen(page))) {
+	if (unlikely(page->frozen)) {
 		stat(s, FREE_FROZEN);
 		goto out_unlock;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
