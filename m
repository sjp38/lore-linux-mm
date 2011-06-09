Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1D0406B00E8
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 10:03:11 -0400 (EDT)
Date: Thu, 9 Jun 2011 15:03:05 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v3 04/10] compaction: make isolate_lru_page with filter
 aware
Message-ID: <20110609140305.GW5247@suse.de>
References: <cover.1307455422.git.minchan.kim@gmail.com>
 <10ad16e14fdbe47ac36f7e55ae72ed59ae73ed0c.1307455422.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <10ad16e14fdbe47ac36f7e55ae72ed59ae73ed0c.1307455422.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, Jun 07, 2011 at 11:38:17PM +0900, Minchan Kim wrote:
> In async mode, compaction doesn't migrate dirty or writeback pages.
> So, it's meaningless to pick the page and re-add it to lru list.
> 
> Of course, when we isolate the page in compaction, the page might
> be dirty or writeback but when we try to migrate the page, the page
> would be not dirty, writeback. So it could be migrated. But it's
> very unlikely as isolate and migration cycle is much faster than
> writeout.
> 
> So, this patch helps cpu and prevent unnecessary LRU churning.
> 
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  mm/compaction.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index f0d75e9..8079346 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -243,6 +243,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
>  	unsigned long last_pageblock_nr = 0, pageblock_nr;
>  	unsigned long nr_scanned = 0, nr_isolated = 0;
>  	struct list_head *migratelist = &cc->migratepages;
> +	enum ISOLATE_MODE mode = ISOLATE_ACTIVE|ISOLATE_INACTIVE;
>  
>  	/* Do not scan outside zone boundaries */
>  	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
> @@ -326,9 +327,11 @@ static unsigned long isolate_migratepages(struct zone *zone,
>  			continue;
>  		}
>  
> +		if (!cc->sync)
> +			mode |= ISOLATE_CLEAN;
> + 
>  		/* Try isolate the page */
> -		if (__isolate_lru_page(page,
> -				ISOLATE_ACTIVE|ISOLATE_INACTIVE, 0) != 0)
> +		if (__isolate_lru_page(page, mode, 0) != 0)
>  			continue;
>  
>  		VM_BUG_ON(PageTransCompound(page));

Looks good for compaction! This change makes a lot of sense.

However I would expand the meaning of this patch. Introduce
ISOLATE_CLEAN in this patch and update both compaction and
__zone_reclaim. You might encounter some mess mapping RECLAIM_WRITE to
ISOLATE_CLEAN but nothing unmanageable.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
