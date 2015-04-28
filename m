Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id B65AD6B006C
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 09:30:12 -0400 (EDT)
Received: by wgso17 with SMTP id o17so151801266wgs.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 06:30:12 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f4si38521110wjn.5.2015.04.28.06.30.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Apr 2015 06:30:11 -0700 (PDT)
Date: Tue, 28 Apr 2015 15:30:09 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 9/9] mm: page_alloc: memory reserve access for
 OOM-killing allocations
Message-ID: <20150428133009.GD2659@dhcp22.suse.cz>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
 <1430161555-6058-10-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1430161555-6058-10-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 27-04-15 15:05:55, Johannes Weiner wrote:
> The OOM killer connects random tasks in the system with unknown
> dependencies between them, and the OOM victim might well get blocked
> behind locks held by the allocating task.  That means that while
> allocations can issue OOM kills to improve the low memory situation,
> which generally frees more than they are going to take out, they can
> not rely on their *own* OOM kills to make forward progress.
> 
> However, OOM-killing allocations currently retry forever.  Without any
> extra measures the above situation will result in a deadlock; between
> the allocating task and the OOM victim at first, but it can spread
> once other tasks in the system start contending for the same locks.
> 
> Allow OOM-killing allocations to dip into the system's memory reserves
> to avoid this deadlock scenario.  Those reserves are specifically for
> operations in the memory reclaim paths which need a small amount of
> memory to release a much larger amount.  Arguably, the same notion
> applies to the OOM killer.

This will not work without some throttling. You will basically give a
free ticket to all memory reserves to basically all allocating tasks
(which are allowed to trigger OOM and there might be hundreds of them)
and that itself might prevent the OOM victim from exiting.

Your previous OOM wmark was nicer because it naturally throttled
allocations and still left some room for the exiting task.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/page_alloc.c | 14 ++++++++++++++
>  1 file changed, 14 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 94530db..5f3806d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2384,6 +2384,20 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order, int alloc_flags,
>  		if (WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
>  			*did_some_progress = 1;
>  	}
> +
> +	/*
> +	 * In the current implementation, an OOM-killing allocation
> +	 * loops indefinitely inside the allocator.  However, it's
> +	 * possible for the OOM victim to get stuck behind locks held
> +	 * by the allocating task itself, so we can never rely on the
> +	 * OOM killer to free memory synchroneously without risking a
> +	 * deadlock.  Allow these allocations to dip into the memory
> +	 * reserves to ensure forward progress once the OOM kill has
> +	 * been issued.  The reserves will be replenished when the
> +	 * caller releases the locks and the victim exits.
> +	 */
> +	if (*did_some_progress)
> +		alloc_flags |= ALLOC_NO_WATERMARKS;
>  out:
>  	mutex_unlock(&oom_lock);
>  alloc:
> -- 
> 2.3.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
