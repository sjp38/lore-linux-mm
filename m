Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7D45D6B003D
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 20:07:06 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id lj1so11498037pab.34
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 17:07:06 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id hb10si9686558pbc.441.2014.04.16.17.07.04
        for <linux-mm@kvack.org>;
        Wed, 16 Apr 2014 17:07:05 -0700 (PDT)
Date: Thu, 17 Apr 2014 09:07:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] mm/compaction: cleanup isolate_freepages()
Message-ID: <20140417000745.GF27534@bbox>
References: <5342BA34.8050006@suse.cz>
 <1397553507-15330-1-git-send-email-vbabka@suse.cz>
 <1397553507-15330-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1397553507-15330-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Heesub Shin <heesub.shin@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dongjun Shin <d.j.shin@samsung.com>, Sunghwan Yun <sunghwan.yun@samsung.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

Hi Vlastimil,

Below just nitpicks.

On Tue, Apr 15, 2014 at 11:18:27AM +0200, Vlastimil Babka wrote:
> isolate_freepages() is currently somewhat hard to follow thanks to many
> different pfn variables. Especially misleading is the name 'high_pfn' which
> looks like it is related to the 'low_pfn' variable, but in fact it is not.

Indeed.

> 
> This patch renames the 'high_pfn' variable to a hopefully less confusing name,
> and slightly changes its handling without a functional change. A comment made
> obsolete by recent changes is also updated.

It's clean up patch so if we do fixing, I'd like to do more.

> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> ---
>  mm/compaction.c | 17 ++++++++---------
>  1 file changed, 8 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 627dc2e..169c7b2 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -671,7 +671,7 @@ static void isolate_freepages(struct zone *zone,
>  				struct compact_control *cc)
>  {
>  	struct page *page;
> -	unsigned long high_pfn, low_pfn, pfn, z_end_pfn;
> +	unsigned long pfn, low_pfn, next_free_pfn, z_end_pfn;

Could you add comment for each variable?

unsigned long pfn; /* scanning cursor */
unsigned long low_pfn; /* lowest pfn free scanner is able to scan */
unsigned long next_free_pfn; /* start pfn for scaning at next truen */
unsigned long z_end_pfn; /* zone's end pfn */


>  	int nr_freepages = cc->nr_freepages;
>  	struct list_head *freelist = &cc->freepages;
>  
> @@ -688,11 +688,10 @@ static void isolate_freepages(struct zone *zone,
>  	low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
>  
>  	/*
> -	 * Take care that if the migration scanner is at the end of the zone
> -	 * that the free scanner does not accidentally move to the next zone
> -	 * in the next isolation cycle.
> +	 * Seed the value for max(next_free_pfn, pfn) updates. If there are
> +	 * none, the pfn < low_pfn check will kick in.

       "none" what? I'd like to clear more.

>  	 */
> -	high_pfn = min(low_pfn, pfn);
> +	next_free_pfn = 0;
>  
>  	z_end_pfn = zone_end_pfn(zone);
>  
> @@ -754,7 +753,7 @@ static void isolate_freepages(struct zone *zone,
>  		 */
>  		if (isolated) {
>  			cc->finished_update_free = true;
> -			high_pfn = max(high_pfn, pfn);
> +			next_free_pfn = max(next_free_pfn, pfn);
>  		}
>  	}
>  
> @@ -766,9 +765,9 @@ static void isolate_freepages(struct zone *zone,
>  	 * so that compact_finished() may detect this
>  	 */
>  	if (pfn < low_pfn)
> -		cc->free_pfn = max(pfn, zone->zone_start_pfn);
> -	else
> -		cc->free_pfn = high_pfn;
> +		next_free_pfn = max(pfn, zone->zone_start_pfn);

Why we need max operation?
IOW, what's the problem if we do (next_free_pfn = pfn)?

> +
> +	cc->free_pfn = next_free_pfn;
>  	cc->nr_freepages = nr_freepages;
>  }
>  
> -- 
> 1.8.4.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
