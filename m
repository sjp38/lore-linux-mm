Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3CD016B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 01:39:08 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so6384654pdb.2
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 22:39:08 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ij4si21013548pbc.142.2015.06.15.22.39.06
        for <linux-mm@kvack.org>;
        Mon, 15 Jun 2015 22:39:07 -0700 (PDT)
Date: Tue, 16 Jun 2015 14:41:15 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 3/6] mm, compaction: encapsulate resetting cached scanner
 positions
Message-ID: <20150616054115.GC12641@js1304-P5Q-DELUXE>
References: <1433928754-966-1-git-send-email-vbabka@suse.cz>
 <1433928754-966-4-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433928754-966-4-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Wed, Jun 10, 2015 at 11:32:31AM +0200, Vlastimil Babka wrote:
> Resetting the cached compaction scanner positions is now done implicitly in
> __reset_isolation_suitable() and compact_finished(). Encapsulate the
> functionality in a new function reset_cached_positions() and call it explicitly
> where needed.
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
>  mm/compaction.c | 22 ++++++++++++++--------
>  1 file changed, 14 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 7e0a814..d334bb3 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -207,6 +207,13 @@ static inline bool isolation_suitable(struct compact_control *cc,
>  	return !get_pageblock_skip(page);
>  }
>  
> +static void reset_cached_positions(struct zone *zone)
> +{
> +	zone->compact_cached_migrate_pfn[0] = zone->zone_start_pfn;
> +	zone->compact_cached_migrate_pfn[1] = zone->zone_start_pfn;
> +	zone->compact_cached_free_pfn = zone_end_pfn(zone);
> +}
> +
>  /*
>   * This function is called to clear all cached information on pageblocks that
>   * should be skipped for page isolation when the migrate and free page scanner
> @@ -218,9 +225,6 @@ static void __reset_isolation_suitable(struct zone *zone)
>  	unsigned long end_pfn = zone_end_pfn(zone);
>  	unsigned long pfn;
>  
> -	zone->compact_cached_migrate_pfn[0] = start_pfn;
> -	zone->compact_cached_migrate_pfn[1] = start_pfn;
> -	zone->compact_cached_free_pfn = end_pfn;
>  	zone->compact_blockskip_flush = false;

Is there a valid reason not to call reset_cached_positions() in
__reset_isolation_suitable? You missed one callsite in
__compact_pgdat().

        if (cc->order == -1)
                __reset_isolation_suitable(zone);

This also needs reset_cached_positions().

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
