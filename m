Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 46D896B005A
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 02:50:28 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6V6oUsX016132
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 31 Jul 2009 15:50:31 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A0FBB45DE56
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 15:50:30 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C75645DE54
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 15:50:30 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C39A81DB805D
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 15:50:29 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F694E1800B
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 15:50:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
In-Reply-To: <20090731093305.50bcc58d.kamezawa.hiroyu@jp.fujitsu.com>
References: <alpine.DEB.2.00.0907301157100.9652@chino.kir.corp.google.com> <20090731093305.50bcc58d.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20090731154823.B6EF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 31 Jul 2009 15:50:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Thu, 30 Jul 2009 12:05:30 -0700 (PDT)
> David Rientjes <rientjes@google.com> wrote:
> 
> > On Thu, 30 Jul 2009, KAMEZAWA Hiroyuki wrote:
> > 
> > > > If you have suggestions for a better name, I'd happily ack it.
> > > > 
> > > 
> > > Simply, reset_oom_adj_at_new_mm_context or some.
> > > 
> > 
> > I think it's preferred to keep the name relatively short which is an 
> > unfortuante requirement in this case.  I also prefer to start the name 
> > with "oom_adj" so it appears alongside /proc/pid/oom_adj when listed 
> > alphabetically.
> > 
> But misleading name is bad.
> 
> 
> 
> > > > > 2. More simple plan is like this, IIUC.
> > > > > 
> > > > >   fix oom-killer's select_bad_process() not to be in deadlock.
> > > > > 
> > > > 
> > > > Alternate ideas?
> > > > 
> > > At brief thiking.
> > > 
> > > 1. move oom_adj from mm_struct to signal struct. or somewhere.
> > >    (see copy_signal())
> > >    Then,
> > >     - all threads in a process will have the same oom_adj.
> > >     - vfork()'ed thread will inherit its parent's oom_adj.   
> > >     - vfork()'ed thread can override oom_adj of its own.
> > > 
> > >     In other words, oom_adj is shared when CLONE_PARENT is not set.
> > > 
> > 
> > Hmm, didn't we talk about signal_struct already?  The problem with that 
> > approach is that oom_adj values represent a killable quantity of memory, 
> > so having multiple threads sharing the same mm_struct with one set to 
> > OOM_DISABLE and the other at +15 will still livelock because the oom 
> > killer can't kill either.
> >
> > > 2. rename  mm_struct's oom_adj as shadow_oom_adj.
> > > 
> > >    update this shadow_oom_adj as the highest oom_adj among
> > >    the values all threads share this mm_struct have.
> > >    This update is done when
> > >    - mm_init()
> > >    - oom_adj is written.
> > > 
> > >    User's 
> > >    # echo XXXX > /proc/<x>/oom_adj
> > >    is not necessary to be very very fast.
> > > 
> > >    I don't think a process which calls vfork() is multi-threaded.
> > > 
> > > 3. use shadow_oom_adj in select_bad_process().
> > > 
> > 
> > Ideas 2 & 3 here seem to be a single proposal.  The problem is that it 
> > still leaves /proc/pid/oom_score to be inconsistent with the badness 
> > scoring that the oom killer will eventually use since if it oom kills one 
> > task, it must kill all tasks sharing the same mm_struct to lead to future 
> > memory freeing.
> > 
> yes.
> 
> > Additionally, if you were to set one thread to OOM_DISABLE, storing the 
> > highest oom_adj value in mm_struct isn't going to help because 
> > oom_kill_task() will still require a tasklist scan to ensure no threads 
> > sharing the mm_struct are OOM_DISABLE and the livelock persists.
> > 
> 
> Why don't you think select_bad_process()-> oom_kill_task() implementation is bad ?
> IMHO, it's bad manner to fix an os-implementation problem by adding _new_ user
> interface which is hard to understand.
> 
> 
> > In other words, the issue here is larger than the inheritance of the 
> > oom_adj value amongst children, it addresses a livelock that neither of 
> > your approaches solve.  The fix actually makes /proc/pid/oom_adj (and 
> > /proc/pid/oom_score) consistent with how the oom killer behaves.
> 
> This oom_adj_child itself is not related to livelock problem. Don't make
> the problem bigger than it is.
> oom_adj_child itself is just a problem how to handle vfork().


