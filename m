Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9A7776B0026
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 17:53:52 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m198so4810762pga.4
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 14:53:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a64-v6sor636697pla.2.2018.03.22.14.53.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Mar 2018 14:53:51 -0700 (PDT)
Date: Thu, 22 Mar 2018 14:53:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2 -mm 2/6] mm, memcg: replace cgroup aware oom killer mount
 option with tunable
In-Reply-To: <alpine.DEB.2.20.1803221451370.17056@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.20.1803221452210.17056@chino.kir.corp.google.com>
References: <alpine.DEB.2.20.1803121755590.192200@chino.kir.corp.google.com> <alpine.DEB.2.20.1803151351140.55261@chino.kir.corp.google.com> <alpine.DEB.2.20.1803161405410.209509@chino.kir.corp.google.com>
 <alpine.DEB.2.20.1803221451370.17056@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Now that each mem cgroup on the system has a memory.oom_policy tunable to
specify oom kill selection behavior, remove the needless "groupoom" mount
option that requires (1) the entire system to be forced, perhaps
unnecessarily, perhaps unexpectedly, into a single oom policy that
differs from the traditional per process selection, and (2) a remount to
change.

Instead of enabling the cgroup aware oom killer with the "groupoom" mount
option, set the mem cgroup subtree's memory.oom_policy to "cgroup".

The heuristic used to select a process or cgroup to kill from is
controlled by the oom mem cgroup's memory.oom_policy.  This means that if
a descendant mem cgroup has an oom policy of "none", for example, and an
oom condition originates in an ancestor with an oom policy of "cgroup",
the selection logic will treat all descendant cgroups as indivisible
memory consumers.

For example, consider an example where each mem cgroup has "memory" set
in cgroup.controllers:

	mem cgroup	cgroup.procs
	==========	============
	/cg1		1 process consuming 250MB
	/cg2		3 processes consuming 100MB each
	/cg3/cg31	2 processes consuming 100MB each
	/cg3/cg32	2 processes consuming 100MB each

If the root mem cgroup's memory.oom_policy is "none", the process from
/cg1 is chosen as the victim.  If memory.oom_policy is "cgroup", a process
from /cg2 is chosen because it is in the single indivisible memory
consumer with the greatest usage.  This policy of "cgroup" is identical to
to the current "groupoom" mount option, now removed.

Note that /cg3 is not the chosen victim when the oom mem cgroup policy is
"cgroup" because cgroups are treated individually without regard to
hierarchical /cg3/memory.current usage.  This will be addressed in a
follow-up patch.

This has the added benefit of allowing descendant cgroups to control their
own oom policies if they have memory.oom_policy file permissions without
being restricted to the system-wide policy.  In the above example, /cg2
and /cg3 can be either "none" or "cgroup" with the same results: the
selection heuristic depends only on the policy of the oom mem cgroup.  If
/cg2 or /cg3 themselves are oom, however, the policy is controlled by
their own oom policies, either process aware or cgroup aware.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/cgroup-v2.txt | 78 +++++++++++++++++++------------------
 include/linux/cgroup-defs.h |  5 ---
 include/linux/memcontrol.h  |  5 +++
 kernel/cgroup/cgroup.c      | 13 +------
 mm/memcontrol.c             | 19 +++++----
 5 files changed, 56 insertions(+), 64 deletions(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -1076,6 +1076,17 @@ PAGE_SIZE multiple when read back.
 	Documentation/filesystems/proc.txt).  This is the same policy as if
 	memory cgroups were not even mounted.
 
+	If "cgroup", the OOM killer will compare mem cgroups as indivisible
+	memory consumers; that is, they will compare mem cgroup usage rather
+	than process memory footprint.  See the "OOM Killer" section below.
+
+	When an OOM condition occurs, the policy is dictated by the mem
+	cgroup that is OOM (the root mem cgroup for a system-wide OOM
+	condition).  If a descendant mem cgroup has a policy of "none", for
+	example, for an OOM condition in a mem cgroup with policy "cgroup",
+	the heuristic will still compare mem cgroups as indivisible memory
+	consumers.
+
   memory.events
 	A read-only flat-keyed file which exists on non-root cgroups.
 	The following entries are defined.  Unless specified
@@ -1282,43 +1293,36 @@ belonging to the affected files to ensure correct memory ownership.
 OOM Killer
 ~~~~~~~~~~
 
