Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 736A1280263
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 21:15:09 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id r196so5522516itc.4
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 18:15:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u87sor1811556ioi.236.2018.01.16.18.15.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jan 2018 18:15:08 -0800 (PST)
Date: Tue, 16 Jan 2018 18:15:05 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 2/4] mm, memcg: replace cgroup aware oom killer mount
 option with tunable
In-Reply-To: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1801161814010.28198@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Now that each mem cgroup on the system has a memory.oom_policy tunable to
specify oom kill selection behavior, remove the needless "groupoom" mount
option that requires (1) the entire system to be forced, perhaps
unnecessarily, perhaps unexpectedly, into a single oom policy that
differs from the traditional per process selection, and (2) a remount to
change.

Instead of enabling the cgroup aware oom killer with the "groupoom" mount
option, set the mem cgroup subtree's memory.oom_policy to "cgroup".

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/cgroup-v2.txt | 43 +++++++++++++++++++++----------------------
 include/linux/cgroup-defs.h |  5 -----
 include/linux/memcontrol.h  |  5 +++++
 kernel/cgroup/cgroup.c      | 13 +------------
 mm/memcontrol.c             | 17 ++++++++---------
 5 files changed, 35 insertions(+), 48 deletions(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -1069,6 +1069,10 @@ PAGE_SIZE multiple when read back.
 	victim; that is, it will choose the single process with the largest
 	memory footprint.
 
+	If "cgroup", the OOM killer will compare mem cgroups as indivisible
+	memory consumers; that is, they will compare mem cgroup usage rather
+	than process memory footprint.  See the "OOM Killer" section.
+
   memory.events
 	A read-only flat-keyed file which exists on non-root cgroups.
 	The following entries are defined.  Unless specified
@@ -1275,37 +1279,32 @@ belonging to the affected files to ensure correct memory ownership.
 OOM Killer
 ~~~~~~~~~~
 
-Cgroup v2 memory controller implements a cgroup-aware OOM killer.
-It means that it treats cgroups as first class OOM entities.
+Cgroup v2 memory controller implements an optional cgroup-aware out of
+memory killer, which treats cgroups as indivisible OOM entities.
 
-Cgroup-aware OOM logic is turned off by default and requires
-passing the "groupoom" option on mounting cgroupfs. It can also
-by remounting cgroupfs with the following command::
+This policy is controlled by memory.oom_policy.  When a memory cgroup is
+out of memory, its memory.oom_policy will dictate how the OOM killer will
+select a process, or cgroup, to kill.  Likewise, when the system is OOM,
+the policy is dictated by the root mem cgroup.
 
-  # mount -o remount,groupoom $MOUNT_POINT
+There are currently two available oom policies:
 
-Under OOM conditions the memory controller tries to make the best
-choice of a victim, looking for a memory cgroup with the largest
-memory footprint, considering leaf cgroups and cgroups with the
-memory.oom_group option set, which are considered to be an indivisible
-memory consumers.
+ - "none": default, choose the largest single memory hogging process to
+   oom kill, as traditionally the OOM killer has always done.
 
-By default, OOM killer will kill the biggest task in the selected
-memory cgroup. A user can change this behavior by enabling
-the per-cgroup memory.oom_group option. If set, it causes
-the OOM killer to kill all processes attached to the cgroup,
-except processes with oom_score_adj set to -1000.
+ - "cgroup": choose the cgroup with the largest memory footprint from the
+   subtree as an OOM victim and kill at least one process, depending on
+   memory.oom_group, from it.
 
-This affects both system- and cgroup-wide OOMs. For a cgroup-wide OOM
-the memory controller considers only cgroups belonging to the sub-tree
-of the OOM'ing cgroup.
+When selecting a cgroup as a victim, the OOM killer will kill the process
+with the largest memory footprint.  A user can control this behavior by
+enabling the per-cgroup memory.oom_group option.  If set, it causes the
+OOM killer to kill all processes attached to the cgroup, except processes
+with /proc/pid/oom_score_adj set to -1000 (oom disabled).
 
 The root cgroup is treated as a leaf memory cgroup, so it's compared
 with other leaf memory cgroups and cgroups with oom_group option set.
 
-If there are no cgroups with the enabled memory controller,
-the OOM killer is using the "traditional" process-based approach.
-
 Please, note that memory charges are not migrating if tasks
 are moved between different memory cgroups. Moving tasks with
 significant memory footprint may affect OOM victim selection logic.
diff --git a/include/linux/cgroup-defs.h b/include/linux/cgroup-defs.h
--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -81,11 +81,6 @@ enum {
 	 * Enable cpuset controller in v1 cgroup to use v2 behavior.
 	 */
 	CGRP_ROOT_CPUSET_V2_MODE = (1 << 4),
-
-	/*
-	 * Enable cgroup-aware OOM killer.
-	 */
-	CGRP_GROUP_OOM = (1 << 5),
 };
 
 /* cftype->flags */
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -64,6 +64,11 @@ enum memcg_oom_policy {
 	 * oom_badness()
 	 */
 	MEMCG_OOM_POLICY_NONE,
+	/*
+	 * Local cgroup usage is used to select a target cgroup, treating each
+	 * mem cgroup as an indivisible consumer
+	 */
+	MEMCG_OOM_POLICY_CGROUP,
 };
 
 struct mem_cgroup_reclaim_cookie {
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -1732,9 +1732,6 @@ static int parse_cgroup_root_flags(char *data, unsigned int *root_flags)
 		if (!strcmp(token, "nsdelegate")) {
 			*root_flags |= CGRP_ROOT_NS_DELEGATE;
 			continue;
-		} else if (!strcmp(token, "groupoom")) {
-			*root_flags |= CGRP_GROUP_OOM;
-			continue;
 		}
 
 		pr_err("cgroup2: unknown option \"%s\"\n", token);
@@ -1751,11 +1748,6 @@ static void apply_cgroup_root_flags(unsigned int root_flags)
 			cgrp_dfl_root.flags |= CGRP_ROOT_NS_DELEGATE;
 		else
 			cgrp_dfl_root.flags &= ~CGRP_ROOT_NS_DELEGATE;
-
-		if (root_flags & CGRP_GROUP_OOM)
-			cgrp_dfl_root.flags |= CGRP_GROUP_OOM;
-		else
-			cgrp_dfl_root.flags &= ~CGRP_GROUP_OOM;
 	}
 }
 
