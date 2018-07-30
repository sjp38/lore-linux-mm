Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BA5D76B026A
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 14:01:51 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s18-v6so2658720edr.15
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 11:01:51 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id b15-v6si4944191edm.391.2018.07.30.11.01.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 11:01:50 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH 3/3] mm, oom: introduce memory.oom.group
Date: Mon, 30 Jul 2018 11:01:00 -0700
Message-ID: <20180730180100.25079-4-guro@fb.com>
In-Reply-To: <20180730180100.25079-1-guro@fb.com>
References: <20180730180100.25079-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>

For some workloads an intervention from the OOM killer
can be painful. Killing a random task can bring
the workload into an inconsistent state.

Historically, there are two common solutions for this
problem:
1) enabling panic_on_oom,
2) using a userspace daemon to monitor OOMs and kill
   all outstanding processes.

Both approaches have their downsides:
rebooting on each OOM is an obvious waste of capacity,
and handling all in userspace is tricky and requires
a userspace agent, which will monitor all cgroups
for OOMs.

In most cases an in-kernel after-OOM cleaning-up
mechanism can eliminate the necessity of enabling
panic_on_oom. Also, it can simplify the cgroup
management for userspace applications.

This commit introduces a new knob for cgroup v2 memory
controller: memory.oom.group. The knob determines
whether the cgroup should be treated as a single
unit by the OOM killer. If set, the cgroup and its
descendants are killed together or not at all.

To determine which cgroup has to be killed, we do
traverse the cgroup hierarchy from the victim task's
cgroup up to the OOMing cgroup (or root) and looking
for the highest-level cgroup  with memory.oom.group set.

Tasks with the OOM protection (oom_score_adj set to -1000)
are treated as an exception and are never killed.

This patch doesn't change the OOM victim selection algorithm.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Tejun Heo <tj@kernel.org>
---
 Documentation/admin-guide/cgroup-v2.rst | 16 +++++++
 include/linux/memcontrol.h              | 13 +++++
 mm/memcontrol.c                         | 84 +++++++++++++++++++++++++++++++++
 mm/oom_kill.c                           | 29 ++++++++++++
 4 files changed, 142 insertions(+)

diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/admin-guide/cgroup-v2.rst
index 8a2c52d5c53b..f11de1b78cfc 100644
--- a/Documentation/admin-guide/cgroup-v2.rst
+++ b/Documentation/admin-guide/cgroup-v2.rst
@@ -1069,6 +1069,22 @@ PAGE_SIZE multiple when read back.
 	high limit is used and monitored properly, this limit's
 	utility is limited to providing the final safety net.
 
+  memory.oom.group
+	A read-write single value file which exists on non-root
+	cgroups.  The default value is "0".
+
+	Determines whether the cgroup should be treated as a single
+	unit by the OOM killer. If set, the cgroup and its descendants
+	are killed together or not at all. This can be used to avoid
+	partial kills to guarantee workload integrity.
+
+	Tasks with the OOM protection (oom_score_adj set to -1000)
+	are treated as an exception and are never killed.
+
+	If the OOM killer is invoked in a cgroup, it's not going
+	to kill any tasks outside of this cgroup, regardless
+	memory.oom.group values of ancestor cgroups.
+
   memory.events
 	A read-only flat-keyed file which exists on non-root cgroups.
 	The following entries are defined.  Unless specified
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index e53e00cdbe3f..05c9c867a3ab 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -213,6 +213,11 @@ struct mem_cgroup {
 	 */
 	bool use_hierarchy;
 
+	/*
+	 * Should the OOM killer kill all belonging tasks, had it kill one?
+	 */
+	bool oom_group;
+
 	/* protected by memcg_oom_lock */
 	bool		oom_lock;
 	int		under_oom;
@@ -517,6 +522,8 @@ static inline bool task_in_memcg_oom(struct task_struct *p)
 }
 
 bool mem_cgroup_oom_synchronize(bool wait);
+struct mem_cgroup *mem_cgroup_get_oom_group(struct task_struct *victim,
+					    struct mem_cgroup *oom_domain);
 
 #ifdef CONFIG_MEMCG_SWAP
 extern int do_swap_account;
@@ -951,6 +958,12 @@ static inline bool mem_cgroup_oom_synchronize(bool wait)
 	return false;
 }
 
+static inline struct mem_cgroup *mem_cgroup_get_oom_group(
+	struct task_struct *victim, struct mem_cgroup *oom_domain)
+{
+	return NULL;
+}
+
 static inline unsigned long memcg_page_state(struct mem_cgroup *memcg,
 					     int idx)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8c0280b3143e..ade832571091 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1577,6 +1577,53 @@ bool mem_cgroup_oom_synchronize(bool handle)
 	return true;
 }
 
