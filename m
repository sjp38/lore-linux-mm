Date: Wed, 05 Oct 2005 08:10:05 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: [PATCH] i386: nid_zone_sizes_init() update
Message-ID: <189750000.1128525005@[10.10.2.4]>
In-Reply-To: <20051005083515.4305.16399.sendpatchset@cherry.local>
References: <20051005083515.4305.16399.sendpatchset@cherry.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Broken out nid_zone_sizes_init() change from i386 NUMA emulation code.

Mmmm. what's the purpose of this change? Not sure I understand what
you're trying to acheive here ... looks like you're just removing
some abstractions? To me, they made the code a bit easier to read.
 
> Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
> ---
> 
> Applies on top of linux-2.6.14-rc2-git8-mhp1
> 
> --- from-0053/arch/i386/kernel/setup.c
> +++ to-work/arch/i386/kernel/setup.c	2005-10-04 15:18:54.000000000 +0900
> @@ -1215,31 +1215,24 @@ static inline unsigned long max_hardware
>  {
>  	return virt_to_phys((char *)MAX_DMA_ADDRESS) >> PAGE_SHIFT;
>  }
> -static inline unsigned long  nid_size_pages(int nid)
> -{
> -	return node_end_pfn[nid] - node_start_pfn[nid];
> -}
> -static inline int nid_starts_in_highmem(int nid)
> -{
> -	return node_start_pfn[nid] >= max_low_pfn;
> -}
>  
>  void __init nid_zone_sizes_init(int nid)
>  {
>  	unsigned long zones_size[MAX_NR_ZONES] = {0, 0, 0};
> -	unsigned long max_dma;
> +	unsigned long max_dma = min(max_hardware_dma_pfn(), max_low_pfn);
>  	unsigned long start = node_start_pfn[nid];
>  	unsigned long end = node_end_pfn[nid];
>  
>  	if (node_has_online_mem(nid)){
> -		if (nid_starts_in_highmem(nid)) {
> -			zones_size[ZONE_HIGHMEM] = nid_size_pages(nid);
> -		} else {
> -			max_dma = min(max_hardware_dma_pfn(), max_low_pfn);
> -			zones_size[ZONE_DMA] = max_dma;
> -			zones_size[ZONE_NORMAL] = max_low_pfn - max_dma;
> -			zones_size[ZONE_HIGHMEM] = end - max_low_pfn;
> +		if (start < max_dma) {
> +			zones_size[ZONE_DMA] = min(end, max_dma) - start;
> +		}
> +		if (start < max_low_pfn && max_dma < end) {
> +			zones_size[ZONE_NORMAL] = min(end, max_low_pfn) - max(start, max_dma);
>  		}
> +		if (max_low_pfn <= end) {
> +			zones_size[ZONE_HIGHMEM] = end - max(start, max_low_pfn);
> +               }
>  	}
>  
>  	free_area_init_node(nid, NODE_DATA(nid), zones_size, start,
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
