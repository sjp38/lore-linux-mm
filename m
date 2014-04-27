Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id B02F26B006E
	for <linux-mm@kvack.org>; Sun, 27 Apr 2014 05:04:21 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id l4so4212116lbv.18
        for <linux-mm@kvack.org>; Sun, 27 Apr 2014 02:04:21 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id xl9si2788759lac.91.2014.04.27.02.04.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Apr 2014 02:04:20 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 6/6] memcg: cleanup kmem_id-related naming
Date: Sun, 27 Apr 2014 13:04:08 +0400
Message-ID: <3f888f9891b89debbc596d8c4e153b7ba67a3853.1398587474.git.vdavydov@parallels.com>
In-Reply-To: <cover.1398587474.git.vdavydov@parallels.com>
References: <cover.1398587474.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

The naming of mem_cgroup->kmemcg_id-related functions is rather
inconsistent. We tend to use cache_id as part of their names, but it
isn't quite right, because kmem_id isn't something specific to kmem
caches. It can be used for indexing any array that stores per memcg
data. For instance, we will use it to make list_lru per memcg in the
future. So let's clean up the names and comments related to kmem_id.

Brief change log:

** old name **                          ** new name **

mem_cgroup->kmemcg_id                   mem_cgroup->kmem_id

memcg_init_cache_id()                   memcg_init_kmem_id()
memcg_cache_id()                        memcg_kmem_id()
cache_from_memcg_idx()                  kmem_cache_of_memcg_by_id()
cache_from_memcg_idx(memcg_cache_id())  kmem_cache_of_memcg()

for_each_memcg_cache_index()            for_each_possible_memcg_kmem_id()

memcg_limited_groups                    memcg_kmem_ida
memcg_limited_groups_array_size         memcg_nr_kmem_ids_max

MEMCG_CACHES_MIN_SIZE                   <constant inlined>
MEMCG_CACHES_MAX_SIZE                   MEMCG_KMEM_ID_MAX + 1

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |   19 +++----
 mm/memcontrol.c            |  117 +++++++++++++++++++++-----------------------
 mm/slab.c                  |    4 +-
 mm/slab.h                  |   24 ++++++---
 mm/slab_common.c           |   10 ++--
 mm/slub.c                  |   10 ++--
 6 files changed, 93 insertions(+), 91 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b20f533a92ca..1a5c33fd40a4 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -458,15 +458,10 @@ static inline void sock_release_memcg(struct sock *sk)
 #ifdef CONFIG_MEMCG_KMEM
 extern struct static_key memcg_kmem_enabled_key;
 
-extern int memcg_limited_groups_array_size;
+extern int memcg_nr_kmem_ids_max;
 
-/*
- * Helper macro to loop through all memcg-specific caches. Callers must still
- * check if the cache is valid (it is either valid or NULL).
- * the slab_mutex must be held when looping through those caches
- */
-#define for_each_memcg_cache_index(_idx)	\
-	for ((_idx) = 0; (_idx) < memcg_limited_groups_array_size; (_idx)++)
+#define for_each_possible_memcg_kmem_id(id) \
+	for ((id) = 0; (id) < memcg_nr_kmem_ids_max; (id)++)
 
 static inline bool memcg_kmem_enabled(void)
 {
@@ -490,7 +485,7 @@ void __memcg_kmem_commit_charge(struct page *page,
 				       struct mem_cgroup *memcg, int order);
 void __memcg_kmem_uncharge_pages(struct page *page, int order);
 
-int memcg_cache_id(struct mem_cgroup *memcg);
+int memcg_kmem_id(struct mem_cgroup *memcg);
 
 struct kmem_cache *
 __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
@@ -591,8 +586,8 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 	return __memcg_kmem_get_cache(cachep, gfp);
 }
 #else
