Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id AEAA46B0044
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 07:11:37 -0500 (EST)
Date: Fri, 9 Nov 2012 12:11:33 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v11 3/7] mm: introduce a common interface for balloon
 pages mobility
Message-ID: <20121109121133.GP3886@csn.ul.ie>
References: <cover.1352256081.git.aquini@redhat.com>
 <4ea10ef1eb1544e12524c8ca7df20cf621395463.1352256087.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4ea10ef1eb1544e12524c8ca7df20cf621395463.1352256087.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Wed, Nov 07, 2012 at 01:05:50AM -0200, Rafael Aquini wrote:
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
>  include/linux/balloon_compaction.h | 220 ++++++++++++++++++++++++++++++
>  include/linux/migrate.h            |  10 ++
>  include/linux/pagemap.h            |  16 +++
>  mm/Kconfig                         |  15 +++
>  mm/Makefile                        |   1 +
>  mm/balloon_compaction.c            | 269 +++++++++++++++++++++++++++++++++++++
>  6 files changed, 531 insertions(+)
>  create mode 100644 include/linux/balloon_compaction.h
>  create mode 100644 mm/balloon_compaction.c
> 
> diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
> new file mode 100644
> index 0000000..1865bd5
> --- /dev/null
> +++ b/include/linux/balloon_compaction.h
> @@ -0,0 +1,220 @@
> +/*
> + * include/linux/balloon_compaction.h
> + *
> + * Common interface definitions for making balloon pages movable to compaction.
> + *

s/to/by/

And the record for nit-picking goes to....

> + * Copyright (C) 2012, Red Hat, Inc.  Rafael Aquini <aquini@redhat.com>
> + */
> +#ifndef _LINUX_BALLOON_COMPACTION_H
> +#define _LINUX_BALLOON_COMPACTION_H
> +#include <linux/pagemap.h>
> +#include <linux/migrate.h>
> +#include <linux/gfp.h>
> +#include <linux/err.h>
> +
> +/*
> + * Balloon device information descriptor.
> + * This struct is used to allow the common balloon compaction interface
> + * procedures to find the proper balloon device holding memory pages they'll
> + * have to cope for page compaction / migration, as well as it serves the
> + * balloon driver as a page book-keeper for its registered balloon devices.
> + */
> +struct balloon_dev_info {
> +	void *balloon_device;		/* balloon device descriptor */
> +	struct address_space *mapping;	/* balloon special page->mapping */
> +	unsigned long isolated_pages;	/* # of isolated pages for migration */
> +	spinlock_t pages_lock;		/* Protection to pages list */
> +	struct list_head pages;		/* Pages enqueued & handled to Host */
> +};
> +
> +extern struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info);
> +extern struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info);
> +extern struct balloon_dev_info *balloon_devinfo_alloc(
> +						void *balloon_dev_descriptor);
> +
> +static inline void balloon_devinfo_free(struct balloon_dev_info *b_dev_info)
> +{
> +	kfree(b_dev_info);
> +}
> +

More stupid nit-picking but in terms of defensive programming it would
be preferred if the container struct of balloon_dev_info was passed in
and then

kfree(something->b_dev_info);
something->b_dev_info = NULL;

This looks like serious overkill but if the lifetime of the balloon driver
is complex and relatively rarely used (which I bet is the case) then we
want use-after-free bugs to blow up quickly instead of corrupt.

It is not mandatory to address this before merging but if you do another
revision it might be a nice idea. I'm only bringing this up as I got bitten
by this recently when I screwed up the lifetime of a mm-associated struct
and it took a while to pin down.

The suggestion is irrelevant if the containing structure is freed at the
same time of course.

> +#ifdef CONFIG_BALLOON_COMPACTION
> +extern bool balloon_page_isolate(struct page *page);
> +extern void balloon_page_putback(struct page *page);
> +extern int balloon_page_migrate(struct page *newpage,
> +				struct page *page, enum migrate_mode mode);
> +extern struct address_space
> +*balloon_mapping_alloc(struct balloon_dev_info *b_dev_info,
> +			const struct address_space_operations *a_ops);
> +

It should not be part of your patch but one day we might want to abstract
even this and put users with different migration requirements behind some
sort of migration_operations callback strucr. Balloon would be the first
user of course but CMA also is and but if placement constraints for
memory usage ever happens, it'd be another user.

