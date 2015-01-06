Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id 77E886B00CB
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 09:53:10 -0500 (EST)
Received: by mail-we0-f172.google.com with SMTP id k11so9747886wes.3
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 06:53:10 -0800 (PST)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com. [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id bg10si24748582wib.33.2015.01.06.06.53.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 06:53:09 -0800 (PST)
Received: by mail-wg0-f48.google.com with SMTP id l2so4151531wgh.21
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 06:53:09 -0800 (PST)
Date: Tue, 6 Jan 2015 15:53:07 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V4 3/4] mm: reduce try_to_compact_pages parameters
Message-ID: <20150106145307.GC20860@dhcp22.suse.cz>
References: <1420478263-25207-1-git-send-email-vbabka@suse.cz>
 <1420478263-25207-4-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420478263-25207-4-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon 05-01-15 18:17:42, Vlastimil Babka wrote:
> Expand the usage of the struct alloc_context introduced in the previous patch
> also for calling try_to_compact_pages(), to reduce the number of its
> parameters. Since the function is in different compilation unit, we need to
> move alloc_context definition in the shared mm/internal.h header.
> 
> With this change we get simpler code and small savings of code size and stack
> usage:
> 
> add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-27 (-27)
> function                                     old     new   delta
> __alloc_pages_direct_compact                 283     256     -27
> add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-13 (-13)
> function                                     old     new   delta
> try_to_compact_pages                         582     569     -13
> 
> Stack usage of __alloc_pages_direct_compact goes from 24 to none (per
> scripts/checkstack.pl).
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Hocko <mhocko@suse.cz>