-#define for_each_memcg_cache_index(_idx)	\
-	for (; NULL; )
+#define for_each_possible_memcg_kmem_id(id) \
+	for ((id) = 0; 0; )
 
 static inline bool memcg_kmem_enabled(void)
 {
@@ -614,7 +609,7 @@ memcg_kmem_commit_charge(struct page *page, struct mem_cgroup *memcg, int order)
 {
 }
 
-static inline int memcg_cache_id(struct mem_cgroup *memcg)
+static inline int memcg_kmem_id(struct mem_cgroup *memcg)
 {
 	return -1;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c795c3e388dc..1077091e995f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -357,11 +357,22 @@ struct mem_cgroup {
 	struct cg_proto tcp_mem;
 #endif
 #if defined(CONFIG_MEMCG_KMEM)
+	/*
+	 * Each kmem-limited memory cgroup has a unique id. We use it for
+	 * indexing the arrays that store per cgroup data. An example of such
+	 * an array is kmem_cache->memcg_params->memcg_caches.
+	 *
+	 * We introduce a separate id instead of using cgroup->id to avoid
+	 * waste of memory in sparse environments, where we have a lot of
+	 * memory cgroups, but only a few of them are kmem-limited.
+	 *
+	 * For unlimited cgroups kmem_id equals -1.
+	 */
+	int kmem_id;
+
 	/* analogous to slab_common's slab_caches list, but per-memcg;
 	 * protected by memcg_slab_mutex */
 	struct list_head memcg_slab_caches;
-        /* Index in the kmem_cache->memcg_params->memcg_caches array */
-	int kmemcg_id;
 #endif
 
 	int last_scanned_node;
@@ -610,35 +621,28 @@ static void disarm_sock_keys(struct mem_cgroup *memcg)
 #endif
 
 #ifdef CONFIG_MEMCG_KMEM
+/* used for mem_cgroup->kmem_id allocations */
+static DEFINE_IDA(memcg_kmem_ida);
+
 /*
- * This will be the memcg's index in each cache's ->memcg_params->memcg_caches.
- * The main reason for not using cgroup id for this:
- *  this works better in sparse environments, where we have a lot of memcgs,
- *  but only a few kmem-limited. Or also, if we have, for instance, 200
- *  memcgs, and none but the 200th is kmem-limited, we'd have to have a
- *  200 entry array for that.
- *
- * The current size of the caches array is stored in
- * memcg_limited_groups_array_size.  It will double each time we have to
- * increase it.
+ * Max kmem id should be as large as max cgroup id so that we could enable
+ * kmem-accounting for each memory cgroup.
  */
-static DEFINE_IDA(kmem_limited_groups);
-int memcg_limited_groups_array_size;
+#define MEMCG_KMEM_ID_MAX	MEM_CGROUP_ID_MAX
 
 /*
- * MIN_SIZE is different than 1, because we would like to avoid going through
- * the alloc/free process all the time. In a small machine, 4 kmem-limited
- * cgroups is a reasonable guess. In the future, it could be a parameter or
- * tunable, but that is strictly not necessary.
+ * We keep the maximal number of kmem ids that may exist in the system in the
+ * memcg_nr_kmem_ids_max variable. We use it for the size of the arrays indexed
+ * by kmem id (see the mem_cgroup->kmem_id definition).
+ *
+ * If a newly allocated kmem id is greater or equal to memcg_nr_kmem_ids_max,
+ * we double it and reallocate the arrays so that they have enough space to
+ * store data for the new cgroup.
  *
- * MAX_SIZE should be as large as the number of cgrp_ids. Ideally, we could get
- * this constant directly from cgroup, but it is understandable that this is
- * better kept as an internal representation in cgroup.c. In any case, the
- * cgrp_id space is not getting any smaller, and we don't have to necessarily
- * increase ours as well if it increases.
+ * The updates are done with activate_kmem_mutex held, so one must take it to
+ * guarantee a stable value of memcg_nr_kmem_ids_max.
  */
-#define MEMCG_CACHES_MIN_SIZE 4
-#define MEMCG_CACHES_MAX_SIZE MEM_CGROUP_ID_MAX
+int memcg_nr_kmem_ids_max;
 
 /*
  * A lot of the calls to the cache allocation functions are expected to be
@@ -653,7 +657,7 @@ static void disarm_kmem_keys(struct mem_cgroup *memcg)
 {
 	if (memcg_kmem_is_active(memcg)) {
 		static_key_slow_dec(&memcg_kmem_enabled_key);
-		ida_simple_remove(&kmem_limited_groups, memcg->kmemcg_id);
+		ida_simple_remove(&memcg_kmem_ida, memcg->kmem_id);
 	}
 	/*
 	 * This check can't live in kmem destruction function,
@@ -2930,11 +2934,8 @@ static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
  */
 static struct kmem_cache *memcg_params_to_cache(struct memcg_cache_params *p)
 {
-	struct kmem_cache *cachep;
-
 	VM_BUG_ON(p->is_root_cache);
-	cachep = p->root_cache;
-	return cache_from_memcg_idx(cachep, memcg_cache_id(p->memcg));
+	return kmem_cache_of_memcg(p->root_cache, p->memcg);
 }
 
 #ifdef CONFIG_SLABINFO
@@ -3017,29 +3018,24 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
 		css_put(&memcg->css);
 }
 
-/*
- * helper for acessing a memcg's index. It will be used as an index in the
- * child cache array in kmem_cache, and also to derive its name. This function
- * will return -1 when this is not a kmem-limited memcg.
- */
-int memcg_cache_id(struct mem_cgroup *memcg)
+int memcg_kmem_id(struct mem_cgroup *memcg)
 {
-	return memcg ? memcg->kmemcg_id : -1;
+	return memcg ? memcg->kmem_id : -1;
 }
 
-static int memcg_init_cache_id(struct mem_cgroup *memcg)
+static int memcg_init_kmem_id(struct mem_cgroup *memcg)
 {
 	int err = 0;
 	int id, size;
 
 	lockdep_assert_held(&activate_kmem_mutex);
 
-	id = ida_simple_get(&kmem_limited_groups,
-			    0, MEMCG_CACHES_MAX_SIZE, GFP_KERNEL);
+	id = ida_simple_get(&memcg_kmem_ida,
+			    0, MEMCG_KMEM_ID_MAX + 1, GFP_KERNEL);
 	if (id < 0)
 		return id;
 
-	if (id < memcg_limited_groups_array_size)
+	if (id < memcg_nr_kmem_ids_max)
 		goto out_setid;
 
 	/*
@@ -3047,10 +3043,10 @@ static int memcg_init_cache_id(struct mem_cgroup *memcg)
 	 * per memcg data. Let's try to grow them then.
 	 */
 	size = id * 2;
-	if (size < MEMCG_CACHES_MIN_SIZE)
-		size = MEMCG_CACHES_MIN_SIZE;
-	else if (size > MEMCG_CACHES_MAX_SIZE)
-		size = MEMCG_CACHES_MAX_SIZE;
+	if (size < 4)
+		size = 4; /* a good number to start with */
+	if (size > MEMCG_KMEM_ID_MAX + 1)
+		size = MEMCG_KMEM_ID_MAX + 1;
 
 	mutex_lock(&memcg_slab_mutex);
 	err = kmem_cache_memcg_arrays_grow(size);
@@ -3064,14 +3060,14 @@ static int memcg_init_cache_id(struct mem_cgroup *memcg)
 	 * walking over such an array won't get an index out of range provided
 	 * they use an appropriate mutex to protect the array's elements.
 	 */
-	memcg_limited_groups_array_size = size;
+	memcg_nr_kmem_ids_max = size;
 
 out_setid:
-	memcg->kmemcg_id = id;
+	memcg->kmem_id = id;
 	return 0;
 
 out_rmid:
-	ida_simple_remove(&kmem_limited_groups, id);
+	ida_simple_remove(&memcg_kmem_ida, id);
 	return err;
 }
 
@@ -3089,11 +3085,10 @@ static int memcg_prepare_kmem_cache(struct kmem_cache *cachep)
 		return 0;
 
 	/* activate_kmem_mutex guarantees a stable value of
-	 * memcg_limited_groups_array_size */
+	 * memcg_nr_kmem_ids_max */
 	mutex_lock(&activate_kmem_mutex);
 	mutex_lock(&memcg_slab_mutex);
-	ret = kmem_cache_init_memcg_array(cachep,
-			memcg_limited_groups_array_size);
+	ret = kmem_cache_init_memcg_array(cachep, memcg_nr_kmem_ids_max);
 	mutex_unlock(&memcg_slab_mutex);
 	mutex_unlock(&activate_kmem_mutex);
 	return ret;
@@ -3112,14 +3107,14 @@ static void memcg_copy_kmem_cache(struct mem_cgroup *memcg,
 
 	lockdep_assert_held(&memcg_slab_mutex);
 
-	id = memcg_cache_id(memcg);
+	id = memcg_kmem_id(memcg);
 
 	/*
 	 * Since per-memcg caches are created asynchronously on first
 	 * allocation (see memcg_kmem_get_cache()), several threads can try to
 	 * create the same cache, but only one of them may succeed.
 	 */
-	if (cache_from_memcg_idx(root_cache, id))
+	if (kmem_cache_of_memcg_by_id(root_cache, id))
 		return;
 
 	cgroup_name(memcg->css.cgroup, memcg_name, NAME_MAX + 1);
@@ -3136,8 +3131,8 @@ static void memcg_copy_kmem_cache(struct mem_cgroup *memcg,
 	list_add(&cachep->memcg_params->list, &memcg->memcg_slab_caches);
 
 	/*
-	 * Since readers won't lock (see cache_from_memcg_idx()), we need a
-	 * barrier here to ensure nobody will see the kmem_cache partially
+	 * Since readers won't lock (see kmem_cache_of_memcg_by_id()), we need
+	 * a barrier here to ensure nobody will see the kmem_cache partially
 	 * initialized.
 	 */
 	smp_wmb();
@@ -3159,7 +3154,7 @@ static int memcg_destroy_kmem_cache_copy(struct kmem_cache *cachep)
 
 	root_cache = cachep->memcg_params->root_cache;
 	memcg = cachep->memcg_params->memcg;
-	id = memcg_cache_id(memcg);
+	id = memcg_kmem_id(memcg);
 
 	/*
 	 * Since memcg_caches arrays can be accessed using only slab_mutex for
@@ -3226,8 +3221,8 @@ int __kmem_cache_destroy_memcg_copies(struct kmem_cache *cachep)
 	BUG_ON(!is_root_cache(cachep));
 
 	mutex_lock(&memcg_slab_mutex);
-	for_each_memcg_cache_index(i) {
-		c = cache_from_memcg_idx(cachep, i);
+	for_each_possible_memcg_kmem_id(i) {
+		c = kmem_cache_of_memcg_by_id(cachep, i);
 		if (!c)
 			continue;
 
@@ -3371,7 +3366,7 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
 	if (!memcg_can_account_kmem(memcg))
 		goto out;
 
-	memcg_cachep = cache_from_memcg_idx(cachep, memcg_cache_id(memcg));
+	memcg_cachep = kmem_cache_of_memcg(cachep, memcg);
 	if (likely(memcg_cachep)) {
 		cachep = memcg_cachep;
 		goto out;
@@ -4945,7 +4940,7 @@ static int __memcg_activate_kmem(struct mem_cgroup *memcg,
 	if (err)
 		goto out;
 
-	err = memcg_init_cache_id(memcg);
+	err = memcg_init_kmem_id(memcg);
 	if (err)
 		goto out;
 
@@ -5676,7 +5671,7 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
 	int ret;
 
-	memcg->kmemcg_id = -1;
+	memcg->kmem_id = -1;
 	ret = memcg_propagate_kmem(memcg);
 	if (ret)
 		return ret;
diff --git a/mm/slab.c b/mm/slab.c
index 25317fd1daa2..194322a634e2 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3844,8 +3844,8 @@ static int do_tune_cpucache(struct kmem_cache *cachep, int limit,
 		return ret;
 
 	VM_BUG_ON(!mutex_is_locked(&slab_mutex));
-	for_each_memcg_cache_index(i) {
-		c = cache_from_memcg_idx(cachep, i);
+	for_each_possible_memcg_kmem_id(i) {
+		c = kmem_cache_of_memcg_by_id(cachep, i);
 		if (c)
 			/* return value determined by the parent cache only */
 			__do_tune_cpucache(c, limit, batchcount, shared, gfp);
diff --git a/mm/slab.h b/mm/slab.h
index ba834860fbfd..61f833c569e7 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -145,11 +145,11 @@ static inline const char *cache_name(struct kmem_cache *s)
  * created a memcg's cache is destroyed only along with the root cache, it is
  * true if we are going to allocate from the cache or hold a reference to the
  * root cache by other means. Otherwise, we should hold either the slab_mutex
- * or the memcg's slab_caches_mutex while calling this function and accessing
- * the returned value.
+ * or the memcg_slab_mutex while calling this function and accessing the
+ * returned value.
  */
 static inline struct kmem_cache *
-cache_from_memcg_idx(struct kmem_cache *s, int idx)
+kmem_cache_of_memcg_by_id(struct kmem_cache *s, int id)
 {
 	struct kmem_cache *cachep;
 	struct memcg_cache_params *params;
@@ -159,18 +159,24 @@ cache_from_memcg_idx(struct kmem_cache *s, int idx)
 
 	rcu_read_lock();
 	params = rcu_dereference(s->memcg_params);
-	cachep = params->memcg_caches[idx];
+	cachep = params->memcg_caches[id];
 	rcu_read_unlock();
 
 	/*
 	 * Make sure we will access the up-to-date value. The code updating
 	 * memcg_caches issues a write barrier to match this (see
-	 * memcg_register_cache()).
+	 * memcg_copy_kmem_cache()).
 	 */
 	smp_read_barrier_depends();
 	return cachep;
 }
 
+static inline struct kmem_cache *
+kmem_cache_of_memcg(struct kmem_cache *s, struct mem_cgroup *memcg)
+{
+	return kmem_cache_of_memcg_by_id(s, memcg_kmem_id(memcg));
+}
+
 static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 {
 	if (is_root_cache(s))
@@ -214,7 +220,13 @@ static inline const char *cache_name(struct kmem_cache *s)
 }
 
 static inline struct kmem_cache *
-cache_from_memcg_idx(struct kmem_cache *s, int idx)
+kmem_cache_of_memcg_by_id(struct kmem_cache *s, int id)
+{
+	return NULL;
+}
+
+static inline struct kmem_cache *
+kmem_cache_of_memcg(struct kmem_cache *s, struct mem_cgroup *memcg)
 {
 	return NULL;
 }
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 36c7d32a6f97..876b40bfe360 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -98,11 +98,11 @@ static int __kmem_cache_init_memcg_array(struct kmem_cache *s, int nr_entries)
 
 	new->is_root_cache = true;
 	if (old) {
-		for_each_memcg_cache_index(i)
+		for_each_possible_memcg_kmem_id(i)
 			new->memcg_caches[i] = old->memcg_caches[i];
 	}
 
-	/* matching rcu_dereference is in cache_from_memcg_idx */
+	/* matching rcu_dereference is in kmem_cache_of_memcg_by_id */
 	rcu_assign_pointer(s->memcg_params, new);
 	if (old)
 		kfree_rcu(old, rcu_head);
@@ -332,7 +332,7 @@ struct kmem_cache *kmem_cache_request_memcg_copy(struct kmem_cache *cachep,
 	memcg_params->root_cache = cachep;
 
 	cache_name = kasprintf(GFP_KERNEL, "%s(%d:%s)", cachep->name,
-			       memcg_cache_id(memcg), memcg_name);
+			       memcg_kmem_id(memcg), memcg_name);
 	if (!cache_name)
 		goto out_unlock;
 
@@ -755,8 +755,8 @@ memcg_accumulate_slabinfo(struct kmem_cache *s, struct slabinfo *info)
 	if (!is_root_cache(s))
 		return;
 
-	for_each_memcg_cache_index(i) {
-		c = cache_from_memcg_idx(s, i);
+	for_each_possible_memcg_kmem_id(i) {
+		c = kmem_cache_of_memcg_by_id(s, i);
 		if (!c)
 			continue;
 
diff --git a/mm/slub.c b/mm/slub.c
index aa30932c5190..006e6bfe257c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3772,8 +3772,8 @@ __kmem_cache_alias(const char *name, size_t size, size_t align,
 		s->object_size = max(s->object_size, (int)size);
 		s->inuse = max_t(int, s->inuse, ALIGN(size, sizeof(void *)));
 
-		for_each_memcg_cache_index(i) {
-			c = cache_from_memcg_idx(s, i);
+		for_each_possible_memcg_kmem_id(i) {
+			c = kmem_cache_of_memcg_by_id(s, i);
 			if (!c)
 				continue;
 			c->object_size = s->object_size;
@@ -5062,8 +5062,8 @@ static ssize_t slab_attr_store(struct kobject *kobj,
 		 * directly either failed or succeeded, in which case we loop
 		 * through the descendants with best-effort propagation.
 		 */
-		for_each_memcg_cache_index(i) {
-			struct kmem_cache *c = cache_from_memcg_idx(s, i);
+		for_each_possible_memcg_kmem_id(i) {
+			struct kmem_cache *c = kmem_cache_of_memcg_by_id(s, i);
 			if (c)
 				attribute->store(c, buf, len);
 		}
@@ -5198,7 +5198,7 @@ static char *create_unique_id(struct kmem_cache *s)
 #ifdef CONFIG_MEMCG_KMEM
 	if (!is_root_cache(s))
 		p += sprintf(p, "-%08d",
-				memcg_cache_id(s->memcg_params->memcg));
+			     memcg_kmem_id(s->memcg_params->memcg));
 #endif
 
 	BUG_ON(p > name + ID_STR_LENGTH - 1);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
