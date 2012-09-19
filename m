Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id DED5F6B0062
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 15:28:02 -0400 (EDT)
Date: Wed, 19 Sep 2012 12:28:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 1/4] mm: fix tracing in free_pcppages_bulk()
Message-Id: <20120919122801.ec1aa1df.akpm@linux-foundation.org>
In-Reply-To: <1347632974-20465-2-git-send-email-b.zolnierkie@samsung.com>
References: <1347632974-20465-1-git-send-email-b.zolnierkie@samsung.com>
	<1347632974-20465-2-git-send-email-b.zolnierkie@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, m.szyprowski@samsung.com, mina86@mina86.com, minchan@kernel.org, mgorman@suse.de, hughd@google.com, kyungmin.park@samsung.com

On Fri, 14 Sep 2012 16:29:31 +0200
Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com> wrote:

> page->private gets re-used in __free_one_page() to store page order
> (so trace_mm_page_pcpu_drain() may print order instead of migratetype)
> thus migratetype value must be cached locally.
> 
> Fixes regression introduced in a701623 ("mm: fix migratetype bug
> which slowed swapping").

Grumble.  Please describe a bug when fixing it!  I've added here the
text "This caused incorrect data to be attached to the
mm_page_pcpu_drain trace event", which is hopefully correct enough.

As it's been this way for 2.5 years, I assume that this can wait for
3.7.

> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -668,12 +668,15 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  			batch_free = to_free;
>  
>  		do {
> +			int mt;
> +
>  			page = list_entry(list->prev, struct page, lru);
>  			/* must delete as __free_one_page list manipulates */
>  			list_del(&page->lru);
> +			mt = page_private(page);
>  			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
> -			__free_one_page(page, zone, 0, page_private(page));
> -			trace_mm_page_pcpu_drain(page, 0, page_private(page));
> +			__free_one_page(page, zone, 0, mt);
> +			trace_mm_page_pcpu_drain(page, 0, mt);
>  		} while (--to_free && --batch_free && !list_empty(list));
>  	}
>  	__mod_zone_page_state(zone, NR_FREE_PAGES, count);

More grumble.  Look:

akpm:/usr/src/25> grep migratetype mm/page_alloc.c | wc -l
115

We should respect the established naming conventions.  But reusing
local var `maigratetype' here is not good practice, so how about

--- a/mm/page_alloc.c~mm-fix-tracing-in-free_pcppages_bulk-fix
+++ a/mm/page_alloc.c
@@ -668,7 +668,7 @@ static void free_pcppages_bulk(struct zo
 			batch_free = to_free;
 
 		do {
-			int mt;
+			int mt;	/* migratetype of the to-be-freed page */
 
 			page = list_entry(list->prev, struct page, lru);
 			/* must delete as __free_one_page list manipulates */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
