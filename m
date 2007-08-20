Subject: [RFC][PATCH] slub: -rt port
From: Peter Zijlstra <peterz@infradead.org>
Content-Type: text/plain
Date: Mon, 20 Aug 2007 13:13:41 +0200
Message-Id: <1187608421.6114.198.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Subject: slub: -rt port
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

My current -rt port of slub.

I haven't compiled the !PREEMPT_RT code paths yet since I still get some
hard to catch corruption somewhere (takes about 20 min with a load of
120 to trigger on my dual code opteron)

I'm posting so that other people can have a look at the code and ideas.

against: 2.6.23-rc2-rt2

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/gfp.h        |    1 
 include/linux/mm.h         |    1 
 include/linux/page-flags.h |    1 
 include/linux/slub_def.h   |    2 
 init/Kconfig               |    1 
 mm/page_alloc.c            |   10 -
 mm/slub.c                  |  375 ++++++++++++++++++++++++++++++++++-----------
 mm/swap.c                  |    5 
 8 files changed, 300 insertions(+), 96 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c
+++ linux-2.6/mm/slub.c
@@ -20,6 +20,7 @@
 #include <linux/mempolicy.h>
 #include <linux/ctype.h>
 #include <linux/kallsyms.h>
+#include <linux/pagemap.h>
 
 /*
  * Lock order:
@@ -99,6 +100,8 @@
  * 			the fast path and disables lockless freelists.
  */
 
+#ifndef CONFIG_PREEMPT_RT
+
 #define FROZEN (1 << PG_active)
 
 #ifdef CONFIG_SLUB_DEBUG
@@ -137,6 +140,46 @@ static inline void ClearSlabDebug(struct
 	page->flags &= ~SLABDEBUG;
 }
 
+#else /* CONFIG_PREEMPT_RT */
+/*
+ * when the allocator is preemptible these operations might be concurrent with
+ * lock_page(), and hence need atomic ops.
+ */
+
+#define PG_frozen		PG_active
+#define PG_debug		PG_error
+
+static inline int SlabFrozen(struct page *page)
+{
+	return test_bit(PG_frozen, &page->flags);
+}
+
+static inline void SetSlabFrozen(struct page *page)
+{
+	set_bit(PG_frozen, &page->flags);
+}
+
+static inline void ClearSlabFrozen(struct page *page)
+{
+	clear_bit(PG_frozen, &page->flags);
+}
+
+static inline int SlabDebug(struct page *page)
+{
+	return test_bit(PG_debug, &page->flags);
+}
+
+static inline void SetSlabDebug(struct page *page)
+{
+	set_bit(PG_debug, &page->flags);
+}
+
+static inline void ClearSlabDebug(struct page *page)
+{
+	clear_bit(PG_debug, &page->flags);
+}
+#endif
+
 /*
  * Issues still to be resolved:
  *
@@ -1081,7 +1124,7 @@ static struct page *new_slab(struct kmem
 	BUG_ON(flags & ~(GFP_DMA | __GFP_ZERO | GFP_LEVEL_MASK));
 
 	if (flags & __GFP_WAIT)
-		local_irq_enable();
+		local_irq_enable_nort();
 
 	page = allocate_slab(s, flags & GFP_LEVEL_MASK, node);
 	if (!page)
@@ -1117,13 +1160,14 @@ static struct page *new_slab(struct kmem
 	page->inuse = 0;
 out:
 	if (flags & __GFP_WAIT)
-		local_irq_disable();
+		local_irq_disable_nort();
 	return page;
 }
 
 static void __free_slab(struct kmem_cache *s, struct page *page)
 {
 	int pages = 1 << s->order;
+	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
 
 	if (unlikely(SlabDebug(page))) {
 		void *p;
@@ -1139,8 +1183,13 @@ static void __free_slab(struct kmem_cach
 		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
 		- pages);
 
+	atomic_long_dec(&n->nr_slabs);
+
+	reset_page_mapcount(page);
+	ClearPageSlab(page);
 	page->mapping = NULL;
-	__free_pages(page, s->order);
+
+	___free_pages(page, s->order);
 }
 
 static void rcu_free_slab(struct rcu_head *h)
@@ -1164,19 +1213,33 @@ static void free_slab(struct kmem_cache 
 		__free_slab(s, page);
 }
 
-static void discard_slab(struct kmem_cache *s, struct page *page)
+void slab_put(struct kmem_cache *s, struct page *page)
 {
-	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
+	if (put_page_testzero(page))
+		free_slab(s, page);
+}
 
-	atomic_long_dec(&n->nr_slabs);
-	reset_page_mapcount(page);
-	__ClearPageSlab(page);
-	free_slab(s, page);
+static struct page *slab_get(struct kmem_cache *s, int cpu)
+{
+	struct page *page;
+
+	do {
+		page = rcu_dereference(s->cpu_slab[cpu]);
+
+		if (page && get_page_unless_zero(page)) {
+			if (page == s->cpu_slab[cpu])
+				return page;
+			put_page(page);
+		}
+	} while (page);
+
+	return NULL;
 }
 
 /*
  * Per slab locking using the pagelock
  */
