Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 824876B0003
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 12:39:14 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f66-v6so3706229plb.10
        for <linux-mm@kvack.org>; Sat, 30 Jun 2018 09:39:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p1-v6sor3586000pld.61.2018.06.30.09.39.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 30 Jun 2018 09:39:12 -0700 (PDT)
From: ufo19890607@gmail.com
Subject: [PATCH v11 1/2] Refactor part of the oom report in dump_header
Date: Sun,  1 Jul 2018 00:38:58 +0800
Message-Id: <1530376739-20459-1-git-send-email-ufo19890607@gmail.com>
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
oom-kill:constraint=<constraint>,nodemask=<nodemask>,oom_memcg=<memcg>,task_memcg=<memcg>,task=<comm>,pid=<pid>,uid=<uid>

Signed-off-by: yuzhoujian <yuzhoujian@didichuxing.com>
---
Below is the part of the oom report in the dmesg
...
[  126.168182] panic invoked oom-killer: gfp_mask=0x6280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), order=0, oom_score_adj=0
[  126.169115] panic cpuset=/ mems_allowed=0-1
[  126.169806] CPU: 23 PID: 8668 Comm: panic Not tainted 4.18.0-rc2+ #36
[  126.170494] Hardware name: Inspur SA5212M4/YZMB-00370-107, BIOS 4.1.10 11/14/2016
[  126.171197] Call Trace:
[  126.171901]  dump_stack+0x5a/0x73
[  126.172593]  dump_header+0x58/0x2dc
[  126.173294]  oom_kill_process+0x228/0x420
[  126.173999]  ? oom_badness+0x2a/0x130
[  126.174705]  out_of_memory+0x11a/0x4a0
[  126.175415]  __alloc_pages_slowpath+0x7cc/0xa1e
[  126.176128]  ? __alloc_pages_slowpath+0x194/0xa1e
[  126.176853]  ? page_counter_try_charge+0x54/0xc0
[  126.177580]  __alloc_pages_nodemask+0x277/0x290
[  126.178319]  alloc_pages_vma+0x73/0x180
[  126.179058]  do_anonymous_page+0xed/0x5a0
[  126.179825]  __handle_mm_fault+0xbb3/0xe70
[  126.180566]  handle_mm_fault+0xfa/0x210
[  126.181313]  __do_page_fault+0x233/0x4c0
[  126.182063]  do_page_fault+0x32/0x140
[  126.182812]  ? page_fault+0x8/0x30
[  126.183560]  page_fault+0x1e/0x30
[  126.184311] RIP: 0033:0x7f62c9e65860
[  126.185059] Code: Bad RIP value.
[  126.185819] RSP: 002b:00007ffcf7bc9288 EFLAGS: 00010206
[  126.186589] RAX: 00007f6209bd8000 RBX: 0000000000000000 RCX: 00007f6236914000
[  126.187383] RDX: 00007f6249bd8000 RSI: 0000000000000000 RDI: 00007f6209bd8000
[  126.188179] RBP: 00007ffcf7bc92b0 R08: ffffffffffffffff R09: 0000000000000000
[  126.188981] R10: 0000000000000022 R11: 0000000000000246 R12: 0000000000400490
[  126.189793] R13: 00007ffcf7bc9390 R14: 0000000000000000 R15: 0000000000000000
[  126.190619] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),global_oom,task_memcg=/test/test1/test2,task=panic,pid= 8673,uid=    0
...

Changes since v10:
- divide the patch v8 into two parts. One part is to add the array of const char and put enum
  oom_constaint into oom.h; the other adds a new func to print the missing information for the system-
  wide oom report.

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

 include/linux/oom.h | 17 +++++++++++++++++
 mm/oom_kill.c       | 31 ++++++++++++++-----------------
 2 files changed, 31 insertions(+), 17 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 6adac113e96d..5bed78d4bfb8 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -15,6 +15,20 @@ struct notifier_block;
 struct mem_cgroup;
 struct task_struct;
 
+enum oom_constraint {
+	CONSTRAINT_NONE,
+	CONSTRAINT_CPUSET,
+	CONSTRAINT_MEMORY_POLICY,
+	CONSTRAINT_MEMCG,
+};
+
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
@@ -42,6 +56,9 @@ struct oom_control {
 	unsigned long totalpages;
 	struct task_struct *chosen;
 	unsigned long chosen_points;
+
+	/* Used to print the constraint info. */
+	enum oom_constraint constraint;
 };
 
 extern struct mutex oom_lock;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 84081e77bc51..f9b08e455fd1 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -237,13 +237,6 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	return points > 0 ? points : 1;
 }
 
-enum oom_constraint {
-	CONSTRAINT_NONE,
-	CONSTRAINT_CPUSET,
-	CONSTRAINT_MEMORY_POLICY,
-	CONSTRAINT_MEMCG,
-};
-
 /*
  * Determine the type of allocation constraint.
  */
@@ -421,15 +414,20 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 
 static void dump_header(struct oom_control *oc, struct task_struct *p)
 {
-	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=%*pbl, order=%d, oom_score_adj=%hd\n",
-		current->comm, oc->gfp_mask, &oc->gfp_mask,
-		nodemask_pr_args(oc->nodemask), oc->order,
+	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), order=%d, oom_score_adj=%hd\n",
+		current->comm, oc->gfp_mask, &oc->gfp_mask, oc->order,
 			current->signal->oom_score_adj);
 	if (!IS_ENABLED(CONFIG_COMPACTION) && oc->order)
 		pr_warn("COMPACTION is disabled!!!\n");
 
 	cpuset_print_current_mems_allowed();
 	dump_stack();
+
+	/* one line summary of the oom killer context. */
+	pr_info("oom-kill:constraint=%s,nodemask=%*pbl,task=%s,pid=%5d,uid=%5d",
+			oom_constraint_text[oc->constraint],
+			nodemask_pr_args(oc->nodemask),
+			p->comm, p->pid, from_kuid(&init_user_ns, task_uid(p)));
 	if (is_memcg_oom(oc))
 		mem_cgroup_print_oom_info(oc->memcg, p);
 	else {
@@ -973,8 +971,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 /*
  * Determines whether the kernel must panic because of the panic_on_oom sysctl.
  */
-static void check_panic_on_oom(struct oom_control *oc,
-			       enum oom_constraint constraint)
+static void check_panic_on_oom(struct oom_control *oc)
 {
 	if (likely(!sysctl_panic_on_oom))
 		return;
@@ -984,7 +981,7 @@ static void check_panic_on_oom(struct oom_control *oc,
 		 * does not panic for cpuset, mempolicy, or memcg allocation
 		 * failures.
 		 */
-		if (constraint != CONSTRAINT_NONE)
+		if (oc->constraint != CONSTRAINT_NONE)
 			return;
 	}
 	/* Do not panic for oom kills triggered by sysrq */
@@ -1021,8 +1018,8 @@ EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 bool out_of_memory(struct oom_control *oc)
 {
 	unsigned long freed = 0;
-	enum oom_constraint constraint = CONSTRAINT_NONE;
 
+	oc->constraint = CONSTRAINT_NONE;
 	if (oom_killer_disabled)
 		return false;
 
@@ -1057,10 +1054,10 @@ bool out_of_memory(struct oom_control *oc)
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
