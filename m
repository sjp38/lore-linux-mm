Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A3C616B0285
	for <linux-mm@kvack.org>; Thu, 24 May 2018 22:00:21 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r9-v6so1156794pgp.12
        for <linux-mm@kvack.org>; Thu, 24 May 2018 19:00:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n20-v6sor8640062pff.33.2018.05.24.19.00.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 May 2018 19:00:20 -0700 (PDT)
From: ufo19890607 <ufo19890607@gmail.com>
Subject: [PATCH v5] Refactor part of the oom report in dump_header
Date: Fri, 25 May 2018 03:00:13 +0100
Message-Id: <1527213613-7922-1-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, guro@fb.com, yang.s@alibaba-inc.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian <yuzhoujian@didichuxing.com>

From: yuzhoujian <yuzhoujian@didichuxing.com>

The dump_header does not print the memcg's name when the system
oom happened, so users cannot locate the certain container which
contains the task that has been killed by the oom killer.

I follow the advices of David Rientjes and Michal Hocko, and refactor
part of the oom report in a backwards compatible way. After this patch,
users can get the memcg's path from the oom report and check the certain
container more quickly.

Below is the part of the oom report in the dmesg
...
[  142.158316] panic cpuset=/ mems_allowed=0-1
[  142.158983] CPU: 15 PID: 8682 Comm: panic Not tainted 4.17.0-rc6+ #13
[  142.159659] Hardware name: Inspur SA5212M4/YZMB-00370-107, BIOS 4.1.10 11/14/2016
[  142.160342] Call Trace:
[  142.161037]  dump_stack+0x78/0xb3
[  142.161734]  dump_header+0x7d/0x334
[  142.162433]  oom_kill_process+0x228/0x490
[  142.163126]  ? oom_badness+0x2a/0x130
[  142.163821]  out_of_memory+0xf0/0x280
[  142.164532]  __alloc_pages_slowpath+0x711/0xa07
[  142.165241]  __alloc_pages_nodemask+0x23f/0x260
[  142.165947]  alloc_pages_vma+0x73/0x180
[  142.166665]  do_anonymous_page+0xed/0x4e0
[  142.167388]  __handle_mm_fault+0xbd2/0xe00
[  142.168114]  handle_mm_fault+0x116/0x250
[  142.168841]  __do_page_fault+0x233/0x4d0
[  142.169567]  do_page_fault+0x32/0x130
[  142.170303]  ? page_fault+0x8/0x30
[  142.171036]  page_fault+0x1e/0x30
[  142.171764] RIP: 0033:0x7f403000a860
[  142.172517] RSP: 002b:00007ffc9f745c28 EFLAGS: 00010206
[  142.173268] RAX: 00007f3f6fd7d000 RBX: 0000000000000000 RCX: 00007f3f7f5cd000
[  142.174040] RDX: 00007f3fafd7d000 RSI: 0000000000000000 RDI: 00007f3f6fd7d000
[  142.174806] RBP: 00007ffc9f745c50 R08: ffffffffffffffff R09: 0000000000000000
[  142.175623] R10: 0000000000000022 R11: 0000000000000246 R12: 0000000000400490
[  142.176542] R13: 00007ffc9f745d30 R14: 0000000000000000 R15: 0000000000000000
[  142.177709] oom-kill: constrain=CONSTRAINT_NONE nodemask=(null) origin_memcg= kill_memcg=/test/test1/test2 task=panic pid= 8622 uid=    0
...

Changes since v4:
- rename the helper's name to mem_cgroup_print_oom_context.
- rename the mem_cgroup_print_oom_info to mem_cgroup_print_oom_meminfo.
- add the constrain info in the dump_header.

Changes since v3:
- rename the helper's name to mem_cgroup_print_oom_memcg_name.
- add the rcu lock held to the helper.
- remove the print info of memcg's name in mem_cgroup_print_oom_info.

Changes since v2:
- add the mem_cgroup_print_memcg_name helper to print the memcg's
    name which contains the task that will be killed by the oom-killer.

Changes since v1:
- replace adding mem_cgroup_print_oom_info with printing the memcg's
    name only.

Signed-off-by: yuzhoujian <yuzhoujian@didichuxing.com>
---
 include/linux/memcontrol.h | 12 ++++++++++--
 mm/memcontrol.c            | 42 ++++++++++++++++++++++++------------------
 mm/oom_kill.c              | 22 +++++++++++++++++++++-
 3 files changed, 55 insertions(+), 21 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index d99b71bc2c66..4c92bcad1ac9 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -464,9 +464,11 @@ void mem_cgroup_handle_over_high(void);
 
 unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg);
 