Looks good as well.
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/compaction.h | 17 +++++++++--------
>  mm/compaction.c            | 23 +++++++++++------------
>  mm/internal.h              | 14 ++++++++++++++
>  mm/page_alloc.c            | 19 ++-----------------
>  4 files changed, 36 insertions(+), 37 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index 3238ffa..f2efda2 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -21,6 +21,8 @@
>  /* Zone lock or lru_lock was contended in async compaction */
>  #define COMPACT_CONTENDED_LOCK	2
>  
> +struct alloc_context; /* in mm/internal.h */
> +
>  #ifdef CONFIG_COMPACTION
>  extern int sysctl_compact_memory;
>  extern int sysctl_compaction_handler(struct ctl_table *table, int write,
> @@ -30,10 +32,9 @@ extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
>  			void __user *buffer, size_t *length, loff_t *ppos);
>  
>  extern int fragmentation_index(struct zone *zone, unsigned int order);
> -extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
> -			int order, gfp_t gfp_mask, nodemask_t *mask,
> -			enum migrate_mode mode, int *contended,
> -			int alloc_flags, int classzone_idx);
> +extern unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
> +			int alloc_flags, const struct alloc_context *ac,
> +			enum migrate_mode mode, int *contended);
>  extern void compact_pgdat(pg_data_t *pgdat, int order);
>  extern void reset_isolation_suitable(pg_data_t *pgdat);
>  extern unsigned long compaction_suitable(struct zone *zone, int order,
> @@ -101,10 +102,10 @@ static inline bool compaction_restarting(struct zone *zone, int order)
>  }
>  
>  #else
> -static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
> -			int order, gfp_t gfp_mask, nodemask_t *nodemask,
> -			enum migrate_mode mode, int *contended,
> -			int alloc_flags, int classzone_idx)
> +static inline unsigned long try_to_compact_pages(gfp_t gfp_mask,
> +			unsigned int order, int alloc_flags,
> +			const struct alloc_context *ac,
> +			enum migrate_mode mode, int *contended)
>  {
>  	return COMPACT_CONTINUE;
>  }
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 546e571..9c7e690 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1335,22 +1335,20 @@ int sysctl_extfrag_threshold = 500;
>  
>  /**
>   * try_to_compact_pages - Direct compact to satisfy a high-order allocation
> - * @zonelist: The zonelist used for the current allocation
> - * @order: The order of the current allocation
>   * @gfp_mask: The GFP mask of the current allocation
> - * @nodemask: The allowed nodes to allocate from
> + * @order: The order of the current allocation
> + * @alloc_flags: The allocation flags of the current allocation
> + * @ac: The context of current allocation
>   * @mode: The migration mode for async, sync light, or sync migration
>   * @contended: Return value that determines if compaction was aborted due to
>   *	       need_resched() or lock contention
>   *
>   * This is the main entry point for direct page compaction.
>   */
> -unsigned long try_to_compact_pages(struct zonelist *zonelist,
> -			int order, gfp_t gfp_mask, nodemask_t *nodemask,
> -			enum migrate_mode mode, int *contended,
> -			int alloc_flags, int classzone_idx)
> +unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
> +			int alloc_flags, const struct alloc_context *ac,
> +			enum migrate_mode mode, int *contended)
>  {
> -	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
>  	int may_enter_fs = gfp_mask & __GFP_FS;
>  	int may_perform_io = gfp_mask & __GFP_IO;
>  	struct zoneref *z;
> @@ -1365,8 +1363,8 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  		return COMPACT_SKIPPED;
>  
>  	/* Compact each zone in the list */
> -	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
> -								nodemask) {
> +	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
> +								ac->nodemask) {
>  		int status;
>  		int zone_contended;
>  
> @@ -1374,7 +1372,8 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  			continue;
>  
>  		status = compact_zone_order(zone, order, gfp_mask, mode,
> -				&zone_contended, alloc_flags, classzone_idx);
> +				&zone_contended, alloc_flags,
> +				ac->classzone_idx);
>  		rc = max(status, rc);
>  		/*
>  		 * It takes at least one zone that wasn't lock contended
> @@ -1384,7 +1383,7 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  
>  		/* If a normal allocation would succeed, stop compacting */
>  		if (zone_watermark_ok(zone, order, low_wmark_pages(zone),
> -					classzone_idx, alloc_flags)) {
> +					ac->classzone_idx, alloc_flags)) {
>  			/*
>  			 * We think the allocation will succeed in this zone,
>  			 * but it is not certain, hence the false. The caller
> diff --git a/mm/internal.h b/mm/internal.h
> index efad241..cd5418b 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -110,6 +110,20 @@ extern pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address);
>   */
>  
>  /*
> + * Structure for holding the mostly immutable allocation parameters passed
> + * between functions involved in allocations, including the alloc_pages*
> + * family of functions.
> + */
> +struct alloc_context {
> +	struct zonelist *zonelist;
> +	nodemask_t *nodemask;
> +	struct zone *preferred_zone;
> +	int classzone_idx;
> +	int migratetype;
> +	enum zone_type high_zoneidx;
> +};
> +
> +/*
>   * Locate the struct page for both the matching buddy in our
>   * pair (buddy1) and the combined O(n+1) page they form (page).
>   *
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index bf0359c..f5f5e2a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -232,19 +232,6 @@ EXPORT_SYMBOL(nr_node_ids);
>  EXPORT_SYMBOL(nr_online_nodes);
>  #endif
>  
> -/*
> - * Structure for holding the mostly immutable allocation parameters passed
> - * between alloc_pages* family of functions.
> - */
> -struct alloc_context {
> -	struct zonelist *zonelist;
> -	nodemask_t *nodemask;
> -	struct zone *preferred_zone;
> -	int classzone_idx;
> -	int migratetype;
> -	enum zone_type high_zoneidx;
> -};
> -
>  int page_group_by_mobility_disabled __read_mostly;
>  
>  void set_pageblock_migratetype(struct page *page, int migratetype)
> @@ -2421,10 +2408,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  		return NULL;
>  
>  	current->flags |= PF_MEMALLOC;
> -	compact_result = try_to_compact_pages(ac->zonelist, order, gfp_mask,
> -						ac->nodemask, mode,
> -						contended_compaction,
> -						alloc_flags, ac->classzone_idx);
> +	compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
> +						mode, contended_compaction);
>  	current->flags &= ~PF_MEMALLOC;
>  
>  	switch (compact_result) {
> -- 
> 2.1.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
