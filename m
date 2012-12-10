Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 8966E6B005A
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 10:24:12 -0500 (EST)
Date: Mon, 10 Dec 2012 15:24:05 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/49] Automatic NUMA Balancing v10
Message-ID: <20121210152405.GJ1009@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
 <20121207110113.GB21482@gmail.com>
 <20121209203630.GC1009@suse.de>
 <20121210113945.GA7550@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121210113945.GA7550@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Dec 10, 2012 at 12:39:45PM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Fri, Dec 07, 2012 at 12:01:13PM +0100, Ingo Molnar wrote:
> > > 
> > > * Mel Gorman <mgorman@suse.de> wrote:
> > > 
> > > > This is a full release of all the patches so apologies for the 
> > > > flood. [...]
> > > 
> > > I have yet to process all your mails, but assuming I address all 
> > > your review feedback and the latest unified tree in tip:master 
> > > shows no regression in your testing, would you be willing to 
> > > start using it for ongoing work?
> > > 
> > 
> > Ingo,
> > 
> > If you had read the second paragraph of the mail you just responded to or
> > the results at the end then you would have seen that I had problems with
> > the performance. [...]
> 
> I've posted a (NUMA-placement sensitive workload centric) 
> performance comparisons between "balancenuma", AutoNUMA and 
> numa/core unified-v3 to:
> 
>    https://lkml.org/lkml/2012/12/7/331
> 
> I tried to address all performance regressions you and others 
> have reported.
> 

I've responded to this now. I acknowledge that balancenuma does not do
great on them. I've also explained that it's very likely because I did
not hook into the scheduler and I'm relucent to do so. Once I do that,
we're directly colliding when my intention was to handle all the necessary
MM changes, the bare minimum of the scheduler hook and maintain that side
while numacore and all the additional scheduler changes was built on top.

> <SNIP>
> I also tried to reproduce and fix as many bugs you reported as 
> possible - but my point is that it would be _much_ better if we 
> actually joined forces.
> 

Which is what balancenuma was meant to do and what I wanted weeks ago
-- I wanted to keep a handle on the mm side of things and establish
performance baseline for just the mm side that numacore could be compared
against.  I'd then help maintain the result, review patches particularly
affecting mm etc.  I was hoping that numacore would be rebased to carry
the necessary scheduler changes but that didn't happen. The unified tree
is not equivalent. Just off-hand

1. there is no performance comparison possible with just the mm changes
2. the vmstat fault accounting is broken in the unified tree
3. the code to allow balancenuma to be disabled from command line
   was removed which the THP experience has told us is very useful
4. The THP patch was wedged in as hard as possible making it effectively
   impossible to treat in isolation
5. ptes are treated as effective hugepage faults which potentially
   results in remote->remote copies if tasks share data on a
   PMD-boundary even if they do not share data on the page boundary.
   For this reason I dislike it quite a bit
6. the migrate rate-limiting code was removed

To be fair, the last one is a difference in opinion. I think migrate
rate-limiting is important because I think it's more important for the
workload to run than the kernel to getting too much in the way thinking
it can do better.

Some of the other changes just made no sense to me and I still fail to
see why you didn't rebase numacore a few weeks ago and instead smacked the
trees together. If it had been a plain rebase then I would have switched
to looking at just numacore on top without having to worry if something
unexpected was broken on the MM side. If something had broken on the MM
side, I'd be on it without wondering if it was due to how the trees were
merged.

For example, I think that point 5 above is the potential source of the
corruption because. You're not flushing the TLBs for the PTEs you are
updating in batch. Granted, you're relaxing rather than restricting access
so it should be ok and at worse cause a spurious fault but I also find
it suspicious that you do not recheck pte_same under the PTL when doing
the final PTE update. I also find it strange that you hold the PTL while
calling task_numa_fault(). No way should the PTL have to protect structures
in kernel/sched and I wonder was that actually part of the reason why you
saw heavy PTL contention.