> +static inline void balloon_mapping_free(struct address_space *balloon_mapping)
> +{
> +	kfree(balloon_mapping);
> +}
> +
> +/*
> + * balloon_page_insert - insert a page into the balloon's page list and make
> + *		         the page->mapping assignment accordingly.
> + * @page    : page to be assigned as a 'balloon page'
> + * @mapping : allocated special 'balloon_mapping'
> + * @head    : balloon's device page list head
> + */
> +static inline void balloon_page_insert(struct page *page,
> +				       struct address_space *mapping,
> +				       struct list_head *head)
> +{
> +	list_add(&page->lru, head);
> +	/*
> +	 * Make sure the page is already inserted on balloon's page list
> +	 * before assigning its ->mapping.
> +	 */
> +	smp_wmb();
> +	page->mapping = mapping;
> +}
> +

Elsewhere we have;

	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
	balloon_page_insert(page, b_dev_info->mapping, &b_dev_info->pages);
	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);

So this happens under an irq-safe lock. Why is a smp_wmb necessary?

> +
> +/*
> + * balloon_page_delete - clear the page->mapping and delete the page from
> + *			 balloon's page list accordingly.
> + * @page    : page to be released from balloon's page list
> + */
> +static inline void balloon_page_delete(struct page *page)
> +{
> +	page->mapping = NULL;
> +	/*
> +	 * Make sure page->mapping is cleared before we proceed with
> +	 * balloon's page list deletion.
> +	 */
> +	smp_wmb();
> +	list_del(&page->lru);
> +}
> +

Same thing on locking except this also appears to be under the page lock
making the barrier seem even more unnecessary.

> +/*
> + * __is_movable_balloon_page - helper to perform @page mapping->flags tests
> + */
> +static inline bool __is_movable_balloon_page(struct page *page)
> +{
> +	/*
> +	 * we might attempt to read ->mapping concurrently to other
> +	 * threads trying to write to it.
> +	 */
> +	struct address_space *mapping = ACCESS_ONCE(page->mapping);
> +	smp_read_barrier_depends();
> +	return mapping_balloon(mapping);
> +}
> +

What happens if this race occurs? I assume it's a racy check before you
isolate the balloon in which case the barrier may be overkill.

> +/*
> + * balloon_page_movable - test page->mapping->flags to identify balloon pages
> + *			  that can be moved by compaction/migration.
> + *
> + * This function is used at core compaction's page isolation scheme, therefore
> + * most pages exposed to it are not enlisted as balloon pages and so, to avoid
> + * undesired side effects like racing against __free_pages(), we cannot afford
> + * holding the page locked while testing page->mapping->flags here.
> + *
> + * As we might return false positives in the case of a balloon page being just
> + * released under us, the page->mapping->flags need to be re-tested later,
> + * under the proper page lock, at the functions that will be coping with the
> + * balloon page case.
> + */
> +static inline bool balloon_page_movable(struct page *page)
> +{
> +	/*
> +	 * Before dereferencing and testing mapping->flags, lets make sure
> +	 * this is not a page that uses ->mapping in a different way
> +	 */
> +	if (!PageSlab(page) && !PageSwapCache(page) && !PageAnon(page) &&
> +	    !page_mapped(page))
> +		return __is_movable_balloon_page(page);
> +
> +	return false;
> +}
> +

Ok.

