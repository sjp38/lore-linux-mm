Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 55AB76B0279
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 04:49:55 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id g6so3952571wmc.8
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 01:49:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y45si14576120wry.96.2017.06.27.01.49.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 01:49:52 -0700 (PDT)
Date: Tue, 27 Jun 2017 10:49:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/6] xfs: map KM_MAYFAIL to __GFP_RETRY_MAYFAIL
Message-ID: <20170627084950.GI28072@dhcp22.suse.cz>
References: <20170623085345.11304-1-mhocko@kernel.org>
 <20170623085345.11304-4-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170623085345.11304-4-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>

Christoph, Darrick
could you have a look at this patch please? Andrew has put it into mmotm
but I definitely do not want it passes your attention.

On Fri 23-06-17 10:53:42, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> KM_MAYFAIL didn't have any suitable GFP_FOO counterpart until recently
> so it relied on the default page allocator behavior for the given set
> of flags. This means that small allocations actually never failed.
> 
> Now that we have __GFP_RETRY_MAYFAIL flag which works independently on the
> allocation request size we can map KM_MAYFAIL to it. The allocator will
> try as hard as it can to fulfill the request but fails eventually if
> the progress cannot be made. It does so without triggering the OOM
> killer which can be seen as an improvement because KM_MAYFAIL users
> should be able to deal with allocation failures.
> 
> Cc: Darrick J. Wong <darrick.wong@oracle.com>
> Cc: Christoph Hellwig <hch@infradead.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  fs/xfs/kmem.h | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/fs/xfs/kmem.h b/fs/xfs/kmem.h
> index d6ea520162b2..4d85992d75b2 100644
> --- a/fs/xfs/kmem.h
> +++ b/fs/xfs/kmem.h
> @@ -54,6 +54,16 @@ kmem_flags_convert(xfs_km_flags_t flags)
>  			lflags &= ~__GFP_FS;
>  	}
>  
> +	/*
> +	 * Default page/slab allocator behavior is to retry for ever
> +	 * for small allocations. We can override this behavior by using
> +	 * __GFP_RETRY_MAYFAIL which will tell the allocator to retry as long
> +	 * as it is feasible but rather fail than retry forever for all
> +	 * request sizes.
> +	 */
> +	if (flags & KM_MAYFAIL)
> +		lflags |= __GFP_RETRY_MAYFAIL;
> +
>  	if (flags & KM_ZERO)
>  		lflags |= __GFP_ZERO;
>  
> -- 
> 2.11.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
