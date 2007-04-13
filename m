Date: Fri, 13 Apr 2007 12:53:05 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [rfc] rename page_count for lockless pagecache
In-Reply-To: <20070412103340.5564.23286.sendpatchset@linux.site>
Message-ID: <Pine.LNX.4.64.0704131229510.19073@blonde.wat.veritas.com>
References: <20070412103151.5564.16127.sendpatchset@linux.site>
 <20070412103340.5564.23286.sendpatchset@linux.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Apr 2007, Nick Piggin wrote:
> In order to force an audit of page_count users (which I have already done
> for in-tree users), and to ensure people think about page_count correctly
> in future, I propose this (incomplete, RFC) patch to rename page_count.

I see your point, it's a concern worth raising; but it grieves me that
we first lost page->count, and now you propose we lose page_count().

I don't care for the patch (especially page_count_lessequal).
I rather think it will cause more noise and nuisance than anything
else.  All the arches would need to be updated too.  Out of tree
people, won't they just #define anew without comprehending?

Might it be more profitable for a DEBUG mode to inject random
variations into page_count?

What did your audit show?  Was anything in the tree actually using
page_count() in a manner safe before but unsafe after your changes?
What you found outside of /mm should be a fair guide to what might
be there out of tree.

Hugh

> 
> Index: linux-2.6/include/linux/mm.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm.h
> +++ linux-2.6/include/linux/mm.h
> @@ -267,13 +267,32 @@ static inline int get_page_unless_zero(s
>  	return atomic_inc_not_zero(&page->_count);
>  }
>  
> -static inline int page_count(struct page *page)
> +static inline int unstable_page_count(struct page *page)
>  {
>  	if (unlikely(PageCompound(page)))
>  		page = (struct page *)page_private(page);
>  	return atomic_read(&page->_count);
>  }
>  
> +/*
> + * Returns true if the page count is zero. The page count is
> + * actually stable if it is zero.
> + */
> +static inline int page_count_is_zero(struct page *page)
> +{
> +	return unstable_page_count(page) == 0;
> +}
> +
> +/*
> + * Returns true if page count of page is less than or equal to c.
> + * PageNoNewRefs must be set on page.
> + */
> +static inline int page_count_lessequal(struct page *page, int c)
> +{
> +	VM_BUG_ON(!PageNoNewRefs(page));
> +	return unstable_page_count(page) <= c;
> +}
> +
>  static inline void get_page(struct page *page)
>  {
>  	if (unlikely(PageCompound(page)))
> Index: linux-2.6/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.orig/mm/hugetlb.c
> +++ linux-2.6/mm/hugetlb.c
> @@ -90,7 +90,7 @@ static struct page *dequeue_huge_page(st
>  
>  static void free_huge_page(struct page *page)
>  {
> -	BUG_ON(page_count(page));
> +	BUG_ON(!page_count_is_zero(page));
>  
>  	INIT_LIST_HEAD(&page->lru);
>  
> @@ -429,7 +429,7 @@ static int hugetlb_cow(struct mm_struct 
>  
>  	/* If no-one else is actually using this page, avoid the copy
>  	 * and just make the page writable */
> -	avoidcopy = (page_count(old_page) == 1);
> +	avoidcopy = (unstable_page_count(old_page) == 1);
>  	if (avoidcopy) {
>  		set_huge_ptep_writable(vma, address, ptep);
>  		return VM_FAULT_MINOR;
> Index: linux-2.6/mm/memory.c
> ===================================================================
> --- linux-2.6.orig/mm/memory.c
> +++ linux-2.6/mm/memory.c
> @@ -1270,7 +1270,7 @@ int vm_insert_page(struct vm_area_struct
>  {
>  	if (addr < vma->vm_start || addr >= vma->vm_end)
>  		return -EFAULT;
> -	if (!page_count(page))
> +	if (page_count_is_zero(page))
>  		return -EINVAL;
>  	vma->vm_flags |= VM_INSERTPAGE;
>  	return insert_page(vma->vm_mm, addr, page, vma->vm_page_prot);
> Index: linux-2.6/mm/migrate.c
> ===================================================================
> --- linux-2.6.orig/mm/migrate.c
> +++ linux-2.6/mm/migrate.c
> @@ -298,7 +298,7 @@ static int migrate_page_move_mapping(str
>  
>  	if (!mapping) {
>  		/* Anonymous page */
> -		if (page_count(page) != 1)
> +		if (unstable_page_count(page) != 1)
>  			return -EAGAIN;
>  		return 0;
>  	}
> @@ -309,7 +309,7 @@ static int migrate_page_move_mapping(str
>  	pslot = radix_tree_lookup_slot(&mapping->page_tree,
>   					page_index(page));
>  
> -	if (page_count(page) != 2 + !!PagePrivate(page) ||
> +	if (!page_count_lessequal(page, 2 + !!PagePrivate(page)) ||
>  			(struct page *)radix_tree_deref_slot(pslot) != page) {
>  		spin_unlock_irq(&mapping->tree_lock);
>  		clear_page_nonewrefs(page);
> @@ -606,7 +606,7 @@ static int unmap_and_move(new_page_t get
>  	if (!newpage)
>  		return -ENOMEM;
>  
> -	if (page_count(page) == 1)
> +	if (unstable_page_count(page) == 1)
>  		/* page was freed from under us. So we are done. */
>  		goto move_newpage;
>  
> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c
> +++ linux-2.6/mm/page_alloc.c
> @@ -192,7 +192,7 @@ static void bad_page(struct page *page)
>  		KERN_EMERG "Backtrace:\n",
>  		current->comm, page, (int)(2*sizeof(unsigned long)),
>  		(unsigned long)page->flags, page->mapping,
> -		page_mapcount(page), page_count(page));
> +		page_mapcount(page), unstable_page_count(page));
>  	dump_stack();
>  	page->flags &= ~(1 << PG_lru	|
>  			1 << PG_private |
> @@ -355,7 +355,7 @@ static inline int page_is_buddy(struct p
>  		return 0;
>  
>  	if (PageBuddy(buddy) && page_order(buddy) == order) {
> -		BUG_ON(page_count(buddy) != 0);
> +		BUG_ON(!page_count_is_zero(buddy));
>  		return 1;
>  	}
>  	return 0;
> @@ -427,7 +427,7 @@ static inline int free_pages_check(struc
>  {
>  	if (unlikely(page_mapcount(page) |
>  		(page->mapping != NULL)  |
> -		(page_count(page) != 0)  |
> +		(!page_count_is_zero(page)) |
>  		(page->flags & (
>  			1 << PG_lru	|
>  			1 << PG_private |
> @@ -576,7 +576,7 @@ static int prep_new_page(struct page *pa
>  {
>  	if (unlikely(page_mapcount(page) |
>  		(page->mapping != NULL)  |
> -		(page_count(page) != 0)  |
> +		(!page_count_is_zero(page)) |
>  		(page->flags & (
>  			1 << PG_lru	|
>  			1 << PG_private	|
> @@ -854,7 +854,7 @@ void split_page(struct page *page, unsig
>  	int i;
>  
>  	VM_BUG_ON(PageCompound(page));
> -	VM_BUG_ON(!page_count(page));
> +	VM_BUG_ON(page_count_is_zero(page));
>  	for (i = 1; i < (1 << order); i++)
>  		set_page_refcounted(page + i);
>  }
> Index: linux-2.6/mm/rmap.c
> ===================================================================
> --- linux-2.6.orig/mm/rmap.c
> +++ linux-2.6/mm/rmap.c
> @@ -586,7 +586,7 @@ void page_remove_rmap(struct page *page,
>  			printk (KERN_EMERG "Eeek! page_mapcount(page) went negative! (%d)\n", page_mapcount(page));
>  			printk (KERN_EMERG "  page pfn = %lx\n", page_to_pfn(page));
>  			printk (KERN_EMERG "  page->flags = %lx\n", page->flags);
> -			printk (KERN_EMERG "  page->count = %x\n", page_count(page));
> +			printk (KERN_EMERG "  page->count = %x\n", unstable_page_count(page));
>  			printk (KERN_EMERG "  page->mapping = %p\n", page->mapping);
>  			print_symbol (KERN_EMERG "  vma->vm_ops = %s\n", (unsigned long)vma->vm_ops);
>  			if (vma->vm_ops)
> Index: linux-2.6/mm/swapfile.c
> ===================================================================
> --- linux-2.6.orig/mm/swapfile.c
> +++ linux-2.6/mm/swapfile.c
> @@ -73,7 +73,7 @@ void swap_unplug_io_fn(struct backing_de
>  		 * condition and it's harmless. However if it triggers without
>  		 * swapoff it signals a problem.
>  		 */
> -		WARN_ON(page_count(page) <= 1);
> +		WARN_ON(unstable_page_count(page) <= 1);
>  
>  		bdi = bdev->bd_inode->i_mapping->backing_dev_info;
>  		blk_run_backing_dev(bdi, page);
> @@ -355,7 +355,7 @@ int remove_exclusive_swap_page(struct pa
>  		return 0;
>  	if (PageWriteback(page))
>  		return 0;
> -	if (page_count(page) != 2) /* 2: us + cache */
> +	if (unstable_page_count(page) != 2) /* 2: us + cache */
>  		return 0;
>  
>  	entry.val = page_private(page);
> @@ -366,14 +366,14 @@ int remove_exclusive_swap_page(struct pa
>  	/* Is the only swap cache user the cache itself? */
>  	retval = 0;
>  	if (p->swap_map[swp_offset(entry)] == 1) {
> -		/* Recheck the page count with the swapcache lock held.. */
> -		spin_lock_irq(&swapper_space.tree_lock);
> -		if ((page_count(page) == 2) && !PageWriteback(page)) {
> +		/* XXX: BUG_ON(PageWriteback(page)) ?? */
> +		if ((unstable_page_count(page) == 2) && !PageWriteback(page)) {
> +			spin_lock_irq(&swapper_space.tree_lock);
>  			__delete_from_swap_cache(page);
> +			spin_unlock_irq(&swapper_space.tree_lock);
>  			SetPageDirty(page);
>  			retval = 1;
>  		}
> -		spin_unlock_irq(&swapper_space.tree_lock);
>  	}
>  	spin_unlock(&swap_lock);
>  
> @@ -412,7 +412,7 @@ void free_swap_and_cache(swp_entry_t ent
>  		int one_user;
>  
>  		BUG_ON(PagePrivate(page));
> -		one_user = (page_count(page) == 2);
> +		one_user = (unstable_page_count(page) == 2);
>  		/* Only cache user (+us), or swap space full? Free it! */
>  		/* Also recheck PageSwapCache after page is locked (above) */
>  		if (PageSwapCache(page) && !PageWriteback(page) &&
> Index: linux-2.6/mm/vmscan.c
> ===================================================================
> --- linux-2.6.orig/mm/vmscan.c
> +++ linux-2.6/mm/vmscan.c
> @@ -254,7 +254,7 @@ static inline int page_mapping_inuse(str
>  
>  static inline int is_page_cache_freeable(struct page *page)
>  {
> -	return page_count(page) - !!PagePrivate(page) == 2;
> +	return unstable_page_count(page) - !!PagePrivate(page) == 2;
>  }
>  
>  static int may_write_to_queue(struct backing_dev_info *bdi)
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
