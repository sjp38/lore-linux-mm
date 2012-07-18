Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 37DF06B0068
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 01:47:52 -0400 (EDT)
Date: Wed, 18 Jul 2012 14:48:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v4 1/3] mm: introduce compaction and migration for virtio
 ballooned pages
Message-ID: <20120718054824.GA32341@bbox>
References: <cover.1342485774.git.aquini@redhat.com>
 <49f828a9331c9b729fcf77226006921ec5bc52fa.1342485774.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49f828a9331c9b729fcf77226006921ec5bc52fa.1342485774.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Rafael Aquini <aquini@linux.com>

Hi Rafael,

On Tue, Jul 17, 2012 at 01:50:41PM -0300, Rafael Aquini wrote:
> This patch introduces the helper functions as well as the necessary changes
> to teach compaction and migration bits how to cope with pages which are
> part of a guest memory balloon, in order to make them movable by memory
> compaction procedures.
> 
> Signed-off-by: Rafael Aquini <aquini@redhat.com>
> ---
>  include/linux/mm.h |   15 +++++++
>  mm/compaction.c    |  126 ++++++++++++++++++++++++++++++++++++++++++++--------
>  mm/migrate.c       |   30 ++++++++++++-
>  3 files changed, 151 insertions(+), 20 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index b36d08c..3112198 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1629,5 +1629,20 @@ static inline unsigned int debug_guardpage_minorder(void) { return 0; }
>  static inline bool page_is_guard(struct page *page) { return false; }
>  #endif /* CONFIG_DEBUG_PAGEALLOC */
>  
> +#if (defined(CONFIG_VIRTIO_BALLOON) || \
> +	defined(CONFIG_VIRTIO_BALLOON_MODULE)) && defined(CONFIG_COMPACTION)
> +extern bool putback_balloon_page(struct page *);
> +extern struct address_space *balloon_mapping;
> +
> +static inline bool is_balloon_page(struct page *page)
> +{
> +	return (page->mapping == balloon_mapping) ? true : false;
> +}
> +#else
> +static inline bool is_balloon_page(struct page *page)       { return false; }
> +static inline bool isolate_balloon_page(struct page *page)  { return false; }
> +static inline bool putback_balloon_page(struct page *page)  { return false; }
> +#endif /* (VIRTIO_BALLOON || VIRTIO_BALLOON_MODULE) && COMPACTION */
> +
>  #endif /* __KERNEL__ */
>  #endif /* _LINUX_MM_H */
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 2f42d95..51eac0c 100644
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
> @@ -21,6 +22,85 @@
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
> +static bool isolate_balloon_page(struct page *page)
> +{
> +	if (WARN_ON(!is_balloon_page(page)))
> +		return false;

I am not sure we need this because you alreay check it before calling
isolate_balloon_page. If you really need it, it would be better to
add likely in isolate_balloon_page, too.

> +
> +	if (likely(get_page_unless_zero(page))) {
> +		/*
> +		 * We can race against move_to_new_page() & __unmap_and_move().
> +		 * If we stumble across a locked balloon page and succeed on
> +		 * isolating it, the result tends to be disastrous.
> +		 */
> +		if (likely(trylock_page(page))) {

Hmm, I can't understand your comment.
What does this lock protect? Could you elaborate it with code sequence?

> +			/*
> +			 * A ballooned page, by default, has just one refcount.
> +			 * Prevent concurrent compaction threads from isolating
> +			 * an already isolated balloon page.
> +			 */
> +			if (is_balloon_page(page) && (page_count(page) == 2)) {
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
> +bool putback_balloon_page(struct page *page)
> +{
> +	if (WARN_ON(!is_balloon_page(page)))
> +		return false;

You already check WARN_ON in putback_lru_pages so we don't need it in here.
And you can add likely in here, too.

> +
> +	if (likely(trylock_page(page))) {
> +		if (is_balloon_page(page)) {
> +			__putback_balloon_page(page);
> +			put_page(page);
> +			unlock_page(page);
> +			return true;
> +		}
> +		unlock_page(page);
> +	}
> +	return false;
> +}
> +#endif /* CONFIG_VIRTIO_BALLOON || CONFIG_VIRTIO_BALLOON_MODULE */
> +
>  static unsigned long release_freepages(struct list_head *freelist)
>  {
>  	struct page *page, *next;
> @@ -312,32 +392,40 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
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
> +		} else if (is_balloon_page(page)) {

unlikely?

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
> index be26d5c..59c7bc5 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -78,7 +78,10 @@ void putback_lru_pages(struct list_head *l)
>  		list_del(&page->lru);
>  		dec_zone_page_state(page, NR_ISOLATED_ANON +
>  				page_is_file_cache(page));
> -		putback_lru_page(page);
> +		if (unlikely(is_balloon_page(page)))
> +			WARN_ON(!putback_balloon_page(page));
> +		else
> +			putback_lru_page(page);

Hmm, I don't like this.
The function name says we putback *lru* pages, but balloon page isn't.
How about this?

diff --git a/mm/compaction.c b/mm/compaction.c
index aad0a16..b07cd67 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -298,6 +298,8 @@ static bool too_many_isolated(struct zone *zone)
  * Apart from cc->migratepages and cc->nr_migratetypes this function
  * does not modify any cc's fields, in particular it does not modify
  * (or read for that matter) cc->migrate_pfn.
+ * 
+ * For returning page, you should use putback_pages instead of putback_lru_pages
  */
 unsigned long
 isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
@@ -827,7 +829,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
                /* Release LRU pages not migrated */
                if (err) {
-                       putback_lru_pages(&cc->migratepages);
+                       putback_pages(&cc->migratepages);
                        cc->nr_migratepages = 0;
                        if (err == -ENOMEM) {
                                ret = COMPACT_PARTIAL;
diff --git a/mm/migrate.c b/mm/migrate.c
index 9705e70..a96b840 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -86,6 +86,22 @@ void putback_lru_pages(struct list_head *l)
        }
 }

+ /* blah blah .... */ 
+void putback_pages(struct list_head *l)
+{
+       struct page *page;
+       struct page *page2;
+
+       list_for_each_entry_safe(page, page2, l, lru) {
+               list_del(&page->lru);
+               dec_zone_page_state(page, NR_ISOLATED_ANON +
+                               page_is_file_cache(page));
+               if (unlikely(is_balloon_page(page)))
+                       WARN_ON(!putback_balloon_page(page));
+               else
+                       putback_lru_page(page);
+       }
+}
+
 /*
  * Restore a potential migration pte to a working pte entry
  */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 32985dd..decb82a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5655,7 +5655,7 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
                                    0, false, MIGRATE_SYNC);
        }
 
-       putback_lru_pages(&cc.migratepages);
+       putback_pages(&cc.migratepages);
        return ret > 0 ? 0 : ret;
 }

>  	}
>  }
>  
> @@ -783,6 +786,17 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>  		}
>  	}
>  
> +	if (is_balloon_page(page)) {

unlikely?

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
> @@ -852,6 +866,20 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
>  			goto out;
>  
>  	rc = __unmap_and_move(page, newpage, force, offlining, mode);
> +
> +	if (is_balloon_page(newpage)) {

unlikely?

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

Why do you use __free_page instead of put_page?

> +		return rc;
> +	}
>  out:
>  	if (rc != -EAGAIN) {
>  		/*
> -- 
> 1.7.10.4

The feeling I look at your code in detail is that it makes compaction/migration
code rather complicated because compaction/migration assumes source/target would
be LRU pages. 

How often memory ballooning happens? Does it make sense to hook it in generic
functions if it's very rare?

Couldn't you implement it like huge page?
It doesn't make current code complicated and doesn't affect performance

In compaction,
#ifdef CONFIG_VIRTIO_BALLOON
static int compact_zone(struct zone *zone, struct compact_control *cc, bool balloon)
{
        if (balloon) {
                isolate_balloonpages

                migrate_balloon_pages
                        unmap_and_move_balloon_page

                putback_balloonpages
        }
}
#endif

I'm not sure memory ballooning so it might be dumb question.
Can we trigger it once only when ballooning happens?

Thanks!
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
