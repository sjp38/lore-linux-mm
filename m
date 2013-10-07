Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 857376B0037
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 14:45:28 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so7471995pbc.16
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 11:45:28 -0700 (PDT)
Message-ID: <5253013D.4090402@redhat.com>
Date: Mon, 07 Oct 2013 14:45:17 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 29/63] sched: Set preferred NUMA node based on number
 of private faults
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-30-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-30-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:29 AM, Mel Gorman wrote:
> Ideally it would be possible to distinguish between NUMA hinting faults that
> are private to a task and those that are shared. If treated identically
> there is a risk that shared pages bounce between nodes depending on
> the order they are referenced by tasks. Ultimately what is desirable is
> that task private pages remain local to the task while shared pages are
> interleaved between sharing tasks running on different nodes to give good
> average performance. This is further complicated by THP as even
> applications that partition their data may not be partitioning on a huge
> page boundary.
> 
> To start with, this patch assumes that multi-threaded or multi-process
> applications partition their data and that in general the private accesses
> are more important for cpu->memory locality in the general case. Also,
> no new infrastructure is required to treat private pages properly but
> interleaving for shared pages requires additional infrastructure.
> 
> To detect private accesses the pid of the last accessing task is required
> but the storage requirements are a high. This patch borrows heavily from
> Ingo Molnar's patch "numa, mm, sched: Implement last-CPU+PID hash tracking"
> to encode some bits from the last accessing task in the page flags as
> well as the node information. Collisions will occur but it is better than
> just depending on the node information. Node information is then used to
> determine if a page needs to migrate. The PID information is used to detect
> private/shared accesses. The preferred NUMA node is selected based on where
> the maximum number of approximately private faults were measured. Shared
> faults are not taken into consideration for a few reasons.
> 
> First, if there are many tasks sharing the page then they'll all move
> towards the same node. The node will be compute overloaded and then
> scheduled away later only to bounce back again. Alternatively the shared
> tasks would just bounce around nodes because the fault information is
> effectively noise. Either way accounting for shared faults the same as
> private faults can result in lower performance overall.
> 
> The second reason is based on a hypothetical workload that has a small
> number of very important, heavily accessed private pages but a large shared
> array. The shared array would dominate the number of faults and be selected
> as a preferred node even though it's the wrong decision.
> 
> The third reason is that multiple threads in a process will race each
> other to fault the shared page making the fault information unreliable.
> 
> [riel@redhat.com: Fix complication error when !NUMA_BALANCING]
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
