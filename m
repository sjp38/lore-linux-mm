Date: Mon, 9 Jul 2007 17:55:30 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 00/10] [RFC] SLUB patches for more functionality,
 performance and maintenance
In-Reply-To: <20070709225817.GA5111@Krystal>
Message-ID: <Pine.LNX.4.64.0707091715450.2062@schroedinger.engr.sgi.com>
References: <20070708034952.022985379@sgi.com> <p73y7hrywel.fsf@bingen.suse.de>
 <Pine.LNX.4.64.0707090845520.13792@schroedinger.engr.sgi.com>
 <46925B5D.8000507@google.com> <Pine.LNX.4.64.0707091055090.16207@schroedinger.engr.sgi.com>
 <4692A1D0.50308@mbligh.org> <20070709214426.GC1026@Krystal>
 <Pine.LNX.4.64.0707091451200.18780@schroedinger.engr.sgi.com>
 <20070709225817.GA5111@Krystal>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: Martin Bligh <mbligh@mbligh.org>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Ok here is a replacement patch for the cmpxchg patch. Problems

1. cmpxchg_local is not available on all arches. If we wanted to do
   this then it needs to be universally available.

2. cmpxchg_local does generate the "lock" prefix. It should not do that.
   Without fixes to cmpxchg_local we cannot expect maximum performance.

3. The approach is x86 centric. It relies on a cmpxchg that does not
   synchronize with memory used by other cpus and therefore is more
   lightweight. As far as I know the IA64 cmpxchg cannot do that.
   Neither several other processors. I am not sure how cmpxchgless
   platforms would use that. We need a detailed comparison of
   interrupt enable /disable vs. cmpxchg cycle counts for cachelines in
   the cpu cache to evaluate the impact that such a change would have.

   The cmpxchg (or its emulation) does not need any barriers since the
   accesses can only come from a single processor. 

Mathieu measured a significant performance benefit coming from not using
interrupt enable / disable.

Some rough processor cycle counts (anyone have better numbers?)

	STI	CLI	CMPXCHG
IA32	36	26	1 (assume XCHG == CMPXCHG, sti/cli also need stack pushes/pulls)
IA64	12	12	1 (but ar.ccv needs 11 cycles to set comparator,
			need register moves to preserve processors flags)

Looks like STI/CLI is pretty expensive and it seems that we may be able to
optimize the alloc / free hotpath quite a bit if we could drop the 
interrupt enable / disable. But we need some measurements.


Draft of a new patch:

SLUB: Single atomic instruction alloc/free using cmpxchg_local

A cmpxchg allows us to avoid disabling and enabling interrupts. The cmpxchg
is optimal to allow operations on per cpu freelist. We can stay on one
processor by disabling preemption() and allowing concurrent interrupts
thus avoiding the overhead of disabling and enabling interrupts.

Pro:
	- No need to disable interrupts.
	- Preempt disable /enable vanishes on non preempt kernels
Con:
        - Slightly complexer handling.
	- Updates to atomic instructions needed

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   72 ++++++++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 49 insertions(+), 23 deletions(-)

