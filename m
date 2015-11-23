Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 35B096B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 07:15:23 -0500 (EST)
Received: by wmuu63 with SMTP id u63so51360334wmu.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:15:22 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id p9si10711545wjw.8.2015.11.23.04.15.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 04:15:21 -0800 (PST)
Received: by wmec201 with SMTP id c201so157506378wme.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:15:21 -0800 (PST)
Date: Mon, 23 Nov 2015 13:15:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] vmscan: do not force-scan file lru if its absolute
 size is small
Message-ID: <20151123121509.GI21050@dhcp22.suse.cz>
References: <20151120134311.8ff0947215fc522f72f791fe@linux-foundation.org>
 <1448275173-10538-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448275173-10538-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 23-11-15 13:39:33, Vladimir Davydov wrote:
> We assume there is enough inactive page cache if the size of inactive
> file lru is greater than the size of active file lru, in which case we
> force-scan file lru ignoring anonymous pages. While this logic works
> fine when there are plenty of page cache pages, it fails if the size of
> file lru is small (several MB): in this case (lru_size >> prio) will be
> 0 for normal scan priorities, as a result, if inactive file lru happens
> to be larger than active file lru, anonymous pages of a cgroup will
> never get evicted unless the system experiences severe memory pressure,
> even if there are gigabytes of unused anonymous memory there, which is
> unfair in respect to other cgroups, whose workloads might be page cache
> oriented.
> 
> This patch attempts to fix this by elaborating the "enough inactive page
> cache" check: it makes it not only check that inactive lru size > active
> lru size, but also that we will scan something from the cgroup at the
> current scan priority. If these conditions do not hold, we proceed to
> SCAN_FRACT as usual.

Yes this makes sense. FWIW I have a similar patch waiting for feedback
from testing which catches the other extreme case when we force anon
pages scan without any progress from the kswapd context (I hope I get to
post it soon).

get_scan_count is getting more and more convoluted :/

> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
> Changes in v2:
>  - remove unnecessary > 0 (Johannes)
>  - elaborate on the comment (Andrew)
> 
>  mm/vmscan.c | 12 +++++++++---
>  1 file changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index bd2918e6391a..97ba9e1cde09 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2043,10 +2043,16 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
>  	}
>  
>  	/*
> -	 * There is enough inactive page cache, do not reclaim
> -	 * anything from the anonymous working set right now.
> +	 * If there is enough inactive page cache, i.e. if the size of the
> +	 * inactive list is greater than that of the active list *and* the
> +	 * inactive list actually has some pages to scan on this priority, we
> +	 * do not reclaim anything from the anonymous working set right now.
> +	 * Without the second condition we could end up never scanning an
> +	 * lruvec even if it has plenty of old anonymous pages unless the
> +	 * system is under heavy pressure.
>  	 */
> -	if (!inactive_file_is_low(lruvec)) {
> +	if (!inactive_file_is_low(lruvec) &&
> +	    get_lru_size(lruvec, LRU_INACTIVE_FILE) >> sc->priority) {
>  		scan_balance = SCAN_FILE;
>  		goto out;
>  	}
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
