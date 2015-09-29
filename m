Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id EFA266B0258
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 11:46:53 -0400 (EDT)
Received: by qgx61 with SMTP id 61so9653757qgx.3
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 08:46:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 71si21670313qhx.74.2015.09.29.08.46.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 08:46:53 -0700 (PDT)
Subject: [MM PATCH V4 1/6] slub: create new ___slab_alloc function that can
 be called with irqs disabled
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 29 Sep 2015 17:47:12 +0200
Message-ID: <20150929154702.14465.68483.stgit@canyon>
In-Reply-To: <20150929154605.14465.98995.stgit@canyon>
References: <20150929154605.14465.98995.stgit@canyon>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Christoph Lameter <cl@linux.com>

NOTICE: Accepted by AKPM
 http://ozlabs.org/~akpm/mmots/broken-out/slub-create-new-___slab_alloc-function-that-can-be-called-with-irqs-disabled.patch

Bulk alloc needs a function like that because it enables interrupts before
calling __slab_alloc which promptly disables them again using the expensive
local_irq_save().

Signed-off-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slub.c |   44 +++++++++++++++++++++++++++++---------------
 1 file changed, 29 insertions(+), 15 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index f614b5dc396b..02cfb3a5983e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2298,23 +2298,15 @@ static inline void *get_freelist(struct kmem_cache *s, struct page *page)
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
@@ -2372,7 +2364,6 @@ load_freelist:
 	VM_BUG_ON(!c->page->frozen);
 	c->freelist = get_freepointer(s, freelist);
 	c->tid = next_tid(c->tid);
-	local_irq_restore(flags);
 	return freelist;
 
 new_slab:
@@ -2389,7 +2380,6 @@ new_slab:
 
 	if (unlikely(!freelist)) {
 		slab_out_of_memory(s, gfpflags, node);
-		local_irq_restore(flags);
 		return NULL;
 	}
 
@@ -2405,11 +2395,35 @@ new_slab:
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