-void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
+void mem_cgroup_print_oom_context(struct mem_cgroup *memcg,
 				struct task_struct *p);
 
+void mem_cgroup_print_oom_meminfo(struct mem_cgroup *memcg);
+
 static inline void mem_cgroup_oom_enable(void)
 {
 	WARN_ON(current->memcg_may_oom);
@@ -859,7 +861,13 @@ static inline unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
 }
 
 static inline void
-mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
+mem_cgroup_print_oom_context(struct mem_cgroup *memcg,
+					struct task_struct *p)
+{
+}
+
+static inline void
+mem_cgroup_print_oom_meminfo(struct mem_cgroup *memcg)
 {
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2bd3df3d101a..392a046cf18a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1118,33 +1118,39 @@ static const char *const memcg1_stat_names[] = {
 };
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
+
 /**
- * mem_cgroup_print_oom_info: Print OOM information relevant to memory controller.
- * @memcg: The memory cgroup that went over limit
- * @p: Task that is going to be killed
+ * mem_cgroup_print_oom_context: Print OOM context information including allocation
+ * constraint, nodemask, orgin memcg that has reached its limit, kill memcg that
+ * contains the killed process, killed process's command, pid and pid.
  *
- * NOTE: @memcg and @p's mem_cgroup can be different when hierarchy is
- * enabled
+ * @oc: pointer to struct oom_control
+ * @p: Task that is going to be killed
  */
-void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
+void mem_cgroup_print_oom_context(struct mem_cgroup *memcg, struct task_struct *p)
 {
-	struct mem_cgroup *iter;
-	unsigned int i;
-
 	rcu_read_lock();
-
+	pr_cont("origin_memcg=");
+	if (memcg)
+		pr_cont_cgroup_path(memcg->css.cgroup);
 	if (p) {
-		pr_info("Task in ");
+		pr_cont(" kill_memcg=");
 		pr_cont_cgroup_path(task_cgroup(p, memory_cgrp_id));
-		pr_cont(" killed as a result of limit of ");
-	} else {
-		pr_info("Memory limit reached of cgroup ");
+		pr_cont(" task=%s pid=%5d uid=%5d\n", p->comm, p->pid,
+			from_kuid(&init_user_ns, task_uid(p)));
 	}
-
-	pr_cont_cgroup_path(memcg->css.cgroup);
-	pr_cont("\n");
-
 	rcu_read_unlock();
+}
+
+/**
+ * mem_cgroup_print_oom_meminfo: Print OOM memory information relevant to
+ * memory controller.
+ * @memcg: The memory cgroup that went over limit
+ */
+void mem_cgroup_print_oom_meminfo(struct mem_cgroup *memcg)
+{
+	struct mem_cgroup *iter;
+	unsigned int i;
 
 	pr_info("memory: usage %llukB, limit %llukB, failcnt %lu\n",
 		K((u64)page_counter_read(&memcg->memory)),
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8ba6cb88cf58..2d00ab084e6f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -421,6 +421,8 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 
 static void dump_header(struct oom_control *oc, struct task_struct *p)
 {
+	enum oom_constraint constraint = constrained_alloc(oc);
+
 	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=%*pbl, order=%d, oom_score_adj=%hd\n",
 		current->comm, oc->gfp_mask, &oc->gfp_mask,
 		nodemask_pr_args(oc->nodemask), oc->order,
@@ -430,8 +432,26 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 
 	cpuset_print_current_mems_allowed();
 	dump_stack();
+	pr_info("oom-kill: constrain=CONSTRAINT_");
+	switch (constraint) {
+	case CONSTRAINT_NONE:
+		pr_cont("NONE ");
+		break;
+	case CONSTRAINT_CPUSET:
+		pr_cont("CPUSET ");
+		break;
+	case CONSTRAINT_MEMORY_POLICY:
+		pr_cont("MEMORY_POLICY ");
+		break;
+	default:
+		pr_cont("MEMCG ");
+		break;
+	}
+	pr_cont("nodemask=%*pbl ", nodemask_pr_args(oc->nodemask));
+	mem_cgroup_print_oom_context(oc->memcg, p);
+	pr_cont("\n");
 	if (is_memcg_oom(oc))
-		mem_cgroup_print_oom_info(oc->memcg, p);
+		mem_cgroup_print_oom_meminfo(oc->memcg);
 	else {
 		show_mem(SHOW_MEM_FILTER_NODES, oc->nodemask);
 		if (is_dump_unreclaim_slabs())
-- 
2.14.1
