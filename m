Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id C2E416B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 04:31:30 -0500 (EST)
Date: Tue, 20 Dec 2011 09:31:25 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] consider swap space when we decide compaction goes or not
Message-ID: <20111220093125.GO3487@suse.de>
References: <1324363653-18220-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1324363653-18220-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Tue, Dec 20, 2011 at 03:47:33PM +0900, Minchan Kim wrote:
> It's pointless to go reclaiming when we have no swap space
> and lots of anon pages in inactive list.
> 
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Johannes Weiner <jweiner@redhat.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/vmscan.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 23256e8..cd5400c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2015,8 +2015,9 @@ static inline bool should_continue_reclaim(struct zone *zone,
>  	 * inactive lists are large enough, continue reclaiming
>  	 */
>  	pages_for_compaction = (2UL << sc->order);
> -	inactive_lru_pages = zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON) +
> -				zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);
> +	inactive_lru_pages = zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);
> +	if (nr_swap_pages > 0)
> +		inactive_lru_pages += zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON);
>  	if (sc->nr_reclaimed < pages_for_compaction &&
>  			inactive_lru_pages > pages_for_compaction)
>  		return true;

The changelog does not win a prize for detail but it makes sense.
Without this patch, it is possible when swap is disabled to continue
trying to reclaim when there are only anonymous page in the system
even though that will not make any progress.

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
