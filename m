Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C192B6B0092
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:58:22 -0400 (EDT)
Message-Id: <20101005185818.789490682@linux.com>
Date: Tue, 05 Oct 2010 13:57:37 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [UnifiedV4 12/16] slub: Cached object expiration
References: <20101005185725.088808842@linux.com>
Content-Disposition: inline; filename=unified_expire
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Provides a variety of functions that allow expiring objects from slabs.

kmem_cache_expire(struct kmem_cache ,int node)
	Expire objects of a specific slab.

kmem_cache_expire_all(int node)
	Walk through all caches and expire objects.


The functions return the number of bytes reclaimed.

Expiration works by scanning through the queues and partial
lists for untouched caches. Those are then reduced or reorganized.
Cache state is set to untouched after a expiration run.

Manual expiration may be done through the sysfs filesytem.


	/sys/kernel/slab/<cache>/expire

can take a node number or -1 for global expiration.

A "cat" will display the number of bytes reclaimed for a given
expiration run.

SLAB performs a scan of all its slabs every 2 seconds.
The  approach here means that the user (or the kernel) has more
control over the expiration of cached data and thereby more
control over the time when the OS can disturb the application
through extensive processing that likely severely disturbs the
per cpu caches.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>


---
 include/linux/slab.h     |    3 
 include/linux/slub_def.h |   15 +
 mm/slab.c                |   12 +
 mm/slob.c                |   12 +
 mm/slub.c                |  419 +++++++++++++++++++++++++++++++++++++++--------
 5 files changed, 395 insertions(+), 66 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-10-05 13:39:59.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-10-05 13:40:04.000000000 -0500
@@ -1569,7 +1569,7 @@ static inline void init_alien_cache(stru
 }
 
 /* Determine a list of the active shared caches */
