Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id E20136B0036
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 11:13:03 -0400 (EDT)
Date: Fri, 28 Jun 2013 17:12:56 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 7/8] sched: Split accounting of NUMA hinting faults that
 pass two-stage filter
Message-ID: <20130628151256.GC6626@twins.programming.kicks-ass.net>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-8-git-send-email-mgorman@suse.de>
 <20130628070027.GD17195@linux.vnet.ibm.com>
 <20130628093625.GF29209@dyad.programming.kicks-ass.net>
 <20130628101245.GD8362@linux.vnet.ibm.com>
 <20130628103304.GF28407@twins.programming.kicks-ass.net>
 <20130628142925.GB1875@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130628142925.GB1875@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 28, 2013 at 03:29:25PM +0100, Mel Gorman wrote:
> > Oh duh indeed. I totally missed it did that. Changelog also isn't giving
> > rationale for this. Mel?
> > 
> 
> There were a few reasons
> 
> First, if there are many tasks sharing the page then they'll all move towards
> the same node. The node will be compute overloaded and then scheduled away
> later only to bounce back again. Alternatively the shared tasks would
> just bounce around nodes because the fault information is effectively
> noise. Either way I felt that accounting for shared faults with private
> faults would be slower overall.
> 
> The second reason was based on a hypothetical workload that had a small
> number of very important, heavily accessed private pages but a large shared
> array. The shared array would dominate the number of faults and be selected
> as a preferred node even though it's the wrong decision.
> 
> The third reason was because multiple threads in a process will race
> each other to fault the shared page making the information unreliable.
> 
> It is important that *something* be done with shared faults but I haven't
> thought of what exactly yet. One possibility would be to give them a
> different weight, maybe based on the number of active NUMA nodes, but I had
> not tested anything yet. Peter suggested privately that if shared faults
> dominate the workload that the shared pages would be migrated based on an
> interleave policy which has some potential.
> 

It would be good to put something like this in the Changelog, or even as
a comment near how we select the preferred node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
