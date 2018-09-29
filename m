Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9E2D38E0001
	for <linux-mm@kvack.org>; Sat, 29 Sep 2018 09:06:55 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id f13-v6so9977872pgs.15
        for <linux-mm@kvack.org>; Sat, 29 Sep 2018 06:06:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j30-v6sor16785pgb.259.2018.09.29.06.06.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 29 Sep 2018 06:06:54 -0700 (PDT)
From: ufo19890607@gmail.com
Subject: [PATCH v15 2/2] Add oom victim's memcg to the oom context information
Date: Sat, 29 Sep 2018 21:06:27 +0800
Message-Id: <1538226387-16600-2-git-send-email-ufo19890607@gmail.com>
In-Reply-To: <1538226387-16600-1-git-send-email-ufo19890607@gmail.com>
References: <1538226387-16600-1-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian@didichuxing.com

From: yuzhoujian <yuzhoujian@didichuxing.com>

The current oom report doesn't display victim's memcg context during the
global OOM situation. While this information is not strictly needed, it
can be really helpful for containerized environments to locate which
container has lost a process. Now that we have a single line for the oom
context, we can trivially add both the oom memcg (this can be either
global_oom or a specific memcg which hits its hard limits) and task_memcg
which is the victim's memcg.

Below is the single line output in the oom report after this patch.
- global oom context information:
oom-kill:constraint=<constraint>,nodemask=<nodemask>,cpuset=<cpuset>,mems_allowed=<mems_allowed>,global_oom,task_memcg=<memcg>,task=<comm>,pid=<pid>,uid=<uid>
- memcg oom context information:
oom-kill:constraint=<constraint>,nodemask=<nodemask>,cpuset=<cpuset>,mems_allowed=<mems_allowed>,oom_memcg=<memcg>,task_memcg=<memcg>,task=<comm>,pid=<pid>,uid=<uid>

Signed-off-by: yuzhoujian <yuzhoujian@didichuxing.com>
---
 include/linux/memcontrol.h | 11 +++++++++--
 mm/memcontrol.c            | 32 ++++++++++++++++++++------------
 mm/oom_kill.c              |  3 ++-
 3 files changed, 31 insertions(+), 15 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 652f602..3adf70a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -526,9 +526,11 @@ unsigned long mem_cgroup_get_zone_lru_size(struct lruvec *lruvec,
 
 unsigned long mem_cgroup_get_max(struct mem_cgroup *memcg);
 
-void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
+void mem_cgroup_print_oom_context(struct mem_cgroup *memcg,
 				struct task_struct *p);
 
+void mem_cgroup_print_oom_meminfo(struct mem_cgroup *memcg);
+
 static inline void mem_cgroup_enter_user_fault(void)
 {
 	WARN_ON(current->in_user_fault);
@@ -970,7 +972,12 @@ static inline unsigned long mem_cgroup_get_max(struct mem_cgroup *memcg)
 }
 
 static inline void
-mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
+mem_cgroup_print_oom_context(struct mem_cgroup *memcg, struct task_struct *p)
+{
+}
+
+static inline void
+mem_cgroup_print_oom_meminfo(struct mem_cgroup *memcg)
 {
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e79cb59..a7b4ada 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1293,32 +1293,40 @@ static bool mem_cgroup_wait_acct_move(struct mem_cgroup *memcg)
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
 /**
- * mem_cgroup_print_oom_info: Print OOM information relevant to memory controller.
+ * mem_cgroup_print_oom_context: Print OOM information relevant to
+ * memory controller.
  * @memcg: The memory cgroup that went over limit
  * @p: Task that is going to be killed
  *
  * NOTE: @memcg and @p's mem_cgroup can be different when hierarchy is
  * enabled
  */
-void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
+void mem_cgroup_print_oom_context(struct mem_cgroup *memcg, struct task_struct *p)
 {
-	struct mem_cgroup *iter;
-	unsigned int i;
-
 	rcu_read_lock();
 
+	if (memcg) {
+		pr_cont(",oom_memcg=");
+		pr_cont_cgroup_path(memcg->css.cgroup);
+	} else
+		pr_cont(",global_oom");
 	if (p) {
-		pr_info("Task in ");
+		pr_cont(",task_memcg=");
 		pr_cont_cgroup_path(task_cgroup(p, memory_cgrp_id));
-		pr_cont(" killed as a result of limit of ");
-	} else {
-		pr_info("Memory limit reached of cgroup ");
 	}
 
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
index 0935fca..820bc87 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -438,7 +438,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 
 	dump_stack();
 	if (is_memcg_oom(oc))
-		mem_cgroup_print_oom_info(oc->memcg, p);
+		mem_cgroup_print_oom_meminfo(oc->memcg);
 	else {
 		show_mem(SHOW_MEM_FILTER_NODES, oc->nodemask);
 		if (is_dump_unreclaim_slabs())
@@ -455,6 +455,7 @@ static void dump_oom_summary(struct oom_control *oc, struct task_struct *victim)
 			oom_constraint_text[oc->constraint],
 			nodemask_pr_args(oc->nodemask));
 	cpuset_print_current_mems_allowed();
+	mem_cgroup_print_oom_context(oc->memcg, victim);
 	pr_cont(",task=%s,pid=%d,uid=%d\n", victim->comm, victim->pid,
 		from_kuid(&init_user_ns, task_uid(victim)));
 }
-- 
1.8.3.1
