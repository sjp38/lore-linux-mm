Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6A8DF6B0006
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 12:39:18 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h14-v6so6157318pfi.19
        for <linux-mm@kvack.org>; Sat, 30 Jun 2018 09:39:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i80-v6sor1097958pfj.25.2018.06.30.09.39.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 30 Jun 2018 09:39:17 -0700 (PDT)
From: ufo19890607@gmail.com
Subject: [PATCH v11 2/2] Add the missing information in dump_header
Date: Sun,  1 Jul 2018 00:38:59 +0800
Message-Id: <1530376739-20459-2-git-send-email-ufo19890607@gmail.com>
In-Reply-To: <1530376739-20459-1-git-send-email-ufo19890607@gmail.com>
References: <1530376739-20459-1-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian@didichuxing.com

From: yuzhoujian <yuzhoujian@didichuxing.com>

Add a new func mem_cgroup_print_oom_context to print missing information
for the system-wide oom report which includes the oom memcg that has
reached its limit, task memcg that contains the killed task.

Signed-off-by: yuzhoujian <yuzhoujian@didichuxing.com>
---
 include/linux/memcontrol.h | 15 ++++++++++++---
 mm/memcontrol.c            | 36 ++++++++++++++++++++++--------------
 mm/oom_kill.c              | 10 ++++++----
 3 files changed, 40 insertions(+), 21 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6c6fb116e925..90855880bca2 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -28,6 +28,7 @@
 #include <linux/eventfd.h>
 #include <linux/mm.h>
 #include <linux/vmstat.h>
+#include <linux/oom.h>
 #include <linux/writeback.h>
 #include <linux/page-flags.h>
 
@@ -491,8 +492,10 @@ void mem_cgroup_handle_over_high(void);
 
 unsigned long mem_cgroup_get_max(struct mem_cgroup *memcg);
 
-void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
-				struct task_struct *p);
+void mem_cgroup_print_oom_context(struct mem_cgroup *memcg,
+		struct task_struct *p);
+
+void mem_cgroup_print_oom_meminfo(struct mem_cgroup *memcg);
 
 static inline void mem_cgroup_oom_enable(void)
 {
@@ -903,7 +906,13 @@ static inline unsigned long mem_cgroup_get_max(struct mem_cgroup *memcg)
 }
 
 static inline void
-mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
+mem_cgroup_print_oom_context(struct mem_cgroup *memcg,
+				struct task_struct *p)
+{
+}
+
+static inline void
+mem_cgroup_print_oom_meminfo(struct mem_cgroup *memcg)
 {
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e6f0d5ef320a..18deea974cfd 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1119,32 +1119,40 @@ static const char *const memcg1_stat_names[] = {
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
 /**
- * mem_cgroup_print_oom_info: Print OOM information relevant to memory controller.
- * @memcg: The memory cgroup that went over limit
+ * mem_cgroup_print_oom_context: Print OOM context information relevant to
+ * memory controller.
+ * @memcg: The origin memory cgroup that went over limit
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
+	struct cgroup *origin_cgrp, *kill_cgrp;
 
 	rcu_read_lock();
-
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
index f9b08e455fd1..e990c45d2e7d 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -424,12 +424,14 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 	dump_stack();
 
 	/* one line summary of the oom killer context. */
-	pr_info("oom-kill:constraint=%s,nodemask=%*pbl,task=%s,pid=%5d,uid=%5d",
+	pr_info("oom-kill:constraint=%s,nodemask=%*pbl",
 			oom_constraint_text[oc->constraint],
-			nodemask_pr_args(oc->nodemask),
-			p->comm, p->pid, from_kuid(&init_user_ns, task_uid(p)));
+			nodemask_pr_args(oc->nodemask));
+	mem_cgroup_print_oom_context(oc->memcg, p);
+	pr_cont(",task=%s,pid=%5d,uid=%5d\n", p->comm, p->pid,
+			from_kuid(&init_user_ns, task_uid(p)));
 	if (is_memcg_oom(oc))
-		mem_cgroup_print_oom_info(oc->memcg, p);
+		mem_cgroup_print_oom_meminfo(oc->memcg);
 	else {
 		show_mem(SHOW_MEM_FILTER_NODES, oc->nodemask);
 		if (is_dump_unreclaim_slabs())
-- 
2.14.1
