Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id C6DFB6B0038
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 02:06:11 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id q83so53136254iod.0
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 23:06:11 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id d64si4063209iod.240.2016.08.15.23.06.10
        for <linux-mm@kvack.org>;
        Mon, 15 Aug 2016 23:06:11 -0700 (PDT)
Date: Tue, 16 Aug 2016 15:12:01 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v6 04/11] mm, compaction: don't recheck watermarks after
 COMPACT_SUCCESS
Message-ID: <20160816061200.GD17448@js1304-P5Q-DELUXE>
References: <20160810091226.6709-1-vbabka@suse.cz>
 <20160810091226.6709-5-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160810091226.6709-5-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 10, 2016 at 11:12:19AM +0200, Vlastimil Babka wrote:
> Joonsoo has reminded me that in a later patch changing watermark checks
> throughout compaction I forgot to update checks in try_to_compact_pages() and
> compactd_do_work(). Closer inspection however shows that they are redundant now
> that compact_zone() reliably reports success with COMPACT_SUCCESS, as they just
> repeat (a subset) of checks that have just passed. So instead of checking
> watermarks again, just test the return value.

In fact, it's not redundant. Even if try_to_compact_pages() returns
!COMPACT_SUCCESS, watermark check could return true.
__compact_finished() calls find_suitable_fallback() and it's slightly
different with watermark check. Anyway, I don't think it is a big
problem.

Thanks.


> 
> Also remove the stray "bool success" variable from kcompactd_do_work().
> 
> Reported-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/compaction.c | 11 +++--------
>  1 file changed, 3 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index c355bf0d8599..a144f58f7193 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1698,9 +1698,8 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
>  					alloc_flags, ac_classzone_idx(ac));
>  		rc = max(status, rc);
>  
> -		/* If a normal allocation would succeed, stop compacting */
> -		if (zone_watermark_ok(zone, order, low_wmark_pages(zone),
> -					ac_classzone_idx(ac), alloc_flags)) {
> +		/* The allocation should succeed, stop compacting */
> +		if (status == COMPACT_SUCCESS) {
>  			/*
>  			 * We think the allocation will succeed in this zone,
>  			 * but it is not certain, hence the false. The caller
> @@ -1873,8 +1872,6 @@ static void kcompactd_do_work(pg_data_t *pgdat)
>  		.ignore_skip_hint = true,
>  
>  	};
> -	bool success = false;
> -
>  	trace_mm_compaction_kcompactd_wake(pgdat->node_id, cc.order,
>  							cc.classzone_idx);
>  	count_vm_event(KCOMPACTD_WAKE);
> @@ -1903,9 +1900,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
>  			return;
>  		status = compact_zone(zone, &cc);
>  
> -		if (zone_watermark_ok(zone, cc.order, low_wmark_pages(zone),
> -						cc.classzone_idx, 0)) {
> -			success = true;
> +		if (status == COMPACT_SUCCESS) {
>  			compaction_defer_reset(zone, cc.order, false);
>  		} else if (status == COMPACT_PARTIAL_SKIPPED || status == COMPACT_COMPLETE) {
>  			/*
> -- 
> 2.9.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
