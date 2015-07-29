Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id BD5BA6B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 06:52:43 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so20375276wib.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 03:52:43 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id p3si6735037wjz.93.2015.07.29.03.52.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Jul 2015 03:52:42 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 16EBA99272
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 10:52:41 +0000 (UTC)
Date: Wed, 29 Jul 2015 11:52:38 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/4] mm/compaction: enable mobile-page migration
Message-ID: <20150729105238.GC30872@techsingularity.net>
References: <1436776519-17337-1-git-send-email-gioh.kim@lge.com>
 <1436776519-17337-3-git-send-email-gioh.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1436776519-17337-3-git-send-email-gioh.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: jlayton@poochiereds.net, bfields@fieldses.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, viro@zeniv.linux.org.uk, mst@redhat.com, koct9i@gmail.com, minchan@kernel.org, aquini@redhat.com, linux-fsdevel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, akpm@linux-foundation.org, Gioh Kim <gurugio@hanmail.net>

On Mon, Jul 13, 2015 at 05:35:17PM +0900, Gioh Kim wrote:
> From: Gioh Kim <gurugio@hanmail.net>
> 
> Add framework to register callback functions and check page mobility.
> There are some modes for page isolation so that isolate interface
> has arguments of page address and isolation mode while putback
> interface has only page address as argument.
> 
> Signed-off-by: Gioh Kim <gioh.kim@lge.com>
> Acked-by: Rafael Aquini <aquini@redhat.com>
> ---
>  fs/proc/page.c                         |  3 ++
>  include/linux/compaction.h             | 80 ++++++++++++++++++++++++++++++++++
>  include/linux/fs.h                     |  2 +
>  include/linux/page-flags.h             | 19 ++++++++
>  include/uapi/linux/kernel-page-flags.h |  1 +
>  5 files changed, 105 insertions(+)
> 

An update to the address_space operations in
Documentation/filesystems/Locking and Documentation/filesystems/vfs.txt
is required. I was going to say "recommended" but it really is required.
The responsibilities and locking rules of these interfaces must be extremely
clear as you may be asking multiple driver authors to use this interface.

For example, it must be clear to users of these interfaces that the isolate
must prevent any parallel updates to the data, prevent parallel frees and
halt attempted accesses until migration is complete. It will not always
be obvious how to do this and may not be obvious that it is required if
someone has not experienced the joy that is mm/migrate.c. For example,
mapped LRU pages get unmapped with migration entries so faults that access
the data wait until the migration completes. Balloons, zram, graphics will
need to provide similar guarantees.

As data accesses may now sleep due to migration, drivers will need to
be careful that it is safe to sleep and suggest that they do not attempt
to spin.

Depending on how it is implemented, the putback may be responsible for
waking up any tasks waiting to access the page.

There are going to be more hazards here which is why documentation to spell
it out is ideal and that zram gets converted to find all the locking and
access pitfalls.

> diff --git a/fs/proc/page.c b/fs/proc/page.c
> index 7eee2d8..a4f5a00 100644
> --- a/fs/proc/page.c
> +++ b/fs/proc/page.c
> @@ -146,6 +146,9 @@ u64 stable_page_flags(struct page *page)
>  	if (PageBalloon(page))
>  		u |= 1 << KPF_BALLOON;
>  
> +	if (PageMobile(page))
> +		u |= 1 << KPF_MOBILE;
> +
>  	u |= kpf_copy_bit(k, KPF_LOCKED,	PG_locked);
>  
>  	u |= kpf_copy_bit(k, KPF_SLAB,		PG_slab);
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index aa8f61c..f693072 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -1,6 +1,9 @@
>  #ifndef _LINUX_COMPACTION_H
>  #define _LINUX_COMPACTION_H
>  
> +#include <linux/page-flags.h>
> +#include <linux/pagemap.h>
> +
>  /* Return values for compact_zone() and try_to_compact_pages() */
>  /* compaction didn't start as it was deferred due to past failures */
>  #define COMPACT_DEFERRED	0
> @@ -51,6 +54,70 @@ extern void compaction_defer_reset(struct zone *zone, int order,
>  				bool alloc_success);
>  extern bool compaction_restarting(struct zone *zone, int order);
>  
> +static inline bool mobile_page(struct page *page)
> +{
> +	return page->mapping &&	(PageMobile(page) || PageBalloon(page));
> +}
> +

