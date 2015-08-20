Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id CC2156B0038
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 09:30:58 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so145730126wic.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 06:30:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ba6si8489913wjb.54.2015.08.20.06.30.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Aug 2015 06:30:57 -0700 (PDT)
Subject: Re: [PATCH 01/10] mm, page_alloc: Delete the zonelist_cache
References: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net>
 <1439376335-17895-2-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55D5D68E.6040206@suse.cz>
Date: Thu, 20 Aug 2015 15:30:54 +0200
MIME-Version: 1.0
In-Reply-To: <1439376335-17895-2-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On 08/12/2015 12:45 PM, Mel Gorman wrote:
> The zonelist cache (zlc) was introduced to skip over zones that were
> recently known to be full. This avoided expensive operations such as the
> cpuset checks, watermark calculations and zone_reclaim. The situation
> today is different and the complexity of zlc is harder to justify.
>
> 1) The cpuset checks are no-ops unless a cpuset is active and in general are
>     a lot cheaper.
>
> 2) zone_reclaim is now disabled by default and I suspect that was a large
>     source of the cost that zlc wanted to avoid. When it is enabled, it's
>     known to be a major source of stalling when nodes fill up and it's
>     unwise to hit every other user with the overhead.
>
> 3) Watermark checks are expensive to calculate for high-order
>     allocation requests. Later patches in this series will reduce the cost
>     of the watermark checking.
>
> 4) The most important issue is that in the current implementation it
>     is possible for a failed THP allocation to mark a zone full for order-0
>     allocations and cause a fallback to remote nodes.
>
> The last issue could be addressed with additional complexity but as the
> benefit of zlc is questionable, it is better to remove it.  If stalls
> due to zone_reclaim are ever reported then an alternative would be to
> introduce deferring logic based on a timeout inside zone_reclaim itself
> and leave the page allocator fast paths alone.
>
> The impact on page-allocator microbenchmarks is negligible as they don't
> hit the paths where the zlc comes into play. The impact was noticeable
> in a workload called "stutter". One part uses a lot of anonymous memory,
> a second measures mmap latency and a third copies a large file. In an
> ideal world the latency application would not notice the mmap latency.
> On a 4-node machine the results of this patch are
>
> 4-node machine stutter
>                               4.2.0-rc1             4.2.0-rc1
>                                 vanilla           nozlc-v1r20
> Min         mmap     53.9902 (  0.00%)     49.3629 (  8.57%)
> 1st-qrtle   mmap     54.6776 (  0.00%)     54.1201 (  1.02%)
> 2nd-qrtle   mmap     54.9242 (  0.00%)     54.5961 (  0.60%)
> 3rd-qrtle   mmap     55.1817 (  0.00%)     54.9338 (  0.45%)
> Max-90%     mmap     55.3952 (  0.00%)     55.3929 (  0.00%)
> Max-93%     mmap     55.4766 (  0.00%)     57.5712 ( -3.78%)
> Max-95%     mmap     55.5522 (  0.00%)     57.8376 ( -4.11%)
> Max-99%     mmap     55.7938 (  0.00%)     63.6180 (-14.02%)
> Max         mmap   6344.0292 (  0.00%)     67.2477 ( 98.94%)
> Mean        mmap     57.3732 (  0.00%)     54.5680 (  4.89%)
>
> Note the maximum stall latency which was 6 seconds and becomes 67ms with
> this patch applied. However, also note that it is not guaranteed this
> benchmark always hits pathelogical cases and the milage varies. There is
> a secondary impact with more direct reclaim because zones are now being
> considered instead of being skipped by zlc.
>
>                                   4.1.0       4.1.0
>                                 vanilla  nozlc-v1r4
> Swap Ins                           838         502
> Swap Outs                      1149395     2622895
> DMA32 allocs                  17839113    15863747
> Normal allocs                129045707   137847920
> Direct pages scanned           4070089    29046893
> Kswapd pages scanned          17147837    17140694
> Kswapd pages reclaimed        17146691    17139601
> Direct pages reclaimed         1888879     4886630
> Kswapd efficiency                  99%         99%
> Kswapd velocity              17523.721   17518.928
> Direct efficiency                  46%         16%
> Direct velocity               4159.306   29687.854
> Percentage direct scans            19%         62%
> Page writes by reclaim     1149395.000 2622895.000
> Page writes file                     0           0
> Page writes anon               1149395     2622895

Interesting, kswapd has no decrease that would counter the increase in 
direct reclaim. So there's more reclaim overall. Does it mean that 
stutter doesn't like LRU and zlc was disrupting LRU?

> The direct page scan and reclaim rates are noticeable. It is possible
> this will not be a universal win on all workloads but cycling through
> zonelists waiting for zlc->last_full_zap to expire is not the right
> decision.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: David Rientjes <rientjes@google.com>

It doesn't seem that removal of zlc would increase overhead due to 
"expensive operations no longer being avoided". Making some corner-case 
benchmark(s) worse as a side-effect of different LRU approximation 
shouldn't be a show-stopper. Hence

Acked-by: Vlastimil Babka <vbabka@suse.cz>

just git grep found some lines that should be also deleted:

include/linux/mmzone.h: * If zlcache_ptr is not NULL, then it is just 
the address of zlcache,
include/linux/mmzone.h: * as explained above.  If zlcache_ptr is NULL, 
there is no zlcache.

And:

> @@ -3157,7 +2967,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>   	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
>   	struct alloc_context ac = {
>   		.high_zoneidx = gfp_zone(gfp_mask),
> -		.nodemask = nodemask,
> +		.nodemask = nodemask ? : &cpuset_current_mems_allowed,
>   		.migratetype = gfpflags_to_migratetype(gfp_mask),
>   	};
>
> @@ -3188,8 +2998,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>   	ac.zonelist = zonelist;
>   	/* The preferred zone is used for statistics later */
>   	preferred_zoneref = first_zones_zonelist(ac.zonelist, ac.high_zoneidx,
> -				ac.nodemask ? : &cpuset_current_mems_allowed,
> -				&ac.preferred_zone);
> +				ac.nodemask, &ac.preferred_zone);
>   	if (!ac.preferred_zone)
>   		goto out;
>   	ac.classzone_idx = zonelist_zone_idx(preferred_zoneref);

These hunks appear unrelated to zonelist cache? Also they move the 
evaluation of cpuset_current_mems_allowed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
