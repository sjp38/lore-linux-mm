Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 49735828E1
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 11:32:00 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k135so155254584lfb.2
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 08:32:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y12si17109384wjw.183.2016.08.04.23.45.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Aug 2016 23:45:06 -0700 (PDT)
Subject: Re: [PATCH V2 1/2] mm/page_alloc: Replace set_dma_reserve to
 set_memory_reserve
References: <1470330729-6273-1-git-send-email-srikar@linux.vnet.ibm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <09d5b30e-5956-bf64-5f4c-ea5425d7f7a5@suse.cz>
Date: Fri, 5 Aug 2016 08:45:03 +0200
MIME-Version: 1.0
In-Reply-To: <1470330729-6273-1-git-send-email-srikar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Balbir Singh <bsingharora@gmail.com>

On 08/04/2016 07:12 PM, Srikar Dronamraju wrote:
> Expand the scope of the existing dma_reserve to accommodate other memory
> reserves too. Accordingly rename variable dma_reserve to
> nr_memory_reserve.
>
> set_memory_reserve also takes a new parameter that helps to identify if
> the current value needs to be incremented.
>
> Suggested-by: Mel Gorman <mgorman@techsingularity.net>
> Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> ---
>  arch/x86/kernel/e820.c |  2 +-
>  include/linux/mm.h     |  2 +-
>  mm/page_alloc.c        | 20 ++++++++++++--------
>  3 files changed, 14 insertions(+), 10 deletions(-)
>
> diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
> index 621b501..d935983 100644
> --- a/arch/x86/kernel/e820.c
> +++ b/arch/x86/kernel/e820.c
> @@ -1188,6 +1188,6 @@ void __init memblock_find_dma_reserve(void)
>  			nr_free_pages += end_pfn - start_pfn;
>  	}
>
> -	set_dma_reserve(nr_pages - nr_free_pages);
> +	set_memory_reserve(nr_pages - nr_free_pages, false);
>  #endif
>  }
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 8f468e0..c884ffb 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1886,7 +1886,7 @@ extern int __meminit __early_pfn_to_nid(unsigned long pfn,
>  					struct mminit_pfnnid_cache *state);
>  #endif
>
> -extern void set_dma_reserve(unsigned long new_dma_reserve);
> +extern void set_memory_reserve(unsigned long nr_reserve, bool inc);
>  extern void memmap_init_zone(unsigned long, int, unsigned long,
>  				unsigned long, enum memmap_context);
>  extern void setup_per_zone_wmarks(void);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c1069ef..a154c2f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -253,7 +253,7 @@ int watermark_scale_factor = 10;
>
>  static unsigned long __meminitdata nr_kernel_pages;
>  static unsigned long __meminitdata nr_all_pages;
> -static unsigned long __meminitdata dma_reserve;
> +static unsigned long __meminitdata nr_memory_reserve;
>
>  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>  static unsigned long __meminitdata arch_zone_lowest_possible_pfn[MAX_NR_ZONES];
> @@ -5493,10 +5493,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  		}
>
>  		/* Account for reserved pages */
> -		if (j == 0 && freesize > dma_reserve) {
> -			freesize -= dma_reserve;
> +		if (j == 0 && freesize > nr_memory_reserve) {

Will this really work (together with patch 2) as intended?
This j == 0 means that we are doing this only for the first zone, which 
is ZONE_DMA (or ZONE_DMA32) on node 0 on many systems. I.e. I don't 
think it's really true that "dma_reserve has nothing to do with DMA or 
ZONE_DMA".

This zone will have limited amount of memory, so the "freesize > 
nr_memory_reserve" will easily be false once you set this to many 
gigabytes, so in fact nothing will get subtracted.

On the other hand if the kernel has both CONFIG_ZONE_DMA and 
CONFIG_ZONE_DMA32 disabled, then j == 0 will be true for ZONE_NORMAL. 
This zone might be present on multiple nodes (unless they are configured 
as movable) and then the value intended to be global will be subtracted 
from several nodes.

I don't know what's the exact ppc64 situation here, perhaps there are 
indeed no DMA/DMA32 zones, and the fadump kernel only uses one node, so 
it works in the end, but it doesn't seem much robust to me?

> +			freesize -= nr_memory_reserve;
>  			printk(KERN_DEBUG "  %s zone: %lu pages reserved\n",
> -					zone_names[0], dma_reserve);
> +					zone_names[0], nr_memory_reserve);
>  		}
>
>  		if (!is_highmem_idx(j))
> @@ -6186,8 +6186,9 @@ void __init mem_init_print_info(const char *str)
>  }
>
>  /**
> - * set_dma_reserve - set the specified number of pages reserved in the first zone
> - * @new_dma_reserve: The number of pages to mark reserved
> + * set_memory_reserve - set number of pages reserved in the first zone
> + * @nr_reserve: The number of pages to mark reserved
> + * @inc: true increment to existing value; false set new value.
>   *
>   * The per-cpu batchsize and zone watermarks are determined by managed_pages.
>   * In the DMA zone, a significant percentage may be consumed by kernel image
> @@ -6196,9 +6197,12 @@ void __init mem_init_print_info(const char *str)
>   * first zone (e.g., ZONE_DMA). The effect will be lower watermarks and
>   * smaller per-cpu batchsize.
>   */
> -void __init set_dma_reserve(unsigned long new_dma_reserve)
> +void __init set_memory_reserve(unsigned long nr_reserve, bool inc)
>  {
> -	dma_reserve = new_dma_reserve;
> +	if (inc)
> +		nr_memory_reserve += nr_reserve;
> +	else
> +		nr_memory_reserve = nr_reserve;
>  }
>
>  void __init free_area_init(unsigned long *zones_size)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
