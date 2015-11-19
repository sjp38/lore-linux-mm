Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id BB48E6B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 18:12:42 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so95303175pac.3
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 15:12:42 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id go6si15081469pbc.166.2015.11.19.15.12.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 15:12:41 -0800 (PST)
Received: by pacej9 with SMTP id ej9so95233592pac.2
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 15:12:41 -0800 (PST)
Date: Thu, 19 Nov 2015 15:12:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 2/3] mm: throttle on IO only when there are too many dirty
 and writeback pages
In-Reply-To: <1447851840-15640-3-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1511191507030.17510@chino.kir.corp.google.com>
References: <1447851840-15640-1-git-send-email-mhocko@kernel.org> <1447851840-15640-3-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.com>

On Wed, 18 Nov 2015, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> wait_iff_congested has been used to throttle allocator before it retried
> another round of direct reclaim to allow the writeback to make some
> progress and prevent reclaim from looping over dirty/writeback pages
> without making any progress. We used to do congestion_wait before
> 0e093d99763e ("writeback: do not sleep on the congestion queue if
> there are no congested BDIs or if significant congestion is not being
> encountered in the current zone") but that led to undesirable stalls
> and sleeping for the full timeout even when the BDI wasn't congested.
> Hence wait_iff_congested was used instead. But it seems that even
> wait_iff_congested doesn't work as expected. We might have a small file
> LRU list with all pages dirty/writeback and yet the bdi is not congested
> so this is just a cond_resched in the end and can end up triggering pre
> mature OOM.
> 
> This patch replaces the unconditional wait_iff_congested by
> congestion_wait which is executed only if we _know_ that the last round
> of direct reclaim didn't make any progress and dirty+writeback pages are
> more than a half of the reclaimable pages on the zone which might be
> usable for our target allocation. This shouldn't reintroduce stalls
> fixed by 0e093d99763e because congestion_wait is called only when we
> are getting hopeless when sleeping is a better choice than OOM with many
> pages under IO.
> 

Why HZ/10 instead of HZ/50?

> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/page_alloc.c | 16 ++++++++++++++--
>  1 file changed, 14 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 020c005c5bc0..e6271bc19e6a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3212,8 +3212,20 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		 */
>  		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
>  				ac->high_zoneidx, alloc_flags, target)) {
> -			/* Wait for some write requests to complete then retry */
> -			wait_iff_congested(zone, BLK_RW_ASYNC, HZ/50);
> +			unsigned long writeback = zone_page_state(zone, NR_WRITEBACK),
> +				      dirty = zone_page_state(zone, NR_FILE_DIRTY);
> +
> +			/*
> +			 * If we didn't make any progress and have a lot of
> +			 * dirty + writeback pages then we should wait for
> +			 * an IO to complete to slow down the reclaim and
> +			 * prevent from pre mature OOM
> +			 */
> +			if (!did_some_progress && 2*(writeback + dirty) > reclaimable)
> +				congestion_wait(BLK_RW_ASYNC, HZ/10);

The purpose of the heuristic seems logical, but I'm concerned about the 
threshold for determining when to wait and when to just resched and retry 
again.

This triggers for environments without swap when

2 * (NR_WRITEBACK + NR_DIRTY) > (NR_ACTIVE_FILE + NR_INACTIVE_FILE +
				 NR_ISOLATED_FILE + NR_ISOLATED_ANON)

 [ The use of NR_ISOLATED_ANON in swapless is asked about in patch 1. ]

How exactly was this chosen?  Why not when the two sides equal each other?

> +			else
> +				cond_resched();
> +
>  			goto retry;
>  		}
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
