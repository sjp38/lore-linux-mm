Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 38EB76B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 18:03:43 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so6243225pbb.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 15:03:42 -0700 (PDT)
Date: Sat, 30 Jun 2012 07:03:33 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 1/4] mm: introduce compaction and migration for virtio
 ballooned pages
Message-ID: <20120629220333.GA2079@barrios>
References: <cover.1340916058.git.aquini@redhat.com>
 <d0f33a6492501a0d420abbf184f9b956cff3e3fc.1340916058.git.aquini@redhat.com>
 <4FED3DDB.1000903@kernel.org>
 <20120629173653.GA1774@t510.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120629173653.GA1774@t510.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>

Hi Rafael,

On Fri, Jun 29, 2012 at 02:36:54PM -0300, Rafael Aquini wrote:
> On Fri, Jun 29, 2012 at 02:32:11PM +0900, Minchan Kim wrote:
> > On 06/29/2012 06:49 AM, Rafael Aquini wrote:
> > 
> > > This patch introduces the helper functions as well as the necessary changes
> > > to teach compaction and migration bits how to cope with pages which are
> > > part of a guest memory balloon, in order to make them movable by memory
> > > compaction procedures.
> > > 
> > > Signed-off-by: Rafael Aquini <aquini@redhat.com>
> > 
> > 
> > Just a few comment but not critical. :)
> > 
> > > ---
> > >  include/linux/mm.h |   16 ++++++++
> > >  mm/compaction.c    |  110 +++++++++++++++++++++++++++++++++++++++++++---------
> > >  mm/migrate.c       |   30 +++++++++++++-
> > >  3 files changed, 136 insertions(+), 20 deletions(-)
> > > 
> > > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > > index b36d08c..35568fc 100644
> > > --- a/include/linux/mm.h
> > > +++ b/include/linux/mm.h
> > > @@ -1629,5 +1629,21 @@ static inline unsigned int debug_guardpage_minorder(void) { return 0; }
> > >  static inline bool page_is_guard(struct page *page) { return false; }
> > >  #endif /* CONFIG_DEBUG_PAGEALLOC */
> > >  
> > > +#if (defined(CONFIG_VIRTIO_BALLOON) || \
> > > +	defined(CONFIG_VIRTIO_BALLOON_MODULE)) && defined(CONFIG_COMPACTION)
> > > +extern bool isolate_balloon_page(struct page *);
> > > +extern bool putback_balloon_page(struct page *);
> > > +extern struct address_space *balloon_mapping;
> > > +
> > > +static inline bool is_balloon_page(struct page *page)
> > > +{
> > > +        return (page->mapping == balloon_mapping) ? true : false;
> > > +}
> > 
> > 
> > What lock should it protect?
> > 
> I'm afraid I didn't quite get what you meant by that question. If you were
> referring to lock protection to the address_space balloon_mapping, we don't need
> it. balloon_mapping, once initialized lives forever (as long as driver is
> loaded, actually) as a static reference that just helps us on identifying pages 
> that are enlisted in a memory balloon as well as it keeps the callback pointers 
> to functions that will make those pages mobility magic happens.

