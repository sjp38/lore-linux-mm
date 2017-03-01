Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id AF5856B038A
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 10:06:24 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id y51so18111362wry.6
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 07:06:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o15si6343401wmd.100.2017.03.01.07.06.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Mar 2017 07:06:22 -0800 (PST)
Date: Wed, 1 Mar 2017 16:06:21 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/9] mm: remove seemingly spurious reclaimability check
 from laptop_mode gating
Message-ID: <20170301150620.GC11730@dhcp22.suse.cz>
References: <20170228214007.5621-1-hannes@cmpxchg.org>
 <20170228214007.5621-4-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170228214007.5621-4-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jia He <hejianet@gmail.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue 28-02-17 16:40:01, Johannes Weiner wrote:
> 1d82de618ddd ("mm, vmscan: make kswapd reclaim in terms of nodes")
> allowed laptop_mode=1 to start writing not just when the priority
> drops to DEF_PRIORITY - 2 but also when the node is unreclaimable.
> That appears to be a spurious change in this patch as I doubt the
> series was tested with laptop_mode, and neither is that particular
> change mentioned in the changelog. Remove it, it's still recent.

The less pgdat_reclaimable we have the better IMHO. If this is really
needed then I would appreciate a proper explanation because each such
a heuristic is just a head scratcher - especially after few years when
all the details are long forgotten.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmscan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f006140f58c6..911957b66622 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3288,7 +3288,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  		 * If we're getting trouble reclaiming, start doing writepage
>  		 * even in laptop mode.
>  		 */
> -		if (sc.priority < DEF_PRIORITY - 2 || !pgdat_reclaimable(pgdat))
> +		if (sc.priority < DEF_PRIORITY - 2)
>  			sc.may_writepage = 1;
>  
>  		/* Call soft limit reclaim before calling shrink_node. */
> -- 
> 2.11.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
