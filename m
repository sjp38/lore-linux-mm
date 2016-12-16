Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5F5FC6B0260
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 12:36:50 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id j10so36464962wjb.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:36:50 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g29si4264359wmi.66.2016.12.16.09.36.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 09:36:48 -0800 (PST)
Date: Fri, 16 Dec 2016 12:31:51 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
 automatically
Message-ID: <20161216173151.GA23182@cmpxchg.org>
References: <20161216073941.GA26976@dhcp22.suse.cz>
 <20161216155808.12809-1-mhocko@kernel.org>
 <20161216155808.12809-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161216155808.12809-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Nils Holland <nholland@tisys.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org, Michal Hocko <mhocko@suse.com>

On Fri, Dec 16, 2016 at 04:58:08PM +0100, Michal Hocko wrote:
> @@ -1013,7 +1013,7 @@ bool out_of_memory(struct oom_control *oc)
>  	 * make sure exclude 0 mask - all other users should have at least
>  	 * ___GFP_DIRECT_RECLAIM to get here.
>  	 */
> -	if (oc->gfp_mask && !(oc->gfp_mask & (__GFP_FS|__GFP_NOFAIL)))
> +	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
>  		return true;

This makes sense, we should go back to what we had here. Because it's
not that the reported OOMs are premature - there is genuinely no more
memory reclaimable from the allocating context - but that this class
of allocations should never invoke the OOM killer in the first place.

> @@ -3737,6 +3752,16 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		 */
>  		WARN_ON_ONCE(order > PAGE_ALLOC_COSTLY_ORDER);
>  
> +		/*
> +		 * Help non-failing allocations by giving them access to memory
> +		 * reserves but do not use ALLOC_NO_WATERMARKS because this
> +		 * could deplete whole memory reserves which would just make
> +		 * the situation worse
> +		 */
> +		page = __alloc_pages_cpuset_fallback(gfp_mask, order, ALLOC_HARDER, ac);
> +		if (page)
> +			goto got_pg;
> +

But this should be a separate patch, IMO.

Do we observe GFP_NOFS lockups when we don't do this? Don't we risk
premature exhaustion of the memory reserves, and it's better to wait
for other reclaimers to make some progress instead? Should we give
reserve access to all GFP_NOFS allocations, or just the ones from a
reclaim/cleaning context? All that should go into the changelog of a
separate allocation booster patch, I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
