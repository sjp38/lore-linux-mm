Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 71EE86B0253
	for <linux-mm@kvack.org>; Sun,  9 Aug 2015 13:21:40 -0400 (EDT)
Received: by qgj62 with SMTP id 62so79413130qgj.2
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 10:21:40 -0700 (PDT)
Received: from nm41.bullet.mail.bf1.yahoo.com (nm41.bullet.mail.bf1.yahoo.com. [216.109.114.57])
        by mx.google.com with ESMTPS id b41si18078097qkh.99.2015.08.09.10.21.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 09 Aug 2015 10:21:39 -0700 (PDT)
Date: Sun, 9 Aug 2015 17:21:13 +0000 (UTC)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Message-ID: <166622926.1247366.1439140873216.JavaMail.yahoo@mail.yahoo.com>
In-Reply-To: <1438619141-22215-2-git-send-email-vbabka@suse.cz>
References: <1438619141-22215-2-git-send-email-vbabka@suse.cz>
Subject: Re: [RFC v3 2/2] mm, compaction: make kcompactd rely on
 sysctl_extfrag_threshold
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pintu Kumar <pintu.k@samsung.com>

Hi,



----- Original Message -----
> From: Vlastimil Babka <vbabka@suse.cz>
> To: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org; Andrew Morton <akpm@linux-foundation.org>; Hugh Dickins <hughd@google.com>; Andrea Arcangeli <aarcange@redhat.com>; Kirill A. Shutemov <kirill.shutemov@linux.intel.com>; Rik van Riel <riel@redhat.com>; Mel Gorman <mgorman@suse.de>; David Rientjes <rientjes@google.com>; Joonsoo Kim <iamjoonsoo.kim@lge.com>; Vlastimil Babka <vbabka@suse.cz>
> Sent: Monday, 3 August 2015 9:55 PM
> Subject: [RFC v3 2/2] mm, compaction: make kcompactd rely on sysctl_extfrag_threshold
> 
>T he previous patch introduced kcompactd kthreads which are meant to keep
> memory fragmentation lower than what kswapd achieves through its
> reclaim/compaction activity. In order to do that, it needs a stricter criteria
> to determine when to start/stop compacting, than the standard criteria that
> try to satisfy a single next high-order allocation request. This patch
> provides such criteria with minimal changes and no new tunables.
> 
> This patch uses the existing sysctl_extfrag_threshold tunable. This tunable
> currently determines when direct compaction should stop trying to satisfy an
> allocation - that happens when a page of desired order has not been made
> available, but the fragmentation already dropped below given threshold, so we
> expect further compaction to be too costly and possibly fail anyway.
> 
> For kcompactd, we simply ignore whether the page has been available, and
> continue compacting, until fragmentation drops below the threshold (or the
> whole zone is scanned).
> 
> Not-yet-signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
> include/linux/compaction.h |  7 ++++---
> mm/compaction.c            | 37 ++++++++++++++++++++++++++-----------
> mm/internal.h              |  1 +
> mm/vmscan.c                | 10 +++++-----
> mm/vmstat.c                | 12 +++++++-----
> 5 files changed, 43 insertions(+), 24 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index 8cd1fb5..c615465 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -36,14 +36,15 @@ extern int sysctl_extfrag_handler(struct ctl_table *table, 
> int write,
>             void __user *buffer, size_t *length, loff_t *ppos);
> extern int sysctl_compact_unevictable_allowed;
> 
> -extern int fragmentation_index(struct zone *zone, unsigned int order);
> +extern int fragmentation_index(struct zone *zone, unsigned int order,

> +                            bool ignore_suitable);

We would like to retain the original fragmentation_index as it is.
Because in some cases people may be using it without kcompactd.
In such cases, future kernel upgrades will suffer.
In my opinion fragmentation_index should work just based on zones and order.

