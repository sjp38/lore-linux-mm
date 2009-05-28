Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C63F06B004D
	for <linux-mm@kvack.org>; Thu, 28 May 2009 03:26:44 -0400 (EDT)
Date: Thu, 28 May 2009 09:27:03 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [9/16] HWPOISON: Use bitmask/action code for try_to_unmap behaviour
Message-ID: <20090528072703.GF6920@wotan.suse.de>
References: <200905271012.668777061@firstfloor.org> <20090527201235.9475E1D0292@basil.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090527201235.9475E1D0292@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Lee.Schermerhorn@hp.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Wed, May 27, 2009 at 10:12:35PM +0200, Andi Kleen wrote:
> 
> try_to_unmap currently has multiple modi (migration, munlock, normal unmap)
> which are selected by magic flag variables. The logic is not very straight
> forward, because each of these flag change multiple behaviours (e.g.
> migration turns off aging, not only sets up migration ptes etc.)
> Also the different flags interact in magic ways.
> 
> A later patch in this series adds another mode to try_to_unmap, so 
> this becomes quickly unmanageable.
> 
> Replace the different flags with a action code (migration, munlock, munmap)
> and some additional flags as modifiers (ignore mlock, ignore aging).
> This makes the logic more straight forward and allows easier extension
> to new behaviours. Change all the caller to declare what they want to 
> do.
> 
> This patch is supposed to be a nop in behaviour. If anyone can prove 
> it is not that would be a bug.

Not a bad idea, but I would prefer to have a set of flags which tell
try_to_unmap what to do, and then combine them with #defines for
callers. Like gfp flags.

And just use regular bitops rather than this TTU_ACTION macro.

