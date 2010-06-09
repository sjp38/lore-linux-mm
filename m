Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 43D6C6B01DD
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:06:43 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id o5906dsK012739
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 17:06:40 -0700
Received: from pva18 (pva18.prod.google.com [10.241.209.18])
	by kpbe15.cbf.corp.google.com with ESMTP id o5906a00019882
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 17:06:38 -0700
Received: by pva18 with SMTP id 18so6116027pva.0
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 17:06:36 -0700 (PDT)
Date: Tue, 8 Jun 2010 17:06:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 03/18] oom: dump_tasks use find_lock_task_mm too
In-Reply-To: <20100608125533.086a4191.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1006081657560.19582@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061523360.32225@chino.kir.corp.google.com> <20100608125533.086a4191.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, Andrew Morton wrote:

> > From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > 
> > dump_task() should use find_lock_task_mm() too. It is necessary for
> > protecting task-exiting race.
> 
> A full description of the race would help people understand the code
> and the change.
> 

Ok, here's a description of it that you can add to KOSAKI's changelog if 
you'd like:

dump_tasks() currently filters any task that does not have an attached 
->mm since it incorrectly assumes that it must either be in process of 
exiting and has detached its memory or that it's a kernel thread; 
multithreaded tasks may actually have subthreads that have a valid ->mm 
pointer and thus those threads should actually be displayed.  This change 
finds those threads, if they exist, and emit its information along with 
the rest of the candidate tasks for kill.

> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Signed-off-by: David Rientjes <rientjes@google.com>
> > ---
> >  mm/oom_kill.c |   39 +++++++++++++++++++++------------------
> >  1 files changed, 21 insertions(+), 18 deletions(-)
> > 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -336,35 +336,38 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
> >   */
> >  static void dump_tasks(const struct mem_cgroup *mem)
> 
> The comment over this function needs to be updated to describe the role
> of incoming argument `mem'.
> 

Ok, I can take care of this as another comment cleanup in a followup 
patch.

> >  {
> > -	struct task_struct *g, *p;
> > +	struct task_struct *p;
> > +	struct task_struct *task;
> >  
> >  	printk(KERN_INFO "[ pid ]   uid  tgid total_vm      rss cpu oom_adj "
> >  	       "name\n");
> > -	do_each_thread(g, p) {
> > -		struct mm_struct *mm;
> > -
> > -		if (mem && !task_in_mem_cgroup(p, mem))
> > +	for_each_process(p) {
> 
> The switch from do_each_thread() to for_each_process() is
> unchangelogged.  It looks like a little cleanup to me.
> 
> > +		/*
> > +		 * We don't have is_global_init() check here, because the old
> > +		 * code do that. printing init process is not big matter. But
> > +		 * we don't hope to make unnecessary compatibility breaking.
> > +		 */
> 
> When merging others' patches, please do review and if necessary fix or
> enhance the comments and the changelog.  I don't think people take
> offense.
> 

Ok, I wasn't sure of the etiquette and I didn't want anything else holding 
this work up.

> Also, I don't think it's really valuable to document *changes* within
> the code comments.  This comment is referring to what the old code did
> versus the new code.  Generally it's best to just document the code as
> it presently stands and leave the documentation of the delta to the
> changelog.
> 
> That's not always true, of course - we should document oddball code
> which is left there for userspace-visible back-compatibility reasons.
> 

Agreed, I think KOSAKI might be working on a patch that moves all of this 
tasklist filtering logic to a helper function and would probably fix this 
up.  KOSAKI?

> 
> > +		if (p->flags & PF_KTHREAD)
> >  			continue;
> > -		if (!thread_group_leader(p))
> > +		if (mem && !task_in_mem_cgroup(p, mem))
> >  			continue;
> >  
> > -		task_lock(p);
> > -		mm = p->mm;
> > -		if (!mm) {
> > +		task = find_lock_task_mm(p);
> > +		if (!task) {
> >  			/*
> > -			 * total_vm and rss sizes do not exist for tasks with no
> > -			 * mm so there's no need to report them; they can't be
> > -			 * oom killed anyway.
> > +			 * Probably oom vs task-exiting race was happen and ->mm
> > +			 * have been detached. thus there's no need to report
> > +			 * them; they can't be oom killed anyway.
> >  			 */
> 
> OK, that hinted at the race but still didn't really tell readers what it is.
> 

It's actually mostly incorrect, it does short-circuit the iteration when a 
task is found to have already exited or detached its memory while we're 
holding tasklist_lock, but the old comment was probably better.  The 
scenario where this condition will be true 99% of the time is when 
iterating through the tasklist and finding a kthread.  I'll fix this up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
