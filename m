Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 3E2A26B005D
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 06:39:53 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so1251566bkc.14
        for <linux-mm@kvack.org>; Mon, 10 Dec 2012 03:39:51 -0800 (PST)
Date: Mon, 10 Dec 2012 12:39:45 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/49] Automatic NUMA Balancing v10
Message-ID: <20121210113945.GA7550@gmail.com>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
 <20121207110113.GB21482@gmail.com>
 <20121209203630.GC1009@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121209203630.GC1009@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> On Fri, Dec 07, 2012 at 12:01:13PM +0100, Ingo Molnar wrote:
> > 
> > * Mel Gorman <mgorman@suse.de> wrote:
> > 
> > > This is a full release of all the patches so apologies for the 
> > > flood. [...]
> > 
> > I have yet to process all your mails, but assuming I address all 
> > your review feedback and the latest unified tree in tip:master 
> > shows no regression in your testing, would you be willing to 
> > start using it for ongoing work?
> > 
> 
> Ingo,
> 
> If you had read the second paragraph of the mail you just responded to or
> the results at the end then you would have seen that I had problems with
> the performance. [...]

I've posted a (NUMA-placement sensitive workload centric) 
performance comparisons between "balancenuma", AutoNUMA and 
numa/core unified-v3 to:

   https://lkml.org/lkml/2012/12/7/331

I tried to address all performance regressions you and others 
have reported.

Here's the direct [bandwidth] comparison of 'balancenuma v10' to 
my -v3 tree:

                            balancenuma  | NUMA-tip
 [test unit]            :          -v10  |    -v3
------------------------------------------------------------
 2x1-bw-process         :         6.136  |  9.647:  57.2%
 3x1-bw-process         :         7.250  | 14.528: 100.4%
 4x1-bw-process         :         6.867  | 18.903: 175.3%
 8x1-bw-process         :         7.974  | 26.829: 236.5%
 8x1-bw-process-NOTHP   :         5.937  | 22.237: 274.5%
 16x1-bw-process        :         5.592  | 29.294: 423.9%
 4x1-bw-thread          :        13.598  | 19.290:  41.9%
 8x1-bw-thread          :        16.356  | 26.391:  61.4%
 16x1-bw-thread         :        24.608  | 29.557:  20.1%
 32x1-bw-thread         :        25.477  | 30.232:  18.7%
 2x3-bw-thread          :         8.785  | 15.327:  74.5%
 4x4-bw-thread          :         6.366  | 27.957: 339.2%
 4x6-bw-thread          :         6.287  | 27.877: 343.4%
 4x8-bw-thread          :         5.860  | 28.439: 385.3%
 4x8-bw-thread-NOTHP    :         6.167  | 25.067: 306.5%
 3x3-bw-thread          :         8.235  | 21.560: 161.8%
 5x5-bw-thread          :         5.762  | 26.081: 352.6%
 2x16-bw-thread         :         5.920  | 23.269: 293.1%
 1x32-bw-thread         :         5.828  | 18.985: 225.8%
 numa02-bw              :        29.054  | 31.431:   8.2%
 numa02-bw-NOTHP        :        27.064  | 29.104:   7.5%
 numa01-bw-thread       :        20.338  | 28.607:  40.7%
 numa01-bw-thread-NOTHP :        18.528  | 21.119:  14.0%
------------------------------------------------------------

I also tried to reproduce and fix as many bugs you reported as 
possible - but my point is that it would be _much_ better if we 
actually joined forces.

> [...] You would also know that tip/master testing for the last 
> week was failing due to a boot problem (issue was in mainline 
> not tip and has been already fixed) and would have known that 
> since the -v18 release that numacore was effectively disabled 
> on my test machine.

I'm glad it's fixed.

> Clearly you are not reading the bug reports you are receiving 
> and you're not seeing the small bit of review feedback or 
> answering the review questions you have received either. Why 
> would I be more forthcoming when I feel that it'll simply be 
> ignored? [...]

I am reading the bug reports and addressing bugs as I can.

> [...]  You simply assume that each batch of patches you place 
> on top must be fixing all known regressions and ignoring any 
> evidence to the contrary.
>
> If you had read my mail from last Tuesday you would even know 
> which patch was causing the problem that effectively disabled 
> numacore although not why. The comment about p->numa_faults 
> was completely off the mark (long journey, was tired, assumed 
> numa_faults was a counter and not a pointer which was 
> careless).  If you had called me on it then I would have 
> spotted the actual problem sooner. The problem was indeed with 
> the nr_cpus_allowed == num_online_cpus()s check which I had 
> pointed out was a suspicious check although for different 
> reasons. As it turns out, a printk() bodge showed that 
> nr_cpus_allowed == 80 set in sched_init_smp() while 
> num_online_cpus() == 48. This effectively disabling numacore. 
> If you had responded to the bug report, this would likely have 
> been found last Wednesday.

