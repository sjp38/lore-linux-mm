Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8C68B6B0032
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 04:12:41 -0500 (EST)
Received: by mail-we0-f171.google.com with SMTP id u56so7471950wes.30
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 01:12:41 -0800 (PST)
Received: from mail-we0-x22a.google.com (mail-we0-x22a.google.com. [2a00:1450:400c:c03::22a])
        by mx.google.com with ESMTPS id bj2si102686732wjb.96.2015.01.05.01.12.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 Jan 2015 01:12:40 -0800 (PST)
Received: by mail-we0-f170.google.com with SMTP id w61so7517504wes.29
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 01:12:40 -0800 (PST)
Date: Mon, 5 Jan 2015 10:12:38 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V3 1/2] mm, vmscan: prevent kswapd livelock due to
 pfmemalloc-throttled process being killed
Message-ID: <20150105091238.GA7687@dhcp22.suse.cz>
References: <1420448203-30212-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420448203-30212-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@parallels.com>, stable@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Mon 05-01-15 09:56:42, Vlastimil Babka wrote:
> Charles Shirron and Paul Cassella from Cray Inc have reported kswapd stuck
> in a busy loop with nothing left to balance, but kswapd_try_to_sleep() failing
> to sleep. Their analysis found the cause to be a combination of several
> factors:
> 
> 1. A process is waiting in throttle_direct_reclaim() on pgdat->pfmemalloc_wait
> 
> 2. The process has been killed (by OOM in this case), but has not yet been
>    scheduled to remove itself from the waitqueue and die.
> 
> 3. kswapd checks for throttled processes in prepare_kswapd_sleep():
> 
>         if (waitqueue_active(&pgdat->pfmemalloc_wait)) {
>                 wake_up(&pgdat->pfmemalloc_wait);
> 		return false; // kswapd will not go to sleep
> 	}
> 
>    However, for a process that was already killed, wake_up() does not remove
>    the process from the waitqueue, since try_to_wake_up() checks its state
>    first and returns false when the process is no longer waiting.
> 
> 4. kswapd is running on the same CPU as the only CPU that the process is
>    allowed to run on (through cpus_allowed, or possibly single-cpu system).
> 
> 5. CONFIG_PREEMPT_NONE=y kernel is used. If there's nothing to balance, kswapd
>    encounters no voluntary preemption points and repeatedly fails
>    prepare_kswapd_sleep(), blocking the process from running and removing
>    itself from the waitqueue, which would let kswapd sleep.
> 
> So, the source of the problem is that we prevent kswapd from going to sleep
> until there are processes waiting on the pfmemalloc_wait queue, and a process
> waiting on a queue is guaranteed to be removed from the queue only when it
> gets scheduled. This was done to make sure that no process is left sleeping
> on pfmemalloc_wait when kswapd itself goes to sleep.
> 
> However, it isn't necessary to postpone kswapd sleep until the pfmemalloc_wait
> queue actually empties. To prevent processes from being left sleeping, it's
> actually enough to guarantee that all processes waiting on pfmemalloc_wait
> queue have been woken up by the time we put kswapd to sleep.
> 
> This patch therefore fixes this issue by substituting 'wake_up' with
> 'wake_up_all' and removing 'return false' in the code snippet from
> prepare_kswapd_sleep() above. Note that if any process puts itself in the
> queue after this waitqueue_active() check, or after the wake up itself, it
> means that the process will also wake up kswapd - and since we are under
> prepare_to_wait(), the wake up won't be missed. Also we update the comment
> prepare_kswapd_sleep() to hopefully more clearly describe the races it is
> preventing.
> 
> Fixes: 5515061d22f0 ("mm: throttle direct reclaimers if PF_MEMALLOC reserves
>                       are low and swap is backed by network storage")
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: <stable@vger.kernel.org>   # v3.6+
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Rik van Riel <riel@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> ---
> Changes in v3 (v2 was sent by Vladimir Davydov, thanks for his new solution):
> 
> - split to two patches again, as I (and Michal Hocko) think it's more correct
> - some rewording in changelog
> - change the code comment again as in v1 with small updates (v2 dropped this
>   part), since it has been clearly a source of confusion so far
> 
>  mm/vmscan.c | 24 +++++++++++++-----------
>  1 file changed, 13 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index bd9a72b..ab2505c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2921,18 +2921,20 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
>  		return false;
>  
>  	/*
> -	 * There is a potential race between when kswapd checks its watermarks
> -	 * and a process gets throttled. There is also a potential race if
> -	 * processes get throttled, kswapd wakes, a large process exits therby
> -	 * balancing the zones that causes kswapd to miss a wakeup. If kswapd
> -	 * is going to sleep, no process should be sleeping on pfmemalloc_wait
> -	 * so wake them now if necessary. If necessary, processes will wake
> -	 * kswapd and get throttled again
> +	 * The throttled processes are normally woken up in balance_pgdat() as
> +	 * soon as pfmemalloc_watermark_ok() is true. But there is a potential
> +	 * race between when kswapd checks the watermarks and a process gets
> +	 * throttled. There is also a potential race if processes get
> +	 * throttled, kswapd wakes, a large process exits thereby balancing the
> +	 * zones, which causes kswapd to exit balance_pgdat() before reaching
> +	 * the wake up checks. If kswapd is going to sleep, no process should
> +	 * be sleeping on pfmemalloc_wait, so wake them now if necessary. If
> +	 * the wake up is premature, processes will wake kswapd and get
> +	 * throttled again. The difference from wake ups in balance_pgdat() is
> +	 * that here we are under prepare_to_wait().
>  	 */
> -	if (waitqueue_active(&pgdat->pfmemalloc_wait)) {
> -		wake_up(&pgdat->pfmemalloc_wait);
> -		return false;
> -	}
> +	if (waitqueue_active(&pgdat->pfmemalloc_wait))
> +		wake_up_all(&pgdat->pfmemalloc_wait);
>  
>  	return pgdat_balanced(pgdat, order, classzone_idx);
>  }
> -- 
> 2.1.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
