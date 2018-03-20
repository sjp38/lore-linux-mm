Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A9E466B0003
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 11:11:19 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 139so1115960pfw.7
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 08:11:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m11-v6si1850070pla.724.2018.03.20.08.11.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Mar 2018 08:11:18 -0700 (PDT)
Date: Tue, 20 Mar 2018 16:11:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/6] mm/vmscan: remove redundant current_may_throttle()
 check
Message-ID: <20180320151115.GY23100@dhcp22.suse.cz>
References: <20180315164553.17856-1-aryabinin@virtuozzo.com>
 <20180315164553.17856-4-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180315164553.17856-4-aryabinin@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Thu 15-03-18 19:45:51, Andrey Ryabinin wrote:
> Only kswapd can have non-zero nr_immediate, and current_may_throttle() is
> always true for kswapd (PF_LESS_THROTTLE bit is never set) thus it's
> enough to check stat.nr_immediate only.

OK, so this is a result of some code evolution. We used to check for
dirty pages as well. But then b738d764652d ("Don't trigger congestion
wait on dirty-but-not-writeout pages") removed the nr_unqueued_dirty ==
nr_taken part. I was wondering whether we still have the
PF_LESS_THROTTLE protection in place but then noticed that we still have
	if (!sc->hibernation_mode && !current_is_kswapd() &&
	    current_may_throttle())
		wait_iff_congested(pgdat, BLK_RW_ASYNC, HZ/10);

in place, so good.

> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmscan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 0d5ab312a7f4..a8f6e4882e00 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1806,7 +1806,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  		 * that pages are cycling through the LRU faster than
>  		 * they are written so also forcibly stall.
>  		 */
> -		if (stat.nr_immediate && current_may_throttle())
> +		if (stat.nr_immediate)
>  			congestion_wait(BLK_RW_ASYNC, HZ/10);
>  	}
>  
> -- 
> 2.16.1

-- 
Michal Hocko
SUSE Labs
