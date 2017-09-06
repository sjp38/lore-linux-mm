Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 092E6280400
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 03:54:46 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g50so511129wra.4
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 00:54:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e79si671524wma.237.2017.09.06.00.54.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Sep 2017 00:54:44 -0700 (PDT)
Subject: Re: [PATCH] mm/page_alloc: don't reserve ZONE_HIGHMEM for
 ZONE_MOVABLE request
References: <1504672525-17915-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <86ec4ba2-44df-f8ec-70da-d389ef7a8ecc@suse.cz>
Date: Wed, 6 Sep 2017 09:54:42 +0200
MIME-Version: 1.0
In-Reply-To: <1504672525-17915-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux API <linux-api@vger.kernel.org>

+CC linux-api

On 09/06/2017 06:35 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Freepage on ZONE_HIGHMEM doesn't work for kernel memory so it's not that
> important to reserve. When ZONE_MOVABLE is used, this problem would
> theorectically cause to decrease usable memory for GFP_HIGHUSER_MOVABLE
> allocation request which is mainly used for page cache and anon page
> allocation. So, fix it by setting 0 to
> sysctl_lowmem_reserve_ratio[ZONE_HIGHMEM].
> 
> And, defining sysctl_lowmem_reserve_ratio array by MAX_NR_ZONES - 1 size
> makes code complex. For example, if there is highmem system, following
> reserve ratio is activated for *NORMAL ZONE* which would be easyily
> misleading people.
> 
>  #ifdef CONFIG_HIGHMEM
>  32
>  #endif
> 
> This patch also fix this situation by defining sysctl_lowmem_reserve_ratio
> array by MAX_NR_ZONES and place "#ifdef" to right place.
> 
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  Documentation/sysctl/vm.txt |  5 ++---
>  include/linux/mmzone.h      |  2 +-
>  mm/page_alloc.c             | 25 ++++++++++++++-----------
>  3 files changed, 17 insertions(+), 15 deletions(-)
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 9baf66a..e9059d3 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -336,8 +336,6 @@ The lowmem_reserve_ratio is an array. You can see them by reading this file.
>  % cat /proc/sys/vm/lowmem_reserve_ratio
>  256     256     32
>  -
> -Note: # of this elements is one fewer than number of zones. Because the highest
> -      zone's value is not necessary for following calculation.
>  
>  But, these values are not used directly. The kernel calculates # of protection
>  pages for each zones from them. These are shown as array of protection pages
> @@ -388,7 +386,8 @@ As above expression, they are reciprocal number of ratio.
>  pages of higher zones on the node.
>  
>  If you would like to protect more pages, smaller values are effective.
> -The minimum value is 1 (1/1 -> 100%).
> +The minimum value is 1 (1/1 -> 100%). The value less than 1 completely
> +disables protection of the pages.
>  
>  ==============================================================
>  
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 356a814..d549c4e 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -890,7 +890,7 @@ int min_free_kbytes_sysctl_handler(struct ctl_table *, int,
>  					void __user *, size_t *, loff_t *);
>  int watermark_scale_factor_sysctl_handler(struct ctl_table *, int,
>  					void __user *, size_t *, loff_t *);
> -extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
> +extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES];
>  int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int,
>  					void __user *, size_t *, loff_t *);
>  int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *, int,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0f34356..2a7f7e9 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -203,17 +203,18 @@ static void __free_pages_ok(struct page *page, unsigned int order);
>   * TBD: should special case ZONE_DMA32 machines here - in those we normally
>   * don't need any ZONE_NORMAL reservation
>   */
> -int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = {
> +int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES] = {
>  #ifdef CONFIG_ZONE_DMA
> -	 256,
> +	[ZONE_DMA] = 256,
>  #endif
>  #ifdef CONFIG_ZONE_DMA32
> -	 256,
> +	[ZONE_DMA32] = 256,
>  #endif
> +	[ZONE_NORMAL] = 32,
>  #ifdef CONFIG_HIGHMEM
> -	 32,
> +	[ZONE_HIGHMEM] = 0,
>  #endif
> -	 32,
> +	[ZONE_MOVABLE] = 0,
>  };
>  
>  EXPORT_SYMBOL(totalram_pages);
> @@ -6921,13 +6922,15 @@ static void setup_per_zone_lowmem_reserve(void)
>  				struct zone *lower_zone;
>  
>  				idx--;
> -
> -				if (sysctl_lowmem_reserve_ratio[idx] < 1)
> -					sysctl_lowmem_reserve_ratio[idx] = 1;
> -
>  				lower_zone = pgdat->node_zones + idx;
> -				lower_zone->lowmem_reserve[j] = managed_pages /
> -					sysctl_lowmem_reserve_ratio[idx];
> +
> +				if (sysctl_lowmem_reserve_ratio[idx] < 1) {
> +					sysctl_lowmem_reserve_ratio[idx] = 0;
> +					lower_zone->lowmem_reserve[j] = 0;
> +				} else {
> +					lower_zone->lowmem_reserve[j] =
> +						managed_pages / sysctl_lowmem_reserve_ratio[idx];
> +				}
>  				managed_pages += lower_zone->managed_pages;
>  			}
>  		}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
