Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id DD3556B006C
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 10:50:40 -0400 (EDT)
Received: by wiaa2 with SMTP id a2so26045245wia.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 07:50:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ex9si11019074wic.44.2015.03.26.07.50.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 07:50:37 -0700 (PDT)
Date: Thu, 26 Mar 2015 15:50:34 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 11/12] mm: page_alloc: do not lock up GFP_NOFS
 allocations upon OOM
Message-ID: <20150326145034.GN15257@dhcp22.suse.cz>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-12-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427264236-17249-12-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>

On Wed 25-03-15 02:17:15, Johannes Weiner wrote:
> GFP_NOFS allocations are not allowed to invoke the OOM killer since
> their reclaim abilities are severely diminished.  However, without the
> OOM killer available there is no hope of progress once the reclaimable
> pages have been exhausted.
> 
> Don't risk hanging these allocations.  Leave it to the allocation site
> to implement the fallback policy for failing allocations.

I fully support this. We need at least
http://marc.info/?l=linux-mm&m=142669354424905&w=2 for this to work
properly, which I am planning to post soon.

I am not sure the RO remount issues in ext4 seen in the previous round
of the similar change have been addressed already.

So it might be safer to route this separately from the previous OOM
enahancements.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/page_alloc.c | 9 +--------
>  1 file changed, 1 insertion(+), 8 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 832ad1c7cd4f..9e45e97aa934 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2367,15 +2367,8 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order, int alloc_flags,
>  		if (ac->high_zoneidx < ZONE_NORMAL)
>  			goto out;
>  		/* The OOM killer does not compensate for IO-less reclaim */
> -		if (!(gfp_mask & __GFP_FS)) {
> -			/*
> -			 * XXX: Page reclaim didn't yield anything,
> -			 * and the OOM killer can't be invoked, but
> -			 * keep looping as per tradition.
> -			 */
> -			*did_some_progress = 1;
> +		if (!(gfp_mask & __GFP_FS))
>  			goto out;
> -		}
>  		if (pm_suspended_storage())
>  			goto out;
>  		/* The OOM killer may not free memory on a specific node */
> -- 
> 2.3.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
