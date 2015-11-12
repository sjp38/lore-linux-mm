Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 642BA6B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 07:39:31 -0500 (EST)
Received: by wmec201 with SMTP id c201so30835188wme.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 04:39:31 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id uv3si18281231wjc.161.2015.11.12.04.39.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 04:39:30 -0800 (PST)
Received: by wmec201 with SMTP id c201so89436058wme.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 04:39:30 -0800 (PST)
Date: Thu, 12 Nov 2015 13:39:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 1/3] mm, oom: refactor oom detection
Message-ID: <20151112123928.GH1174@dhcp22.suse.cz>
References: <1446131835-3263-1-git-send-email-mhocko@kernel.org>
 <1446131835-3263-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1446131835-3263-2-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Thu 29-10-15 16:17:13, mhocko@kernel.org wrote:
[...]
> @@ -3135,13 +3145,56 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	if (gfp_mask & __GFP_NORETRY)
>  		goto noretry;
>  
> -	/* Keep reclaiming pages as long as there is reasonable progress */
> +	/*
> +	 * Do not retry high order allocations unless they are __GFP_REPEAT
> +	 * and even then do not retry endlessly.
> +	 */
>  	pages_reclaimed += did_some_progress;
> -	if ((did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER) ||
> -	    ((gfp_mask & __GFP_REPEAT) && pages_reclaimed < (1 << order))) {
> -		/* Wait for some write requests to complete then retry */
> -		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
> -		goto retry;
> +	if (order > PAGE_ALLOC_COSTLY_ORDER) {
> +		if (!(gfp_mask & __GFP_REPEAT) || pages_reclaimed >= (1<<order))
> +			goto noretry;

This is not correct because we could fail __GFP_NOFAIL allocation. It
should do
		if (!(gfp_mask & __GFP_NOFAIL) &&
		   (!(gfp_mask & __GFP_REPEAT) || pages_reclaimed >= (1<<order)))
			goto noretry;

It looks rather ugly but it will get much better with patch3 which
reorganizes the code a bit

> +
> +		if (did_some_progress)
> +			goto retry;
> +	}

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
