Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id E746E6B0260
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 09:18:44 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 33so75272504lfw.1
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 06:18:44 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id tm3si31325574wjc.108.2016.08.01.06.18.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 06:18:43 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id o80so26131567wme.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 06:18:43 -0700 (PDT)
Date: Mon, 1 Aug 2016 15:18:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: vmscan: fix memcg-aware shrinkers not called on
 global reclaim
Message-ID: <20160801131840.GE13544@dhcp22.suse.cz>
References: <1470056590-7177-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1470056590-7177-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 01-08-16 16:03:10, Vladimir Davydov wrote:
> We must call shrink_slab() for each memory cgroup on both global and
> memcg reclaim in shrink_node_memcg(). Commit d71df22b55099 accidentally
> changed that so that now shrink_slab() is only called with memcg != NULL
> on memcg reclaim. As a result, memcg-aware shrinkers (including
> dentry/inode) are never invoked on global reclaim. Fix that.
> 
> Fixes: d71df22b55099 ("mm, vmscan: begin reclaiming pages on a per-node basis")

I guess you meant b2e18757f2c9. I do not see d71df22b55099 anywhere.

> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

The fix looks ok to me otherwise

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmscan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 650d26832569..374d95d04178 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2561,7 +2561,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>  			shrink_node_memcg(pgdat, memcg, sc, &lru_pages);
>  			node_lru_pages += lru_pages;
>  
> -			if (!global_reclaim(sc))
> +			if (memcg)
>  				shrink_slab(sc->gfp_mask, pgdat->node_id,
>  					    memcg, sc->nr_scanned - scanned,
>  					    lru_pages);
> -- 
> 2.1.4
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
