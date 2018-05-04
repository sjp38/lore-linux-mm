Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BD0336B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 03:05:06 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 70so317456wmb.2
        for <linux-mm@kvack.org>; Fri, 04 May 2018 00:05:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 90-v6si12883783edq.64.2018.05.04.00.05.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 May 2018 00:05:05 -0700 (PDT)
Subject: Re: [PATCH] mm/page_alloc: use ac->high_zoneidx for classzone_idx
References: <1525408246-14768-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8b06973c-ef82-17d2-a83d-454368de75e6@suse.cz>
Date: Fri, 4 May 2018 09:03:02 +0200
MIME-Version: 1.0
In-Reply-To: <1525408246-14768-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Ye Xiaolong <xiaolong.ye@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 05/04/2018 06:30 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Currently, we use the zone index of preferred_zone which represents
> the best matching zone for allocation, as classzone_idx. It has a problem
> on NUMA system with ZONE_MOVABLE.
> 
> In NUMA system, it can be possible that each node has different populated
> zones. For example, node 0 could have DMA/DMA32/NORMAL/MOVABLE zone and
> node 1 could have only NORMAL zone. In this setup, allocation request
> initiated on node 0 and the one on node 1 would have different
> classzone_idx, 3 and 2, respectively, since their preferred_zones are
> different. If they are handled by only their own node, there is no problem.
> However, if they are somtimes handled by the remote node, the problem
> would happen.
> 
> In the following setup, allocation initiated on node 1 will have some
> precedence than allocation initiated on node 0 when former allocation is
> processed on node 0 due to not enough memory on node 1. They will have
> different lowmem reserve due to their different classzone_idx thus
> an watermark bars are also different.
> 
...

> 
> min watermark for NORMAL zone on node 0
> allocation initiated on node 0: 750 + 4096 = 4846
> allocation initiated on node 1: 750 + 0 = 750
> 
> This watermark difference could cause too many numa_miss allocation
> in some situation and then performance could be downgraded.
> 
> Recently, there was a regression report about this problem on CMA patches
> since CMA memory are placed in ZONE_MOVABLE by those patches. I checked
> that problem is disappeared with this fix that uses high_zoneidx
> for classzone_idx.
> 
> http://lkml.kernel.org/r/20180102063528.GG30397@yexl-desktop
> 
> Using high_zoneidx for classzone_idx is more consistent way than previous
> approach because system's memory layout doesn't affect anything to it.

So to summarize;
- ac->high_zoneidx is computed via the arcane gfp_zone(gfp_mask) and
represents the highest zone the allocation can use
- classzone_idx was supposed to be the highest zone that the allocation
can use, that is actually available in the system. Somehow that became
the highest zone that is available on the preferred node (in the default
node-order zonelist), which causes the watermark inconsistencies you
mention.

I don't see a problem with your change. I would be worried about
inflated reserves when e.g. ZONE_MOVABLE doesn't exist, but that doesn't
seem to be the case. My laptop has empty ZONE_MOVABLE and the
ZONE_NORMAL protection for movable is 0.

But there had to be some reason for classzone_idx to be like this and
not simple high_zoneidx. Maybe Mel remembers? Maybe it was important
then, but is not anymore? Sigh, it seems to be pre-git.

> With this patch, both classzone_idx on above example will be 3 so will
> have the same min watermark.
> 
> allocation initiated on node 0: 750 + 4096 = 4846
> allocation initiated on node 1: 750 + 4096 = 4846
> 
> Reported-by: Ye Xiaolong <xiaolong.ye@intel.com>
> Tested-by: Ye Xiaolong <xiaolong.ye@intel.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/internal.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/internal.h b/mm/internal.h
> index 228dd66..e1d7376 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -123,7 +123,7 @@ struct alloc_context {
>  	bool spread_dirty_pages;
>  };
>  
> -#define ac_classzone_idx(ac) zonelist_zone_idx(ac->preferred_zoneref)
> +#define ac_classzone_idx(ac) (ac->high_zoneidx)
>  
>  /*
>   * Locate the struct page for both the matching buddy in our
> 
