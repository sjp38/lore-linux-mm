Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6F1DD6B01B5
	for <linux-mm@kvack.org>; Fri, 21 May 2010 17:18:57 -0400 (EDT)
Message-Id: <20100521211538.695980225@quilx.com>
Date: Fri, 21 May 2010 16:14:55 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC V2 SLEB 03/14] SLUB: Use kmem_cache flags to detect if Slab is in debugging mode.
References: <20100521211452.659982351@quilx.com>
Content-Disposition: inline; filename=slub_debug_on
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The cacheline with the flags is reachable from the hot paths after the
percpu allocator changes went in. So there is no need anymore to put a
flag into each slab page. Get rid of the SlubDebug flag and use
the flags in kmem_cache instead.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/page-flags.h |    1 -
 mm/slub.c                  |   33 ++++++++++++---------------------
 2 files changed, 12 insertions(+), 22 deletions(-)

Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2010-04-27 12:47:10.000000000 -0500
+++ linux-2.6/include/linux/page-flags.h	2010-04-27 12:47:21.000000000 -0500
@@ -215,7 +215,6 @@ PAGEFLAG(SwapBacked, swapbacked) __CLEAR
 __PAGEFLAG(SlobFree, slob_free)
 
 __PAGEFLAG(SlubFrozen, slub_frozen)
-__PAGEFLAG(SlubDebug, slub_debug)
 
 /*
  * Private page markings that may be used by the filesystem that owns the page
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-04-27 12:41:05.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-04-27 13:15:32.000000000 -0500
@@ -107,11 +107,17 @@
  * 			the fast path and disables lockless freelists.
  */
 
+#define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
+		SLAB_TRACE | SLAB_DEBUG_FREE)
+
+static inline int debug_on(struct kmem_cache *s)
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
@@ -1165,9 +1171,6 @@ static struct page *new_slab(struct kmem
 	inc_slabs_node(s, page_to_nid(page), page->objects);
 	page->slab = s;
 	page->flags |= 1 << PG_slab;
-	if (s->flags & (SLAB_DEBUG_FREE | SLAB_RED_ZONE | SLAB_POISON |
-			SLAB_STORE_USER | SLAB_TRACE))
-		__SetPageSlubDebug(page);
 
 	start = page_address(page);
 
@@ -1194,14 +1197,13 @@ static void __free_slab(struct kmem_cach
 	int order = compound_order(page);
 	int pages = 1 << order;
 
-	if (unlikely(SLABDEBUG && PageSlubDebug(page))) {
+	if (debug_on(s)) {
 		void *p;
 
 		slab_pad_check(s, page);
 		for_each_object(p, s, page_address(page),
 						page->objects)
 			check_object(s, page, p, 0);
-		__ClearPageSlubDebug(page);
 	}
 
 	kmemcheck_free_shadow(page, compound_order(page));
@@ -1419,8 +1421,7 @@ static void unfreeze_slab(struct kmem_ca
 			stat(s, tail ? DEACTIVATE_TO_TAIL : DEACTIVATE_TO_HEAD);
 		} else {
 			stat(s, DEACTIVATE_FULL);
-			if (SLABDEBUG && PageSlubDebug(page) &&
-						(s->flags & SLAB_STORE_USER))
+			if (debug_on(s) && (s->flags & SLAB_STORE_USER))
 				add_full(n, page);
 		}
 		slab_unlock(page);
@@ -1628,7 +1629,7 @@ load_freelist:
 	object = c->page->freelist;
 	if (unlikely(!object))
 		goto another_slab;
-	if (unlikely(SLABDEBUG && PageSlubDebug(c->page)))
+	if (debug_on(s))
 		goto debug;
 
 	c->freelist = get_freepointer(s, object);
@@ -1787,7 +1788,7 @@ static void __slab_free(struct kmem_cach
 	stat(s, FREE_SLOWPATH);
 	slab_lock(page);
 
-	if (unlikely(SLABDEBUG && PageSlubDebug(page)))
+	if (debug_on(s))
 		goto debug;
 
 checks_ok:
@@ -3400,16 +3401,6 @@ static void validate_slab_slab(struct km
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
