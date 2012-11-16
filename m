Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 0838D6B005A
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 09:14:34 -0500 (EST)
Date: Fri, 16 Nov 2012 14:14:28 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Benchmark results: "Enhanced NUMA scheduling with adaptive
 affinity"
Message-ID: <20121116141428.GZ8218@suse.de>
References: <20121112160451.189715188@chello.nl>
 <20121112184833.GA17503@gmail.com>
 <20121115100805.GS8218@suse.de>
 <CA+55aFyEJwRvQezg3oKg71Nk9+1QU7qwvo0BH4ykReKxNhFJRg@mail.gmail.com>
 <50A566FA.2090306@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <50A566FA.2090306@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On Thu, Nov 15, 2012 at 05:04:42PM -0500, Rik van Riel wrote:
> On 11/15/2012 03:32 PM, Linus Torvalds wrote:
> >Ugh.
> >
> >According to these numbers, the latest sched-numa actually regresses
> >against mainline on Specjbb.
> >
> >No way is this even close to ready for merging in the 3.8 timeframe.
> >
> >I would ask the invilved people to please come up with a set of
> >initial patches that people agree on, so that we can at least start
> >merging some of the infrastructure, and see how far we can get on at
> >least getting *started*. As I mentioned to Andrew and Mel separately,
> >nobody seems to disagree with the TLB optimization patches. What else?
> >Is Mel's set of early patches still considered a reasonable starting
> >point for everybody?
> 
> Mel's infrastructure patches, 1-14 and 17 out
> of his latest series, could be a great starting
> point.
> 

V3 increased a lot in size due to rate-limiting of migration which was
yanked out of autonuma. The rate limiting has two obvious purposes. One,
during periods of fast convergency it will prevent the memory bus being
saturated with traffic and causing stalls. As a side effect it should
decrease system CPU usage in some cases. Two, if the placement policy
completely breaks down, it will help contain the damage. If we added a vmstat
that increments when the rate limiting kicked in then users could report
broken policies by checking if the migration and rate-limited counter are
increasing. If they are both increasing rapidly then the placement policy
is broken. I think identifying when it's broken is just as important as
identifying when it's working.

The equivalent numbered patches in the new series to match what Rik suggests
above are Patches 1-17, 19. I'll swap patches 19 and 18 to avoid this mess.
The TLB patches are 33-35 but are not contested. I am going to move them
to the start of the series.

With some shuffling the question on what to consider for merging
becomes

1. TLB optimisation patches 1-3?	 	Patches  1-3
2. Stats for migration?				Patches  4-6
3. Common NUMA infrastructure?			Patches  7-21
4. Basic fault-driven policy, stats, ratelimits	Patches 22-35

Patches 36-43 are complete cabbage and should not be considered at this
stage. It should be possible to build the placement policies and the
scheduling decisions from schednuma, autonuma, some combination of the
above or something completely different on top of patches 1-35.

Peter, Ingo, Andrea?

I know that other common patches that should exist but they are
optimisations to the policies and not a fundamental design choice.

> Ingo is trying to get the mm/ code in his tree
> to be mostly the same to Mel's code anyway, so
> that is the infrastructure everybody wants.
> 
> At that point, we can focus our discussions on
> just the policy side, which could help us zoom in
> on the issues.
> 

Preferably yes and we'd have a comparison points of mainline and the most
basic of placement policies to work with that should be bisectable as a
last resort.

> It would also make it possible for us to do apple
> to apple comparisons between the various policy
> decisions, allowing us to reach a decision based
> on data, not just gut feel.
> 
> As long as each tree has its own basic infrastructure,
> we cannot do apples to apples comparisons; this has
> frustrated the discussion for months.
> 
> Having all that basic infrastructure upstream should
> short-circuit that part of the discussion.
> 

Agreed.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
