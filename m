Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6FDBE600924
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 15:12:34 -0400 (EDT)
Message-Id: <20100709190854.329374697@quilx.com>
Date: Fri, 09 Jul 2010 14:07:14 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q2 08/19] slub: Use kmem_cache flags to detect if slab is in debugging mode.
References: <20100709190706.938177313@quilx.com>
Content-Disposition: inline; filename=slub_debug_on
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

The cacheline with the flags is reachable from the hot paths after the
percpu allocator changes went in. So there is no need anymore to put a
flag into each slab page. Get rid of the SlubDebug flag and use
the flags in kmem_cache instead.

Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/page-flags.h |    2 --
 mm/slub.c                  |   33 ++++++++++++---------------------
 2 files changed, 12 insertions(+), 23 deletions(-)

Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2010-07-09 13:47:25.000000000 -0500
+++ linux-2.6/include/linux/page-flags.h	2010-07-09 14:00:38.000000000 -0500
@@ -128,7 +128,6 @@ enum pageflags {
 
 	/* SLUB */
 	PG_slub_frozen = PG_active,
-	PG_slub_debug = PG_error,
 };
 
 #ifndef __GENERATING_BOUNDS_H
@@ -215,7 +214,6 @@ PAGEFLAG(SwapBacked, swapbacked) __CLEAR
 __PAGEFLAG(SlobFree, slob_free)
 
 __PAGEFLAG(SlubFrozen, slub_frozen)
-__PAGEFLAG(SlubDebug, slub_debug)
 
 /*
  * Private page markings that may be used by the filesystem that owns the page
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-07-09 13:59:26.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-07-09 13:59:30.000000000 -0500
@@ -107,11 +107,17 @@
  * 			the fast path and disables lockless freelists.
  */
 
+#define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
+		SLAB_TRACE | SLAB_DEBUG_FREE)
+
+static inline int kmem_cache_debug(struct kmem_cache *s)
+{
 #ifdef CONFIG_SLUB_DEBUG
-#define SLABDEBUG 1
+	return unlikely(s->flags & SLAB_DEBUG_FLAGS);
 #else
-#define SLABDEBUG 0
+	return 0;
 #endif
+}
 
 /*
  * Issues still to be resolved:
@@ -1157,9 +1163,6 @@ static struct page *new_slab(struct kmem
 	inc_slabs_node(s, page_to_nid(page), page->objects);
 	page->slab = s;
 	page->flags |= 1 << PG_slab;
-	if (s->flags & (SLAB_DEBUG_FREE | SLAB_RED_ZONE | SLAB_POISON |
-			SLAB_STORE_USER | SLAB_TRACE))
-		__SetPageSlubDebug(page);
 
 	start = page_address(page);
 
@@ -1186,14 +1189,13 @@ static void __free_slab(struct kmem_cach
 	int order = compound_order(page);
 	int pages = 1 << order;
 
-	if (unlikely(SLABDEBUG && PageSlubDebug(page))) {
+	if (kmem_cache_debug(s)) {
 		void *p;
 
 		slab_pad_check(s, page);
 		for_each_object(p, s, page_address(page),
 						page->objects)
 			check_object(s, page, p, 0);
-		__ClearPageSlubDebug(page);
 	}
 
 	kmemcheck_free_shadow(page, compound_order(page));
@@ -1415,8 +1417,7 @@ static void unfreeze_slab(struct kmem_ca
 			stat(s, tail ? DEACTIVATE_TO_TAIL : DEACTIVATE_TO_HEAD);
 		} else {
 			stat(s, DEACTIVATE_FULL);
-			if (SLABDEBUG && PageSlubDebug(page) &&
-						(s->flags & SLAB_STORE_USER))
+			if (kmem_cache_debug(s) && (s->flags & SLAB_STORE_USER))
 				add_full(n, page);
 		}
 		slab_unlock(page);
@@ -1624,7 +1625,7 @@ load_freelist:
 	object = c->page->freelist;
 	if (unlikely(!object))
 		goto another_slab;
-	if (unlikely(SLABDEBUG && PageSlubDebug(c->page)))
+	if (kmem_cache_debug(s))
 		goto debug;
 
 	c->freelist = get_freepointer(s, object);
@@ -1783,7 +1784,7 @@ static void __slab_free(struct kmem_cach
 	stat(s, FREE_SLOWPATH);
 	slab_lock(page);
 
-	if (unlikely(SLABDEBUG && PageSlubDebug(page)))
+	if (kmem_cache_debug(s))
 		goto debug;
 
 checks_ok:
@@ -3398,16 +3399,6 @@ static void validate_slab_slab(struct km
 	} else
 		printk(KERN_INFO "SLUB %s: Skipped busy slab 0x%p\n",
 			s->name, page);
-
-	if (s->flags & DEBUG_DEFAULT_FLAGS) {
-		if (!PageSlubDebug(page))
-			printk(KERN_ERR "SLUB %s: SlubDebug not set "
-				"on slab 0x%p\n", s->name, page);
-	} else {
-		if (PageSlubDebug(page))
-			printk(KERN_ERR "SLUB %s: SlubDebug set on "
-				"slab 0x%p\n", s->name, page);
-	}
 }
 
 static int validate_slab_node(struct kmem_cache *s,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
