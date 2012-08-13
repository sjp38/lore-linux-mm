Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 44DF96B0069
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 04:25:29 -0400 (EDT)
Date: Mon, 13 Aug 2012 11:26:19 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v7 1/4] mm: introduce compaction and migration for virtio
 ballooned pages
Message-ID: <20120813082619.GE14081@redhat.com>
References: <cover.1344619987.git.aquini@redhat.com>
 <292b1b52e863a05b299f94bda69a61371011ac19.1344619987.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <292b1b52e863a05b299f94bda69a61371011ac19.1344619987.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Fri, Aug 10, 2012 at 02:55:14PM -0300, Rafael Aquini wrote:
> Memory fragmentation introduced by ballooning might reduce significantly
> the number of 2MB contiguous memory blocks that can be used within a guest,
> thus imposing performance penalties associated with the reduced number of
> transparent huge pages that could be used by the guest workload.
> 
> This patch introduces the helper functions as well as the necessary changes
> to teach compaction and migration bits how to cope with pages which are
> part of a guest memory balloon, in order to make them movable by memory
> compaction procedures.
> 
> Signed-off-by: Rafael Aquini <aquini@redhat.com>
> ---
>  include/linux/mm.h |  17 ++++++++
>  mm/compaction.c    | 125 +++++++++++++++++++++++++++++++++++++++++++++--------
>  mm/migrate.c       |  30 ++++++++++++-
>  3 files changed, 152 insertions(+), 20 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 311be90..56cc553 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1662,5 +1662,22 @@ static inline unsigned int debug_guardpage_minorder(void) { return 0; }
>  static inline bool page_is_guard(struct page *page) { return false; }
>  #endif /* CONFIG_DEBUG_PAGEALLOC */
>  
> +#if (defined(CONFIG_VIRTIO_BALLOON) || \
> +	defined(CONFIG_VIRTIO_BALLOON_MODULE)) && defined(CONFIG_COMPACTION)
> +extern bool isolate_balloon_page(struct page *);
> +extern void putback_balloon_page(struct page *);
> +extern struct address_space *balloon_mapping;
> +
> +static inline bool movable_balloon_page(struct page *page)
> +{
> +	return (page->mapping && page->mapping == balloon_mapping);

I am guessing this needs smp_read_barrier_depends, and maybe
ACCESS_ONCE ...

> +}
> +
> +#else
> +static inline bool isolate_balloon_page(struct page *page) { return false; }
> +static inline void putback_balloon_page(struct page *page) { return false; }
> +static inline bool movable_balloon_page(struct page *page) { return false; }
> +#endif /* (VIRTIO_BALLOON || VIRTIO_BALLOON_MODULE) && CONFIG_COMPACTION */
> +

This does mean that only one type of balloon is useable at a time.
I wonder whether using a flag in address_space structure instead
is possible ...

