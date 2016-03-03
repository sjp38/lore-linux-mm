Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id CB5716B007E
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 08:46:17 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id n186so132399405wmn.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 05:46:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g188si4157429wmf.61.2016.03.03.05.46.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Mar 2016 05:46:16 -0800 (PST)
Subject: Re: [PATCH 08/27] mm, vmscan: Make kswapd reclaim in terms of nodes
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
 <1456239890-20737-9-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56D84026.3010409@suse.cz>
Date: Thu, 3 Mar 2016 14:46:14 +0100
MIME-Version: 1.0
In-Reply-To: <1456239890-20737-9-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 02/23/2016 04:04 PM, Mel Gorman wrote:
> -static bool zone_balanced(struct zone *zone, int order, bool highorder,
> +static bool zone_balanced(struct zone *zone, int order,
>  			unsigned long balance_gap, int classzone_idx)
>  {
>  	unsigned long mark = high_wmark_pages(zone) + balance_gap;
>  
> -	/*
> -	 * When checking from pgdat_balanced(), kswapd should stop and sleep
> -	 * when it reaches the high order-0 watermark and let kcompactd take
> -	 * over. Other callers such as wakeup_kswapd() want to determine the
> -	 * true high-order watermark.
> -	 */
> -	if (IS_ENABLED(CONFIG_COMPACTION) && !highorder) {
> -		mark += (1UL << order);
> -		order = 0;
> -	}
> -
>  	return zone_watermark_ok_safe(zone, order, mark, classzone_idx);

Did you really intend to remove this or was it due to rebasing on top of
kcompactd?
My intention was that kswapd will consider zone balanced just by having
enough base pages. Maybe the next patches will reintroduce this differently?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
