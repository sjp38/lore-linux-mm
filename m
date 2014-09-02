Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id B471B6B0036
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 09:09:15 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id m15so6841701wgh.35
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 06:09:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q15si15029002wiv.87.2014.09.02.06.09.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Sep 2014 06:09:13 -0700 (PDT)
Date: Tue, 2 Sep 2014 09:09:01 -0400
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v2 6/6] mm/balloon_compaction: general cleanup
Message-ID: <20140902130900.GG14419@t510.redhat.com>
References: <20140830163834.29066.98205.stgit@zurg>
 <20140830164127.29066.99498.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140830164127.29066.99498.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Sasha Levin <sasha.levin@oracle.com>

On Sat, Aug 30, 2014 at 08:41:27PM +0400, Konstantin Khlebnikov wrote:
> From: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
> 
> * move special branch for balloon migraion into migrate_pages
> * remove special mapping for balloon and its flag AS_BALLOON_MAP
> * embed struct balloon_dev_info into struct virtio_balloon
> * cleanup balloon_page_dequeue, kill balloon_page_free
> 
> Signed-off-by: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
> ---
>  drivers/virtio/virtio_balloon.c    |   77 ++++---------
>  include/linux/balloon_compaction.h |  127 ++++++---------------
>  include/linux/migrate.h            |   11 --
>  include/linux/pagemap.h            |   18 ---
>  mm/balloon_compaction.c            |  214 ++++++++++++------------------------
>  mm/migrate.c                       |   29 +----
>  6 files changed, 134 insertions(+), 342 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 25ebe8e..c84d6a8 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -59,7 +59,7 @@ struct virtio_balloon
>  	 * Each page on this list adds VIRTIO_BALLOON_PAGES_PER_PAGE
>  	 * to num_pages above.
>  	 */
> -	struct balloon_dev_info *vb_dev_info;
> +	struct balloon_dev_info vb_dev_info;
>  
>  	/* Synchronize access/update to this struct virtio_balloon elements */
>  	struct mutex balloon_lock;
> @@ -127,7 +127,7 @@ static void set_page_pfns(u32 pfns[], struct page *page)
>  
>  static void fill_balloon(struct virtio_balloon *vb, size_t num)
>  {
> -	struct balloon_dev_info *vb_dev_info = vb->vb_dev_info;
> +	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
>  
>  	/* We can only do one array worth at a time. */
>  	num = min(num, ARRAY_SIZE(vb->pfns));
> @@ -163,15 +163,15 @@ static void release_pages_by_pfn(const u32 pfns[], unsigned int num)
>  	/* Find pfns pointing at start of each page, get pages and free them. */
>  	for (i = 0; i < num; i += VIRTIO_BALLOON_PAGES_PER_PAGE) {
>  		struct page *page = balloon_pfn_to_page(pfns[i]);
> -		balloon_page_free(page);
>  		adjust_managed_page_count(page, 1);
> +		put_page(page);
>  	}
>  }
>  
>  static void leak_balloon(struct virtio_balloon *vb, size_t num)
>  {
>  	struct page *page;
> -	struct balloon_dev_info *vb_dev_info = vb->vb_dev_info;
> +	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
>  
>  	/* We can only do one array worth at a time. */
>  	num = min(num, ARRAY_SIZE(vb->pfns));
> @@ -353,12 +353,11 @@ static int init_vqs(struct virtio_balloon *vb)
>  	return 0;
>  }
>  
> -static const struct address_space_operations virtio_balloon_aops;
>  #ifdef CONFIG_BALLOON_COMPACTION
>  /*
>   * virtballoon_migratepage - perform the balloon page migration on behalf of
>   *			     a compation thread.     (called under page lock)
> - * @mapping: the page->mapping which will be assigned to the new migrated page.
> + * @vb_dev_info: the balloon device
>   * @newpage: page that will replace the isolated page after migration finishes.
>   * @page   : the isolated (old) page that is about to be migrated to newpage.
>   * @mode   : compaction mode -- not used for balloon page migration.
> @@ -373,17 +372,13 @@ static const struct address_space_operations virtio_balloon_aops;
>   * This function preforms the balloon page migration task.
>   * Called through balloon_mapping->a_ops->migratepage
>   */
> -static int virtballoon_migratepage(struct address_space *mapping,
> +static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
>  		struct page *newpage, struct page *page, enum migrate_mode mode)
>  {
> -	struct balloon_dev_info *vb_dev_info = balloon_page_device(page);
> -	struct virtio_balloon *vb;
> +	struct virtio_balloon *vb = container_of(vb_dev_info,
> +			struct virtio_balloon, vb_dev_info);
>  	unsigned long flags;
>  
> -	BUG_ON(!vb_dev_info);
> -
> -	vb = vb_dev_info->balloon_device;
> -
>  	/*
>  	 * In order to avoid lock contention while migrating pages concurrently
>  	 * to leak_balloon() or fill_balloon() we just give up the balloon_lock
> @@ -395,42 +390,34 @@ static int virtballoon_migratepage(struct address_space *mapping,
>  	if (!mutex_trylock(&vb->balloon_lock))
>  		return -EAGAIN;
>  
> +	get_page(newpage); /* balloon reference */
> +
>  	/* balloon's page migration 1st step  -- inflate "newpage" */
>  	spin_lock_irqsave(&vb_dev_info->pages_lock, flags);
> -	balloon_page_insert(newpage, mapping, &vb_dev_info->pages);
> +	balloon_page_insert(vb_dev_info, newpage);
>  	vb_dev_info->isolated_pages--;
>  	spin_unlock_irqrestore(&vb_dev_info->pages_lock, flags);
>  	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
>  	set_page_pfns(vb->pfns, newpage);
>  	tell_host(vb, vb->inflate_vq);
>  
> -	/*
> -	 * balloon's page migration 2nd step -- deflate "page"
> -	 *
> -	 * It's safe to delete page->lru here because this page is at
> -	 * an isolated migration list, and this step is expected to happen here
> -	 */
> -	balloon_page_delete(page);
> +	/* balloon's page migration 2nd step -- deflate "page" */
> +	balloon_page_delete(page, true);
>  	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
>  	set_page_pfns(vb->pfns, page);
>  	tell_host(vb, vb->deflate_vq);
>  
>  	mutex_unlock(&vb->balloon_lock);
>  
> -	return MIGRATEPAGE_BALLOON_SUCCESS;
> -}
> +	put_page(page); /* balloon reference */
>  
> -/* define the balloon_mapping->a_ops callback to allow balloon page migration */
> -static const struct address_space_operations virtio_balloon_aops = {
> -			.migratepage = virtballoon_migratepage,
> -};
> +	return MIGRATEPAGE_SUCCESS;
> +}
>  #endif /* CONFIG_BALLOON_COMPACTION */
>  
>  static int virtballoon_probe(struct virtio_device *vdev)
>  {
>  	struct virtio_balloon *vb;
> -	struct address_space *vb_mapping;
> -	struct balloon_dev_info *vb_devinfo;
>  	int err;
>  
>  	vdev->priv = vb = kmalloc(sizeof(*vb), GFP_KERNEL);
> @@ -446,30 +433,14 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  	vb->vdev = vdev;
>  	vb->need_stats_update = 0;
>  
> -	vb_devinfo = balloon_devinfo_alloc(vb);
> -	if (IS_ERR(vb_devinfo)) {
> -		err = PTR_ERR(vb_devinfo);
> -		goto out_free_vb;
> -	}
> -
> -	vb_mapping = balloon_mapping_alloc(vb_devinfo,
> -					   (balloon_compaction_check()) ?
> -					   &virtio_balloon_aops : NULL);
> -	if (IS_ERR(vb_mapping)) {
> -		/*
> -		 * IS_ERR(vb_mapping) && PTR_ERR(vb_mapping) == -EOPNOTSUPP
> -		 * This means !CONFIG_BALLOON_COMPACTION, otherwise we get off.
> -		 */
> -		err = PTR_ERR(vb_mapping);
> -		if (err != -EOPNOTSUPP)
> -			goto out_free_vb_devinfo;
> -	}
> -
> -	vb->vb_dev_info = vb_devinfo;
> +	balloon_devinfo_init(&vb->vb_dev_info);
> +#ifdef CONFIG_BALLOON_COMPACTION
> +	vb->vb_dev_info.migratepage = virtballoon_migratepage;
> +#endif
>  
>  	err = init_vqs(vb);
>  	if (err)
> -		goto out_free_vb_mapping;
> +		goto out_free_vb;
>  
>  	vb->thread = kthread_run(balloon, vb, "vballoon");
>  	if (IS_ERR(vb->thread)) {
> @@ -481,10 +452,6 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  
>  out_del_vqs:
>  	vdev->config->del_vqs(vdev);
> -out_free_vb_mapping:
> -	balloon_mapping_free(vb_mapping);
> -out_free_vb_devinfo:
> -	balloon_devinfo_free(vb_devinfo);
>  out_free_vb:
>  	kfree(vb);
>  out:
> @@ -510,8 +477,6 @@ static void virtballoon_remove(struct virtio_device *vdev)
>  
>  	kthread_stop(vb->thread);
>  	remove_common(vb);
> -	balloon_mapping_free(vb->vb_dev_info->mapping);
> -	balloon_devinfo_free(vb->vb_dev_info);
>  	kfree(vb);
>  }
>  
> diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
> index 09f8c5a..ad112fcc6 100644
> --- a/include/linux/balloon_compaction.h
> +++ b/include/linux/balloon_compaction.h
> @@ -56,96 +56,58 @@
>   * balloon driver as a page book-keeper for its registered balloon devices.
>   */
>  struct balloon_dev_info {
> -	void *balloon_device;		/* balloon device descriptor */
> -	struct address_space *mapping;	/* balloon special page->mapping */
>  	unsigned long isolated_pages;	/* # of isolated pages for migration */
>  	spinlock_t pages_lock;		/* Protection to pages list */
>  	struct list_head pages;		/* Pages enqueued & handled to Host */
> +	int (*migratepage)(struct balloon_dev_info *, struct page *newpage,
> +			struct page *page, enum migrate_mode mode);
>  };
>  
> -extern struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info);
> -extern struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info);
> -extern struct balloon_dev_info *balloon_devinfo_alloc(
> -						void *balloon_dev_descriptor);
> -
> -static inline void balloon_devinfo_free(struct balloon_dev_info *b_dev_info)
> +static inline void balloon_devinfo_init(struct balloon_dev_info *b_dev_info)
>  {
> -	kfree(b_dev_info);
> +	b_dev_info->isolated_pages = 0;
> +	spin_lock_init(&b_dev_info->pages_lock);
> +	INIT_LIST_HEAD(&b_dev_info->pages);
> +	b_dev_info->migratepage = NULL;
>  }
>  
> -/*
> - * balloon_page_free - release a balloon page back to the page free lists
> - * @page: ballooned page to be set free
> - *
> - * This function must be used to properly set free an isolated/dequeued balloon
> - * page at the end of a sucessful page migration, or at the balloon driver's
> - * page release procedure.
> - */
> -static inline void balloon_page_free(struct page *page)
> -{
> -	/*
> -	 * Balloon pages always get an extra refcount before being isolated
> -	 * and before being dequeued to help on sorting out fortuite colisions
> -	 * between a thread attempting to isolate and another thread attempting
> -	 * to release the very same balloon page.
> -	 *
> -	 * Before we handle the page back to Buddy, lets drop its extra refcnt.
> -	 */
> -	put_page(page);
> -	__free_page(page);
> -}
> +extern struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info);
> +extern struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info);
>  
>  /*
> - * balloon_page_insert - insert a page into the balloon's page list and make
> - *		         the page->mapping assignment accordingly.
> - * @page    : page to be assigned as a 'balloon page'
> - * @mapping : allocated special 'balloon_mapping'
> - * @head    : balloon's device page list head
> + * balloon_page_insert - insert a page into the balloon's page list,
> + *			 mark and account it accordingly.
> + * @b_dev_info : pinter to ballon device
> + * @page       : page to be assigned as a 'balloon page'
>   *
>   * Caller must ensure the page is locked and the spin_lock protecting balloon
>   * pages list is held before inserting a page into the balloon device.
>   */
> -static inline void balloon_page_insert(struct page *page,
> -				       struct address_space *mapping,
> -				       struct list_head *head)
> +static inline void
> +balloon_page_insert(struct balloon_dev_info *b_dev_info, struct page *page)
>  {
>  	__SetPageBalloon(page);
>  	inc_zone_page_state(page, NR_BALLOON_PAGES);
> -	page->mapping = mapping;
> -	list_add(&page->lru, head);
> +	set_page_private(page, (unsigned long)b_dev_info);
> +	list_add(&page->lru, &b_dev_info->pages);
>  }
>  
>  /*
>   * balloon_page_delete - delete a page from balloon's page list and clear
> - *			 the page->mapping assignement accordingly.
> + *			 the ballon page mark accordingly.
>   * @page    : page to be released from balloon's page list
> + * @isolated: already isolated, do not delete from list
>   *
>   * Caller must ensure the page is locked and the spin_lock protecting balloon
>   * pages list is held before deleting a page from the balloon device.
>   */
> -static inline void balloon_page_delete(struct page *page)
> +static inline void balloon_page_delete(struct page *page, bool isolated)
>  {
>  	__ClearPageBalloon(page);
>  	dec_zone_page_state(page, NR_BALLOON_PAGES);
> -	page->mapping = NULL;
> -	list_del(&page->lru);
> -}
> -
> -#endif /* CONFIG_MEMORY_BALLOON */
> -
> -#ifdef CONFIG_BALLOON_COMPACTION
> -
> -extern bool balloon_page_isolate(struct page *page);
> -extern void balloon_page_putback(struct page *page);
> -extern int balloon_page_migrate(struct page *newpage,
> -				struct page *page, enum migrate_mode mode);
> -extern struct address_space
> -*balloon_mapping_alloc(struct balloon_dev_info *b_dev_info,
> -			const struct address_space_operations *a_ops);
> -
> -static inline void balloon_mapping_free(struct address_space *balloon_mapping)
> -{
> -	kfree(balloon_mapping);
> +	set_page_private(page, 0);
> +	if (!isolated)
> +		list_del(&page->lru);
>  }
>  
>  /*
> @@ -154,35 +116,25 @@ static inline void balloon_mapping_free(struct address_space *balloon_mapping)
>   */
>  static inline struct balloon_dev_info *balloon_page_device(struct page *page)
>  {
> -	struct address_space *mapping = page->mapping;
> -	if (likely(mapping))
> -		return mapping->private_data;
> -
> -	return NULL;
> +	return (struct balloon_dev_info *)page_private(page);
>  }
>  
> -static inline gfp_t balloon_mapping_gfp_mask(void)
> -{
> -	return GFP_HIGHUSER_MOVABLE;
> -}
> +#endif /* CONFIG_MEMORY_BALLOON */
>  
> -static inline bool balloon_compaction_check(void)
> -{
> -	return true;
> -}
> +#ifdef CONFIG_BALLOON_COMPACTION
> +extern bool balloon_page_isolate(struct page *page);
> +extern void balloon_page_putback(struct page *page);
>  
> -#else /* !CONFIG_BALLOON_COMPACTION */
> +int balloon_page_migrate(new_page_t get_new_page, free_page_t put_new_page,
> +		unsigned long private, struct page *page,
> +		int force, enum migrate_mode mode);
>  
> -static inline void *balloon_mapping_alloc(void *balloon_device,
> -				const struct address_space_operations *a_ops)
> +static inline gfp_t balloon_mapping_gfp_mask(void)
>  {
> -	return ERR_PTR(-EOPNOTSUPP);
> +	return GFP_HIGHUSER_MOVABLE;
>  }
>  
> -static inline void balloon_mapping_free(struct address_space *balloon_mapping)
> -{
> -	return;
> -}
> +#else /* !CONFIG_BALLOON_COMPACTION */
>  
>  static inline bool balloon_page_isolate(struct page *page)
>  {
> @@ -194,10 +146,11 @@ static inline void balloon_page_putback(struct page *page)
>  	return;
>  }
>  
> -static inline int balloon_page_migrate(struct page *newpage,
> -				struct page *page, enum migrate_mode mode)
> +static inline int balloon_page_migrate(new_page_t get_new_page,
> +		free_page_t put_new_page, unsigned long private,
> +		struct page *page, int force, enum migrate_mode mode)
>  {
> -	return 0;
> +	return -EAGAIN;
>  }
>  
>  static inline gfp_t balloon_mapping_gfp_mask(void)
> @@ -205,9 +158,5 @@ static inline gfp_t balloon_mapping_gfp_mask(void)
>  	return GFP_HIGHUSER;
>  }
>  
> -static inline bool balloon_compaction_check(void)
> -{
> -	return false;
> -}
>  #endif /* CONFIG_BALLOON_COMPACTION */
>  #endif /* _LINUX_BALLOON_COMPACTION_H */
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index 0a4604a..cf90776 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -13,18 +13,9 @@ typedef void free_page_t(struct page *page, unsigned long private);
>   * Return values from addresss_space_operations.migratepage():
>   * - negative errno on page migration failure;
>   * - zero on page migration success;
> - *
> - * The balloon page migration introduces this special case where a 'distinct'
> - * return code is used to flag a successful page migration to unmap_and_move().
> - * This approach is necessary because page migration can race against balloon
> - * deflation procedure, and for such case we could introduce a nasty page leak
> - * if a successfully migrated balloon page gets released concurrently with
> - * migration's unmap_and_move() wrap-up steps.
>   */
>  #define MIGRATEPAGE_SUCCESS		0
> -#define MIGRATEPAGE_BALLOON_SUCCESS	1 /* special ret code for balloon page
> -					   * sucessful migration case.
> -					   */
> +
>  enum migrate_reason {
>  	MR_COMPACTION,
>  	MR_MEMORY_FAILURE,
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 5ba1813..210b46b 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -24,8 +24,7 @@ enum mapping_flags {
>  	AS_ENOSPC	= __GFP_BITS_SHIFT + 1,	/* ENOSPC on async write */
>  	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
>  	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
> -	AS_BALLOON_MAP  = __GFP_BITS_SHIFT + 4, /* balloon page special map */
> -	AS_EXITING	= __GFP_BITS_SHIFT + 5, /* final truncate in progress */
> +	AS_EXITING	= __GFP_BITS_SHIFT + 4, /* final truncate in progress */
>  };
>  
>  static inline void mapping_set_error(struct address_space *mapping, int error)
> @@ -55,21 +54,6 @@ static inline int mapping_unevictable(struct address_space *mapping)
>  	return !!mapping;
>  }
>  
> -static inline void mapping_set_balloon(struct address_space *mapping)
> -{
> -	set_bit(AS_BALLOON_MAP, &mapping->flags);
> -}
> -
> -static inline void mapping_clear_balloon(struct address_space *mapping)
> -{
> -	clear_bit(AS_BALLOON_MAP, &mapping->flags);
> -}
> -
> -static inline int mapping_balloon(struct address_space *mapping)
> -{
> -	return mapping && test_bit(AS_BALLOON_MAP, &mapping->flags);
> -}
> -
>  static inline void mapping_set_exiting(struct address_space *mapping)
>  {
>  	set_bit(AS_EXITING, &mapping->flags);
> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
> index a942081..3c8cb7a 100644
> --- a/mm/balloon_compaction.c
> +++ b/mm/balloon_compaction.c
> @@ -11,32 +11,6 @@
>  #include <linux/balloon_compaction.h>
>  
>  /*
> - * balloon_devinfo_alloc - allocates a balloon device information descriptor.
> - * @balloon_dev_descriptor: pointer to reference the balloon device which
> - *                          this struct balloon_dev_info will be servicing.
> - *
> - * Driver must call it to properly allocate and initialize an instance of
> - * struct balloon_dev_info which will be used to reference a balloon device
> - * as well as to keep track of the balloon device page list.
> - */
> -struct balloon_dev_info *balloon_devinfo_alloc(void *balloon_dev_descriptor)
> -{
> -	struct balloon_dev_info *b_dev_info;
> -	b_dev_info = kmalloc(sizeof(*b_dev_info), GFP_KERNEL);
> -	if (!b_dev_info)
> -		return ERR_PTR(-ENOMEM);
> -
> -	b_dev_info->balloon_device = balloon_dev_descriptor;
> -	b_dev_info->mapping = NULL;
> -	b_dev_info->isolated_pages = 0;
> -	spin_lock_init(&b_dev_info->pages_lock);
> -	INIT_LIST_HEAD(&b_dev_info->pages);
> -
> -	return b_dev_info;
> -}
> -EXPORT_SYMBOL_GPL(balloon_devinfo_alloc);
> -
> -/*
>   * balloon_page_enqueue - allocates a new page and inserts it into the balloon
>   *			  page list.
>   * @b_dev_info: balloon device decriptor where we will insert a new page to
> @@ -61,7 +35,7 @@ struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info)
>  	 */
>  	BUG_ON(!trylock_page(page));
>  	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
> -	balloon_page_insert(page, b_dev_info->mapping, &b_dev_info->pages);
> +	balloon_page_insert(b_dev_info, page);
>  	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
>  	unlock_page(page);
>  	return page;
> @@ -81,12 +55,10 @@ EXPORT_SYMBOL_GPL(balloon_page_enqueue);
>   */
>  struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
>  {
> -	struct page *page, *tmp;
> +	struct page *page;
>  	unsigned long flags;
> -	bool dequeued_page;
>  
> -	dequeued_page = false;
> -	list_for_each_entry_safe(page, tmp, &b_dev_info->pages, lru) {
> +	list_for_each_entry(page, &b_dev_info->pages, lru) {
>  		/*
>  		 * Block others from accessing the 'page' while we get around
>  		 * establishing additional references and preparing the 'page'
> @@ -94,98 +66,32 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
>  		 */
>  		if (trylock_page(page)) {
>  			spin_lock_irqsave(&b_dev_info->pages_lock, flags);
> -			/*
> -			 * Raise the page refcount here to prevent any wrong
> -			 * attempt to isolate this page, in case of coliding
> -			 * with balloon_page_isolate() just after we release
> -			 * the page lock.
> -			 *
> -			 * balloon_page_free() will take care of dropping
> -			 * this extra refcount later.
> -			 */
> -			get_page(page);
> -			balloon_page_delete(page);
> +			balloon_page_delete(page, false);
>  			spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
>  			unlock_page(page);
> -			dequeued_page = true;
> -			break;
> +			return page;
>  		}
>  	}
>  
> -	if (!dequeued_page) {
> -		/*
> -		 * If we are unable to dequeue a balloon page because the page
> -		 * list is empty and there is no isolated pages, then something
> -		 * went out of track and some balloon pages are lost.
> -		 * BUG() here, otherwise the balloon driver may get stuck into
> -		 * an infinite loop while attempting to release all its pages.
> -		 */
> -		spin_lock_irqsave(&b_dev_info->pages_lock, flags);
> -		if (unlikely(list_empty(&b_dev_info->pages) &&
> -			     !b_dev_info->isolated_pages))
> -			BUG();
> -		spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
> -		page = NULL;
> -	}
> -	return page;
> +	/*
> +	 * If we are unable to dequeue a balloon page because the page
> +	 * list is empty and there is no isolated pages, then something
> +	 * went out of track and some balloon pages are lost.
> +	 * BUG() here, otherwise the balloon driver may get stuck into
> +	 * an infinite loop while attempting to release all its pages.
> +	 */
> +	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
> +	BUG_ON(list_empty(&b_dev_info->pages) && !b_dev_info->isolated_pages);
> +	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
> +	return NULL;
>  }
>  EXPORT_SYMBOL_GPL(balloon_page_dequeue);
>  
>  #ifdef CONFIG_BALLOON_COMPACTION
> -/*
> - * balloon_mapping_alloc - allocates a special ->mapping for ballooned pages.
> - * @b_dev_info: holds the balloon device information descriptor.
> - * @a_ops: balloon_mapping address_space_operations descriptor.
> - *
> - * Driver must call it to properly allocate and initialize an instance of
> - * struct address_space which will be used as the special page->mapping for
> - * balloon device enlisted page instances.
> - */
> -struct address_space *balloon_mapping_alloc(struct balloon_dev_info *b_dev_info,
> -				const struct address_space_operations *a_ops)
> -{
> -	struct address_space *mapping;
> -
> -	mapping = kmalloc(sizeof(*mapping), GFP_KERNEL);
> -	if (!mapping)
> -		return ERR_PTR(-ENOMEM);
> -
> -	/*
> -	 * Give a clean 'zeroed' status to all elements of this special
> -	 * balloon page->mapping struct address_space instance.
> -	 */
> -	address_space_init_once(mapping);
> -
> -	/*
> -	 * Set mapping->flags appropriately, to allow balloon pages
> -	 * ->mapping identification.
> -	 */
> -	mapping_set_balloon(mapping);
> -	mapping_set_gfp_mask(mapping, balloon_mapping_gfp_mask());
> -
> -	/* balloon's page->mapping->a_ops callback descriptor */
> -	mapping->a_ops = a_ops;
> -
> -	/*
> -	 * Establish a pointer reference back to the balloon device descriptor
> -	 * this particular page->mapping will be servicing.
> -	 * This is used by compaction / migration procedures to identify and
> -	 * access the balloon device pageset while isolating / migrating pages.
> -	 *
> -	 * As some balloon drivers can register multiple balloon devices
> -	 * for a single guest, this also helps compaction / migration to
> -	 * properly deal with multiple balloon pagesets, when required.
> -	 */
> -	mapping->private_data = b_dev_info;
> -	b_dev_info->mapping = mapping;
> -
> -	return mapping;
> -}
> -EXPORT_SYMBOL_GPL(balloon_mapping_alloc);
>  
>  static inline void __isolate_balloon_page(struct page *page)
>  {
> -	struct balloon_dev_info *b_dev_info = page->mapping->private_data;
> +	struct balloon_dev_info *b_dev_info = balloon_page_device(page);
>  	unsigned long flags;
>  	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
>  	list_del(&page->lru);
> @@ -195,7 +101,7 @@ static inline void __isolate_balloon_page(struct page *page)
>  
>  static inline void __putback_balloon_page(struct page *page)
>  {
> -	struct balloon_dev_info *b_dev_info = page->mapping->private_data;
> +	struct balloon_dev_info *b_dev_info = balloon_page_device(page);
>  	unsigned long flags;
>  	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
>  	list_add(&page->lru, &b_dev_info->pages);
> @@ -203,12 +109,6 @@ static inline void __putback_balloon_page(struct page *page)
>  	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
>  }
>  
> -static inline int __migrate_balloon_page(struct address_space *mapping,
> -		struct page *newpage, struct page *page, enum migrate_mode mode)
> -{
> -	return page->mapping->a_ops->migratepage(mapping, newpage, page, mode);
> -}
> -
>  /* __isolate_lru_page() counterpart for a ballooned page */
>  bool balloon_page_isolate(struct page *page)
>  {
> @@ -251,6 +151,57 @@ bool balloon_page_isolate(struct page *page)
>  	return false;
>  }
>  
> +int balloon_page_migrate(new_page_t get_new_page, free_page_t put_new_page,
> +			 unsigned long private, struct page *page,
> +			 int force, enum migrate_mode mode)
> +{
> +	struct balloon_dev_info *balloon = balloon_page_device(page);
> +	struct page *newpage;
> +	int *result = NULL;
> +	int rc = -EAGAIN;
> +
> +	if (!balloon || !balloon->migratepage)
> +		return -EAGAIN;
> +
> +	newpage = get_new_page(page, private, &result);
> +	if (!newpage)
> +		return -ENOMEM;
> +
> +	if (!trylock_page(newpage))
> +		BUG();
> +
> +	if (!trylock_page(page)) {
> +		if (!force || mode != MIGRATE_SYNC)
> +			goto out;
> +		lock_page(page);
> +	}
> +
> +	rc = balloon->migratepage(balloon, newpage, page, mode);
> +
> +	unlock_page(page);
> +out:
> +	unlock_page(newpage);
> +
> +	if (rc != -EAGAIN) {
> +		dec_zone_page_state(page, NR_ISOLATED_FILE);
> +		list_del(&page->lru);
> +		put_page(page);
> +	}
> +
> +	if (rc != MIGRATEPAGE_SUCCESS && put_new_page)
> +		put_new_page(newpage, private);
> +	else
> +		put_page(newpage);
> +
> +	if (result) {
> +		if (rc)
> +			*result = rc;
> +		else
> +			*result = page_to_nid(newpage);
> +	}
> +	return rc;
> +}
> +
>  /* putback_lru_page() counterpart for a ballooned page */
>  void balloon_page_putback(struct page *page)
>  {
> @@ -271,31 +222,4 @@ void balloon_page_putback(struct page *page)
>  	unlock_page(page);
>  }
>  
> -/* move_to_new_page() counterpart for a ballooned page */
> -int balloon_page_migrate(struct page *newpage,
> -			 struct page *page, enum migrate_mode mode)
> -{
> -	struct address_space *mapping;
> -	int rc = -EAGAIN;
> -
> -	/*
> -	 * Block others from accessing the 'newpage' when we get around to
> -	 * establishing additional references. We should be the only one
> -	 * holding a reference to the 'newpage' at this point.
> -	 */
> -	BUG_ON(!trylock_page(newpage));
> -
> -	if (WARN_ON(!PageBalloon(page))) {
> -		dump_page(page, "not movable balloon page");
> -		unlock_page(newpage);
> -		return rc;
> -	}
> -
> -	mapping = page->mapping;
> -	if (mapping)
> -		rc = __migrate_balloon_page(mapping, newpage, page, mode);
> -
> -	unlock_page(newpage);
> -	return rc;
> -}
>  #endif /* CONFIG_BALLOON_COMPACTION */
> diff --git a/mm/migrate.c b/mm/migrate.c
> index a4939b1..e6d0d2d 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -873,18 +873,6 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>  		}
>  	}
>  
> -	if (unlikely(PageBalloon(page))) {
> -		/*
> -		 * A ballooned page does not need any special attention from
> -		 * physical to virtual reverse mapping procedures.
> -		 * Skip any attempt to unmap PTEs or to remap swap cache,
> -		 * in order to avoid burning cycles at rmap level, and perform
> -		 * the page migration right away (proteced by page lock).
> -		 */
> -		rc = balloon_page_migrate(newpage, page, mode);
> -		goto out_unlock;
> -	}
> -
>  	/*
>  	 * Corner case handling:
>  	 * 1. When a new swap-cache page is read into, it is added to the LRU
> @@ -952,19 +940,6 @@ static int unmap_and_move(new_page_t get_new_page, free_page_t put_new_page,
>  
>  	rc = __unmap_and_move(page, newpage, force, mode);
>  
> -#ifdef CONFIG_MEMORY_BALLOON
> -	if (unlikely(rc == MIGRATEPAGE_BALLOON_SUCCESS)) {
> -		/*
> -		 * A ballooned page has been migrated already.
> -		 * Now, it's the time to wrap-up counters,
> -		 * handle the page back to Buddy and return.
> -		 */
> -		dec_zone_page_state(page, NR_ISOLATED_ANON +
> -				    page_is_file_cache(page));
> -		balloon_page_free(page);
> -		return MIGRATEPAGE_SUCCESS;
> -	}
> -#endif
>  out:
>  	if (rc != -EAGAIN) {
>  		/*
> @@ -1139,6 +1114,10 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
>  				rc = unmap_and_move_huge_page(get_new_page,
>  						put_new_page, private, page,
>  						pass > 2, mode);
> +			else if (PageBalloon(page))
> +				rc = balloon_page_migrate(get_new_page,
> +						put_new_page, private,
> +						page, pass > 2, mode);
>  			else
>  				rc = unmap_and_move(get_new_page, put_new_page,
>  						private, page, pass > 2, mode);
> 
Acked-by: Rafael Aquini <aquini@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
