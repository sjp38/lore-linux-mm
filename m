Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 504DF6B0038
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 08:26:10 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so11193840pad.10
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 05:26:10 -0800 (PST)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com. [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id vu1si4658119pbc.23.2015.01.20.05.26.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 05:26:08 -0800 (PST)
Received: by mail-pd0-f176.google.com with SMTP id y10so3426416pdj.7
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 05:26:08 -0800 (PST)
Message-ID: <54BE5769.20405@gmail.com>
Date: Tue, 20 Jan 2015 21:26:01 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] mm, compaction: more robust check for scanners meeting
References: <1421661920-4114-1-git-send-email-vbabka@suse.cz> <1421661920-4114-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1421661920-4114-2-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=gbk
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

OU 2015/1/19 18:05, Vlastimil Babka D'uA:
> Compaction should finish when the migration and free scanner meet, i.e. they
> reach the same pageblock. Currently however, the test in compact_finished()
> simply just compares the exact pfns, which may yield a false negative when the
> free scanner position is in the middle of a pageblock and the migration
> scanner reaches the begining of the same pageblock.
> 
> This hasn't been a problem until commit e14c720efdd7 ("mm, compaction:
> remember position within pageblock in free pages scanner") allowed the free
> scanner position to be in the middle of a pageblock between invocations.
> The hot-fix 1d5bfe1ffb5b ("mm, compaction: prevent infinite loop in
> compact_zone") prevented the issue by adding a special check in the migration
> scanner to satisfy the current detection of scanners meeting.
> 
> However, the proper fix is to make the detection more robust. This patch
> introduces the compact_scanners_met() function that returns true when the free
> scanner position is in the same or lower pageblock than the migration scanner.
> The special case in isolate_migratepages() introduced by 1d5bfe1ffb5b is
> removed.
> 
> Suggested-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
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
>  mm/compaction.c | 22 ++++++++++++++--------
>  1 file changed, 14 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 546e571..5fdbdb8 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -803,6 +803,16 @@ isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
>  #endif /* CONFIG_COMPACTION || CONFIG_CMA */
>  #ifdef CONFIG_COMPACTION
>  /*
> + * Test whether the free scanner has reached the same or lower pageblock than
> + * the migration scanner, and compaction should thus terminate.
> + */
> +static inline bool compact_scanners_met(struct compact_control *cc)
> +{
> +	return (cc->free_pfn >> pageblock_order)
> +		<= (cc->migrate_pfn >> pageblock_order);
> +}
> +
> +/*
>   * Based on information in the current compact_control, find blocks
>   * suitable for isolating free pages from and then isolate them.
>   */
> @@ -1027,12 +1037,8 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  	}
>  
>  	acct_isolated(zone, cc);
> -	/*
> -	 * Record where migration scanner will be restarted. If we end up in
> -	 * the same pageblock as the free scanner, make the scanners fully
> -	 * meet so that compact_finished() terminates compaction.
> -	 */
> -	cc->migrate_pfn = (end_pfn <= cc->free_pfn) ? low_pfn : cc->free_pfn;
> +	/* Record where migration scanner will be restarted. */
> +	cc->migrate_pfn = low_pfn;
>  
>  	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
>  }
> @@ -1047,7 +1053,7 @@ static int compact_finished(struct zone *zone, struct compact_control *cc,
>  		return COMPACT_PARTIAL;
>  
>  	/* Compaction run completes if the migrate and free scanner meet */
> -	if (cc->free_pfn <= cc->migrate_pfn) {
> +	if (compact_scanners_met(cc)) {
>  		/* Let the next compaction start anew. */
>  		zone->compact_cached_migrate_pfn[0] = zone->zone_start_pfn;
>  		zone->compact_cached_migrate_pfn[1] = zone->zone_start_pfn;
> @@ -1238,7 +1244,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>  			 * migrate_pages() may return -ENOMEM when scanners meet
>  			 * and we want compact_finished() to detect it
>  			 */
> -			if (err == -ENOMEM && cc->free_pfn > cc->migrate_pfn) {
> +			if (err == -ENOMEM && !compact_scanners_met(cc)) {
>  				ret = COMPACT_PARTIAL;
>  				goto out;
>  			}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
