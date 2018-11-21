Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 081556B2608
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 06:30:15 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id g12-v6so7643617plo.14
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 03:30:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 14-v6sor57703523pfs.60.2018.11.21.03.30.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Nov 2018 03:30:13 -0800 (PST)
From: ufo19890607@gmail.com
Subject: [PATCH v15 1/2] Reorganize the oom report in dump_header
Date: Wed, 21 Nov 2018 19:29:58 +0800
Message-Id: <1542799799-36184-1-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian@didichuxing.com

From: yuzhoujian <yuzhoujian@didichuxing.com>

OOM report contains several sections. The first one is the allocation
context that has triggered the OOM. Then we have cpuset context
followed by the stack trace of the OOM path. The tird one is the OOM
memory information. Followed by the current memory state of all system
tasks. At last, we will show oom eligible tasks and the information
about the chosen oom victim.

One thing that makes parsing more awkward than necessary is that we do
not have a single and easily parsable line about the oom context. This
patch is reorganizing the oom report to
1) who invoked oom and what was the allocation request
[  515.902945] tuned invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), order=0, oom_score_adj=0

2) OOM stack trace
[  515.904273] CPU: 24 PID: 1809 Comm: tuned Not tainted 4.20.0-rc3+ #3
[  515.905518] Hardware name: Inspur SA5212M4/YZMB-00370-107, BIOS 4.1.10 11/14/2016
[  515.906821] Call Trace:
[  515.908062]  dump_stack+0x5a/0x73
[  515.909311]  dump_header+0x55/0x28c
[  515.914260]  oom_kill_process+0x2d8/0x300
[  515.916708]  out_of_memory+0x145/0x4a0
[  515.917932]  __alloc_pages_slowpath+0x7d2/0xa16
[  515.919157]  __alloc_pages_nodemask+0x277/0x290
[  515.920367]  filemap_fault+0x3d0/0x6c0
[  515.921529]  ? filemap_map_pages+0x2b8/0x420
[  515.922709]  ext4_filemap_fault+0x2c/0x40 [ext4]
[  515.923884]  __do_fault+0x20/0x80
[  515.925032]  __handle_mm_fault+0xbc0/0xe80
[  515.926195]  handle_mm_fault+0xfa/0x210
[  515.927357]  __do_page_fault+0x233/0x4c0
[  515.928506]  do_page_fault+0x32/0x140
[  515.929646]  ? page_fault+0x8/0x30
[  515.930770]  page_fault+0x1e/0x30

3) OOM memory information
[  515.958093] Mem-Info:
[  515.959647] active_anon:26501758 inactive_anon:1179809 isolated_anon:0
 active_file:4402672 inactive_file:483963 isolated_file:1344
 unevictable:0 dirty:4886753 writeback:0 unstable:0
 slab_reclaimable:148442 slab_unreclaimable:18741
 mapped:1347 shmem:1347 pagetables:58669 bounce:0
 free:88663 free_pcp:0 free_cma:0
...

4) current memory state of all system tasks
[  516.079544] [    744]     0   744     9211     1345   114688       82             0 systemd-journal
[  516.082034] [    787]     0   787    31764        0   143360       92             0 lvmetad
[  516.084465] [    792]     0   792    10930        1   110592      208         -1000 systemd-udevd
[  516.086865] [   1199]     0  1199    13866        0   131072      112         -1000 auditd
[  516.089190] [   1222]     0  1222    31990        1   110592      157             0 smartd
[  516.091477] [   1225]     0  1225     4864       85    81920       43             0 irqbalance
[  516.093712] [   1226]     0  1226    52612        0   258048      426             0 abrtd
[  516.112128] [   1280]     0  1280   109774       55   299008      400             0 NetworkManager
[  516.113998] [   1295]     0  1295    28817       37    69632       24             0 ksmtuned
[  516.144596] [  10718]     0 10718  2622484  1721372 15998976   267219             0 panic
[  516.145792] [  10719]     0 10719  2622484  1164767  9818112    53576             0 panic
[  516.146977] [  10720]     0 10720  2622484  1174361  9904128    53709             0 panic
[  516.148163] [  10721]     0 10721  2622484  1209070 10194944    54824             0 panic
[  516.149329] [  10722]     0 10722  2622484  1745799 14774272    91138             0 panic

5) oom context (contrains and the chosen victim).
oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),cpuset=/,mems_allowed=0-1,task=panic,pid=10737,uid=0

An admin can easily get the full oom context at a single line which
makes parsing much easier.

Signed-off-by: yuzhoujian <yuzhoujian@didichuxing.com>
---
Changes since v14:
- add the dump_oom_summary for the single line output of oom context.
- fix the null pointer in the dump_header.

