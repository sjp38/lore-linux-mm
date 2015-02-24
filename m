Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5A9576B006C
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:22:53 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id r20so27704687wiv.2
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 10:22:53 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ln3si62460918wjb.20.2015.02.24.10.22.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Feb 2015 10:22:51 -0800 (PST)
Date: Tue, 24 Feb 2015 19:22:50 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm, oom: do not fail __GFP_NOFAIL allocation if oom
 killer is disbaled
Message-ID: <20150224182250.GE14939@dhcp22.suse.cz>
References: <1424801964-1602-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1424801964-1602-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 24-02-15 19:19:24, Michal Hocko wrote:
> Tetsuo Handa has pointed out that __GFP_NOFAIL allocations might fail
> after OOM killer is disabled if the allocation is performed by a
> kernel thread. This behavior was introduced from the very beginning by
> 7f33d49a2ed5 (mm, PM/Freezer: Disable OOM killer when tasks are frozen).
> This means that the basic contract for the allocation request is broken
> and the context requesting such an allocation might blow up unexpectedly.
> 
> There are basically two ways forward.
> 1) move oom_killer_disable after kernel threads are frozen. This has a
>    risk that the OOM victim wouldn't be able to finish because it would
>    depend on an already frozen kernel thread. This would be really
>    tricky to debug.
> 2) do not fail GFP_NOFAIL allocation no matter what and risk a potential
>    Freezable kernel threads will loop and fail the suspend. Incidental
>    allocations after kernel threads are frozen will at least dump a
>    warning - if we are lucky and the serial console is still active of
>    course...
> 
> This patch implements the later option because it is safer. We would see
> warnings rather than allocation failures for the kernel threads which
> would blow up otherwise and have a higher chances to identify
> __GFP_NOFAIL users from deeper pm code.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
> 
> We haven't seen any bug reports 

Ups, forgot to save the file before sending. The full text is:
"
We haven't seen any bug reports since 2009 so I haven't marked the patch
for stable. I have no problem to backport it to stable trees though if
people think it is a good precaution.
"

> 
>  mm/oom_kill.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 642f38cb175a..ea8b443cd871 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -772,6 +772,10 @@ out:
>  		schedule_timeout_killable(1);
>  }
>  
> +static DEFINE_RATELIMIT_STATE(oom_disabled_rs,
> +		DEFAULT_RATELIMIT_INTERVAL,
> +		DEFAULT_RATELIMIT_BURST);
> +
>  /**
>   * out_of_memory -  tries to invoke OOM killer.
>   * @zonelist: zonelist pointer
> @@ -792,6 +796,10 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  	if (!oom_killer_disabled) {
>  		__out_of_memory(zonelist, gfp_mask, order, nodemask, force_kill);
>  		ret = true;
> +	} else if (gfp_mask & __GFP_NOFAIL) {
> +		if (__ratelimit(&oom_disabled_rs))
> +			WARN(1, "Unable to make forward progress for __GFP_NOFAIL because OOM killer is disbaled\n");
> +		ret = true;
>  	}
>  	up_read(&oom_sem);
>  
> -- 
> 2.1.4
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
