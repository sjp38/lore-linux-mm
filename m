Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7BAC56B0299
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 03:06:15 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id zy2so97515448pac.1
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 00:06:15 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id zp15si1891608pab.241.2016.04.21.00.06.13
        for <linux-mm@kvack.org>;
        Thu, 21 Apr 2016 00:06:14 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org> <1461181647-8039-10-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461181647-8039-10-git-send-email-mhocko@kernel.org>
Subject: Re: [PATCH 09/14] mm: use compaction feedback for thp backoff conditions
Date: Thu, 21 Apr 2016 15:05:52 +0800
Message-ID: <02d401d19b9c$3e6a6aa0$bb3f3fe0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'Joonsoo Kim' <js1304@gmail.com>, 'Vlastimil Babka' <vbabka@suse.cz>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>

> 
> From: Michal Hocko <mhocko@suse.com>
> 
> THP requests skip the direct reclaim if the compaction is either
> deferred or contended to reduce stalls which wouldn't help the
> allocation success anyway. These checks are ignoring other potential
> feedback modes which we have available now.
> 
> It clearly doesn't make much sense to go and reclaim few pages if the
> previous compaction has failed.
> 
> We can also simplify the check by using compaction_withdrawn which
> checks for both COMPACT_CONTENDED and COMPACT_DEFERRED. This check
> is however covering more reasons why the compaction was withdrawn.
> None of them should be a problem for the THP case though.
> 
> It is safe to back of if we see COMPACT_SKIPPED because that means
> that compaction_suitable failed and a single round of the reclaim is
> unlikely to make any difference here. We would have to be close to
> the low watermark to reclaim enough and even then there is no guarantee
> that the compaction would make any progress while the direct reclaim
> would have caused the stall.
> 
> COMPACT_PARTIAL_SKIPPED is slightly different because that means that we
> have only seen a part of the zone so a retry would make some sense. But
> it would be a compaction retry not a reclaim retry to perform. We are
> not doing that and that might indeed lead to situations where THP fails
> but this should happen only rarely and it would be really hard to
> measure.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/page_alloc.c | 27 ++++++++-------------------
>  1 file changed, 8 insertions(+), 19 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 350d13f3709b..d551fe326c33 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3257,25 +3257,14 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	if (page)
>  		goto got_pg;
> 
> -	/* Checks for THP-specific high-order allocations */
> -	if (is_thp_gfp_mask(gfp_mask)) {
> -		/*
> -		 * If compaction is deferred for high-order allocations, it is
> -		 * because sync compaction recently failed. If this is the case
> -		 * and the caller requested a THP allocation, we do not want
> -		 * to heavily disrupt the system, so we fail the allocation
> -		 * instead of entering direct reclaim.
> -		 */
> -		if (compact_result == COMPACT_DEFERRED)
> -			goto nopage;
> -
> -		/*
> -		 * Compaction is contended so rather back off than cause
> -		 * excessive stalls.
> -		 */
> -		if(compact_result == COMPACT_CONTENDED)
> -			goto nopage;
> -	}
> +	/*
> +	 * Checks for THP-specific high-order allocations and back off
> +	 * if the the compaction backed off or failed
> +	 */

Alternatively,
	/*
	 * Check THP allocations and back off
	 * if the compaction bailed out or failed
	 */
> +	if (is_thp_gfp_mask(gfp_mask) &&
> +			(compaction_withdrawn(compact_result) ||
> +			 compaction_failed(compact_result)))
> +		goto nopage;
> 
>  	/*
>  	 * It can become very expensive to allocate transparent hugepages at
> --
> 2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
