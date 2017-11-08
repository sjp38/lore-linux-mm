Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 28C64440417
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 09:50:43 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u70so2364845pfa.2
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 06:50:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w12si3899845pld.307.2017.11.08.06.50.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 06:50:41 -0800 (PST)
Date: Wed, 8 Nov 2017 15:50:39 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 1/5] mm,page_alloc: Update comment for last second
 allocation attempt.
Message-ID: <20171108145039.tdueguedqos4rpk5@dhcp22.suse.cz>
References: <1510138908-6265-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1510138908-6265-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed 08-11-17 20:01:44, Tetsuo Handa wrote:
> __alloc_pages_may_oom() is doing last second allocation attempt using
> ALLOC_WMARK_HIGH before calling out_of_memory(). This had two reasons.
> 
> The first reason is explained in the comment that it aims to catch
> potential parallel OOM killing. But there is no longer parallel OOM
> killing (in the sense that out_of_memory() is called "concurrently")
> because we serialize out_of_memory() calls using oom_lock.
> 
> The second reason is explained by Andrea Arcangeli (who added that code)
> that it aims to reduce the likelihood of OOM livelocks and be sure to
> invoke the OOM killer. There was a risk of livelock or anyway of delayed
> OOM killer invocation if ALLOC_WMARK_MIN is used, for relying on last
> few pages which are constantly allocated and freed in the meantime will
> not improve the situation.

> But there is no longer possibility of OOM
> livelocks or failing to invoke the OOM killer because we need to mask
> __GFP_DIRECT_RECLAIM for last second allocation attempt because oom_lock
> prevents __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocations which last
> second allocation attempt indirectly involve from failing.

This is an unfounded, misleading and actually even wrong statement that
has nothing to do with what Andrea had in mind. __GFP_DIRECT_RECLAIM
doesn't have anything to do with the livelock as I've already mentioned
several times already.

> Since the OOM killer does not always kill a process consuming significant
> amount of memory (the OOM killer kills a process with highest OOM score
> (or instead one of its children if any)), there will be cases where
> ALLOC_WMARK_HIGH fails and ALLOC_WMARK_MIN succeeds.

This is possible but not really interesting case as already explained.

> Since the gap between ALLOC_WMARK_HIGH and ALLOC_WMARK_MIN can be changed
> by /proc/sys/vm/min_free_kbytes parameter, using ALLOC_WMARK_MIN for last
> second allocation attempt might be better for minimizing number of OOM
> victims. But that change should be done in a separate patch. This patch
> just clarifies that ALLOC_WMARK_HIGH is an arbitrary choice.

Again unfounded claim.

That being said, the comment removing a note about parallel oom killing
is OK. I am not sure this is something worth a separate patch. The
changelog is just wrong and so Nack to the patch.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/page_alloc.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 536431b..613814c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3341,11 +3341,10 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
>  	}
>  
>  	/*
> -	 * Go through the zonelist yet one more time, keep very high watermark
> -	 * here, this is only to catch a parallel oom killing, we must fail if
> -	 * we're still under heavy pressure. But make sure that this reclaim
> -	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
> -	 * allocation which will never fail due to oom_lock already held.
> +	 * This allocation attempt must not depend on __GFP_DIRECT_RECLAIM &&
> +	 * !__GFP_NORETRY allocation which will never fail due to oom_lock
> +	 * already held. And since this allocation attempt does not sleep,
> +	 * there is no reason we must use high watermark here.
>  	 */
>  	page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
>  				      ~__GFP_DIRECT_RECLAIM, order,
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
