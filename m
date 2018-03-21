Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2ECC66B0005
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 08:56:55 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id r15so2504177wrr.16
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 05:56:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p59si3301013wrb.339.2018.03.21.05.56.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 05:56:52 -0700 (PDT)
Subject: Re: [RFC PATCH v2 3/4] mm/rmqueue_bulk: alloc without touching
 individual page structure
References: <20180320085452.24641-1-aaron.lu@intel.com>
 <20180320085452.24641-4-aaron.lu@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <12a89171-27b8-af4f-450e-41e5775683c5@suse.cz>
Date: Wed, 21 Mar 2018 13:55:01 +0100
MIME-Version: 1.0
In-Reply-To: <20180320085452.24641-4-aaron.lu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>

On 03/20/2018 09:54 AM, Aaron Lu wrote:
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

I'm sorry, but I feel the added complexity here is simply too large to
justify the change. Especially if the motivation seems to be just the
microbenchmark. It would be better if this was motivated by a real
workload where zone lock contention was identified as the main issue,
and we would see the improvements on the workload. We could also e.g.
find out that the problem can be avoided at a different level.

Besides complexity, it may also add overhead to the non-contended case,
i.e. the atomic operations on in_progress. This goes against recent page
allocation optimizations by Mel Gorman etc.

Would perhaps prefetching the next page in freelist (in
remove_from_buddy()) help here?

