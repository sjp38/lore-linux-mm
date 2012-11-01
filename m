Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 8212B6B007D
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 08:09:10 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v6 18/29] Allocate memory for memcg caches whenever a new memcg appears
Date: Thu,  1 Nov 2012 16:07:34 +0400
Message-Id: <1351771665-11076-19-git-send-email-glommer@parallels.com>
In-Reply-To: <1351771665-11076-1-git-send-email-glommer@parallels.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

Every cache that is considered a root cache (basically the "original" caches,
tied to the root memcg/no-memcg) will have an array that should be large enough
to store a cache pointer per each memcg in the system.

Theoreticaly, this is as high as 1 << sizeof(css_id), which is currently in the
64k pointers range. Most of the time, we won't be using that much.

What goes in this patch, is a simple scheme to dynamically allocate such an
array, in order to minimize memory usage for memcg caches. Because we would
also like to avoid allocations all the time, at least for now, the array will
only grow. It will tend to be big enough to hold the maximum number of
kmem-limited memcgs ever achieved.

We'll allocate it to be a minimum of 64 kmem-limited memcgs. When we have more
than that, we'll start doubling the size of this array every time the limit is
reached.

Because we are only considering kmem limited memcgs, a natural point for this
to happen is when we write to the limit. At that point, we already have
set_limit_mutex held, so that will become our natural synchronization
mechanism.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Suleiman Souhlal <suleiman@google.com>
CC: Tejun Heo <tj@kernel.org>
---
 include/linux/memcontrol.h |   2 +
 mm/memcontrol.c            | 210 +++++++++++++++++++++++++++++++++++++++++----
 mm/slab_common.c           |  28 ++++++
 3 files changed, 224 insertions(+), 16 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ea1e66f..49f5e4f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -440,6 +440,8 @@ int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s);
 void memcg_release_cache(struct kmem_cache *cachep);
 void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep);
 
