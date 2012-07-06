Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 9EF996B0083
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 16:25:26 -0400 (EDT)
Message-Id: <20120706202524.732071594@linux.com>
Date: Fri, 06 Jul 2012 15:25:12 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [3/4] Use a common mutex definition
References: <20120706202509.294809131@linux.com>
Content-Disposition: inline; filename=common_mutex
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

Use the mutex definition from SLAB and make it the common way to take a sleeping lock.

This has the effect of using a mutex instead of a rw semaphore for SLUB.

SLOB gains the use of a mutex for kmem_cache_create serialization.
Not needed now but SLOB may acquire some more features later (like slabinfo
/ sysfs support) through the expansion of the common code that will
need this.

Reviewed-by: Glauber Costa <glommer@parallels.com>
Reviewed-by: Joonsoo Kim <js1304@gmail.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slab.c        |  108 +++++++++++++++++++++++++------------------------------
 mm/slab.h        |    4 ++
 mm/slab_common.c |    2 +
 mm/slub.c        |   54 ++++++++++++---------------
 4 files changed, 82 insertions(+), 86 deletions(-)

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-07-06 07:30:16.719290474 -0500
+++ linux-2.6/mm/slab.c	2012-07-06 07:30:20.735290389 -0500
@@ -68,7 +68,7 @@
  * Further notes from the original documentation:
  *
  * 11 April '97.  Started multi-threading - markhe
- *	The global cache-chain is protected by the mutex 'cache_chain_mutex'.
+ *	The global cache-chain is protected by the mutex 'slab_mutex'.
  *	The sem is only needed when accessing/extending the cache-chain, which
  *	can never happen inside an interrupt (kmem_cache_create(),
  *	kmem_cache_shrink() and kmem_cache_reap()).
@@ -671,12 +671,6 @@ static void slab_set_debugobj_lock_class
 }
 #endif
 
-/*
- * Guard access to the cache-chain.
- */
-static DEFINE_MUTEX(cache_chain_mutex);
-static struct list_head cache_chain;
-
 static DEFINE_PER_CPU(struct delayed_work, slab_reap_work);
 
 static inline struct array_cache *cpu_cache_get(struct kmem_cache *cachep)
