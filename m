Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id B8EDC6B0078
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 04:45:51 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 7/7] memcg: increment static branch right after limit set.
Date: Fri, 11 Jan 2013 13:45:27 +0400
Message-Id: <1357897527-15479-8-git-send-email-glommer@parallels.com>
In-Reply-To: <1357897527-15479-1-git-send-email-glommer@parallels.com>
References: <1357897527-15479-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>

We were deferring the kmemcg static branch increment to a later time,
due to a nasty dependency between the cpu_hotplug lock, taken by the
jump label update, and the cgroup_lock.

Now we no longer take the cgroup lock, and we can save ourselves the
trouble.

Signed-off-by: Glauber Costa <glommer@parallels.com>
---
 mm/memcontrol.c | 31 +++++++------------------------
 1 file changed, 7 insertions(+), 24 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5f3adbc..f87d6d2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4926,8 +4926,6 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
 {
 	int ret = -EINVAL;
 #ifdef CONFIG_MEMCG_KMEM
-	bool must_inc_static_branch = false;
-
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 	/*
 	 * For simplicity, we won't allow this to be disabled.  It also can't
@@ -4958,7 +4956,13 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
 			res_counter_set_limit(&memcg->kmem, RESOURCE_MAX);
 			goto out;
 		}
-		must_inc_static_branch = true;
+		static_key_slow_inc(&memcg_kmem_enabled_key);
+		/*
+		 * setting the active bit after the inc will guarantee no one
+		 * starts accounting before all call sites are patched
+		 */
+		memcg_kmem_set_active(memcg);
+
 		/*
 		 * kmem charges can outlive the cgroup. In the case of slab
 		 * pages, for instance, a page contain objects from various
@@ -4970,27 +4974,6 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
 		ret = res_counter_set_limit(&memcg->kmem, val);
 out:
 	mutex_unlock(&memcg_mutex);
-
-	/*
-	 * We are by now familiar with the fact that we can't inc the static
-	 * branch inside cgroup_lock. See disarm functions for details. A
-	 * worker here is overkill, but also wrong: After the limit is set, we
-	 * must start accounting right away. Since this operation can't fail,
-	 * we can safely defer it to here - no rollback will be needed.
-	 *
-	 * The boolean used to control this is also safe, because
-	 * KMEM_ACCOUNTED_ACTIVATED guarantees that only one process will be
-	 * able to set it to true;
-	 */
-	if (must_inc_static_branch) {
-		static_key_slow_inc(&memcg_kmem_enabled_key);
-		/*
-		 * setting the active bit after the inc will guarantee no one
-		 * starts accounting before all call sites are patched
-		 */
-		memcg_kmem_set_active(memcg);
-	}
-
 #endif
 	return ret;
 }
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
