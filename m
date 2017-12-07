Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3CF366B0038
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 04:52:35 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a10so4813773pgq.3
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 01:52:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f19sor1819306plj.59.2017.12.07.01.52.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 01:52:28 -0800 (PST)
Date: Thu, 7 Dec 2017 18:52:23 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm: terminate shrink_slab loop if signal is pending
Message-ID: <20171207095223.GB574@jagdpanzerIV>
References: <20171206192026.25133-1-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171206192026.25133-1-surenb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, timmurray@google.com, tkjos@google.com

On (12/06/17 11:20), Suren Baghdasaryan wrote:
> Slab shrinkers can be quite time consuming and when signal
> is pending they can delay handling of the signal. If fatal
> signal is pending there is no point in shrinking that process
> since it will be killed anyway. This change checks for pending
> fatal signals inside shrink_slab loop and if one is detected
> terminates this loop early.
> 
> Signed-off-by: Suren Baghdasaryan <surenb@google.com>
> ---
>  mm/vmscan.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c02c850ea349..69296528ff33 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -486,6 +486,13 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  			.memcg = memcg,
>  		};
>  
> +		/*
> +		 * We are about to die and free our memory.
> +		 * Stop shrinking which might delay signal handling.
> +		 */
> +		if (unlikely(fatal_signal_pending(current))

-               if (unlikely(fatal_signal_pending(current))
+               if (unlikely(fatal_signal_pending(current)))

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
