Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 252674403E0
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 04:18:49 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id s19so573636lfi.19
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 01:18:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k24sor590538ljb.44.2017.11.08.01.18.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Nov 2017 01:18:47 -0800 (PST)
From: Dmitry Monakhov <dmonakhov@openvz.org>
Subject: [PATCH 1/2] mm: add sysctl to control global OOM logging behaviour
Date: Wed,  8 Nov 2017 09:18:42 +0000
Message-Id: <20171108091843.29349-1-dmonakhov@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, vdavydov.dev@gmail.com, Dmitry Monakhov <dmonakhov@openvz.org>

Our systems becomes bigger and bigger, but OOM still happens.
This becomes serious problem for systems where OOM happens
frequently(containers, VM) because each OOM generate pressure
on dmesg log infrastructure. Let's allow system administrator
ability to tune OOM dump behaviour

Disable oom log dump globaly:
# echo 0 > /proc/sys/vm/oom_dump_log
Enable oom log dump globaly:
# echo 1 > /proc/sys/vm/oom_dump_log

Signed-off-by: Dmitry Monakhov <dmonakhov@openvz.org>
---
 Documentation/sysctl/vm.txt | 13 +++++++++++++
 include/linux/oom.h         |  1 +
 kernel/sysctl.c             |  7 +++++++
 mm/oom_kill.c               | 40 ++++++++++++++++++++++------------------
 4 files changed, 43 insertions(+), 18 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 9baf66a..09d69a0 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -617,7 +617,20 @@ Default order is recommended unless this is causing problems for your
 system/application.
 
 ==============================================================
+oom_dump_log
 
+Enables a system-wide dump to be produced when the kernel performs an
+OOM-killing. This sysctl control dump about  general information of OOM state
+
+If this is set to zero, this information is suppressed.  On very
+large systems with thousands of tasks it may not be feasible to dump
+the memory state information for each OOM event.  Such systems should
+not be forced to incur a performance penalty in OOM conditions when the
+information may not be desired.
+
+The default value is 1 (enabled).
+
+==============================================================
 oom_dump_tasks
 
 Enables a system-wide task dump (excluding kernel threads) to be produced
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 01c91d8..8ff56d3 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -104,6 +104,7 @@ extern unsigned long oom_badness(struct task_struct *p,
 
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
+extern int sysctl_oom_dump_log;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_panic_on_oom;
 #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index d9c31bc..87163c1 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1263,6 +1263,13 @@ static int sysrq_sysctl_handler(struct ctl_table *table, int write,
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "oom_dump_log",
+		.data		= &sysctl_oom_dump_log,
+		.maxlen		= sizeof(sysctl_oom_dump_log),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "overcommit_ratio",
 		.data		= &sysctl_overcommit_ratio,
 		.maxlen		= sizeof(sysctl_overcommit_ratio),
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dee0f75..02c8f5d6 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -51,6 +51,7 @@
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
+int sysctl_oom_dump_log = 1;
 
 DEFINE_MUTEX(oom_lock);
 
@@ -552,7 +553,8 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 					 NULL);
 	}
 	tlb_finish_mmu(&tlb, 0, -1);
-	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
+	if (sysctl_oom_dump_log)
+		pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 			task_pid_nr(tsk), tsk->comm,
 			K(get_mm_counter(mm, MM_ANONPAGES)),
 			K(get_mm_counter(mm, MM_FILEPAGES)),
@@ -578,11 +580,11 @@ static void oom_reap_task(struct task_struct *tsk)
 	if (attempts <= MAX_OOM_REAP_RETRIES)
 		goto done;
 
-
-	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
-		task_pid_nr(tsk), tsk->comm);
-	debug_show_all_locks();
-
+	if (sysctl_oom_dump_log) {
+		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
+			task_pid_nr(tsk), tsk->comm);
+		debug_show_all_locks();
+	}
 done:
 	tsk->oom_reaper_list = NULL;
 
@@ -647,7 +649,7 @@ static int __init oom_init(void)
 }
 subsys_initcall(oom_init)
 #else
-static inline void wake_oom_reaper(struct task_struct *tsk)
+static inline void wake_oom_reaper(struct task_struct *tsk, bool verbose)
 {
 }
 #endif /* CONFIG_MMU */
@@ -847,13 +849,13 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 		return;
 	}
 	task_unlock(p);
+	if (sysctl_oom_dump_log) {
+		if (__ratelimit(&oom_rs))
+			dump_header(oc, p);
 
-	if (__ratelimit(&oom_rs))
-		dump_header(oc, p);
-
-	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
-		message, task_pid_nr(p), p->comm, points);
-
+		pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
+		       message, task_pid_nr(p), p->comm, points);
+	}
 	/*
 	 * If any of p's children has a different mm and is eligible for kill,
 	 * the one with the highest oom_badness() score is sacrificed for its
@@ -907,11 +909,13 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	mark_oom_victim(victim);
-	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
-		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
-		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
-		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
-		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
+	if (sysctl_oom_dump_log)
+		pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
+		       task_pid_nr(victim), victim->comm,
+		       K(victim->mm->total_vm),
+		       K(get_mm_counter(victim->mm, MM_ANONPAGES)),
+		       K(get_mm_counter(victim->mm, MM_FILEPAGES)),
+		       K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
 	task_unlock(victim);
 
 	/*
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