I made my proposal patch today.
this patch have following charactatistics.

o per-process oom_adj (by signal_struct)
o don't live-lock


Please comment.



Patch against 2.6.31-rc4

===========================
Subject: [PATCH] move oom_adj to task->signal

test program
----------------------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define BUF_SIZE 128

void oom_adj_print(void)
{
	FILE* file;
	char buf[BUF_SIZE];

	file = fopen("/proc/self/oom_adj", "r");
	if (!file) {
		perror("fopen");
		exit(1);
	}

	fscanf(file, "%s\n", buf);
	printf("%s\n", buf);

	fclose(file);
}

void oom_adj_write(int value)
{
	FILE* file;
	size_t ret;


	file = fopen("/proc/self/oom_adj", "w");
	if (!file) {
		perror("fopen");
		exit(1);
	}

	ret = fprintf(file, "%d", value);
	if (!ret) {
		perror("fprintf");
		exit(1);
	}

	fclose(file);
}

int main(void)
{
	int status;

	oom_adj_print();
	oom_adj_write(1);
	oom_adj_print();

	printf("vfork\n");
	if (vfork() == 0) {
		/* child */
		oom_adj_print();
		oom_adj_write(2);
		oom_adj_print();
		_exit(0);
	}
	wait(&status);
	oom_adj_print();

	return 0;
}

test result:
---------------------------------
% ./a.out
0
1
vfork
1
2
1



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reported-by: Paul Menage <menage@google.com>
Cc: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>,
Cc: Andrew Morton <akpm@linux-foundation.org>,
---
 fs/proc/base.c           |    7 ++++---
 include/linux/mm_types.h |    3 ++-
 include/linux/oom.h      |    1 +
 include/linux/sched.h    |    2 ++
 kernel/exit.c            |    2 ++
 kernel/fork.c            |    2 ++
 mm/oom_kill.c            |   14 +++++++++-----
 7 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 3ce5ae9..c64499e 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1008,7 +1008,7 @@ static ssize_t oom_adjust_read(struct file *file, char __user *buf,
 		return -ESRCH;
 	task_lock(task);
 	if (task->mm)
-		oom_adjust = task->mm->oom_adj;
+		oom_adjust = task->signal->oom_adj;
 	else
 		oom_adjust = OOM_DISABLE;
 	task_unlock(task);
@@ -1046,12 +1046,13 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
 		put_task_struct(task);
 		return -EINVAL;
 	}
