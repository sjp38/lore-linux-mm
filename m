Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 43CCD6B0038
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 20:03:30 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id o88so491931wrb.18
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 17:03:30 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id z9si756278ede.320.2017.11.16.17.03.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Nov 2017 17:03:27 -0800 (PST)
Date: Thu, 16 Nov 2017 17:03:08 -0800
From: Liu Bo <bo.li.liu@oracle.com>
Subject: Re: [PATCH 09/10] Btrfs: kill the btree_inode
Message-ID: <20171117010307.GF23614@dhcp-whq-twvpn-1-vpnpool-10-159-142-193.vpn.oracle.com>
Reply-To: bo.li.liu@oracle.com
References: <1510696616-8489-1-git-send-email-josef@toxicpanda.com>
 <1510696616-8489-9-git-send-email-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1510696616-8489-9-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Tue, Nov 14, 2017 at 04:56:55PM -0500, Josef Bacik wrote:
> From: Josef Bacik <jbacik@fb.com>
> 
> In order to more efficiently support sub-page blocksizes we need to stop
> allocating pages from pagecache for our metadata.  Instead switch to using the
> account_metadata* counters for making sure we are keeping the system aware of
> how much dirty metadata we have, and use the ->free_cached_objects super
> operation in order to handle freeing up extent buffers.  This greatly simplifies
> how we deal with extent buffers as now we no longer have to tie the page cache
> reclaimation stuff to the extent buffer stuff.  This will also allow us to
> simply kmalloc() our data for sub-page blocksizes.
>

The patch is too big for one to review, but so far it looks good to
me, a few comments.

