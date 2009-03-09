Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9C6B96B00B3
	for <linux-mm@kvack.org>; Sun,  8 Mar 2009 21:50:41 -0400 (EDT)
Subject: Re: [RFC PATCH 00/19] Cleanup and optimise the page allocator V2
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <20090306130317.GF9461@csn.ul.ie>
References: <1235647139.16552.34.camel@penberg-laptop>
	 <20090226112232.GE32756@csn.ul.ie> <1235724283.11610.212.camel@minggr>
	 <20090302112122.GC21145@csn.ul.ie> <1236132307.2567.25.camel@ymzhang>
	 <20090304090740.GA27043@wotan.suse.de> <1236218198.2567.119.camel@ymzhang>
	 <20090305103403.GB32407@elte.hu>
	 <1236328388.11608.35.camel@minggr.sh.intel.com>
	 <20090306093918.GA20698@elte.hu>  <20090306130317.GF9461@csn.ul.ie>
Content-Type: text/plain
Date: Mon, 09 Mar 2009 09:50:10 +0800
Message-Id: <1236563410.2567.282.camel@ymzhang>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Ingo Molnar <mingo@elte.hu>, Lin Ming <ming.m.lin@intel.com>, Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2009-03-06 at 13:03 +0000, Mel Gorman wrote:
> On Fri, Mar 06, 2009 at 10:39:18AM +0100, Ingo Molnar wrote:
> > 
> > * Lin Ming <ming.m.lin@intel.com> wrote:
> > 
> > > Thanks, I have used "perfstat -s" to collect cache misses 
> > > data.
> > > 
> > > 2.6.29-rc7-tip: tip/perfcounters/core (b5e8acf)
> > > 2.6.29-rc7-tip-mg2: v2 patches applied to tip/perfcounters/core
> > > 
> > > I collected 5 times netperf UDP-U-4k data with and without 
> > > mg-v2 patches applied to tip/perfcounters/core on a 4p 
> > > quad-core tigerton machine, as below "value" means UDP-U-4k 
> > > test result.
> > > 
> > > 2.6.29-rc7-tip
> > > ---------------
> > > value           cache misses    CPU migrations  cachemisses/migrations
> > > 5329.71          391094656       1710            228710
> > > 5641.59          239552767       2138            112045
> > > 5580.87          132474745       2172            60992
> > > 5547.19          86911457        2099            41406
> > > 5626.38          196751217       2050            95976
> > > 
> > > 2.6.29-rc7-tip-mg2
> > > -------------------
> > > value           cache misses    CPU migrations  cachemisses/migrations
> > > 4749.80          649929463       1132            574142
> > > 4327.06          484100170       1252            386661
> > > 4649.51          374201508       1489            251310
> > > 5655.82          405511551       1848            219432
> > > 5571.58          90222256        2159            41788
> > > 
> > > Lin Ming
> > 
> > Hm, these numbers look really interesting and give us insight 
> > into this workload. The workload is fluctuating but by measuring 
> > 3 metrics at once instead of just one we see the following 
> > patterns:
> > 
> >  - Less CPU migrations means more cache misses and less 
> >    performance.
> > 
> 
> I also happen to know that V2 was cache unfriendly in a number of
> respects. I've been trying to address it in V3 but still the netperf
> performance in general is being very tricky even though profiles tell me
> the page allocator is lighter and incurring fewer cache misses.
> 
> (aside, thanks for saying how you were running netperf. It allowed me to
> take shortcuts writing the automation as I knew what parameters to use)
The script chooses to bind client/server to cores of different physical cpu.
You could also try:
1) no-binding;
2) Start CPU_NUM clients;

