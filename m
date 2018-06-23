Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id AD8836B0006
	for <linux-mm@kvack.org>; Sat, 23 Jun 2018 10:13:20 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id t19-v6so5277835plo.9
        for <linux-mm@kvack.org>; Sat, 23 Jun 2018 07:13:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x1-v6sor3311402plo.120.2018.06.23.07.13.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 23 Jun 2018 07:13:18 -0700 (PDT)
From: ufo19890607@gmail.com
Subject: [PATCH v10 2/2] Refactor part of the oom report in dump_header
Date: Sat, 23 Jun 2018 22:12:51 +0800
Message-Id: <1529763171-29240-2-git-send-email-ufo19890607@gmail.com>
In-Reply-To: <1529763171-29240-1-git-send-email-ufo19890607@gmail.com>
References: <1529763171-29240-1-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian@didichuxing.com

From: yuzhoujian <yuzhoujian@didichuxing.com>

The current system wide oom report prints information about the victim
and the allocation context and restrictions. It, however, doesn't
provide any information about memory cgroup the victim belongs to. This
information can be interesting for container users because they can find
the victim's container much more easily.

I follow the advices of David Rientjes and Michal Hocko, and refactor
part of the oom report. After this patch, users can get the memcg's
path from the oom report and check the certain container more quickly.

The oom print info after this patch:
oom-kill:constraint=<constraint>,nodemask=<nodemask>,oom_memcg=<memcg>,task_memcg=<memcg>,task=<commm>,pid=<pid>,uid=<uid>

Signed-off-by: yuzhoujian <yuzhoujian@didichuxing.com>
---
Below is the part of the oom report in the dmesg
...
[  134.873392] panic invoked oom-killer: gfp_mask=0x6280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null), order=0, oom_score_adj=0
[  134.873394] panic cpuset=/ mems_allowed=0-1
[  134.873400] CPU: 37 PID: 9094 Comm: panic Not tainted 4.18.0-rc1+ #27
[  134.873401] Hardware name: Inspur SA5212M4/YZMB-00370-107, BIOS 4.1.10 11/14/2016
[  134.873402] Call Trace:
[  134.873412]  dump_stack+0x5a/0x73
[  134.873416]  dump_header+0x77/0x2ac
[  134.873419]  oom_kill_process+0x228/0x420
[  134.873420]  ? oom_badness+0x2a/0x130
[  134.873422]  out_of_memory+0x11a/0x4a0
[  134.873426]  __alloc_pages_slowpath+0x7cc/0xa1e
[  134.873428]  ? __alloc_pages_slowpath+0x194/0xa1e
[  134.873433]  ? page_counter_try_charge+0x54/0xc0
[  134.873435]  __alloc_pages_nodemask+0x277/0x290
[  134.873440]  alloc_pages_vma+0x73/0x180
[  134.873443]  do_anonymous_page+0xed/0x5a0
[  134.873446]  __handle_mm_fault+0xbb3/0xe70
[  134.873449]  handle_mm_fault+0xfa/0x210
[  134.873453]  __do_page_fault+0x233/0x4c0
[  134.873456]  do_page_fault+0x32/0x140
[  134.873459]  ? page_fault+0x8/0x30
[  134.873461]  page_fault+0x1e/0x30
[  134.873464] RIP: 0033:0x7f99720db860
[  134.873465] Code: Bad RIP value.
[  134.873471] RSP: 002b:00007ffdb7f2cde8 EFLAGS: 00010206
[  134.873473] RAX: 00007f9931e4e000 RBX: 0000000000000000 RCX: 00007f996029a000
[  134.873474] RDX: 00007f9971e4e000 RSI: 0000000000000000 RDI: 00007f9931e4e000
[  134.873475] RBP: 00007ffdb7f2ce10 R08: ffffffffffffffff R09: 0000000000000000
[  134.873476] R10: 00007ffdb7f2cb00 R11: 00007f99720db7c0 R12: 0000000000400490
[  134.873477] R13: 00007ffdb7f2cef0 R14: 0000000000000000 R15: 0000000000000000
[  134.873480] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),task_memcg=/test/test1/test2,task=panic,pid= 8669,  uid=    0
...

