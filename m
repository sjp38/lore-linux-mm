Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id A341B6B006E
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 10:01:25 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id l13so808286iga.14
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 07:01:24 -0800 (PST)
Received: from resqmta-po-05v.sys.comcast.net (resqmta-po-05v.sys.comcast.net. [2001:558:fe16:19:96:114:154:164])
        by mx.google.com with ESMTPS id o16si7386184ioo.32.2014.12.19.07.01.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 19 Dec 2014 07:01:22 -0800 (PST)
Date: Fri, 19 Dec 2014 09:01:20 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] Slab infrastructure for array operations
In-Reply-To: <20141219113113.477fd18f@redhat.com>
Message-ID: <alpine.DEB.2.11.1412190859140.9649@gentwo.org>
References: <alpine.DEB.2.11.1412181031520.2962@gentwo.org> <20141218140629.393972c7bd8b3b884507264c@linux-foundation.org> <20141219113113.477fd18f@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, akpm@linuxfoundation.org, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>

On Fri, 19 Dec 2014, Jesper Dangaard Brouer wrote:

> > > Allocators must define _HAVE_SLAB_ALLOCATOR_OPERATIONS in their
> > > header files in order to implement their own fast version for
> > > these array operations.
>
> I would like to see an implementation of a fast-version.  Else it is
> difficult to evaluate if the API is the right one.  E.g. if it would be
> beneficial for the MM system, we could likely restrict the API to only
> work with power-of-two, from the beginning.

I have some half way done patch mess here to implement fast functions for
SLUB. This does not even compile just for illustration of my thinking.

Index: linux/include/linux/slub_def.h
===================================================================
--- linux.orig/include/linux/slub_def.h	2014-12-18 14:34:02.726408665 -0600
+++ linux/include/linux/slub_def.h	2014-12-18 14:34:38.977288122 -0600
@@ -110,4 +110,5 @@ static inline void sysfs_slab_remove(str
 }
 #endif

+#define _HAVE_SLAB_ARRAY_ALLOCATION
 #endif /* _LINUX_SLUB_DEF_H */
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2014-12-18 14:34:02.730408541 -0600
+++ linux/mm/slub.c	2014-12-18 15:44:18.812347165 -0600
@@ -1374,13 +1374,9 @@ static void setup_object(struct kmem_cac
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
@@ -1389,33 +1385,42 @@ static struct page *new_slab(struct kmem

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

@@ -2511,6 +2516,62 @@ EXPORT_SYMBOL(kmem_cache_alloc_node_trac
 #endif
 #endif

+int kmem_cache_alloc_array(struct kmem_cache *s,
+	gfp_t gfpflags, int nr, void **p)
+{
+	void **end = p + nr;
+	struct kmem_cache_node *n = getnode(numa_mem_id());
+
+	/* See if we can use some of the partial slabs in our per node list */
+	if (n->nr_partial) {
+		spin_lock_irqsave(&n->list_lock, flags);
+		while (n->nr_partial) {
+			void *freelist;
+
+			page = n->partial.next;
+			if (page->objects - page->inuse > end - p)
+				/* More objects free in page than we want */
+				break;
+			list_del(page->list);
+			slab_lock(page);
+			freelist = page->freelist;
+			page->inuse = page->objects;
+			page->freelist = NULL;
+			slab_unlock(page);
+			/* Grab all available objects */
+			while (freelist) {
+				*p++ = freelist;
+				freelist = get_freepointer(s, freelist);
+			}
+		}
+		spin_lock_irqrestore(&n->list_lock, flags);
+	}
+
+	/* If we still need lots more objects get some new slabs allocated */
+	while (end - p >= oo_objects(s->oo)) {
+		struct page *page = __new_slab(s, gfpflags, NUMA_NO_NODE);
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
+	}
+
+	/* Drain per cpu partials */
+	/* Drain per cpu slab */
+
+	/* If we are missing some objects get them the regular way */
+	while (p < end)
+		*p++ = kmem_cache_alloc(s, gfpflags);
+}
+
 /*
  * Slow patch handling. This may still be called frequently since objects
  * have a longer lifetime than the cpu slabs in most processing loads.
@@ -2632,6 +2693,57 @@ slab_empty:
 	discard_slab(s, page);
 }

+void kmem_cache_free_array(struct kmem_cache *s, int nr, void **p)
+{
+	struct kmem_cache_node *n = NULL;
+	int last_node = NUMA_NO_NODE;
+	struct kmem_cache_cpu *c;
+	struct page *page;
+
+	local_irq_save(flags);
+	c = this_cpu_ptr(s->cpu_slab);
+	for (i = 0; i < nr; i++) {
+		object = p[i];
+		if (!object)
+			continue;
+		page = virt_to_head_page(object);
+		/* Check if valid slab page */
+		if (s != page->slab_cache)
+			BUG
+		if (c->page == page) {
+			set_freepointer(object, c->freelist);
+			c->freelist = object;
+		} else {
+			node = page_to_nid(page);
+			if (page->frozen) {
+				if (page is from this cpu) {
+					lock_page(page);
+					set_freepointer(object, page->freelist);
+					page->freelist = object;
+					unlock_page(page);
+					/* Can free without locking */
+				} else {
+					/* We need to wait */
+				}
+			} else {
+				if (node != last_node) {
+					if (n)
+						spin_unlock(n->list_lock);
+					n = s->node[node];
+					last_node = node;
+					spin_lock(n->list_lock);
+				}
+				/* General free case with locking */
+			}
+		}
+
+	}
+	if (n)
+		spin_unlock(n->list_lock);
+	local_irq_restore(flags);
+
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
