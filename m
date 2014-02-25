Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id EC6706B00B9
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 15:14:54 -0500 (EST)
Received: by mail-qa0-f45.google.com with SMTP id m5so997799qaj.32
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 12:14:54 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [2002:4a5c:3b41:1:216:3eff:fe57:7f4])
        by mx.google.com with ESMTPS id b7si762036qad.126.2014.02.25.12.14.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 12:14:54 -0800 (PST)
Message-ID: <530CF9B8.1020008@surriel.com>
Date: Tue, 25 Feb 2014 15:14:48 -0500
From: Rik van Riel <riel@surriel.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm:prototype for the updated swapoff implementation
References: <20140219003522.GA8887@kelleynnn-virtual-machine>
In-Reply-To: <20140219003522.GA8887@kelleynnn-virtual-machine>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kelley Nielsen <kelleynnn@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, opw-kernel@googlegroups.com, jamieliu@google.com, sjenning@linux.vnet.ibm.com

On 02/18/2014 07:35 PM, Kelley Nielsen wrote:
> The function try_to_unuse() is of quadratic complexity, with a lot of
> wasted effort. It unuses swap entries one by one, potentially iterating
> over all the page tables for all the processes in the system for each
> one.
> 
> This new proposed implementation of try_to_unuse simplifies its
> complexity to linear. It iterates over the system's mms once, unusing
> all the affected entries as it walks each set of page tables. It also
> makes similar changes to shmem_unuse.

Nice work.  After reading some related code, I think I may have found
one of the issues you are running into...

> TODO
> 
> * Find and correct where swap entries are being left behind
> * Probably related: handle case of remaining reference in try_to_unuse

It looks like the way you iterate over the mmlist may not be safe.

I believe you need the mm / prev_mm juggling, to make sure that you
never call mmput on an mm before dereferencing mm->mmlist.next.

Otherwise, the process holding the mm can exit during swapoff, and
swapoff will be the last user of the mm. Calling mmput will free
the mm_struct, after which the memory can be re-used for something
else.

In the best case, this can lead to swapoff continuing the scan at
another spot in the mmlist. At the worst case, the code can follow
a pointer to la-la land.

> * Remove find_next_to_unuse, and the call to it in try_to_unuse,
>   when the previous item has been resolved
> * Handle the failure of swapin_readahead in unuse_pte_range

When swapin_readahead fails to allocate memory, the swapoff operation
can be aborted.

When it runs into a swap slot that is no longer in use, swapoff can
continue.

> * make sure unuse_pte_range is handling multiple ptes in the best way

I would not worry about that for now. The reduction from quadratic
to linear complexity should be quite a performance boost :)

> * clean up after failure of unuse_pte in unuse_pte_range
> * Determine the proper place for the mmlist locks in try_to_unuse

The mmlist lock needs to be held until after mm->mmlist.next has
been dereferenced.

> * Handle count of unused pages for frontswap

This can probably be deferred till later.

> * Determine what kind of housekeeping shmem_unuse needs
> * Tighten up the access control for all the various data structures
>   (for instance, the mutex on shmem_swaplist is held throughout the
>   entire process, which is probably not only unneccesary but problematic)
> * Prevent radix entries with zero indices from being passed to
>   shmem_unuse_inode_index

Can you pass only exceptional radix tree entries?

> * Decide if shmem_unuse_inode* should be combined into one function

Probably :)

> * Find cases in which the errors returned from shmem_getpage_gfp can be
>   gracefully handled in shmem_unuse_inode_index, instead of just failing
> * determine when old comments and housekeeping are no longer needed
>   (there are still some to serve as reminders of the housekeeping that
>    needs to be accounted for)

It probably makes sense to not try to do everything at once, but send
in incrementally improved patches.

