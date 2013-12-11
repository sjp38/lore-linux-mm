Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id C78216B0035
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 03:37:48 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id e49so2675596eek.21
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 00:37:48 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id e48si17973762eeh.155.2013.12.11.00.37.47
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 00:37:47 -0800 (PST)
Date: Wed, 11 Dec 2013 08:37:45 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 17/18] sched: Add tracepoints related to NUMA task
 migration
Message-ID: <20131211083744.GP11295@suse.de>
References: <1386690695-27380-1-git-send-email-mgorman@suse.de>
 <1386690695-27380-18-git-send-email-mgorman@suse.de>
 <20131210142211.099fe782c361707ab3c04742@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131210142211.099fe782c361707ab3c04742@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Dec 10, 2013 at 02:22:11PM -0800, Andrew Morton wrote:
> On Tue, 10 Dec 2013 15:51:35 +0000 Mel Gorman <mgorman@suse.de> wrote:
> 
> > This patch adds three tracepoints
> >  o trace_sched_move_numa	when a task is moved to a node
> >  o trace_sched_swap_numa	when a task is swapped with another task
> >  o trace_sched_stick_numa	when a numa-related migration fails
> > 
> > The tracepoints allow the NUMA scheduler activity to be monitored and the
> > following high-level metrics can be calculated
> > 
> >  o NUMA migrated stuck	 nr trace_sched_stick_numa
> >  o NUMA migrated idle	 nr trace_sched_move_numa
> >  o NUMA migrated swapped nr trace_sched_swap_numa
> >  o NUMA local swapped	 trace_sched_swap_numa src_nid == dst_nid (should never happen)
> >  o NUMA remote swapped	 trace_sched_swap_numa src_nid != dst_nid (should == NUMA migrated swapped)
> >  o NUMA group swapped	 trace_sched_swap_numa src_ngid == dst_ngid
> > 			 Maybe a small number of these are acceptable
> > 			 but a high number would be a major surprise.
> > 			 It would be even worse if bounces are frequent.
> >  o NUMA avg task migs.	 Average number of migrations for tasks
> >  o NUMA stddev task mig	 Self-explanatory
> >  o NUMA max task migs.	 Maximum number of migrations for a single task
> > 
> > In general the intent of the tracepoints is to help diagnose problems
> > where automatic NUMA balancing appears to be doing an excessive amount of
> > useless work.
> > 
> > ...
> >
> > --- a/kernel/sched/fair.c
> > +++ b/kernel/sched/fair.c
> > @@ -1272,11 +1272,13 @@ static int task_numa_migrate(struct task_struct *p)
> >  	p->numa_scan_period = task_scan_min(p);
> >  
> >  	if (env.best_task == NULL) {
> > -		int ret = migrate_task_to(p, env.best_cpu);
> > +		if ((ret = migrate_task_to(p, env.best_cpu)) != 0)
> > +			trace_sched_stick_numa(p, env.src_cpu, env.best_cpu);
> >  		return ret;
> >  	}
> >  
> > -	ret = migrate_swap(p, env.best_task);
> > +	if ((ret = migrate_swap(p, env.best_task)) != 0);
> 
> I'll zap that semicolon...
> 

Thanks

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
