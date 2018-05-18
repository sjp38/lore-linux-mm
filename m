Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id DDE516B059C
	for <linux-mm@kvack.org>; Fri, 18 May 2018 04:41:04 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id t5-v6so4655481ply.13
        for <linux-mm@kvack.org>; Fri, 18 May 2018 01:41:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bd7-v6sor3903971plb.45.2018.05.18.01.41.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 May 2018 01:41:03 -0700 (PDT)
From: ufo19890607 <ufo19890607@gmail.com>
Subject: [PATCH v3] Print the memcg's name when system-wide OOM happened
Date: Fri, 18 May 2018 09:40:51 +0100
Message-Id: <1526632851-25613-1-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, guro@fb.com, yang.s@alibaba-inc.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian <yuzhoujian@didichuxing.com>

From: yuzhoujian <yuzhoujian@didichuxing.com>

The dump_header does not print the memcg's name when the system
oom happened. So users cannot locate the certain container which
contains the task that has been killed by the oom killer.

System oom report will contain the memcg's name after this patch,
so users can get the memcg's path from the oom report and check
that container more quickly.

Changes since v2:
- add the mem_cgroup_print_memcg_name helper to print the memcg's
  name which contains the task that will be killed by the oom-killer.

Changes since v1:
- replace adding mem_cgroup_print_oom_info with printing the memcg's
  name only.

Signed-off-by: yuzhoujian <yuzhoujian@didichuxing.com>
---
 include/linux/memcontrol.h |  7 +++++++
 mm/memcontrol.c            | 13 +++++++++++++
 mm/oom_kill.c              |  1 +
 3 files changed, 21 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index d99b71bc2c66..12ffe4d0a4f8 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -464,6 +464,8 @@ void mem_cgroup_handle_over_high(void);
 
 unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg);
 
+void mem_cgroup_print_memcg_name(struct task_struct *p);
+
 void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 				struct task_struct *p);
 
@@ -858,6 +860,11 @@ static inline unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
 	return 0;
 }
 
+static inline void
+mem_cgroup_print_memcg_name(struct task_struct *p)
+{
+}
+
 static inline void
 mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2bd3df3d101a..15fb5ea9ddc9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1118,6 +1118,19 @@ static const char *const memcg1_stat_names[] = {
 };
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
+
+/**
+ * mem_cgroup_print_memcg_name: Print the memcg's name which contains the task
+ * that will be killed by the oom-killer.
+ * @p: Task that is going to be killed
+ */
+void mem_cgroup_print_memcg_name(struct task_struct *p)
+{
+	pr_info("Task in ");
+	pr_cont_cgroup_path(task_cgroup(p, memory_cgrp_id));
+	pr_cont(" killed as a result of limit of ");
+}
+
 /**
  * mem_cgroup_print_oom_info: Print OOM information relevant to memory controller.
  * @memcg: The memory cgroup that went over limit
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8ba6cb88cf58..73fdfa2311d5 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -433,6 +433,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 	if (is_memcg_oom(oc))
 		mem_cgroup_print_oom_info(oc->memcg, p);
 	else {
+		mem_cgroup_print_memcg_name(p);
 		show_mem(SHOW_MEM_FILTER_NODES, oc->nodemask);
 		if (is_dump_unreclaim_slabs())
 			dump_unreclaimable_slab();
-- 
2.14.1
