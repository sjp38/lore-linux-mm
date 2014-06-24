Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id D6D666B006E
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 15:09:20 -0400 (EDT)
Received: by mail-qa0-f51.google.com with SMTP id j7so634760qaq.38
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 12:09:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p95si1571583qgd.71.2014.06.24.12.09.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jun 2014 12:09:20 -0700 (PDT)
Date: Tue, 24 Jun 2014 15:09:02 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 08/13] mm, compaction: remember position within
 pageblock in free pages scanner
Message-ID: <20140624190902.GB11945@nhori.redhat.com>
References: <1403279383-5862-1-git-send-email-vbabka@suse.cz>
 <1403279383-5862-9-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403279383-5862-9-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-kernel@vger.kernel.org

On Fri, Jun 20, 2014 at 05:49:38PM +0200, Vlastimil Babka wrote:
> Unlike the migration scanner, the free scanner remembers the beginning of the
> last scanned pageblock in cc->free_pfn. It might be therefore rescanning pages
> uselessly when called several times during single compaction. This might have
> been useful when pages were returned to the buddy allocator after a failed
> migration, but this is no longer the case.
> 
> This patch changes the meaning of cc->free_pfn so that if it points to a
> middle of a pageblock, that pageblock is scanned only from cc->free_pfn to the
> end. isolate_freepages_block() will record the pfn of the last page it looked
> at, which is then used to update cc->free_pfn.
> 
> In the mmtests stress-highalloc benchmark, this has resulted in lowering the
> ratio between pages scanned by both scanners, from 2.5 free pages per migrate
> page, to 2.25 free pages per migrate page, without affecting success rates.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: David Rientjes <rientjes@google.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/compaction.c | 40 +++++++++++++++++++++++++++++++---------
>  1 file changed, 31 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 9f6e857..41c7005 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -287,7 +287,7 @@ static bool suitable_migration_target(struct page *page)
>   * (even though it may still end up isolating some pages).
>   */
>  static unsigned long isolate_freepages_block(struct compact_control *cc,
> -				unsigned long blockpfn,
> +				unsigned long *start_pfn,
>  				unsigned long end_pfn,
>  				struct list_head *freelist,
>  				bool strict)
> @@ -296,6 +296,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>  	struct page *cursor, *valid_page = NULL;
>  	unsigned long flags;
>  	bool locked = false;
> +	unsigned long blockpfn = *start_pfn;
>  
>  	cursor = pfn_to_page(blockpfn);
>  
> @@ -369,6 +370,9 @@ isolate_fail:
>  			break;
>  	}
>  
> +	/* Record how far we have got within the block */
> +	*start_pfn = blockpfn;
> +
>  	trace_mm_compaction_isolate_freepages(nr_scanned, total_isolated);
>  
>  	/*
> @@ -413,6 +417,9 @@ isolate_freepages_range(struct compact_control *cc,
>  	LIST_HEAD(freelist);
>  
>  	for (pfn = start_pfn; pfn < end_pfn; pfn += isolated) {
> +		/* Protect pfn from changing by isolate_freepages_block */
> +		unsigned long isolate_start_pfn = pfn;
> +
>  		if (!pfn_valid(pfn) || cc->zone != page_zone(pfn_to_page(pfn)))
>  			break;
>  
> @@ -423,8 +430,8 @@ isolate_freepages_range(struct compact_control *cc,
>  		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
>  		block_end_pfn = min(block_end_pfn, end_pfn);
>  
> -		isolated = isolate_freepages_block(cc, pfn, block_end_pfn,
> -						   &freelist, true);
> +		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
> +						block_end_pfn, &freelist, true);
>  
>  		/*
>  		 * In strict mode, isolate_freepages_block() returns 0 if
> @@ -708,6 +715,7 @@ static void isolate_freepages(struct zone *zone,
>  {
>  	struct page *page;
>  	unsigned long block_start_pfn;	/* start of current pageblock */
> +	unsigned long isolate_start_pfn; /* exact pfn we start at */
>  	unsigned long block_end_pfn;	/* end of current pageblock */
>  	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
>  	int nr_freepages = cc->nr_freepages;
> @@ -716,14 +724,15 @@ static void isolate_freepages(struct zone *zone,
>  	/*
>  	 * Initialise the free scanner. The starting point is where we last
>  	 * successfully isolated from, zone-cached value, or the end of the
> -	 * zone when isolating for the first time. We need this aligned to
> -	 * the pageblock boundary, because we do
> +	 * zone when isolating for the first time. For looping we also need
> +	 * this pfn aligned down to the pageblock boundary, because we do
>  	 * block_start_pfn -= pageblock_nr_pages in the for loop.
>  	 * For ending point, take care when isolating in last pageblock of a
>  	 * a zone which ends in the middle of a pageblock.
>  	 * The low boundary is the end of the pageblock the migration scanner
>  	 * is using.
>  	 */
> +	isolate_start_pfn = cc->free_pfn;
>  	block_start_pfn = cc->free_pfn & ~(pageblock_nr_pages-1);
>  	block_end_pfn = min(block_start_pfn + pageblock_nr_pages,
>  						zone_end_pfn(zone));
> @@ -736,7 +745,8 @@ static void isolate_freepages(struct zone *zone,
>  	 */
>  	for (; block_start_pfn >= low_pfn && cc->nr_migratepages > nr_freepages;
>  				block_end_pfn = block_start_pfn,
> -				block_start_pfn -= pageblock_nr_pages) {
> +				block_start_pfn -= pageblock_nr_pages,
> +				isolate_start_pfn = block_start_pfn) {
>  		unsigned long isolated;
>  
>  		/*
> @@ -770,13 +780,25 @@ static void isolate_freepages(struct zone *zone,
>  		if (!isolation_suitable(cc, page))
>  			continue;
>  
> -		/* Found a block suitable for isolating free pages from */
> -		cc->free_pfn = block_start_pfn;
> -		isolated = isolate_freepages_block(cc, block_start_pfn,
> +		/* Found a block suitable for isolating free pages from. */
> +		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
>  					block_end_pfn, freelist, false);
>  		nr_freepages += isolated;
>  
>  		/*
> +		 * Remember where the free scanner should restart next time,
> +		 * which is where isolate_freepages_block() left off.
> +		 * But if it scanned the whole pageblock, isolate_start_pfn
> +		 * now points at block_end_pfn, which is the start of the next
> +		 * pageblock.
> +		 * In that case we will however want to restart at the start
> +		 * of the previous pageblock.
> +		 */
> +		cc->free_pfn = (isolate_start_pfn < block_end_pfn) ?
> +				isolate_start_pfn :
> +				block_start_pfn - pageblock_nr_pages;
> +
> +		/*
>  		 * Set a flag that we successfully isolated in this pageblock.
>  		 * In the next loop iteration, zone->compact_cached_free_pfn
>  		 * will not be updated and thus it will effectively contain the
> -- 
> 1.8.4.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
