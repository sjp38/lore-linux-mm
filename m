Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 79A6E6B0031
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 17:57:12 -0400 (EDT)
Date: Wed, 3 Jul 2013 17:56:54 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 07/13] sched: Split accounting of NUMA hinting faults
 that pass two-stage filter
Message-ID: <20130703215654.GN17812@cmpxchg.org>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
 <1372861300-9973-8-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372861300-9973-8-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 03, 2013 at 03:21:34PM +0100, Mel Gorman wrote:
> Ideally it would be possible to distinguish between NUMA hinting faults
> that are private to a task and those that are shared. This would require
> that the last task that accessed a page for a hinting fault would be
> recorded which would increase the size of struct page. Instead this patch
> approximates private pages by assuming that faults that pass the two-stage
> filter are private pages and all others are shared. The preferred NUMA
> node is then selected based on where the maximum number of approximately
> private faults were measured. Shared faults are not taken into
> consideration for a few reasons.

Ingo had a patch that would just encode a few bits of the PID along
with the last_nid (last_cpu in his case) member of struct page.  No
extra space required and should be accurate enough.

Otherwise this is blind to sharedness within the node the task is
currently running on, right?

> First, if there are many tasks sharing the page then they'll all move
> towards the same node. The node will be compute overloaded and then
> scheduled away later only to bounce back again. Alternatively the shared
> tasks would just bounce around nodes because the fault information is
> effectively noise. Either way accounting for shared faults the same as
> private faults may result in lower performance overall.

When the node with many shared pages is compute overloaded then there
is arguably not an optimal node for the tasks and moving them off is
inevitable.  However, the node with the most page accesses, private or
shared, is still the preferred node from a memory stand point.
Compute load being equal, the task should go to the node with 2GB of
shared memory and not to the one with 2 private pages.

If the load balancer moves the task off due to cpu load reasons,
wouldn't the settle count mechanism prevent it from bouncing back?

Likewise, if the cpu load situation changes, the balancer could move
the task back to its truly preferred node.

> The second reason is based on a hypothetical workload that has a small
> number of very important, heavily accessed private pages but a large shared
> array. The shared array would dominate the number of faults and be selected
> as a preferred node even though it's the wrong decision.

That's a scan granularity problem and I can't see how you solve it
with ignoring the shared pages.  What if the situation is opposite
with a small, heavily used shared set and many rarely used private
pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
