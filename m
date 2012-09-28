Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id EFAE36B0071
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 15:34:24 -0400 (EDT)
Message-Id: <0000013a0e5f5fbf-3a8952c6-477c-4ea3-b6a3-6bdba4b2c4f1-000000@email.amazonses.com>
Date: Fri, 28 Sep 2012 19:34:22 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK2 [08/15] slab: Common name for the per node structures
References: <20120928191715.368450474@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Rename the structure used for the per node structures in slab
to have a name that expresses that fact.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab_def.h
===================================================================
--- linux.orig/include/linux/slab_def.h	2012-09-28 11:50:45.418698300 -0500
+++ linux/include/linux/slab_def.h	2012-09-28 11:50:54.606889979 -0500
@@ -88,7 +88,7 @@ struct kmem_cache {
 	 * We still use [NR_CPUS] and not [1] or [0] because cache_cache
 	 * is statically defined, so we reserve the max number of cpus.
 	 */
-	struct kmem_list3 **nodelists;
+	struct kmem_cache_node **nodelists;
 	struct array_cache *array[NR_CPUS + MAX_NUMNODES];
 	/*
 	 * Do not add fields after array[]
Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2012-09-28 11:50:45.430698559 -0500
+++ linux/mm/slab.c	2012-09-28 11:50:54.610890058 -0500
@@ -304,7 +304,7 @@ struct arraycache_init {
 /*
  * The slab lists for all objects.
  */
-struct kmem_list3 {
+struct kmem_cache_node {
 	struct list_head slabs_partial;	/* partial list first, better asm code */
 	struct list_head slabs_full;
 	struct list_head slabs_free;
@@ -322,13 +322,13 @@ struct kmem_list3 {
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
@@ -337,9 +337,9 @@ static void cache_reap(struct work_struc
 static int slab_early_init = 1;
 
 #define INDEX_AC kmalloc_index(sizeof(struct arraycache_init))
-#define INDEX_L3 kmalloc_index(sizeof(struct kmem_list3))
+#define INDEX_L3 kmalloc_index(sizeof(struct kmem_cache_node))
 
-static void kmem_list3_init(struct kmem_list3 *parent)
+static void kmem_list3_init(struct kmem_cache_node *parent)
 {
 	INIT_LIST_HEAD(&parent->slabs_full);
 	INIT_LIST_HEAD(&parent->slabs_partial);
@@ -562,7 +562,7 @@ static void slab_set_lock_classes(struct
 		int q)
 {
 	struct array_cache **alc;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 	int r;
 
 	l3 = cachep->nodelists[q];
@@ -607,7 +607,7 @@ static void init_node_lock_keys(int q)
 		return;
 
 	for (i = 1; i < PAGE_SHIFT + MAX_ORDER; i++) {
-		struct kmem_list3 *l3;
+		struct kmem_cache_node *l3;
 		struct kmem_cache *cache = kmalloc_caches[i];
 
 		if (!cache)
@@ -888,7 +888,7 @@ static inline bool is_slab_pfmemalloc(st
 static void recheck_pfmemalloc_active(struct kmem_cache *cachep,
 						struct array_cache *ac)
 {
-	struct kmem_list3 *l3 = cachep->nodelists[numa_mem_id()];
+	struct kmem_cache_node *l3 = cachep->nodelists[numa_mem_id()];
 	struct slab *slabp;
 	unsigned long flags;
 
@@ -921,7 +921,7 @@ static void *__ac_get_obj(struct kmem_ca
 
 	/* Ensure the caller is allowed to use objects from PFMEMALLOC slab */
 	if (unlikely(is_obj_pfmemalloc(objp))) {
-		struct kmem_list3 *l3;
+		struct kmem_cache_node *l3;
 
 		if (gfp_pfmemalloc_allowed(flags)) {
 			clear_obj_pfmemalloc(&objp);
@@ -1093,7 +1093,7 @@ static void free_alien_cache(struct arra
 static void __drain_alien_cache(struct kmem_cache *cachep,
 				struct array_cache *ac, int node)
 {
-	struct kmem_list3 *rl3 = cachep->nodelists[node];
+	struct kmem_cache_node *rl3 = cachep->nodelists[node];
 
 	if (ac->avail) {
 		spin_lock(&rl3->list_lock);
@@ -1114,7 +1114,7 @@ static void __drain_alien_cache(struct k
 /*
  * Called from cache_reap() to regularly drain alien caches round robin.
  */
-static void reap_alien(struct kmem_cache *cachep, struct kmem_list3 *l3)
+static void reap_alien(struct kmem_cache *cachep, struct kmem_cache_node *l3)
 {
 	int node = __this_cpu_read(slab_reap_node);
 
@@ -1149,7 +1149,7 @@ static inline int cache_free_alien(struc
 {
 	struct slab *slabp = virt_to_slab(objp);
 	int nodeid = slabp->nodeid;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 	struct array_cache *alien = NULL;
 	int node;
 
@@ -1194,8 +1194,8 @@ static inline int cache_free_alien(struc
 static int init_cache_nodelists_node(int node)
 {
 	struct kmem_cache *cachep;
-	struct kmem_list3 *l3;
-	const int memsize = sizeof(struct kmem_list3);
+	struct kmem_cache_node *l3;
+	const int memsize = sizeof(struct kmem_cache_node);
 
 	list_for_each_entry(cachep, &slab_caches, list) {
 		/*
@@ -1231,7 +1231,7 @@ static int init_cache_nodelists_node(int
 static void __cpuinit cpuup_canceled(long cpu)
 {
 	struct kmem_cache *cachep;
-	struct kmem_list3 *l3 = NULL;
+	struct kmem_cache_node *l3 = NULL;
 	int node = cpu_to_mem(cpu);
 	const struct cpumask *mask = cpumask_of_node(node);
 
@@ -1296,7 +1296,7 @@ free_array_cache:
 static int __cpuinit cpuup_prepare(long cpu)
 {
 	struct kmem_cache *cachep;
-	struct kmem_list3 *l3 = NULL;
+	struct kmem_cache_node *l3 = NULL;
 	int node = cpu_to_mem(cpu);
 	int err;
 
@@ -1447,7 +1447,7 @@ static int __meminit drain_cache_nodelis
 	int ret = 0;
 
 	list_for_each_entry(cachep, &slab_caches, list) {
-		struct kmem_list3 *l3;
+		struct kmem_cache_node *l3;
 
 		l3 = cachep->nodelists[node];
 		if (!l3)
@@ -1500,15 +1500,15 @@ out:
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
@@ -1540,7 +1540,7 @@ static void __init set_up_list3s(struct
  */
 static void setup_nodelists_pointer(struct kmem_cache *s)
 {
-	s->nodelists = (struct kmem_list3 **)&s->array[nr_cpu_ids];
+	s->nodelists = (struct kmem_cache_node **)&s->array[nr_cpu_ids];
 }
 
 /*
@@ -1600,7 +1600,7 @@ void __init kmem_cache_init(void)
 	 */
 	create_boot_cache(kmem_cache, "kmem_cache",
 		offsetof(struct kmem_cache, array[nr_cpu_ids]) +
-				  nr_node_ids * sizeof(struct kmem_list3 *),
+				  nr_node_ids * sizeof(struct kmem_cache_node *),
 				  SLAB_HWCACHE_ALIGN);
 
 	slab_state = PARTIAL;
@@ -1775,7 +1775,7 @@ __initcall(cpucache_init);
 static noinline void
 slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
 {
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 	struct slab *slabp;
 	unsigned long flags;
 	int node;
@@ -2265,7 +2265,7 @@ static int __init_refok setup_cpu_cache(
 			int node;
 			for_each_online_node(node) {
 				cachep->nodelists[node] =
-				    kmalloc_node(sizeof(struct kmem_list3),
+				    kmalloc_node(sizeof(struct kmem_cache_node),
 						gfp, node);
 				BUG_ON(!cachep->nodelists[node]);
 				kmem_list3_init(cachep->nodelists[node]);
@@ -2540,7 +2540,7 @@ static void check_spinlock_acquired_node
 #define check_spinlock_acquired_node(x, y) do { } while(0)
 #endif
 
-static void drain_array(struct kmem_cache *cachep, struct kmem_list3 *l3,
+static void drain_array(struct kmem_cache *cachep, struct kmem_cache_node *l3,
 			struct array_cache *ac,
 			int force, int node);
 
@@ -2560,7 +2560,7 @@ static void do_drain(void *arg)
 
 static void drain_cpu_caches(struct kmem_cache *cachep)
 {
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 	int node;
 
 	on_each_cpu(do_drain, cachep, 1);
@@ -2585,7 +2585,7 @@ static void drain_cpu_caches(struct kmem
  * Returns the actual number of slabs released.
  */
 static int drain_freelist(struct kmem_cache *cache,
-			struct kmem_list3 *l3, int tofree)
+			struct kmem_cache_node *l3, int tofree)
 {
 	struct list_head *p;
 	int nr_freed;
@@ -2623,7 +2623,7 @@ out:
 static int __cache_shrink(struct kmem_cache *cachep)
 {
 	int ret = 0, i = 0;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 
 	drain_cpu_caches(cachep);
 
@@ -2665,7 +2665,7 @@ EXPORT_SYMBOL(kmem_cache_shrink);
 int __kmem_cache_shutdown(struct kmem_cache *cachep)
 {
 	int i;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 	int rc = __cache_shrink(cachep);
 
 	if (rc)
@@ -2862,7 +2862,7 @@ static int cache_grow(struct kmem_cache
 	struct slab *slabp;
 	size_t offset;
 	gfp_t local_flags;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 
 	/*
 	 * Be lazy and only check for valid flags here,  keeping it out of the
@@ -3052,7 +3052,7 @@ static void *cache_alloc_refill(struct k
 							bool force_refill)
 {
 	int batchcount;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 	struct array_cache *ac;
 	int node;
 
@@ -3384,7 +3384,7 @@ static void *____cache_alloc_node(struct
 {
 	struct list_head *entry;
 	struct slab *slabp;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 	void *obj;
 	int x;
 
@@ -3575,7 +3575,7 @@ static void free_block(struct kmem_cache
 		       int node)
 {
 	int i;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 
 	for (i = 0; i < nr_objects; i++) {
 		void *objp;
@@ -3621,7 +3621,7 @@ static void free_block(struct kmem_cache
 static void cache_flusharray(struct kmem_cache *cachep, struct array_cache *ac)
 {
 	int batchcount;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 	int node = numa_mem_id();
 
 	batchcount = ac->batchcount;
@@ -3918,7 +3918,7 @@ EXPORT_SYMBOL(kmem_cache_size);
 static int alloc_kmemlist(struct kmem_cache *cachep, gfp_t gfp)
 {
 	int node;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 	struct array_cache *new_shared;
 	struct array_cache **new_alien = NULL;
 
@@ -3963,7 +3963,7 @@ static int alloc_kmemlist(struct kmem_ca
 			free_alien_cache(new_alien);
 			continue;
 		}
-		l3 = kmalloc_node(sizeof(struct kmem_list3), gfp, node);
+		l3 = kmalloc_node(sizeof(struct kmem_cache_node), gfp, node);
 		if (!l3) {
 			free_alien_cache(new_alien);
 			kfree(new_shared);
@@ -4120,7 +4120,7 @@ static int enable_cpucache(struct kmem_c
  * necessary. Note that the l3 listlock also protects the array_cache
  * if drain_array() is used on the shared array.
  */
-static void drain_array(struct kmem_cache *cachep, struct kmem_list3 *l3,
+static void drain_array(struct kmem_cache *cachep, struct kmem_cache_node *l3,
 			 struct array_cache *ac, int force, int node)
 {
 	int tofree;
@@ -4159,7 +4159,7 @@ static void drain_array(struct kmem_cach
 static void cache_reap(struct work_struct *w)
 {
 	struct kmem_cache *searchp;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 	int node = numa_mem_id();
 	struct delayed_work *work = to_delayed_work(w);
 
@@ -4269,7 +4269,7 @@ static int s_show(struct seq_file *m, vo
 	const char *name;
 	char *error = NULL;
 	int node;
-	struct kmem_list3 *l3;
+	struct kmem_cache_node *l3;
 
 	active_objs = 0;
 	num_slabs = 0;
@@ -4512,7 +4512,7 @@ static int leaks_show(struct seq_file *m
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
