Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 986696B005A
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 03:07:43 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AE0E63EE0C1
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 16:07:41 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9793545DEB7
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 16:07:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 81E3745DEB2
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 16:07:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7547CE08003
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 16:07:41 +0900 (JST)
Received: from g01jpexchkw31.g01.fujitsu.local (g01jpexchkw31.g01.fujitsu.local [10.0.193.114])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3141FE08001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 16:07:41 +0900 (JST)
Message-ID: <50596F27.4080208@jp.fujitsu.com>
Date: Wed, 19 Sep 2012 16:07:19 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 1/4] mm: fix tracing in free_pcppages_bulk()
References: <1347632974-20465-1-git-send-email-b.zolnierkie@samsung.com> <1347632974-20465-2-git-send-email-b.zolnierkie@samsung.com>
In-Reply-To: <1347632974-20465-2-git-send-email-b.zolnierkie@samsung.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, minchan@kernel.org
Cc: linux-mm@kvack.org, m.szyprowski@samsung.com, mina86@mina86.com, mgorman@suse.de, hughd@google.com, kyungmin.park@samsung.com

Hi Bartlomiej,

2012/09/14 23:29, Bartlomiej Zolnierkiewicz wrote:
> page->private gets re-used in __free_one_page() to store page order
> (so trace_mm_page_pcpu_drain() may print order instead of migratetype)
> thus migratetype value must be cached locally.
> 
> Fixes regression introduced in a701623 ("mm: fix migratetype bug
> which slowed swapping").

I think the regression has been alreadly fixed by following Mincahn's patches.

https://lkml.org/lkml/2012/9/6/635

=> Hi Minchan,

   Am I wrong?

Thanks,
Yasuaki Ishimatsu
 
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Acked-by: Minchan Kim <minchan@kernel.org>
> Acked-by: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>   mm/page_alloc.c | 7 +++++--
>   1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 93a3433..e9da55c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -668,12 +668,15 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>   			batch_free = to_free;
>   
>   		do {
> +			int mt;
> +
>   			page = list_entry(list->prev, struct page, lru);
>   			/* must delete as __free_one_page list manipulates */
>   			list_del(&page->lru);
> +			mt = page_private(page);
>   			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
> -			__free_one_page(page, zone, 0, page_private(page));
> -			trace_mm_page_pcpu_drain(page, 0, page_private(page));
> +			__free_one_page(page, zone, 0, mt);
> +			trace_mm_page_pcpu_drain(page, 0, mt);
>   		} while (--to_free && --batch_free && !list_empty(list));
>   	}
>   	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