@@ -1763,8 +1755,6 @@ static int cgroup_show_options(struct seq_file *seq, struct kernfs_root *kf_root
 {
 	if (cgrp_dfl_root.flags & CGRP_ROOT_NS_DELEGATE)
 		seq_puts(seq, ",nsdelegate");
-	if (cgrp_dfl_root.flags & CGRP_GROUP_OOM)
-		seq_puts(seq, ",groupoom");
 	return 0;
 }
 
@@ -5921,8 +5911,7 @@ static struct kobj_attribute cgroup_delegate_attr = __ATTR_RO(delegate);
 static ssize_t features_show(struct kobject *kobj, struct kobj_attribute *attr,
 			     char *buf)
 {
-	return snprintf(buf, PAGE_SIZE, "nsdelegate\n"
-					"groupoom\n");
+	return snprintf(buf, PAGE_SIZE, "nsdelegate\n");
 }
 static struct kobj_attribute cgroup_features_attr = __ATTR_RO(features);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2798,14 +2798,14 @@ bool mem_cgroup_select_oom_victim(struct oom_control *oc)
 	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
 		return false;
 
-	if (!(cgrp_dfl_root.flags & CGRP_GROUP_OOM))
-		return false;
-
 	if (oc->memcg)
 		root = oc->memcg;
 	else
 		root = root_mem_cgroup;
 
+	if (root->oom_policy != MEMCG_OOM_POLICY_CGROUP)
+		return false;
+
 	select_victim_memcg(root, oc);
 
 	return oc->chosen_memcg;
@@ -5412,9 +5412,6 @@ static int memory_oom_group_show(struct seq_file *m, void *v)
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
 	bool oom_group = memcg->oom_group;
 
-	if (!(cgrp_dfl_root.flags & CGRP_GROUP_OOM))
-		return -ENOTSUPP;
-
 	seq_printf(m, "%d\n", oom_group);
 
 	return 0;
@@ -5428,9 +5425,6 @@ static ssize_t memory_oom_group_write(struct kernfs_open_file *of,
 	int oom_group;
 	int err;
 
-	if (!(cgrp_dfl_root.flags & CGRP_GROUP_OOM))
-		return -ENOTSUPP;
-
 	err = kstrtoint(strstrip(buf), 0, &oom_group);
 	if (err)
 		return err;
@@ -5541,6 +5535,9 @@ static int memory_oom_policy_show(struct seq_file *m, void *v)
 	enum memcg_oom_policy policy = READ_ONCE(memcg->oom_policy);
 
 	switch (policy) {
+	case MEMCG_OOM_POLICY_CGROUP:
+		seq_puts(m, "cgroup\n");
+		break;
 	case MEMCG_OOM_POLICY_NONE:
 	default:
 		seq_puts(m, "none\n");
@@ -5557,6 +5554,8 @@ static ssize_t memory_oom_policy_write(struct kernfs_open_file *of,
 	buf = strstrip(buf);
 	if (!memcmp("none", buf, min(sizeof("none")-1, nbytes)))
 		memcg->oom_policy = MEMCG_OOM_POLICY_NONE;
+	else if (!memcmp("cgroup", buf, min(sizeof("cgroup")-1, nbytes)))
+		memcg->oom_policy = MEMCG_OOM_POLICY_CGROUP;
 	else
 		ret = -EINVAL;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
