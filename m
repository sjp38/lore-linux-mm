Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id DC58B6B0003
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 18:29:35 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id 94-v6so383121oth.4
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 15:29:35 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r15-v6sor1238263oth.118.2018.03.20.15.29.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Mar 2018 15:29:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180320085452.24641-4-aaron.lu@intel.com>
References: <20180320085452.24641-1-aaron.lu@intel.com> <20180320085452.24641-4-aaron.lu@intel.com>
From: "Figo.zhang" <figo1802@gmail.com>
Date: Tue, 20 Mar 2018 15:29:33 -0700
Message-ID: <CAF7GXvpzgc0vsJemUYQPhPFte8b8a4nBFo=iwZBTdM1Y2eoHYw@mail.gmail.com>
Subject: Re: [RFC PATCH v2 3/4] mm/rmqueue_bulk: alloc without touching
 individual page structure
Content-Type: multipart/alternative; boundary="000000000000de61a70567df9bfd"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>

--000000000000de61a70567df9bfd
Content-Type: text/plain; charset="UTF-8"

2018-03-20 1:54 GMT-07:00 Aaron Lu <aaron.lu@intel.com>:

> Profile on Intel Skylake server shows the most time consuming part
> under zone->lock on allocation path is accessing those to-be-returned
> page's "struct page" on the free_list inside zone->lock. One explanation
> is, different CPUs are releasing pages to the head of free_list and
> those page's 'struct page' may very well be cache cold for the allocating
> CPU when it grabs these pages from free_list' head. The purpose here
> is to avoid touching these pages one by one inside zone->lock.
>
> One idea is, we just take the requested number of pages off free_list
> with something like list_cut_position() and then adjust nr_free of
> free_area accordingly inside zone->lock and other operations like
> clearing PageBuddy flag for these pages are done outside of zone->lock.
>

sounds good!
your idea is reducing the lock contention in rmqueue_bulk() function by
split the order-0
freelist into two list, one is without zone->lock, other is need zone->lock?

it seems that it is a big lock granularity holding the zone->lock in
rmqueue_bulk() ,
why not we change like it?

static int rmqueue_bulk(struct zone *zone, unsigned int order,
            unsigned long count, struct list_head *list,
            int migratetype, bool cold)
{

    for (i = 0; i < count; ++i) {
        spin_lock(&zone->lock);
        struct page *page = __rmqueue(zone, order, migratetype);
       spin_unlock(&zone->lock);
       ...
    }
    __mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));

    return i;
}


