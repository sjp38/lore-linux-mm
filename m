Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C28876B006E
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 11:00:29 -0500 (EST)
Date: Tue, 15 Nov 2011 10:00:21 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 5/5] mm: Only IPI CPUs to drain local pages if they
 exist
In-Reply-To: <1321179449-6675-6-git-send-email-gilad@benyossef.com>
Message-ID: <alpine.DEB.2.00.1111150956410.22502@router.home>
References: <1321179449-6675-1-git-send-email-gilad@benyossef.com> <1321179449-6675-6-git-send-email-gilad@benyossef.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>

On Sun, 13 Nov 2011, Gilad Ben-Yossef wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9dd443d..44dc6c5 100644
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
> +	struct per_cpu_pageset *pageset;

We usually name such pointers "pcp" in the page allocator.

> +
> +	if (likely(zalloc_cpumask_var(&cpus, GFP_ATOMIC))) {
> +		for_each_populated_zone(zone) {
> +			for_each_online_cpu(cpu) {
> +				pageset = per_cpu_ptr(zone->pageset, cpu);
> +				if (pageset->pcp.count)
> +					cpumask_set_cpu(cpu, cpus);
> +		}

The pagesets are allocated on bootup from the per cpu areas. You may get a
better access pattern by using for_each_online_cpu as the outer loop
because their is a likelyhood of linear increasing accesses as you loop
through the zones for a particular cpu.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
