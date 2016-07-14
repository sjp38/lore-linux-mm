Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A746D6B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 08:12:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f126so55283689wma.3
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 05:12:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m131si2820082wmf.113.2016.07.14.05.12.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jul 2016 05:12:33 -0700 (PDT)
Subject: Re: [PATCH 25/34] mm, vmscan: avoid passing in classzone_idx
 unnecessarily to compaction_ready
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-26-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ac068319-a38d-4514-c075-a09b88d2d979@suse.cz>
Date: Thu, 14 Jul 2016 14:12:28 +0200
MIME-Version: 1.0
In-Reply-To: <1467970510-21195-26-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On 07/08/2016 11:35 AM, Mel Gorman wrote:
> The scan_control structure has enough information available for
> compaction_ready() to make a decision. The classzone_idx manipulations in
> shrink_zones() are no longer necessary as the highest populated zone is
> no longer used to determine if shrink_slab should be called or not.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> @@ -2621,8 +2609,8 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  			 */
>  			if (IS_ENABLED(CONFIG_COMPACTION) &&
>  			    sc->order > PAGE_ALLOC_COSTLY_ORDER &&
> -			    zonelist_zone_idx(z) <= classzone_idx &&
> -			    compaction_ready(zone, sc->order, classzone_idx)) {
> +			    zonelist_zone_idx(z) <= sc->reclaim_idx &&

Hm I notice that the condition on the line above should be always true 
as the same sc->reclaim_idx value is used to limit zone_idx in 
for_each_zone_zonelist_nodemask(). The implication was probably true 
even before this patch (classzone_idx would be <= sc->reclaim_idx), but 
now it stands out clearly.

> +			    compaction_ready(zone, sc)) {
>  				sc->compaction_ready = true;
>  				continue;
>  			}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
