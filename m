Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id E1C946B0073
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 12:45:49 -0500 (EST)
Received: by vcge1 with SMTP id e1so15548342vcg.14
        for <linux-mm@kvack.org>; Tue, 03 Jan 2012 09:45:48 -0800 (PST)
Message-ID: <4F033EC9.4050909@gmail.com>
Date: Tue, 03 Jan 2012 12:45:45 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 7/8] mm: Only IPI CPUs to drain local pages if they
 exist
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com> <1325499859-2262-8-git-send-email-gilad@benyossef.com>
In-Reply-To: <1325499859-2262-8-git-send-email-gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

(1/2/12 5:24 AM), Gilad Ben-Yossef wrote:
> Calculate a cpumask of CPUs with per-cpu pages in any zone
> and only send an IPI requesting CPUs to drain these pages
> to the buddy allocator if they actually have pages when
> asked to flush.
> 
> This patch saves 99% of IPIs asking to drain per-cpu
> pages in case of severe memory preassure that leads
> to OOM since in these cases multiple, possibly concurrent,
> allocation requests end up in the direct reclaim code
> path so when the per-cpu pages end up reclaimed on first
> allocation failure for most of the proceeding allocation
> attempts until the memory pressure is off (possibly via
> the OOM killer) there are no per-cpu pages on most CPUs
> (and there can easily be hundreds of them).
> 
> This also has the side effect of shortening the average
> latency of direct reclaim by 1 or more order of magnitude
> since waiting for all the CPUs to ACK the IPI takes a
> long time.
> 
> Tested by running "hackbench 400" on a 4 CPU x86 otherwise
> idle VM and observing the difference between the number
> of direct reclaim attempts that end up in drain_all_pages()
> and those were more then 1/2 of the online CPU had any
> per-cpu page in them, using the vmstat counters introduced
> in the next patch in the series and using proc/interrupts.
> 
> In the test sceanrio, this saved around 500 global IPIs.
> After trigerring an OOM:
> 
> $ cat /proc/vmstat
> ...
> pcp_global_drain 627
> pcp_global_ipi_saved 578
> 
> I've also seen the number of drains reach 15k calls
> with the saved percentage reaching 99% when there
> are more tasks running during an OOM kill.
> 
> Signed-off-by: Gilad Ben-Yossef<gilad@benyossef.com>
> Acked-by: Christoph Lameter<cl@linux.com>
> CC: Chris Metcalf<cmetcalf@tilera.com>
> CC: Peter Zijlstra<a.p.zijlstra@chello.nl>
> CC: Frederic Weisbecker<fweisbec@gmail.com>
> CC: Russell King<linux@arm.linux.org.uk>
> CC: linux-mm@kvack.org
> CC: Pekka Enberg<penberg@kernel.org>
> CC: Matt Mackall<mpm@selenic.com>
> CC: Sasha Levin<levinsasha928@gmail.com>
> CC: Rik van Riel<riel@redhat.com>
> CC: Andi Kleen<andi@firstfloor.org>
> CC: Mel Gorman<mel@csn.ul.ie>
> CC: Andrew Morton<akpm@linux-foundation.org>
> CC: Alexander Viro<viro@zeniv.linux.org.uk>
> CC: linux-fsdevel@vger.kernel.org
> CC: Avi Kivity<avi@redhat.com>
> ---
>   Christopth Ack was for a previous version that allocated
>   the cpumask in drain_all_pages().

When you changed a patch design and implementation, ACKs are
should be dropped. otherwise you miss to chance to get a good
review.



>   mm/page_alloc.c |   26 +++++++++++++++++++++++++-
>   1 files changed, 25 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2b8ba3a..092c331 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -67,6 +67,14 @@ DEFINE_PER_CPU(int, numa_node);
>   EXPORT_PER_CPU_SYMBOL(numa_node);
>   #endif
> 
> +/*
> + * A global cpumask of CPUs with per-cpu pages that gets
> + * recomputed on each drain. We use a global cpumask
> + * for to avoid allocation on direct reclaim code path
> + * for CONFIG_CPUMASK_OFFSTACK=y
> + */
> +static cpumask_var_t cpus_with_pcps;
> +
>   #ifdef CONFIG_HAVE_MEMORYLESS_NODES
>   /*
>    * N.B., Do NOT reference the '_numa_mem_' per cpu variable directly.
> @@ -1119,7 +1127,19 @@ void drain_local_pages(void *arg)
>    */
>   void drain_all_pages(void)
>   {
> -	on_each_cpu(drain_local_pages, NULL, 1);
> +	int cpu;
> +	struct per_cpu_pageset *pcp;
> +	struct zone *zone;
> +

get_online_cpu() ?

> +	for_each_online_cpu(cpu)
> +		for_each_populated_zone(zone) {
> +			pcp = per_cpu_ptr(zone->pageset, cpu);
> +			if (pcp->pcp.count)
> +				cpumask_set_cpu(cpu, cpus_with_pcps);
> +			else
> +				cpumask_clear_cpu(cpu, cpus_with_pcps);

cpumask* functions can't be used locklessly?

> +		}
> +	on_each_cpu_mask(cpus_with_pcps, drain_local_pages, NULL, 1);
>   }
> 
>   #ifdef CONFIG_HIBERNATION
> @@ -3623,6 +3643,10 @@ static void setup_zone_pageset(struct zone *zone)
>   void __init setup_per_cpu_pageset(void)
>   {
>   	struct zone *zone;
> +	int ret;
> +
> +	ret = zalloc_cpumask_var(&cpus_with_pcps, GFP_KERNEL);
> +	BUG_ON(!ret);
> 
>   	for_each_populated_zone(zone)
>   		setup_zone_pageset(zone);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
