Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f51.google.com (mail-oa0-f51.google.com [209.85.219.51])
	by kanga.kvack.org (Postfix) with ESMTP id 177226B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 19:35:34 -0500 (EST)
Received: by mail-oa0-f51.google.com with SMTP id h16so7692057oag.10
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 16:35:33 -0800 (PST)
Received: from g6t0187.atlanta.hp.com (g6t0187.atlanta.hp.com. [15.193.32.64])
        by mx.google.com with ESMTPS id rk9si5433872obb.51.2014.01.27.16.35.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Jan 2014 16:35:32 -0800 (PST)
Message-ID: <52E6FB52.3070001@hp.com>
Date: Mon, 27 Jan 2014 16:35:30 -0800
From: Chegu Vinod <chegu_vinod@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 0/9] numa,sched,mm: pseudo-interleaving for automatic
 NUMA balancing
References: <1390860228-21539-1-git-send-email-riel@redhat.com>
In-Reply-To: <1390860228-21539-1-git-send-email-riel@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, peterz@infradead.org, mgorman@suse.de, mingo@redhat.com

On 1/27/2014 2:03 PM, riel@redhat.com wrote:
> The current automatic NUMA balancing code base has issues with
> workloads that do not fit on one NUMA load. Page migration is
> slowed down, but memory distribution between the nodes where
> the workload runs is essentially random, often resulting in a
> suboptimal amount of memory bandwidth being available to the
> workload.
>
> In order to maximize performance of workloads that do not fit in one NUMA
> node, we want to satisfy the following criteria:
> 1) keep private memory local to each thread
> 2) avoid excessive NUMA migration of pages
> 3) distribute shared memory across the active nodes, to
>     maximize memory bandwidth available to the workload
>
> This patch series identifies the NUMA nodes on which the workload
> is actively running, and balances (somewhat lazily) the memory
> between those nodes, satisfying the criteria above.
>
> As usual, the series has had some performance testing, but it
> could always benefit from more testing, on other systems.
>
> Changes since v4:
>   - remove some code that did not help performance
>   - implement all the cleanups suggested by Mel Gorman
>   - lots more testing, by Chegu Vinod and myself
>   - rebase against -tip instead of -next, to make merging easier

Acked-by:  Chegu Vinod <chegu_vinod@hp.com>

---

The following 1, 2, 4 & 8 socket-wide results on an 8-socket box are an 
average of 4 runs.


I) Eight 1-socket wide instances (10 warehouse threads/instance)

a) numactl pinning results
throughput =     350720  bops
throughput =     355250  bops
throughput =     350338  bops
throughput =     345963  bops
throughput =     344723  bops
throughput =     347838  bops
throughput =     347623  bops
throughput =     347963  bops

b) Automatic NUMA balancing results
   (Avg# page migrations : 10317611)
throughput =     319037  bops
throughput =     319612  bops
throughput =     314089  bops
throughput =     317499  bops
throughput =     320516  bops
throughput =     314905  bops
throughput =     315821  bops
throughput =     320575  bops

c) No Automatic NUMA balancing and NO-pinning results
throughput =     175433  bops
throughput =     179470  bops
throughput =     176262  bops
throughput =     162551  bops
throughput =     167874  bops
throughput =     173196  bops
throughput =     172001  bops
throughput =     174332  bops

-------

II) Four 2-socket wide instances (20 warehouse threads/instance)

a) numactl pinning results
throughput =     611391  bops
throughput =     618464  bops
throughput =     612350  bops
throughput =     616826  bops

b) Automatic NUMA balancing results
   (Avg# page migrations : 8643581)
throughput =     523053  bops
throughput =     519375  bops
throughput =     502800  bops
throughput =     528880  bops

c) No Automatic NUMA balancing and NO-pinning results
throughput =     334807  bops
throughput =     330348  bops
throughput =     306250  bops
throughput =     309624  bops

-------

III) Two 4-socket wide instances (40 warehouse threads/instance)

a) numactl pinning results
throughput =     946760  bops
throughput =     949712  bops

b) Automatic NUMA balancing results
   (Avg# page migrations : 5710932)
throughput =     861105  bops
throughput =     879878  bops

c) No Automatic NUMA balancing and NO-pinning results
throughput =     500527  bops
throughput =     450884  bops

-------

IV) One 8-socket wide instance (80 warehouse threads/instance)

a) numactl pinning results
throughput =    1199211  bops

b) Automatic NUMA balancing results
   (Avg# page migrations : 3426618)
throughput =    1119524  bops

c) No Automatic NUMA balancing and NO-pinning results
throughput =     789243  bops


Thanks
Vinod
> Changes since v3:
>   - various code cleanups suggested by Mel Gorman (some in their own patches)
>   - after some testing, switch back to the NUMA specific CPU use stats,
>     since that results in a 1% performance increase for two 8-warehouse
>     specjbb instances on a 4-node system, and reduced page migration across
>     the board
> Changes since v2:
>   - dropped tracepoint (for now?)
>   - implement obvious improvements suggested by Peter
>   - use the scheduler maintained CPU use statistics, drop
>     the NUMA specific ones for now. We can add those later
>     if they turn out to be beneficial
> Changes since v1:
>   - fix divide by zero found by Chegu Vinod
>   - improve comment, as suggested by Peter Zijlstra
>   - do stats calculations in task_numa_placement in local variables
>
>
> Some performance numbers, with two 40-warehouse specjbb instances
> on an 8 node system with 10 CPU cores per node, using a pre-cleanup
> version of these patches, courtesy of Chegu Vinod:
>
> numactl manual pinning
> spec1.txt:           throughput =     755900.20 SPECjbb2005 bops
> spec2.txt:           throughput =     754914.40 SPECjbb2005 bops
>
> NO-pinning results (Automatic NUMA balancing, with patches)
> spec1.txt:           throughput =     706439.84 SPECjbb2005 bops
> spec2.txt:           throughput =     729347.75 SPECjbb2005 bops
>
> NO-pinning results (Automatic NUMA balancing, without patches)
> spec1.txt:           throughput =     667988.47 SPECjbb2005 bops
> spec2.txt:           throughput =     638220.45 SPECjbb2005 bops
>
> No Automatic NUMA and NO-pinning results
> spec1.txt:           throughput =     544120.97 SPECjbb2005 bops
> spec2.txt:           throughput =     453553.41 SPECjbb2005 bops
>
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
