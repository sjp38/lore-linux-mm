Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 0B5526B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 10:29:29 -0400 (EDT)
Date: Fri, 28 Jun 2013 15:29:25 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 7/8] sched: Split accounting of NUMA hinting faults that
 pass two-stage filter
Message-ID: <20130628142925.GB1875@suse.de>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-8-git-send-email-mgorman@suse.de>
 <20130628070027.GD17195@linux.vnet.ibm.com>
 <20130628093625.GF29209@dyad.programming.kicks-ass.net>
 <20130628101245.GD8362@linux.vnet.ibm.com>
 <20130628103304.GF28407@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130628103304.GF28407@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 28, 2013 at 12:33:04PM +0200, Peter Zijlstra wrote:
> On Fri, Jun 28, 2013 at 03:42:45PM +0530, Srikar Dronamraju wrote:
> > > > 
> > > > > Ideally it would be possible to distinguish between NUMA hinting faults
> > > > > that are private to a task and those that are shared. This would require
> > > > > that the last task that accessed a page for a hinting fault would be
> > > > > recorded which would increase the size of struct page. Instead this patch
> > > > > approximates private pages by assuming that faults that pass the two-stage
> > > > > filter are private pages and all others are shared. The preferred NUMA
> > > > > node is then selected based on where the maximum number of approximately
> > > > > private faults were measured.
> > > > 
> > > > Should we consider only private faults for preferred node?
> > > 
> > > I don't think so; its optimal for the task to be nearest most of its pages;
> > > irrespective of whether they be private or shared.
> > 
> > Then the preferred node should have been chosen based on both the
> > private and shared faults and not just private faults.
> 
> Oh duh indeed. I totally missed it did that. Changelog also isn't giving
> rationale for this. Mel?
> 

There were a few reasons

First, if there are many tasks sharing the page then they'll all move towards
the same node. The node will be compute overloaded and then scheduled away
later only to bounce back again. Alternatively the shared tasks would
just bounce around nodes because the fault information is effectively
noise. Either way I felt that accounting for shared faults with private
faults would be slower overall.

The second reason was based on a hypothetical workload that had a small
number of very important, heavily accessed private pages but a large shared
array. The shared array would dominate the number of faults and be selected
as a preferred node even though it's the wrong decision.

The third reason was because multiple threads in a process will race
each other to fault the shared page making the information unreliable.

It is important that *something* be done with shared faults but I haven't
thought of what exactly yet. One possibility would be to give them a
different weight, maybe based on the number of active NUMA nodes, but I had
not tested anything yet. Peter suggested privately that if shared faults
dominate the workload that the shared pages would be migrated based on an
interleave policy which has some potential.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
