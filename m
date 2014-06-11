Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 95BE36B0140
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 23:29:50 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id g10so6682003pdj.8
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 20:29:50 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id ys1si5060870pac.12.2014.06.10.20.29.47
        for <linux-mm@kvack.org>;
        Tue, 10 Jun 2014 20:29:49 -0700 (PDT)
Message-ID: <5397CD36.5040909@cn.fujitsu.com>
Date: Wed, 11 Jun 2014 11:29:58 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/10] mm, compaction: remember position within pageblock
 in free pages scanner
References: <1402305982-6928-1-git-send-email-vbabka@suse.cz> <1402305982-6928-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1402305982-6928-5-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On 06/09/2014 05:26 PM, Vlastimil Babka wrote:
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

Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> ---
>  mm/compaction.c | 33 ++++++++++++++++++++++++++++-----
>  1 file changed, 28 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 83f72bd..58dfaaa 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -297,7 +297,7 @@ static bool suitable_migration_target(struct page *page)
>   * (even though it may still end up isolating some pages).
>   */
>  static unsigned long isolate_freepages_block(struct compact_control *cc,
> -				unsigned long blockpfn,
> +				unsigned long *start_pfn,
>  				unsigned long end_pfn,
>  				struct list_head *freelist,
>  				bool strict)
> @@ -306,6 +306,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>  	struct page *cursor, *valid_page = NULL;
>  	unsigned long flags;
>  	bool locked = false;
> +	unsigned long blockpfn = *start_pfn;
>  
>  	cursor = pfn_to_page(blockpfn);
>  
> @@ -314,6 +315,9 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>  		int isolated, i;
>  		struct page *page = cursor;
>  
> +		/* Record how far we have got within the block */
> +		*start_pfn = blockpfn;
> +
>  		/*
>  		 * Periodically drop the lock (if held) regardless of its
>  		 * contention, to give chance to IRQs. Abort async compaction
> @@ -424,6 +428,9 @@ isolate_freepages_range(struct compact_control *cc,
>  	LIST_HEAD(freelist);
>  
>  	for (pfn = start_pfn; pfn < end_pfn; pfn += isolated) {
> +		/* Protect pfn from changing by isolate_freepages_block */
> +		unsigned long isolate_start_pfn = pfn;
> +
>  		if (!pfn_valid(pfn) || cc->zone != page_zone(pfn_to_page(pfn)))
>  			break;
>  
> @@ -434,8 +441,8 @@ isolate_freepages_range(struct compact_control *cc,
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
> @@ -774,6 +781,7 @@ static void isolate_freepages(struct zone *zone,
>  				block_end_pfn = block_start_pfn,
>  				block_start_pfn -= pageblock_nr_pages) {
>  		unsigned long isolated;
> +		unsigned long isolate_start_pfn;
>  
>  		/*
>  		 * This can iterate a massively long zone without finding any
> @@ -807,12 +815,27 @@ static void isolate_freepages(struct zone *zone,
>  			continue;
>  
>  		/* Found a block suitable for isolating free pages from */
> -		cc->free_pfn = block_start_pfn;
> -		isolated = isolate_freepages_block(cc, block_start_pfn,
> +		isolate_start_pfn = block_start_pfn;
> +
> +		/*
> +		 * If we are restarting the free scanner in this block, do not
> +		 * rescan the beginning of the block
> +		 */
> +		if (cc->free_pfn < block_end_pfn)
> +			isolate_start_pfn = cc->free_pfn;
> +
> +		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
>  					block_end_pfn, freelist, false);
>  		nr_freepages += isolated;
>  
>  		/*
> +		 * Remember where the free scanner should restart next time.
> +		 * This will point to the last page of pageblock we just
> +		 * scanned, if we scanned it fully.
> +		 */
> +		cc->free_pfn = isolate_start_pfn;
> +
> +		/*
>  		 * Set a flag that we successfully isolated in this pageblock.
>  		 * In the next loop iteration, zone->compact_cached_free_pfn
>  		 * will not be updated and thus it will effectively contain the
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