> 
> Here is the results from one x86-64 machine running an unreleased version
> of the patchset
> 
> Netperf UDP_STREAM Comparison
> ----------------------------
>                                     clean      opt-palloc   diff
> UDP_STREAM-64                       68.63           73.15    6.18%
> UDP_STREAM-128                     149.77          144.33   -3.77%
> UDP_STREAM-256                     264.06          280.18    5.75%
> UDP_STREAM-1024                   1037.81         1058.61    1.96%
> UDP_STREAM-2048                   1790.33         1906.53    6.09%
> UDP_STREAM-3312                   2671.34         2744.38    2.66%
> UDP_STREAM-4096                   2722.92         2910.65    6.45%
> UDP_STREAM-8192                   4280.14         4314.00    0.78%
> UDP_STREAM-16384                  5384.13         5606.83    3.97%
> Netperf TCP_STREAM Comparison
> ----------------------------
>                                     clean      opt-palloc   diff
> TCP_STREAM-64                      180.09          204.59   11.98%
> TCP_STREAM-128                     297.45          812.22   63.38%
> TCP_STREAM-256                    1315.20         1432.74    8.20%
> TCP_STREAM-1024                   2544.73         3043.22   16.38%
> TCP_STREAM-2048                   4157.76         4351.28    4.45%
> TCP_STREAM-3312                   4254.53         4790.56   11.19%
> TCP_STREAM-4096                   4773.22         4932.61    3.23%
> TCP_STREAM-8192                   4937.03         5453.58    9.47%
> TCP_STREAM-16384                  6003.46         6183.74    2.92%
> 
> WOooo, more or less awesome. Then here are the results of a second x86-64
> machine
> 
> Netperf UDP_STREAM Comparison
> ----------------------------
>                                     clean      opt-palloc   diff
> UDP_STREAM-64                      106.50          106.98    0.45%
> UDP_STREAM-128                     216.39          212.48   -1.84%
> UDP_STREAM-256                     425.29          419.12   -1.47%
> UDP_STREAM-1024                   1433.21         1449.20    1.10%
> UDP_STREAM-2048                   2569.67         2503.73   -2.63%
> UDP_STREAM-3312                   3685.30         3603.15   -2.28%
> UDP_STREAM-4096                   4019.05         4252.53    5.49%
> UDP_STREAM-8192                   6278.44         6315.58    0.59%
> UDP_STREAM-16384                  7389.78         7162.91   -3.17%
> Netperf TCP_STREAM Comparison
> ----------------------------
>                                     clean      opt-palloc   diff
> TCP_STREAM-64                      694.90          674.47   -3.03%
> TCP_STREAM-128                    1160.13         1159.26   -0.08%
> TCP_STREAM-256                    2016.35         2018.03    0.08%
> TCP_STREAM-1024                   4619.41         4562.86   -1.24%
> TCP_STREAM-2048                   5001.08         5096.51    1.87%
> TCP_STREAM-3312                   5235.22         5276.18    0.78%
> TCP_STREAM-4096                   5832.15         5844.42    0.21%
> TCP_STREAM-8192                   6247.71         6287.93    0.64%
> TCP_STREAM-16384                  7987.68         7896.17   -1.16%
> 
> Much less awesome and the cause of much frowny face and contemplation as to
> whether I'd be much better off hitting the bar for a tasty beverage or 10.
> 
> I'm trying to pin down why there are such large differences between machines
> but it's something with the machine themselves as the results between runs
> is fairly consistent. Annoyingly, the second machine showed good results
> for kernbench (allocator heavy), sysbench (not allocator heavy), was more
> or less the same for hackbench but regressed tbench and netperf even though
> the page allocator overhead was less. I'm doing something screwy with cache
> but don't know what it is yet.
> 
> netperf is being run on different CPUs and is possibly maximising the amount
> of cache bounces incurred by the page allocator as it splits and merges
> buddies. I'm experimenting with the idea of delaying bulk PCP frees but it's
> also possible the network layer is having trouble with cache line bounces when
> the workload is run over localhost and my modifications are changing timings.
Ingo's analysis is on the right track. Both netperf and tbench have dependency on
process scheduler. Perhaps V2 has some impact on scheduler?

> 
> > The lowest-score runs had the lowest CPU migrations count, 
> > coupled with a high amount of cachemisses.
> > 
> > This _probably_ means that in this workload migrations are 
> > desired: the sooner two related tasks migrate to the same CPU 
> > the better. If they stay separate (migration count is low) then 
> > they interact with each other from different CPUs, creating a 
> > lot of cachemisses and reducing performance.
> > 
> > You can reduce the migration barrier of the system by enabling 
> > CONFIG_SCHED_DEBUG=y and setting sched_migration_cost to zero:
> > 
> >    echo 0 > /proc/sys/kernel/sched_migration_cost
> > 
> > This will hurt other workloads - but if this improves the 
> > numbers then it proves that what this particular workload wants 
> > is easy migrations.
> > 
> > Now the question is, why does the mg2 patchset reduce the number 
> > of migrations? It might not be an inherent property of the mg2 
> > patches: maybe just unlucky timings push the workload across 
> > sched_migration_cost.
> > 
> > Setting sched_migration_cost to either zero or to a very high 
> > value and repeating the test will eliminate this source of noise 
> > and will tell us about other properties of the mg2 patchset.
> > 
> > There might be other effects i'm missing. For example what kind 
> > of UDP transport is used - localhost networking? That means that 
> > sender and receiver really wants to be coupled strongly and what 
> > controls this workload is whether such a 'pair' of tasks can 
> > properly migrate to the same CPU.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
