Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id A1F876B0072
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 14:12:20 -0500 (EST)
Message-Id: <0000013c25e08970-50551550-09c8-4eca-872e-ec6e7fbd61ee-000000@email.amazonses.com>
Date: Thu, 10 Jan 2013 19:12:17 +0000
From: Christoph Lameter <cl@linux.com>
Subject: REN2 [05/13] slab: Common name for the per node structures
References: <20130110190027.780479755@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

Rename the structure used for the per node structures in slab
to have a name that expresses that fact.

Acked-by: Glauber Costa <glommer@parallels.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab_def.h
===================================================================
--- linux.orig/include/linux/slab_def.h	2013-01-10 09:48:38.379114005 -0600
+++ linux/include/linux/slab_def.h	2013-01-10 09:54:20.332351136 -0600
@@ -95,7 +95,7 @@ struct kmem_cache {
 	 * pointer for each node since "nodelists" uses the remainder of
 	 * available pointers.
 	 */
-	struct kmem_list3 **nodelists;
+	struct kmem_cache_node **nodelists;
 	struct array_cache *array[NR_CPUS + MAX_NUMNODES];
 	/*
 	 * Do not add fields after array[]
Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2013-01-10 09:48:38.375113938 -0600
+++ linux/mm/slab.c	2013-01-10 09:55:04.981034970 -0600
@@ -288,7 +288,7 @@ struct arraycache_init {
 /*
  * The slab lists for all objects.
  */
-struct kmem_list3 {
+struct kmem_cache_node {
 	struct list_head slabs_partial;	/* partial list first, better asm code */
 	struct list_head slabs_full;
 	struct list_head slabs_free;
@@ -306,13 +306,13 @@ struct kmem_list3 {
  * Need this for bootstrapping a per node allocator.
  */
 #define NUM_INIT_LISTS (3 * MAX_NUMNODES)
-static struct kmem_list3 __initdata initkmem_list3[NUM_INIT_LISTS];
+static struct kmem_cache_node __initdata initkmem_list3[NUM_INIT_LISTS];
 #define	CACHE_CACHE 0
 #define	SIZE_AC MAX_NUMNODES
 #define	SIZE_L3 (2 * MAX_NUMNODES)
 
 static int drain_freelist(struct kmem_cache *cache,
-			struct kmem_list3 *l3, int tofree);
+			struct kmem_cache_node *l3, int tofree);
 static void free_block(struct kmem_cache *cachep, void **objpp, int len,
 			int node);
 static int enable_cpucache(struct kmem_cache *cachep, gfp_t gfp);
@@ -329,9 +329,9 @@ EXPORT_SYMBOL(kmalloc_dma_caches);
 static int slab_early_init = 1;
 
 #define INDEX_AC kmalloc_index(sizeof(struct arraycache_init))
-#define INDEX_L3 kmalloc_index(sizeof(struct kmem_list3))
+#define INDEX_L3 kmalloc_index(sizeof(struct kmem_cache_node))
 
-static void kmem_list3_init(struct kmem_list3 *parent)
+static void kmem_list3_init(struct kmem_cache_node *parent)
 {
 	INIT_LIST_HEAD(&parent->slabs_full);
 	INIT_LIST_HEAD(&parent->slabs_partial);
@@ -546,7 +546,7 @@ static void slab_set_lock_classes(struct
 		int q)
 {
 	struct array_cache **alc;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 	int r;
 
 	l3 = cachep->nodelists[q];
@@ -591,7 +591,7 @@ static void init_node_lock_keys(int q)
 		return;
 
 	for (i = 1; i < PAGE_SHIFT + MAX_ORDER; i++) {
-		struct kmem_list3 *l3;
+		struct kmem_cache_node *l3;
 		struct kmem_cache *cache = kmalloc_caches[i];
 
 		if (!cache)
@@ -608,9 +608,8 @@ static void init_node_lock_keys(int q)
 
 static void on_slab_lock_classes_node(struct kmem_cache *cachep, int q)
 {
-	struct kmem_list3 *l3;
-	l3 = cachep->nodelists[q];
-	if (!l3)
+
+	if (!cachep->nodelists[q])
 		return;
 
 	slab_set_lock_classes(cachep, &on_slab_l3_key,
@@ -901,7 +900,7 @@ static inline bool is_slab_pfmemalloc(st
 static void recheck_pfmemalloc_active(struct kmem_cache *cachep,
 						struct array_cache *ac)
 {
-	struct kmem_list3 *l3 = cachep->nodelists[numa_mem_id()];
+	struct kmem_cache_node *l3 = cachep->nodelists[numa_mem_id()];
 	struct slab *slabp;
 	unsigned long flags;
 
@@ -934,7 +933,7 @@ static void *__ac_get_obj(struct kmem_ca
 
 	/* Ensure the caller is allowed to use objects from PFMEMALLOC slab */
 	if (unlikely(is_obj_pfmemalloc(objp))) {
-		struct kmem_list3 *l3;
+		struct kmem_cache_node *l3;
 
 		if (gfp_pfmemalloc_allowed(flags)) {
 			clear_obj_pfmemalloc(&objp);
@@ -1106,7 +1105,7 @@ static void free_alien_cache(struct arra
 static void __drain_alien_cache(struct kmem_cache *cachep,
 				struct array_cache *ac, int node)
 {
-	struct kmem_list3 *rl3 = cachep->nodelists[node];
+	struct kmem_cache_node *rl3 = cachep->nodelists[node];
 
 	if (ac->avail) {
 		spin_lock(&rl3->list_lock);
@@ -1127,7 +1126,7 @@ static void __drain_alien_cache(struct k
 /*
  * Called from cache_reap() to regularly drain alien caches round robin.
  */
-static void reap_alien(struct kmem_cache *cachep, struct kmem_list3 *l3)
+static void reap_alien(struct kmem_cache *cachep, struct kmem_cache_node *l3)
 {
 	int node = __this_cpu_read(slab_reap_node);
 
@@ -1162,7 +1161,7 @@ static inline int cache_free_alien(struc
 {
 	struct slab *slabp = virt_to_slab(objp);
 	int nodeid = slabp->nodeid;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 	struct array_cache *alien = NULL;
 	int node;
 
@@ -1207,8 +1206,8 @@ static inline int cache_free_alien(struc
 static int init_cache_nodelists_node(int node)
 {
 	struct kmem_cache *cachep;
-	struct kmem_list3 *l3;
-	const int memsize = sizeof(struct kmem_list3);
+	struct kmem_cache_node *l3;
+	const int memsize = sizeof(struct kmem_cache_node);
 
 	list_for_each_entry(cachep, &slab_caches, list) {
 		/*
@@ -1244,7 +1243,7 @@ static int init_cache_nodelists_node(int
 static void __cpuinit cpuup_canceled(long cpu)
 {
 	struct kmem_cache *cachep;
-	struct kmem_list3 *l3 = NULL;
+	struct kmem_cache_node *l3 = NULL;
 	int node = cpu_to_mem(cpu);
 	const struct cpumask *mask = cpumask_of_node(node);
 
@@ -1309,7 +1308,7 @@ free_array_cache:
 static int __cpuinit cpuup_prepare(long cpu)
 {
 	struct kmem_cache *cachep;
-	struct kmem_list3 *l3 = NULL;
+	struct kmem_cache_node *l3 = NULL;
 	int node = cpu_to_mem(cpu);
 	int err;
 
@@ -1463,7 +1462,7 @@ static int __meminit drain_cache_nodelis
 	int ret = 0;
 
 	list_for_each_entry(cachep, &slab_caches, list) {
-		struct kmem_list3 *l3;
+		struct kmem_cache_node *l3;
 
 		l3 = cachep->nodelists[node];
 		if (!l3)
@@ -1516,15 +1515,15 @@ out:
 /*
  * swap the static kmem_list3 with kmalloced memory
  */
-static void __init init_list(struct kmem_cache *cachep, struct kmem_list3 *list,
+static void __init init_list(struct kmem_cache *cachep, struct kmem_cache_node *list,
 				int nodeid)
 {
-	struct kmem_list3 *ptr;
+	struct kmem_cache_node *ptr;
 
-	ptr = kmalloc_node(sizeof(struct kmem_list3), GFP_NOWAIT, nodeid);
+	ptr = kmalloc_node(sizeof(struct kmem_cache_node), GFP_NOWAIT, nodeid);
 	BUG_ON(!ptr);
 
-	memcpy(ptr, list, sizeof(struct kmem_list3));
+	memcpy(ptr, list, sizeof(struct kmem_cache_node));
 	/*
 	 * Do not assume that spinlocks can be initialized via memcpy:
 	 */
@@ -1556,7 +1555,7 @@ static void __init set_up_list3s(struct
  */
 static void setup_nodelists_pointer(struct kmem_cache *cachep)
 {
-	cachep->nodelists = (struct kmem_list3 **)&cachep->array[nr_cpu_ids];
+	cachep->nodelists = (struct kmem_cache_node **)&cachep->array[nr_cpu_ids];
 }
 
 /*
@@ -1613,7 +1612,7 @@ void __init kmem_cache_init(void)
 	 */
 	create_boot_cache(kmem_cache, "kmem_cache",
 		offsetof(struct kmem_cache, array[nr_cpu_ids]) +
-				  nr_node_ids * sizeof(struct kmem_list3 *),
+				  nr_node_ids * sizeof(struct kmem_cache_node *),
 				  SLAB_HWCACHE_ALIGN);
 	list_add(&kmem_cache->list, &slab_caches);
 
@@ -1787,7 +1786,7 @@ __initcall(cpucache_init);
 static noinline void
 slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
 {
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 	struct slab *slabp;
 	unsigned long flags;
 	int node;
@@ -2279,7 +2278,7 @@ static int __init_refok setup_cpu_cache(
 			int node;
 			for_each_online_node(node) {
 				cachep->nodelists[node] =
-				    kmalloc_node(sizeof(struct kmem_list3),
+				    kmalloc_node(sizeof(struct kmem_cache_node),
 						gfp, node);
 				BUG_ON(!cachep->nodelists[node]);
 				kmem_list3_init(cachep->nodelists[node]);
@@ -2547,7 +2546,7 @@ static void check_spinlock_acquired_node
 #define check_spinlock_acquired_node(x, y) do { } while(0)
 #endif
 
-static void drain_array(struct kmem_cache *cachep, struct kmem_list3 *l3,
+static void drain_array(struct kmem_cache *cachep, struct kmem_cache_node *l3,
 			struct array_cache *ac,
 			int force, int node);
 
@@ -2567,7 +2566,7 @@ static void do_drain(void *arg)
 
 static void drain_cpu_caches(struct kmem_cache *cachep)
 {
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 	int node;
 
 	on_each_cpu(do_drain, cachep, 1);
@@ -2592,7 +2591,7 @@ static void drain_cpu_caches(struct kmem
  * Returns the actual number of slabs released.
  */
 static int drain_freelist(struct kmem_cache *cache,
-			struct kmem_list3 *l3, int tofree)
+			struct kmem_cache_node *l3, int tofree)
 {
 	struct list_head *p;
 	int nr_freed;
@@ -2630,7 +2629,7 @@ out:
 static int __cache_shrink(struct kmem_cache *cachep)
 {
 	int ret = 0, i = 0;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 
 	drain_cpu_caches(cachep);
 
@@ -2672,7 +2671,7 @@ EXPORT_SYMBOL(kmem_cache_shrink);
 int __kmem_cache_shutdown(struct kmem_cache *cachep)
 {
 	int i;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 	int rc = __cache_shrink(cachep);
 
 	if (rc)
@@ -2869,7 +2868,7 @@ static int cache_grow(struct kmem_cache
 	struct slab *slabp;
 	size_t offset;
 	gfp_t local_flags;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 
 	/*
 	 * Be lazy and only check for valid flags here,  keeping it out of the
@@ -3059,7 +3058,7 @@ static void *cache_alloc_refill(struct k
 							bool force_refill)
 {
 	int batchcount;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 	struct array_cache *ac;
 	int node;
 
@@ -3391,7 +3390,7 @@ static void *____cache_alloc_node(struct
 {
 	struct list_head *entry;
 	struct slab *slabp;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 	void *obj;
 	int x;
 
@@ -3586,7 +3585,7 @@ static void free_block(struct kmem_cache
 		       int node)
 {
 	int i;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 
 	for (i = 0; i < nr_objects; i++) {
 		void *objp;
@@ -3632,7 +3631,7 @@ static void free_block(struct kmem_cache
 static void cache_flusharray(struct kmem_cache *cachep, struct array_cache *ac)
 {
 	int batchcount;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 	int node = numa_mem_id();
 
 	batchcount = ac->batchcount;
@@ -3924,7 +3923,7 @@ EXPORT_SYMBOL(kfree);
 static int alloc_kmemlist(struct kmem_cache *cachep, gfp_t gfp)
 {
 	int node;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 	struct array_cache *new_shared;
 	struct array_cache **new_alien = NULL;
 
@@ -3969,7 +3968,7 @@ static int alloc_kmemlist(struct kmem_ca
 			free_alien_cache(new_alien);
 			continue;
 		}
-		l3 = kmalloc_node(sizeof(struct kmem_list3), gfp, node);
+		l3 = kmalloc_node(sizeof(struct kmem_cache_node), gfp, node);
 		if (!l3) {
 			free_alien_cache(new_alien);
 			kfree(new_shared);
@@ -4165,7 +4164,7 @@ skip_setup:
  * necessary. Note that the l3 listlock also protects the array_cache
  * if drain_array() is used on the shared array.
  */
-static void drain_array(struct kmem_cache *cachep, struct kmem_list3 *l3,
+static void drain_array(struct kmem_cache *cachep, struct kmem_cache_node *l3,
 			 struct array_cache *ac, int force, int node)
 {
 	int tofree;
@@ -4204,7 +4203,7 @@ static void drain_array(struct kmem_cach
 static void cache_reap(struct work_struct *w)
 {
 	struct kmem_cache *searchp;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 	int node = numa_mem_id();
 	struct delayed_work *work = to_delayed_work(w);
 
@@ -4268,7 +4267,7 @@ void get_slabinfo(struct kmem_cache *cac
 	const char *name;
 	char *error = NULL;
 	int node;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 
 	active_objs = 0;
 	num_slabs = 0;
@@ -4482,7 +4481,7 @@ static int leaks_show(struct seq_file *m
 {
 	struct kmem_cache *cachep = list_entry(p, struct kmem_cache, list);
 	struct slab *slabp;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 	const char *name;
 	unsigned long *n = m->private;
 	int node;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
