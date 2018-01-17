Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 276DF280263
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 21:15:13 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id m4so16611308iob.16
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 18:15:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l73sor1730938ita.140.2018.01.16.18.15.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jan 2018 18:15:10 -0800 (PST)
Date: Tue, 16 Jan 2018 18:15:08 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 3/4] mm, memcg: replace memory.oom_group with policy
 tunable
In-Reply-To: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1801161814130.28198@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The behavior of killing an entire indivisible memory consumer, enabled
by memory.oom_group, is an oom policy itself.  It specifies that all
usage should be accounted to an ancestor and, if selected by the cgroup
aware oom killer, all processes attached to it and its descendant mem
cgroups should be oom killed.

This is replaced by writing "all" to memory.oom_policy and allows for the
same functionality as the existing memory.oom_group without (1) polluting
the mem cgroup v2 filesystem unnecessarily and (2) unnecessarily when the
"groupoom" mount option is not used (now by writing "cgroup" to the root
mem cgroup's memory.oom_policy).

The "all" oom policy cannot be enabled on the root mem cgroup.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/cgroup-v2.txt | 51 ++++++++++++++---------------------------
 include/linux/memcontrol.h  | 18 +++++++--------
 mm/memcontrol.c             | 55 ++++++++++++---------------------------------
 mm/oom_kill.c               |  4 ++--
 4 files changed, 41 insertions(+), 87 deletions(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -1035,31 +1035,6 @@ PAGE_SIZE multiple when read back.
 	high limit is used and monitored properly, this limit's
 	utility is limited to providing the final safety net.
 
-  memory.oom_group
-
-	A read-write single value file which exists on non-root
-	cgroups.  The default is "0".
-
-	If set, OOM killer will consider the memory cgroup as an
-	indivisible memory consumers and compare it with other memory
-	consumers by it's memory footprint.
-	If such memory cgroup is selected as an OOM victim, all
-	processes belonging to it or it's descendants will be killed.
-
-	This applies to system-wide OOM conditions and reaching
-	the hard memory limit of the cgroup and their ancestor.
-	If OOM condition happens in a descendant cgroup with it's own
-	memory limit, the memory cgroup can't be considered
-	as an OOM victim, and OOM killer will not kill all belonging
-	tasks.
-
-	Also, OOM killer respects the /proc/pid/oom_score_adj value -1000,
-	and will never kill the unkillable task, even if memory.oom_group
-	is set.
-
-	If cgroup-aware OOM killer is not enabled, ENOTSUPP error
-	is returned on attempt to access the file.
-
   memory.oom_policy
 
 	A read-write single string file which exists on all cgroups.  The
@@ -1073,6 +1048,11 @@ PAGE_SIZE multiple when read back.
 	memory consumers; that is, they will compare mem cgroup usage rather
 	than process memory footprint.  See the "OOM Killer" section.
 
+	If "all", the OOM killer will compare mem cgroups and its subtree
+	as indivisible memory consumers and kill all processes attached to
+	the mem cgroup and its subtree.  This policy cannot be set on the
+	root mem cgroup.  See the "OOM Killer" section.
+
   memory.events
 	A read-only flat-keyed file which exists on non-root cgroups.
 	The following entries are defined.  Unless specified
@@ -1287,29 +1267,32 @@ out of memory, its memory.oom_policy will dictate how the OOM killer will
 select a process, or cgroup, to kill.  Likewise, when the system is OOM,
 the policy is dictated by the root mem cgroup.
 
-There are currently two available oom policies:
+There are currently three available oom policies:
 
  - "none": default, choose the largest single memory hogging process to
    oom kill, as traditionally the OOM killer has always done.
 
  - "cgroup": choose the cgroup with the largest memory footprint from the
-   subtree as an OOM victim and kill at least one process, depending on
-   memory.oom_group, from it.
+   subtree as an OOM victim and kill at least one process.
+
+ - "all": choose the cgroup with the largest memory footprint considering
+   itself and its subtree and kill all processes attached (cannot be set on
+   the root mem cgroup).
 
 When selecting a cgroup as a victim, the OOM killer will kill the process
-with the largest memory footprint.  A user can control this behavior by
-enabling the per-cgroup memory.oom_group option.  If set, it causes the
-OOM killer to kill all processes attached to the cgroup, except processes
-with /proc/pid/oom_score_adj set to -1000 (oom disabled).
+with the largest memory footprint, unless the policy is specified as "all".
+In that case, the OOM killer will kill all processes attached to the cgroup
+and its subtree, except processes with /proc/pid/oom_score_adj set to
+-1000 (oom disabled).
 
 The root cgroup is treated as a leaf memory cgroup, so it's compared
-with other leaf memory cgroups and cgroups with oom_group option set.
+with other leaf memory cgroups.
 
 Please, note that memory charges are not migrating if tasks
 are moved between different memory cgroups. Moving tasks with
 significant memory footprint may affect OOM victim selection logic.
 If it's a case, please, consider creating a common ancestor for
-the source and destination memory cgroups and enabling oom_group
+the source and destination memory cgroups and setting a policy of "all"
 on ancestor layer.
 
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -69,6 +69,11 @@ enum memcg_oom_policy {
 	 * mem cgroup as an indivisible consumer
 	 */
 	MEMCG_OOM_POLICY_CGROUP,
+	/*
+	 * Same as MEMCG_OOM_POLICY_CGROUP, but all eligible processes attached
+	 * to the cgroup and subtree should be oom killed
+	 */
+	MEMCG_OOM_POLICY_ALL,
 };
 
 struct mem_cgroup_reclaim_cookie {
@@ -219,13 +224,6 @@ struct mem_cgroup {
 	/* OOM policy for this subtree */
 	enum memcg_oom_policy oom_policy;
 
-	/*
-	 * Treat the sub-tree as an indivisible memory consumer,
-	 * kill all belonging tasks if the memory cgroup selected
-	 * as OOM victim.
-	 */
-	bool oom_group;
-
 	/* handle for "memory.events" */
 	struct cgroup_file events_file;
 
@@ -513,9 +511,9 @@ bool mem_cgroup_oom_synchronize(bool wait);
 
 bool mem_cgroup_select_oom_victim(struct oom_control *oc);
 
-static inline bool mem_cgroup_oom_group(struct mem_cgroup *memcg)
+static inline bool mem_cgroup_oom_policy_all(struct mem_cgroup *memcg)
 {
-	return memcg->oom_group;
+	return memcg->oom_policy == MEMCG_OOM_POLICY_ALL;
 }
 
 #ifdef CONFIG_MEMCG_SWAP
@@ -1019,7 +1017,7 @@ static inline bool mem_cgroup_select_oom_victim(struct oom_control *oc)
 	return false;
 }
 
-static inline bool mem_cgroup_oom_group(struct mem_cgroup *memcg)
+static inline bool mem_cgroup_oom_policy_all(struct mem_cgroup *memcg)
 {
 	return false;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2715,11 +2715,11 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 	oc->chosen_points = 0;
 
 	/*
-	 * If OOM is memcg-wide, and the memcg has the oom_group flag set,
-	 * all tasks belonging to the memcg should be killed.
+	 * If OOM is memcg-wide, and the oom policy is "all", all processes
+	 * attached to the memcg and subtree should be killed.
 	 * So, we mark the memcg as a victim.
 	 */
-	if (oc->memcg && mem_cgroup_oom_group(oc->memcg)) {
+	if (oc->memcg && mem_cgroup_oom_policy_all(oc->memcg)) {
 		oc->chosen_memcg = oc->memcg;
 		css_get(&oc->chosen_memcg->css);
 		return;
@@ -2728,7 +2728,7 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 	/*
 	 * The oom_score is calculated for leaf memory cgroups (including
 	 * the root memcg).
-	 * Non-leaf oom_group cgroups accumulating score of descendant
+	 * Cgroups with oom policy of "all" accumulate the score of descendant
 	 * leaf memory cgroups.
 	 */
 	rcu_read_lock();
@@ -2736,11 +2736,11 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 		long score;
 
 		/*
-		 * We don't consider non-leaf non-oom_group memory cgroups
-		 * as OOM victims.
+		 * We don't consider non-leaf memory cgroups without the oom
+		 * policy of "all" as oom victims.
 		 */
 		if (memcg_has_children(iter) && iter != root_mem_cgroup &&
-		    !mem_cgroup_oom_group(iter))
+		    !mem_cgroup_oom_policy_all(iter))
 			continue;
 
 		/*
@@ -2803,7 +2803,7 @@ bool mem_cgroup_select_oom_victim(struct oom_control *oc)
 	else
 		root = root_mem_cgroup;
 
-	if (root->oom_policy != MEMCG_OOM_POLICY_CGROUP)
+	if (root->oom_policy == MEMCG_OOM_POLICY_NONE)
 		return false;
 
 	select_victim_memcg(root, oc);
@@ -5407,33 +5407,6 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
 	return nbytes;
 }
 
-static int memory_oom_group_show(struct seq_file *m, void *v)
-{
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
-	bool oom_group = memcg->oom_group;
-
-	seq_printf(m, "%d\n", oom_group);
-
-	return 0;
-}
-
-static ssize_t memory_oom_group_write(struct kernfs_open_file *of,
-				      char *buf, size_t nbytes,
-				      loff_t off)
-{
-	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
-	int oom_group;
-	int err;
-
-	err = kstrtoint(strstrip(buf), 0, &oom_group);
-	if (err)
-		return err;
-
-	memcg->oom_group = oom_group;
-
-	return nbytes;
-}
-
 static int memory_events_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
@@ -5538,6 +5511,9 @@ static int memory_oom_policy_show(struct seq_file *m, void *v)
 	case MEMCG_OOM_POLICY_CGROUP:
 		seq_puts(m, "cgroup\n");
 		break;
+	case MEMCG_OOM_POLICY_ALL:
+		seq_puts(m, "all\n");
+		break;
 	case MEMCG_OOM_POLICY_NONE:
 	default:
 		seq_puts(m, "none\n");
@@ -5556,6 +5532,9 @@ static ssize_t memory_oom_policy_write(struct kernfs_open_file *of,
 		memcg->oom_policy = MEMCG_OOM_POLICY_NONE;
 	else if (!memcmp("cgroup", buf, min(sizeof("cgroup")-1, nbytes)))
 		memcg->oom_policy = MEMCG_OOM_POLICY_CGROUP;
+	else if (memcg != root_mem_cgroup &&
+			!memcmp("all", buf, min(sizeof("all")-1, nbytes)))
+		memcg->oom_policy = MEMCG_OOM_POLICY_ALL;
 	else
 		ret = -EINVAL;
 
@@ -5586,12 +5565,6 @@ static struct cftype memory_files[] = {
 		.seq_show = memory_max_show,
 		.write = memory_max_write,
 	},
-	{
-		.name = "oom_group",
-		.flags = CFTYPE_NOT_ON_ROOT | CFTYPE_NS_DELEGATABLE,
-		.seq_show = memory_oom_group_show,
-		.write = memory_oom_group_write,
-	},
 	{
 		.name = "events",
 		.flags = CFTYPE_NOT_ON_ROOT,
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1000,11 +1000,11 @@ static bool oom_kill_memcg_victim(struct oom_control *oc)
 		return oc->chosen_memcg;
 
 	/*
-	 * If memory.oom_group is set, kill all tasks belonging to the sub-tree
+	 * If the oom policy is "all", kill all tasks belonging to the sub-tree
 	 * of the chosen memory cgroup, otherwise kill the task with the biggest
 	 * memory footprint.
 	 */
-	if (mem_cgroup_oom_group(oc->chosen_memcg)) {
+	if (mem_cgroup_oom_policy_all(oc->chosen_memcg)) {
 		mem_cgroup_scan_tasks(oc->chosen_memcg, oom_kill_memcg_member,
 				      NULL);
 		/* We have one or more terminating processes at this point. */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
