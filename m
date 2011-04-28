Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 79EBC6B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 06:35:11 -0400 (EDT)
Date: Thu, 28 Apr 2011 11:35:05 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC 3/8] vmscan: make isolate_lru_page with filter aware
Message-ID: <20110428103505.GS4658@suse.de>
References: <cover.1303833415.git.minchan.kim@gmail.com>
 <232562452317897b5acb1445803410d74233a923.1303833417.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <232562452317897b5acb1445803410d74233a923.1303833417.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, Apr 27, 2011 at 01:25:20AM +0900, Minchan Kim wrote:
> In some __zone_reclaim case, we don't want to shrink mapped page.
> Nonetheless, we have isolated mapped page and re-add it into
> LRU's head. It's unnecessary CPU overhead and makes LRU churning.
> 
> Of course, when we isolate the page, the page might be mapped but
> when we try to migrate the page, the page would be not mapped.
> So it could be migrated. But race is rare and although it happens,
> it's no big deal.
> 
> Cc: Christoph Lameter <cl@linux.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

> index 71d2da9..e8d6190 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1147,7 +1147,8 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  
>  static unsigned long isolate_pages_global(unsigned long nr,
>  					struct list_head *dst,
> -					unsigned long *scanned, int order,
> +					unsigned long *scanned,
> +					struct scan_control *sc,
>  					int mode, struct zone *z,
>  					int active, int file)
>  {
> @@ -1156,8 +1157,8 @@ static unsigned long isolate_pages_global(unsigned long nr,
>  		lru += LRU_ACTIVE;
>  	if (file)
>  		lru += LRU_FILE;
> -	return isolate_lru_pages(nr, &z->lru[lru].list, dst, scanned, order,
> -					mode, file, 0, 0);
> +	return isolate_lru_pages(nr, &z->lru[lru].list, dst, scanned, sc->order,
> +					mode, file, 0, !sc->may_unmap);
>  }
>  

Why not take may_writepage into account for dirty pages?

>  /*
> @@ -1407,7 +1408,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
>  
>  	if (scanning_global_lru(sc)) {
>  		nr_taken = isolate_pages_global(nr_to_scan,
> -			&page_list, &nr_scanned, sc->order,
> +			&page_list, &nr_scanned, sc,
>  			sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
>  					ISOLATE_BOTH : ISOLATE_INACTIVE,
>  			zone, 0, file);
> @@ -1531,7 +1532,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  	spin_lock_irq(&zone->lru_lock);
>  	if (scanning_global_lru(sc)) {
>  		nr_taken = isolate_pages_global(nr_pages, &l_hold,
> -						&pgscanned, sc->order,
> +						&pgscanned, sc,
>  						ISOLATE_ACTIVE, zone,
>  						1, file);
>  		zone->pages_scanned += pgscanned;
> -- 
> 1.7.1
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
