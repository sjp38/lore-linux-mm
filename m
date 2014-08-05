Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id A70F26B0035
	for <linux-mm@kvack.org>; Tue,  5 Aug 2014 08:26:53 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id k48so930074wev.27
        for <linux-mm@kvack.org>; Tue, 05 Aug 2014 05:26:53 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id on8si3317658wjc.12.2014.08.05.05.26.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 05 Aug 2014 05:26:44 -0700 (PDT)
Date: Tue, 5 Aug 2014 14:26:36 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm: memcontrol: clean up reclaim size variable use in
 try_charge()
Message-ID: <20140805122636.GE15908@dhcp22.suse.cz>
References: <1407184502-20818-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1407184502-20818-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 04-08-14 16:35:02, Johannes Weiner wrote:
> Charge reclaim and OOM currently use the charge batch variable, but
> batching is already disabled at that point.  To simplify the charge
> logic, the batch variable is reset to the original request size when
> reclaim is entered, so it's functionally equal, but it's misleading.
> 
> Switch reclaim/OOM to nr_pages, which is the original request size.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8d65dadeec1b..ec4dcf1b9562 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2574,7 +2574,7 @@ retry:
>  
>  	nr_reclaimed = mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags);
>  
> -	if (mem_cgroup_margin(mem_over_limit) >= batch)
> +	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
>  		goto retry;
>  
>  	if (gfp_mask & __GFP_NORETRY)
> @@ -2588,7 +2588,7 @@ retry:
>  	 * unlikely to succeed so close to the limit, and we fall back
>  	 * to regular pages anyway in case of failure.
>  	 */
> -	if (nr_reclaimed && batch <= (1 << PAGE_ALLOC_COSTLY_ORDER))
> +	if (nr_reclaimed && nr_pages <= (1 << PAGE_ALLOC_COSTLY_ORDER))
>  		goto retry;
>  	/*
>  	 * At task move, charge accounts can be doubly counted. So, it's
> @@ -2606,7 +2606,7 @@ retry:
>  	if (fatal_signal_pending(current))
>  		goto bypass;
>  
> -	mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(batch));
> +	mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(nr_pages));
>  nomem:
>  	if (!(gfp_mask & __GFP_NOFAIL))
>  		return -ENOMEM;
> -- 
> 2.0.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
