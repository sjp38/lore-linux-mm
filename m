Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CF2786B000C
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 20:58:00 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id i11so7391045pgq.10
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 17:58:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h2sor1949237pgs.309.2018.03.12.17.57.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Mar 2018 17:57:59 -0700 (PDT)
Date: Mon, 12 Mar 2018 17:57:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm v3 3/3] mm, memcg: add hierarchical usage oom policy
In-Reply-To: <alpine.DEB.2.20.1803121755590.192200@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.20.1803121757360.192200@chino.kir.corp.google.com>
References: <alpine.DEB.2.20.1803121755590.192200@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

One of the three significant concerns brought up about the cgroup aware
oom killer is that its decisionmaking is completely evaded by creating
subcontainers and attaching processes such that the ancestor's usage does
not exceed another cgroup on the system.

Consider the example from the previous patch where "memory" is set in
each mem cgroup's cgroup.controllers:

	mem cgroup	cgroup.procs
	==========	============
	/cg1		1 process consuming 250MB
	/cg2		3 processes consuming 100MB each
	/cg3/cg31	2 processes consuming 100MB each
	/cg3/cg32	2 processes consuming 100MB each

If memory.oom_policy is "cgroup", a process from /cg2 is chosen because it
is in the single indivisible memory consumer with the greatest usage.

The true usage of /cg3 is actually 400MB, but a process from /cg2 is
chosen because cgroups are compared individually rather than
hierarchically.

If a system is divided into two users, for example:

	mem cgroup	memory.max
	==========	==========
	/userA		250MB
	/userB		250MB

If /userA runs all processes attached to the local mem cgroup, whereas
/userB distributes their processes over a set of subcontainers under
/userB, /userA will be unfairly penalized.

There is incentive with cgroup v2 to distribute processes over a set of
subcontainers if those processes shall be constrained by other cgroup
controllers; this is a direct result of mandating a single, unified
hierarchy for cgroups.  A user may also reasonably do this for mem cgroup
control or statistics.  And, a user may do this to evade the cgroup-aware
oom killer selection logic.

This patch adds an oom policy, "tree", that accounts for hierarchical
usage when comparing cgroups and the cgroup aware oom killer is enabled by
an ancestor.  This allows administrators, for example, to require users in
their own top-level mem cgroup subtree to be accounted for with
hierarchical usage.  In other words, they can longer evade the oom killer
by using other controllers or subcontainers.

