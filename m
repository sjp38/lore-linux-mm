Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 385916B006C
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 15:53:04 -0400 (EDT)
Message-Id: <20120601195302.428834288@linux.com>
Date: Fri, 01 Jun 2012 14:52:50 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [05/20] [slab] Remove some accessors
References: <20120601195245.084749371@linux.com>
Content-Disposition: inline; filename=slab_remove_accessors
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

Those are rather trivial now and its better to see inline what is
really going on.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slab.c |   35 ++++++++---------------------------
 1 file changed, 8 insertions(+), 27 deletions(-)

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-05-22 09:21:28.528444571 -0500
+++ linux-2.6/mm/slab.c	2012-05-22 09:27:35.664436970 -0500
@@ -489,16 +489,6 @@ EXPORT_SYMBOL(slab_buffer_size);
 static int slab_max_order = SLAB_MAX_ORDER_LO;
 static bool slab_max_order_set __initdata;
 
-/*
- * Functions for storing/retrieving the cachep and or slab from the page
- * allocator.  These are used to find the slab an obj belongs to.  With kfree(),
- * these are used to find the cache which an obj belongs to.
- */
-static inline void page_set_cache(struct page *page, struct kmem_cache *cache)
-{
-	page->slab_cache = cache;
-}
-
 static inline struct kmem_cache *page_get_cache(struct page *page)
 {
 	page = compound_head(page);
@@ -506,27 +496,18 @@ static inline struct kmem_cache *page_ge
 	return page->slab_cache;
 }
 
-static inline void page_set_slab(struct page *page, struct slab *slab)
-{
-	page->slab_page = slab;
-}
-
-static inline struct slab *page_get_slab(struct page *page)
-{
-	BUG_ON(!PageSlab(page));
-	return page->slab_page;
-}
-
 static inline struct kmem_cache *virt_to_cache(const void *obj)
 {
 	struct page *page = virt_to_head_page(obj);
-	return page_get_cache(page);
+	return page->slab_cache;
 }
 
 static inline struct slab *virt_to_slab(const void *obj)
 {
 	struct page *page = virt_to_head_page(obj);
-	return page_get_slab(page);
+
+	VM_BUG_ON(!PageSlab(page));
+	return page->slab_page;
 }
 
 static inline void *index_to_obj(struct kmem_cache *cache, struct slab *slab,
@@ -2918,8 +2899,8 @@ static void slab_map_pages(struct kmem_c
 		nr_pages <<= cache->gfporder;
 
 	do {
-		page_set_cache(page, cache);
-		page_set_slab(page, slab);
+		page->slab_cache = cache;
+		page->slab_page = slab;
 		page++;
 	} while (--nr_pages);
 }
@@ -3057,7 +3038,7 @@ static void *cache_free_debugcheck(struc
 	kfree_debugcheck(objp);
 	page = virt_to_head_page(objp);
 
-	slabp = page_get_slab(page);
+	slabp = page->slab_page;
 
 	if (cachep->flags & SLAB_RED_ZONE) {
 		verify_redzone_free(cachep, objp);
@@ -3261,7 +3242,7 @@ static void *cache_alloc_debugcheck_afte
 		struct slab *slabp;
 		unsigned objnr;
 
-		slabp = page_get_slab(virt_to_head_page(objp));
+		slabp = virt_to_head_page(objp)->slab_page;
 		objnr = (unsigned)(objp - slabp->s_mem) / cachep->buffer_size;
 		slab_bufctl(slabp)[objnr] = BUFCTL_ACTIVE;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
