Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 25F166B0029
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 17:08:52 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x6so5766252pfx.16
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:08:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y192sor1409397pgd.184.2018.03.16.14.08.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Mar 2018 14:08:50 -0700 (PDT)
Date: Fri, 16 Mar 2018 14:08:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 1/6] mm, memcg: introduce per-memcg oom policy tunable
In-Reply-To: <alpine.DEB.2.20.1803161405410.209509@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.20.1803161406590.211123@chino.kir.corp.google.com>
References: <alpine.DEB.2.20.1803121755590.192200@chino.kir.corp.google.com> <alpine.DEB.2.20.1803151351140.55261@chino.kir.corp.google.com> <alpine.DEB.2.20.1803161405410.209509@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The cgroup aware oom killer is needlessly enforced for the entire system
by a mount option.  It's unnecessary to force the system into a single
oom policy: either cgroup aware, or the traditional process aware.

This patch introduces a memory.oom_policy tunable for all mem cgroups.
It is currently a no-op: it can only be set to "none", which is its
default policy.  It will be expanded in the next patch to define cgroup
aware oom killer behavior for its subtree.

This is an extensible interface that can be used to define cgroup aware
assessment of mem cgroup subtrees or the traditional process aware
assessment.

Reading memory.oom_policy will specify the list of available policies.

Another benefit of such an approach is that an admin can lock in a
certain policy for the system or for a mem cgroup subtree and can
delegate the policy decision to the user to determine if the kill should
originate from a subcontainer, as indivisible memory consumers
themselves, or selection should be done per process.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/cgroup-v2.txt | 11 +++++++++++
 include/linux/memcontrol.h  | 11 +++++++++++
 mm/memcontrol.c             | 35 +++++++++++++++++++++++++++++++++++
 3 files changed, 57 insertions(+)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -1065,6 +1065,17 @@ PAGE_SIZE multiple when read back.
 	If cgroup-aware OOM killer is not enabled, ENOTSUPP error
 	is returned on attempt to access the file.
 
+  memory.oom_policy
+
+	A read-write single string file which exists on all cgroups.  The
+	default value is "none".
+
+	If "none", the OOM killer will use the default policy to choose a
+	victim; that is, it will choose the single process with the largest
+	memory footprint adjusted by /proc/pid/oom_score_adj (see
+	Documentation/filesystems/proc.txt).  This is the same policy as if
+	memory cgroups were not even mounted.
+
   memory.events
 	A read-only flat-keyed file which exists on non-root cgroups.
 	The following entries are defined.  Unless specified
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -58,6 +58,14 @@ enum memcg_event_item {
 	MEMCG_NR_EVENTS,
 };
 
+enum memcg_oom_policy {
+	/*
+	 * No special oom policy, process selection is determined by
+	 * oom_badness()
+	 */
+	MEMCG_OOM_POLICY_NONE,
+};
+
 struct mem_cgroup_reclaim_cookie {
 	pg_data_t *pgdat;
 	int priority;
@@ -203,6 +211,9 @@ struct mem_cgroup {
 	/* OOM-Killer disable */
 	int		oom_kill_disable;
 
+	/* OOM policy for this subtree */
+	enum memcg_oom_policy oom_policy;
+
 	/*
 	 * Treat the sub-tree as an indivisible memory consumer,
 	 * kill all belonging tasks if the memory cgroup selected
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4430,6 +4430,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	if (parent) {
 		memcg->swappiness = mem_cgroup_swappiness(parent);
 		memcg->oom_kill_disable = parent->oom_kill_disable;
+		memcg->oom_policy = parent->oom_policy;
 	}
 	if (parent && parent->use_hierarchy) {
 		memcg->use_hierarchy = true;
@@ -5547,6 +5548,34 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	return 0;
 }
 
+static int memory_oom_policy_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	enum memcg_oom_policy policy = READ_ONCE(memcg->oom_policy);
+
+	switch (policy) {
+	case MEMCG_OOM_POLICY_NONE:
+	default:
+		seq_puts(m, "[none]\n");
+	};
+	return 0;
+}
+
+static ssize_t memory_oom_policy_write(struct kernfs_open_file *of,
+				       char *buf, size_t nbytes, loff_t off)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	ssize_t ret = nbytes;
+
+	buf = strstrip(buf);
+	if (!memcmp("none", buf, min(sizeof("none")-1, nbytes)))
+		memcg->oom_policy = MEMCG_OOM_POLICY_NONE;
+	else
+		ret = -EINVAL;
+
+	return ret;
+}
+
 static struct cftype memory_files[] = {
 	{
 		.name = "current",
@@ -5588,6 +5617,12 @@ static struct cftype memory_files[] = {
 		.flags = CFTYPE_NOT_ON_ROOT,
 		.seq_show = memory_stat_show,
 	},
+	{
+		.name = "oom_policy",
+		.flags = CFTYPE_NS_DELEGATABLE,
+		.seq_show = memory_oom_policy_show,
+		.write = memory_oom_policy_write,
+	},
 	{ }	/* terminate */
 };
 