>
> list_cut_position() needs to know where to cut, that's what the new
> 'struct cluster' meant to provide. All pages on order 0's free_list
> belongs to a cluster so when a number of pages is needed, the cluster
> to which head page of free_list belongs is checked and then tail page
> of the cluster could be found. With tail page, list_cut_position() can
> be used to drop the cluster off free_list. The 'struct cluster' also has
> 'nr' to tell how many pages this cluster has so nr_free of free_area can
> be adjusted inside the lock too.
>
> This caused a race window though: from the moment zone->lock is dropped
> till these pages' PageBuddy flags get cleared, these pages are not in
> buddy but still have PageBuddy flag set.
>
> This doesn't cause problems for users that access buddy pages through
> free_list. But there are other users, like move_freepages() which is
> used to move a pageblock pages from one migratetype to another in
> fallback allocation path, will test PageBuddy flag of a page derived
> from PFN. The end result could be that for pages in the race window,
> they are moved back to free_list of another migratetype. For this
> reason, a synchronization function zone_wait_cluster_alloc() is
> introduced to wait till all pages are in correct state. This function
> is meant to be called with zone->lock held, so after this function
> returns, we do not need to worry about new pages becoming racy state.
>
> Another user is compaction, where it will scan a pageblock for
> migratable candidates. In this process, pages derived from PFN will
> be checked for PageBuddy flag to decide if it is a merge skipped page.
> To avoid a racy page getting merged back into buddy, the
> zone_wait_and_disable_cluster_alloc() function is introduced to:
> 1 disable clustered allocation by increasing zone->cluster.disable_depth;
> 2 wait till the race window pass by calling zone_wait_cluster_alloc().
> This function is also meant to be called with zone->lock held so after
> it returns, all pages are in correct state and no more cluster alloc
> will be attempted till zone_enable_cluster_alloc() is called to decrease
> zone->cluster.disable_depth.
>
> The two patches could eliminate zone->lock contention entirely but at
> the same time, pgdat->lru_lock contention rose to 82%. Final performance
> increased about 8.3%.
>
> Suggested-by: Ying Huang <ying.huang@intel.com>
> Signed-off-by: Aaron Lu <aaron.lu@intel.com>
> ---
>  Documentation/vm/struct_page_field |   5 +
>  include/linux/mm_types.h           |   2 +
>  include/linux/mmzone.h             |  35 +++++
>  mm/compaction.c                    |   4 +
>  mm/internal.h                      |  34 +++++
>  mm/page_alloc.c                    | 288 ++++++++++++++++++++++++++++++
> +++++--
>  6 files changed, 360 insertions(+), 8 deletions(-)
>
> diff --git a/Documentation/vm/struct_page_field b/Documentation/vm/struct_
> page_field
> index 1ab6c19ccc7a..bab738ea4e0a 100644
> --- a/Documentation/vm/struct_page_field
> +++ b/Documentation/vm/struct_page_field
> @@ -3,3 +3,8 @@ Used to indicate this page skipped merging when added to
> buddy. This
>  field only makes sense if the page is in Buddy and is order zero.
>  It's a bug if any higher order pages in Buddy has this field set.
>  Shares space with index.
> +
> +cluster:
> +Order 0 Buddy pages are grouped in cluster on free_list to speed up
> +allocation. This field stores the cluster pointer for them.
> +Shares space with mapping.
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 7edc4e102a8e..49fe9d755a7c 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -84,6 +84,8 @@ struct page {
>                 void *s_mem;                    /* slab first object */
>                 atomic_t compound_mapcount;     /* first tail page */
>                 /* page_deferred_list().next     -- second tail page */
> +
> +               struct cluster *cluster;        /* order 0 cluster this
> page belongs to */
>         };
>
>         /* Second double word */
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 7522a6987595..09ba9d3cc385 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -355,6 +355,40 @@ enum zone_type {
>
>  #ifndef __GENERATING_BOUNDS_H
>
> +struct cluster {
> +       struct page     *tail;  /* tail page of the cluster */
> +       int             nr;     /* how many pages are in this cluster */
> +};
> +
> +struct order0_cluster {
> +       /* order 0 cluster array, dynamically allocated */
> +       struct cluster *array;
> +       /*
> +        * order 0 cluster array length, also used to indicate if cluster
> +        * allocation is enabled for this zone(cluster allocation is
> disabled
> +        * for small zones whose batch size is smaller than 1, like DMA
> zone)
> +        */
> +       int             len;
> +       /*
> +        * smallest position from where we search for an
> +        * empty cluster from the cluster array
> +        */
> +       int             zero_bit;
> +       /* bitmap used to quickly locate an empty cluster from cluster
> array */
> +       unsigned long   *bitmap;
> +
> +       /* disable cluster allocation to avoid new pages becoming racy
> state. */
> +       unsigned long   disable_depth;
> +
> +       /*
> +        * used to indicate if there are pages allocated in cluster mode
> +        * still in racy state. Caller with zone->lock held could use
> helper
> +        * function zone_wait_cluster_alloc() to wait all such pages to
> exit
> +        * the race window.
> +        */
> +       atomic_t        in_progress;
> +};
> +
>  struct zone {
>         /* Read-mostly fields */
>
> @@ -459,6 +493,7 @@ struct zone {
>
>         /* free areas of different sizes */
>         struct free_area        free_area[MAX_ORDER];
> +       struct order0_cluster   cluster;
>
>         /* zone flags, see below */
>         unsigned long           flags;
> diff --git a/mm/compaction.c b/mm/compaction.c
> index fb9031fdca41..e71fa82786a1 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1601,6 +1601,8 @@ static enum compact_result compact_zone(struct zone
> *zone, struct compact_contro
>
>         migrate_prep_local();
>
> +       zone_wait_and_disable_cluster_alloc(zone);
> +
>         while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
>                 int err;
>
> @@ -1699,6 +1701,8 @@ static enum compact_result compact_zone(struct zone
> *zone, struct compact_contro
>                         zone->compact_cached_free_pfn = free_pfn;
>         }
>
> +       zone_enable_cluster_alloc(zone);
> +
>         count_compact_events(COMPACTMIGRATE_SCANNED,
> cc->total_migrate_scanned);
>         count_compact_events(COMPACTFREE_SCANNED, cc->total_free_scanned);
>
> diff --git a/mm/internal.h b/mm/internal.h
> index 2bfbaae2d835..1b0535af1b49 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -557,12 +557,46 @@ static inline bool can_skip_merge(struct zone *zone,
> int order)
>         if (order)
>                 return false;
>
> +       /*
> +        * Clustered allocation is only disabled when high-order pages
> +        * are needed, e.g. in compaction and CMA alloc, so we should
> +        * also skip merging in that case.
> +        */
> +       if (zone->cluster.disable_depth)
> +               return false;
> +
>         return true;
>  }
> +
> +static inline void zone_wait_cluster_alloc(struct zone *zone)
> +{
> +       while (atomic_read(&zone->cluster.in_progress))
> +               cpu_relax();
> +}
> +
> +static inline void zone_wait_and_disable_cluster_alloc(struct zone *zone)
> +{
> +       unsigned long flags;
> +       spin_lock_irqsave(&zone->lock, flags);
> +       zone->cluster.disable_depth++;
> +       zone_wait_cluster_alloc(zone);
> +       spin_unlock_irqrestore(&zone->lock, flags);
> +}
> +
> +static inline void zone_enable_cluster_alloc(struct zone *zone)
> +{
> +       unsigned long flags;
> +       spin_lock_irqsave(&zone->lock, flags);
> +       zone->cluster.disable_depth--;
> +       spin_unlock_irqrestore(&zone->lock, flags);
> +}
>  #else /* CONFIG_COMPACTION */
>  static inline bool can_skip_merge(struct zone *zone, int order)
>  {
>         return false;
>  }
> +static inline void zone_wait_cluster_alloc(struct zone *zone) {}
> +static inline void zone_wait_and_disable_cluster_alloc(struct zone
> *zone) {}
> +static inline void zone_enable_cluster_alloc(struct zone *zone) {}
>  #endif  /* CONFIG_COMPACTION */
>  #endif /* __MM_INTERNAL_H */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index eb78014dfbde..ac93833a2877 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -746,6 +746,82 @@ static inline void set_page_order(struct page *page,
> unsigned int order)
>         __SetPageBuddy(page);
>  }
>
> +static inline struct cluster *new_cluster(struct zone *zone, int nr,
> +                                               struct page *tail)
> +{
> +       struct order0_cluster *cluster = &zone->cluster;
> +       int n = find_next_zero_bit(cluster->bitmap, cluster->len,
> cluster->zero_bit);
> +       if (n == cluster->len) {
> +               printk_ratelimited("node%d zone %s cluster used up\n",
> +                               zone->zone_pgdat->node_id, zone->name);
> +               return NULL;
> +       }
> +       cluster->zero_bit = n;
> +       set_bit(n, cluster->bitmap);
> +       cluster->array[n].nr = nr;
> +       cluster->array[n].tail = tail;
> +       return &cluster->array[n];
> +}
> +
> +static inline struct cluster *add_to_cluster_common(struct page *page,
> +                       struct zone *zone, struct page *neighbor)
> +{
> +       struct cluster *c;
> +
> +       if (neighbor) {
> +               int batch = this_cpu_ptr(zone->pageset)->pcp.batch;
> +               c = neighbor->cluster;
> +               if (c && c->nr < batch) {
> +                       page->cluster = c;
> +                       c->nr++;
> +                       return c;
> +               }
> +       }
> +
> +       c = new_cluster(zone, 1, page);
> +       if (unlikely(!c))
> +               return NULL;
> +
> +       page->cluster = c;
> +       return c;
> +}
> +
> +/*
> + * Add this page to the cluster where the previous head page belongs.
> + * Called after page is added to free_list(and becoming the new head).
> + */
> +static inline void add_to_cluster_head(struct page *page, struct zone
> *zone,
> +                                      int order, int mt)
> +{
> +       struct page *neighbor;
> +
> +       if (order || !zone->cluster.len)
> +               return;
> +
> +       neighbor = page->lru.next == &zone->free_area[0].free_list[mt] ?
> +                  NULL : list_entry(page->lru.next, struct page, lru);
> +       add_to_cluster_common(page, zone, neighbor);
> +}
> +
> +/*
> + * Add this page to the cluster where the previous tail page belongs.
> + * Called after page is added to free_list(and becoming the new tail).
> + */
> +static inline void add_to_cluster_tail(struct page *page, struct zone
> *zone,
> +                                      int order, int mt)
> +{
> +       struct page *neighbor;
> +       struct cluster *c;
> +
> +       if (order || !zone->cluster.len)
> +               return;
> +
> +       neighbor = page->lru.prev == &zone->free_area[0].free_list[mt] ?
> +                  NULL : list_entry(page->lru.prev, struct page, lru);
> +       c = add_to_cluster_common(page, zone, neighbor);
> +       c->tail = page;
> +}
> +
>  static inline void add_to_buddy_common(struct page *page, struct zone
> *zone,
>                                         unsigned int order, int mt)
>  {
> @@ -765,6 +841,7 @@ static inline void add_to_buddy_head(struct page
> *page, struct zone *zone,
>  {
>         add_to_buddy_common(page, zone, order, mt);
>         list_add(&page->lru, &zone->free_area[order].free_list[mt]);
> +       add_to_cluster_head(page, zone, order, mt);
>  }
>
>  static inline void add_to_buddy_tail(struct page *page, struct zone *zone,
> @@ -772,6 +849,7 @@ static inline void add_to_buddy_tail(struct page
> *page, struct zone *zone,
>  {
>         add_to_buddy_common(page, zone, order, mt);
>         list_add_tail(&page->lru, &zone->free_area[order].free_list[mt]);
> +       add_to_cluster_tail(page, zone, order, mt);
>  }
>
>  static inline void rmv_page_order(struct page *page)
> @@ -780,9 +858,29 @@ static inline void rmv_page_order(struct page *page)
>         set_page_private(page, 0);
>  }
>
> +/* called before removed from free_list */
> +static inline void remove_from_cluster(struct page *page, struct zone
> *zone)
> +{
> +       struct cluster *c = page->cluster;
> +       if (!c)
> +               return;
> +
> +       page->cluster = NULL;
> +       c->nr--;
> +       if (!c->nr) {
> +               int bit = c - zone->cluster.array;
> +               c->tail = NULL;
> +               clear_bit(bit, zone->cluster.bitmap);
> +               if (bit < zone->cluster.zero_bit)
> +                       zone->cluster.zero_bit = bit;
> +       } else if (page == c->tail)
> +               c->tail = list_entry(page->lru.prev, struct page, lru);
> +}
> +
>  static inline void remove_from_buddy(struct page *page, struct zone *zone,
>                                         unsigned int order)
>  {
> +       remove_from_cluster(page, zone);
>         list_del(&page->lru);
>         zone->free_area[order].nr_free--;
>         rmv_page_order(page);
> @@ -2025,6 +2123,17 @@ static int move_freepages(struct zone *zone,
>         if (num_movable)
>                 *num_movable = 0;
>
> +       /*
> +        * Cluster alloced pages may have their PageBuddy flag unclear yet
> +        * after dropping zone->lock in rmqueue_bulk() and steal here could
> +        * move them back to free_list. So it's necessary to wait till all
> +        * those pages have their flags properly cleared.
> +        *
> +        * We do not need to disable cluster alloc though since we already
> +        * held zone->lock and no allocation could happen.
> +        */
> +       zone_wait_cluster_alloc(zone);
> +
>         for (page = start_page; page <= end_page;) {
>                 if (!pfn_valid_within(page_to_pfn(page))) {
>                         page++;
> @@ -2049,8 +2158,10 @@ static int move_freepages(struct zone *zone,
>                 }
>
>                 order = page_order(page);
> +               remove_from_cluster(page, zone);
>                 list_move(&page->lru,
>                           &zone->free_area[order].free_list[migratetype]);
> +               add_to_cluster_head(page, zone, order, migratetype);
>                 page += 1 << order;
>                 pages_moved += 1 << order;
>         }
> @@ -2199,7 +2310,9 @@ static void steal_suitable_fallback(struct zone
> *zone, struct page *page,
>
>  single_page:
>         area = &zone->free_area[current_order];
> +       remove_from_cluster(page, zone);
>         list_move(&page->lru, &area->free_list[start_type]);
> +       add_to_cluster_head(page, zone, current_order, start_type);
>  }
>
>  /*
> @@ -2460,6 +2573,145 @@ __rmqueue(struct zone *zone, unsigned int order,
> int migratetype)
>         return page;
>  }
>
> +static int __init zone_order0_cluster_init(void)
> +{
> +       struct zone *zone;
> +
> +       for_each_zone(zone) {
> +               int len, mt, batch;
> +               unsigned long flags;
> +               struct order0_cluster *cluster;
> +
> +               if (!managed_zone(zone))
> +                       continue;
> +
> +               /* no need to enable cluster allocation for batch<=1 zone
> */
> +               preempt_disable();
> +               batch = this_cpu_ptr(zone->pageset)->pcp.batch;
> +               preempt_enable();
> +               if (batch <= 1)
> +                       continue;
> +
> +               cluster = &zone->cluster;
> +               /* FIXME: possible overflow of int type */
> +               len = DIV_ROUND_UP(zone->managed_pages, batch);
> +               cluster->array = vzalloc(len * sizeof(struct cluster));
> +               if (!cluster->array)
> +                       return -ENOMEM;
> +               cluster->bitmap = vzalloc(DIV_ROUND_UP(len, BITS_PER_LONG)
> *
> +                               sizeof(unsigned long));
> +               if (!cluster->bitmap)
> +                       return -ENOMEM;
> +
> +               spin_lock_irqsave(&zone->lock, flags);
> +               cluster->len = len;
> +               for (mt = 0; mt < MIGRATE_PCPTYPES; mt++) {
> +                       struct page *page;
> +                       list_for_each_entry_reverse(page,
> +                                       &zone->free_area[0].free_list[mt],
> lru)
> +                               add_to_cluster_head(page, zone, 0, mt);
> +               }
> +               spin_unlock_irqrestore(&zone->lock, flags);
> +       }
> +
> +       return 0;
> +}
> +subsys_initcall(zone_order0_cluster_init);
> +
> +static inline int __rmqueue_bulk_cluster(struct zone *zone, unsigned long
> count,
> +                                               struct list_head *list,
> int mt)
> +{
> +       struct list_head *head = &zone->free_area[0].free_list[mt];
> +       int nr = 0;
> +
> +       while (nr < count) {
> +               struct page *head_page;
> +               struct list_head *tail, tmp_list;
> +               struct cluster *c;
> +               int bit;
> +
> +               head_page = list_first_entry_or_null(head, struct page,
> lru);
> +               if (!head_page || !head_page->cluster)
> +                       break;
> +
> +               c = head_page->cluster;
> +               tail = &c->tail->lru;
> +
> +               /* drop the cluster off free_list and attach to list */
> +               list_cut_position(&tmp_list, head, tail);
> +               list_splice_tail(&tmp_list, list);
> +
> +               nr += c->nr;
> +               zone->free_area[0].nr_free -= c->nr;
> +
> +               /* this cluster is empty now */
> +               c->tail = NULL;
> +               c->nr = 0;
> +               bit = c - zone->cluster.array;
> +               clear_bit(bit, zone->cluster.bitmap);
> +               if (bit < zone->cluster.zero_bit)
> +                       zone->cluster.zero_bit = bit;
> +       }
> +
> +       return nr;
> +}
> +
> +static inline int rmqueue_bulk_cluster(struct zone *zone, unsigned int
> order,
> +                               unsigned long count, struct list_head
> *list,
> +                               int migratetype)
> +{
> +       int alloced;
> +       struct page *page;
> +
> +       /*
> +        * Cluster alloc races with merging so don't try cluster alloc
> when we
> +        * can't skip merging. Note that can_skip_merge() keeps the same
> return
> +        * value from here till all pages have their flags properly
> processed,
> +        * i.e. the end of the function where in_progress is incremented,
> even
> +        * we have dropped the lock in the middle because the only place
> that
> +        * can change can_skip_merge()'s return value is compaction code
> and
> +        * compaction needs to wait on in_progress.
> +        */
> +       if (!can_skip_merge(zone, 0))
> +               return 0;
> +
> +       /* Cluster alloc is disabled, mostly compaction is already in
> progress */
> +       if (zone->cluster.disable_depth)
> +               return 0;
> +
> +       /* Cluster alloc is disabled for this zone */
> +       if (unlikely(!zone->cluster.len))
> +               return 0;
> +
> +       alloced = __rmqueue_bulk_cluster(zone, count, list, migratetype);
> +       if (!alloced)
> +               return 0;
> +
> +       /*
> +        * Cache miss on page structure could slow things down
> +        * dramatically so accessing these alloced pages without
> +        * holding lock for better performance.
> +        *
> +        * Since these pages still have PageBuddy set, there is a race
> +        * window between now and when PageBuddy is cleared for them
> +        * below. Any operation that would scan a pageblock and check
> +        * PageBuddy(page), e.g. compaction, will need to wait till all
> +        * such pages are properly processed. in_progress is used for
> +        * such purpose so increase it now before dropping the lock.
> +        */
> +       atomic_inc(&zone->cluster.in_progress);
> +       spin_unlock(&zone->lock);
> +
> +       list_for_each_entry(page, list, lru) {
> +               rmv_page_order(page);
> +               page->cluster = NULL;
> +               set_pcppage_migratetype(page, migratetype);
> +       }
> +       atomic_dec(&zone->cluster.in_progress);
> +
> +       return alloced;
> +}
> +
>  /*
>   * Obtain a specified number of elements from the buddy allocator, all
> under
>   * a single hold of the lock, for efficiency.  Add them to the supplied
> list.
> @@ -2469,17 +2721,23 @@ static int rmqueue_bulk(struct zone *zone,
> unsigned int order,
>                         unsigned long count, struct list_head *list,
>                         int migratetype)
>  {
> -       int i, alloced = 0;
> +       int i, alloced;
> +       struct page *page, *tmp;
>
>         spin_lock(&zone->lock);
> -       for (i = 0; i < count; ++i) {
> -               struct page *page = __rmqueue(zone, order, migratetype);
> +       alloced = rmqueue_bulk_cluster(zone, order, count, list,
> migratetype);
> +       if (alloced > 0) {
> +               if (alloced >= count)
> +                       goto out;
> +               else
> +                       spin_lock(&zone->lock);
> +       }
> +
> +       for (; alloced < count; alloced++) {
> +               page = __rmqueue(zone, order, migratetype);
>                 if (unlikely(page == NULL))
>                         break;
>
> -               if (unlikely(check_pcp_refill(page)))
> -                       continue;
> -
>                 /*
>                  * Split buddy pages returned by expand() are received
> here in
>                  * physical page order. The page is added to the tail of
> @@ -2491,7 +2749,18 @@ static int rmqueue_bulk(struct zone *zone, unsigned
> int order,
>                  * pages are ordered properly.
>                  */
>                 list_add_tail(&page->lru, list);
> -               alloced++;
> +       }
> +       spin_unlock(&zone->lock);
> +
> +out:
> +       i = alloced;
> +       list_for_each_entry_safe(page, tmp, list, lru) {
> +               if (unlikely(check_pcp_refill(page))) {
> +                       list_del(&page->lru);
> +                       alloced--;
> +                       continue;
> +               }
> +
>                 if (is_migrate_cma(get_pcppage_migratetype(page)))
>                         __mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
>                                               -(1 << order));
> @@ -2504,7 +2773,6 @@ static int rmqueue_bulk(struct zone *zone, unsigned
> int order,
>          * pages added to the pcp list.
>          */
>         __mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
> -       spin_unlock(&zone->lock);
>         return alloced;
>  }
>
> @@ -7744,6 +8012,7 @@ int alloc_contig_range(unsigned long start, unsigned
> long end,
>         unsigned long outer_start, outer_end;
>         unsigned int order;
>         int ret = 0;
> +       struct zone *zone = page_zone(pfn_to_page(start));
>
>         struct compact_control cc = {
>                 .nr_migratepages = 0,
> @@ -7786,6 +8055,7 @@ int alloc_contig_range(unsigned long start, unsigned
> long end,
>         if (ret)
>                 return ret;
>
> +       zone_wait_and_disable_cluster_alloc(zone);
>         /*
>          * In case of -EBUSY, we'd like to know which page causes problem.
>          * So, just fall through. test_pages_isolated() has a tracepoint
> @@ -7868,6 +8138,8 @@ int alloc_contig_range(unsigned long start, unsigned
> long end,
>  done:
>         undo_isolate_page_range(pfn_max_align_down(start),
>                                 pfn_max_align_up(end), migratetype);
> +
> +       zone_enable_cluster_alloc(zone);
>         return ret;
>  }
>
> --
> 2.14.3
>
>

--000000000000de61a70567df9bfd
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">2018-03-20 1:54 GMT-07:00 Aaron Lu <span dir=3D"ltr">&lt;<a href=3D"mai=
lto:aaron.lu@intel.com" target=3D"_blank">aaron.lu@intel.com</a>&gt;</span>=
:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-le=
ft:1px #ccc solid;padding-left:1ex">Profile on Intel Skylake server shows t=
he most time consuming part<br>
under zone-&gt;lock on allocation path is accessing those to-be-returned<br=
>
page&#39;s &quot;struct page&quot; on the free_list inside zone-&gt;lock. O=
ne explanation<br>
is, different CPUs are releasing pages to the head of free_list and<br>
those page&#39;s &#39;struct page&#39; may very well be cache cold for the =
allocating<br>
CPU when it grabs these pages from free_list&#39; head. The purpose here<br=
>
is to avoid touching these pages one by one inside zone-&gt;lock.<br>
<br>
One idea is, we just take the requested number of pages off free_list<br>
with something like list_cut_position() and then adjust nr_free of<br>
free_area accordingly inside zone-&gt;lock and other operations like<br>
clearing PageBuddy flag for these pages are done outside of zone-&gt;lock.<=
br></blockquote><div><br></div><div>

<span style=3D"color:rgb(34,34,34);font-family:arial,sans-serif;font-size:s=
mall;font-style:normal;font-variant-ligatures:normal;font-variant-caps:norm=
al;font-weight:400;letter-spacing:normal;text-align:start;text-indent:0px;t=
ext-transform:none;white-space:normal;word-spacing:0px;background-color:rgb=
(255,255,255);text-decoration-style:initial;text-decoration-color:initial;f=
loat:none;display:inline">sounds good!<span>=C2=A0</span></span><br style=
=3D"color:rgb(34,34,34);font-family:arial,sans-serif;font-size:small;font-s=
tyle:normal;font-variant-ligatures:normal;font-variant-caps:normal;font-wei=
ght:400;letter-spacing:normal;text-align:start;text-indent:0px;text-transfo=
rm:none;white-space:normal;word-spacing:0px;background-color:rgb(255,255,25=
5);text-decoration-style:initial;text-decoration-color:initial"><span style=
=3D"color:rgb(34,34,34);font-family:arial,sans-serif;font-size:small;font-s=
tyle:normal;font-variant-ligatures:normal;font-variant-caps:normal;font-wei=
ght:400;letter-spacing:normal;text-align:start;text-indent:0px;text-transfo=
rm:none;white-space:normal;word-spacing:0px;background-color:rgb(255,255,25=
5);text-decoration-style:initial;text-decoration-color:initial;float:none;d=
isplay:inline">your idea is reducing the lock contention in rmqueue_bulk() =
function by split the order-0</span><br style=3D"color:rgb(34,34,34);font-f=
amily:arial,sans-serif;font-size:small;font-style:normal;font-variant-ligat=
ures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:normal;=
text-align:start;text-indent:0px;text-transform:none;white-space:normal;wor=
d-spacing:0px;background-color:rgb(255,255,255);text-decoration-style:initi=
al;text-decoration-color:initial"><span style=3D"color:rgb(34,34,34);font-f=
amily:arial,sans-serif;font-size:small;font-style:normal;font-variant-ligat=
ures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:normal;=
text-align:start;text-indent:0px;text-transform:none;white-space:normal;wor=
d-spacing:0px;background-color:rgb(255,255,255);text-decoration-style:initi=
al;text-decoration-color:initial;float:none;display:inline">freelist into t=
wo list, one is without zone-&gt;lock, other is need zone-&gt;lock?</span><=
br style=3D"color:rgb(34,34,34);font-family:arial,sans-serif;font-size:smal=
l;font-style:normal;font-variant-ligatures:normal;font-variant-caps:normal;=
font-weight:400;letter-spacing:normal;text-align:start;text-indent:0px;text=
-transform:none;white-space:normal;word-spacing:0px;background-color:rgb(25=
5,255,255);text-decoration-style:initial;text-decoration-color:initial"><br=
 style=3D"color:rgb(34,34,34);font-family:arial,sans-serif;font-size:small;=
font-style:normal;font-variant-ligatures:normal;font-variant-caps:normal;fo=
nt-weight:400;letter-spacing:normal;text-align:start;text-indent:0px;text-t=
ransform:none;white-space:normal;word-spacing:0px;background-color:rgb(255,=
255,255);text-decoration-style:initial;text-decoration-color:initial"><span=
 style=3D"color:rgb(34,34,34);font-family:arial,sans-serif;font-size:small;=
font-style:normal;font-variant-ligatures:normal;font-variant-caps:normal;fo=
nt-weight:400;letter-spacing:normal;text-align:start;text-indent:0px;text-t=
ransform:none;white-space:normal;word-spacing:0px;background-color:rgb(255,=
255,255);text-decoration-style:initial;text-decoration-color:initial;float:=
none;display:inline">it seems that it is a big lock granularity holding the=
 zone-&gt;lock in rmqueue_bulk() ,</span><br style=3D"color:rgb(34,34,34);f=
ont-family:arial,sans-serif;font-size:small;font-style:normal;font-variant-=
ligatures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:no=
rmal;text-align:start;text-indent:0px;text-transform:none;white-space:norma=
l;word-spacing:0px;background-color:rgb(255,255,255);text-decoration-style:=
initial;text-decoration-color:initial"><span style=3D"color:rgb(34,34,34);f=
ont-family:arial,sans-serif;font-size:small;font-style:normal;font-variant-=
ligatures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:no=
rmal;text-align:start;text-indent:0px;text-transform:none;white-space:norma=
l;word-spacing:0px;background-color:rgb(255,255,255);text-decoration-style:=
initial;text-decoration-color:initial;float:none;display:inline">why not we=
 change like it?</span><br style=3D"color:rgb(34,34,34);font-family:arial,s=
ans-serif;font-size:small;font-style:normal;font-variant-ligatures:normal;f=
ont-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:st=
art;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0px=
;background-color:rgb(255,255,255);text-decoration-style:initial;text-decor=
ation-color:initial"><br style=3D"color:rgb(34,34,34);font-family:arial,san=
s-serif;font-size:small;font-style:normal;font-variant-ligatures:normal;fon=
t-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:star=
t;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0px;b=
ackground-color:rgb(255,255,255);text-decoration-style:initial;text-decorat=
ion-color:initial"><span style=3D"color:rgb(34,34,34);font-family:arial,san=
s-serif;font-size:small;font-style:normal;font-variant-ligatures:normal;fon=
t-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:star=
t;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0px;b=
ackground-color:rgb(255,255,255);text-decoration-style:initial;text-decorat=
ion-color:initial;float:none;display:inline">static int rmqueue_bulk(struct=
 zone *zone, unsigned int order,</span><br style=3D"color:rgb(34,34,34);fon=
t-family:arial,sans-serif;font-size:small;font-style:normal;font-variant-li=
gatures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:norm=
al;text-align:start;text-indent:0px;text-transform:none;white-space:normal;=
word-spacing:0px;background-color:rgb(255,255,255);text-decoration-style:in=
itial;text-decoration-color:initial"><span style=3D"color:rgb(34,34,34);fon=
t-family:arial,sans-serif;font-size:small;font-style:normal;font-variant-li=
gatures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:norm=
al;text-align:start;text-indent:0px;text-transform:none;white-space:normal;=
word-spacing:0px;background-color:rgb(255,255,255);text-decoration-style:in=
itial;text-decoration-color:initial;float:none;display:inline">=C2=A0=C2=A0=
=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 unsigned long count, struct li=
st_head *list,</span><br style=3D"color:rgb(34,34,34);font-family:arial,san=
s-serif;font-size:small;font-style:normal;font-variant-ligatures:normal;fon=
t-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:star=
t;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0px;b=
ackground-color:rgb(255,255,255);text-decoration-style:initial;text-decorat=
ion-color:initial"><span style=3D"color:rgb(34,34,34);font-family:arial,san=
s-serif;font-size:small;font-style:normal;font-variant-ligatures:normal;fon=
t-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:star=
t;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0px;b=
ackground-color:rgb(255,255,255);text-decoration-style:initial;text-decorat=
ion-color:initial;float:none;display:inline">=C2=A0=C2=A0=C2=A0 =C2=A0=C2=
=A0=C2=A0 =C2=A0=C2=A0=C2=A0 int migratetype, bool cold)</span><br style=3D=
"color:rgb(34,34,34);font-family:arial,sans-serif;font-size:small;font-styl=
e:normal;font-variant-ligatures:normal;font-variant-caps:normal;font-weight=
:400;letter-spacing:normal;text-align:start;text-indent:0px;text-transform:=
none;white-space:normal;word-spacing:0px;background-color:rgb(255,255,255);=
text-decoration-style:initial;text-decoration-color:initial"><span style=3D=
"color:rgb(34,34,34);font-family:arial,sans-serif;font-size:small;font-styl=
e:normal;font-variant-ligatures:normal;font-variant-caps:normal;font-weight=
:400;letter-spacing:normal;text-align:start;text-indent:0px;text-transform:=
none;white-space:normal;word-spacing:0px;background-color:rgb(255,255,255);=
text-decoration-style:initial;text-decoration-color:initial;float:none;disp=
lay:inline">{</span><br style=3D"color:rgb(34,34,34);font-family:arial,sans=
-serif;font-size:small;font-style:normal;font-variant-ligatures:normal;font=
-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:start=
;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0px;ba=
ckground-color:rgb(255,255,255);text-decoration-style:initial;text-decorati=
on-color:initial"><span style=3D"color:rgb(34,34,34);font-family:arial,sans=
-serif;font-size:small;font-style:normal;font-variant-ligatures:normal;font=
-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:start=
;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0px;ba=
ckground-color:rgb(255,255,255);text-decoration-style:initial;text-decorati=
on-color:initial;float:none;display:inline">=C2=A0=C2=A0=C2=A0<span>=C2=A0<=
/span></span><br style=3D"color:rgb(34,34,34);font-family:arial,sans-serif;=
font-size:small;font-style:normal;font-variant-ligatures:normal;font-varian=
t-caps:normal;font-weight:400;letter-spacing:normal;text-align:start;text-i=
ndent:0px;text-transform:none;white-space:normal;word-spacing:0px;backgroun=
d-color:rgb(255,255,255);text-decoration-style:initial;text-decoration-colo=
r:initial"><span style=3D"color:rgb(34,34,34);font-family:arial,sans-serif;=
font-size:small;font-style:normal;font-variant-ligatures:normal;font-varian=
t-caps:normal;font-weight:400;letter-spacing:normal;text-align:start;text-i=
ndent:0px;text-transform:none;white-space:normal;word-spacing:0px;backgroun=
d-color:rgb(255,255,255);text-decoration-style:initial;text-decoration-colo=
r:initial;float:none;display:inline">=C2=A0=C2=A0=C2=A0 for (i =3D 0; i &lt=
; count; ++i) {</span><br style=3D"color:rgb(34,34,34);font-family:arial,sa=
ns-serif;font-size:small;font-style:normal;font-variant-ligatures:normal;fo=
nt-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:sta=
rt;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0px;=
background-color:rgb(255,255,255);text-decoration-style:initial;text-decora=
tion-color:initial"><span style=3D"color:rgb(34,34,34);font-family:arial,sa=
ns-serif;font-size:small;font-style:normal;font-variant-ligatures:normal;fo=
nt-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:sta=
rt;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0px;=
background-color:rgb(255,255,255);text-decoration-style:initial;text-decora=
tion-color:initial;float:none;display:inline">=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 =C2=A0 spin_lock(&amp;zone-&gt;lock);</span><br style=3D"color:rgb(34,3=
4,34);font-family:arial,sans-serif;font-size:small;font-style:normal;font-v=
ariant-ligatures:normal;font-variant-caps:normal;font-weight:400;letter-spa=
cing:normal;text-align:start;text-indent:0px;text-transform:none;white-spac=
e:normal;word-spacing:0px;background-color:rgb(255,255,255);text-decoration=
-style:initial;text-decoration-color:initial"><span style=3D"color:rgb(34,3=
4,34);font-family:arial,sans-serif;font-size:small;font-style:normal;font-v=
ariant-ligatures:normal;font-variant-caps:normal;font-weight:400;letter-spa=
cing:normal;text-align:start;text-indent:0px;text-transform:none;white-spac=
e:normal;word-spacing:0px;background-color:rgb(255,255,255);text-decoration=
-style:initial;text-decoration-color:initial;float:none;display:inline">=C2=
=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 struct page *page =3D __rmqueue(zone, or=
der, migratetype);</span><br style=3D"color:rgb(34,34,34);font-family:arial=
,sans-serif;font-size:small;font-style:normal;font-variant-ligatures:normal=
;font-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:=
start;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0=
px;background-color:rgb(255,255,255);text-decoration-style:initial;text-dec=
oration-color:initial"><span style=3D"color:rgb(34,34,34);font-family:arial=
,sans-serif;font-size:small;font-style:normal;font-variant-ligatures:normal=
;font-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:=
start;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0=
px;background-color:rgb(255,255,255);text-decoration-style:initial;text-dec=
oration-color:initial;float:none;display:inline">=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 spin_unlock(&amp;zone-&gt;lock);</span><br style=3D"color:rgb(=
34,34,34);font-family:arial,sans-serif;font-size:small;font-style:normal;fo=
nt-variant-ligatures:normal;font-variant-caps:normal;font-weight:400;letter=
-spacing:normal;text-align:start;text-indent:0px;text-transform:none;white-=
space:normal;word-spacing:0px;background-color:rgb(255,255,255);text-decora=
tion-style:initial;text-decoration-color:initial"><span style=3D"color:rgb(=
34,34,34);font-family:arial,sans-serif;font-size:small;font-style:normal;fo=
nt-variant-ligatures:normal;font-variant-caps:normal;font-weight:400;letter=
-spacing:normal;text-align:start;text-indent:0px;text-transform:none;white-=
space:normal;word-spacing:0px;background-color:rgb(255,255,255);text-decora=
tion-style:initial;text-decoration-color:initial;float:none;display:inline"=
>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ...</span><br style=3D"color:rgb(34,3=
4,34);font-family:arial,sans-serif;font-size:small;font-style:normal;font-v=
ariant-ligatures:normal;font-variant-caps:normal;font-weight:400;letter-spa=
cing:normal;text-align:start;text-indent:0px;text-transform:none;white-spac=
e:normal;word-spacing:0px;background-color:rgb(255,255,255);text-decoration=
-style:initial;text-decoration-color:initial"><span style=3D"color:rgb(34,3=
4,34);font-family:arial,sans-serif;font-size:small;font-style:normal;font-v=
ariant-ligatures:normal;font-variant-caps:normal;font-weight:400;letter-spa=
cing:normal;text-align:start;text-indent:0px;text-transform:none;white-spac=
e:normal;word-spacing:0px;background-color:rgb(255,255,255);text-decoration=
-style:initial;text-decoration-color:initial;float:none;display:inline">=C2=
=A0=C2=A0=C2=A0 }</span><br style=3D"color:rgb(34,34,34);font-family:arial,=
sans-serif;font-size:small;font-style:normal;font-variant-ligatures:normal;=
font-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:s=
tart;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0p=
x;background-color:rgb(255,255,255);text-decoration-style:initial;text-deco=
ration-color:initial"><span style=3D"color:rgb(34,34,34);font-family:arial,=
sans-serif;font-size:small;font-style:normal;font-variant-ligatures:normal;=
font-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:s=
tart;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0p=
x;background-color:rgb(255,255,255);text-decoration-style:initial;text-deco=
ration-color:initial;float:none;display:inline">=C2=A0=C2=A0=C2=A0 __mod_zo=
ne_page_state(zone, NR_FREE_PAGES, -(i &lt;&lt; order));</span><br style=3D=
"color:rgb(34,34,34);font-family:arial,sans-serif;font-size:small;font-styl=
e:normal;font-variant-ligatures:normal;font-variant-caps:normal;font-weight=
:400;letter-spacing:normal;text-align:start;text-indent:0px;text-transform:=
none;white-space:normal;word-spacing:0px;background-color:rgb(255,255,255);=
text-decoration-style:initial;text-decoration-color:initial"><span style=3D=
"color:rgb(34,34,34);font-family:arial,sans-serif;font-size:small;font-styl=
e:normal;font-variant-ligatures:normal;font-variant-caps:normal;font-weight=
:400;letter-spacing:normal;text-align:start;text-indent:0px;text-transform:=
none;white-space:normal;word-spacing:0px;background-color:rgb(255,255,255);=
text-decoration-style:initial;text-decoration-color:initial;float:none;disp=
lay:inline">=C2=A0=C2=A0=C2=A0<span>=C2=A0</span></span><br style=3D"color:=
rgb(34,34,34);font-family:arial,sans-serif;font-size:small;font-style:norma=
l;font-variant-ligatures:normal;font-variant-caps:normal;font-weight:400;le=
tter-spacing:normal;text-align:start;text-indent:0px;text-transform:none;wh=
ite-space:normal;word-spacing:0px;background-color:rgb(255,255,255);text-de=
coration-style:initial;text-decoration-color:initial"><span style=3D"color:=
rgb(34,34,34);font-family:arial,sans-serif;font-size:small;font-style:norma=
l;font-variant-ligatures:normal;font-variant-caps:normal;font-weight:400;le=
tter-spacing:normal;text-align:start;text-indent:0px;text-transform:none;wh=
ite-space:normal;word-spacing:0px;background-color:rgb(255,255,255);text-de=
coration-style:initial;text-decoration-color:initial;float:none;display:inl=
ine">=C2=A0=C2=A0=C2=A0 return i;</span><br style=3D"color:rgb(34,34,34);fo=
nt-family:arial,sans-serif;font-size:small;font-style:normal;font-variant-l=
igatures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:nor=
mal;text-align:start;text-indent:0px;text-transform:none;white-space:normal=
;word-spacing:0px;background-color:rgb(255,255,255);text-decoration-style:i=
nitial;text-decoration-color:initial"><span style=3D"color:rgb(34,34,34);fo=
nt-family:arial,sans-serif;font-size:small;font-style:normal;font-variant-l=
igatures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:nor=
mal;text-align:start;text-indent:0px;text-transform:none;white-space:normal=
;word-spacing:0px;background-color:rgb(255,255,255);text-decoration-style:i=
nitial;text-decoration-color:initial;float:none;display:inline">}</span>=C2=
=A0</div><div>=C2=A0
=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bo=
rder-left:1px #ccc solid;padding-left:1ex">
<br>
list_cut_position() needs to know where to cut, that&#39;s what the new<br>
&#39;struct cluster&#39; meant to provide. All pages on order 0&#39;s free_=
list<br>
belongs to a cluster so when a number of pages is needed, the cluster<br>
to which head page of free_list belongs is checked and then tail page<br>
of the cluster could be found. With tail page, list_cut_position() can<br>
be used to drop the cluster off free_list. The &#39;struct cluster&#39; als=
o has<br>
&#39;nr&#39; to tell how many pages this cluster has so nr_free of free_are=
a can<br>
be adjusted inside the lock too.<br>
<br>
This caused a race window though: from the moment zone-&gt;lock is dropped<=
br>
till these pages&#39; PageBuddy flags get cleared, these pages are not in<b=
r>
buddy but still have PageBuddy flag set.<br>
<br>
This doesn&#39;t cause problems for users that access buddy pages through<b=
r>
free_list. But there are other users, like move_freepages() which is<br>
used to move a pageblock pages from one migratetype to another in<br>
fallback allocation path, will test PageBuddy flag of a page derived<br>
from PFN. The end result could be that for pages in the race window,<br>
they are moved back to free_list of another migratetype. For this<br>
reason, a synchronization function zone_wait_cluster_alloc() is<br>
introduced to wait till all pages are in correct state. This function<br>
is meant to be called with zone-&gt;lock held, so after this function<br>
returns, we do not need to worry about new pages becoming racy state.<br>
<br>
Another user is compaction, where it will scan a pageblock for<br>
migratable candidates. In this process, pages derived from PFN will<br>
be checked for PageBuddy flag to decide if it is a merge skipped page.<br>
To avoid a racy page getting merged back into buddy, the<br>
zone_wait_and_disable_cluster_<wbr>alloc() function is introduced to:<br>
1 disable clustered allocation by increasing zone-&gt;cluster.disable_depth=
;<br>
2 wait till the race window pass by calling zone_wait_cluster_alloc().<br>
This function is also meant to be called with zone-&gt;lock held so after<b=
r>
it returns, all pages are in correct state and no more cluster alloc<br>
will be attempted till zone_enable_cluster_alloc() is called to decrease<br=
>
zone-&gt;cluster.disable_depth.<br>
<br>
The two patches could eliminate zone-&gt;lock contention entirely but at<br=
>
the same time, pgdat-&gt;lru_lock contention rose to 82%. Final performance=
<br>
increased about 8.3%.<br>
<br>
Suggested-by: Ying Huang &lt;<a href=3D"mailto:ying.huang@intel.com">ying.h=
uang@intel.com</a>&gt;<br>
Signed-off-by: Aaron Lu &lt;<a href=3D"mailto:aaron.lu@intel.com">aaron.lu@=
intel.com</a>&gt;<br>
---<br>
=C2=A0Documentation/vm/struct_page_<wbr>field |=C2=A0 =C2=A05 +<br>
=C2=A0include/linux/mm_types.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=
=A0 =C2=A02 +<br>
=C2=A0include/linux/mmzone.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0|=C2=A0 35 +++++<br>
=C2=A0mm/compaction.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A04 +<br>
=C2=A0mm/internal.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 |=C2=A0 34 +++++<br>
=C2=A0mm/page_alloc.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 | 288 ++++++++++++++++++++++++++++++<wbr>+++++--<br>
=C2=A06 files changed, 360 insertions(+), 8 deletions(-)<br>
<br>
diff --git a/Documentation/vm/struct_<wbr>page_field b/Documentation/vm/str=
uct_<wbr>page_field<br>
index 1ab6c19ccc7a..bab738ea4e0a 100644<br>
--- a/Documentation/vm/struct_<wbr>page_field<br>
+++ b/Documentation/vm/struct_<wbr>page_field<br>
@@ -3,3 +3,8 @@ Used to indicate this page skipped merging when added to bu=
ddy. This<br>
=C2=A0field only makes sense if the page is in Buddy and is order zero.<br>
=C2=A0It&#39;s a bug if any higher order pages in Buddy has this field set.=
<br>
=C2=A0Shares space with index.<br>
+<br>
+cluster:<br>
+Order 0 Buddy pages are grouped in cluster on free_list to speed up<br>
+allocation. This field stores the cluster pointer for them.<br>
+Shares space with mapping.<br>
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h<br>
index 7edc4e102a8e..49fe9d755a7c 100644<br>
--- a/include/linux/mm_types.h<br>
+++ b/include/linux/mm_types.h<br>
@@ -84,6 +84,8 @@ struct page {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 void *s_mem;=C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* slab firs=
t object */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_t compound_m=
apcount;=C2=A0 =C2=A0 =C2=A0/* first tail page */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* page_deferred_li=
st().next=C2=A0 =C2=A0 =C2=A0-- second tail page */<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct cluster *clu=
ster;=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* order 0 cluster this page belongs to */=
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 };<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Second double word */<br>
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h<br>
index 7522a6987595..09ba9d3cc385 100644<br>
--- a/include/linux/mmzone.h<br>
+++ b/include/linux/mmzone.h<br>
@@ -355,6 +355,40 @@ enum zone_type {<br>
<br>
=C2=A0#ifndef __GENERATING_BOUNDS_H<br>
<br>
+struct cluster {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0struct page=C2=A0 =C2=A0 =C2=A0*tail;=C2=A0 /* =
tail page of the cluster */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0int=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0nr;=C2=A0 =C2=A0 =C2=A0/* how many pages are in this cluster */<br>
+};<br>
+<br>
+struct order0_cluster {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0/* order 0 cluster array, dynamically allocated=
 */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0struct cluster *array;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * order 0 cluster array length, also used to i=
ndicate if cluster<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * allocation is enabled for this zone(cluster =
allocation is disabled<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * for small zones whose batch size is smaller =
than 1, like DMA zone)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0int=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0len;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * smallest position from where we search for a=
n<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * empty cluster from the cluster array<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0int=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0zero_bit;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0/* bitmap used to quickly locate an empty clust=
er from cluster array */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long=C2=A0 =C2=A0*bitmap;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0/* disable cluster allocation to avoid new page=
s becoming racy state. */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long=C2=A0 =C2=A0disable_depth;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * used to indicate if there are pages allocate=
d in cluster mode<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * still in racy state. Caller with zone-&gt;lo=
ck held could use helper<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * function zone_wait_cluster_alloc() to wait a=
ll such pages to exit<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * the race window.<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0atomic_t=C2=A0 =C2=A0 =C2=A0 =C2=A0 in_progress=
;<br>
+};<br>
+<br>
=C2=A0struct zone {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Read-mostly fields */<br>
<br>
@@ -459,6 +493,7 @@ struct zone {<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* free areas of different sizes */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct free_area=C2=A0 =C2=A0 =C2=A0 =C2=A0 fre=
e_area[MAX_ORDER];<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0struct order0_cluster=C2=A0 =C2=A0cluster;<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* zone flags, see below */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0flags;<br>
diff --git a/mm/compaction.c b/mm/compaction.c<br>
index fb9031fdca41..e71fa82786a1 100644<br>
--- a/mm/compaction.c<br>
+++ b/mm/compaction.c<br>
@@ -1601,6 +1601,8 @@ static enum compact_result compact_zone(struct zone *=
zone, struct compact_contro<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 migrate_prep_local();<br>
<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0zone_wait_and_disable_cluster_<wbr>alloc(zone);=
<br>
+<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 while ((ret =3D compact_finished(zone, cc)) =3D=
=3D COMPACT_CONTINUE) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int err;<br>
<br>
@@ -1699,6 +1701,8 @@ static enum compact_result compact_zone(struct zone *=
zone, struct compact_contro<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 zone-&gt;compact_cached_free_pfn =3D free_pfn;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0zone_enable_cluster_alloc(<wbr>zone);<br>
+<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 count_compact_events(<wbr>COMPACTMIGRATE_SCANNE=
D, cc-&gt;total_migrate_scanned);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 count_compact_events(<wbr>COMPACTFREE_SCANNED, =
cc-&gt;total_free_scanned);<br>
<br>
diff --git a/mm/internal.h b/mm/internal.h<br>
index 2bfbaae2d835..1b0535af1b49 100644<br>
--- a/mm/internal.h<br>
+++ b/mm/internal.h<br>
@@ -557,12 +557,46 @@ static inline bool can_skip_merge(struct zone *zone, =
int order)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (order)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;<br>
<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * Clustered allocation is only disabled when h=
igh-order pages<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * are needed, e.g. in compaction and CMA alloc=
, so we should<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * also skip merging in that case.<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (zone-&gt;cluster.disable_depth)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return false;<br>
+<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return true;<br>
=C2=A0}<br>
+<br>
+static inline void zone_wait_cluster_alloc(struct zone *zone)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0while (atomic_read(&amp;zone-&gt;cluster.<wbr>i=
n_progress))<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cpu_relax();<br>
+}<br>
+<br>
+static inline void zone_wait_and_disable_cluster_<wbr>alloc(struct zone *z=
one)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long flags;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irqsave(&amp;zone-&gt;lock, flags);<b=
r>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0zone-&gt;cluster.disable_depth++;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0zone_wait_cluster_alloc(zone);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irqrestore(&amp;zone-&gt;<wbr>lock,=
 flags);<br>
+}<br>
+<br>
+static inline void zone_enable_cluster_alloc(<wbr>struct zone *zone)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long flags;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irqsave(&amp;zone-&gt;lock, flags);<b=
r>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0zone-&gt;cluster.disable_depth--;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irqrestore(&amp;zone-&gt;<wbr>lock,=
 flags);<br>
+}<br>
=C2=A0#else /* CONFIG_COMPACTION */<br>
=C2=A0static inline bool can_skip_merge(struct zone *zone, int order)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;<br>
=C2=A0}<br>
+static inline void zone_wait_cluster_alloc(struct zone *zone) {}<br>
+static inline void zone_wait_and_disable_cluster_<wbr>alloc(struct zone *z=
one) {}<br>
+static inline void zone_enable_cluster_alloc(<wbr>struct zone *zone) {}<br=
>
=C2=A0#endif=C2=A0 /* CONFIG_COMPACTION */<br>
=C2=A0#endif /* __MM_INTERNAL_H */<br>
diff --git a/mm/page_alloc.c b/mm/page_alloc.c<br>
index eb78014dfbde..ac93833a2877 100644<br>
--- a/mm/page_alloc.c<br>
+++ b/mm/page_alloc.c<br>
@@ -746,6 +746,82 @@ static inline void set_page_order(struct page *page, u=
nsigned int order)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 __SetPageBuddy(page);<br>
=C2=A0}<br>
<br>
+static inline struct cluster *new_cluster(struct zone *zone, int nr,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0struct page *tail)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0struct order0_cluster *cluster =3D &amp;zone-&g=
t;cluster;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0int n =3D find_next_zero_bit(cluster-&gt;<wbr>b=
itmap, cluster-&gt;len, cluster-&gt;zero_bit);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (n =3D=3D cluster-&gt;len) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0printk_ratelimited(=
&quot;node%d zone %s cluster used up\n&quot;,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone-&gt;zone_pgdat-&gt;node_id, zone=
-&gt;name);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0cluster-&gt;zero_bit =3D n;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0set_bit(n, cluster-&gt;bitmap);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0cluster-&gt;array[n].nr =3D nr;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0cluster-&gt;array[n].tail =3D tail;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return &amp;cluster-&gt;array[n];<br>
+}<br>
+<br>
+static inline struct cluster *add_to_cluster_common(struct page *page,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0struct zone *zone, struct page *neighbor)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0struct cluster *c;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (neighbor) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int batch =3D this_=
cpu_ptr(zone-&gt;pageset)-&gt;<wbr>pcp.batch;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0c =3D neighbor-&gt;=
cluster;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (c &amp;&amp; c-=
&gt;nr &lt; batch) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0page-&gt;cluster =3D c;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0c-&gt;nr++;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0return c;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0c =3D new_cluster(zone, 1, page);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(!c))<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0page-&gt;cluster =3D c;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return c;<br>
+}<br>
+<br>
+/*<br>
+ * Add this page to the cluster where the previous head page belongs.<br>
+ * Called after page is added to free_list(and becoming the new head).<br>
+ */<br>
+static inline void add_to_cluster_head(struct page *page, struct zone *zon=
e,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int order, int =
mt)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *neighbor;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (order || !zone-&gt;cluster.len)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0neighbor =3D page-&gt;lru.next =3D=3D &amp;zone=
-&gt;free_area[0].free_list[<wbr>mt] ?<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 NULL : list=
_entry(page-&gt;lru.next, struct page, lru);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0add_to_cluster_common(page, zone, neighbor);<br=
>
+}<br>
+<br>
+/*<br>
+ * Add this page to the cluster where the previous tail page belongs.<br>
+ * Called after page is added to free_list(and becoming the new tail).<br>
+ */<br>
+static inline void add_to_cluster_tail(struct page *page, struct zone *zon=
e,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int order, int =
mt)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *neighbor;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0struct cluster *c;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (order || !zone-&gt;cluster.len)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0neighbor =3D page-&gt;lru.prev =3D=3D &amp;zone=
-&gt;free_area[0].free_list[<wbr>mt] ?<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 NULL : list=
_entry(page-&gt;lru.prev, struct page, lru);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0c =3D add_to_cluster_common(page, zone, neighbo=
r);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0c-&gt;tail =3D page;<br>
+}<br>
+<br>
=C2=A0static inline void add_to_buddy_common(struct page *page, struct zone=
 *zone,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned=
 int order, int mt)<br>
