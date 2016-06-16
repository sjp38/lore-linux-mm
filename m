Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D96366B0253
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 20:27:09 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 143so75707343pfx.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 17:27:09 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id xr1si10855388pab.95.2016.06.15.17.27.08
        for <linux-mm@kvack.org>;
        Wed, 15 Jun 2016 17:27:09 -0700 (PDT)
Date: Thu, 16 Jun 2016 10:23:02 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC PATCH 2/2] xfs: map KM_MAYFAIL to __GFP_RETRY_HARD
Message-ID: <20160616002302.GK12670@dastard>
References: <1465212736-14637-1-git-send-email-mhocko@kernel.org>
 <1465212736-14637-3-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465212736-14637-3-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, Jun 06, 2016 at 01:32:16PM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> KM_MAYFAIL didn't have any suitable GFP_FOO counterpart until recently
> so it relied on the default page allocator behavior for the given set
> of flags. This means that small allocations actually never failed.
> 
> Now that we have __GFP_RETRY_HARD flags which works independently on the
> allocation request size we can map KM_MAYFAIL to it. The allocator will
> try as hard as it can to fulfill the request but fails eventually if
> the progress cannot be made.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  fs/xfs/kmem.h | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/fs/xfs/kmem.h b/fs/xfs/kmem.h
> index 689f746224e7..34e6b062ce0e 100644
> --- a/fs/xfs/kmem.h
> +++ b/fs/xfs/kmem.h
> @@ -54,6 +54,9 @@ kmem_flags_convert(xfs_km_flags_t flags)
>  			lflags &= ~__GFP_FS;
>  	}
>  
> +	if (flags & KM_MAYFAIL)
> +		lflags |= __GFP_RETRY_HARD;
> +

I don't understand. KM_MAYFAIL means "caller handles
allocation failure, so retry on failure is not required." To then
map KM_MAYFAIL to a flag that implies the allocation will internally
retry to try exceptionally hard to prevent failure seems wrong.

IOWs, KM_MAYFAIL means XFS is just using for normal allocator
behaviour here, so I'm not sure what problem this change is actually
solving and it's not clear from the description....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
