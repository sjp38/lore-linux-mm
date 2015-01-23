Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id F0D276B006E
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 16:37:40 -0500 (EST)
Received: by mail-qa0-f43.google.com with SMTP id v10so7784111qac.2
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 13:37:40 -0800 (PST)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id e3si3487376qaf.113.2015.01.23.13.37.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 13:37:38 -0800 (PST)
Message-Id: <20150123213735.707854993@linux.com>
Date: Fri, 23 Jan 2015 15:37:29 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 2/3] slub: Support for array operations
References: <20150123213727.142554068@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=array_alloc_slub
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

The major portions are there but there is no support yet for
directly allocating per cpu objects. There could also be more
sophisticated code to exploit the batch freeing.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slub_def.h
===================================================================
--- linux.orig/include/linux/slub_def.h
+++ linux/include/linux/slub_def.h
@@ -110,4 +110,5 @@ static inline void sysfs_slab_remove(str
 }
 #endif
 
+#define _HAVE_SLAB_ALLOCATOR_ARRAY_OPERATIONS
 #endif /* _LINUX_SLUB_DEF_H */
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -1379,13 +1379,9 @@ static void setup_object(struct kmem_cac
 		s->ctor(object);
 }
 
-static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
+static struct page *__new_slab(struct kmem_cache *s, gfp_t flags, int node)
 {
 	struct page *page;
-	void *start;
-	void *p;
-	int order;
-	int idx;
 
 	if (unlikely(flags & GFP_SLAB_BUG_MASK)) {
 		pr_emerg("gfp: %u\n", flags & GFP_SLAB_BUG_MASK);
@@ -1394,33 +1390,42 @@ static struct page *new_slab(struct kmem
 
 	page = allocate_slab(s,
 		flags & (GFP_RECLAIM_MASK | GFP_CONSTRAINT_MASK), node);
-	if (!page)
-		goto out;
+	if (page) {
+		inc_slabs_node(s, page_to_nid(page), page->objects);
+		page->slab_cache = s;
+		__SetPageSlab(page);
+		if (page->pfmemalloc)
+			SetPageSlabPfmemalloc(page);
+	}
 
-	order = compound_order(page);
-	inc_slabs_node(s, page_to_nid(page), page->objects);
-	page->slab_cache = s;
-	__SetPageSlab(page);
-	if (page->pfmemalloc)
-		SetPageSlabPfmemalloc(page);
-
-	start = page_address(page);
-
-	if (unlikely(s->flags & SLAB_POISON))
-		memset(start, POISON_INUSE, PAGE_SIZE << order);
-
-	for_each_object_idx(p, idx, s, start, page->objects) {
-		setup_object(s, page, p);
-		if (likely(idx < page->objects))
-			set_freepointer(s, p, p + s->size);
-		else
-			set_freepointer(s, p, NULL);
-	}
-
-	page->freelist = start;
-	page->inuse = page->objects;
-	page->frozen = 1;
-out:
+	return page;
+}
+
+static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
+{
+	struct page *page = __new_slab(s, flags, node);
+
+	if (page) {
+		void *p;
+		int idx;
+		void *start = page_address(page);
+
+		if (unlikely(s->flags & SLAB_POISON))
+			memset(start, POISON_INUSE,
+				PAGE_SIZE << compound_order(page));
+
+		for_each_object_idx(p, idx, s, start, page->objects) {
+			setup_object(s, page, p);
+			if (likely(idx < page->objects))
+				set_freepointer(s, p, p + s->size);
+			else
+				set_freepointer(s, p, NULL);
+		}
+
+		page->freelist = start;
+		page->inuse = page->objects;
+		page->frozen = 1;
+	}
 	return page;
 }
 
@@ -2516,8 +2521,78 @@ EXPORT_SYMBOL(kmem_cache_alloc_node_trac
 #endif
 #endif
 
+int slab_array_alloc_from_partial(struct kmem_cache *s,
+			size_t nr, void **p)
+{
+	void **end = p + nr;
+	struct kmem_cache_node *n = get_node(s, numa_mem_id());
+	int allocated = 0;
+	unsigned long flags;
+	struct page *page, *page2;
+
+	if (!n->nr_partial)
+		return 0;
+
+
+	spin_lock_irqsave(&n->list_lock, flags);
+	list_for_each_entry_safe(page, page2, &n->partial, lru) {
+		void *freelist;
+
+		if (page->objects - page->inuse > end - p)
+			/* More objects free in page than we want */
+			break;
+		list_del(&page->lru);
+		slab_lock(page);
+		freelist = page->freelist;
+		page->inuse = page->objects;
+		page->freelist = NULL;
+		slab_unlock(page);
+		/* Grab all available objects */
+		while (freelist) {
+			*p++ = freelist;
+			freelist = get_freepointer(s, freelist);
+			allocated++;
+		}
+	}
+	spin_unlock_irqrestore(&n->list_lock, flags);
+	return allocated;
+}
+
+int slab_array_alloc_from_page_allocator(struct kmem_cache *s,
+		gfp_t flags, size_t nr, void **p)
+{
+	void **end = p + nr;
+	int allocated = 0;
+
+	while (end - p >= oo_objects(s->oo)) {
+		struct page *page = __new_slab(s, flags, NUMA_NO_NODE);
+		void *q = page_address(page);
+		int i;
+
+		/* Use all the objects */
+		for (i = 0; i < page->objects; i++) {
+			setup_object(s, page, q);
+			*p++ = q;
+			q += s->size;
+		}
+
+		page->inuse = page->objects;
+		page->freelist = NULL;
+		allocated += page->objects;
+	}
+	return allocated;
+}
+
+int slab_array_alloc_from_local(struct kmem_cache *s,
+		size_t nr, void **p)
+{
+	/* Go for the per cpu partials list first */
+	/* Use the cpu_slab if objects are still needed */
+	return 0;
+}
+
 /*
- * Slow patch handling. This may still be called frequently since objects
+ * Slow path handling. This may still be called frequently since objects
  * have a longer lifetime than the cpu slabs in most processing loads.
  *
  * So we still attempt to reduce cache line usage. Just take the slab
@@ -2637,6 +2712,14 @@ slab_empty:
 	discard_slab(s, page);
 }
 
+void kmem_cache_free_array(struct kmem_cache *s, size_t nr, void **p)
+{
+	void **end = p + nr;
+
+	for ( ; p < end; p++)
+		__slab_free(s, virt_to_head_page(p), p, 0);
+}
+
 /*
  * Fastpath with forced inlining to produce a kfree and kmem_cache_free that
  * can perform fastpath freeing without additional function calls.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