+int memcg_update_cache_size(struct kmem_cache *s, int num_groups);
+void memcg_update_array_size(int num_groups);
 /**
  * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
  * @gfp: the gfp allocation flags.
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fb5b1e6..eb873af 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -376,6 +376,11 @@ static void memcg_kmem_set_activated(struct mem_cgroup *memcg)
 	set_bit(KMEM_ACCOUNTED_ACTIVATED, &memcg->kmem_account_flags);
 }
 
+static void memcg_kmem_clear_activated(struct mem_cgroup *memcg)
+{
+	clear_bit(KMEM_ACCOUNTED_ACTIVATED, &memcg->kmem_account_flags);
+}
+
 static void memcg_kmem_mark_dead(struct mem_cgroup *memcg)
 {
 	if (test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags))
@@ -547,12 +552,48 @@ static void disarm_sock_keys(struct mem_cgroup *memcg)
 #endif
 
 #ifdef CONFIG_MEMCG_KMEM
+/*
+ * This will be the memcg's index in each cache's ->memcg_params->memcg_caches.
+ * There are two main reasons for not using the css_id for this:
+ *  1) this works better in sparse environments, where we have a lot of memcgs,
+ *     but only a few kmem-limited. Or also, if we have, for instance, 200
+ *     memcgs, and none but the 200th is kmem-limited, we'd have to have a
+ *     200 entry array for that.
+ *
+ *  2) In order not to violate the cgroup API, we would like to do all memory
+ *     allocation in ->create(). At that point, we haven't yet allocated the
+ *     css_id. Having a separate index prevents us from messing with the cgroup
+ *     core for this
+ *
+ * The current size of the caches array is stored in
+ * memcg_limited_groups_array_size.  It will double each time we have to
+ * increase it.
+ */
+static struct ida kmem_limited_groups;
+static int memcg_limited_groups_array_size;
+/*
+ * MIN_SIZE is different than 1, because we would like to avoid going through
+ * the alloc/free process all the time. In a small machine, 4 kmem-limited
+ * cgroups is a reasonable guess. In the future, it could be a parameter or
+ * tunable, but that is strictly not necessary.
+ *
+ * MAX_SIZE should be as large as the number of css_ids. Ideally, we could get
+ * this constant directly from cgroup, but it is understandable that this is
+ * better kept as an internal representation in cgroup.c. In any case, the
+ * css_id space is not getting any smaller, and we don't have to necessarily
+ * increase ours as well if it increases.
+ */
+#define MEMCG_CACHES_MIN_SIZE 4
+#define MEMCG_CACHES_MAX_SIZE 65535
+
 struct static_key memcg_kmem_enabled_key;
 
 static void disarm_kmem_keys(struct mem_cgroup *memcg)
 {
-	if (memcg_kmem_is_active(memcg))
+	if (memcg_kmem_is_active(memcg)) {
 		static_key_slow_dec(&memcg_kmem_enabled_key);
+		ida_simple_remove(&kmem_limited_groups, memcg->kmemcg_id);
+	}
 	/*
 	 * This check can't live in kmem destruction function,
 	 * since the charges will outlive the cgroup
@@ -2782,6 +2823,120 @@ int memcg_cache_id(struct mem_cgroup *memcg)
 	return memcg ? memcg->kmemcg_id : -1;
 }
 
+/*
+ * This ends up being protected by the set_limit mutex, during normal
+ * operation, because that is its main call site.
+ *
+ * But when we create a new cache, we can call this as well if its parent
+ * is kmem-limited. That will have to hold set_limit_mutex as well.
+ */
+int memcg_update_cache_sizes(struct mem_cgroup *memcg)
+{
+	int num, ret;
+
+	num = ida_simple_get(&kmem_limited_groups,
+				0, MEMCG_CACHES_MAX_SIZE, GFP_KERNEL);
+	if (num < 0)
+		return num;
+	/*
+	 * After this point, kmem_accounted (that we test atomically in
+	 * the beginning of this conditional), is no longer 0. This
+	 * guarantees only one process will set the following boolean
+	 * to true. We don't need test_and_set because we're protected
+	 * by the set_limit_mutex anyway.
+	 */
+	memcg_kmem_set_activated(memcg);
+
+	ret = memcg_update_all_caches(num+1);
+	if (ret) {
+		ida_simple_remove(&kmem_limited_groups, num);
+		memcg_kmem_clear_activated(memcg);
+		return ret;
+	}
+
+	memcg->kmemcg_id = num;
+	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
+	mutex_init(&memcg->slab_caches_mutex);
+	return 0;
+}
+
+static size_t memcg_caches_array_size(int num_groups)
+{
+	ssize_t size;
+	if (num_groups <= 0)
+		return 0;
+
+	size = 2 * num_groups;
+	if (size < MEMCG_CACHES_MIN_SIZE)
+		size = MEMCG_CACHES_MIN_SIZE;
+	else if (size > MEMCG_CACHES_MAX_SIZE)
+		size = MEMCG_CACHES_MAX_SIZE;
+
+	return size;
+}
+
+/*
+ * We should update the current array size iff all caches updates succeed. This
+ * can only be done from the slab side. The slab mutex needs to be held when
+ * calling this.
+ */
+void memcg_update_array_size(int num)
+{
+	if (num > memcg_limited_groups_array_size)
+		memcg_limited_groups_array_size = memcg_caches_array_size(num);
+}
+
+int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
+{
+	struct memcg_cache_params *cur_params = s->memcg_params;
+
+	VM_BUG_ON(s->memcg_params && !s->memcg_params->is_root_cache);
+
+	if (num_groups > memcg_limited_groups_array_size) {
+		int i;
+		ssize_t size = memcg_caches_array_size(num_groups);
+
+		size *= sizeof(void *);
+		size += sizeof(struct memcg_cache_params);
+
+		s->memcg_params = kzalloc(size, GFP_KERNEL);
+		if (!s->memcg_params) {
+			s->memcg_params = cur_params;
+			return -ENOMEM;
+		}
+
+		s->memcg_params->is_root_cache = true;
+
+		/*
+		 * There is the chance it will be bigger than
+		 * memcg_limited_groups_array_size, if we failed an allocation
+		 * in a cache, in which case all caches updated before it, will
+		 * have a bigger array.
+		 *
+		 * But if that is the case, the data after
+		 * memcg_limited_groups_array_size is certainly unused
+		 */
+		for (i = 0; i < memcg_limited_groups_array_size; i++) {
+			if (!cur_params->memcg_caches[i])
+				continue;
+			s->memcg_params->memcg_caches[i] =
+						cur_params->memcg_caches[i];
+		}
+
+		/*
+		 * Ideally, we would wait until all caches succeed, and only
+		 * then free the old one. But this is not worth the extra
+		 * pointer per-cache we'd have to have for this.
+		 *
+		 * It is not a big deal if some caches are left with a size
+		 * bigger than the others. And all updates will reset this
+		 * anyway.
+		 */
+		kfree(cur_params);
+	}
+	return 0;
+}
+
 int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s)
 {
 	size_t size = sizeof(struct memcg_cache_params);
@@ -2789,6 +2944,9 @@ int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s)
 	if (!memcg_kmem_enabled())
 		return 0;
 
+	if (!memcg)
+		size += memcg_limited_groups_array_size * sizeof(void *);
+
 	s->memcg_params = kzalloc(size, GFP_KERNEL);
 	if (!s->memcg_params)
 		return -ENOMEM;
