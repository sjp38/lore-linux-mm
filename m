Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id C1AA982F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 01:49:12 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so63637359pad.1
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 22:49:12 -0700 (PDT)
Received: from mgwym02.jp.fujitsu.com (mgwym02.jp.fujitsu.com. [211.128.242.41])
        by mx.google.com with ESMTPS id yj10si8162290pab.237.2015.10.29.22.49.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Oct 2015 22:49:06 -0700 (PDT)
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by yt-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 446CBAC0271
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 14:48:58 +0900 (JST)
Subject: Re: [RFC 2/3] mm: throttle on IO only when there are too many dirty
 and writeback pages
References: <1446131835-3263-1-git-send-email-mhocko@kernel.org>
 <1446131835-3263-3-git-send-email-mhocko@kernel.org>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <563304B8.6040703@jp.fujitsu.com>
Date: Fri, 30 Oct 2015 14:48:40 +0900
MIME-Version: 1.0
In-Reply-To: <1446131835-3263-3-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 2015/10/30 0:17, mhocko@kernel.org wrote:
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
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>   mm/page_alloc.c | 19 +++++++++++++++++--
>   1 file changed, 17 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9c0abb75ad53..0518ca6a9776 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3191,8 +3191,23 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>   		 */
>   		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
>   				ac->high_zoneidx, alloc_flags, target)) {
> -			/* Wait for some write requests to complete then retry */
> -			wait_iff_congested(zone, BLK_RW_ASYNC, HZ/50);
> +			unsigned long writeback = zone_page_state(zone, NR_WRITEBACK),
> +				      dirty = zone_page_state(zone, NR_FILE_DIRTY);
> +
> +			if (did_some_progress)
> +				goto retry;
> +
> +			/*
> +			 * If we didn't make any progress and have a lot of
> +			 * dirty + writeback pages then we should wait for
> +			 * an IO to complete to slow down the reclaim and
> +			 * prevent from pre mature OOM
> +			 */
> +			if (2*(writeback + dirty) > reclaimable)

Doesn't this add unnecessary latency if other zones have enough clean memory ?


Thanks,
-Kame
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
