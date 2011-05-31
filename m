Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EF8C76B0011
	for <linux-mm@kvack.org>; Tue, 31 May 2011 09:46:14 -0400 (EDT)
Date: Tue, 31 May 2011 15:46:09 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 06/10] vmscan: make isolate_lru_page with filter aware
Message-ID: <20110531134609.GB4594@cmpxchg.org>
References: <cover.1306689214.git.minchan.kim@gmail.com>
 <48bcb7597cd5695f30381715630dc66a5d32c638.1306689214.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48bcb7597cd5695f30381715630dc66a5d32c638.1306689214.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Mon, May 30, 2011 at 03:13:45AM +0900, Minchan Kim wrote:
> In __zone_reclaim case, we don't want to shrink mapped page.
> Nonetheless, we have isolated mapped page and re-add it into
> LRU's head. It's unnecessary CPU overhead and makes LRU churning.
> 
> Of course, when we isolate the page, the page might be mapped but
> when we try to migrate the page, the page would be not mapped.
> So it could be migrated. But race is rare and although it happens,
> it's no big deal.
> 
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  mm/vmscan.c |   29 +++++++++++++++++++++--------
>  1 files changed, 21 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 9972356..39941c7 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1395,6 +1395,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
>  	unsigned long nr_taken;
>  	unsigned long nr_anon;
>  	unsigned long nr_file;
> +	enum ISOLATE_PAGE_MODE mode = ISOLATE_NONE;
>  
>  	while (unlikely(too_many_isolated(zone, file, sc))) {
>  		congestion_wait(BLK_RW_ASYNC, HZ/10);
> @@ -1406,13 +1407,20 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
>  
>  	set_reclaim_mode(priority, sc, false);
>  	lru_add_drain();
> +
> +	if (!sc->may_unmap)
> +		mode |= ISOLATE_UNMAPPED;
> +	if (!sc->may_writepage)
> +		mode |= ISOLATE_CLEAN;
> +	mode |= sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
> +				ISOLATE_BOTH : ISOLATE_INACTIVE;

Hmm, it would probably be cleaner to fully convert the isolation mode
into independent flags.  INACTIVE, ACTIVE, BOTH is currently a
tri-state among flags, which is a bit ugly.

	mode = ISOLATE_INACTIVE;
	if (!sc->may_unmap)
		mode |= ISOLATE_UNMAPPED;
	if (!sc->may_writepage)
		mode |= ISOLATE_CLEAN;
	if (sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM)
		mode |= ISOLATE_ACTIVE;

What do you think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
