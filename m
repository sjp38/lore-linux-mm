Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id AB54C6B0088
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 11:31:29 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id a108so2316608qge.8
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 08:31:29 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id j104si5428508qgd.15.2014.12.10.08.30.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 08:30:39 -0800 (PST)
Message-Id: <20141210163034.078015357@linux.com>
Date: Wed, 10 Dec 2014 10:30:23 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 6/7] slub: Drop ->page field from kmem_cache_cpu
References: <20141210163017.092096069@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=slub_drop_kmem_cache_cpu_page_Field
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

Dropping the page field is possible since the page struct address
of an object or a freelist pointer can now always be calcualted from
the address. No freelist pointer will be NULL anymore so use
NULL to signify the condition that the current cpu has no
percpu slab attached to it.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slub_def.h
===================================================================
--- linux.orig/include/linux/slub_def.h	2014-12-09 12:41:01.150901379 -0600
+++ linux/include/linux/slub_def.h	2014-12-09 12:41:01.150901379 -0600
@@ -40,7 +40,6 @@ enum stat_item {
 struct kmem_cache_cpu {
 	void **freelist;	/* Pointer to next available object */
 	unsigned long tid;	/* Globally unique transaction id */
-	struct page *page;	/* The slab from which we are allocating */
 	struct page *partial;	/* Partially allocated frozen slabs */
 #ifdef CONFIG_SLUB_STATS
 	unsigned stat[NR_SLUB_STAT_ITEMS];
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2014-12-09 12:41:01.150901379 -0600
+++ linux/mm/slub.c	2014-12-09 12:41:01.150901379 -0600
@@ -1613,7 +1613,6 @@ static void *get_partial_node(struct kme
 
 		available += objects;
 		if (!object) {
-			c->page = page;
 			stat(s, ALLOC_FROM_PARTIAL);
 			object = t;
 		} else {
@@ -2051,10 +2050,9 @@ static void put_cpu_partial(struct kmem_
 static inline void flush_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
 {
 	stat(s, CPUSLAB_FLUSH);
-	deactivate_slab(s, c->page, c->freelist);
+	deactivate_slab(s, virt_to_head_page(c->freelist), c->freelist);
 
 	c->tid = next_tid(c->tid);
-	c->page = NULL;
 	c->freelist = NULL;
 }
 
@@ -2068,7 +2066,7 @@ static inline void __flush_cpu_slab(stru
 	struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
 
 	if (likely(c)) {
-		if (c->page)
+		if (c->freelist)
 			flush_slab(s, c);
 
 		unfreeze_partials(s, c);
@@ -2087,7 +2085,7 @@ static bool has_cpu_slab(int cpu, void *
 	struct kmem_cache *s = info;
 	struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
 
-	return c->page || c->partial;
+	return c->freelist || c->partial;
 }
 
 static void flush_all(struct kmem_cache *s)
@@ -2197,7 +2195,7 @@ static inline void *new_slab_objects(str
 	page = new_slab(s, flags, node);
 	if (page) {
 		c = raw_cpu_ptr(s->cpu_slab);
-		if (c->page)
+		if (c->freelist)
 			flush_slab(s, c);
 
 		/*
@@ -2208,7 +2206,6 @@ static inline void *new_slab_objects(str
 		page->freelist = end_token(freelist);
 
 		stat(s, ALLOC_SLAB);
-		c->page = page;
 		*pc = c;
 	} else
 		freelist = NULL;
@@ -2291,9 +2288,10 @@ static void *__slab_alloc(struct kmem_ca
 	c = this_cpu_ptr(s->cpu_slab);
 #endif
 
-	page = c->page;
-	if (!page)
+	if (!c->freelist || is_end_token(c->freelist))
 		goto new_slab;
+
+	page = virt_to_head_page(c->freelist);
 redo:
 
 	if (unlikely(!node_match(page, node))) {
@@ -2329,7 +2327,7 @@ redo:
 
 	if (is_end_token(freelist)) {
 		/* page has been deactivated by get_freelist */
-		c->page = NULL;
+		c->freelist = NULL;
 		stat(s, DEACTIVATE_BYPASS);
 		goto new_slab;
 	}
@@ -2342,7 +2340,7 @@ load_freelist:
 	 * page is pointing to the page from which the objects are obtained.
 	 * That page must be frozen for per cpu allocations to work.
 	 */
-	VM_BUG_ON(!c->page->frozen);
+	VM_BUG_ON(!virt_to_head_page(freelist)->frozen);
 	c->freelist = get_freepointer(s, freelist);
 	c->tid = next_tid(c->tid);
 	local_irq_restore(flags);
@@ -2350,13 +2348,12 @@ load_freelist:
 
 deactivate:
 	deactivate_slab(s, page, c->freelist);
-	c->page = NULL;
 	c->freelist = NULL;
 
 new_slab:
 
 	if (c->partial) {
-		page = c->page = c->partial;
+		page = c->partial;
 		c->partial = page->next;
 		stat(s, CPU_PARTIAL_ALLOC);
 		c->freelist = end_token(page->address);
@@ -2371,7 +2368,7 @@ new_slab:
 		return NULL;
 	}
 
-	page = c->page;
+	page = virt_to_head_page(freelist);
 	if (likely(!kmem_cache_debug(s) && pfmemalloc_match(page, gfpflags)))
 		goto load_freelist;
 
@@ -2381,7 +2378,6 @@ new_slab:
 		goto new_slab;	/* Slab failed checks. Next slab needed */
 
 	deactivate_slab(s, page, get_freepointer(s, freelist));
-	c->page = NULL;
 	c->freelist = NULL;
 	local_irq_restore(flags);
 	return freelist;
@@ -2402,7 +2398,6 @@ static __always_inline void *slab_alloc_
 {
 	void **object;
 	struct kmem_cache_cpu *c;
-	struct page *page;
 	unsigned long tid;
 
 	if (slab_pre_alloc_hook(s, gfpflags))
@@ -2434,7 +2429,6 @@ redo:
 	preempt_enable();
 
 	object = c->freelist;
-	page = c->page;
 	if (unlikely(!object || is_end_token(object) ||!node_match_ptr(object, node))) {
 		object = __slab_alloc(s, gfpflags, node, addr, c);
 		stat(s, ALLOC_SLOWPATH);
@@ -4216,10 +4210,10 @@ static ssize_t show_slab_objects(struct
 			int node;
 			struct page *page;
 
-			page = ACCESS_ONCE(c->page);
-			if (!page)
+			if (!c->freelist)
 				continue;
 
+			page = virt_to_head_page(c->freelist);
 			node = page_to_nid(page);
 			if (flags & SO_TOTAL)
 				x = page->objects;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
