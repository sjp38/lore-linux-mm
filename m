Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 391836B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 02:08:07 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so6073055pab.3
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 23:08:07 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id gq6si1486853pac.114.2015.06.15.23.08.05
        for <linux-mm@kvack.org>;
        Mon, 15 Jun 2015 23:08:06 -0700 (PDT)
Date: Tue, 16 Jun 2015 15:10:13 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 6/6] mm, compaction: decouple updating pageblock_skip and
 cached pfn
Message-ID: <20150616061013.GF12641@js1304-P5Q-DELUXE>
References: <1433928754-966-1-git-send-email-vbabka@suse.cz>
 <1433928754-966-7-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433928754-966-7-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Wed, Jun 10, 2015 at 11:32:34AM +0200, Vlastimil Babka wrote:
> The pageblock_skip bitmap and cached scanner pfn's are two mechanisms in
> compaction to prevent rescanning pages where isolation has recently failed
> or they were scanned during the previous compaction attempt.
> 
> Currently, both kinds of information are updated via update_pageblock_skip(),
> which is suboptimal for the cached scanner pfn's:
> 
> - The condition "isolation has failed in the pageblock" checked by
>   update_pageblock_skip() may be valid for the pageblock_skip bitmap, but makes
>   less sense for cached pfn's. There's little point for the next compaction
>   attempt to scan again a pageblock where all pages that could be isolated were
>   already processed.

In async compaction, compaction could be stopped due to cc->contended
in freepage scanner so sometimes isolated pages were not migrated. Your
change makes next async compaction skip these pages. This possibly causes
compaction complete prematurely by async compaction.

And, rescan previous attempted range could solve some race problem.
If allocated page waits to set PageLRU in pagevec, compaction will
pass it. If we try rescan after short time, page will have PageLRU and
compaction can isolate and migrate it and make high order freepage. This
requires some rescanning overhead but migration overhead which is more bigger
than scanning overhead is just a little. If compaction pass it like as
this change, pages on this area would be allocated for other requestor, and,
when compaction revisit, there would be more page to migrate.

I basically agree with this change because it is more intuitive. But,
I'd like to see some improvement result or test this patch myself before merging
it.

Thanks.

> 
> - whole pageblocks can be skipped at the level of isolate_migratepages() or
>   isolate_freepages() before going into the corresponding _block() function.
>   Not updating cached scanner positions at the higher level may again result
>   in extra iterations.
> 
> This patch moves updating cached scanner pfn's from update_pageblock_skip()
> to dedicated functions, which are called directly from isolate_migratepages()
> and isolate_freepages(), resolving both inefficiencies.
> 
> During testing, the observed differences in compact_migrate_scanned and
> compact_free_scanned were lost in the noise.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> ---
>  mm/compaction.c | 48 +++++++++++++++++++++++++-----------------------
>  1 file changed, 25 insertions(+), 23 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 4a14084..c326607 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -261,17 +261,31 @@ void reset_isolation_suitable(pg_data_t *pgdat)
>  	}
>  }
>  
> +static inline void
> +update_cached_migrate_pfn(struct zone *zone, unsigned long pfn,
> +						enum migrate_mode mode)
> +{
> +	if (pfn > zone->compact_cached_migrate_pfn[0])
> +		zone->compact_cached_migrate_pfn[0] = pfn;
> +	if (mode != MIGRATE_ASYNC &&
> +	    pfn > zone->compact_cached_migrate_pfn[1])
> +		zone->compact_cached_migrate_pfn[1] = pfn;
> +}
> +
> +static inline void
> +update_cached_free_pfn(struct zone *zone, unsigned long pfn)
> +{
> +	if (pfn < zone->compact_cached_free_pfn)
> +		zone->compact_cached_free_pfn = pfn;
> +}
> +
>  /*
>   * If no pages were isolated then mark this pageblock to be skipped in the
>   * future. The information is later cleared by __reset_isolation_suitable().
>   */
>  static void update_pageblock_skip(struct compact_control *cc,
> -			struct page *page, unsigned long nr_isolated,
> -			bool migrate_scanner)
> +			struct page *page, unsigned long nr_isolated)
>  {
> -	struct zone *zone = cc->zone;
> -	unsigned long pfn;
> -
>  	if (cc->ignore_skip_hint)
>  		return;
>  
> @@ -282,20 +296,6 @@ static void update_pageblock_skip(struct compact_control *cc,
>  		return;
>  
>  	set_pageblock_skip(page);
> -
> -	pfn = page_to_pfn(page);
> -
> -	/* Update where async and sync compaction should restart */
> -	if (migrate_scanner) {
> -		if (pfn > zone->compact_cached_migrate_pfn[0])
> -			zone->compact_cached_migrate_pfn[0] = pfn;
> -		if (cc->mode != MIGRATE_ASYNC &&
> -		    pfn > zone->compact_cached_migrate_pfn[1])
> -			zone->compact_cached_migrate_pfn[1] = pfn;
> -	} else {
> -		if (pfn < zone->compact_cached_free_pfn)
> -			zone->compact_cached_free_pfn = pfn;
> -	}
>  }
>  #else
>  static inline bool isolation_suitable(struct compact_control *cc,
> @@ -305,8 +305,7 @@ static inline bool isolation_suitable(struct compact_control *cc,
>  }
>  
>  static void update_pageblock_skip(struct compact_control *cc,
> -			struct page *page, unsigned long nr_isolated,
> -			bool migrate_scanner)
> +			struct page *page, unsigned long nr_isolated)
>  {
>  }
>  #endif /* CONFIG_COMPACTION */
> @@ -540,7 +539,7 @@ isolate_fail:
>  
>  	/* Update the pageblock-skip if the whole pageblock was scanned */
>  	if (blockpfn == end_pfn)
> -		update_pageblock_skip(cc, valid_page, total_isolated, false);
> +		update_pageblock_skip(cc, valid_page, total_isolated);
>  
>  	count_compact_events(COMPACTFREE_SCANNED, nr_scanned);
>  	if (total_isolated)
> @@ -843,7 +842,7 @@ isolate_success:
>  	 * if the whole pageblock was scanned without isolating any page.
>  	 */
>  	if (low_pfn == end_pfn)
> -		update_pageblock_skip(cc, valid_page, nr_isolated, true);
> +		update_pageblock_skip(cc, valid_page, nr_isolated);
>  
>  	trace_mm_compaction_isolate_migratepages(start_pfn, low_pfn,
>  						nr_scanned, nr_isolated);
> @@ -1043,6 +1042,7 @@ static void isolate_freepages(struct compact_control *cc)
>  	 * and the loop terminated due to isolate_start_pfn < low_pfn
>  	 */
>  	cc->free_pfn = isolate_start_pfn;
> +	update_cached_free_pfn(zone, isolate_start_pfn);
>  }
>  
>  /*
> @@ -1177,6 +1177,8 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  	acct_isolated(zone, cc);
>  	/* Record where migration scanner will be restarted. */
>  	cc->migrate_pfn = low_pfn;
> +	update_cached_migrate_pfn(zone, low_pfn, cc->mode);
> +
>  
>  	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
>  }
> -- 
> 2.1.4
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