=C2=A0{<br>
@@ -765,6 +841,7 @@ static inline void add_to_buddy_head(struct page *page,=
 struct zone *zone,<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 add_to_buddy_common(page, zone, order, mt);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 list_add(&amp;page-&gt;lru, &amp;zone-&gt;free_=
area[order].free_<wbr>list[mt]);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0add_to_cluster_head(page, zone, order, mt);<br>
=C2=A0}<br>
<br>
=C2=A0static inline void add_to_buddy_tail(struct page *page, struct zone *=
zone,<br>
@@ -772,6 +849,7 @@ static inline void add_to_buddy_tail(struct page *page,=
 struct zone *zone,<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 add_to_buddy_common(page, zone, order, mt);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 list_add_tail(&amp;page-&gt;lru, &amp;zone-&gt;=
free_area[order].free_<wbr>list[mt]);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0add_to_cluster_tail(page, zone, order, mt);<br>
=C2=A0}<br>
<br>
=C2=A0static inline void rmv_page_order(struct page *page)<br>
@@ -780,9 +858,29 @@ static inline void rmv_page_order(struct page *page)<b=
r>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 set_page_private(page, 0);<br>
=C2=A0}<br>
<br>
+/* called before removed from free_list */<br>
+static inline void remove_from_cluster(struct page *page, struct zone *zon=
e)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0struct cluster *c =3D page-&gt;cluster;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!c)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0page-&gt;cluster =3D NULL;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0c-&gt;nr--;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!c-&gt;nr) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int bit =3D c - zon=
e-&gt;cluster.array;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0c-&gt;tail =3D NULL=
;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0clear_bit(bit, zone=
-&gt;cluster.bitmap);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (bit &lt; zone-&=
gt;cluster.zero_bit)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0zone-&gt;cluster.zero_bit =3D bit;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0} else if (page =3D=3D c-&gt;tail)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0c-&gt;tail =3D list=
_entry(page-&gt;lru.prev, struct page, lru);<br>
+}<br>
+<br>
=C2=A0static inline void remove_from_buddy(struct page *page, struct zone *=
zone,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned=
 int order)<br>
