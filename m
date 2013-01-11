Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id A79296B0078
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 04:45:45 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 4/7] memcg: fast hierarchy-aware child test.
Date: Fri, 11 Jan 2013 13:45:24 +0400
Message-Id: <1357897527-15479-5-git-send-email-glommer@parallels.com>
In-Reply-To: <1357897527-15479-1-git-send-email-glommer@parallels.com>
References: <1357897527-15479-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>

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
---
 mm/memcontrol.c | 32 +++++++++++++++++++++++++++-----
 1 file changed, 27 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2ac2808..aa4e258 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4723,6 +4723,30 @@ static void mem_cgroup_reparent_charges(struct mem_cgroup *memcg)
 }
 
 /*
+ * must be called with memcg_mutex held, unless the cgroup is guaranteed to be
+ * already dead (like in mem_cgroup_force_empty, for instance).  This is
+ * different than mem_cgroup_count_children, in the sense that we don't really
+ * care how many children we have, we only need to know if we have any. It is
+ * also count any memcg without hierarchy as infertile for that matter.
+ */
+static inline bool memcg_has_children(struct mem_cgroup *memcg)
+{
+	struct mem_cgroup *iter;
+
+	if (!memcg->use_hierarchy)
+		return false;
+
+	/* bounce at first found */
+	for_each_mem_cgroup_tree(iter, memcg) {
+		if ((iter == memcg) || !mem_cgroup_online(iter))
+			continue;
+		return true;
+	}
+
+	return false;
+}
+
+/*
  * Reclaims as many pages from the given memcg as possible and moves
  * the rest to the parent.
  *
@@ -4807,7 +4831,7 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
 	 */
 	if ((!parent_memcg || !parent_memcg->use_hierarchy) &&
 				(val == 1 || val == 0)) {
-		if (list_empty(&cont->children))
+		if (!memcg_has_children(memcg))
 			memcg->use_hierarchy = val;
 		else
 			retval = -EBUSY;
@@ -4924,8 +4948,7 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
 	cgroup_lock();
 	mutex_lock(&set_limit_mutex);
 	if (!memcg->kmem_account_flags && val != RESOURCE_MAX) {
-		if (cgroup_task_count(cont) || (memcg->use_hierarchy &&
-						!list_empty(&cont->children))) {
+		if (cgroup_task_count(cont) || memcg_has_children(memcg)) {
 			ret = -EBUSY;
 			goto out;
 		}
@@ -5341,8 +5364,7 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
 	cgroup_lock();
 
 	/* If under hierarchy, only empty-root can set this value */
-	if ((parent->use_hierarchy) ||
-	    (memcg->use_hierarchy && !list_empty(&cgrp->children))) {
+	if ((parent->use_hierarchy) || memcg_has_children(memcg)) {
 		cgroup_unlock();
 		return -EINVAL;
 	}
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