This creates an oddity because now there is a disconnect between movable
and mobile pages. They are similar but different.

o A Mobile page is a driver-owned page that has the address space
  operations that enable migration.

o A Movable page is generally a page mapped by page tables that can be
  migrated using the existing mechanisms.

The concepts should be unified.

A Mobile page is a driver-owner page that has the address space
operations that enable migration. Pages that are mapped by userspace are
considered to be mobile with the following properties

	a_ops->isolatepage isolates the page from the LRU to prevent
	parallel reclaim. It is unmapped from page tables using rmap
	with PTEs replaced by migration entries. Any attempt to access
	the page will wait in page fault until the migration completes.

	a_ops->putbackpage removes the migration entries and wakes up
	all waiters in page fault.

	A further property is that allocation of this type specified
	__GFP_MOVABLE to group them all together. They are the most mobile
	page category that are cheapest to move. In theory, all mobile
	pages could be allocated __GFP_MOVABLE if it's known in advance
	the page->mapping will have the necessary operations in the
	future.

?

A complicating factor is that a Movable page as it's currently defined
may not have a page->mapping. You'd have to continue replying on PageLRU to
identify them as a special page that has access to the necessary isolateppage
and putbackpage helpers. However, at least we would have a single view
on what a movable page is.

Additional note: After I wrote the above, I read the other reviews. I
	did not read them in advance so I'd have a fresh view. I see
	Konstantin Khlebnikov has been active and he suggested the mobility
	naming to distinguish between the LRU pages. I simply disagree
	even though I see his reasoning. I do not think we should have a
	special case of LRU pages and everything else. Instead we should
	have a single concept of movability (or mobility) with the special
	case being that LRU pages without an aops can directly call the
	necessary helpers.

> +static inline bool isolate_mobilepage(struct page *page, isolate_mode_t mode)
> +{
> +	bool ret = false;
> +
> +	/*
> +	 * Avoid burning cycles with pages that are yet under __free_pages(),
> +	 * or just got freed under us.
> +	 *
> +	 * In case we 'win' a race for a mobile page being freed under us and
> +	 * raise its refcount preventing __free_pages() from doing its job
> +	 * the put_page() at the end of this block will take care of
> +	 * release this page, thus avoiding a nasty leakage.
> +	 */
> +	if (unlikely(!get_page_unless_zero(page)))
> +		goto out;
> +

Ok.

> +	/*
> +	 * As mobile pages are not isolated from LRU lists, concurrent
> +	 * compaction threads can race against page migration functions
> +	 * as well as race against the releasing a page.
> +	 *
> +	 * In order to avoid having an already isolated mobile page
> +	 * being (wrongly) re-isolated while it is under migration,
> +	 * or to avoid attempting to isolate pages being released,
> +	 * lets be sure we have the page lock
> +	 * before proceeding with the mobile page isolation steps.
> +	 */
> +	if (unlikely(!trylock_page(page)))
> +		goto out_putpage;
> +

There are some big assumptions here. It assumes that any users of this
interface can prevent parallel compaction attempts via the page lock. It
also assumes that the caller does not recursively hold the page lock already.
It would be incompatible with how LRU pages are isolated as they co-ordinate
via the zone->lru_lock.

I suspect you went with the page lock because it happens to be what the
balloon driver needed which is fine, but potentially pastes us into a
corner later.

I don't see a way this could be generically handled for arbitrary subsystems
unless you put responsibility for the locking inside a_ops->isolatepage. That
still works for existing movable pages if you give it a pseudo a_ops for
pages without page->mapping.

Because of this, I really think it would benefit if there was a patch
3 that converted the existing migration of LRU pages to use the aops
interface. This could be done via a fake address_space that only populates
the migration interfaces and is used for LRU pages. Then remove the LRU
special casing in compaction and migration before converting the balloon
driver and zram. This will rattle out any conceivable locking hazard and
unify migration in general. I recognise that it's a lot of heavy lifting
unfortunately but it leaves you with a partial solution to your problem
(zram in the way) and paves the way for drivers to reliably convert.

> +	if (!(mobile_page(page) && page->mapping->a_ops->isolatepage))
> +		goto out_not_isolated;
> +	ret = page->mapping->a_ops->isolatepage(page, mode);
> +	if (!ret)
> +		goto out_not_isolated;
> +	unlock_page(page);
> +	return ret;
> +
> +out_not_isolated:
> +	unlock_page(page);
> +out_putpage:
> +	put_page(page);
> +out:
> +	return ret;
> +}
> +
> +static inline void putback_mobilepage(struct page *page)
> +{
> +	/*
> +	 * 'lock_page()' stabilizes the page and prevents races against
> +	 * concurrent isolation threads attempting to re-isolate it.
> +	 */
> +	lock_page(page);
> +	if (page->mapping && page->mapping->a_ops->putbackpage)
> +		page->mapping->a_ops->putbackpage(page);
> +	unlock_page(page);
> +	/* drop the extra ref count taken for mobile page isolation */
> +	put_page(page);
> +}

