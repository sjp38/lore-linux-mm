Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id E3B7E6B004D
	for <linux-mm@kvack.org>; Fri, 23 Dec 2011 05:28:16 -0500 (EST)
Date: Fri, 23 Dec 2011 10:28:10 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 5/5] mm: Only IPI CPUs to drain local pages if they
 exist
Message-ID: <20111223102810.GT3487@suse.de>
References: <1321960128-15191-1-git-send-email-gilad@benyossef.com>
 <1321960128-15191-6-git-send-email-gilad@benyossef.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1321960128-15191-6-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>

On Tue, Nov 22, 2011 at 01:08:48PM +0200, Gilad Ben-Yossef wrote:
> Calculate a cpumask of CPUs with per-cpu pages in any zone and only send an IPI requesting CPUs to drain these pages to the buddy allocator if they actually have pages when asked to flush.
> 
> The code path of memory allocation failure for CPUMASK_OFFSTACK=y config was tested using fault injection framework.
> 
> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
> Acked-by: Christoph Lameter <cl@linux.com>
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
> ---
>  mm/page_alloc.c |   18 +++++++++++++++++-
>  1 files changed, 17 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9dd443d..a3efdf1 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1119,7 +1119,23 @@ void drain_local_pages(void *arg)
>   */
>  void drain_all_pages(void)
>  {
> -	on_each_cpu(drain_local_pages, NULL, 1);
> +	int cpu;
> +	struct zone *zone;
> +	cpumask_var_t cpus;
> +	struct per_cpu_pageset *pcp;
> +
> +	if (likely(zalloc_cpumask_var(&cpus, GFP_ATOMIC))) {
> +		for_each_online_cpu(cpu) {
> +			for_each_populated_zone(zone) {
> +				pcp = per_cpu_ptr(zone->pageset, cpu);
> +				if (pcp->pcp.count)
> +					cpumask_set_cpu(cpu, cpus);
> +		}
> +	}
> +		on_each_cpu_mask(cpus, drain_local_pages, NULL, 1);
> +		free_cpumask_var(cpus);

The indenting there is very weird but easily fixed.

A greater concern is that we are calling zalloc_cpumask_var() from the
direct reclaim path when we are already under memory pressure. How often
is this path hit and how often does the allocation fail?

Related to that, calling into the page allocator again for
zalloc_cpumask_var is not cheap.  Does reducing the number of IPIs
offset the cost of calling into the allocator again? How often does it
offset the cost and how often does it end up costing more? I guess that
would heavily depend on the number of CPUs and how many of them have
pages in their per-cpu buffer. Basically, sometimes we *might* save but
it comes at a definite cost of calling into the page allocator again.

The patch looks ok functionally but I'm skeptical that it really helps
performance.

> +	} else
> +		on_each_cpu(drain_local_pages, NULL, 1);
>  }
>  
>  #ifdef CONFIG_HIBERNATION

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
