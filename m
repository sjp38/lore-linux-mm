Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 250976B0255
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 15:43:29 -0400 (EDT)
Received: by qkch123 with SMTP id h123so34434364qkc.0
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 12:43:29 -0700 (PDT)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id 71si8396381qky.1.2015.08.28.12.43.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 28 Aug 2015 12:43:28 -0700 (PDT)
Date: Fri, 28 Aug 2015 14:43:26 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH] slub: create new ___slab_alloc function that can be called
 with irqs disabled
Message-ID: <alpine.DEB.2.11.1508281442390.11894@east.gentwo.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org


Bulk alloc needs a function like that because it enables interrupts before
calling __slab_alloc which promptly disables them again using the expensive
local_irq_save().

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2015-08-28 14:33:01.520254081 -0500
+++ linux/mm/slub.c	2015-08-28 14:34:21.050215578 -0500
@@ -2300,23 +2300,15 @@ static inline void *get_freelist(struct
  * And if we were unable to get a new slab from the partial slab lists then
  * we need to allocate a new slab. This is the slowest path since it involves
  * a call to the page allocator and the setup of a new slab.
+ *
+ * Version of __slab_alloc to use when we know that interrupts are
+ * already disabled (which is the case for bulk allocation).
  */
-static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
+static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 			  unsigned long addr, struct kmem_cache_cpu *c)
 {
 	void *freelist;
 	struct page *page;
-	unsigned long flags;
-
-	local_irq_save(flags);
-#ifdef CONFIG_PREEMPT
-	/*
-	 * We may have been preempted and rescheduled on a different
-	 * cpu before disabling interrupts. Need to reload cpu area
-	 * pointer.
-	 */
-	c = this_cpu_ptr(s->cpu_slab);
-#endif

 	page = c->page;
 	if (!page)
@@ -2374,7 +2366,6 @@ load_freelist:
 	VM_BUG_ON(!c->page->frozen);
 	c->freelist = get_freepointer(s, freelist);
 	c->tid = next_tid(c->tid);
-	local_irq_restore(flags);
 	return freelist;

 new_slab:
@@ -2391,7 +2382,6 @@ new_slab:

 	if (unlikely(!freelist)) {
 		slab_out_of_memory(s, gfpflags, node);
-		local_irq_restore(flags);
 		return NULL;
 	}

@@ -2407,11 +2397,35 @@ new_slab:
 	deactivate_slab(s, page, get_freepointer(s, freelist));
 	c->page = NULL;
 	c->freelist = NULL;
-	local_irq_restore(flags);
 	return freelist;
 }

 /*
+ * Another one that disabled interrupt and compensates for possible
+ * cpu changes by refetching the per cpu area pointer.
+ */
+static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
+			  unsigned long addr, struct kmem_cache_cpu *c)
+{
+	void *p;
+	unsigned long flags;
+
+	local_irq_save(flags);
+#ifdef CONFIG_PREEMPT
+	/*
+	 * We may have been preempted and rescheduled on a different
+	 * cpu before disabling interrupts. Need to reload cpu area
+	 * pointer.
+	 */
+	c = this_cpu_ptr(s->cpu_slab);
+#endif
+
+	p = ___slab_alloc(s, gfpflags, node, addr, c);
+	local_irq_restore(flags);
+	return p;
+}
+
+/*
  * Inlined fastpath so that allocation functions (kmalloc, kmem_cache_alloc)
  * have the fastpath folded into their functions. So no function call
  * overhead for requests that can be satisfied on the fastpath.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
