Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2877C6B026E
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 08:21:51 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id kq3so39714341wjc.1
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 05:21:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w84si26525635wmg.121.2017.01.26.05.21.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 05:21:49 -0800 (PST)
Date: Thu, 26 Jan 2017 14:21:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/5] mm: vmscan: remove old flusher wakeup from direct
 reclaim path
Message-ID: <20170126132147.GC7827@dhcp22.suse.cz>
References: <20170123181641.23938-1-hannes@cmpxchg.org>
 <20170123181641.23938-4-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170123181641.23938-4-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon 23-01-17 13:16:39, Johannes Weiner wrote:
> Direct reclaim has been replaced by kswapd reclaim in pretty much all
> common memory pressure situations, so this code most likely doesn't
> accomplish the described effect anymore. The previous patch wakes up
> flushers for all reclaimers when we encounter dirty pages at the tail
> end of the LRU. Remove the crufty old direct reclaim invocation.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmscan.c | 17 -----------------
>  1 file changed, 17 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 56ea8d24041f..915fc658de41 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2757,8 +2757,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  					  struct scan_control *sc)
>  {
>  	int initial_priority = sc->priority;
> -	unsigned long total_scanned = 0;
> -	unsigned long writeback_threshold;
>  retry:
>  	delayacct_freepages_start();
>  
> @@ -2771,7 +2769,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		sc->nr_scanned = 0;
>  		shrink_zones(zonelist, sc);
>  
> -		total_scanned += sc->nr_scanned;
>  		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
>  			break;
>  
> @@ -2784,20 +2781,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		 */
>  		if (sc->priority < DEF_PRIORITY - 2)
>  			sc->may_writepage = 1;
> -
> -		/*
> -		 * Try to write back as many pages as we just scanned.  This
> -		 * tends to cause slow streaming writers to write data to the
> -		 * disk smoothly, at the dirtying rate, which is nice.   But
> -		 * that's undesirable in laptop mode, where we *want* lumpy
> -		 * writeout.  So in laptop mode, write out the whole world.
> -		 */
> -		writeback_threshold = sc->nr_to_reclaim + sc->nr_to_reclaim / 2;
> -		if (total_scanned > writeback_threshold) {
> -			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned,
> -						WB_REASON_VMSCAN);
> -			sc->may_writepage = 1;
> -		}
>  	} while (--sc->priority >= 0);
>  
>  	delayacct_freepages_end();
> -- 
> 2.11.0
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
