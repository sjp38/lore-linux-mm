Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0A82E900014
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 11:55:35 -0400 (EDT)
Received: by mail-ig0-f172.google.com with SMTP id r2so1171920igi.5
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 08:55:34 -0700 (PDT)
Received: from resqmta-po-08v.sys.comcast.net (resqmta-po-08v.sys.comcast.net. [2001:558:fe16:19:96:114:154:167])
        by mx.google.com with ESMTPS id jg2si2326751igb.14.2014.10.22.08.55.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 08:55:34 -0700 (PDT)
Message-Id: <20141022155527.268224371@linux.com>
Date: Wed, 22 Oct 2014 10:55:21 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 4/4] slub: Remove preemption disable/enable from fastpath
References: <20141022155517.560385718@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=slub_fastpath_remove_preempt
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com

We can now use a this_cpu_cmpxchg_double to update two 64
bit values that are the entire description of the per cpu
freelist. There is no need anymore to disable preempt.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -2261,21 +2261,15 @@ static inline void *get_freelist(struct
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
@@ -2379,7 +2373,6 @@ static __always_inline void *slab_alloc_
 		gfp_t gfpflags, int node, unsigned long addr)
 {
 	void **object;
-	struct kmem_cache_cpu *c;
 	unsigned long tid;
 
 	if (slab_pre_alloc_hook(s, gfpflags))
@@ -2388,31 +2381,15 @@ static __always_inline void *slab_alloc_
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
+	tid = this_cpu_read(s->cpu_slab->tid);
+	object = this_cpu_read(s->cpu_slab->freelist);
 	if (unlikely(!object || is_end_token(object) || !node_match(virt_to_head_page(object), node))) {
-		object = __slab_alloc(s, gfpflags, node, addr, c);
+		object = __slab_alloc(s, gfpflags, node, addr);
 		stat(s, ALLOC_SLOWPATH);
 	} else {
 		void *next_object = get_freepointer_safe(s, object);
@@ -2641,30 +2618,21 @@ static __always_inline void slab_free(st
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
 
-	if (likely(c->freelist && page == virt_to_head_page(c->freelist))) {
-		set_freepointer(s, object, c->freelist);
+	if (likely(freelist && page == virt_to_head_page(freelist))) {
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