Vlastimil

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
>  mm/page_alloc.c                    | 288 +++++++++++++++++++++++++++++++++++--
>  6 files changed, 360 insertions(+), 8 deletions(-)
> 
> diff --git a/Documentation/vm/struct_page_field b/Documentation/vm/struct_page_field
> index 1ab6c19ccc7a..bab738ea4e0a 100644
> --- a/Documentation/vm/struct_page_field
> +++ b/Documentation/vm/struct_page_field
> @@ -3,3 +3,8 @@ Used to indicate this page skipped merging when added to buddy. This
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
>  		void *s_mem;			/* slab first object */
>  		atomic_t compound_mapcount;	/* first tail page */
>  		/* page_deferred_list().next	 -- second tail page */
> +
> +		struct cluster *cluster;	/* order 0 cluster this page belongs to */
>  	};
>  
>  	/* Second double word */
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 7522a6987595..09ba9d3cc385 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -355,6 +355,40 @@ enum zone_type {
>  
>  #ifndef __GENERATING_BOUNDS_H
>  
> +struct cluster {
> +	struct page     *tail;  /* tail page of the cluster */
> +	int             nr;     /* how many pages are in this cluster */
> +};
> +
> +struct order0_cluster {
> +	/* order 0 cluster array, dynamically allocated */
> +	struct cluster *array;
> +	/*
> +	 * order 0 cluster array length, also used to indicate if cluster
> +	 * allocation is enabled for this zone(cluster allocation is disabled
> +	 * for small zones whose batch size is smaller than 1, like DMA zone)
> +	 */
> +	int             len;
> +	/*
> +	 * smallest position from where we search for an
> +	 * empty cluster from the cluster array
> +	 */
> +	int		zero_bit;
> +	/* bitmap used to quickly locate an empty cluster from cluster array */
> +	unsigned long   *bitmap;
> +
> +	/* disable cluster allocation to avoid new pages becoming racy state. */
> +	unsigned long	disable_depth;
> +
> +	/*
> +	 * used to indicate if there are pages allocated in cluster mode
> +	 * still in racy state. Caller with zone->lock held could use helper
> +	 * function zone_wait_cluster_alloc() to wait all such pages to exit
> +	 * the race window.
> +	 */
> +	atomic_t        in_progress;
> +};
> +
>  struct zone {
>  	/* Read-mostly fields */
>  
> @@ -459,6 +493,7 @@ struct zone {
>  
>  	/* free areas of different sizes */
>  	struct free_area	free_area[MAX_ORDER];
> +	struct order0_cluster	cluster;
>  
>  	/* zone flags, see below */
>  	unsigned long		flags;
> diff --git a/mm/compaction.c b/mm/compaction.c
> index fb9031fdca41..e71fa82786a1 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1601,6 +1601,8 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
>  
>  	migrate_prep_local();
>  
> +	zone_wait_and_disable_cluster_alloc(zone);
> +
>  	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
>  		int err;
>  
> @@ -1699,6 +1701,8 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
>  			zone->compact_cached_free_pfn = free_pfn;
>  	}
>  
> +	zone_enable_cluster_alloc(zone);
> +
>  	count_compact_events(COMPACTMIGRATE_SCANNED, cc->total_migrate_scanned);
>  	count_compact_events(COMPACTFREE_SCANNED, cc->total_free_scanned);
>  
> diff --git a/mm/internal.h b/mm/internal.h
> index 2bfbaae2d835..1b0535af1b49 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -557,12 +557,46 @@ static inline bool can_skip_merge(struct zone *zone, int order)
>  	if (order)
>  		return false;
>  
> +	/*
> +	 * Clustered allocation is only disabled when high-order pages
> +	 * are needed, e.g. in compaction and CMA alloc, so we should
> +	 * also skip merging in that case.
> +	 */
> +	if (zone->cluster.disable_depth)
> +		return false;
> +
>  	return true;
>  }
> +
> +static inline void zone_wait_cluster_alloc(struct zone *zone)
> +{
> +	while (atomic_read(&zone->cluster.in_progress))
> +		cpu_relax();
> +}
> +
> +static inline void zone_wait_and_disable_cluster_alloc(struct zone *zone)
> +{
> +	unsigned long flags;
> +	spin_lock_irqsave(&zone->lock, flags);
> +	zone->cluster.disable_depth++;
> +	zone_wait_cluster_alloc(zone);
> +	spin_unlock_irqrestore(&zone->lock, flags);
> +}
> +
> +static inline void zone_enable_cluster_alloc(struct zone *zone)
> +{
> +	unsigned long flags;
> +	spin_lock_irqsave(&zone->lock, flags);
> +	zone->cluster.disable_depth--;
> +	spin_unlock_irqrestore(&zone->lock, flags);
> +}
>  #else /* CONFIG_COMPACTION */
>  static inline bool can_skip_merge(struct zone *zone, int order)
>  {
>  	return false;
>  }
> +static inline void zone_wait_cluster_alloc(struct zone *zone) {}
> +static inline void zone_wait_and_disable_cluster_alloc(struct zone *zone) {}
> +static inline void zone_enable_cluster_alloc(struct zone *zone) {}
>  #endif  /* CONFIG_COMPACTION */
>  #endif	/* __MM_INTERNAL_H */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index eb78014dfbde..ac93833a2877 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -746,6 +746,82 @@ static inline void set_page_order(struct page *page, unsigned int order)
>  	__SetPageBuddy(page);
>  }
>  
> +static inline struct cluster *new_cluster(struct zone *zone, int nr,
> +						struct page *tail)
> +{
> +	struct order0_cluster *cluster = &zone->cluster;
> +	int n = find_next_zero_bit(cluster->bitmap, cluster->len, cluster->zero_bit);
> +	if (n == cluster->len) {
> +		printk_ratelimited("node%d zone %s cluster used up\n",
> +				zone->zone_pgdat->node_id, zone->name);
> +		return NULL;
> +	}
> +	cluster->zero_bit = n;
> +	set_bit(n, cluster->bitmap);
> +	cluster->array[n].nr = nr;
> +	cluster->array[n].tail = tail;
> +	return &cluster->array[n];
> +}
> +
> +static inline struct cluster *add_to_cluster_common(struct page *page,
> +			struct zone *zone, struct page *neighbor)
> +{
> +	struct cluster *c;
> +
> +	if (neighbor) {
> +		int batch = this_cpu_ptr(zone->pageset)->pcp.batch;
> +		c = neighbor->cluster;
> +		if (c && c->nr < batch) {
> +			page->cluster = c;
> +			c->nr++;
> +			return c;
> +		}
> +	}
> +
> +	c = new_cluster(zone, 1, page);
> +	if (unlikely(!c))
> +		return NULL;
> +
> +	page->cluster = c;
> +	return c;
> +}
> +
> +/*
> + * Add this page to the cluster where the previous head page belongs.
> + * Called after page is added to free_list(and becoming the new head).
> + */
> +static inline void add_to_cluster_head(struct page *page, struct zone *zone,
> +				       int order, int mt)
> +{
> +	struct page *neighbor;
> +
> +	if (order || !zone->cluster.len)
> +		return;
> +
> +	neighbor = page->lru.next == &zone->free_area[0].free_list[mt] ?
> +		   NULL : list_entry(page->lru.next, struct page, lru);
> +	add_to_cluster_common(page, zone, neighbor);
> +}
> +
> +/*
> + * Add this page to the cluster where the previous tail page belongs.
> + * Called after page is added to free_list(and becoming the new tail).
> + */
> +static inline void add_to_cluster_tail(struct page *page, struct zone *zone,
> +				       int order, int mt)
> +{
> +	struct page *neighbor;
> +	struct cluster *c;
> +
> +	if (order || !zone->cluster.len)
> +		return;
> +
> +	neighbor = page->lru.prev == &zone->free_area[0].free_list[mt] ?
> +		   NULL : list_entry(page->lru.prev, struct page, lru);
> +	c = add_to_cluster_common(page, zone, neighbor);
> +	c->tail = page;
> +}
> +
>  static inline void add_to_buddy_common(struct page *page, struct zone *zone,
>  					unsigned int order, int mt)
>  {
> @@ -765,6 +841,7 @@ static inline void add_to_buddy_head(struct page *page, struct zone *zone,
>  {
>  	add_to_buddy_common(page, zone, order, mt);
>  	list_add(&page->lru, &zone->free_area[order].free_list[mt]);
> +	add_to_cluster_head(page, zone, order, mt);
>  }
>  
>  static inline void add_to_buddy_tail(struct page *page, struct zone *zone,
> @@ -772,6 +849,7 @@ static inline void add_to_buddy_tail(struct page *page, struct zone *zone,
>  {
>  	add_to_buddy_common(page, zone, order, mt);
>  	list_add_tail(&page->lru, &zone->free_area[order].free_list[mt]);
> +	add_to_cluster_tail(page, zone, order, mt);
>  }
>  
>  static inline void rmv_page_order(struct page *page)
> @@ -780,9 +858,29 @@ static inline void rmv_page_order(struct page *page)
>  	set_page_private(page, 0);
>  }
>  
> +/* called before removed from free_list */
> +static inline void remove_from_cluster(struct page *page, struct zone *zone)
> +{
> +	struct cluster *c = page->cluster;
> +	if (!c)
> +		return;
> +
> +	page->cluster = NULL;
> +	c->nr--;
> +	if (!c->nr) {
> +		int bit = c - zone->cluster.array;
> +		c->tail = NULL;
> +		clear_bit(bit, zone->cluster.bitmap);
> +		if (bit < zone->cluster.zero_bit)
> +			zone->cluster.zero_bit = bit;
> +	} else if (page == c->tail)
> +		c->tail = list_entry(page->lru.prev, struct page, lru);
> +}
> +
>  static inline void remove_from_buddy(struct page *page, struct zone *zone,
>  					unsigned int order)
>  {
> +	remove_from_cluster(page, zone);
>  	list_del(&page->lru);
>  	zone->free_area[order].nr_free--;
>  	rmv_page_order(page);
> @@ -2025,6 +2123,17 @@ static int move_freepages(struct zone *zone,
>  	if (num_movable)
>  		*num_movable = 0;
>  
> +	/*
> +	 * Cluster alloced pages may have their PageBuddy flag unclear yet
> +	 * after dropping zone->lock in rmqueue_bulk() and steal here could
> +	 * move them back to free_list. So it's necessary to wait till all
> +	 * those pages have their flags properly cleared.
> +	 *
> +	 * We do not need to disable cluster alloc though since we already
> +	 * held zone->lock and no allocation could happen.
> +	 */
> +	zone_wait_cluster_alloc(zone);
> +
>  	for (page = start_page; page <= end_page;) {
>  		if (!pfn_valid_within(page_to_pfn(page))) {
>  			page++;
> @@ -2049,8 +2158,10 @@ static int move_freepages(struct zone *zone,
>  		}
>  
>  		order = page_order(page);
> +		remove_from_cluster(page, zone);
>  		list_move(&page->lru,
>  			  &zone->free_area[order].free_list[migratetype]);
> +		add_to_cluster_head(page, zone, order, migratetype);
>  		page += 1 << order;
>  		pages_moved += 1 << order;
>  	}
> @@ -2199,7 +2310,9 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
>  
>  single_page:
>  	area = &zone->free_area[current_order];
> +	remove_from_cluster(page, zone);
>  	list_move(&page->lru, &area->free_list[start_type]);
> +	add_to_cluster_head(page, zone, current_order, start_type);
>  }
>  
>  /*
> @@ -2460,6 +2573,145 @@ __rmqueue(struct zone *zone, unsigned int order, int migratetype)
>  	return page;
>  }
>  
> +static int __init zone_order0_cluster_init(void)
> +{
> +	struct zone *zone;
> +
> +	for_each_zone(zone) {
> +		int len, mt, batch;
> +		unsigned long flags;
> +		struct order0_cluster *cluster;
> +
> +		if (!managed_zone(zone))
> +			continue;
> +
> +		/* no need to enable cluster allocation for batch<=1 zone */
> +		preempt_disable();
> +		batch = this_cpu_ptr(zone->pageset)->pcp.batch;
> +		preempt_enable();
> +		if (batch <= 1)
> +			continue;
> +
> +		cluster = &zone->cluster;
> +		/* FIXME: possible overflow of int type */
> +		len = DIV_ROUND_UP(zone->managed_pages, batch);
> +		cluster->array = vzalloc(len * sizeof(struct cluster));
> +		if (!cluster->array)
> +			return -ENOMEM;
> +		cluster->bitmap = vzalloc(DIV_ROUND_UP(len, BITS_PER_LONG) *
> +				sizeof(unsigned long));
> +		if (!cluster->bitmap)
> +			return -ENOMEM;
> +
> +		spin_lock_irqsave(&zone->lock, flags);
> +		cluster->len = len;
> +		for (mt = 0; mt < MIGRATE_PCPTYPES; mt++) {
> +			struct page *page;
> +			list_for_each_entry_reverse(page,
> +					&zone->free_area[0].free_list[mt], lru)
> +				add_to_cluster_head(page, zone, 0, mt);
> +		}
> +		spin_unlock_irqrestore(&zone->lock, flags);
> +	}
> +
> +	return 0;
> +}
> +subsys_initcall(zone_order0_cluster_init);
> +
> +static inline int __rmqueue_bulk_cluster(struct zone *zone, unsigned long count,
> +						struct list_head *list, int mt)
> +{
> +	struct list_head *head = &zone->free_area[0].free_list[mt];
> +	int nr = 0;
> +
> +	while (nr < count) {
> +		struct page *head_page;
> +		struct list_head *tail, tmp_list;
> +		struct cluster *c;
> +		int bit;
> +
> +		head_page = list_first_entry_or_null(head, struct page, lru);
> +		if (!head_page || !head_page->cluster)
> +			break;
> +
> +		c = head_page->cluster;
> +		tail = &c->tail->lru;
> +
> +		/* drop the cluster off free_list and attach to list */
> +		list_cut_position(&tmp_list, head, tail);
> +		list_splice_tail(&tmp_list, list);
> +
> +		nr += c->nr;
> +		zone->free_area[0].nr_free -= c->nr;
> +
> +		/* this cluster is empty now */
> +		c->tail = NULL;
> +		c->nr = 0;
> +		bit = c - zone->cluster.array;
> +		clear_bit(bit, zone->cluster.bitmap);
> +		if (bit < zone->cluster.zero_bit)
> +			zone->cluster.zero_bit = bit;
> +	}
> +
> +	return nr;
> +}
> +
> +static inline int rmqueue_bulk_cluster(struct zone *zone, unsigned int order,
> +				unsigned long count, struct list_head *list,
> +				int migratetype)
> +{
> +	int alloced;
> +	struct page *page;
> +
> +	/*
> +	 * Cluster alloc races with merging so don't try cluster alloc when we
> +	 * can't skip merging. Note that can_skip_merge() keeps the same return
> +	 * value from here till all pages have their flags properly processed,
> +	 * i.e. the end of the function where in_progress is incremented, even
> +	 * we have dropped the lock in the middle because the only place that
> +	 * can change can_skip_merge()'s return value is compaction code and
> +	 * compaction needs to wait on in_progress.
> +	 */
> +	if (!can_skip_merge(zone, 0))
> +		return 0;
> +
> +	/* Cluster alloc is disabled, mostly compaction is already in progress */
> +	if (zone->cluster.disable_depth)
> +		return 0;
> +
> +	/* Cluster alloc is disabled for this zone */
> +	if (unlikely(!zone->cluster.len))
> +		return 0;
> +
> +	alloced = __rmqueue_bulk_cluster(zone, count, list, migratetype);
> +	if (!alloced)
> +		return 0;
> +
> +	/*
> +	 * Cache miss on page structure could slow things down
> +	 * dramatically so accessing these alloced pages without
> +	 * holding lock for better performance.
> +	 *
> +	 * Since these pages still have PageBuddy set, there is a race
> +	 * window between now and when PageBuddy is cleared for them
> +	 * below. Any operation that would scan a pageblock and check
> +	 * PageBuddy(page), e.g. compaction, will need to wait till all
> +	 * such pages are properly processed. in_progress is used for
> +	 * such purpose so increase it now before dropping the lock.
> +	 */
> +	atomic_inc(&zone->cluster.in_progress);
> +	spin_unlock(&zone->lock);
> +
> +	list_for_each_entry(page, list, lru) {
> +		rmv_page_order(page);
> +		page->cluster = NULL;
> +		set_pcppage_migratetype(page, migratetype);
> +	}
> +	atomic_dec(&zone->cluster.in_progress);
> +
> +	return alloced;
> +}
> +
>  /*
>   * Obtain a specified number of elements from the buddy allocator, all under
>   * a single hold of the lock, for efficiency.  Add them to the supplied list.
> @@ -2469,17 +2721,23 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  			unsigned long count, struct list_head *list,
>  			int migratetype)
>  {
> -	int i, alloced = 0;
> +	int i, alloced;
> +	struct page *page, *tmp;
>  
>  	spin_lock(&zone->lock);
> -	for (i = 0; i < count; ++i) {
> -		struct page *page = __rmqueue(zone, order, migratetype);
> +	alloced = rmqueue_bulk_cluster(zone, order, count, list, migratetype);
> +	if (alloced > 0) {
> +		if (alloced >= count)
> +			goto out;
> +		else
> +			spin_lock(&zone->lock);
> +	}
> +
> +	for (; alloced < count; alloced++) {
> +		page = __rmqueue(zone, order, migratetype);
>  		if (unlikely(page == NULL))
>  			break;
>  
> -		if (unlikely(check_pcp_refill(page)))
> -			continue;
> -
>  		/*
>  		 * Split buddy pages returned by expand() are received here in
>  		 * physical page order. The page is added to the tail of
> @@ -2491,7 +2749,18 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  		 * pages are ordered properly.
>  		 */
>  		list_add_tail(&page->lru, list);
> -		alloced++;
> +	}
> +	spin_unlock(&zone->lock);
> +
> +out:
> +	i = alloced;
> +	list_for_each_entry_safe(page, tmp, list, lru) {
> +		if (unlikely(check_pcp_refill(page))) {
> +			list_del(&page->lru);
> +			alloced--;
> +			continue;
> +		}
> +
>  		if (is_migrate_cma(get_pcppage_migratetype(page)))
>  			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
>  					      -(1 << order));
> @@ -2504,7 +2773,6 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  	 * pages added to the pcp list.
>  	 */
>  	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
> -	spin_unlock(&zone->lock);
>  	return alloced;
>  }
>  
> @@ -7744,6 +8012,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>  	unsigned long outer_start, outer_end;
>  	unsigned int order;
>  	int ret = 0;
> +	struct zone *zone = page_zone(pfn_to_page(start));
>  
>  	struct compact_control cc = {
>  		.nr_migratepages = 0,
> @@ -7786,6 +8055,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>  	if (ret)
>  		return ret;
>  
> +	zone_wait_and_disable_cluster_alloc(zone);
>  	/*
>  	 * In case of -EBUSY, we'd like to know which page causes problem.
>  	 * So, just fall through. test_pages_isolated() has a tracepoint
> @@ -7868,6 +8138,8 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>  done:
>  	undo_isolate_page_range(pfn_max_align_down(start),
>  				pfn_max_align_up(end), migratetype);
> +
> +	zone_enable_cluster_alloc(zone);
>  	return ret;
>  }
>  
> 
