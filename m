Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 78EF86B13F0
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 10:22:26 -0500 (EST)
Date: Mon, 6 Feb 2012 16:22:23 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] [ATTEND] NUMA aware load-balancing
Message-ID: <20120206152223.GH31064@redhat.com>
References: <20120131202836.GF31817@redhat.com>
 <4F2FD25C.7070801@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F2FD25C.7070801@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Turner <pjt@google.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

Hi Paul,

On Mon, Feb 06, 2012 at 05:15:08AM -0800, Paul Turner wrote:
> I don't see it proposed as a topic yet (unless I missed it) but I spoke with
> Peter briefly and I think this would be a good opportunity in particular to
> discuss NUMA-aware load-balancing.  Currently, we only try to solve the 1-d
> problem of optimizing for weight; but there's recently been interest from
> several parties in improving this.  Issues involves proactively accounting for
> the distribution of current allocations, determining when to initiate reactive
> migration (or when not to move tasks!), and the associated grouping semantics.

Thanks for the topic proposal. We actually planned to have two topics
slots for the NUMA aware balancing. It was also proposed as a topic by
Andi and Peter but they didn't CC linux-mm on it so it wasn't visible
yet.

BTW, not sure if you noticed I also got AutoNUMA to work pretty well
over the last month. I posted the results and testcases used for the
benchmarks on linux-kernel. I'm still cleaning it up. I've yet to do
full evaluation in virt mixed environment though (for host it seems to
work as good as hard bindings so far, especially in the testcases I
developed to test it which starts from worst case memory placement
scenarios). It tracks both mm<->processes affinity and page<->thread
affinity and balances processes vs processes and threads vs threads in
the scheduler (while still maxing out all idle CPUs of course). Shared
memory accessed by different nodes is handled with some heuristic. By
default I only allow CPU_IDLE/NEWIDLE load balances across the nodes
as that performs best globally :) but tends to partition the NUMA
system more so it's less fair. I'll add a tweak to allow load_balances
also for non idle CPUs across nodes (it's a few liner change to switch
between the two modes), but even in that case it always tries to find
an affine task first (double the number of passes). Overall there's an
huge room for improvement in the scheduler area, and the way I hooked
into the scheduler to drive it in function of the NUMA statistical
info, is quite self contained but probably not the best for long term
(though at runtime I shouldn't matter, so I leave it for a second
stage cleanup if these algorithms will be proven to be worthwhile).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
