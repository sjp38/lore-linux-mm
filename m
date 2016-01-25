Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7CAFC6B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 09:55:44 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id r129so67397505wmr.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 06:55:44 -0800 (PST)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id d71si24919917wmi.16.2016.01.25.06.55.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 06:55:43 -0800 (PST)
Received: by mail-wm0-f50.google.com with SMTP id l65so67297519wmf.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 06:55:43 -0800 (PST)
Date: Mon, 25 Jan 2016 15:55:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: do not loop !__GFP_FS allocation if the OOM
 killer is disabled.
Message-ID: <20160125145541.GD23939@dhcp22.suse.cz>
References: <1453563531-4831-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453563531-4831-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

It would really help if you CCed all people who participated in the
previous discussion... and Andrew (CCed now) to pick up the patch as
well.

On Sun 24-01-16 00:38:51, Tetsuo Handa wrote:
> After the OOM killer is disabled during suspend operation,
> any !__GFP_NOFAIL && __GFP_FS allocations are forced to fail.
> Thus, any !__GFP_NOFAIL && !__GFP_FS allocations should be
> forced to fail as well.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Acked-by: David Rientjes <rientjes@google.com>
> ---
>  mm/page_alloc.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6463426..2f71caa 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2749,8 +2749,12 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  			 * XXX: Page reclaim didn't yield anything,
>  			 * and the OOM killer can't be invoked, but
>  			 * keep looping as per tradition.
> +			 *
> +			 * But do not keep looping if oom_killer_disable()
> +			 * was already called, for the system is trying to
> +			 * enter a quiescent state during suspend.
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
