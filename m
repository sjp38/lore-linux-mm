Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 3912D6B0073
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 04:45:45 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 5/7] May god have mercy on my soul.
Date: Fri, 11 Jan 2013 13:45:25 +0400
Message-Id: <1357897527-15479-6-git-send-email-glommer@parallels.com>
In-Reply-To: <1357897527-15479-1-git-send-email-glommer@parallels.com>
References: <1357897527-15479-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>

Signed-off-by: Glauber Costa <glommer@parallels.com>
---
 mm/memcontrol.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index aa4e258..c024614 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2909,7 +2909,7 @@ int memcg_cache_id(struct mem_cgroup *memcg)
  * operation, because that is its main call site.
  *
  * But when we create a new cache, we can call this as well if its parent
- * is kmem-limited. That will have to hold set_limit_mutex as well.
+ * is kmem-limited. That will have to hold cgroup_lock as well.
  */
 int memcg_update_cache_sizes(struct mem_cgroup *memcg)
 {
@@ -2924,7 +2924,7 @@ int memcg_update_cache_sizes(struct mem_cgroup *memcg)
 	 * the beginning of this conditional), is no longer 0. This
 	 * guarantees only one process will set the following boolean
 	 * to true. We don't need test_and_set because we're protected
-	 * by the set_limit_mutex anyway.
+	 * by the cgroup_lock anyway.
 	 */
 	memcg_kmem_set_activated(memcg);
 
@@ -3265,9 +3265,9 @@ void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 	 *
 	 * Still, we don't want anyone else freeing memcg_caches under our
 	 * noses, which can happen if a new memcg comes to life. As usual,
-	 * we'll take the set_limit_mutex to protect ourselves against this.
+	 * we'll take the cgroup_lock to protect ourselves against this.
 	 */
-	mutex_lock(&set_limit_mutex);
+	cgroup_lock();
 	for (i = 0; i < memcg_limited_groups_array_size; i++) {
 		c = s->memcg_params->memcg_caches[i];
 		if (!c)
@@ -3290,7 +3290,7 @@ void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 		cancel_work_sync(&c->memcg_params->destroy);
 		kmem_cache_destroy(c);
 	}
-	mutex_unlock(&set_limit_mutex);
+	cgroup_unlock();
 }
 
 struct create_work {
@@ -4946,7 +4946,6 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
 	 * can also get rid of the use_hierarchy check.
 	 */
 	cgroup_lock();
-	mutex_lock(&set_limit_mutex);
 	if (!memcg->kmem_account_flags && val != RESOURCE_MAX) {
 		if (cgroup_task_count(cont) || memcg_has_children(memcg)) {
 			ret = -EBUSY;
@@ -4971,7 +4970,6 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
 	} else
 		ret = res_counter_set_limit(&memcg->kmem, val);
 out:
-	mutex_unlock(&set_limit_mutex);
 	cgroup_unlock();
 
 	/*
@@ -5029,9 +5027,9 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
 	mem_cgroup_get(memcg);
 	static_key_slow_inc(&memcg_kmem_enabled_key);
 
-	mutex_lock(&set_limit_mutex);
+	cgroup_lock();
 	ret = memcg_update_cache_sizes(memcg);
-	mutex_unlock(&set_limit_mutex);
+	cgroup_unlock();
 #endif
 out:
 	return ret;
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
