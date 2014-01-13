Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id C25596B0036
	for <linux-mm@kvack.org>; Sun, 12 Jan 2014 21:00:56 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id lf10so4692426pab.35
        for <linux-mm@kvack.org>; Sun, 12 Jan 2014 18:00:56 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id bc9si14190411pbd.161.2014.01.12.18.00.53
        for <linux-mm@kvack.org>;
        Sun, 12 Jan 2014 18:00:55 -0800 (PST)
Date: Mon, 13 Jan 2014 11:01:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch 5/9] mm + fs: prepare for non-page entries in page cache
 radix trees
Message-ID: <20140113020132.GO1992@bbox>
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org>
 <1389377443-11755-6-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389377443-11755-6-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jan 10, 2014 at 01:10:39PM -0500, Johannes Weiner wrote:
> shmem mappings already contain exceptional entries where swap slot
> information is remembered.
> 
> To be able to store eviction information for regular page cache,
> prepare every site dealing with the radix trees directly to handle
> entries other than pages.
> 
> The common lookup functions will filter out non-page entries and
> return NULL for page cache holes, just as before.  But provide a raw
> version of the API which returns non-page entries as well, and switch
> shmem over to use it.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Minchan Kim <minchan@kernel.org>

Below are just nitpicks.

> ---
>  fs/btrfs/compression.c   |   2 +-
>  include/linux/mm.h       |   8 ++
>  include/linux/pagemap.h  |  15 ++--
>  include/linux/pagevec.h  |   3 +
>  include/linux/shmem_fs.h |   1 +
>  mm/filemap.c             | 196 +++++++++++++++++++++++++++++++++++++++++------
>  mm/mincore.c             |  20 +++--
>  mm/readahead.c           |   2 +-
>  mm/shmem.c               |  97 +++++------------------
>  mm/swap.c                |  47 ++++++++++++
>  mm/truncate.c            |  73 ++++++++++++++----
>  11 files changed, 336 insertions(+), 128 deletions(-)
> 
> diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
> index 6aad98cb343f..c88316587900 100644
> --- a/fs/btrfs/compression.c
> +++ b/fs/btrfs/compression.c
> @@ -474,7 +474,7 @@ static noinline int add_ra_bio_pages(struct inode *inode,
>  		rcu_read_lock();
>  		page = radix_tree_lookup(&mapping->page_tree, pg_index);
>  		rcu_read_unlock();
> -		if (page) {
> +		if (page && !radix_tree_exceptional_entry(page)) {
>  			misses++;
>  			if (misses > 4)
>  				break;
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 8b6e55ee8855..c09ef3ae55bc 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -906,6 +906,14 @@ extern void show_free_areas(unsigned int flags);
>  extern bool skip_free_areas_node(unsigned int flags, int nid);
>  
>  int shmem_zero_setup(struct vm_area_struct *);
> +#ifdef CONFIG_SHMEM
> +bool shmem_mapping(struct address_space *mapping);
> +#else
> +static inline bool shmem_mapping(struct address_space *mapping)
> +{
> +	return false;
> +}
> +#endif
>  
>  extern int can_do_mlock(void);
>  extern int user_shm_lock(size_t, struct user_struct *);
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index c73130c607c4..b6854b7c58cb 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -248,12 +248,15 @@ pgoff_t page_cache_next_hole(struct address_space *mapping,
>  pgoff_t page_cache_prev_hole(struct address_space *mapping,
>  			     pgoff_t index, unsigned long max_scan);
>  
> -extern struct page * find_get_page(struct address_space *mapping,
> -				pgoff_t index);
> -extern struct page * find_lock_page(struct address_space *mapping,
> -				pgoff_t index);
> -extern struct page * find_or_create_page(struct address_space *mapping,
> -				pgoff_t index, gfp_t gfp_mask);
> +struct page *__find_get_page(struct address_space *mapping, pgoff_t offset);
> +struct page *find_get_page(struct address_space *mapping, pgoff_t offset);
> +struct page *__find_lock_page(struct address_space *mapping, pgoff_t offset);
> +struct page *find_lock_page(struct address_space *mapping, pgoff_t offset);
> +struct page *find_or_create_page(struct address_space *mapping, pgoff_t index,
> +				 gfp_t gfp_mask);
> +unsigned __find_get_pages(struct address_space *mapping, pgoff_t start,
> +			  unsigned int nr_pages, struct page **pages,
> +			  pgoff_t *indices);
>  unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
>  			unsigned int nr_pages, struct page **pages);
>  unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t start,
> diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
> index e4dbfab37729..3c6b8b1e945b 100644
> --- a/include/linux/pagevec.h
> +++ b/include/linux/pagevec.h
> @@ -22,6 +22,9 @@ struct pagevec {
>  
>  void __pagevec_release(struct pagevec *pvec);
>  void __pagevec_lru_add(struct pagevec *pvec);
> +unsigned __pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
> +			  pgoff_t start, unsigned nr_pages, pgoff_t *indices);
> +void pagevec_remove_exceptionals(struct pagevec *pvec);
>  unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
>  		pgoff_t start, unsigned nr_pages);
>  unsigned pagevec_lookup_tag(struct pagevec *pvec,
> diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
> index 30aa0dc60d75..deb49609cd36 100644
> --- a/include/linux/shmem_fs.h
> +++ b/include/linux/shmem_fs.h
> @@ -49,6 +49,7 @@ extern struct file *shmem_file_setup(const char *name,
>  					loff_t size, unsigned long flags);
>  extern int shmem_zero_setup(struct vm_area_struct *);
>  extern int shmem_lock(struct file *file, int lock, struct user_struct *user);
> +extern bool shmem_mapping(struct address_space *mapping);
>  extern void shmem_unlock_mapping(struct address_space *mapping);
>  extern struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
>  					pgoff_t index, gfp_t gfp_mask);
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 0746b7a4658f..23eb3be27205 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -446,6 +446,29 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
>  }
>  EXPORT_SYMBOL_GPL(replace_page_cache_page);
>  
> +static int page_cache_tree_insert(struct address_space *mapping,
> +				  struct page *page)
> +{
> +	void **slot;
> +	int error;
> +
> +	slot = radix_tree_lookup_slot(&mapping->page_tree, page->index);
> +	if (slot) {
> +		void *p;
> +
> +		p = radix_tree_deref_slot_protected(slot, &mapping->tree_lock);
> +		if (!radix_tree_exceptional_entry(p))
> +		    return -EEXIST;
> +		radix_tree_replace_slot(slot, page);
> +		mapping->nrpages++;
> +		return 0;
> +	}
> +	error = radix_tree_insert(&mapping->page_tree, page->index, page);
> +	if (!error)
> +		mapping->nrpages++;
> +	return error;
> +}
> +
>  /**
>   * add_to_page_cache_locked - add a locked page to the pagecache
>   * @page:	page to add
> @@ -480,11 +503,10 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
>  	page->index = offset;
>  
>  	spin_lock_irq(&mapping->tree_lock);
> -	error = radix_tree_insert(&mapping->page_tree, offset, page);
> +	error = page_cache_tree_insert(mapping, page);
>  	radix_tree_preload_end();
>  	if (unlikely(error))
>  		goto err_insert;
> -	mapping->nrpages++;
>  	__inc_zone_page_state(page, NR_FILE_PAGES);
>  	spin_unlock_irq(&mapping->tree_lock);
>  	trace_mm_filemap_add_to_page_cache(page);
> @@ -712,7 +734,10 @@ pgoff_t page_cache_next_hole(struct address_space *mapping,
>  	unsigned long i;
>  
>  	for (i = 0; i < max_scan; i++) {
> -		if (!radix_tree_lookup(&mapping->page_tree, index))
> +		struct page *page;
> +
> +		page = radix_tree_lookup(&mapping->page_tree, index);
> +		if (!page || radix_tree_exceptional_entry(page))
>  			break;
>  		index++;
>  		if (index == 0)
> @@ -750,7 +775,10 @@ pgoff_t page_cache_prev_hole(struct address_space *mapping,
>  	unsigned long i;
>  
>  	for (i = 0; i < max_scan; i++) {
> -		if (!radix_tree_lookup(&mapping->page_tree, index))
> +		struct page *page;
> +
> +		page = radix_tree_lookup(&mapping->page_tree, index);
> +		if (!page || radix_tree_exceptional_entry(page))
>  			break;
>  		index--;
>  		if (index == ULONG_MAX)
> @@ -762,14 +790,19 @@ pgoff_t page_cache_prev_hole(struct address_space *mapping,
>  EXPORT_SYMBOL(page_cache_prev_hole);
>  
>  /**
> - * find_get_page - find and get a page reference
> + * __find_get_page - find and get a page reference
>   * @mapping: the address_space to search
>   * @offset: the page index
>   *
> - * Is there a pagecache struct page at the given (mapping, offset) tuple?
> - * If yes, increment its refcount and return it; if no, return NULL.
> + * Looks up the page cache slot at @mapping & @offset.  If there is a
> + * page cache page, it is returned with an increased refcount.
> + *
> + * If the slot holds a shadow entry of a previously evicted page, it
> + * is returned.
> + *
> + * Otherwise, %NULL is returned.
>   */
> -struct page *find_get_page(struct address_space *mapping, pgoff_t offset)
> +struct page *__find_get_page(struct address_space *mapping, pgoff_t offset)
>  {
>  	void **pagep;
>  	struct page *page;
> @@ -810,24 +843,49 @@ out:
>  
>  	return page;
>  }
> +EXPORT_SYMBOL(__find_get_page);
> +
> +/**
> + * find_get_page - find and get a page reference
> + * @mapping: the address_space to search
> + * @offset: the page index
> + *
> + * Looks up the page cache slot at @mapping & @offset.  If there is a
> + * page cache page, it is returned with an increased refcount.
> + *
> + * Otherwise, %NULL is returned.
> + */
> +struct page *find_get_page(struct address_space *mapping, pgoff_t offset)
> +{
> +	struct page *page = __find_get_page(mapping, offset);
> +
> +	if (radix_tree_exceptional_entry(page))
> +		page = NULL;
> +	return page;
> +}
>  EXPORT_SYMBOL(find_get_page);
>  
>  /**
> - * find_lock_page - locate, pin and lock a pagecache page
> + * __find_lock_page - locate, pin and lock a pagecache page
>   * @mapping: the address_space to search
>   * @offset: the page index
>   *
> - * Locates the desired pagecache page, locks it, increments its reference
> - * count and returns its address.
> + * Looks up the page cache slot at @mapping & @offset.  If there is a
> + * page cache page, it is returned locked and with an increased
> + * refcount.
> + *
> + * If the slot holds a shadow entry of a previously evicted page, it
> + * is returned.
> + *
> + * Otherwise, %NULL is returned.
>   *
> - * Returns zero if the page was not present. find_lock_page() may sleep.
> + * __find_lock_page() may sleep.
>   */
> -struct page *find_lock_page(struct address_space *mapping, pgoff_t offset)
> +struct page *__find_lock_page(struct address_space *mapping, pgoff_t offset)
>  {
>  	struct page *page;
> -
>  repeat:
> -	page = find_get_page(mapping, offset);
> +	page = __find_get_page(mapping, offset);
>  	if (page && !radix_tree_exception(page)) {
>  		lock_page(page);
>  		/* Has the page been truncated? */
> @@ -840,6 +898,29 @@ repeat:
>  	}
>  	return page;
>  }
> +EXPORT_SYMBOL(__find_lock_page);
> +
> +/**
> + * find_lock_page - locate, pin and lock a pagecache page
> + * @mapping: the address_space to search
> + * @offset: the page index
> + *
> + * Looks up the page cache slot at @mapping & @offset.  If there is a
> + * page cache page, it is returned locked and with an increased
> + * refcount.
> + *
> + * Otherwise, %NULL is returned.
> + *
> + * find_lock_page() may sleep.
> + */
> +struct page *find_lock_page(struct address_space *mapping, pgoff_t offset)
> +{
> +	struct page *page = __find_lock_page(mapping, offset);
> +
> +	if (radix_tree_exceptional_entry(page))
> +		page = NULL;
> +	return page;
> +}
>  EXPORT_SYMBOL(find_lock_page);
>  
>  /**
> @@ -848,16 +929,18 @@ EXPORT_SYMBOL(find_lock_page);
>   * @index: the page's index into the mapping
>   * @gfp_mask: page allocation mode
>   *
> - * Locates a page in the pagecache.  If the page is not present, a new page
> - * is allocated using @gfp_mask and is added to the pagecache and to the VM's
> - * LRU list.  The returned page is locked and has its reference count
> - * incremented.
> + * Looks up the page cache slot at @mapping & @offset.  If there is a
> + * page cache page, it is returned locked and with an increased
> + * refcount.
>   *
> - * find_or_create_page() may sleep, even if @gfp_flags specifies an atomic
> - * allocation!
> + * If the page is not present, a new page is allocated using @gfp_mask
> + * and added to the page cache and the VM's LRU list.  The page is
> + * returned locked and with an increased refcount.
>   *
> - * find_or_create_page() returns the desired page's address, or zero on
> - * memory exhaustion.
> + * On memory exhaustion, %NULL is returned.
> + *
> + * find_or_create_page() may sleep, even if @gfp_flags specifies an
> + * atomic allocation!
>   */
>  struct page *find_or_create_page(struct address_space *mapping,
>  		pgoff_t index, gfp_t gfp_mask)
> @@ -890,6 +973,73 @@ repeat:
>  EXPORT_SYMBOL(find_or_create_page);
>  
>  /**
> + * __find_get_pages - gang pagecache lookup
> + * @mapping:	The address_space to search
> + * @start:	The starting page index
> + * @nr_pages:	The maximum number of pages
> + * @pages:	Where the resulting pages are placed

where is @indices?

> + *
> + * __find_get_pages() will search for and return a group of up to
> + * @nr_pages pages in the mapping.  The pages are placed at @pages.
> + * __find_get_pages() takes a reference against the returned pages.
> + *
> + * The search returns a group of mapping-contiguous pages with ascending
> + * indexes.  There may be holes in the indices due to not-present pages.
> + *
> + * Any shadow entries of evicted pages are included in the returned
> + * array.
> + *
> + * __find_get_pages() returns the number of pages and shadow entries
> + * which were found.
> + */
> +unsigned __find_get_pages(struct address_space *mapping,
> +			  pgoff_t start, unsigned int nr_pages,
> +			  struct page **pages, pgoff_t *indices)
> +{
> +	void **slot;
> +	unsigned int ret = 0;
> +	struct radix_tree_iter iter;
> +
> +	if (!nr_pages)
> +		return 0;
> +
> +	rcu_read_lock();
> +restart:
> +	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
> +		struct page *page;
> +repeat:
> +		page = radix_tree_deref_slot(slot);
> +		if (unlikely(!page))
> +			continue;
> +		if (radix_tree_exception(page)) {
> +			if (radix_tree_deref_retry(page))
> +				goto restart;
> +			/*
> +			 * Otherwise, we must be storing a swap entry
> +			 * here as an exceptional entry: so return it
> +			 * without attempting to raise page count.
> +			 */
> +			goto export;
> +		}
> +		if (!page_cache_get_speculative(page))
> +			goto repeat;
> +
> +		/* Has the page moved? */
> +		if (unlikely(page != *slot)) {
> +			page_cache_release(page);
> +			goto repeat;
> +		}
> +export:
> +		indices[ret] = iter.index;
> +		pages[ret] = page;
> +		if (++ret == nr_pages)
> +			break;
> +	}
> +	rcu_read_unlock();
> +	return ret;
> +}
> +
> +/**
>   * find_get_pages - gang pagecache lookup
>   * @mapping:	The address_space to search
>   * @start:	The starting page index
> diff --git a/mm/mincore.c b/mm/mincore.c
> index da2be56a7b8f..ad411ec86a55 100644
> --- a/mm/mincore.c
> +++ b/mm/mincore.c
> @@ -70,13 +70,21 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
>  	 * any other file mapping (ie. marked !present and faulted in with
>  	 * tmpfs's .fault). So swapped out tmpfs mappings are tested here.
>  	 */
> -	page = find_get_page(mapping, pgoff);
>  #ifdef CONFIG_SWAP
> -	/* shmem/tmpfs may return swap: account for swapcache page too. */
> -	if (radix_tree_exceptional_entry(page)) {
> -		swp_entry_t swap = radix_to_swp_entry(page);
> -		page = find_get_page(swap_address_space(swap), swap.val);
> -	}
> +	if (shmem_mapping(mapping)) {
> +		page = __find_get_page(mapping, pgoff);
> +		/*
> +		 * shmem/tmpfs may return swap: account for swapcache
> +		 * page too.
> +		 */
> +		if (radix_tree_exceptional_entry(page)) {
> +			swp_entry_t swp = radix_to_swp_entry(page);
> +			page = find_get_page(swap_address_space(swp), swp.val);
> +		}
> +	} else
> +		page = find_get_page(mapping, pgoff);
> +#else
> +	page = find_get_page(mapping, pgoff);
>  #endif
>  	if (page) {
>  		present = PageUptodate(page);
> diff --git a/mm/readahead.c b/mm/readahead.c
> index 9eeeeda4ac0e..912c00358112 100644
> --- a/mm/readahead.c
> +++ b/mm/readahead.c
> @@ -179,7 +179,7 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
>  		rcu_read_lock();
>  		page = radix_tree_lookup(&mapping->page_tree, page_offset);
>  		rcu_read_unlock();
> -		if (page)
> +		if (page && !radix_tree_exceptional_entry(page))
>  			continue;
>  
>  		page = page_cache_alloc_readahead(mapping);
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 7c67249d6f28..1f4b65f7b831 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -329,56 +329,6 @@ static void shmem_delete_from_page_cache(struct page *page, void *radswap)
>  }
>  
>  /*
> - * Like find_get_pages, but collecting swap entries as well as pages.
> - */
> -static unsigned shmem_find_get_pages_and_swap(struct address_space *mapping,
> -					pgoff_t start, unsigned int nr_pages,
> -					struct page **pages, pgoff_t *indices)
> -{
> -	void **slot;
> -	unsigned int ret = 0;
> -	struct radix_tree_iter iter;
> -
> -	if (!nr_pages)
> -		return 0;
> -
> -	rcu_read_lock();
> -restart:
> -	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
> -		struct page *page;
> -repeat:
> -		page = radix_tree_deref_slot(slot);
> -		if (unlikely(!page))
> -			continue;
> -		if (radix_tree_exception(page)) {
> -			if (radix_tree_deref_retry(page))
> -				goto restart;
> -			/*
> -			 * Otherwise, we must be storing a swap entry
> -			 * here as an exceptional entry: so return it
> -			 * without attempting to raise page count.
> -			 */
> -			goto export;
> -		}
> -		if (!page_cache_get_speculative(page))
> -			goto repeat;
> -
> -		/* Has the page moved? */
> -		if (unlikely(page != *slot)) {
> -			page_cache_release(page);
> -			goto repeat;
> -		}
> -export:
> -		indices[ret] = iter.index;
> -		pages[ret] = page;
> -		if (++ret == nr_pages)
> -			break;
> -	}
> -	rcu_read_unlock();
> -	return ret;
> -}
> -
> -/*
>   * Remove swap entry from radix tree, free the swap and its page cache.
>   */
>  static int shmem_free_swap(struct address_space *mapping,
> @@ -396,21 +346,6 @@ static int shmem_free_swap(struct address_space *mapping,
>  }
>  
>  /*
> - * Pagevec may contain swap entries, so shuffle up pages before releasing.
> - */
> -static void shmem_deswap_pagevec(struct pagevec *pvec)
> -{
> -	int i, j;
> -
> -	for (i = 0, j = 0; i < pagevec_count(pvec); i++) {
> -		struct page *page = pvec->pages[i];
> -		if (!radix_tree_exceptional_entry(page))
> -			pvec->pages[j++] = page;
> -	}
> -	pvec->nr = j;
> -}
> -
> -/*
>   * SysV IPC SHM_UNLOCK restore Unevictable pages to their evictable lists.
>   */
>  void shmem_unlock_mapping(struct address_space *mapping)
> @@ -428,12 +363,12 @@ void shmem_unlock_mapping(struct address_space *mapping)
>  		 * Avoid pagevec_lookup(): find_get_pages() returns 0 as if it
>  		 * has finished, if it hits a row of PAGEVEC_SIZE swap entries.
>  		 */
> -		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
> +		pvec.nr = __find_get_pages(mapping, index,
>  					PAGEVEC_SIZE, pvec.pages, indices);
>  		if (!pvec.nr)
>  			break;
>  		index = indices[pvec.nr - 1] + 1;
> -		shmem_deswap_pagevec(&pvec);
> +		pagevec_remove_exceptionals(&pvec);
>  		check_move_unevictable_pages(pvec.pages, pvec.nr);
>  		pagevec_release(&pvec);
>  		cond_resched();
> @@ -465,9 +400,9 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
>  	pagevec_init(&pvec, 0);
>  	index = start;
>  	while (index < end) {
> -		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
> -				min(end - index, (pgoff_t)PAGEVEC_SIZE),
> -							pvec.pages, indices);
> +		pvec.nr = __find_get_pages(mapping, index,
> +			min(end - index, (pgoff_t)PAGEVEC_SIZE),
> +			pvec.pages, indices);
>  		if (!pvec.nr)
>  			break;
>  		mem_cgroup_uncharge_start();
> @@ -496,7 +431,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
>  			}
>  			unlock_page(page);
>  		}
> -		shmem_deswap_pagevec(&pvec);
> +		pagevec_remove_exceptionals(&pvec);
>  		pagevec_release(&pvec);
>  		mem_cgroup_uncharge_end();
>  		cond_resched();
> @@ -534,9 +469,10 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
>  	index = start;
>  	for ( ; ; ) {
>  		cond_resched();
> -		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
> +
> +		pvec.nr = __find_get_pages(mapping, index,
>  				min(end - index, (pgoff_t)PAGEVEC_SIZE),
> -							pvec.pages, indices);
> +				pvec.pages, indices);
>  		if (!pvec.nr) {
>  			if (index == start || unfalloc)
>  				break;
> @@ -544,7 +480,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
>  			continue;
>  		}
>  		if ((index == start || unfalloc) && indices[0] >= end) {
> -			shmem_deswap_pagevec(&pvec);
> +			pagevec_remove_exceptionals(&pvec);
>  			pagevec_release(&pvec);
>  			break;
>  		}
> @@ -573,7 +509,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
>  			}
>  			unlock_page(page);
>  		}
> -		shmem_deswap_pagevec(&pvec);
> +		pagevec_remove_exceptionals(&pvec);
>  		pagevec_release(&pvec);
>  		mem_cgroup_uncharge_end();
>  		index++;
> @@ -1081,7 +1017,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
>  		return -EFBIG;
>  repeat:
>  	swap.val = 0;
> -	page = find_lock_page(mapping, index);
> +	page = __find_lock_page(mapping, index);
>  	if (radix_tree_exceptional_entry(page)) {
>  		swap = radix_to_swp_entry(page);
>  		page = NULL;
> @@ -1418,6 +1354,11 @@ static struct inode *shmem_get_inode(struct super_block *sb, const struct inode
>  	return inode;
>  }
>  
> +bool shmem_mapping(struct address_space *mapping)
> +{
> +	return mapping->backing_dev_info == &shmem_backing_dev_info;
> +}
> +
>  #ifdef CONFIG_TMPFS
>  static const struct inode_operations shmem_symlink_inode_operations;
>  static const struct inode_operations shmem_short_symlink_operations;
> @@ -1730,7 +1671,7 @@ static pgoff_t shmem_seek_hole_data(struct address_space *mapping,
>  	pagevec_init(&pvec, 0);
>  	pvec.nr = 1;		/* start small: we may be there already */
>  	while (!done) {
> -		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
> +		pvec.nr = __find_get_pages(mapping, index,
>  					pvec.nr, pvec.pages, indices);
>  		if (!pvec.nr) {
>  			if (whence == SEEK_DATA)
> @@ -1757,7 +1698,7 @@ static pgoff_t shmem_seek_hole_data(struct address_space *mapping,
>  				break;
>  			}
>  		}
> -		shmem_deswap_pagevec(&pvec);
> +		pagevec_remove_exceptionals(&pvec);
>  		pagevec_release(&pvec);
>  		pvec.nr = PAGEVEC_SIZE;
>  		cond_resched();
> diff --git a/mm/swap.c b/mm/swap.c
> index 759c3caf44bd..f624e5b4b724 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -894,6 +894,53 @@ EXPORT_SYMBOL(__pagevec_lru_add);
>  
>  /**
>   * pagevec_lookup - gang pagecache lookup

      __pagevec_lookup?

> + * @pvec:	Where the resulting entries are placed
> + * @mapping:	The address_space to search
> + * @start:	The starting entry index
> + * @nr_pages:	The maximum number of entries

      missing @indices?

> + *
> + * pagevec_lookup() will search for and return a group of up to
> + * @nr_pages pages and shadow entries in the mapping.  All entries are
> + * placed in @pvec.  pagevec_lookup() takes a reference against actual
> + * pages in @pvec.
> + *
> + * The search returns a group of mapping-contiguous entries with
> + * ascending indexes.  There may be holes in the indices due to
> + * not-present entries.
> + *
> + * pagevec_lookup() returns the number of entries which were found.

      __pagevec_lookup

> + */
> +unsigned __pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
> +			  pgoff_t start, unsigned nr_pages, pgoff_t *indices)
> +{
> +	pvec->nr = __find_get_pages(mapping, start, nr_pages,
> +				    pvec->pages, indices);
> +	return pagevec_count(pvec);
> +}
> +
> +/**
> + * pagevec_remove_exceptionals - pagevec exceptionals pruning
> + * @pvec:	The pagevec to prune
> + *
> + * __pagevec_lookup() fills both pages and exceptional radix tree
> + * entries into the pagevec.  This function prunes all exceptionals
> + * from @pvec without leaving holes, so that it can be passed on to
> + * other pagevec operations.
> + */
> +void pagevec_remove_exceptionals(struct pagevec *pvec)
> +{
> +	int i, j;
> +
> +	for (i = 0, j = 0; i < pagevec_count(pvec); i++) {
> +		struct page *page = pvec->pages[i];
> +		if (!radix_tree_exceptional_entry(page))
> +			pvec->pages[j++] = page;
> +	}
> +	pvec->nr = j;
> +}
> +
> +/**
> + * pagevec_lookup - gang pagecache lookup
>   * @pvec:	Where the resulting pages are placed
>   * @mapping:	The address_space to search
>   * @start:	The starting page index
> diff --git a/mm/truncate.c b/mm/truncate.c
> index 353b683afd6e..b0f4d4bee8ab 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -22,6 +22,22 @@
>  #include <linux/cleancache.h>
>  #include "internal.h"
>  
> +static void clear_exceptional_entry(struct address_space *mapping,
> +				    pgoff_t index, void *entry)
> +{
> +	/* Handled by shmem itself */
> +	if (shmem_mapping(mapping))
> +		return;
> +
> +	spin_lock_irq(&mapping->tree_lock);
> +	/*
> +	 * Regular page slots are stabilized by the page lock even
> +	 * without the tree itself locked.  These unlocked entries
> +	 * need verification under the tree lock.
> +	 */

Could you explain why repeated spin_lock with irq disabled isn't problem
in truncation path?

> +	radix_tree_delete_item(&mapping->page_tree, index, entry);
> +	spin_unlock_irq(&mapping->tree_lock);
> +}
>  
>  /**
>   * do_invalidatepage - invalidate part or all of a page
> @@ -208,6 +224,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
>  	unsigned int	partial_start;	/* inclusive */
>  	unsigned int	partial_end;	/* exclusive */
>  	struct pagevec	pvec;
> +	pgoff_t		indices[PAGEVEC_SIZE];
>  	pgoff_t		index;
>  	int		i;
>  
> @@ -238,17 +255,23 @@ void truncate_inode_pages_range(struct address_space *mapping,
>  
>  	pagevec_init(&pvec, 0);
>  	index = start;
> -	while (index < end && pagevec_lookup(&pvec, mapping, index,
> -			min(end - index, (pgoff_t)PAGEVEC_SIZE))) {
> +	while (index < end && __pagevec_lookup(&pvec, mapping, index,
> +			min(end - index, (pgoff_t)PAGEVEC_SIZE),
> +			indices)) {
>  		mem_cgroup_uncharge_start();
>  		for (i = 0; i < pagevec_count(&pvec); i++) {
>  			struct page *page = pvec.pages[i];
>  
>  			/* We rely upon deletion not changing page->index */
> -			index = page->index;
> +			index = indices[i];
>  			if (index >= end)
>  				break;
>  
> +			if (radix_tree_exceptional_entry(page)) {
> +				clear_exceptional_entry(mapping, index, page);
> +				continue;
> +			}
> +
>  			if (!trylock_page(page))
>  				continue;
>  			WARN_ON(page->index != index);
> @@ -259,6 +282,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
>  			truncate_inode_page(mapping, page);
>  			unlock_page(page);
>  		}
> +		pagevec_remove_exceptionals(&pvec);
>  		pagevec_release(&pvec);
>  		mem_cgroup_uncharge_end();
>  		cond_resched();
> @@ -307,14 +331,15 @@ void truncate_inode_pages_range(struct address_space *mapping,
>  	index = start;
>  	for ( ; ; ) {
>  		cond_resched();
> -		if (!pagevec_lookup(&pvec, mapping, index,
> -			min(end - index, (pgoff_t)PAGEVEC_SIZE))) {
> +		if (!__pagevec_lookup(&pvec, mapping, index,
> +			min(end - index, (pgoff_t)PAGEVEC_SIZE),
> +			indices)) {
>  			if (index == start)
>  				break;
>  			index = start;
>  			continue;
>  		}
> -		if (index == start && pvec.pages[0]->index >= end) {
> +		if (index == start && indices[0] >= end) {
>  			pagevec_release(&pvec);
>  			break;
>  		}
> @@ -323,16 +348,22 @@ void truncate_inode_pages_range(struct address_space *mapping,
>  			struct page *page = pvec.pages[i];
>  
>  			/* We rely upon deletion not changing page->index */
> -			index = page->index;
> +			index = indices[i];
>  			if (index >= end)
>  				break;
>  
> +			if (radix_tree_exceptional_entry(page)) {
> +				clear_exceptional_entry(mapping, index, page);
> +				continue;
> +			}
> +
>  			lock_page(page);
>  			WARN_ON(page->index != index);
>  			wait_on_page_writeback(page);
>  			truncate_inode_page(mapping, page);
>  			unlock_page(page);
>  		}
> +		pagevec_remove_exceptionals(&pvec);
>  		pagevec_release(&pvec);
>  		mem_cgroup_uncharge_end();
>  		index++;
> @@ -375,6 +406,7 @@ EXPORT_SYMBOL(truncate_inode_pages);
>  unsigned long invalidate_mapping_pages(struct address_space *mapping,
>  		pgoff_t start, pgoff_t end)
>  {
> +	pgoff_t indices[PAGEVEC_SIZE];
>  	struct pagevec pvec;
>  	pgoff_t index = start;
>  	unsigned long ret;
> @@ -390,17 +422,23 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
>  	 */
>  
>  	pagevec_init(&pvec, 0);
> -	while (index <= end && pagevec_lookup(&pvec, mapping, index,
> -			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
> +	while (index <= end && __pagevec_lookup(&pvec, mapping, index,
> +			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
> +			indices)) {
>  		mem_cgroup_uncharge_start();
>  		for (i = 0; i < pagevec_count(&pvec); i++) {
>  			struct page *page = pvec.pages[i];
>  
>  			/* We rely upon deletion not changing page->index */
> -			index = page->index;
> +			index = indices[i];
>  			if (index > end)
>  				break;
>  
> +			if (radix_tree_exceptional_entry(page)) {
> +				clear_exceptional_entry(mapping, index, page);
> +				continue;
> +			}
> +
>  			if (!trylock_page(page))
>  				continue;
>  			WARN_ON(page->index != index);
> @@ -414,6 +452,7 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
>  				deactivate_page(page);
>  			count += ret;
>  		}
> +		pagevec_remove_exceptionals(&pvec);
>  		pagevec_release(&pvec);
>  		mem_cgroup_uncharge_end();
>  		cond_resched();
> @@ -481,6 +520,7 @@ static int do_launder_page(struct address_space *mapping, struct page *page)
>  int invalidate_inode_pages2_range(struct address_space *mapping,
>  				  pgoff_t start, pgoff_t end)
>  {
> +	pgoff_t indices[PAGEVEC_SIZE];
>  	struct pagevec pvec;
>  	pgoff_t index;
>  	int i;
> @@ -491,17 +531,23 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
>  	cleancache_invalidate_inode(mapping);
>  	pagevec_init(&pvec, 0);
>  	index = start;
> -	while (index <= end && pagevec_lookup(&pvec, mapping, index,
> -			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
> +	while (index <= end && __pagevec_lookup(&pvec, mapping, index,
> +			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
> +			indices)) {
>  		mem_cgroup_uncharge_start();
>  		for (i = 0; i < pagevec_count(&pvec); i++) {
>  			struct page *page = pvec.pages[i];
>  
>  			/* We rely upon deletion not changing page->index */
> -			index = page->index;
> +			index = indices[i];
>  			if (index > end)
>  				break;
>  
> +			if (radix_tree_exceptional_entry(page)) {
> +				clear_exceptional_entry(mapping, index, page);
> +				continue;
> +			}
> +
>  			lock_page(page);
>  			WARN_ON(page->index != index);
>  			if (page->mapping != mapping) {
> @@ -539,6 +585,7 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
>  				ret = ret2;
>  			unlock_page(page);
>  		}
> +		pagevec_remove_exceptionals(&pvec);
>  		pagevec_release(&pvec);
>  		mem_cgroup_uncharge_end();
>  		cond_resched();
> -- 
> 1.8.4.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