Thanks. That's what I want to know.
If anyone(like me don't know of ballooning in detail) see this, it would be very helpful.

> 
> 
> 
> > > +#else
> > > +static inline bool is_balloon_page(struct page *page)       { return false; }
> > > +static inline bool isolate_balloon_page(struct page *page)  { return false; }
> > > +static inline bool putback_balloon_page(struct page *page)  { return false; }
> > > +#endif /* (VIRTIO_BALLOON || VIRTIO_BALLOON_MODULE) && COMPACTION */
> > > +
> > >  #endif /* __KERNEL__ */
> > >  #endif /* _LINUX_MM_H */
> > > diff --git a/mm/compaction.c b/mm/compaction.c
> > > index 7ea259d..6c6e572 100644
> > > --- a/mm/compaction.c
> > > +++ b/mm/compaction.c
> > > @@ -14,6 +14,7 @@
> > >  #include <linux/backing-dev.h>
> > >  #include <linux/sysctl.h>
> > >  #include <linux/sysfs.h>
> > > +#include <linux/export.h>
> > >  #include "internal.h"
> > >  
> > >  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
> > > @@ -312,32 +313,40 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
> > >  			continue;
> > >  		}
> > >  
> > > -		if (!PageLRU(page))
> > > -			continue;
> > > -
> > >  		/*
> > > -		 * PageLRU is set, and lru_lock excludes isolation,
> > > -		 * splitting and collapsing (collapsing has already
> > > -		 * happened if PageLRU is set).
> > > +		 * It is possible to migrate LRU pages and balloon pages.
> > > +		 * Skip any other type of page.
> > >  		 */
> > > -		if (PageTransHuge(page)) {
> > > -			low_pfn += (1 << compound_order(page)) - 1;
> > > -			continue;
> > > -		}
> > > +		if (likely(PageLRU(page))) {
> > 
> > 
> > We can't make sure it is likely because there might be so many pages for kernel.
> > 
> I thought that by that far in codepath that would be the likelihood since most
> pages of an ordinary workload will be at LRU lists. Following that idea, it
> sounded neat to hint the compiler to not branch for that block. But, if in the
> end that is just a "bad hint", I'll get rid of it right away.

Yeb. I hope you remove this.
If you want really, it should be separated patch because it's not related to your
series.

> 
> 
> > > +			/*
> > > +			 * PageLRU is set, and lru_lock excludes isolation,
> > > +			 * splitting and collapsing (collapsing has already
> > > +			 * happened if PageLRU is set).
> > > +			 */
> > > +			if (PageTransHuge(page)) {
> > > +				low_pfn += (1 << compound_order(page)) - 1;
> > > +				continue;
> > > +			}
> > >  
> > > -		if (!cc->sync)
> > > -			mode |= ISOLATE_ASYNC_MIGRATE;
> > > +			if (!cc->sync)
> > > +				mode |= ISOLATE_ASYNC_MIGRATE;
> > >  
> > > -		lruvec = mem_cgroup_page_lruvec(page, zone);
> > > +			lruvec = mem_cgroup_page_lruvec(page, zone);
> > >  
> > > -		/* Try isolate the page */
> > > -		if (__isolate_lru_page(page, mode) != 0)
> > > -			continue;
> > > +			/* Try isolate the page */
> > > +			if (__isolate_lru_page(page, mode) != 0)
> > > +				continue;
> > >  
> > > -		VM_BUG_ON(PageTransCompound(page));
> > > +			VM_BUG_ON(PageTransCompound(page));
> > > +
> > > +			/* Successfully isolated */
> > > +			del_page_from_lru_list(page, lruvec, page_lru(page));
> > > +		} else if (is_balloon_page(page)) {
> > > +			if (!isolate_balloon_page(page))
> > > +				continue;
> > > +		} else
> > > +			continue;
> > >  
> > > -		/* Successfully isolated */
> > > -		del_page_from_lru_list(page, lruvec, page_lru(page));
> > >  		list_add(&page->lru, migratelist);
> > >  		cc->nr_migratepages++;
> > >  		nr_isolated++;
> > > @@ -903,4 +912,67 @@ void compaction_unregister_node(struct node *node)
> > >  }
> > >  #endif /* CONFIG_SYSFS && CONFIG_NUMA */
> > >  
> > > +#if defined(CONFIG_VIRTIO_BALLOON) || defined(CONFIG_VIRTIO_BALLOON_MODULE)
> > > +/*
> > > + * Balloon pages special page->mapping.
> > > + * users must properly allocate and initialize an instance of balloon_mapping,
> > > + * and set it as the page->mapping for balloon enlisted page instances.
> > > + *
> > > + * address_space_operations necessary methods for ballooned pages:
> > > + *   .migratepage    - used to perform balloon's page migration (as is)
> > > + *   .invalidatepage - used to isolate a page from balloon's page list
> > > + *   .freepage       - used to reinsert an isolated page to balloon's page list
> > > + */
> > > +struct address_space *balloon_mapping;
> > > +EXPORT_SYMBOL_GPL(balloon_mapping);
> > > +
> > > +/* __isolate_lru_page() counterpart for a ballooned page */
> > > +bool isolate_balloon_page(struct page *page)
> > > +{
> > > +	if (WARN_ON(!is_balloon_page(page)))
> > > +		return false;
> > > +
> > > +	if (likely(get_page_unless_zero(page))) {
> > > +		/*
> > > +		 * We can race against move_to_new_page() & __unmap_and_move().
> > > +		 * If we stumble across a locked balloon page and succeed on
> > > +		 * isolating it, the result tends to be disastrous.
> > > +		 */
> > > +		if (likely(trylock_page(page))) {
> > > +			/*
> > > +			 * A ballooned page, by default, has just one refcount.
> > > +			 * Prevent concurrent compaction threads from isolating
> > > +			 * an already isolated balloon page.
> > > +			 */
> > > +			if (is_balloon_page(page) && (page_count(page) == 2)) {
> > > +				page->mapping->a_ops->invalidatepage(page, 0);
> > 
> > 
> > Could you add more meaningful name wrapping raw invalidatepage?
> > But I don't know what is proper name. ;)
> > 
> If I understood you correctely, your suggestion is to add two extra callback
> pointers to struct address_space_operations, instead of re-using those which are
> already there, and are suitable for the mission. Is this really necessary? It
> seems just like unecessary bloat to struct address_space_operations, IMHO.

I meant this. :)

void isolate_page_from_balloonlist(struct page* page)
{
	page->mapping->a_ops->invalidatepage(page, 0);
}

	if (is_balloon_page(page) && (page_count(page) == 2)) {
		isolate_page_from_balloonlist(page);
	}

Thanks!

> -- 
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
