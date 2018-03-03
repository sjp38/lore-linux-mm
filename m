Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD5616B0007
	for <linux-mm@kvack.org>; Sat,  3 Mar 2018 09:28:08 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id s82so10177425qke.1
        for <linux-mm@kvack.org>; Sat, 03 Mar 2018 06:28:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u22sor6809555qte.54.2018.03.03.06.28.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 03 Mar 2018 06:28:02 -0800 (PST)
Message-ID: <1520087276.4280.29.camel@redhat.com>
Subject: Re: [PATCH v7 09/61] page cache: Use xa_lock
From: Jeff Layton <jlayton@redhat.com>
Date: Sat, 03 Mar 2018 09:27:56 -0500
In-Reply-To: <20180219194556.6575-10-willy@infradead.org>
References: <20180219194556.6575-1-willy@infradead.org>
	 <20180219194556.6575-10-willy@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, 2018-02-19 at 11:45 -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Remove the address_space ->tree_lock and use the xa_lock newly added to
> the radix_tree_root.  Rename the address_space ->page_tree to ->pages,
> since we don't really care that it's a tree.  Take the opportunity to
> rearrange the elements of address_space to pack them better on 64-bit,
> and make the comments more useful.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  Documentation/cgroup-v1/memory.txt              |   2 +-
>  Documentation/vm/page_migration                 |  14 +--
>  arch/arm/include/asm/cacheflush.h               |   6 +-
>  arch/nios2/include/asm/cacheflush.h             |   6 +-
>  arch/parisc/include/asm/cacheflush.h            |   6 +-
>  drivers/staging/lustre/lustre/llite/glimpse.c   |   2 +-
>  drivers/staging/lustre/lustre/mdc/mdc_request.c |   8 +-
>  fs/afs/write.c                                  |   9 +-
>  fs/btrfs/compression.c                          |   2 +-
>  fs/btrfs/extent_io.c                            |  16 +--
>  fs/btrfs/inode.c                                |   2 +-
>  fs/buffer.c                                     |  13 ++-
>  fs/cifs/file.c                                  |   9 +-
>  fs/dax.c                                        | 123 ++++++++++++------------
>  fs/f2fs/data.c                                  |   6 +-
>  fs/f2fs/dir.c                                   |   6 +-
>  fs/f2fs/inline.c                                |   6 +-
>  fs/f2fs/node.c                                  |   8 +-
>  fs/fs-writeback.c                               |  20 ++--
>  fs/inode.c                                      |  11 +--
>  fs/nilfs2/btnode.c                              |  20 ++--
>  fs/nilfs2/page.c                                |  22 ++---
>  include/linux/backing-dev.h                     |  12 +--
>  include/linux/fs.h                              |  17 ++--
>  include/linux/mm.h                              |   2 +-
>  include/linux/pagemap.h                         |   4 +-
>  mm/filemap.c                                    |  84 ++++++++--------
>  mm/huge_memory.c                                |  10 +-
>  mm/khugepaged.c                                 |  49 +++++-----
>  mm/memcontrol.c                                 |   4 +-
>  mm/migrate.c                                    |  32 +++---
>  mm/page-writeback.c                             |  42 ++++----
>  mm/readahead.c                                  |   2 +-
>  mm/rmap.c                                       |   4 +-
>  mm/shmem.c                                      |  60 ++++++------
>  mm/swap_state.c                                 |  17 ++--
>  mm/truncate.c                                   |  22 ++---
>  mm/vmscan.c                                     |  12 +--
>  mm/workingset.c                                 |  22 ++---
>  39 files changed, 344 insertions(+), 368 deletions(-)
> 
> diff --git a/Documentation/cgroup-v1/memory.txt b/Documentation/cgroup-v1/memory.txt
> index a4af2e124e24..e8ed4c2c2e9c 100644
> --- a/Documentation/cgroup-v1/memory.txt
> +++ b/Documentation/cgroup-v1/memory.txt
> @@ -262,7 +262,7 @@ When oom event notifier is registered, event will be delivered.
>  2.6 Locking
>  
>     lock_page_cgroup()/unlock_page_cgroup() should not be called under
> -   mapping->tree_lock.
> +   the mapping's xa_lock.
>  
>     Other lock order is following:
>     PG_locked.
> diff --git a/Documentation/vm/page_migration b/Documentation/vm/page_migration
> index 0478ae2ad44a..faf849596a85 100644
> --- a/Documentation/vm/page_migration
> +++ b/Documentation/vm/page_migration
> @@ -90,7 +90,7 @@ Steps:
>  
>  1. Lock the page to be migrated
>  
> -2. Insure that writeback is complete.
> +2. Ensure that writeback is complete.
>  
>  3. Lock the new page that we want to move to. It is locked so that accesses to
>     this (not yet uptodate) page immediately lock while the move is in progress.
> @@ -100,8 +100,8 @@ Steps:
>     mapcount is not zero then we do not migrate the page. All user space
>     processes that attempt to access the page will now wait on the page lock.
>  
> -5. The radix tree lock is taken. This will cause all processes trying
> -   to access the page via the mapping to block on the radix tree spinlock.
> +5. The address space xa_lock is taken. This will cause all processes trying
> +   to access the page via the mapping to block on the spinlock.
>  
>  6. The refcount of the page is examined and we back out if references remain
>     otherwise we know that we are the only one referencing this page.
> @@ -114,12 +114,12 @@ Steps:
>  
>  9. The radix tree is changed to point to the new page.
>  
> -10. The reference count of the old page is dropped because the radix tree
> +10. The reference count of the old page is dropped because the address space
>      reference is gone. A reference to the new page is established because
> -    the new page is referenced to by the radix tree.
> +    the new page is referenced by the address space.
>  
> -11. The radix tree lock is dropped. With that lookups in the mapping
> -    become possible again. Processes will move from spinning on the tree_lock
> +11. The address space xa_lock is dropped. With that lookups in the mapping
> +    become possible again. Processes will move from spinning on the xa_lock
>      to sleeping on the locked new page.
>  
>  12. The page contents are copied to the new page.
> diff --git a/arch/arm/include/asm/cacheflush.h b/arch/arm/include/asm/cacheflush.h
> index 74504b154256..f4ead9a74b7d 100644
> --- a/arch/arm/include/asm/cacheflush.h
> +++ b/arch/arm/include/asm/cacheflush.h
> @@ -318,10 +318,8 @@ static inline void flush_anon_page(struct vm_area_struct *vma,
>  #define ARCH_HAS_FLUSH_KERNEL_DCACHE_PAGE
>  extern void flush_kernel_dcache_page(struct page *);
>  
> -#define flush_dcache_mmap_lock(mapping) \
> -	spin_lock_irq(&(mapping)->tree_lock)
> -#define flush_dcache_mmap_unlock(mapping) \
> -	spin_unlock_irq(&(mapping)->tree_lock)
> +#define flush_dcache_mmap_lock(mapping)		xa_lock_irq(&mapping->pages)
> +#define flush_dcache_mmap_unlock(mapping)	xa_unlock_irq(&mapping->pages)
>  
>  #define flush_icache_user_range(vma,page,addr,len) \
>  	flush_dcache_page(page)
> diff --git a/arch/nios2/include/asm/cacheflush.h b/arch/nios2/include/asm/cacheflush.h
> index 55e383c173f7..7a6eda381964 100644
> --- a/arch/nios2/include/asm/cacheflush.h
> +++ b/arch/nios2/include/asm/cacheflush.h
> @@ -46,9 +46,7 @@ extern void copy_from_user_page(struct vm_area_struct *vma, struct page *page,
>  extern void flush_dcache_range(unsigned long start, unsigned long end);
>  extern void invalidate_dcache_range(unsigned long start, unsigned long end);
>  
> -#define flush_dcache_mmap_lock(mapping) \
> -	spin_lock_irq(&(mapping)->tree_lock)
> -#define flush_dcache_mmap_unlock(mapping) \
> -	spin_unlock_irq(&(mapping)->tree_lock)
> +#define flush_dcache_mmap_lock(mapping)		xa_lock_irq(&mapping->pages)
> +#define flush_dcache_mmap_unlock(mapping)	xa_unlock_irq(&mapping->pages)
>  
>  #endif /* _ASM_NIOS2_CACHEFLUSH_H */
> diff --git a/arch/parisc/include/asm/cacheflush.h b/arch/parisc/include/asm/cacheflush.h
> index 3742508cc534..b772dd320118 100644
> --- a/arch/parisc/include/asm/cacheflush.h
> +++ b/arch/parisc/include/asm/cacheflush.h
> @@ -54,10 +54,8 @@ void invalidate_kernel_vmap_range(void *vaddr, int size);
>  #define ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE 1
>  extern void flush_dcache_page(struct page *page);
>  
> -#define flush_dcache_mmap_lock(mapping) \
> -	spin_lock_irq(&(mapping)->tree_lock)
> -#define flush_dcache_mmap_unlock(mapping) \
> -	spin_unlock_irq(&(mapping)->tree_lock)
> +#define flush_dcache_mmap_lock(mapping)		xa_lock_irq(&mapping->pages)
> +#define flush_dcache_mmap_unlock(mapping)	xa_unlock_irq(&mapping->pages)
>  
>  #define flush_icache_page(vma,page)	do { 		\
>  	flush_kernel_dcache_page(page);			\
> diff --git a/drivers/staging/lustre/lustre/llite/glimpse.c b/drivers/staging/lustre/lustre/llite/glimpse.c
> index c43ac574274c..5f2843da911c 100644
> --- a/drivers/staging/lustre/lustre/llite/glimpse.c
> +++ b/drivers/staging/lustre/lustre/llite/glimpse.c
> @@ -69,7 +69,7 @@ blkcnt_t dirty_cnt(struct inode *inode)
>  	void	      *results[1];
>  
>  	if (inode->i_mapping)
> -		cnt += radix_tree_gang_lookup_tag(&inode->i_mapping->page_tree,
> +		cnt += radix_tree_gang_lookup_tag(&inode->i_mapping->pages,
>  						  results, 0, 1,
>  						  PAGECACHE_TAG_DIRTY);
>  	if (cnt == 0 && atomic_read(&vob->vob_mmap_cnt) > 0)
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> index 03e55bca4ada..45dcf9f958d4 100644
> --- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
> +++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> @@ -937,14 +937,14 @@ static struct page *mdc_page_locate(struct address_space *mapping, __u64 *hash,
>  	struct page *page;
>  	int found;
>  
> -	spin_lock_irq(&mapping->tree_lock);
> -	found = radix_tree_gang_lookup(&mapping->page_tree,
> +	xa_lock_irq(&mapping->pages);
> +	found = radix_tree_gang_lookup(&mapping->pages,
>  				       (void **)&page, offset, 1);
>  	if (found > 0 && !radix_tree_exceptional_entry(page)) {
>  		struct lu_dirpage *dp;
>  
>  		get_page(page);
> -		spin_unlock_irq(&mapping->tree_lock);
> +		xa_unlock_irq(&mapping->pages);
>  		/*
>  		 * In contrast to find_lock_page() we are sure that directory
>  		 * page cannot be truncated (while DLM lock is held) and,
> @@ -992,7 +992,7 @@ static struct page *mdc_page_locate(struct address_space *mapping, __u64 *hash,
>  			page = ERR_PTR(-EIO);
>  		}
>  	} else {
> -		spin_unlock_irq(&mapping->tree_lock);
> +		xa_unlock_irq(&mapping->pages);
>  		page = NULL;
>  	}
>  	return page;
> diff --git a/fs/afs/write.c b/fs/afs/write.c
> index 9370e2feb999..603d2ce48dbb 100644
> --- a/fs/afs/write.c
> +++ b/fs/afs/write.c
> @@ -570,10 +570,11 @@ static int afs_writepages_region(struct address_space *mapping,
>  
>  		_debug("wback %lx", page->index);
>  
> -		/* at this point we hold neither mapping->tree_lock nor lock on
> -		 * the page itself: the page may be truncated or invalidated
> -		 * (changing page->mapping to NULL), or even swizzled back from
> -		 * swapper_space to tmpfs file mapping
> +		/*
> +		 * at this point we hold neither the xa_lock nor the
> +		 * page lock: the page may be truncated or invalidated
> +		 * (changing page->mapping to NULL), or even swizzled
> +		 * back from swapper_space to tmpfs file mapping
>  		 */
>  		ret = lock_page_killable(page);
>  		if (ret < 0) {
> diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
> index 07d049c0c20f..0e35aa6aa2f1 100644
> --- a/fs/btrfs/compression.c
> +++ b/fs/btrfs/compression.c
> @@ -458,7 +458,7 @@ static noinline int add_ra_bio_pages(struct inode *inode,
>  			break;
>  
>  		rcu_read_lock();
> -		page = radix_tree_lookup(&mapping->page_tree, pg_index);
> +		page = radix_tree_lookup(&mapping->pages, pg_index);
>  		rcu_read_unlock();
>  		if (page && !radix_tree_exceptional_entry(page)) {
>  			misses++;
> diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
> index dfeb74a0be77..1f2739702518 100644
> --- a/fs/btrfs/extent_io.c
> +++ b/fs/btrfs/extent_io.c
> @@ -3958,11 +3958,11 @@ static int extent_write_cache_pages(struct address_space *mapping,
>  
>  			done_index = page->index;
>  			/*
> -			 * At this point we hold neither mapping->tree_lock nor
> -			 * lock on the page itself: the page may be truncated or
> -			 * invalidated (changing page->mapping to NULL), or even
> -			 * swizzled back from swapper_space to tmpfs file
> -			 * mapping
> +			 * At this point we hold neither the xa_lock nor
> +			 * the page lock: the page may be truncated or
> +			 * invalidated (changing page->mapping to NULL),
> +			 * or even swizzled back from swapper_space to
> +			 * tmpfs file mapping
>  			 */
>  			if (!trylock_page(page)) {
>  				flush_write_bio(epd);
> @@ -5169,13 +5169,13 @@ void clear_extent_buffer_dirty(struct extent_buffer *eb)
>  		WARN_ON(!PagePrivate(page));
>  
>  		clear_page_dirty_for_io(page);
> -		spin_lock_irq(&page->mapping->tree_lock);
> +		xa_lock_irq(&page->mapping->pages);
>  		if (!PageDirty(page)) {
> -			radix_tree_tag_clear(&page->mapping->page_tree,
> +			radix_tree_tag_clear(&page->mapping->pages,
>  						page_index(page),
>  						PAGECACHE_TAG_DIRTY);
>  		}
> -		spin_unlock_irq(&page->mapping->tree_lock);
> +		xa_unlock_irq(&page->mapping->pages);
>  		ClearPageError(page);
>  		unlock_page(page);
>  	}
> diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
> index 53ca025655fc..d0016c1c7b04 100644
> --- a/fs/btrfs/inode.c
> +++ b/fs/btrfs/inode.c
> @@ -7427,7 +7427,7 @@ noinline int can_nocow_extent(struct inode *inode, u64 offset, u64 *len,
>  
>  bool btrfs_page_exists_in_range(struct inode *inode, loff_t start, loff_t end)
>  {
> -	struct radix_tree_root *root = &inode->i_mapping->page_tree;
> +	struct radix_tree_root *root = &inode->i_mapping->pages;
>  	bool found = false;
>  	void **pagep = NULL;
>  	struct page *page = NULL;
> diff --git a/fs/buffer.c b/fs/buffer.c
> index 0b487cdb7124..692ee249fb6a 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -185,10 +185,9 @@ EXPORT_SYMBOL(end_buffer_write_sync);
>   * we get exclusion from try_to_free_buffers with the blockdev mapping's
>   * private_lock.
>   *
> - * Hack idea: for the blockdev mapping, i_bufferlist_lock contention
> + * Hack idea: for the blockdev mapping, private_lock contention
>   * may be quite high.  This code could TryLock the page, and if that
> - * succeeds, there is no need to take private_lock. (But if
> - * private_lock is contended then so is mapping->tree_lock).
> + * succeeds, there is no need to take private_lock.
>   */
>  static struct buffer_head *
>  __find_get_block_slow(struct block_device *bdev, sector_t block)
> @@ -599,14 +598,14 @@ void __set_page_dirty(struct page *page, struct address_space *mapping,
>  {
>  	unsigned long flags;
>  
> -	spin_lock_irqsave(&mapping->tree_lock, flags);
> +	xa_lock_irqsave(&mapping->pages, flags);
>  	if (page->mapping) {	/* Race with truncate? */
>  		WARN_ON_ONCE(warn && !PageUptodate(page));
>  		account_page_dirtied(page, mapping);
> -		radix_tree_tag_set(&mapping->page_tree,
> +		radix_tree_tag_set(&mapping->pages,
>  				page_index(page), PAGECACHE_TAG_DIRTY);
>  	}
> -	spin_unlock_irqrestore(&mapping->tree_lock, flags);
> +	xa_unlock_irqrestore(&mapping->pages, flags);
>  }
>  EXPORT_SYMBOL_GPL(__set_page_dirty);
>  
> @@ -1096,7 +1095,7 @@ __getblk_slow(struct block_device *bdev, sector_t block,
>   * inode list.
>   *
>   * mark_buffer_dirty() is atomic.  It takes bh->b_page->mapping->private_lock,
> - * mapping->tree_lock and mapping->host->i_lock.
> + * mapping xa_lock and mapping->host->i_lock.
>   */
>  void mark_buffer_dirty(struct buffer_head *bh)
>  {
> diff --git a/fs/cifs/file.c b/fs/cifs/file.c
> index 7cee97b93a61..a6ace9ac4d94 100644
> --- a/fs/cifs/file.c
> +++ b/fs/cifs/file.c
> @@ -1987,11 +1987,10 @@ wdata_prepare_pages(struct cifs_writedata *wdata, unsigned int found_pages,
>  	for (i = 0; i < found_pages; i++) {
>  		page = wdata->pages[i];
>  		/*
> -		 * At this point we hold neither mapping->tree_lock nor
> -		 * lock on the page itself: the page may be truncated or
> -		 * invalidated (changing page->mapping to NULL), or even
> -		 * swizzled back from swapper_space to tmpfs file
> -		 * mapping
> +		 * At this point we hold neither the xa_lock nor the
> +		 * page lock: the page may be truncated or invalidated
> +		 * (changing page->mapping to NULL), or even swizzled
> +		 * back from swapper_space to tmpfs file mapping
>  		 */
>  
>  		if (nr_pages == 0)
> diff --git a/fs/dax.c b/fs/dax.c
> index 0276df90e86c..cac580399ed4 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -159,11 +159,9 @@ static int wake_exceptional_entry_func(wait_queue_entry_t *wait, unsigned int mo
>  }
>  
>  /*
> - * We do not necessarily hold the mapping->tree_lock when we call this
> - * function so it is possible that 'entry' is no longer a valid item in the
> - * radix tree.  This is okay because all we really need to do is to find the
> - * correct waitqueue where tasks might be waiting for that old 'entry' and
> - * wake them.
> + * @entry may no longer be the entry at the index in the mapping.
> + * The important information it's conveying is whether the entry at
> + * this index used to be a PMD entry.
>   */
>  static void dax_wake_mapping_entry_waiter(struct address_space *mapping,
>  		pgoff_t index, void *entry, bool wake_all)
> @@ -175,7 +173,7 @@ static void dax_wake_mapping_entry_waiter(struct address_space *mapping,
>  
>  	/*
>  	 * Checking for locked entry and prepare_to_wait_exclusive() happens
> -	 * under mapping->tree_lock, ditto for entry handling in our callers.
> +	 * under xa_lock, ditto for entry handling in our callers.
>  	 * So at this point all tasks that could have seen our entry locked
>  	 * must be in the waitqueue and the following check will see them.
>  	 */
> @@ -184,41 +182,38 @@ static void dax_wake_mapping_entry_waiter(struct address_space *mapping,
>  }
>  
>  /*
> - * Check whether the given slot is locked. The function must be called with
> - * mapping->tree_lock held
> + * Check whether the given slot is locked.  Must be called with xa_lock held.
>   */
>  static inline int slot_locked(struct address_space *mapping, void **slot)
>  {
>  	unsigned long entry = (unsigned long)
> -		radix_tree_deref_slot_protected(slot, &mapping->tree_lock);
> +		radix_tree_deref_slot_protected(slot, &mapping->pages.xa_lock);
>  	return entry & RADIX_DAX_ENTRY_LOCK;
>  }
>  
>  /*
> - * Mark the given slot is locked. The function must be called with
> - * mapping->tree_lock held
> + * Mark the given slot as locked.  Must be called with xa_lock held.
>   */
>  static inline void *lock_slot(struct address_space *mapping, void **slot)
>  {
>  	unsigned long entry = (unsigned long)
> -		radix_tree_deref_slot_protected(slot, &mapping->tree_lock);
> +		radix_tree_deref_slot_protected(slot, &mapping->pages.xa_lock);
>  
>  	entry |= RADIX_DAX_ENTRY_LOCK;
> -	radix_tree_replace_slot(&mapping->page_tree, slot, (void *)entry);
> +	radix_tree_replace_slot(&mapping->pages, slot, (void *)entry);
>  	return (void *)entry;
>  }
>  
>  /*
> - * Mark the given slot is unlocked. The function must be called with
> - * mapping->tree_lock held
> + * Mark the given slot as unlocked.  Must be called with xa_lock held.
>   */
>  static inline void *unlock_slot(struct address_space *mapping, void **slot)
>  {
>  	unsigned long entry = (unsigned long)
> -		radix_tree_deref_slot_protected(slot, &mapping->tree_lock);
> +		radix_tree_deref_slot_protected(slot, &mapping->pages.xa_lock);
>  
>  	entry &= ~(unsigned long)RADIX_DAX_ENTRY_LOCK;
> -	radix_tree_replace_slot(&mapping->page_tree, slot, (void *)entry);
> +	radix_tree_replace_slot(&mapping->pages, slot, (void *)entry);
>  	return (void *)entry;
>  }
>  
> @@ -229,7 +224,7 @@ static inline void *unlock_slot(struct address_space *mapping, void **slot)
>   * put_locked_mapping_entry() when he locked the entry and now wants to
>   * unlock it.
>   *
> - * The function must be called with mapping->tree_lock held.
> + * Must be called with xa_lock held.
>   */
>  static void *get_unlocked_mapping_entry(struct address_space *mapping,
>  					pgoff_t index, void ***slotp)
> @@ -242,7 +237,7 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
>  	ewait.wait.func = wake_exceptional_entry_func;
>  
>  	for (;;) {
> -		entry = __radix_tree_lookup(&mapping->page_tree, index, NULL,
> +		entry = __radix_tree_lookup(&mapping->pages, index, NULL,
>  					  &slot);
>  		if (!entry ||
>  		    WARN_ON_ONCE(!radix_tree_exceptional_entry(entry)) ||
> @@ -255,10 +250,10 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
>  		wq = dax_entry_waitqueue(mapping, index, entry, &ewait.key);
>  		prepare_to_wait_exclusive(wq, &ewait.wait,
>  					  TASK_UNINTERRUPTIBLE);
> -		spin_unlock_irq(&mapping->tree_lock);
> +		xa_unlock_irq(&mapping->pages);
>  		schedule();
>  		finish_wait(wq, &ewait.wait);
> -		spin_lock_irq(&mapping->tree_lock);
> +		xa_lock_irq(&mapping->pages);
>  	}
>  }
>  
> @@ -267,15 +262,15 @@ static void dax_unlock_mapping_entry(struct address_space *mapping,
>  {
>  	void *entry, **slot;
>  
> -	spin_lock_irq(&mapping->tree_lock);
> -	entry = __radix_tree_lookup(&mapping->page_tree, index, NULL, &slot);
> +	xa_lock_irq(&mapping->pages);
> +	entry = __radix_tree_lookup(&mapping->pages, index, NULL, &slot);
>  	if (WARN_ON_ONCE(!entry || !radix_tree_exceptional_entry(entry) ||
>  			 !slot_locked(mapping, slot))) {
> -		spin_unlock_irq(&mapping->tree_lock);
> +		xa_unlock_irq(&mapping->pages);
>  		return;
>  	}
>  	unlock_slot(mapping, slot);
> -	spin_unlock_irq(&mapping->tree_lock);
> +	xa_unlock_irq(&mapping->pages);
>  	dax_wake_mapping_entry_waiter(mapping, index, entry, false);
>  }
>  
> @@ -332,7 +327,7 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
>  	void *entry, **slot;
>  
>  restart:
> -	spin_lock_irq(&mapping->tree_lock);
> +	xa_lock_irq(&mapping->pages);
>  	entry = get_unlocked_mapping_entry(mapping, index, &slot);
>  
>  	if (WARN_ON_ONCE(entry && !radix_tree_exceptional_entry(entry))) {
> @@ -364,12 +359,12 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
>  		if (pmd_downgrade) {
>  			/*
>  			 * Make sure 'entry' remains valid while we drop
> -			 * mapping->tree_lock.
> +			 * xa_lock.
>  			 */
>  			entry = lock_slot(mapping, slot);
>  		}
>  
> -		spin_unlock_irq(&mapping->tree_lock);
> +		xa_unlock_irq(&mapping->pages);
>  		/*
>  		 * Besides huge zero pages the only other thing that gets
>  		 * downgraded are empty entries which don't need to be
> @@ -386,26 +381,26 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
>  				put_locked_mapping_entry(mapping, index);
>  			return ERR_PTR(err);
>  		}
> -		spin_lock_irq(&mapping->tree_lock);
> +		xa_lock_irq(&mapping->pages);
>  
>  		if (!entry) {
>  			/*
> -			 * We needed to drop the page_tree lock while calling
> +			 * We needed to drop the pages lock while calling
>  			 * radix_tree_preload() and we didn't have an entry to
>  			 * lock.  See if another thread inserted an entry at
>  			 * our index during this time.
>  			 */
> -			entry = __radix_tree_lookup(&mapping->page_tree, index,
> +			entry = __radix_tree_lookup(&mapping->pages, index,
>  					NULL, &slot);
>  			if (entry) {
>  				radix_tree_preload_end();
> -				spin_unlock_irq(&mapping->tree_lock);
> +				xa_unlock_irq(&mapping->pages);
>  				goto restart;
>  			}
>  		}
>  
>  		if (pmd_downgrade) {
> -			radix_tree_delete(&mapping->page_tree, index);
> +			radix_tree_delete(&mapping->pages, index);
>  			mapping->nrexceptional--;
>  			dax_wake_mapping_entry_waiter(mapping, index, entry,
>  					true);
> @@ -413,11 +408,11 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
>  
>  		entry = dax_radix_locked_entry(0, size_flag | RADIX_DAX_EMPTY);
>  
> -		err = __radix_tree_insert(&mapping->page_tree, index,
> +		err = __radix_tree_insert(&mapping->pages, index,
>  				dax_radix_order(entry), entry);
>  		radix_tree_preload_end();
>  		if (err) {
> -			spin_unlock_irq(&mapping->tree_lock);
> +			xa_unlock_irq(&mapping->pages);
>  			/*
>  			 * Our insertion of a DAX entry failed, most likely
>  			 * because we were inserting a PMD entry and it
> @@ -430,12 +425,12 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
>  		}
>  		/* Good, we have inserted empty locked entry into the tree. */
>  		mapping->nrexceptional++;
> -		spin_unlock_irq(&mapping->tree_lock);
> +		xa_unlock_irq(&mapping->pages);
>  		return entry;
>  	}
>  	entry = lock_slot(mapping, slot);
>   out_unlock:
> -	spin_unlock_irq(&mapping->tree_lock);
> +	xa_unlock_irq(&mapping->pages);
>  	return entry;
>  }
>  
> @@ -444,22 +439,22 @@ static int __dax_invalidate_mapping_entry(struct address_space *mapping,
>  {
>  	int ret = 0;
>  	void *entry;
> -	struct radix_tree_root *page_tree = &mapping->page_tree;
> +	struct radix_tree_root *pages = &mapping->pages;
>  
> -	spin_lock_irq(&mapping->tree_lock);
> +	xa_lock_irq(&mapping->pages);
>  	entry = get_unlocked_mapping_entry(mapping, index, NULL);
>  	if (!entry || WARN_ON_ONCE(!radix_tree_exceptional_entry(entry)))
>  		goto out;
>  	if (!trunc &&
> -	    (radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_DIRTY) ||
> -	     radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_TOWRITE)))
> +	    (radix_tree_tag_get(pages, index, PAGECACHE_TAG_DIRTY) ||
> +	     radix_tree_tag_get(pages, index, PAGECACHE_TAG_TOWRITE)))
>  		goto out;
> -	radix_tree_delete(page_tree, index);
> +	radix_tree_delete(pages, index);
>  	mapping->nrexceptional--;
>  	ret = 1;
>  out:
>  	put_unlocked_mapping_entry(mapping, index, entry);
> -	spin_unlock_irq(&mapping->tree_lock);
> +	xa_unlock_irq(&mapping->pages);
>  	return ret;
>  }
>  /*
> @@ -529,7 +524,7 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
>  				      void *entry, sector_t sector,
>  				      unsigned long flags, bool dirty)
>  {
> -	struct radix_tree_root *page_tree = &mapping->page_tree;
> +	struct radix_tree_root *pages = &mapping->pages;
>  	void *new_entry;
>  	pgoff_t index = vmf->pgoff;
>  
> @@ -545,7 +540,7 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
>  			unmap_mapping_pages(mapping, vmf->pgoff, 1, false);
>  	}
>  
> -	spin_lock_irq(&mapping->tree_lock);
> +	xa_lock_irq(&mapping->pages);
>  	new_entry = dax_radix_locked_entry(sector, flags);
>  
>  	if (dax_is_zero_entry(entry) || dax_is_empty_entry(entry)) {
> @@ -561,17 +556,17 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
>  		void **slot;
>  		void *ret;
>  
> -		ret = __radix_tree_lookup(page_tree, index, &node, &slot);
> +		ret = __radix_tree_lookup(pages, index, &node, &slot);
>  		WARN_ON_ONCE(ret != entry);
> -		__radix_tree_replace(page_tree, node, slot,
> +		__radix_tree_replace(pages, node, slot,
>  				     new_entry, NULL);
>  		entry = new_entry;
>  	}
>  
>  	if (dirty)
> -		radix_tree_tag_set(page_tree, index, PAGECACHE_TAG_DIRTY);
> +		radix_tree_tag_set(pages, index, PAGECACHE_TAG_DIRTY);
>  
> -	spin_unlock_irq(&mapping->tree_lock);
> +	xa_unlock_irq(&mapping->pages);
>  	return entry;
>  }
>  
> @@ -661,7 +656,7 @@ static int dax_writeback_one(struct block_device *bdev,
>  		struct dax_device *dax_dev, struct address_space *mapping,
>  		pgoff_t index, void *entry)
>  {
> -	struct radix_tree_root *page_tree = &mapping->page_tree;
> +	struct radix_tree_root *pages = &mapping->pages;
>  	void *entry2, **slot, *kaddr;
>  	long ret = 0, id;
>  	sector_t sector;
> @@ -676,7 +671,7 @@ static int dax_writeback_one(struct block_device *bdev,
>  	if (WARN_ON(!radix_tree_exceptional_entry(entry)))
>  		return -EIO;
>  
> -	spin_lock_irq(&mapping->tree_lock);
> +	xa_lock_irq(&mapping->pages);
>  	entry2 = get_unlocked_mapping_entry(mapping, index, &slot);
>  	/* Entry got punched out / reallocated? */
>  	if (!entry2 || WARN_ON_ONCE(!radix_tree_exceptional_entry(entry2)))
> @@ -695,7 +690,7 @@ static int dax_writeback_one(struct block_device *bdev,
>  	}
>  
>  	/* Another fsync thread may have already written back this entry */
> -	if (!radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_TOWRITE))
> +	if (!radix_tree_tag_get(pages, index, PAGECACHE_TAG_TOWRITE))
>  		goto put_unlocked;
>  	/* Lock the entry to serialize with page faults */
>  	entry = lock_slot(mapping, slot);
> @@ -703,11 +698,11 @@ static int dax_writeback_one(struct block_device *bdev,
>  	 * We can clear the tag now but we have to be careful so that concurrent
>  	 * dax_writeback_one() calls for the same index cannot finish before we
>  	 * actually flush the caches. This is achieved as the calls will look
> -	 * at the entry only under tree_lock and once they do that they will
> +	 * at the entry only under xa_lock and once they do that they will
>  	 * see the entry locked and wait for it to unlock.
>  	 */
> -	radix_tree_tag_clear(page_tree, index, PAGECACHE_TAG_TOWRITE);
> -	spin_unlock_irq(&mapping->tree_lock);
> +	radix_tree_tag_clear(pages, index, PAGECACHE_TAG_TOWRITE);
> +	xa_unlock_irq(&mapping->pages);
>  
>  	/*
>  	 * Even if dax_writeback_mapping_range() was given a wbc->range_start
> @@ -725,7 +720,7 @@ static int dax_writeback_one(struct block_device *bdev,
>  		goto dax_unlock;
>  
>  	/*
> -	 * dax_direct_access() may sleep, so cannot hold tree_lock over
> +	 * dax_direct_access() may sleep, so cannot hold xa_lock over
>  	 * its invocation.
>  	 */
>  	ret = dax_direct_access(dax_dev, pgoff, size / PAGE_SIZE, &kaddr, &pfn);
> @@ -745,9 +740,9 @@ static int dax_writeback_one(struct block_device *bdev,
>  	 * the pfn mappings are writeprotected and fault waits for mapping
>  	 * entry lock.
>  	 */
> -	spin_lock_irq(&mapping->tree_lock);
> -	radix_tree_tag_clear(page_tree, index, PAGECACHE_TAG_DIRTY);
> -	spin_unlock_irq(&mapping->tree_lock);
> +	xa_lock_irq(&mapping->pages);
> +	radix_tree_tag_clear(pages, index, PAGECACHE_TAG_DIRTY);
> +	xa_unlock_irq(&mapping->pages);
>  	trace_dax_writeback_one(mapping->host, index, size >> PAGE_SHIFT);
>   dax_unlock:
>  	dax_read_unlock(id);
> @@ -756,7 +751,7 @@ static int dax_writeback_one(struct block_device *bdev,
>  
>   put_unlocked:
>  	put_unlocked_mapping_entry(mapping, index, entry2);
> -	spin_unlock_irq(&mapping->tree_lock);
> +	xa_unlock_irq(&mapping->pages);
>  	return ret;
>  }
>  
> @@ -1524,21 +1519,21 @@ static int dax_insert_pfn_mkwrite(struct vm_fault *vmf,
>  	pgoff_t index = vmf->pgoff;
>  	int vmf_ret, error;
>  
> -	spin_lock_irq(&mapping->tree_lock);
> +	xa_lock_irq(&mapping->pages);
>  	entry = get_unlocked_mapping_entry(mapping, index, &slot);
>  	/* Did we race with someone splitting entry or so? */
>  	if (!entry ||
>  	    (pe_size == PE_SIZE_PTE && !dax_is_pte_entry(entry)) ||
>  	    (pe_size == PE_SIZE_PMD && !dax_is_pmd_entry(entry))) {
>  		put_unlocked_mapping_entry(mapping, index, entry);
> -		spin_unlock_irq(&mapping->tree_lock);
> +		xa_unlock_irq(&mapping->pages);
>  		trace_dax_insert_pfn_mkwrite_no_entry(mapping->host, vmf,
>  						      VM_FAULT_NOPAGE);
>  		return VM_FAULT_NOPAGE;
>  	}
> -	radix_tree_tag_set(&mapping->page_tree, index, PAGECACHE_TAG_DIRTY);
> +	radix_tree_tag_set(&mapping->pages, index, PAGECACHE_TAG_DIRTY);
>  	entry = lock_slot(mapping, slot);
> -	spin_unlock_irq(&mapping->tree_lock);
> +	xa_unlock_irq(&mapping->pages);
>  	switch (pe_size) {
>  	case PE_SIZE_PTE:
>  		error = vm_insert_mixed_mkwrite(vmf->vma, vmf->address, pfn);
> diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
> index 7578ed1a85e0..4eee39befc67 100644
> --- a/fs/f2fs/data.c
> +++ b/fs/f2fs/data.c
> @@ -2381,12 +2381,12 @@ void f2fs_set_page_dirty_nobuffers(struct page *page)
>  	SetPageDirty(page);
>  	spin_unlock(&mapping->private_lock);
>  
> -	spin_lock_irqsave(&mapping->tree_lock, flags);
> +	xa_lock_irqsave(&mapping->pages, flags);
>  	WARN_ON_ONCE(!PageUptodate(page));
>  	account_page_dirtied(page, mapping);
> -	radix_tree_tag_set(&mapping->page_tree,
> +	radix_tree_tag_set(&mapping->pages,
>  			page_index(page), PAGECACHE_TAG_DIRTY);
> -	spin_unlock_irqrestore(&mapping->tree_lock, flags);
> +	xa_unlock_irqrestore(&mapping->pages, flags);
>  	unlock_page_memcg(page);
>  
>  	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
> diff --git a/fs/f2fs/dir.c b/fs/f2fs/dir.c
> index f00b5ed8c011..0fd9695eddf6 100644
> --- a/fs/f2fs/dir.c
> +++ b/fs/f2fs/dir.c
> @@ -741,10 +741,10 @@ void f2fs_delete_entry(struct f2fs_dir_entry *dentry, struct page *page,
>  
>  	if (bit_pos == NR_DENTRY_IN_BLOCK &&
>  			!truncate_hole(dir, page->index, page->index + 1)) {
> -		spin_lock_irqsave(&mapping->tree_lock, flags);
> -		radix_tree_tag_clear(&mapping->page_tree, page_index(page),
> +		xa_lock_irqsave(&mapping->pages, flags);
> +		radix_tree_tag_clear(&mapping->pages, page_index(page),
>  				     PAGECACHE_TAG_DIRTY);
> -		spin_unlock_irqrestore(&mapping->tree_lock, flags);
> +		xa_unlock_irqrestore(&mapping->pages, flags);
>  
>  		clear_page_dirty_for_io(page);
>  		ClearPagePrivate(page);
> diff --git a/fs/f2fs/inline.c b/fs/f2fs/inline.c
> index 90e38d8ea688..7858b8e15f33 100644
> --- a/fs/f2fs/inline.c
> +++ b/fs/f2fs/inline.c
> @@ -226,10 +226,10 @@ int f2fs_write_inline_data(struct inode *inode, struct page *page)
>  	kunmap_atomic(src_addr);
>  	set_page_dirty(dn.inode_page);
>  
> -	spin_lock_irqsave(&mapping->tree_lock, flags);
> -	radix_tree_tag_clear(&mapping->page_tree, page_index(page),
> +	xa_lock_irqsave(&mapping->pages, flags);
> +	radix_tree_tag_clear(&mapping->pages, page_index(page),
>  			     PAGECACHE_TAG_DIRTY);
> -	spin_unlock_irqrestore(&mapping->tree_lock, flags);
> +	xa_unlock_irqrestore(&mapping->pages, flags);
>  
>  	set_inode_flag(inode, FI_APPEND_WRITE);
>  	set_inode_flag(inode, FI_DATA_EXIST);
> diff --git a/fs/f2fs/node.c b/fs/f2fs/node.c
> index 177c438e4a56..fba2644abdf0 100644
> --- a/fs/f2fs/node.c
> +++ b/fs/f2fs/node.c
> @@ -91,11 +91,11 @@ static void clear_node_page_dirty(struct page *page)
>  	unsigned int long flags;
>  
>  	if (PageDirty(page)) {
> -		spin_lock_irqsave(&mapping->tree_lock, flags);
> -		radix_tree_tag_clear(&mapping->page_tree,
> +		xa_lock_irqsave(&mapping->pages, flags);
> +		radix_tree_tag_clear(&mapping->pages,
>  				page_index(page),
>  				PAGECACHE_TAG_DIRTY);
> -		spin_unlock_irqrestore(&mapping->tree_lock, flags);
> +		xa_unlock_irqrestore(&mapping->pages, flags);
>  
>  		clear_page_dirty_for_io(page);
>  		dec_page_count(F2FS_M_SB(mapping), F2FS_DIRTY_NODES);
> @@ -1140,7 +1140,7 @@ void ra_node_page(struct f2fs_sb_info *sbi, nid_t nid)
>  	f2fs_bug_on(sbi, check_nid_range(sbi, nid));
>  
>  	rcu_read_lock();
> -	apage = radix_tree_lookup(&NODE_MAPPING(sbi)->page_tree, nid);
> +	apage = radix_tree_lookup(&NODE_MAPPING(sbi)->pages, nid);
>  	rcu_read_unlock();
>  	if (apage)
>  		return;
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index d4d04fee568a..d5c0e70dbfa8 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -347,9 +347,9 @@ static void inode_switch_wbs_work_fn(struct work_struct *work)
>  	 * By the time control reaches here, RCU grace period has passed
>  	 * since I_WB_SWITCH assertion and all wb stat update transactions
>  	 * between unlocked_inode_to_wb_begin/end() are guaranteed to be
> -	 * synchronizing against mapping->tree_lock.
> +	 * synchronizing against xa_lock.
>  	 *
> -	 * Grabbing old_wb->list_lock, inode->i_lock and mapping->tree_lock
> +	 * Grabbing old_wb->list_lock, inode->i_lock and xa_lock
>  	 * gives us exclusion against all wb related operations on @inode
>  	 * including IO list manipulations and stat updates.
>  	 */
> @@ -361,7 +361,7 @@ static void inode_switch_wbs_work_fn(struct work_struct *work)
>  		spin_lock_nested(&old_wb->list_lock, SINGLE_DEPTH_NESTING);
>  	}
>  	spin_lock(&inode->i_lock);
> -	spin_lock_irq(&mapping->tree_lock);
> +	xa_lock_irq(&mapping->pages);
>  
>  	/*
>  	 * Once I_FREEING is visible under i_lock, the eviction path owns
> @@ -373,22 +373,22 @@ static void inode_switch_wbs_work_fn(struct work_struct *work)
>  	/*
>  	 * Count and transfer stats.  Note that PAGECACHE_TAG_DIRTY points
>  	 * to possibly dirty pages while PAGECACHE_TAG_WRITEBACK points to
> -	 * pages actually under underwriteback.
> +	 * pages actually under writeback.
>  	 */
> -	radix_tree_for_each_tagged(slot, &mapping->page_tree, &iter, 0,
> +	radix_tree_for_each_tagged(slot, &mapping->pages, &iter, 0,
>  				   PAGECACHE_TAG_DIRTY) {
>  		struct page *page = radix_tree_deref_slot_protected(slot,
> -							&mapping->tree_lock);
> +						&mapping->pages.xa_lock);
>  		if (likely(page) && PageDirty(page)) {
>  			dec_wb_stat(old_wb, WB_RECLAIMABLE);
>  			inc_wb_stat(new_wb, WB_RECLAIMABLE);
>  		}
>  	}
>  
> -	radix_tree_for_each_tagged(slot, &mapping->page_tree, &iter, 0,
> +	radix_tree_for_each_tagged(slot, &mapping->pages, &iter, 0,
>  				   PAGECACHE_TAG_WRITEBACK) {
>  		struct page *page = radix_tree_deref_slot_protected(slot,
> -							&mapping->tree_lock);
> +						&mapping->pages.xa_lock);
>  		if (likely(page)) {
>  			WARN_ON_ONCE(!PageWriteback(page));
>  			dec_wb_stat(old_wb, WB_WRITEBACK);
> @@ -430,7 +430,7 @@ static void inode_switch_wbs_work_fn(struct work_struct *work)
>  	 */
>  	smp_store_release(&inode->i_state, inode->i_state & ~I_WB_SWITCH);
>  
> -	spin_unlock_irq(&mapping->tree_lock);
> +	xa_unlock_irq(&mapping->pages);
>  	spin_unlock(&inode->i_lock);
>  	spin_unlock(&new_wb->list_lock);
>  	spin_unlock(&old_wb->list_lock);
> @@ -507,7 +507,7 @@ static void inode_switch_wbs(struct inode *inode, int new_wb_id)
>  	/*
>  	 * In addition to synchronizing among switchers, I_WB_SWITCH tells
>  	 * the RCU protected stat update paths to grab the mapping's
> -	 * tree_lock so that stat transfer can synchronize against them.
> +	 * xa_lock so that stat transfer can synchronize against them.
>  	 * Let's continue after I_WB_SWITCH is guaranteed to be visible.
>  	 */
>  	call_rcu(&isw->rcu_head, inode_switch_wbs_rcu_fn);
> diff --git a/fs/inode.c b/fs/inode.c
> index ef362364d396..07e26909e24d 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -349,8 +349,7 @@ EXPORT_SYMBOL(inc_nlink);
>  void address_space_init_once(struct address_space *mapping)
>  {
>  	memset(mapping, 0, sizeof(*mapping));
> -	INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC | __GFP_ACCOUNT);
> -	spin_lock_init(&mapping->tree_lock);
> +	INIT_RADIX_TREE(&mapping->pages, GFP_ATOMIC | __GFP_ACCOUNT);
>  	init_rwsem(&mapping->i_mmap_rwsem);
>  	INIT_LIST_HEAD(&mapping->private_list);
>  	spin_lock_init(&mapping->private_lock);
> @@ -499,14 +498,14 @@ EXPORT_SYMBOL(__remove_inode_hash);
>  void clear_inode(struct inode *inode)
>  {
>  	/*
> -	 * We have to cycle tree_lock here because reclaim can be still in the
> +	 * We have to cycle the xa_lock here because reclaim can be in the
>  	 * process of removing the last page (in __delete_from_page_cache())
> -	 * and we must not free mapping under it.
> +	 * and we must not free the mapping under it.
>  	 */
> -	spin_lock_irq(&inode->i_data.tree_lock);
> +	xa_lock_irq(&inode->i_data.pages);
>  	BUG_ON(inode->i_data.nrpages);
>  	BUG_ON(inode->i_data.nrexceptional);
> -	spin_unlock_irq(&inode->i_data.tree_lock);
> +	xa_unlock_irq(&inode->i_data.pages);
>  	BUG_ON(!list_empty(&inode->i_data.private_list));
>  	BUG_ON(!(inode->i_state & I_FREEING));
>  	BUG_ON(inode->i_state & I_CLEAR);
> diff --git a/fs/nilfs2/btnode.c b/fs/nilfs2/btnode.c
> index c21e0b4454a6..9e2a00207436 100644
> --- a/fs/nilfs2/btnode.c
> +++ b/fs/nilfs2/btnode.c
> @@ -193,9 +193,9 @@ int nilfs_btnode_prepare_change_key(struct address_space *btnc,
>  				       (unsigned long long)oldkey,
>  				       (unsigned long long)newkey);
>  
> -		spin_lock_irq(&btnc->tree_lock);
> -		err = radix_tree_insert(&btnc->page_tree, newkey, obh->b_page);
> -		spin_unlock_irq(&btnc->tree_lock);
> +		xa_lock_irq(&btnc->pages);
> +		err = radix_tree_insert(&btnc->pages, newkey, obh->b_page);
> +		xa_unlock_irq(&btnc->pages);
>  		/*
>  		 * Note: page->index will not change to newkey until
>  		 * nilfs_btnode_commit_change_key() will be called.
> @@ -251,11 +251,11 @@ void nilfs_btnode_commit_change_key(struct address_space *btnc,
>  				       (unsigned long long)newkey);
>  		mark_buffer_dirty(obh);
>  
> -		spin_lock_irq(&btnc->tree_lock);
> -		radix_tree_delete(&btnc->page_tree, oldkey);
> -		radix_tree_tag_set(&btnc->page_tree, newkey,
> +		xa_lock_irq(&btnc->pages);
> +		radix_tree_delete(&btnc->pages, oldkey);
> +		radix_tree_tag_set(&btnc->pages, newkey,
>  				   PAGECACHE_TAG_DIRTY);
> -		spin_unlock_irq(&btnc->tree_lock);
> +		xa_unlock_irq(&btnc->pages);
>  
>  		opage->index = obh->b_blocknr = newkey;
>  		unlock_page(opage);
> @@ -283,9 +283,9 @@ void nilfs_btnode_abort_change_key(struct address_space *btnc,
>  		return;
>  
>  	if (nbh == NULL) {	/* blocksize == pagesize */
> -		spin_lock_irq(&btnc->tree_lock);
> -		radix_tree_delete(&btnc->page_tree, newkey);
> -		spin_unlock_irq(&btnc->tree_lock);
> +		xa_lock_irq(&btnc->pages);
> +		radix_tree_delete(&btnc->pages, newkey);
> +		xa_unlock_irq(&btnc->pages);
>  		unlock_page(ctxt->bh->b_page);
>  	} else
>  		brelse(nbh);
> diff --git a/fs/nilfs2/page.c b/fs/nilfs2/page.c
> index 68241512d7c1..1c6703efde9e 100644
> --- a/fs/nilfs2/page.c
> +++ b/fs/nilfs2/page.c
> @@ -331,15 +331,15 @@ void nilfs_copy_back_pages(struct address_space *dmap,
>  			struct page *page2;
>  
>  			/* move the page to the destination cache */
> -			spin_lock_irq(&smap->tree_lock);
> -			page2 = radix_tree_delete(&smap->page_tree, offset);
> +			xa_lock_irq(&smap->pages);
> +			page2 = radix_tree_delete(&smap->pages, offset);
>  			WARN_ON(page2 != page);
>  
>  			smap->nrpages--;
> -			spin_unlock_irq(&smap->tree_lock);
> +			xa_unlock_irq(&smap->pages);
>  
> -			spin_lock_irq(&dmap->tree_lock);
> -			err = radix_tree_insert(&dmap->page_tree, offset, page);
> +			xa_lock_irq(&dmap->pages);
> +			err = radix_tree_insert(&dmap->pages, offset, page);
>  			if (unlikely(err < 0)) {
>  				WARN_ON(err == -EEXIST);
>  				page->mapping = NULL;
> @@ -348,11 +348,11 @@ void nilfs_copy_back_pages(struct address_space *dmap,
>  				page->mapping = dmap;
>  				dmap->nrpages++;
>  				if (PageDirty(page))
> -					radix_tree_tag_set(&dmap->page_tree,
> +					radix_tree_tag_set(&dmap->pages,
>  							   offset,
>  							   PAGECACHE_TAG_DIRTY);
>  			}
> -			spin_unlock_irq(&dmap->tree_lock);
> +			xa_unlock_irq(&dmap->pages);
>  		}
>  		unlock_page(page);
>  	}
> @@ -474,15 +474,15 @@ int __nilfs_clear_page_dirty(struct page *page)
>  	struct address_space *mapping = page->mapping;
>  
>  	if (mapping) {
> -		spin_lock_irq(&mapping->tree_lock);
> +		xa_lock_irq(&mapping->pages);
>  		if (test_bit(PG_dirty, &page->flags)) {
> -			radix_tree_tag_clear(&mapping->page_tree,
> +			radix_tree_tag_clear(&mapping->pages,
>  					     page_index(page),
>  					     PAGECACHE_TAG_DIRTY);
> -			spin_unlock_irq(&mapping->tree_lock);
> +			xa_unlock_irq(&mapping->pages);
>  			return clear_page_dirty_for_io(page);
>  		}
> -		spin_unlock_irq(&mapping->tree_lock);
> +		xa_unlock_irq(&mapping->pages);
>  		return 0;
>  	}
>  	return TestClearPageDirty(page);
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index 3e4ce54d84ab..3df0d20e23f3 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -329,7 +329,7 @@ static inline bool inode_to_wb_is_valid(struct inode *inode)
>   * @inode: inode of interest
>   *
>   * Returns the wb @inode is currently associated with.  The caller must be
> - * holding either @inode->i_lock, @inode->i_mapping->tree_lock, or the
> + * holding either @inode->i_lock, @inode->i_mapping->pages.xa_lock, or the
>   * associated wb's list_lock.
>   */
>  static inline struct bdi_writeback *inode_to_wb(const struct inode *inode)
> @@ -337,7 +337,7 @@ static inline struct bdi_writeback *inode_to_wb(const struct inode *inode)
>  #ifdef CONFIG_LOCKDEP
>  	WARN_ON_ONCE(debug_locks &&
>  		     (!lockdep_is_held(&inode->i_lock) &&
> -		      !lockdep_is_held(&inode->i_mapping->tree_lock) &&
> +		      !lockdep_is_held(&inode->i_mapping->pages.xa_lock) &&
>  		      !lockdep_is_held(&inode->i_wb->list_lock)));
>  #endif
>  	return inode->i_wb;
> @@ -349,7 +349,7 @@ static inline struct bdi_writeback *inode_to_wb(const struct inode *inode)
>   * @lockedp: temp bool output param, to be passed to the end function
>   *
>   * The caller wants to access the wb associated with @inode but isn't
> - * holding inode->i_lock, mapping->tree_lock or wb->list_lock.  This
> + * holding inode->i_lock, mapping->pages.xa_lock or wb->list_lock.  This
>   * function determines the wb associated with @inode and ensures that the
>   * association doesn't change until the transaction is finished with
>   * unlocked_inode_to_wb_end().
> @@ -370,10 +370,10 @@ unlocked_inode_to_wb_begin(struct inode *inode, bool *lockedp)
>  	*lockedp = smp_load_acquire(&inode->i_state) & I_WB_SWITCH;
>  
>  	if (unlikely(*lockedp))
> -		spin_lock_irq(&inode->i_mapping->tree_lock);
> +		xa_lock_irq(&inode->i_mapping->pages);
>  
>  	/*
> -	 * Protected by either !I_WB_SWITCH + rcu_read_lock() or tree_lock.
> +	 * Protected by either !I_WB_SWITCH + rcu_read_lock() or xa_lock.
>  	 * inode_to_wb() will bark.  Deref directly.
>  	 */
>  	return inode->i_wb;
> @@ -387,7 +387,7 @@ unlocked_inode_to_wb_begin(struct inode *inode, bool *lockedp)
>  static inline void unlocked_inode_to_wb_end(struct inode *inode, bool locked)
>  {
>  	if (unlikely(locked))
> -		spin_unlock_irq(&inode->i_mapping->tree_lock);
> +		xa_unlock_irq(&inode->i_mapping->pages);
>  
>  	rcu_read_unlock();
>  }
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 2a815560fda0..e227f68e0418 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -13,6 +13,7 @@
>  #include <linux/list_lru.h>
>  #include <linux/llist.h>
>  #include <linux/radix-tree.h>
> +#include <linux/xarray.h>
>  #include <linux/rbtree.h>
>  #include <linux/init.h>
>  #include <linux/pid.h>
> @@ -390,23 +391,21 @@ int pagecache_write_end(struct file *, struct address_space *mapping,
>  
>  struct address_space {
>  	struct inode		*host;		/* owner: inode, block_device */
> -	struct radix_tree_root	page_tree;	/* radix tree of all pages */
> -	spinlock_t		tree_lock;	/* and lock protecting it */
> +	struct radix_tree_root	pages;		/* cached pages */
> +	gfp_t			gfp_mask;	/* for allocating pages */
>  	atomic_t		i_mmap_writable;/* count VM_SHARED mappings */
>  	struct rb_root_cached	i_mmap;		/* tree of private and shared mappings */
>  	struct rw_semaphore	i_mmap_rwsem;	/* protect tree, count, list */
> -	/* Protected by tree_lock together with the radix tree */
> +	/* Protected by pages.xa_lock */
>  	unsigned long		nrpages;	/* number of total pages */
> -	/* number of shadow or DAX exceptional entries */
> -	unsigned long		nrexceptional;
> +	unsigned long		nrexceptional;	/* shadow or DAX entries */
>  	pgoff_t			writeback_index;/* writeback starts here */
>  	const struct address_space_operations *a_ops;	/* methods */
>  	unsigned long		flags;		/* error bits */
> +	errseq_t		wb_err;
>  	spinlock_t		private_lock;	/* for use by the address_space */
> -	gfp_t			gfp_mask;	/* implicit gfp mask for allocations */
> -	struct list_head	private_list;	/* for use by the address_space */
> +	struct list_head	private_list;	/* ditto */
>  	void			*private_data;	/* ditto */
> -	errseq_t		wb_err;
>  } __attribute__((aligned(sizeof(long)))) __randomize_layout;
>  	/*
>  	 * On most architectures that alignment is already the case; but
> @@ -1986,7 +1985,7 @@ static inline void init_sync_kiocb(struct kiocb *kiocb, struct file *filp)
>   *
>   * I_WB_SWITCH		Cgroup bdi_writeback switching in progress.  Used to
>   *			synchronize competing switching instances and to tell
> - *			wb stat updates to grab mapping->tree_lock.  See
> + *			wb stat updates to grab mapping->pages.xa_lock.  See
>   *			inode_switch_wb_work_fn() for details.
>   *
>   * I_OVL_INUSE		Used by overlayfs to get exclusive ownership on upper
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 47b0fb0a6e41..aad22344d685 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -738,7 +738,7 @@ int finish_mkwrite_fault(struct vm_fault *vmf);
>   * refcount. The each user mapping also has a reference to the page.
>   *
>   * The pagecache pages are stored in a per-mapping radix tree, which is
> - * rooted at mapping->page_tree, and indexed by offset.
> + * rooted at mapping->pages, and indexed by offset.
>   * Where 2.4 and early 2.6 kernels kept dirty/clean pages in per-address_space
>   * lists, we instead now tag pages as dirty/writeback in the radix tree.
>   *
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 34ce3ebf97d5..80a6149152d4 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -144,7 +144,7 @@ void release_pages(struct page **pages, int nr);
>   * 3. check the page is still in pagecache (if no, goto 1)
>   *
>   * Remove-side that cares about stability of _refcount (eg. reclaim) has the
> - * following (with tree_lock held for write):
> + * following (with pages.xa_lock held):
>   * A. atomically check refcount is correct and set it to 0 (atomic_cmpxchg)
>   * B. remove page from pagecache
>   * C. free the page
> @@ -157,7 +157,7 @@ void release_pages(struct page **pages, int nr);
>   *
>   * It is possible that between 1 and 2, the page is removed then the exact same
>   * page is inserted into the same position in pagecache. That's OK: the
> - * old find_get_page using tree_lock could equally have run before or after
> + * old find_get_page using a lock could equally have run before or after
>   * such a re-insertion, depending on order that locks are granted.
>   *
>   * Lookups racing against pagecache insertion isn't a big problem: either 1
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 693f62212a59..7588b7f1f479 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -66,7 +66,7 @@
>   *  ->i_mmap_rwsem		(truncate_pagecache)
>   *    ->private_lock		(__free_pte->__set_page_dirty_buffers)
>   *      ->swap_lock		(exclusive_swap_page, others)
> - *        ->mapping->tree_lock
> + *        ->mapping->pages.xa_lock
>   *
>   *  ->i_mutex
>   *    ->i_mmap_rwsem		(truncate->unmap_mapping_range)
> @@ -74,7 +74,7 @@
>   *  ->mmap_sem
>   *    ->i_mmap_rwsem
>   *      ->page_table_lock or pte_lock	(various, mainly in memory.c)
> - *        ->mapping->tree_lock	(arch-dependent flush_dcache_mmap_lock)
> + *        ->mapping->pages.xa_lock	(arch-dependent flush_dcache_mmap_lock)
>   *
>   *  ->mmap_sem
>   *    ->lock_page		(access_process_vm)
> @@ -84,7 +84,7 @@
>   *
>   *  bdi->wb.list_lock
>   *    sb_lock			(fs/fs-writeback.c)
> - *    ->mapping->tree_lock	(__sync_single_inode)
> + *    ->mapping->pages.xa_lock	(__sync_single_inode)
>   *
>   *  ->i_mmap_rwsem
>   *    ->anon_vma.lock		(vma_adjust)
> @@ -95,11 +95,11 @@
>   *  ->page_table_lock or pte_lock
>   *    ->swap_lock		(try_to_unmap_one)
>   *    ->private_lock		(try_to_unmap_one)
> - *    ->tree_lock		(try_to_unmap_one)
> + *    ->pages.xa_lock		(try_to_unmap_one)
>   *    ->zone_lru_lock(zone)	(follow_page->mark_page_accessed)
>   *    ->zone_lru_lock(zone)	(check_pte_range->isolate_lru_page)
>   *    ->private_lock		(page_remove_rmap->set_page_dirty)
> - *    ->tree_lock		(page_remove_rmap->set_page_dirty)
> + *    ->pages.xa_lock		(page_remove_rmap->set_page_dirty)
>   *    bdi.wb->list_lock		(page_remove_rmap->set_page_dirty)
>   *    ->inode->i_lock		(page_remove_rmap->set_page_dirty)
>   *    ->memcg->move_lock	(page_remove_rmap->lock_page_memcg)
> @@ -118,14 +118,15 @@ static int page_cache_tree_insert(struct address_space *mapping,
>  	void **slot;
>  	int error;
>  
> -	error = __radix_tree_create(&mapping->page_tree, page->index, 0,
> +	error = __radix_tree_create(&mapping->pages, page->index, 0,
>  				    &node, &slot);
>  	if (error)
>  		return error;
>  	if (*slot) {
>  		void *p;
>  
> -		p = radix_tree_deref_slot_protected(slot, &mapping->tree_lock);
> +		p = radix_tree_deref_slot_protected(slot,
> +						    &mapping->pages.xa_lock);
>  		if (!radix_tree_exceptional_entry(p))
>  			return -EEXIST;
>  
> @@ -133,7 +134,7 @@ static int page_cache_tree_insert(struct address_space *mapping,
>  		if (shadowp)
>  			*shadowp = p;
>  	}
> -	__radix_tree_replace(&mapping->page_tree, node, slot, page,
> +	__radix_tree_replace(&mapping->pages, node, slot, page,
>  			     workingset_lookup_update(mapping));
>  	mapping->nrpages++;
>  	return 0;
> @@ -155,13 +156,13 @@ static void page_cache_tree_delete(struct address_space *mapping,
>  		struct radix_tree_node *node;
>  		void **slot;
>  
> -		__radix_tree_lookup(&mapping->page_tree, page->index + i,
> +		__radix_tree_lookup(&mapping->pages, page->index + i,
>  				    &node, &slot);
>  
>  		VM_BUG_ON_PAGE(!node && nr != 1, page);
>  
> -		radix_tree_clear_tags(&mapping->page_tree, node, slot);
> -		__radix_tree_replace(&mapping->page_tree, node, slot, shadow,
> +		radix_tree_clear_tags(&mapping->pages, node, slot);
> +		__radix_tree_replace(&mapping->pages, node, slot, shadow,
>  				workingset_lookup_update(mapping));
>  	}
>  
> @@ -253,7 +254,7 @@ static void unaccount_page_cache_page(struct address_space *mapping,
>  /*
>   * Delete a page from the page cache and free it. Caller has to make
>   * sure the page is locked and that nobody else uses it - or that usage
> - * is safe.  The caller must hold the mapping's tree_lock.
> + * is safe.  The caller must hold the xa_lock.
>   */
>  void __delete_from_page_cache(struct page *page, void *shadow)
>  {
> @@ -296,9 +297,9 @@ void delete_from_page_cache(struct page *page)
>  	unsigned long flags;
>  
>  	BUG_ON(!PageLocked(page));
> -	spin_lock_irqsave(&mapping->tree_lock, flags);
> +	xa_lock_irqsave(&mapping->pages, flags);
>  	__delete_from_page_cache(page, NULL);
> -	spin_unlock_irqrestore(&mapping->tree_lock, flags);
> +	xa_unlock_irqrestore(&mapping->pages, flags);
>  
>  	page_cache_free_page(mapping, page);
>  }
> @@ -309,14 +310,14 @@ EXPORT_SYMBOL(delete_from_page_cache);
>   * @mapping: the mapping to which pages belong
>   * @pvec: pagevec with pages to delete
>   *
> - * The function walks over mapping->page_tree and removes pages passed in @pvec
> - * from the radix tree. The function expects @pvec to be sorted by page index.
> - * It tolerates holes in @pvec (radix tree entries at those indices are not
> + * The function walks over mapping->pages and removes pages passed in @pvec
> + * from the mapping. The function expects @pvec to be sorted by page index.
> + * It tolerates holes in @pvec (mapping entries at those indices are not
>   * modified). The function expects only THP head pages to be present in the
> - * @pvec and takes care to delete all corresponding tail pages from the radix
> - * tree as well.
> + * @pvec and takes care to delete all corresponding tail pages from the
> + * mapping as well.
>   *
> - * The function expects mapping->tree_lock to be held.
> + * The function expects xa_lock to be held.
>   */
>  static void
>  page_cache_tree_delete_batch(struct address_space *mapping,
> @@ -330,11 +331,11 @@ page_cache_tree_delete_batch(struct address_space *mapping,
>  	pgoff_t start;
>  
>  	start = pvec->pages[0]->index;
> -	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
> +	radix_tree_for_each_slot(slot, &mapping->pages, &iter, start) {
>  		if (i >= pagevec_count(pvec) && !tail_pages)
>  			break;
>  		page = radix_tree_deref_slot_protected(slot,
> -						       &mapping->tree_lock);
> +						       &mapping->pages.xa_lock);
>  		if (radix_tree_exceptional_entry(page))
>  			continue;
>  		if (!tail_pages) {
> @@ -357,8 +358,8 @@ page_cache_tree_delete_batch(struct address_space *mapping,
>  		} else {
>  			tail_pages--;
>  		}
> -		radix_tree_clear_tags(&mapping->page_tree, iter.node, slot);
> -		__radix_tree_replace(&mapping->page_tree, iter.node, slot, NULL,
> +		radix_tree_clear_tags(&mapping->pages, iter.node, slot);
> +		__radix_tree_replace(&mapping->pages, iter.node, slot, NULL,
>  				workingset_lookup_update(mapping));
>  		total_pages++;
>  	}
> @@ -374,14 +375,14 @@ void delete_from_page_cache_batch(struct address_space *mapping,
>  	if (!pagevec_count(pvec))
>  		return;
>  
> -	spin_lock_irqsave(&mapping->tree_lock, flags);
> +	xa_lock_irqsave(&mapping->pages, flags);
>  	for (i = 0; i < pagevec_count(pvec); i++) {
>  		trace_mm_filemap_delete_from_page_cache(pvec->pages[i]);
>  
>  		unaccount_page_cache_page(mapping, pvec->pages[i]);
>  	}
>  	page_cache_tree_delete_batch(mapping, pvec);
> -	spin_unlock_irqrestore(&mapping->tree_lock, flags);
> +	xa_unlock_irqrestore(&mapping->pages, flags);
>  
>  	for (i = 0; i < pagevec_count(pvec); i++)
>  		page_cache_free_page(mapping, pvec->pages[i]);
> @@ -798,7 +799,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
>  		new->mapping = mapping;
>  		new->index = offset;
>  
> -		spin_lock_irqsave(&mapping->tree_lock, flags);
> +		xa_lock_irqsave(&mapping->pages, flags);
>  		__delete_from_page_cache(old, NULL);
>  		error = page_cache_tree_insert(mapping, new, NULL);
>  		BUG_ON(error);
> @@ -810,7 +811,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
>  			__inc_node_page_state(new, NR_FILE_PAGES);
>  		if (PageSwapBacked(new))
>  			__inc_node_page_state(new, NR_SHMEM);
> -		spin_unlock_irqrestore(&mapping->tree_lock, flags);
> +		xa_unlock_irqrestore(&mapping->pages, flags);
>  		mem_cgroup_migrate(old, new);
>  		radix_tree_preload_end();
>  		if (freepage)
> @@ -852,7 +853,7 @@ static int __add_to_page_cache_locked(struct page *page,
>  	page->mapping = mapping;
>  	page->index = offset;
>  
> -	spin_lock_irq(&mapping->tree_lock);
> +	xa_lock_irq(&mapping->pages);
>  	error = page_cache_tree_insert(mapping, page, shadowp);
>  	radix_tree_preload_end();
>  	if (unlikely(error))
> @@ -861,7 +862,7 @@ static int __add_to_page_cache_locked(struct page *page,
>  	/* hugetlb pages do not participate in page cache accounting. */
>  	if (!huge)
>  		__inc_node_page_state(page, NR_FILE_PAGES);
> -	spin_unlock_irq(&mapping->tree_lock);
> +	xa_unlock_irq(&mapping->pages);
>  	if (!huge)
>  		mem_cgroup_commit_charge(page, memcg, false, false);
>  	trace_mm_filemap_add_to_page_cache(page);
> @@ -869,7 +870,7 @@ static int __add_to_page_cache_locked(struct page *page,
>  err_insert:
>  	page->mapping = NULL;
>  	/* Leave page->index set: truncation relies upon it */
> -	spin_unlock_irq(&mapping->tree_lock);
> +	xa_unlock_irq(&mapping->pages);
>  	if (!huge)
>  		mem_cgroup_cancel_charge(page, memcg, false);
>  	put_page(page);
> @@ -1353,7 +1354,7 @@ pgoff_t page_cache_next_hole(struct address_space *mapping,
>  	for (i = 0; i < max_scan; i++) {
>  		struct page *page;
>  
> -		page = radix_tree_lookup(&mapping->page_tree, index);
> +		page = radix_tree_lookup(&mapping->pages, index);
>  		if (!page || radix_tree_exceptional_entry(page))
>  			break;
>  		index++;
> @@ -1394,7 +1395,7 @@ pgoff_t page_cache_prev_hole(struct address_space *mapping,
>  	for (i = 0; i < max_scan; i++) {
>  		struct page *page;
>  
> -		page = radix_tree_lookup(&mapping->page_tree, index);
> +		page = radix_tree_lookup(&mapping->pages, index);
>  		if (!page || radix_tree_exceptional_entry(page))
>  			break;
>  		index--;
> @@ -1427,7 +1428,7 @@ struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
>  	rcu_read_lock();
>  repeat:
>  	page = NULL;
> -	pagep = radix_tree_lookup_slot(&mapping->page_tree, offset);
> +	pagep = radix_tree_lookup_slot(&mapping->pages, offset);
>  	if (pagep) {
>  		page = radix_tree_deref_slot(pagep);
>  		if (unlikely(!page))
> @@ -1633,7 +1634,7 @@ unsigned find_get_entries(struct address_space *mapping,
>  		return 0;
>  
>  	rcu_read_lock();
> -	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
> +	radix_tree_for_each_slot(slot, &mapping->pages, &iter, start) {
>  		struct page *head, *page;
>  repeat:
>  		page = radix_tree_deref_slot(slot);
> @@ -1710,7 +1711,7 @@ unsigned find_get_pages_range(struct address_space *mapping, pgoff_t *start,
>  		return 0;
>  
>  	rcu_read_lock();
> -	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, *start) {
> +	radix_tree_for_each_slot(slot, &mapping->pages, &iter, *start) {
>  		struct page *head, *page;
>  
>  		if (iter.index > end)
> @@ -1795,7 +1796,7 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
>  		return 0;
>  
>  	rcu_read_lock();
> -	radix_tree_for_each_contig(slot, &mapping->page_tree, &iter, index) {
> +	radix_tree_for_each_contig(slot, &mapping->pages, &iter, index) {
>  		struct page *head, *page;
>  repeat:
>  		page = radix_tree_deref_slot(slot);
> @@ -1875,8 +1876,7 @@ unsigned find_get_pages_range_tag(struct address_space *mapping, pgoff_t *index,
>  		return 0;
>  
>  	rcu_read_lock();
> -	radix_tree_for_each_tagged(slot, &mapping->page_tree,
> -				   &iter, *index, tag) {
> +	radix_tree_for_each_tagged(slot, &mapping->pages, &iter, *index, tag) {
>  		struct page *head, *page;
>  
>  		if (iter.index > end)
> @@ -1969,8 +1969,7 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
>  		return 0;
>  
>  	rcu_read_lock();
> -	radix_tree_for_each_tagged(slot, &mapping->page_tree,
> -				   &iter, start, tag) {
> +	radix_tree_for_each_tagged(slot, &mapping->pages, &iter, start, tag) {
>  		struct page *head, *page;
>  repeat:
>  		page = radix_tree_deref_slot(slot);
> @@ -2624,8 +2623,7 @@ void filemap_map_pages(struct vm_fault *vmf,
>  	struct page *head, *page;
>  
>  	rcu_read_lock();
> -	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter,
> -			start_pgoff) {
> +	radix_tree_for_each_slot(slot, &mapping->pages, &iter, start_pgoff) {
>  		if (iter.index > end_pgoff)
>  			break;
>  repeat:
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 87ab9b8f56b5..4b60f55f1f8b 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2450,7 +2450,7 @@ static void __split_huge_page(struct page *page, struct list_head *list,
>  	} else {
>  		/* Additional pin to radix tree */
>  		page_ref_add(head, 2);
> -		spin_unlock(&head->mapping->tree_lock);
> +		xa_unlock(&head->mapping->pages);
>  	}
>  
>  	spin_unlock_irqrestore(zone_lru_lock(page_zone(head)), flags);
> @@ -2658,15 +2658,15 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  	if (mapping) {
>  		void **pslot;
>  
> -		spin_lock(&mapping->tree_lock);
> -		pslot = radix_tree_lookup_slot(&mapping->page_tree,
> +		xa_lock(&mapping->pages);
> +		pslot = radix_tree_lookup_slot(&mapping->pages,
>  				page_index(head));
>  		/*
>  		 * Check if the head page is present in radix tree.
>  		 * We assume all tail are present too, if head is there.
>  		 */
>  		if (radix_tree_deref_slot_protected(pslot,
> -					&mapping->tree_lock) != head)
> +					&mapping->pages.xa_lock) != head)
>  			goto fail;
>  	}
>  
> @@ -2700,7 +2700,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  		}
>  		spin_unlock(&pgdata->split_queue_lock);
>  fail:		if (mapping)
> -			spin_unlock(&mapping->tree_lock);
> +			xa_unlock(&mapping->pages);
>  		spin_unlock_irqrestore(zone_lru_lock(page_zone(head)), flags);
>  		unfreeze_page(head);
>  		ret = -EBUSY;
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index b7e2268dfc9a..5800093fe94a 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1339,8 +1339,8 @@ static void collapse_shmem(struct mm_struct *mm,
>  	 */
>  
>  	index = start;
> -	spin_lock_irq(&mapping->tree_lock);
> -	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
> +	xa_lock_irq(&mapping->pages);
> +	radix_tree_for_each_slot(slot, &mapping->pages, &iter, start) {
>  		int n = min(iter.index, end) - index;
>  
>  		/*
> @@ -1353,7 +1353,7 @@ static void collapse_shmem(struct mm_struct *mm,
>  		}
>  		nr_none += n;
>  		for (; index < min(iter.index, end); index++) {
> -			radix_tree_insert(&mapping->page_tree, index,
> +			radix_tree_insert(&mapping->pages, index,
>  					new_page + (index % HPAGE_PMD_NR));
>  		}
>  
> @@ -1362,16 +1362,16 @@ static void collapse_shmem(struct mm_struct *mm,
>  			break;
>  
>  		page = radix_tree_deref_slot_protected(slot,
> -				&mapping->tree_lock);
> +				&mapping->pages.xa_lock);
>  		if (radix_tree_exceptional_entry(page) || !PageUptodate(page)) {
> -			spin_unlock_irq(&mapping->tree_lock);
> +			xa_unlock_irq(&mapping->pages);
>  			/* swap in or instantiate fallocated page */
>  			if (shmem_getpage(mapping->host, index, &page,
>  						SGP_NOHUGE)) {
>  				result = SCAN_FAIL;
>  				goto tree_unlocked;
>  			}
> -			spin_lock_irq(&mapping->tree_lock);
> +			xa_lock_irq(&mapping->pages);
>  		} else if (trylock_page(page)) {
>  			get_page(page);
>  		} else {
> @@ -1380,7 +1380,7 @@ static void collapse_shmem(struct mm_struct *mm,
>  		}
>  
>  		/*
> -		 * The page must be locked, so we can drop the tree_lock
> +		 * The page must be locked, so we can drop the xa_lock
>  		 * without racing with truncate.
>  		 */
>  		VM_BUG_ON_PAGE(!PageLocked(page), page);
> @@ -1391,7 +1391,7 @@ static void collapse_shmem(struct mm_struct *mm,
>  			result = SCAN_TRUNCATED;
>  			goto out_unlock;
>  		}
> -		spin_unlock_irq(&mapping->tree_lock);
> +		xa_unlock_irq(&mapping->pages);
>  
>  		if (isolate_lru_page(page)) {
>  			result = SCAN_DEL_PAGE_LRU;
> @@ -1401,11 +1401,11 @@ static void collapse_shmem(struct mm_struct *mm,
>  		if (page_mapped(page))
>  			unmap_mapping_pages(mapping, index, 1, false);
>  
> -		spin_lock_irq(&mapping->tree_lock);
> +		xa_lock_irq(&mapping->pages);
>  
> -		slot = radix_tree_lookup_slot(&mapping->page_tree, index);
> +		slot = radix_tree_lookup_slot(&mapping->pages, index);
>  		VM_BUG_ON_PAGE(page != radix_tree_deref_slot_protected(slot,
> -					&mapping->tree_lock), page);
> +					&mapping->pages.xa_lock), page);
>  		VM_BUG_ON_PAGE(page_mapped(page), page);
>  
>  		/*
> @@ -1426,14 +1426,14 @@ static void collapse_shmem(struct mm_struct *mm,
>  		list_add_tail(&page->lru, &pagelist);
>  
>  		/* Finally, replace with the new page. */
> -		radix_tree_replace_slot(&mapping->page_tree, slot,
> +		radix_tree_replace_slot(&mapping->pages, slot,
>  				new_page + (index % HPAGE_PMD_NR));
>  
>  		slot = radix_tree_iter_resume(slot, &iter);
>  		index++;
>  		continue;
>  out_lru:
> -		spin_unlock_irq(&mapping->tree_lock);
> +		xa_unlock_irq(&mapping->pages);
>  		putback_lru_page(page);
>  out_isolate_failed:
>  		unlock_page(page);
> @@ -1459,14 +1459,14 @@ static void collapse_shmem(struct mm_struct *mm,
>  		}
>  
>  		for (; index < end; index++) {
> -			radix_tree_insert(&mapping->page_tree, index,
> +			radix_tree_insert(&mapping->pages, index,
>  					new_page + (index % HPAGE_PMD_NR));
>  		}
>  		nr_none += n;
>  	}
>  
>  tree_locked:
> -	spin_unlock_irq(&mapping->tree_lock);
> +	xa_unlock_irq(&mapping->pages);
>  tree_unlocked:
>  
>  	if (result == SCAN_SUCCEED) {
> @@ -1515,9 +1515,8 @@ static void collapse_shmem(struct mm_struct *mm,
>  	} else {
>  		/* Something went wrong: rollback changes to the radix-tree */
>  		shmem_uncharge(mapping->host, nr_none);
> -		spin_lock_irq(&mapping->tree_lock);
> -		radix_tree_for_each_slot(slot, &mapping->page_tree, &iter,
> -				start) {
> +		xa_lock_irq(&mapping->pages);
> +		radix_tree_for_each_slot(slot, &mapping->pages, &iter, start) {
>  			if (iter.index >= end)
>  				break;
>  			page = list_first_entry_or_null(&pagelist,
> @@ -1527,8 +1526,7 @@ static void collapse_shmem(struct mm_struct *mm,
>  					break;
>  				nr_none--;
>  				/* Put holes back where they were */
> -				radix_tree_delete(&mapping->page_tree,
> -						  iter.index);
> +				radix_tree_delete(&mapping->pages, iter.index);
>  				continue;
>  			}
>  
> @@ -1537,16 +1535,15 @@ static void collapse_shmem(struct mm_struct *mm,
>  			/* Unfreeze the page. */
>  			list_del(&page->lru);
>  			page_ref_unfreeze(page, 2);
> -			radix_tree_replace_slot(&mapping->page_tree,
> -						slot, page);
> +			radix_tree_replace_slot(&mapping->pages, slot, page);
>  			slot = radix_tree_iter_resume(slot, &iter);
> -			spin_unlock_irq(&mapping->tree_lock);
> +			xa_unlock_irq(&mapping->pages);
>  			putback_lru_page(page);
>  			unlock_page(page);
> -			spin_lock_irq(&mapping->tree_lock);
> +			xa_lock_irq(&mapping->pages);
>  		}
>  		VM_BUG_ON(nr_none);
> -		spin_unlock_irq(&mapping->tree_lock);
> +		xa_unlock_irq(&mapping->pages);
>  
>  		/* Unfreeze new_page, caller would take care about freeing it */
>  		page_ref_unfreeze(new_page, 1);
> @@ -1574,7 +1571,7 @@ static void khugepaged_scan_shmem(struct mm_struct *mm,
>  	swap = 0;
>  	memset(khugepaged_node_load, 0, sizeof(khugepaged_node_load));
>  	rcu_read_lock();
> -	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
> +	radix_tree_for_each_slot(slot, &mapping->pages, &iter, start) {
>  		if (iter.index >= start + HPAGE_PMD_NR)
>  			break;
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 670e99b68aa6..d89cb08ac39b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5967,9 +5967,9 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>  
>  	/*
>  	 * Interrupts should be disabled here because the caller holds the
> -	 * mapping->tree_lock lock which is taken with interrupts-off. It is
> +	 * mapping->pages xa_lock which is taken with interrupts-off. It is
>  	 * important here to have the interrupts disabled because it is the
> -	 * only synchronisation we have for udpating the per-CPU variables.
> +	 * only synchronisation we have for updating the per-CPU variables.
>  	 */
>  	VM_BUG_ON(!irqs_disabled());
>  	mem_cgroup_charge_statistics(memcg, page, PageTransHuge(page),
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 1e5525a25691..184bc1d0e187 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -466,20 +466,21 @@ int migrate_page_move_mapping(struct address_space *mapping,
>  	oldzone = page_zone(page);
>  	newzone = page_zone(newpage);
>  
> -	spin_lock_irq(&mapping->tree_lock);
> +	xa_lock_irq(&mapping->pages);
>  
> -	pslot = radix_tree_lookup_slot(&mapping->page_tree,
> +	pslot = radix_tree_lookup_slot(&mapping->pages,
>   					page_index(page));
>  
>  	expected_count += 1 + page_has_private(page);
>  	if (page_count(page) != expected_count ||
> -		radix_tree_deref_slot_protected(pslot, &mapping->tree_lock) != page) {
> -		spin_unlock_irq(&mapping->tree_lock);
> +		radix_tree_deref_slot_protected(pslot,
> +					&mapping->pages.xa_lock) != page) {
> +		xa_unlock_irq(&mapping->pages);
>  		return -EAGAIN;
>  	}
>  
>  	if (!page_ref_freeze(page, expected_count)) {
> -		spin_unlock_irq(&mapping->tree_lock);
> +		xa_unlock_irq(&mapping->pages);
>  		return -EAGAIN;
>  	}
>  
> @@ -493,7 +494,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
>  	if (mode == MIGRATE_ASYNC && head &&
>  			!buffer_migrate_lock_buffers(head, mode)) {
>  		page_ref_unfreeze(page, expected_count);
> -		spin_unlock_irq(&mapping->tree_lock);
> +		xa_unlock_irq(&mapping->pages);
>  		return -EAGAIN;
>  	}
>  
> @@ -521,7 +522,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
>  		SetPageDirty(newpage);
>  	}
>  
> -	radix_tree_replace_slot(&mapping->page_tree, pslot, newpage);
> +	radix_tree_replace_slot(&mapping->pages, pslot, newpage);
>  
>  	/*
>  	 * Drop cache reference from old page by unfreezing
> @@ -530,7 +531,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
>  	 */
>  	page_ref_unfreeze(page, expected_count - 1);
>  
> -	spin_unlock(&mapping->tree_lock);
> +	xa_unlock(&mapping->pages);
>  	/* Leave irq disabled to prevent preemption while updating stats */
>  
>  	/*
> @@ -573,20 +574,19 @@ int migrate_huge_page_move_mapping(struct address_space *mapping,
>  	int expected_count;
>  	void **pslot;
>  
> -	spin_lock_irq(&mapping->tree_lock);
> +	xa_lock_irq(&mapping->pages);
>  
> -	pslot = radix_tree_lookup_slot(&mapping->page_tree,
> -					page_index(page));
> +	pslot = radix_tree_lookup_slot(&mapping->pages, page_index(page));
>  
>  	expected_count = 2 + page_has_private(page);
>  	if (page_count(page) != expected_count ||
> -		radix_tree_deref_slot_protected(pslot, &mapping->tree_lock) != page) {
> -		spin_unlock_irq(&mapping->tree_lock);
> +		radix_tree_deref_slot_protected(pslot, &mapping->pages.xa_lock) != page) {
> +		xa_unlock_irq(&mapping->pages);
>  		return -EAGAIN;
>  	}
>  
>  	if (!page_ref_freeze(page, expected_count)) {
> -		spin_unlock_irq(&mapping->tree_lock);
> +		xa_unlock_irq(&mapping->pages);
>  		return -EAGAIN;
>  	}
>  
> @@ -595,11 +595,11 @@ int migrate_huge_page_move_mapping(struct address_space *mapping,
>  
>  	get_page(newpage);
>  
> -	radix_tree_replace_slot(&mapping->page_tree, pslot, newpage);
> +	radix_tree_replace_slot(&mapping->pages, pslot, newpage);
>  
>  	page_ref_unfreeze(page, expected_count - 1);
>  
> -	spin_unlock_irq(&mapping->tree_lock);
> +	xa_unlock_irq(&mapping->pages);
>  
>  	return MIGRATEPAGE_SUCCESS;
>  }
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 586f31261c83..588ce729d199 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -2099,7 +2099,7 @@ void __init page_writeback_init(void)
>   * so that it can tag pages faster than a dirtying process can create them).
>   */
>  /*
> - * We tag pages in batches of WRITEBACK_TAG_BATCH to reduce tree_lock latency.
> + * We tag pages in batches of WRITEBACK_TAG_BATCH to reduce xa_lock latency.
>   */
>  void tag_pages_for_writeback(struct address_space *mapping,
>  			     pgoff_t start, pgoff_t end)
> @@ -2109,22 +2109,22 @@ void tag_pages_for_writeback(struct address_space *mapping,
>  	struct radix_tree_iter iter;
>  	void **slot;
>  
> -	spin_lock_irq(&mapping->tree_lock);
> -	radix_tree_for_each_tagged(slot, &mapping->page_tree, &iter, start,
> +	xa_lock_irq(&mapping->pages);
> +	radix_tree_for_each_tagged(slot, &mapping->pages, &iter, start,
>  							PAGECACHE_TAG_DIRTY) {
>  		if (iter.index > end)
>  			break;
> -		radix_tree_iter_tag_set(&mapping->page_tree, &iter,
> +		radix_tree_iter_tag_set(&mapping->pages, &iter,
>  							PAGECACHE_TAG_TOWRITE);
>  		tagged++;
>  		if ((tagged % WRITEBACK_TAG_BATCH) != 0)
>  			continue;
>  		slot = radix_tree_iter_resume(slot, &iter);
> -		spin_unlock_irq(&mapping->tree_lock);
> +		xa_unlock_irq(&mapping->pages);
>  		cond_resched();
> -		spin_lock_irq(&mapping->tree_lock);
> +		xa_lock_irq(&mapping->pages);
>  	}
> -	spin_unlock_irq(&mapping->tree_lock);
> +	xa_unlock_irq(&mapping->pages);
>  }
>  EXPORT_SYMBOL(tag_pages_for_writeback);
>  
> @@ -2467,13 +2467,13 @@ int __set_page_dirty_nobuffers(struct page *page)
>  			return 1;
>  		}
>  
> -		spin_lock_irqsave(&mapping->tree_lock, flags);
> +		xa_lock_irqsave(&mapping->pages, flags);
>  		BUG_ON(page_mapping(page) != mapping);
>  		WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
>  		account_page_dirtied(page, mapping);
> -		radix_tree_tag_set(&mapping->page_tree, page_index(page),
> +		radix_tree_tag_set(&mapping->pages, page_index(page),
>  				   PAGECACHE_TAG_DIRTY);
> -		spin_unlock_irqrestore(&mapping->tree_lock, flags);
> +		xa_unlock_irqrestore(&mapping->pages, flags);
>  		unlock_page_memcg(page);
>  
>  		if (mapping->host) {
> @@ -2718,11 +2718,10 @@ int test_clear_page_writeback(struct page *page)
>  		struct backing_dev_info *bdi = inode_to_bdi(inode);
>  		unsigned long flags;
>  
> -		spin_lock_irqsave(&mapping->tree_lock, flags);
> +		xa_lock_irqsave(&mapping->pages, flags);
>  		ret = TestClearPageWriteback(page);
>  		if (ret) {
> -			radix_tree_tag_clear(&mapping->page_tree,
> -						page_index(page),
> +			radix_tree_tag_clear(&mapping->pages, page_index(page),
>  						PAGECACHE_TAG_WRITEBACK);
>  			if (bdi_cap_account_writeback(bdi)) {
>  				struct bdi_writeback *wb = inode_to_wb(inode);
> @@ -2736,7 +2735,7 @@ int test_clear_page_writeback(struct page *page)
>  						     PAGECACHE_TAG_WRITEBACK))
>  			sb_clear_inode_writeback(mapping->host);
>  
> -		spin_unlock_irqrestore(&mapping->tree_lock, flags);
> +		xa_unlock_irqrestore(&mapping->pages, flags);
>  	} else {
>  		ret = TestClearPageWriteback(page);
>  	}
> @@ -2766,7 +2765,7 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
>  		struct backing_dev_info *bdi = inode_to_bdi(inode);
>  		unsigned long flags;
>  
> -		spin_lock_irqsave(&mapping->tree_lock, flags);
> +		xa_lock_irqsave(&mapping->pages, flags);
>  		ret = TestSetPageWriteback(page);
>  		if (!ret) {
>  			bool on_wblist;
> @@ -2774,8 +2773,7 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
>  			on_wblist = mapping_tagged(mapping,
>  						   PAGECACHE_TAG_WRITEBACK);
>  
> -			radix_tree_tag_set(&mapping->page_tree,
> -						page_index(page),
> +			radix_tree_tag_set(&mapping->pages, page_index(page),
>  						PAGECACHE_TAG_WRITEBACK);
>  			if (bdi_cap_account_writeback(bdi))
>  				inc_wb_stat(inode_to_wb(inode), WB_WRITEBACK);
> @@ -2789,14 +2787,12 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
>  				sb_mark_inode_writeback(mapping->host);
>  		}
>  		if (!PageDirty(page))
> -			radix_tree_tag_clear(&mapping->page_tree,
> -						page_index(page),
> +			radix_tree_tag_clear(&mapping->pages, page_index(page),
>  						PAGECACHE_TAG_DIRTY);
>  		if (!keep_write)
> -			radix_tree_tag_clear(&mapping->page_tree,
> -						page_index(page),
> +			radix_tree_tag_clear(&mapping->pages, page_index(page),
>  						PAGECACHE_TAG_TOWRITE);
> -		spin_unlock_irqrestore(&mapping->tree_lock, flags);
> +		xa_unlock_irqrestore(&mapping->pages, flags);
>  	} else {
>  		ret = TestSetPageWriteback(page);
>  	}
> @@ -2816,7 +2812,7 @@ EXPORT_SYMBOL(__test_set_page_writeback);
>   */
>  int mapping_tagged(struct address_space *mapping, int tag)
>  {
> -	return radix_tree_tagged(&mapping->page_tree, tag);
> +	return radix_tree_tagged(&mapping->pages, tag);
>  }
>  EXPORT_SYMBOL(mapping_tagged);
>  
> diff --git a/mm/readahead.c b/mm/readahead.c
> index c4ca70239233..514188fd2489 100644
> --- a/mm/readahead.c
> +++ b/mm/readahead.c
> @@ -175,7 +175,7 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
>  			break;
>  
>  		rcu_read_lock();
> -		page = radix_tree_lookup(&mapping->page_tree, page_offset);
> +		page = radix_tree_lookup(&mapping->pages, page_offset);
>  		rcu_read_unlock();
>  		if (page && !radix_tree_exceptional_entry(page))
>  			continue;
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 47db27f8049e..87c1ca0cf1a3 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -32,11 +32,11 @@
>   *                 mmlist_lock (in mmput, drain_mmlist and others)
>   *                 mapping->private_lock (in __set_page_dirty_buffers)
>   *                   mem_cgroup_{begin,end}_page_stat (memcg->move_lock)
> - *                     mapping->tree_lock (widely used)
> + *                     mapping->pages.xa_lock (widely used)
>   *                 inode->i_lock (in set_page_dirty's __mark_inode_dirty)
>   *                 bdi.wb->list_lock (in set_page_dirty's __mark_inode_dirty)
>   *                   sb_lock (within inode_lock in fs/fs-writeback.c)
> - *                   mapping->tree_lock (widely used, in set_page_dirty,
> + *                   mapping->pages.xa_lock (widely used, in set_page_dirty,
>   *                             in arch-dependent flush_dcache_mmap_lock,
>   *                             within bdi.wb->list_lock in __sync_single_inode)
>   *
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 1907688b75ee..b2fdc258853d 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -332,12 +332,12 @@ static int shmem_radix_tree_replace(struct address_space *mapping,
>  
>  	VM_BUG_ON(!expected);
>  	VM_BUG_ON(!replacement);
> -	item = __radix_tree_lookup(&mapping->page_tree, index, &node, &pslot);
> +	item = __radix_tree_lookup(&mapping->pages, index, &node, &pslot);
>  	if (!item)
>  		return -ENOENT;
>  	if (item != expected)
>  		return -ENOENT;
> -	__radix_tree_replace(&mapping->page_tree, node, pslot,
> +	__radix_tree_replace(&mapping->pages, node, pslot,
>  			     replacement, NULL);
>  	return 0;
>  }
> @@ -355,7 +355,7 @@ static bool shmem_confirm_swap(struct address_space *mapping,
>  	void *item;
>  
>  	rcu_read_lock();
> -	item = radix_tree_lookup(&mapping->page_tree, index);
> +	item = radix_tree_lookup(&mapping->pages, index);
>  	rcu_read_unlock();
>  	return item == swp_to_radix_entry(swap);
>  }
> @@ -581,14 +581,14 @@ static int shmem_add_to_page_cache(struct page *page,
>  	page->mapping = mapping;
>  	page->index = index;
>  
> -	spin_lock_irq(&mapping->tree_lock);
> +	xa_lock_irq(&mapping->pages);
>  	if (PageTransHuge(page)) {
>  		void __rcu **results;
>  		pgoff_t idx;
>  		int i;
>  
>  		error = 0;
> -		if (radix_tree_gang_lookup_slot(&mapping->page_tree,
> +		if (radix_tree_gang_lookup_slot(&mapping->pages,
>  					&results, &idx, index, 1) &&
>  				idx < index + HPAGE_PMD_NR) {
>  			error = -EEXIST;
> @@ -596,14 +596,14 @@ static int shmem_add_to_page_cache(struct page *page,
>  
>  		if (!error) {
>  			for (i = 0; i < HPAGE_PMD_NR; i++) {
> -				error = radix_tree_insert(&mapping->page_tree,
> +				error = radix_tree_insert(&mapping->pages,
>  						index + i, page + i);
>  				VM_BUG_ON(error);
>  			}
>  			count_vm_event(THP_FILE_ALLOC);
>  		}
>  	} else if (!expected) {
> -		error = radix_tree_insert(&mapping->page_tree, index, page);
> +		error = radix_tree_insert(&mapping->pages, index, page);
>  	} else {
>  		error = shmem_radix_tree_replace(mapping, index, expected,
>  								 page);
> @@ -615,10 +615,10 @@ static int shmem_add_to_page_cache(struct page *page,
>  			__inc_node_page_state(page, NR_SHMEM_THPS);
>  		__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, nr);
>  		__mod_node_page_state(page_pgdat(page), NR_SHMEM, nr);
> -		spin_unlock_irq(&mapping->tree_lock);
> +		xa_unlock_irq(&mapping->pages);
>  	} else {
>  		page->mapping = NULL;
> -		spin_unlock_irq(&mapping->tree_lock);
> +		xa_unlock_irq(&mapping->pages);
>  		page_ref_sub(page, nr);
>  	}
>  	return error;
> @@ -634,13 +634,13 @@ static void shmem_delete_from_page_cache(struct page *page, void *radswap)
>  
>  	VM_BUG_ON_PAGE(PageCompound(page), page);
>  
> -	spin_lock_irq(&mapping->tree_lock);
> +	xa_lock_irq(&mapping->pages);
>  	error = shmem_radix_tree_replace(mapping, page->index, page, radswap);
>  	page->mapping = NULL;
>  	mapping->nrpages--;
>  	__dec_node_page_state(page, NR_FILE_PAGES);
>  	__dec_node_page_state(page, NR_SHMEM);
> -	spin_unlock_irq(&mapping->tree_lock);
> +	xa_unlock_irq(&mapping->pages);
>  	put_page(page);
>  	BUG_ON(error);
>  }
> @@ -653,9 +653,9 @@ static int shmem_free_swap(struct address_space *mapping,
>  {
>  	void *old;
>  
> -	spin_lock_irq(&mapping->tree_lock);
> -	old = radix_tree_delete_item(&mapping->page_tree, index, radswap);
> -	spin_unlock_irq(&mapping->tree_lock);
> +	xa_lock_irq(&mapping->pages);
> +	old = radix_tree_delete_item(&mapping->pages, index, radswap);
> +	xa_unlock_irq(&mapping->pages);
>  	if (old != radswap)
>  		return -ENOENT;
>  	free_swap_and_cache(radix_to_swp_entry(radswap));
> @@ -666,7 +666,7 @@ static int shmem_free_swap(struct address_space *mapping,
>   * Determine (in bytes) how many of the shmem object's pages mapped by the
>   * given offsets are swapped out.
>   *
> - * This is safe to call without i_mutex or mapping->tree_lock thanks to RCU,
> + * This is safe to call without i_mutex or mapping->pages.xa_lock thanks to RCU,
>   * as long as the inode doesn't go away and racy results are not a problem.
>   */
>  unsigned long shmem_partial_swap_usage(struct address_space *mapping,
> @@ -679,7 +679,7 @@ unsigned long shmem_partial_swap_usage(struct address_space *mapping,
>  
>  	rcu_read_lock();
>  
> -	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
> +	radix_tree_for_each_slot(slot, &mapping->pages, &iter, start) {
>  		if (iter.index >= end)
>  			break;
>  
> @@ -708,7 +708,7 @@ unsigned long shmem_partial_swap_usage(struct address_space *mapping,
>   * Determine (in bytes) how many of the shmem object's pages mapped by the
>   * given vma is swapped out.
>   *
> - * This is safe to call without i_mutex or mapping->tree_lock thanks to RCU,
> + * This is safe to call without i_mutex or mapping->pages.xa_lock thanks to RCU,
>   * as long as the inode doesn't go away and racy results are not a problem.
>   */
>  unsigned long shmem_swap_usage(struct vm_area_struct *vma)
> @@ -1123,7 +1123,7 @@ static int shmem_unuse_inode(struct shmem_inode_info *info,
>  	int error = 0;
>  
>  	radswap = swp_to_radix_entry(swap);
> -	index = find_swap_entry(&mapping->page_tree, radswap);
> +	index = find_swap_entry(&mapping->pages, radswap);
>  	if (index == -1)
>  		return -EAGAIN;	/* tell shmem_unuse we found nothing */
>  
> @@ -1436,7 +1436,7 @@ static struct page *shmem_alloc_hugepage(gfp_t gfp,
>  
>  	hindex = round_down(index, HPAGE_PMD_NR);
>  	rcu_read_lock();
> -	if (radix_tree_gang_lookup_slot(&mapping->page_tree, &results, &idx,
> +	if (radix_tree_gang_lookup_slot(&mapping->pages, &results, &idx,
>  				hindex, 1) && idx < hindex + HPAGE_PMD_NR) {
>  		rcu_read_unlock();
>  		return NULL;
> @@ -1549,14 +1549,14 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
>  	 * Our caller will very soon move newpage out of swapcache, but it's
>  	 * a nice clean interface for us to replace oldpage by newpage there.
>  	 */
> -	spin_lock_irq(&swap_mapping->tree_lock);
> +	xa_lock_irq(&swap_mapping->pages);
>  	error = shmem_radix_tree_replace(swap_mapping, swap_index, oldpage,
>  								   newpage);
>  	if (!error) {
>  		__inc_node_page_state(newpage, NR_FILE_PAGES);
>  		__dec_node_page_state(oldpage, NR_FILE_PAGES);
>  	}
> -	spin_unlock_irq(&swap_mapping->tree_lock);
> +	xa_unlock_irq(&swap_mapping->pages);
>  
>  	if (unlikely(error)) {
>  		/*
> @@ -2622,7 +2622,7 @@ static void shmem_tag_pins(struct address_space *mapping)
>  	start = 0;
>  	rcu_read_lock();
>  
> -	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
> +	radix_tree_for_each_slot(slot, &mapping->pages, &iter, start) {
>  		page = radix_tree_deref_slot(slot);
>  		if (!page || radix_tree_exception(page)) {
>  			if (radix_tree_deref_retry(page)) {
> @@ -2630,10 +2630,10 @@ static void shmem_tag_pins(struct address_space *mapping)
>  				continue;
>  			}
>  		} else if (page_count(page) - page_mapcount(page) > 1) {
> -			spin_lock_irq(&mapping->tree_lock);
> -			radix_tree_tag_set(&mapping->page_tree, iter.index,
> +			xa_lock_irq(&mapping->pages);
> +			radix_tree_tag_set(&mapping->pages, iter.index,
>  					   SHMEM_TAG_PINNED);
> -			spin_unlock_irq(&mapping->tree_lock);
> +			xa_unlock_irq(&mapping->pages);
>  		}
>  
>  		if (need_resched()) {
> @@ -2665,7 +2665,7 @@ static int shmem_wait_for_pins(struct address_space *mapping)
>  
>  	error = 0;
>  	for (scan = 0; scan <= LAST_SCAN; scan++) {
> -		if (!radix_tree_tagged(&mapping->page_tree, SHMEM_TAG_PINNED))
> +		if (!radix_tree_tagged(&mapping->pages, SHMEM_TAG_PINNED))
>  			break;
>  
>  		if (!scan)
> @@ -2675,7 +2675,7 @@ static int shmem_wait_for_pins(struct address_space *mapping)
>  
>  		start = 0;
>  		rcu_read_lock();
> -		radix_tree_for_each_tagged(slot, &mapping->page_tree, &iter,
> +		radix_tree_for_each_tagged(slot, &mapping->pages, &iter,
>  					   start, SHMEM_TAG_PINNED) {
>  
>  			page = radix_tree_deref_slot(slot);
> @@ -2701,10 +2701,10 @@ static int shmem_wait_for_pins(struct address_space *mapping)
>  				error = -EBUSY;
>  			}
>  
> -			spin_lock_irq(&mapping->tree_lock);
> -			radix_tree_tag_clear(&mapping->page_tree,
> +			xa_lock_irq(&mapping->pages);
> +			radix_tree_tag_clear(&mapping->pages,
>  					     iter.index, SHMEM_TAG_PINNED);
> -			spin_unlock_irq(&mapping->tree_lock);
> +			xa_unlock_irq(&mapping->pages);
>  continue_resched:
>  			if (need_resched()) {
>  				slot = radix_tree_iter_resume(slot, &iter);
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 39ae7cfad90f..3f95e8fc4cb2 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -124,10 +124,10 @@ int __add_to_swap_cache(struct page *page, swp_entry_t entry)
>  	SetPageSwapCache(page);
>  
>  	address_space = swap_address_space(entry);
> -	spin_lock_irq(&address_space->tree_lock);
> +	xa_lock_irq(&address_space->pages);
>  	for (i = 0; i < nr; i++) {
>  		set_page_private(page + i, entry.val + i);
> -		error = radix_tree_insert(&address_space->page_tree,
> +		error = radix_tree_insert(&address_space->pages,
>  					  idx + i, page + i);
>  		if (unlikely(error))
>  			break;
> @@ -145,13 +145,13 @@ int __add_to_swap_cache(struct page *page, swp_entry_t entry)
>  		VM_BUG_ON(error == -EEXIST);
>  		set_page_private(page + i, 0UL);
>  		while (i--) {
> -			radix_tree_delete(&address_space->page_tree, idx + i);
> +			radix_tree_delete(&address_space->pages, idx + i);
>  			set_page_private(page + i, 0UL);
>  		}
>  		ClearPageSwapCache(page);
>  		page_ref_sub(page, nr);
>  	}
> -	spin_unlock_irq(&address_space->tree_lock);
> +	xa_unlock_irq(&address_space->pages);
>  
>  	return error;
>  }
> @@ -188,7 +188,7 @@ void __delete_from_swap_cache(struct page *page)
>  	address_space = swap_address_space(entry);
>  	idx = swp_offset(entry);
>  	for (i = 0; i < nr; i++) {
> -		radix_tree_delete(&address_space->page_tree, idx + i);
> +		radix_tree_delete(&address_space->pages, idx + i);
>  		set_page_private(page + i, 0);
>  	}
>  	ClearPageSwapCache(page);
> @@ -272,9 +272,9 @@ void delete_from_swap_cache(struct page *page)
>  	entry.val = page_private(page);
>  
>  	address_space = swap_address_space(entry);
> -	spin_lock_irq(&address_space->tree_lock);
> +	xa_lock_irq(&address_space->pages);
>  	__delete_from_swap_cache(page);
> -	spin_unlock_irq(&address_space->tree_lock);
> +	xa_unlock_irq(&address_space->pages);
>  
>  	put_swap_page(page, entry);
>  	page_ref_sub(page, hpage_nr_pages(page));
> @@ -612,12 +612,11 @@ int init_swap_address_space(unsigned int type, unsigned long nr_pages)
>  		return -ENOMEM;
>  	for (i = 0; i < nr; i++) {
>  		space = spaces + i;
> -		INIT_RADIX_TREE(&space->page_tree, GFP_ATOMIC|__GFP_NOWARN);
> +		INIT_RADIX_TREE(&space->pages, GFP_ATOMIC|__GFP_NOWARN);
>  		atomic_set(&space->i_mmap_writable, 0);
>  		space->a_ops = &swap_aops;
>  		/* swap cache doesn't use writeback related tags */
>  		mapping_set_no_writeback_tags(space);
> -		spin_lock_init(&space->tree_lock);
>  	}
>  	nr_swapper_spaces[type] = nr;
>  	rcu_assign_pointer(swapper_spaces[type], spaces);
> diff --git a/mm/truncate.c b/mm/truncate.c
> index c34e2fd4f583..295a33a06fac 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -36,11 +36,11 @@ static inline void __clear_shadow_entry(struct address_space *mapping,
>  	struct radix_tree_node *node;
>  	void **slot;
>  
> -	if (!__radix_tree_lookup(&mapping->page_tree, index, &node, &slot))
> +	if (!__radix_tree_lookup(&mapping->pages, index, &node, &slot))
>  		return;
>  	if (*slot != entry)
>  		return;
> -	__radix_tree_replace(&mapping->page_tree, node, slot, NULL,
> +	__radix_tree_replace(&mapping->pages, node, slot, NULL,
>  			     workingset_update_node);
>  	mapping->nrexceptional--;
>  }
> @@ -48,9 +48,9 @@ static inline void __clear_shadow_entry(struct address_space *mapping,
>  static void clear_shadow_entry(struct address_space *mapping, pgoff_t index,
>  			       void *entry)
>  {
> -	spin_lock_irq(&mapping->tree_lock);
> +	xa_lock_irq(&mapping->pages);
>  	__clear_shadow_entry(mapping, index, entry);
> -	spin_unlock_irq(&mapping->tree_lock);
> +	xa_unlock_irq(&mapping->pages);
>  }
>  
>  /*
> @@ -79,7 +79,7 @@ static void truncate_exceptional_pvec_entries(struct address_space *mapping,
>  	dax = dax_mapping(mapping);
>  	lock = !dax && indices[j] < end;
>  	if (lock)
> -		spin_lock_irq(&mapping->tree_lock);
> +		xa_lock_irq(&mapping->pages);
>  
>  	for (i = j; i < pagevec_count(pvec); i++) {
>  		struct page *page = pvec->pages[i];
> @@ -102,7 +102,7 @@ static void truncate_exceptional_pvec_entries(struct address_space *mapping,
>  	}
>  
>  	if (lock)
> -		spin_unlock_irq(&mapping->tree_lock);
> +		xa_unlock_irq(&mapping->pages);
>  	pvec->nr = j;
>  }
>  
> @@ -518,8 +518,8 @@ void truncate_inode_pages_final(struct address_space *mapping)
>  		 * modification that does not see AS_EXITING is
>  		 * completed before starting the final truncate.
>  		 */
> -		spin_lock_irq(&mapping->tree_lock);
> -		spin_unlock_irq(&mapping->tree_lock);
> +		xa_lock_irq(&mapping->pages);
> +		xa_unlock_irq(&mapping->pages);
>  
>  		truncate_inode_pages(mapping, 0);
>  	}
> @@ -627,13 +627,13 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
>  	if (page_has_private(page) && !try_to_release_page(page, GFP_KERNEL))
>  		return 0;
>  
> -	spin_lock_irqsave(&mapping->tree_lock, flags);
> +	xa_lock_irqsave(&mapping->pages, flags);
>  	if (PageDirty(page))
>  		goto failed;
>  
>  	BUG_ON(page_has_private(page));
>  	__delete_from_page_cache(page, NULL);
> -	spin_unlock_irqrestore(&mapping->tree_lock, flags);
> +	xa_unlock_irqrestore(&mapping->pages, flags);
>  
>  	if (mapping->a_ops->freepage)
>  		mapping->a_ops->freepage(page);
> @@ -641,7 +641,7 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
>  	put_page(page);	/* pagecache ref */
>  	return 1;
>  failed:
> -	spin_unlock_irqrestore(&mapping->tree_lock, flags);
> +	xa_unlock_irqrestore(&mapping->pages, flags);
>  	return 0;
>  }
>  
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 444749669187..93f4b4634431 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -656,7 +656,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
>  	BUG_ON(!PageLocked(page));
>  	BUG_ON(mapping != page_mapping(page));
>  
> -	spin_lock_irqsave(&mapping->tree_lock, flags);
> +	xa_lock_irqsave(&mapping->pages, flags);
>  	/*
>  	 * The non racy check for a busy page.
>  	 *
> @@ -680,7 +680,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
>  	 * load is not satisfied before that of page->_refcount.
>  	 *
>  	 * Note that if SetPageDirty is always performed via set_page_dirty,
> -	 * and thus under tree_lock, then this ordering is not required.
> +	 * and thus under xa_lock, then this ordering is not required.
>  	 */
>  	if (unlikely(PageTransHuge(page)) && PageSwapCache(page))
>  		refcount = 1 + HPAGE_PMD_NR;
> @@ -698,7 +698,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
>  		swp_entry_t swap = { .val = page_private(page) };
>  		mem_cgroup_swapout(page, swap);
>  		__delete_from_swap_cache(page);
> -		spin_unlock_irqrestore(&mapping->tree_lock, flags);
> +		xa_unlock_irqrestore(&mapping->pages, flags);
>  		put_swap_page(page, swap);
>  	} else {
>  		void (*freepage)(struct page *);
> @@ -719,13 +719,13 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
>  		 * only page cache pages found in these are zero pages
>  		 * covering holes, and because we don't want to mix DAX
>  		 * exceptional entries and shadow exceptional entries in the
> -		 * same page_tree.
> +		 * same address_space.
>  		 */
>  		if (reclaimed && page_is_file_cache(page) &&
>  		    !mapping_exiting(mapping) && !dax_mapping(mapping))
>  			shadow = workingset_eviction(mapping, page);
>  		__delete_from_page_cache(page, shadow);
> -		spin_unlock_irqrestore(&mapping->tree_lock, flags);
> +		xa_unlock_irqrestore(&mapping->pages, flags);
>  
>  		if (freepage != NULL)
>  			freepage(page);
> @@ -734,7 +734,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
>  	return 1;
>  
>  cannot_free:
> -	spin_unlock_irqrestore(&mapping->tree_lock, flags);
> +	xa_unlock_irqrestore(&mapping->pages, flags);
>  	return 0;
>  }
>  
> diff --git a/mm/workingset.c b/mm/workingset.c
> index b7d616a3bbbe..3cb3586181e6 100644
> --- a/mm/workingset.c
> +++ b/mm/workingset.c
> @@ -202,7 +202,7 @@ static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
>   * @mapping: address space the page was backing
>   * @page: the page being evicted
>   *
> - * Returns a shadow entry to be stored in @mapping->page_tree in place
> + * Returns a shadow entry to be stored in @mapping->pages in place
>   * of the evicted @page so that a later refault can be detected.
>   */
>  void *workingset_eviction(struct address_space *mapping, struct page *page)
> @@ -348,7 +348,7 @@ void workingset_update_node(struct radix_tree_node *node)
>  	 *
>  	 * Avoid acquiring the list_lru lock when the nodes are
>  	 * already where they should be. The list_empty() test is safe
> -	 * as node->private_list is protected by &mapping->tree_lock.
> +	 * as node->private_list is protected by mapping->pages.xa_lock.
>  	 */
>  	if (node->count && node->count == node->exceptional) {
>  		if (list_empty(&node->private_list))
> @@ -366,7 +366,7 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
>  	unsigned long nodes;
>  	unsigned long cache;
>  
> -	/* list_lru lock nests inside IRQ-safe mapping->tree_lock */
> +	/* list_lru lock nests inside IRQ-safe mapping->pages.xa_lock */
>  	local_irq_disable();
>  	nodes = list_lru_shrink_count(&shadow_nodes, sc);
>  	local_irq_enable();
> @@ -419,21 +419,21 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
>  
>  	/*
>  	 * Page cache insertions and deletions synchroneously maintain
> -	 * the shadow node LRU under the mapping->tree_lock and the
> +	 * the shadow node LRU under the mapping->pages.xa_lock and the
>  	 * lru_lock.  Because the page cache tree is emptied before
>  	 * the inode can be destroyed, holding the lru_lock pins any
>  	 * address_space that has radix tree nodes on the LRU.
>  	 *
> -	 * We can then safely transition to the mapping->tree_lock to
> +	 * We can then safely transition to the mapping->pages.xa_lock to
>  	 * pin only the address_space of the particular node we want
>  	 * to reclaim, take the node off-LRU, and drop the lru_lock.
>  	 */
>  
>  	node = container_of(item, struct radix_tree_node, private_list);
> -	mapping = container_of(node->root, struct address_space, page_tree);
> +	mapping = container_of(node->root, struct address_space, pages);
>  
>  	/* Coming from the list, invert the lock order */
> -	if (!spin_trylock(&mapping->tree_lock)) {
> +	if (!xa_trylock(&mapping->pages)) {
>  		spin_unlock(lru_lock);
>  		ret = LRU_RETRY;
>  		goto out;
> @@ -468,11 +468,11 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
>  	if (WARN_ON_ONCE(node->exceptional))
>  		goto out_invalid;
>  	inc_lruvec_page_state(virt_to_page(node), WORKINGSET_NODERECLAIM);
> -	__radix_tree_delete_node(&mapping->page_tree, node,
> +	__radix_tree_delete_node(&mapping->pages, node,
>  				 workingset_lookup_update(mapping));
>  
>  out_invalid:
> -	spin_unlock(&mapping->tree_lock);
> +	xa_unlock(&mapping->pages);
>  	ret = LRU_REMOVED_RETRY;
>  out:
>  	local_irq_enable();
> @@ -487,7 +487,7 @@ static unsigned long scan_shadow_nodes(struct shrinker *shrinker,
>  {
>  	unsigned long ret;
>  
> -	/* list_lru lock nests inside IRQ-safe mapping->tree_lock */
> +	/* list_lru lock nests inside IRQ-safe mapping->pages.xa_lock */
>  	local_irq_disable();
>  	ret = list_lru_shrink_walk(&shadow_nodes, sc, shadow_lru_isolate, NULL);
>  	local_irq_enable();
> @@ -503,7 +503,7 @@ static struct shrinker workingset_shadow_shrinker = {
>  
>  /*
>   * Our list_lru->lock is IRQ-safe as it nests inside the IRQ-safe
> - * mapping->tree_lock.
> + * mapping->pages.xa_lock.
>   */
>  static struct lock_class_key shadow_nodes_key;
>  

Straightforward change and the doc comments are a nice cleanup. Big
patch though and I didn't go over it in detail, so:

Acked-by: Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
