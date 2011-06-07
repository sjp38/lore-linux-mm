Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4CE6E6B004A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 11:50:40 -0400 (EDT)
Received: by pwi12 with SMTP id 12so3486878pwi.14
        for <linux-mm@kvack.org>; Tue, 07 Jun 2011 08:50:36 -0700 (PDT)
Date: Wed, 8 Jun 2011 00:50:29 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 4/4] mm: compaction: Abort compaction if too many pages
 are isolated and caller is asynchronous
Message-ID: <20110607155029.GL1686@barrios-laptop>
References: <1307459225-4481-1-git-send-email-mgorman@suse.de>
 <1307459225-4481-5-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1307459225-4481-5-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Sattler <tsattler@gmx.de>, Ury Stankevich <urykhy@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, Jun 07, 2011 at 04:07:05PM +0100, Mel Gorman wrote:
> Asynchronous compaction is used when promoting to huge pages. This is
> all very nice but if there are a number of processes in compacting
> memory, a large number of pages can be isolated. An "asynchronous"
> process can stall for long periods of time as a result with a user
> reporting that firefox can stall for 10s of seconds. This patch aborts
> asynchronous compaction if too many pages are isolated as it's better to
> fail a hugepage promotion than stall a process.
> 
> Reported-and-tested-by: Ury Stankevich <urykhy@gmail.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/compaction.c |   28 +++++++++++++++++++++++-----
>  1 files changed, 23 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 5c744ab..cb28580 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -251,11 +251,18 @@ static bool too_many_isolated(struct zone *zone)
>  	return isolated > (inactive + active) / 2;
>  }
>  
> +/* possible outcome of isolate_migratepages */
> +typedef enum {
> +	ISOLATE_ABORT,		/* Abort compaction now */
> +	ISOLATE_NONE,		/* No pages isolated, continue scanning */
> +	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
> +} isolate_migrate_t;
> +
>  /*
>   * Isolate all pages that can be migrated from the block pointed to by
>   * the migrate scanner within compact_control.
>   */
> -static unsigned long isolate_migratepages(struct zone *zone,
> +static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  					struct compact_control *cc)
>  {
>  	unsigned long low_pfn, end_pfn;
> @@ -272,7 +279,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
>  	/* Do not cross the free scanner or scan within a memory hole */
>  	if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {
>  		cc->migrate_pfn = end_pfn;
> -		return 0;
> +		return ISOLATE_NONE;
>  	}
>  
>  	/*
> @@ -281,10 +288,14 @@ static unsigned long isolate_migratepages(struct zone *zone,
>  	 * delay for some time until fewer pages are isolated
>  	 */
>  	while (unlikely(too_many_isolated(zone))) {
> +		/* async migration should just abort */
> +		if (!cc->sync)
> +			return ISOLATE_ABORT;
> +
>  		congestion_wait(BLK_RW_ASYNC, HZ/10);
>  
>  		if (fatal_signal_pending(current))
> -			return 0;
> +			return ISOLATE_ABORT;
>  	}
>  
>  	/* Time to isolate some pages for migration */
> @@ -369,7 +380,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
>  
>  	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
>  
> -	return cc->nr_migratepages;
> +	return ISOLATE_SUCCESS;
>  }
>  
>  /*
> @@ -533,8 +544,14 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>  		unsigned long nr_migrate, nr_remaining;
>  		int err;
>  
> -		if (!isolate_migratepages(zone, cc))
> +		switch (isolate_migratepages(zone, cc)) {
> +		case ISOLATE_ABORT:

In this case, you change old behavior slightly.
In old case, we return COMPACT_PARTIAL to cancel migration.
But this patch makes to return COMPACT_SUCCESS.
At present, return value of compact_zone is only used by __alloc_pages_direct_compact
and it only consider COMPACT_SKIPPED so it would be not a problem.
But I think it would be better to return COMPACT_PARTIAL instead of COMPACT_CONTINUE
for consistency with compact_finished and right semantic for the future user of compact_zone.

-- 
Kind regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
