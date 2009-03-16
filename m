Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 626BC6B005A
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:22:22 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id AC9AF3048AC
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:29:02 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id bTtB7zYYUGrs for <linux-mm@kvack.org>;
	Mon, 16 Mar 2009 12:28:55 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2DDB230483D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:27:24 -0400 (EDT)
Date: Mon, 16 Mar 2009 12:19:06 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 24/35] Convert gfp_zone() to use a table of precalculated
 values
In-Reply-To: <1237196790-7268-25-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0903161218170.32577@qirst.com>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <1237196790-7268-25-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Mar 2009, Mel Gorman wrote:

> diff --git a/init/main.c b/init/main.c
> index 8442094..08a5663 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -573,6 +573,7 @@ asmlinkage void __init start_kernel(void)
>  	 * fragile until we cpu_idle() for the first time.
>  	 */
>  	preempt_disable();
> +	init_gfp_zone_table();
>  	build_all_zonelists();
>  	page_alloc_init();
>  	printk(KERN_NOTICE "Kernel command line: %s\n", boot_command_line);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index bc491fa..d76f57d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -70,6 +70,7 @@ EXPORT_SYMBOL(node_states);
>  unsigned long totalram_pages __read_mostly;
>  unsigned long totalreserve_pages __read_mostly;
>  unsigned long highest_memmap_pfn __read_mostly;
> +int gfp_zone_table[GFP_ZONEMASK] __read_mostly;
>  int static_num_online_nodes __read_mostly;
>  int percpu_pagelist_fraction;
>
> @@ -4569,7 +4570,7 @@ static void setup_per_zone_inactive_ratio(void)
>   * 8192MB:	11584k
>   * 16384MB:	16384k
>   */
> -static int __init init_per_zone_pages_min(void)
> +static int init_per_zone_pages_min(void)
>  {
>  	unsigned long lowmem_kbytes;
>
> @@ -4587,6 +4588,39 @@ static int __init init_per_zone_pages_min(void)
>  }
>  module_init(init_per_zone_pages_min)
>
> +static inline int __init gfp_flags_to_zone(gfp_t flags)
> +{
> +#ifdef CONFIG_ZONE_DMA
> +	if (flags & __GFP_DMA)
> +		return ZONE_DMA;
> +#endif
> +#ifdef CONFIG_ZONE_DMA32
> +	if (flags & __GFP_DMA32)
> +		return ZONE_DMA32;
> +#endif
> +	if ((flags & (__GFP_HIGHMEM | __GFP_MOVABLE)) ==
> +			(__GFP_HIGHMEM | __GFP_MOVABLE))
> +		return ZONE_MOVABLE;
> +#ifdef CONFIG_HIGHMEM
> +	if (flags & __GFP_HIGHMEM)
> +		return ZONE_HIGHMEM;
> +#endif
> +	return ZONE_NORMAL;
> +}
> +
> +/*
> + * For each possible combination of zone modifier flags, we calculate
> + * what zone it should be using. This consumes a cache line in most
> + * cases but avoids a number of branches in the allocator fast path
> + */
> +void __init init_gfp_zone_table(void)
> +{
> +	gfp_t gfp_flags;
> +
> +	for (gfp_flags = 0; gfp_flags < GFP_ZONEMASK; gfp_flags++)
> +		gfp_zone_table[gfp_flags] = gfp_flags_to_zone(gfp_flags);
> +}
> +

This is all known at compile time. The table can be calculated at compile
time with some ifdefs and then we do not need the init_gfp_zone_table().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
