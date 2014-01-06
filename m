Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 166BE6B0039
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 03:45:32 -0500 (EST)
Received: by mail-lb0-f171.google.com with SMTP id w7so9840719lbi.30
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 00:45:32 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id fa7si35735763lbc.175.2014.01.06.00.45.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 00:45:31 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RESEND 11/11] memcg: rework memcg_update_kmem_limit synchronization
Date: Mon, 6 Jan 2014 12:45:02 +0400
Message-ID: <408496c3827385d49a4d963a9f5cfb067da1f2e0.1388996525.git.vdavydov@parallels.com>
In-Reply-To: <cover.1388996525.git.vdavydov@parallels.com>
References: <cover.1388996525.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, akpm@linux-foundation.org
Cc: glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Currently we take both the memcg_create_mutex and the set_limit_mutex
when we enable kmem accounting for a memory cgroup, which makes kmem
activation events serialize with both memcg creations and other memcg
limit updates (memory.limit, memory.memsw.limit). However, there is no
point in such strict synchronization rules there.

First, the set_limit_mutex was introduced to keep the memory.limit and
memory.memsw.limit values in sync. Since memory.kmem.limit can be set
independently of them, it is better to introduce a separate mutex to
synchronize against concurrent kmem limit updates.

Second, we take the memcg_create_mutex in order to make sure all
children of this memcg will be kmem-active as well. For achieving that,
it is enough to hold this mutex only while checking if
memcg_has_children() though. This guarantees that if a child is added
after we checked that the memcg has no children, the newly added cgroup
will see its parent kmem-active (of course if the latter succeeded), and
call kmem activation for itself.

This patch simplifies the locking rules of memcg_update_kmem_limit()
according to these considerations.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/memcontrol.c |  198 +++++++++++++++++++++++++++++--------------------------
 1 file changed, 106 insertions(+), 92 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a5a1ae1..696707c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2941,6 +2941,8 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 static DEFINE_MUTEX(set_limit_mutex);
 
 #ifdef CONFIG_MEMCG_KMEM
+static DEFINE_MUTEX(activate_kmem_mutex);
+
 static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
 {
 	return !mem_cgroup_disabled() && !mem_cgroup_is_root(memcg) &&
@@ -3054,34 +3056,6 @@ int memcg_cache_id(struct mem_cgroup *memcg)
 	return memcg ? memcg->kmemcg_id : -1;
 }
 
