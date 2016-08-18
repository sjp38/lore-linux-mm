Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5ECDB82F5F
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 05:03:17 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u81so11489800wmu.3
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 02:03:17 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id d77si1344471wmh.91.2016.08.18.02.03.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Aug 2016 02:03:16 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id i138so4172048wmf.3
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 02:03:16 -0700 (PDT)
Date: Thu, 18 Aug 2016 11:03:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 04/11] mm, compaction: don't recheck watermarks after
 COMPACT_SUCCESS
Message-ID: <20160818090314.GE30162@dhcp22.suse.cz>
References: <20160810091226.6709-1-vbabka@suse.cz>
 <20160810091226.6709-5-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160810091226.6709-5-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 10-08-16 11:12:19, Vlastimil Babka wrote:
> Joonsoo has reminded me that in a later patch changing watermark checks
> throughout compaction I forgot to update checks in try_to_compact_pages() and
> compactd_do_work(). Closer inspection however shows that they are redundant now
> that compact_zone() reliably reports success with COMPACT_SUCCESS, as they just
> repeat (a subset) of checks that have just passed. So instead of checking
> watermarks again, just test the return value.

the less watermark checks we do the better because they just increase a
probability of subtle and hard to explain corner cases.

> Also remove the stray "bool success" variable from kcompactd_do_work().
> 
> Reported-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.com>

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
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
