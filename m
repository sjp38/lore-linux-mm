Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 70B9E6B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 16:07:51 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id t18so20591035wmt.7
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 13:07:51 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id p5si26332292wrb.115.2017.01.17.13.07.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 13:07:50 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id EE1C598FBE
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 21:07:49 +0000 (UTC)
Date: Tue, 17 Jan 2017 21:07:49 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/4] mm, page_alloc: Split buffered_rmqueue
Message-ID: <20170117210749.rzpsavbx5gztsx6o@techsingularity.net>
References: <20170117092954.15413-1-mgorman@techsingularity.net>
 <20170117092954.15413-2-mgorman@techsingularity.net>
 <20170117190732.0fc733ec@redhat.com>
 <2df88f73-a32d-4b71-d4de-3a0ad8831d9a@suse.cz>
 <20170117202008.pcufk5qencdgkgpj@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170117202008.pcufk5qencdgkgpj@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>

On Tue, Jan 17, 2017 at 08:20:08PM +0000, Mel Gorman wrote:
> It's late so I'm fairly tired but assuming I can reproduce this in the
> morning, the first thing I'll try is something like this to force a reread
> of mems_allowed;
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ebea51cc0135..3fc2b3a8d301 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3774,13 +3774,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  		.migratetype = gfpflags_to_migratetype(gfp_mask),
>  	};
>  
> -	if (cpusets_enabled()) {
> -		alloc_mask |= __GFP_HARDWALL;
> -		alloc_flags |= ALLOC_CPUSET;
> -		if (!ac.nodemask)
> -			ac.nodemask = &cpuset_current_mems_allowed;
> -	}
> -
>  	gfp_mask &= gfp_allowed_mask;
>  
>  	lockdep_trace_alloc(gfp_mask);
> @@ -3802,6 +3795,13 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  		alloc_flags |= ALLOC_CMA;
>  
>  retry_cpuset:
> +	if (cpusets_enabled()) {
> +		alloc_mask |= __GFP_HARDWALL;
> +		alloc_flags |= ALLOC_CPUSET;
> +		if (!nodemask)
> +			ac.nodemask = &cpuset_current_mems_allowed;
> +	}
> +
>  	cpuset_mems_cookie = read_mems_allowed_begin();
>  
>  	/* Dirty zone balancing only done in the fast path */
> 

I later recalled that we looked at this before and didn't think a reinit
was necessary because the location of cpuset_current_mems_allowed doesn't
change so I came back and took another look.  The location doesn't change
but after the first attempt, we reset ac.nodemask to the given nodemask and
don't recheck current_mems_allowed if the cpuset changed. The application
of memory policies versus cpusets is a mess so it'll take time to pick
apart to see if this is even remotely in the right direction.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
