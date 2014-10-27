Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id CB6A96B0069
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 02:45:39 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id ft15so3119485pdb.39
        for <linux-mm@kvack.org>; Sun, 26 Oct 2014 23:45:39 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id hw4si9685385pbb.178.2014.10.26.23.45.36
        for <linux-mm@kvack.org>;
        Sun, 26 Oct 2014 23:45:38 -0700 (PDT)
Date: Mon, 27 Oct 2014 15:46:51 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/5] mm, compaction: pass classzone_idx and alloc_flags
 to watermark checking
Message-ID: <20141027064651.GA23379@js1304-P5Q-DELUXE>
References: <1412696019-21761-1-git-send-email-vbabka@suse.cz>
 <1412696019-21761-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1412696019-21761-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Tue, Oct 07, 2014 at 05:33:35PM +0200, Vlastimil Babka wrote:
> Compaction relies on zone watermark checks for decisions such as if it's worth
> to start compacting in compaction_suitable() or whether compaction should stop
> in compact_finished(). The watermark checks take classzone_idx and alloc_flags
> parameters, which are related to the memory allocation request. But from the
> context of compaction they are currently passed as 0, including the direct
> compaction which is invoked to satisfy the allocation request, and could
> therefore know the proper values.
> 
> The lack of proper values can lead to mismatch between decisions taken during
> compaction and decisions related to the allocation request. Lack of proper
> classzone_idx value means that lowmem_reserve is not taken into account.
> This has manifested (during recent changes to deferred compaction) when DMA
> zone was used as fallback for preferred Normal zone. compaction_suitable()
> without proper classzone_idx would think that the watermarks are already
> satisfied, but watermark check in get_page_from_freelist() would fail. Because
> of this problem, deferring compaction has extra complexity that can be removed
> in the following patch.
> 
> The issue (not confirmed in practice) with missing alloc_flags is opposite in
> nature. For allocations that include ALLOC_HIGH, ALLOC_HIGHER or ALLOC_CMA in
> alloc_flags (the last includes all MOVABLE allocations on CMA-enabled systems)
> the watermark checking in compaction with 0 passed will be stricter than in
> get_page_from_freelist(). In these cases compaction might be running for a
> longer time than is really needed.
> 
> This patch fixes these problems by adding alloc_flags and classzone_idx to
> struct compact_control and related functions involved in direct compaction and
> watermark checking. Where possible, all other callers of compaction_suitable()
> pass proper values where those are known. This is currently limited to
> classzone_idx, which is sometimes known in kswapd context. However, the direct
> reclaim callers should_continue_reclaim() and compaction_ready() do not
> currently know the proper values, so the coordination between reclaim and
> compaction may still not be as accurate as it could. This can be fixed later,
> if it's shown to be an issue.
> 
> The effect of this patch should be slightly better high-order allocation
> success rates and/or less compaction overhead, depending on the type of
> allocations and presence of CMA. It allows simplifying deferred compaction
> code in a followup patch.
> 
> When testing with stress-highalloc, there was some slight improvement (which
> might be just due to variance) in success rates of non-THP-like allocations.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> ---
>  include/linux/compaction.h |  8 ++++++--
>  mm/compaction.c            | 29 +++++++++++++++--------------
>  mm/internal.h              |  2 ++
>  mm/page_alloc.c            |  1 +
>  mm/vmscan.c                | 12 ++++++------
>  5 files changed, 30 insertions(+), 22 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index 60bdf8d..d896765 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -33,10 +33,12 @@ extern int fragmentation_index(struct zone *zone, unsigned int order);
>  extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  			int order, gfp_t gfp_mask, nodemask_t *mask,
>  			enum migrate_mode mode, int *contended,
> +			int alloc_flags, int classzone_idx,
>  			struct zone **candidate_zone);
>  extern void compact_pgdat(pg_data_t *pgdat, int order);
>  extern void reset_isolation_suitable(pg_data_t *pgdat);
> -extern unsigned long compaction_suitable(struct zone *zone, int order);
> +extern unsigned long compaction_suitable(struct zone *zone, int order,
> +					int alloc_flags, int classzone_idx);
>  
>  /* Do not skip compaction more than 64 times */
>  #define COMPACT_MAX_DEFER_SHIFT 6
> @@ -103,6 +105,7 @@ static inline bool compaction_restarting(struct zone *zone, int order)
>  static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  			int order, gfp_t gfp_mask, nodemask_t *nodemask,
>  			enum migrate_mode mode, int *contended,
> +			int alloc_flags, int classzone_idx,
>  			struct zone **candidate_zone)
>  {
>  	return COMPACT_CONTINUE;
> @@ -116,7 +119,8 @@ static inline void reset_isolation_suitable(pg_data_t *pgdat)
>  {
>  }
>  
> -static inline unsigned long compaction_suitable(struct zone *zone, int order)
> +static inline unsigned long compaction_suitable(struct zone *zone, int order,
> +					int alloc_flags, int classzone_idx)
>  {
>  	return COMPACT_SKIPPED;
>  }
> diff --git a/mm/compaction.c b/mm/compaction.c
> index edba18a..dba8891 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1069,9 +1069,9 @@ static int compact_finished(struct zone *zone, struct compact_control *cc,
>  
>  	/* Compaction run is not finished if the watermark is not met */
>  	watermark = low_wmark_pages(zone);
> -	watermark += (1 << cc->order);
>  
> -	if (!zone_watermark_ok(zone, cc->order, watermark, 0, 0))
> +	if (!zone_watermark_ok(zone, cc->order, watermark, cc->classzone_idx,
> +							cc->alloc_flags))
>  		return COMPACT_CONTINUE;
>  
>  	/* Direct compactor: Is a suitable page free? */
> @@ -1097,7 +1097,8 @@ static int compact_finished(struct zone *zone, struct compact_control *cc,
>   *   COMPACT_PARTIAL  - If the allocation would succeed without compaction
>   *   COMPACT_CONTINUE - If compaction should run now
>   */
> -unsigned long compaction_suitable(struct zone *zone, int order)
> +unsigned long compaction_suitable(struct zone *zone, int order,
> +					int alloc_flags, int classzone_idx)
>  {
>  	int fragindex;
>  	unsigned long watermark;
> @@ -1134,7 +1135,7 @@ unsigned long compaction_suitable(struct zone *zone, int order)
>  		return COMPACT_SKIPPED;
>  
>  	if (fragindex == -1000 && zone_watermark_ok(zone, order, watermark,
> -	    0, 0))
> +	    classzone_idx, alloc_flags))
>  		return COMPACT_PARTIAL;

Hello,

compaction_suitable() has one more zone_watermark_ok(). Why is it
unchanged?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
