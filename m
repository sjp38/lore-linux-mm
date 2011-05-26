Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D0413900114
	for <linux-mm@kvack.org>; Thu, 26 May 2011 15:03:19 -0400 (EDT)
Message-Id: <20110526190316.731134873@linux.com>
Date: Thu, 26 May 2011 14:03:04 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slub p1 4/4] slub: [RFC] per cpu cache for partial pages
References: <20110526190300.120896512@linux.com>
Content-Disposition: inline; filename=per_cpu_partial
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org

Allow filling out the rest of the kmem_cache_cpu cacheline with pointers to
partial pages. The partial page list is used in slab_free() to avoid
per node lock taking. The list_lock is taken for batches of partial pages
instead of individual ones.

We can then also use the partial list in slab_alloc() to avoid scanning
partial lists for pages with free objects.

This is only a first stab at this. There are some limitations:

1. We have to scan through an percpu array of page pointers. That is fast
   since we stick to a cacheline size.

2. The pickup in __slab_alloc() could consider NUMA locality instead of
   blindly picking the first partial block.

3. The "unfreeze()" function should have common code with deactivate_slab().
   Maybe those can be unified.

Future enhancements:

1. The pickup from the partial list could be perhaps be done without disabling
   interrupts with some work. The free path already puts the page into the
   per cpu partial list without disabling interrupts.

2. Configure the size of the per cpu partial blocks dynamically like the other
   aspects of slab operations.

3. The __slab_free() likely has some code path that are unnecessary now or
   where code is duplicated.

4. We dump all partials if the per cpu array overflows. There must be some other
   better algorithm.


Signed-off-by: Christoph Lameter <cl@linux.com>


