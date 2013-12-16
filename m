Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id B0B226B005A
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 07:17:27 -0500 (EST)
Received: by mail-lb0-f180.google.com with SMTP id x18so813399lbi.39
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 04:17:27 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id dw4si3525866lbc.110.2013.12.16.04.17.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 04:17:26 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v14 06/18] memcg: rework memcg_update_kmem_limit synchronization
Date: Mon, 16 Dec 2013 16:16:55 +0400
Message-ID: <f35d6d667b6380dbabdac539c89390401c8071e7.1387193771.git.vdavydov@parallels.com>
In-Reply-To: <cover.1387193771.git.vdavydov@parallels.com>
References: <cover.1387193771.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dchinner@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Currently we take both the memcg_create_mutex and the set_limit_mutex
when we enable kmem accounting for a memory cgroup, which makes kmem
activation events serialize with both memcg creations and other memcg
limit updates (memory.limit, memory.memsw.limit). However, there is no
point keeping both of these mutexes during the whole kmem initialization
process.

First, the set_limit_mutex was introduced to keep the memory.limit and
memory.memsw.limit values in sync. Since memory.kmem.limit can be set
independently of them, it is better to introduce a separate mutex to
synchronize against concurrent kmem limit updates.

Second, we take the memcg_create_mutex in order to make sure all
children of this memcg will be kmem-active as well. For achieving that,
it is enough to take this mutex only around the call to
memcg_has_children(). This guarantees that if a child is added after we
check that the memcg has no children, the newly added cgroup will see
its parent kmem-active (of course if the latter succeeded), and call
kmem activation for itself.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |  180 +++++++++++++++++++++++++++++--------------------------
 1 file changed, 94 insertions(+), 86 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9bf11bf..f2372b0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3063,32 +3063,6 @@ void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep)
 	mutex_unlock(&memcg->slab_caches_mutex);
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
-	return 0;
-}
-
 static size_t memcg_caches_array_size(int num_groups)
 {
 	ssize_t size;
@@ -5119,11 +5093,28 @@ static ssize_t mem_cgroup_read(struct cgroup_subsys_state *css,
 	return simple_read_from_buffer(buf, nbytes, ppos, str, len);
 }
 
-static int memcg_update_kmem_limit(struct cgroup_subsys_state *css, u64 val)
-{
-	int ret = -EINVAL;
 #ifdef CONFIG_MEMCG_KMEM
-	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+static DEFINE_MUTEX(activate_kmem_mutex);
+
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
+	err = res_counter_set_limit(&memcg->kmem, limit);
+	VM_BUG_ON(err);
+
 	/*
 	 * For simplicity, we won't allow this to be disabled.  It also can't
 	 * be changed if the cgroup has children already, or if tasks had
@@ -5137,72 +5128,91 @@ static int memcg_update_kmem_limit(struct cgroup_subsys_state *css, u64 val)
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
+		goto out_reset_limit;
+
+	memcg_id = ida_simple_get(&kmem_limited_groups,
+				  0, MEMCG_CACHES_MAX_SIZE, GFP_KERNEL);
+	if (memcg_id < 0) {
+		err = memcg_id;
+		goto out_reset_limit;
+	}
 
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
+	/*
+	 * Make sure we have enough space for this cgroup in each kmem_cache's
+	 * memcg_params array.
+	 */
+	err = memcg_update_all_caches(memcg_id + 1);
+	if (err)
+		goto out_rmid;
+
+	memcg->kmemcg_id = memcg_id;
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
+out_reset_limit:
+	res_counter_set_limit(&memcg->kmem, RES_COUNTER_MAX);
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
 	int ret = 0;
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
+	if (!parent)
 		goto out;
 
-	/*
-	 * __mem_cgroup_free() will issue static_key_slow_dec() because this
-	 * memcg is active already. If the later initialization fails then the
-	 * cgroup core triggers the cleanup so we do not have to do it here.
-	 */
-	static_key_slow_inc(&memcg_kmem_enabled_key);
-
-	mutex_lock(&set_limit_mutex);
-	memcg_stop_kmem_account();
-	ret = memcg_update_cache_sizes(memcg);
-	memcg_resume_kmem_account();
-	mutex_unlock(&set_limit_mutex);
+	mutex_lock(&activate_kmem_mutex);
+	if (memcg_kmem_is_active(parent))
+		ret = __memcg_activate_kmem(memcg, RES_COUNTER_MAX);
+	mutex_unlock(&activate_kmem_mutex);
 out:
 	return ret;
 }
+#else
+static inline int memcg_update_kmem_limit(struct mem_cgroup *memcg,
+					  unsigned long long val)
+{
+	return -EINVAL;
+}
 #endif /* CONFIG_MEMCG_KMEM */
 
 /*
@@ -5236,7 +5246,7 @@ static int mem_cgroup_write(struct cgroup_subsys_state *css, struct cftype *cft,
 		else if (type == _MEMSWAP)
 			ret = mem_cgroup_resize_memsw_limit(memcg, val);
 		else if (type == _KMEM)
-			ret = memcg_update_kmem_limit(css, val);
+			ret = memcg_update_kmem_limit(memcg, val);
 		else
 			return -EINVAL;
 		break;
@@ -6253,7 +6263,6 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup *parent = mem_cgroup_from_css(css_parent(css));
-	int error = 0;
 
 	if (css->cgroup->id > MEM_CGROUP_ID_MAX)
 		return -ENOSPC;
@@ -6288,10 +6297,9 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
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
