Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 18ECC6B01B8
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 01:13:06 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id o5H5D1l0004295
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 22:13:01 -0700
Received: from pwi5 (pwi5.prod.google.com [10.241.219.5])
	by hpaq3.eem.corp.google.com with ESMTP id o5H5CuLQ028340
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 22:13:00 -0700
Received: by pwi5 with SMTP id 5so1198585pwi.38
        for <linux-mm@kvack.org>; Wed, 16 Jun 2010 22:12:56 -0700 (PDT)
Date: Wed, 16 Jun 2010 22:12:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 16/18] oom: badness heuristic rewrite
In-Reply-To: <20100608194533.7657.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006162212490.19549@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061526540.32225@chino.kir.corp.google.com> <20100608194533.7657.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, KOSAKI Motohiro wrote:

> > diff --git a/fs/proc/base.c b/fs/proc/base.c
> > --- a/fs/proc/base.c
> > +++ b/fs/proc/base.c
> > @@ -63,6 +63,7 @@
> >  #include <linux/namei.h>
> >  #include <linux/mnt_namespace.h>
> >  #include <linux/mm.h>
> > +#include <linux/swap.h>
> >  #include <linux/rcupdate.h>
> >  #include <linux/kallsyms.h>
> >  #include <linux/stacktrace.h>
> > @@ -428,16 +429,18 @@ static const struct file_operations proc_lstats_operations = {
> >  #endif
> >  
> >  /* The badness from the OOM killer */
> > -unsigned long badness(struct task_struct *p, unsigned long uptime);
> >  static int proc_oom_score(struct task_struct *task, char *buffer)
> >  {
> >  	unsigned long points = 0;
> > -	struct timespec uptime;
> >  
> > -	do_posix_clock_monotonic_gettime(&uptime);
> >  	read_lock(&tasklist_lock);
> >  	if (pid_alive(task))
> > -		points = badness(task, uptime.tv_sec);
> > +		points = oom_badness(task->group_leader,
> > +					global_page_state(NR_INACTIVE_ANON) +
> > +					global_page_state(NR_ACTIVE_ANON) +
> > +					global_page_state(NR_INACTIVE_FILE) +
> > +					global_page_state(NR_ACTIVE_FILE) +
> > +					total_swap_pages);
> 
> Sorry I can't ack this. again and again, I try to explain why this is wrong
> (hopefully last)
> 
> 1) incompatibility
>    oom_score is one of ABI. then, we can't change this. from enduser view,
>    this change is no merit. In general, an incompatibility is allowed on very
>    limited situation such as that an end-user get much benefit than compatibility.
>    In other word, old style ABI doesn't works fine from end user view.
>    But, in this case, it isn't.
> 

There is no incompatibility here, /proc/pid/oom_score has no meaningful 
units because of the old heuristic.  The _only_ thing it represents is a 
score in comparison with other eligible tasks to decide which task to 
kill.  Thus, oom_score by itself means nothing if not compared to other 
eligible tasks.

Although deprecated, /proc/pid/oom_adj still changes 
/proc/pid/oom_score_adj with a different scale (-17 maps to -1000 and +15 
maps to +1000), so there is absolutely no userspace imcompatibility with 
this change.

> 2) technically incorrect
>    this math is not correct math. this is not represented "allowed memory".
>    example, 1) this is not accumulated mlocked memory, but it can be freed
>    task kill 2) SHM_LOCKED memory freeablility depend on IPC_RMID did or not.
>    if not, task killing doesn't free SYSV IPC memory.

Ah, very good point.  We should be using totalram_pages + total_swap_pages 
here to represent global normalization, memcg limit for CONSTRAINT_MEMCG, 
and a total of node_spanned_pages for mempolicy nodes or cpuset mems for 
CONSTAINT_MEMORY_POLICY and CONSTRAINT_CPUSET, respectively.  I'll make 
that switch in the next revision, thanks!

>    In additon, 3) This normalization doesn't works on asymmetric numa. 
>    total pages and oom are not related almostly.

What this does is represents the heuristic baseline, rss and swap, as a 
proportion depending on the type of oom constraint.  This works when 
comparing eligible tasks amongst each other because the the task with the 
highest rss and swap is the one we (normally) want to kill, minus the 3% 
privilege given to root and outside influence of /proc/pid/oom_score_adj.

We want to represent this as a proportion and not as a shear value simply 
because the task may be attached to a cpuset, a memcg, or bound to a 
mempolicy out from under the task's knowledge.  That is, we compare tasks 
sharing the same constraint for oom kill and normalize the heuristic based 
on that.  We don't want to expose a userspace interface that takes memory 
quantities directly since the task may be bound to a mempolicy, for 
instance, later and the oom_score_adj is then rendered obsolete.