>  #endif /* __KERNEL__ */
>  #endif /* _LINUX_MM_H */
> diff --git a/mm/compaction.c b/mm/compaction.c
> index e78cb96..e4e871b 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -14,6 +14,7 @@
>  #include <linux/backing-dev.h>
>  #include <linux/sysctl.h>
>  #include <linux/sysfs.h>
> +#include <linux/export.h>
>  #include "internal.h"
>  
>  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
> @@ -21,6 +22,84 @@
>  #define CREATE_TRACE_POINTS
>  #include <trace/events/compaction.h>
>  
> +#if defined(CONFIG_VIRTIO_BALLOON) || defined(CONFIG_VIRTIO_BALLOON_MODULE)
> +/*
> + * Balloon pages special page->mapping.
> + * Users must properly allocate and initialize an instance of balloon_mapping,
> + * and set it as the page->mapping for balloon enlisted page instances.
> + * There is no need on utilizing struct address_space locking schemes for
> + * balloon_mapping as, once it gets initialized at balloon driver, it will
> + * remain just like a static reference that helps us on identifying a guest
> + * ballooned page by its mapping, as well as it will keep the 'a_ops' callback
> + * pointers to the functions that will execute the balloon page mobility tasks.
> + *
> + * address_space_operations necessary methods for ballooned pages:
> + *   .migratepage    - used to perform balloon's page migration (as is)
> + *   .invalidatepage - used to isolate a page from balloon's page list
> + *   .freepage       - used to reinsert an isolated page to balloon's page list
> + */
> +struct address_space *balloon_mapping;
> +EXPORT_SYMBOL_GPL(balloon_mapping);
> +
> +static inline void __isolate_balloon_page(struct page *page)
> +{
> +	page->mapping->a_ops->invalidatepage(page, 0);
> +}
> +
> +static inline void __putback_balloon_page(struct page *page)
> +{
> +	page->mapping->a_ops->freepage(page);
> +}
> +
> +/* __isolate_lru_page() counterpart for a ballooned page */
> +bool isolate_balloon_page(struct page *page)
> +{
> +	if (WARN_ON(!movable_balloon_page(page)))

Looks like this actually can happen if the page is leaked
between previous movable_balloon_page and here.

> +		return false;
> +
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
> +			 * an already isolated balloon page.
> +			 */
> +			if (movable_balloon_page(page) &&
> +			    (page_count(page) == 2)) {
> +				__isolate_balloon_page(page);
> +				unlock_page(page);
> +				return true;
> +			}
> +			unlock_page(page);
> +		}
> +		/* Drop refcount taken for this already isolated page */
> +		put_page(page);
> +	}
> +	return false;
> +}
> +
> +/* putback_lru_page() counterpart for a ballooned page */
> +void putback_balloon_page(struct page *page)
> +{
> +	if (WARN_ON(!movable_balloon_page(page)))
> +		return;
> +
> +	lock_page(page);
> +	__putback_balloon_page(page);
> +	put_page(page);
> +	unlock_page(page);
> +}
> +#endif /* CONFIG_VIRTIO_BALLOON || CONFIG_VIRTIO_BALLOON_MODULE */
> +
>  static unsigned long release_freepages(struct list_head *freelist)
>  {
>  	struct page *page, *next;
> @@ -312,32 +391,40 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  			continue;
>  		}
>  
> -		if (!PageLRU(page))
> -			continue;
> -
>  		/*
> -		 * PageLRU is set, and lru_lock excludes isolation,
> -		 * splitting and collapsing (collapsing has already
> -		 * happened if PageLRU is set).
> +		 * It is possible to migrate LRU pages and balloon pages.
> +		 * Skip any other type of page.
>  		 */
> -		if (PageTransHuge(page)) {
> -			low_pfn += (1 << compound_order(page)) - 1;
> -			continue;
> -		}
> +		if (PageLRU(page)) {
> +			/*
> +			 * PageLRU is set, and lru_lock excludes isolation,
> +			 * splitting and collapsing (collapsing has already
> +			 * happened if PageLRU is set).
> +			 */
> +			if (PageTransHuge(page)) {
> +				low_pfn += (1 << compound_order(page)) - 1;
> +				continue;
> +			}
>  
> -		if (!cc->sync)
> -			mode |= ISOLATE_ASYNC_MIGRATE;
> +			if (!cc->sync)
> +				mode |= ISOLATE_ASYNC_MIGRATE;
>  
> -		lruvec = mem_cgroup_page_lruvec(page, zone);
> +			lruvec = mem_cgroup_page_lruvec(page, zone);
>  
> -		/* Try isolate the page */
> -		if (__isolate_lru_page(page, mode) != 0)
> -			continue;
> +			/* Try isolate the page */
> +			if (__isolate_lru_page(page, mode) != 0)
> +				continue;
> +
> +			VM_BUG_ON(PageTransCompound(page));
>  
> -		VM_BUG_ON(PageTransCompound(page));
> +			/* Successfully isolated */
> +			del_page_from_lru_list(page, lruvec, page_lru(page));
> +		} else if (unlikely(movable_balloon_page(page))) {
> +			if (!isolate_balloon_page(page))
> +				continue;
> +		} else
> +			continue;
>  
> -		/* Successfully isolated */
> -		del_page_from_lru_list(page, lruvec, page_lru(page));
>  		list_add(&page->lru, migratelist);
>  		cc->nr_migratepages++;
>  		nr_isolated++;
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 77ed2d7..80f22bb 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -79,7 +79,10 @@ void putback_lru_pages(struct list_head *l)
>  		list_del(&page->lru);
>  		dec_zone_page_state(page, NR_ISOLATED_ANON +
>  				page_is_file_cache(page));
> -		putback_lru_page(page);
> +		if (unlikely(movable_balloon_page(page)))
> +			putback_balloon_page(page);
> +		else
> +			putback_lru_page(page);
>  	}
>  }
>  
> @@ -778,6 +781,17 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>  		}
>  	}
>  
> +	if (unlikely(movable_balloon_page(page))) {
> +		/*
> +		 * A ballooned page does not need any special attention from
> +		 * physical to virtual reverse mapping procedures.
> +		 * Skip any attempt to unmap PTEs or to remap swap cache,
> +		 * in order to avoid burning cycles at rmap level.
> +		 */
> +		remap_swapcache = 0;
> +		goto skip_unmap;
> +	}
> +
>  	/*
>  	 * Corner case handling:
>  	 * 1. When a new swap-cache page is read into, it is added to the LRU
> @@ -846,6 +860,20 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
>  			goto out;
>  
>  	rc = __unmap_and_move(page, newpage, force, offlining, mode);
> +
> +	if (unlikely(movable_balloon_page(newpage))) {
> +		/*
> +		 * A ballooned page has been migrated already. Now, it is the
> +		 * time to wrap-up counters, handle the old page back to Buddy
> +		 * and return.
> +		 */
> +		list_del(&page->lru);
> +		dec_zone_page_state(page, NR_ISOLATED_ANON +
> +				    page_is_file_cache(page));
> +		put_page(page);
> +		__free_page(page);
> +		return rc;
> +	}
>  out:
>  	if (rc != -EAGAIN) {
>  		/*
> -- 
> 1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