Changes since v13:
- remove the spaces for printing pid and uid.

Changes since v12:
- print the cpuset and memory allocation information after oom victim comm, pid.

Changes since v11:
- move the array of const char oom_constraint_text to oom_kill.c
- add the cpuset information in the one line output.

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

 include/linux/oom.h    | 10 ++++++++++
 kernel/cgroup/cpuset.c |  4 ++--
 mm/oom_kill.c          | 29 ++++++++++++++++++++---------
 mm/page_alloc.c        |  4 ++--
 4 files changed, 34 insertions(+), 13 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 69864a5..d079920 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -15,6 +15,13 @@
 struct mem_cgroup;
 struct task_struct;
 
+enum oom_constraint {
+	CONSTRAINT_NONE,
+	CONSTRAINT_CPUSET,
+	CONSTRAINT_MEMORY_POLICY,
+	CONSTRAINT_MEMCG,
+};
+
 /*
  * Details of the page allocation that triggered the oom killer that are used to
  * determine what should be killed.
@@ -42,6 +49,9 @@ struct oom_control {
 	unsigned long totalpages;
 	struct task_struct *chosen;
 	unsigned long chosen_points;
+
+	/* Used to print the constraint info. */
+	enum oom_constraint constraint;
 };
 
 extern struct mutex oom_lock;
diff --git a/kernel/cgroup/cpuset.c b/kernel/cgroup/cpuset.c
index 266f10c..9510a5b 100644
--- a/kernel/cgroup/cpuset.c
+++ b/kernel/cgroup/cpuset.c
@@ -2666,9 +2666,9 @@ void cpuset_print_current_mems_allowed(void)
 	rcu_read_lock();
 
 	cgrp = task_cs(current)->css.cgroup;
-	pr_info("%s cpuset=", current->comm);
+	pr_cont(",cpuset=");
 	pr_cont_cgroup_name(cgrp);
-	pr_cont(" mems_allowed=%*pbl\n",
+	pr_cont(",mems_allowed=%*pbl",
 		nodemask_pr_args(&current->mems_allowed));
 
 	rcu_read_unlock();
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 6589f60..2c686d2 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -245,11 +245,11 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	return points > 0 ? points : 1;
 }
 
-enum oom_constraint {
-	CONSTRAINT_NONE,
-	CONSTRAINT_CPUSET,
-	CONSTRAINT_MEMORY_POLICY,
-	CONSTRAINT_MEMCG,
+static const char * const oom_constraint_text[] = {
+	[CONSTRAINT_NONE] = "CONSTRAINT_NONE",
+	[CONSTRAINT_CPUSET] = "CONSTRAINT_CPUSET",
+	[CONSTRAINT_MEMORY_POLICY] = "CONSTRAINT_MEMORY_POLICY",
+	[CONSTRAINT_MEMCG] = "CONSTRAINT_MEMCG",
 };
 
 /*
@@ -428,16 +428,25 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 	rcu_read_unlock();
 }
 
+static void dump_oom_summary(struct oom_control *oc, struct task_struct *victim)
+{
+	/* one line summary of the oom killer context. */
+	pr_info("oom-kill:constraint=%s,nodemask=%*pbl",
+			oom_constraint_text[oc->constraint],
+			nodemask_pr_args(oc->nodemask));
+	cpuset_print_current_mems_allowed();
+	pr_cont(",task=%s,pid=%d,uid=%d\n", victim->comm, victim->pid,
+		from_kuid(&init_user_ns, task_uid(victim)));
+}
+
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
 
-	cpuset_print_current_mems_allowed();
 	dump_stack();
 	if (is_memcg_oom(oc))
 		mem_cgroup_print_oom_info(oc->memcg, p);
@@ -448,6 +457,8 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 	}
 	if (sysctl_oom_dump_tasks)
 		dump_tasks(oc->memcg, oc->nodemask);
+	if (p)
+		dump_oom_summary(oc, p);
 }
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6847177..e7cff0b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3413,13 +3413,13 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	va_start(args, fmt);
 	vaf.fmt = fmt;
 	vaf.va = &args;
-	pr_warn("%s: %pV, mode:%#x(%pGg), nodemask=%*pbl\n",
+	pr_warn("%s: %pV, mode:%#x(%pGg), nodemask=%*pbl",
 			current->comm, &vaf, gfp_mask, &gfp_mask,
 			nodemask_pr_args(nodemask));
 	va_end(args);
 
 	cpuset_print_current_mems_allowed();
-
+	pr_cont("\n");
 	dump_stack();
 	warn_alloc_show_mem(gfp_mask, nodemask);
 }
-- 
1.8.3.1
