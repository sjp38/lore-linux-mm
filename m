Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id E1AC86B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 09:14:39 -0500 (EST)
Received: by mail-we0-f176.google.com with SMTP id t61so2644224wes.7
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 06:14:39 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ho1si622009wjb.145.2014.01.24.06.14.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 06:14:38 -0800 (PST)
Date: Fri, 24 Jan 2014 14:14:34 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/6] numa,sched: track from which nodes NUMA faults are
 triggered
Message-ID: <20140124141434.GX4963@suse.de>
References: <1390245667-24193-1-git-send-email-riel@redhat.com>
 <1390245667-24193-3-git-send-email-riel@redhat.com>
 <20140121122130.GG4963@suse.de>
 <52DEF41F.1040105@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <52DEF41F.1040105@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@redhat.com, chegu_vinod@hp.com

On Tue, Jan 21, 2014 at 05:26:39PM -0500, Rik van Riel wrote:
> On 01/21/2014 07:21 AM, Mel Gorman wrote:
> > On Mon, Jan 20, 2014 at 02:21:03PM -0500, riel@redhat.com wrote:
> 
> >> +++ b/include/linux/sched.h
> >> @@ -1492,6 +1492,14 @@ struct task_struct {
> >>  	unsigned long *numa_faults_buffer;
> >>  
> >>  	/*
> >> +	 * Track the nodes where faults are incurred. This is not very
> >> +	 * interesting on a per-task basis, but it help with smarter
> >> +	 * numa memory placement for groups of processes.
> >> +	 */
> >> +	unsigned long *numa_faults_from;
> >> +	unsigned long *numa_faults_from_buffer;
> >> +
> > 
> > As an aside I wonder if we can derive any useful metric from this
> 
> It may provide for a better way to tune the numa scan interval
> than the current code, since the "local vs remote" ratio is not
> going to provide us much useful info when dealing with a workload
> that is spread across multiple numa nodes.
> 

Agreed. Local vs Remote handles the easier cases, particularly where the
workload has been configured to have aspects of it fit within NUMA nodes
(e.g. multiple JVMs, multiple virtual machines etc) but it's nowhere near
as useful for large single-image workloads spanning the full machine

I think in this New World Order that for single instance workloads we
would instead take into account the balance of all remote nodes. So if
all remote nodes are roughly even in terms of usage and we've decided to
interleave then slow the scan rate if the remote active nodes are evenly used

It's not something for this series just yet but I have observed a higher
system CPU usage as a result of this series. It's still far lower than
the overhead we had in the past but this is one potential idea that would
allow us to reduce the system overhead again in the future.

> >>  		grp->total_faults = p->total_numa_faults;
> >> @@ -1526,7 +1536,7 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
> >>  
> >>  	double_lock(&my_grp->lock, &grp->lock);
> >>  
> >> -	for (i = 0; i < 2*nr_node_ids; i++) {
> >> +	for (i = 0; i < 4*nr_node_ids; i++) {
> >>  		my_grp->faults[i] -= p->numa_faults[i];
> >>  		grp->faults[i] += p->numa_faults[i];
> >>  	}
> > 
> > The same obscure trick is used throughout and I'm not sure how
> > maintainable that will be. Would it be better to be explicit about this?
> 
> I have made a cleanup patch for this, using the defines you
> suggested.
> 
> >> @@ -1634,6 +1649,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
> >>  		p->numa_pages_migrated += pages;
> >>  
> >>  	p->numa_faults_buffer[task_faults_idx(node, priv)] += pages;
> >> +	p->numa_faults_from_buffer[task_faults_idx(this_node, priv)] += pages;
> >>  	p->numa_faults_locality[!!(flags & TNF_FAULT_LOCAL)] += pages;
> > 
> > this_node and node is similarly ambiguous in terms of name. Rename of
> > data_node and cpu_node would have been clearer.
> 
> I added a patch in the next version of the series.
> 
> Don't want to make the series too large, though :)
> 

Understood, it's a bit of a mouthful already.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
