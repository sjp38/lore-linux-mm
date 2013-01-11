Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 8A1776B0074
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 04:45:50 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 6/7] memcg: replace cgroup_lock with memcg specific memcg_lock
Date: Fri, 11 Jan 2013 13:45:26 +0400
Message-Id: <1357897527-15479-7-git-send-email-glommer@parallels.com>
In-Reply-To: <1357897527-15479-1-git-send-email-glommer@parallels.com>
References: <1357897527-15479-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>

After the preparation work done in earlier patches, the
cgroup_lock can be trivially replaced with a memcg-specific lock. This
is an automatic translation in every site the values involved were
queried.

The sites were values are written, however, used to be naturally called
under cgroup_lock. This is the case for instance of the css_online
callback. For those, we now need to explicitly add the memcg_lock.

With this, all the calls to cgroup_lock outside cgroup core are gone.

Signed-off-by: Glauber Costa <glommer@parallels.com>
---
 mm/memcontrol.c | 43 ++++++++++++++++++++++---------------------
 1 file changed, 22 insertions(+), 21 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c024614..5f3adbc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -472,6 +472,8 @@ enum res_type {
 #define MEM_CGROUP_RECLAIM_SHRINK_BIT	0x1
 #define MEM_CGROUP_RECLAIM_SHRINK	(1 << MEM_CGROUP_RECLAIM_SHRINK_BIT)
 
+static DEFINE_MUTEX(memcg_mutex);
+
 static void mem_cgroup_get(struct mem_cgroup *memcg);
 static void mem_cgroup_put(struct mem_cgroup *memcg);
 
@@ -2909,7 +2911,7 @@ int memcg_cache_id(struct mem_cgroup *memcg)
  * operation, because that is its main call site.
  *
  * But when we create a new cache, we can call this as well if its parent
- * is kmem-limited. That will have to hold cgroup_lock as well.
+ * is kmem-limited. That will have to hold memcg_mutex as well.
  */
 int memcg_update_cache_sizes(struct mem_cgroup *memcg)
 {
@@ -2924,7 +2926,7 @@ int memcg_update_cache_sizes(struct mem_cgroup *memcg)
 	 * the beginning of this conditional), is no longer 0. This
 	 * guarantees only one process will set the following boolean
 	 * to true. We don't need test_and_set because we're protected
-	 * by the cgroup_lock anyway.
+	 * by the memcg_mutex anyway.
 	 */
 	memcg_kmem_set_activated(memcg);
 
@@ -3265,9 +3267,9 @@ void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 	 *
 	 * Still, we don't want anyone else freeing memcg_caches under our
 	 * noses, which can happen if a new memcg comes to life. As usual,
-	 * we'll take the cgroup_lock to protect ourselves against this.
+	 * we'll take the memcg_mutex to protect ourselves against this.
 	 */
-	cgroup_lock();
+	mutex_lock(&memcg_mutex);
 	for (i = 0; i < memcg_limited_groups_array_size; i++) {
 		c = s->memcg_params->memcg_caches[i];
 		if (!c)
@@ -3290,7 +3292,7 @@ void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 		cancel_work_sync(&c->memcg_params->destroy);
 		kmem_cache_destroy(c);
 	}
-	cgroup_unlock();
+	mutex_unlock(&memcg_mutex);
 }
 
 struct create_work {
@@ -4816,7 +4818,7 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
 	if (parent)
 		parent_memcg = mem_cgroup_from_cont(parent);
 
-	cgroup_lock();
+	mutex_lock(&memcg_mutex);
 
 	if (memcg->use_hierarchy == val)
 		goto out;
@@ -4839,7 +4841,7 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
 		retval = -EINVAL;
 
 out:
-	cgroup_unlock();
+	mutex_unlock(&memcg_mutex);
 
 	return retval;
 }
@@ -4939,13 +4941,10 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
 	 * After it first became limited, changes in the value of the limit are
 	 * of course permitted.
 	 *
-	 * Taking the cgroup_lock is really offensive, but it is so far the only
-	 * way to guarantee that no children will appear. There are plenty of
-	 * other offenders, and they should all go away. Fine grained locking
-	 * is probably the way to go here. When we are fully hierarchical, we
-	 * can also get rid of the use_hierarchy check.
+	 * We are protected by the memcg_mutex, so no other cgroups can appear
+	 * in the mean time.
 	 */
-	cgroup_lock();
+	mutex_lock(&memcg_mutex);
 	if (!memcg->kmem_account_flags && val != RESOURCE_MAX) {
 		if (cgroup_task_count(cont) || memcg_has_children(memcg)) {
 			ret = -EBUSY;
@@ -4970,7 +4969,7 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
 	} else
 		ret = res_counter_set_limit(&memcg->kmem, val);
 out:
-	cgroup_unlock();
+	mutex_unlock(&memcg_mutex);
 
 	/*
 	 * We are by now familiar with the fact that we can't inc the static
@@ -5027,9 +5026,9 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
 	mem_cgroup_get(memcg);
 	static_key_slow_inc(&memcg_kmem_enabled_key);
 
-	cgroup_lock();
+	mutex_lock(&memcg_mutex);
 	ret = memcg_update_cache_sizes(memcg);
-	cgroup_unlock();
+	mutex_unlock(&memcg_mutex);
 #endif
 out:
 	return ret;
@@ -5359,17 +5358,17 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
 
 	parent = mem_cgroup_from_cont(cgrp->parent);
 
-	cgroup_lock();
+	mutex_lock(&memcg_mutex);
 
 	/* If under hierarchy, only empty-root can set this value */
 	if ((parent->use_hierarchy) || memcg_has_children(memcg)) {
-		cgroup_unlock();
+		mutex_unlock(&memcg_mutex);
 		return -EINVAL;
 	}
 
 	memcg->swappiness = val;
 
-	cgroup_unlock();
+	mutex_unlock(&memcg_mutex);
 
 	return 0;
 }
@@ -5695,7 +5694,7 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
 
 	parent = mem_cgroup_from_cont(cgrp->parent);
 
-	cgroup_lock();
+	mutex_lock(&memcg_mutex);
 	/* oom-kill-disable is a flag for subhierarchy. */
 	if ((parent->use_hierarchy) ||
 	    (memcg->use_hierarchy && !list_empty(&cgrp->children))) {
@@ -5705,7 +5704,7 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
 	memcg->oom_kill_disable = val;
 	if (!val)
 		memcg_oom_recover(memcg);
-	cgroup_unlock();
+	mutex_unlock(&memcg_mutex);
 	return 0;
 }
 
@@ -6148,6 +6147,7 @@ mem_cgroup_css_online(struct cgroup *cont)
 		return 0;
 	}
 
+	mutex_lock(&memcg_mutex);
 	parent = mem_cgroup_from_cont(cont->parent);
 
 	memcg->use_hierarchy = parent->use_hierarchy;
@@ -6182,6 +6182,7 @@ mem_cgroup_css_online(struct cgroup *cont)
 	atomic_set(&memcg->refcnt, 1);
 
 	error = memcg_init_kmem(memcg, &mem_cgroup_subsys);
+	mutex_unlock(&memcg_mutex);
 	if (error) {
 		/*
 		 * We call put now because our (and parent's) refcnts
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
