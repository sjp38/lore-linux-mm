Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D1A22280852
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 05:30:54 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id a110so130796wrc.1
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 02:30:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 34si2936984wrf.313.2017.08.24.02.30.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 02:30:52 -0700 (PDT)
Date: Thu, 24 Aug 2017 11:30:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: don't reserve ZONE_HIGHMEM for
 ZONE_MOVABLE request
Message-ID: <20170824093050.GD5943@dhcp22.suse.cz>
References: <1503553546-27450-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1503553546-27450-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu 24-08-17 14:45:46, Joonsoo Kim wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Freepage on ZONE_HIGHMEM doesn't work for kernel memory so it's not that
> important to reserve. When ZONE_MOVABLE is used, this problem would
> theorectically cause to decrease usable memory for GFP_HIGHUSER_MOVABLE
> allocation request which is mainly used for page cache and anon page
> allocation. So, fix it.

I do not really understand what is the problem you are trying to fix.
Yes the memory is reserved for a higher priority consumer and that is
deliberate AFAICT. Just consider that an OOM victim wants to make
further progress and rely on memory reserve while doing
GFP_HIGHUSER_MOVABLE request.

So what is the real problem you are trying to address here?

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
>  include/linux/mmzone.h |  2 +-
>  mm/page_alloc.c        | 11 ++++++-----
>  2 files changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index e7e92c8..e5f134b 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -882,7 +882,7 @@ int min_free_kbytes_sysctl_handler(struct ctl_table *, int,
>  					void __user *, size_t *, loff_t *);
>  int watermark_scale_factor_sysctl_handler(struct ctl_table *, int,
>  					void __user *, size_t *, loff_t *);
> -extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
> +extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES];
>  int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int,
>  					void __user *, size_t *, loff_t *);
>  int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *, int,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 90b1996..6faa53d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -202,17 +202,18 @@ static void __free_pages_ok(struct page *page, unsigned int order);
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
> +	[ZONE_HIGHMEM] = INT_MAX,
>  #endif
> -	 32,
> +	[ZONE_MOVABLE] = INT_MAX,
>  };
>  
>  EXPORT_SYMBOL(totalram_pages);
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
