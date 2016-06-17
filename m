Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75E836B0253
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 04:53:39 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id c1so19106440lbw.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 01:53:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id vu6si10798173wjb.28.2016.06.17.01.53.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 01:53:38 -0700 (PDT)
Subject: Re: [PATCH 20/27] mm, vmscan: Update classzone_idx if
 buffer_heads_over_limit
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-21-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8e47f6d8-ec2f-fc2d-ccf1-c32baec92110@suse.cz>
Date: Fri, 17 Jun 2016 10:53:36 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-21-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> If buffer heads are over the limit then the direct reclaim gfp_mask
> is promoted to __GFP_HIGHMEM so that lowmem is indirectly freed. With
> node-based reclaim, it is also required that the classzone_idx be updated
> or the pages will be skipped.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/vmscan.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 3edf941e9965..7a2d69612231 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2547,8 +2547,10 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
>  	 * highmem pages could be pinning lowmem pages storing buffer_heads
>  	 */
>  	orig_mask = sc->gfp_mask;
> -	if (buffer_heads_over_limit)
> +	if (buffer_heads_over_limit) {
>  		sc->gfp_mask |= __GFP_HIGHMEM;
> +		classzone_idx = gfp_zone(sc->gfp_mask);
> +	}
>
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
>  					gfp_zone(sc->gfp_mask), sc->nodemask) {
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