> 
> Cc: Lee.Schermerhorn@hp.com
> Cc: npiggin@suse.de
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> 
> ---
>  include/linux/rmap.h |   14 +++++++++++++-
>  mm/migrate.c         |    2 +-
>  mm/rmap.c            |   40 ++++++++++++++++++++++------------------
>  mm/vmscan.c          |    2 +-
>  4 files changed, 37 insertions(+), 21 deletions(-)
> 
> Index: linux/include/linux/rmap.h
> ===================================================================
> --- linux.orig/include/linux/rmap.h	2009-05-27 21:14:21.000000000 +0200
> +++ linux/include/linux/rmap.h	2009-05-27 21:19:18.000000000 +0200
> @@ -84,7 +84,19 @@
>   * Called from mm/vmscan.c to handle paging out
>   */
>  int page_referenced(struct page *, int is_locked, struct mem_cgroup *cnt);
> -int try_to_unmap(struct page *, int ignore_refs);
> +
> +enum ttu_flags {
> +	TTU_UNMAP = 0,			/* unmap mode */
> +	TTU_MIGRATION = 1,		/* migration mode */
> +	TTU_MUNLOCK = 2,		/* munlock mode */
> +	TTU_ACTION_MASK = 0xff,
> +
> +	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
> +	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
> +};
> +#define TTU_ACTION(x) ((x) & TTU_ACTION_MASK)
> +
> +int try_to_unmap(struct page *, enum ttu_flags flags);
>  
>  /*
>   * Called from mm/filemap_xip.c to unmap empty zero page
> Index: linux/mm/rmap.c
> ===================================================================
> --- linux.orig/mm/rmap.c	2009-05-27 21:14:21.000000000 +0200
> +++ linux/mm/rmap.c	2009-05-27 21:19:18.000000000 +0200
> @@ -755,7 +755,7 @@
>   * repeatedly from either try_to_unmap_anon or try_to_unmap_file.
>   */
>  static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> -				int migration)
> +				enum ttu_flags flags)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	unsigned long address;
> @@ -777,11 +777,13 @@
>  	 * If it's recently referenced (perhaps page_referenced
>  	 * skipped over this mm) then we should reactivate it.
>  	 */
> -	if (!migration) {
> +	if (!(flags & TTU_IGNORE_MLOCK)) {
>  		if (vma->vm_flags & VM_LOCKED) {
>  			ret = SWAP_MLOCK;
>  			goto out_unmap;
>  		}
> +	}
> +	if (!(flags & TTU_IGNORE_ACCESS)) {
>  		if (ptep_clear_flush_young_notify(vma, address, pte)) {
>  			ret = SWAP_FAIL;
>  			goto out_unmap;
> @@ -821,12 +823,12 @@
>  			 * pte. do_swap_page() will wait until the migration
>  			 * pte is removed and then restart fault handling.
>  			 */
> -			BUG_ON(!migration);
> +			BUG_ON(TTU_ACTION(flags) != TTU_MIGRATION);
>  			entry = make_migration_entry(page, pte_write(pteval));
>  		}
>  		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
>  		BUG_ON(pte_file(*pte));
> -	} else if (PAGE_MIGRATION && migration) {
> +	} else if (PAGE_MIGRATION && (TTU_ACTION(flags) == TTU_MIGRATION)) {
>  		/* Establish migration entry for a file page */
>  		swp_entry_t entry;
>  		entry = make_migration_entry(page, pte_write(pteval));
> @@ -995,12 +997,13 @@
>   * vm_flags for that VMA.  That should be OK, because that vma shouldn't be
>   * 'LOCKED.
>   */
> -static int try_to_unmap_anon(struct page *page, int unlock, int migration)
> +static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
>  {
>  	struct anon_vma *anon_vma;
>  	struct vm_area_struct *vma;
>  	unsigned int mlocked = 0;
>  	int ret = SWAP_AGAIN;
> +	int unlock = TTU_ACTION(flags) == TTU_MUNLOCK;
>  
>  	if (MLOCK_PAGES && unlikely(unlock))
>  		ret = SWAP_SUCCESS;	/* default for try_to_munlock() */
> @@ -1016,7 +1019,7 @@
>  				continue;  /* must visit all unlocked vmas */
>  			ret = SWAP_MLOCK;  /* saw at least one mlocked vma */
>  		} else {
> -			ret = try_to_unmap_one(page, vma, migration);
> +			ret = try_to_unmap_one(page, vma, flags);
>  			if (ret == SWAP_FAIL || !page_mapped(page))
>  				break;
>  		}
> @@ -1040,8 +1043,7 @@
>  /**
>   * try_to_unmap_file - unmap/unlock file page using the object-based rmap method
>   * @page: the page to unmap/unlock
> - * @unlock:  request for unlock rather than unmap [unlikely]
> - * @migration:  unmapping for migration - ignored if @unlock
> + * @flags: action and flags
>   *
>   * Find all the mappings of a page using the mapping pointer and the vma chains
>   * contained in the address_space struct it points to.
> @@ -1053,7 +1055,7 @@
>   * vm_flags for that VMA.  That should be OK, because that vma shouldn't be
>   * 'LOCKED.
>   */
> -static int try_to_unmap_file(struct page *page, int unlock, int migration)
> +static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
>  {
>  	struct address_space *mapping = page->mapping;
>  	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> @@ -1065,6 +1067,7 @@
>  	unsigned long max_nl_size = 0;
>  	unsigned int mapcount;
>  	unsigned int mlocked = 0;
> +	int unlock = TTU_ACTION(flags) == TTU_MUNLOCK;
>  
>  	if (MLOCK_PAGES && unlikely(unlock))
>  		ret = SWAP_SUCCESS;	/* default for try_to_munlock() */
> @@ -1077,7 +1080,7 @@
>  				continue;	/* must visit all vmas */
>  			ret = SWAP_MLOCK;
>  		} else {
> -			ret = try_to_unmap_one(page, vma, migration);
> +			ret = try_to_unmap_one(page, vma, flags);
>  			if (ret == SWAP_FAIL || !page_mapped(page))
>  				goto out;
>  		}
> @@ -1102,7 +1105,8 @@
>  			ret = SWAP_MLOCK;	/* leave mlocked == 0 */
>  			goto out;		/* no need to look further */
>  		}
> -		if (!MLOCK_PAGES && !migration && (vma->vm_flags & VM_LOCKED))
> +		if (!MLOCK_PAGES && !(flags & TTU_IGNORE_MLOCK) &&
> +			(vma->vm_flags & VM_LOCKED))
>  			continue;
>  		cursor = (unsigned long) vma->vm_private_data;
>  		if (cursor > max_nl_cursor)
> @@ -1136,7 +1140,7 @@
>  	do {
>  		list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
>  						shared.vm_set.list) {
> -			if (!MLOCK_PAGES && !migration &&
> +			if (!MLOCK_PAGES && !(flags & TTU_IGNORE_MLOCK) &&
>  			    (vma->vm_flags & VM_LOCKED))
>  				continue;
>  			cursor = (unsigned long) vma->vm_private_data;
> @@ -1176,7 +1180,7 @@
>  /**
>   * try_to_unmap - try to remove all page table mappings to a page
>   * @page: the page to get unmapped
> - * @migration: migration flag
> + * @flags: action and flags
>   *
>   * Tries to remove all the page table entries which are mapping this
>   * page, used in the pageout path.  Caller must hold the page lock.
> @@ -1187,16 +1191,16 @@
>   * SWAP_FAIL	- the page is unswappable
>   * SWAP_MLOCK	- page is mlocked.
>   */
> -int try_to_unmap(struct page *page, int migration)
> +int try_to_unmap(struct page *page, enum ttu_flags flags)
>  {
>  	int ret;
>  
>  	BUG_ON(!PageLocked(page));
>  
>  	if (PageAnon(page))
> -		ret = try_to_unmap_anon(page, 0, migration);
> +		ret = try_to_unmap_anon(page, flags);
>  	else
> -		ret = try_to_unmap_file(page, 0, migration);
> +		ret = try_to_unmap_file(page, flags);
>  	if (ret != SWAP_MLOCK && !page_mapped(page))
>  		ret = SWAP_SUCCESS;
>  	return ret;
> @@ -1222,8 +1226,8 @@
>  	VM_BUG_ON(!PageLocked(page) || PageLRU(page));
>  
>  	if (PageAnon(page))
> -		return try_to_unmap_anon(page, 1, 0);
> +		return try_to_unmap_anon(page, TTU_MUNLOCK);
>  	else
> -		return try_to_unmap_file(page, 1, 0);
> +		return try_to_unmap_file(page, TTU_MUNLOCK);
>  }
>  #endif
> Index: linux/mm/vmscan.c
> ===================================================================
> --- linux.orig/mm/vmscan.c	2009-05-27 21:13:54.000000000 +0200
> +++ linux/mm/vmscan.c	2009-05-27 21:14:21.000000000 +0200
> @@ -666,7 +666,7 @@
>  		 * processes. Try to unmap it here.
>  		 */
>  		if (page_mapped(page) && mapping) {
> -			switch (try_to_unmap(page, 0)) {
> +			switch (try_to_unmap(page, TTU_UNMAP)) {
>  			case SWAP_FAIL:
>  				goto activate_locked;
>  			case SWAP_AGAIN:
> Index: linux/mm/migrate.c
> ===================================================================
> --- linux.orig/mm/migrate.c	2009-05-27 21:13:54.000000000 +0200
> +++ linux/mm/migrate.c	2009-05-27 21:14:21.000000000 +0200
> @@ -669,7 +669,7 @@
>  	}
>  
>  	/* Establish migration ptes or remove ptes */
> -	try_to_unmap(page, 1);
> +	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
>  
>  	if (!page_mapped(page))
>  		rc = move_to_new_page(newpage, page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
