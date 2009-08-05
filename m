Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 113046B004F
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 20:46:19 -0400 (EDT)
Received: by pzk28 with SMTP id 28so3393438pzk.11
        for <linux-mm@kvack.org>; Tue, 04 Aug 2009 17:46:20 -0700 (PDT)
Date: Wed, 5 Aug 2009 09:45:34 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 1/4] oom: move oom_adj to signal_struct
Message-Id: <20090805094534.35e64fbe.minchan.kim@barrios-desktop>
In-Reply-To: <20090804192514.6A40.A69D9226@jp.fujitsu.com>
References: <20090804191031.6A3D.A69D9226@jp.fujitsu.com>
	<20090804192514.6A40.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


Hi, Kosaki. 

I am so late to invole this thread. 
But let me have a question. 

What's advantage of placing oom_adj in singal rather than task ?
I mean task->oom_adj and task->signal->oom_adj ?

I am sorry if you already discussed it at last threads. 

On Tue,  4 Aug 2009 19:25:57 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Subject: [PATCH] oom: move oom_adj to signal_struct
> 
> The commit 2ff05b2b (oom: move oom_adj value) move oom_adj value to mm_struct.
> It is very good first step for sanitize OOM.
> 
> However Paul Menage reported the commit makes regression to his job scheduler.
> Current OOM logic can kill OOM_DISABLED process.
> 
> Why? His program has the code of similar to the following.
> 
> 	...
> 	set_oom_adj(OOM_DISABLE); /* The job scheduler never killed by oom */
> 	...
> 	if (vfork() == 0) {
> 		set_oom_adj(0); /* Invoked child can be killed */
> 		execve("foo-bar-cmd")
> 	}
> 	....
> 
> vfork() parent and child are shared the same mm_struct. then above set_oom_adj(0) doesn't
> only change oom_adj for vfork() child, but also change oom_adj for vfork() parent.
> Then, vfork() parent (job scheduler) lost OOM immune and it was killed.
> 
> Actually, fork-setting-exec idiom is very frequently used in userland program. We must
> not break this assumption.
> 
> Therefore, this patch move oom_adj again. it will be moved signal_struct. it is
> truth per-process data place.
> 
> Plus, Restored writing to /proc/pid/oom_adj for a kernel thread return success again.
> changing return value might make confusing to shell-script.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Paul Menage <menage@google.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  Documentation/filesystems/proc.txt |    9 ++---
>  fs/proc/base.c                     |   33 +++++++++++---------
>  include/linux/mm_types.h           |    2 -
>  include/linux/sched.h              |    2 +
>  kernel/fork.c                      |    3 +
>  mm/oom_kill.c                      |   60 +++++++++++++++++++++++++++----------
>  6 files changed, 70 insertions(+), 39 deletions(-)
> 
> Index: b/fs/proc/base.c
> ===================================================================
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -1002,16 +1002,17 @@ static ssize_t oom_adjust_read(struct fi
>  	struct task_struct *task = get_proc_task(file->f_path.dentry->d_inode);
>  	char buffer[PROC_NUMBUF];
>  	size_t len;
> -	int oom_adjust;
> +	int oom_adjust = OOM_DISABLE;
> +	unsigned long flags;
>  
>  	if (!task)
>  		return -ESRCH;
> -	task_lock(task);
> -	if (task->mm)
> -		oom_adjust = task->mm->oom_adj;
> -	else
> -		oom_adjust = OOM_DISABLE;
> -	task_unlock(task);
> +
> +	if (lock_task_sighand(task, &flags)) {
> +		oom_adjust = task->signal->oom_adj;
> +		unlock_task_sighand(task, &flags);
> +	}
> +
>  	put_task_struct(task);
>  
>  	len = snprintf(buffer, sizeof(buffer), "%i\n", oom_adjust);
> @@ -1025,6 +1026,7 @@ static ssize_t oom_adjust_write(struct f
>  	struct task_struct *task;
>  	char buffer[PROC_NUMBUF], *end;
>  	int oom_adjust;
> +	unsigned long flags;
>  
>  	memset(buffer, 0, sizeof(buffer));
>  	if (count > sizeof(buffer) - 1)
> @@ -1040,19 +1042,20 @@ static ssize_t oom_adjust_write(struct f
>  	task = get_proc_task(file->f_path.dentry->d_inode);
>  	if (!task)
>  		return -ESRCH;
> -	task_lock(task);
> -	if (!task->mm) {
> -		task_unlock(task);
> +
> +	if (!lock_task_sighand(task, &flags)) {
>  		put_task_struct(task);
> -		return -EINVAL;
> +		return -ESRCH;
>  	}
> -	if (oom_adjust < task->mm->oom_adj && !capable(CAP_SYS_RESOURCE)) {
> -		task_unlock(task);
> +
> +	if (oom_adjust < task->signal->oom_adj && !capable(CAP_SYS_RESOURCE)) {
> +		unlock_task_sighand(task, &flags);
>  		put_task_struct(task);
>  		return -EACCES;
>  	}
> -	task->mm->oom_adj = oom_adjust;
> -	task_unlock(task);
> +
> +	task->signal->oom_adj = oom_adjust;
> +	unlock_task_sighand(task, &flags);
>  	put_task_struct(task);
>  	if (end - buffer == 0)
>  		return -EIO;
> Index: b/include/linux/mm_types.h
> ===================================================================
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -240,8 +240,6 @@ struct mm_struct {
>  
>  	unsigned long saved_auxv[AT_VECTOR_SIZE]; /* for /proc/PID/auxv */
>  
> -	s8 oom_adj;	/* OOM kill score adjustment (bit shift) */
> -
>  	cpumask_t cpu_vm_mask;
>  
>  	/* Architecture-specific MM context */
> Index: b/include/linux/sched.h
> ===================================================================
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -629,6 +629,8 @@ struct signal_struct {
>  	unsigned audit_tty;
>  	struct tty_audit_buf *tty_audit_buf;
>  #endif
> +
> +	int oom_adj;	/* OOM kill score adjustment (bit shift) */
>  };
>  
>  /* Context switch must be unlocked if interrupts are to be enabled */
> Index: b/kernel/fork.c
> ===================================================================
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -426,7 +426,6 @@ static struct mm_struct * mm_init(struct
>  	init_rwsem(&mm->mmap_sem);
>  	INIT_LIST_HEAD(&mm->mmlist);
>  	mm->flags = (current->mm) ? current->mm->flags : default_dump_filter;
> -	mm->oom_adj = (current->mm) ? current->mm->oom_adj : 0;
>  	mm->core_state = NULL;
>  	mm->nr_ptes = 0;
>  	set_mm_counter(mm, file_rss, 0);
> @@ -868,6 +867,8 @@ static int copy_signal(unsigned long clo
>  
>  	tty_audit_fork(sig);
>  
> +	sig->oom_adj = current->signal->oom_adj;
> +
>  	return 0;
>  }
>  
> Index: b/mm/oom_kill.c
> ===================================================================
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -34,6 +34,31 @@ int sysctl_oom_dump_tasks;
>  static DEFINE_SPINLOCK(zone_scan_lock);
>  /* #define DEBUG */
>  
> +int get_oom_adj(struct task_struct *tsk)
> +{
> +	unsigned long flags;
> +	int oom_adj = OOM_DISABLE;
> +
> +	if (tsk->mm && lock_task_sighand(tsk, &flags)) {
> +		oom_adj = tsk->signal->oom_adj;
> +		unlock_task_sighand(tsk, &flags);
> +	}
> +
> +	return oom_adj;
> +}
> +
> +void set_oom_adj(struct task_struct *tsk, int oom_adj)
> +{
> +	unsigned long flags;
> +
> +	if (lock_task_sighand(tsk, &flags)) {
> +		tsk->signal->oom_adj = oom_adj;
> +		unlock_task_sighand(tsk, &flags);
> +	}
> +}
> +
> +
> +
>  /**
>   * badness - calculate a numeric value for how bad this task has been
>   * @p: task struct of which task we should calculate
> @@ -60,17 +85,16 @@ unsigned long badness(struct task_struct
>  	struct task_struct *child;
>  	int oom_adj;
>  
> +	oom_adj = get_oom_adj(p);
> +	if (oom_adj == OOM_DISABLE)
> +		return 0;
> +
>  	task_lock(p);
>  	mm = p->mm;
>  	if (!mm) {
>  		task_unlock(p);
>  		return 0;
>  	}
> -	oom_adj = mm->oom_adj;
> -	if (oom_adj == OOM_DISABLE) {
> -		task_unlock(p);
> -		return 0;
> -	}
>  
>  	/*
>  	 * The memory size of the process is the basis for the badness.
> @@ -283,6 +307,8 @@ static struct task_struct *select_bad_pr
>  static void dump_tasks(const struct mem_cgroup *mem)
>  {
>  	struct task_struct *g, *p;
> +	unsigned long flags;
> +	int oom_adj;
>  
>  	printk(KERN_INFO "[ pid ]   uid  tgid total_vm      rss cpu oom_adj "
>  	       "name\n");
> @@ -294,6 +320,12 @@ static void dump_tasks(const struct mem_
>  		if (!thread_group_leader(p))
>  			continue;
>  
> +		if (!lock_task_sighand(p, &flags))
> +			continue;
> +
> +		oom_adj = p->signal->oom_adj;
> +		unlock_task_sighand(p, &flags);
> +
>  		task_lock(p);
>  		mm = p->mm;
>  		if (!mm) {
> @@ -307,7 +339,7 @@ static void dump_tasks(const struct mem_
>  		}
>  		printk(KERN_INFO "[%5d] %5d %5d %8lu %8lu %3d     %3d %s\n",
>  		       p->pid, __task_cred(p)->uid, p->tgid, mm->total_vm,
> -		       get_mm_rss(mm), (int)task_cpu(p), mm->oom_adj, p->comm);
> +		       get_mm_rss(mm), (int)task_cpu(p), oom_adj, p->comm);
>  		task_unlock(p);
>  	} while_each_thread(g, p);
>  }
> @@ -345,16 +377,11 @@ static void __oom_kill_task(struct task_
>  
>  static int oom_kill_task(struct task_struct *p)
>  {
> -	struct mm_struct *mm;
>  	struct task_struct *g, *q;
>  
> -	task_lock(p);
> -	mm = p->mm;
> -	if (!mm || mm->oom_adj == OOM_DISABLE) {
> -		task_unlock(p);
> +	if (get_oom_adj(p) == OOM_DISABLE)
>  		return 1;
> -	}
> -	task_unlock(p);
> +
>  	__oom_kill_task(p, 1);
>  
>  	/*
> @@ -363,7 +390,7 @@ static int oom_kill_task(struct task_str
>  	 * to memory reserves though, otherwise we might deplete all memory.
>  	 */
>  	do_each_thread(g, q) {
> -		if (q->mm == mm && !same_thread_group(q, p))
> +		if (q->mm == p->mm && !same_thread_group(q, p))
>  			force_sig(SIGKILL, q);
>  	} while_each_thread(g, q);
>  
> @@ -377,11 +404,12 @@ static int oom_kill_process(struct task_
>  	struct task_struct *c;
>  
>  	if (printk_ratelimit()) {
> +		int oom_adj = get_oom_adj(current);
> +
>  		task_lock(current);
>  		printk(KERN_WARNING "%s invoked oom-killer: "
>  			"gfp_mask=0x%x, order=%d, oom_adj=%d\n",
> -			current->comm, gfp_mask, order,
> -			current->mm ? current->mm->oom_adj : OOM_DISABLE);
> +			current->comm, gfp_mask, order, oom_adj);
>  		cpuset_print_task_mems_allowed(current);
>  		task_unlock(current);
>  		dump_stack();
> Index: b/Documentation/filesystems/proc.txt
> ===================================================================
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -1168,12 +1168,11 @@ CHAPTER 3: PER-PROCESS PARAMETERS
>  ------------------------------------------------------
>  
>  This file can be used to adjust the score used to select which processes should
> -be killed in an out-of-memory situation.  The oom_adj value is a characteristic
> -of the task's mm, so all threads that share an mm with pid will have the same
> +be killed in an out-of-memory situation. All threads in the process will have the same
>  oom_adj value.  A high value will increase the likelihood of this process being
>  killed by the oom-killer.  Valid values are in the range -16 to +15 as
>  explained below and a special value of -17, which disables oom-killing
> -altogether for threads sharing pid's mm.
> +altogether the process.
>  
>  The process to be killed in an out-of-memory situation is selected among all others
>  based on its badness score. This value equals the original memory size of the process
> @@ -1187,8 +1186,8 @@ the parent's score if they do not share 
>  are the prime candidates to be killed. Having only one 'hungry' child will make
>  parent less preferable than the child.
>  
> -/proc/<pid>/oom_adj cannot be changed for kthreads since they are immune from
> -oom-killing already.
> +/proc/<pid>/oom_adj can be changed for kthreads, but it's meaningless. They are immune from
> +oom-killing.
>  
>  /proc/<pid>/oom_score shows process' current badness score.
>  
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
