Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id C7F6A6B0004
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 08:47:37 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v4 3/6] memcg: fast hierarchy-aware child test.
Date: Tue, 22 Jan 2013 17:47:38 +0400
Message-Id: <1358862461-18046-4-git-send-email-glommer@parallels.com>
In-Reply-To: <1358862461-18046-1-git-send-email-glommer@parallels.com>
References: <1358862461-18046-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Glauber Costa <glommer@parallels.com>

Currently, we use cgroups' provided list of children to verify if it is
safe to proceed with any value change that is dependent on the cgroup
being empty.

This is less than ideal, because it enforces a dependency over cgroup
core that we would be better off without. The solution proposed here is
to iterate over the child cgroups and if any is found that is already
online, we bounce and return: we don't really care how many children we
have, only if we have any.

This is also made to be hierarchy aware. IOW, cgroups with  hierarchy
disabled, while they still exist, will be considered for the purpose of
this interface as having no children.

Signed-off-by: Glauber Costa <glommer@parallels.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 34 +++++++++++++++++++++++++++++-----
 1 file changed, 29 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6c72204..6d3ad21 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4716,6 +4716,32 @@ static void mem_cgroup_reparent_charges(struct mem_cgroup *memcg)
 }
 
 /*
+ * this mainly exists for tests during set of use_hierarchy. Since this is
+ * the very setting we are changing, the current hierarchy value is meaningless
+ */
+static inline bool __memcg_has_children(struct mem_cgroup *memcg)
+{
+	struct cgroup *pos;
+
+	/* bounce at first found */
+	cgroup_for_each_child(pos, memcg->css.cgroup)
+		return true;
+	return false;
+}
+
+/*
+ * must be called with cgroup_lock held, unless the cgroup is guaranteed to be
+ * already dead (like in mem_cgroup_force_empty, for instance).  This is
+ * different than mem_cgroup_count_children, in the sense that we don't really
+ * care how many children we have, we only need to know if we have any. It is
+ * also count any memcg without hierarchy as infertile for that matter.
+ */
+static inline bool memcg_has_children(struct mem_cgroup *memcg)
+{
+	return memcg->use_hierarchy && __memcg_has_children(memcg);
+}
+
+/*
  * Reclaims as many pages from the given memcg as possible and moves
  * the rest to the parent.
  *
@@ -4800,7 +4826,7 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
 	 */
 	if ((!parent_memcg || !parent_memcg->use_hierarchy) &&
 				(val == 1 || val == 0)) {
-		if (list_empty(&cont->children))
+		if (!__memcg_has_children(memcg))
 			memcg->use_hierarchy = val;
 		else
 			retval = -EBUSY;
@@ -4917,8 +4943,7 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
 	cgroup_lock();
 	mutex_lock(&set_limit_mutex);
 	if (!memcg->kmem_account_flags && val != RESOURCE_MAX) {
-		if (cgroup_task_count(cont) || (memcg->use_hierarchy &&
-						!list_empty(&cont->children))) {
+		if (cgroup_task_count(cont) || memcg_has_children(memcg)) {
 			ret = -EBUSY;
 			goto out;
 		}
@@ -5334,8 +5359,7 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
 	cgroup_lock();
 
 	/* If under hierarchy, only empty-root can set this value */
-	if ((parent->use_hierarchy) ||
-	    (memcg->use_hierarchy && !list_empty(&cgrp->children))) {
+	if ((parent->use_hierarchy) || memcg_has_children(memcg)) {
 		cgroup_unlock();
 		return -EINVAL;
 	}
-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
