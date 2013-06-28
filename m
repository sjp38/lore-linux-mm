Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 368026B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 06:24:24 -0400 (EDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 28 Jun 2013 04:24:23 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id B39083E4004E
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 04:24:00 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5SAOKfH149592
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 04:24:20 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5SAOIWu001907
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 04:24:19 -0600
Date: Fri, 28 Jun 2013 15:54:04 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/8] sched: Select a preferred node with the most numa
 hinting faults
Message-ID: <20130628102404.GE8362@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-4-git-send-email-mgorman@suse.de>
 <20130628061428.GB17195@linux.vnet.ibm.com>
 <20130628085956.GB28407@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20130628085956.GB28407@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> > >  
> > >  	struct rcu_head rcu;
> > > diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> > > index f332ec0..019baae 100644
> > > --- a/kernel/sched/core.c
> > > +++ b/kernel/sched/core.c
> > > @@ -1593,6 +1593,7 @@ static void __sched_fork(struct task_struct *p)
> > >  	p->numa_scan_seq = p->mm ? p->mm->numa_scan_seq : 0;
> > >  	p->numa_migrate_seq = p->mm ? p->mm->numa_scan_seq - 1 : 0;
> > >  	p->numa_scan_period = sysctl_numa_balancing_scan_delay;
> > > +	p->numa_preferred_nid = -1;
> > 
> > Though we may not want to inherit faults, I think the tasks generally
> > share pages with their siblings, parent. So will it make sense to
> > inherit the preferred node?
> 
> One of the patches I have locally wipes the numa state on exec(). I
> think we want to do that if we're going to think about inheriting stuff.
> 
> 

Agree, if we inherit the preferred node, we would have to reset on exec.
Since we have to reset the numa_faults also on exec, the reset of
preferred node can go in task_numa_free

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
