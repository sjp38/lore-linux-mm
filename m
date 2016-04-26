Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4DAB36B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 08:05:00 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id j8so10458374lfd.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:05:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 3si24570976wmk.45.2016.04.26.05.04.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 05:04:58 -0700 (PDT)
Subject: Re: [PATCH 13/28] mm, page_alloc: Remove redundant check for empty
 zonelist
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571F5963.1000504@suse.cz>
Date: Tue, 26 Apr 2016 14:04:51 +0200
MIME-Version: 1.0
In-Reply-To: <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2016 11:07 AM, Mel Gorman wrote:
> A check is made for an empty zonelist early in the page allocator fast path
> but it's unnecessary. When get_page_from_freelist() is called, it'll return
> NULL immediately. Removing the first check is slower for machines with
> memoryless nodes but that is a corner case that can live with the overhead.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>   mm/page_alloc.c | 11 -----------
>   1 file changed, 11 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index df03ccc7f07c..21aaef6ddd7a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3374,14 +3374,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>   	if (should_fail_alloc_page(gfp_mask, order))
>   		return NULL;
>
> -	/*
> -	 * Check the zones suitable for the gfp_mask contain at least one
> -	 * valid zone. It's possible to have an empty zonelist as a result
> -	 * of __GFP_THISNODE and a memoryless node
> -	 */
> -	if (unlikely(!zonelist->_zonerefs->zone))
> -		return NULL;
> -
>   	if (IS_ENABLED(CONFIG_CMA) && ac.migratetype == MIGRATE_MOVABLE)
>   		alloc_flags |= ALLOC_CMA;
>
> @@ -3394,8 +3386,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>   	/* The preferred zone is used for statistics later */
>   	preferred_zoneref = first_zones_zonelist(ac.zonelist, ac.high_zoneidx,
>   				ac.nodemask, &ac.preferred_zone);
> -	if (!ac.preferred_zone)
> -		goto out;

Is this part really safe? Besides changelog doesn't mention preferred_zone. What 
if somebody attempts e.g. a DMA allocation with ac.nodemask being set to 
cpuset_current_mems_allowed and initially only containing nodes without 
ZONE_DMA. Then ac.preferred_zone is NULL, yet we proceed to 
get_page_from_freelist(). Meanwhile cpuset_current_mems_allowed gets changed so 
in fact it does contains a suitable node, so we manage to get inside 
for_each_zone_zonelist_nodemask(). Then there's zone_local(ac->preferred_zone, 
zone), which will defererence the NULL ac->preferred_zone?

>   	ac.classzone_idx = zonelist_zone_idx(preferred_zoneref);
>
>   	/* First allocation attempt */
> @@ -3418,7 +3408,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>
>   	trace_mm_page_alloc(page, order, alloc_mask, ac.migratetype);
>
> -out:
>   	/*
>   	 * When updating a task's mems_allowed, it is possible to race with
>   	 * parallel threads in such a way that an allocation can fail while
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
