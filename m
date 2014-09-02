Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7836B0038
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 08:57:43 -0400 (EDT)
Received: by mail-qc0-f171.google.com with SMTP id x3so6637473qcv.2
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 05:57:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 36si5101556qgx.35.2014.09.02.05.57.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Sep 2014 05:57:42 -0700 (PDT)
Date: Tue, 2 Sep 2014 08:57:31 -0400
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v2 5/6] mm/balloon_compaction: use common page ballooning
Message-ID: <20140902125730.GF14419@t510.redhat.com>
References: <20140830163834.29066.98205.stgit@zurg>
 <20140830164123.29066.26554.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140830164123.29066.26554.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Sasha Levin <sasha.levin@oracle.com>

On Sat, Aug 30, 2014 at 08:41:23PM +0400, Konstantin Khlebnikov wrote:
> From: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
> 
> This patch replaces checking AS_BALLOON_MAP in page->mapping->flags
> with PageBalloon which is stored directly in the struct page.
> All code of balloon_compaction now under CONFIG_MEMORY_BALLOON.
> 
> Signed-off-by: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
> ---
>  drivers/virtio/Kconfig             |    1 
>  include/linux/balloon_compaction.h |  135 ++++++------------------------------
>  mm/Kconfig                         |    2 -
>  mm/Makefile                        |    3 +
>  mm/balloon_compaction.c            |    7 +-
>  mm/compaction.c                    |    9 +-
>  mm/migrate.c                       |    6 +-
>  mm/vmscan.c                        |    2 -
>  8 files changed, 39 insertions(+), 126 deletions(-)
> 
> diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> index c6683f2..00b2286 100644
> --- a/drivers/virtio/Kconfig
> +++ b/drivers/virtio/Kconfig
> @@ -25,6 +25,7 @@ config VIRTIO_PCI
>  config VIRTIO_BALLOON
>  	tristate "Virtio balloon driver"
>  	depends on VIRTIO
> +	select MEMORY_BALLOON
>  	---help---
>  	 This driver supports increasing and decreasing the amount
>  	 of memory within a KVM guest.
> diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
> index 284fc1d..09f8c5a 100644
> --- a/include/linux/balloon_compaction.h
> +++ b/include/linux/balloon_compaction.h
> @@ -46,6 +46,8 @@
>  #include <linux/gfp.h>
>  #include <linux/err.h>
>  
> +#ifdef CONFIG_MEMORY_BALLOON
> +
>  /*
>   * Balloon device information descriptor.
>   * This struct is used to allow the common balloon compaction interface
> @@ -93,91 +95,6 @@ static inline void balloon_page_free(struct page *page)
>  	__free_page(page);
>  }
>  
> -#ifdef CONFIG_BALLOON_COMPACTION
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
> -}
> -
> -/*
> - * page_flags_cleared - helper to perform balloon @page ->flags tests.
> - *
> - * As balloon pages are obtained from buddy and we do not play with page->flags
> - * at driver level (exception made when we get the page lock for compaction),
> - * we can safely identify a ballooned page by checking if the
> - * PAGE_FLAGS_CHECK_AT_PREP page->flags are all cleared.  This approach also
> - * helps us skip ballooned pages that are locked for compaction or release, thus
> - * mitigating their racy check at balloon_page_movable()
> - */
> -static inline bool page_flags_cleared(struct page *page)
> -{
> -	return !(page->flags & PAGE_FLAGS_CHECK_AT_PREP);
> -}
> -
> -/*
> - * __is_movable_balloon_page - helper to perform @page mapping->flags tests
> - */
> -static inline bool __is_movable_balloon_page(struct page *page)
> -{
> -	struct address_space *mapping = page->mapping;
> -	return !PageAnon(page) && mapping_balloon(mapping);
> -}
> -
> -/*
> - * balloon_page_movable - test page->mapping->flags to identify balloon pages
> - *			  that can be moved by compaction/migration.
> - *
> - * This function is used at core compaction's page isolation scheme, therefore
> - * most pages exposed to it are not enlisted as balloon pages and so, to avoid
> - * undesired side effects like racing against __free_pages(), we cannot afford
> - * holding the page locked while testing page->mapping->flags here.
> - *
> - * As we might return false positives in the case of a balloon page being just
> - * released under us, the page->mapping->flags need to be re-tested later,
> - * under the proper page lock, at the functions that will be coping with the
> - * balloon page case.
> - */
> -static inline bool balloon_page_movable(struct page *page)
> -{
> -	/*
> -	 * Before dereferencing and testing mapping->flags, let's make sure
> -	 * this is not a page that uses ->mapping in a different way
> -	 */
> -	if (page_flags_cleared(page) && !page_mapped(page) &&
> -	    page_count(page) == 1)
> -		return __is_movable_balloon_page(page);
> -
> -	return false;
> -}
> -
> -/*
> - * isolated_balloon_page - identify an isolated balloon page on private
> - *			   compaction/migration page lists.
> - *
> - * After a compaction thread isolates a balloon page for migration, it raises
> - * the page refcount to prevent concurrent compaction threads from re-isolating
> - * the same page. For that reason putback_movable_pages(), or other routines
> - * that need to identify isolated balloon pages on private pagelists, cannot
> - * rely on balloon_page_movable() to accomplish the task.
> - */
> -static inline bool isolated_balloon_page(struct page *page)
> -{
> -	/* Already isolated balloon pages, by default, have a raised refcount */
> -	if (page_flags_cleared(page) && !page_mapped(page) &&
> -	    page_count(page) >= 2)
> -		return __is_movable_balloon_page(page);
> -
> -	return false;
> -}
> -
>  /*
>   * balloon_page_insert - insert a page into the balloon's page list and make
>   *		         the page->mapping assignment accordingly.
> @@ -192,6 +109,8 @@ static inline void balloon_page_insert(struct page *page,
>  				       struct address_space *mapping,
>  				       struct list_head *head)
>  {
> +	__SetPageBalloon(page);
> +	inc_zone_page_state(page, NR_BALLOON_PAGES);
>  	page->mapping = mapping;
>  	list_add(&page->lru, head);
>  }
> @@ -206,10 +125,29 @@ static inline void balloon_page_insert(struct page *page,
>   */
>  static inline void balloon_page_delete(struct page *page)
>  {
> +	__ClearPageBalloon(page);
> +	dec_zone_page_state(page, NR_BALLOON_PAGES);
>  	page->mapping = NULL;
>  	list_del(&page->lru);
>  }
>  
> +#endif /* CONFIG_MEMORY_BALLOON */
> +
> +#ifdef CONFIG_BALLOON_COMPACTION
> +
> +extern bool balloon_page_isolate(struct page *page);
> +extern void balloon_page_putback(struct page *page);
> +extern int balloon_page_migrate(struct page *newpage,
> +				struct page *page, enum migrate_mode mode);
> +extern struct address_space
> +*balloon_mapping_alloc(struct balloon_dev_info *b_dev_info,
> +			const struct address_space_operations *a_ops);
> +
> +static inline void balloon_mapping_free(struct address_space *balloon_mapping)
> +{
> +	kfree(balloon_mapping);
> +}
> +
>  /*
>   * balloon_page_device - get the b_dev_info descriptor for the balloon device
>   *			 that enqueues the given page.
> @@ -246,33 +184,6 @@ static inline void balloon_mapping_free(struct address_space *balloon_mapping)
>  	return;
>  }
>  
> -static inline void balloon_page_insert(struct page *page,
> -				       struct address_space *mapping,
> -				       struct list_head *head)
> -{
> -	list_add(&page->lru, head);
> -}
> -
> -static inline void balloon_page_delete(struct page *page)
> -{
> -	list_del(&page->lru);
> -}
> -
> -static inline bool __is_movable_balloon_page(struct page *page)
> -{
> -	return false;
> -}
> -
> -static inline bool balloon_page_movable(struct page *page)
> -{
> -	return false;
> -}
> -
> -static inline bool isolated_balloon_page(struct page *page)
> -{
> -	return false;
> -}
> -
>  static inline bool balloon_page_isolate(struct page *page)
>  {
>  	return false;
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 72e0db0..e09cf0a 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -237,7 +237,7 @@ config MEMORY_BALLOON
>  config BALLOON_COMPACTION
>  	bool "Allow for balloon memory compaction/migration"
>  	def_bool y
> -	depends on COMPACTION && VIRTIO_BALLOON
> +	depends on COMPACTION && MEMORY_BALLOON
>  	help
>  	  Memory fragmentation introduced by ballooning might reduce
>  	  significantly the number of 2MB contiguous memory blocks that can be
> diff --git a/mm/Makefile b/mm/Makefile
> index a96e3a1..b2f18dc 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -16,7 +16,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
>  			   readahead.o swap.o truncate.o vmscan.o shmem.o \
>  			   util.o mmzone.o vmstat.o backing-dev.o \
>  			   mm_init.o mmu_context.o percpu.o slab_common.o \
> -			   compaction.o balloon_compaction.o vmacache.o \
> +			   compaction.o vmacache.o \
>  			   interval_tree.o list_lru.o workingset.o \
>  			   iov_iter.o $(mmu-y)
>  
> @@ -64,3 +64,4 @@ obj-$(CONFIG_ZBUD)	+= zbud.o
>  obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
>  obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
>  obj-$(CONFIG_CMA)	+= cma.o
> +obj-$(CONFIG_MEMORY_BALLOON) += balloon_compaction.o
> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
> index 6e45a50..a942081 100644
> --- a/mm/balloon_compaction.c
> +++ b/mm/balloon_compaction.c
> @@ -239,8 +239,7 @@ bool balloon_page_isolate(struct page *page)
>  			 * Prevent concurrent compaction threads from isolating
>  			 * an already isolated balloon page by refcount check.
>  			 */
> -			if (__is_movable_balloon_page(page) &&
> -			    page_count(page) == 2) {
> +			if (PageBalloon(page) && page_count(page) == 2) {
>  				__isolate_balloon_page(page);
>  				unlock_page(page);
>  				return true;
> @@ -261,7 +260,7 @@ void balloon_page_putback(struct page *page)
>  	 */
>  	lock_page(page);
>  
> -	if (__is_movable_balloon_page(page)) {
> +	if (PageBalloon(page)) {
>  		__putback_balloon_page(page);
>  		/* drop the extra ref count taken for page isolation */
>  		put_page(page);
> @@ -286,7 +285,7 @@ int balloon_page_migrate(struct page *newpage,
>  	 */
>  	BUG_ON(!trylock_page(newpage));
>  
> -	if (WARN_ON(!__is_movable_balloon_page(page))) {
> +	if (WARN_ON(!PageBalloon(page))) {
>  		dump_page(page, "not movable balloon page");
>  		unlock_page(newpage);
>  		return rc;
> diff --git a/mm/compaction.c b/mm/compaction.c
> index ad58f73..7d9d92e 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -642,11 +642,10 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>  		 * Skip any other type of page
>  		 */
>  		if (!PageLRU(page)) {
> -			if (unlikely(balloon_page_movable(page))) {
> -				if (balloon_page_isolate(page)) {
> -					/* Successfully isolated */
> -					goto isolate_success;
> -				}
> +			if (unlikely(PageBalloon(page)) &&
> +					balloon_page_isolate(page)) {
> +				/* Successfully isolated */
> +				goto isolate_success;
>  			}
>  			continue;
>  		}
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 57c94f9..a4939b1 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -92,7 +92,7 @@ void putback_movable_pages(struct list_head *l)
>  		list_del(&page->lru);
>  		dec_zone_page_state(page, NR_ISOLATED_ANON +
>  				page_is_file_cache(page));
> -		if (unlikely(isolated_balloon_page(page)))
> +		if (unlikely(PageBalloon(page)))
>  			balloon_page_putback(page);
>  		else
>  			putback_lru_page(page);
> @@ -873,7 +873,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>  		}
>  	}
>  
> -	if (unlikely(__is_movable_balloon_page(page))) {
> +	if (unlikely(PageBalloon(page))) {
>  		/*
>  		 * A ballooned page does not need any special attention from
>  		 * physical to virtual reverse mapping procedures.
> @@ -952,6 +952,7 @@ static int unmap_and_move(new_page_t get_new_page, free_page_t put_new_page,
>  
>  	rc = __unmap_and_move(page, newpage, force, mode);
>  
> +#ifdef CONFIG_MEMORY_BALLOON
>  	if (unlikely(rc == MIGRATEPAGE_BALLOON_SUCCESS)) {
>  		/*
>  		 * A ballooned page has been migrated already.
> @@ -963,6 +964,7 @@ static int unmap_and_move(new_page_t get_new_page, free_page_t put_new_page,
>  		balloon_page_free(page);
>  		return MIGRATEPAGE_SUCCESS;
>  	}
> +#endif
>  out:
>  	if (rc != -EAGAIN) {
>  		/*
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 1a71b8b..88dd901 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1160,7 +1160,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>  
>  	list_for_each_entry_safe(page, next, page_list, lru) {
>  		if (page_is_file_cache(page) && !PageDirty(page) &&
> -		    !isolated_balloon_page(page)) {
> +		    !PageBalloon(page)) {
>  			ClearPageActive(page);
>  			list_move(&page->lru, &clean_pages);
>  		}
> 
Acked-by: Rafael Aquini <aquini@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
