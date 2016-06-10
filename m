Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 63B766B007E
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 12:39:33 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id u74so32992643lff.0
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 09:39:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y195si33845362wme.63.2016.06.10.09.39.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Jun 2016 09:39:32 -0700 (PDT)
Subject: Re: [PATCH 02/27] mm, vmscan: Move lru_lock to the node
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-3-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <575AED3E.3090705@suse.cz>
Date: Fri, 10 Jun 2016 18:39:26 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-3-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> Node-based reclaim requires node-based LRUs and locking. This is a
> preparation patch that just moves the lru_lock to the node so later patches
> are easier to review. It is a mechanical change but note this patch makes
> contention worse because the LRU lock is hotter and direct reclaim and kswapd
> can contend on the same lock even when reclaiming from different zones.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

One thing...

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9d71af25acf9..1e0ad06c33bd 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5944,10 +5944,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  		zone->min_slab_pages = (freesize * sysctl_min_slab_ratio) / 100;
>  #endif
>  		zone->name = zone_names[j];
> +		zone->zone_pgdat = pgdat;
>  		spin_lock_init(&zone->lock);
> -		spin_lock_init(&zone->lru_lock);
> +		spin_lock_init(zone_lru_lock(zone));

This means the same lock will be inited MAX_NR_ZONES times. Peterz told
me it's valid but weird. Probably better to do it just once, in case
lockdep/lock debugging gains some checks for that?

>  		zone_seqlock_init(zone);
> -		zone->zone_pgdat = pgdat;
>  		zone_pcp_init(zone);
>  
>  		/* For bootup, initialized properly in watermark setup */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