> +/*
> + * balloon_page_device - get the b_dev_info descriptor for the balloon device
> + *			 that enqueues the given page.
> + */
> +static inline struct balloon_dev_info *balloon_page_device(struct page *page)
> +{
> +	struct address_space *mapping = page->mapping;
> +	if (likely(mapping))
> +		return mapping->private_data;
> +
> +	return NULL;
> +}
> +
> +static inline gfp_t balloon_mapping_gfp_mask(void)
> +{
> +	return GFP_HIGHUSER_MOVABLE;
> +}
> +
> +static inline void balloon_event_count(enum vm_event_item item)
> +{
> +	count_vm_event(item);
> +}
> +
> +static inline bool balloon_compaction_check(void)
> +{
> +	return true;
> +}
> +
> +#else /* !CONFIG_BALLOON_COMPACTION */
> +
> +static inline void *balloon_mapping_alloc(void *balloon_device,
> +				const struct address_space_operations *a_ops)
> +{
> +	return ERR_PTR(-EOPNOTSUPP);
> +}
> +
> +static inline void balloon_mapping_free(struct address_space *balloon_mapping)
> +{
> +	return;
> +}
> +
> +static inline void balloon_page_insert(struct page *page,
> +				       struct address_space *mapping,
> +				       struct list_head *head)
> +{
> +	list_add(&page->lru, head);
> +}
> +
> +static inline void balloon_page_delete(struct page *page)
> +{
> +	list_del(&page->lru);
> +}
> +
> +static inline bool balloon_page_movable(struct page *page)
> +{
> +	return false;
> +}
> +
> +static inline bool balloon_page_isolate(struct page *page)
> +{
> +	return false;
> +}
> +
> +static inline void balloon_page_putback(struct page *page)
> +{
> +	return;
> +}
> +
> +static inline int balloon_page_migrate(struct page *newpage,
> +				struct page *page, enum migrate_mode mode)
> +{
> +	return 0;
> +}
> +
> +static inline gfp_t balloon_mapping_gfp_mask(void)
> +{
> +	return GFP_HIGHUSER;
> +}
> +
> +static inline void balloon_event_count(enum vm_event_item item)
> +{
> +	return;
> +}
> +
> +static inline bool balloon_compaction_check(void)
> +{
> +	return false;
> +}
> +#endif /* CONFIG_BALLOON_COMPACTION */
> +#endif /* _LINUX_BALLOON_COMPACTION_H */
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index a4e886d..e570c3c 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -11,8 +11,18 @@ typedef struct page *new_page_t(struct page *, unsigned long private, int **);
>   * Return values from addresss_space_operations.migratepage():
>   * - negative errno on page migration failure;
>   * - zero on page migration success;
> + *
> + * The balloon page migration introduces this special case where a 'distinct'
> + * return code is used to flag a successful page migration to unmap_and_move().
> + * This approach is necessary because page migration can race against balloon
> + * deflation procedure, and for such case we could introduce a nasty page leak
> + * if a successfully migrated balloon page gets released concurrently with
> + * migration's unmap_and_move() wrap-up steps.
>   */
>  #define MIGRATEPAGE_SUCCESS		0
> +#define MIGRATEPAGE_BALLOON_SUCCESS	1 /* special ret code for balloon page
> +					   * sucessfull migration case.
> +					   */

s/sucessfull/successful/