=C2=A0{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0remove_from_cluster(page, zone);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 list_del(&amp;page-&gt;lru);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 zone-&gt;free_area[order].nr_<wbr>free--;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 rmv_page_order(page);<br>
@@ -2025,6 +2123,17 @@ static int move_freepages(struct zone *zone,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (num_movable)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *num_movable =3D 0;=
<br>
<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * Cluster alloced pages may have their PageBud=
dy flag unclear yet<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * after dropping zone-&gt;lock in rmqueue_bulk=
() and steal here could<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * move them back to free_list. So it&#39;s nec=
essary to wait till all<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * those pages have their flags properly cleare=
d.<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 *<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * We do not need to disable cluster alloc thou=
gh since we already<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * held zone-&gt;lock and no allocation could h=
appen.<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0zone_wait_cluster_alloc(zone);<br>
+<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 for (page =3D start_page; page &lt;=3D end_page=
;) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!pfn_valid_with=
in(page_to_<wbr>pfn(page))) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 page++;<br>
@@ -2049,8 +2158,10 @@ static int move_freepages(struct zone *zone,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 order =3D page_orde=
r(page);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0remove_from_cluster=
(page, zone);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_move(&amp;page=
-&gt;lru,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 &amp;zone-&gt;free_area[order].free_<wbr>list[migratetype=
]);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0add_to_cluster_head=
(page, zone, order, migratetype);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page +=3D 1 &lt;&lt=
; order;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pages_moved +=3D 1 =
&lt;&lt; order;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
@@ -2199,7 +2310,9 @@ static void steal_suitable_fallback(struct zone *zone=
, struct page *page,<br>
<br>
=C2=A0single_page:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 area =3D &amp;zone-&gt;free_area[current_<wbr>o=
rder];<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0remove_from_cluster(page, zone);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 list_move(&amp;page-&gt;lru, &amp;area-&gt;free=
_list[start_type]);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0add_to_cluster_head(page, zone, current_order, =
start_type);<br>
=C2=A0}<br>
<br>
=C2=A0/*<br>
@@ -2460,6 +2573,145 @@ __rmqueue(struct zone *zone, unsigned int order, in=
t migratetype)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return page;<br>
=C2=A0}<br>
<br>
+static int __init zone_order0_cluster_init(void)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone *zone;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0for_each_zone(zone) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int len, mt, batch;=
<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long flags=
;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct order0_clust=
er *cluster;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!managed_zone(z=
one))<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* no need to enabl=
e cluster allocation for batch&lt;=3D1 zone */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0preempt_disable();<=
br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0batch =3D this_cpu_=
ptr(zone-&gt;pageset)-&gt;<wbr>pcp.batch;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0preempt_enable();<b=
r>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (batch &lt;=3D 1=
)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cluster =3D &amp;zo=
ne-&gt;cluster;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* FIXME: possible =
overflow of int type */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0len =3D DIV_ROUND_U=
P(zone-&gt;managed_<wbr>pages, batch);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cluster-&gt;array =
=3D vzalloc(len * sizeof(struct cluster));<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!cluster-&gt;ar=
ray)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0return -ENOMEM;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cluster-&gt;bitmap =
=3D vzalloc(DIV_ROUND_UP(len, BITS_PER_LONG) *<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sizeof(unsigned long));<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!cluster-&gt;bi=
tmap)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0return -ENOMEM;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irqsave(&=
amp;zone-&gt;lock, flags);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cluster-&gt;len =3D=
 len;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0for (mt =3D 0; mt &=
lt; MIGRATE_PCPTYPES; mt++) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0struct page *page;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0list_for_each_entry_reverse(<wbr>page,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&amp;zone=
-&gt;free_area[0].free_list[<wbr>mt], lru)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0add_to_cluster_head(page, zone, 0, mt=
);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irqrest=
ore(&amp;zone-&gt;<wbr>lock, flags);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;<br>
+}<br>
+subsys_initcall(zone_order0_<wbr>cluster_init);<br>
+<br>
+static inline int __rmqueue_bulk_cluster(struct zone *zone, unsigned long =
count,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0struct list_head *list, int mt)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head *head =3D &amp;zone-&gt;free_a=
rea[0].free_list[<wbr>mt];<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0int nr =3D 0;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0while (nr &lt; count) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *head_p=
age;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head *t=
ail, tmp_list;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct cluster *c;<=
br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int bit;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0head_page =3D list_=
first_entry_or_null(head, struct page, lru);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!head_page || !=
head_page-&gt;cluster)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0break;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0c =3D head_page-&gt=
;cluster;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0tail =3D &amp;c-&gt=
;tail-&gt;lru;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* drop the cluster=
 off free_list and attach to list */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_cut_position(&=
amp;tmp_list, head, tail);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_splice_tail(&a=
mp;tmp_list, list);<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nr +=3D c-&gt;nr;<b=
r>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone-&gt;free_area[=
0].nr_free -=3D c-&gt;nr;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* this cluster is =
empty now */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0c-&gt;tail =3D NULL=
;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0c-&gt;nr =3D 0;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0bit =3D c - zone-&g=
t;cluster.array;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0clear_bit(bit, zone=
-&gt;cluster.bitmap);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (bit &lt; zone-&=
gt;cluster.zero_bit)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0zone-&gt;cluster.zero_bit =3D bit;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return nr;<br>
+}<br>
+<br>
+static inline int rmqueue_bulk_cluster(struct zone *zone, unsigned int ord=
er,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long count, struct list_head=
 *list,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int migratetype)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0int alloced;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * Cluster alloc races with merging so don&#39;=
