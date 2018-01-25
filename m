Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1B0D86B000E
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 18:53:54 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id t192so8382241iof.6
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 15:53:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t10sor1418810itf.29.2018.01.25.15.53.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jan 2018 15:53:53 -0800 (PST)
Date: Thu, 25 Jan 2018 15:53:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm v2 3/3] mm, memcg: add hierarchical usage oom policy
In-Reply-To: <alpine.DEB.2.10.1801251552320.161808@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1801251553210.161808@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com> <alpine.DEB.2.10.1801251552320.161808@chino.kir.corp.google.com>
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
 include/linux/memcontrol.h  |  5 +++++
 mm/memcontrol.c             | 12 +++++++++---
 3 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -1078,6 +1078,11 @@ PAGE_SIZE multiple when read back.
 	memory consumers; that is, they will compare mem cgroup usage rather
 	than process memory footprint.  See the "OOM Killer" section.
 
+	If "tree", the OOM killer will compare mem cgroups and its subtree
+	as indivisible memory consumers when selecting a hierarchy.  This
+	policy cannot be set on the root mem cgroup.  See the "OOM Killer"
+	section.
+
   memory.events
 	A read-only flat-keyed file which exists on non-root cgroups.
 	The following entries are defined.  Unless specified
@@ -1301,6 +1306,9 @@ There are currently two available oom policies:
    subtree as an OOM victim and kill at least one process, depending on
    memory.oom_group, from it.
 
+ - "tree": choose the cgroup with the largest memory footprint considering
+   itself and its subtree and kill at least one process.
+
 When selecting a cgroup as a victim, the OOM killer will kill the process
 with the largest memory footprint.  A user can control this behavior by
 enabling the per-cgroup memory.oom_group option.  If set, it causes the
@@ -1314,8 +1322,8 @@ Please, note that memory charges are not migrating if tasks
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
@@ -2728,7 +2728,7 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 	/*
 	 * The oom_score is calculated for leaf memory cgroups (including
 	 * the root memcg).
-	 * Non-leaf oom_group cgroups accumulating score of descendant
+	 * Cgroups with oom policy of "tree" accumulate the score of descendant
 	 * leaf memory cgroups.
 	 */
 	rcu_read_lock();
@@ -2737,10 +2737,11 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 
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
@@ -5538,6 +5539,9 @@ static int memory_oom_policy_show(struct seq_file *m, void *v)
 	case MEMCG_OOM_POLICY_CGROUP:
 		seq_puts(m, "cgroup\n");
 		break;
+	case MEMCG_OOM_POLICY_TREE:
+		seq_puts(m, "tree\n");
+		break;
 	case MEMCG_OOM_POLICY_NONE:
 	default:
 		seq_puts(m, "none\n");
@@ -5556,6 +5560,8 @@ static ssize_t memory_oom_policy_write(struct kernfs_open_file *of,
 		memcg->oom_policy = MEMCG_OOM_POLICY_NONE;
 	else if (!memcmp("cgroup", buf, min(sizeof("cgroup")-1, nbytes)))
 		memcg->oom_policy = MEMCG_OOM_POLICY_CGROUP;
+	else if (!memcmp("tree", buf, min(sizeof("tree")-1, nbytes)))
+		memcg->oom_policy = MEMCG_OOM_POLICY_TREE;
 	else
 		ret = -EINVAL;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
