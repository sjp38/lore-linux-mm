Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C26356B0055
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 07:00:18 -0400 (EDT)
Date: Thu, 4 Jun 2009 18:59:59 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH v4] zone_reclaim is always 0 by default
Message-ID: <20090604105959.GA22118@localhost>
References: <20090604192236.9761.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090604192236.9761.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Robin Holt <holt@sgi.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 04, 2009 at 06:23:15PM +0800, KOSAKI Motohiro wrote:
> 
> Current linux policy is, zone_reclaim_mode is enabled by default if the machine
> has large remote node distance. it's because we could assume that large distance
> mean large server until recently.
> 
> Unfortunately, recent modern x86 CPU (e.g. Core i7, Opeteron) have P2P transport
> memory controller. IOW it's seen as NUMA from software view.
> Some Core i7 machine has large remote node distance.
> 
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
> In general, workload depended configration shouldn't put into default settings.
> 
> However, current code is long standing about two year. Highest POWER and IA64 HPC machine
> (only) use this setting.
> 
> Thus, x86 and almost rest architecture change default setting, but Only power and ia64
> remain current configuration for backward-compatibility.

The above lines are too long. Limit to 72 cols in general could be
better as git-log may add additional leading white spaces.

Thank you for all the efforts!

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

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

s/begin to/default to/ ?

> + */
> +#define RECLAIM_DISTANCE 20
> +
> +
>  static inline int cpu_to_node(int cpu)
>  {
>  	return numa_cpu_lookup_table[cpu];
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