-struct kmem_cache_queue **shared_caches(struct kmem_cache *s)
+struct kmem_cache_queue **shared_caches(struct kmem_cache *s, int node)
 {
 	int cpu;
 	struct kmem_cache_queue **caches;
@@ -1594,6 +1594,9 @@ struct kmem_cache_queue **shared_caches(
 		if (!q)
 			continue;
 
+		if (node != NUMA_NO_NODE && node != c->node)
+			continue;
+
 		for (n = 0; n < nr; n++)
 			if (caches[n] == q)
 				break;
@@ -1604,7 +1607,7 @@ struct kmem_cache_queue **shared_caches(
 		caches[nr++] = q;
 	}
 	caches[nr] = NULL;
-	BUG_ON(nr != s->nr_shared);
+	BUG_ON(node == NUMA_NO_NODE && nr != s->nr_shared);
 	return caches;
 }
 
@@ -1613,29 +1616,36 @@ struct kmem_cache_queue **shared_caches(
  */
 
 #ifdef CONFIG_NUMA
+
+static inline struct kmem_cache_queue *__alien_cache(struct kmem_cache *s,
+			struct kmem_cache_queue *q, int node)
+{
+	void *p = q;
+
+	p -= (node << s->alien_shift);
+
+	return (struct kmem_cache_queue *)p;
+}
+
 /* Given an allocation context determine the alien queue to use */
 static inline struct kmem_cache_queue *alien_cache(struct kmem_cache *s,
 		struct kmem_cache_cpu *c, int node)
 {
-	void *p = c->q.shared;
-
 	/* If the cache does not have any alien caches return NULL */
-	if (!aliens(s) || !p || node == c->node)
+	if (!aliens(s) || !c->q.shared || node == c->node)
 		return NULL;
 
 	/*
 	 * Map [0..(c->node - 1)] -> [1..c->node].
 	 *
 	 * This effectively removes the current node (which is serviced by
-	 * the shared cachei) from the list and avoids hitting 0 (which would
+	 * the shared cache) from the list and avoids hitting 0 (which would
 	 * result in accessing the shared queue used for the cpu cache).
 	 */
 	if (node < c->node)
 		node++;
 
-	p -= (node << s->alien_shift);
-
-	return (struct kmem_cache_queue *)p;
+	return __alien_cache(s, c->q.shared, node);
 }
 
 static inline void drain_alien_caches(struct kmem_cache *s,
@@ -1776,7 +1786,7 @@ static int remove_shared_caches(struct k
 	struct kmem_cache_queue **caches;
 	int i;
 
-	caches = shared_caches(s);
+	caches = shared_caches(s, NUMA_NO_NODE);
 	if (!caches)
 		return 0;
 	if (IS_ERR(caches))
@@ -3275,75 +3285,330 @@ void kfree(const void *x)
 }
 EXPORT_SYMBOL(kfree);
 
-/*
- * kmem_cache_shrink removes empty slabs from the partial lists and sorts
- * the remaining slabs by the number of items in use. The slabs with the
- * most items in use come first. New allocations will then fill those up
- * and thus they can be removed from the partial lists.
- *
- * The slabs with the least items are placed last. This results in them
- * being allocated from last increasing the chance that the last objects
- * are freed in them.
- */
-int kmem_cache_shrink(struct kmem_cache *s)
+static struct list_head *alloc_slabs_by_inuse(struct kmem_cache *s)
 {
-	int node;
-	int i;
-	struct kmem_cache_node *n;
-	struct page *page;
-	struct page *t;
 	int objects = oo_objects(s->max);
-	struct list_head *slabs_by_inuse =
+	struct list_head *h =
 		kmalloc(sizeof(struct list_head) * objects, GFP_KERNEL);
+
+	return h;
+
+}
+
+static int shrink_partial_list(struct kmem_cache *s, int node)
+{
+ 	int i;
+	struct kmem_cache_node *n = get_node(s, node);
+	struct page *page;
+	struct page *t;
+	int reclaimed = 0;
 	unsigned long flags;
+	int objects = oo_objects(s->max);
+	struct list_head *slabs_by_inuse;
+
+	if (!n->nr_partial)
+		return 0;
+
+	slabs_by_inuse = alloc_slabs_by_inuse(s);
+
+ 	if (!slabs_by_inuse)
+ 		return -ENOMEM;
+
+	for (i = 0; i < objects; i++)
+		INIT_LIST_HEAD(slabs_by_inuse + i);
+
+	spin_lock_irqsave(&n->lock, flags);
+
+	/*
+	 * Build lists indexed by the items in use in each slab.
+	 *
+	 * Note that concurrent frees may occur while we hold the
+	 * list_lock. page->inuse here is the upper limit.
+	 */
+	list_for_each_entry_safe(page, t, &n->partial, lru) {
+		if (all_objects_available(page)) {
+			remove_partial(n, page);
+			reclaimed += PAGE_SIZE << compound_order(page);
+			discard_slab(s, page);
+		} else {
+			list_move(&page->lru,
+			slabs_by_inuse + inuse(page));
+		}
+	}
+
+	/*
+	 * Rebuild the partial list with the slabs filled up most
+	 * first and the least used slabs at the end.
+	 * This will cause the partial list to be shrunk during
+	 * allocations and memory to be freed up when more objects
+	 * are freed in pages at the tail.
+	 */
+	for (i = objects - 1; i >= 0; i--)
+		list_splice(slabs_by_inuse + i, n->partial.prev);
+
+	n->touched = 0;
+	spin_unlock_irqrestore(&n->lock, flags);
+	kfree(slabs_by_inuse);
+	return reclaimed;
+}
+
+static int expire_cache(struct kmem_cache *s, struct kmem_cache_queue *q,
+							int lock)
+{
+	unsigned long flags = 0;
+	int n;
+
+	if (!q || queue_empty(q))
+		return 0;
+
+	if (lock)
+		spin_lock_irqsave(&q->lock, flags);
+	else
+		local_irq_save(flags);
+
+	n = drain_queue(s, q, s->batch);
+
+	if (lock)
+		spin_unlock_irqrestore(&q->lock, flags);
+	else
+		local_irq_restore(flags);
+
+	return n;
+}
 
-	if (!slabs_by_inuse)
+static inline int node_match(int node, int n)
+{
+	return node == NUMA_NO_NODE || node == n;
+}
+
+static int expire_partials(struct kmem_cache *s, int node)
+{
+	struct kmem_cache_node *n = get_node(s, node);
+
+	if (!n->nr_partial || n->touched) {
+			n->touched = 0;
+			return 0;
+	}
+
+	/* Check error code */
+	return shrink_partial_list(s, node) *
+			    PAGE_SHIFT << oo_order(s->oo);
+}
+
+static int expire_cpu_caches(struct kmem_cache *s, int node)
+{
+	cpumask_var_t saved_mask;
+	int reclaimed = 0;
+	int cpu;
+
+	if (!alloc_cpumask_var(&saved_mask, GFP_KERNEL))
 		return -ENOMEM;
 
-	flush_all(s);
-	for_each_node_state(node, N_NORMAL_MEMORY) {
-		n = get_node(s, node);
+	cpumask_copy(saved_mask, &current->cpus_allowed);
+	for_each_online_cpu(cpu) {
+		struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu, cpu);
+		struct kmem_cache_queue *q = &c->q;
 
-		if (!n->nr_partial)
-			continue;
+		if (!q->touched && node_match(node, c->node)) {
+			/*
+			 * Switch affinity to the target cpu to allow access
+			 * to the cpu cache
+ 			 */
+			set_cpus_allowed_ptr(current, &cpumask_of_cpu(cpu));
+			reclaimed += expire_cache(s, q, 0) * s->size;
+		}
+		q->touched = 0;
+	}
+	set_cpus_allowed_ptr(current, saved_mask);
+	free_cpumask_var(saved_mask);
 
-		for (i = 0; i < objects; i++)
-			INIT_LIST_HEAD(slabs_by_inuse + i);
+	return reclaimed;
+}
 
-		spin_lock_irqsave(&n->lock, flags);
+#ifdef CONFIG_SMP
+static int expire_shared_caches(struct kmem_cache *s, int node)
+{
+	struct kmem_cache_queue **l;
+	int reclaimed = 0;
+	struct kmem_cache_queue **caches = shared_caches(s, node);
 
-		/*
-		 * Build lists indexed by the items in use in each slab.
-		 *
-		 * Note that concurrent frees may occur while we hold the
-		 * lock. page->inuse here is the upper limit.
-		 */
-		list_for_each_entry_safe(page, t, &n->partial, lru) {
-			if (all_objects_available(page)) {
-				/*
-				 * Must hold slab lock here because slab_free
-				 * may have freed the last object and be
-				 * waiting to release the slab.
-				 */
-				remove_partial(n, page);
-				discard_slab(s, page);
-			} else {
-				list_move(&page->lru,
-				slabs_by_inuse + inuse(page));
+	if (!caches)
+		return -ENOMEM;
+
+	for (l = caches; *l; l++) {
+		struct kmem_cache_queue *q = *l;
+
+		if (!q->touched)
+			reclaimed += expire_cache(s, q, 1) * s->size;
+
+		q->touched = 0;
+	}
+
+	kfree(caches);
+	return reclaimed;
+}
+#endif
+
+#ifdef CONFIG_NUMA
+static int expire_alien_caches(struct kmem_cache *s, int nid)
+{
+	int reclaimed = 0;
+	struct kmem_cache_queue **caches = shared_caches(s, nid);
+
+	if (!caches)
+		return -ENOMEM;
+
+	if (aliens(s)) {
+		struct kmem_cache_queue **l;
+
+	    	for (l = caches; *l; l++) {
+			int node;
+
+			for (node = 0; node < nr_node_ids - 1;
+					node++) {
+				struct kmem_cache_queue *a =
+					__alien_cache(s, *l, node);
+
+				if (!a->touched)
+					reclaimed += expire_cache(s, a, 1)
+								* s->size;
+				a->touched = 0;
 			}
 		}
+	}
+	return reclaimed;
+}
+#endif
 
-		/*
-		 * Rebuild the partial list with the slabs filled up most
-		 * first and the least used slabs at the end.
-		 */
-		for (i = objects - 1; i >= 0; i--)
-			list_splice(slabs_by_inuse + i, n->partial.prev);
+/*
+ * Cache expiration is called when the kernel is low on memory in a node
+ * or globally (specify node == NUMA_NO_NODE).
+ *
+ * Cache expiration works by reducing caching memory used by the allocator.
+ * It starts with caches that are not that important for performance.
+ * If it cannot retrieve memory in a low importance cache then it will
+ * start expiring data from more important caches.
+ * The function returns 0 when all caches have been expired and no
+ * objects are cached anymore.
+ *
+ * low impact	 	Dropping of empty partial list slabs
+ *			Drop a batch from the alien caches
+ *                      Drop a batch from the shared caches
+ * high impact		Drop a batch from the cpu caches
+ */
 
-		spin_unlock_irqrestore(&n->lock, flags);
+typedef int (*expire_t)(struct kmem_cache *,
+			int nid);
+
+static expire_t expire_methods[] =
+{
+	expire_partials,
+#ifdef CONFIG_SMP
+#ifdef CONFIG_NUMA
+	expire_alien_caches,
+#endif
+	expire_shared_caches,
+#endif
+	expire_cpu_caches,
+	NULL
+};
+
+long kmem_cache_expire(struct kmem_cache *s, int node)
+{
+	int reclaimed = 0;
+	int n;
+
+	for (n = 0; n < NR_EXPIRE; n++) {
+		if (node == NUMA_NO_NODE) {
+			for_each_node_state(node, N_NORMAL_MEMORY) {
+				int r =  expire_methods[n](s, node);
+
+				if (r < 0) {
+					reclaimed = r;
+					goto out;
+				}
+				reclaimed += r;
+			}
+		} else
+			reclaimed = expire_methods[n](s, node);
 	}
+out:
+	return reclaimed;
+}
+
+static long __kmem_cache_expire_all(int node)
+{
+	struct kmem_cache *s;
+	int reclaimed = 0;
+	int n;
+
+	for (n = 0; n < NR_EXPIRE; n++) {
+		int r;
+
+		list_for_each_entry(s, &slab_caches, list) {
+
+ 			r = expire_methods[n](s, node);
+			if (r < 0)
+				return r;
+
+			reclaimed += r;
+		}
+	}
+	return reclaimed;
+}
+
+long kmem_cache_expire_all(int node)
+{
+	int reclaimed = 0;
+
+	/*
+	 * Expiration may be done from reclaim. Therefore recursion
+	 * is possible. The trylock avoids recusion issues and keeps
+	 * lockdep happy.
+	 *
+	 * Take the write lock to ensure that only a single reclaimer
+	 * is active at a time.
+	 */
+	if (!down_write_trylock(&slub_lock))
+		return 0;
+
+	if (node == NUMA_NO_NODE) {
+		for_each_node_state(node, N_NORMAL_MEMORY) {
+			int r =  __kmem_cache_expire_all(node);
+
+			if (r < 0) {
+				reclaimed = r;
+				goto out;
+			}
+			reclaimed += r;
+		}
+	} else
+		reclaimed = __kmem_cache_expire_all(node);
+
+out:
+	up_write(&slub_lock);
+	return reclaimed;
+}
+
+/*
+ * kmem_cache_shrink removes empty slabs from the partial lists and sorts
+ * the remaining slabs by the number of items in use. The slabs with the
+ * most items in use come first. New allocations will then fill those up
+ * and thus they can be removed from the partial lists.
+ *
+ * The slabs with the least items are placed last. This results in them
+ * being allocated from last increasing the chance that the last objects
+ * are freed in them.
+ */
+int kmem_cache_shrink(struct kmem_cache *s)
+{
+	int node;
+
+	flush_all(s);
+
+	for_each_node_state(node, N_NORMAL_MEMORY)
+		shrink_partial_list(s, node);
 
-	kfree(slabs_by_inuse);
 	return 0;
 }
 EXPORT_SYMBOL(kmem_cache_shrink);
@@ -4530,7 +4795,7 @@ static ssize_t shared_caches_show(struct
 	struct kmem_cache_queue **caches;
 
 	down_read(&slub_lock);
-	caches = shared_caches(s);
+	caches = shared_caches(s, NUMA_NO_NODE);
 	if (!caches) {
 		up_read(&slub_lock);
 		return -ENOENT;
@@ -4715,7 +4980,7 @@ static ssize_t alien_caches_show(struct 
 		return -ENOSYS;
 
 	down_read(&slub_lock);
-	caches = shared_caches(s);
+	caches = shared_caches(s, NUMA_NO_NODE);
 	if (!caches) {
 		up_read(&slub_lock);
 		return -ENOENT;
@@ -4994,6 +5259,29 @@ static ssize_t failslab_store(struct kme
 SLAB_ATTR(failslab);
 #endif
 
+static ssize_t expire_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%lu\n", s->last_expired_bytes);
+}
+
+static ssize_t expire_store(struct kmem_cache *s,
+			const char *buf, size_t length)
+{
+	long node;
+	int err;
+
+	err = strict_strtol(buf, 10, &node);
+	if (err)
+		return err;
+
+	if (node > nr_node_ids || node < -1)
+		return -EINVAL;
+
+	s->last_expired_bytes = kmem_cache_expire(s, node);
+	return length;
+}
+SLAB_ATTR(expire);
+
 static ssize_t shrink_show(struct kmem_cache *s, char *buf)
 {
 	return 0;
@@ -5111,6 +5399,7 @@ static struct attribute *slab_attrs[] = 
 	&reclaim_account_attr.attr,
 	&destroy_by_rcu_attr.attr,
 	&shrink_attr.attr,
+	&expire_attr.attr,
 #ifdef CONFIG_SLUB_DEBUG
 	&total_objects_attr.attr,
 	&slabs_attr.attr,
@@ -5450,7 +5739,7 @@ static unsigned long shared_objects(stru
 	int n;
 	struct kmem_cache_queue **caches;
 
-	caches = shared_caches(s);
+	caches = shared_caches(s, NUMA_NO_NODE);
 	if (IS_ERR(caches))
 		return PTR_ERR(caches);
 
Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2010-10-05 13:26:31.000000000 -0500
+++ linux-2.6/include/linux/slab.h	2010-10-05 13:40:04.000000000 -0500
@@ -103,12 +103,15 @@ struct kmem_cache *kmem_cache_create(con
 			void (*)(void *));
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
+long kmem_cache_expire(struct kmem_cache *, int);
 void kmem_cache_free(struct kmem_cache *, void *);
 unsigned int kmem_cache_size(struct kmem_cache *);
 const char *kmem_cache_name(struct kmem_cache *);
 int kern_ptr_validate(const void *ptr, unsigned long size);
 int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
 
+long kmem_cache_expire_all(int node);
+
 /*
  * Please use this macro to create slab caches. Simply specify the
  * name of the structure and maybe some flags that are listed above.
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-10-05 13:39:59.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-10-05 13:40:04.000000000 -0500
@@ -35,6 +35,18 @@ enum stat_item {
 	ORDER_FALLBACK,		/* Number of times fallback was necessary */
 	NR_SLUB_STAT_ITEMS };
 
+enum expire_item {
+	EXPIRE_PARTIAL,
+#ifdef CONFIG_NUMA
+	EXPIRE_ALIEN_CACHES,
+#endif
+#ifdef CONFIG_SMP
+	EXPIRE_SHARED_CACHES,
+#endif
+	EXPIRE_CPU_CACHES,
+	NR_EXPIRE
+};
+
 /*
  * Queueing structure used for per cpu, l3 cache and alien queueing.
  *
@@ -47,7 +59,7 @@ enum stat_item {
  * Foreign objects will then be on the queue until memory becomes available
  * again on the node. Freeing objects always occurs to the correct node.
  *
- * Which means that queueing is no longer effective since
+ * Which means that queueing is then no longer so effective since
  * objects are freed to the alien caches after having been dequeued from
  * the per cpu queue.
  */
@@ -122,6 +134,7 @@ struct kmem_cache {
 	struct list_head list;	/* List of slab caches */
 #ifdef CONFIG_SYSFS
 	struct kobject kobj;	/* For sysfs */
+	unsigned long last_expired_bytes;
 #endif
 	int shared_queue_sysfs;	/* Desired shared queue size */
 
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2010-10-05 13:26:31.000000000 -0500
+++ linux-2.6/mm/slab.c	2010-10-05 13:40:04.000000000 -0500
@@ -2592,6 +2592,18 @@ int kmem_cache_shrink(struct kmem_cache 
 }
 EXPORT_SYMBOL(kmem_cache_shrink);
 
+unsigned long kmem_cache_expire(struct kmem_cache *cachep, int node)
+{
+	return 0;
+}
+EXPORT_SYMBOL(kmem_cache_expire);
+
+unsigned long kmem_cache_expire_all(int node)
+{
+	return 0;
+}
+EXPORT_SYMBOL(kmem_cache_expire_all);
+
 /**
  * kmem_cache_destroy - delete a cache
  * @cachep: the cache to destroy
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2010-10-05 13:26:31.000000000 -0500
+++ linux-2.6/mm/slob.c	2010-10-05 13:40:04.000000000 -0500
@@ -678,6 +678,18 @@ int kmem_cache_shrink(struct kmem_cache 
 }
 EXPORT_SYMBOL(kmem_cache_shrink);
 
+unsigned long kmem_cache_expire(struct kmem_cache *cachep, int node)
+{
+	return 0;
+}
+EXPORT_SYMBOL(kmem_cache_expire);
+
+unsigned long kmem_cache_expire_all(int node)
+{
+	return 0;
+}
+EXPORT_SYMBOL(kmem_cache_expire_all);
+
 int kmem_ptr_validate(struct kmem_cache *a, const void *b)
 {
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
