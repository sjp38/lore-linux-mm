Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id A0D966B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 18:19:52 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id m20so165149qcx.12
        for <linux-mm@kvack.org>; Tue, 06 May 2014 15:19:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id u7si3702003qab.236.2014.05.06.15.19.51
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 15:19:52 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/2] mm/compaction: avoid rescanning pageblocks in isolate_freepages
Date: Tue,  6 May 2014 18:19:39 -0400
Message-Id: <53696008.4718e00a.3223.ffff8aa5SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <1399044475-3154-1-git-send-email-vbabka@suse.cz>
References: <5363B854.3010401@suse.cz> <1399044475-3154-1-git-send-email-vbabka@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vbabka@suse.cz
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, gthelen@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, Mel Gorman <mgorman@suse.de>, iamjoonsoo.kim@lge.com, cl@linux.com, Rik van Riel <riel@redhat.com>

On Fri, May 02, 2014 at 05:27:55PM +0200, Vlastimil Babka wrote:
> The compaction free scanner in isolate_freepages() currently remembers PFN of
> the highest pageblock where it successfully isolates, to be used as the
> starting pageblock for the next invocation. The rationale behind this is that
> page migration might return free pages to the allocator when migration fails
> and we don't want to skip them if the compaction continues.
> 
> Since migration now returns free pages back to compaction code where they can
> be reused, this is no longer a concern. This patch changes isolate_freepages()
> so that the PFN for restarting is updated with each pageblock where isolation
> is attempted. Using stress-highalloc from mmtests, this resulted in 10%
> reduction of the pages scanned by the free scanner.
> 
> Note that the somewhat similar functionality that records highest successful
> pageblock in zone->compact_cached_free_pfn, remains unchanged. This cache is
> used when the whole compaction is restarted, not for multiple invocations of
> the free scanner during single compaction.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> ---
>  mm/compaction.c | 18 ++++++------------
>  1 file changed, 6 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 873d7de..1967850 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -686,12 +686,6 @@ static void isolate_freepages(struct zone *zone,
>  	low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
>  
>  	/*
> -	 * If no pages are isolated, the block_start_pfn < low_pfn check
> -	 * will kick in.
> -	 */
> -	next_free_pfn = 0;
> -
> -	/*
>  	 * Isolate free pages until enough are available to migrate the
>  	 * pages on cc->migratepages. We stop searching if the migrate
>  	 * and free page scanners meet or enough free pages are isolated.
> @@ -731,19 +725,19 @@ static void isolate_freepages(struct zone *zone,
>  			continue;
>  
>  		/* Found a block suitable for isolating free pages from */
> +		next_free_pfn = block_start_pfn;
>  		isolated = isolate_freepages_block(cc, block_start_pfn,
>  					block_end_pfn, freelist, false);
>  		nr_freepages += isolated;
>  
>  		/*
> -		 * Record the highest PFN we isolated pages from. When next
> -		 * looking for free pages, the search will restart here as
> -		 * page migration may have returned some pages to the allocator
> +		 * Set a flag that we successfully isolated in this pageblock.
> +		 * In the next loop iteration, zone->compact_cached_free_pfn
> +		 * will not be updated and thus it will effectively contain the
> +		 * highest pageblock we isolated pages from.
>  		 */
> -		if (isolated && next_free_pfn == 0) {
> +		if (isolated)
>  			cc->finished_update_free = true;
> -			next_free_pfn = block_start_pfn;
> -		}

Why don't you completely remove next_free_pfn and update cc->free_pfn directly?

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
