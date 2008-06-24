Date: Tue, 24 Jun 2008 06:56:07 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: Can get_user_pages( ,write=1, force=1, ) result in a read-only
	pte and _count=2?
Message-ID: <20080624115606.GJ10062@sgi.com>
References: <200806190329.30622.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0806181944080.4968@blonde.site> <200806191307.04499.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0806191154270.7324@blonde.site> <20080619133809.GC10123@sgi.com> <Pine.LNX.4.64.0806191441040.25832@blonde.site> <20080623155400.GH10123@sgi.com> <Pine.LNX.4.64.0806231718460.16782@blonde.site> <20080623175203.GI10123@sgi.com> <Pine.LNX.4.64.0806232134330.19691@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806232134330.19691@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Robin Holt <holt@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Argh, the current kernel does not boot for ia64.  I will look into
that first.  It fails even without your patch applied.

Thanks,
Robin

On Mon, Jun 23, 2008 at 09:58:42PM +0100, Hugh Dickins wrote:
> On Mon, 23 Jun 2008, Robin Holt wrote:
> > On Mon, Jun 23, 2008 at 05:48:17PM +0100, Hugh Dickins wrote:
> > 
> > > reuse test in do_wp_page that I'm still working on - of which Nick sent
> > > a lock_page approximation for you to try?  Would you still be able to
> > > try mine when I'm ready, or does it now appear irrelevant to you?
> > 
> > Before your response, I had convinced myself my problem was specific to
> > XPMEM, but I see your point and may agree that it is a problem for all
> > get_user_pages() users.
> > 
> > I can certainly test when you have it ready.
> 
> Thanks a lot, Robin.  Here it is below.
> 
> > 
> > I had confused myself about Nick's first patch.  I will give that
> > another look over and see if it fixes the problem.
> 
> Nick's _first_ patch?  The one I was thinking of was the one
> with lock_page in do_wp_page, but it shouldn't be necessary now if
> what's below works - though his is a much smaller and less worrying
> patch, so anyone looking for a quick fix to the issue might well
> prefer his.
> 
> > 
> > > 	http://lkml.org/lkml/2006/9/14/384
> > > 
> > > but it's a broken thread, with misunderstanding on all sides,
> > > so rather hard to get a grasp of it.
> > 
> > That is extremely similar to the issue I am seeing.  I think that if
> > Infiniband were using the mmu_notifier stuff, they would be closer, but
> > IIRC, there are significant hardware restrictions which prevent demand
> > paging for working on some IB devices.
> 
> Ah, I'm glad you've managed to glean something from it, good.
> 
> Here's the rollup of the patches I'm proposing for two issues:
> it doesn't get my signoff yet because I'll want to split it into
> little stages properly commented, and I'll want to do more strenuous
> testing; but this shouldn't blow up in your face.  Against 2.6.26-rc7,
> should apply quite easily to earlier, but a little more work against
> 2.6.26-rc5-mm3 - though it simplifies some of that too (Rik+Lee Cced).
> 
> I say two issues, two competing issues.  One is the issue which may be
> your issue, that we want to decide COW in do_wp_page without needing
> PageLocked, so a concurrent shrink_page_list() doesn't occasionally
> force an unwanted COW, messing up some get_user_pages() uses.  The
> other, of no interest to you, is that we do want PageLocked when
> deciding COW in do_wp_page, because that's a good moment to free
> up the swap space - leaving the modified page with swap just makes
> a big seek likely when it's next written to swap.
> 
> Hugh
> 
>  include/linux/swap.h |   21 ++++--
>  mm/memory.c          |   15 +++-
>  mm/migrate.c         |    5 -
>  mm/page_io.c         |    2 
>  mm/swap_state.c      |   12 ++-
>  mm/swapfile.c        |  128 ++++++++++++++++++++++-------------------
>  6 files changed, 105 insertions(+), 78 deletions(-)
> 
> --- 2.6.26-rc7/include/linux/swap.h	2008-05-03 21:55:11.000000000 +0100
> +++ linux/include/linux/swap.h	2008-06-23 18:12:47.000000000 +0100
> @@ -250,8 +250,9 @@ extern unsigned int count_swap_pages(int
>  extern sector_t map_swap_page(struct swap_info_struct *, pgoff_t);
>  extern sector_t swapdev_block(int, pgoff_t);
>  extern struct swap_info_struct *get_swap_info_struct(unsigned);
> -extern int can_share_swap_page(struct page *);
> -extern int remove_exclusive_swap_page(struct page *);
> +extern int can_reuse_swap_page_unlocked(struct page *);
> +extern int can_reuse_swap_page_locked(struct page *);
> +extern int try_to_free_swap(struct page *);
>  struct backing_dev_info;
>  
>  extern spinlock_t swap_lock;
> @@ -319,8 +320,6 @@ static inline struct page *lookup_swap_c
>  	return NULL;
>  }
>  
> -#define can_share_swap_page(p)			(page_mapcount(p) == 1)
> -
>  static inline int add_to_swap_cache(struct page *page, swp_entry_t entry,
>  							gfp_t gfp_mask)
>  {
> @@ -337,9 +336,19 @@ static inline void delete_from_swap_cach
>  
>  #define swap_token_default_timeout		0
>  
> -static inline int remove_exclusive_swap_page(struct page *p)
> +static inline int can_reuse_swap_page_unlocked(struct page *page)
>  {
> -	return 0;
> +	return 0;	/* irrelevant: never called  */
> +}
> +
> +static inline int can_reuse_swap_page_locked(struct page *page)
> +{
> +	return 0;	/* irrelevant: never called */
> +}
> +
> +static inline int try_to_free_swap(struct page *page)
> +{
> +	return 0;	/* irrelevant: never called */
>  }
>  
>  static inline swp_entry_t get_swap_page(void)
> --- 2.6.26-rc7/mm/memory.c	2008-06-21 08:41:19.000000000 +0100
> +++ linux/mm/memory.c	2008-06-23 18:12:47.000000000 +0100
> @@ -1686,9 +1686,14 @@ static int do_wp_page(struct mm_struct *
>  	 * not dirty accountable.
>  	 */
>  	if (PageAnon(old_page)) {
> -		if (!TestSetPageLocked(old_page)) {
> -			reuse = can_share_swap_page(old_page);
> -			unlock_page(old_page);
> +		if (page_mapcount(old_page) == 1) {
> +			if (!PageSwapCache(old_page))
> +				reuse = 1;
> +			else if (!TestSetPageLocked(old_page)) {
> +				reuse = can_reuse_swap_page_locked(old_page);
> +				unlock_page(old_page);
> +			} else
> +				reuse = can_reuse_swap_page_unlocked(old_page);
>  		}
>  	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
>  					(VM_WRITE|VM_SHARED))) {
> @@ -2185,7 +2190,7 @@ static int do_swap_page(struct mm_struct
>  
>  	inc_mm_counter(mm, anon_rss);
>  	pte = mk_pte(page, vma->vm_page_prot);
> -	if (write_access && can_share_swap_page(page)) {
> +	if (write_access && can_reuse_swap_page_locked(page)) {
>  		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
>  		write_access = 0;
>  	}
> @@ -2196,7 +2201,7 @@ static int do_swap_page(struct mm_struct
>  
>  	swap_free(entry);
>  	if (vm_swap_full())
> -		remove_exclusive_swap_page(page);
> +		try_to_free_swap(page);
>  	unlock_page(page);
>  
>  	if (write_access) {
> --- 2.6.26-rc7/mm/migrate.c	2008-06-21 08:41:19.000000000 +0100
> +++ linux/mm/migrate.c	2008-06-23 18:12:47.000000000 +0100
> @@ -330,8 +330,10 @@ static int migrate_page_move_mapping(str
>  	get_page(newpage);	/* add cache reference */
>  #ifdef CONFIG_SWAP
>  	if (PageSwapCache(page)) {
> -		SetPageSwapCache(newpage);
>  		set_page_private(newpage, page_private(page));
> +		/* page_swapcount() relies on private whenever PageSwapCache */
> +		smp_wmb();
> +		SetPageSwapCache(newpage);
>  	}
>  #endif
>  
> @@ -398,7 +400,6 @@ static void migrate_page_copy(struct pag
>  #endif
>  	ClearPageActive(page);
>  	ClearPagePrivate(page);
> -	set_page_private(page, 0);
>  	page->mapping = NULL;
>  
>  	/*
> --- 2.6.26-rc7/mm/page_io.c	2008-04-17 03:49:44.000000000 +0100
> +++ linux/mm/page_io.c	2008-06-23 18:12:47.000000000 +0100
> @@ -98,7 +98,7 @@ int swap_writepage(struct page *page, st
>  	struct bio *bio;
>  	int ret = 0, rw = WRITE;
>  
> -	if (remove_exclusive_swap_page(page)) {
> +	if (try_to_free_swap(page)) {
>  		unlock_page(page);
>  		goto out;
>  	}
> --- 2.6.26-rc7/mm/swap_state.c	2008-05-03 21:55:12.000000000 +0100
> +++ linux/mm/swap_state.c	2008-06-23 18:12:47.000000000 +0100
> @@ -76,13 +76,15 @@ int add_to_swap_cache(struct page *page,
>  	BUG_ON(PagePrivate(page));
>  	error = radix_tree_preload(gfp_mask);
>  	if (!error) {
> +		set_page_private(page, entry.val);
> +		/* page_swapcount() relies on private whenever PageSwapCache */
> +		smp_wmb();
>  		write_lock_irq(&swapper_space.tree_lock);
>  		error = radix_tree_insert(&swapper_space.page_tree,
>  						entry.val, page);
>  		if (!error) {
>  			page_cache_get(page);
>  			SetPageSwapCache(page);
> -			set_page_private(page, entry.val);
>  			total_swapcache_pages++;
>  			__inc_zone_page_state(page, NR_FILE_PAGES);
>  			INC_CACHE_INFO(add_total);
> @@ -105,7 +107,6 @@ void __delete_from_swap_cache(struct pag
>  	BUG_ON(PagePrivate(page));
>  
>  	radix_tree_delete(&swapper_space.page_tree, page_private(page));
> -	set_page_private(page, 0);
>  	ClearPageSwapCache(page);
>  	total_swapcache_pages--;
>  	__dec_zone_page_state(page, NR_FILE_PAGES);
> @@ -188,13 +189,14 @@ void delete_from_swap_cache(struct page 
>   * 
>   * Its ok to check for PageSwapCache without the page lock
>   * here because we are going to recheck again inside 
> - * exclusive_swap_page() _with_ the lock. 
> + * try_to_free_swap() _with_ the lock. 
>   * 					- Marcelo
>   */
>  static inline void free_swap_cache(struct page *page)
>  {
> -	if (PageSwapCache(page) && !TestSetPageLocked(page)) {
> -		remove_exclusive_swap_page(page);
> +	if (PageSwapCache(page) && !page_mapped(page) &&
> +	    !TestSetPageLocked(page)) {
> +		try_to_free_swap(page);
>  		unlock_page(page);
>  	}
>  }
> --- 2.6.26-rc7/mm/swapfile.c	2008-05-03 21:55:12.000000000 +0100
> +++ linux/mm/swapfile.c	2008-06-23 18:12:47.000000000 +0100
> @@ -251,7 +251,6 @@ static struct swap_info_struct * swap_in
>  		goto bad_offset;
>  	if (!p->swap_map[offset])
>  		goto bad_free;
> -	spin_lock(&swap_lock);
>  	return p;
>  
>  bad_free:
> @@ -300,90 +299,104 @@ void swap_free(swp_entry_t entry)
>  
>  	p = swap_info_get(entry);
>  	if (p) {
> +		spin_lock(&swap_lock);
>  		swap_entry_free(p, swp_offset(entry));
>  		spin_unlock(&swap_lock);
>  	}
>  }
>  
>  /*
> - * How many references to page are currently swapped out?
> + * How many page table references are there to this page's swap entry?
> + * including references to the page itself if add_mapcount.
> + *
> + * page_swapcount is only called on a page which was recently PageSwapCache
> + * (but might have been deleted from swap cache just before getting here).
> + *
> + * When called with PageLocked, the swapcount is stable, and the mapcount
> + * cannot rise (but may fall if the page is concurrently unmapped from a
> + * page table whose lock we don't hold).
> + *
> + * When called without PageLocked, the swapcount is stable while we hold
> + * swap_lock, and the mapcount cannot rise from 1 while we hold that page
> + * table lock (but may fall if the page is concurrently unmapped from a
> + * page table whose lock we don't hold).
> + *
> + * do_swap_page and unuse_pte call page_add_anon_rmap before swap_free,
> + * try_to_unmap_one calls swap_duplicate before page_remove_rmap:
> + * so in general, swapcount+mapcount should never be seen too low -
> + * but you need to consider more memory barriers if extending its use.
>   */
> -static inline int page_swapcount(struct page *page)
> +static int page_swapcount(struct page *page, int add_mapcount)
>  {
>  	int count = 0;
>  	struct swap_info_struct *p;
>  	swp_entry_t entry;
>  
> -	entry.val = page_private(page);
> -	p = swap_info_get(entry);
> -	if (p) {
> -		/* Subtract the 1 for the swap cache itself */
> -		count = p->swap_map[swp_offset(entry)] - 1;
> -		spin_unlock(&swap_lock);
> +	spin_lock(&swap_lock);
> +	if (add_mapcount)
> +		count = page_mapcount(page);
> +	if (PageSwapCache(page)) {
> +		/* We can rely on page_private once PageSwapCache is visible */
> +		smp_rmb();
> +		entry.val = page_private(page);
> +		p = swap_info_get(entry);
> +		if (p) {
> +			/* Subtract the 1 for the swap cache itself */
> +			count += p->swap_map[swp_offset(entry)] - 1;
> +		}
>  	}
> +	spin_unlock(&swap_lock);
>  	return count;
>  }
>  
>  /*
> - * We can use this swap cache entry directly
> - * if there are no other references to it.
> + * Can do_wp_page() make the faulting swapcache page writable without COW?
> + * But something else, probably shrink_page_list(), already has PageLocked.
> + * Don't be misled to COW the page unnecessarily: check swapcount+mapcount.
>   */
> -int can_share_swap_page(struct page *page)
> +int can_reuse_swap_page_unlocked(struct page *page)
>  {
> -	int count;
> -
> -	BUG_ON(!PageLocked(page));
> -	count = page_mapcount(page);
> -	if (count <= 1 && PageSwapCache(page))
> -		count += page_swapcount(page);
> -	return count == 1;
> +	return page_swapcount(page, 1) == 1;
>  }
>  
>  /*
> - * Work out if there are any other processes sharing this
> - * swap cache page. Free it if you can. Return success.
> + * Can do_wp_page() make the faulting swapcache page writable without COW?
> + * having acquiring PageLocked.  In this case, since we have that lock and
> + * are about to modify the page, we'd better free its swap space - it won't
> + * be read again, and writing there later would probably require an extra seek.
>   */
> -int remove_exclusive_swap_page(struct page *page)
> +int can_reuse_swap_page_locked(struct page *page)
>  {
> -	int retval;
> -	struct swap_info_struct * p;
> -	swp_entry_t entry;
> +	VM_BUG_ON(!PageLocked(page));
> +	if (page_swapcount(page, 1) != 1)
> +		return 0;
> +	if (!PageSwapCache(page))
> +		return 1;
> +	if (PageWriteback(page))
> +		return 1;
>  
> -	BUG_ON(PagePrivate(page));
> -	BUG_ON(!PageLocked(page));
> +	delete_from_swap_cache(page);
> +	SetPageDirty(page);
> +	return 1;
> +}
>  
> +/*
> + * If swap is getting full, or if there are no more mappings of this page,
> + * then try_to_free_swap is called to free its swap space.
> + */
> +int try_to_free_swap(struct page *page)
> +{
> +	VM_BUG_ON(!PageLocked(page));
>  	if (!PageSwapCache(page))
>  		return 0;
>  	if (PageWriteback(page))
>  		return 0;
> -	if (page_count(page) != 2) /* 2: us + cache */
> +	if (page_swapcount(page, 0))	/* Here we don't care about mapcount */
>  		return 0;
>  
> -	entry.val = page_private(page);
> -	p = swap_info_get(entry);
> -	if (!p)
> -		return 0;
> -
> -	/* Is the only swap cache user the cache itself? */
> -	retval = 0;
> -	if (p->swap_map[swp_offset(entry)] == 1) {
> -		/* Recheck the page count with the swapcache lock held.. */
> -		write_lock_irq(&swapper_space.tree_lock);
> -		if ((page_count(page) == 2) && !PageWriteback(page)) {
> -			__delete_from_swap_cache(page);
> -			SetPageDirty(page);
> -			retval = 1;
> -		}
> -		write_unlock_irq(&swapper_space.tree_lock);
> -	}
> -	spin_unlock(&swap_lock);
> -
> -	if (retval) {
> -		swap_free(entry);
> -		page_cache_release(page);
> -	}
> -
> -	return retval;
> +	delete_from_swap_cache(page);
> +	SetPageDirty(page);
> +	return 1;
>  }
>  
>  /*
> @@ -400,6 +413,7 @@ void free_swap_and_cache(swp_entry_t ent
>  
>  	p = swap_info_get(entry);
>  	if (p) {
> +		spin_lock(&swap_lock);
>  		if (swap_entry_free(p, swp_offset(entry)) == 1) {
>  			page = find_get_page(&swapper_space, entry.val);
>  			if (page && unlikely(TestSetPageLocked(page))) {
> @@ -410,14 +424,10 @@ void free_swap_and_cache(swp_entry_t ent
>  		spin_unlock(&swap_lock);
>  	}
>  	if (page) {
> -		int one_user;
> -
> -		BUG_ON(PagePrivate(page));
> -		one_user = (page_count(page) == 2);
> -		/* Only cache user (+us), or swap space full? Free it! */
> +		/* Not mapped elsewhere, or swap space full? Free it! */
>  		/* Also recheck PageSwapCache after page is locked (above) */
>  		if (PageSwapCache(page) && !PageWriteback(page) &&
> -					(one_user || vm_swap_full())) {
> +				(!page_mapped(page) || vm_swap_full())) {
>  			delete_from_swap_cache(page);
>  			SetPageDirty(page);
>  		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
