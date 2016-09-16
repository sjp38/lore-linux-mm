Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 467246B0069
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 23:14:30 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l132so2072510wmf.0
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 20:14:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z3si1892531wjh.38.2016.09.15.20.14.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 20:14:29 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8G3D2iN024899
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 23:14:27 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25fsbjhdpf-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 23:14:27 -0400
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 15 Sep 2016 23:14:27 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 1/6] mm/page_alloc: don't reserve ZONE_HIGHMEM for ZONE_MOVABLE request
In-Reply-To: <1472447255-10584-2-git-send-email-iamjoonsoo.kim@lge.com>
References: <1472447255-10584-1-git-send-email-iamjoonsoo.kim@lge.com> <1472447255-10584-2-git-send-email-iamjoonsoo.kim@lge.com>
Date: Fri, 16 Sep 2016 08:44:17 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87sht0y1rq.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

js1304@gmail.com writes:

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
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  include/linux/mmzone.h | 2 +-
>  mm/page_alloc.c        | 7 ++++---
>  2 files changed, 5 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index d572b78..e3f39af 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -877,7 +877,7 @@ int min_free_kbytes_sysctl_handler(struct ctl_table *, int,
>  					void __user *, size_t *, loff_t *);
>  int watermark_scale_factor_sysctl_handler(struct ctl_table *, int,
>  					void __user *, size_t *, loff_t *);
> -extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
> +extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES];
>  int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int,
>  					void __user *, size_t *, loff_t *);
>  int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *, int,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4f7d5d7..a8310de 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -198,17 +198,18 @@ static void __free_pages_ok(struct page *page, unsigned int order);
>   * TBD: should special case ZONE_DMA32 machines here - in those we normally
>   * don't need any ZONE_NORMAL reservation
>   */
> -int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = {
> +int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES] = {
>  #ifdef CONFIG_ZONE_DMA
>  	 256,
>  #endif
>  #ifdef CONFIG_ZONE_DMA32
>  	 256,
>  #endif
> -#ifdef CONFIG_HIGHMEM
>  	 32,
> +#ifdef CONFIG_HIGHMEM
> +	 INT_MAX,
>  #endif
> -	 32,
> +	 INT_MAX,
>  };
>
>  EXPORT_SYMBOL(totalram_pages);
> -- 
> 1.9.1

We can also do things like below to make it readable ?

#ifdef CONFIG_ZONE_DMA
	[ZONE_DMA] = 256,
#endif

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
