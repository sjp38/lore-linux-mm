Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B52B06B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 04:25:47 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [10.3.21.2])
	by smtp-out.google.com with ESMTP id o318PgTb000945
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 10:25:43 +0200
Received: from pvg2 (pvg2.prod.google.com [10.241.210.130])
	by hpaq2.eem.corp.google.com with ESMTP id o318PewR009491
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 10:25:41 +0200
Received: by pvg2 with SMTP id 2so326919pvg.0
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 01:25:40 -0700 (PDT)
Date: Thu, 1 Apr 2010 01:25:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] oom: give current access to memory reserves if it has
 been killed
In-Reply-To: <20100331224904.GA4025@redhat.com>
Message-ID: <alpine.DEB.2.00.1004010044320.6285@chino.kir.corp.google.com>
References: <20100326223356.GA20833@redhat.com> <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com>
 <20100330154659.GA12416@redhat.com> <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com> <20100331175836.GA11635@redhat.com> <alpine.DEB.2.00.1003311342410.25284@chino.kir.corp.google.com> <20100331224904.GA4025@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 1 Apr 2010, Oleg Nesterov wrote:

> Why? You ignored this part:
> 
> 	Say, right after exit_mm() we are doing acct_process(), and f_op->write()
> 	needs a page. So, you are saying that in this case __page_cache_alloc()
> 	can never trigger out_of_memory() ?
> 
> why this is not possible?
> 

It can, but the check for p->mm is sufficient since exit_notify() takes 
write_lock_irq(&tasklist_lock) that the oom killer holds for read, so the 
rule is that whenever we have a valid p->mm, we have a valid p->sighand 
and can do force_sig() while under tasklist_lock.  The only time we call 
oom_kill_process() without holding a readlock on tasklist_lock is for 
current during pagefault ooms and we know it's not exiting because it's in 
the oom killer.

> > > OK, but I guess this !p->mm check is still wrong for the same reason.
> > > In fact I do not understand why it is needed in select_bad_process()
> > > right before oom_badness() which checks ->mm too (and this check is
> > > equally wrong).
> >
> > It prevents kthreads from being killed.
> 
> No it doesn't, see use_mm(). See also another email I sent.
> 

We cannot rely on oom_badness() to filter this task because we still 
select it as our chosen task even with a badness score of 0 if !chosen, so 
we must filter these threads ahead of time:

	if (points > *ppoints || !chosen) {
		chosen = p;
		*ppoints = points;
	}

Filtering on !p->mm prevents us from doing "if (points > *ppoints || 
(!chosen && p->mm))" because it's just cleaner and makes this rule 
explicit.

Your point about p->mm being non-NULL for kthreads using use_mm() is 
taken, we should probably just change the is_global_init() check in 
select_bad_process() to p->flags & PF_KTHREAD and ensure we reject 
oom_kill_process() for them.

> > The task is in the process of exiting and will do so if its not current,
> > otherwise it will get access to memory reserves since we're obviously oom
> > in the exit path.  Thus, we'll be freeing that memory soon or recalling
> > the oom killer to kill additional tasks once those children have been
> > reparented (or one of its children was sacrificed).
> 
> Just can't understand.
> 
> OK, a bad user does
> 
> 	int sleep_forever(void *)
> 	{
> 		pause();
> 	}
> 
> 	int main(void)
> 	{
> 		pthread_create(sleep_forever);
> 		syscall(__NR_exit);
> 	}
> 
> Now, every time select_bad_process() is called it will find this process
> and PF_EXITING is true, so it just returns ERR_PTR(-1UL). And note that
> this process is not going to exit.
> 

Hmm, so it looks like we need to filter on !p->mm before checking for 
PF_EXITING so that tasks that are EXIT_ZOMBIE won't make the oom killer 
into a no-op.

> > > Say, oom_forkbomb_penalty() does list_for_each_entry(tsk->children).
> > > Again, this is not right even if we forget about !child->mm check.
> > > This list_for_each_entry() can only see the processes forked by the
> > > main thread.
> > >
> >
> > That's the intention.
> 
> Why? shouldn't oom_badness() return the same result for any thread
> in thread group? We should take all childs into account.
> 

oom_forkbomb_penalty() only cares about first-descendant children that 
do not share the same memory, so we purposely penalize the parent so that 
it is more biased to select for oom kill and then it will sacrifice these 
threads in oom_kill_process().

> > > Hmm. Why oom_forkbomb_penalty() does thread_group_cputime() under
> > > task_lock() ? It seems, ->alloc_lock() is only needed for get_mm_rss().
> > >
> >
> > Right, but we need to ensure that the check for !child->mm || child->mm ==
> > tsk->mm fails before adding in get_mm_rss(child->mm).  It can race and
> > detach its mm prior to the dereference.
> 
> Oh, yes sure, I mentioned get_mm_rss() above.
> 
> > It would be possible to move the
> > thread_group_cputime() out of this critical section,
> 
> Yes, this is what I meant.
> 

You could, but then you'd be calling thread_group_cputime() for all 
threads even though they may not share the same ->mm as tsk.

> > but I felt it was
> > better to do filter all tasks with child->mm == tsk->mm first before
> > unnecessarily finding the cputime for them.
> 
> Yes, but we can check child->mm == tsk->mm, call get_mm_counter() and drop
> task_lock().
> 

We need task_lock() to ensure child->mm hasn't detached between the check 
for child->mm == tsk->mm and get_mm_rss(child->mm).  So I'm not sure what 
you're trying to improve with this variation, it's a tradeoff between 
calling thread_group_cputime() under task_lock() for a subset of a task's 
threads when we already need to hold task_lock() anyway vs. calling it for 
all threads unconditionally.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
