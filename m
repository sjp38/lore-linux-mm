Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A7CB06B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 03:58:00 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f137so854438wme.5
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 00:58:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z66si3865825wmb.189.2018.04.05.00.57.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Apr 2018 00:57:56 -0700 (PDT)
Date: Thu, 5 Apr 2018 09:57:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/thp: don't count ZONE_MOVABLE as the target for
 freepage reserving
Message-ID: <20180405075753.GZ6312@dhcp22.suse.cz>
References: <1522913236-15776-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522913236-15776-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu 05-04-18 16:27:16, Joonsoo Kim wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> ZONE_MOVABLE only has movable pages so we don't need to keep enough
> freepages to avoid or deal with fragmentation. So, don't count it.
> 
> This changes min_free_kbytes and thus min_watermark greatly
> if ZONE_MOVABLE is used. It will make the user uses more memory.

OK, but why does it matter. Has anybody seen this as an issue?

> o System
> 22GB ram, fakenuma, 2 nodes. 5 zones are used.
> 
> o Before
> min_free_kbytes: 112640
> 
> zone_info (min_watermark):
> Node 0, zone      DMA
>         min      19
> Node 0, zone    DMA32
>         min      3778
> Node 0, zone   Normal
>         min      10191
> Node 0, zone  Movable
>         min      0
> Node 0, zone   Device
>         min      0
> Node 1, zone      DMA
>         min      0
> Node 1, zone    DMA32
>         min      0
> Node 1, zone   Normal
>         min      14043
> Node 1, zone  Movable
>         min      127
> Node 1, zone   Device
>         min      0
> 
> o After
> min_free_kbytes: 90112
> 
> zone_info (min_watermark):
> Node 0, zone      DMA
>         min      15
> Node 0, zone    DMA32
>         min      3022
> Node 0, zone   Normal
>         min      8152
> Node 0, zone  Movable
>         min      0
> Node 0, zone   Device
>         min      0
> Node 1, zone      DMA
>         min      0
> Node 1, zone    DMA32
>         min      0
> Node 1, zone   Normal
>         min      11234
> Node 1, zone  Movable
>         min      102
> Node 1, zone   Device
>         min      0
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/khugepaged.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index 5de1c6f..92dd4e6 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1880,8 +1880,16 @@ static void set_recommended_min_free_kbytes(void)
>  	int nr_zones = 0;
>  	unsigned long recommended_min;
>  
> -	for_each_populated_zone(zone)
> +	for_each_populated_zone(zone) {
> +		/*
> +		 * We don't need to worry about fragmentation of
> +		 * ZONE_MOVABLE since it only has movable pages.
> +		 */
> +		if (zone_idx(zone) > gfp_zone(GFP_USER))
> +			continue;
> +
>  		nr_zones++;
> +	}
>  
>  	/* Ensure 2 pageblocks are free to assist fragmentation avoidance */
>  	recommended_min = pageblock_nr_pages * nr_zones * 2;
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs
