Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 85EE26B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 09:51:33 -0400 (EDT)
Date: Tue, 21 Aug 2012 16:52:23 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v8 1/5] mm: introduce a common interface for balloon
 pages mobility
Message-ID: <20120821135223.GA7117@redhat.com>
References: <cover.1345519422.git.aquini@redhat.com>
 <e24f3073ef539985dea52943dcb84762213a0857.1345519422.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e24f3073ef539985dea52943dcb84762213a0857.1345519422.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Tue, Aug 21, 2012 at 09:47:44AM -0300, Rafael Aquini wrote:
> Memory fragmentation introduced by ballooning might reduce significantly
> the number of 2MB contiguous memory blocks that can be used within a guest,
> thus imposing performance penalties associated with the reduced number of
> transparent huge pages that could be used by the guest workload.
> 
> This patch introduces a common interface to help a balloon driver on
> making its page set movable to compaction, and thus allowing the system
> to better leverage the compation efforts on memory defragmentation.
> 
> Signed-off-by: Rafael Aquini <aquini@redhat.com>
> ---
>  include/linux/balloon_compaction.h | 113 +++++++++++++++++++++++++++++
>  include/linux/pagemap.h            |  18 +++++
>  mm/Kconfig                         |  15 ++++
>  mm/Makefile                        |   2 +-
>  mm/balloon_compaction.c            | 145 +++++++++++++++++++++++++++++++++++++
>  5 files changed, 292 insertions(+), 1 deletion(-)
>  create mode 100644 include/linux/balloon_compaction.h
>  create mode 100644 mm/balloon_compaction.c
> 
> diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
> new file mode 100644
> index 0000000..5fbf036
> --- /dev/null
> +++ b/include/linux/balloon_compaction.h
> @@ -0,0 +1,113 @@
> +/*
> + * include/linux/balloon_compaction.h
> + *
> + * Common interface definitions for making balloon pages movable to compaction.
> + *
> + * Copyright (C) 2012, Red Hat, Inc.  Rafael Aquini <aquini@redhat.com>
> + */
> +#ifndef _LINUX_BALLOON_COMPACTION_H
> +#define _LINUX_BALLOON_COMPACTION_H
> +#ifdef __KERNEL__
> +
> +#include <linux/rcupdate.h>
> +#include <linux/pagemap.h>
> +#include <linux/gfp.h>
> +
> +#if defined(CONFIG_BALLOON_COMPACTION)
> +extern bool isolate_balloon_page(struct page *);
> +extern void putback_balloon_page(struct page *);
> +
> +static inline bool movable_balloon_page(struct page *page)
> +{
> +	struct address_space *mapping = NULL;
> +	bool ret = false;
> +	/*
> +	 * Before dereferencing and testing mapping->flags, lets make sure
> +	 * this is not a page that uses ->mapping in a different way
> +	 */
> +	if (!PageSlab(page) && !PageSwapCache(page) &&
> +	    !PageAnon(page) && !page_mapped(page)) {
> +		rcu_read_lock();
> +		mapping = rcu_dereference(page->mapping);
> +		if (mapping_balloon(mapping))
> +			ret = true;
> +		rcu_read_unlock();

This looks suspicious: you drop rcu_read_unlock
so can't page switch from balloon to non balloon?

Even if correct, it's probably cleaner to just make caller
invoke this within an rcu critical section.
You will notice that all callers immediately re-enter
rcu critical section anyway.

Alternatively, I noted that accesses to page->mapping
seem protected by page lock bit.
If true we can rely on that instead of RCU, just need
assign_balloon_mapping to lock_page/unlock_page.

> +	}
> +	return ret;
> +}
> +
> +static inline gfp_t balloon_mapping_gfp_mask(void)
> +{
> +	return GFP_HIGHUSER_MOVABLE;
> +}
> +
> +/*
> + * __page_balloon_device - return the balloon device owing the page.
> + *
> + * This shall only be used at driver callbacks under proper page_lock,
> + * to get access to the balloon device structure that owns @page.
> + */
> +static inline void *__page_balloon_device(struct page *page)
> +{
> +	struct address_space *mapping;
> +	mapping = rcu_access_pointer(page->mapping);
> +	if (mapping)
> +		mapping = mapping->assoc_mapping;
> +	return (void *)mapping;
> +}
> +
> +#define count_balloon_event(e) count_vm_event(e)
> +/*
> + * DEFINE_BALLOON_MAPPING_AOPS - declare and instantiate a callback descriptor
> + *				 to be used as balloon page->mapping->a_ops.
> + *
> + * @label     : declaration identifier (var name)
> + * @migratepg : callback symbol name for performing the page migration step
> + * @isolatepg : callback symbol name for performing the page isolation step
> + * @putbackpg : callback symbol name for performing the page putback step
> + *
> + * address_space_operations utilized methods for ballooned pages:
> + *   .migratepage    - used to perform balloon's page migration (as is)
> + *   .launder_page   - used to isolate a page from balloon's page list
> + *   .freepage       - used to reinsert an isolated page to balloon's page list
> + */

It would be a good idea to document the assumptions here.
Looks like .launder_page and .freepage are called in rcu critical
section.
But migratepage isn't - why is that safe?

> +#define DEFINE_BALLOON_MAPPING_AOPS(label, migratepg, isolatepg, putbackpg) \
> +	const struct address_space_operations (label) = {		    \
> +		.migratepage  = (migratepg),				    \
> +		.launder_page = (isolatepg),				    \
> +		.freepage     = (putbackpg),				    \
> +	}
> +
> +#else
> +static inline bool isolate_balloon_page(struct page *page) { return false; }
> +static inline bool movable_balloon_page(struct page *page) { return false; }
> +static inline void putback_balloon_page(struct page *page) { return; }
> +
> +static inline gfp_t balloon_mapping_gfp_mask(void)
> +{
> +	return GFP_HIGHUSER;
> +}
> +
> +#define count_balloon_event(e) {}
> +#define DEFINE_BALLOON_MAPPING_AOPS(label, migratepg, isolatepg, putbackpg) \
> +	const struct address_space_operations *(label) = NULL
> +
> +#endif /* CONFIG_BALLOON_COMPACTION */
> +
> +extern struct address_space *alloc_balloon_mapping(void *balloon_device,
> +				const struct address_space_operations *a_ops);
> +extern void *page_balloon_device(struct page *page);
> +
> +static inline void assign_balloon_mapping(struct page *page,
> +					  struct address_space *mapping)
> +{
> +	rcu_assign_pointer(page->mapping, mapping);
> +}
> +
> +static inline void clear_balloon_mapping(struct page *page)
> +{
> +	rcu_assign_pointer(page->mapping, NULL);
> +}
> +
> +#endif /* __KERNEL__ */
> +#endif /* _LINUX_BALLOON_COMPACTION_H */
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index e42c762..6df0664 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -24,6 +24,7 @@ enum mapping_flags {
>  	AS_ENOSPC	= __GFP_BITS_SHIFT + 1,	/* ENOSPC on async write */
>  	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
>  	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
> +	AS_BALLOON_MAP  = __GFP_BITS_SHIFT + 4, /* balloon page special map */
>  };
>  
>  static inline void mapping_set_error(struct address_space *mapping, int error)
> @@ -53,6 +54,23 @@ static inline int mapping_unevictable(struct address_space *mapping)
>  	return !!mapping;
>  }
>  
> +static inline void mapping_set_balloon(struct address_space *mapping)
> +{
> +	set_bit(AS_BALLOON_MAP, &mapping->flags);
> +}
> +
> +static inline void mapping_clear_balloon(struct address_space *mapping)
> +{
> +	clear_bit(AS_BALLOON_MAP, &mapping->flags);
> +}
> +
> +static inline int mapping_balloon(struct address_space *mapping)
> +{
> +	if (mapping)
> +		return test_bit(AS_BALLOON_MAP, &mapping->flags);
> +	return !!mapping;
> +}
> +
>  static inline gfp_t mapping_gfp_mask(struct address_space * mapping)
>  {
>  	return (__force gfp_t)mapping->flags & __GFP_BITS_MASK;
> diff --git a/mm/Kconfig b/mm/Kconfig
> index d5c8019..4857899 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -188,6 +188,21 @@ config SPLIT_PTLOCK_CPUS
>  	default "4"
>  
>  #
> +# support for memory balloon compaction
> +config BALLOON_COMPACTION
> +	bool "Allow for balloon memory compaction/migration"
> +	select COMPACTION
> +	depends on VIRTIO_BALLOON
> +	help
> +	  Memory fragmentation introduced by ballooning might reduce
> +	  significantly the number of 2MB contiguous memory blocks that can be
> +	  used within a guest, thus imposing performance penalties associated
> +	  with the reduced number of transparent huge pages that could be used
> +	  by the guest workload. Allowing the compaction & migration for memory
> +	  pages enlisted as being part of memory balloon devices avoids the
> +	  scenario aforementioned and helps improving memory defragmentation.
> +
> +#
>  # support for memory compaction
>  config COMPACTION
>  	bool "Allow for memory compaction"
> diff --git a/mm/Makefile b/mm/Makefile
> index 92753e2..78d8caa 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -16,7 +16,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
>  			   readahead.o swap.o truncate.o vmscan.o shmem.o \
>  			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
>  			   mm_init.o mmu_context.o percpu.o slab_common.o \
> -			   compaction.o $(mmu-y)
> +			   compaction.o balloon_compaction.o $(mmu-y)
>  
>  obj-y += init-mm.o
>  
> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
> new file mode 100644
> index 0000000..d79f13d
> --- /dev/null
> +++ b/mm/balloon_compaction.c
> @@ -0,0 +1,145 @@
> +/*
> + * mm/balloon_compaction.c
> + *
> + * Common interface for making balloon pages movable to compaction.
> + *
> + * Copyright (C) 2012, Red Hat, Inc.  Rafael Aquini <aquini@redhat.com>
> + */
> +#include <linux/slab.h>
> +#include <linux/export.h>
> +#include <linux/balloon_compaction.h>
> +
> +/*
> + * alloc_balloon_mapping - allocates a special ->mapping for ballooned pages.
> + * @balloon_device: pointer address that references the balloon device which
> + *                 owns pages bearing this ->mapping.
> + * @a_ops: balloon_mapping address_space_operations descriptor.
> + *
> + * Users must call it to properly allocate and initialize an instance of
> + * struct address_space which will be used as the special page->mapping for
> + * balloon devices enlisted page instances.
> + */
> +struct address_space *alloc_balloon_mapping(void *balloon_device,
> +				const struct address_space_operations *a_ops)
> +{
> +	struct address_space *mapping;
> +
> +	mapping = kmalloc(sizeof(*mapping), GFP_KERNEL);
> +	if (mapping) {

If !mapping return NULL will make code shorter.

> +		/*
> +		 * Give a clean 'zeroed' status to all elements of this special
> +		 * balloon page->mapping struct address_space instance.
> +		 */
> +		address_space_init_once(mapping);
> +
> +		/*
> +		 * Set mapping->flags appropriately, to allow balloon ->mapping
> +		 * identification, as well as give a proper hint to the balloon
> +		 * driver on what GFP allocation mask shall be used.
> +		 */
> +		mapping_set_balloon(mapping);
> +		mapping_set_gfp_mask(mapping, balloon_mapping_gfp_mask());
> +
> +		/* balloon's page->mapping->a_ops callback descriptor */
> +		mapping->a_ops = a_ops;
> +
> +		/*
> +		 * balloon special page->mapping overloads ->assoc_mapping
> +		 * to held a reference back to the balloon device wich 'owns'
> +		 * a given page. This is the way we can cope with multiple
> +		 * balloon devices without losing reference of several
> +		 * ballooned pagesets.
> +		 */
> +		mapping->assoc_mapping = (void *)balloon_device;

(void *) is only a good idea if you are casting a long value.

> +
> +		return mapping;
> +	}
> +	return NULL;
> +}
> +EXPORT_SYMBOL_GPL(alloc_balloon_mapping);
> +
> +#if defined(CONFIG_BALLOON_COMPACTION)
> +static inline int __isolate_balloon_page(struct page *page)
> +{
> +	struct address_space *mapping;
> +	int ret = 0;
> +
> +	rcu_read_lock();
> +	mapping = rcu_dereference(page->mapping);
> +	if (mapping)
> +		ret = mapping->a_ops->launder_page(page);
> +
> +	rcu_read_unlock();
> +	return ret;
> +}
> +
> +static inline void __putback_balloon_page(struct page *page)
> +{
> +	struct address_space *mapping;
> +
> +	rcu_read_lock();
> +	mapping = rcu_dereference(page->mapping);
> +	/*
> +	 * If we stumble across a page->mapping NULL here, so something has
> +	 * messed with the private isolated pageset we are iterating over.
> +	 */
> +	BUG_ON(!mapping);
> +
> +	mapping->a_ops->freepage(page);
> +	/* isolation bumps up the page refcount, time to decrement it */
> +	put_page(page);
> +	rcu_read_unlock();
> +}
> +
> +/* __isolate_lru_page() counterpart for a ballooned page */
> +bool isolate_balloon_page(struct page *page)
> +{
> +	if (likely(get_page_unless_zero(page))) {
> +		/*
> +		 * As balloon pages are not isolated from LRU lists, concurrent
> +		 * compaction threads can race against page migration functions
> +		 * move_to_new_page() & __unmap_and_move().
> +		 * In order to avoid having an already isolated balloon page
> +		 * being (wrongly) re-isolated while it is under migration,
> +		 * lets be sure we have the page lock before proceeding with
> +		 * the balloon page isolation steps.
> +		 */
> +		if (likely(trylock_page(page))) {
> +			/*
> +			 * A ballooned page, by default, has just one refcount.
> +			 * Prevent concurrent compaction threads from isolating
> +			 * an already isolated balloon page by refcount check.
> +			 */
> +			if (movable_balloon_page(page) &&
> +			    (page_count(page) == 2)) {
> +				if (__isolate_balloon_page(page)) {
> +					unlock_page(page);
> +					return true;
> +				}
> +			}
> +			unlock_page(page);
> +		}
> +		/*
> +		 * This page is either under migration, it is isolated already,
> +		 * or its isolation step has not happened at this round.
> +		 * Drop the refcount taken for it.
> +		 */
> +		put_page(page);
> +	}
> +	return false;
> +}
> +
> +/* putback_lru_page() counterpart for a ballooned page */
> +void putback_balloon_page(struct page *page)
> +{
> +	/*
> +	 * 'lock_page()' stabilizes the page and prevents races against
> +	 * concurrent isolation threads attempting to re-isolate it.
> +	 */
> +	lock_page(page);
> +	if (movable_balloon_page(page))
> +		__putback_balloon_page(page);
> +
> +	unlock_page(page);
> +}
> +#endif /* CONFIG_BALLOON_COMPACTION */
> -- 
> 1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
