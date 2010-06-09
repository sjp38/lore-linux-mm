Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 360CE6B01D2
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:30:32 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id o590URMt024073
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 17:30:29 -0700
Received: from pvc7 (pvc7.prod.google.com [10.241.209.135])
	by hpaq7.eem.corp.google.com with ESMTP id o590UPaO015672
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 17:30:26 -0700
Received: by pvc7 with SMTP id 7so38533pvc.34
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 17:30:25 -0700 (PDT)
Date: Tue, 8 Jun 2010 17:30:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 08/18] oom: sacrifice child with highest badness score
 for parent
In-Reply-To: <20100608133356.6e941d20.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1006081726550.19582@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061524470.32225@chino.kir.corp.google.com> <20100608133356.6e941d20.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, Andrew Morton wrote:

> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -441,8 +441,11 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> >  			    unsigned long points, struct mem_cgroup *mem,
> >  			    const char *message)
> >  {
> > +	struct task_struct *victim = p;
> >  	struct task_struct *c;
> >  	struct task_struct *t = p;
> > +	unsigned long victim_points = 0;
> > +	struct timespec uptime;
> >  
> >  	if (printk_ratelimit())
> >  		dump_header(p, gfp_mask, order, mem);
> > @@ -456,22 +459,30 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> >  		return 0;
> >  	}
> >  
> > -	printk(KERN_ERR "%s: kill process %d (%s) score %li or a child\n",
> > -					message, task_pid_nr(p), p->comm, points);
> > +	pr_err("%s: Kill process %d (%s) score %lu or sacrifice child\n",
> > +		message, task_pid_nr(p), p->comm, points);
> 
> fyi, access to another task's ->comm is racy against prctl().  Fixable
> with get_task_comm().  But that takes task_lock(), which is risky in
> this code.  The world wouldn't end if we didn't fix this ;)
> 

I'll look into doing that, thanks!

> > -	/* Try to kill a child first */
> > +	/* Try to sacrifice the worst child first */
> > +	do_posix_clock_monotonic_gettime(&uptime);
> >  	do {
> > +		unsigned long cpoints;
> 
> This could be local to the list_for_each_entry() block.
> 

Ok.

> What does "cpoints" mean?
> 

child points :)  I'll send an incremental patch.

> >  		list_for_each_entry(c, &t->children, sibling) {
> 
> I'm surprised we don't have a sched.h helper for this.  Maybe it's not
> a very common thing to do.
> 
> >  			if (c->mm == p->mm)
> >  				continue;
> >  			if (mem && !task_in_mem_cgroup(c, mem))
> >  				continue;
> > -			if (!oom_kill_task(c))
> > -				return 0;
> > +
> > +			/* badness() returns 0 if the thread is unkillable */
> > +			cpoints = badness(c, uptime.tv_sec);
> > +			if (cpoints > victim_points) {
> > +				victim = c;
> > +				victim_points = cpoints;
> > +			}
> >  		}
> >  	} while_each_thread(p, t);
> >  
> > -	return oom_kill_task(p);
> > +	return oom_kill_task(victim);
> >  }
> 
> And this function is secretly called under tasklist_lock, which is what
> pins *victim, yes?
> 

All of the out_of_memory() helper functions are called under 
tasklist_lock, which is what makes all these iterations safe.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
