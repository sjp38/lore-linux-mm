Date: Mon, 15 May 2006 23:44:35 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/6] Have ia64 use add_active_range() and free_area_init_nodes
In-Reply-To: <20060515122728.GA29253@skynet.ie>
Message-ID: <Pine.LNX.4.64.0605152342520.30476@skynet.skynet.ie>
References: <20060508141030.26912.93090.sendpatchset@skynet>
 <20060508141211.26912.48278.sendpatchset@skynet> <20060514203158.216a966e.akpm@osdl.org>
 <20060515122728.GA29253@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Andy Whitcroft <apw@shadowen.org>, davej@codemonkey.org.uk, tony.luck@intel.com, linux-kernel@vger.kernel.org, bob.picco@hp.com, ak@suse.de, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

> diff -rup -X /usr/src/patchset-0.5/bin//dontdiff linux-2.6.17-rc4-mm4-clean/mm/page_alloc.c linux-2.6.17-rc4-mm4-ia64_force_alignment/mm/page_alloc.c
> --- linux-2.6.17-rc4-mm4-clean/mm/page_alloc.c	2006-05-15 10:37:55.000000000 +0100
> +++ linux-2.6.17-rc4-mm4-ia64_force_alignment/mm/page_alloc.c	2006-05-15 13:10:42.000000000 +0100
> @@ -2640,14 +2640,20 @@ void __init free_area_init_nodes(unsigne
> {
> 	unsigned long nid;
> 	int zone_index;
> +	unsigned long lowest_pfn = find_min_pfn_with_active_regions();
> +
> +	lowest_pfn = zone_boundary_align_pfn(lowest_pfn);
> +	arch_max_dma_pfn = zone_boundary_align_pfn(arch_max_dma_pfn);
> +	arch_max_dma32_pfn = zone_boundary_align_pfn(arch_max_dma32_pfn);
> +	arch_max_low_pfn = zone_boundary_align_pfn(arch_max_low_pfn);
> +	arch_max_high_pfn = zone_boundary_align_pfn(arch_max_high_pfn);
>
> 	/* Record where the zone boundaries are */
> 	memset(arch_zone_lowest_possible_pfn, 0,
> 				sizeof(arch_zone_lowest_possible_pfn));
> 	memset(arch_zone_highest_possible_pfn, 0,
> 				sizeof(arch_zone_highest_possible_pfn));
> -	arch_zone_lowest_possible_pfn[ZONE_DMA] =
> -					find_min_pfn_with_active_regions();
> +	arch_zone_lowest_possible_pfn[ZONE_DMA] = lowest_pfn;
> 	arch_zone_highest_possible_pfn[ZONE_DMA] = arch_max_dma_pfn;
> 	arch_zone_highest_possible_pfn[ZONE_DMA32] = arch_max_dma32_pfn;
> 	arch_zone_highest_possible_pfn[ZONE_NORMAL] = arch_max_low_pfn;
>

Ok, this patch is broken in a number of ways. It doesn't help the IA64 
problem at all and two other machine configurations failed with the patch 
applied during regression testing. Please drop and I'll figure out what 
the correct solution is to your IA64 machine not booting.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
