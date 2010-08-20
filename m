Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 51FDF6004CE
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 18:41:59 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id o7KMfufm021578
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 15:41:56 -0700
Received: from pvh1 (pvh1.prod.google.com [10.241.210.193])
	by hpaq7.eem.corp.google.com with ESMTP id o7KMfr6P000469
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 15:41:54 -0700
Received: by pvh1 with SMTP id 1so1883092pvh.37
        for <linux-mm@kvack.org>; Fri, 20 Aug 2010 15:41:53 -0700 (PDT)
Date: Fri, 20 Aug 2010 15:41:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/3 v3] oom: add per-mm oom disable count
Message-ID: <alpine.DEB.2.00.1008201539310.9201@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ying Han <yinghan@google.com>

It's pointless to kill a task if another thread sharing its mm cannot be
killed to allow future memory freeing.  A subsequent patch will prevent
kills in such cases, but first it's necessary to have a way to flag a
task that shares memory with an OOM_DISABLE task that doesn't incur an
additional tasklist scan, which would make select_bad_process() an O(n^2)
function.

This patch adds an atomic counter to struct mm_struct that follows how
many threads attached to it have an oom_score_adj of OOM_SCORE_ADJ_MIN.
They cannot be killed by the kernel, so their memory cannot be freed in
oom conditions.

This only requires task_lock() on the task that we're operating on, it
does not require mm->mmap_sem since task_lock() pins the mm and the
operation is atomic.

[rientjes@google.com: changelog and sys_unshare() code]
Signed-off-by: Ying Han <yinghan@google.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 fs/exec.c                |    5 +++++
 fs/proc/base.c           |   30 ++++++++++++++++++++++++++++++
 include/linux/mm_types.h |    2 ++
 kernel/exit.c            |    3 +++
 kernel/fork.c            |   13 ++++++++++++-
 5 files changed, 52 insertions(+), 1 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -54,6 +54,7 @@
 #include <linux/fsnotify.h>
 #include <linux/fs_struct.h>
 #include <linux/pipe_fs_i.h>
+#include <linux/oom.h>
 
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
@@ -745,6 +746,10 @@ static int exec_mmap(struct mm_struct *mm)
 	tsk->mm = mm;
 	tsk->active_mm = mm;
 	activate_mm(active_mm, mm);
+	if (tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
+		atomic_dec(&active_mm->oom_disable_count);
+		atomic_inc(&tsk->mm->oom_disable_count);
+	}
 	task_unlock(tsk);
 	arch_pick_mmap_layout(mm);
 	if (old_mm) {
diff --git a/fs/proc/base.c b/fs/proc/base.c
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1047,6 +1047,21 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
 		return -EACCES;
 	}
 
+	task_lock(task);
+	if (!task->mm) {
+		task_unlock(task);
+		unlock_task_sighand(task, &flags);
+		put_task_struct(task);
+		return -EINVAL;
+	}
+
+	if (oom_adjust != task->signal->oom_adj) {
+		if (oom_adjust == OOM_DISABLE)
+			atomic_inc(&task->mm->oom_disable_count);
+		if (task->signal->oom_adj == OOM_DISABLE)
+			atomic_dec(&task->mm->oom_disable_count);
+	}
+
 	/*
 	 * Warn that /proc/pid/oom_adj is deprecated, see
 	 * Documentation/feature-removal-schedule.txt.
@@ -1065,6 +1080,7 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
 	else
 		task->signal->oom_score_adj = (oom_adjust * OOM_SCORE_ADJ_MAX) /
 								-OOM_DISABLE;
+	task_unlock(task);
 	unlock_task_sighand(task, &flags);
 	put_task_struct(task);
 
@@ -1133,6 +1149,19 @@ static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
 		return -EACCES;
 	}
 
+	task_lock(task);
+	if (!task->mm) {
+		task_unlock(task);
+		unlock_task_sighand(task, &flags);
+		put_task_struct(task);
+		return -EINVAL;
+	}
+	if (oom_score_adj != task->signal->oom_score_adj) {
+		if (oom_score_adj == OOM_SCORE_ADJ_MIN)
+			atomic_inc(&task->mm->oom_disable_count);
+		if (task->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
+			atomic_dec(&task->mm->oom_disable_count);
+	}
 	task->signal->oom_score_adj = oom_score_adj;
 	/*
 	 * Scale /proc/pid/oom_adj appropriately ensuring that OOM_DISABLE is
@@ -1143,6 +1172,7 @@ static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
 	else
 		task->signal->oom_adj = (oom_score_adj * OOM_ADJUST_MAX) /
 							OOM_SCORE_ADJ_MAX;
+	task_unlock(task);
 	unlock_task_sighand(task, &flags);
 	put_task_struct(task);
 	return count;
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -310,6 +310,8 @@ struct mm_struct {
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
 #endif
+	/* How many tasks sharing this mm are OOM_DISABLE */
+	atomic_t oom_disable_count;
 };
 
 /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
diff --git a/kernel/exit.c b/kernel/exit.c
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -50,6 +50,7 @@
 #include <linux/perf_event.h>
 #include <trace/events/sched.h>
 #include <linux/hw_breakpoint.h>
+#include <linux/oom.h>
 
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
@@ -689,6 +690,8 @@ static void exit_mm(struct task_struct * tsk)
 	enter_lazy_tlb(mm, current);
 	/* We don't want this task to be frozen prematurely */
 	clear_freeze_flag(tsk);
+	if (tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
+		atomic_dec(&mm->oom_disable_count);
 	task_unlock(tsk);
 	mm_update_next_owner(mm);
 	mmput(mm);
diff --git a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -65,6 +65,7 @@
 #include <linux/perf_event.h>
 #include <linux/posix-timers.h>
 #include <linux/user-return-notifier.h>
+#include <linux/oom.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -485,6 +486,7 @@ static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
 	mm->cached_hole_size = ~0UL;
 	mm_init_aio(mm);
 	mm_init_owner(mm, p);
+	atomic_set(&mm->oom_disable_count, 0);
 
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
@@ -738,6 +740,8 @@ good_mm:
 	/* Initializing for Swap token stuff */
 	mm->token_priority = 0;
 	mm->last_interval = 0;
+	if (tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
+		atomic_inc(&mm->oom_disable_count);
 
 	tsk->mm = mm;
 	tsk->active_mm = mm;
@@ -1296,8 +1300,11 @@ bad_fork_cleanup_io:
 bad_fork_cleanup_namespaces:
 	exit_task_namespaces(p);
 bad_fork_cleanup_mm:
-	if (p->mm)
+	if (p->mm) {
+		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
+			atomic_dec(&p->mm->oom_disable_count);
 		mmput(p->mm);
+	}
 bad_fork_cleanup_signal:
 	if (!(clone_flags & CLONE_THREAD))
 		free_signal_struct(p->signal);
@@ -1690,6 +1697,10 @@ SYSCALL_DEFINE1(unshare, unsigned long, unshare_flags)
 			active_mm = current->active_mm;
 			current->mm = new_mm;
 			current->active_mm = new_mm;
+			if (current->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
+				atomic_dec(&mm->oom_disable_count);
+				atomic_inc(&new_mm->oom_disable_count);
+			}
 			activate_mm(active_mm, new_mm);
 			new_mm = mm;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
