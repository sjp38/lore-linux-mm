Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id D9BA283099
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 04:24:24 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id s2so178807381iod.0
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 01:24:24 -0700 (PDT)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTP id n1si15383486ign.19.2016.04.21.01.24.22
        for <linux-mm@kvack.org>;
        Thu, 21 Apr 2016 01:24:24 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org> <1461181647-8039-15-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461181647-8039-15-git-send-email-mhocko@kernel.org>
Subject: Re: [PATCH 14/14] mm, oom, compaction: prevent from should_compact_retry looping for ever for costly orders
Date: Thu, 21 Apr 2016 16:24:03 +0800
Message-ID: <02f501d19ba7$2a4c9240$7ee5b6c0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'Joonsoo Kim' <js1304@gmail.com>, 'Vlastimil Babka' <vbabka@suse.cz>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>

> 
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
> [vbabka@suse.cz: fix classzone_idx vs. high_zoneidx usage in
> compaction_zonelist_suitable]
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

> ---
>  include/linux/compaction.h |  4 ++++
>  include/linux/mmzone.h     |  3 +++
>  mm/compaction.c            | 42 +++++++++++++++++++++++++++++++++++++++---
>  mm/page_alloc.c            | 18 +++++++++++-------
>  4 files changed, 57 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index a002ca55c513..7bbdbf729757 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -142,6 +142,10 @@ static inline bool compaction_withdrawn(enum compact_result result)
>  	return false;
>  }
> 
> +
> +bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
> +					int alloc_flags);
> +
>  extern int kcompactd_run(int nid);
>  extern void kcompactd_stop(int nid);
>  extern void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx);
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 150c6049f961..0bf13c7cd8cd 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -746,6 +746,9 @@ static inline bool is_dev_zone(const struct zone *zone)
>  extern struct mutex zonelists_mutex;
>  void build_all_zonelists(pg_data_t *pgdat, struct zone *zone);
>  void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx);
> +bool __zone_watermark_ok(struct zone *z, unsigned int order,
> +			unsigned long mark, int classzone_idx, int alloc_flags,
> +			long free_pages);
>  bool zone_watermark_ok(struct zone *z, unsigned int order,
>  		unsigned long mark, int classzone_idx, int alloc_flags);
>  bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
> diff --git a/mm/compaction.c b/mm/compaction.c
> index e2e487cea5ea..0a7ca578af97 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1369,7 +1369,8 @@ static enum compact_result compact_finished(struct zone *zone,
>   *   COMPACT_CONTINUE - If compaction should run now
>   */
>  static enum compact_result __compaction_suitable(struct zone *zone, int order,
> -					int alloc_flags, int classzone_idx)
> +					int alloc_flags, int classzone_idx,
> +					unsigned long wmark_target)
>  {
>  	int fragindex;
>  	unsigned long watermark;
> @@ -1392,7 +1393,8 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
>  	 * allocated and for a short time, the footprint is higher
>  	 */
>  	watermark += (2UL << order);
> -	if (!zone_watermark_ok(zone, 0, watermark, classzone_idx, alloc_flags))
> +	if (!__zone_watermark_ok(zone, 0, watermark, classzone_idx,
> +				 alloc_flags, wmark_target))
>  		return COMPACT_SKIPPED;
> 
>  	/*
> @@ -1418,7 +1420,8 @@ enum compact_result compaction_suitable(struct zone *zone, int order,
>  {
>  	enum compact_result ret;
> 
> -	ret = __compaction_suitable(zone, order, alloc_flags, classzone_idx);
> +	ret = __compaction_suitable(zone, order, alloc_flags, classzone_idx,
> +				    zone_page_state(zone, NR_FREE_PAGES));
>  	trace_mm_compaction_suitable(zone, order, ret);
>  	if (ret == COMPACT_NOT_SUITABLE_ZONE)
>  		ret = COMPACT_SKIPPED;
> @@ -1426,6 +1429,39 @@ enum compact_result compaction_suitable(struct zone *zone, int order,
>  	return ret;
>  }
> 
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
> +	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
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
> +				ac->classzone_idx, available);
> +		if (compact_result != COMPACT_SKIPPED &&
> +				compact_result != COMPACT_NOT_SUITABLE_ZONE)
> +			return true;
> +	}
> +
> +	return false;
> +}
> +
>  static enum compact_result compact_zone(struct zone *zone, struct compact_control *cc)
>  {
>  	enum compact_result ret;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d5a938f12554..6757d6df2160 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2526,7 +2526,7 @@ static inline bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
>   * one free page of a suitable size. Checking now avoids taking the zone lock
>   * to check in the allocation paths if no pages are free.
>   */
> -static bool __zone_watermark_ok(struct zone *z, unsigned int order,
> +bool __zone_watermark_ok(struct zone *z, unsigned int order,
>  			unsigned long mark, int classzone_idx, int alloc_flags,
>  			long free_pages)
>  {
> @@ -3015,8 +3015,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  }
> 
>  static inline bool
> -should_compact_retry(unsigned int order, enum compact_result compact_result,
> -		     enum migrate_mode *migrate_mode,
> +should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
> +		     enum compact_result compact_result, enum migrate_mode *migrate_mode,
>  		     int compaction_retries)
>  {
>  	int max_retries = MAX_COMPACT_RETRIES;
> @@ -3040,9 +3040,11 @@ should_compact_retry(unsigned int order, enum compact_result compact_result,
>  	/*
>  	 * make sure the compaction wasn't deferred or didn't bail out early
>  	 * due to locks contention before we declare that we should give up.
> +	 * But do not retry if the given zonelist is not suitable for
> +	 * compaction.
>  	 */
>  	if (compaction_withdrawn(compact_result))
> -		return true;
> +		return compaction_zonelist_suitable(ac, order, alloc_flags);
> 
>  	/*
>  	 * !costly requests are much more important than __GFP_REPEAT
> @@ -3069,7 +3071,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  }
> 
>  static inline bool
> -should_compact_retry(unsigned int order, enum compact_result compact_result,
> +should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_flags,
> +		     enum compact_result compact_result,
>  		     enum migrate_mode *migrate_mode,
>  		     int compaction_retries)
>  {
> @@ -3464,8 +3467,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	 * of free memory (see __compaction_suitable)
>  	 */
>  	if (did_some_progress > 0 &&
> -			should_compact_retry(order, compact_result,
> -				&migration_mode, compaction_retries))
> +			should_compact_retry(ac, order, alloc_flags,
> +				compact_result, &migration_mode,
> +				compaction_retries))
>  		goto retry;
> 
>  	/* Reclaim has failed us, start killing things */
> --
> 2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
