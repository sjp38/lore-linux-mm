Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id D9C656B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 05:00:02 -0400 (EDT)
Date: Fri, 28 Jun 2013 10:59:56 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/8] sched: Select a preferred node with the most numa
 hinting faults
Message-ID: <20130628085956.GB28407@twins.programming.kicks-ass.net>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-4-git-send-email-mgorman@suse.de>
 <20130628061428.GB17195@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130628061428.GB17195@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 28, 2013 at 11:44:28AM +0530, Srikar Dronamraju wrote:
> * Mel Gorman <mgorman@suse.de> [2013-06-26 15:38:02]:
> 
> > This patch selects a preferred node for a task to run on based on the
> > NUMA hinting faults. This information is later used to migrate tasks
> > towards the node during balancing.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  include/linux/sched.h |  1 +
> >  kernel/sched/core.c   | 10 ++++++++++
> >  kernel/sched/fair.c   | 16 ++++++++++++++--
> >  kernel/sched/sched.h  |  2 +-
> >  4 files changed, 26 insertions(+), 3 deletions(-)
> > 
> > diff --git a/include/linux/sched.h b/include/linux/sched.h
> > index 72861b4..ba46a64 100644
> > --- a/include/linux/sched.h
> > +++ b/include/linux/sched.h
> > @@ -1507,6 +1507,7 @@ struct task_struct {
> >  	struct callback_head numa_work;
> >  
> >  	unsigned long *numa_faults;
> > +	int numa_preferred_nid;
> >  #endif /* CONFIG_NUMA_BALANCING */
> >  
> >  	struct rcu_head rcu;
> > diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> > index f332ec0..019baae 100644
> > --- a/kernel/sched/core.c
> > +++ b/kernel/sched/core.c
> > @@ -1593,6 +1593,7 @@ static void __sched_fork(struct task_struct *p)
> >  	p->numa_scan_seq = p->mm ? p->mm->numa_scan_seq : 0;
> >  	p->numa_migrate_seq = p->mm ? p->mm->numa_scan_seq - 1 : 0;
> >  	p->numa_scan_period = sysctl_numa_balancing_scan_delay;
> > +	p->numa_preferred_nid = -1;
> 
> Though we may not want to inherit faults, I think the tasks generally
> share pages with their siblings, parent. So will it make sense to
> inherit the preferred node?

One of the patches I have locally wipes the numa state on exec(). I
think we want to do that if we're going to think about inheriting stuff.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
