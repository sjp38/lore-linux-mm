Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 416BD6B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 08:28:02 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id v10so24787502pde.10
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 05:28:02 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id bk4si4420109pbb.144.2015.01.20.05.28.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 05:28:00 -0800 (PST)
Received: by mail-pa0-f44.google.com with SMTP id et14so45691311pad.3
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 05:28:00 -0800 (PST)
Message-ID: <54BE57D7.6080501@gmail.com>
Date: Tue, 20 Jan 2015 21:27:51 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] mm, compaction: simplify handling restart position
 in free pages scanner
References: <1421661920-4114-1-git-send-email-vbabka@suse.cz> <1421661920-4114-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1421661920-4114-3-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=gbk
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

Hello,

OU 2015/1/19 18:05, Vlastimil Babka D'uA:
> Handling the position where compaction free scanner should restart (stored in
> cc->free_pfn) got more complex with commit e14c720efdd7 ("mm, compaction:
> remember position within pageblock in free pages scanner"). Currently the
> position is updated in each loop iteration isolate_freepages(), although it's
> enough to update it only when exiting the loop when we have found enough free
> pages, or detected contention in async compaction. Then an extra check outside
> the loop updates the position in case we have met the migration scanner.
> 
> This can be simplified if we move the test for having isolated enough from
> for loop header next to the test for contention, and determining the restart
> position only in these cases. We can reuse the isolate_start_pfn variable for
> this instead of setting cc->free_pfn directly. Outside the loop, we can simply
> set cc->free_pfn to value of isolate_start_pfn without extra check.
> 
> We also add VM_BUG_ON to future-proof the code, in case somebody adds a new
> condition that terminates isolate_freepages_block() prematurely, which
> wouldn't be also considered in isolate_freepages().
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
>  mm/compaction.c | 34 +++++++++++++++++++---------------
>  1 file changed, 19 insertions(+), 15 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 5fdbdb8..45799a4 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -849,7 +849,7 @@ static void isolate_freepages(struct compact_control *cc)
>  	 * pages on cc->migratepages. We stop searching if the migrate
>  	 * and free page scanners meet or enough free pages are isolated.
>  	 */
> -	for (; block_start_pfn >= low_pfn && cc->nr_migratepages > nr_freepages;
> +	for (; block_start_pfn >= low_pfn;
>  				block_end_pfn = block_start_pfn,
>  				block_start_pfn -= pageblock_nr_pages,
>  				isolate_start_pfn = block_start_pfn) {
> @@ -883,6 +883,8 @@ static void isolate_freepages(struct compact_control *cc)
>  		nr_freepages += isolated;
>  
>  		/*
> +		 * If we isolated enough freepages, or aborted due to async
> +		 * compaction being contended, terminate the loop.
>  		 * Remember where the free scanner should restart next time,
>  		 * which is where isolate_freepages_block() left off.
>  		 * But if it scanned the whole pageblock, isolate_start_pfn
> @@ -891,28 +893,30 @@ static void isolate_freepages(struct compact_control *cc)
>  		 * In that case we will however want to restart at the start
>  		 * of the previous pageblock.
>  		 */
> -		cc->free_pfn = (isolate_start_pfn < block_end_pfn) ?
> -				isolate_start_pfn :
> -				block_start_pfn - pageblock_nr_pages;
> -
> -		/*
> -		 * isolate_freepages_block() might have aborted due to async
> -		 * compaction being contended
> -		 */
> -		if (cc->contended)
> +		if ((nr_freepages > cc->nr_migratepages) || cc->contended) {

Shouldn't this be nr_freepages >= cc->nr_migratepages?

Thanks

> +			if (isolate_start_pfn >= block_end_pfn)
> +				isolate_start_pfn =
> +					block_start_pfn - pageblock_nr_pages;
>  			break;
> +		} else {
> +			/*
> +			 * isolate_freepages_block() should not terminate
> +			 * prematurely unless contended, or isolated enough
> +			 */
> +			VM_BUG_ON(isolate_start_pfn < block_end_pfn);
> +		}
>  	}
>  
>  	/* split_free_page does not map the pages */
>  	map_pages(freelist);
>  
>  	/*
> -	 * If we crossed the migrate scanner, we want to keep it that way
> -	 * so that compact_finished() may detect this
> +	 * Record where the free scanner will restart next time. Either we
> +	 * broke from the loop and set isolate_start_pfn based on the last
> +	 * call to isolate_freepages_block(), or we met the migration scanner
> +	 * and the loop terminated due to isolate_start_pfn < low_pfn
>  	 */
> -	if (block_start_pfn < low_pfn)
> -		cc->free_pfn = cc->migrate_pfn;
> -
> +	cc->free_pfn = isolate_start_pfn;
>  	cc->nr_freepages = nr_freepages;
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