Similar comments about the locking, I think the a_ops handler needs to be
responsible. We should not expand the role of the page->lock in the
general case.

>  #else
>  static inline unsigned long try_to_compact_pages(gfp_t gfp_mask,
>  			unsigned int order, int alloc_flags,
> @@ -83,6 +150,19 @@ static inline bool compaction_deferred(struct zone *zone, int order)
>  	return true;
>  }
>  
> +static inline bool mobile_page(struct page *page)
> +{
> +	return false;
> +}
> +
> +static inline bool isolate_mobilepage(struct page *page, isolate_mode_t mode)
> +{
> +	return false;
> +}
> +
> +static inline void putback_mobilepage(struct page *page)
> +{
> +}
>  #endif /* CONFIG_COMPACTION */
>  
>  #if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index a0653e5..2cc4b24 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -396,6 +396,8 @@ struct address_space_operations {
>  	 */
>  	int (*migratepage) (struct address_space *,
>  			struct page *, struct page *, enum migrate_mode);
> +	bool (*isolatepage) (struct page *, isolate_mode_t);
> +	void (*putbackpage) (struct page *);
>  	int (*launder_page) (struct page *);
>  	int (*is_partially_uptodate) (struct page *, unsigned long,
>  					unsigned long);
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index f34e040..abef145 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -582,6 +582,25 @@ static inline void __ClearPageBalloon(struct page *page)
>  	atomic_set(&page->_mapcount, -1);
>  }
>  
> +#define PAGE_MOBILE_MAPCOUNT_VALUE (-255)
> +
> +static inline int PageMobile(struct page *page)
> +{
> +	return atomic_read(&page->_mapcount) == PAGE_MOBILE_MAPCOUNT_VALUE;
> +}
> +
> +static inline void __SetPageMobile(struct page *page)
> +{
> +	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
> +	atomic_set(&page->_mapcount, PAGE_MOBILE_MAPCOUNT_VALUE);
> +}
> +
> +static inline void __ClearPageMobile(struct page *page)
> +{
> +	VM_BUG_ON_PAGE(!PageMobile(page), page);
> +	atomic_set(&page->_mapcount, -1);
> +}
> +

This definition of Mobility would prevent LRU pages ever being considered
"mobile" in the same why. Why do we not either check it's an LRU page (in
which case it's inherently mobile) or has an aops with the correct handlers?

>  /*
>   * If network-based swap is enabled, sl*b must keep track of whether pages
>   * were allocated from pfmemalloc reserves.
> diff --git a/include/uapi/linux/kernel-page-flags.h b/include/uapi/linux/kernel-page-flags.h
> index a6c4962..d50d9e8 100644
> --- a/include/uapi/linux/kernel-page-flags.h
> +++ b/include/uapi/linux/kernel-page-flags.h
> @@ -33,6 +33,7 @@
>  #define KPF_THP			22
>  #define KPF_BALLOON		23
>  #define KPF_ZERO_PAGE		24
> +#define KPF_MOBILE		25
>  
>  
>  #endif /* _UAPILINUX_KERNEL_PAGE_FLAGS_H */

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
