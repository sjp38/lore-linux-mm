Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 059D26B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 06:46:09 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id na2so38776451lbb.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 03:46:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ec11si11305545wjb.99.2016.06.17.03.46.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 03:46:07 -0700 (PDT)
Subject: Re: [PATCH 21/27] mm, vmscan: Only wakeup kswapd once per node for
 the requested classzone
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-22-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2ce07fcf-7b7d-a70b-ed7b-60867ad4458f@suse.cz>
Date: Fri, 17 Jun 2016 12:46:05 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-22-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> kswapd is woken when zones are below the low watermark but the wakeup
> decision is not taking the classzone into account.  Now that reclaim is
> node-based, it is only required to wake kswapd once per node and only if
> all zones are unbalanced for the requested classzone.
>
> Note that one node might be checked multiple times but there is no cheap
> way of tracking what nodes have already been visited for zoneslists that
> be ordered by either zone or node.

Wouldn't it be possible to optimize for node order as you did in direct reclaim? 
Do the zone_balanced checks when going through zonelist, and once node changes 
in iteration, wake up if no eligible zones visited so far were balanced.

> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  mm/vmscan.c | 13 +++++++++++--
>  1 file changed, 11 insertions(+), 2 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 7a2d69612231..b9cff9047ac0 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3389,6 +3389,7 @@ static int kswapd(void *p)
>  void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
>  {
>  	pg_data_t *pgdat;
> +	int z;
>
>  	if (!populated_zone(zone))
>  		return;
> @@ -3402,8 +3403,16 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
>  	pgdat->kswapd_order = max(pgdat->kswapd_order, order);
>  	if (!waitqueue_active(&pgdat->kswapd_wait))
>  		return;
> -	if (zone_balanced(zone, order, 0))
> -		return;
> +
> +	/* Only wake kswapd if all zones are unbalanced */
> +	for (z = 0; z <= classzone_idx; z++) {
> +		zone = pgdat->node_zones + z;
> +		if (!populated_zone(zone))
> +			continue;
> +
> +		if (zone_balanced(zone, order, classzone_idx))
> +			return;
> +	}
>
>  	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
>  	wake_up_interruptible(&pgdat->kswapd_wait);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
