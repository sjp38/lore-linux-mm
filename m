Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 137826B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 03:15:46 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id k184so22036046wme.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 00:15:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o62si2801419wme.27.2016.06.16.00.15.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 00:15:44 -0700 (PDT)
Subject: Re: [patch] mm, compaction: ignore watermarks when isolating free
 pages
References: <alpine.DEB.2.10.1606151530590.37360@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <4f5ba93e-8bf0-151e-57eb-cad1a4823b9e@suse.cz>
Date: Thu, 16 Jun 2016 09:15:42 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1606151530590.37360@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: Hugh Dickins <hughd@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

On 06/16/2016 12:34 AM, David Rientjes wrote:
> The goal of memory compaction is to defragment memory by moving migratable
> pages to free pages at the end of the zone.  No additional memory is being
> allocated.
>
> Ignore per-zone low watermarks in __isolate_free_page() because memory is
> either fully migrated or isolated free pages are returned when migration
> fails.

Michal Hocko suggested that too, but I didn't think it safe that 
compaction should go below the min watermark, even temporarily. It means 
the system is struggling with order-0 allocations, so making it worse 
for the benefit of high-order allocations doesn't make sense. The 
high-order allocation would likely fail anyway due to watermark checks, 
even if the page of sufficient order was formed by compaction. So in my 
series, I just changed the low watermark check to min [1].

> This fixes an issue where the compaction freeing scanner can isolate
> memory but the zone drops below its low watermark for that page order, so
> the scanner must continue to scan all memory pointlessly.

Good point, looks like failing the watermark is the only reason when 
__isolate_free_page() can fail. isolate_freepages_block() and its 
callers should take this as an indication that compaction should return 
with failure immediately.

[1] http://article.gmane.org/gmane.linux.kernel/2231369

> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/page_alloc.c | 14 ++------------
>  1 file changed, 2 insertions(+), 12 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2484,23 +2484,14 @@ EXPORT_SYMBOL_GPL(split_page);
>
>  int __isolate_free_page(struct page *page, unsigned int order)
>  {
> -	unsigned long watermark;
>  	struct zone *zone;
> -	int mt;
> +	const int mt = get_pageblock_migratetype(page);
>
>  	BUG_ON(!PageBuddy(page));
> -
>  	zone = page_zone(page);
> -	mt = get_pageblock_migratetype(page);
> -
> -	if (!is_migrate_isolate(mt)) {
> -		/* Obey watermarks as if the page was being allocated */
> -		watermark = low_wmark_pages(zone) + (1 << order);
> -		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
> -			return 0;
>
> +	if (!is_migrate_isolate(mt))
>  		__mod_zone_freepage_state(zone, -(1UL << order), mt);
> -	}
>
>  	/* Remove page from free list */
>  	list_del(&page->lru);
> @@ -2520,7 +2511,6 @@ int __isolate_free_page(struct page *page, unsigned int order)
>  		}
>  	}
>
> -
>  	return 1UL << order;
>  }
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