@@ -1100,7 +1094,7 @@ static inline int cache_free_alien(struc
  * When hotplugging memory or a cpu, existing nodelists are not replaced if
  * already in use.
  *
- * Must hold cache_chain_mutex.
+ * Must hold slab_mutex.
  */
 static int init_cache_nodelists_node(int node)
 {
@@ -1108,7 +1102,7 @@ static int init_cache_nodelists_node(int
 	struct kmem_list3 *l3;
 	const int memsize = sizeof(struct kmem_list3);
 
-	list_for_each_entry(cachep, &cache_chain, list) {
+	list_for_each_entry(cachep, &slab_caches, list) {
 		/*
 		 * Set up the size64 kmemlist for cpu before we can
 		 * begin anything. Make sure some other cpu on this
@@ -1124,7 +1118,7 @@ static int init_cache_nodelists_node(int
 
 			/*
 			 * The l3s don't come and go as CPUs come and
-			 * go.  cache_chain_mutex is sufficient
+			 * go.  slab_mutex is sufficient
 			 * protection here.
 			 */
 			cachep->nodelists[node] = l3;
@@ -1146,7 +1140,7 @@ static void __cpuinit cpuup_canceled(lon
 	int node = cpu_to_mem(cpu);
 	const struct cpumask *mask = cpumask_of_node(node);
 
-	list_for_each_entry(cachep, &cache_chain, list) {
+	list_for_each_entry(cachep, &slab_caches, list) {
 		struct array_cache *nc;
 		struct array_cache *shared;
 		struct array_cache **alien;
@@ -1196,7 +1190,7 @@ free_array_cache:
 	 * the respective cache's slabs,  now we can go ahead and
 	 * shrink each nodelist to its limit.
 	 */
-	list_for_each_entry(cachep, &cache_chain, list) {
+	list_for_each_entry(cachep, &slab_caches, list) {
 		l3 = cachep->nodelists[node];
 		if (!l3)
 			continue;
@@ -1225,7 +1219,7 @@ static int __cpuinit cpuup_prepare(long
 	 * Now we can go ahead with allocating the shared arrays and
 	 * array caches
 	 */
-	list_for_each_entry(cachep, &cache_chain, list) {
+	list_for_each_entry(cachep, &slab_caches, list) {
 		struct array_cache *nc;
 		struct array_cache *shared = NULL;
 		struct array_cache **alien = NULL;
@@ -1293,9 +1287,9 @@ static int __cpuinit cpuup_callback(stru
 	switch (action) {
 	case CPU_UP_PREPARE:
 	case CPU_UP_PREPARE_FROZEN:
-		mutex_lock(&cache_chain_mutex);
+		mutex_lock(&slab_mutex);
 		err = cpuup_prepare(cpu);
-		mutex_unlock(&cache_chain_mutex);
+		mutex_unlock(&slab_mutex);
 		break;
 	case CPU_ONLINE:
 	case CPU_ONLINE_FROZEN:
@@ -1305,7 +1299,7 @@ static int __cpuinit cpuup_callback(stru
   	case CPU_DOWN_PREPARE:
   	case CPU_DOWN_PREPARE_FROZEN:
 		/*
-		 * Shutdown cache reaper. Note that the cache_chain_mutex is
+		 * Shutdown cache reaper. Note that the slab_mutex is
 		 * held so that if cache_reap() is invoked it cannot do
 		 * anything expensive but will only modify reap_work
 		 * and reschedule the timer.
@@ -1332,9 +1326,9 @@ static int __cpuinit cpuup_callback(stru
 #endif
 	case CPU_UP_CANCELED:
 	case CPU_UP_CANCELED_FROZEN:
-		mutex_lock(&cache_chain_mutex);
+		mutex_lock(&slab_mutex);
 		cpuup_canceled(cpu);
-		mutex_unlock(&cache_chain_mutex);
+		mutex_unlock(&slab_mutex);
 		break;
 	}
 	return notifier_from_errno(err);
@@ -1350,14 +1344,14 @@ static struct notifier_block __cpuinitda
  * Returns -EBUSY if all objects cannot be drained so that the node is not
  * removed.
  *
- * Must hold cache_chain_mutex.
+ * Must hold slab_mutex.
  */
 static int __meminit drain_cache_nodelists_node(int node)
 {
 	struct kmem_cache *cachep;
 	int ret = 0;
 
-	list_for_each_entry(cachep, &cache_chain, list) {
+	list_for_each_entry(cachep, &slab_caches, list) {
 		struct kmem_list3 *l3;
 
 		l3 = cachep->nodelists[node];
@@ -1388,14 +1382,14 @@ static int __meminit slab_memory_callbac
 
 	switch (action) {
 	case MEM_GOING_ONLINE:
-		mutex_lock(&cache_chain_mutex);
+		mutex_lock(&slab_mutex);
 		ret = init_cache_nodelists_node(nid);
-		mutex_unlock(&cache_chain_mutex);
+		mutex_unlock(&slab_mutex);
 		break;
 	case MEM_GOING_OFFLINE:
-		mutex_lock(&cache_chain_mutex);
+		mutex_lock(&slab_mutex);
 		ret = drain_cache_nodelists_node(nid);
-		mutex_unlock(&cache_chain_mutex);
+		mutex_unlock(&slab_mutex);
 		break;
 	case MEM_ONLINE:
 	case MEM_OFFLINE:
@@ -1499,8 +1493,8 @@ void __init kmem_cache_init(void)
 	node = numa_mem_id();
 
 	/* 1) create the cache_cache */
-	INIT_LIST_HEAD(&cache_chain);
-	list_add(&cache_cache.list, &cache_chain);
+	INIT_LIST_HEAD(&slab_caches);
+	list_add(&cache_cache.list, &slab_caches);
 	cache_cache.colour_off = cache_line_size();
 	cache_cache.array[smp_processor_id()] = &initarray_cache.cache;
 	cache_cache.nodelists[node] = &initkmem_list3[CACHE_CACHE + node];
@@ -1642,11 +1636,11 @@ void __init kmem_cache_init_late(void)
 	init_lock_keys();
 
 	/* 6) resize the head arrays to their final sizes */
-	mutex_lock(&cache_chain_mutex);
-	list_for_each_entry(cachep, &cache_chain, list)
+	mutex_lock(&slab_mutex);
+	list_for_each_entry(cachep, &slab_caches, list)
 		if (enable_cpucache(cachep, GFP_NOWAIT))
 			BUG();
-	mutex_unlock(&cache_chain_mutex);
+	mutex_unlock(&slab_mutex);
 
 	/* Done! */
 	slab_state = FULL;
@@ -2253,10 +2247,10 @@ __kmem_cache_create (const char *name, s
 	 */
 	if (slab_is_available()) {
 		get_online_cpus();
-		mutex_lock(&cache_chain_mutex);
+		mutex_lock(&slab_mutex);
 	}
 
-	list_for_each_entry(pc, &cache_chain, list) {
+	list_for_each_entry(pc, &slab_caches, list) {
 		char tmp;
 		int res;
 
@@ -2500,10 +2494,10 @@ __kmem_cache_create (const char *name, s
 	}
 
 	/* cache setup completed, link it into the list */
-	list_add(&cachep->list, &cache_chain);
+	list_add(&cachep->list, &slab_caches);
 oops:
 	if (slab_is_available()) {
-		mutex_unlock(&cache_chain_mutex);
+		mutex_unlock(&slab_mutex);
 		put_online_cpus();
 	}
 	return cachep;
@@ -2622,7 +2616,7 @@ out:
 	return nr_freed;
 }
 
-/* Called with cache_chain_mutex held to protect against cpu hotplug */
+/* Called with slab_mutex held to protect against cpu hotplug */
 static int __cache_shrink(struct kmem_cache *cachep)
 {
 	int ret = 0, i = 0;
@@ -2657,9 +2651,9 @@ int kmem_cache_shrink(struct kmem_cache
 	BUG_ON(!cachep || in_interrupt());
 
 	get_online_cpus();
-	mutex_lock(&cache_chain_mutex);
+	mutex_lock(&slab_mutex);
 	ret = __cache_shrink(cachep);
-	mutex_unlock(&cache_chain_mutex);
+	mutex_unlock(&slab_mutex);
 	put_online_cpus();
 	return ret;
 }
@@ -2687,15 +2681,15 @@ void kmem_cache_destroy(struct kmem_cach
 
 	/* Find the cache in the chain of caches. */
 	get_online_cpus();
-	mutex_lock(&cache_chain_mutex);
+	mutex_lock(&slab_mutex);
 	/*
 	 * the chain is never empty, cache_cache is never destroyed
 	 */
 	list_del(&cachep->list);
 	if (__cache_shrink(cachep)) {
 		slab_error(cachep, "Can't free all objects");
-		list_add(&cachep->list, &cache_chain);
-		mutex_unlock(&cache_chain_mutex);
+		list_add(&cachep->list, &slab_caches);
+		mutex_unlock(&slab_mutex);
 		put_online_cpus();
 		return;
 	}
@@ -2704,7 +2698,7 @@ void kmem_cache_destroy(struct kmem_cach
 		rcu_barrier();
 
 	__kmem_cache_destroy(cachep);
-	mutex_unlock(&cache_chain_mutex);
+	mutex_unlock(&slab_mutex);
 	put_online_cpus();
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
@@ -4017,7 +4011,7 @@ static void do_ccupdate_local(void *info
 	new->new[smp_processor_id()] = old;
 }
 
-/* Always called with the cache_chain_mutex held */
+/* Always called with the slab_mutex held */
 static int do_tune_cpucache(struct kmem_cache *cachep, int limit,
 				int batchcount, int shared, gfp_t gfp)
 {
@@ -4061,7 +4055,7 @@ static int do_tune_cpucache(struct kmem_
 	return alloc_kmemlist(cachep, gfp);
 }
 
-/* Called with cache_chain_mutex held always */
+/* Called with slab_mutex held always */
 static int enable_cpucache(struct kmem_cache *cachep, gfp_t gfp)
 {
 	int err;
@@ -4163,11 +4157,11 @@ static void cache_reap(struct work_struc
 	int node = numa_mem_id();
 	struct delayed_work *work = to_delayed_work(w);
 
-	if (!mutex_trylock(&cache_chain_mutex))
+	if (!mutex_trylock(&slab_mutex))
 		/* Give up. Setup the next iteration. */
 		goto out;
 
-	list_for_each_entry(searchp, &cache_chain, list) {
+	list_for_each_entry(searchp, &slab_caches, list) {
 		check_irq_on();
 
 		/*
@@ -4205,7 +4199,7 @@ next:
 		cond_resched();
 	}
 	check_irq_on();
-	mutex_unlock(&cache_chain_mutex);
+	mutex_unlock(&slab_mutex);
 	next_reap_node();
 out:
 	/* Set up the next iteration */
@@ -4241,21 +4235,21 @@ static void *s_start(struct seq_file *m,
 {
 	loff_t n = *pos;
 
-	mutex_lock(&cache_chain_mutex);
+	mutex_lock(&slab_mutex);
 	if (!n)
 		print_slabinfo_header(m);
 
-	return seq_list_start(&cache_chain, *pos);
+	return seq_list_start(&slab_caches, *pos);
 }
 
 static void *s_next(struct seq_file *m, void *p, loff_t *pos)
 {
-	return seq_list_next(p, &cache_chain, pos);
+	return seq_list_next(p, &slab_caches, pos);
 }
 
 static void s_stop(struct seq_file *m, void *p)
 {
-	mutex_unlock(&cache_chain_mutex);
+	mutex_unlock(&slab_mutex);
 }
 
 static int s_show(struct seq_file *m, void *p)
@@ -4406,9 +4400,9 @@ static ssize_t slabinfo_write(struct fil
 		return -EINVAL;
 
 	/* Find the cache in the chain of caches. */
-	mutex_lock(&cache_chain_mutex);
+	mutex_lock(&slab_mutex);
 	res = -EINVAL;
-	list_for_each_entry(cachep, &cache_chain, list) {
+	list_for_each_entry(cachep, &slab_caches, list) {
 		if (!strcmp(cachep->name, kbuf)) {
 			if (limit < 1 || batchcount < 1 ||
 					batchcount > limit || shared < 0) {
@@ -4421,7 +4415,7 @@ static ssize_t slabinfo_write(struct fil
 			break;
 		}
 	}
-	mutex_unlock(&cache_chain_mutex);
+	mutex_unlock(&slab_mutex);
 	if (res >= 0)
 		res = count;
 	return res;
@@ -4444,8 +4438,8 @@ static const struct file_operations proc
 
 static void *leaks_start(struct seq_file *m, loff_t *pos)
 {
-	mutex_lock(&cache_chain_mutex);
-	return seq_list_start(&cache_chain, *pos);
+	mutex_lock(&slab_mutex);
+	return seq_list_start(&slab_caches, *pos);
 }
 
 static inline int add_caller(unsigned long *n, unsigned long v)
@@ -4544,17 +4538,17 @@ static int leaks_show(struct seq_file *m
 	name = cachep->name;
 	if (n[0] == n[1]) {
 		/* Increase the buffer size */
-		mutex_unlock(&cache_chain_mutex);
+		mutex_unlock(&slab_mutex);
 		m->private = kzalloc(n[0] * 4 * sizeof(unsigned long), GFP_KERNEL);
 		if (!m->private) {
 			/* Too bad, we are really out */
 			m->private = n;
-			mutex_lock(&cache_chain_mutex);
+			mutex_lock(&slab_mutex);
 			return -ENOMEM;
 		}
 		*(unsigned long *)m->private = n[0] * 2;
 		kfree(n);
-		mutex_lock(&cache_chain_mutex);
+		mutex_lock(&slab_mutex);
 		/* Now make sure this entry will be retried */
 		m->count = m->size;
 		return 0;
Index: linux-2.6/mm/slab.h
===================================================================
--- linux-2.6.orig/mm/slab.h	2012-07-06 07:30:16.719290474 -0500
+++ linux-2.6/mm/slab.h	2012-07-06 07:30:20.735290389 -0500
@@ -23,6 +23,10 @@ enum slab_state {
 
 extern enum slab_state slab_state;
 
+/* The slab cache mutex protects the management structures during changes */
+extern struct mutex slab_mutex;
+extern struct list_head slab_caches;
+
 struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
 	size_t align, unsigned long flags, void (*ctor)(void *));
 
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-07-06 07:30:16.719290474 -0500
+++ linux-2.6/mm/slub.c	2012-07-06 07:30:20.735290389 -0500
@@ -36,13 +36,13 @@
 
 /*
  * Lock order:
- *   1. slub_lock (Global Semaphore)
+ *   1. slab_mutex (Global Mutex)
  *   2. node->list_lock
  *   3. slab_lock(page) (Only on some arches and for debugging)
  *
- *   slub_lock
+ *   slab_mutex
  *
- *   The role of the slub_lock is to protect the list of all the slabs
+ *   The role of the slab_mutex is to protect the list of all the slabs
  *   and to synchronize major metadata changes to slab cache structures.
  *
  *   The slab_lock is only used for debugging and on arches that do not
@@ -183,10 +183,6 @@ static int kmem_size = sizeof(struct kme
 static struct notifier_block slab_notifier;
 #endif
 
-/* A list of all slab caches on the system */
-static DECLARE_RWSEM(slub_lock);
-static LIST_HEAD(slab_caches);
-
 /*
  * Tracking user of a slab.
  */
@@ -3176,11 +3172,11 @@ static inline int kmem_cache_close(struc
  */
 void kmem_cache_destroy(struct kmem_cache *s)
 {
-	down_write(&slub_lock);
+	mutex_lock(&slab_mutex);
 	s->refcount--;
 	if (!s->refcount) {
 		list_del(&s->list);
-		up_write(&slub_lock);
+		mutex_unlock(&slab_mutex);
 		if (kmem_cache_close(s)) {
 			printk(KERN_ERR "SLUB %s: %s called for cache that "
 				"still has objects.\n", s->name, __func__);
@@ -3190,7 +3186,7 @@ void kmem_cache_destroy(struct kmem_cach
 			rcu_barrier();
 		sysfs_slab_remove(s);
 	} else
-		up_write(&slub_lock);
+		mutex_unlock(&slab_mutex);
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
@@ -3252,7 +3248,7 @@ static struct kmem_cache *__init create_
 
 	/*
 	 * This function is called with IRQs disabled during early-boot on
-	 * single CPU so there's no need to take slub_lock here.
+	 * single CPU so there's no need to take slab_mutex here.
 	 */
 	if (!kmem_cache_open(s, name, size, ARCH_KMALLOC_MINALIGN,
 								flags, NULL))
@@ -3537,10 +3533,10 @@ static int slab_mem_going_offline_callba
 {
 	struct kmem_cache *s;
 
-	down_read(&slub_lock);
+	mutex_lock(&slab_mutex);
 	list_for_each_entry(s, &slab_caches, list)
 		kmem_cache_shrink(s);
-	up_read(&slub_lock);
+	mutex_unlock(&slab_mutex);
 
 	return 0;
 }
@@ -3561,7 +3557,7 @@ static void slab_mem_offline_callback(vo
 	if (offline_node < 0)
 		return;
 
-	down_read(&slub_lock);
+	mutex_lock(&slab_mutex);
 	list_for_each_entry(s, &slab_caches, list) {
 		n = get_node(s, offline_node);
 		if (n) {
@@ -3577,7 +3573,7 @@ static void slab_mem_offline_callback(vo
 			kmem_cache_free(kmem_cache_node, n);
 		}
 	}
-	up_read(&slub_lock);
+	mutex_unlock(&slab_mutex);
 }
 
 static int slab_mem_going_online_callback(void *arg)
@@ -3600,7 +3596,7 @@ static int slab_mem_going_online_callbac
 	 * allocate a kmem_cache_node structure in order to bring the node
 	 * online.
 	 */
-	down_read(&slub_lock);
+	mutex_lock(&slab_mutex);
 	list_for_each_entry(s, &slab_caches, list) {
 		/*
 		 * XXX: kmem_cache_alloc_node will fallback to other nodes
@@ -3616,7 +3612,7 @@ static int slab_mem_going_online_callbac
 		s->node[nid] = n;
 	}
 out:
-	up_read(&slub_lock);
+	mutex_unlock(&slab_mutex);
 	return ret;
 }
 
@@ -3914,7 +3910,7 @@ struct kmem_cache *__kmem_cache_create(c
 	struct kmem_cache *s;
 	char *n;
 
-	down_write(&slub_lock);
+	mutex_lock(&slab_mutex);
 	s = find_mergeable(size, align, flags, name, ctor);
 	if (s) {
 		s->refcount++;
@@ -3929,7 +3925,7 @@ struct kmem_cache *__kmem_cache_create(c
 			s->refcount--;
 			goto err;
 		}
-		up_write(&slub_lock);
+		mutex_unlock(&slab_mutex);
 		return s;
 	}
 
@@ -3942,9 +3938,9 @@ struct kmem_cache *__kmem_cache_create(c
 		if (kmem_cache_open(s, n,
 				size, align, flags, ctor)) {
 			list_add(&s->list, &slab_caches);
-			up_write(&slub_lock);
+			mutex_unlock(&slab_mutex);
 			if (sysfs_slab_add(s)) {
-				down_write(&slub_lock);
+				mutex_lock(&slab_mutex);
 				list_del(&s->list);
 				kfree(n);
 				kfree(s);
@@ -3956,7 +3952,7 @@ struct kmem_cache *__kmem_cache_create(c
 	}
 	kfree(n);
 err:
-	up_write(&slub_lock);
+	mutex_unlock(&slab_mutex);
 	return s;
 }
 
@@ -3977,13 +3973,13 @@ static int __cpuinit slab_cpuup_callback
 	case CPU_UP_CANCELED_FROZEN:
 	case CPU_DEAD:
 	case CPU_DEAD_FROZEN:
-		down_read(&slub_lock);
+		mutex_lock(&slab_mutex);
 		list_for_each_entry(s, &slab_caches, list) {
 			local_irq_save(flags);
 			__flush_cpu_slab(s, cpu);
 			local_irq_restore(flags);
 		}
-		up_read(&slub_lock);
+		mutex_unlock(&slab_mutex);
 		break;
 	default:
 		break;
@@ -5359,11 +5355,11 @@ static int __init slab_sysfs_init(void)
 	struct kmem_cache *s;
 	int err;
 
-	down_write(&slub_lock);
+	mutex_lock(&slab_mutex);
 
 	slab_kset = kset_create_and_add("slab", &slab_uevent_ops, kernel_kobj);
 	if (!slab_kset) {
-		up_write(&slub_lock);
+		mutex_unlock(&slab_mutex);
 		printk(KERN_ERR "Cannot register slab subsystem.\n");
 		return -ENOSYS;
 	}
@@ -5388,7 +5384,7 @@ static int __init slab_sysfs_init(void)
 		kfree(al);
 	}
 
-	up_write(&slub_lock);
+	mutex_unlock(&slab_mutex);
 	resiliency_test();
 	return 0;
 }
@@ -5414,7 +5410,7 @@ static void *s_start(struct seq_file *m,
 {
 	loff_t n = *pos;
 
-	down_read(&slub_lock);
+	mutex_lock(&slab_mutex);
 	if (!n)
 		print_slabinfo_header(m);
 
@@ -5428,7 +5424,7 @@ static void *s_next(struct seq_file *m,
 
 static void s_stop(struct seq_file *m, void *p)
 {
-	up_read(&slub_lock);
+	mutex_unlock(&slab_mutex);
 }
 
 static int s_show(struct seq_file *m, void *p)
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-07-06 07:30:16.719290474 -0500
+++ linux-2.6/mm/slab_common.c	2012-07-06 07:30:20.735290389 -0500
@@ -19,6 +19,8 @@
 #include "slab.h"
 
 enum slab_state slab_state;
+LIST_HEAD(slab_caches);
+DEFINE_MUTEX(slab_mutex);
 
 /*
  * kmem_cache_create - Create a cache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
