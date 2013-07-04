Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 801CD6B0033
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 15:36:51 -0400 (EDT)
Date: Thu, 4 Jul 2013 15:36:38 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 07/13] sched: Split accounting of NUMA hinting faults
 that pass two-stage filter
Message-ID: <20130704193638.GP17812@cmpxchg.org>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
 <1372861300-9973-8-git-send-email-mgorman@suse.de>
 <20130703215654.GN17812@cmpxchg.org>
 <20130704092356.GK1875@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130704092356.GK1875@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 04, 2013 at 10:23:56AM +0100, Mel Gorman wrote:
> On Wed, Jul 03, 2013 at 05:56:54PM -0400, Johannes Weiner wrote:
> > On Wed, Jul 03, 2013 at 03:21:34PM +0100, Mel Gorman wrote:
> > > Ideally it would be possible to distinguish between NUMA hinting faults
> > > that are private to a task and those that are shared. This would require
> > > that the last task that accessed a page for a hinting fault would be
> > > recorded which would increase the size of struct page. Instead this patch
> > > approximates private pages by assuming that faults that pass the two-stage
> > > filter are private pages and all others are shared. The preferred NUMA
> > > node is then selected based on where the maximum number of approximately
> > > private faults were measured. Shared faults are not taken into
> > > consideration for a few reasons.
> > 
> > Ingo had a patch that would just encode a few bits of the PID along
> > with the last_nid (last_cpu in his case) member of struct page.  No
> > extra space required and should be accurate enough.
> > 
> 
> Yes, I'm aware of it. I noted in the changelog that ideally we'd record
> the task both to remind myself and so that the patch that introduces it
> could refer to this changelog so there is some sort of logical progression
> for reviewers.
> 
> I was not keen on the use of last_cpu because I felt there was an implicit
> assumption that scanning would always be fast enough to record hinting
> faults before a task got moved to another CPU for any reason. I feared this
> would be worse as memory and task sizes increased. That's why I stayed
> with tracking the nid for the two-stage filter until it could be proven
> it was insufficient for some reason.
> 
> The lack of anything resembling pid tracking now is that the series is
> already a bit of a mouthful and I thought the other parts were more
> important for now.

Fair enough.

> > Otherwise this is blind to sharedness within the node the task is
> > currently running on, right?
> > 
> 
> Yes, it is.
> 
> > > First, if there are many tasks sharing the page then they'll all move
> > > towards the same node. The node will be compute overloaded and then
> > > scheduled away later only to bounce back again. Alternatively the shared
> > > tasks would just bounce around nodes because the fault information is
> > > effectively noise. Either way accounting for shared faults the same as
> > > private faults may result in lower performance overall.
> > 
> > When the node with many shared pages is compute overloaded then there
> > is arguably not an optimal node for the tasks and moving them off is
> > inevitable. 
> 
> Yes. If such an event occurs then the ideal is that the task interleaves
> between a subset of nodes. The situation could be partially detected by
> tracking if the number of historical faults is approximately larger than
> the preferred node and then interleave between the top N nodes most faulted
> nodes until the working set fits. Starting the interleave should just be
> a matter of coding. The difficulty is correctly backing off that if there
> is a phase change.

Agreed, optimizing second-best placement can be dealt with later.  I'm
worried about optimal placement, though.

And I'm worried about skewing memory access statistics in order to
steer future situations the CPU load balancer should handle instead.

> > However, the node with the most page accesses, private or
> > shared, is still the preferred node from a memory stand point.
> > Compute load being equal, the task should go to the node with 2GB of
> > shared memory and not to the one with 2 private pages.
> > 
> 
> Agreed. The level of shared vs private needs to be detected. The problem
> here is that detecting private dominated workloads is not straight-forward,
> particularly as the scan rate slows as we've already discussed.

I was going for the opposite conclusion: that it does not matter
whether memory is accessed privately or in a shared fashion, because
there is no obvious connection to its access frequency, not to me at
least.  Short of accurate access frequency sampling and supportive
data, the node with most accesses in general should be the preferred
node, not the one with the most private accesses because it's the
smaller assumption to make.

> > > The second reason is based on a hypothetical workload that has a small
> > > number of very important, heavily accessed private pages but a large shared
> > > array. The shared array would dominate the number of faults and be selected
> > > as a preferred node even though it's the wrong decision.
> > 
> > That's a scan granularity problem and I can't see how you solve it
> > with ignoring the shared pages. 
> 
> I acknowledge it's a problem and basically I'm making a big assumption
> that private-dominated workloads are going to be the common case. Threaded
> application on UMA with heavy amounts of shared data (within cache lines)
> already suck in terms of performance so I'm expecting programmers already
> try and avoid this sort of sharing. Obviously we are at a page granularity
> here so the assumption will depend entirely on alignments and buffer sizes
> so it might still fall apart.

Don't basically all VM-based mulithreaded programs have this usage
pattern?  The whole runtime (text, heap) is shared between threads.
If some thread-local memory spills over to another node, should the
scheduler move this thread off node from a memory standpoint?  I don't
think so at all.  I would expect it to always gravitate back towards
this node with the VM on it, only get moved off for CPU load reasons,
and get moved back as soon as the load situation permits.

Meanwhile, if there is little shared memory and private memory spills
over to other nodes, you still don't know which node's memory is more
frequently used beyond scan period granularity.  Ignoring shared
memory accesses would not actually help finding the right node in this
case.  You might even make it worse: since private accesses are all
treated equally, you assume equal access frequency among them.  Shared
accesses could now be the distinguishing data point to tell which node
sees more memory accesses.

> I think that dealing with this specific problem is a series all on its
> own and treating it on its own in isolation would be best.

The scan granularity issue is indeed a separate issue, I'm just really
suspicious of the assumption you make to attempt working around it in
this patch, because of the risk of moving away from optimal placement
prematurely.

The null hypothesis is that there is no connection between accesses
being shared or private and their actual frequency.  I would be
interested if this assumption has had a positive effect in your
testing or if this is based on the theoretical cases you mentioned in
the changelog, i.e. why you chose to make the bigger assumption.
-ENODATA ;-)

I think answering this question is precisely the scope of this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
