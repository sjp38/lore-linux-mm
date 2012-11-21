Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 3CCD56B004D
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 14:56:46 -0500 (EST)
Date: Wed, 21 Nov 2012 19:56:38 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
Message-ID: <20121121195637.GO8218@suse.de>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
 <20121119162909.GL8218@suse.de>
 <20121119191339.GA11701@gmail.com>
 <20121121103859.GU8218@suse.de>
 <20121121193712.GJ3773@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121121193712.GJ3773@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Wed, Nov 21, 2012 at 08:37:12PM +0100, Andrea Arcangeli wrote:
> Hi,
> 
> On Wed, Nov 21, 2012 at 10:38:59AM +0000, Mel Gorman wrote:
> > HACKBENCH PIPES
> >                          3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
> >                rc6-stats-v4r12   rc6-schednuma-v16r2rc6-autonuma-v28fastr3       rc6-moron-v4r38    rc6-twostage-v4r38
> > Procs 1       0.0320 (  0.00%)      0.0354 (-10.53%)      0.0410 (-28.28%)      0.0310 (  3.00%)      0.0296 (  7.55%)
> > Procs 4       0.0560 (  0.00%)      0.0699 (-24.87%)      0.0641 (-14.47%)      0.0556 (  0.79%)      0.0562 ( -0.36%)
> > Procs 8       0.0850 (  0.00%)      0.1084 (-27.51%)      0.1397 (-64.30%)      0.0833 (  1.96%)      0.0953 (-12.07%)
> > Procs 12      0.1047 (  0.00%)      0.1084 ( -3.54%)      0.1789 (-70.91%)      0.0990 (  5.44%)      0.1127 ( -7.72%)
> > Procs 16      0.1276 (  0.00%)      0.1323 ( -3.67%)      0.1395 ( -9.34%)      0.1236 (  3.16%)      0.1240 (  2.83%)
> > Procs 20      0.1405 (  0.00%)      0.1578 (-12.29%)      0.2452 (-74.52%)      0.1471 ( -4.73%)      0.1454 ( -3.50%)
> > Procs 24      0.1823 (  0.00%)      0.1800 (  1.24%)      0.3030 (-66.22%)      0.1776 (  2.58%)      0.1574 ( 13.63%)
> > Procs 28      0.2019 (  0.00%)      0.2143 ( -6.13%)      0.3403 (-68.52%)      0.2000 (  0.94%)      0.1983 (  1.78%)
> > Procs 32      0.2162 (  0.00%)      0.2329 ( -7.71%)      0.6526 (-201.85%)      0.2235 ( -3.36%)      0.2158 (  0.20%)
> > Procs 36      0.2354 (  0.00%)      0.2577 ( -9.47%)      0.4468 (-89.77%)      0.2619 (-11.24%)      0.2451 ( -4.11%)
> > Procs 40      0.2600 (  0.00%)      0.2850 ( -9.62%)      0.5247 (-101.79%)      0.2724 ( -4.77%)      0.2646 ( -1.75%)
> > 
> > The number of procs hackbench is running is too low here for a 48-core
> > machine. It should have been reconfigured but this is better than nothing.
> > 
> > schednuma and autonuma both show large regressions in the performance here.
> > I do not investigate why but as there are a number of scheduler changes
> > it could be anything.
> 
> Strange, last time I tested hackbench it was perfectly ok, I even had
> this test shown in some of the pdf.
> 

It's been rebased to 3.7-rc6 since so there may be an incompatible
scheduler change somewhere.

> Lately (post my last hackbench run) I disabled the affine wakeups
> cross-node and pipes use sd_affine wakeups. That could matter for
> these heavy scheduling tests as it practically disables the _sync in
> wake_up_interruptible_sync_poll used by the pipe code, if the waker
> CPU is in a different node than the wakee prev_cpu. I discussed this
> with Mike and he liked this change IIRC but it's the first thing that
> should be checked at the light of above regression.
> 

Understood. I found in early profiles that the mutex_spin_on_owner logic
was also relevant but did not pin down why. I expected it was contention
on mmap_sem due to the PTE scanner but have not had the chance to
verify.