-Cgroup v2 memory controller implements a cgroup-aware OOM killer.
-It means that it treats cgroups as first class OOM entities.
-
-Cgroup-aware OOM logic is turned off by default and requires
-passing the "groupoom" option on mounting cgroupfs. It can also
-by remounting cgroupfs with the following command::
-
-  # mount -o remount,groupoom $MOUNT_POINT
-
-Under OOM conditions the memory controller tries to make the best
-choice of a victim, looking for a memory cgroup with the largest
-memory footprint, considering leaf cgroups and cgroups with the
-memory.oom_group option set, which are considered to be an indivisible
-memory consumers.
-
-By default, OOM killer will kill the biggest task in the selected
-memory cgroup. A user can change this behavior by enabling
-the per-cgroup memory.oom_group option. If set, it causes
-the OOM killer to kill all processes attached to the cgroup,
-except processes with oom_score_adj set to -1000.
-
-This affects both system- and cgroup-wide OOMs. For a cgroup-wide OOM
-the memory controller considers only cgroups belonging to the sub-tree
-of the OOM'ing cgroup.
-
-Leaf cgroups and cgroups with oom_group option set are compared based
-on their cumulative memory usage. The root cgroup is treated as a
-leaf memory cgroup as well, so it is compared with other leaf memory
-cgroups. Due to internal implementation restrictions the size of
-the root cgroup is the cumulative sum of oom_badness of all its tasks
-(in other words oom_score_adj of each task is obeyed). Relying on
-oom_score_adj (apart from OOM_SCORE_ADJ_MIN) can lead to over- or
-underestimation of the root cgroup consumption and it is therefore
-discouraged. This might change in the future, however.
-
-If there are no cgroups with the enabled memory controller,
-the OOM killer is using the "traditional" process-based approach.
+Cgroup v2 memory controller implements an optional cgroup-aware out of
+memory killer, which treats cgroups as indivisible OOM entities.
+
+This policy is controlled by memory.oom_policy.  When a memory cgroup is
+out of memory, its memory.oom_policy will dictate how the OOM killer will
+select a process, or cgroup, to kill.  Likewise, when the system is OOM,
+the policy is dictated by the root mem cgroup.
+
+There are currently two available oom policies:
+
+ - "none": default, choose the largest single memory hogging process to
+   oom kill, as traditionally the OOM killer has always done.
+
+ - "cgroup": choose the cgroup with the largest memory footprint from the
+   subtree as an OOM victim and kill at least one process, depending on
+   memory.oom_group, from it.
+
+When selecting a cgroup as a victim, the OOM killer will kill the process
+with the largest memory footprint.  A user can control this behavior by
+enabling the per-cgroup memory.oom_group option.  If set, it causes the
+OOM killer to kill all processes attached to the cgroup, except processes
+with /proc/pid/oom_score_adj set to -1000 (oom disabled).
+
+The root cgroup is treated as a leaf memory cgroup as well, so it is
+compared with other leaf memory cgroups. Due to internal implementation
+restrictions the size of the root cgroup is the cumulative sum of
+oom_badness of all its tasks (in other words oom_score_adj of each task
+is obeyed). Relying on oom_score_adj (apart from OOM_SCORE_ADJ_MIN) can
+lead to over- or underestimation of the root cgroup consumption and it is
+therefore discouraged. This might change in the future, however.
 
 Please, note that memory charges are not migrating if tasks
 are moved between different memory cgroups. Moving tasks with
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
 
@@ -5925,8 +5915,7 @@ static struct kobj_attribute cgroup_delegate_attr = __ATTR_RO(delegate);
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
@@ -2811,14 +2811,14 @@ bool mem_cgroup_select_oom_victim(struct oom_control *oc)
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
@@ -5425,9 +5425,6 @@ static int memory_oom_group_show(struct seq_file *m, void *v)
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
 	bool oom_group = memcg->oom_group;
 
-	if (!(cgrp_dfl_root.flags & CGRP_GROUP_OOM))
-		return -ENOTSUPP;
-
 	seq_printf(m, "%d\n", oom_group);
 
 	return 0;
@@ -5441,9 +5438,6 @@ static ssize_t memory_oom_group_write(struct kernfs_open_file *of,
 	int oom_group;
 	int err;
 
-	if (!(cgrp_dfl_root.flags & CGRP_GROUP_OOM))
-		return -ENOTSUPP;
-
 	err = kstrtoint(strstrip(buf), 0, &oom_group);
 	if (err)
 		return err;
@@ -5554,9 +5548,12 @@ static int memory_oom_policy_show(struct seq_file *m, void *v)
 	enum memcg_oom_policy policy = READ_ONCE(memcg->oom_policy);
 
 	switch (policy) {
+	case MEMCG_OOM_POLICY_CGROUP:
+		seq_puts(m, "none [cgroup]\n");
+		break;
 	case MEMCG_OOM_POLICY_NONE:
 	default:
-		seq_puts(m, "[none]\n");
+		seq_puts(m, "[none] cgroup\n");
 	};
 	return 0;
 }
@@ -5570,6 +5567,8 @@ static ssize_t memory_oom_policy_write(struct kernfs_open_file *of,
 	buf = strstrip(buf);
 	if (!memcmp("none", buf, min(sizeof("none")-1, nbytes)))
 		memcg->oom_policy = MEMCG_OOM_POLICY_NONE;
+	else if (!memcmp("cgroup", buf, min(sizeof("cgroup")-1, nbytes)))
+		memcg->oom_policy = MEMCG_OOM_POLICY_CGROUP;
 	else
 		ret = -EINVAL;
 
