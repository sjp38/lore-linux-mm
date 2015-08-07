Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0EF8B6B0038
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 03:49:27 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so50128064pab.0
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 00:49:26 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id ho6si16116872pac.147.2015.08.07.00.49.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Aug 2015 00:49:26 -0700 (PDT)
Received: by pacrr5 with SMTP id rr5so46967450pac.3
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 00:49:25 -0700 (PDT)
Date: Fri, 7 Aug 2015 16:50:01 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 1/1] mm: vmstat: introducing vm counter for slowpath
Message-ID: <20150807075001.GK1891@swordfish>
References: <1438931334-25894-1-git-send-email-pintu.k@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438931334-25894-1-git-send-email-pintu.k@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Kumar <pintu.k@samsung.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, dave@stgolabs.net, mhocko@suse.cz, koct9i@gmail.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.k@outlook.com, vishnu.ps@samsung.com, rohit.kr@samsung.com

On (08/07/15 12:38), Pintu Kumar wrote:
> This patch add new counter slowpath_entered in /proc/vmstat to
> track how many times the system entered into slowpath after
> first allocation attempt is failed.
> This is useful to know the rate of allocation success within
> the slowpath.
> This patch is tested on ARM with 512MB RAM.
> A sample output is shown below after successful boot-up:
> shell> cat /proc/vmstat
> nr_free_pages 4712
> pgalloc_normal 1319432
> pgalloc_movable 0
> pageoutrun 379
> allocstall 0
> slowpath_entered 585
> compact_stall 0
> compact_fail 0
> compact_success 0
> 
> From the above output we can see that the system entered
> slowpath 585 times.

so what can you do with this number?

	-ss

> But the existing counter kswapd(pageoutrun), direct_reclaim(allocstall),
> direct_compact(compact_stall) does not tell this value.
> From the above value, it clearly indicates that the system have
> entered slowpath 585 times. Out of which 379 times allocation passed
> through kswapd, without performing direct reclaim/compaction.
> That means the remaining 206 times the allocation would have succeeded
> using the alloc_pages_high_priority.
> 
> Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
> ---
>  include/linux/vm_event_item.h |    2 +-
>  mm/page_alloc.c               |    2 ++
>  mm/vmstat.c                   |    2 +-
>  3 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
> index 2b1cef8..9825f294 100644
> --- a/include/linux/vm_event_item.h
> +++ b/include/linux/vm_event_item.h
> @@ -37,7 +37,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  #endif
>  		PGINODESTEAL, SLABS_SCANNED, KSWAPD_INODESTEAL,
>  		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
> -		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
> +		PAGEOUTRUN, ALLOCSTALL, SLOWPATH_ENTERED, PGROTATED,
>  		DROP_PAGECACHE, DROP_SLAB,
>  #ifdef CONFIG_NUMA_BALANCING
>  		NUMA_PTE_UPDATES,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2024d2e..4a5d487 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3029,6 +3029,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	if (IS_ENABLED(CONFIG_NUMA) && (gfp_mask & __GFP_THISNODE) && !wait)
>  		goto nopage;
>  
> +	count_vm_event(SLOWPATH_ENTERED);
> +
>  retry:
>  	if (!(gfp_mask & __GFP_NO_KSWAPD))
>  		wake_all_kswapds(order, ac);
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 1fd0886..1c54fdf 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -778,7 +778,7 @@ const char * const vmstat_text[] = {
>  	"kswapd_high_wmark_hit_quickly",
>  	"pageoutrun",
>  	"allocstall",
> -
> +	"slowpath_entered",
>  	"pgrotated",
>  
>  	"drop_pagecache",
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
