Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 49458280263
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 21:15:15 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id y200so5549270itc.7
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 18:15:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 73sor2099152ita.120.2018.01.16.18.15.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jan 2018 18:15:14 -0800 (PST)
Date: Tue, 16 Jan 2018 18:15:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 4/4] mm, memcg: add hierarchical usage oom policy
In-Reply-To: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1801161814260.28198@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

One of the three significant concerns brought up about the cgroup aware
oom killer is that its decisionmaking is completely evaded by creating
subcontainers and attaching processes such that the ancestor's usage does
not exceed another cgroup on the system.

In this regard, users who do not distribute their processes over a set of
subcontainers for mem cgroup control, statistics, or other controllers
are unfairly penalized.

This adds an oom policy, "tree", that accounts for hierarchical usage
when comparing cgroups and the cgroup aware oom killer is enabled by an
ancestor.  This allows administrators, for example, to require users in
their own top-level mem cgroup subtree to be accounted for with
hierarchical usage.  In other words, they can longer evade the oom killer
by using other controllers or subcontainers.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/cgroup-v2.txt | 12 ++++++++++--
 include/linux/memcontrol.h  |  9 +++++++--
 mm/memcontrol.c             | 23 +++++++++++++++--------
 3 files changed, 32 insertions(+), 12 deletions(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -1048,6 +1048,11 @@ PAGE_SIZE multiple when read back.
 	memory consumers; that is, they will compare mem cgroup usage rather
 	than process memory footprint.  See the "OOM Killer" section.
 
+	If "tree", the OOM killer will compare mem cgroups and its subtree
+	as indivisible memory consumers when selecting a hierarchy.  This
+	policy cannot be set on the root mem cgroup.  See the "OOM Killer"
+	section.
+
 	If "all", the OOM killer will compare mem cgroups and its subtree
 	as indivisible memory consumers and kill all processes attached to
 	the mem cgroup and its subtree.  This policy cannot be set on the
@@ -1275,6 +1280,9 @@ There are currently three available oom policies:
  - "cgroup": choose the cgroup with the largest memory footprint from the
    subtree as an OOM victim and kill at least one process.
 
+ - "tree": choose the cgroup with the largest memory footprint considering
+   itself and its subtree and kill at least one process.
+
  - "all": choose the cgroup with the largest memory footprint considering
    itself and its subtree and kill all processes attached (cannot be set on
    the root mem cgroup).
@@ -1292,8 +1300,8 @@ Please, note that memory charges are not migrating if tasks
 are moved between different memory cgroups. Moving tasks with
 significant memory footprint may affect OOM victim selection logic.
 If it's a case, please, consider creating a common ancestor for
-the source and destination memory cgroups and setting a policy of "all"
-on ancestor layer.
+the source and destination memory cgroups and setting a policy of "tree"
+or "all" on ancestor layer.
 
 
 IO
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -70,8 +70,13 @@ enum memcg_oom_policy {
 	 */
 	MEMCG_OOM_POLICY_CGROUP,
 	/*
-	 * Same as MEMCG_OOM_POLICY_CGROUP, but all eligible processes attached
-	 * to the cgroup and subtree should be oom killed
+	 * Tree cgroup usage for all descendant memcg groups, treating each mem
+	 * cgroup and its subtree as an indivisible consumer
+	 */
+	MEMCG_OOM_POLICY_TREE,
+	/*
+	 * Same as MEMCG_OOM_POLICY_TREE, but all eligible processes are also
+	 * oom killed
 	 */
 	MEMCG_OOM_POLICY_ALL,
 };
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2715,11 +2715,11 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 	oc->chosen_points = 0;
 
 	/*
-	 * If OOM is memcg-wide, and the oom policy is "all", all processes
-	 * attached to the memcg and subtree should be killed.
-	 * So, we mark the memcg as a victim.
+	 * If OOM is memcg-wide, and the oom policy is "tree" or "all", this
+	 * is the selected memcg.
 	 */
-	if (oc->memcg && mem_cgroup_oom_policy_all(oc->memcg)) {
+	if (oc->memcg && (oc->memcg->oom_policy == MEMCG_OOM_POLICY_TREE ||
+			  oc->memcg->oom_policy == MEMCG_OOM_POLICY_ALL)) {
 		oc->chosen_memcg = oc->memcg;
 		css_get(&oc->chosen_memcg->css);
 		return;
@@ -2728,8 +2728,8 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 	/*
 	 * The oom_score is calculated for leaf memory cgroups (including
 	 * the root memcg).
-	 * Cgroups with oom policy of "all" accumulate the score of descendant
-	 * leaf memory cgroups.
+	 * Cgroups with oom policy of "tree" or "all" accumulate the score of
+	 * descendant leaf memory cgroups.
 	 */
 	rcu_read_lock();
 	for_each_mem_cgroup_tree(iter, root) {
@@ -2737,10 +2737,11 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 
 		/*
 		 * We don't consider non-leaf memory cgroups without the oom
-		 * policy of "all" as oom victims.
+		 * policy of "tree" or "all" as oom victims.
 		 */
 		if (memcg_has_children(iter) && iter != root_mem_cgroup &&
-		    !mem_cgroup_oom_policy_all(iter))
+		    iter->oom_policy != MEMCG_OOM_POLICY_TREE &&
+		    iter->oom_policy != MEMCG_OOM_POLICY_ALL)
 			continue;
 
 		/*
@@ -5511,6 +5512,9 @@ static int memory_oom_policy_show(struct seq_file *m, void *v)
 	case MEMCG_OOM_POLICY_CGROUP:
 		seq_puts(m, "cgroup\n");
 		break;
+	case MEMCG_OOM_POLICY_TREE:
+		seq_puts(m, "tree\n");
+		break;
 	case MEMCG_OOM_POLICY_ALL:
 		seq_puts(m, "all\n");
 		break;
@@ -5532,6 +5536,9 @@ static ssize_t memory_oom_policy_write(struct kernfs_open_file *of,
 		memcg->oom_policy = MEMCG_OOM_POLICY_NONE;
 	else if (!memcmp("cgroup", buf, min(sizeof("cgroup")-1, nbytes)))
 		memcg->oom_policy = MEMCG_OOM_POLICY_CGROUP;
+	else if (memcg != root_mem_cgroup &&
+			!memcmp("tree", buf, min(sizeof("tree")-1, nbytes)))
+		memcg->oom_policy = MEMCG_OOM_POLICY_TREE;
 	else if (memcg != root_mem_cgroup &&
 			!memcmp("all", buf, min(sizeof("all")-1, nbytes)))
 		memcg->oom_policy = MEMCG_OOM_POLICY_ALL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
