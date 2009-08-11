Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CDC2B6B004F
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 19:30:50 -0400 (EDT)
Date: Wed, 12 Aug 2009 08:30:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH for 2.6.31] Revert oom: move oom_adj value
Message-Id: <20090812082535.E1A3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Andrew,

Can you please drop my oom related patch from -mm temporary.
I plan to post rebased patch this week end.

Thanks.

===================== cut here =====================
The commit 2ff05b2b (oom: move oom_adj value) move oom_adj value to mm_struct.
It is very good first step for sanitize OOM.

However Paul Menage reported the commit makes regression to his job scheduler.
Current OOM logic can kill OOM_DISABLED process.

Why? His program has the code of similar to the following.

	...
	set_oom_adj(OOM_DISABLE); /* The job scheduler never killed by oom */
	...
	if (vfork() == 0) {
		set_oom_adj(0); /* Invoked child can be killed */
		execve("foo-bar-cmd");
	}
	....

vfork() parent and child are shared the same mm_struct. then above
set_oom_adj(0) doesn't only change oom_adj for vfork() child, it's also
change oom_adj for vfork() parent.
Then, vfork() parent (job scheduler) lost OOM immune and it was killed.

Actually, fork-setting-exec idiom is very frequently used in userland program.
We must not break this assumption.

Then, this patch revert commit 2ff05b2b and related commit.

Reverted commit list
---------------------
- commit 2ff05b2b4e (oom: move oom_adj value from task_struct to mm_struct)
- commit 4d8b9135c3 (oom: avoid unnecessary mm locking and scanning for OOM_DISABLE)
- commit 8123681022 (oom: only oom kill exiting tasks with attached memory)
- commit 933b787b57 (mm: copy over oom_adj value at fork time)

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 Documentation/filesystems/proc.txt |   15 +++------
 fs/proc/base.c                     |   19 ++---------
 include/linux/mm_types.h           |    2 -
 include/linux/sched.h              |    1 +
 kernel/fork.c                      |    1 -
 mm/oom_kill.c                      |   64 ++++++++++++++++++++++--------------
 6 files changed, 48 insertions(+), 54 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index fad18f9..ffead13 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -1167,13 +1167,11 @@ CHAPTER 3: PER-PROCESS PARAMETERS
 3.1 /proc/<pid>/oom_adj - Adjust the oom-killer score
 ------------------------------------------------------
 
-This file can be used to adjust the score used to select which processes should
-be killed in an out-of-memory situation.  The oom_adj value is a characteristic
-of the task's mm, so all threads that share an mm with pid will have the same
-oom_adj value.  A high value will increase the likelihood of this process being
-killed by the oom-killer.  Valid values are in the range -16 to +15 as
-explained below and a special value of -17, which disables oom-killing
-altogether for threads sharing pid's mm.
+This file can be used to adjust the score used to select which processes
+should be killed in an  out-of-memory  situation.  Giving it a high score will
+increase the likelihood of this process being killed by the oom-killer.  Valid
+values are in the range -16 to +15, plus the special value -17, which disables
+oom-killing altogether for this process.
 
 The process to be killed in an out-of-memory situation is selected among all others
 based on its badness score. This value equals the original memory size of the process
@@ -1187,9 +1185,6 @@ the parent's score if they do not share the same memory. Thus forking servers
 are the prime candidates to be killed. Having only one 'hungry' child will make
 parent less preferable than the child.
 
