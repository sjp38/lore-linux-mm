Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id DEA936B00C2
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 03:10:11 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0486D3EE0C5
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 16:10:10 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CC1645DE5E
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 16:10:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3887145DE56
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 16:10:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EC18D1DB8046
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 16:10:08 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A29541DB803A
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 16:10:07 +0900 (JST)
Message-ID: <4FD59952.7020602@jp.fujitsu.com>
Date: Mon, 11 Jun 2012 16:08:02 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: clean up __count_immobile_pages
References: <1339380442-1137-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1339380442-1137-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

(2012/06/11 11:07), Minchan Kim wrote:
> __count_immobile_pages naming is rather awkward.
> This patch clean up the function and add comment.
>
> Cc: Mel Gorman<mgorman@suse.de>
> Cc: Michal Hocko<mhocko@suse.cz>
> Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Minchan Kim<minchan@kernel.org>

exchange true<->false caused by renaming ?

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>   mm/page_alloc.c |   33 +++++++++++++++++----------------
>   1 file changed, 17 insertions(+), 16 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 019c4fe..2c71ac9 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5467,26 +5467,27 @@ void set_pageblock_flags_group(struct page *page, unsigned long flags,
>   }
>
>   /*
> - * This is designed as sub function...plz see page_isolation.c also.
> - * set/clear page block's type to be ISOLATE.
> - * page allocater never alloc memory from ISOLATE block.
> + * This function checks whether pageblock includes unmovable pages or not.
> + * If @count is not zero, it is okay to include less @count unmovable pages
> + *
> + * This function can race in PageLRU and MIGRATE_MOVABLE can have unmovable
> + * pages so that it might be not exact.
>    */
> -
> -static int
> -__count_immobile_pages(struct zone *zone, struct page *page, int count)
> +static bool
> +__has_unmovable_pages(struct zone *zone, struct page *page, int count)
>   {
>   	unsigned long pfn, iter, found;
>   	int mt;
>
>   	/*
>   	 * For avoiding noise data, lru_add_drain_all() should be called
> -	 * If ZONE_MOVABLE, the zone never contains immobile pages
> +	 * If ZONE_MOVABLE, the zone never contains unmovable pages
>   	 */
>   	if (zone_idx(zone) == ZONE_MOVABLE)
> -		return true;
> +		return false;
>   	mt = get_pageblock_migratetype(page);
>   	if (mt == MIGRATE_MOVABLE || is_migrate_cma(mt))
> -		return true;
> +		return false;
>
>   	pfn = page_to_pfn(page);
>   	for (found = 0, iter = 0; iter<  pageblock_nr_pages; iter++) {
> @@ -5521,9 +5522,9 @@ __count_immobile_pages(struct zone *zone, struct page *page, int count)
>   		 * page at boot.
>   		 */
>   		if (found>  count)
> -			return false;
> +			return true;
>   	}
> -	return true;
> +	return false;
>   }
>
>   bool is_pageblock_removable_nolock(struct page *page)
> @@ -5547,7 +5548,7 @@ bool is_pageblock_removable_nolock(struct page *page)
>   			zone->zone_start_pfn + zone->spanned_pages<= pfn)
>   		return false;
>
> -	return __count_immobile_pages(zone, page, 0);
> +	return !__has_unmovable_pages(zone, page, 0);
>   }
>
>   int set_migratetype_isolate(struct page *page)
> @@ -5586,12 +5587,12 @@ int set_migratetype_isolate(struct page *page)
>   	 * FIXME: Now, memory hotplug doesn't call shrink_slab() by itself.
>   	 * We just check MOVABLE pages.
>   	 */
> -	if (__count_immobile_pages(zone, page, arg.pages_found))
> +	if (!__has_unmovable_pages(zone, page, arg.pages_found))
>   		ret = 0;
> -
>   	/*
> -	 * immobile means "not-on-lru" paes. If immobile is larger than
> -	 * removable-by-driver pages reported by notifier, we'll fail.
> +	 * Unmovable means "not-on-lru" pages. If Unmovable pages are
> +	 * larger than removable-by-driver pages reported by notifier,
> +	 * we'll fail.
>   	 */
>
>   out:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
