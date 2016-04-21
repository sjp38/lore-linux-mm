Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id D469E8308B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 23:32:33 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id z8so145366739igl.3
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 20:32:33 -0700 (PDT)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id vu3si1073154igb.46.2016.04.20.20.32.31
        for <linux-mm@kvack.org>;
        Wed, 20 Apr 2016 20:32:33 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org> <1461181647-8039-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461181647-8039-2-git-send-email-mhocko@kernel.org>
Subject: Re: [PATCH 01/14] vmscan: consider classzone_idx in compaction_ready
Date: Thu, 21 Apr 2016 11:32:13 +0800
Message-ID: <027701d19b7e$65b48910$311d9b30$@alibaba-inc.com>
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
> while playing with the oom detection rework [1] I have noticed
> that my heavy order-9 (hugetlb) load close to OOM ended up in an
> endless loop where the reclaim hasn't made any progress but
> did_some_progress didn't reflect that and compaction_suitable
> was backing off because no zone is above low wmark + 1 << order.
> 
> It turned out that this is in fact an old standing bug in compaction_ready
> which ignores the requested_highidx and did the watermark check for
> 0 classzone_idx. This succeeds for zone DMA most of the time as the zone
> is mostly unused because of lowmem protection. This also means that the
> OOM killer wouldn't be triggered for higher order requests even when
> there is no reclaim progress and we essentially rely on order-0 request
> to find this out. 

Thanks.

> This has been broken in one way or another since
> fe4b1b244bdb ("mm: vmscan: when reclaiming for compaction, ensure there
> are sufficient free pages available") but only since 7335084d446b ("mm:
> vmscan: do not OOM if aborting reclaim to start compaction") we are not
> invoking the OOM killer based on the wrong calculation.
> 
> Propagate requested_highidx down to compaction_ready and use it for both
> the watermak check and compaction_suitable to fix this issue.
> 
> [1] http://lkml.kernel.org/r/1459855533-4600-1-git-send-email-mhocko@kernel.org
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/vmscan.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c839adc13efd..3e6347e2a5fc 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2482,7 +2482,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>   * Returns true if compaction should go ahead for a high-order request, or
>   * the high-order allocation would succeed without compaction.
>   */
> -static inline bool compaction_ready(struct zone *zone, int order)
> +static inline bool compaction_ready(struct zone *zone, int order, int classzone_idx)
>  {
>  	unsigned long balance_gap, watermark;
>  	bool watermark_ok;
> @@ -2496,7 +2496,7 @@ static inline bool compaction_ready(struct zone *zone, int order)
>  	balance_gap = min(low_wmark_pages(zone), DIV_ROUND_UP(
>  			zone->managed_pages, KSWAPD_ZONE_BALANCE_GAP_RATIO));
>  	watermark = high_wmark_pages(zone) + balance_gap + (2UL << order);
> -	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, 0);
> +	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, classzone_idx);
> 
>  	/*
>  	 * If compaction is deferred, reclaim up to a point where
> @@ -2509,7 +2509,7 @@ static inline bool compaction_ready(struct zone *zone, int order)
>  	 * If compaction is not ready to start and allocation is not likely
>  	 * to succeed without it, then keep reclaiming.
>  	 */
> -	if (compaction_suitable(zone, order, 0, 0) == COMPACT_SKIPPED)
> +	if (compaction_suitable(zone, order, 0, classzone_idx) == COMPACT_SKIPPED)
>  		return false;
> 
>  	return watermark_ok;
> @@ -2589,7 +2589,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  			if (IS_ENABLED(CONFIG_COMPACTION) &&
>  			    sc->order > PAGE_ALLOC_COSTLY_ORDER &&
>  			    zonelist_zone_idx(z) <= requested_highidx &&
> -			    compaction_ready(zone, sc->order)) {
> +			    compaction_ready(zone, sc->order, requested_highidx)) {
>  				sc->compaction_ready = true;
>  				continue;
>  			}
> --
> 2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
