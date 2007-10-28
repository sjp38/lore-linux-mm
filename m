Date: Sun, 28 Oct 2007 15:05:50 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [patch 08/10] SLUB: Optional fast path using cmpxchg_local
In-Reply-To: <20071028033300.240703208@sgi.com>
Message-ID: <Pine.LNX.4.64.0710281502480.4207@sbz-30.cs.Helsinki.FI>
References: <20071028033156.022983073@sgi.com> <20071028033300.240703208@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matthew Wilcox <matthew@wil.cx>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 27 Oct 2007, Christoph Lameter wrote:
> The alternate path is realized using #ifdef's. Several attempts to do the
> same with macros and in line functions resulted in a mess (in particular due
> to the strange way that local_interrupt_save() handles its argument and due
> to the need to define macros/functions that sometimes disable interrupts
> and sometimes do something else. The macro based approaches made it also
> difficult to preserve the optimizations for the non cmpxchg paths).

I think at least slub_alloc() and slub_free() can be made simpler. See the 
included patch below.

> @@ -1496,7 +1496,12 @@ static void *__slab_alloc(struct kmem_ca
>  {
>  	void **object;
>  	struct page *new;
> +#ifdef CONFIG_FAST_CMPXCHG_LOCAL
> +	unsigned long flags;
>  
> +	local_irq_save(flags);
> +	preempt_enable_no_resched();
> +#endif
>  	if (!c->page)
>  		goto new_slab;
>  
> @@ -1518,6 +1523,10 @@ load_freelist:
>  unlock_out:
>  	slab_unlock(c->page);
>  out:
> +#ifdef CONFIG_FAST_CMPXCHG_LOCAL
> +	preempt_disable();
> +	local_irq_restore(flags);
> +#endif
>  	return object;

Can you please write a comment of the locking rules when cmpxchg_local() 
is used? Looks as if we could push that local_irq_save() to slub_lock() 
and local_irq_restore() to slub_unlock() and deal with the unused flags 
variable for the non-CONFIG_FAST_CMPXCHG_LOCAL case with a macro, no?

			Pekka

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 arch/x86/Kconfig.i386   |    4 +
 arch/x86/Kconfig.x86_64 |    4 +
 mm/slub.c               |  140 +++++++++++++++++++++++++++++++++++++++---------
 3 files changed, 122 insertions(+), 26 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c
+++ linux-2.6/mm/slub.c
@@ -1496,7 +1496,12 @@ static void *__slab_alloc(struct kmem_ca
 {
 	void **object;
 	struct page *new;
+#ifdef CONFIG_FAST_CMPXCHG_LOCAL
+	unsigned long flags;
 
+	local_irq_save(flags);
+	preempt_enable_no_resched();
+#endif
 	if (!c->page)
 		goto new_slab;
 
@@ -1518,6 +1523,10 @@ load_freelist:
 unlock_out:
 	slab_unlock(c->page);
 out:
+#ifdef CONFIG_FAST_CMPXCHG_LOCAL
+	preempt_disable();
+	local_irq_restore(flags);
+#endif
 	return object;
 
 another_slab:
@@ -1578,6 +1587,45 @@ debug:
 	goto unlock_out;
 }
 
+#ifdef CONFIG_FAST_CMPXHG_LOCAL
+static __always_inline void *do_slab_alloc(struct kmem_cache *s,
+		struct kmem_cache_cpu *c, gfp_t gfpflags, int node, void *addr)
+{
+	unsigned long flags;
+	void **object;
+
+	do {
+		object = c->freelist;
+		if (unlikely(is_end(object) || !node_match(c, node))) {
+			object = __slab_alloc(s, gfpflags, node, addr, c);
+			break;
+		}
+	} while (cmpxchg_local(&c->freelist, object, object[c->offset])
+								!= object);
+	put_cpu();
+
+	return object;
+}
+#else
+
+static __always_inline void *do_slab_alloc(struct kmem_cache *s,
+		struct kmem_cache_cpu *c, gfp_t gfpflags, int node, void *addr)
+{
+	unsigned long flags;
+	void **object;
+
+	local_irq_save(flags);
+	if (unlikely((is_end(c->freelist)) || !node_match(c, node))) {
+		object = __slab_alloc(s, gfpflags, node, addr, c);
+	} else {
+		object = c->freelist;
+		c->freelist = object[c->offset];
+	}
+	local_irq_restore(flags);
+	return object;
+}
+#endif
+
 /*
  * Inlined fastpath so that allocation functions (kmalloc, kmem_cache_alloc)
  * have the fastpath folded into their functions. So no function call
@@ -1591,24 +1639,13 @@ debug:
 static void __always_inline *slab_alloc(struct kmem_cache *s,
 		gfp_t gfpflags, int node, void *addr)
 {
-	void **object;
-	unsigned long flags;
 	struct kmem_cache_cpu *c;
+	void **object;
 
-	local_irq_save(flags);
 	c = get_cpu_slab(s, smp_processor_id());
-	if (unlikely((is_end(c->freelist)) || !node_match(c, node))) {
-
-		object = __slab_alloc(s, gfpflags, node, addr, c);
-		if (unlikely(!object)) {
-			local_irq_restore(flags);
-			goto out;
-		}
-	} else {
-		object = c->freelist;
-		c->freelist = object[c->offset];
-	}
-	local_irq_restore(flags);
+	object = do_slab_alloc(s, c, gfpflags, node, addr);
+	if (unlikely(!object))
+		goto out;
 
 	if (unlikely((gfpflags & __GFP_ZERO)))
 		memset(object, 0, c->objsize);
@@ -1644,6 +1681,11 @@ static void __slab_free(struct kmem_cach
 	void *prior;
 	void **object = (void *)x;
 
+#ifdef CONFIG_FAST_CMPXCHG_LOCAL
+	unsigned long flags;
+
+	local_irq_save(flags);
+#endif
 	slab_lock(page);
 
 	if (unlikely(SlabDebug(page)))
@@ -1669,6 +1711,9 @@ checks_ok:
 
 out_unlock:
 	slab_unlock(page);
+#ifdef CONFIG_FAST_CMPXCHG_LOCAL
+	local_irq_restore(flags);
+#endif
 	return;
 
 slab_empty:
@@ -1679,6 +1724,9 @@ slab_empty:
 		remove_partial(s, page);
 
 	slab_unlock(page);
+#ifdef CONFIG_FAST_CMPXCHG_LOCAL
+	local_irq_restore(flags);
+#endif
 	discard_slab(s, page);
 	return;
 
@@ -1688,6 +1736,56 @@ debug:
 	goto checks_ok;
 }
 
+#ifdef CONFIG_FAST_CMPXCHG_LOCAL
+static __always_inline void do_slab_free(struct kmem_cache *s,
+		struct page *page, void **object, void *addr)
+{
+	struct kmem_cache_cpu *c;
+	void **freelist;
+
+	c = get_cpu_slab(s, get_cpu());
+	do {
+		freelist = c->freelist;
+		barrier();
+		/*
+		 * If the compiler would reorder the retrieval of c->page to
+		 * come before c->freelist then an interrupt could
+		 * change the cpu slab before we retrieve c->freelist. We
+		 * could be matching on a page no longer active and put the
+		 * object onto the freelist of the wrong slab.
+		 *
+		 * On the other hand: If we already have the freelist pointer
+		 * then any change of cpu_slab will cause the cmpxchg to fail
+		 * since the freelist pointers are unique per slab.
+		 */
+		if (unlikely(page != c->page || c->node < 0)) {
+			__slab_free(s, page, object, addr, c->offset);
+			break;
+		}
+		object[c->offset] = freelist;
+	} while (cmpxchg_local(&c->freelist, freelist, object) != freelist);
+	put_cpu();
+}
+#else
+
+static __always_inline void do_slab_free(struct kmem_cache *s,
+		struct page *page, void **object, void *addr)
+{
+	struct kmem_cache_cpu *c;
+	unsigned long flags;
+
+	c = get_cpu_slab(s, smp_processor_id());
+	local_irq_save(flags);
+	if (likely(page == c->page && c->node >= 0)) {
+		object[c->offset] = c->freelist;
+		c->freelist = object;
+	} else
+		__slab_free(s, page, object, addr, c->offset);
+
+	local_irq_restore(flags);
+}
+#endif
+
 /*
  * Fastpath with forced inlining to produce a kfree and kmem_cache_free that
  * can perform fastpath freeing without additional function calls.
@@ -1703,19 +1801,9 @@ static void __always_inline slab_free(st
 			struct page *page, void *x, void *addr)
 {
 	void **object = (void *)x;
-	unsigned long flags;
-	struct kmem_cache_cpu *c;
 
-	local_irq_save(flags);
 	debug_check_no_locks_freed(object, s->objsize);
-	c = get_cpu_slab(s, smp_processor_id());
-	if (likely(page == c->page && c->node >= 0)) {
-		object[c->offset] = c->freelist;
-		c->freelist = object;
-	} else
-		__slab_free(s, page, x, addr, c->offset);
-
-	local_irq_restore(flags);
+	do_slab_free(s, page, object, addr);
 }
 
 void kmem_cache_free(struct kmem_cache *s, void *x)
Index: linux-2.6/arch/x86/Kconfig.i386
===================================================================
--- linux-2.6.orig/arch/x86/Kconfig.i386
+++ linux-2.6/arch/x86/Kconfig.i386
@@ -51,6 +51,10 @@ config X86
 	bool
 	default y
 
+config FAST_CMPXCHG_LOCAL
+	bool
+	default y
+
 config MMU
 	bool
 	default y
Index: linux-2.6/arch/x86/Kconfig.x86_64
===================================================================
--- linux-2.6.orig/arch/x86/Kconfig.x86_64
+++ linux-2.6/arch/x86/Kconfig.x86_64
@@ -97,6 +97,10 @@ config X86_CMPXCHG
 	bool
 	default y
 
+config FAST_CMPXCHG_LOCAL
+	bool
+	default y
+
 config EARLY_PRINTK
 	bool
 	default y

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