t try cluster alloc when we<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * can&#39;t skip merging. Note that can_skip_m=
erge() keeps the same return<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * value from here till all pages have their fl=
ags properly processed,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * i.e. the end of the function where in_progre=
ss is incremented, even<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * we have dropped the lock in the middle becau=
se the only place that<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * can change can_skip_merge()&#39;s return val=
ue is compaction code and<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * compaction needs to wait on in_progress.<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!can_skip_merge(zone, 0))<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0/* Cluster alloc is disabled, mostly compaction=
 is already in progress */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (zone-&gt;cluster.disable_depth)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0/* Cluster alloc is disabled for this zone */<b=
r>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(!zone-&gt;cluster.len))<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0alloced =3D __rmqueue_bulk_cluster(zone, count,=
 list, migratetype);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!alloced)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * Cache miss on page structure could slow thin=
gs down<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * dramatically so accessing these alloced page=
s without<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * holding lock for better performance.<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 *<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * Since these pages still have PageBuddy set, =
there is a race<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * window between now and when PageBuddy is cle=
ared for them<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * below. Any operation that would scan a pageb=
lock and check<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * PageBuddy(page), e.g. compaction, will need =
to wait till all<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * such pages are properly processed. in_progre=
ss is used for<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * such purpose so increase it now before dropp=
ing the lock.<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0atomic_inc(&amp;zone-&gt;cluster.in_<wbr>progre=
ss);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&amp;zone-&gt;lock);<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0list_for_each_entry(page, list, lru) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rmv_page_order(page=
);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page-&gt;cluster =
=3D NULL;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0set_pcppage_migrate=
type(page, migratetype);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0atomic_dec(&amp;zone-&gt;cluster.in_<wbr>progre=
ss);<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return alloced;<br>
+}<br>
+<br>
=C2=A0/*<br>
=C2=A0 * Obtain a specified number of elements from the buddy allocator, al=
l under<br>
=C2=A0 * a single hold of the lock, for efficiency.=C2=A0 Add them to the s=
upplied list.<br>
@@ -2469,17 +2721,23 @@ static int rmqueue_bulk(struct zone *zone, unsigned=
 int order,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 unsigned long count, struct list_head *list,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 int migratetype)<br>
=C2=A0{<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0int i, alloced =3D 0;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0int i, alloced;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page, *tmp;<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock(&amp;zone-&gt;lock);<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; i &lt; count; ++i) {<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page =
=3D __rmqueue(zone, order, migratetype);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0alloced =3D rmqueue_bulk_cluster(zone, order, c=
ount, list, migratetype);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (alloced &gt; 0) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (alloced &gt;=3D=
 count)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0goto out;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0else<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0spin_lock(&amp;zone-&gt;lock);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0for (; alloced &lt; count; alloced++) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D __rmqueue(=
zone, order, migratetype);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (unlikely(page =
=3D=3D NULL))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 break;<br>
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(check_=
pcp_refill(<wbr>page)))<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;<br>
-<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Split buddy=
 pages returned by expand() are received here in<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* physical pa=
ge order. The page is added to the tail of<br>
@@ -2491,7 +2749,18 @@ static int rmqueue_bulk(struct zone *zone, unsigned =
int order,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* pages are o=
rdered properly.<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_add_tail(&amp;=
page-&gt;lru, list);<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0alloced++;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&amp;zone-&gt;lock);<br>
+<br>
+out:<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0i =3D alloced;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0list_for_each_entry_safe(page, tmp, list, lru) =
{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(check_=
pcp_refill(<wbr>page))) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0list_del(&amp;page-&gt;lru);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0alloced--;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
+<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (is_migrate_cma(=
get_pcppage_<wbr>migratetype(page)))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 __mod_zone_page_state(zone, NR_FREE_CMA_PAGES,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 -(1 &lt;&lt; order));<br>
@@ -2504,7 +2773,6 @@ static int rmqueue_bulk(struct zone *zone, unsigned i=
nt order,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* pages added to the pcp list.<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 __mod_zone_page_state(zone, NR_FREE_PAGES, -(i =
&lt;&lt; order));<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&amp;zone-&gt;lock);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return alloced;<br>
=C2=A0}<br>
<br>
@@ -7744,6 +8012,7 @@ int alloc_contig_range(unsigned long start, unsigned =
long end,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long outer_start, outer_end;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned int order;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 int ret =3D 0;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone *zone =3D page_zone(pfn_to_page(sta=
rt));<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct compact_control cc =3D {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .nr_migratepages =
=3D 0,<br>
@@ -7786,6 +8055,7 @@ int alloc_contig_range(unsigned long start, unsigned =
long end,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ret)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;<br>
<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0zone_wait_and_disable_cluster_<wbr>alloc(zone);=
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /*<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* In case of -EBUSY, we&#39;d like to kno=
w which page causes problem.<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* So, just fall through. test_pages_isola=
ted() has a tracepoint<br>
@@ -7868,6 +8138,8 @@ int alloc_contig_range(unsigned long start, unsigned =
long end,<br>
=C2=A0done:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 undo_isolate_page_range(pfn_<wbr>max_align_down=
(start),<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pfn_max_align_up(end), migratetype);=
<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0zone_enable_cluster_alloc(<wbr>zone);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;<br>
=C2=A0}<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
2.14.3<br>
<br>
</font></span></blockquote></div><br></div></div>

--000000000000de61a70567df9bfd--
