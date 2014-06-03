Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id D811E6B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 09:16:39 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id k48so6775753wev.19
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 06:16:39 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ce8si32301404wjb.125.2014.06.03.06.16.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 06:16:38 -0700 (PDT)
Date: Tue, 3 Jun 2014 15:16:35 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 04/10] mm: memcontrol: reclaim at least once for
 __GFP_NORETRY
Message-ID: <20140603131635.GH1321@dhcp22.suse.cz>
References: <1401380162-24121-1-git-send-email-hannes@cmpxchg.org>
 <1401380162-24121-5-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1401380162-24121-5-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 29-05-14 12:15:56, Johannes Weiner wrote:
> Currently, __GFP_NORETRY tries charging once and gives up before even
> trying to reclaim.  Bring the behavior on par with the page allocator
> and reclaim at least once before giving up.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e8d5075c081f..8957d6c945b8 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2614,13 +2614,13 @@ retry:
>  	if (!(gfp_mask & __GFP_WAIT))
>  		goto nomem;
>  
> -	if (gfp_mask & __GFP_NORETRY)
> -		goto nomem;
> -
>  	nr_reclaimed = mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags);
>  
>  	if (mem_cgroup_margin(mem_over_limit) >= batch)
>  		goto retry;
> +
> +	if (gfp_mask & __GFP_NORETRY)
> +		goto nomem;
>  	/*
>  	 * Even though the limit is exceeded at this point, reclaim
>  	 * may have been able to free some pages.  Retry the charge
> -- 
> 1.9.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