> ---
>  include/linux/shmem_fs.h |   2 +-
>  mm/shmem.c               | 146 +++++++-------------
>  mm/swapfile.c            | 352 ++++++++++++++++++++---------------------------
>  3 files changed, 206 insertions(+), 294 deletions(-)
> 
> diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
> index 9d55438..af78151 100644
> --- a/include/linux/shmem_fs.h
> +++ b/include/linux/shmem_fs.h
> @@ -55,7 +55,7 @@ extern void shmem_unlock_mapping(struct address_space *mapping);
>  extern struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
>  					pgoff_t index, gfp_t gfp_mask);
>  extern void shmem_truncate_range(struct inode *inode, loff_t start, loff_t end);
> -extern int shmem_unuse(swp_entry_t entry, struct page *page);
> +extern int shmem_unuse(unsigned int type);
>  
>  static inline struct page *shmem_read_mapping_page(
>  				struct address_space *mapping, pgoff_t index)
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 1f18c9d..802456e 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -650,127 +650,87 @@ static void shmem_evict_inode(struct inode *inode)
>  /*
>   * If swap found in inode, free it and move page from swapcache to filecache.
>   */
> -static int shmem_unuse_inode(struct shmem_inode_info *info,
> -			     swp_entry_t swap, struct page **pagep)
> +/* TODO Since there's hardly anything left of this function
> + * now that the things shmem_getpage_gfp does have been removed,
> + * just incorporate its actions into shmem_unuse_inode?
> + */
> +static int shmem_unuse_inode_index(struct shmem_inode_info *info,
> +			     pgoff_t index)
>  {
>  	struct address_space *mapping = info->vfs_inode.i_mapping;
> -	void *radswap;
> -	pgoff_t index;
> +	struct page *pagep;
>  	gfp_t gfp;
>  	int error = 0;
>  
> -	radswap = swp_to_radix_entry(swap);
> -	index = radix_tree_locate_item(&mapping->page_tree, radswap);
> -	if (index == -1)
> -		return 0;
> -
> -	/*
> -	 * Move _head_ to start search for next from here.
> -	 * But be careful: shmem_evict_inode checks list_empty without taking
> -	 * mutex, and there's an instant in list_move_tail when info->swaplist
> -	 * would appear empty, if it were the only one on shmem_swaplist.
> +	gfp = mapping_gfp_mask(mapping);
> +	error = shmem_getpage_gfp(&info->vfs_inode, index, &pagep, SGP_CACHE,
> +			gfp, NULL);
> +	/* TODO: go through all the possible error returns
> +	 * in shmem_getpage_gfp, and determine whether
> +	 * we need to fail, or whether we can gracefully recover.
> +	 * (for instance, if the page was swapped in from somewhere
> +	 * else in the kernel between the start of swapoff and now,
> +	 * and can be safely let go.)
> +	 * For now, send failure up the call chain for all errors.
>  	 */
> -	if (shmem_swaplist.next != &info->swaplist)
> -		list_move_tail(&shmem_swaplist, &info->swaplist);
> +	return error;
> +}
>  
> -	gfp = mapping_gfp_mask(mapping);
> -	if (shmem_should_replace_page(*pagep, gfp)) {
> -		mutex_unlock(&shmem_swaplist_mutex);
> -		error = shmem_replace_page(pagep, gfp, info, index);
> -		mutex_lock(&shmem_swaplist_mutex);
> -		/*
> -		 * We needed to drop mutex to make that restrictive page
> -		 * allocation, but the inode might have been freed while we
> -		 * dropped it: although a racing shmem_evict_inode() cannot
> -		 * complete without emptying the radix_tree, our page lock
> -		 * on this swapcache page is not enough to prevent that -
> -		 * free_swap_and_cache() of our swap entry will only
> -		 * trylock_page(), removing swap from radix_tree whatever.
> -		 *
> -		 * We must not proceed to shmem_add_to_page_cache() if the
> -		 * inode has been freed, but of course we cannot rely on
> -		 * inode or mapping or info to check that.  However, we can
> -		 * safely check if our swap entry is still in use (and here
> -		 * it can't have got reused for another page): if it's still
> -		 * in use, then the inode cannot have been freed yet, and we
> -		 * can safely proceed (if it's no longer in use, that tells
> -		 * nothing about the inode, but we don't need to unuse swap).
> -		 */
> -		if (!page_swapcount(*pagep))
> -			error = -ENOENT;
> -	}
> +/* TODO some pages with a null index are slipping through
> + * and being passed to shmem_unuse_inode_index
> + */
> +static int shmem_unuse_inode(struct shmem_inode_info *info, unsigned int type){
> +	struct address_space *mapping = info->vfs_inode.i_mapping;
> +	void **slot;
> +	struct radix_tree_iter iter;
> +	int error = 0;
>  
> -	/*
> -	 * We rely on shmem_swaplist_mutex, not only to protect the swaplist,
> -	 * but also to hold up shmem_evict_inode(): so inode cannot be freed
> -	 * beneath us (pagelock doesn't help until the page is in pagecache).
> -	 */
> -	if (!error)
> -		error = shmem_add_to_page_cache(*pagep, mapping, index,
> -						GFP_NOWAIT, radswap);
> -	if (error != -ENOMEM) {
> -		/*
> -		 * Truncation and eviction use free_swap_and_cache(), which
> -		 * only does trylock page: if we raced, best clean up here.
> -		 */
> -		delete_from_swap_cache(*pagep);
> -		set_page_dirty(*pagep);
> -		if (!error) {
> -			spin_lock(&info->lock);
> -			info->swapped--;
> -			spin_unlock(&info->lock);
> -			swap_free(swap);
> +	rcu_read_lock();
> +	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, 0){
> +		struct page *page;
> +		pgoff_t index;
> +		swp_entry_t entry;
> +		unsigned int stype;
> +
> +		index = iter.index;
> +		page = radix_tree_deref_slot(slot);
> +		if (unlikely(!page))
> +			continue;
> +		if (radix_tree_exceptional_entry(page)) {
> +			entry = radix_to_swp_entry(page);
> +			stype = swp_type(entry);
> +			if (stype == type){
> +				error = shmem_unuse_inode_index(info, index);
> +			}
>  		}
> -		error = 1;	/* not an error, but entry was found */
> +		if (error)
> +		break;
>  	}
> +	rcu_read_unlock();
>  	return error;
>  }
>  
> -/*
> - * Search through swapped inodes to find and replace swap by page.
> +/* unuse all the shared memory swap entries that
> + * have backing store in the designated swap type.
>   */
> -int shmem_unuse(swp_entry_t swap, struct page *page)
> +int shmem_unuse(unsigned int type)
>  {
>  	struct list_head *this, *next;
>  	struct shmem_inode_info *info;
> -	int found = 0;
>  	int error = 0;
>  
> -	/*
> -	 * There's a faint possibility that swap page was replaced before
> -	 * caller locked it: caller will come back later with the right page.
> -	 */
> -	if (unlikely(!PageSwapCache(page) || page_private(page) != swap.val))
> -		goto out;
> -
> -	/*
> -	 * Charge page using GFP_KERNEL while we can wait, before taking
> -	 * the shmem_swaplist_mutex which might hold up shmem_writepage().
> -	 * Charged back to the user (not to caller) when swap account is used.
> -	 */
> -	error = mem_cgroup_cache_charge(page, current->mm, GFP_KERNEL);
> -	if (error)
> -		goto out;
> -	/* No radix_tree_preload: swap entry keeps a place for page in tree */
> -
>  	mutex_lock(&shmem_swaplist_mutex);
>  	list_for_each_safe(this, next, &shmem_swaplist) {
>  		info = list_entry(this, struct shmem_inode_info, swaplist);
>  		if (info->swapped)
> -			found = shmem_unuse_inode(info, swap, &page);
> +			error = shmem_unuse_inode(info, type);
>  		else
>  			list_del_init(&info->swaplist);
>  		cond_resched();
> -		if (found)
> +		if (error)
>  			break;
>  	}
>  	mutex_unlock(&shmem_swaplist_mutex);
> -
> -	if (found < 0)
> -		error = found;
> -out:
> -	unlock_page(page);
> -	page_cache_release(page);
>  	return error;
>  }
>  
> @@ -2873,7 +2833,7 @@ int __init shmem_init(void)
>  	return 0;
>  }
>  
> -int shmem_unuse(swp_entry_t swap, struct page *page)
> +int shmem_unuse(unsigned int type)
>  {
>  	return 0;
>  }
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 4a7f7e6..b69e319 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -68,6 +68,9 @@ static DECLARE_WAIT_QUEUE_HEAD(proc_poll_wait);
>  /* Activity counter to indicate that a swapon or swapoff has occurred */
>  static atomic_t proc_poll_event = ATOMIC_INIT(0);
>  
> +/* count instances of unuse_pte for the changelog */
> +static long unusepte_calls = 0;
> +
>  static inline unsigned char swap_count(unsigned char ent)
>  {
>  	return ent & ~SWAP_HAS_CACHE;	/* may include SWAP_HAS_CONT flag */
> @@ -1167,13 +1170,18 @@ out_nolock:
>  
>  static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  				unsigned long addr, unsigned long end,
> -				swp_entry_t entry, struct page *page)
> +				unsigned int type)
>  {
> -	pte_t swp_pte = swp_entry_to_pte(entry);
> +	struct page * page;
> +	swp_entry_t entry;
> +	unsigned int found_type;
>  	pte_t *pte;
>  	int ret = 0;
>  
> +	unusepte_calls++;
> +
>  	/*
> +	 * TODO comment left from original:
>  	 * We don't actually need pte lock while scanning for swp_pte: since
>  	 * we hold page lock and mmap_sem, swp_pte cannot be inserted into the
>  	 * page table while we're scanning; though it could get zapped, and on
> @@ -1184,16 +1192,71 @@ static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  	 */
>  	pte = pte_offset_map(pmd, addr);
>  	do {
> +		if (is_swap_pte(*pte)){
> +			entry = pte_to_swp_entry(*pte);
> +			found_type = swp_type(entry);
> +		}
> +		else {
> +			continue;
> +		}
> +		if (found_type == type){
> +			entry = pte_to_swp_entry(*pte);
> +			page = swapin_readahead(entry, GFP_HIGHUSER_MOVABLE,
> +					vma, addr);
> +			if (!page){
> +				/* TODO not sure yet what to do here, or
> +				 * how great the chance of the page
> +				 * not existing actually is.
> +				 * There is a comment in try_to_unuse
> +				 * about the page possibly being freed
> +				 * independently, etc
> +				 */
> +				printk("unuse_pte tried to swap in an invalid page\n");
> +				continue;
> +			}
>  		/*
> -		 * swapoff spends a _lot_ of time in this loop!
> -		 * Test inline before going to call unuse_pte.
> +		 * Wait for and lock page.  When do_swap_page races with
> +		 * try_to_unuse, do_swap_page can handle the fault much
> +		 * faster than try_to_unuse can locate the entry.  This
> +		 * apparently redundant "wait_on_page_locked" lets try_to_unuse
> +		 * defer to do_swap_page in such a case - in some tests,
> +		 * do_swap_page and try_to_unuse repeatedly compete.
>  		 */
> -		if (unlikely(maybe_same_pte(*pte, swp_pte))) {
> +			wait_on_page_locked(page);
> +			wait_on_page_writeback(page);
> +			lock_page(page);
> +			wait_on_page_writeback(page);
>  			pte_unmap(pte);
>  			ret = unuse_pte(vma, pmd, addr, entry, page);
> -			if (ret)
> -				goto out;
> -			pte = pte_offset_map(pmd, addr);
> +		/* TODO fix
> +		 * in the new way, we unuse
> +		 * all ptes in the range or fail before returning.
> +		 * For now, leave the return from unuse_pte as is,
> +		 * move on and unuse the next pte.
> +		 */
> +		if (ret < 1){
> +			/* TODO for now, we're just returning
> +			 * the error if unuse_pte fails.
> +			 * we need to clean up the allocated page,
> +			 * plus all the rest of the mess
> +			 */
> +			unlock_page(page);
> +			goto out;
> +		}
> +		/*
> +		 * TODO moved here from try_to_unuse--still relevant?:
> +		 * It is conceivable that a racing task removed this page from
> +		 * swap cache just before we acquired the page lock at the top,
> +		 * or while we dropped it in unuse_mm().  The page might even
> +		 * be back in swap cache on another swap area: that we must not
> +		 * delete, since it may not have been written out to swap yet.
> +		 */
> +		if (PageSwapCache(page) &&
> +		    likely(page_private(page) == entry.val))
> +			delete_from_swap_cache(page);
> +		SetPageDirty(page);
> +		unlock_page(page);
> +		page_cache_release(page);
>  		}
>  	} while (pte++, addr += PAGE_SIZE, addr != end);
>  	pte_unmap(pte - 1);
> @@ -1203,7 +1266,7 @@ out:
>  
>  static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
>  				unsigned long addr, unsigned long end,
> -				swp_entry_t entry, struct page *page)
> +				unsigned int type)
>  {
>  	pmd_t *pmd;
>  	unsigned long next;
> @@ -1214,8 +1277,8 @@ static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
>  		next = pmd_addr_end(addr, end);
>  		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
>  			continue;
> -		ret = unuse_pte_range(vma, pmd, addr, next, entry, page);
> -		if (ret)
> +		ret = unuse_pte_range(vma, pmd, addr, next, type);
> +		if (ret < 0)
>  			return ret;
>  	} while (pmd++, addr = next, addr != end);
>  	return 0;
> @@ -1223,7 +1286,7 @@ static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
>  
>  static inline int unuse_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
>  				unsigned long addr, unsigned long end,
> -				swp_entry_t entry, struct page *page)
> +				unsigned int type)
>  {
>  	pud_t *pud;
>  	unsigned long next;
> @@ -1234,67 +1297,52 @@ static inline int unuse_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
>  		next = pud_addr_end(addr, end);
>  		if (pud_none_or_clear_bad(pud))
>  			continue;
> -		ret = unuse_pmd_range(vma, pud, addr, next, entry, page);
> -		if (ret)
> +		ret = unuse_pmd_range(vma, pud, addr, next, type);
> +		if (ret < 0)
>  			return ret;
>  	} while (pud++, addr = next, addr != end);
>  	return 0;
>  }
>  
> -static int unuse_vma(struct vm_area_struct *vma,
> -				swp_entry_t entry, struct page *page)
> +static int unuse_vma(struct vm_area_struct *vma, unsigned int type)
>  {
>  	pgd_t *pgd;
>  	unsigned long addr, end, next;
>  	int ret;
>  
> -	if (page_anon_vma(page)) {
> -		addr = page_address_in_vma(page, vma);
> -		if (addr == -EFAULT)
> -			return 0;
> -		else
> -			end = addr + PAGE_SIZE;
> -	} else {
> -		addr = vma->vm_start;
> -		end = vma->vm_end;
> -	}
> +	addr = vma->vm_start;
> +	end = vma->vm_end;
>  
>  	pgd = pgd_offset(vma->vm_mm, addr);
>  	do {
>  		next = pgd_addr_end(addr, end);
>  		if (pgd_none_or_clear_bad(pgd))
>  			continue;
> -		ret = unuse_pud_range(vma, pgd, addr, next, entry, page);
> -		if (ret)
> +		ret = unuse_pud_range(vma, pgd, addr, next, type);
> +		if (ret < 0)
>  			return ret;
>  	} while (pgd++, addr = next, addr != end);
>  	return 0;
>  }
>  
> -static int unuse_mm(struct mm_struct *mm,
> -				swp_entry_t entry, struct page *page)
> +static int unuse_mm(struct mm_struct *mm, unsigned int type)
>  {
>  	struct vm_area_struct *vma;
>  	int ret = 0;
>  
> -	if (!down_read_trylock(&mm->mmap_sem)) {
> -		/*
> -		 * Activate page so shrink_inactive_list is unlikely to unmap
> -		 * its ptes while lock is dropped, so swapoff can make progress.
> -		 */
> -		activate_page(page);
> -		unlock_page(page);
> -		down_read(&mm->mmap_sem);
> -		lock_page(page);
> -	}
> +	down_read(&mm->mmap_sem);
>  	for (vma = mm->mmap; vma; vma = vma->vm_next) {
> -		if (vma->anon_vma && (ret = unuse_vma(vma, entry, page)))
> +		if (vma->anon_vma && (ret = unuse_vma(vma, type)))
>  			break;
>  	}
>  	up_read(&mm->mmap_sem);
>  	return (ret < 0)? ret: 0;
>  }
>  
> +/* TODO: this whole function is no longer necessary 
> + * useful for checking that the swap area is clean,
> + * so leaving until these changes are submitted
> + */
>  /*
>   * Scan swap_map (or frontswap_map if frontswap parameter is true)
>   * from current position to next entry still in use.
> @@ -1341,29 +1389,31 @@ static unsigned int find_next_to_unuse(struct swap_info_struct *si,
>  }
>  
>  /*
> - * We completely avoid races by reading each swap page in advance,
> - * and then search for the process using it.  All the necessary
> - * page table adjustments can then be made atomically.
> - *
>   * if the boolean frontswap is true, only unuse pages_to_unuse pages;
>   * pages_to_unuse==0 means all pages; ignored if frontswap is false
>   */
>  int try_to_unuse(unsigned int type, bool frontswap,
>  		 unsigned long pages_to_unuse)
>  {
> -	struct swap_info_struct *si = swap_info[type];
>  	struct mm_struct *start_mm;
> -	volatile unsigned char *swap_map; /* swap_map is accessed without
> -					   * locking. Mark it as volatile
> -					   * to prevent compiler doing
> -					   * something odd.
> -					   */
> -	unsigned char swcount;
> -	struct page *page;
> -	swp_entry_t entry;
> -	unsigned int i = 0;
> +	struct mm_struct *mm;
> +	struct list_head *p;
>  	int retval = 0;
>  
> +	/* TODO for checking if any entries are left
> +	 * after swapoff finishes
> +	 * for debug purposes, remove before submitting */
> +	struct swap_info_struct *si = swap_info[type];
> +	int i = 0;
> +
> +	/* TODO shmem_unuse needs its housekeeping
> +	 * exactly what needs to be done is not yet
> +	 * determined
> +	 */
> +	retval = shmem_unuse(type);
> +	if (retval)
> +		goto out;
> +
>  	/*
>  	 * When searching mms for an entry, a good strategy is to
>  	 * start at the first mm we freed the previous entry from
> @@ -1380,48 +1430,17 @@ int try_to_unuse(unsigned int type, bool frontswap,
>  	 */
>  	start_mm = &init_mm;
>  	atomic_inc(&init_mm.mm_users);
> +	p = &start_mm->mmlist;
>  
> -	/*
> -	 * Keep on scanning until all entries have gone.  Usually,
> -	 * one pass through swap_map is enough, but not necessarily:
> -	 * there are races when an instance of an entry might be missed.
> +	/* TODO: why do we protect the mmlist? (noob QUESTION)
> +	 * Where should the locks actually go?
>  	 */
> -	while ((i = find_next_to_unuse(si, i, frontswap)) != 0) {
> +	spin_lock(&mmlist_lock);
> +	while (!retval && (p = p->next) != &start_mm->mmlist) {
>  		if (signal_pending(current)) {
>  			retval = -EINTR;
>  			break;
>  		}
> -
> -		/*
> -		 * Get a page for the entry, using the existing swap
> -		 * cache page if there is one.  Otherwise, get a clean
> -		 * page and read the swap into it.
> -		 */
> -		swap_map = &si->swap_map[i];
> -		entry = swp_entry(type, i);
> -		page = read_swap_cache_async(entry,
> -					GFP_HIGHUSER_MOVABLE, NULL, 0);
> -		if (!page) {
> -			/*
> -			 * Either swap_duplicate() failed because entry
> -			 * has been freed independently, and will not be
> -			 * reused since sys_swapoff() already disabled
> -			 * allocation from here, or alloc_page() failed.
> -			 */
> -			swcount = *swap_map;
> -			/*
> -			 * We don't hold lock here, so the swap entry could be
> -			 * SWAP_MAP_BAD (when the cluster is discarding).
> -			 * Instead of fail out, We can just skip the swap
> -			 * entry because swapoff will wait for discarding
> -			 * finish anyway.
> -			 */
> -			if (!swcount || swcount == SWAP_MAP_BAD)
> -				continue;
> -			retval = -ENOMEM;
> -			break;
> -		}
> -
>  		/*
>  		 * Don't hold on to start_mm if it looks like exiting.
>  		 */
> @@ -1431,80 +1450,36 @@ int try_to_unuse(unsigned int type, bool frontswap,
>  			atomic_inc(&init_mm.mm_users);
>  		}
>  
> -		/*
> -		 * Wait for and lock page.  When do_swap_page races with
> -		 * try_to_unuse, do_swap_page can handle the fault much
> -		 * faster than try_to_unuse can locate the entry.  This
> -		 * apparently redundant "wait_on_page_locked" lets try_to_unuse
> -		 * defer to do_swap_page in such a case - in some tests,
> -		 * do_swap_page and try_to_unuse repeatedly compete.
> -		 */
> -		wait_on_page_locked(page);
> -		wait_on_page_writeback(page);
> -		lock_page(page);
> -		wait_on_page_writeback(page);
> +		mm = list_entry(p, struct mm_struct, mmlist);
> +		if (!atomic_inc_not_zero(&mm->mm_users))
> +			continue;
> +		spin_unlock(&mmlist_lock);
> +
> +		cond_resched();
> +
> +		retval = unuse_mm(mm, type);
> +		mmput(mm);
> +		if (retval)
> +			break;
>  
>  		/*
> -		 * Remove all references to entry.
> +		 * Make sure that we aren't completely killing
> +		 * interactive performance.
>  		 */
> -		swcount = *swap_map;
> -		if (swap_count(swcount) == SWAP_MAP_SHMEM) {
> -			retval = shmem_unuse(entry, page);
> -			/* page has already been unlocked and released */
> -			if (retval < 0)
> +		cond_resched();
> +		/* TODO we need another way to count these,
> +		 * because we will now be unusing all an mm's pages
> +		 * on each pass through the loop
> +		 * Ignoring frontswap for now
> +		 */
> +		if (frontswap && pages_to_unuse > 0) {
> +			if (!--pages_to_unuse)
>  				break;
> -			continue;
>  		}
> -		if (swap_count(swcount) && start_mm != &init_mm)
> -			retval = unuse_mm(start_mm, entry, page);
> -
> -		if (swap_count(*swap_map)) {
> -			int set_start_mm = (*swap_map >= swcount);
> -			struct list_head *p = &start_mm->mmlist;
> -			struct mm_struct *new_start_mm = start_mm;
> -			struct mm_struct *prev_mm = start_mm;
> -			struct mm_struct *mm;
> -
> -			atomic_inc(&new_start_mm->mm_users);
> -			atomic_inc(&prev_mm->mm_users);
> -			spin_lock(&mmlist_lock);
> -			while (swap_count(*swap_map) && !retval &&
> -					(p = p->next) != &start_mm->mmlist) {
> -				mm = list_entry(p, struct mm_struct, mmlist);
> -				if (!atomic_inc_not_zero(&mm->mm_users))
> -					continue;
> -				spin_unlock(&mmlist_lock);
> -				mmput(prev_mm);
> -				prev_mm = mm;
>  
> -				cond_resched();
> -
> -				swcount = *swap_map;
> -				if (!swap_count(swcount)) /* any usage ? */
> -					;
> -				else if (mm == &init_mm)
> -					set_start_mm = 1;
> -				else
> -					retval = unuse_mm(mm, entry, page);
> -
> -				if (set_start_mm && *swap_map < swcount) {
> -					mmput(new_start_mm);
> -					atomic_inc(&mm->mm_users);
> -					new_start_mm = mm;
> -					set_start_mm = 0;
> -				}
> -				spin_lock(&mmlist_lock);
> -			}
> -			spin_unlock(&mmlist_lock);
> -			mmput(prev_mm);
> -			mmput(start_mm);
> -			start_mm = new_start_mm;
> -		}
> -		if (retval) {
> -			unlock_page(page);
> -			page_cache_release(page);
> -			break;
> -		}
> +		spin_lock(&mmlist_lock);
> +	}
> +	spin_unlock(&mmlist_lock);
>  
>  		/*
>  		 * If a reference remains (rare), we would like to leave
> @@ -1524,50 +1499,27 @@ int try_to_unuse(unsigned int type, bool frontswap,
>  		 * this splitting happens to be just what is needed to
>  		 * handle where KSM pages have been swapped out: re-reading
>  		 * is unnecessarily slow, but we can fix that later on.
> +		 * TODO move this to unuse_pte_range?
>  		 */
> -		if (swap_count(*swap_map) &&
> -		     PageDirty(page) && PageSwapCache(page)) {
> -			struct writeback_control wbc = {
> -				.sync_mode = WB_SYNC_NONE,
> -			};
> -
> -			swap_writepage(page, &wbc);
> -			lock_page(page);
> -			wait_on_page_writeback(page);
> -		}
> -
> -		/*
> -		 * It is conceivable that a racing task removed this page from
> -		 * swap cache just before we acquired the page lock at the top,
> -		 * or while we dropped it in unuse_mm().  The page might even
> -		 * be back in swap cache on another swap area: that we must not
> -		 * delete, since it may not have been written out to swap yet.
> -		 */
> -		if (PageSwapCache(page) &&
> -		    likely(page_private(page) == entry.val))
> -			delete_from_swap_cache(page);
> -
> -		/*
> -		 * So we could skip searching mms once swap count went
> -		 * to 1, we did not mark any present ptes as dirty: must
> -		 * mark page dirty so shrink_page_list will preserve it.
> -		 */
> -		SetPageDirty(page);
> -		unlock_page(page);
> -		page_cache_release(page);
> -
> -		/*
> -		 * Make sure that we aren't completely killing
> -		 * interactive performance.
> -		 */
> -		cond_resched();
> -		if (frontswap && pages_to_unuse > 0) {
> -			if (!--pages_to_unuse)
> -				break;
> -		}
> -	}
> +/*		if (swap_count(*swap_map) &&
> +*		     PageDirty(page) && PageSwapCache(page)) {
> +*			struct writeback_control wbc = {
> +*				.sync_mode = WB_SYNC_NONE,
> +*			};
> +*
> +*			swap_writepage(page, &wbc);
> +*			lock_page(page);
> +*			wait_on_page_writeback(page);
> +*		}
> +*/
>  
> +	/* TODO check if there are any swap entries we failed to clean up. */
> +	if ((i = find_next_to_unuse(si, i, frontswap)) != 0)
> +		printk("swap entries remain, type not clean\n");
> +	printk("Leaving try_to_unuse\n");
> +	printk("Calls made to unuse_pte: %lu\n", unusepte_calls);
>  	mmput(start_mm);
> +out:
>  	return retval;
>  }
>  
> 


-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