Does changing it from num_online_cpus() to num_possible_cpus() 
help? (Can send a patch if you want.)

> > It would make it much easier for me to pick up your 
> > enhancements, fixes, etc.
> > 
> > > Changelog since V9
> > >   o Migration scalability                                             (mingo)
> > 
> > To *really* see migration scalability bottlenecks you need to 
> > remove the migration-bandwidth throttling kludge from your tree 
> > (or configure it up very high if you want to do it simple).
> > 
> 
> Why is it a kludge? I already explained what the rational 
> behind the rate limiting was. It's not about scalability, it's 
> about mitigating worse-case behaviour and the amount of time 
> the kernel spends moving data around which a deliberately 
> adverse workload can trigger.  It is unacceptable if during a 
> phase change that a process would stall potentially for 
> milliseconds (seconds if the node is large enough I guess) 
> while the data is being migrated. Here is it again -- 
> http://www.spinics.net/lists/linux-mm/msg47440.html . You 
> either ignored the mail or simply could not be bothered 
> explaining why you thought this was the incorrect decision or 
> why the concerns about an adverse workload were unimportant.

I think the stalls could have been at least in part due to the 
scalability bottlenecks that the rate-limiting code has hidden.

If you think of the NUMA migration as a natural part of the 
workload, as a sort of extended cache-miss, and if you assume 
that the scheduler is intelligent about not flip-flopping tasks 
between nodes (which the latest code certainly is), then I don't 
see why the rate of migration should be rate-limited in the VM.

Note that I tried to quantify this effect: the perf bench numa 
testcases start from a practical 'worst-case adverse' workload 
in essence: all pages concentrated on the wrong node, and the 
workload having to migrate all of them over.

We could add a new 'absolutely worst case' testcase, to make it 
behaves sanely?

> I have a vague suspicion actually that when you are modelling 
> the task->data relationship that you make an implicit 
> assumption that moving data has zero or near-zero cost. In 
> such a model it would always make sense to move quickly and 
> immediately but in practice the cost of moving can exceed the 
> performance benefit of accessing local data and lead to 
> regressions. It becomes more pronounced if the nodes are not 
> fully connected.

I make no such assumption - convergence costs were part of my 
measurements.

> > Some (certainly not all) of the performance regressions you 
> > reported were certainly due to numa/core code hitting the 
> > migration codepaths as aggressively as the workload demanded 
> > - and hitting scalability bottlenecks.
> 
> How are you so certain? [...]

Hm, I don't think my "some (certainly not all)" statement 
reflected any sort of certainty. So we violently agree about:

> [...] How do you not know it's because your code is migrating 
> excessively for no good reason because the algorithm has a 
> flaw in it? [...]

That's another source - but again not something we should fix by 
hiding it under the carpet via migration bandwidth rate limits, 
right?

> [...] Or that the cost of excessive migration is not being 
> offset by local data accesses? [...]

That's another possibility.

The _real_ fix is to avoid excessive migration on the CPU and 
memory placement side, not to throttle the basic mechanism 
itself!

I don't exclude the possibility that bandwidth limits might be 
needed - but only if everything else fails. Meanwhile, the 
bandwidth limits were actively hiding scalability bottlenecks, 
which bottlenecks only trigger at higher migration rates.

> [...] The critical point to note is that if it really was only 
> scalability problems then autonuma would suffer the same 
> problems and would be impossible to autonumas performance to 
> exceed numacores. This isn't the case making it unlikely the 
> scalability is your only problem.

The scheduling patterns are different - so they can hit 
different bottlenecks.

> Either way, last night I applied a patch on top of latest 
> tip/master to remove the nr_cpus_allowed check so that 
> numacore would be enabled again and tested that. In some 
> places it has indeed much improved. In others it is still 
> regressing badly and in two case, it's corrupting memory -- 
> specjbb when THP is enabled crashes when running for single or 
> multiple JVMs. It is likely that a zero page is being inserted 
> due to a race with migration and causes the JVM to throw a 
> null pointer exception. Here is the comparison on the rough 
> off-chance you actually read it this time.

Can you still see the JVM crash with the unified -v3 tree?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
