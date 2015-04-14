Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 950B46B0032
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 12:55:14 -0400 (EDT)
Received: by wgsk9 with SMTP id k9so18879848wgs.3
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 09:55:14 -0700 (PDT)
Received: from mail-wg0-x229.google.com (mail-wg0-x229.google.com. [2a00:1450:400c:c00::229])
        by mx.google.com with ESMTPS id e3si3149742wjs.203.2015.04.14.09.55.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Apr 2015 09:55:13 -0700 (PDT)
Received: by wgin8 with SMTP id n8so18950954wgi.0
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 09:55:12 -0700 (PDT)
Date: Tue, 14 Apr 2015 18:55:11 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 10/12] mm: page_alloc: emergency reserve access for
 __GFP_NOFAIL allocations
Message-ID: <20150414165511.GK17160@dhcp22.suse.cz>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-11-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427264236-17249-11-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>

On Wed 25-03-15 02:17:14, Johannes Weiner wrote:
> __GFP_NOFAIL allocations can deadlock the OOM killer when they're
> holding locks that the OOM victim might need to exit.  When that
> happens the allocation may never complete, which has disastrous
> effects on things like in-flight filesystem transactions.
> 
> When the system is OOM, allow __GFP_NOFAIL allocations to dip into the
> emergency reserves in the hope that this will allow transactions and
> writeback to complete and the deadlock can be avoided.

This one slipped through. Sorry.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Suggested-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/page_alloc.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3c165016175d..832ad1c7cd4f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2403,9 +2403,17 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order, int alloc_flags,
>  	 * from exiting.  While allocations can use OOM kills to free
>  	 * memory, they can not necessarily rely on their *own* kills
>  	 * to make forward progress.
> +	 *
> +	 * This last point is crucial for __GFP_NOFAIL allocations.
> +	 * Since they can't quit, they might actually deadlock, so
> +	 * give them hail mary access to the emergency reserves.
>  	 */
> -	alloc_flags &= ~ALLOC_WMARK_MASK;
> -	alloc_flags |= ALLOC_WMARK_OOM;
> +	if (gfp_mask & __GFP_NOFAIL) {
> +		alloc_flags |= ALLOC_NO_WATERMARKS;
> +	} else {
> +		alloc_flags &= ~ALLOC_WMARK_MASK;
> +		alloc_flags |= ALLOC_WMARK_OOM;
> +	}
>  out:
>  	mutex_unlock(&oom_lock);
>  alloc:
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
