Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 09B916B0260
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 21:20:47 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id wu1so121072827obb.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 18:20:47 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id n9si19627243itn.14.2016.07.13.18.20.45
        for <linux-mm@kvack.org>;
        Wed, 13 Jul 2016 18:20:46 -0700 (PDT)
Date: Thu, 14 Jul 2016 10:22:04 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/4] mm, vmscan: Have kswapd reclaim from all zones if
 reclaiming and buffer_heads_over_limit -fix
Message-ID: <20160714012204.GB23512@bbox>
References: <1468404004-5085-1-git-send-email-mgorman@techsingularity.net>
 <1468404004-5085-2-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
In-Reply-To: <1468404004-5085-2-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 13, 2016 at 11:00:01AM +0100, Mel Gorman wrote:
> Johannes reported that the comment about buffer_heads_over_limit in
> balance_pgdat only made sense in the context of the patch. This patch
> clarifies the reasoning and how it applies to 32 and 64 bit systems.
> 
> This is a fix to the mmotm patch
> mm-vmscan-have-kswapd-reclaim-from-all-zones-if-reclaiming-and-buffer_heads_over_limit.patch
> 
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  mm/vmscan.c | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index d079210d46ee..21eae17ee730 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3131,12 +3131,13 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  
>  		/*
>  		 * If the number of buffer_heads exceeds the maximum allowed
> -		 * then consider reclaiming from all zones. This is not
> -		 * specific to highmem which may not exist but it is it is
> -		 * expected that buffer_heads are stripped in writeback.
> -		 * Reclaim may still not go ahead if all eligible zones
> -		 * for the original allocation request are balanced to
> -		 * avoid excessive reclaim from kswapd.
> +		 * then consider reclaiming from all zones. This has a dual
> +		 * purpose -- on 64-bit systems it is expected that
> +		 * buffer_heads are stripped during active rotation. On 32-bit
> +		 * systems, highmem pages can pin lowmem memory and shrinking
> +		 * buffers can relieve lowmem pressure. Reclaim may still not

It's good but I hope we can make it more clear.

On 32-bit systems, highmem pages can pin lowmem pages storing buffer_heads
so shrinking highmem pages can relieve lowmem pressure.

If you don't think it's much readable compared to yours, feel free to drop.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