Changes since v9:
- divide the patch v8 into two parts. One part is to move enum oom_constraint into memcontrol.h; the
  other refactors the output info in the dump_header.
- replace orgin_memcg and kill_memcg with oom_memcg and task_memcg resptively.

Changes since v8:
- add the constraint in the oom_control structure.
- put enum oom_constraint and constraint array into the oom.h file.
- simplify the description for mem_cgroup_print_oom_context.

Changes since v7:
- add the constraint parameter to dump_header and oom_kill_process.
- remove the static char array in the mem_cgroup_print_oom_context, and
  invoke pr_cont_cgroup_path to print memcg' name.
- combine the patchset v6 into one.

Changes since v6:
- divide the patch v5 into two parts. One part is to add an array of const char and
  put enum oom_constraint into the memcontrol.h; the other refactors the output
  in the dump_header.
- limit the memory usage for the static char array by using NAME_MAX in the mem_cgroup_print_oom_context.
- eliminate the spurious spaces in the oom's output and fix the spelling of "constrain".

Changes since v5:
- add an array of const char for each constraint.
- replace all of the pr_cont with a single line print of the pr_info.
- put enum oom_constraint into the memcontrol.c file for printing oom constraint.

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

 include/linux/memcontrol.h | 15 ++++++++++++---
 include/linux/oom.h        | 10 ++++++++++
 mm/memcontrol.c            | 41 ++++++++++++++++++++++++++++-------------
 mm/oom_kill.c              | 17 +++++++++--------
 4 files changed, 59 insertions(+), 24 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 513b74b3115b..e4d0d4693781 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -492,8 +492,11 @@ void mem_cgroup_handle_over_high(void);
 
 unsigned long mem_cgroup_get_max(struct mem_cgroup *memcg);
 
-void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
-				struct task_struct *p);
+void mem_cgroup_print_oom_context(struct mem_cgroup *memcg,
+		struct task_struct *p, enum oom_constraint constraint,
+		nodemask_t *nodemask);
+
+void mem_cgroup_print_oom_meminfo(struct mem_cgroup *memcg);
 
 static inline void mem_cgroup_oom_enable(void)
 {
@@ -904,7 +907,13 @@ static inline unsigned long mem_cgroup_get_max(struct mem_cgroup *memcg)
 }
 
 static inline void
-mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
+mem_cgroup_print_oom_context(struct mem_cgroup *memcg, struct task_struct *p,
+			enum oom_constraint constraint, nodemask_t *nodemask)
+{
+}
+
+static inline void
+mem_cgroup_print_oom_meminfo(struct mem_cgroup *memcg)
 {
 }
 
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 40cc561f8557..5bed78d4bfb8 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -22,6 +22,13 @@ enum oom_constraint {
 	CONSTRAINT_MEMCG,
 };
 
