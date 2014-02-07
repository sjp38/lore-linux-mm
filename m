Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id D5D7F6B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 05:30:07 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id cc10so682832wib.4
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 02:30:07 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wa6si2059454wjc.50.2014.02.07.02.30.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 02:30:06 -0800 (PST)
Message-ID: <52F4B5AA.2040006@suse.cz>
Date: Fri, 07 Feb 2014 11:30:02 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] mm/compaction: check pageblock suitability once per
 pageblock
References: <1391749726-28910-1-git-send-email-iamjoonsoo.kim@lge.com> <1391749726-28910-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1391749726-28910-5-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/07/2014 06:08 AM, Joonsoo Kim wrote:
> isolation_suitable() and migrate_async_suitable() is used to be sure
> that this pageblock range is fine to be migragted. It isn't needed to
> call it on every page. Current code do well if not suitable, but, don't
> do well when suitable. It re-check it on every valid pageblock.
> This patch fix this situation by updating last_pageblock_nr.

It took me a while to understand that the problem with migrate_async_suitable() was the
lack of last_pageblock_nr updates (when the code doesn't go through next_pageblock:
label), while the problem with isolation_suitable() was the lack of doing the test only
when last_pageblock_nr != pageblock_nr (so two different things). How bout making it
clearer in the changelog by replacing the paragraph above with something like:

<snip>
isolation_suitable() and migrate_async_suitable() is used to be sure
that this pageblock range is fine to be migragted. It isn't needed to
call it on every page. Current code do well if not suitable, but, don't
do well when suitable.

1) It re-checks isolation_suitable() on each page of a pageblock that was already
estabilished as suitable.
2) It re-checks migrate_async_suitable() on each page of a pageblock that was not entered
through the next_pageblock: label, because last_pageblock_nr is not otherwise updated.

This patch fixes situation by 1) calling isolation_suitable() only once per pageblock and
2) always updating last_pageblock_nr to the pageblock that was just checked.
</snip>

> Additionally, move PageBuddy() check after pageblock unit check,
> since pageblock check is the first thing we should do and makes things
> more simple.

You should also do this, since it becomes redundant and might only confuse people:

 next_pageblock:
                 low_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages) - 1;
-                last_pageblock_nr = pageblock_nr;


> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

With the above resolved, consider the patch to be

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> diff --git a/mm/compaction.c b/mm/compaction.c
> index b1ba297..985b782 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -520,26 +520,32 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  
>  		/* If isolation recently failed, do not retry */
>  		pageblock_nr = low_pfn >> pageblock_order;
> -		if (!isolation_suitable(cc, page))
> -			goto next_pageblock;
> +		if (last_pageblock_nr != pageblock_nr) {
> +			int mt;
> +
> +			if (!isolation_suitable(cc, page))
> +				goto next_pageblock;
> +
> +			/*
> +			 * For async migration, also only scan in MOVABLE
> +			 * blocks. Async migration is optimistic to see if
> +			 * the minimum amount of work satisfies the allocation
> +			 */
> +			mt = get_pageblock_migratetype(page);
> +			if (!cc->sync && !migrate_async_suitable(mt)) {
> +				cc->finished_update_migrate = true;
> +				skipped_async_unsuitable = true;
> +				goto next_pageblock;
> +			}
> +
> +			last_pageblock_nr = pageblock_nr;
> +		}
>  
>  		/* Skip if free */
>  		if (PageBuddy(page))
>  			continue;
>  
>  		/*
> -		 * For async migration, also only scan in MOVABLE blocks. Async
> -		 * migration is optimistic to see if the minimum amount of work
> -		 * satisfies the allocation
> -		 */
> -		if (!cc->sync && last_pageblock_nr != pageblock_nr &&
> -		    !migrate_async_suitable(get_pageblock_migratetype(page))) {
> -			cc->finished_update_migrate = true;
> -			skipped_async_unsuitable = true;
> -			goto next_pageblock;
> -		}
> -
> -		/*
>  		 * Check may be lockless but that's ok as we recheck later.
>  		 * It's possible to migrate LRU pages and balloon pages
>  		 * Skip any other type of page
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
