Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id EA7FD6B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 09:59:04 -0500 (EST)
Date: Mon, 30 Jan 2012 14:59:00 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [v7 7/8] mm: only IPI CPUs to drain local pages if they exist
Message-ID: <20120130145900.GR25268@csn.ul.ie>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
 <1327572121-13673-8-git-send-email-gilad@benyossef.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1327572121-13673-8-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Milton Miller <miltonm@bga.com>

On Thu, Jan 26, 2012 at 12:02:00PM +0200, Gilad Ben-Yossef wrote:
> Calculate a cpumask of CPUs with per-cpu pages in any zone
> and only send an IPI requesting CPUs to drain these pages
> to the buddy allocator if they actually have pages when
> asked to flush.
> 
> This patch saves 85%+ of IPIs asking to drain per-cpu
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
> Tested by running "hackbench 400" on a 8 CPU x86 VM and
> observing the difference between the number of direct
> reclaim attempts that end up in drain_all_pages() and
> those were more then 1/2 of the online CPU had any per-cpu
> page in them, using the vmstat counters introduced
> in the next patch in the series and using proc/interrupts.
> 
> In the test sceanrio, this was seen to save around 3600 global
> IPIs after trigerring an OOM on a concurrent workload:
> 
> $ cat /proc/vmstat | tail -n 2
> pcp_global_drain 0
> pcp_global_ipi_saved 0
> 
> $ cat /proc/interrupts | grep CAL
> CAL:          1          2          1          2
>           2          2          2          2   Function call interrupts
> 
> $ hackbench 400
> [OOM messages snipped]
> 
> $ cat /proc/vmstat | tail -n 2
> pcp_global_drain 3647
> pcp_global_ipi_saved 3642
> 
> $ cat /proc/interrupts | grep CAL
> CAL:          6         13          6          3
>           3          3         1 2          7   Function call interrupts
> 
> Please note that if the global drain is removed from the
> direct reclaim path as a patch from Mel Gorman currently
> suggests this should be replaced with an on_each_cpu_cond
> invocation.
> 
> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
> CC: Mel Gorman <mel@csn.ul.ie>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Christoph Lameter <cl@linux.com>
> CC: Chris Metcalf <cmetcalf@tilera.com>
> CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> CC: Frederic Weisbecker <fweisbec@gmail.com>
> CC: Russell King <linux@arm.linux.org.uk>
> CC: linux-mm@kvack.org
> CC: Pekka Enberg <penberg@kernel.org>
> CC: Matt Mackall <mpm@selenic.com>
> CC: Sasha Levin <levinsasha928@gmail.com>
> CC: Rik van Riel <riel@redhat.com>
> CC: Andi Kleen <andi@firstfloor.org>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Alexander Viro <viro@zeniv.linux.org.uk>
> CC: linux-fsdevel@vger.kernel.org
> CC: Avi Kivity <avi@redhat.com>
> CC: Michal Nazarewicz <mina86@mina86.com>
> CC: Milton Miller <miltonm@bga.com>
> ---
>  mm/page_alloc.c |   31 ++++++++++++++++++++++++++++++-
>  1 files changed, 30 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d2186ec..4135983 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1165,7 +1165,36 @@ void drain_local_pages(void *arg)
>   */
>  void drain_all_pages(void)
>  {
> -	on_each_cpu(drain_local_pages, NULL, 1);
> +	int cpu;
> +	struct per_cpu_pageset *pcp;
> +	struct zone *zone;
> +
> +	/* Allocate in the BSS so we wont require allocation in
> +	 * direct reclaim path for CONFIG_CPUMASK_OFFSTACK=y
> +	 */
> +	static cpumask_t cpus_with_pcps;
> +
> +	/*
> +	 * We don't care about racing with CPU hotplug event
> +	 * as offline notification will cause the notified
> +	 * cpu to drain that CPU pcps and on_each_cpu_mask
> +	 * disables preemption as part of its processing
> +	 */
> +	for_each_online_cpu(cpu) {
> +		bool has_pcps = false;
> +		for_each_populated_zone(zone) {
> +			pcp = per_cpu_ptr(zone->pageset, cpu);
> +			if (pcp->pcp.count) {
> +				has_pcps = true;
> +				break;
> +			}
> +		}
> +		if (has_pcps)
> +			cpumask_set_cpu(cpu, &cpus_with_pcps);
> +		else
> +			cpumask_clear_cpu(cpu, &cpus_with_pcps);
> +	}

Lets take two CPUs running this code at the same time. CPU 1 has per-cpu
pages in all zones. CPU 2 has no per-cpu pages in any zone. If both run
at the same time, CPU 2 can be clearing the mask for CPU 1 before it has
had a chance to send the IPI. This means we'll miss sending IPIs to CPUs
that we intended to. As I was willing to send no IPI at all;

Acked-by: Mel Gorman <mel@csn.ul.ie>

But if this gets another revision, add a comment saying that two CPUs
can interfere with each other running at the same time but we don't
care.

> +	on_each_cpu_mask(&cpus_with_pcps, drain_local_pages, NULL, 1);
>  }
>  
>  #ifdef CONFIG_HIBERNATION
> -- 
> 1.7.0.4
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