> Signed-off-by: Josef Bacik <jbacik@fb.com>
> ---
...
>  
> -static int check_async_write(struct btrfs_inode *bi)
> +static int check_async_write(void)
>  {
> -	if (atomic_read(&bi->sync_writers))
> +	if (current->journal_info)

Please add a comment that explains we're called from commit
transaction.

>  		return 0;
>  #ifdef CONFIG_X86
>  	if (static_cpu_has(X86_FEATURE_XMM4_2))
...
> @@ -4977,12 +5054,12 @@ struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
>  	unsigned long len = fs_info->nodesize;
>  	unsigned long num_pages = num_extent_pages(start, len);
>  	unsigned long i;
> -	unsigned long index = start >> PAGE_SHIFT;
>  	struct extent_buffer *eb;
>  	struct extent_buffer *exists = NULL;
>  	struct page *p;
> -	struct address_space *mapping = fs_info->btree_inode->i_mapping;
> -	int uptodate = 1;
> +	struct btrfs_eb_info *eb_info = fs_info->eb_info;
> +//	struct zone *last_zone = NULL;
> +//	struct pg_data_t *last_pgdata = NULL;

hmm, a typo?

Thanks,

-liubo

>  	int ret;
>  
>  	if (!IS_ALIGNED(start, fs_info->sectorsize)) {
> @@ -4990,62 +5067,36 @@ struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
>  		return ERR_PTR(-EINVAL);
>  	}
>  
> -	eb = find_extent_buffer(fs_info, start);
> +	eb = find_extent_buffer(eb_info, start);
>  	if (eb)
>  		return eb;
>  
> -	eb = __alloc_extent_buffer(fs_info, start, len);
> +	eb = __alloc_extent_buffer(eb_info, start, len);
>  	if (!eb)
>  		return ERR_PTR(-ENOMEM);
>  
> -	for (i = 0; i < num_pages; i++, index++) {
> -		p = find_or_create_page(mapping, index, GFP_NOFS|__GFP_NOFAIL);
> +	for (i = 0; i < num_pages; i++) {
> +		p = alloc_page(GFP_NOFS|__GFP_NOFAIL);
>  		if (!p) {
>  			exists = ERR_PTR(-ENOMEM);
>  			goto free_eb;
>  		}
>  
> -		spin_lock(&mapping->private_lock);
> -		if (PagePrivate(p)) {
> -			/*
> -			 * We could have already allocated an eb for this page
> -			 * and attached one so lets see if we can get a ref on
> -			 * the existing eb, and if we can we know it's good and
> -			 * we can just return that one, else we know we can just
> -			 * overwrite page->private.
> -			 */
> -			exists = (struct extent_buffer *)p->private;
> -			if (atomic_inc_not_zero(&exists->refs)) {
> -				spin_unlock(&mapping->private_lock);
> -				unlock_page(p);
> -				put_page(p);
> -				mark_extent_buffer_accessed(exists, p);
> -				goto free_eb;
> -			}
> -			exists = NULL;
> -
> -			/*
> -			 * Do this so attach doesn't complain and we need to
> -			 * drop the ref the old guy had.
> -			 */
> -			ClearPagePrivate(p);
> -			WARN_ON(PageDirty(p));
> -			put_page(p);
> -		}
> +		/*
> +		 * If our pages span zones or numa nodes we have to do
> +		 * dirty/writeback accounting per page, otherwise we can do it
> +		 * in bulk and save us some looping.
> +		 *
> +		if (!last_zone)
> +			last_zone = page_zone(p);
> +		if (!last_pgdata)
> +			last_pgdata = page_pgdata(p);
> +		if (last_zone != page_zone(p) || last_pgdata != page_pgdata(p))
> +			set_bit(EXTENT_BUFFER_MIXED_PAGES, &eb->bflags);
> +		*/
>  		attach_extent_buffer_page(eb, p);
> -		spin_unlock(&mapping->private_lock);
> -		WARN_ON(PageDirty(p));
>  		eb->pages[i] = p;
> -		if (!PageUptodate(p))
> -			uptodate = 0;
> -
> -		/*
> -		 * see below about how we avoid a nasty race with release page
> -		 * and why we unlock later
> -		 */
>  	}
> -	if (uptodate)
> -		set_bit(EXTENT_BUFFER_UPTODATE, &eb->bflags);
>  again:
>  	ret = radix_tree_preload(GFP_NOFS);
>  	if (ret) {
> @@ -5053,13 +5104,13 @@ struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
>  		goto free_eb;
>  	}
>  
> -	spin_lock(&fs_info->buffer_lock);
> -	ret = radix_tree_insert(&fs_info->buffer_radix,
> +	spin_lock_irq(&eb_info->buffer_lock);
> +	ret = radix_tree_insert(&eb_info->buffer_radix,
>  				start >> PAGE_SHIFT, eb);
> -	spin_unlock(&fs_info->buffer_lock);
> +	spin_unlock_irq(&eb_info->buffer_lock);
>  	radix_tree_preload_end();
>  	if (ret == -EEXIST) {
> -		exists = find_extent_buffer(fs_info, start);
> +		exists = find_extent_buffer(eb_info, start);
>  		if (exists)
>  			goto free_eb;
>  		else
> @@ -5069,31 +5120,10 @@ struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
>  	check_buffer_tree_ref(eb);
>  	set_bit(EXTENT_BUFFER_IN_TREE, &eb->bflags);
>  
> -	/*
> -	 * there is a race where release page may have
> -	 * tried to find this extent buffer in the radix
> -	 * but failed.  It will tell the VM it is safe to
> -	 * reclaim the, and it will clear the page private bit.
> -	 * We must make sure to set the page private bit properly
> -	 * after the extent buffer is in the radix tree so
> -	 * it doesn't get lost
> -	 */
> -	SetPageChecked(eb->pages[0]);
> -	for (i = 1; i < num_pages; i++) {
> -		p = eb->pages[i];
> -		ClearPageChecked(p);
> -		unlock_page(p);
> -	}
> -	unlock_page(eb->pages[0]);
>  	return eb;
>  
>  free_eb:
>  	WARN_ON(!atomic_dec_and_test(&eb->refs));
> -	for (i = 0; i < num_pages; i++) {
> -		if (eb->pages[i])
> -			unlock_page(eb->pages[i]);
> -	}
> -
>  	btrfs_release_extent_buffer(eb);
>  	return exists;
>  }
> @@ -5109,17 +5139,19 @@ static inline void btrfs_release_extent_buffer_rcu(struct rcu_head *head)
>  /* Expects to have eb->eb_lock already held */
>  static int release_extent_buffer(struct extent_buffer *eb)
>  {
> +	struct btrfs_eb_info *eb_info = eb->eb_info;
> +
>  	WARN_ON(atomic_read(&eb->refs) == 0);
>  	if (atomic_dec_and_test(&eb->refs)) {
> +		if (eb_info)
> +			list_lru_del(&eb_info->lru_list, &eb->lru);
>  		if (test_and_clear_bit(EXTENT_BUFFER_IN_TREE, &eb->bflags)) {
> -			struct btrfs_fs_info *fs_info = eb->fs_info;
> -
>  			spin_unlock(&eb->refs_lock);
>  
> -			spin_lock(&fs_info->buffer_lock);
> -			radix_tree_delete(&fs_info->buffer_radix,
> -					  eb->start >> PAGE_SHIFT);
> -			spin_unlock(&fs_info->buffer_lock);
> +			spin_lock_irq(&eb_info->buffer_lock);
> +			radix_tree_delete(&eb_info->buffer_radix,
> +					  eb_index(eb));
> +			spin_unlock_irq(&eb_info->buffer_lock);
>  		} else {
>  			spin_unlock(&eb->refs_lock);
>  		}
> @@ -5134,6 +5166,8 @@ static int release_extent_buffer(struct extent_buffer *eb)
>  #endif
>  		call_rcu(&eb->rcu_head, btrfs_release_extent_buffer_rcu);
>  		return 1;
> +	} else if (eb_info && atomic_read(&eb->refs) == 1) {
> +		list_lru_add(&eb_info->lru_list, &eb->lru);
>  	}
>  	spin_unlock(&eb->refs_lock);
>  
> @@ -5167,10 +5201,6 @@ void free_extent_buffer(struct extent_buffer *eb)
>  	    test_and_clear_bit(EXTENT_BUFFER_TREE_REF, &eb->bflags))
>  		atomic_dec(&eb->refs);
>  
> -	/*
> -	 * I know this is terrible, but it's temporary until we stop tracking
> -	 * the uptodate bits and such for the extent buffers.
> -	 */
>  	release_extent_buffer(eb);
>  }
>  
> @@ -5188,82 +5218,156 @@ void free_extent_buffer_stale(struct extent_buffer *eb)
>  	release_extent_buffer(eb);
>  }
>  
> -void clear_extent_buffer_dirty(struct extent_buffer *eb)
> +long btrfs_nr_ebs(struct super_block *sb, struct shrink_control *sc)
>  {
> -	unsigned long i;
> -	unsigned long num_pages;
> -	struct page *page;
> +	struct btrfs_fs_info *fs_info = btrfs_sb(sb);
> +	struct btrfs_eb_info *eb_info = fs_info->eb_info;
>  
> -	num_pages = num_extent_pages(eb->start, eb->len);
> +	return list_lru_shrink_count(&eb_info->lru_list, sc);
> +}
>  
> -	for (i = 0; i < num_pages; i++) {
> -		page = eb->pages[i];
> -		if (!PageDirty(page))
> -			continue;
> +static enum lru_status eb_lru_isolate(struct list_head *item,
> +				      struct list_lru_one *lru,
> +				      spinlock_t *lru_lock, void *arg)
> +{
> +	struct list_head *freeable = (struct list_head *)arg;
> +	struct extent_buffer *eb = container_of(item, struct extent_buffer,
> +						lru);
> +	enum lru_status ret;
> +	int refs;
>  
> -		lock_page(page);
> -		WARN_ON(!PagePrivate(page));
> +	if (!spin_trylock(&eb->refs_lock))
> +		return LRU_SKIP;
>  
> -		clear_page_dirty_for_io(page);
> -		spin_lock_irq(&page->mapping->tree_lock);
> -		if (!PageDirty(page)) {
> -			radix_tree_tag_clear(&page->mapping->page_tree,
> -						page_index(page),
> -						PAGECACHE_TAG_DIRTY);
> -		}
> -		spin_unlock_irq(&page->mapping->tree_lock);
> -		ClearPageError(page);
> -		unlock_page(page);
> +	if (extent_buffer_under_io(eb)) {
> +		ret = LRU_ROTATE;
> +		goto out;
>  	}
> +
> +	refs = atomic_read(&eb->refs);
> +	/* We can race with somebody freeing us, just skip if this happens. */
> +	if (refs == 0) {
> +		ret = LRU_SKIP;
> +		goto out;
> +	}
> +
> +	/* Eb is in use, don't kill it. */
> +	if (refs > 1) {
> +		ret = LRU_ROTATE;
> +		goto out;
> +	}
> +
> +	/*
> +	 * If we don't clear the TREE_REF flag then this eb is going to
> +	 * disappear soon anyway.  Otherwise we become responsible for dropping
> +	 * the last ref on this eb and we know it'll survive until we call
> +	 * dispose_list.
> +	 */
> +	if (!test_and_clear_bit(EXTENT_BUFFER_TREE_REF, &eb->bflags)) {
> +		ret = LRU_SKIP;
> +		goto out;
> +	}
> +	list_lru_isolate_move(lru, &eb->lru, freeable);
> +	ret = LRU_REMOVED;
> +out:
> +	spin_unlock(&eb->refs_lock);
> +	return ret;
> +}
> +
> +static void dispose_list(struct list_head *list)
> +{
> +	struct extent_buffer *eb;
> +
> +	while (!list_empty(list)) {
> +		eb = list_first_entry(list, struct extent_buffer, lru);
> +
> +		spin_lock(&eb->refs_lock);
> +		list_del_init(&eb->lru);
> +		spin_unlock(&eb->refs_lock);
> +		free_extent_buffer(eb);
> +		cond_resched();
> +	}
> +}
> +
> +long btrfs_free_ebs(struct super_block *sb, struct shrink_control *sc)
> +{
> +	struct btrfs_fs_info *fs_info = btrfs_sb(sb);
> +	struct btrfs_eb_info *eb_info = fs_info->eb_info;
> +	LIST_HEAD(freeable);
> +	long freed;
> +
> +	freed = list_lru_shrink_walk(&eb_info->lru_list, sc, eb_lru_isolate,
> +				     &freeable);
> +	dispose_list(&freeable);
> +	return freed;
> +}
> +
> +void btrfs_invalidate_eb_info(struct btrfs_eb_info *eb_info)
> +{
> +	LIST_HEAD(freeable);
> +
> +	/*
> +	 * We should be able to free all the extent buffers at this point, if we
> +	 * can't there's a problem and we should complain loudly about it.
> +	 */
> +	do {
> +		list_lru_walk(&eb_info->lru_list, eb_lru_isolate, &freeable, LONG_MAX);
> +	} while (WARN_ON(list_lru_count(&eb_info->lru_list)));
> +	dispose_list(&freeable);
> +	synchronize_rcu();
> +}
> +
> +int clear_extent_buffer_dirty(struct extent_buffer *eb)
> +{
> +	struct btrfs_eb_info *eb_info = eb->eb_info;
> +	struct super_block *sb = eb_info->fs_info->sb;
> +	unsigned long num_pages;
> +
> +	if (!test_and_clear_bit(EXTENT_BUFFER_DIRTY, &eb->bflags))
> +		return 0;
> +
> +	spin_lock_irq(&eb_info->buffer_lock);
> +	radix_tree_tag_clear(&eb_info->buffer_radix, eb_index(eb),
> +			     PAGECACHE_TAG_DIRTY);
> +	spin_unlock_irq(&eb_info->buffer_lock);
> +
> +	num_pages = num_extent_pages(eb->start, eb->len);
> +	account_metadata_cleaned(eb->pages[0], sb->s_bdi, eb->len);
>  	WARN_ON(atomic_read(&eb->refs) == 0);
> +	return 1;
>  }
>  
>  int set_extent_buffer_dirty(struct extent_buffer *eb)
>  {
> -	unsigned long i;
> +	struct btrfs_eb_info *eb_info = eb->eb_info;
> +	struct super_block *sb = eb_info->fs_info->sb;
>  	unsigned long num_pages;
>  	int was_dirty = 0;
>  
>  	check_buffer_tree_ref(eb);
>  
> -	was_dirty = test_and_set_bit(EXTENT_BUFFER_DIRTY, &eb->bflags);
> -
> -	num_pages = num_extent_pages(eb->start, eb->len);
>  	WARN_ON(atomic_read(&eb->refs) == 0);
>  	WARN_ON(!test_bit(EXTENT_BUFFER_TREE_REF, &eb->bflags));
> +	if (test_and_set_bit(EXTENT_BUFFER_DIRTY, &eb->bflags))
> +		return 1;
>  
> -	for (i = 0; i < num_pages; i++)
> -		set_page_dirty(eb->pages[i]);
> +	num_pages = num_extent_pages(eb->start, eb->len);
> +	account_metadata_dirtied(eb->pages[0], sb->s_bdi, eb->len);
> +	spin_lock_irq(&eb_info->buffer_lock);
> +	radix_tree_tag_set(&eb_info->buffer_radix, eb_index(eb),
> +			   PAGECACHE_TAG_DIRTY);
> +	spin_unlock_irq(&eb_info->buffer_lock);
>  	return was_dirty;
>  }
>  
>  void clear_extent_buffer_uptodate(struct extent_buffer *eb)
>  {
> -	unsigned long i;
> -	struct page *page;
> -	unsigned long num_pages;
> -
>  	clear_bit(EXTENT_BUFFER_UPTODATE, &eb->bflags);
> -	num_pages = num_extent_pages(eb->start, eb->len);
> -	for (i = 0; i < num_pages; i++) {
> -		page = eb->pages[i];
> -		if (page)
> -			ClearPageUptodate(page);
> -	}
>  }
>  
>  void set_extent_buffer_uptodate(struct extent_buffer *eb)
>  {
> -	unsigned long i;
> -	struct page *page;
> -	unsigned long num_pages;
> -
>  	set_bit(EXTENT_BUFFER_UPTODATE, &eb->bflags);
> -	num_pages = num_extent_pages(eb->start, eb->len);
> -	for (i = 0; i < num_pages; i++) {
> -		page = eb->pages[i];
> -		SetPageUptodate(page);
> -	}
>  }
>  
>  int extent_buffer_uptodate(struct extent_buffer *eb)
> @@ -5271,112 +5375,165 @@ int extent_buffer_uptodate(struct extent_buffer *eb)
>  	return test_bit(EXTENT_BUFFER_UPTODATE, &eb->bflags);
>  }
>  
> -int read_extent_buffer_pages(struct extent_io_tree *tree,
> -			     struct extent_buffer *eb, int wait,
> -			     get_extent_t *get_extent, int mirror_num)
> +static void end_bio_extent_buffer_readpage(struct bio *bio)
>  {
> +	struct btrfs_io_bio *io_bio = btrfs_io_bio(bio);
> +	struct extent_io_tree *tree = NULL;
> +	struct bio_vec *bvec;
> +	u64 unlock_start = 0, unlock_len = 0;
> +	int mirror_num = io_bio->mirror_num;
> +	int uptodate = !bio->bi_status;
> +	int i, ret;
> +
> +	bio_for_each_segment_all(bvec, bio, i) {
> +		struct page *page = bvec->bv_page;
> +		struct btrfs_eb_info *eb_info;
> +		struct extent_buffer *eb;
> +
> +		eb = (struct extent_buffer *)page->private;
> +		if (WARN_ON(!eb))
> +			continue;
> +
> +		eb_info = eb->eb_info;
> +		if (!tree)
> +			tree = &eb_info->io_tree;
> +		if (uptodate) {
> +			/*
> +			 * btree_readpage_end_io_hook doesn't care about
> +			 * start/end so just pass 0.  We'll kill this later.
> +			 */
> +			ret = tree->ops->readpage_end_io_hook(io_bio, 0,
> +							      page, 0, 0,
> +							      mirror_num);
> +			if (ret) {
> +				uptodate = 0;
> +			} else {
> +				u64 start = eb->start;
> +				int c, num_pages;
> +
> +				num_pages = num_extent_pages(eb->start,
> +							     eb->len);
> +				for (c = 0; c < num_pages; c++) {
> +					if (eb->pages[c] == page)
> +						break;
> +					start += PAGE_SIZE;
> +				}
> +				clean_io_failure(eb_info->fs_info,
> +						 &eb_info->io_failure_tree,
> +						 tree, start, page, 0, 0);
> +			}
> +		}
> +		/*
> +		 * We never fix anything in btree_io_failed_hook.
> +		 *
> +		 * TODO: rework the io failed hook to not assume we can fix
> +		 * anything.
> +		 */
> +		if (!uptodate)
> +			tree->ops->readpage_io_failed_hook(page, mirror_num);
> +
> +		if (unlock_start == 0) {
> +			unlock_start = eb->start;
> +			unlock_len = PAGE_SIZE;
> +		} else {
> +			unlock_len += PAGE_SIZE;
> +		}
> +	}
> +
> +	if (unlock_start)
> +		unlock_extent(tree, unlock_start,
> +			      unlock_start + unlock_len - 1);
> +	if (io_bio->end_io)
> +		io_bio->end_io(io_bio, blk_status_to_errno(bio->bi_status));
> +	bio_put(bio);
> +}
> +
> +int read_extent_buffer_pages(struct extent_buffer *eb, int wait,
> +			     int mirror_num)
> +{
> +	struct btrfs_eb_info *eb_info = eb->eb_info;
> +	struct extent_io_tree *io_tree = &eb_info->io_tree;
> +	struct block_device *bdev = eb_info->fs_info->fs_devices->latest_bdev;
> +	struct bio *bio = NULL;
> +	u64 offset = eb->start;
> +	u64 unlock_start = 0, unlock_len = 0;
>  	unsigned long i;
>  	struct page *page;
>  	int err;
>  	int ret = 0;
> -	int locked_pages = 0;
> -	int all_uptodate = 1;
>  	unsigned long num_pages;
> -	unsigned long num_reads = 0;
> -	struct bio *bio = NULL;
> -	unsigned long bio_flags = 0;
>  
>  	if (test_bit(EXTENT_BUFFER_UPTODATE, &eb->bflags))
>  		return 0;
>  
> -	num_pages = num_extent_pages(eb->start, eb->len);
> -	for (i = 0; i < num_pages; i++) {
> -		page = eb->pages[i];
> -		if (wait == WAIT_NONE) {
> -			if (!trylock_page(page))
> -				goto unlock_exit;
> -		} else {
> -			lock_page(page);
> -		}
> -		locked_pages++;
> -	}
> -	/*
> -	 * We need to firstly lock all pages to make sure that
> -	 * the uptodate bit of our pages won't be affected by
> -	 * clear_extent_buffer_uptodate().
> -	 */
> -	for (i = 0; i < num_pages; i++) {
> -		page = eb->pages[i];
> -		if (!PageUptodate(page)) {
> -			num_reads++;
> -			all_uptodate = 0;
> -		}
> -	}
> -
> -	if (all_uptodate) {
> -		set_bit(EXTENT_BUFFER_UPTODATE, &eb->bflags);
> -		goto unlock_exit;
> +	if (test_and_set_bit(EXTENT_BUFFER_READING, &eb->bflags)) {
> +		if (wait != WAIT_COMPLETE)
> +			return 0;
> +		wait_on_bit_io(&eb->bflags, EXTENT_BUFFER_READING,
> +			       TASK_UNINTERRUPTIBLE);
> +		if (!test_bit(EXTENT_BUFFER_UPTODATE, &eb->bflags))
> +			ret = -EIO;
> +		return ret;
>  	}
>  
> +	lock_extent(io_tree, eb->start, eb->start + eb->len - 1);
> +	num_pages = num_extent_pages(eb->start, eb->len);
>  	clear_bit(EXTENT_BUFFER_READ_ERR, &eb->bflags);
>  	eb->read_mirror = 0;
> -	atomic_set(&eb->io_pages, num_reads);
> +	atomic_set(&eb->io_pages, num_pages);
>  	for (i = 0; i < num_pages; i++) {
>  		page = eb->pages[i];
> -
> -		if (!PageUptodate(page)) {
> -			if (ret) {
> -				atomic_dec(&eb->io_pages);
> -				unlock_page(page);
> -				continue;
> +		if (ret) {
> +			unlock_len += PAGE_SIZE;
> +			if (atomic_dec_and_test(&eb->io_pages)) {
> +				clear_bit(EXTENT_BUFFER_READING, &eb->bflags);
> +				smp_mb__after_atomic();
> +				wake_up_bit(&eb->bflags, EXTENT_BUFFER_READING);
>  			}
> +			continue;
> +		}
>  
> -			ClearPageError(page);
> -			err = __extent_read_full_page(tree, page,
> -						      get_extent, &bio,
> -						      mirror_num, &bio_flags,
> -						      REQ_META);
> -			if (err) {
> -				ret = err;
> -				/*
> -				 * We use &bio in above __extent_read_full_page,
> -				 * so we ensure that if it returns error, the
> -				 * current page fails to add itself to bio and
> -				 * it's been unlocked.
> -				 *
> -				 * We must dec io_pages by ourselves.
> -				 */
> -				atomic_dec(&eb->io_pages);
> +		err = submit_extent_page(REQ_OP_READ | REQ_META, io_tree, NULL,
> +					 page, offset >> 9, PAGE_SIZE, 0, bdev,
> +					 &bio, end_bio_extent_buffer_readpage,
> +					 mirror_num, 0, 0, 0, false);
> +		if (err) {
> +			ret = err;
> +			/*
> +			 * We use &bio in above submit_extent_page
> +			 * so we ensure that if it returns error, the
> +			 * current page fails to add itself to bio and
> +			 * it's been unlocked.
> +			 *
> +			 * We must dec io_pages by ourselves.
> +			 */
> +			if (atomic_dec_and_test(&eb->io_pages)) {
> +				clear_bit(EXTENT_BUFFER_READING, &eb->bflags);
> +				smp_mb__after_atomic();
> +				wake_up_bit(&eb->bflags, EXTENT_BUFFER_READING);
>  			}
> -		} else {
> -			unlock_page(page);
> +			unlock_start = eb->start;
> +			unlock_len = PAGE_SIZE;
>  		}
> +		offset += PAGE_SIZE;
>  	}
>  
>  	if (bio) {
> -		err = submit_one_bio(bio, mirror_num, bio_flags);
> +		err = submit_one_bio(bio, mirror_num, 0);
>  		if (err)
>  			return err;
>  	}
>  
> +	if (ret && unlock_start)
> +		unlock_extent(io_tree, unlock_start,
> +			      unlock_start + unlock_len - 1);
>  	if (ret || wait != WAIT_COMPLETE)
>  		return ret;
>  
> -	for (i = 0; i < num_pages; i++) {
> -		page = eb->pages[i];
> -		wait_on_page_locked(page);
> -		if (!PageUptodate(page))
> -			ret = -EIO;
> -	}
> -
> -	return ret;
> -
> -unlock_exit:
> -	while (locked_pages > 0) {
> -		locked_pages--;
> -		page = eb->pages[locked_pages];
> -		unlock_page(page);
> -	}
> +	wait_on_bit_io(&eb->bflags, EXTENT_BUFFER_READING,
> +		       TASK_UNINTERRUPTIBLE);
> +	if (!test_bit(EXTENT_BUFFER_UPTODATE, &eb->bflags))
> +		ret = -EIO;
>  	return ret;
>  }
>  
> @@ -5533,7 +5690,6 @@ void write_extent_buffer_chunk_tree_uuid(struct extent_buffer *eb,
>  {
>  	char *kaddr;
>  
> -	WARN_ON(!PageUptodate(eb->pages[0]));
>  	kaddr = page_address(eb->pages[0]);
>  	memcpy(kaddr + offsetof(struct btrfs_header, chunk_tree_uuid), srcv,
>  			BTRFS_FSID_SIZE);
> @@ -5543,7 +5699,6 @@ void write_extent_buffer_fsid(struct extent_buffer *eb, const void *srcv)
>  {
>  	char *kaddr;
>  
> -	WARN_ON(!PageUptodate(eb->pages[0]));
>  	kaddr = page_address(eb->pages[0]);
>  	memcpy(kaddr + offsetof(struct btrfs_header, fsid), srcv,
>  			BTRFS_FSID_SIZE);
> @@ -5567,7 +5722,6 @@ void write_extent_buffer(struct extent_buffer *eb, const void *srcv,
>  
>  	while (len > 0) {
>  		page = eb->pages[i];
> -		WARN_ON(!PageUptodate(page));
>  
>  		cur = min(len, PAGE_SIZE - offset);
>  		kaddr = page_address(page);
> @@ -5597,7 +5751,6 @@ void memzero_extent_buffer(struct extent_buffer *eb, unsigned long start,
>  
>  	while (len > 0) {
>  		page = eb->pages[i];
> -		WARN_ON(!PageUptodate(page));
>  
>  		cur = min(len, PAGE_SIZE - offset);
>  		kaddr = page_address(page);
> @@ -5642,7 +5795,6 @@ void copy_extent_buffer(struct extent_buffer *dst, struct extent_buffer *src,
>  
>  	while (len > 0) {
>  		page = dst->pages[i];
> -		WARN_ON(!PageUptodate(page));
>  
>  		cur = min(len, (unsigned long)(PAGE_SIZE - offset));
>  
> @@ -5745,7 +5897,6 @@ int extent_buffer_test_bit(struct extent_buffer *eb, unsigned long start,
>  
>  	eb_bitmap_offset(eb, start, nr, &i, &offset);
>  	page = eb->pages[i];
> -	WARN_ON(!PageUptodate(page));
>  	kaddr = page_address(page);
>  	return 1U & (kaddr[offset] >> (nr & (BITS_PER_BYTE - 1)));
>  }
> @@ -5770,7 +5921,6 @@ void extent_buffer_bitmap_set(struct extent_buffer *eb, unsigned long start,
>  
>  	eb_bitmap_offset(eb, start, pos, &i, &offset);
>  	page = eb->pages[i];
> -	WARN_ON(!PageUptodate(page));
>  	kaddr = page_address(page);
>  
>  	while (len >= bits_to_set) {
> @@ -5781,7 +5931,6 @@ void extent_buffer_bitmap_set(struct extent_buffer *eb, unsigned long start,
>  		if (++offset >= PAGE_SIZE && len > 0) {
>  			offset = 0;
>  			page = eb->pages[++i];
> -			WARN_ON(!PageUptodate(page));
>  			kaddr = page_address(page);
>  		}
>  	}
> @@ -5812,7 +5961,6 @@ void extent_buffer_bitmap_clear(struct extent_buffer *eb, unsigned long start,
>  
>  	eb_bitmap_offset(eb, start, pos, &i, &offset);
>  	page = eb->pages[i];
> -	WARN_ON(!PageUptodate(page));
>  	kaddr = page_address(page);
>  
>  	while (len >= bits_to_clear) {
> @@ -5823,7 +5971,6 @@ void extent_buffer_bitmap_clear(struct extent_buffer *eb, unsigned long start,
>  		if (++offset >= PAGE_SIZE && len > 0) {
>  			offset = 0;
>  			page = eb->pages[++i];
> -			WARN_ON(!PageUptodate(page));
>  			kaddr = page_address(page);
>  		}
>  	}
> @@ -5864,7 +6011,7 @@ static void copy_pages(struct page *dst_page, struct page *src_page,
>  void memcpy_extent_buffer(struct extent_buffer *dst, unsigned long dst_offset,
>  			   unsigned long src_offset, unsigned long len)
>  {
> -	struct btrfs_fs_info *fs_info = dst->fs_info;
> +	struct btrfs_fs_info *fs_info = dst->eb_info->fs_info;
>  	size_t cur;
>  	size_t dst_off_in_page;
>  	size_t src_off_in_page;
> @@ -5911,7 +6058,7 @@ void memcpy_extent_buffer(struct extent_buffer *dst, unsigned long dst_offset,
>  void memmove_extent_buffer(struct extent_buffer *dst, unsigned long dst_offset,
>  			   unsigned long src_offset, unsigned long len)
>  {
> -	struct btrfs_fs_info *fs_info = dst->fs_info;
> +	struct btrfs_fs_info *fs_info = dst->eb_info->fs_info;
>  	size_t cur;
>  	size_t dst_off_in_page;
>  	size_t src_off_in_page;
> @@ -5957,45 +6104,3 @@ void memmove_extent_buffer(struct extent_buffer *dst, unsigned long dst_offset,
>  		len -= cur;
>  	}
>  }
> -
> -int try_release_extent_buffer(struct page *page)
> -{
> -	struct extent_buffer *eb;
> -
> -	/*
> -	 * We need to make sure nobody is attaching this page to an eb right
> -	 * now.
> -	 */
> -	spin_lock(&page->mapping->private_lock);
> -	if (!PagePrivate(page)) {
> -		spin_unlock(&page->mapping->private_lock);
> -		return 1;
> -	}
> -
> -	eb = (struct extent_buffer *)page->private;
> -	BUG_ON(!eb);
> -
> -	/*
> -	 * This is a little awful but should be ok, we need to make sure that
> -	 * the eb doesn't disappear out from under us while we're looking at
> -	 * this page.
> -	 */
> -	spin_lock(&eb->refs_lock);
> -	if (atomic_read(&eb->refs) != 1 || extent_buffer_under_io(eb)) {
> -		spin_unlock(&eb->refs_lock);
> -		spin_unlock(&page->mapping->private_lock);
> -		return 0;
> -	}
> -	spin_unlock(&page->mapping->private_lock);
> -
> -	/*
> -	 * If tree ref isn't set then we know the ref on this eb is a real ref,
> -	 * so just return, this page will likely be freed soon anyway.
> -	 */
> -	if (!test_and_clear_bit(EXTENT_BUFFER_TREE_REF, &eb->bflags)) {
> -		spin_unlock(&eb->refs_lock);
> -		return 0;
> -	}
> -
> -	return release_extent_buffer(eb);
> -}
> diff --git a/fs/btrfs/extent_io.h b/fs/btrfs/extent_io.h
> index 861dacb371c7..f18cbce1f2f1 100644
> --- a/fs/btrfs/extent_io.h
> +++ b/fs/btrfs/extent_io.h
> @@ -47,6 +47,8 @@
>  #define EXTENT_BUFFER_DUMMY 9
>  #define EXTENT_BUFFER_IN_TREE 10
>  #define EXTENT_BUFFER_WRITE_ERR 11    /* write IO error */
> +#define EXTENT_BUFFER_MIXED_PAGES 12	/* the pages span multiple zones or numa nodes. */
> +#define EXTENT_BUFFER_READING 13 /* currently reading this eb. */
>  
>  /* these are flags for __process_pages_contig */
>  #define PAGE_UNLOCK		(1 << 0)
> @@ -160,13 +162,25 @@ struct extent_state {
>  #endif
>  };
>  
> +struct btrfs_eb_info {
> +	struct btrfs_fs_info *fs_info;
> +	struct extent_io_tree io_tree;
> +	struct extent_io_tree io_failure_tree;
> +
> +	/* Extent buffer radix tree */
> +	spinlock_t buffer_lock;
> +	struct radix_tree_root buffer_radix;
> +	struct list_lru lru_list;
> +	pgoff_t writeback_index;
> +};
> +
>  #define INLINE_EXTENT_BUFFER_PAGES 16
>  #define MAX_INLINE_EXTENT_BUFFER_SIZE (INLINE_EXTENT_BUFFER_PAGES * PAGE_SIZE)
>  struct extent_buffer {
>  	u64 start;
>  	unsigned long len;
>  	unsigned long bflags;
> -	struct btrfs_fs_info *fs_info;
> +	struct btrfs_eb_info *eb_info;
>  	spinlock_t refs_lock;
>  	atomic_t refs;
>  	atomic_t io_pages;
> @@ -201,6 +215,7 @@ struct extent_buffer {
>  #ifdef CONFIG_BTRFS_DEBUG
>  	struct list_head leak_list;
>  #endif
> +	struct list_head lru;
>  };
>  
>  /*
> @@ -408,8 +423,6 @@ int extent_writepages(struct extent_io_tree *tree,
>  		      struct address_space *mapping,
>  		      get_extent_t *get_extent,
>  		      struct writeback_control *wbc);
> -int btree_write_cache_pages(struct address_space *mapping,
> -			    struct writeback_control *wbc);
>  int extent_readpages(struct extent_io_tree *tree,
>  		     struct address_space *mapping,
>  		     struct list_head *pages, unsigned nr_pages,
> @@ -420,21 +433,18 @@ void set_page_extent_mapped(struct page *page);
>  
>  struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
>  					  u64 start);
> -struct extent_buffer *__alloc_dummy_extent_buffer(struct btrfs_fs_info *fs_info,
> -						  u64 start, unsigned long len);
> -struct extent_buffer *alloc_dummy_extent_buffer(struct btrfs_fs_info *fs_info,
> -						u64 start);
> +struct extent_buffer *alloc_dummy_extent_buffer(struct btrfs_eb_info *eb_info,
> +						u64 start, unsigned long len);
>  struct extent_buffer *btrfs_clone_extent_buffer(struct extent_buffer *src);
> -struct extent_buffer *find_extent_buffer(struct btrfs_fs_info *fs_info,
> +struct extent_buffer *find_extent_buffer(struct btrfs_eb_info *eb_info,
>  					 u64 start);
>  void free_extent_buffer(struct extent_buffer *eb);
>  void free_extent_buffer_stale(struct extent_buffer *eb);
>  #define WAIT_NONE	0
>  #define WAIT_COMPLETE	1
>  #define WAIT_PAGE_LOCK	2
> -int read_extent_buffer_pages(struct extent_io_tree *tree,
> -			     struct extent_buffer *eb, int wait,
> -			     get_extent_t *get_extent, int mirror_num);
> +int read_extent_buffer_pages(struct extent_buffer *eb, int wait,
> +			     int mirror_num);
>  void wait_on_extent_buffer_writeback(struct extent_buffer *eb);
>  
>  static inline unsigned long num_extent_pages(u64 start, u64 len)
> @@ -448,6 +458,11 @@ static inline void extent_buffer_get(struct extent_buffer *eb)
>  	atomic_inc(&eb->refs);
>  }
>  
> +static inline unsigned long eb_index(struct extent_buffer *eb)
> +{
> +	return eb->start >> PAGE_SHIFT;
> +}
> +
>  int memcmp_extent_buffer(const struct extent_buffer *eb, const void *ptrv,
>  			 unsigned long start, unsigned long len);
>  void read_extent_buffer(const struct extent_buffer *eb, void *dst,
> @@ -478,7 +493,7 @@ void extent_buffer_bitmap_set(struct extent_buffer *eb, unsigned long start,
>  			      unsigned long pos, unsigned long len);
>  void extent_buffer_bitmap_clear(struct extent_buffer *eb, unsigned long start,
>  				unsigned long pos, unsigned long len);
> -void clear_extent_buffer_dirty(struct extent_buffer *eb);
> +int clear_extent_buffer_dirty(struct extent_buffer *eb);
>  int set_extent_buffer_dirty(struct extent_buffer *eb);
>  void set_extent_buffer_uptodate(struct extent_buffer *eb);
>  void clear_extent_buffer_uptodate(struct extent_buffer *eb);
> @@ -512,6 +527,14 @@ int clean_io_failure(struct btrfs_fs_info *fs_info,
>  void end_extent_writepage(struct page *page, int err, u64 start, u64 end);
>  int repair_eb_io_failure(struct btrfs_fs_info *fs_info,
>  			 struct extent_buffer *eb, int mirror_num);
> +void btree_flush(struct btrfs_fs_info *fs_info);
> +int btree_write_range(struct btrfs_fs_info *fs_info, u64 start, u64 end);
> +int btree_wait_range(struct btrfs_fs_info *fs_info, u64 start, u64 end);
> +long btrfs_free_ebs(struct super_block *sb, struct shrink_control *sc);
> +long btrfs_nr_ebs(struct super_block *sb, struct shrink_control *sc);
> +void btrfs_write_ebs(struct super_block *sb, struct writeback_control *wbc);
> +void btrfs_invalidate_eb_info(struct btrfs_eb_info *eb_info);
> +int btrfs_init_eb_info(struct btrfs_fs_info *fs_info);
>  
>  /*
>   * When IO fails, either with EIO or csum verification fails, we
> @@ -552,6 +575,6 @@ noinline u64 find_lock_delalloc_range(struct inode *inode,
>  				      struct page *locked_page, u64 *start,
>  				      u64 *end, u64 max_bytes);
>  #endif
> -struct extent_buffer *alloc_test_extent_buffer(struct btrfs_fs_info *fs_info,
> -					       u64 start);
> +struct extent_buffer *alloc_test_extent_buffer(struct btrfs_eb_info *eb_info,
> +					       u64 start, u32 nodesize);
>  #endif
> diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
> index 46b5632a7c6d..27bc64fb6d3e 100644
> --- a/fs/btrfs/inode.c
> +++ b/fs/btrfs/inode.c
> @@ -1877,9 +1877,9 @@ static void btrfs_clear_bit_hook(void *private_data,
>   * return 0 if page can be merged to bio
>   * return error otherwise
>   */
> -int btrfs_merge_bio_hook(struct page *page, unsigned long offset,
> -			 size_t size, struct bio *bio,
> -			 unsigned long bio_flags)
> +static int btrfs_merge_bio_hook(struct page *page, unsigned long offset,
> +				size_t size, struct bio *bio,
> +				unsigned long bio_flags)
>  {
>  	struct inode *inode = page->mapping->host;
>  	struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
> diff --git a/fs/btrfs/print-tree.c b/fs/btrfs/print-tree.c
> index 569205e651c7..f912c8166d94 100644
> --- a/fs/btrfs/print-tree.c
> +++ b/fs/btrfs/print-tree.c
> @@ -102,6 +102,7 @@ static void print_extent_item(struct extent_buffer *eb, int slot, int type)
>  	ptr = (unsigned long)iref;
>  	end = (unsigned long)ei + item_size;
>  	while (ptr < end) {
> +		struct btrfs_fs_info *fs_info = eb->eb_info->fs_info;
>  		iref = (struct btrfs_extent_inline_ref *)ptr;
>  		type = btrfs_extent_inline_ref_type(eb, iref);
>  		offset = btrfs_extent_inline_ref_offset(eb, iref);
> @@ -116,9 +117,9 @@ static void print_extent_item(struct extent_buffer *eb, int slot, int type)
>  			 * offset is supposed to be a tree block which
>  			 * must be aligned to nodesize.
>  			 */
> -			if (!IS_ALIGNED(offset, eb->fs_info->nodesize))
> +			if (!IS_ALIGNED(offset, fs_info->nodesize))
>  				pr_info("\t\t\t(parent %llu is NOT ALIGNED to nodesize %llu)\n",
> -					offset, (unsigned long long)eb->fs_info->nodesize);
> +					offset, (unsigned long long)fs_info->nodesize);
>  			break;
>  		case BTRFS_EXTENT_DATA_REF_KEY:
>  			dref = (struct btrfs_extent_data_ref *)(&iref->offset);
> @@ -132,9 +133,9 @@ static void print_extent_item(struct extent_buffer *eb, int slot, int type)
>  			 * offset is supposed to be a tree block which
>  			 * must be aligned to nodesize.
>  			 */
> -			if (!IS_ALIGNED(offset, eb->fs_info->nodesize))
> +			if (!IS_ALIGNED(offset, fs_info->nodesize))
>  				pr_info("\t\t\t(parent %llu is NOT ALIGNED to nodesize %llu)\n",
> -				     offset, (unsigned long long)eb->fs_info->nodesize);
> +				     offset, (unsigned long long)fs_info->nodesize);
>  			break;
>  		default:
>  			pr_cont("(extent %llu has INVALID ref type %d)\n",
> @@ -199,7 +200,7 @@ void btrfs_print_leaf(struct extent_buffer *l)
>  	if (!l)
>  		return;
>  
> -	fs_info = l->fs_info;
> +	fs_info = l->eb_info->fs_info;
>  	nr = btrfs_header_nritems(l);
>  
>  	btrfs_info(fs_info, "leaf %llu total ptrs %d free space %d",
> @@ -347,7 +348,7 @@ void btrfs_print_tree(struct extent_buffer *c)
>  
>  	if (!c)
>  		return;
> -	fs_info = c->fs_info;
> +	fs_info = c->eb_info->fs_info;
>  	nr = btrfs_header_nritems(c);
>  	level = btrfs_header_level(c);
>  	if (level == 0) {
> diff --git a/fs/btrfs/reada.c b/fs/btrfs/reada.c
> index ab852b8e3e37..c6244890085f 100644
> --- a/fs/btrfs/reada.c
> +++ b/fs/btrfs/reada.c
> @@ -210,7 +210,7 @@ static void __readahead_hook(struct btrfs_fs_info *fs_info,
>  
>  int btree_readahead_hook(struct extent_buffer *eb, int err)
>  {
> -	struct btrfs_fs_info *fs_info = eb->fs_info;
> +	struct btrfs_fs_info *fs_info = eb->eb_info->fs_info;
>  	int ret = 0;
>  	struct reada_extent *re;
>  
> diff --git a/fs/btrfs/root-tree.c b/fs/btrfs/root-tree.c
> index 3338407ef0f0..e40bd9a910dd 100644
> --- a/fs/btrfs/root-tree.c
> +++ b/fs/btrfs/root-tree.c
> @@ -45,7 +45,7 @@ static void btrfs_read_root_item(struct extent_buffer *eb, int slot,
>  	if (!need_reset && btrfs_root_generation(item)
>  		!= btrfs_root_generation_v2(item)) {
>  		if (btrfs_root_generation_v2(item) != 0) {
> -			btrfs_warn(eb->fs_info,
> +			btrfs_warn(eb->eb_info->fs_info,
>  					"mismatching generation and generation_v2 found in root item. This root was probably mounted with an older kernel. Resetting all new fields.");
>  		}
>  		need_reset = 1;
> diff --git a/fs/btrfs/super.c b/fs/btrfs/super.c
> index 8e74f7029e12..3b5fe791639d 100644
> --- a/fs/btrfs/super.c
> +++ b/fs/btrfs/super.c
> @@ -1198,7 +1198,7 @@ int btrfs_sync_fs(struct super_block *sb, int wait)
>  	trace_btrfs_sync_fs(fs_info, wait);
>  
>  	if (!wait) {
> -		filemap_flush(fs_info->btree_inode->i_mapping);
> +		btree_flush(fs_info);
>  		return 0;
>  	}
>  
> @@ -2284,19 +2284,22 @@ static int btrfs_show_devname(struct seq_file *m, struct dentry *root)
>  }
>  
>  static const struct super_operations btrfs_super_ops = {
> -	.drop_inode	= btrfs_drop_inode,
> -	.evict_inode	= btrfs_evict_inode,
> -	.put_super	= btrfs_put_super,
> -	.sync_fs	= btrfs_sync_fs,
> -	.show_options	= btrfs_show_options,
> -	.show_devname	= btrfs_show_devname,
> -	.write_inode	= btrfs_write_inode,
> -	.alloc_inode	= btrfs_alloc_inode,
> -	.destroy_inode	= btrfs_destroy_inode,
> -	.statfs		= btrfs_statfs,
> -	.remount_fs	= btrfs_remount,
> -	.freeze_fs	= btrfs_freeze,
> -	.unfreeze_fs	= btrfs_unfreeze,
> +	.drop_inode		= btrfs_drop_inode,
> +	.evict_inode		= btrfs_evict_inode,
> +	.put_super		= btrfs_put_super,
> +	.sync_fs		= btrfs_sync_fs,
> +	.show_options		= btrfs_show_options,
> +	.show_devname		= btrfs_show_devname,
> +	.write_inode		= btrfs_write_inode,
> +	.alloc_inode		= btrfs_alloc_inode,
> +	.destroy_inode		= btrfs_destroy_inode,
> +	.statfs			= btrfs_statfs,
> +	.remount_fs		= btrfs_remount,
> +	.freeze_fs		= btrfs_freeze,
> +	.unfreeze_fs		= btrfs_unfreeze,
> +	.nr_cached_objects	= btrfs_nr_ebs,
> +	.free_cached_objects	= btrfs_free_ebs,
> +	.write_metadata		= btrfs_write_ebs,
>  };
>  
>  static const struct file_operations btrfs_ctl_fops = {
> diff --git a/fs/btrfs/tests/btrfs-tests.c b/fs/btrfs/tests/btrfs-tests.c
> index d3f25376a0f8..dbf05b2ab9ee 100644
> --- a/fs/btrfs/tests/btrfs-tests.c
> +++ b/fs/btrfs/tests/btrfs-tests.c
> @@ -102,15 +102,32 @@ struct btrfs_fs_info *btrfs_alloc_dummy_fs_info(u32 nodesize, u32 sectorsize)
>  
>  	fs_info->nodesize = nodesize;
>  	fs_info->sectorsize = sectorsize;
> +	fs_info->eb_info = kzalloc(sizeof(struct btrfs_eb_info),
> +				   GFP_KERNEL);
> +	if (!fs_info->eb_info) {
> +		kfree(fs_info->fs_devices);
> +		kfree(fs_info->super_copy);
> +		kfree(fs_info);
> +		return NULL;
> +	}
> +
> +	if (btrfs_init_eb_info(fs_info)) {
> +		kfree(fs_info->eb_info);
> +		kfree(fs_info->fs_devices);
> +		kfree(fs_info->super_copy);
> +		kfree(fs_info);
> +		return NULL;
> +	}
>  
>  	if (init_srcu_struct(&fs_info->subvol_srcu)) {
> +		list_lru_destroy(&fs_info->eb_info->lru_list);
> +		kfree(fs_info->eb_info);
>  		kfree(fs_info->fs_devices);
>  		kfree(fs_info->super_copy);
>  		kfree(fs_info);
>  		return NULL;
>  	}
>  
> -	spin_lock_init(&fs_info->buffer_lock);
>  	spin_lock_init(&fs_info->qgroup_lock);
>  	spin_lock_init(&fs_info->qgroup_op_lock);
>  	spin_lock_init(&fs_info->super_lock);
> @@ -126,7 +143,6 @@ struct btrfs_fs_info *btrfs_alloc_dummy_fs_info(u32 nodesize, u32 sectorsize)
>  	INIT_LIST_HEAD(&fs_info->dirty_qgroups);
>  	INIT_LIST_HEAD(&fs_info->dead_roots);
>  	INIT_LIST_HEAD(&fs_info->tree_mod_seq_list);
> -	INIT_RADIX_TREE(&fs_info->buffer_radix, GFP_ATOMIC);
>  	INIT_RADIX_TREE(&fs_info->fs_roots_radix, GFP_ATOMIC);
>  	extent_io_tree_init(&fs_info->freed_extents[0], NULL);
>  	extent_io_tree_init(&fs_info->freed_extents[1], NULL);
> @@ -140,6 +156,7 @@ struct btrfs_fs_info *btrfs_alloc_dummy_fs_info(u32 nodesize, u32 sectorsize)
>  
>  void btrfs_free_dummy_fs_info(struct btrfs_fs_info *fs_info)
>  {
> +	struct btrfs_eb_info *eb_info;
>  	struct radix_tree_iter iter;
>  	void **slot;
>  
> @@ -150,13 +167,14 @@ void btrfs_free_dummy_fs_info(struct btrfs_fs_info *fs_info)
>  			      &fs_info->fs_state)))
>  		return;
>  
> +	eb_info = fs_info->eb_info;
>  	test_mnt->mnt_sb->s_fs_info = NULL;
>  
> -	spin_lock(&fs_info->buffer_lock);
> -	radix_tree_for_each_slot(slot, &fs_info->buffer_radix, &iter, 0) {
> +	spin_lock_irq(&eb_info->buffer_lock);
> +	radix_tree_for_each_slot(slot, &eb_info->buffer_radix, &iter, 0) {
>  		struct extent_buffer *eb;
>  
> -		eb = radix_tree_deref_slot_protected(slot, &fs_info->buffer_lock);
> +		eb = radix_tree_deref_slot_protected(slot, &eb_info->buffer_lock);
>  		if (!eb)
>  			continue;
>  		/* Shouldn't happen but that kind of thinking creates CVE's */
> @@ -166,15 +184,17 @@ void btrfs_free_dummy_fs_info(struct btrfs_fs_info *fs_info)
>  			continue;
>  		}
>  		slot = radix_tree_iter_resume(slot, &iter);
> -		spin_unlock(&fs_info->buffer_lock);
> +		spin_unlock_irq(&eb_info->buffer_lock);
>  		free_extent_buffer_stale(eb);
> -		spin_lock(&fs_info->buffer_lock);
> +		spin_lock_irq(&eb_info->buffer_lock);
>  	}
> -	spin_unlock(&fs_info->buffer_lock);
> +	spin_unlock_irq(&eb_info->buffer_lock);
>  
>  	btrfs_free_qgroup_config(fs_info);
>  	btrfs_free_fs_roots(fs_info);
>  	cleanup_srcu_struct(&fs_info->subvol_srcu);
> +	list_lru_destroy(&eb_info->lru_list);
> +	kfree(fs_info->eb_info);
>  	kfree(fs_info->super_copy);
>  	kfree(fs_info->fs_devices);
>  	kfree(fs_info);
> diff --git a/fs/btrfs/tests/extent-buffer-tests.c b/fs/btrfs/tests/extent-buffer-tests.c
> index b9142c614114..9a264b81a7b4 100644
> --- a/fs/btrfs/tests/extent-buffer-tests.c
> +++ b/fs/btrfs/tests/extent-buffer-tests.c
> @@ -61,7 +61,8 @@ static int test_btrfs_split_item(u32 sectorsize, u32 nodesize)
>  		goto out;
>  	}
>  
> -	path->nodes[0] = eb = alloc_dummy_extent_buffer(fs_info, nodesize);
> +	path->nodes[0] = eb = alloc_dummy_extent_buffer(fs_info->eb_info, 0,
> +							nodesize);
>  	if (!eb) {
>  		test_msg("Could not allocate dummy buffer\n");
>  		ret = -ENOMEM;
> diff --git a/fs/btrfs/tests/extent-io-tests.c b/fs/btrfs/tests/extent-io-tests.c
> index d06b1c931d05..600c01ddf0d0 100644
> --- a/fs/btrfs/tests/extent-io-tests.c
> +++ b/fs/btrfs/tests/extent-io-tests.c
> @@ -406,7 +406,7 @@ static int test_eb_bitmaps(u32 sectorsize, u32 nodesize)
>  		return -ENOMEM;
>  	}
>  
> -	eb = __alloc_dummy_extent_buffer(fs_info, 0, len);
> +	eb = alloc_dummy_extent_buffer(NULL, 0, len);
>  	if (!eb) {
>  		test_msg("Couldn't allocate test extent buffer\n");
>  		kfree(bitmap);
> @@ -419,7 +419,7 @@ static int test_eb_bitmaps(u32 sectorsize, u32 nodesize)
>  
>  	/* Do it over again with an extent buffer which isn't page-aligned. */
>  	free_extent_buffer(eb);
> -	eb = __alloc_dummy_extent_buffer(NULL, nodesize / 2, len);
> +	eb = alloc_dummy_extent_buffer(NULL, nodesize / 2, len);
>  	if (!eb) {
>  		test_msg("Couldn't allocate test extent buffer\n");
>  		kfree(bitmap);
> diff --git a/fs/btrfs/tests/free-space-tree-tests.c b/fs/btrfs/tests/free-space-tree-tests.c
> index 8444a018cca2..afba937f4365 100644
> --- a/fs/btrfs/tests/free-space-tree-tests.c
> +++ b/fs/btrfs/tests/free-space-tree-tests.c
> @@ -474,7 +474,8 @@ static int run_test(test_func_t test_func, int bitmaps, u32 sectorsize,
>  	root->fs_info->free_space_root = root;
>  	root->fs_info->tree_root = root;
>  
> -	root->node = alloc_test_extent_buffer(root->fs_info, nodesize);
> +	root->node = alloc_test_extent_buffer(fs_info->eb_info, nodesize,
> +					      nodesize);
>  	if (!root->node) {
>  		test_msg("Couldn't allocate dummy buffer\n");
>  		ret = -ENOMEM;
> diff --git a/fs/btrfs/tests/inode-tests.c b/fs/btrfs/tests/inode-tests.c
> index 11c77eafde00..486aa7fbfce2 100644
> --- a/fs/btrfs/tests/inode-tests.c
> +++ b/fs/btrfs/tests/inode-tests.c
> @@ -261,7 +261,7 @@ static noinline int test_btrfs_get_extent(u32 sectorsize, u32 nodesize)
>  		goto out;
>  	}
>  
> -	root->node = alloc_dummy_extent_buffer(fs_info, nodesize);
> +	root->node = alloc_dummy_extent_buffer(fs_info->eb_info, 0, nodesize);
>  	if (!root->node) {
>  		test_msg("Couldn't allocate dummy buffer\n");
>  		goto out;
> @@ -867,7 +867,7 @@ static int test_hole_first(u32 sectorsize, u32 nodesize)
>  		goto out;
>  	}
>  
> -	root->node = alloc_dummy_extent_buffer(fs_info, nodesize);
> +	root->node = alloc_dummy_extent_buffer(fs_info->eb_info, 0, nodesize);
>  	if (!root->node) {
>  		test_msg("Couldn't allocate dummy buffer\n");
>  		goto out;
> diff --git a/fs/btrfs/tests/qgroup-tests.c b/fs/btrfs/tests/qgroup-tests.c
> index 0f4ce970d195..0ba27cd9ae4c 100644
> --- a/fs/btrfs/tests/qgroup-tests.c
> +++ b/fs/btrfs/tests/qgroup-tests.c
> @@ -486,7 +486,8 @@ int btrfs_test_qgroups(u32 sectorsize, u32 nodesize)
>  	 * Can't use bytenr 0, some things freak out
>  	 * *cough*backref walking code*cough*
>  	 */
> -	root->node = alloc_test_extent_buffer(root->fs_info, nodesize);
> +	root->node = alloc_test_extent_buffer(fs_info->eb_info, nodesize,
> +					      nodesize);
>  	if (!root->node) {
>  		test_msg("Couldn't allocate dummy buffer\n");
>  		ret = -ENOMEM;
> diff --git a/fs/btrfs/transaction.c b/fs/btrfs/transaction.c
> index 9fed8c67b6e8..5df3963c413e 100644
> --- a/fs/btrfs/transaction.c
> +++ b/fs/btrfs/transaction.c
> @@ -293,8 +293,7 @@ static noinline int join_transaction(struct btrfs_fs_info *fs_info,
>  	INIT_LIST_HEAD(&cur_trans->deleted_bgs);
>  	spin_lock_init(&cur_trans->dropped_roots_lock);
>  	list_add_tail(&cur_trans->list, &fs_info->trans_list);
> -	extent_io_tree_init(&cur_trans->dirty_pages,
> -			     fs_info->btree_inode);
> +	extent_io_tree_init(&cur_trans->dirty_pages, NULL);
>  	fs_info->generation++;
>  	cur_trans->transid = fs_info->generation;
>  	fs_info->running_transaction = cur_trans;
> @@ -944,12 +943,10 @@ int btrfs_write_marked_extents(struct btrfs_fs_info *fs_info,
>  {
>  	int err = 0;
>  	int werr = 0;
> -	struct address_space *mapping = fs_info->btree_inode->i_mapping;
>  	struct extent_state *cached_state = NULL;
>  	u64 start = 0;
>  	u64 end;
>  
> -	atomic_inc(&BTRFS_I(fs_info->btree_inode)->sync_writers);
>  	while (!find_first_extent_bit(dirty_pages, start, &start, &end,
>  				      mark, &cached_state)) {
>  		bool wait_writeback = false;
> @@ -975,17 +972,16 @@ int btrfs_write_marked_extents(struct btrfs_fs_info *fs_info,
>  			wait_writeback = true;
>  		}
>  		if (!err)
> -			err = filemap_fdatawrite_range(mapping, start, end);
> +			err = btree_write_range(fs_info, start, end);
>  		if (err)
>  			werr = err;
>  		else if (wait_writeback)
> -			werr = filemap_fdatawait_range(mapping, start, end);
> +			werr = btree_wait_range(fs_info, start, end);
>  		free_extent_state(cached_state);
>  		cached_state = NULL;
>  		cond_resched();
>  		start = end + 1;
>  	}
> -	atomic_dec(&BTRFS_I(fs_info->btree_inode)->sync_writers);
>  	return werr;
>  }
>  
> @@ -1000,7 +996,6 @@ static int __btrfs_wait_marked_extents(struct btrfs_fs_info *fs_info,
>  {
>  	int err = 0;
>  	int werr = 0;
> -	struct address_space *mapping = fs_info->btree_inode->i_mapping;
>  	struct extent_state *cached_state = NULL;
>  	u64 start = 0;
>  	u64 end;
> @@ -1021,7 +1016,7 @@ static int __btrfs_wait_marked_extents(struct btrfs_fs_info *fs_info,
>  		if (err == -ENOMEM)
>  			err = 0;
>  		if (!err)
> -			err = filemap_fdatawait_range(mapping, start, end);
> +			err = btree_wait_range(fs_info, start, end);
>  		if (err)
>  			werr = err;
>  		free_extent_state(cached_state);
> -- 
> 2.7.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-btrfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
