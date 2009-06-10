Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 166906B005C
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 13:56:52 -0400 (EDT)
Date: Wed, 10 Jun 2009 20:58:04 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH 2/3] slab: setup allocators earlier in the boot sequence
Message-ID: <Pine.LNX.4.64.0906102057220.28361@melkki.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: cl@linux-foundation.com, mingo@elte.hu, hannes@cmpxchg.org, torvalds@linux-foundation.org, mpm@selenic.com, npiggin@suse.de, yinghai@kernel.org
List-ID: <linux-mm.kvack.org>

From: Pekka Enberg <penberg@cs.helsinki.fi>

This patch makes kmalloc() available earlier in the boot sequence so we can get
rid of some bootmem allocations. The bulk of the changes are due to
kmem_cache_init() being called with interrupts disabled which requires some
changes to allocator boostrap code.

Cc: Christoph Lameter <cl@linux-foundation.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Nick Piggin <npiggin@suse.de>
Cc: Yinghai Lu <yinghai@kernel.org>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 init/main.c |   32 ++++++++++++++--------
 mm/slab.c   |   85 +++++++++++++++++++++++++++++++---------------------------
 mm/slub.c   |   17 +++++++-----
 3 files changed, 75 insertions(+), 59 deletions(-)

diff --git a/init/main.c b/init/main.c
index d721dad..8be5193 100644
--- a/init/main.c
+++ b/init/main.c
@@ -574,6 +574,26 @@ asmlinkage void __init start_kernel(void)
 	setup_nr_cpu_ids();
 	smp_prepare_boot_cpu();	/* arch-specific boot-cpu hooks */
 
+	build_all_zonelists();
+	page_alloc_init();
+
+	printk(KERN_NOTICE "Kernel command line: %s\n", boot_command_line);
+	parse_early_param();
+	parse_args("Booting kernel", static_command_line, __start___param,
+		   __stop___param - __start___param,
+		   &unknown_bootoption);
+	/*
+	 * These use large bootmem allocations and must precede
+	 * kmem_cache_init()
+	 */
+	pidhash_init();
+	vmalloc_init();
+	vfs_caches_init_early();
+	/*
+	 * Set up kernel memory allocators
+	 */
+	mem_init();
+	kmem_cache_init();
 	/*
 	 * Set up the scheduler prior starting any interrupts (such as the
 	 * timer interrupt). Full topology setup happens at smp_init()
@@ -585,13 +605,6 @@ asmlinkage void __init start_kernel(void)
 	 * fragile until we cpu_idle() for the first time.
 	 */
 	preempt_disable();
-	build_all_zonelists();
-	page_alloc_init();
-	printk(KERN_NOTICE "Kernel command line: %s\n", boot_command_line);
-	parse_early_param();
-	parse_args("Booting kernel", static_command_line, __start___param,
-		   __stop___param - __start___param,
-		   &unknown_bootoption);
 	if (!irqs_disabled()) {
 		printk(KERN_WARNING "start_kernel(): bug: interrupts were "
 				"enabled *very* early, fixing it\n");
@@ -603,7 +616,6 @@ asmlinkage void __init start_kernel(void)
 	/* init some links before init_ISA_irqs() */
 	early_irq_init();
 	init_IRQ();
-	pidhash_init();
 	init_timers();
 	hrtimers_init();
 	softirq_init();
@@ -645,14 +657,10 @@ asmlinkage void __init start_kernel(void)
 		initrd_start = 0;
 	}
 #endif
-	vmalloc_init();
-	vfs_caches_init_early();
 	cpuset_init_early();
 	page_cgroup_init();
-	mem_init();
 	enable_debug_pagealloc();
 	cpu_hotplug_init();
-	kmem_cache_init();
 	kmemtrace_init();
 	debug_objects_mem_init();
 	idr_init_cache();
diff --git a/mm/slab.c b/mm/slab.c
index 9a90b00..a5b3cf4 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -315,7 +315,7 @@ static int drain_freelist(struct kmem_cache *cache,
 			struct kmem_list3 *l3, int tofree);
 static void free_block(struct kmem_cache *cachep, void **objpp, int len,
 			int node);
