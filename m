Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 5CFA46B0033
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 06:07:45 -0400 (EDT)
Date: Fri, 5 Jul 2013 11:07:41 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 11/13] sched: Check current->mm before allocating NUMA
 faults
Message-ID: <20130705100741.GV1875@suse.de>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
 <1372861300-9973-12-git-send-email-mgorman@suse.de>
 <20130704124823.GB29916@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130704124823.GB29916@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 04, 2013 at 06:18:23PM +0530, Srikar Dronamraju wrote:
> * Mel Gorman <mgorman@suse.de> [2013-07-03 15:21:38]:
> 
> > task_numa_placement checks current->mm but after buffers for faults
> > have already been uselessly allocated. Move the check earlier.
> > 
> > [peterz@infradead.org: Identified the problem]
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  kernel/sched/fair.c | 22 ++++++++++++++--------
> >  1 file changed, 14 insertions(+), 8 deletions(-)
> > 
> > diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> > index 336074f..3c796b0 100644
> > --- a/kernel/sched/fair.c
> > +++ b/kernel/sched/fair.c
> > @@ -870,8 +870,6 @@ static void task_numa_placement(struct task_struct *p)
> >  	int seq, nid, max_nid = 0;
> >  	unsigned long max_faults = 0;
> > 
> > -	if (!p->mm)	/* for example, ksmd faulting in a user's mm */
> > -		return;
> >  	seq = ACCESS_ONCE(p->mm->numa_scan_seq);
> >  	if (p->numa_scan_seq == seq)
> >  		return;
> > @@ -945,6 +943,12 @@ void task_numa_fault(int last_nid, int node, int pages, bool migrated)
> >  	if (!sched_feat_numa(NUMA))
> >  		return;
> > 
> > +	/* for example, ksmd faulting in a user's mm */
> > +	if (!p->mm) {
> > +		p->numa_scan_period = sysctl_numa_balancing_scan_period_max;
> 
> Naive question:
> Why are we resetting the scan_period?
> 

At the time I wrote it I was thinking of tick times and meant to recheck
if it's necessary but then it slipped my mind. The reset is unnecessary
as curr->mm is already checked.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
