Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EEF116B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 02:50:10 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id h21so16877581pfk.14
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 23:50:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b186si17390410pgc.780.2017.11.23.23.50.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 23:50:09 -0800 (PST)
Date: Fri, 24 Nov 2017 08:50:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Do not stall register_shrinker
Message-ID: <20171124075006.wlixilwhipagvbc5@dhcp22.suse.cz>
References: <1511481899-20335-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511481899-20335-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team <kernel-team@lge.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Shakeel Butt <shakeelb@google.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri 24-11-17 09:04:59, Minchan Kim wrote:
> Shakeel Butt reported, he have observed in production system that
> the job loader gets stuck for 10s of seconds while doing mount
> operation. It turns out that it was stuck in register_shrinker()
> and some unrelated job was under memory pressure and spending time
> in shrink_slab(). Machines have a lot of shrinkers registered and
> jobs under memory pressure has to traverse all of those memcg-aware
> shrinkers and do affect unrelated jobs which want to register their
> own shrinkers.
> 
> To solve the issue, this patch simply bails out slab shrinking
> once it found someone want to register shrinker in parallel.
> A downside is it could cause unfair shrinking between shrinkers.
> However, it should be rare and we can add compilcated logic once
> we found it's not enough.
> 
> Link: http://lkml.kernel.org/r/20171115005602.GB23810@bbox
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Reported-and-tested-by: Shakeel Butt <shakeelb@google.com>
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmscan.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 6a5a72baccd5..6698001787bd 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -486,6 +486,14 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  			sc.nid = 0;
>  
>  		freed += do_shrink_slab(&sc, shrinker, priority);
> +		/*
> +		 * bail out if someone want to register a new shrinker to
> +		 * prevent long time stall by parallel ongoing shrinking.
> +		 */
> +		if (rwsem_is_contended(&shrinker_rwsem)) {
> +			freed = freed ? : 1;
> +			break;
> +		}
>  	}
>  
>  	up_read(&shrinker_rwsem);
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
