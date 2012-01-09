Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id D53136B005C
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 11:35:31 -0500 (EST)
Date: Mon, 9 Jan 2012 10:35:26 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v6 7/8] mm: only IPI CPUs to drain local pages if they
 exist
In-Reply-To: <1326040026-7285-8-git-send-email-gilad@benyossef.com>
Message-ID: <alpine.DEB.2.00.1201091034390.31395@router.home>
References: <y> <1326040026-7285-8-git-send-email-gilad@benyossef.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.org>

On Sun, 8 Jan 2012, Gilad Ben-Yossef wrote:

> @@ -67,6 +67,14 @@ DEFINE_PER_CPU(int, numa_node);
>  EXPORT_PER_CPU_SYMBOL(numa_node);
>  #endif
>
> +/*
> + * A global cpumask of CPUs with per-cpu pages that gets
> + * recomputed on each drain. We use a global cpumask
> + * here to avoid allocation on direct reclaim code path
> + * for CONFIG_CPUMASK_OFFSTACK=y
> + */
> +static cpumask_var_t cpus_with_pcps;

Move the static definition into drain_all_pages()?

> +
>  #ifdef CONFIG_HAVE_MEMORYLESS_NODES
>  /*
>   * N.B., Do NOT reference the '_numa_mem_' per cpu variable directly.
> @@ -1097,7 +1105,19 @@ void drain_local_pages(void *arg)
>   */
>  void drain_all_pages(void)
>  {
> -	on_each_cpu(drain_local_pages, NULL, 1);
> +	int cpu;
> +	struct per_cpu_pageset *pcp;
> +	struct zone *zone;
> +
> +	for_each_online_cpu(cpu)
> +		for_each_populated_zone(zone) {
> +			pcp = per_cpu_ptr(zone->pageset, cpu);
> +			if (pcp->pcp.count)
> +				cpumask_set_cpu(cpu, cpus_with_pcps);
> +			else
> +				cpumask_clear_cpu(cpu, cpus_with_pcps);
> +		}
> +	on_each_cpu_mask(cpus_with_pcps, drain_local_pages, NULL, 1);
>  }
>
>  #ifdef CONFIG_HIBERNATION
> @@ -3601,6 +3621,10 @@ static void setup_zone_pageset(struct zone *zone)
>  void __init setup_per_cpu_pageset(void)
>  {
>  	struct zone *zone;
> +	int ret;
> +
> +	ret = zalloc_cpumask_var(&cpus_with_pcps, GFP_KERNEL);
> +	BUG_ON(!ret);
>
>  	for_each_populated_zone(zone)
>  		setup_zone_pageset(zone);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
