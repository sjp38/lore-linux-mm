Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3E16B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 05:29:14 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 33so111992708lfw.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 02:29:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fd4si13985781wjb.204.2016.07.25.02.29.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jul 2016 02:29:13 -0700 (PDT)
Date: Mon, 25 Jul 2016 10:29:09 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC] mm: bail out in shrin_inactive_list
Message-ID: <20160725092909.GV11400@suse.de>
References: <1469433119-1543-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1469433119-1543-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

There is a typo in the subject line.

On Mon, Jul 25, 2016 at 04:51:59PM +0900, Minchan Kim wrote:
> With node-lru, if there are enough reclaimable pages in highmem
> but nothing in lowmem, VM can try to shrink inactive list although
> the requested zone is lowmem.
> 
> The problem is direct reclaimer scans inactive list is fulled with


> highmem pages to find a victim page at a reqested zone or lower zones
> but the result is that VM should skip all of pages. 

Rephease -- The problem is that if the inactive list is full of highmem
pages then a direct reclaimer searching for a lowmem page waste CPU
scanning uselessly.

> CPU. Even, many direct reclaimers are stalled by too_many_isolated
> if lots of parallel reclaimer are going on although there are no
> reclaimable memory in inactive list.
> 
> I tried the experiment 4 times in 32bit 2G 8 CPU KVM machine
> to get elapsed time.
> 
> 	hackbench 500 process 2
> 
> = Old =
> 
> 1st: 289s 2nd: 310s 3rd: 112s 4th: 272s
> 
> = Now =
> 
> 1st: 31s  2nd: 132s 3rd: 162s 4th: 50s.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
> I believe proper fix is to modify get_scan_count. IOW, I think
> we should introduce lruvec_reclaimable_lru_size with proper
> classzone_idx but I don't know how we can fix it with memcg
> which doesn't have zone stat now. should introduce zone stat
> back to memcg? Or, it's okay to ignore memcg?
> 

I think it's ok to ignore memcg in this case as a memcg shrink is often
going to be for pages that can use highmem anyway.

>  mm/vmscan.c | 28 ++++++++++++++++++++++++++++
>  1 file changed, 28 insertions(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index e5af357..3d285cc 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1652,6 +1652,31 @@ static int current_may_throttle(void)
>  		bdi_write_congested(current->backing_dev_info);
>  }
>  
> +static inline bool inactive_reclaimable_pages(struct lruvec *lruvec,
> +				struct scan_control *sc,
> +				enum lru_list lru)

inline is unnecessary. The function is long but only has one caller so
it'll be inlined automatically.

> +{
> +	int zid;
> +	struct zone *zone;
> +	bool file = is_file_lru(lru);

It's more appropriate to use int for file in this case as it's used as a
multiplier. It'll work either way.

Otherwise;

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
