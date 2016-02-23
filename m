Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9AB926B0005
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:57:32 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id g62so7898002wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:57:32 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g67si41303073wmi.14.2016.02.23.10.57.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 10:57:31 -0800 (PST)
Date: Tue, 23 Feb 2016 10:57:22 -0800
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 06/27] mm, vmscan: Begin reclaiming pages on a per-node
 basis
Message-ID: <20160223185722.GF13816@cmpxchg.org>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
 <1456239890-20737-7-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456239890-20737-7-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 23, 2016 at 03:04:29PM +0000, Mel Gorman wrote:
> @@ -2428,10 +2448,11 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  			reclaimed = sc->nr_reclaimed;
>  			scanned = sc->nr_scanned;
>  
> +			sc->reclaim_idx = reclaim_idx;
>  			shrink_zone_memcg(zone, memcg, sc, &lru_pages);
>  			zone_lru_pages += lru_pages;

The setting of sc->reclaim_idx is unexpected here. Why not set it in
the caller and eliminate the reclaim_idx parameter?

> @@ -2558,16 +2579,12 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  		sc->gfp_mask |= __GFP_HIGHMEM;
>  
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> -					requested_highidx, sc->nodemask) {

It's unfortunate that we start with the lowest zone here. For Normal
allocations, the most common allocations, this will always have two
full shrink_node() rounds that skip over everything >DMA in the first,
then over everything >DMA32 in the second, even though all pages on
the node are valid reclaim candidates for that allocation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
