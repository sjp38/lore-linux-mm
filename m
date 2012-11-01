Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 3020C6B0062
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 08:20:34 -0400 (EDT)
Date: Thu, 1 Nov 2012 12:20:27 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 17/31] mm/migrate: Introduce migrate_misplaced_page()
Message-ID: <20121101122027.GV3888@suse.de>
References: <20121025121617.617683848@chello.nl>
 <20121025124833.785487250@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121025124833.785487250@chello.nl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Ingo Molnar <mingo@kernel.org>

On Thu, Oct 25, 2012 at 02:16:34PM +0200, Peter Zijlstra wrote:
> Add migrate_misplaced_page() which deals with migrating pages from
> faults. 
> 
> This includes adding a new MIGRATE_FAULT migration mode to
> deal with the extra page reference required due to having to look up
> the page.
> 
> Based-on-work-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Cc: Paul Turner <pjt@google.com>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Ingo Molnar <mingo@kernel.org>
> ---
>  include/linux/migrate.h      |    7 +++
>  include/linux/migrate_mode.h |    3 +
>  mm/migrate.c                 |   85 ++++++++++++++++++++++++++++++++++++++-----
>  3 files changed, 87 insertions(+), 8 deletions(-)
> 
> Index: tip/include/linux/migrate.h
> ===================================================================
> --- tip.orig/include/linux/migrate.h
> +++ tip/include/linux/migrate.h
> @@ -30,6 +30,7 @@ extern int migrate_vmas(struct mm_struct
>  extern void migrate_page_copy(struct page *newpage, struct page *page);
>  extern int migrate_huge_page_move_mapping(struct address_space *mapping,
>  				  struct page *newpage, struct page *page);
> +extern int migrate_misplaced_page(struct page *page, int node);
>  #else
>  
>  static inline void putback_lru_pages(struct list_head *l) {}
> @@ -63,5 +64,11 @@ static inline int migrate_huge_page_move
>  #define migrate_page NULL
>  #define fail_migrate_page NULL
>  
> +static inline
> +int migrate_misplaced_page(struct page *page, int node)
> +{
> +	return -EAGAIN; /* can't migrate now */
> +}
>  #endif /* CONFIG_MIGRATION */
> +
>  #endif /* _LINUX_MIGRATE_H */
> Index: tip/include/linux/migrate_mode.h
> ===================================================================
> --- tip.orig/include/linux/migrate_mode.h
> +++ tip/include/linux/migrate_mode.h
> @@ -6,11 +6,14 @@
>   *	on most operations but not ->writepage as the potential stall time
>   *	is too significant
>   * MIGRATE_SYNC will block when migrating pages
> + * MIGRATE_FAULT called from the fault path to migrate-on-fault for mempolicy
> + *	this path has an extra reference count
>   */
>  enum migrate_mode {
>  	MIGRATE_ASYNC,
>  	MIGRATE_SYNC_LIGHT,
>  	MIGRATE_SYNC,
> +	MIGRATE_FAULT,
>  };
>  
>  #endif		/* MIGRATE_MODE_H_INCLUDED */
> Index: tip/mm/migrate.c
> ===================================================================
> --- tip.orig/mm/migrate.c
> +++ tip/mm/migrate.c
> @@ -225,7 +225,7 @@ static bool buffer_migrate_lock_buffers(
>  	struct buffer_head *bh = head;
>  
>  	/* Simple case, sync compaction */
> -	if (mode != MIGRATE_ASYNC) {
> +	if (mode != MIGRATE_ASYNC && mode != MIGRATE_FAULT) {
>  		do {
>  			get_bh(bh);
>  			lock_buffer(bh);
> @@ -279,12 +279,22 @@ static int migrate_page_move_mapping(str
>  		struct page *newpage, struct page *page,
>  		struct buffer_head *head, enum migrate_mode mode)
>  {
> -	int expected_count;
> +	int expected_count = 0;
>  	void **pslot;
>  
> +	if (mode == MIGRATE_FAULT) {
> +		/*
> +		 * MIGRATE_FAULT has an extra reference on the page and
> +		 * otherwise acts like ASYNC, no point in delaying the
> +		 * fault, we'll try again next time.
> +		 */
> +		expected_count++;
> +	}
> +
>  	if (!mapping) {
>  		/* Anonymous page without mapping */
> -		if (page_count(page) != 1)
> +		expected_count += 1;
> +		if (page_count(page) != expected_count)
>  			return -EAGAIN;
>  		return 0;
>  	}
> @@ -294,7 +304,7 @@ static int migrate_page_move_mapping(str
>  	pslot = radix_tree_lookup_slot(&mapping->page_tree,
>   					page_index(page));
>  
> -	expected_count = 2 + page_has_private(page);
> +	expected_count += 2 + page_has_private(page);
>  	if (page_count(page) != expected_count ||
>  		radix_tree_deref_slot_protected(pslot, &mapping->tree_lock) != page) {
>  		spin_unlock_irq(&mapping->tree_lock);
> @@ -313,7 +323,7 @@ static int migrate_page_move_mapping(str
>  	 * the mapping back due to an elevated page count, we would have to
>  	 * block waiting on other references to be dropped.
>  	 */
> -	if (mode == MIGRATE_ASYNC && head &&
> +	if ((mode == MIGRATE_ASYNC || mode == MIGRATE_FAULT) && head &&
>  			!buffer_migrate_lock_buffers(head, mode)) {
>  		page_unfreeze_refs(page, expected_count);
>  		spin_unlock_irq(&mapping->tree_lock);
> @@ -521,7 +531,7 @@ int buffer_migrate_page(struct address_s
>  	 * with an IRQ-safe spinlock held. In the sync case, the buffers
>  	 * need to be locked now
>  	 */
> -	if (mode != MIGRATE_ASYNC)
> +	if (mode != MIGRATE_ASYNC && mode != MIGRATE_FAULT)
>  		BUG_ON(!buffer_migrate_lock_buffers(head, mode));
>  
>  	ClearPagePrivate(page);
> @@ -687,7 +697,7 @@ static int __unmap_and_move(struct page
>  	struct anon_vma *anon_vma = NULL;
>  
>  	if (!trylock_page(page)) {
> -		if (!force || mode == MIGRATE_ASYNC)
> +		if (!force || mode == MIGRATE_ASYNC || mode == MIGRATE_FAULT)
>  			goto out;
>  
>  		/*
> @@ -1403,4 +1413,63 @@ int migrate_vmas(struct mm_struct *mm, c
>   	}
>   	return err;
>  }
> -#endif
> +
> +/*
> + * Attempt to migrate a misplaced page to the specified destination
> + * node.
> + */
> +int migrate_misplaced_page(struct page *page, int node)
> +{
> +	struct address_space *mapping = page_mapping(page);
> +	int page_lru = page_is_file_cache(page);
> +	struct page *newpage;
> +	int ret = -EAGAIN;
> +	gfp_t gfp = GFP_HIGHUSER_MOVABLE;
> +
> +	/*
> +	 * Don't migrate pages that are mapped in multiple processes.
> +	 */
> +	if (page_mapcount(page) != 1)
> +		goto out;
> +

Why?

I know why -- it's because we don't want to ping-pong shared library
pages.

However, what if it's a shmem mapping? We might want to consider migrating
those but with this check that will never happen.

> +	/*
> +	 * Never wait for allocations just to migrate on fault, but don't dip
> +	 * into reserves. And, only accept pages from the specified node. No
> +	 * sense migrating to a different "misplaced" page!
> +	 */

Not only that,  we do not want to reclaim on a remote node to allow
migration. The cost of reclaim will exceed the benefit from local memory
accesses.

> +	if (mapping)
> +		gfp = mapping_gfp_mask(mapping);
> +	gfp &= ~__GFP_WAIT;
> +	gfp |= __GFP_NOMEMALLOC | GFP_THISNODE;
> +
> +	newpage = alloc_pages_node(node, gfp, 0);
> +	if (!newpage) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +
> +	if (isolate_lru_page(page)) {
> +		ret = -EBUSY;
> +		goto put_new;
> +	}
> +

Going to need to keep an eye on the hotness of the LRU lock during heavy
migration states. Actually, a process using MPOL_MF_LAZY and then creating
a large number of threads is going to hammer that lock. I've no proposed
solution to this but if we see a bug report related to stalls after using
that system call then this will be a candidate.

Compaction had to use trylock-like logic to get around this problem but
it's not necessarily the right choice for lazy migration unless you are
willing to depend on the automatic detection to fix it up later.

> +	inc_zone_page_state(page, NR_ISOLATED_ANON + page_lru);
> +	ret = __unmap_and_move(page, newpage, 0, 0, MIGRATE_FAULT);

By bypassing __unmap_and_move, you miss the PageTransHuge() check in
unmap_and_move and the splitting when a transhuge is encountered. Was that
deliberate? Why?

> +	/*
> +	 * A page that has been migrated has all references removed and will be
> +	 * freed. A page that has not been migrated will have kepts its
> +	 * references and be restored.
> +	 */
> +	dec_zone_page_state(page, NR_ISOLATED_ANON + page_lru);
> +	putback_lru_page(page);
> +put_new:
> +	/*
> +	 * Move the new page to the LRU. If migration was not successful
> +	 * then this will free the page.
> +	 */
> +	putback_lru_page(newpage);
> +out:
> +	return ret;
> +}
> +
> +#endif /* CONFIG_NUMA */
> 
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
