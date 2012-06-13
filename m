Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id D09DD6B0074
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 11:25:18 -0400 (EDT)
Message-Id: <20120613152516.987570955@linux.com>
Date: Wed, 13 Jun 2012 10:24:55 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [04/20] [slab] Use page struct fields instead of casting
References: <20120613152451.465596612@linux.com>
Content-Disposition: inline; filename=slab_page_struct_fields
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

Add fields to the page struct so that it is properly documented that
slab overlays the lru fields.

This cleans up some casts in slab.

Reviewed-by: Glauber Costa <glommer@parallels.com>
Reviewed-by: Joonsoo Kim <js1304@gmail.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/mm_types.h |    4 ++++
 mm/slab.c                |    8 ++++----
 2 files changed, 8 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-06-13 03:44:15.321477984 -0500
+++ linux-2.6/mm/slab.c	2012-06-13 03:45:57.341475870 -0500
@@ -496,25 +496,25 @@ static bool slab_max_order_set __initdat
  */
 static inline void page_set_cache(struct page *page, struct kmem_cache *cache)
 {
-	page->lru.next = (struct list_head *)cache;
+	page->slab_cache = cache;
 }
 
 static inline struct kmem_cache *page_get_cache(struct page *page)
 {
 	page = compound_head(page);
 	BUG_ON(!PageSlab(page));
-	return (struct kmem_cache *)page->lru.next;
+	return page->slab_cache;
 }
 
 static inline void page_set_slab(struct page *page, struct slab *slab)
 {
-	page->lru.prev = (struct list_head *)slab;
+	page->slab_page = slab;
 }
 
 static inline struct slab *page_get_slab(struct page *page)
 {
 	BUG_ON(!PageSlab(page));
-	return (struct slab *)page->lru.prev;
+	return page->slab_page;
 }
 
 static inline struct kmem_cache *virt_to_cache(const void *obj)
Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h	2012-06-13 03:44:40.433477464 -0500
+++ linux-2.6/include/linux/mm_types.h	2012-06-13 03:44:40.525477462 -0500
@@ -110,6 +110,10 @@ struct page {
 		};
 
 		struct list_head list;	/* slobs list of pages */
+		struct {		/* slab fields */
+			struct kmem_cache *slab_cache;
+			struct slab *slab_page;
+		};
 	};
 
 	/* Remainder is not double word aligned */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
