Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 220F06B0105
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 04:39:36 -0500 (EST)
Date: Fri, 6 Mar 2009 10:39:18 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC PATCH 00/19] Cleanup and optimise the page allocator V2
Message-ID: <20090306093918.GA20698@elte.hu>
References: <20090226110336.GC32756@csn.ul.ie> <1235647139.16552.34.camel@penberg-laptop> <20090226112232.GE32756@csn.ul.ie> <1235724283.11610.212.camel@minggr> <20090302112122.GC21145@csn.ul.ie> <1236132307.2567.25.camel@ymzhang> <20090304090740.GA27043@wotan.suse.de> <1236218198.2567.119.camel@ymzhang> <20090305103403.GB32407@elte.hu> <1236328388.11608.35.camel@minggr.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1236328388.11608.35.camel@minggr.sh.intel.com>
Sender: owner-linux-mm@kvack.org
To: Lin Ming <ming.m.lin@intel.com>
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>


* Lin Ming <ming.m.lin@intel.com> wrote:

> Thanks, I have used "perfstat -s" to collect cache misses 
> data.
> 
> 2.6.29-rc7-tip: tip/perfcounters/core (b5e8acf)
> 2.6.29-rc7-tip-mg2: v2 patches applied to tip/perfcounters/core
> 
> I collected 5 times netperf UDP-U-4k data with and without 
> mg-v2 patches applied to tip/perfcounters/core on a 4p 
> quad-core tigerton machine, as below "value" means UDP-U-4k 
> test result.
> 
> 2.6.29-rc7-tip
> ---------------
> value           cache misses    CPU migrations  cachemisses/migrations
> 5329.71          391094656       1710            228710
> 5641.59          239552767       2138            112045
> 5580.87          132474745       2172            60992
> 5547.19          86911457        2099            41406
> 5626.38          196751217       2050            95976
> 
> 2.6.29-rc7-tip-mg2
> -------------------
> value           cache misses    CPU migrations  cachemisses/migrations
> 4749.80          649929463       1132            574142
> 4327.06          484100170       1252            386661
> 4649.51          374201508       1489            251310
> 5655.82          405511551       1848            219432
> 5571.58          90222256        2159            41788
> 
> Lin Ming

Hm, these numbers look really interesting and give us insight 
into this workload. The workload is fluctuating but by measuring 
3 metrics at once instead of just one we see the following 
patterns:

 - Less CPU migrations means more cache misses and less 
   performance.

The lowest-score runs had the lowest CPU migrations count, 
coupled with a high amount of cachemisses.

This _probably_ means that in this workload migrations are 
desired: the sooner two related tasks migrate to the same CPU 
the better. If they stay separate (migration count is low) then 
they interact with each other from different CPUs, creating a 
lot of cachemisses and reducing performance.

You can reduce the migration barrier of the system by enabling 
CONFIG_SCHED_DEBUG=y and setting sched_migration_cost to zero:

   echo 0 > /proc/sys/kernel/sched_migration_cost

This will hurt other workloads - but if this improves the 
numbers then it proves that what this particular workload wants 
is easy migrations.

Now the question is, why does the mg2 patchset reduce the number 
of migrations? It might not be an inherent property of the mg2 
patches: maybe just unlucky timings push the workload across 
sched_migration_cost.

Setting sched_migration_cost to either zero or to a very high 
value and repeating the test will eliminate this source of noise 
and will tell us about other properties of the mg2 patchset.

There might be other effects i'm missing. For example what kind 
of UDP transport is used - localhost networking? That means that 
sender and receiver really wants to be coupled strongly and what 
controls this workload is whether such a 'pair' of tasks can 
properly migrate to the same CPU.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
