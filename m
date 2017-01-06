Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 53C5D6B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 05:40:51 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id l2so2815275wml.5
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 02:40:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f197si2299786wmf.28.2017.01.06.02.40.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 02:40:49 -0800 (PST)
Date: Fri, 6 Jan 2017 11:40:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, page_alloc: don't check cpuset allowed twice in
 fast-path
Message-ID: <20170106104048.GB5561@dhcp22.suse.cz>
References: <20170106081805.26132-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170106081805.26132-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 06-01-17 09:18:05, Vlastimil Babka wrote:
> Since commit 682a3385e773 ("mm, page_alloc: inline the fast path of the
> zonelist iterator") we replace a NULL nodemask with cpuset_current_mems_allowed
> in the fast path, so that get_page_from_freelist() filters nodes allowed by the
> cpuset via for_next_zone_zonelist_nodemask(). In that case it's pointless to
> also check __cpuset_zone_allowed(), which we can avoid by not using
> ALLOC_CPUSET in that scenario.

OK, this seems to be really worth it as most allocations go via
__alloc_pages so we can save __cpuset_zone_allowed in the fast path.

I was about to object how fragile this might be wrt. other ALLOC_CPUSET
checks but then I've realized this is only for the hotpath as the
slowpath goes through gfp_to_alloc_flags() which sets it back on.

Maybe all that could be added to the changelog?
 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2c6d5f64feca..3d86fbe2f4f4 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3754,9 +3754,10 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  
>  	if (cpusets_enabled()) {
>  		alloc_mask |= __GFP_HARDWALL;
> -		alloc_flags |= ALLOC_CPUSET;
>  		if (!ac.nodemask)
>  			ac.nodemask = &cpuset_current_mems_allowed;
> +		else
> +			alloc_flags |= ALLOC_CPUSET;
>  	}
>  
>  	gfp_mask &= gfp_allowed_mask;
> -- 
> 2.11.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
