Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CBDDC6B007E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 14:25:03 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id k184so1745891wme.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 11:25:03 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id nd4si13333318wjb.168.2016.06.17.11.25.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 11:25:02 -0700 (PDT)
Date: Fri, 17 Jun 2016 14:22:35 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 2/2] xfs: map KM_MAYFAIL to __GFP_RETRY_HARD
Message-ID: <20160617182235.GC10485@cmpxchg.org>
References: <1465212736-14637-1-git-send-email-mhocko@kernel.org>
 <1465212736-14637-3-git-send-email-mhocko@kernel.org>
 <20160616002302.GK12670@dastard>
 <20160616080355.GB6836@dhcp22.suse.cz>
 <20160616112606.GH6836@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160616112606.GH6836@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 16, 2016 at 01:26:06PM +0200, Michal Hocko wrote:
> @@ -54,6 +54,13 @@ kmem_flags_convert(xfs_km_flags_t flags)
>  			lflags &= ~__GFP_FS;
>  	}
>  
> +	/*
> +	 * Default page/slab allocator behavior is to retry for ever
> +	 * for small allocations. We can override this behavior by using
> +	 * __GFP_RETRY_HARD which will tell the allocator to retry as long
> +	 * as it is feasible but rather fail than retry for ever for all
> +	 * request sizes.
> +	 */
>  	if (flags & KM_MAYFAIL)
>  		lflags |= __GFP_RETRY_HARD;

I think this example shows that __GFP_RETRY_HARD is not a good flag
because it conflates two seemingly unrelated semantics; the comment
doesn't quite make up for that.

When the flag is set,

- it allows costly orders to invoke the OOM killer and retry
- it allows !costly orders to fail

While 1. is obvious from the name, 2. is not. Even if we don't want
full-on fine-grained naming for every reclaim methodology and retry
behavior, those two things just shouldn't be tied together.

I don't see us failing !costly order per default anytime soon, and
they are common, so adding a __GFP_MAYFAIL to explicitely override
that behavior seems like a good idea to me. That would make the XFS
callsite here perfectly obvious.

And you can still combine it with __GFP_REPEAT.

For a generic allocation site like this, __GFP_MAYFAIL | __GFP_REPEAT
does the right thing for all orders, and it's self-explanatory: try
hard, allow falling back.

Whether we want a __GFP_REPEAT or __GFP_TRY_HARD at all is a different
topic. In the long term, it might be better to provide best-effort per
default and simply annotate MAYFAIL/NORETRY callsites that want to
give up earlier. Because as I mentioned at LSFMM, it's much easier to
identify callsites that have a convenient fallback than callsites that
need to "try harder." Everybody thinks their allocations are oh so
important. The former is much more specific and uses obvious criteria.

Either way, __GFP_MAYFAIL should be on its own.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