>  
>  #ifdef CONFIG_MIGRATION
>  
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index e42c762..6da609d 100644
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
> @@ -53,6 +54,21 @@ static inline int mapping_unevictable(struct address_space *mapping)
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
> +	return mapping && test_bit(AS_BALLOON_MAP, &mapping->flags);
> +}
> +
>  static inline gfp_t mapping_gfp_mask(struct address_space * mapping)
>  {
>  	return (__force gfp_t)mapping->flags & __GFP_BITS_MASK;
> diff --git a/mm/Kconfig b/mm/Kconfig
> index a3f8ddd..b119172 100644
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

Rather than select COMPACTION, should it depend on it? Similarly as THP
is the primary motivation, would it make more sense to depend on
TRANSPARENT_HUGEPAGE?

Should it default y? It seems useful, why would someone support
VIRTIO_BALLOON and *not* use this?

> +#
>  # support for memory compaction
>  config COMPACTION
>  	bool "Allow for memory compaction"
> diff --git a/mm/Makefile b/mm/Makefile
> index 6b025f8..21e10ee 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -57,3 +57,4 @@ obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
>  obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
>  obj-$(CONFIG_CLEANCACHE) += cleancache.o
>  obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
> +obj-$(CONFIG_BALLOON_COMPACTION) += balloon_compaction.o
> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
> new file mode 100644
> index 0000000..90935aa
> --- /dev/null
> +++ b/mm/balloon_compaction.c
> @@ -0,0 +1,269 @@
> +/*
> + * mm/balloon_compaction.c
> + *
> + * Common interface for making balloon pages movable to compaction.
> + *
> + * Copyright (C) 2012, Red Hat, Inc.  Rafael Aquini <aquini@redhat.com>
> + */
> +#include <linux/mm.h>
> +#include <linux/slab.h>
> +#include <linux/export.h>
> +#include <linux/balloon_compaction.h>
> +
> +/*
> + * balloon_devinfo_alloc - allocates a balloon device information descriptor.
> + * @balloon_dev_descriptor: pointer to reference the balloon device which
> + *                          this struct balloon_dev_info will be servicing.
> + *
> + * Driver must call it to properly allocate and initialize an instance of
> + * struct balloon_dev_info which will be used to reference a balloon device
> + * as well as to keep track of the balloon device page list.
> + */
> +struct balloon_dev_info *balloon_devinfo_alloc(void *balloon_dev_descriptor)
> +{
> +	struct balloon_dev_info *b_dev_info;
> +	b_dev_info = kmalloc(sizeof(*b_dev_info), GFP_KERNEL);
> +	if (!b_dev_info)
> +		return ERR_PTR(-ENOMEM);
> +
> +	b_dev_info->balloon_device = balloon_dev_descriptor;
> +	b_dev_info->mapping = NULL;
> +	b_dev_info->isolated_pages = 0;
> +	spin_lock_init(&b_dev_info->pages_lock);
> +	INIT_LIST_HEAD(&b_dev_info->pages);
> +
> +	return b_dev_info;
> +}
> +EXPORT_SYMBOL_GPL(balloon_devinfo_alloc);
> +
> +/*
> + * balloon_page_enqueue - allocates a new page and inserts it into the balloon
> + *			  page list.
> + * @b_dev_info: balloon device decriptor where we will insert a new page to
> + *
> + * Driver must call it to properly allocate a new enlisted balloon page
> + * before definetively removing it from the guest system.
> + * This function returns the page address for the recently enqueued page or
> + * NULL in the case we fail to allocate a new page this turn.
> + */
> +struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info)
> +{
> +	unsigned long flags;
> +	struct page *page = alloc_page(balloon_mapping_gfp_mask() |
> +					__GFP_NOMEMALLOC | __GFP_NORETRY);
> +	if (!page)
> +		return NULL;
> +
> +	BUG_ON(!trylock_page(page));
> +	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
> +	balloon_page_insert(page, b_dev_info->mapping, &b_dev_info->pages);
> +	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
> +	unlock_page(page);
> +	return page;
> +}
> +EXPORT_SYMBOL_GPL(balloon_page_enqueue);
> +
> +/*
> + * balloon_page_dequeue - removes a page from balloon's page list and returns
> + *			  the its address to allow the driver release the page.
> + * @b_dev_info: balloon device decriptor where we will grab a page from.
> + *
> + * Driver must call it to properly de-allocate a previous enlisted balloon page
> + * before definetively releasing it back to the guest system.
> + * This function returns the page address for the recently dequeued page or
> + * NULL in the case we find balloon's page list temporarely empty due to
> + * compaction isolated pages.
> + */
> +struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
> +{
> +	struct page *page, *tmp;
> +	unsigned long flags;
> +	bool dequeued_page;
> +
> +	dequeued_page = false;
> +	list_for_each_entry_safe(page, tmp, &b_dev_info->pages, lru) {
> +		if (trylock_page(page)) {
> +			spin_lock_irqsave(&b_dev_info->pages_lock, flags);
> +			balloon_page_delete(page);
> +			spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
> +			unlock_page(page);
> +			dequeued_page = true;
> +			break;
> +		}
> +	}
> +
> +	if (!dequeued_page) {
> +		spin_lock_irqsave(&b_dev_info->pages_lock, flags);
> +		if (unlikely(list_empty(&b_dev_info->pages) &&
> +			     !b_dev_info->isolated_pages))
> +			BUG();
> +		spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
> +		page = NULL;
> +	}
> +	return page;
> +}
> +EXPORT_SYMBOL_GPL(balloon_page_dequeue);
> +
> +#ifdef CONFIG_BALLOON_COMPACTION
> +/*
> + * balloon_mapping_alloc - allocates a special ->mapping for ballooned pages.
> + * @b_dev_info: holds the balloon device information descriptor.
> + * @a_ops: balloon_mapping address_space_operations descriptor.
> + *
> + * Driver must call it to properly allocate and initialize an instance of
> + * struct address_space which will be used as the special page->mapping for
> + * balloon device enlisted page instances.
> + */
> +struct address_space *balloon_mapping_alloc(struct balloon_dev_info *b_dev_info,
> +				const struct address_space_operations *a_ops)
> +{
> +	struct address_space *mapping;
> +
> +	mapping = kmalloc(sizeof(*mapping), GFP_KERNEL);
> +	if (!mapping)
> +		return ERR_PTR(-ENOMEM);
> +
> +	/*
> +	 * Give a clean 'zeroed' status to all elements of this special
> +	 * balloon page->mapping struct address_space instance.
> +	 */
> +	address_space_init_once(mapping);
> +
> +	/*
> +	 * Set mapping->flags appropriately, to allow balloon pages
> +	 * ->mapping identification.
> +	 */
> +	mapping_set_balloon(mapping);
> +	mapping_set_gfp_mask(mapping, balloon_mapping_gfp_mask());
> +
> +	/* balloon's page->mapping->a_ops callback descriptor */
> +	mapping->a_ops = a_ops;
> +
> +	/*
> +	 * Establish a pointer reference back to the balloon device descriptor
> +	 * this particular page->mapping will be servicing.
> +	 * This is used by compaction / migration procedures to identify and
> +	 * access the balloon device pageset while isolating / migrating pages.
> +	 *
> +	 * As some balloon drivers can register multiple balloon devices
> +	 * for a single guest, this also helps compaction / migration to
> +	 * properly deal with multiple balloon pagesets, when required.
> +	 */
> +	mapping->private_data = b_dev_info;
> +	b_dev_info->mapping = mapping;
> +
> +	return mapping;
> +}
> +EXPORT_SYMBOL_GPL(balloon_mapping_alloc);
> +
> +static inline void __isolate_balloon_page(struct page *page)
> +{
> +	struct balloon_dev_info *b_dev_info = page->mapping->private_data;
> +	unsigned long flags;
> +	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
> +	list_del(&page->lru);
> +	b_dev_info->isolated_pages++;
> +	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
> +}
> +
> +static inline void __putback_balloon_page(struct page *page)
> +{
> +	struct balloon_dev_info *b_dev_info = page->mapping->private_data;
> +	unsigned long flags;
> +	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
> +	list_add(&page->lru, &b_dev_info->pages);
> +	b_dev_info->isolated_pages--;
> +	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
> +}
> +
> +static inline int __migrate_balloon_page(struct address_space *mapping,
> +		struct page *newpage, struct page *page, enum migrate_mode mode)
> +{
> +	return page->mapping->a_ops->migratepage(mapping, newpage, page, mode);
> +}
> +
> +/* __isolate_lru_page() counterpart for a ballooned page */
> +bool balloon_page_isolate(struct page *page)
> +{
> +	/*
> +	 * Avoid burning cycles with pages that are yet under __free_pages(),
> +	 * or just got freed under us.
> +	 *
> +	 * In case we 'win' a race for a balloon page being freed under us and
> +	 * raise its refcount preventing __free_pages() from doing its job
> +	 * the put_page() at the end of this block will take care of
> +	 * release this page, thus avoiding a nasty leakage.
> +	 */
> +	if (likely(get_page_unless_zero(page))) {
> +		/*
> +		 * As balloon pages are not isolated from LRU lists, concurrent
> +		 * compaction threads can race against page migration functions
> +		 * as well as race against the balloon driver releasing a page.
> +		 *
> +		 * In order to avoid having an already isolated balloon page
> +		 * being (wrongly) re-isolated while it is under migration,
> +		 * or to avoid attempting to isolate pages being released by
> +		 * the balloon driver, lets be sure we have the page lock
> +		 * before proceeding with the balloon page isolation steps.
> +		 */
> +		if (likely(trylock_page(page))) {
> +			/*
> +			 * A ballooned page, by default, has just one refcount.
> +			 * Prevent concurrent compaction threads from isolating
> +			 * an already isolated balloon page by refcount check.
> +			 */
> +			if (__is_movable_balloon_page(page) &&
> +			    page_count(page) == 2) {
> +				__isolate_balloon_page(page);
> +				unlock_page(page);
> +				return true;
> +			}
> +			unlock_page(page);
> +		}
> +		put_page(page);
> +	}
> +	return false;
> +}
> +
> +/* putback_lru_page() counterpart for a ballooned page */
> +void balloon_page_putback(struct page *page)
> +{
> +	/*
> +	 * 'lock_page()' stabilizes the page and prevents races against
> +	 * concurrent isolation threads attempting to re-isolate it.
> +	 */
> +	lock_page(page);
> +
> +	if (__is_movable_balloon_page(page)) {
> +		__putback_balloon_page(page);
> +		put_page(page);
> +	} else {
> +		__WARN();
> +		dump_page(page);
> +	}
> +	unlock_page(page);
> +}
> +
> +/* move_to_new_page() counterpart for a ballooned page */
> +int balloon_page_migrate(struct page *newpage,
> +			 struct page *page, enum migrate_mode mode)
> +{
> +	struct address_space *mapping;
> +	int rc = -EAGAIN;
> +
> +	BUG_ON(!trylock_page(newpage));
> +
> +	if (WARN_ON(!__is_movable_balloon_page(page))) {
> +		dump_page(page);
> +		unlock_page(newpage);
> +		return rc;
> +	}
> +
> +	mapping = page->mapping;
> +	if (mapping)
> +		rc = __migrate_balloon_page(mapping, newpage, page, mode);
> +
> +	unlock_page(newpage);
> +	return rc;
> +}
> +#endif /* CONFIG_BALLOON_COMPACTION */

Ok, I did not spot any obvious problems in this. The barriers were the
big issue for me really - they seem overkill. I think we've discussed
this already but even though it was recent I cannot remember the
conclusion. In a sense, it doesn't matter because it should have been
described in the code anyway.

If you get the barrier issue sorted out then feel free to add

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
