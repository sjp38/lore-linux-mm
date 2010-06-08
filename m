Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AC2A76B01D0
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 19:50:13 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id o58No981024300
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 16:50:09 -0700
Received: from pvg3 (pvg3.prod.google.com [10.241.210.131])
	by wpaz1.hot.corp.google.com with ESMTP id o58NnfAK028183
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 16:50:08 -0700
Received: by pvg3 with SMTP id 3so1406880pvg.18
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 16:50:08 -0700 (PDT)
Date: Tue, 8 Jun 2010 16:50:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 02/18] oom: introduce find_lock_task_mm() to fix !mm
 false positives
In-Reply-To: <20100608124246.9258ccab.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1006081642370.19582@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061521310.32225@chino.kir.corp.google.com> <20100608124246.9258ccab.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, Andrew Morton wrote:

> > From: Oleg Nesterov <oleg@redhat.com>
> > 
> > Almost all ->mm == NUL checks in oom_kill.c are wrong.
> > 
> > The current code assumes that the task without ->mm has already
> > released its memory and ignores the process. However this is not
> > necessarily true when this process is multithreaded, other live
> > sub-threads can use this ->mm.
> > 
> > - Remove the "if (!p->mm)" check in select_bad_process(), it is
> >   just wrong.
> > 
> > - Add the new helper, find_lock_task_mm(), which finds the live
> >   thread which uses the memory and takes task_lock() to pin ->mm
> > 
> > - change oom_badness() to use this helper instead of just checking
> >   ->mm != NULL.
> > 
> > - As David pointed out, select_bad_process() must never choose the
> >   task without ->mm, but no matter what oom_badness() returns the
> >   task can be chosen if nothing else has been found yet.
> > 
> >   Change oom_badness() to return int, change it to return -1 if
> >   find_lock_task_mm() fails, and change select_bad_process() to
> >   check points >= 0.
> > 
> > Note! This patch is not enough, we need more changes.
> > 
> > 	- oom_badness() was fixed, but oom_kill_task() still ignores
> > 	  the task without ->mm
> > 
> > 	- oom_forkbomb_penalty() should use find_lock_task_mm() too,
> > 	  and it also needs other changes to actually find the first
> > 	  first-descendant children
> > 
> > This will be addressed later.
> > 
> > [kosaki.motohiro@jp.fujitsu.com: use in badness(), __oom_kill_task()]
> > Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> I assume from the above that we should have a Signed-off-by:kosaki
> here.  I didn't make that change yet - please advise.
> 

Oops, that was accidently dropped, sorry about that.  I folded two of his 
patches into this one since it introduces find_lock_task_mm() and it needs 
to be used in the places KOSAKI fixed as well.  His original patches are 
at

	http://marc.info/?l=linux-mm&m=127537136419677
	http://marc.info/?l=linux-mm&m=127537153619893

along with his sign-off.

> 
> >  mm/oom_kill.c |   74 +++++++++++++++++++++++++++++++++------------------------
> >  1 files changed, 43 insertions(+), 31 deletions(-)
> > 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -52,6 +52,20 @@ static int has_intersects_mems_allowed(struct task_struct *tsk)
> >  	return 0;
> >  }
> >  
> > +static struct task_struct *find_lock_task_mm(struct task_struct *p)
> > +{
> > +	struct task_struct *t = p;
> > +
> > +	do {
> > +		task_lock(t);
> > +		if (likely(t->mm))
> > +			return t;
> > +		task_unlock(t);
> > +	} while_each_thread(p, t);
> > +
> > +	return NULL;
> > +}
> 
> What pins `p'?  Ah, caller must hold tasklist_lock.
> 

I'll add a comment about this in a followup patch, it should remove the 
the confusion others have had about the naming of the function as well, 
which I think is good but could use some explanation.

> >  /**
> >   * badness - calculate a numeric value for how bad this task has been
> >   * @p: task struct of which task we should calculate
> > @@ -74,8 +88,8 @@ static int has_intersects_mems_allowed(struct task_struct *tsk)
> >  unsigned long badness(struct task_struct *p, unsigned long uptime)
> >  {
> >  	unsigned long points, cpu_time, run_time;
> > -	struct mm_struct *mm;
> >  	struct task_struct *child;
> > +	struct task_struct *c, *t;
> >  	int oom_adj = p->signal->oom_adj;
> >  	struct task_cputime task_time;
> >  	unsigned long utime;
> > @@ -84,17 +98,14 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
> >  	if (oom_adj == OOM_DISABLE)
> >  		return 0;
> >  
> > -	task_lock(p);
> > -	mm = p->mm;
> > -	if (!mm) {
> > -		task_unlock(p);
> > +	p = find_lock_task_mm(p);
> > +	if (!p)
> >  		return 0;
> > -	}
> >  
> >  	/*
> >  	 * The memory size of the process is the basis for the badness.
> >  	 */
> > -	points = mm->total_vm;
> > +	points = p->mm->total_vm;
> >  
> >  	/*
> >  	 * After this unlock we can no longer dereference local variable `mm'
> 
> This comment is stale.  Replace with p->mm.
> 

