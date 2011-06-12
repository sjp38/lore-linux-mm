Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CBF026B0012
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 10:55:36 -0400 (EDT)
Date: Sun, 12 Jun 2011 16:55:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 05/10] vmscan: make isolate_lru_page with filter aware
Message-ID: <20110612145531.GD24323@tiehlicka.suse.cz>
References: <cover.1307455422.git.minchan.kim@gmail.com>
 <f101a50f11ffac79eff441c58eafbb5eceac0b47.1307455422.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f101a50f11ffac79eff441c58eafbb5eceac0b47.1307455422.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue 07-06-11 23:38:18, Minchan Kim wrote:
> In __zone_reclaim case, we don't want to shrink mapped page.
> Nonetheless, we have isolated mapped page and re-add it into
> LRU's head. It's unnecessary CPU overhead and makes LRU churning.
> 
> Of course, when we isolate the page, the page might be mapped but
> when we try to migrate the page, the page would be not mapped.
> So it could be migrated. But race is rare and although it happens,
> it's no big deal.

Same like with the previous patch. I think it would be better to
introduce ISOLATE_UNMAPPED here.

Other than that looks good to me
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> 
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  mm/vmscan.c |   17 +++++++++++++++--
>  1 files changed, 15 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 26aa627..c08911d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1408,6 +1408,12 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
>  		reclaim_mode |= ISOLATE_ACTIVE;
>  
>  	lru_add_drain();
> +
> +	if (!sc->may_unmap)
> +		reclaim_mode |= ISOLATE_UNMAPPED;
> +	if (!sc->may_writepage)
> +		reclaim_mode |= ISOLATE_CLEAN;
> +
>  	spin_lock_irq(&zone->lru_lock);
>  
>  	if (scanning_global_lru(sc)) {
> @@ -1525,19 +1531,26 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  	struct page *page;
>  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
>  	unsigned long nr_rotated = 0;
> +	enum ISOLATE_MODE reclaim_mode = ISOLATE_ACTIVE;
>  
>  	lru_add_drain();
> +
> +	if (!sc->may_unmap)
> +		reclaim_mode |= ISOLATE_UNMAPPED;
> +	if (!sc->may_writepage)
> +		reclaim_mode |= ISOLATE_CLEAN;
> +
>  	spin_lock_irq(&zone->lru_lock);
>  	if (scanning_global_lru(sc)) {
>  		nr_taken = isolate_pages_global(nr_pages, &l_hold,
>  						&pgscanned, sc->order,
> -						ISOLATE_ACTIVE, zone,
> +						reclaim_mode, zone,
>  						1, file);
>  		zone->pages_scanned += pgscanned;
>  	} else {
>  		nr_taken = mem_cgroup_isolate_pages(nr_pages, &l_hold,
>  						&pgscanned, sc->order,
> -						ISOLATE_ACTIVE, zone,
> +						reclaim_mode, zone,
>  						sc->mem_cgroup, 1, file);
>  		/*
>  		 * mem_cgroup_isolate_pages() keeps track of
> -- 
> 1.7.0.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