+#ifndef CONFIG_PREEMPT_RT
 static __always_inline void slab_lock(struct page *page)
 {
 	bit_spin_lock(PG_locked, &page->flags);
@@ -1194,6 +1257,22 @@ static __always_inline int slab_trylock(
 	rc = bit_spin_trylock(PG_locked, &page->flags);
 	return rc;
 }
+#else
+static __always_inline void slab_lock(struct page *page)
+{
+	lock_page_nosync(page);
+}
+
+static __always_inline void slab_unlock(struct page *page)
+{
+	unlock_page(page);
+}
+
+static __always_inline int slab_trylock(struct page *page)
+{
+	return !TestSetPageLocked(page);
+}
+#endif
 
 /*
  * Management of partially allocated slabs
@@ -1214,8 +1293,7 @@ static void add_partial(struct kmem_cach
 	spin_unlock(&n->list_lock);
 }
 
-static void remove_partial(struct kmem_cache *s,
-						struct page *page)
+static void remove_partial(struct kmem_cache *s, struct page *page)
 {
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
 
@@ -1338,11 +1416,13 @@ static struct page *get_partial(struct k
  *
  * On exit the slab lock will have been dropped.
  */
-static void unfreeze_slab(struct kmem_cache *s, struct page *page)
+static void return_slab(struct kmem_cache *s, struct page *page)
 {
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
 
-	ClearSlabFrozen(page);
+	BUG_ON(!PageLocked(page));
+	BUG_ON(SlabFrozen(page));
+
 	if (page->inuse) {
 
 		if (page->freelist)
@@ -1365,53 +1445,136 @@ static void unfreeze_slab(struct kmem_ca
 			slab_unlock(page);
 		} else {
 			slab_unlock(page);
-			discard_slab(s, page);
+			slab_put(s, page);
 		}
 	}
 }
 
+#define slab_cmpxchg(__p, __o, __n) \
+ 	((__typeof__(*(__p)))atomic_long_cmpxchg((atomic_long_t *)(__p), (__o), (__n)))
+
 /*
- * Remove the cpu slab
+ * get an object from the lockless freelist.
  */
-static void deactivate_slab(struct kmem_cache *s, struct page *page, int cpu)
+static __always_inline
+void **get_object_lockless(struct page *page)
+{
+	void **object;
+
+	BUG_ON(!page_count(page));
+
+again:
+	object = rcu_dereference(page->lockless_freelist);
+	if (object && slab_cmpxchg(&page->lockless_freelist,
+				object, object[page->offset]) != object)
+		goto again;
+
+	return object;
+}
+
+/*
+ * try to put the object on the lockless freelist
+ * fails if the lockless_freelist is empty and !create
+ */
+static __always_inline
+bool put_object_lockless(struct page *page, void *x, int create)
+{
+	void **object = (void *)x;
+	void **freelist = rcu_dereference(page->lockless_freelist);
+	void **old_freelist;
+
+	/*
+	 * the regular freelist must be empty when we create the
+	 * lockless_freelist
+	 */
+	BUG_ON(create && page->freelist);
+	BUG_ON(!page_count(page));
+
+	while (create || freelist) {
+		object[page->offset] = freelist;
+		old_freelist = slab_cmpxchg(&page->lockless_freelist,
+					    freelist, object);
+		if (old_freelist == freelist)
+			return true;
+		freelist = old_freelist;
+	}
+	return false;
+}
+
+static void unfreeze_slab(struct kmem_cache *s, struct page *page)
 {
+	BUG_ON(!PageLocked(page));
+	BUG_ON(!SlabFrozen(page));
+
+	ClearSlabFrozen(page);
+
 	/*
 	 * Merge cpu freelist into freelist. Typically we get here
 	 * because both freelists are empty. So this is unlikely
 	 * to occur.
 	 */
-	while (unlikely(page->lockless_freelist)) {
+	for (;;) {
 		void **object;
 
 		/* Retrieve object from cpu_freelist */
-		object = page->lockless_freelist;
-		page->lockless_freelist = page->lockless_freelist[page->offset];
+		object = get_object_lockless(page);
+		if (likely(!object))
+			break;
 
 		/* And put onto the regular freelist */
 		object[page->offset] = page->freelist;
 		page->freelist = object;
 		page->inuse--;
 	}
-	s->cpu_slab[cpu] = NULL;
+
+	return_slab(s, page);
+}
+
+/*
+ * Remove the cpu slab
+ */
+static void deactivate_slab(struct kmem_cache *s, struct page *page, int cpu)
+{
+	if (unlikely(slab_cmpxchg(&s->cpu_slab[cpu], page, NULL) != page))
+		BUG();
+
 	unfreeze_slab(s, page);
 }
 
-static inline void flush_slab(struct kmem_cache *s, struct page *page, int cpu)
+/*
+ * Get and lock the CPUs slab
+ */
+struct page *slab_lock_cpu(struct kmem_cache *s, int cpu)
 {
+	struct page *page;
+
+again:
+	page = slab_get(s, cpu);
+	if (!page)
+		goto out;
+
 	slab_lock(page);
-	deactivate_slab(s, page, cpu);
+	if (unlikely(page != rcu_dereference(s->cpu_slab[cpu]))) {
+		slab_unlock(page);
+		slab_put(s, page);
+		goto again;
+	}
+	slab_put(s, page);
+out:
+	return page;
 }
 
 /*
  * Flush cpu slab.
  * Called from IPI handler with interrupts disabled.
  */
-static inline void __flush_cpu_slab(struct kmem_cache *s, int cpu)
+static void __slab_flush_cpu(struct kmem_cache *s, int cpu)
 {
-	struct page *page = s->cpu_slab[cpu];
+	struct page *page;
 
+	page = slab_lock_cpu(s, cpu);
 	if (likely(page))
-		flush_slab(s, page, cpu);
+		deactivate_slab(s, page, cpu);
 }
 
 static void flush_cpu_slab(void *d)
@@ -1419,19 +1582,23 @@ static void flush_cpu_slab(void *d)
 	struct kmem_cache *s = d;
 	int cpu = smp_processor_id();
 
-	__flush_cpu_slab(s, cpu);
+	__slab_flush_cpu(s, cpu);
 }
 
 static void flush_all(struct kmem_cache *s)
 {
 #ifdef CONFIG_SMP
+#ifdef CONFIG_PREEMPT_RT
+	schedule_on_each_cpu(flush_cpu_slab, s, 1, 1);
+#else
 	on_each_cpu(flush_cpu_slab, s, 1, 1);
+#endif
 #else
 	unsigned long flags;
 
-	local_irq_save(flags);
+	local_irq_save_nort(flags);
 	flush_cpu_slab(s);
-	local_irq_restore(flags);
+	local_irq_restore_nort(flags);
 #endif
 }
 
@@ -1453,18 +1620,33 @@ static void flush_all(struct kmem_cache 
  * we need to allocate a new slab. This is slowest path since we may sleep.
  */
 static void *__slab_alloc(struct kmem_cache *s,
-		gfp_t gfpflags, int node, void *addr, struct page *page)
+		gfp_t gfpflags, int node, void *addr)
 {
 	void **object;
-	int cpu = smp_processor_id();
+	int cpu;
+	unsigned long flags;
+	struct page *page;
+	struct page *cur_page;
+
+	local_irq_save_nort(flags);
 
+again:
+	cpu = raw_smp_processor_id();
+	page = slab_lock_cpu(s, cpu);
 	if (!page)
 		goto new_slab;
 
-	slab_lock(page);
 	if (unlikely(node != -1 && page_to_nid(page) != node))
 		goto another_slab;
 load_freelist:
+	object = get_object_lockless(page);
+	if (unlikely(object)) {
+		/*
+		 * if there is an lockless_freelist, the freelist should be empty.
+		 */
+		BUG_ON(page->freelist);
+		goto out;
+	}
 	object = page->freelist;
 	if (unlikely(!object))
 		goto another_slab;
@@ -1472,10 +1654,15 @@ load_freelist:
 		goto debug;
 
 	object = page->freelist;
-	page->lockless_freelist = object[page->offset];
+	if (unlikely(slab_cmpxchg(&page->lockless_freelist,
+					NULL, object[page->offset]) != NULL)) {
+		BUG();
+	}
 	page->inuse = s->objects;
 	page->freelist = NULL;
+out:
 	slab_unlock(page);
+	local_irq_restore_nort(flags);
 	return object;
 
 another_slab:
@@ -1483,42 +1670,21 @@ another_slab:
 
 new_slab:
 	page = get_partial(s, gfpflags, node);
-	if (page) {
-		s->cpu_slab[cpu] = page;
-		goto load_freelist;
-	}
+	if (page)
+		goto try_flip;
 
 	page = new_slab(s, gfpflags, node);
 	if (page) {
-		cpu = smp_processor_id();
-		if (s->cpu_slab[cpu]) {
-			/*
-			 * Someone else populated the cpu_slab while we
-			 * enabled interrupts, or we have gotten scheduled
-			 * on another cpu. The page may not be on the
-			 * requested node even if __GFP_THISNODE was
-			 * specified. So we need to recheck.
-			 */
-			if (node == -1 ||
-				page_to_nid(s->cpu_slab[cpu]) == node) {
-				/*
-				 * Current cpuslab is acceptable and we
-				 * want the current one since its cache hot
-				 */
-				discard_slab(s, page);
-				page = s->cpu_slab[cpu];
-				slab_lock(page);
-				goto load_freelist;
-			}
-			/* New slab does not fit our expectations */
-			flush_slab(s, s->cpu_slab[cpu], cpu);
-		}
-		slab_lock(page);
+		if (unlikely(!slab_trylock(page)))
+			BUG();
 		SetSlabFrozen(page);
-		s->cpu_slab[cpu] = page;
-		goto load_freelist;
+		cpu = raw_smp_processor_id();
+		goto try_flip;
 	}
+
+	local_irq_restore_nort(flags);
 	return NULL;
+
 debug:
 	object = page->freelist;
 	if (!alloc_debug_processing(s, page, object, addr))
@@ -1526,8 +1692,30 @@ debug:
 
 	page->inuse++;
 	page->freelist = object[page->offset];
-	slab_unlock(page);
-	return object;
+	goto out;
+
+try_flip:
+	cur_page = slab_cmpxchg(&s->cpu_slab[cpu], NULL, page);
+	if (cur_page) {
+		/*
+		 * Someone else populated the cpu_slab while we
+		 * enabled interrupts, or we have gotten scheduled
+		 * on another cpu. The page may not be on the
+		 * requested node even if __GFP_THISNODE was
+		 * specified. So we need to recheck.
+		 */
+		if (node == -1 || page_to_nid(cur_page) == node) {
+			/*
+			 * We want the current one since its cache hot.
+			 */
+			unfreeze_slab(s, page);
+			goto again;
+		}
+		/* The current slab does not fit our requirement */
+		__slab_flush_cpu(s, cpu);
+		goto try_flip;
+	}
+	goto load_freelist;
 }
 
 /*
@@ -1545,20 +1733,20 @@ static void __always_inline *slab_alloc(
 {
 	struct page *page;
 	void **object;
-	unsigned long flags;
+	int cpu = raw_smp_processor_id();
 
-	local_irq_save(flags);
-	page = s->cpu_slab[smp_processor_id()];
-	if (unlikely(!page || !page->lockless_freelist ||
-			(node != -1 && page_to_nid(page) != node)))
-
-		object = __slab_alloc(s, gfpflags, node, addr, page);
-
-	else {
-		object = page->lockless_freelist;
-		page->lockless_freelist = object[page->offset];
+	page = slab_get(s, cpu);
+	if (unlikely(!page || (node != -1 && page_to_nid(page) != node))) {
+		if (page)
+			slab_put(s, page);
+do_alloc:
+		object = __slab_alloc(s, gfpflags, node, addr);
+	} else {
+		object = get_object_lockless(page);
+		slab_put(s, page);
+		if (unlikely(!object))
+			goto do_alloc;
 	}
-	local_irq_restore(flags);
 
 	if (unlikely((gfpflags & __GFP_ZERO) && object))
 		memset(object, 0, s->objsize);
@@ -1593,11 +1781,21 @@ static void __slab_free(struct kmem_cach
 {
 	void *prior;
 	void **object = (void *)x;
+	unsigned long flags;
 
+	local_irq_save_nort(flags);
+	/*
+	 * If there is no lockless_freelist we need to lock the slab and check
+	 * SlabFrozen to see if its allowed to create the lockless_freelist.
+	 */
 	slab_lock(page);
 
 	if (unlikely(SlabDebug(page)))
 		goto debug;
+
+	if (SlabFrozen(page) && put_object_lockless(page, x, 1))
+		goto out_unlock;
+
 checks_ok:
 	prior = object[page->offset] = page->freelist;
 	page->freelist = object;
@@ -1619,6 +1817,7 @@ checks_ok:
 
 out_unlock:
 	slab_unlock(page);
+	local_irq_restore_nort(flags);
 	return;
 
 slab_empty:
@@ -1629,7 +1828,8 @@ slab_empty:
 		remove_partial(s, page);
 
 	slab_unlock(page);
-	discard_slab(s, page);
+	slab_put(s, page);
+	local_irq_restore_nort(flags);
 	return;
 
 debug:
@@ -1653,18 +1853,11 @@ static void __always_inline slab_free(st
 			struct page *page, void *x, void *addr)
 {
 	void **object = (void *)x;
-	unsigned long flags;
 
-	local_irq_save(flags);
 	debug_check_no_locks_freed(object, s->objsize);
-	if (likely(page == s->cpu_slab[smp_processor_id()] &&
-						!SlabDebug(page))) {
-		object[page->offset] = page->lockless_freelist;
-		page->lockless_freelist = object;
-	} else
+	if (unlikely(SlabDebug(page)) ||
+			!put_object_lockless(page, x, 0))
 		__slab_free(s, page, x, addr);
-
-	local_irq_restore(flags);
 }
 
 void kmem_cache_free(struct kmem_cache *s, void *x)
@@ -2159,7 +2352,7 @@ static int free_list(struct kmem_cache *
 	list_for_each_entry_safe(page, h, list, lru)
 		if (!page->inuse) {
 			list_del(&page->lru);
-			discard_slab(s, page);
+			slab_put(s, page);
 		} else
 			slabs_inuse++;
 	spin_unlock_irqrestore(&n->list_lock, flags);
@@ -2498,7 +2691,7 @@ int kmem_cache_shrink(struct kmem_cache 
 				list_del(&page->lru);
 				n->nr_partial--;
 				slab_unlock(page);
-				discard_slab(s, page);
+				slab_put(s, page);
 			} else {
 				if (n->nr_partial > MAX_PARTIAL)
 					list_move(&page->lru,
@@ -2730,9 +2923,9 @@ static int __cpuinit slab_cpuup_callback
 	case CPU_DEAD_FROZEN:
 		down_read(&slub_lock);
 		list_for_each_entry(s, &slab_caches, list) {
-			local_irq_save(flags);
-			__flush_cpu_slab(s, cpu);
-			local_irq_restore(flags);
+			local_irq_save_nort(flags);
+			__slab_flush_cpu(s, cpu);
+			local_irq_restore_nort(flags);
 		}
 		up_read(&slub_lock);
 		break;
Index: linux-2.6/init/Kconfig
===================================================================
--- linux-2.6.orig/init/Kconfig
+++ linux-2.6/init/Kconfig
@@ -561,7 +561,6 @@ config SLAB
 
 config SLUB
 	bool "SLUB (Unqueued Allocator)"
-	depends on !PREEMPT_RT
 	help
 	   SLUB is a slab allocator that minimizes cache line usage
 	   instead of managing queues of cached objects (SLAB approach).
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -290,7 +290,6 @@ static inline int put_page_testzero(stru
  */
 static inline int get_page_unless_zero(struct page *page)
 {
-	VM_BUG_ON(PageCompound(page));
 	return atomic_inc_not_zero(&page->_count);
 }
 
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -164,6 +164,7 @@ static inline void SetPageUptodate(struc
 
 #define PageSlab(page)		test_bit(PG_slab, &(page)->flags)
 #define __SetPageSlab(page)	__set_bit(PG_slab, &(page)->flags)
+#define ClearPageSlab(page)	clear_bit(PG_slab, &(page)->flags)
 #define __ClearPageSlab(page)	__clear_bit(PG_slab, &(page)->flags)
 
 #ifdef CONFIG_HIGHMEM
Index: linux-2.6/include/linux/gfp.h
===================================================================
--- linux-2.6.orig/include/linux/gfp.h
+++ linux-2.6/include/linux/gfp.h
@@ -184,6 +184,7 @@ extern unsigned long FASTCALL(get_zeroed
 #define __get_dma_pages(gfp_mask, order) \
 		__get_free_pages((gfp_mask) | GFP_DMA,(order))
 
+extern void FASTCALL(___free_pages(struct page *page, unsigned int order));
 extern void FASTCALL(__free_pages(struct page *page, unsigned int order));
 extern void FASTCALL(free_pages(unsigned long addr, unsigned int order));
 extern void FASTCALL(free_hot_page(struct page *page));
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -1479,14 +1479,18 @@ void __pagevec_free(struct pagevec *pvec
 		free_hot_cold_page(pvec->pages[i], pvec->cold);
 }
 
-fastcall void __free_pages(struct page *page, unsigned int order)
+fastcall void ___free_pages(struct page *page, unsigned int order)
 {
-	if (put_page_testzero(page)) {
 		if (order == 0)
 			free_hot_page(page);
 		else
 			__free_pages_ok(page, order);
-	}
+}
+
+fastcall void __free_pages(struct page *page, unsigned int order)
+{
+	if (put_page_testzero(page))
+		___free_pages(page, order);
 }
 
 EXPORT_SYMBOL(__free_pages);
Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c
+++ linux-2.6/mm/swap.c
@@ -66,6 +66,11 @@ static void put_compound_page(struct pag
 
 void put_page(struct page *page)
 {
+#ifdef CONFIG_SLUB
+	if (unlikely(PageSlab(page)))
+		slab_put(page->slab, page);
+	else
+#endif
 	if (unlikely(PageCompound(page)))
 		put_compound_page(page);
 	else if (put_page_testzero(page))
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h
+++ linux-2.6/include/linux/slub_def.h
@@ -197,4 +197,6 @@ static inline void *kmalloc_node(size_t 
 }
 #endif
 
+extern void slab_put(struct kmem_cache *s, struct page *page);
+
 #endif /* _LINUX_SLUB_DEF_H */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