Basically if I felt that handling ptes in batch like this was of
critical important I would have implemented it very differently on top of
balancenuma. I would have only taken the PTL lock if updating the PTE to
keep contention down and redid racy checks under PTL, I'd have only used
trylock for every non-faulted PTE and I would only have migrated if it
was a remote->local copy. I certainly would not hold PTL while calling
task_numa_fault(). I would have kept the handling ona per-pmd basis when
it was expected that most PTEs underneath should be on the same node.

> > [...] You would also know that tip/master testing for the last 
> > week was failing due to a boot problem (issue was in mainline 
> > not tip and has been already fixed) and would have known that 
> > since the -v18 release that numacore was effectively disabled 
> > on my test machine.
> 
> I'm glad it's fixed.
> 

Agreed.

> > Clearly you are not reading the bug reports you are receiving 
> > and you're not seeing the small bit of review feedback or 
> > answering the review questions you have received either. Why 
> > would I be more forthcoming when I feel that it'll simply be 
> > ignored? [...]
> 
> I am reading the bug reports and addressing bugs as I can.
> 
> > [...]  You simply assume that each batch of patches you place 
> > on top must be fixing all known regressions and ignoring any 
> > evidence to the contrary.
> >
> > If you had read my mail from last Tuesday you would even know 
> > which patch was causing the problem that effectively disabled 
> > numacore although not why. The comment about p->numa_faults 
> > was completely off the mark (long journey, was tired, assumed 
> > numa_faults was a counter and not a pointer which was 
> > careless).  If you had called me on it then I would have 
> > spotted the actual problem sooner. The problem was indeed with 
> > the nr_cpus_allowed == num_online_cpus()s check which I had 
> > pointed out was a suspicious check although for different 
> > reasons. As it turns out, a printk() bodge showed that 
> > nr_cpus_allowed == 80 set in sched_init_smp() while 
> > num_online_cpus() == 48. This effectively disabling numacore. 
> > If you had responded to the bug report, this would likely have 
> > been found last Wednesday.
> 
> Does changing it from num_online_cpus() to num_possible_cpus() 
> help? (Can send a patch if you want.)
> 

I'll check. The patch would be trivial.

> > > It would make it much easier for me to pick up your 
> > > enhancements, fixes, etc.
> > > 
> > > > Changelog since V9
> > > >   o Migration scalability                                             (mingo)
> > > 
> > > To *really* see migration scalability bottlenecks you need to 
> > > remove the migration-bandwidth throttling kludge from your tree 
> > > (or configure it up very high if you want to do it simple).
> > > 
> > 
> > Why is it a kludge? I already explained what the rational 
> > behind the rate limiting was. It's not about scalability, it's 
> > about mitigating worse-case behaviour and the amount of time 
> > the kernel spends moving data around which a deliberately 
> > adverse workload can trigger.  It is unacceptable if during a 
> > phase change that a process would stall potentially for 
> > milliseconds (seconds if the node is large enough I guess) 
> > while the data is being migrated. Here is it again -- 
> > http://www.spinics.net/lists/linux-mm/msg47440.html . You 
> > either ignored the mail or simply could not be bothered 
> > explaining why you thought this was the incorrect decision or 
> > why the concerns about an adverse workload were unimportant.
> 
> I think the stalls could have been at least in part due to the 
> scalability bottlenecks that the rate-limiting code has hidden.
> 

In part yes, but the actual data copying will stall as well. If a node
is 16G and all the data has to migrate from one node to another, it could
take up to 2 seconds even if there is no other contention. This is assuming
roughly 8G/sec transfer speeds but I know is a bit on the low end and it
can vary a lot.

> If you think of the NUMA migration as a natural part of the 
> workload, as a sort of extended cache-miss, and if you assume 
> that the scheduler is intelligent about not flip-flopping tasks 
> between nodes (which the latest code certainly is), then I don't 
> see why the rate of migration should be rate-limited in the VM.
> 

That's just it. I don't view the NUMA migration as a natural part of
the workload. I treat is as a cost that is optionally paid to get local
memory access and that the cost of the move must be offset. I think care
should be taken to minimise the amount of data that is transferred and
the system CPU cost of working out when to migrate should be as low as
possible and my reports have emphasised this.

