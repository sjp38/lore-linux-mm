Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 323AC6B01D2
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 14:53:34 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o58IrUAL029234
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 11:53:30 -0700
Received: from pxi1 (pxi1.prod.google.com [10.243.27.1])
	by wpaz13.hot.corp.google.com with ESMTP id o58IpuS1020160
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 11:53:29 -0700
Received: by pxi1 with SMTP id 1so2329792pxi.8
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 11:53:29 -0700 (PDT)
Date: Tue, 8 Jun 2010 11:53:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 08/18] oom: sacrifice child with highest badness score
 for parent
In-Reply-To: <20100608203443.7666.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006081152080.18848@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061524470.32225@chino.kir.corp.google.com> <20100608203443.7666.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, KOSAKI Motohiro wrote:

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
> >  
> > -	/* Try to kill a child first */
> > +	/* Try to sacrifice the worst child first */
> > +	do_posix_clock_monotonic_gettime(&uptime);
> >  	do {
> > +		unsigned long cpoints;
> > +
> >  		list_for_each_entry(c, &t->children, sibling) {
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
> >  
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
> 
> better version already is there in my patch kit.
> 

Would you like to review this one?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