If an oom policy of "tree" is in place for a subtree, such as /cg3 above,
the hierarchical usage is used for comparisons with other cgroups if
either "cgroup" or "tree" is the oom policy of the oom mem cgroup.  Thus,
if /cg3/memory.oom_policy is "tree", one of the processes from /cg3's
subcontainers is chosen for oom kill.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/cgroup-v2.txt | 15 +++++++++++++--
 include/linux/memcontrol.h  |  5 +++++
 mm/memcontrol.c             | 14 ++++++++++----
 3 files changed, 28 insertions(+), 6 deletions(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -1080,6 +1080,10 @@ PAGE_SIZE multiple when read back.
 	memory consumers; that is, they will compare mem cgroup usage rather
 	than process memory footprint.  See the "OOM Killer" section below.
 
+	If "tree", the OOM killer will compare mem cgroups and its subtree
+	as a single indivisible memory consumer.  This policy cannot be set
+	on the root mem cgroup.  See the "OOM Killer" section below.
+
 	When an OOM condition occurs, the policy is dictated by the mem
 	cgroup that is OOM (the root mem cgroup for a system-wide OOM
 	condition).  If a descendant mem cgroup has a policy of "none", for
@@ -1087,6 +1091,10 @@ PAGE_SIZE multiple when read back.
 	the heuristic will still compare mem cgroups as indivisible memory
 	consumers.
 
+	When an OOM condition occurs in a mem cgroup with an OOM policy of
+	"cgroup" or "tree", the OOM killer will compare mem cgroups with
+	"cgroup" policy individually with "tree" policy subtrees.
+
   memory.events
 	A read-only flat-keyed file which exists on non-root cgroups.
 	The following entries are defined.  Unless specified
@@ -1310,6 +1318,9 @@ There are currently two available oom policies:
    subtree as an OOM victim and kill at least one process, depending on
    memory.oom_group, from it.
 
+ - "tree": choose the cgroup with the largest memory footprint considering
+   itself and its subtree and kill at least one process.
+
 When selecting a cgroup as a victim, the OOM killer will kill the process
 with the largest memory footprint.  A user can control this behavior by
 enabling the per-cgroup memory.oom_group option.  If set, it causes the
@@ -1323,8 +1334,8 @@ Please, note that memory charges are not migrating if tasks
 are moved between different memory cgroups. Moving tasks with
 significant memory footprint may affect OOM victim selection logic.
 If it's a case, please, consider creating a common ancestor for
-the source and destination memory cgroups and enabling oom_group
-on ancestor layer.
+the source and destination memory cgroups and setting a policy of "tree"
+and enabling oom_group on an ancestor layer.
 
 
 IO
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -69,6 +69,11 @@ enum memcg_oom_policy {
 	 * mem cgroup as an indivisible consumer
 	 */
 	MEMCG_OOM_POLICY_CGROUP,
+	/*
+	 * Tree cgroup usage for all descendant memcg groups, treating each mem
+	 * cgroup and its subtree as an indivisible consumer
+	 */
+	MEMCG_OOM_POLICY_TREE,
 };
 
 struct mem_cgroup_reclaim_cookie {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2726,7 +2726,7 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 	/*
 	 * The oom_score is calculated for leaf memory cgroups (including
 	 * the root memcg).
-	 * Non-leaf oom_group cgroups accumulating score of descendant
+	 * Cgroups with oom policy of "tree" accumulate the score of descendant
 	 * leaf memory cgroups.
 	 */
 	rcu_read_lock();
@@ -2735,10 +2735,11 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 
 		/*
 		 * We don't consider non-leaf non-oom_group memory cgroups
-		 * as OOM victims.
+		 * without the oom policy of "tree" as OOM victims.
 		 */
 		if (memcg_has_children(iter) && iter != root_mem_cgroup &&
-		    !mem_cgroup_oom_group(iter))
+		    !mem_cgroup_oom_group(iter) &&
+		    iter->oom_policy != MEMCG_OOM_POLICY_TREE)
 			continue;
 
 		/*
@@ -2801,7 +2802,7 @@ bool mem_cgroup_select_oom_victim(struct oom_control *oc)
 	else
 		root = root_mem_cgroup;
 
-	if (root->oom_policy != MEMCG_OOM_POLICY_CGROUP)
+	if (root->oom_policy == MEMCG_OOM_POLICY_NONE)
 		return false;
 
 	select_victim_memcg(root, oc);
@@ -5536,6 +5537,9 @@ static int memory_oom_policy_show(struct seq_file *m, void *v)
 	case MEMCG_OOM_POLICY_CGROUP:
 		seq_puts(m, "cgroup\n");
 		break;
+	case MEMCG_OOM_POLICY_TREE:
+		seq_puts(m, "tree\n");
+		break;
 	case MEMCG_OOM_POLICY_NONE:
 	default:
 		seq_puts(m, "none\n");
@@ -5554,6 +5558,8 @@ static ssize_t memory_oom_policy_write(struct kernfs_open_file *of,
 		memcg->oom_policy = MEMCG_OOM_POLICY_NONE;
 	else if (!memcmp("cgroup", buf, min(sizeof("cgroup")-1, nbytes)))
 		memcg->oom_policy = MEMCG_OOM_POLICY_CGROUP;
+	else if (!memcmp("tree", buf, min(sizeof("tree")-1, nbytes)))
+		memcg->oom_policy = MEMCG_OOM_POLICY_TREE;
 	else
 		ret = -EINVAL;
 
