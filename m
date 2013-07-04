Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 278746B0034
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 05:24:01 -0400 (EDT)
Date: Thu, 4 Jul 2013 10:23:56 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 07/13] sched: Split accounting of NUMA hinting faults
 that pass two-stage filter
Message-ID: <20130704092356.GK1875@suse.de>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
 <1372861300-9973-8-git-send-email-mgorman@suse.de>
 <20130703215654.GN17812@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130703215654.GN17812@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 03, 2013 at 05:56:54PM -0400, Johannes Weiner wrote:
> On Wed, Jul 03, 2013 at 03:21:34PM +0100, Mel Gorman wrote:
> > Ideally it would be possible to distinguish between NUMA hinting faults
> > that are private to a task and those that are shared. This would require
> > that the last task that accessed a page for a hinting fault would be
> > recorded which would increase the size of struct page. Instead this patch
> > approximates private pages by assuming that faults that pass the two-stage
> > filter are private pages and all others are shared. The preferred NUMA
> > node is then selected based on where the maximum number of approximately
> > private faults were measured. Shared faults are not taken into
> > consideration for a few reasons.
> 
> Ingo had a patch that would just encode a few bits of the PID along
> with the last_nid (last_cpu in his case) member of struct page.  No
> extra space required and should be accurate enough.
> 

Yes, I'm aware of it. I noted in the changelog that ideally we'd record
the task both to remind myself and so that the patch that introduces it
could refer to this changelog so there is some sort of logical progression
for reviewers.

I was not keen on the use of last_cpu because I felt there was an implicit
assumption that scanning would always be fast enough to record hinting
faults before a task got moved to another CPU for any reason. I feared this
would be worse as memory and task sizes increased. That's why I stayed
with tracking the nid for the two-stage filter until it could be proven
it was insufficient for some reason.

The lack of anything resembling pid tracking now is that the series is
already a bit of a mouthful and I thought the other parts were more
important for now.

> Otherwise this is blind to sharedness within the node the task is
> currently running on, right?
> 

Yes, it is.

> > First, if there are many tasks sharing the page then they'll all move
> > towards the same node. The node will be compute overloaded and then
> > scheduled away later only to bounce back again. Alternatively the shared
> > tasks would just bounce around nodes because the fault information is
> > effectively noise. Either way accounting for shared faults the same as
> > private faults may result in lower performance overall.
> 
> When the node with many shared pages is compute overloaded then there
> is arguably not an optimal node for the tasks and moving them off is
> inevitable. 

Yes. If such an event occurs then the ideal is that the task interleaves
between a subset of nodes. The situation could be partially detected by
tracking if the number of historical faults is approximately larger than
the preferred node and then interleave between the top N nodes most faulted
nodes until the working set fits. Starting the interleave should just be
a matter of coding. The difficulty is correctly backing off that if there
is a phase change.

> However, the node with the most page accesses, private or
> shared, is still the preferred node from a memory stand point.
> Compute load being equal, the task should go to the node with 2GB of
> shared memory and not to the one with 2 private pages.
> 

Agreed. The level of shared vs private needs to be detected. The problem
here is that detecting private dominated workloads is not straight-forward,
particularly as the scan rate slows as we've already discussed.

> If the load balancer moves the task off due to cpu load reasons,
> wouldn't the settle count mechanism prevent it from bouncing back?
> 
> Likewise, if the cpu load situation changes, the balancer could move
> the task back to its truly preferred node.
> 
> > The second reason is based on a hypothetical workload that has a small
> > number of very important, heavily accessed private pages but a large shared
> > array. The shared array would dominate the number of faults and be selected
> > as a preferred node even though it's the wrong decision.
> 
> That's a scan granularity problem and I can't see how you solve it
> with ignoring the shared pages. 

I acknowledge it's a problem and basically I'm making a big assumption
that private-dominated workloads are going to be the common case. Threaded
application on UMA with heavy amounts of shared data (within cache lines)
already suck in terms of performance so I'm expecting programmers already
try and avoid this sort of sharing. Obviously we are at a page granularity
here so the assumption will depend entirely on alignments and buffer sizes
so it might still fall apart.

I think that dealing with this specific problem is a series all on its
own and treating it on its own in isolation would be best.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
