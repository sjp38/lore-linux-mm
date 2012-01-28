Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 977466B004D
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 19:12:38 -0500 (EST)
Date: Fri, 27 Jan 2012 16:12:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [v7 7/8] mm: only IPI CPUs to drain local pages if they exist
Message-Id: <20120127161236.ff1e7e7e.akpm@linux-foundation.org>
In-Reply-To: <1327572121-13673-8-git-send-email-gilad@benyossef.com>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
	<1327572121-13673-8-git-send-email-gilad@benyossef.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Milton Miller <miltonm@bga.com>

On Thu, 26 Jan 2012 12:02:00 +0200
Gilad Ben-Yossef <gilad@benyossef.com> wrote:

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
>
> ...
>
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

hmmm.

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
> +	on_each_cpu_mask(&cpus_with_pcps, drain_local_pages, NULL, 1);
>  }

Can we end up sending an IPI to a now-unplugged CPU?  That won't work
very well if that CPU is now sitting on its sysadmin's desk.

There's also the case of CPU online.  We could end up failing to IPI a
CPU which now has some percpu pages.  That's not at all serious - 90%
is good enough in page reclaim.  But this thinking merits a mention in
the comment.  Or we simply make this code hotplug-safe.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