---
 include/linux/slub_def.h |    2 
 mm/slub.c                |  175 ++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 159 insertions(+), 18 deletions(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2011-05-26 09:12:26.305543189 -0500
+++ linux-2.6/include/linux/slub_def.h	2011-05-26 09:12:38.665543109 -0500
@@ -46,6 +46,7 @@ struct kmem_cache_cpu {
 #ifdef CONFIG_SLUB_STATS
 	unsigned stat[NR_SLUB_STAT_ITEMS];
 #endif
+	struct page *partial[];	/* Partially allocated frozen slabs */
 };
 
 struct kmem_cache_node {
@@ -79,6 +80,7 @@ struct kmem_cache {
 	int size;		/* The size of an object including meta data */
 	int objsize;		/* The size of an object without meta data */
 	int offset;		/* Free pointer offset. */
+	int cpu_partial;	/* Number of per cpu partial pages to keep around */
 	struct kmem_cache_order_objects oo;
 
 	/* Allocation and freeing of slabs */
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-05-26 09:12:26.285543189 -0500
+++ linux-2.6/mm/slub.c	2011-05-26 13:25:32.187867196 -0500
@@ -1806,6 +1806,97 @@ redo:
 	}
 }
 
+/*
+ * Unfreeze a page. Page cannot be full. May be empty. If n is passed then the list lock on that
+ * node was taken. The functions return the pointer to the list_lock that was eventually taken in
+ * this function.
+ *
+ * Races are limited to __slab_free. Meaning that the number of free objects may increase but not
+ * decrease.
+ */
+struct kmem_cache_node *unfreeze(struct kmem_cache *s, struct page *page, struct kmem_cache_node *n)
+{
+	enum slab_modes { M_PARTIAL, M_FREE };
+	enum slab_modes l = M_FREE, m = M_FREE;
+	struct page new;
+	struct page old;
+
+	do {
+
+		old.freelist = page->freelist;
+		old.counters = page->counters;
+		VM_BUG_ON(!old.frozen);
+
+		new.counters = old.counters;
+		new.freelist = old.freelist;
+
+		new.frozen = 0;
+
+		if (!new.inuse && (!n || n->nr_partial < s->min_partial))
+			m = M_FREE;
+		else {
+			struct kmem_cache_node *n2 = get_node(s, page_to_nid(page));
+
+			m = M_PARTIAL;
+			if (n != n2) {
+				if (n)
+					spin_unlock(&n->list_lock);
+
+				n = n2;
+				spin_lock(&n->list_lock);
+			}
+		}
+
+		if (l != m) {
+			if (l == M_PARTIAL)
+				remove_partial(n, page);
+			else
+				add_partial(n, page, 1);
+
+			l = m;
+		}
+
+	} while (!cmpxchg_double_slab(s, page,
+				old.freelist, old.counters,
+				new.freelist, new.counters,
+				"unfreezing slab"));
+
+	if (m == M_FREE) {
+		stat(s, DEACTIVATE_EMPTY);
+		discard_slab(s, page);
+		stat(s, FREE_SLAB);
+	}
+	return n;
+}
+
+static void unfreeze_partials(struct kmem_cache *s, struct page *page)
+{
+	int i;
+	unsigned long flags;
+	struct kmem_cache_node *n;
+
+	/* Batch free the partial pages */
+	local_irq_save(flags);
+
+	n = unfreeze(s, page, NULL);
+
+	for (i = 0; i < s->cpu_partial; i++) {
+		page = this_cpu_read(s->cpu_slab->partial[i]);
+
+		if (page) {
+			this_cpu_write(s->cpu_slab->partial[i], NULL);
+			n = unfreeze(s, page, n);
+		}
+
+	}
+
+	if (n)
+		spin_unlock(&n->list_lock);
+
+	local_irq_restore(flags);
+}
+
+
 static inline void flush_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
 {
 	stat(s, CPUSLAB_FLUSH);
@@ -1967,6 +2058,7 @@ static void *__slab_alloc(struct kmem_ca
 	unsigned long flags;
 	struct page new;
 	unsigned long counters;
+	int i;
 
 	local_irq_save(flags);
 #ifdef CONFIG_PREEMPT
@@ -1983,7 +2075,7 @@ static void *__slab_alloc(struct kmem_ca
 
 	if (!c->page)
 		goto new_slab;
-
+redo:
 	if (unlikely(!node_match(c, node))) {
 		stat(s, ALLOC_NODE_MISMATCH);
 		deactivate_slab(s, c);
@@ -2031,6 +2123,17 @@ load_freelist:
 	return object;
 
 new_slab:
+	/* First try our cache of partially allocated pages */
+	for (i = 0; i < s->cpu_partial; i++)
+		if (c->partial[i]) {
+			c->page = c->partial[i];
+			c->freelist = NULL;
+			c->partial[i] = NULL;
+			c->node = page_to_nid(c->page);
+			goto redo;
+		}
+
+	/* Then do expensive stuff like retrieving pages from the partial lists */
 	object = get_partial(s, gfpflags, node, c);
 
 	if (unlikely(!object)) {
@@ -2225,16 +2328,29 @@ static void __slab_free(struct kmem_cach
 		was_frozen = new.frozen;
 		new.inuse--;
 		if ((!new.inuse || !prior) && !was_frozen && !n) {
-                        n = get_node(s, page_to_nid(page));
-			/*
-			 * Speculatively acquire the list_lock.
-			 * If the cmpxchg does not succeed then we may
-			 * drop the list_lock without any processing.
-			 *
-			 * Otherwise the list_lock will synchronize with
-			 * other processors updating the list of slabs.
-			 */
-                        spin_lock_irqsave(&n->list_lock, flags);
+
+			if (!kmem_cache_debug(s) && !prior)
+
+				/*
+				 * Slab was on no list before and will be partially empty
+				 * We can defer the list move and freeze it easily.
+				 */
+				new.frozen = 1;
+
+			else { /* Needs to be taken off a list */
+
+	                        n = get_node(s, page_to_nid(page));
+				/*
+				 * Speculatively acquire the list_lock.
+				 * If the cmpxchg does not succeed then we may
+				 * drop the list_lock without any processing.
+				 *
+				 * Otherwise the list_lock will synchronize with
+				 * other processors updating the list of slabs.
+				 */
+				spin_lock_irqsave(&n->list_lock, flags);
+
+			}
 		}
 		inuse = new.inuse;
 
@@ -2244,7 +2360,21 @@ static void __slab_free(struct kmem_cach
 		"__slab_free"));
 
 	if (likely(!n)) {
-                /*
+       		if (new.frozen && !was_frozen) {
+			int i;
+
+			for (i = 0; i < s->cpu_partial; i++)
+				if (this_cpu_cmpxchg(s->cpu_slab->partial[i], NULL, page) == NULL)
+					return;
+
+			/*
+			 * partial array is overflowing. Drop them all as well as the one we just
+			 * froze.
+			 */
+			unfreeze_partials(s, page);
+		}
+
+         	/*
 		 * The list lock was not taken therefore no list
 		 * activity can be necessary.
 		 */
@@ -2311,7 +2441,6 @@ static __always_inline void slab_free(st
 	slab_free_hook(s, x);
 
 redo:
-
 	/*
 	 * Determine the currently cpus per cpu slab.
 	 * The cpu may change afterward. However that does not matter since
@@ -2526,6 +2655,9 @@ init_kmem_cache_node(struct kmem_cache_n
 
 static inline int alloc_kmem_cache_cpus(struct kmem_cache *s)
 {
+	int size = sizeof(struct kmem_cache_cpu) + s->cpu_partial * sizeof(void *);
+	int align = sizeof(void *);
+
 	BUILD_BUG_ON(PERCPU_DYNAMIC_EARLY_SIZE <
 			SLUB_PAGE_SHIFT * sizeof(struct kmem_cache_cpu));
 
@@ -2534,12 +2666,10 @@ static inline int alloc_kmem_cache_cpus(
 	 * Must align to double word boundary for the double cmpxchg instructions
 	 * to work.
 	 */
-	s->cpu_slab = __alloc_percpu(sizeof(struct kmem_cache_cpu), 2 * sizeof(void *));
-#else
-	/* Regular alignment is sufficient */
-	s->cpu_slab = alloc_percpu(struct kmem_cache_cpu);
+	align = 2 * sizeof(void *);
 #endif
 
+	s->cpu_slab = __alloc_percpu(size, align);
 	if (!s->cpu_slab)
 		return 0;
 
@@ -2805,7 +2935,9 @@ static int kmem_cache_open(struct kmem_c
 	 * The larger the object size is, the more pages we want on the partial
 	 * list to avoid pounding the page allocator excessively.
 	 */
-	set_min_partial(s, ilog2(s->size));
+	set_min_partial(s, ilog2(s->size) / 2);
+	s->cpu_partial = min((cache_line_size() - sizeof(struct kmem_cache_cpu)) / sizeof(void),
+				s->min_partial);
 	s->refcount = 1;
 #ifdef CONFIG_NUMA
 	s->remote_node_defrag_ratio = 1000;
@@ -4343,6 +4475,12 @@ static ssize_t min_partial_store(struct
 }
 SLAB_ATTR(min_partial);
 
+static ssize_t cpu_partial_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%u\n", s->cpu_partial);
+}
+SLAB_ATTR_RO(cpu_partial);
+
 static ssize_t ctor_show(struct kmem_cache *s, char *buf)
 {
 	if (!s->ctor)
@@ -4701,6 +4839,7 @@ static struct attribute *slab_attrs[] =
 	&objs_per_slab_attr.attr,
 	&order_attr.attr,
 	&min_partial_attr.attr,
+	&cpu_partial_attr.attr,
 	&objects_attr.attr,
 	&objects_partial_attr.attr,
 	&partial_attr.attr,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