> 4) scalability. if the 
>    system 10TB memory, 1 point oom score mean 10GB memory consumption.

Well, sure, a 10TB system would have a large granularity such as that :)  
But in such cases we don't necessarily care if one task is using 5GB more 
than another task using 1TB, for example.

> >  	read_unlock(&tasklist_lock);
> >  	return sprintf(buffer, "%lu\n", points);
> >  }
> > @@ -1042,7 +1045,15 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
> >  	}
> >  
> >  	task->signal->oom_adj = oom_adjust;
> > -
> > +	/*
> > +	 * Scale /proc/pid/oom_score_adj appropriately ensuring that a maximum
> > +	 * value is always attainable.
> > +	 */
> > +	if (task->signal->oom_adj == OOM_ADJUST_MAX)
> > +		task->signal->oom_score_adj = OOM_SCORE_ADJ_MAX;
> > +	else
> > +		task->signal->oom_score_adj = (oom_adjust * OOM_SCORE_ADJ_MAX) /
> > +								-OOM_DISABLE;
> >  	unlock_task_sighand(task, &flags);
> >  	put_task_struct(task);
> 
> Generically, I wasn't against the feature for rare use-case. but sorry,
> as far as I investigated, I haven't find any actual user. then, I don't
> put ack, because my reviewing basically stand on 1) how much user use this
> 2) how strongly required this from an users 3) how much side effect is there
> etc etc. not cool or not.

oom_score_adj is much more powerful than oom_adj simply because it (i) is 
in units that are understood, not a bitshift on a widely unpredictable 
heuristic, and (ii) the granularity is _much_ finer than oom_adj.  We have 
many use cases for this internally especially when we bind tasks to 
cpusets or memcg and they change in size.

