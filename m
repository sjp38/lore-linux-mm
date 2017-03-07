Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3A6C26B038E
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 12:05:33 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id 14so9039505itw.3
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 09:05:33 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id p5si1006565iod.111.2017.03.07.09.05.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 09:05:32 -0800 (PST)
Date: Tue, 7 Mar 2017 09:05:19 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [RFC PATCH 3/4] xfs: map KM_MAYFAIL to __GFP_RETRY_MAYFAIL
Message-ID: <20170307170519.GE5281@birch.djwong.org>
References: <20170307154843.32516-1-mhocko@kernel.org>
 <20170307154843.32516-4-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307154843.32516-4-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Mar 07, 2017 at 04:48:42PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> KM_MAYFAIL didn't have any suitable GFP_FOO counterpart until recently
> so it relied on the default page allocator behavior for the given set
> of flags. This means that small allocations actually never failed.
> 
> Now that we have __GFP_RETRY_MAYFAIL flag which works independently on the
> allocation request size we can map KM_MAYFAIL to it. The allocator will
> try as hard as it can to fulfill the request but fails eventually if
> the progress cannot be made.
> 
> Cc: Darrick J. Wong <darrick.wong@oracle.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  fs/xfs/kmem.h | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/fs/xfs/kmem.h b/fs/xfs/kmem.h
> index ae08cfd9552a..ac80a4855c83 100644
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
> +	 * as it is feasible but rather fail than retry for ever for all

s/for ever/forever/

> +	 * request sizes.
> +	 */
> +	if (flags & KM_MAYFAIL)
> +		lflags |= __GFP_RETRY_MAYFAIL;

But otherwise seems ok from a quick grep -B5 MAYFAIL through the XFS code.

(Has this been tested anywhere?)

--D

> +
>  	if (flags & KM_ZERO)
>  		lflags |= __GFP_ZERO;
>  
> -- 
> 2.11.0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
