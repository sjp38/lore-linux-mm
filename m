Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3E0416B003D
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 11:50:14 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id q59so4667129wes.27
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 08:50:13 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l18si32891860wiw.85.2014.07.07.08.50.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Jul 2014 08:50:13 -0700 (PDT)
Message-ID: <53BAC1B1.4090002@suse.cz>
Date: Mon, 07 Jul 2014 17:50:09 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 05/10] mm/page_alloc: optimize and unify pageblock migratetype
 check in free path
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com> <1404460675-24456-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1404460675-24456-6-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/04/2014 09:57 AM, Joonsoo Kim wrote:
> Currently, when we free the page from pcp list to buddy, we check
> pageblock of the page in order to isolate the page on isolated
> pageblock. Although this could rarely happen and to check migratetype of
> pageblock is somewhat expensive, we check it on free fast path. I think
> that this is undesirable. To prevent this situation, I introduce new
> variable, nr_isolate_pageblock on struct zone and use it to determine
> if we should check pageblock migratetype. Isolation on pageblock rarely
> happens so we can mostly avoid this pageblock migratetype check.

Better, but still there's a zone flag check and maintenance. So if it 
could be avoided, it would be better.

> Additionally, unify freepage counting code, because it can be done in
> common part, __free_one_page(). This unifying provides extra guarantee
> that the page on isolate pageblock don't go into non-isolate buddy list.
> This is similar situation describing in previous patch so refer it
> if you need more explanation.

You should make it clearer that you are solving misplacement of the type 
"page should be placed on isolated freelist but it's not" through 
free_one_page(), which was solved only for free_pcppages_bulk() in patch 
03/10. Mentioning patch 04/10 here, which solves the opposite problem 
"page shouldn't be placed on isolated freelist, but it is", only 
confuses the situation. Also this patch undoes everything of 04/10 and 
moves it elsewhere, so that would make it harder to git blame etc. I 
would reorder 04 and 05.

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>   include/linux/mmzone.h         |    5 +++++
>   include/linux/page-isolation.h |    8 ++++++++
>   mm/page_alloc.c                |   40 +++++++++++++++++++---------------------
>   mm/page_isolation.c            |    2 ++
>   4 files changed, 34 insertions(+), 21 deletions(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index fd48890..e9c194f 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -374,6 +374,11 @@ struct zone {
>   	/* pfn where async and sync compaction migration scanner should start */
>   	unsigned long		compact_cached_migrate_pfn[2];
>   #endif
> +
> +#ifdef CONFIG_MEMORY_ISOLATION
> +	unsigned long		nr_isolate_pageblock;
> +#endif
> +
>   #ifdef CONFIG_MEMORY_HOTPLUG
>   	/* see spanned/present_pages for more description */
>   	seqlock_t		span_seqlock;
> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
> index 3fff8e7..2dc1e16 100644
> --- a/include/linux/page-isolation.h
> +++ b/include/linux/page-isolation.h
> @@ -2,6 +2,10 @@
>   #define __LINUX_PAGEISOLATION_H
>
>   #ifdef CONFIG_MEMORY_ISOLATION
> +static inline bool has_isolate_pageblock(struct zone *zone)
> +{
> +	return zone->nr_isolate_pageblock;
> +}
>   static inline bool is_migrate_isolate_page(struct page *page)
>   {
>   	return get_pageblock_migratetype(page) == MIGRATE_ISOLATE;
> @@ -11,6 +15,10 @@ static inline bool is_migrate_isolate(int migratetype)
>   	return migratetype == MIGRATE_ISOLATE;
>   }
>   #else
> +static inline bool has_isolate_pageblock(struct zone *zone)
> +{
> +	return false;
> +}
>   static inline bool is_migrate_isolate_page(struct page *page)
>   {
>   	return false;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d8feedc..dcc2f08 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -594,6 +594,24 @@ static inline void __free_one_page(struct page *page,
>   	VM_BUG_ON_PAGE(page_idx & ((1 << order) - 1), page);
>   	VM_BUG_ON_PAGE(bad_range(zone, page), page);
>
> +	/*
> +	 * pcp pages could go normal buddy list due to stale pageblock
> +	 * migratetype so re-check it if there is isolate pageblock.
> +	 *
> +	 * And, we got migratetype without holding the lock so it could be
> +	 * racy. If some pages go on the isolate migratetype buddy list
> +	 * by this race, we can't allocate this page anymore until next
> +	 * isolation attempt on this pageblock. To prevent this
> +	 * possibility, re-check migratetype with holding the lock.
> +	 */
> +	if (unlikely(has_isolate_pageblock(zone) ||
> +		is_migrate_isolate(migratetype))) {
> +		migratetype = get_pfnblock_migratetype(page, pfn);
> +	}
> +
> +	if (!is_migrate_isolate(migratetype))
> +		__mod_zone_freepage_state(zone, 1 << order, migratetype);
> +
>   	while (order < MAX_ORDER-1) {
>   		buddy_idx = __find_buddy_index(page_idx, order);
>   		buddy = page + (buddy_idx - page_idx);
> @@ -719,13 +737,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>   			page = list_entry(list->prev, struct page, lru);
>   			/* must delete as __free_one_page list manipulates */
>   			list_del(&page->lru);
> -
> -			if (unlikely(is_migrate_isolate_page(page))) {
> -				mt = MIGRATE_ISOLATE;
> -			} else {
> -				mt = get_freepage_migratetype(page);
> -				__mod_zone_freepage_state(zone, 1, mt);
> -			}
> +			mt = get_freepage_migratetype(page);
>
>   			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
>   			__free_one_page(page, page_to_pfn(page), zone, 0, mt);
> @@ -742,21 +754,7 @@ static void free_one_page(struct zone *zone,
>   {
>   	spin_lock(&zone->lock);
>   	zone->pages_scanned = 0;
> -
> -	if (unlikely(is_migrate_isolate(migratetype))) {
> -		/*
> -		 * We got migratetype without holding the lock so it could be
> -		 * racy. If some pages go on the isolate migratetype buddy list
> -		 * by this race, we can't allocate this page anymore until next
> -		 * isolation attempt on this pageblock. To prevent this
> -		 * possibility, re-check migratetype with holding the lock.
> -		 */
> -		migratetype = get_pfnblock_migratetype(page, pfn);
> -	}
> -
>   	__free_one_page(page, pfn, zone, order, migratetype);
> -	if (!is_migrate_isolate(migratetype))
> -		__mod_zone_freepage_state(zone, 1 << order, migratetype);
>   	spin_unlock(&zone->lock);
>   }
>
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index d1473b2..1fa4a4d 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -60,6 +60,7 @@ out:
>   		int migratetype = get_pageblock_migratetype(page);
>
>   		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
> +		zone->nr_isolate_pageblock++;
>   		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE);
>
>   		__mod_zone_freepage_state(zone, -nr_pages, migratetype);
> @@ -83,6 +84,7 @@ void unset_migratetype_isolate(struct page *page, unsigned migratetype)
>   	nr_pages = move_freepages_block(zone, page, migratetype);
>   	__mod_zone_freepage_state(zone, nr_pages, migratetype);
>   	set_pageblock_migratetype(page, migratetype);
> +	zone->nr_isolate_pageblock--;
>   out:
>   	spin_unlock_irqrestore(&zone->lock, flags);
>   }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
