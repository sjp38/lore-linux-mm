Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 286106B0085
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 11:31:12 -0500 (EST)
Received: by mail-qg0-f50.google.com with SMTP id i50so2313378qgf.23
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 08:31:12 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id w5si2039990qap.131.2014.12.10.08.30.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 08:30:39 -0800 (PST)
Message-Id: <20141210163034.199347747@linux.com>
Date: Wed, 10 Dec 2014 10:30:24 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 7/7] slub: Remove preemption disable/enable from fastpath
References: <20141210163017.092096069@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=slub_fastpath_remove_preempt
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

We can now use a this_cpu_cmpxchg_double to update two 64
bit values that are the entire description of the per cpu
freelist. There is no need anymore to disable preempt.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2014-12-09 12:31:45.867575731 -0600
+++ linux/mm/slub.c	2014-12-09 12:31:45.867575731 -0600
@@ -2272,21 +2272,15 @@ static inline void *get_freelist(struct
  * a call to the page allocator and the setup of a new slab.
  */
 static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
-			  unsigned long addr, struct kmem_cache_cpu *c)
+			  unsigned long addr)
 {
 	void *freelist;
 	struct page *page;
 	unsigned long flags;
+	struct kmem_cache_cpu *c;
 
 	local_irq_save(flags);
-#ifdef CONFIG_PREEMPT
-	/*
-	 * We may have been preempted and rescheduled on a different
-	 * cpu before disabling interrupts. Need to reload cpu area
-	 * pointer.
-	 */
 	c = this_cpu_ptr(s->cpu_slab);
-#endif
 
 	if (!c->freelist || is_end_token(c->freelist))
 		goto new_slab;
@@ -2397,7 +2391,6 @@ static __always_inline void *slab_alloc_
 		gfp_t gfpflags, int node, unsigned long addr)
 {
 	void **object;
-	struct kmem_cache_cpu *c;
 	unsigned long tid;
 
 	if (slab_pre_alloc_hook(s, gfpflags))
@@ -2406,31 +2399,15 @@ static __always_inline void *slab_alloc_
 	s = memcg_kmem_get_cache(s, gfpflags);
 redo:
 	/*
-	 * Must read kmem_cache cpu data via this cpu ptr. Preemption is
-	 * enabled. We may switch back and forth between cpus while
-	 * reading from one cpu area. That does not matter as long
-	 * as we end up on the original cpu again when doing the cmpxchg.
-	 *
-	 * Preemption is disabled for the retrieval of the tid because that
-	 * must occur from the current processor. We cannot allow rescheduling
-	 * on a different processor between the determination of the pointer
-	 * and the retrieval of the tid.
-	 */
-	preempt_disable();
-	c = this_cpu_ptr(s->cpu_slab);
-
-	/*
 	 * The transaction ids are globally unique per cpu and per operation on
 	 * a per cpu queue. Thus they can be guarantee that the cmpxchg_double
 	 * occurs on the right processor and that there was no operation on the
 	 * linked list in between.
 	 */
-	tid = c->tid;
-	preempt_enable();
-
-	object = c->freelist;
-	if (unlikely(!object || is_end_token(object) ||!node_match_ptr(object, node))) {
-		object = __slab_alloc(s, gfpflags, node, addr, c);
+	tid = this_cpu_read(s->cpu_slab->tid);
+	object = this_cpu_read(s->cpu_slab->freelist);
+	if (unlikely(!object || is_end_token(object) || !node_match_ptr(object, node))) {
+		object = __slab_alloc(s, gfpflags, node, addr);
 		stat(s, ALLOC_SLOWPATH);
 	} else {
 		void *next_object = get_freepointer_safe(s, object);
@@ -2666,30 +2643,21 @@ static __always_inline void slab_free(st
 			struct page *page, void *x, unsigned long addr)
 {
 	void **object = (void *)x;
-	struct kmem_cache_cpu *c;
+	void *freelist;
 	unsigned long tid;
 
 	slab_free_hook(s, x);
 
 redo:
-	/*
-	 * Determine the currently cpus per cpu slab.
-	 * The cpu may change afterward. However that does not matter since
-	 * data is retrieved via this pointer. If we are on the same cpu
-	 * during the cmpxchg then the free will succedd.
-	 */
-	preempt_disable();
-	c = this_cpu_ptr(s->cpu_slab);
-
-	tid = c->tid;
-	preempt_enable();
+	tid = this_cpu_read(s->cpu_slab->tid);
+	freelist = this_cpu_read(s->cpu_slab->freelist);
 
-	if (likely(same_slab_page(s, page, c->freelist))) {
-		set_freepointer(s, object, c->freelist);
+	if (likely(same_slab_page(s, page, freelist))) {
+		set_freepointer(s, object, freelist);
 
 		if (unlikely(!this_cpu_cmpxchg_double(
 				s->cpu_slab->freelist, s->cpu_slab->tid,
-				c->freelist, tid,
+				freelist, tid,
 				object, next_tid(tid)))) {
 
 			note_cmpxchg_failure("slab_free", s, tid);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
