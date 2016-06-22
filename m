Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id B35C0828E1
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 10:49:21 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id c1so42853862lbw.0
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 07:49:21 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id uv1si44643638wjc.96.2016.06.22.07.49.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 07:49:20 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id 187so1913549wmz.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 07:49:20 -0700 (PDT)
Date: Wed, 22 Jun 2016 16:49:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 20/27] mm, vmscan: Update classzone_idx if
 buffer_heads_over_limit
Message-ID: <20160622144915.GH7527@dhcp22.suse.cz>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
 <1466518566-30034-21-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466518566-30034-21-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 21-06-16 15:15:59, Mel Gorman wrote:
> If buffer heads are over the limit then the direct reclaim gfp_mask
> is promoted to __GFP_HIGHMEM so that lowmem is indirectly freed. With
> node-based reclaim, it is also required that the classzone_idx be updated
> or the pages will be skipped.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/vmscan.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 1f7c1262c0a3..f4c759b3581b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2571,8 +2571,10 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
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

The code that follows that however does update classzone_idx
		/*
		 * Note that reclaim_idx does not change as it is the highest
		 * zone reclaimed from which for empty zones is a no-op but
		 * classzone_idx is used by shrink_node to test if the slabs
		 * should be shrunk on a given node.
		 */
		while (!populated_zone(zone->zone_pgdat->node_zones +
							classzone_idx)) {
			classzone_idx--;
		}

so if we start with a zone which doesn't have the highmem zone we will
not see highmems of other zone AFAIU. I guess this would be unlikely
because highmem systems will be UMA in most cases but the code looks a
bit confusing.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