@@ -4291,14 +4449,11 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
 		ret = res_counter_set_limit(&memcg->kmem, val);
 		VM_BUG_ON(ret);
 
-		/*
-		 * After this point, kmem_accounted (that we test atomically in
-		 * the beginning of this conditional), is no longer 0. This
-		 * guarantees only one process will set the following boolean
-		 * to true. We don't need test_and_set because we're protected
-		 * by the set_limit_mutex anyway.
-		 */
-		memcg_kmem_set_activated(memcg);
+		ret = memcg_update_cache_sizes(memcg);
+		if (ret) {
+			res_counter_set_limit(&memcg->kmem, RESOURCE_MAX);
+			goto out;
+		}
 		must_inc_static_branch = true;
 		/*
 		 * kmem charges can outlive the cgroup. In the case of slab
@@ -4337,11 +4492,13 @@ out:
 	return ret;
 }
 
-static void memcg_propagate_kmem(struct mem_cgroup *memcg)
+static int memcg_propagate_kmem(struct mem_cgroup *memcg)
 {
+	int ret = 0;
 	struct mem_cgroup *parent = parent_mem_cgroup(memcg);
 	if (!parent)
-		return;
+		goto out;
+
 	memcg->kmem_account_flags = parent->kmem_account_flags;
 #ifdef CONFIG_MEMCG_KMEM
 	/*
@@ -4354,11 +4511,24 @@ static void memcg_propagate_kmem(struct mem_cgroup *memcg)
 	 * It is a lot simpler just to do static_key_slow_inc() on every child
 	 * that is accounted.
 	 */
-	if (memcg_kmem_is_active(memcg)) {
-		mem_cgroup_get(memcg);
-		static_key_slow_inc(&memcg_kmem_enabled_key);
-	}
+	if (!memcg_kmem_is_active(memcg))
+		goto out;
+
+	/*
+	 * destroy(), called if we fail, will issue static_key_slow_inc() and
+	 * mem_cgroup_put() if kmem is enabled. We have to either call them
+	 * unconditionally, or clear the KMEM_ACTIVE flag. I personally find
+	 * this more consistent, since it always leads to the same destroy path
+	 */
+	mem_cgroup_get(memcg);
+	static_key_slow_inc(&memcg_kmem_enabled_key);
+
+	mutex_lock(&set_limit_mutex);
+	ret = memcg_update_cache_sizes(memcg);
+	mutex_unlock(&set_limit_mutex);
 #endif
+out:
+	return ret;
 }
 
 /*
@@ -5040,8 +5210,15 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
 #ifdef CONFIG_MEMCG_KMEM
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
+	int ret;
+
 	memcg->kmemcg_id = -1;
-	memcg_propagate_kmem(memcg);
+	ret = memcg_propagate_kmem(memcg);
+	if (ret)
+		return ret;
+
+	if (mem_cgroup_is_root(memcg))
+		ida_init(&kmem_limited_groups);
 
 	return mem_cgroup_sockets_init(memcg, ss);
 };
@@ -5444,6 +5621,7 @@ mem_cgroup_create(struct cgroup *cont)
 		res_counter_init(&memcg->res, &parent->res);
 		res_counter_init(&memcg->memsw, &parent->memsw);
 		res_counter_init(&memcg->kmem, &parent->kmem);
+
 		/*
 		 * We increment refcnt of the parent to ensure that we can
 		 * safely access it on res_counter_charge/uncharge.
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 0578731..b76a74c 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -81,6 +81,34 @@ static inline int kmem_cache_sanity_check(struct mem_cgroup *memcg,
 }
 #endif
 
+#ifdef CONFIG_MEMCG_KMEM
+int memcg_update_all_caches(int num_memcgs)
+{
+	struct kmem_cache *s;
+	int ret = 0;
+	mutex_lock(&slab_mutex);
+
+	list_for_each_entry(s, &slab_caches, list) {
+		if (!is_root_cache(s))
+			continue;
+
+		ret = memcg_update_cache_size(s, num_memcgs);
+		/*
+		 * See comment in memcontrol.c, memcg_update_cache_size:
+		 * Instead of freeing the memory, we'll just leave the caches
+		 * up to this point in an updated state.
+		 */
+		if (ret)
+			goto out;
+	}
+
+	memcg_update_array_size(num_memcgs);
+out:
+	mutex_unlock(&slab_mutex);
+	return ret;
+}
+#endif
+
 /*
  * kmem_cache_create - Create a cache.
  * @name: A string which is used in /proc/slabinfo to identify this cache.
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
