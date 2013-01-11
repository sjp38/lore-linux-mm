Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 7A2196B0072
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 04:45:38 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 2/7] memcg: split part of memcg creation to css_online
Date: Fri, 11 Jan 2013 13:45:22 +0400
Message-Id: <1357897527-15479-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1357897527-15479-1-git-send-email-glommer@parallels.com>
References: <1357897527-15479-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>

Although there is arguably some value in doing this per se, the main
goal of this patch is to make room for the locking changes to come.

With all the value assignment from parent happening in a context where
our iterators can already be used, we can safely lock against value
change in some key values like use_hierarchy, without resorting to the
cgroup core at all.

Signed-off-by: Glauber Costa <glommer@parallels.com>
---
 mm/memcontrol.c | 53 ++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 36 insertions(+), 17 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 18f4e76..2229945 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6090,12 +6090,41 @@ mem_cgroup_css_alloc(struct cgroup *cont)
 						&per_cpu(memcg_stock, cpu);
 			INIT_WORK(&stock->work, drain_local_stock);
 		}
-	} else {
-		parent = mem_cgroup_from_cont(cont->parent);
-		memcg->use_hierarchy = parent->use_hierarchy;
-		memcg->oom_kill_disable = parent->oom_kill_disable;
+
+		res_counter_init(&memcg->res, NULL);
+		res_counter_init(&memcg->memsw, NULL);
+		res_counter_init(&memcg->kmem, NULL);
 	}
 
+	memcg->last_scanned_node = MAX_NUMNODES;
+	INIT_LIST_HEAD(&memcg->oom_notify);
+	atomic_set(&memcg->refcnt, 1);
+	memcg->move_charge_at_immigrate = 0;
+	mutex_init(&memcg->thresholds_lock);
+	spin_lock_init(&memcg->move_lock);
+
+	return &memcg->css;
+
+free_out:
+	__mem_cgroup_free(memcg);
+	return ERR_PTR(error);
+}
+
+static int
+mem_cgroup_css_online(struct cgroup *cont)
+{
+	struct mem_cgroup *memcg, *parent;
+	int error = 0;
+
+	if (!cont->parent)
+		return 0;
+
+	memcg = mem_cgroup_from_cont(cont);
+	parent = mem_cgroup_from_cont(cont->parent);
+
+	memcg->use_hierarchy = parent->use_hierarchy;
+	memcg->oom_kill_disable = parent->oom_kill_disable;
+
 	if (parent && parent->use_hierarchy) {
 		res_counter_init(&memcg->res, &parent->res);
 		res_counter_init(&memcg->memsw, &parent->memsw);
@@ -6120,15 +6149,8 @@ mem_cgroup_css_alloc(struct cgroup *cont)
 		if (parent && parent != root_mem_cgroup)
 			mem_cgroup_subsys.broken_hierarchy = true;
 	}
-	memcg->last_scanned_node = MAX_NUMNODES;
-	INIT_LIST_HEAD(&memcg->oom_notify);
 
-	if (parent)
-		memcg->swappiness = mem_cgroup_swappiness(parent);
-	atomic_set(&memcg->refcnt, 1);
-	memcg->move_charge_at_immigrate = 0;
-	mutex_init(&memcg->thresholds_lock);
-	spin_lock_init(&memcg->move_lock);
+	memcg->swappiness = mem_cgroup_swappiness(parent);
 
 	error = memcg_init_kmem(memcg, &mem_cgroup_subsys);
 	if (error) {
@@ -6138,12 +6160,8 @@ mem_cgroup_css_alloc(struct cgroup *cont)
 		 * call __mem_cgroup_free, so return directly
 		 */
 		mem_cgroup_put(memcg);
-		return ERR_PTR(error);
 	}
-	return &memcg->css;
-free_out:
-	__mem_cgroup_free(memcg);
-	return ERR_PTR(error);
+	return error;
 }
 
 static void mem_cgroup_css_offline(struct cgroup *cont)
@@ -6753,6 +6771,7 @@ struct cgroup_subsys mem_cgroup_subsys = {
 	.name = "memory",
 	.subsys_id = mem_cgroup_subsys_id,
 	.css_alloc = mem_cgroup_css_alloc,
+	.css_online = mem_cgroup_css_online,
 	.css_offline = mem_cgroup_css_offline,
 	.css_free = mem_cgroup_css_free,
 	.can_attach = mem_cgroup_can_attach,
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