> > PAGE FAULT TEST
> > 
> > This is a microbenchmark for page faults. The number of clients are badly ordered
> > which again, I really should fix but anyway.
> > 
> >                               3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
> >                     rc6-stats-v4r12   rc6-schednuma-v16r2rc6-autonuma-v28fastr3       rc6-moron-v4r38    rc6-twostage-v4r38
> > System     1       8.0710 (  0.00%)      8.1085 ( -0.46%)      8.0925 ( -0.27%)      8.0170 (  0.67%)     37.3075 (-362.24%
> > System     10      9.4975 (  0.00%)      9.5690 ( -0.75%)     12.0055 (-26.41%)      9.5915 ( -0.99%)      9.5835 ( -0.91%)
> > System     11      9.7740 (  0.00%)      9.7915 ( -0.18%)     13.4890 (-38.01%)      9.7275 (  0.48%)      9.6810 (  0.95%)
> 
> No real clue on this one as I should look in what the test does.

It's the PFT test in MMTests and it should run it by default out of the
box. Running it will fetch the relevant source and it'll be in
work/testsdisk/sources

> It
> might be related to THP splits though. I can't imagine anything else
> because there's nothing at all in autonuma that alters the page faults
> (except from arming NUMA hinting faults which should be lighter in
> autonuma than in the other implementation using task work).
> 
> Chances are the faults are tested by touching bytes at different 4k
> offsets in the same 2m naturally aligned virtual range.
> 
> Hugh THP native migration patch will clarify things on the above.
> 

The current sets of tests been run has Hugh's THP native migration patch
on top. There was a trivial conflict but otherwise it applied.

> > also hope that the concepts of autonuma would be reimplemented on top of
> > this foundation so we can do a meaningful comparison between different
> > placement policies.
> 
> I'll try to help with this to see what could be added from autonuma on
> top to improve on top your balancenuma foundation. Your current
> foundation looks ideal for inclusion to me.
> 

That would be really great. If this happened then potentially numacore
and autonuma can be directly compared in terms of placement and scheduler
policies if both depended on the same underlying infrastrcture. If there
was a better implementation of the PTE scanner for example then it should
be usable by both.

> I noticed you haven't run any single instance specjbb workload, that
> should be added to the battery of tests. But hey take your time, the
> amount of data you provided is already very comprehensive and you were
> so fast.
> 

No, I haven't. Each time they got cancelled due to patch updates before
they had a chance to run. They're still not queued because I want profiles
for the other tests first. When they'll complete I'll fire them up.

> The thing is: single instance and multi instance are totally different
> beasts.
> 
> multi instance is all about avoiding NUMA false sharing in the first
> place (the anti false sharing algorithm becomes a noop), and it has a
> trivial perfect solution with all cross node traffic guaranteed to
> stop after converence has been reached for the whole duration of the
> workload.
> 
> single instance is all about NUMA false sharing detection and it has
> no perfect solution and there's no way to fully converge and to stop
> all cross node traffic. So it's a tradeoff between doing too many
> CPU/memory spurious migrations (harmful, causes regressions) and doing
> too few (i.e. not improving at all compared to upstream but not
> regressing either).
> 

Thanks for that explanation. It does mean that for any specjbb results
that it'll have to be declared if it's single or multi configurations as
they cannot be directly compared in a meaningful manner. If the majority
of JVM tests are single-configuration then I'll prioritise those over the
multi-JVM configurations just to have compatability in comparisons.

> autonuma27/28/28fast will perform identical on multi instance loads
> (i.e. optimal, a few percent away from hard bindings). 
> 
> I was just starting to improve the anti false sharing algorithm in
> autonuma28/28fast to improve single instance specjbb too (this is why
> you really need autonuma28 or autonuma28fast to test single instance
> specjbb and not autonuma27).
> 
> About THP, normally when I was running benchmarks I was testing these
> 4 configs:
> 
> 1) THP on PMD scan on
> 2) THP on PMD scan off
> 3) THP off PMD scan on
> 4) THP off PMD scan off
> 
> (1 and 2 are practically the same for the autonuma benchmark, because
> all memory is backed by THP rendering the PMD level hinting faults for
> 4k pages very unlikely, but I was testing it anyway just in case)
> 

Testing the PMD and !PMD cases was important as I expect the results are
different depending on whether the workload converges on a 2M boundary or
not. A similar tunable is not available in my current tree but perhaps it
should be added to allow the same comparison to happen.

> THP off is going to hit KVM guests the most and much less host
> workloads. But even for KVM it's good practice to test with THP off
> too, to verify the cost of the numa hinting page faults remains very
> low (the cost is much higher for guests than host because of the
> vmexists).
> 

Agreed.

> The KVM benchmark run by IBM was also done in all 4 combinations: THP
> on/off KSM on/off and showed improvement even for the "No THP" case
> (btw, things should run much better these days than the old
> autonuma13).
> 
> http://dl.dropbox.com/u/82832537/kvm-numa-comparison-0.png

Thanks for that.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