+/**
+ * mem_cgroup_get_oom_group - get a memory cgroup to clean up after OOM
+ * @victim: task to be killed by the OOM killer
+ * @oom_domain: memcg in case of memcg OOM, NULL in case of system-wide OOM
+ *
+ * Returns a pointer to a memory cgroup, which has to be cleaned up
+ * by killing all belonging OOM-killable tasks.
+ */
+struct mem_cgroup *mem_cgroup_get_oom_group(struct task_struct *victim,
+					    struct mem_cgroup *oom_domain)
+{
+	struct mem_cgroup *oom_group = NULL;
+	struct mem_cgroup *memcg;
+
+	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
+		return NULL;
+
+	if (!oom_domain)
+		oom_domain = root_mem_cgroup;
+
+	rcu_read_lock();
+
+	memcg = mem_cgroup_from_task(victim);
+	if (!memcg || memcg == root_mem_cgroup)
+		goto out;
+
+	/*
+	 * Traverse the memory cgroup hierarchy from the victim task's
+	 * cgroup up to the OOMing cgroup (or root) to find the
+	 * highest-level memory cgroup with oom.group set.
+	 */
+	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
+		if (memcg->oom_group)
+			oom_group = memcg;
+
+		if (memcg == oom_domain)
+			break;
+	}
+
+	if (oom_group)
+		css_get(&oom_group->css);
+out:
+	rcu_read_unlock();
+
+	return oom_group;
+}
+
 /**
  * lock_page_memcg - lock a page->mem_cgroup binding
  * @page: the page
@@ -5328,6 +5375,37 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	return 0;
 }
 
+static int memory_oom_group_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+
+	seq_printf(m, "%d\n", memcg->oom_group);
+
+	return 0;
+}
+
+static ssize_t memory_oom_group_write(struct kernfs_open_file *of,
+				      char *buf, size_t nbytes, loff_t off)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	int ret, oom_group;
+
+	buf = strstrip(buf);
+	if (!buf)
+		return -EINVAL;
+
+	ret = kstrtoint(buf, 0, &oom_group);
+	if (ret)
+		return ret;
+
+	if (oom_group != 0 && oom_group != 1)
+		return -EINVAL;
+
+	memcg->oom_group = oom_group;
+
+	return nbytes;
+}
+
 static struct cftype memory_files[] = {
 	{
 		.name = "current",
@@ -5369,6 +5447,12 @@ static struct cftype memory_files[] = {
 		.flags = CFTYPE_NOT_ON_ROOT,
 		.seq_show = memory_stat_show,
 	},
+	{
+		.name = "oom.group",
+		.flags = CFTYPE_NOT_ON_ROOT | CFTYPE_NS_DELEGATABLE,
+		.seq_show = memory_oom_group_show,
+		.write = memory_oom_group_write,
+	},
 	{ }	/* terminate */
 };
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8bded6b3205b..08f30ed5abed 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -914,6 +914,19 @@ static void __oom_kill_process(struct task_struct *victim)
 }
 #undef K
 
+/*
+ * Kill provided task unless it's secured by setting
+ * oom_score_adj to OOM_SCORE_ADJ_MIN.
+ */
+static int oom_kill_memcg_member(struct task_struct *task, void *unused)
+{
+	if (task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
+		get_task_struct(task);
+		__oom_kill_process(task);
+	}
+	return 0;
+}
+
 static void oom_kill_process(struct oom_control *oc, const char *message)
 {
 	struct task_struct *p = oc->chosen;
@@ -921,6 +934,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	struct task_struct *victim = p;
 	struct task_struct *child;
 	struct task_struct *t;
+	struct mem_cgroup *oom_group;
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
@@ -974,7 +988,22 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	}
 	read_unlock(&tasklist_lock);
 
+	/*
+	 * Do we need to kill the entire memory cgroup?
+	 * Or even one of the ancestor memory cgroups?
+	 * Check this out before killing the victim task.
+	 */
+	oom_group = mem_cgroup_get_oom_group(victim, oc->memcg);
+
 	__oom_kill_process(victim);
+
+	/*
+	 * If necessary, kill all tasks in the selected memory cgroup.
+	 */
+	if (oom_group) {
+		mem_cgroup_scan_tasks(oom_group, oom_kill_memcg_member, NULL);
+		mem_cgroup_put(oom_group);
+	}
 }
 
 /*
-- 
2.14.4