And I guess, for kcompactd, we must be definitely having CONFIG_COMPACTION_KCOMPACTD?./
> extern unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
>             int alloc_flags, const struct alloc_context *ac,
>             enum migrate_mode mode, int *contended);
> extern void compact_pgdat(pg_data_t *pgdat, int order);
> extern void reset_isolation_suitable(pg_data_t *pgdat);
> extern unsigned long compaction_suitable(struct zone *zone, int order,
> -                    int alloc_flags, int classzone_idx);
> +            int alloc_flags, int classzone_idx, bool kcompactd);
> 
> extern void defer_compaction(struct zone *zone, int order);
> extern bool compaction_deferred(struct zone *zone, int order);
> @@ -73,7 +74,7 @@ static inline void reset_isolation_suitable(pg_data_t *pgdat)
> }
> 
> static inline unsigned long compaction_suitable(struct zone *zone, int order,
> -                    int alloc_flags, int classzone_idx)
> +            int alloc_flags, int classzone_idx, bool kcompactd)
> {
>     return COMPACT_SKIPPED;
> }
> diff --git a/mm/compaction.c b/mm/compaction.c
> index b051412..62b9e51 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1183,6 +1183,19 @@ static int __compact_finished(struct zone *zone, struct 
> compact_control *cc,
>                             cc->alloc_flags))
>         return COMPACT_CONTINUE;
> 
> +    if (cc->kcompactd) {
> +        /*
> +         * kcompactd continues even if watermarks are met, until the
> +         * fragmentation index is so low that direct compaction
> +         * wouldn't be attempted
> +         */
> +        int fragindex = fragmentation_index(zone, cc->order, true);
> +        if (fragindex <= sysctl_extfrag_threshold)
> +            return COMPACT_NOT_SUITABLE_ZONE;
> +        else
> +            return COMPACT_CONTINUE;
> +    }
> +
>     /* Direct compactor: Is a suitable page free? */
>     for (order = cc->order; order < MAX_ORDER; order++) {
>         struct free_area *area = &zone->free_area[order];
> @@ -1231,7 +1244,7 @@ static int compact_finished(struct zone *zone, struct 
> compact_control *cc,
>   *   COMPACT_CONTINUE - If compaction should run now
>   */
> static unsigned long __compaction_suitable(struct zone *zone, int order,
> -                    int alloc_flags, int classzone_idx)
> +            int alloc_flags, int classzone_idx, bool kcompactd)
> {
>     int fragindex;
>     unsigned long watermark;
> @@ -1246,10 +1259,10 @@ static unsigned long __compaction_suitable(struct zone 
> *zone, int order,
>     watermark = low_wmark_pages(zone);
>     /*
>      * If watermarks for high-order allocation are already met, there
> -     * should be no need for compaction at all.
> +     * should be no need for compaction at all, unless it's kcompactd.
>      */
> -    if (zone_watermark_ok(zone, order, watermark, classzone_idx,
> -                                alloc_flags))
> +    if (!kcompactd && zone_watermark_ok(zone, order, watermark,
> +                        classzone_idx, alloc_flags))
>         return COMPACT_PARTIAL;
> 
>     /*
> @@ -1272,7 +1285,7 @@ static unsigned long __compaction_suitable(struct zone 
> *zone, int order,
>      *
>      * Only compact if a failure would be due to fragmentation.
>      */
> -    fragindex = fragmentation_index(zone, order);
> +    fragindex = fragmentation_index(zone, order, kcompactd);
>     if (fragindex >= 0 && fragindex <= sysctl_extfrag_threshold)
>         return COMPACT_NOT_SUITABLE_ZONE;
> 
> @@ -1280,11 +1293,12 @@ static unsigned long __compaction_suitable(struct zone 
> *zone, int order,
> }
> 
> unsigned long compaction_suitable(struct zone *zone, int order,
> -                    int alloc_flags, int classzone_idx)
> +            int alloc_flags, int classzone_idx, bool kcompactd)
> {
>     unsigned long ret;
> 
> -    ret = __compaction_suitable(zone, order, alloc_flags, classzone_idx);
> +    ret = __compaction_suitable(zone, order, alloc_flags, classzone_idx,
> +                                kcompactd);
>     trace_mm_compaction_suitable(zone, order, ret);
>     if (ret == COMPACT_NOT_SUITABLE_ZONE)
>         ret = COMPACT_SKIPPED;
> @@ -1302,7 +1316,7 @@ static int compact_zone(struct zone *zone, struct 
> compact_control *cc)
>     unsigned long last_migrated_pfn = 0;
> 
>     ret = compaction_suitable(zone, cc->order, cc->alloc_flags,
> -                            cc->classzone_idx);
> +                    cc->classzone_idx, cc->kcompactd);
>     switch (ret) {
>     case COMPACT_PARTIAL:
>     case COMPACT_SKIPPED:
> @@ -1731,8 +1745,8 @@ static bool kcompactd_node_suitable(pg_data_t *pgdat, int 
> order)
>     for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
>         zone = &pgdat->node_zones[zoneid];
> 
> -        if (compaction_suitable(zone, order, 0, zoneid) ==
> -                        COMPACT_CONTINUE)
> +        if (compaction_suitable(zone, order, 0, zoneid, true) ==
> +                            COMPACT_CONTINUE)
>             return true;
>     }
> 
> @@ -1750,6 +1764,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
>     struct compact_control cc = {
>         .order = pgdat->kcompactd_max_order,
>         .mode = MIGRATE_SYNC_LIGHT,
> +        .kcompactd = true,
>         //TODO: do this or not?
>         .ignore_skip_hint = true,
>     };
> @@ -1760,7 +1775,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
>         if (!populated_zone(zone))
>             continue;
> 
> -        if (compaction_suitable(zone, cc.order, 0, zoneid) !=
> +        if (compaction_suitable(zone, cc.order, 0, zoneid, true) !=
>                             COMPACT_CONTINUE)
>             continue;
> 
> diff --git a/mm/internal.h b/mm/internal.h
> index 36b23f1..2cea51a 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -184,6 +184,7 @@ struct compact_control {
>     unsigned long migrate_pfn;    /* isolate_migratepages search base */
>     enum migrate_mode mode;        /* Async or sync migration mode */
>     bool ignore_skip_hint;        /* Scan blocks even if marked skip */
> +    bool kcompactd;            /* We are in kcompactd kthread */
>     int order;            /* order a direct compactor needs */
>     const gfp_t gfp_mask;        /* gfp mask of a direct compactor */
>     const int alloc_flags;        /* alloc flags of a direct compactor */
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 075f53c..f6582b6 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2339,7 +2339,7 @@ static inline bool should_continue_reclaim(struct zone 
> *zone,
>         return true;
> 
>     /* If compaction would go ahead or the allocation would succeed, stop */
> -    switch (compaction_suitable(zone, sc->order, 0, 0)) {
> +    switch (compaction_suitable(zone, sc->order, 0, 0, false)) {
>     case COMPACT_PARTIAL:
>     case COMPACT_CONTINUE:
>         return false;
> @@ -2467,7 +2467,7 @@ static inline bool compaction_ready(struct zone *zone, int 
> order)
>      * If compaction is not ready to start and allocation is not likely
>      * to succeed without it, then keep reclaiming.
>      */
> -    if (compaction_suitable(zone, order, 0, 0) == COMPACT_SKIPPED)
> +    if (compaction_suitable(zone, order, 0, 0, false) == COMPACT_SKIPPED)
>         return false;
> 
>     return watermark_ok;
> @@ -2941,7 +2941,7 @@ static bool zone_balanced(struct zone *zone, int order,
>         return false;
> 
>     if (IS_ENABLED(CONFIG_COMPACTION) && order && 
> compaction_suitable(zone,
> -                order, 0, classzone_idx) == COMPACT_SKIPPED)
> +            order, 0, classzone_idx, false) == COMPACT_SKIPPED)
>         return false;
> 
>     return true;
> @@ -3065,8 +3065,8 @@ static bool kswapd_shrink_zone(struct zone *zone,
>      * from memory. Do not reclaim more than needed for compaction.
>      */
>     if (IS_ENABLED(CONFIG_COMPACTION) && sc->order &&
> -            compaction_suitable(zone, sc->order, 0, classzone_idx)
> -                            != COMPACT_SKIPPED)
> +            compaction_suitable(zone, sc->order, 0, classzone_idx,
> +                        false) != COMPACT_SKIPPED)
>         testorder = 0;
> 
>     /*
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 4f5cd97..9916110 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -643,7 +643,8 @@ static void fill_contig_page_info(struct zone *zone,
>   * The value can be used to determine if page reclaim or compaction
>   * should be used
>   */
> -static int __fragmentation_index(unsigned int order, struct contig_page_info 
> *info)
> +static int __fragmentation_index(unsigned int order,
> +            struct contig_page_info *info, bool ignore_suitable)
> {
>     unsigned long requested = 1UL << order;
> 
> @@ -651,7 +652,7 @@ static int __fragmentation_index(unsigned int order, struct 
> contig_page_info *in
>         return 0;
> 
>     /* Fragmentation index only makes sense when a request would fail */
> -    if (info->free_blocks_suitable)
> +    if (!ignore_suitable && info->free_blocks_suitable)
>         return -1000;
> 
>     /*
> @@ -664,12 +665,13 @@ static int __fragmentation_index(unsigned int order, 
> struct contig_page_info *in
> }
> 
> /* Same as __fragmentation index but allocs contig_page_info on stack */
> -int fragmentation_index(struct zone *zone, unsigned int order)
> +int fragmentation_index(struct zone *zone, unsigned int order,
> +                            bool ignore_suitable)
> {
>     struct contig_page_info info;
> 
>     fill_contig_page_info(zone, order, &info);
> -    return __fragmentation_index(order, &info);
> +    return __fragmentation_index(order, &info, ignore_suitable);
> }
> #endif
> 
> @@ -1635,7 +1637,7 @@ static void extfrag_show_print(struct seq_file *m,
>                 zone->name);
>     for (order = 0; order < MAX_ORDER; ++order) {
>         fill_contig_page_info(zone, order, &info);
> -        index = __fragmentation_index(order, &info);
> +        index = __fragmentation_index(order, &info, false);
>         seq_printf(m, "%d.%03d ", index / 1000, index % 1000);
> 
>     }
> 
> -- 
> 2.4.6
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> 
> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
