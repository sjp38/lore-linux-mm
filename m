Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 445406B0253
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 08:26:05 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so178428175wib.1
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 05:26:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k8si20077848wia.75.2015.07.28.05.26.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jul 2015 05:26:03 -0700 (PDT)
Subject: Re: [PATCH 03/10] mm, page_alloc: Remove unnecessary recalculations
 for dirty zone balancing
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
 <1437379219-9160-4-git-send-email-mgorman@suse.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55B774D5.8030600@suse.cz>
Date: Tue, 28 Jul 2015 14:25:57 +0200
MIME-Version: 1.0
In-Reply-To: <1437379219-9160-4-git-send-email-mgorman@suse.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.com>, Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

On 07/20/2015 10:00 AM, Mel Gorman wrote:
> From: Mel Gorman <mgorman@suse.de>
>
> File-backed pages that will be immediately dirtied are balanced between
> zones but it's unnecessarily expensive. Move consider_zone_balanced into
> the alloc_context instead of checking bitmaps multiple times.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Agreed with new ac->spread_dirty_page name (or rather plural, 
spread_dirty_pages?) , and a nitpick below.

> ---
>   mm/internal.h   | 1 +
>   mm/page_alloc.c | 9 ++++++---
>   2 files changed, 7 insertions(+), 3 deletions(-)
>
> diff --git a/mm/internal.h b/mm/internal.h
> index 36b23f1e2ca6..8977348fbeec 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -129,6 +129,7 @@ struct alloc_context {
>   	int classzone_idx;
>   	int migratetype;
>   	enum zone_type high_zoneidx;
> +	bool consider_zone_dirty;
>   };
>
>   /*
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4b35b196aeda..7c2dc022f4ba 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2295,8 +2295,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
>   	struct zoneref *z;
>   	struct page *page = NULL;
>   	struct zone *zone;
> -	bool consider_zone_dirty = (alloc_flags & ALLOC_WMARK_LOW) &&
> -				(gfp_mask & __GFP_WRITE);
>   	int nr_fair_skipped = 0;
>   	bool zonelist_rescan;
>
> @@ -2355,7 +2353,7 @@ zonelist_scan:

I've been recently suggested by mhocko to add to ~/.gitconfig

[diff "default"]
         xfuncname = "^[[:alpha:]$_].*[^:]$"

So that git produces function names in hunk context instead of labels. I 
gladly spread this arcane knowledge :)

>   		 * will require awareness of zones in the
>   		 * dirty-throttling and the flusher threads.
>   		 */

This comment (in the part not shown) mentions ALLOC_WMARK_LOW as the 
mechanism to distinguish fastpath from slowpath. This is no longer true, 
so update it too?

> -		if (consider_zone_dirty && !zone_dirty_ok(zone))
> +		if (ac->consider_zone_dirty && !zone_dirty_ok(zone))
>   			continue;
>
>   		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
> @@ -2995,6 +2993,10 @@ retry_cpuset:
>
>   	/* We set it here, as __alloc_pages_slowpath might have changed it */
>   	ac.zonelist = zonelist;
> +
> +	/* Dirty zone balancing only done in the fast path */
> +	ac.consider_zone_dirty = (gfp_mask & __GFP_WRITE);
> +
>   	/* The preferred zone is used for statistics later */
>   	preferred_zoneref = first_zones_zonelist(ac.zonelist, ac.high_zoneidx,
>   				ac.nodemask, &ac.preferred_zone);
> @@ -3012,6 +3014,7 @@ retry_cpuset:
>   		 * complete.
>   		 */
>   		alloc_mask = memalloc_noio_flags(gfp_mask);
> +		ac.consider_zone_dirty = false;
>
>   		page = __alloc_pages_slowpath(alloc_mask, order, &ac);
>   	}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