-/*
- * This ends up being protected by the set_limit mutex, during normal
- * operation, because that is its main call site.
- *
- * But when we create a new cache, we can call this as well if its parent
- * is kmem-limited. That will have to hold set_limit_mutex as well.
- */
-int memcg_update_cache_sizes(struct mem_cgroup *memcg)
-{
-	int num, ret;
-
-	num = ida_simple_get(&kmem_limited_groups,
-				0, MEMCG_CACHES_MAX_SIZE, GFP_KERNEL);
-	if (num < 0)
-		return num;
-
-	ret = memcg_update_all_caches(num+1);
-	if (ret) {
-		ida_simple_remove(&kmem_limited_groups, num);
-		return ret;
-	}
-
-	memcg->kmemcg_id = num;
-	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
-	mutex_init(&memcg->slab_caches_mutex);
-	return 0;
-}
-
 static size_t memcg_caches_array_size(int num_groups)
 {
 	ssize_t size;
@@ -3424,9 +3398,10 @@ void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 	 *
 	 * Still, we don't want anyone else freeing memcg_caches under our
 	 * noses, which can happen if a new memcg comes to life. As usual,
-	 * we'll take the set_limit_mutex to protect ourselves against this.
+	 * we'll take the activate_kmem_mutex to protect ourselves against
+	 * this.
 	 */
-	mutex_lock(&set_limit_mutex);
+	mutex_lock(&activate_kmem_mutex);
 	for_each_memcg_cache_index(i) {
 		c = cache_from_memcg_idx(s, i);
 		if (!c)
@@ -3449,7 +3424,7 @@ void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 		cancel_work_sync(&c->memcg_params->destroy);
 		kmem_cache_destroy(c);
 	}
-	mutex_unlock(&set_limit_mutex);
+	mutex_unlock(&activate_kmem_mutex);
 }
 
 struct create_work {
@@ -5116,11 +5091,23 @@ static ssize_t mem_cgroup_read(struct cgroup_subsys_state *css,
 	return simple_read_from_buffer(buf, nbytes, ppos, str, len);
 }
 
-static int memcg_update_kmem_limit(struct cgroup_subsys_state *css, u64 val)
-{
-	int ret = -EINVAL;
 #ifdef CONFIG_MEMCG_KMEM
-	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+/* should be called with activate_kmem_mutex held */
+static int __memcg_activate_kmem(struct mem_cgroup *memcg,
+				 unsigned long long limit)
+{
+	int err = 0;
+	int memcg_id;
+
+	if (memcg_kmem_is_active(memcg))
+		return 0;
+
+	/*
+	 * We are going to allocate memory for data shared by all memory
+	 * cgroups so let's stop accounting here.
+	 */
+	memcg_stop_kmem_account();
+
 	/*
 	 * For simplicity, we won't allow this to be disabled.  It also can't
 	 * be changed if the cgroup has children already, or if tasks had
@@ -5134,72 +5121,101 @@ static int memcg_update_kmem_limit(struct cgroup_subsys_state *css, u64 val)
 	 * of course permitted.
 	 */
 	mutex_lock(&memcg_create_mutex);
-	mutex_lock(&set_limit_mutex);
-	if (!memcg->kmem_account_flags && val != RES_COUNTER_MAX) {
-		if (cgroup_task_count(css->cgroup) || memcg_has_children(memcg)) {
-			ret = -EBUSY;
-			goto out;
-		}
-		ret = res_counter_set_limit(&memcg->kmem, val);
-		VM_BUG_ON(ret);
+	if (cgroup_task_count(memcg->css.cgroup) || memcg_has_children(memcg))
+		err = -EBUSY;
+	mutex_unlock(&memcg_create_mutex);
+	if (err)
+		goto out;
 
-		ret = memcg_update_cache_sizes(memcg);
-		if (ret) {
-			res_counter_set_limit(&memcg->kmem, RES_COUNTER_MAX);
-			goto out;
-		}
-		static_key_slow_inc(&memcg_kmem_enabled_key);
-		/*
-		 * setting the active bit after the inc will guarantee no one
-		 * starts accounting before all call sites are patched
-		 */
-		memcg_kmem_set_active(memcg);
-	} else
-		ret = res_counter_set_limit(&memcg->kmem, val);
+	memcg_id = ida_simple_get(&kmem_limited_groups,
+				  0, MEMCG_CACHES_MAX_SIZE, GFP_KERNEL);
+	if (memcg_id < 0) {
+		err = memcg_id;
+		goto out;
+	}
+
+	/*
+	 * Make sure we have enough space for this cgroup in each root cache's
+	 * memcg_params.
+	 */
+	err = memcg_update_all_caches(memcg_id + 1);
+	if (err)
+		goto out_rmid;
+
+	memcg->kmemcg_id = memcg_id;
+	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
+	mutex_init(&memcg->slab_caches_mutex);
+
+	/*
+	 * We couldn't have accounted to this cgroup, because it hasn't got the
+	 * active bit set yet, so this should succeed.
+	 */
+	err = res_counter_set_limit(&memcg->kmem, limit);
+	VM_BUG_ON(err);
+
+	static_key_slow_inc(&memcg_kmem_enabled_key);
+	/*
+	 * Setting the active bit after enabling static branching will
+	 * guarantee no one starts accounting before all call sites are
+	 * patched.
+	 */
+	memcg_kmem_set_active(memcg);
 out:
-	mutex_unlock(&set_limit_mutex);
-	mutex_unlock(&memcg_create_mutex);
-#endif
+	memcg_resume_kmem_account();
+	return err;
+
+out_rmid:
+	ida_simple_remove(&kmem_limited_groups, memcg_id);
+	goto out;
+}
+
+static int memcg_activate_kmem(struct mem_cgroup *memcg,
+			       unsigned long long limit)
+{
+	int ret;
+
+	mutex_lock(&activate_kmem_mutex);
+	ret = __memcg_activate_kmem(memcg, limit);
+	mutex_unlock(&activate_kmem_mutex);
+	return ret;
+}
+
+static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
+				   unsigned long long val)
+{
+	int ret;
+
+	if (!memcg_kmem_is_active(memcg))
+		ret = memcg_activate_kmem(memcg, val);
+	else
+		ret = res_counter_set_limit(&memcg->kmem, val);
 	return ret;
 }
 
-#ifdef CONFIG_MEMCG_KMEM
 static int memcg_propagate_kmem(struct mem_cgroup *memcg)
 {
-	int ret = 0;
+	int ret;
 	struct mem_cgroup *parent = parent_mem_cgroup(memcg);
-	if (!parent)
-		goto out;
 
-	memcg->kmem_account_flags = parent->kmem_account_flags;
-	/*
-	 * When that happen, we need to disable the static branch only on those
-	 * memcgs that enabled it. To achieve this, we would be forced to
-	 * complicate the code by keeping track of which memcgs were the ones
-	 * that actually enabled limits, and which ones got it from its
-	 * parents.
-	 *
-	 * It is a lot simpler just to do static_key_slow_inc() on every child
-	 * that is accounted.
-	 */
-	if (!memcg_kmem_is_active(memcg))
-		goto out;
+	if (!parent)
+		return 0;
 
+	mutex_lock(&activate_kmem_mutex);
 	/*
-	 * __mem_cgroup_free() will issue static_key_slow_dec() because this
-	 * memcg is active already. If the later initialization fails then the
-	 * cgroup core triggers the cleanup so we do not have to do it here.
+	 * If the parent cgroup is not kmem-active now, it cannot be activated
+	 * after this point, because it has at least one child already.
 	 */
-	static_key_slow_inc(&memcg_kmem_enabled_key);
-
-	mutex_lock(&set_limit_mutex);
-	memcg_stop_kmem_account();
-	ret = memcg_update_cache_sizes(memcg);
-	memcg_resume_kmem_account();
-	mutex_unlock(&set_limit_mutex);
-out:
+	if (memcg_kmem_is_active(parent))
+		ret = __memcg_activate_kmem(memcg, RES_COUNTER_MAX);
+	mutex_unlock(&activate_kmem_mutex);
 	return ret;
 }
+#else
+static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
+				   unsigned long long val)
+{
+	return -EINVAL;
+}
 #endif /* CONFIG_MEMCG_KMEM */
 
 /*
@@ -5233,7 +5249,7 @@ static int mem_cgroup_write(struct cgroup_subsys_state *css, struct cftype *cft,
 		else if (type == _MEMSWAP)
 			ret = mem_cgroup_resize_memsw_limit(memcg, val);
 		else if (type == _KMEM)
-			ret = memcg_update_kmem_limit(css, val);
+			ret = memcg_update_kmem_limit(memcg, val);
 		else
 			return -EINVAL;
 		break;
@@ -6248,7 +6264,6 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup *parent = mem_cgroup_from_css(css_parent(css));
-	int error = 0;
 
 	if (css->cgroup->id > MEM_CGROUP_ID_MAX)
 		return -ENOSPC;
@@ -6283,10 +6298,9 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 		if (parent != root_mem_cgroup)
 			mem_cgroup_subsys.broken_hierarchy = true;
 	}
-
-	error = memcg_init_kmem(memcg, &mem_cgroup_subsys);
 	mutex_unlock(&memcg_create_mutex);
-	return error;
+
+	return memcg_init_kmem(memcg, &mem_cgroup_subsys);
 }
 
 /*
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
