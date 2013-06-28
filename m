Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 5A9636B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 10:01:03 -0400 (EDT)
Date: Fri, 28 Jun 2013 15:00:59 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 7/8] sched: Split accounting of NUMA hinting faults that
 pass two-stage filter
Message-ID: <20130628140059.GA1875@suse.de>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-8-git-send-email-mgorman@suse.de>
 <20130627145658.GV28407@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130627145658.GV28407@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 27, 2013 at 04:56:58PM +0200, Peter Zijlstra wrote:
> On Wed, Jun 26, 2013 at 03:38:06PM +0100, Mel Gorman wrote:
> > +void task_numa_fault(int last_nid, int node, int pages, bool migrated)
> >  {
> >  	struct task_struct *p = current;
> > +	int priv = (cpu_to_node(task_cpu(p)) == last_nid);
> >  
> >  	if (!sched_feat_numa(NUMA))
> >  		return;
> >  
> >  	/* Allocate buffer to track faults on a per-node basis */
> >  	if (unlikely(!p->numa_faults)) {
> > -		int size = sizeof(*p->numa_faults) * nr_node_ids;
> > +		int size = sizeof(*p->numa_faults) * 2 * nr_node_ids;
> >  
> >  		/* numa_faults and numa_faults_buffer share the allocation */
> > -		p->numa_faults = kzalloc(size * 2, GFP_KERNEL);
> > +		p->numa_faults = kzalloc(size * 4, GFP_KERNEL);
> >  		if (!p->numa_faults)
> >  			return;
> 
> So you need a buffer 2x the size in total; but you're now allocating
> a buffer 4x larger than before.
> 
> Isn't doubling size alone sufficient?

/me slaps self

This was a rebase screwup. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