-/proc/<pid>/oom_adj cannot be changed for kthreads since they are immune from
-oom-killing already.
-
 /proc/<pid>/oom_score shows process' current badness score.
 
 The following heuristics are then applied:
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 175db25..6f742f6 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1003,12 +1003,7 @@ static ssize_t oom_adjust_read(struct file *file, char __user *buf,
 
 	if (!task)
 		return -ESRCH;
-	task_lock(task);
-	if (task->mm)
-		oom_adjust = task->mm->oom_adj;
-	else
-		oom_adjust = OOM_DISABLE;
-	task_unlock(task);
+	oom_adjust = task->oomkilladj;
 	put_task_struct(task);
 
 	len = snprintf(buffer, sizeof(buffer), "%i\n", oom_adjust);
@@ -1037,19 +1032,11 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
 	task = get_proc_task(file->f_path.dentry->d_inode);
 	if (!task)
 		return -ESRCH;
-	task_lock(task);
-	if (!task->mm) {
-		task_unlock(task);
-		put_task_struct(task);
-		return -EINVAL;
-	}
-	if (oom_adjust < task->mm->oom_adj && !capable(CAP_SYS_RESOURCE)) {
-		task_unlock(task);
+	if (oom_adjust < task->oomkilladj && !capable(CAP_SYS_RESOURCE)) {
 		put_task_struct(task);
 		return -EACCES;
 	}
-	task->mm->oom_adj = oom_adjust;
-	task_unlock(task);
+	task->oomkilladj = oom_adjust;
 	put_task_struct(task);
 	if (end - buffer == 0)
 		return -EIO;
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 7acc843..0042090 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -240,8 +240,6 @@ struct mm_struct {
 
 	unsigned long saved_auxv[AT_VECTOR_SIZE]; /* for /proc/PID/auxv */
 
-	s8 oom_adj;	/* OOM kill score adjustment (bit shift) */
-
 	cpumask_t cpu_vm_mask;
 
 	/* Architecture-specific MM context */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 3ab08e4..0f1ea4a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1198,6 +1198,7 @@ struct task_struct {
 	 * a short time
 	 */
 	unsigned char fpu_counter;
+	s8 oomkilladj; /* OOM kill score adjustment (bit shift). */
 #ifdef CONFIG_BLK_DEV_IO_TRACE
 	unsigned int btrace_seq;
 #endif
diff --git a/kernel/fork.c b/kernel/fork.c
index 021e113..144326b 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -426,7 +426,6 @@ static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
 	init_rwsem(&mm->mmap_sem);
 	INIT_LIST_HEAD(&mm->mmlist);
 	mm->flags = (current->mm) ? current->mm->flags : default_dump_filter;
-	mm->oom_adj = (current->mm) ? current->mm->oom_adj : 0;
 	mm->core_state = NULL;
 	mm->nr_ptes = 0;
 	set_mm_counter(mm, file_rss, 0);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 175a67a..a7b2460 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -58,7 +58,6 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 	unsigned long points, cpu_time, run_time;
 	struct mm_struct *mm;
 	struct task_struct *child;
-	int oom_adj;
 
 	task_lock(p);
 	mm = p->mm;
@@ -66,11 +65,6 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 		task_unlock(p);
 		return 0;
 	}
-	oom_adj = mm->oom_adj;
-	if (oom_adj == OOM_DISABLE) {
-		task_unlock(p);
-		return 0;
-	}
 
 	/*
 	 * The memory size of the process is the basis for the badness.
@@ -154,15 +148,15 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 		points /= 8;
 
 	/*
-	 * Adjust the score by oom_adj.
+	 * Adjust the score by oomkilladj.
 	 */
-	if (oom_adj) {
-		if (oom_adj > 0) {
+	if (p->oomkilladj) {
+		if (p->oomkilladj > 0) {
 			if (!points)
 				points = 1;
-			points <<= oom_adj;
+			points <<= p->oomkilladj;
 		} else
-			points >>= -(oom_adj);
+			points >>= -(p->oomkilladj);
 	}
 
 #ifdef DEBUG
@@ -257,8 +251,11 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 			*ppoints = ULONG_MAX;
 		}
 
+		if (p->oomkilladj == OOM_DISABLE)
+			continue;
+
 		points = badness(p, uptime.tv_sec);
-		if (points > *ppoints) {
+		if (points > *ppoints || !chosen) {
 			chosen = p;
 			*ppoints = points;
 		}
@@ -307,7 +304,8 @@ static void dump_tasks(const struct mem_cgroup *mem)
 		}
 		printk(KERN_INFO "[%5d] %5d %5d %8lu %8lu %3d     %3d %s\n",
 		       p->pid, __task_cred(p)->uid, p->tgid, mm->total_vm,
-		       get_mm_rss(mm), (int)task_cpu(p), mm->oom_adj, p->comm);
+		       get_mm_rss(mm), (int)task_cpu(p), p->oomkilladj,
+		       p->comm);
 		task_unlock(p);
 	} while_each_thread(g, p);
 }
@@ -325,8 +323,11 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
 		return;
 	}
 
-	if (!p->mm)
+	if (!p->mm) {
+		WARN_ON(1);
+		printk(KERN_WARNING "tried to kill an mm-less task!\n");
 		return;
+	}
 
 	if (verbose)
 		printk(KERN_ERR "Killed process %d (%s)\n",
@@ -348,13 +349,28 @@ static int oom_kill_task(struct task_struct *p)
 	struct mm_struct *mm;
 	struct task_struct *g, *q;
 
-	task_lock(p);
 	mm = p->mm;
-	if (!mm || mm->oom_adj == OOM_DISABLE) {
-		task_unlock(p);
+
+	/* WARNING: mm may not be dereferenced since we did not obtain its
+	 * value from get_task_mm(p).  This is OK since all we need to do is
+	 * compare mm to q->mm below.
+	 *
+	 * Furthermore, even if mm contains a non-NULL value, p->mm may
+	 * change to NULL at any time since we do not hold task_lock(p).
+	 * However, this is of no concern to us.
+	 */
+
+	if (mm == NULL)
 		return 1;
-	}
-	task_unlock(p);
+
+	/*
+	 * Don't kill the process if any threads are set to OOM_DISABLE
+	 */
+	do_each_thread(g, q) {
+		if (q->mm == mm && q->oomkilladj == OOM_DISABLE)
+			return 1;
+	} while_each_thread(g, q);
+
 	__oom_kill_task(p, 1);
 
 	/*
@@ -377,11 +393,10 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	struct task_struct *c;
 
 	if (printk_ratelimit()) {
-		task_lock(current);
 		printk(KERN_WARNING "%s invoked oom-killer: "
-			"gfp_mask=0x%x, order=%d, oom_adj=%d\n",
-			current->comm, gfp_mask, order,
-			current->mm ? current->mm->oom_adj : OOM_DISABLE);
+			"gfp_mask=0x%x, order=%d, oomkilladj=%d\n",
+			current->comm, gfp_mask, order, current->oomkilladj);
+		task_lock(current);
 		cpuset_print_task_mems_allowed(current);
 		task_unlock(current);
 		dump_stack();
@@ -394,9 +409,8 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
-	 * if its mm is still attached.
 	 */
-	if (p->mm && (p->flags & PF_EXITING)) {
+	if (p->flags & PF_EXITING) {
 		__oom_kill_task(p, 0);
 		return 0;
 	}
-- 
1.5.4.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
