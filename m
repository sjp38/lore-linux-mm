Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 576396B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:23:54 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id f198so174863734wme.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 00:23:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a129si22371177wmf.119.2016.04.12.00.23.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Apr 2016 00:23:53 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm, oom, compaction: prevent from
 should_compact_retry looping for ever for costly orders
References: <1460357151-25554-1-git-send-email-mhocko@kernel.org>
 <1460357151-25554-3-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <570CA287.3030604@suse.cz>
Date: Tue, 12 Apr 2016 09:23:51 +0200
MIME-Version: 1.0
In-Reply-To: <1460357151-25554-3-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 04/11/2016 08:45 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> "mm: consider compaction feedback also for costly allocation" has
> removed the upper bound for the reclaim/compaction retries based on the
> number of reclaimed pages for costly orders. While this is desirable
> the patch did miss a mis interaction between reclaim, compaction and the
> retry logic. The direct reclaim tries to get zones over min watermark
> while compaction backs off and returns COMPACT_SKIPPED when all zones
> are below low watermark + 1<<order gap. If we are getting really close
> to OOM then __compaction_suitable can keep returning COMPACT_SKIPPED a
> high order request (e.g. hugetlb order-9) while the reclaim is not able
> to release enough pages to get us over low watermark. The reclaim is
> still able to make some progress (usually trashing over few remaining
> pages) so we are not able to break out from the loop.
>
> I have seen this happening with the same test described in "mm: consider
> compaction feedback also for costly allocation" on a swapless system.
> The original problem got resolved by "vmscan: consider classzone_idx in
> compaction_ready" but it shows how things might go wrong when we
> approach the oom event horizont.
>
> The reason why compaction requires being over low rather than min
> watermark is not clear to me. This check was there essentially since
> 56de7263fcf3 ("mm: compaction: direct compact when a high-order
> allocation fails"). It is clearly an implementation detail though and we

It's probably worth testing whether low watermark makes sense there 
instead of min watermark. I never noticed it myself, so thanks :)

> shouldn't pull it into the generic retry logic while we should be able
> to cope with such eventuality. The only place in should_compact_retry
> where we retry without any upper bound is for compaction_withdrawn()
> case.
>
> Introduce compaction_zonelist_suitable function which checks the given
> zonelist and returns true only if there is at least one zone which would
> would unblock __compaction_suitable if more memory got reclaimed. In
> this implementation it checks __compaction_suitable with NR_FREE_PAGES
> plus part of the reclaimable memory as the target for the watermark check.
> The reclaimable memory is reduced linearly by the allocation order. The
> idea is that we do not want to reclaim all the remaining memory for a
> single allocation request just unblock __compaction_suitable which
> doesn't guarantee we will make a further progress.
>
> The new helper is then used if compaction_withdrawn() feedback was
> provided so we do not retry if there is no outlook for a further
> progress. !costly requests shouldn't be affected much - e.g. order-2
> pages would require to have at least 64kB on the reclaimable LRUs while
> order-9 would need at least 32M which should be enough to not lock up.
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

It's a bit complicated, but I agree that something like this is needed 
to prevent unexpected endless loops. Alternatively you could maybe just 
extend compact_result to distinguish between COMPACT_SKIPPED (but 
possible after reclaim) and COMPACT_IMPOSSIBLE (or some better name?). 
Then compaction_withdrawn() would obviously be false for IMPOSSIBLE, 
while compaction_failed() would be true? Then you shouldn't need 
compaction_zonelist_suitable().

[...]

> +bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
> +		int alloc_flags)
> +{
> +	struct zone *zone;
> +	struct zoneref *z;
> +
> +	/*
> +	 * Make sure at least one zone would pass __compaction_suitable if we continue
> +	 * retrying the reclaim.
> +	 */
> +	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->classzone_idx,

I think here you should s/classzone_idx/high_zoneidx/

> +					ac->nodemask) {
> +		unsigned long available;
> +		enum compact_result compact_result;
> +
> +		/*
> +		 * Do not consider all the reclaimable memory because we do not
> +		 * want to trash just for a single high order allocation which
> +		 * is even not guaranteed to appear even if __compaction_suitable
> +		 * is happy about the watermark check.
> +		 */
> +		available = zone_reclaimable_pages(zone) / order;
> +		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
> +		compact_result = __compaction_suitable(zone, order, alloc_flags,
> +				ac->high_zoneidx, available);

And vice versa here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