-static int enable_cpucache(struct kmem_cache *cachep);
+static int enable_cpucache(struct kmem_cache *cachep, gfp_t gfp);
 static void cache_reap(struct work_struct *unused);
 
 /*
@@ -958,12 +958,12 @@ static void __cpuinit start_cpu_timer(int cpu)
 }
 
 static struct array_cache *alloc_arraycache(int node, int entries,
-					    int batchcount)
+					    int batchcount, gfp_t gfp)
 {
 	int memsize = sizeof(void *) * entries + sizeof(struct array_cache);
 	struct array_cache *nc = NULL;
 
-	nc = kmalloc_node(memsize, GFP_KERNEL, node);
+	nc = kmalloc_node(memsize, gfp, node);
 	if (nc) {
 		nc->avail = 0;
 		nc->limit = entries;
@@ -1003,7 +1003,7 @@ static int transfer_objects(struct array_cache *to,
 #define drain_alien_cache(cachep, alien) do { } while (0)
 #define reap_alien(cachep, l3) do { } while (0)
 
-static inline struct array_cache **alloc_alien_cache(int node, int limit)
+static inline struct array_cache **alloc_alien_cache(int node, int limit, gfp_t gfp)
 {
 	return (struct array_cache **)BAD_ALIEN_MAGIC;
 }
@@ -1034,7 +1034,7 @@ static inline void *____cache_alloc_node(struct kmem_cache *cachep,
 static void *____cache_alloc_node(struct kmem_cache *, gfp_t, int);
 static void *alternate_node_alloc(struct kmem_cache *, gfp_t);
 
-static struct array_cache **alloc_alien_cache(int node, int limit)
+static struct array_cache **alloc_alien_cache(int node, int limit, gfp_t gfp)
 {
 	struct array_cache **ac_ptr;
 	int memsize = sizeof(void *) * nr_node_ids;
@@ -1042,14 +1042,14 @@ static struct array_cache **alloc_alien_cache(int node, int limit)
 
 	if (limit > 1)
 		limit = 12;
-	ac_ptr = kmalloc_node(memsize, GFP_KERNEL, node);
+	ac_ptr = kmalloc_node(memsize, gfp, node);
 	if (ac_ptr) {
 		for_each_node(i) {
 			if (i == node || !node_online(i)) {
 				ac_ptr[i] = NULL;
 				continue;
 			}
-			ac_ptr[i] = alloc_arraycache(node, limit, 0xbaadf00d);
+			ac_ptr[i] = alloc_arraycache(node, limit, 0xbaadf00d, gfp);
 			if (!ac_ptr[i]) {
 				for (i--; i >= 0; i--)
 					kfree(ac_ptr[i]);
@@ -1282,20 +1282,20 @@ static int __cpuinit cpuup_prepare(long cpu)
 		struct array_cache **alien = NULL;
 
 		nc = alloc_arraycache(node, cachep->limit,
-					cachep->batchcount);
+					cachep->batchcount, GFP_KERNEL);
 		if (!nc)
 			goto bad;
 		if (cachep->shared) {
 			shared = alloc_arraycache(node,
 				cachep->shared * cachep->batchcount,
-				0xbaadf00d);
+				0xbaadf00d, GFP_KERNEL);
 			if (!shared) {
 				kfree(nc);
 				goto bad;
 			}
 		}
 		if (use_alien_caches) {
-			alien = alloc_alien_cache(node, cachep->limit);
+			alien = alloc_alien_cache(node, cachep->limit, GFP_KERNEL);
 			if (!alien) {
 				kfree(shared);
 				kfree(nc);
@@ -1399,10 +1399,9 @@ static void init_list(struct kmem_cache *cachep, struct kmem_list3 *list,
 {
 	struct kmem_list3 *ptr;
 
-	ptr = kmalloc_node(sizeof(struct kmem_list3), GFP_KERNEL, nodeid);
+	ptr = kmalloc_node(sizeof(struct kmem_list3), GFP_NOWAIT, nodeid);
 	BUG_ON(!ptr);
 
-	local_irq_disable();
 	memcpy(ptr, list, sizeof(struct kmem_list3));
 	/*
 	 * Do not assume that spinlocks can be initialized via memcpy:
@@ -1411,7 +1410,6 @@ static void init_list(struct kmem_cache *cachep, struct kmem_list3 *list,
 
 	MAKE_ALL_LISTS(cachep, ptr, nodeid);
 	cachep->nodelists[nodeid] = ptr;
-	local_irq_enable();
 }
 
 /*
@@ -1575,9 +1573,8 @@ void __init kmem_cache_init(void)
 	{
 		struct array_cache *ptr;
 
-		ptr = kmalloc(sizeof(struct arraycache_init), GFP_KERNEL);
+		ptr = kmalloc(sizeof(struct arraycache_init), GFP_NOWAIT);
 
-		local_irq_disable();
 		BUG_ON(cpu_cache_get(&cache_cache) != &initarray_cache.cache);
 		memcpy(ptr, cpu_cache_get(&cache_cache),
 		       sizeof(struct arraycache_init));
@@ -1587,11 +1584,9 @@ void __init kmem_cache_init(void)
 		spin_lock_init(&ptr->lock);
 
 		cache_cache.array[smp_processor_id()] = ptr;
-		local_irq_enable();
 
-		ptr = kmalloc(sizeof(struct arraycache_init), GFP_KERNEL);
+		ptr = kmalloc(sizeof(struct arraycache_init), GFP_NOWAIT);
 
-		local_irq_disable();
 		BUG_ON(cpu_cache_get(malloc_sizes[INDEX_AC].cs_cachep)
 		       != &initarray_generic.cache);
 		memcpy(ptr, cpu_cache_get(malloc_sizes[INDEX_AC].cs_cachep),
@@ -1603,7 +1598,6 @@ void __init kmem_cache_init(void)
 
 		malloc_sizes[INDEX_AC].cs_cachep->array[smp_processor_id()] =
 		    ptr;
-		local_irq_enable();
 	}
 	/* 5) Replace the bootstrap kmem_list3's */
 	{
@@ -1627,7 +1621,7 @@ void __init kmem_cache_init(void)
 		struct kmem_cache *cachep;
 		mutex_lock(&cache_chain_mutex);
 		list_for_each_entry(cachep, &cache_chain, next)
-			if (enable_cpucache(cachep))
+			if (enable_cpucache(cachep, GFP_NOWAIT))
 				BUG();
 		mutex_unlock(&cache_chain_mutex);
 	}
