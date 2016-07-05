Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id EBBF76B0005
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 02:57:43 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id b13so384183245pat.3
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 23:57:43 -0700 (PDT)
Received: from out4133-98.mail.aliyun.com (out4133-98.mail.aliyun.com. [42.120.133.98])
        by mx.google.com with ESMTP id a9si4468281pas.137.2016.07.04.23.57.41
        for <linux-mm@kvack.org>;
        Mon, 04 Jul 2016 23:57:42 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <00e101d1d689$b9a1d730$2ce58590$@alibaba-inc.com>
In-Reply-To: <00e101d1d689$b9a1d730$2ce58590$@alibaba-inc.com>
Subject: Re: [PATCH 21/31] mm, page_alloc: Wake kswapd based on the highest eligible zone
Date: Tue, 05 Jul 2016 14:57:38 +0800
Message-ID: <00e201d1d68a$84b72100$8e256300$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

> 
> The ac_classzone_idx is used as the basis for waking kswapd and that is based
> on the preferred zoneref. If the preferred zoneref's highest zone is lower
> than what is available on other nodes, it's possible that kswapd is woken
> on a zone with only higher, but still eligible, zones. As classzone_idx
> is strictly adhered to now, it causes a problem because eligible pages
> are skipped.
> 
> For example, node 0 has only DMA32 and node 1 has only NORMAL. An allocating
> context running on node 0 may wake kswapd on node 1 telling it to skip
> all NORMAL pages.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2fe2fbb4f2ad..b10bee2e5968 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3415,7 +3415,7 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
>  	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist,
>  					ac->high_zoneidx, ac->nodemask) {
>  		if (last_pgdat != zone->zone_pgdat)
> -			wakeup_kswapd(zone, order, ac_classzone_idx(ac));
> +			wakeup_kswapd(zone, order, ac->high_zoneidx);
>  		last_pgdat = zone->zone_pgdat;
>  	}
>  }
> --
> 2.6.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
