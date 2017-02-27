Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id CFCDB6B0387
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 08:48:56 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id w37so18231455wrc.2
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 05:48:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o110si21470245wrc.152.2017.02.27.05.48.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Feb 2017 05:48:55 -0800 (PST)
Date: Mon, 27 Feb 2017 14:48:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V5 1/6] mm: delete unnecessary TTU_* flags
Message-ID: <20170227134851.GD26504@dhcp22.suse.cz>
References: <cover.1487965799.git.shli@fb.com>
 <4be3ea1bc56b26fd98a54d0a6f70bec63f6d8980.1487965799.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4be3ea1bc56b26fd98a54d0a6f70bec63f6d8980.1487965799.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri 24-02-17 13:31:44, Shaohua Li wrote:
> Johannes pointed out TTU_LZFREE is unnecessary. It's true because we
> always have the flag set if we want to do an unmap. For cases we don't
> do an unmap, the TTU_LZFREE part of code should never run.
> 
> Also the TTU_UNMAP is unnecessary. If no other flags set (for
> example, TTU_MIGRATION), an unmap is implied.
> 
> The patch includes Johannes's cleanup and dead TTU_ACTION macro removal
> code
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Minchan Kim <minchan@kernel.org>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> Signed-off-by: Shaohua Li <shli@fb.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/rmap.h | 22 +++++++++-------------
>  mm/memory-failure.c  |  2 +-
>  mm/rmap.c            |  2 +-
>  mm/vmscan.c          | 11 ++++-------
>  4 files changed, 15 insertions(+), 22 deletions(-)
> 
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index 8c89e90..7a39414 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -83,19 +83,17 @@ struct anon_vma_chain {
>  };
>  
>  enum ttu_flags {
> -	TTU_UNMAP = 1,			/* unmap mode */
> -	TTU_MIGRATION = 2,		/* migration mode */
> -	TTU_MUNLOCK = 4,		/* munlock mode */
> -	TTU_LZFREE = 8,			/* lazy free mode */
> -	TTU_SPLIT_HUGE_PMD = 16,	/* split huge PMD if any */
> -
> -	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
> -	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
> -	TTU_IGNORE_HWPOISON = (1 << 10),/* corrupted page is recoverable */
> -	TTU_BATCH_FLUSH = (1 << 11),	/* Batch TLB flushes where possible
> +	TTU_MIGRATION		= 0x1,	/* migration mode */
> +	TTU_MUNLOCK		= 0x2,	/* munlock mode */
> +
> +	TTU_SPLIT_HUGE_PMD	= 0x4,	/* split huge PMD if any */
> +	TTU_IGNORE_MLOCK	= 0x8,	/* ignore mlock */
> +	TTU_IGNORE_ACCESS	= 0x10,	/* don't age */
> +	TTU_IGNORE_HWPOISON	= 0x20,	/* corrupted page is recoverable */
> +	TTU_BATCH_FLUSH		= 0x40,	/* Batch TLB flushes where possible
>  					 * and caller guarantees they will
>  					 * do a final flush if necessary */
> -	TTU_RMAP_LOCKED = (1 << 12)	/* do not grab rmap lock:
> +	TTU_RMAP_LOCKED		= 0x80	/* do not grab rmap lock:
>  					 * caller holds it */
>  };
>  
> @@ -193,8 +191,6 @@ static inline void page_dup_rmap(struct page *page, bool compound)
>  int page_referenced(struct page *, int is_locked,
>  			struct mem_cgroup *memcg, unsigned long *vm_flags);
>  
> -#define TTU_ACTION(x) ((x) & TTU_ACTION_MASK)
> -
>  int try_to_unmap(struct page *, enum ttu_flags flags);
>  
>  /* Avoid racy checks */
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 3d0f2fd..b78d080 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -906,7 +906,7 @@ EXPORT_SYMBOL_GPL(get_hwpoison_page);
>  static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
>  				  int trapno, int flags, struct page **hpagep)
>  {
> -	enum ttu_flags ttu = TTU_UNMAP | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
> +	enum ttu_flags ttu = TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
>  	struct address_space *mapping;
>  	LIST_HEAD(tokill);
>  	int ret;
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 8774791..96eb85c 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1418,7 +1418,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  			 */
>  			VM_BUG_ON_PAGE(!PageSwapCache(page), page);
>  
> -			if (!PageDirty(page) && (flags & TTU_LZFREE)) {
> +			if (!PageDirty(page)) {
>  				/* It's a freeable page by MADV_FREE */
>  				dec_mm_counter(mm, MM_ANONPAGES);
>  				rp->lazyfreed++;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 26c3b40..68ea50d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -971,7 +971,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		int may_enter_fs;
>  		enum page_references references = PAGEREF_RECLAIM_CLEAN;
>  		bool dirty, writeback;
> -		bool lazyfree = false;
>  		int ret = SWAP_SUCCESS;
>  
>  		cond_resched();
> @@ -1125,7 +1124,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  				goto keep_locked;
>  			if (!add_to_swap(page, page_list))
>  				goto activate_locked;
> -			lazyfree = true;
>  			may_enter_fs = 1;
>  
>  			/* Adding to swap updated mapping */
> @@ -1143,9 +1141,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		 * processes. Try to unmap it here.
>  		 */
>  		if (page_mapped(page) && mapping) {
> -			switch (ret = try_to_unmap(page, lazyfree ?
> -				(ttu_flags | TTU_BATCH_FLUSH | TTU_LZFREE) :
> -				(ttu_flags | TTU_BATCH_FLUSH))) {
> +			switch (ret = try_to_unmap(page,
> +				ttu_flags | TTU_BATCH_FLUSH)) {
>  			case SWAP_FAIL:
>  				nr_unmap_fail++;
>  				goto activate_locked;
> @@ -1353,7 +1350,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>  	}
>  
>  	ret = shrink_page_list(&clean_pages, zone->zone_pgdat, &sc,
> -			TTU_UNMAP|TTU_IGNORE_ACCESS, NULL, true);
> +			TTU_IGNORE_ACCESS, NULL, true);
>  	list_splice(&clean_pages, page_list);
>  	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, -ret);
>  	return ret;
> @@ -1760,7 +1757,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	if (nr_taken == 0)
>  		return 0;
>  
> -	nr_reclaimed = shrink_page_list(&page_list, pgdat, sc, TTU_UNMAP,
> +	nr_reclaimed = shrink_page_list(&page_list, pgdat, sc, 0,
>  				&stat, false);
>  
>  	spin_lock_irq(&pgdat->lru_lock);
> -- 
> 2.9.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
