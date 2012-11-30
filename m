Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id CB2CE6B00A5
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 08:31:39 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 4/4] memcg: replace cgroup_lock with memcg specific memcg_lock
Date: Fri, 30 Nov 2012 17:31:26 +0400
Message-Id: <1354282286-32278-5-git-send-email-glommer@parallels.com>
In-Reply-To: <1354282286-32278-1-git-send-email-glommer@parallels.com>
References: <1354282286-32278-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@parallels.com>

After the preparation work done in earlier patches, the
cgroup_lock can be trivially replaced with a memcg-specific lock in all
readers.

The writers, however, used to be naturally called under cgroup_lock, and
now we need to explicitly add the memcg_lock. Those are the callbacks in
attach_task, and parent-dependent value assignment in newly-created
memcgs.

With this, all the calls to cgroup_lock outside cgroup core are gone.

Signed-off-by: Glauber Costa <glommer@parallels.com>
---
 mm/memcontrol.c | 48 ++++++++++++++++++++++++++++++++++--------------
 1 file changed, 34 insertions(+), 14 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b6d352f..fd7b5d3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3830,6 +3830,17 @@ static void mem_cgroup_reparent_charges(struct mem_cgroup *memcg)
 	} while (res_counter_read_u64(&memcg->res, RES_USAGE) > 0);
 }
 
+static DEFINE_MUTEX(memcg_lock);
+
+/*
+ * must be called with memcg_lock held, unless the cgroup is guaranteed to be
+ * already dead (like in mem_cgroup_force_empty, for instance).
+ */
+static inline bool memcg_has_children(struct mem_cgroup *memcg)
+{
+	return mem_cgroup_count_children(memcg) != 1;
+}
+
 /*
  * Reclaims as many pages from the given memcg as possible and moves
  * the rest to the parent.
@@ -3842,7 +3853,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
 	struct cgroup *cgrp = memcg->css.cgroup;
 
 	/* returns EBUSY if there is a task or if we come here twice. */
-	if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
+	if (cgroup_task_count(cgrp) || memcg_has_children(memcg))
 		return -EBUSY;
 
 	/* we call try-to-free pages for make this cgroup empty */
@@ -3900,7 +3911,7 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
 	if (parent)
 		parent_memcg = mem_cgroup_from_cont(parent);
 
-	cgroup_lock();
+	mutex_lock(&memcg_lock);
 
 	if (memcg->use_hierarchy == val)
 		goto out;
@@ -3915,7 +3926,7 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
 	 */
 	if ((!parent_memcg || !parent_memcg->use_hierarchy) &&
 				(val == 1 || val == 0)) {
-		if (list_empty(&cont->children))
+		if (!memcg_has_children(memcg))
 			memcg->use_hierarchy = val;
 		else
 			retval = -EBUSY;
@@ -3923,7 +3934,7 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
 		retval = -EINVAL;
 
 out:
-	cgroup_unlock();
+	mutex_unlock(&memcg_lock);
 
 	return retval;
 }
@@ -4129,13 +4140,13 @@ static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
 	 * attach(), so we need cgroup lock to prevent this value from being
 	 * inconsistent.
 	 */
-	cgroup_lock();
+	mutex_lock(&memcg_lock);
 	if (memcg->attach_in_progress)
 		goto out;
 	memcg->move_charge_at_immigrate = val;
 	ret = 0;
 out:
-	cgroup_unlock();
+	mutex_unlock(&memcg_lock);
 	return ret;
 }
 #else
@@ -4314,18 +4325,18 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
 
 	parent = mem_cgroup_from_cont(cgrp->parent);
 
-	cgroup_lock();
+	mutex_lock(&memcg_lock);
 
 	/* If under hierarchy, only empty-root can set this value */
 	if ((parent->use_hierarchy) ||
-	    (memcg->use_hierarchy && !list_empty(&cgrp->children))) {
-		cgroup_unlock();
+	    (memcg->use_hierarchy && !memcg_has_children(memcg))) {
+		mutex_unlock(&memcg_lock);
 		return -EINVAL;
 	}
 
 	memcg->swappiness = val;
 
-	cgroup_unlock();
+	mutex_unlock(&memcg_lock);
 
 	return 0;
 }
@@ -4651,17 +4662,17 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
 
 	parent = mem_cgroup_from_cont(cgrp->parent);
 
-	cgroup_lock();
+	mutex_lock(&memcg_lock);
 	/* oom-kill-disable is a flag for subhierarchy. */
 	if ((parent->use_hierarchy) ||
-	    (memcg->use_hierarchy && !list_empty(&cgrp->children))) {
-		cgroup_unlock();
+	    (memcg->use_hierarchy && memcg_has_children(memcg))) {
+		mutex_unlock(&memcg_lock);
 		return -EINVAL;
 	}
 	memcg->oom_kill_disable = val;
 	if (!val)
 		memcg_oom_recover(memcg);
-	cgroup_unlock();
+	mutex_unlock(&memcg_lock);
 	return 0;
 }
 
@@ -5051,6 +5062,7 @@ mem_cgroup_css_online(struct cgroup *cont)
 	if (!cont->parent)
 		return 0;
 
+	mutex_lock(&memcg_lock);
 	memcg = mem_cgroup_from_cont(cont);
 	parent = mem_cgroup_from_cont(cont->parent);
 
@@ -5082,6 +5094,7 @@ mem_cgroup_css_online(struct cgroup *cont)
 	memcg->swappiness = mem_cgroup_swappiness(parent);
 
 	error = memcg_init_kmem(memcg, &mem_cgroup_subsys);
+	mutex_unlock(&memcg_lock);
 	if (error) {
 		/*
 		 * We call put now because our (and parent's) refcnts
@@ -5693,7 +5706,10 @@ static int mem_cgroup_can_attach(struct cgroup *cgroup,
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgroup);
 
+	mutex_lock(&memcg_lock);
 	memcg->attach_in_progress++;
+	mutex_unlock(&memcg_lock);
+
 	return __mem_cgroup_can_attach(memcg, tset);
 }
 
@@ -5703,7 +5719,9 @@ static void mem_cgroup_cancel_attach(struct cgroup *cgroup,
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgroup);
 
 	__mem_cgroup_cancel_attach(memcg, tset);
+	mutex_lock(&memcg_lock);
 	memcg->attach_in_progress--;
+	mutex_unlock(&memcg_lock);
 }
 
 static void mem_cgroup_move_task(struct cgroup *cgroup,
@@ -5712,7 +5730,9 @@ static void mem_cgroup_move_task(struct cgroup *cgroup,
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgroup);
 
 	__mem_cgroup_move_task(memcg, tset);
+	mutex_lock(&memcg_lock);
 	memcg->attach_in_progress--;
+	mutex_unlock(&memcg_lock);
 }
 
 struct cgroup_subsys mem_cgroup_subsys = {
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
