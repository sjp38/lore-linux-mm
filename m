Date: Wed, 14 Feb 2007 14:24:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Use ZVC counters to establish exact size of dirtyable pages
Message-Id: <20070214142432.a7e913fa.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0702130933001.23798@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702121014500.15560@schroedinger.engr.sgi.com>
	<20070213000411.a6d76e0c.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702130933001.23798@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Feb 2007 09:43:43 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> We can use the global ZVC counters to establish the exact size of the LRU
> and the free pages.  This allows a more accurate determination of the dirty
> ratio.
> 
> This patch will fix the broken ratio calculations if large amounts of
> memory are allocated to huge pags or other consumers that do not put the
> pages on to the LRU.
> 
> Notes:
> - I did not add NR_SLAB_RECLAIMABLE to the calculation of the
>   dirtyable pages. Those may be reclaimable but they are at this
>   point not dirtyable. If NR_SLAB_RECLAIMABLE would be considered
>   then a huge number of reclaimable pages would stop writeback
>   from occurring.
> 
> - This patch used to be in mm as the last one in a series of patches.
>   It was removed when Linus updated the treatment of highmem because
>   there was a conflict. I updated the patch to follow Linus' approach.
>   This patch is neede to fulfill the claims made in the beginning of the
>   patchset that is now in Linus' tree.
> 

Let's get paranoid.

> --- linux-2.6.orig/mm/page-writeback.c	2007-02-12 09:15:22.000000000 -0800
> +++ linux-2.6/mm/page-writeback.c	2007-02-13 09:40:04.000000000 -0800
> @@ -119,6 +119,38 @@ static void background_writeout(unsigned
>   * We make sure that the background writeout level is below the adjusted
>   * clamping level.
>   */
> +
> +static unsigned long highmem_dirtyable_memory(void)
> +{
> +#ifdef CONFIG_HIGHMEM
> +	int node;
> +	unsigned long x = 0;
> +
> +	for_each_online_node(node) {
> +		struct zone *z =
> +			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
> +
> +		x += zone_page_state(z, NR_FREE_PAGES)
> +			+ zone_page_state(z, NR_INACTIVE)
> +			+ zone_page_state(z, NR_ACTIVE);
> +	}
> +	return x;
> +#else
> +	return 0;
> +#endif
> +}
> +
> +static unsigned long determine_dirtyable_memory(void)
> +{
> +	unsigned long x;
> +
> +	x = global_page_state(NR_FREE_PAGES)
> +		+ global_page_state(NR_INACTIVE)
> +		+ global_page_state(NR_ACTIVE)
> +		- highmem_dirtyable_memory();
> +	return x;
> +}

Suppose a zone has ten dirty pages.  All the remaining pages in the zone
are off being used for soundcard buffers and networking skbs.

The zone's ten dirty pages are temporarily off the LRU, being processed by
the vm scanner.

So we're now in the state where the zone has more dirty pages than it has
dirtyable memory(!).

This function will return zero.  Which I think we'll happen to handle OK.

But this function can, I think, also return negative (ie: very large)
numbers.  I don't think we handle that right.


>  static void
>  get_dirty_limits(long *pbackground, long *pdirty,
>  					struct address_space *mapping)
> @@ -128,17 +160,9 @@ get_dirty_limits(long *pbackground, long
>  	int unmapped_ratio;
>  	long background;
>  	long dirty;
> -	unsigned long available_memory = vm_total_pages;
> +	unsigned long available_memory = determine_dirtyable_memory();
>  	struct task_struct *tsk;
>  
> -#ifdef CONFIG_HIGHMEM
> -	/*
> -	 * We always exclude high memory from our count.
> -	 */
> -	available_memory -= totalhigh_pages;
> -#endif
> -
> -
>  	unmapped_ratio = 100 - ((global_page_state(NR_FILE_MAPPED) +
>  				global_page_state(NR_ANON_PAGES)) * 100) /
>  					vm_total_pages;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
