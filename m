Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0EE5B6B007E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 04:36:38 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w143so60967848wmw.3
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 01:36:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dm2si9409272wjb.137.2016.04.28.01.36.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Apr 2016 01:36:36 -0700 (PDT)
Subject: Re: [PATCH 06/27] mm, vmscan: Make kswapd reclaim in terms of nodes
References: <1460711613-2761-1-git-send-email-mgorman@techsingularity.net>
 <1460711613-2761-7-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5721CB93.8000207@suse.cz>
Date: Thu, 28 Apr 2016 10:36:35 +0200
MIME-Version: 1.0
In-Reply-To: <1460711613-2761-7-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2016 11:13 AM, Mel Gorman wrote:
>   	/*
> -	 * If a zone reaches its high watermark, consider it to be no longer
> -	 * congested. It's possible there are dirty pages backed by congested
> -	 * BDIs but as pressure is relieved, speculatively avoid congestion
> -	 * waits.
> +	 * Fragmentation may mean that the system cannot be rebalanced for
> +	 * high-order allocations. If twice the allocation size has been
> +	 * reclaimed then recheck watermarks only at order-0 to prevent
> +	 * excessive reclaim. Assume that a process requested a high-order
> +	 * can direct reclaim/compact.

Also kcompactd is woken up in this case...

>   	 */
> -	if (pgdat_reclaimable(zone->zone_pgdat) &&
> -	    zone_balanced(zone, sc->order, false, 0, classzone_idx)) {
> -		clear_bit(PGDAT_CONGESTED, &pgdat->flags);
> -		clear_bit(PGDAT_DIRTY, &pgdat->flags);
> -	}
> +	if (sc->order && sc->nr_reclaimed >= 2UL << sc->order)
> +		sc->order = 0;
>
>   	return sc->nr_scanned >= sc->nr_to_reclaim;

This looks indeed simpler than my earlier zone_balanced() modification 
you removed. However I think there's still potential of overreclaim due 
to a stream of kswapd_wakeups where each will have to reclaim 2UL << 
sc->order pages, regardless of watermarks. Could be some high-order 
wakeups from GFP_ATOMIC context that have order-0 fallbacks but will 
cause kswapd to keep reclaiming when kcompactd can't keep up due to 
fragmentation...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
