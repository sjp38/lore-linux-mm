Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 112CC6B026A
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:45:57 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id ez4so34678267wjd.2
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 10:45:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a34si27923933wrc.277.2017.01.25.10.45.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 10:45:55 -0800 (PST)
Date: Wed, 25 Jan 2017 19:45:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6] mm: Add memory allocation watchdog kernel thread.
Message-ID: <20170125184548.GB32041@dhcp22.suse.cz>
References: <1478416501-10104-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170125181150.GA16398@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170125181150.GA16398@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 25-01-17 13:11:50, Johannes Weiner wrote:
[...]
> >From 6420cae52cac8167bd5fb19f45feed2d540bc11d Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Wed, 25 Jan 2017 12:57:20 -0500
> Subject: [PATCH] mm: page_alloc: __GFP_NOWARN shouldn't suppress stall
>  warnings
> 
> __GFP_NOWARN, which is usually added to avoid warnings from callsites
> that expect to fail and have fallbacks, currently also suppresses
> allocation stall warnings. These trigger when an allocation is stuck
> inside the allocator for 10 seconds or longer.
> 
> But there is no class of allocations that can get legitimately stuck
> in the allocator for this long. This always indicates a problem.
> 
> Always emit stall warnings. Restrict __GFP_NOWARN to alloc failures.

Tetsuo has already suggested something like this and I didn't really
like it because it makes the semantic of the flag confusing. The mask
says to not warn while the kernel log might contain an allocation splat.
You are right that stalling for 10s seconds means a problem on its own
but on the other hand I can imagine somebody might really want to have
clean logs and the last thing we want is to have another gfp flag for
that purpose.

I also do not think that this change would make a big difference because
most allocations simply use this flag along with __GFP_NORETRY or
GFP_NOWAIT resp GFP_ATOMIC. Have we ever seen a stall with this
allocation requests?

I haven't nacked Tetsuo's patch AFAIR and will not nack this one either
I just do not think we should tweak __GFP_NOWARN.
 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f3e0c69a97b7..7ce051d1d575 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3704,7 +3704,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  
>  	/* Make sure we know about allocations which stall for too long */
>  	if (time_after(jiffies, alloc_start + stall_timeout)) {
> -		warn_alloc(gfp_mask,
> +		warn_alloc(gfp_mask & ~__GFP_NOWARN,
>  			"page allocation stalls for %ums, order:%u",
>  			jiffies_to_msecs(jiffies-alloc_start), order);
>  		stall_timeout += 10 * HZ;
> -- 
> 2.11.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
