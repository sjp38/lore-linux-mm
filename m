Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BA4DA6B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 06:37:25 -0400 (EDT)
Date: Mon, 8 Jun 2009 12:50:48 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v4] zone_reclaim is always 0 by default
Message-ID: <20090608115048.GA15070@csn.ul.ie>
References: <20090604192236.9761.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090604192236.9761.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Robin Holt <holt@sgi.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 04, 2009 at 07:23:15PM +0900, KOSAKI Motohiro wrote:
> 
> Current linux policy is, zone_reclaim_mode is enabled by default if the machine
> has large remote node distance. it's because we could assume that large distance
> mean large server until recently.
> 

We don't make assumptions about the server being large, small or otherwise. The
affinity tables reporting a distance of 20 or more is saying "remote memory
has twice the latency of local memory". This is true irrespective of workload
and implies that going off-node has a real penalty regardless of workload.

> Unfortunately, recent modern x86 CPU (e.g. Core i7, Opeteron) have P2P transport
> memory controller. IOW it's seen as NUMA from software view.
> Some Core i7 machine has large remote node distance.
> 

If they have large remote node distance, they have large remote node
distance. Now, if they are *lying* and remote memory is not really that
expensive, then prehaps we should be thinking of a per-arch-per-chip
modifier to the distances reported by ACPI.

> Yanmin reported zone_reclaim_mode=1 cause large apache regression.
> 
>     One Nehalem machine has 12GB memory,
>     but there is always 2GB free although applications accesses lots of files.
>     Eventually we located the root cause as zone_reclaim_mode=1.
> 
> Actually, zone_reclaim_mode=1 mean "I dislike remote node allocation rather than
> disk access", it makes performance improvement to HPC workload.
> but it makes performance degression to desktop, file server and web server.
> 

How are you determining a performance regression to desktop? On a
desktop, I would expect processes to be spread on the different CPUs for
each of the nodes. In that case, memory faulted on each CPU should be
faulted locally.

If there are local processes that access a lot of files, then it might end
up reclaiming those to keep memory local and this might be undesirable
but this is explicitly documented;

"It may be beneficial to switch off zone reclaim if the system is used for a
file server and all of memory should be used for caching files from disk. In
that case the caching effect is more important than data locality."

Ideally we could detect if the machine was a file-server or not but no
such luck.

> In general, workload depended configration shouldn't put into default settings.
> 
> However, current code is long standing about two year. Highest POWER and IA64 HPC machine
> (only) use this setting.
> 
> Thus, x86 and almost rest architecture change default setting, but Only power and ia64
> remain current configuration for backward-compatibility.
> 

What about if it's x86-64-based NUMA but it's not i7 based. There, the
NUMA distances might really mean something and that zone_reclaim behaviour
is desirable.

I think if we're going down the road of setting the default, it shouldn't be
per-architecture defaults as such. Other choices for addressing this might be;

1. Make RECLAIM_DISTANCE a variable on x86. Set it to 20 by default, and 5
   (or some other sensible figure) on i7

2. There should be a per-arch modifier callback for the affinity
   distances. If the x86 code detects the CPU is an i7, it can reduce the
   reported latencies to be more in line with expected reality.

3. Do not use zone_reclaim() for file-backed data if more than 20% of memory
   overall is free. The difficulty is figuring out if the allocation is for
   file pages.

4. Change zone_reclaim_mode default to mean "do your best to figure it
   out". Patch 1 would default large distances to 1 to see what happens.
   Then apply a heuristic when in figure-it-out mode and using reclaim_mode == 1

	If we have locally reclaimed 2% of the nodes memory in file pages
	within the last 5 seconds when >= 20% of total physical memory was
	free, then set the reclaim_mode to 0 on the assumption the node is
	mostly caching pages and shouldn't be reclaimed to avoid excessive IO

Option 1 would appear to be the most straight-forward but option 2
should be doable. Option 3 and 4 could turn into a rats nest and I would
consider those approaches a bit more drastic.

> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Robin Holt <holt@sgi.com>
> Cc: "Zhang, Yanmin" <yanmin.zhang@intel.com>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Cc: linux-ia64@vger.kernel.org
> Cc: linuxppc-dev@ozlabs.org
> ---
>  arch/powerpc/include/asm/topology.h |    6 ++++++
>  include/linux/topology.h            |    7 +------
>  2 files changed, 7 insertions(+), 6 deletions(-)
> 
> Index: b/include/linux/topology.h
> ===================================================================
> --- a/include/linux/topology.h
> +++ b/include/linux/topology.h
> @@ -54,12 +54,7 @@ int arch_update_cpu_topology(void);
>  #define node_distance(from,to)	((from) == (to) ? LOCAL_DISTANCE : REMOTE_DISTANCE)
>  #endif
>  #ifndef RECLAIM_DISTANCE
> -/*
> - * If the distance between nodes in a system is larger than RECLAIM_DISTANCE
> - * (in whatever arch specific measurement units returned by node_distance())
> - * then switch on zone reclaim on boot.
> - */
> -#define RECLAIM_DISTANCE 20
> +#define RECLAIM_DISTANCE INT_MAX
>  #endif
>  #ifndef PENALTY_FOR_NODE_WITH_CPUS
>  #define PENALTY_FOR_NODE_WITH_CPUS	(1)
> Index: b/arch/powerpc/include/asm/topology.h
> ===================================================================
> --- a/arch/powerpc/include/asm/topology.h
> +++ b/arch/powerpc/include/asm/topology.h
> @@ -10,6 +10,12 @@ struct device_node;
>  
>  #include <asm/mmzone.h>
>  
> +/*
> + * Distance above which we begin to use zone reclaim
> + */
> +#define RECLAIM_DISTANCE 20
> +
> +

Where is the ia-64-specific modifier to RECAIM_DISTANCE?

>  static inline int cpu_to_node(int cpu)
>  {
>  	return numa_cpu_lookup_table[cpu];
> 
> 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