To some extent I consider THP to have similar restrictions. THP is useless
if the cost of THP allocation is not offset by performance gains due to
reduced TLB misses. I think it's preferable to fail a THP allocation than
spend a lot of time reclaiming pages and compacting memory to satisfy THP.
Reclaim/compaction is meant to give up very quickly.

> Note that I tried to quantify this effect: the perf bench numa 
> testcases start from a practical 'worst-case adverse' workload 
> in essence: all pages concentrated on the wrong node, and the 
> workload having to migrate all of them over.
> 
> We could add a new 'absolutely worst case' testcase, to make it 
> behaves sanely?
> 

I don't think it'll tell us anything new. Without rate limiting the process
will stall while the transfer takes place. The duration of the stall will
be related to inter-node bandwidth.

> > I have a vague suspicion actually that when you are modelling 
> > the task->data relationship that you make an implicit 
> > assumption that moving data has zero or near-zero cost. In 
> > such a model it would always make sense to move quickly and 
> > immediately but in practice the cost of moving can exceed the 
> > performance benefit of accessing local data and lead to 
> > regressions. It becomes more pronounced if the nodes are not 
> > fully connected.
> 
> I make no such assumption - convergence costs were part of my 
> measurements.
> 

Then you must expect that squashing all that cost into the smallest period
of time will result in stalls. It's a much higher cost than cache-line
misses when there a process changes to running on a new CPU for example.

> > > Some (certainly not all) of the performance regressions you 
> > > reported were certainly due to numa/core code hitting the 
> > > migration codepaths as aggressively as the workload demanded 
> > > - and hitting scalability bottlenecks.
> > 
> > How are you so certain? [...]
> 
> Hm, I don't think my "some (certainly not all)" statement 
> reflected any sort of certainty. So we violently agree about:
> 

"regressions you reported were certainly due to numa/core code hitting
the migration codepaths" is what led me to believe that you were very sure
about where the source of the regression was.

> > [...] How do you not know it's because your code is migrating 
> > excessively for no good reason because the algorithm has a 
> > flaw in it? [...]
> 
> That's another source - but again not something we should fix by 
> hiding it under the carpet via migration bandwidth rate limits, 
> right?
> 

I would agree if that was the point of the migration rate-limiting was
to avoid contention. It's not. It's to prevent the kernel getting in the
way of a workload doing work for long periods of time. As balancenuma is
also dumb as rocks with respect to the schedueler it was also aimed at
mitigating problems related to tasks bouncing around if a particular node
was over-subscribed.

> > [...] Or that the cost of excessive migration is not being 
> > offset by local data accesses? [...]
> 
> That's another possibility.
> 
> The _real_ fix is to avoid excessive migration on the CPU and 
> memory placement side, not to throttle the basic mechanism 
> itself!
> 
> I don't exclude the possibility that bandwidth limits might be 
> needed - but only if everything else fails. Meanwhile, the 
> bandwidth limits were actively hiding scalability bottlenecks, 
> which bottlenecks only trigger at higher migration rates.
> 

The bottleneck is visible with or without the migration rate limiting.
If it wasn't then the patches would have made no difference between
balancenuma v9 and v10 but they did but they did make a difference.

> > [...] The critical point to note is that if it really was only 
> > scalability problems then autonuma would suffer the same 
> > problems and would be impossible to autonumas performance to 
> > exceed numacores. This isn't the case making it unlikely the 
> > scalability is your only problem.
> 
> The scheduling patterns are different - so they can hit 
> different bottlenecks.
> 

Ok, that is fair enough.

> > Either way, last night I applied a patch on top of latest 
> > tip/master to remove the nr_cpus_allowed check so that 
> > numacore would be enabled again and tested that. In some 
> > places it has indeed much improved. In others it is still 
> > regressing badly and in two case, it's corrupting memory -- 
> > specjbb when THP is enabled crashes when running for single or 
> > multiple JVMs. It is likely that a zero page is being inserted 
> > due to a race with migration and causes the JVM to throw a 
> > null pointer exception. Here is the comparison on the rough 
> > off-chance you actually read it this time.
> 
> Can you still see the JVM crash with the unified -v3 tree?
> 

The crash was based on tip/master from yesterday. Does that not include
the unified -v3 tree?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