-	if (oom_adjust < task->mm->oom_adj && !capable(CAP_SYS_RESOURCE)) {
+	if (oom_adjust < task->signal->oom_adj && !capable(CAP_SYS_RESOURCE)) {
 		task_unlock(task);
 		put_task_struct(task);
 		return -EACCES;
 	}
-	task->mm->oom_adj = oom_adjust;
+	task->signal->oom_adj = oom_adjust;
+	task->mm->oom_adj_cached = OOM_CACHE_DEFAULT;
 	task_unlock(task);
 	put_task_struct(task);
 	if (end - buffer == 0)
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 7acc843..f93f97f 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -240,7 +240,8 @@ struct mm_struct {
 
 	unsigned long saved_auxv[AT_VECTOR_SIZE]; /* for /proc/PID/auxv */
 
-	s8 oom_adj;	/* OOM kill score adjustment (bit shift) */
+	s8 oom_adj_cached;	/* mirror from signal_struct->oom_adj.
+				   in vfork case, multiple processes use the same mm. */
 
 	cpumask_t cpu_vm_mask;
 
diff --git a/include/linux/oom.h b/include/linux/oom.h
index a7979ba..a219480 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -3,6 +3,7 @@
 
 /* /proc/<pid>/oom_adj set to -17 protects from the oom-killer */
 #define OOM_DISABLE (-17)
+#define OOM_CACHE_DEFAULT (15)
 /* inclusive */
 #define OOM_ADJUST_MIN (-16)
 #define OOM_ADJUST_MAX 15
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 3ab08e4..e10b12b 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -629,6 +629,8 @@ struct signal_struct {
 	unsigned audit_tty;
 	struct tty_audit_buf *tty_audit_buf;
 #endif
+
+	s8 oom_adj;	/* OOM kill score adjustment (bit shift) */
 };
 
 /* Context switch must be unlocked if interrupts are to be enabled */
diff --git a/kernel/exit.c b/kernel/exit.c
index 869dc22..c741a45 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -48,6 +48,7 @@
 #include <linux/fs_struct.h>
 #include <linux/init_task.h>
 #include <linux/perf_counter.h>
+#include <linux/oom.h>
 #include <trace/events/sched.h>
 
 #include <asm/uaccess.h>
@@ -688,6 +689,7 @@ static void exit_mm(struct task_struct * tsk)
 	enter_lazy_tlb(mm, current);
 	/* We don't want this task to be frozen prematurely */
 	clear_freeze_flag(tsk);
+	mm->oom_adj_cached = OOM_CACHE_DEFAULT;
 	task_unlock(tsk);
 	mm_update_next_owner(mm);
 	mmput(mm);
diff --git a/kernel/fork.c b/kernel/fork.c
index 9b42695..b7cb474 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -62,6 +62,7 @@
 #include <linux/fs_struct.h>
 #include <linux/magic.h>
 #include <linux/perf_counter.h>
+#include <linux/oom.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -426,6 +427,7 @@ static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
 	init_rwsem(&mm->mmap_sem);
 	INIT_LIST_HEAD(&mm->mmlist);
 	mm->flags = (current->mm) ? current->mm->flags : default_dump_filter;
+	mm->oom_adj_cached = OOM_CACHE_DEFAULT;
 	mm->core_state = NULL;
 	mm->nr_ptes = 0;
 	set_mm_counter(mm, file_rss, 0);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 175a67a..eae2d78 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -58,7 +58,7 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 	unsigned long points, cpu_time, run_time;
 	struct mm_struct *mm;
 	struct task_struct *child;
-	int oom_adj;
+	s8 oom_adj;
 
 	task_lock(p);
 	mm = p->mm;
@@ -66,7 +66,10 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 		task_unlock(p);
 		return 0;
 	}
-	oom_adj = mm->oom_adj;
+
+	if (mm->oom_adj_cached < p->signal->oom_adj)
+		mm->oom_adj_cached = p->signal->oom_adj;
+	oom_adj = mm->oom_adj_cached;
 	if (oom_adj == OOM_DISABLE) {
 		task_unlock(p);
 		return 0;
@@ -307,7 +310,8 @@ static void dump_tasks(const struct mem_cgroup *mem)
 		}
 		printk(KERN_INFO "[%5d] %5d %5d %8lu %8lu %3d     %3d %s\n",
 		       p->pid, __task_cred(p)->uid, p->tgid, mm->total_vm,
-		       get_mm_rss(mm), (int)task_cpu(p), mm->oom_adj, p->comm);
+		       get_mm_rss(mm), (int)task_cpu(p), p->signal->oom_adj,
+		       p->comm);
 		task_unlock(p);
 	} while_each_thread(g, p);
 }
@@ -350,7 +354,7 @@ static int oom_kill_task(struct task_struct *p)
 
 	task_lock(p);
 	mm = p->mm;
-	if (!mm || mm->oom_adj == OOM_DISABLE) {
+	if (!mm || p->signal->oom_adj == OOM_DISABLE) {
 		task_unlock(p);
 		return 1;
 	}
@@ -381,7 +385,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		printk(KERN_WARNING "%s invoked oom-killer: "
 			"gfp_mask=0x%x, order=%d, oom_adj=%d\n",
 			current->comm, gfp_mask, order,
-			current->mm ? current->mm->oom_adj : OOM_DISABLE);
+			current->mm ? current->signal->oom_adj : OOM_DISABLE);
 		cpuset_print_task_mems_allowed(current);
 		task_unlock(current);
 		dump_stack();
-- 
1.6.0.GIT




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
