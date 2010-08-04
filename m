Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DABD466002F
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 22:45:37 -0400 (EDT)
Message-Id: <20100804024536.477394860@linux.com>
Date: Tue, 03 Aug 2010 21:45:36 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q3 22/23] slub: Cached object expiration
References: <20100804024514.139976032@linux.com>
Content-Disposition: inline; filename=unified_expire
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Provides a variety of functions that allow expiring objects from slabs.

kmem_cache_expire(struct kmem_cache ,int node)
	Expire objects of a specific slab.

kmem_cache_expire_all(int node)
	Walk through all caches and expire objects.

Functions return the number of bytes reclaimed.

Object expiration works by gradually expiring more or less performance
sensitive cached data. Expiration can be called multiple times and will
then gradually touch more and more performance sensitive cached data.

Levels of expiration

first		Empty partial slabs
		Alien caches
		Shared caches
last		Cpu caches

Manual expiration may be done by using the sysfs filesytem.

	/sys/kernel/slab/<cache>/expire

can take a node number or -1 for global expiration.

A cat will display the number of bytes reclaimed for a given
expiration run.

SLAB performs a scan of all its slabs every 2 seconds.
The  approach here means that the user (or the kernel) has more
control over the expiration of cached data and thereby control over
the time when the OS can disturb the application by extensive
processing.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>


---
 include/linux/slab.h     |    3 
 include/linux/slub_def.h |    1 
 mm/slub.c                |  283 ++++++++++++++++++++++++++++++++++++++---------
 3 files changed, 238 insertions(+), 49 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-08-03 21:19:00.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-08-03 21:19:00.000000000 -0500
@@ -3320,6 +3320,213 @@ void kfree(const void *x)
 }
 EXPORT_SYMBOL(kfree);
 
+static struct list_head *alloc_slabs_by_inuse(struct kmem_cache *s)
+{
+	int objects = oo_objects(s->max);
+	struct list_head *h =
+		kmalloc(sizeof(struct list_head) * objects, GFP_KERNEL);
+
+	return h;
+
+}
+
+static int shrink_partial_list(struct kmem_cache *s, int node,
+				struct list_head *slabs_by_inuse)
+{
+	int i;
+	struct kmem_cache_node *n = get_node(s, node);
+	struct page *page;
+	struct page *t;
+	int reclaimed = 0;
+	unsigned long flags;
+	int objects = oo_objects(s->max);
+
+	if (!n->nr_partial)
+		return 0;
+
+	for (i = 0; i < objects; i++)
+		INIT_LIST_HEAD(slabs_by_inuse + i);
+
+	spin_lock_irqsave(&n->list_lock, flags);
+
+	/*
+	 * Build lists indexed by the items in use in each slab.
+	 *
+	 * Note that concurrent frees may occur while we hold the
+	 * list_lock. page->inuse here is the upper limit.
+	 */
+	list_for_each_entry_safe(page, t, &n->partial, lru) {
+		if (all_objects_available(page) && slab_trylock(page)) {
+			/*
+			 * Must hold slab lock here because slab_free
+			 * may have freed the last object and be
+			 * waiting to release the slab.
+			 */
+			list_del(&page->lru);
+			n->nr_partial--;
+			slab_unlock(page);
+			discard_slab(s, page);
+			reclaimed++;
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
+	spin_unlock_irqrestore(&n->list_lock, flags);
+	return reclaimed;
+}
+
+static int expire_cache(struct kmem_cache *s, struct kmem_cache_cpu *c,
+		struct kmem_cache_queue *q, int lock)
+{
+	unsigned long flags = 0;
+	int n;
+
+	if (queue_empty(q))
+		return 0;
+
+	if (lock)
+		spin_lock(&q->lock);
+	else
+		local_irq_save(flags);
+
+	n = drain_queue(s, q, s->batch);
+
+	if (lock)
+		spin_unlock(&q->lock);
+	else
+		local_irq_restore(flags);
+
+	return n;
+}
+
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
+
+unsigned long kmem_cache_expire(struct kmem_cache *s, int node)
+{
+	struct list_head *slabs_by_inuse = alloc_slabs_by_inuse(s);
+	int reclaimed = 0;
+	int cpu;
+	cpumask_var_t saved_mask;
+
+	if (!slabs_by_inuse)
+		return -ENOMEM;
+
+	if (node != NUMA_NO_NODE)
+		reclaimed = shrink_partial_list(s, node, slabs_by_inuse);
+	else {
+		int n;
+
+		for_each_node_state(n, N_NORMAL_MEMORY)
+			reclaimed +=
+				shrink_partial_list(s, n, slabs_by_inuse)
+					* PAGE_SHIFT << oo_order(s->oo);
+	}
+
+	kfree(slabs_by_inuse);
+
+	if (reclaimed)
+		return reclaimed;
+#ifdef CONFIG_NUMA
+	if (aliens(s))
+	    for_each_online_cpu(cpu) {
+		struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu, cpu);
+
+		if (!c->q.shared)
+			continue;
+
+		if (node == NUMA_NO_NODE) {
+			int x;
+
+			for_each_online_node(x)
+				reclaimed += expire_cache(s, c,
+					alien_cache(s, c, x), 1) * s->size;
+
+		} else
+		if (c->node != node)
+			reclaimed += expire_cache(s, c,
+				alien_cache(s, c, node), 1) * s->size;
+	}
+
+	if (reclaimed)
+		return reclaimed;
+#endif
+
+	for_each_online_cpu(cpu) {
+		struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu, cpu);
+
+		if (!c->q.shared)
+			continue;
+
+		if (node != NUMA_NO_NODE && c->node != node)
+			continue;
+
+		reclaimed += expire_cache(s, c, c->q.shared, 1) * s->size;
+	}
+
+	if (reclaimed)
+		return reclaimed;
+
+	if (alloc_cpumask_var(&saved_mask, GFP_KERNEL)) {
+		cpumask_copy(saved_mask, &current->cpus_allowed);
+		for_each_online_cpu(cpu) {
+			struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu, cpu);
+
+			if (node != NUMA_NO_NODE && c->node != node)
+				continue;
+
+			/*
+			 * Switch affinity to the target cpu to allow access
+			 * to the cpu cache
+			 */
+			set_cpus_allowed_ptr(current, &cpumask_of_cpu(cpu));
+			reclaimed += expire_cache(s, c, &c->q, 0) * s->size;
+		}
+		set_cpus_allowed_ptr(current, saved_mask);
+		free_cpumask_var(saved_mask);
+	}
+
+	return reclaimed;
+}
+
+unsigned long kmem_cache_expire_all(int node)
+{
+	struct kmem_cache *s;
+	unsigned long n = 0;
+
+	down_read(&slub_lock);
+	list_for_each_entry(s, &slab_caches, list)
+		n += kmem_cache_expire(s, node);
+	up_read(&slub_lock);
+	return n;
+}
+
 /*
  * kmem_cache_shrink removes empty slabs from the partial lists and sorts
  * the remaining slabs by the number of items in use. The slabs with the
@@ -3333,62 +3540,16 @@ EXPORT_SYMBOL(kfree);
 int kmem_cache_shrink(struct kmem_cache *s)
 {
 	int node;
-	int i;
-	struct kmem_cache_node *n;
-	struct page *page;
-	struct page *t;
-	int objects = oo_objects(s->max);
-	struct list_head *slabs_by_inuse =
-		kmalloc(sizeof(struct list_head) * objects, GFP_KERNEL);
-	unsigned long flags;
+	struct list_head *slabs_by_inuse = alloc_slabs_by_inuse(s);
 
 	if (!slabs_by_inuse)
 		return -ENOMEM;
 
 	flush_all(s);
-	for_each_node_state(node, N_NORMAL_MEMORY) {
-		n = get_node(s, node);
-
-		if (!n->nr_partial)
-			continue;
-
-		for (i = 0; i < objects; i++)
-			INIT_LIST_HEAD(slabs_by_inuse + i);
-
-		spin_lock_irqsave(&n->list_lock, flags);
 
-		/*
-		 * Build lists indexed by the items in use in each slab.
-		 *
-		 * Note that concurrent frees may occur while we hold the
-		 * list_lock. page->inuse here is the upper limit.
-		 */
-		list_for_each_entry_safe(page, t, &n->partial, lru) {
-			if (all_objects_available(page) && slab_trylock(page)) {
-				/*
-				 * Must hold slab lock here because slab_free
-				 * may have freed the last object and be
-				 * waiting to release the slab.
-				 */
-				list_del(&page->lru);
-				n->nr_partial--;
-				slab_unlock(page);
-				discard_slab(s, page);
-			} else {
-				list_move(&page->lru,
-				slabs_by_inuse + inuse(page));
-			}
-		}
+	for_each_node_state(node, N_NORMAL_MEMORY)
+		shrink_partial_list(s, node, slabs_by_inuse);
 