Indeed, find_lock_task_mm() returns with task_lock() held for p->mm here 
so the deference is always safe.  I'll send a followup.

> > @@ -115,12 +126,17 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
> >  	 * child is eating the vast majority of memory, adding only half
> >  	 * to the parents will make the child our kill candidate of choice.
> >  	 */
> > -	list_for_each_entry(child, &p->children, sibling) {
> > -		task_lock(child);
> > -		if (child->mm != mm && child->mm)
> > -			points += child->mm->total_vm/2 + 1;
> > -		task_unlock(child);
> > -	}
> > +	t = p;
> > +	do {
> > +		list_for_each_entry(c, &t->children, sibling) {
> > +			child = find_lock_task_mm(c);
> > +			if (child) {
> > +				if (child->mm != p->mm)
> > +					points += child->mm->total_vm/2 + 1;
> 
> What if 1000 children share the same mm?  Doesn't this give a grossly
> wrong result?
> 

It does, and that's why there has been large criticism about this 
particular part of the heuristic over the past few months.  It gets 
removed in my badness() rewrite, but the change here is concerned solely 
about the use_mm() race so closes a gap that currently exists.

> > +				task_unlock(child);
> > +			}
> > +		}
> > +	} while_each_thread(p, t);
> >  
> >  	/*
> >  	 * CPU time is in tens of seconds and run time is in thousands
> > @@ -256,9 +272,6 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
> >  	for_each_process(p) {
> >  		unsigned long points;
> >  
> > -		/* skip tasks that have already released their mm */
> > -		if (!p->mm)
> > -			continue;
> >  		/* skip the init task and kthreads */
> >  		if (is_global_init(p) || (p->flags & PF_KTHREAD))
> >  			continue;
> > @@ -385,14 +398,9 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
> >  		return;
> >  	}
> >  
> > -	task_lock(p);
> > -	if (!p->mm) {
> > -		WARN_ON(1);
> > -		printk(KERN_WARNING "tried to kill an mm-less task %d (%s)!\n",
> > -			task_pid_nr(p), p->comm);
> > -		task_unlock(p);
> > +	p = find_lock_task_mm(p);
> > +	if (!p)
> >  		return;
> > -	}
> >  
> >  	if (verbose)
> >  		printk(KERN_ERR "Killed process %d (%s) "
> > @@ -437,6 +445,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> >  			    const char *message)
> >  {
> >  	struct task_struct *c;
> > +	struct task_struct *t = p;
> >  
> >  	if (printk_ratelimit())
> >  		dump_header(p, gfp_mask, order, mem);
> > @@ -454,14 +463,17 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> >  					message, task_pid_nr(p), p->comm, points);
> >  
> >  	/* Try to kill a child first */
> 
> It'd be nice to improve the comments a bit.  This one tells us the
> "what" (which is usually obvious) but didn't tell us "why", which is
> often the unobvious.
> 

This gets modified in 
oom-sacrifice-child-with-highest-badness-score-for-parent.patch, so I'll 
expand upon it there and post a followup patch since it's already merged.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
