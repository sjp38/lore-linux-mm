Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id B59DE6B0005
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 11:55:44 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id r97so55487343lfi.2
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 08:55:44 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s17si1580493wmb.62.2016.07.21.08.55.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jul 2016 08:55:43 -0700 (PDT)
Date: Thu, 21 Jul 2016 11:52:59 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/5] mm: consider per-zone inactive ratio to deactivate
Message-ID: <20160721155259.GB30303@cmpxchg.org>
References: <1469110261-7365-1-git-send-email-mgorman@techsingularity.net>
 <1469110261-7365-5-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469110261-7365-5-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 21, 2016 at 03:11:00PM +0100, Mel Gorman wrote:
> @@ -1981,6 +1982,32 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file)
>  	inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
>  	active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
>  
> +	/*
> +	 * For global reclaim on zone-constrained allocations, it is necessary
> +	 * to check if rotations are required for lowmem to be reclaimed. This

s/rotation/deactivation/

> +	 * calculates the inactive/active pages available in eligible zones.
> +	 */
> +	if (global_reclaim(sc)) {
> +		struct pglist_data *pgdat = lruvec_pgdat(lruvec);
> +		int zid;
> +
> +		for (zid = sc->reclaim_idx + 1; zid < MAX_NR_ZONES; zid++) {

The emphasis on global vs. memcg reclaim is somewhat strange, because
this is only about excluding pages from the balancing math that will
be skipped. Memcg reclaim is never zone-restricted, but if it were, it
would make sense to exclude the skipped pages there as well.

Indeed, for memcg reclaim sc->reclaim_idx+1 is always MAX_NR_ZONES,
and so the for loop alone will do the right thing.

Can you please drop the global_reclaim() branch, the sc function
parameter, and the "global reclaim" from the comment?

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
