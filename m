Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 949B76B0036
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 13:07:08 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so1616234eek.20
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 10:07:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id x47si4120991eel.193.2014.03.14.10.07.06
        for <linux-mm@kvack.org>;
        Fri, 14 Mar 2014 10:07:07 -0700 (PDT)
Date: Fri, 14 Mar 2014 14:06:55 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [patch] mm: vmscan: do not swap anon pages just because
 free+file is low
Message-ID: <20140314170654.GA13596@localhost.localdomain>
References: <1394811302-30468-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1394811302-30468-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 14, 2014 at 11:35:02AM -0400, Johannes Weiner wrote:
> Page reclaim force-scans / swaps anonymous pages when file cache drops
> below the high watermark of a zone in order to prevent what little
> cache remains from thrashing.
> 
> However, on bigger machines the high watermark value can be quite
> large and when the workload is dominated by a static anonymous/shmem
> set, the file set might just be a small window of used-once cache.  In
> such situations, the VM starts swapping heavily when instead it should
> be recycling the no longer used cache.
> 
> This is a longer-standing problem, but it's more likely to trigger
> after 81c0a2bb515f ("mm: page_alloc: fair zone allocator policy")
> because file pages can no longer accumulate in a single zone and are
> dispersed into smaller fractions among the available zones.
> 
> To resolve this, do not force scan anon when file pages are low but
> instead rely on the scan/rotation ratios to make the right prediction.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: <stable@kernel.org> [3.12+]
> ---

Acked-by: Rafael Aquini <aquini@redhat.com>

>  mm/vmscan.c | 16 +---------------
>  1 file changed, 1 insertion(+), 15 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a9c74b409681..e58e9ad5b5d1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1848,7 +1848,7 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>  	struct zone *zone = lruvec_zone(lruvec);
>  	unsigned long anon_prio, file_prio;
>  	enum scan_balance scan_balance;
> -	unsigned long anon, file, free;
> +	unsigned long anon, file;
>  	bool force_scan = false;
>  	unsigned long ap, fp;
>  	enum lru_list lru;
> @@ -1902,20 +1902,6 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>  		get_lru_size(lruvec, LRU_INACTIVE_FILE);
>  
>  	/*
> -	 * If it's foreseeable that reclaiming the file cache won't be
> -	 * enough to get the zone back into a desirable shape, we have
> -	 * to swap.  Better start now and leave the - probably heavily
> -	 * thrashing - remaining file pages alone.
> -	 */
> -	if (global_reclaim(sc)) {
> -		free = zone_page_state(zone, NR_FREE_PAGES);
> -		if (unlikely(file + free <= high_wmark_pages(zone))) {
> -			scan_balance = SCAN_ANON;
> -			goto out;
> -		}
> -	}
> -
> -	/*
>  	 * There is enough inactive page cache, do not reclaim
>  	 * anything from the anonymous working set right now.
>  	 */
> -- 
> 1.9.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