> > @@ -1055,6 +1066,82 @@ static const struct file_operations proc_oom_adjust_operations = {
> >  	.llseek		= generic_file_llseek,
> >  };
> >  
> > +static ssize_t oom_score_adj_read(struct file *file, char __user *buf,
> > +					size_t count, loff_t *ppos)
> > +{
> > +	struct task_struct *task = get_proc_task(file->f_path.dentry->d_inode);
> > +	char buffer[PROC_NUMBUF];
> > +	int oom_score_adj = OOM_SCORE_ADJ_MIN;
> > +	unsigned long flags;
> > +	size_t len;
> > +
> > +	if (!task)
> > +		return -ESRCH;
> > +	if (lock_task_sighand(task, &flags)) {
> > +		oom_score_adj = task->signal->oom_score_adj;
> > +		unlock_task_sighand(task, &flags);
> > +	}
> > +	put_task_struct(task);
> > +	len = snprintf(buffer, sizeof(buffer), "%d\n", oom_score_adj);
> > +	return simple_read_from_buffer(buf, count, ppos, buffer, len);
> > +}
> > +
> > +static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
> > +					size_t count, loff_t *ppos)
> > +{
> > +	struct task_struct *task;
> > +	char buffer[PROC_NUMBUF];
> > +	unsigned long flags;
> > +	long oom_score_adj;
> > +	int err;
> > +
> > +	memset(buffer, 0, sizeof(buffer));
> > +	if (count > sizeof(buffer) - 1)
> > +		count = sizeof(buffer) - 1;
> > +	if (copy_from_user(buffer, buf, count))
> > +		return -EFAULT;
> > +
> > +	err = strict_strtol(strstrip(buffer), 0, &oom_score_adj);
> > +	if (err)
> > +		return -EINVAL;
> > +	if (oom_score_adj < OOM_SCORE_ADJ_MIN ||
> > +			oom_score_adj > OOM_SCORE_ADJ_MAX)
> > +		return -EINVAL;
> > +
> > +	task = get_proc_task(file->f_path.dentry->d_inode);
> > +	if (!task)
> > +		return -ESRCH;
> > +	if (!lock_task_sighand(task, &flags)) {
> > +		put_task_struct(task);
> > +		return -ESRCH;
> > +	}
> > +	if (oom_score_adj < task->signal->oom_score_adj &&
> > +			!capable(CAP_SYS_RESOURCE)) {
> > +		unlock_task_sighand(task, &flags);
> > +		put_task_struct(task);
> > +		return -EACCES;
> > +	}
> > +
> > +	task->signal->oom_score_adj = oom_score_adj;
> > +	/*
> > +	 * Scale /proc/pid/oom_adj appropriately ensuring that OOM_DISABLE is
> > +	 * always attainable.
> > +	 */
> > +	if (task->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> > +		task->signal->oom_adj = OOM_DISABLE;
> > +	else
> > +		task->signal->oom_adj = (oom_score_adj * OOM_ADJUST_MAX) /
> > +							OOM_SCORE_ADJ_MAX;
> > +	unlock_task_sighand(task, &flags);
> > +	put_task_struct(task);
> > +	return count;
> > +}
> > +
> > +static const struct file_operations proc_oom_score_adj_operations = {
> > +	.read		= oom_score_adj_read,
> > +	.write		= oom_score_adj_write,
> > +};
> > +
> >  #ifdef CONFIG_AUDITSYSCALL
> >  #define TMPBUFLEN 21
> >  static ssize_t proc_loginuid_read(struct file * file, char __user * buf,
> > @@ -2627,6 +2714,7 @@ static const struct pid_entry tgid_base_stuff[] = {
> >  #endif
> >  	INF("oom_score",  S_IRUGO, proc_oom_score),
> >  	REG("oom_adj",    S_IRUGO|S_IWUSR, proc_oom_adjust_operations),
> > +	REG("oom_score_adj", S_IRUGO|S_IWUSR, proc_oom_score_adj_operations),
> >  #ifdef CONFIG_AUDITSYSCALL
> >  	REG("loginuid",   S_IWUSR|S_IRUGO, proc_loginuid_operations),
> >  	REG("sessionid",  S_IRUGO, proc_sessionid_operations),
> > @@ -2961,6 +3049,7 @@ static const struct pid_entry tid_base_stuff[] = {
> >  #endif
> >  	INF("oom_score", S_IRUGO, proc_oom_score),
> >  	REG("oom_adj",   S_IRUGO|S_IWUSR, proc_oom_adjust_operations),
> > +	REG("oom_score_adj", S_IRUGO|S_IWUSR, proc_oom_score_adj_operations),
> >  #ifdef CONFIG_AUDITSYSCALL
> >  	REG("loginuid",  S_IWUSR|S_IRUGO, proc_loginuid_operations),
> >  	REG("sessionid",  S_IRUSR, proc_sessionid_operations),
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -4,6 +4,8 @@
> >   *  Copyright (C)  1998,2000  Rik van Riel
> >   *	Thanks go out to Claus Fischer for some serious inspiration and
> >   *	for goading me into coding this file...
> > + *  Copyright (C)  2010  Google, Inc.
> > + *	Rewritten by David Rientjes
> 
> don't put it.
> 
> 
> 
> >   *
> >   *  The routines in this file are used to kill a process when
> >   *  we're seriously out of memory. This gets called from __alloc_pages()
> > @@ -34,7 +36,6 @@ int sysctl_panic_on_oom;
> >  int sysctl_oom_kill_allocating_task;
> >  int sysctl_oom_dump_tasks = 1;
> >  static DEFINE_SPINLOCK(zone_scan_lock);
> > -/* #define DEBUG */
> >  
> >  /*
> >   * Do all threads of the target process overlap our allowed nodes?
> > @@ -84,139 +85,72 @@ static struct task_struct *find_lock_task_mm(struct task_struct *p)
> >  }
> >  
> >  /**
> > - * badness - calculate a numeric value for how bad this task has been
> > + * oom_badness - heuristic function to determine which candidate task to kill
> >   * @p: task struct of which task we should calculate
> > - * @uptime: current uptime in seconds
> > + * @totalpages: total present RAM allowed for page allocation
> >   *
> > - * The formula used is relatively simple and documented inline in the
> > - * function. The main rationale is that we want to select a good task
> > - * to kill when we run out of memory.
> > - *
> > - * Good in this context means that:
> > - * 1) we lose the minimum amount of work done
> > - * 2) we recover a large amount of memory
> > - * 3) we don't kill anything innocent of eating tons of memory
> > - * 4) we want to kill the minimum amount of processes (one)
> > - * 5) we try to kill the process the user expects us to kill, this
> > - *    algorithm has been meticulously tuned to meet the principle
> > - *    of least surprise ... (be careful when you change it)
> > + * The heuristic for determining which task to kill is made to be as simple and
> > + * predictable as possible.  The goal is to return the highest value for the
> > + * task consuming the most memory to avoid subsequent oom failures.
> >   */
> > -
> > -unsigned long badness(struct task_struct *p, unsigned long uptime)
> > +unsigned int oom_badness(struct task_struct *p, unsigned long totalpages)
> >  {
> > -	unsigned long points, cpu_time, run_time;
> > -	struct task_struct *child;
> > -	struct task_struct *c, *t;
> > -	int oom_adj = p->signal->oom_adj;
> > -	struct task_cputime task_time;
> > -	unsigned long utime;
> > -	unsigned long stime;
> > -
> > -	if (oom_adj == OOM_DISABLE)
> > -		return 0;
> > +	int points;
> >  
> >  	p = find_lock_task_mm(p);
> >  	if (!p)
> >  		return 0;
> >  
> >  	/*
> > -	 * The memory size of the process is the basis for the badness.
> > -	 */
> > -	points = p->mm->total_vm;
> > -
> > -	/*
> > -	 * After this unlock we can no longer dereference local variable `mm'
> > -	 */
> > -	task_unlock(p);
> > -
> > -	/*
> > -	 * swapoff can easily use up all memory, so kill those first.
> > +	 * Shortcut check for OOM_SCORE_ADJ_MIN so the entire heuristic doesn't
> > +	 * need to be executed for something that cannot be killed.
> >  	 */
> > -	if (p->flags & PF_OOM_ORIGIN)
> > -		return ULONG_MAX;
> > -
> > -	/*
> > -	 * Processes which fork a lot of child processes are likely
> > -	 * a good choice. We add half the vmsize of the children if they
> > -	 * have an own mm. This prevents forking servers to flood the
> > -	 * machine with an endless amount of children. In case a single
> > -	 * child is eating the vast majority of memory, adding only half
> > -	 * to the parents will make the child our kill candidate of choice.
> > -	 */
> > -	t = p;
> > -	do {
> > -		list_for_each_entry(c, &t->children, sibling) {
> > -			child = find_lock_task_mm(c);
> > -			if (child) {
> > -				if (child->mm != p->mm)
> > -					points += child->mm->total_vm/2 + 1;
> > -				task_unlock(child);
> > -			}
> > -		}
> > -	} while_each_thread(p, t);
> > +	if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > +		task_unlock(p);
> > +		return 0;
> > +	}
> >  
> >  	/*
> > -	 * CPU time is in tens of seconds and run time is in thousands
> > -         * of seconds. There is no particular reason for this other than
> > -         * that it turned out to work very well in practice.
> > +	 * When the PF_OOM_ORIGIN bit is set, it indicates the task should have
> > +	 * priority for oom killing.
> >  	 */
> > -	thread_group_cputime(p, &task_time);
> > -	utime = cputime_to_jiffies(task_time.utime);
> > -	stime = cputime_to_jiffies(task_time.stime);
> > -	cpu_time = (utime + stime) >> (SHIFT_HZ + 3);
> > -
> > -
> > -	if (uptime >= p->start_time.tv_sec)
> > -		run_time = (uptime - p->start_time.tv_sec) >> 10;
> > -	else
> > -		run_time = 0;
> > -
> > -	if (cpu_time)
> > -		points /= int_sqrt(cpu_time);
> > -	if (run_time)
> > -		points /= int_sqrt(int_sqrt(run_time));
> > +	if (p->flags & PF_OOM_ORIGIN) {
> > +		task_unlock(p);
> > +		return 1000;
> > +	}
> >  
> >  	/*
> > -	 * Niced processes are most likely less important, so double
> > -	 * their badness points.
> > +	 * The memory controller may have a limit of 0 bytes, so avoid a divide
> > +	 * by zero if necessary.
> >  	 */
> > -	if (task_nice(p) > 0)
> > -		points *= 2;
> 
> You removed 
>   - run time check
>   - cpu time check
>   - nice check
> 
> but no described the reason. reviewers are puzzled. How do we review
> this though we don't get your point? please write
> 

The comment for oom_badness() reflects these changes: our goal is to make 
the heuristic as simple and _predictable_ as possible, we can't allow 
runtime and cputime, for example, to avoid freeing more memory by biasing 
against those tasks.  A long cputime does not indicate the importance of a 
task, nor does it avoid subsequent oom kills in the future because we've 
freed less memory by killing other tasks as a result.

>  - What benerit is there?

It's predictable and users understand exactly what the heuristic is.

>  - Why do you think no bad effect?

These heursitics seem to have been misplaced from the beginning and there 
was a _lot_ of desire to remove them dating back a couple years: we simply 
can't convert runtime or nice levels into potential for memory freeing.  
It's much better to have a sane and predictable heuristic that will react 
in similar circumstances to do exactly what the oom killer intends to do: 
oom kill a task that will free a large amount of memory to avoid 
subsequent failures that will result in an even greater amount of work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
