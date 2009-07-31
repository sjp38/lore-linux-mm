Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8F88E6B005A
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 15:38:31 -0400 (EDT)
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id n6VJcUp4002215
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 12:38:31 -0700
Received: from pzk27 (pzk27.prod.google.com [10.243.19.155])
	by spaceape8.eur.corp.google.com with ESMTP id n6VJcRtJ009445
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 12:38:27 -0700
Received: by pzk27 with SMTP id 27so1619740pzk.2
        for <linux-mm@kvack.org>; Fri, 31 Jul 2009 12:38:26 -0700 (PDT)
Date: Fri, 31 Jul 2009 12:38:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
In-Reply-To: <20090731154823.B6EF.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0907311225480.22732@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0907301157100.9652@chino.kir.corp.google.com> <20090731093305.50bcc58d.kamezawa.hiroyu@jp.fujitsu.com> <20090731154823.B6EF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 31 Jul 2009, KOSAKI Motohiro wrote:

> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index 3ce5ae9..c64499e 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -1008,7 +1008,7 @@ static ssize_t oom_adjust_read(struct file *file, char __user *buf,
>  		return -ESRCH;
>  	task_lock(task);
>  	if (task->mm)
> -		oom_adjust = task->mm->oom_adj;
> +		oom_adjust = task->signal->oom_adj;
>  	else
>  		oom_adjust = OOM_DISABLE;
>  	task_unlock(task);

This may display a /proc/pid/oom_adj that is radically different from 
task->mm->oom_adj_cached without knowledge to userspace and you can't 
simply display task->mm>oom_adj_cached here because it gets reset on every 
write to /proc/pid/oom_adj.

> @@ -1046,12 +1046,13 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
>  		put_task_struct(task);
>  		return -EINVAL;
>  	}
> -	if (oom_adjust < task->mm->oom_adj && !capable(CAP_SYS_RESOURCE)) {
> +	if (oom_adjust < task->signal->oom_adj && !capable(CAP_SYS_RESOURCE)) {
>  		task_unlock(task);
>  		put_task_struct(task);
>  		return -EACCES;
>  	}
> -	task->mm->oom_adj = oom_adjust;
> +	task->signal->oom_adj = oom_adjust;
> +	task->mm->oom_adj_cached = OOM_CACHE_DEFAULT;
>  	task_unlock(task);
>  	put_task_struct(task);
>  	if (end - buffer == 0)
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 7acc843..f93f97f 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -240,7 +240,8 @@ struct mm_struct {
>  
>  	unsigned long saved_auxv[AT_VECTOR_SIZE]; /* for /proc/PID/auxv */
>  
> -	s8 oom_adj;	/* OOM kill score adjustment (bit shift) */
> +	s8 oom_adj_cached;	/* mirror from signal_struct->oom_adj.
> +				   in vfork case, multiple processes use the same mm. */
>  
>  	cpumask_t cpu_vm_mask;
>  
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index a7979ba..a219480 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -3,6 +3,7 @@
>  
>  /* /proc/<pid>/oom_adj set to -17 protects from the oom-killer */
>  #define OOM_DISABLE (-17)
> +#define OOM_CACHE_DEFAULT (15)
>  /* inclusive */
>  #define OOM_ADJUST_MIN (-16)
>  #define OOM_ADJUST_MAX 15
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 3ab08e4..e10b12b 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -629,6 +629,8 @@ struct signal_struct {
>  	unsigned audit_tty;
>  	struct tty_audit_buf *tty_audit_buf;
>  #endif
> +
> +	s8 oom_adj;	/* OOM kill score adjustment (bit shift) */
>  };
>  
>  /* Context switch must be unlocked if interrupts are to be enabled */

I don't believe oom_adj is an appropriate use of signal_struct, sorry.

> diff --git a/kernel/exit.c b/kernel/exit.c
> index 869dc22..c741a45 100644
> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -688,6 +689,7 @@ static void exit_mm(struct task_struct * tsk)
>  	enter_lazy_tlb(mm, current);
>  	/* We don't want this task to be frozen prematurely */
>  	clear_freeze_flag(tsk);
> +	mm->oom_adj_cached = OOM_CACHE_DEFAULT;
>  	task_unlock(tsk);
>  	mm_update_next_owner(mm);
>  	mmput(mm);

This is similiar to an early proposal that wanted to keep an array of 
oom_adj values for tasks attached to the mm in mm_struct.  The problem is 
that you're obviously losing information about all threads attached to the 
mm any time one of the threads exits or writes to /proc/pid/oom_adj.  That 
information can only be regenerated with a tasklist scan.

> diff --git a/kernel/fork.c b/kernel/fork.c
> index 9b42695..b7cb474 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -426,6 +427,7 @@ static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
>  	init_rwsem(&mm->mmap_sem);
>  	INIT_LIST_HEAD(&mm->mmlist);
>  	mm->flags = (current->mm) ? current->mm->flags : default_dump_filter;
> +	mm->oom_adj_cached = OOM_CACHE_DEFAULT;
>  	mm->core_state = NULL;
>  	mm->nr_ptes = 0;
>  	set_mm_counter(mm, file_rss, 0);
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 175a67a..eae2d78 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -58,7 +58,7 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
>  	unsigned long points, cpu_time, run_time;
>  	struct mm_struct *mm;
>  	struct task_struct *child;
> -	int oom_adj;
> +	s8 oom_adj;
>  
>  	task_lock(p);
>  	mm = p->mm;
> @@ -66,7 +66,10 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
>  		task_unlock(p);
>  		return 0;
>  	}
> -	oom_adj = mm->oom_adj;
> +
> +	if (mm->oom_adj_cached < p->signal->oom_adj)
> +		mm->oom_adj_cached = p->signal->oom_adj;

This conditional will never be true since mm->oom_adj_cached is 
initialized to 15, which is the upper bound on which p->signal->oom_adj 
may ever be, so mm->oom_adj_cached never gets changed from 
OOM_CACHE_DEFAULT.

Thus, this patch doesn't even work, and you probably would have noticed 
that if you'd checked /proc/pid/oom_score for any pid.

Even if mm->oom_adj_cached _was_ properly updated here, 
/proc/pid/oom_score would be out of sync with more negative oom_adj values 
for threads sharing the mm_struct since it calls badness() for only a 
single thread.

> +	oom_adj = mm->oom_adj_cached;
>  	if (oom_adj == OOM_DISABLE) {
>  		task_unlock(p);
>  		return 0;
> @@ -350,7 +354,7 @@ static int oom_kill_task(struct task_struct *p)
>  
>  	task_lock(p);
>  	mm = p->mm;
> -	if (!mm || mm->oom_adj == OOM_DISABLE) {
> +	if (!mm || p->signal->oom_adj == OOM_DISABLE) {
>  		task_unlock(p);
>  		return 1;
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
