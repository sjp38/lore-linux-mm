Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A4F9F6B01F1
	for <linux-mm@kvack.org>; Sun, 15 Aug 2010 17:23:46 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o7FLNixO004424
	for <linux-mm@kvack.org>; Sun, 15 Aug 2010 14:23:44 -0700
Received: from pxi6 (pxi6.prod.google.com [10.243.27.6])
	by wpaz17.hot.corp.google.com with ESMTP id o7FLNeY7002430
	for <linux-mm@kvack.org>; Sun, 15 Aug 2010 14:23:43 -0700
Received: by pxi6 with SMTP id 6so1929893pxi.17
        for <linux-mm@kvack.org>; Sun, 15 Aug 2010 14:23:40 -0700 (PDT)
Date: Sun, 15 Aug 2010 14:23:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] oom: avoid killing a task if a thread sharing its
 mm cannot be killed
In-Reply-To: <20100815151819.GA3531@redhat.com>
Message-ID: <alpine.DEB.2.00.1008151409020.8727@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008142128050.31510@chino.kir.corp.google.com> <20100815151819.GA3531@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 15 Aug 2010, Oleg Nesterov wrote:

> Well. I shouldn't try to comment this patch because I do not know
> the state of the current code (and I do not understand the changelog).
> Still, it looks a bit strange to me.
> 

You snipped the changelog, so it's unclear what you don't understand about 
it.  The goal is to detect if a task A shares its mm with any other thread 
that cannot be oom killed; if so, we can't free task A's memory when it 
exits.  It's then pointless to kill task A in the first place since it 
will not solve the oom issue.

> > + * Determines whether an mm is unfreeable since a user thread attached to
> > + * it cannot be killed.  Kthreads only temporarily assume a thread's mm,
> > + * so they are not considered.
> > + *
> > + * mm need not be protected by task_lock() since it will not be
> > + * dereferened.
> > + */
> > +static bool is_mm_unfreeable(struct mm_struct *mm)
> > +{
> > +	struct task_struct *g, *q;
> > +
> > +	do_each_thread(g, q) {
> > +		if (q->mm == mm && !(q->flags & PF_KTHREAD) &&
> > +		    q->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> > +			return true;
> > +	} while_each_thread(g, q);
> 
> do_each_thread() doesn't look good. All sub-threads have the same ->mm.
> 

There's no other way to detect threads in other thread groups that share 
the same mm since subthreads of a process can have an oom_score_adj that 
differ from that process, this includes the possibility of 
OOM_SCORE_ADJ_MIN that we're interested in here.

> > @@ -160,12 +181,7 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
> >  	p = find_lock_task_mm(p);
> >  	if (!p)
> >  		return 0;
> > -
> > -	/*
> > -	 * Shortcut check for OOM_SCORE_ADJ_MIN so the entire heuristic doesn't
> > -	 * need to be executed for something that cannot be killed.
> > -	 */
> > -	if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > +	if (is_mm_unfreeable(p->mm)) {
> 
> oom_badness() becomes O(n**2), not good.
> 

No, oom_badness() becomes O(n) from O(1); select_bad_process() becomes 
slower for eligible tasks.

It would be possible to defer this check to oom_kill_process() if 
additional logic were added to its callers to retry if it fails:

 - move the check for threads sharing an mm with an OOM_SCORE_ADJ_MIN
   task to oom_kill_process() and return zero if found,

 - callers of oom_kill_process() following select_bad_process() must loop
   and select another process to kill with a badness score less than the 
   one initially selected (this could race based on variation in that
   task's memory usage, but would not infinitely select it), and

 - callers of oom_kill_process() directly on task (only 
   oom_kill_allocating_task) would fallback to using the tasklist scan
   via select_bad_process().

What do you think?

> And, more importantly. This patch makes me think ->oom_score_adj should
> be moved from ->signal to ->mm.
> 

I did that several months ago but people were unhappy with how a parent's 
oom_score_adj value would change if it did a vfork() and the child's 
oom_score_adj value was changed prior to execve().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
