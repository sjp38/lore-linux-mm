Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0F68B828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 10:45:06 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id b14so275097613wmb.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 07:45:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cb2si199927639wjc.79.2016.01.11.07.45.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 11 Jan 2016 07:45:05 -0800 (PST)
Date: Mon, 11 Jan 2016 16:45:01 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm,oom: do not loop !__GFP_FS allocation if the OOM
 killer is disabled.
Message-ID: <20160111154501.GI27317@dhcp22.suse.cz>
References: <1452488836-6772-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1452488836-6772-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, rientjes@google.com, linux-mm@kvack.org

On Mon 11-01-16 14:07:16, Tetsuo Handa wrote:
> After the OOM killer is disabled during suspend operation,
> any !__GFP_NOFAIL && __GFP_FS allocations are forced to fail.
> Thus, any !__GFP_NOFAIL && !__GFP_FS allocations should be
> forced to fail as well.

I hoped for minimum exposure of oom_killer_disabled outside of the OOM
proper but this seems to be the easiest way to go.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3c3a5c5..214f824 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2766,7 +2766,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  			 * and the OOM killer can't be invoked, but
>  			 * keep looping as per tradition.
>  			 */
> -			*did_some_progress = 1;
> +			*did_some_progress = !oom_killer_disabled;
>  			goto out;
>  		}
>  		if (pm_suspended_storage())
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