+static const char * const oom_constraint_text[] = {
+	[CONSTRAINT_NONE] = "CONSTRAINT_NONE",
+	[CONSTRAINT_CPUSET] = "CONSTRAINT_CPUSET",
+	[CONSTRAINT_MEMORY_POLICY] = "CONSTRAINT_MEMORY_POLICY",
+	[CONSTRAINT_MEMCG] = "CONSTRAINT_MEMCG",
+};
+
 /*
  * Details of the page allocation that triggered the oom killer that are used to
  * determine what should be killed.
@@ -49,6 +56,9 @@ struct oom_control {
 	unsigned long totalpages;
 	struct task_struct *chosen;
 	unsigned long chosen_points;
+
+	/* Used to print the constraint info. */
+	enum oom_constraint constraint;
 };
 
 extern struct mutex oom_lock;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e6f0d5ef320a..cfd93db9e902 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1119,32 +1119,47 @@ static const char *const memcg1_stat_names[] = {
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
 /**
- * mem_cgroup_print_oom_info: Print OOM information relevant to memory controller.
- * @memcg: The memory cgroup that went over limit
+ * mem_cgroup_print_oom_context: Print OOM context information relevant to
+ * memory controller.
+ * @memcg: The origin memory cgroup that went over limit
  * @p: Task that is going to be killed
+ * @constraint: The allocation constraint
+ * @nodemask: The allocation nodemask
  *
  * NOTE: @memcg and @p's mem_cgroup can be different when hierarchy is
  * enabled
  */
-void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
+void mem_cgroup_print_oom_context(struct mem_cgroup *memcg, struct task_struct *p,
+	enum oom_constraint constraint, nodemask_t *nodemask)
 {
-	struct mem_cgroup *iter;
-	unsigned int i;
+	struct cgroup *origin_cgrp, *kill_cgrp;
 
 	rcu_read_lock();
-
+	pr_info("oom-kill:constraint=%s,nodemask=%*pbl",
+	   oom_constraint_text[constraint], nodemask_pr_args(nodemask));
+	if (memcg) {
+		pr_cont(",oom_memcg=");
+		pr_cont_cgroup_path(memcg->css.cgroup);
+	}
 	if (p) {
-		pr_info("Task in ");
+		pr_cont(",task_memcg=");
 		pr_cont_cgroup_path(task_cgroup(p, memory_cgrp_id));
-		pr_cont(" killed as a result of limit of ");
-	} else {
-		pr_info("Memory limit reached of cgroup ");
+		pr_cont(",task=%s,pid=%5d,uid=%5d",
+		   p->comm, p->pid, from_kuid(&init_user_ns, task_uid(p)));
 	}
-
-	pr_cont_cgroup_path(memcg->css.cgroup);
 	pr_cont("\n");
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
index 1045c5bc7c37..44cb4b080d9d 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -423,8 +423,10 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 
 	cpuset_print_current_mems_allowed();
 	dump_stack();
+	mem_cgroup_print_oom_context(oc->memcg, p,
+		oc->constraint, oc->nodemask);
 	if (is_memcg_oom(oc))
-		mem_cgroup_print_oom_info(oc->memcg, p);
+		mem_cgroup_print_oom_meminfo(oc->memcg);
 	else {
 		show_mem(SHOW_MEM_FILTER_NODES, oc->nodemask);
 		if (is_dump_unreclaim_slabs())
@@ -966,8 +968,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 /*
  * Determines whether the kernel must panic because of the panic_on_oom sysctl.
  */
-static void check_panic_on_oom(struct oom_control *oc,
-			       enum oom_constraint constraint)
+static void check_panic_on_oom(struct oom_control *oc)
 {
 	if (likely(!sysctl_panic_on_oom))
 		return;
@@ -977,7 +978,7 @@ static void check_panic_on_oom(struct oom_control *oc,
 		 * does not panic for cpuset, mempolicy, or memcg allocation
 		 * failures.
 		 */
-		if (constraint != CONSTRAINT_NONE)
+		if (oc->constraint != CONSTRAINT_NONE)
 			return;
 	}
 	/* Do not panic for oom kills triggered by sysrq */
@@ -1014,8 +1015,8 @@ EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 bool out_of_memory(struct oom_control *oc)
 {
 	unsigned long freed = 0;
-	enum oom_constraint constraint = CONSTRAINT_NONE;
 
+	oc->constraint = CONSTRAINT_NONE;
 	if (oom_killer_disabled)
 		return false;
 
@@ -1050,10 +1051,10 @@ bool out_of_memory(struct oom_control *oc)
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA and memcg) that may require different handling.
 	 */
-	constraint = constrained_alloc(oc);
-	if (constraint != CONSTRAINT_MEMORY_POLICY)
+	oc->constraint = constrained_alloc(oc);
+	if (oc->constraint != CONSTRAINT_MEMORY_POLICY)
 		oc->nodemask = NULL;
-	check_panic_on_oom(oc, constraint);
+	check_panic_on_oom(oc);
 
 	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
 	    current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
-- 
2.14.1
