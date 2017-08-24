Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 180AE6B04C4
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 05:42:02 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id m1so123160wmd.3
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 02:42:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j38si3019899wre.521.2017.08.24.02.42.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 02:42:00 -0700 (PDT)
Subject: Re: [PATCH] mm/page_alloc: don't reserve ZONE_HIGHMEM for
 ZONE_MOVABLE request
References: <1503553546-27450-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e919c65e-bc2f-6b3b-41fc-3589590a84ac@suse.cz>
Date: Thu, 24 Aug 2017 11:41:58 +0200
MIME-Version: 1.0
In-Reply-To: <1503553546-27450-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 08/24/2017 07:45 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Freepage on ZONE_HIGHMEM doesn't work for kernel memory so it's not that
> important to reserve. When ZONE_MOVABLE is used, this problem would
> theorectically cause to decrease usable memory for GFP_HIGHUSER_MOVABLE
> allocation request which is mainly used for page cache and anon page
> allocation. So, fix it.
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

Looks like I did that almost year ago, so definitely had to refresh my
memory now :)

Anyway now I looked more thoroughly and noticed that this change leaks
into the reported sysctl. On a 64bit system with ZONE_MOVABLE:

before the patch:
vm.lowmem_reserve_ratio = 256   256     32

after the patch:
vm.lowmem_reserve_ratio = 256   256     32      2147483647

So if we indeed remove HIGHMEM from protection (c.f. Michal's mail), we
should do that differently than with the INT_MAX trick, IMHO.

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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
