Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 015FB6B0032
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 03:47:38 -0400 (EDT)
Date: Tue, 2 Jul 2013 09:46:59 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 0/6] Basic scheduler support for automatic NUMA balancing
Message-ID: <20130702074659.GC21726@dyad.programming.kicks-ass.net>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <20130628135422.GA21895@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130628135422.GA21895@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 28, 2013 at 07:24:22PM +0530, Srikar Dronamraju wrote:
> * Mel Gorman <mgorman@suse.de> [2013-06-26 15:37:59]:
> 
> > It's several months overdue and everything was quiet after 3.8 came out
> > but I recently had a chance to revisit automatic NUMA balancing for a few
> > days. I looked at basic scheduler integration resulting in the following
> > small series. Much of the following is heavily based on the numacore series
> > which in itself takes part of the autonuma series from back in November. In
> > particular it borrows heavily from Peter Ziljstra's work in "sched, numa,
> > mm: Add adaptive NUMA affinity support" but deviates too much to preserve
> > Signed-off-bys. As before, if the relevant authors are ok with it I'll
> > add Signed-off-bys (or add them yourselves if you pick the patches up).
> 
> 
> Here is a snapshot of the results of running autonuma-benchmark running on 8
> node 64 cpu system with hyper threading disabled. Ran 5 iterations for each
> setup
> 
> 	KernelVersion: 3.9.0-mainline_v39+()
> 				Testcase:      Min      Max      Avg
> 				  numa01:  1784.16  1864.15  1800.16
> 				  numa02:    32.07    32.72    32.59
> 
> 	KernelVersion: 3.9.0-mainline_v39+() + mel's patches
> 				Testcase:      Min      Max      Avg  %Change
> 				  numa01:  1752.48  1859.60  1785.60    0.82%
> 				  numa02:    47.21    60.58    53.43  -39.00%

I had to go look at these benchmarks again; and numa02 is the one that's purely
private and thus should run well with this patch set. numa01 is the purely
shared one and should fare less good for now.


So on the biggest system I've got; 4 nodes 32 cpus:

 Performance counter stats for './numa02' (5 runs):

3.10.0+ - NO_NUMA		57.973118199 seconds time elapsed    ( +-  0.71% )
3.10.0+ -    NUMA		17.619811716 seconds time elapsed    ( +-  0.32% )

3.10.0+ + patches - NO_NUMA	58.235353126 seconds time elapsed    ( +-  0.45% )
3.10.0+ + patches -    NUMA     17.580963359 seconds time elapsed    ( +-  0.09% )


Which is a small to no improvement. We'd have to look at what makes the 8 node
go funny, but I don't think its realistic to hold off on the patches for that
system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