Index: linux-2.6.22-rc6-mm1/mm/slub.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/slub.c	2007-07-09 15:04:46.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/slub.c	2007-07-09 17:09:00.000000000 -0700
@@ -1467,12 +1467,14 @@ static void *__slab_alloc(struct kmem_ca
 {
 	void **object;
 	struct page *new;
+	unsigned long flags;
 
+	local_irq_save(flags);
 	if (!c->page)
 		goto new_slab;
 
 	slab_lock(c->page);
-	if (unlikely(!node_match(c, node)))
+	if (unlikely(!node_match(c, node) || c->freelist))
 		goto another_slab;
 load_freelist:
 	object = c->page->freelist;
@@ -1486,7 +1488,14 @@ load_freelist:
 	c->page->inuse = s->objects;
 	c->page->freelist = NULL;
 	c->node = page_to_nid(c->page);
+out:
 	slab_unlock(c->page);
+	local_irq_restore(flags);
+	preempt_enable();
+
+	if (unlikely((gfpflags & __GFP_ZERO)))
+		memset(object, 0, c->objsize);
+
 	return object;
 
 another_slab:
@@ -1527,6 +1536,8 @@ new_slab:
 		c->page = new;
 		goto load_freelist;
 	}
+	local_irq_restore(flags);
+	preempt_enable();
 	return NULL;
 debug:
 	c->freelist = NULL;
@@ -1536,8 +1547,7 @@ debug:
 
 	c->page->inuse++;
 	c->page->freelist = object[c->offset];
-	slab_unlock(c->page);
-	return object;
+	goto out;
 }
 
 /*
@@ -1554,23 +1564,20 @@ static void __always_inline *slab_alloc(
 		gfp_t gfpflags, int node, void *addr)
 {
 	void **object;
-	unsigned long flags;
 	struct kmem_cache_cpu *c;
 
-	local_irq_save(flags);
+	preempt_disable();
 	c = get_cpu_slab(s, smp_processor_id());
-	if (unlikely(!c->page || !c->freelist ||
-					!node_match(c, node)))
+redo:
+	object = c->freelist;
+	if (unlikely(!object || !node_match(c, node)))
+		return __slab_alloc(s, gfpflags, node, addr, c);
 
-		object = __slab_alloc(s, gfpflags, node, addr, c);
+	if (cmpxchg_local(&c->freelist, object, object[c->offset]) != object)
+		goto redo;
 
-	else {
-		object = c->freelist;
-		c->freelist = object[c->offset];
-	}
-	local_irq_restore(flags);
-
-	if (unlikely((gfpflags & __GFP_ZERO) && object))
+	preempt_enable();
+	if (unlikely((gfpflags & __GFP_ZERO)))
 		memset(object, 0, c->objsize);
 
 	return object;
@@ -1603,7 +1610,9 @@ static void __slab_free(struct kmem_cach
 {
 	void *prior;
 	void **object = (void *)x;
+	unsigned long flags;
 
+	local_irq_save(flags);
 	slab_lock(page);
 
 	if (unlikely(SlabDebug(page)))
@@ -1629,6 +1638,8 @@ checks_ok:
 
 out_unlock:
 	slab_unlock(page);
+	local_irq_restore(flags);
+	preempt_enable();
 	return;
 
 slab_empty:
@@ -1639,6 +1650,8 @@ slab_empty:
 		remove_partial(s, page);
 
 	slab_unlock(page);
+	local_irq_restore(flags);
+	preempt_enable();
 	discard_slab(s, page);
 	return;
 
@@ -1663,18 +1676,31 @@ static void __always_inline slab_free(st
 			struct page *page, void *x, void *addr)
 {
 	void **object = (void *)x;
-	unsigned long flags;
 	struct kmem_cache_cpu *c;
+	void **freelist;
 
-	local_irq_save(flags);
+	preempt_disable();
 	c = get_cpu_slab(s, smp_processor_id());
-	if (likely(page == c->page && c->freelist)) {
-		object[c->offset] = c->freelist;
-		c->freelist = object;
-	} else
-		__slab_free(s, page, x, addr, c->offset);
+redo:
+	freelist = c->freelist;
+	/*
+	 * Must read freelist before c->page. If a interrupt occurs and
+	 * changes c->page after we have read it here then it
+	 * will also have changed c->freelist and the cmpxchg will fail.
+	 *
+	 * If we would have checked c->page first then the freelist could
+	 * have been changed under us before we read c->freelist and we
+	 * would not be able to detect that situation.
+	 */
+	smp_rmb();
+	if (unlikely(page != c->page || !freelist))
+		return __slab_free(s, page, x, addr, c->offset);
+
+	object[c->offset] = freelist;
+	if (cmpxchg_local(&c->freelist, freelist, object) != freelist)
+		goto redo;
 
-	local_irq_restore(flags);
+	preempt_enable();
 }
 
 void kmem_cache_free(struct kmem_cache *s, void *x)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
