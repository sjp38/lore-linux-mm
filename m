Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 11D7E6B00E7
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 03:27:48 -0500 (EST)
Received: by mail-ie0-f179.google.com with SMTP id rl12so17661532iec.10
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 00:27:47 -0800 (PST)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com. [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id jf8si2209037igb.37.2014.11.14.00.27.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Nov 2014 00:27:46 -0800 (PST)
Received: by mail-ig0-f170.google.com with SMTP id a13so2729917igq.5
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 00:27:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1414740330-4086-2-git-send-email-iamjoonsoo.kim@lge.com>
References: <1414740330-4086-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1414740330-4086-2-git-send-email-iamjoonsoo.kim@lge.com>
Date: Fri, 14 Nov 2014 16:27:46 +0800
Message-ID: <CAL1ERfMxR0BPQ-1hsD+Z-Oizkt4WHzL_rwYmKd2n70R=H0X22Q@mail.gmail.com>
Subject: Re: [PATCH v5 1/4] mm/page_alloc: fix incorrect isolation behavior by
 rechecking migratetype
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Fri, Oct 31, 2014 at 3:25 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> There are two paths to reach core free function of buddy allocator,
> __free_one_page(), one is free_one_page()->__free_one_page() and the
> other is free_hot_cold_page()->free_pcppages_bulk()->__free_one_page().
> Each paths has race condition causing serious problems. At first, this
> patch is focused on first type of freepath. And then, following patch
> will solve the problem in second type of freepath.
>
> In the first type of freepath, we got migratetype of freeing page without
> holding the zone lock, so it could be racy. There are two cases of this
> race.
>
> 1. pages are added to isolate buddy list after restoring orignal
> migratetype
>
> CPU1                                   CPU2
>
> get migratetype => return MIGRATE_ISOLATE
> call free_one_page() with MIGRATE_ISOLATE
>
>                                 grab the zone lock
>                                 unisolate pageblock
>                                 release the zone lock
>
> grab the zone lock
> call __free_one_page() with MIGRATE_ISOLATE
> freepage go into isolate buddy list,
> although pageblock is already unisolated
>
> This may cause two problems. One is that we can't use this page anymore
> until next isolation attempt of this pageblock, because freepage is on
> isolate buddy list. The other is that freepage accouting could be wrong
> due to merging between different buddy list. Freepages on isolate buddy
> list aren't counted as freepage, but ones on normal buddy list are counted
> as freepage. If merge happens, buddy freepage on normal buddy list is
> inevitably moved to isolate buddy list without any consideration of
> freepage accouting so it could be incorrect.
>
> 2. pages are added to normal buddy list while pageblock is isolated.
> It is similar with above case.
>
> This also may cause two problems. One is that we can't keep these
> freepages from being allocated. Although this pageblock is isolated,
> freepage would be added to normal buddy list so that it could be
> allocated without any restriction. And the other problem is same as
> case 1, that it, incorrect freepage accouting.
>
> This race condition would be prevented by checking migratetype again
> with holding the zone lock. Because it is somewhat heavy operation
> and it isn't needed in common case, we want to avoid rechecking as much
> as possible. So this patch introduce new variable, nr_isolate_pageblock
> in struct zone to check if there is isolated pageblock.
> With this, we can avoid to re-check migratetype in common case and do
> it only if there is isolated pageblock or migratetype is MIGRATE_ISOLATE.
> This solve above mentioned problems.
>
> Changes from v3:
> Add one more check in free_one_page() that checks whether migratetype is
> MIGRATE_ISOLATE or not. Without this, abovementioned case 1 could happens.
>
> Cc: <stable@vger.kernel.org>
> Acked-by: Minchan Kim <minchan@kernel.org>
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  include/linux/mmzone.h         |    9 +++++++++
>  include/linux/page-isolation.h |    8 ++++++++
>  mm/page_alloc.c                |   11 +++++++++--
>  mm/page_isolation.c            |    2 ++
>  4 files changed, 28 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 4593567..3d090af 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -431,6 +431,15 @@ struct zone {
>          */
>         int                     nr_migrate_reserve_block;
>
> +#ifdef CONFIG_MEMORY_ISOLATION
> +       /*
> +        * Number of isolated pageblock. It is used to solve incorrect
> +        * freepage counting problem due to racy retrieving migratetype
> +        * of pageblock. Protected by zone->lock.
> +        */
> +       unsigned long           nr_isolate_pageblock;
> +#endif
> +

First sorry for this deferred reply, I see these patches have been merged
into the mainline.
However, I still have a tiny question:
Why use ZONE_PADDING(_pad1_)  seperate it and zone->lock?
How about move it to the same cacheline with zone->lock, because it is
accessed under zone->lock?

>  #ifdef CONFIG_MEMORY_HOTPLUG
>         /* see spanned/present_pages for more description */
>         seqlock_t               span_seqlock;
> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
> index 3fff8e7..2dc1e16 100644
> --- a/include/linux/page-isolation.h
> +++ b/include/linux/page-isolation.h
> @@ -2,6 +2,10 @@
>  #define __LINUX_PAGEISOLATION_H
>
>  #ifdef CONFIG_MEMORY_ISOLATION
> +static inline bool has_isolate_pageblock(struct zone *zone)
> +{
> +       return zone->nr_isolate_pageblock;
> +}
>  static inline bool is_migrate_isolate_page(struct page *page)
>  {
>         return get_pageblock_migratetype(page) == MIGRATE_ISOLATE;
> @@ -11,6 +15,10 @@ static inline bool is_migrate_isolate(int migratetype)
>         return migratetype == MIGRATE_ISOLATE;
>  }
>  #else
> +static inline bool has_isolate_pageblock(struct zone *zone)
> +{
> +       return false;
> +}
>  static inline bool is_migrate_isolate_page(struct page *page)
>  {
>         return false;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d3ed723..f7a867e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -749,9 +749,16 @@ static void free_one_page(struct zone *zone,
>         if (nr_scanned)
>                 __mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
>
> +       if (unlikely(has_isolate_pageblock(zone) ||
> +               is_migrate_isolate(migratetype))) {
> +               migratetype = get_pfnblock_migratetype(page, pfn);
> +               if (is_migrate_isolate(migratetype))
> +                       goto skip_counting;
> +       }
> +       __mod_zone_freepage_state(zone, 1 << order, migratetype);
> +
> +skip_counting:
>         __free_one_page(page, pfn, zone, order, migratetype);
> -       if (unlikely(!is_migrate_isolate(migratetype)))
> -               __mod_zone_freepage_state(zone, 1 << order, migratetype);
>         spin_unlock(&zone->lock);
>  }
>
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index d1473b2..1fa4a4d 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -60,6 +60,7 @@ out:
>                 int migratetype = get_pageblock_migratetype(page);
>
>                 set_pageblock_migratetype(page, MIGRATE_ISOLATE);
> +               zone->nr_isolate_pageblock++;
>                 nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE);
>
>                 __mod_zone_freepage_state(zone, -nr_pages, migratetype);
> @@ -83,6 +84,7 @@ void unset_migratetype_isolate(struct page *page, unsigned migratetype)
>         nr_pages = move_freepages_block(zone, page, migratetype);
>         __mod_zone_freepage_state(zone, nr_pages, migratetype);
>         set_pageblock_migratetype(page, migratetype);
> +       zone->nr_isolate_pageblock--;
>  out:
>         spin_unlock_irqrestore(&zone->lock, flags);
>  }
> --
> 1.7.9.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
