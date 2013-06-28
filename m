Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id D2D376B0031
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 09:00:06 -0400 (EDT)
Date: Fri, 28 Jun 2013 14:00:03 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/8] sched: Favour moving tasks towards the preferred node
Message-ID: <20130628130003.GV1875@suse.de>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-6-git-send-email-mgorman@suse.de>
 <20130627145345.GT28407@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130627145345.GT28407@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 27, 2013 at 04:53:45PM +0200, Peter Zijlstra wrote:
> On Wed, Jun 26, 2013 at 03:38:04PM +0100, Mel Gorman wrote:
> > This patch favours moving tasks towards the preferred NUMA node when
> > it has just been selected. Ideally this is self-reinforcing as the
> > longer the the task runs on that node, the more faults it should incur
> > causing task_numa_placement to keep the task running on that node. In
> > reality a big weakness is that the nodes CPUs can be overloaded and it
> > would be more effficient to queue tasks on an idle node and migrate to
> > the new node. This would require additional smarts in the balancer so
> > for now the balancer will simply prefer to place the task on the
> > preferred node for a tunable number of PTE scans.
> 
> This changelog fails to mention why you're adding the settle stuff in
> this patch.

Updated the change.

This patch favours moving tasks towards the preferred NUMA node when it
has just been selected. Ideally this is self-reinforcing as the longer
the task runs on that node, the more faults it should incur causing
task_numa_placement to keep the task running on that node. In reality
a big weakness is that the nodes CPUs can be overloaded and it would be
more efficient to queue tasks on an idle node and migrate to the new node.
This would require additional smarts in the balancer so for now the balancer
will simply prefer to place the task on the preferred node for a PTE scans
which is controlled by the numa_balancing_settle_count sysctl. Once the
settle_count number of scans has complete the schedule is free to place
the task on an alternative node if the load is imbalanced.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