-		/*
-		 * Rebuild the partial list with the slabs filled up most
-		 * first and the least used slabs at the end.
-		 */
-		for (i = objects - 1; i >= 0; i--)
-			list_splice(slabs_by_inuse + i, n->partial.prev);
-
-		spin_unlock_irqrestore(&n->list_lock, flags);
-	}
 
 	kfree(slabs_by_inuse);
 	return 0;
@@ -4867,6 +5028,29 @@ static ssize_t shrink_store(struct kmem_
 }
 SLAB_ATTR(shrink);
 
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
 static ssize_t alloc_calls_show(struct kmem_cache *s, char *buf)
 {
 	if (!(s->flags & SLAB_STORE_USER))
@@ -5158,6 +5342,7 @@ static struct attribute *slab_attrs[] = 
 	&store_user_attr.attr,
 	&validate_attr.attr,
 	&shrink_attr.attr,
+	&expire_attr.attr,
 	&alloc_calls_attr.attr,
 	&free_calls_attr.attr,
 #ifdef CONFIG_ZONE_DMA
Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2010-08-03 21:18:41.000000000 -0500
+++ linux-2.6/include/linux/slab.h	2010-08-03 21:19:00.000000000 -0500
@@ -103,12 +103,15 @@ struct kmem_cache *kmem_cache_create(con
 			void (*)(void *));
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
+unsigned long kmem_cache_expire(struct kmem_cache *, int);
 void kmem_cache_free(struct kmem_cache *, void *);
 unsigned int kmem_cache_size(struct kmem_cache *);
 const char *kmem_cache_name(struct kmem_cache *);
 int kern_ptr_validate(const void *ptr, unsigned long size);
 int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
 
+unsigned long kmem_cache_expire_all(int node);
+
 /*
  * Please use this macro to create slab caches. Simply specify the
  * name of the structure and maybe some flags that are listed above.
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-08-03 21:19:00.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-08-03 21:19:00.000000000 -0500
@@ -101,6 +101,7 @@ struct kmem_cache {
 	struct list_head list;	/* List of slab caches */
 #ifdef CONFIG_SLUB_DEBUG
 	struct kobject kobj;	/* For sysfs */
+	unsigned long last_expired_bytes;
 #endif
 	int shared_queue_sysfs;	/* Desired shared queue size */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