@@ -2064,10 +2058,10 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
 	return left_over;
 }
 
-static int __init_refok setup_cpu_cache(struct kmem_cache *cachep)
+static int __init_refok setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
 {
 	if (g_cpucache_up == FULL)
-		return enable_cpucache(cachep);
+		return enable_cpucache(cachep, gfp);
 
 	if (g_cpucache_up == NONE) {
 		/*
@@ -2089,7 +2083,7 @@ static int __init_refok setup_cpu_cache(struct kmem_cache *cachep)
 			g_cpucache_up = PARTIAL_AC;
 	} else {
 		cachep->array[smp_processor_id()] =
-			kmalloc(sizeof(struct arraycache_init), GFP_KERNEL);
+			kmalloc(sizeof(struct arraycache_init), gfp);
 
 		if (g_cpucache_up == PARTIAL_AC) {
 			set_up_list3s(cachep, SIZE_L3);
@@ -2153,6 +2147,7 @@ kmem_cache_create (const char *name, size_t size, size_t align,
 {
 	size_t left_over, slab_size, ralign;
 	struct kmem_cache *cachep = NULL, *pc;
+	gfp_t gfp;
 
 	/*
 	 * Sanity checks... these are all serious usage bugs.
@@ -2168,8 +2163,10 @@ kmem_cache_create (const char *name, size_t size, size_t align,
 	 * We use cache_chain_mutex to ensure a consistent view of
 	 * cpu_online_mask as well.  Please see cpuup_callback
 	 */
-	get_online_cpus();
-	mutex_lock(&cache_chain_mutex);
+	if (slab_is_available()) {
+		get_online_cpus();
+		mutex_lock(&cache_chain_mutex);
+	}
 
 	list_for_each_entry(pc, &cache_chain, next) {
 		char tmp;
@@ -2278,8 +2275,13 @@ kmem_cache_create (const char *name, size_t size, size_t align,
 	 */
 	align = ralign;
 
+	if (slab_is_available())
+		gfp = GFP_KERNEL;
+	else
+		gfp = GFP_NOWAIT;
+
 	/* Get cache's description obj. */
-	cachep = kmem_cache_zalloc(&cache_cache, GFP_KERNEL);
+	cachep = kmem_cache_zalloc(&cache_cache, gfp);
 	if (!cachep)
 		goto oops;
 
@@ -2382,7 +2384,7 @@ kmem_cache_create (const char *name, size_t size, size_t align,
 	cachep->ctor = ctor;
 	cachep->name = name;
 
-	if (setup_cpu_cache(cachep)) {
+	if (setup_cpu_cache(cachep, gfp)) {
 		__kmem_cache_destroy(cachep);
 		cachep = NULL;
 		goto oops;
@@ -2394,8 +2396,10 @@ oops:
 	if (!cachep && (flags & SLAB_PANIC))
 		panic("kmem_cache_create(): failed to create slab `%s'\n",
 		      name);
-	mutex_unlock(&cache_chain_mutex);
-	put_online_cpus();
+	if (slab_is_available()) {
+		mutex_unlock(&cache_chain_mutex);
+		put_online_cpus();
+	}
 	return cachep;
 }
 EXPORT_SYMBOL(kmem_cache_create);
@@ -3802,7 +3806,7 @@ EXPORT_SYMBOL_GPL(kmem_cache_name);
 /*
  * This initializes kmem_list3 or resizes various caches for all nodes.
  */
-static int alloc_kmemlist(struct kmem_cache *cachep)
+static int alloc_kmemlist(struct kmem_cache *cachep, gfp_t gfp)
 {
 	int node;
 	struct kmem_list3 *l3;
@@ -3812,7 +3816,7 @@ static int alloc_kmemlist(struct kmem_cache *cachep)
 	for_each_online_node(node) {
 
                 if (use_alien_caches) {
-                        new_alien = alloc_alien_cache(node, cachep->limit);
+                        new_alien = alloc_alien_cache(node, cachep->limit, gfp);
                         if (!new_alien)
                                 goto fail;
                 }
@@ -3821,7 +3825,7 @@ static int alloc_kmemlist(struct kmem_cache *cachep)
 		if (cachep->shared) {
 			new_shared = alloc_arraycache(node,
 				cachep->shared*cachep->batchcount,
-					0xbaadf00d);
+					0xbaadf00d, gfp);
 			if (!new_shared) {
 				free_alien_cache(new_alien);
 				goto fail;
@@ -3850,7 +3854,7 @@ static int alloc_kmemlist(struct kmem_cache *cachep)
 			free_alien_cache(new_alien);
 			continue;
 		}
-		l3 = kmalloc_node(sizeof(struct kmem_list3), GFP_KERNEL, node);
+		l3 = kmalloc_node(sizeof(struct kmem_list3), gfp, node);
 		if (!l3) {
 			free_alien_cache(new_alien);
 			kfree(new_shared);
@@ -3906,18 +3910,18 @@ static void do_ccupdate_local(void *info)
 
 /* Always called with the cache_chain_mutex held */
 static int do_tune_cpucache(struct kmem_cache *cachep, int limit,
-				int batchcount, int shared)
+				int batchcount, int shared, gfp_t gfp)
 {
 	struct ccupdate_struct *new;
 	int i;
 
-	new = kzalloc(sizeof(*new), GFP_KERNEL);
+	new = kzalloc(sizeof(*new), gfp);
 	if (!new)
 		return -ENOMEM;
 
 	for_each_online_cpu(i) {
 		new->new[i] = alloc_arraycache(cpu_to_node(i), limit,
-						batchcount);
+						batchcount, gfp);
 		if (!new->new[i]) {
 			for (i--; i >= 0; i--)
 				kfree(new->new[i]);
@@ -3944,11 +3948,11 @@ static int do_tune_cpucache(struct kmem_cache *cachep, int limit,
 		kfree(ccold);
 	}
 	kfree(new);
-	return alloc_kmemlist(cachep);
+	return alloc_kmemlist(cachep, gfp);
 }
 
 /* Called with cache_chain_mutex held always */
-static int enable_cpucache(struct kmem_cache *cachep)
+static int enable_cpucache(struct kmem_cache *cachep, gfp_t gfp)
 {
 	int err;
 	int limit, shared;
@@ -3994,7 +3998,7 @@ static int enable_cpucache(struct kmem_cache *cachep)
 	if (limit > 32)
 		limit = 32;
 #endif
-	err = do_tune_cpucache(cachep, limit, (limit + 1) / 2, shared);
+	err = do_tune_cpucache(cachep, limit, (limit + 1) / 2, shared, gfp);
 	if (err)
 		printk(KERN_ERR "enable_cpucache failed for %s, error %d.\n",
 		       cachep->name, -err);
@@ -4300,7 +4304,8 @@ ssize_t slabinfo_write(struct file *file, const char __user * buffer,
 				res = 0;
 			} else {
 				res = do_tune_cpucache(cachep, limit,
-						       batchcount, shared);
+						       batchcount, shared,
+						       GFP_KERNEL);
 			}
 			break;
 		}
diff --git a/mm/slub.c b/mm/slub.c
index 65ffda5..0ead807 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2557,13 +2557,16 @@ static struct kmem_cache *create_kmalloc_cache(struct kmem_cache *s,
 	if (gfp_flags & SLUB_DMA)
 		flags = SLAB_CACHE_DMA;
 
-	down_write(&slub_lock);
+	/*
+	 * This function is called with IRQs disabled during early-boot on
+	 * single CPU so there's no need to take slub_lock here.
+	 */
 	if (!kmem_cache_open(s, gfp_flags, name, size, ARCH_KMALLOC_MINALIGN,
 								flags, NULL))
 		goto panic;
 
 	list_add(&s->list, &slab_caches);
-	up_write(&slub_lock);
+
 	if (sysfs_slab_add(s))
 		goto panic;
 	return s;
@@ -3021,7 +3024,7 @@ void __init kmem_cache_init(void)
 	 * kmem_cache_open for slab_state == DOWN.
 	 */
 	create_kmalloc_cache(&kmalloc_caches[0], "kmem_cache_node",
-		sizeof(struct kmem_cache_node), GFP_KERNEL);
+		sizeof(struct kmem_cache_node), GFP_NOWAIT);
 	kmalloc_caches[0].refcount = -1;
 	caches++;
 
@@ -3034,16 +3037,16 @@ void __init kmem_cache_init(void)
 	/* Caches that are not of the two-to-the-power-of size */
 	if (KMALLOC_MIN_SIZE <= 64) {
 		create_kmalloc_cache(&kmalloc_caches[1],
-				"kmalloc-96", 96, GFP_KERNEL);
+				"kmalloc-96", 96, GFP_NOWAIT);
 		caches++;
 		create_kmalloc_cache(&kmalloc_caches[2],
-				"kmalloc-192", 192, GFP_KERNEL);
+				"kmalloc-192", 192, GFP_NOWAIT);
 		caches++;
 	}
 
 	for (i = KMALLOC_SHIFT_LOW; i < SLUB_PAGE_SHIFT; i++) {
 		create_kmalloc_cache(&kmalloc_caches[i],
-			"kmalloc", 1 << i, GFP_KERNEL);
+			"kmalloc", 1 << i, GFP_NOWAIT);
 		caches++;
 	}
 
@@ -3080,7 +3083,7 @@ void __init kmem_cache_init(void)
 	/* Provide the correct kmalloc names now that the caches are up */
 	for (i = KMALLOC_SHIFT_LOW; i < SLUB_PAGE_SHIFT; i++)
 		kmalloc_caches[i]. name =
-			kasprintf(GFP_KERNEL, "kmalloc-%d", 1 << i);
+			kasprintf(GFP_NOWAIT, "kmalloc-%d", 1 << i);
 
 #ifdef CONFIG_SMP
 	register_cpu_notifier(&slab_notifier);
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
