Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 21BF06B01C4
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 14:45:30 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id o58IjPIV025984
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 11:45:25 -0700
Received: from pxi19 (pxi19.prod.google.com [10.243.27.19])
	by hpaq12.eem.corp.google.com with ESMTP id o58IjOc7030478
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 11:45:24 -0700
Received: by pxi19 with SMTP id 19so2322545pxi.17
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 11:45:23 -0700 (PDT)
Date: Tue, 8 Jun 2010 11:45:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 02/18] oom: sacrifice child with highest badness
 score for parent
In-Reply-To: <20100607221121.8781.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006081144460.18848@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010013220.29202@chino.kir.corp.google.com> <20100607221121.8781.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, KOSAKI Motohiro wrote:

> > @@ -447,19 +450,27 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> >  		return 0;
> >  	}
> >  
> > -	printk(KERN_ERR "%s: kill process %d (%s) score %li or a child\n",
> > -					message, task_pid_nr(p), p->comm, points);
> > +	pr_err("%s: Kill process %d (%s) with score %lu or sacrifice child\n",
> > +		message, task_pid_nr(p), p->comm, points);
> >  
> > -	/* Try to kill a child first */
> > +	do_posix_clock_monotonic_gettime(&uptime);
> > +	/* Try to sacrifice the worst child first */
> >  	list_for_each_entry(c, &p->children, sibling) {
> > +		unsigned long cpoints;
> > +
> >  		if (c->mm == p->mm)
> >  			continue;
> >  		if (mem && !task_in_mem_cgroup(c, mem))
> >  			continue;
> > -		if (!oom_kill_task(c))
> > -			return 0;
> > +
> 
> need to the check of cpuset (and memplicy) memory intersection here, probably.
> otherwise, this may selected innocence task.
> 

I'll do this, then, if you don't want to post your own patch.  Fine.

> also, OOM_DISABL check is necessary?
> 

No, badness() is 0 for tasks that are OOM_DISABLE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
