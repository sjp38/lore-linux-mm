Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C613B6B01DB
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 15:42:54 -0400 (EDT)
Date: Tue, 8 Jun 2010 12:42:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 02/18] oom: introduce find_lock_task_mm() to fix !mm
 false positives
Message-Id: <20100608124246.9258ccab.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1006061521310.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006061521310.32225@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 6 Jun 2010 15:34:03 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> From: Oleg Nesterov <oleg@redhat.com>
> 
> Almost all ->mm == NUL checks in oom_kill.c are wrong.
> 
> The current code assumes that the task without ->mm has already
> released its memory and ignores the process. However this is not
> necessarily true when this process is multithreaded, other live
> sub-threads can use this ->mm.
> 
> - Remove the "if (!p->mm)" check in select_bad_process(), it is
>   just wrong.
> 
> - Add the new helper, find_lock_task_mm(), which finds the live
>   thread which uses the memory and takes task_lock() to pin ->mm
> 
> - change oom_badness() to use this helper instead of just checking
>   ->mm != NULL.
> 
> - As David pointed out, select_bad_process() must never choose the
>   task without ->mm, but no matter what oom_badness() returns the
>   task can be chosen if nothing else has been found yet.
> 
>   Change oom_badness() to return int, change it to return -1 if
>   find_lock_task_mm() fails, and change select_bad_process() to
>   check points >= 0.
> 
> Note! This patch is not enough, we need more changes.
> 
> 	- oom_badness() was fixed, but oom_kill_task() still ignores
> 	  the task without ->mm
> 
> 	- oom_forkbomb_penalty() should use find_lock_task_mm() too,
> 	  and it also needs other changes to actually find the first
> 	  first-descendant children
> 
> This will be addressed later.
> 
> [kosaki.motohiro@jp.fujitsu.com: use in badness(), __oom_kill_task()]
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

I assume from the above that we should have a Signed-off-by:kosaki
here.  I didn't make that change yet - please advise.


>  mm/oom_kill.c |   74 +++++++++++++++++++++++++++++++++------------------------
>  1 files changed, 43 insertions(+), 31 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -52,6 +52,20 @@ static int has_intersects_mems_allowed(struct task_struct *tsk)
>  	return 0;
>  }
>  
> +static struct task_struct *find_lock_task_mm(struct task_struct *p)
> +{
> +	struct task_struct *t = p;
> +
> +	do {
> +		task_lock(t);
> +		if (likely(t->mm))
> +			return t;
> +		task_unlock(t);
> +	} while_each_thread(p, t);
> +
> +	return NULL;
> +}

What pins `p'?  Ah, caller must hold tasklist_lock.

>  /**
>   * badness - calculate a numeric value for how bad this task has been
>   * @p: task struct of which task we should calculate
> @@ -74,8 +88,8 @@ static int has_intersects_mems_allowed(struct task_struct *tsk)
>  unsigned long badness(struct task_struct *p, unsigned long uptime)
>  {
>  	unsigned long points, cpu_time, run_time;
> -	struct mm_struct *mm;
>  	struct task_struct *child;
> +	struct task_struct *c, *t;
>  	int oom_adj = p->signal->oom_adj;
>  	struct task_cputime task_time;
>  	unsigned long utime;
> @@ -84,17 +98,14 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
>  	if (oom_adj == OOM_DISABLE)
>  		return 0;
>  
> -	task_lock(p);
> -	mm = p->mm;
> -	if (!mm) {
> -		task_unlock(p);
> +	p = find_lock_task_mm(p);
> +	if (!p)
>  		return 0;
> -	}
>  
>  	/*
>  	 * The memory size of the process is the basis for the badness.
>  	 */
> -	points = mm->total_vm;
> +	points = p->mm->total_vm;
>  
>  	/*
>  	 * After this unlock we can no longer dereference local variable `mm'

This comment is stale.  Replace with p->mm.

> @@ -115,12 +126,17 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
>  	 * child is eating the vast majority of memory, adding only half
>  	 * to the parents will make the child our kill candidate of choice.
>  	 */
> -	list_for_each_entry(child, &p->children, sibling) {
> -		task_lock(child);
> -		if (child->mm != mm && child->mm)
> -			points += child->mm->total_vm/2 + 1;
> -		task_unlock(child);
> -	}
> +	t = p;
> +	do {
> +		list_for_each_entry(c, &t->children, sibling) {
> +			child = find_lock_task_mm(c);
> +			if (child) {
> +				if (child->mm != p->mm)
> +					points += child->mm->total_vm/2 + 1;

What if 1000 children share the same mm?  Doesn't this give a grossly
wrong result?

> +				task_unlock(child);
> +			}
> +		}
> +	} while_each_thread(p, t);
>  
>  	/*
>  	 * CPU time is in tens of seconds and run time is in thousands
> @@ -256,9 +272,6 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
>  	for_each_process(p) {
>  		unsigned long points;
>  
> -		/* skip tasks that have already released their mm */
> -		if (!p->mm)
> -			continue;
>  		/* skip the init task and kthreads */
>  		if (is_global_init(p) || (p->flags & PF_KTHREAD))
>  			continue;
> @@ -385,14 +398,9 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
>  		return;
>  	}
>  
> -	task_lock(p);
> -	if (!p->mm) {
> -		WARN_ON(1);
> -		printk(KERN_WARNING "tried to kill an mm-less task %d (%s)!\n",
> -			task_pid_nr(p), p->comm);
> -		task_unlock(p);
> +	p = find_lock_task_mm(p);
> +	if (!p)
>  		return;
> -	}
>  
>  	if (verbose)
>  		printk(KERN_ERR "Killed process %d (%s) "
> @@ -437,6 +445,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  			    const char *message)
>  {
>  	struct task_struct *c;
> +	struct task_struct *t = p;
>  
>  	if (printk_ratelimit())
>  		dump_header(p, gfp_mask, order, mem);
> @@ -454,14 +463,17 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  					message, task_pid_nr(p), p->comm, points);
>  
>  	/* Try to kill a child first */

It'd be nice to improve the comments a bit.  This one tells us the
"what" (which is usually obvious) but didn't tell us "why", which is
often the unobvious.

> -	list_for_each_entry(c, &p->children, sibling) {
> -		if (c->mm == p->mm)
> -			continue;
> -		if (mem && !task_in_mem_cgroup(c, mem))
> -			continue;
> -		if (!oom_kill_task(c))
> -			return 0;
> -	}
> +	do {
> +		list_for_each_entry(c, &t->children, sibling) {
> +			if (c->mm == p->mm)
> +				continue;
> +			if (mem && !task_in_mem_cgroup(c, mem))
> +				continue;
> +			if (!oom_kill_task(c))
> +				return 0;
> +		}
> +	} while_each_thread(p, t);
> +
>  	return oom_kill_task(p);
>  }

I'll apply this for now..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
