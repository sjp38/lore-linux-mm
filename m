Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id DCAD86B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 10:54:33 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id n5so314619724pfn.2
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 07:54:33 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id v67si6842601pfa.181.2016.03.22.07.54.32
        for <linux-mm@kvack.org>;
        Tue, 22 Mar 2016 07:54:32 -0700 (PDT)
Date: Tue, 22 Mar 2016 23:55:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 13/18] mm/compaction: support non-lru movable page
 migration
Message-ID: <20160322145545.GB3221@bbox>
References: <1458541867-27380-1-git-send-email-minchan@kernel.org>
 <1458541867-27380-14-git-send-email-minchan@kernel.org>
 <20160322055037.GC31955@js1304-P5Q-DELUXE>
MIME-Version: 1.0
In-Reply-To: <20160322055037.GC31955@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, dri-devel@lists.freedesktop.org, Gioh Kim <gurugio@hanmail.net>

On Tue, Mar 22, 2016 at 02:50:37PM +0900, Joonsoo Kim wrote:
> On Mon, Mar 21, 2016 at 03:31:02PM +0900, Minchan Kim wrote:
> > We have allowed migration for only LRU pages until now and it was
> > enough to make high-order pages. But recently, embedded system(e.g.,
> > webOS, android) uses lots of non-movable pages(e.g., zram, GPU memory)
> > so we have seen several reports about troubles of small high-order
> > allocation. For fixing the problem, there were several efforts
> > (e,g,. enhance compaction algorithm, SLUB fallback to 0-order page,
> > reserved memory, vmalloc and so on) but if there are lots of
> > non-movable pages in system, their solutions are void in the long run.
> > 
> > So, this patch is to support facility to change non-movable pages
> > with movable. For the feature, this patch introduces functions related
> > to migration to address_space_operations as well as some page flags.
> > 
> > Basically, this patch supports two page-flags and two functions related
> > to page migration. The flag and page->mapping stability are protected
> > by PG_lock.
> > 
> > 	PG_movable
> > 	PG_isolated
> > 
> > 	bool (*isolate_page) (struct page *, isolate_mode_t);
> > 	void (*putback_page) (struct page *);
> > 
> > Duty of subsystem want to make their pages as migratable are
> > as follows:
> > 
> > 1. It should register address_space to page->mapping then mark
> > the page as PG_movable via __SetPageMovable.
> > 
> > 2. It should mark the page as PG_isolated via SetPageIsolated
> > if isolation is sucessful and return true.
> > 
> > 3. If migration is successful, it should clear PG_isolated and
> > PG_movable of the page for free preparation then release the
> > reference of the page to free.
> > 
> > 4. If migration fails, putback function of subsystem should
> > clear PG_isolated via ClearPageIsolated.
> 
> I think that this feature needs a separate document to describe
> requirement of each step in more detail. For example, #1 can be
> possible without holding a lock? I'm not sure because you lock
> the page when implementing zsmalloc page migration in 15th patch.

Yes, we needs PG_lock because install page->mapping and PG_movable
should be atomic and PG_lock protects it.

Better interface might be

void __SetPageMovable(struct page *page, sruct address_space *mapping);

> 
> #3 also need more explanation. Before release, we need to
> unregister address_space. I guess that it needs to be done
> in migratepage() but there is no explanation.

Okay, we can unregister address_space in __ClearPageMovable.
I will change it.

> 
> > 
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: dri-devel@lists.freedesktop.org
> > Cc: virtualization@lists.linux-foundation.org
> > Signed-off-by: Gioh Kim <gurugio@hanmail.net>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  Documentation/filesystems/Locking      |   4 +
> >  Documentation/filesystems/vfs.txt      |   5 ++
> >  fs/proc/page.c                         |   3 +
> >  include/linux/fs.h                     |   2 +
> >  include/linux/migrate.h                |   2 +
> >  include/linux/page-flags.h             |  29 ++++++++
> >  include/uapi/linux/kernel-page-flags.h |   1 +
> >  mm/compaction.c                        |  14 +++-
> >  mm/migrate.c                           | 132 +++++++++++++++++++++++++++++----
> >  9 files changed, 177 insertions(+), 15 deletions(-)
> > 
> > diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
> > index 619af9bfdcb3..0bb79560abb3 100644
> > --- a/Documentation/filesystems/Locking
> > +++ b/Documentation/filesystems/Locking
> > @@ -195,7 +195,9 @@ unlocks and drops the reference.
> >  	int (*releasepage) (struct page *, int);
> >  	void (*freepage)(struct page *);
> >  	int (*direct_IO)(struct kiocb *, struct iov_iter *iter, loff_t offset);
> > +	bool (*isolate_page) (struct page *, isolate_mode_t);
> >  	int (*migratepage)(struct address_space *, struct page *, struct page *);
> > +	void (*putback_page) (struct page *);
> >  	int (*launder_page)(struct page *);
> >  	int (*is_partially_uptodate)(struct page *, unsigned long, unsigned long);
> >  	int (*error_remove_page)(struct address_space *, struct page *);
> > @@ -219,7 +221,9 @@ invalidatepage:		yes
> >  releasepage:		yes
> >  freepage:		yes
> >  direct_IO:
> > +isolate_page:		yes
> >  migratepage:		yes (both)
> > +putback_page:		yes
> >  launder_page:		yes
> >  is_partially_uptodate:	yes
> >  error_remove_page:	yes
> > diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
> > index b02a7d598258..4c1b6c3b4bc8 100644
> > --- a/Documentation/filesystems/vfs.txt
> > +++ b/Documentation/filesystems/vfs.txt
> > @@ -592,9 +592,14 @@ struct address_space_operations {
> >  	int (*releasepage) (struct page *, int);
> >  	void (*freepage)(struct page *);
> >  	ssize_t (*direct_IO)(struct kiocb *, struct iov_iter *iter, loff_t offset);
> > +	/* isolate a page for migration */
> > +	bool (*isolate_page) (struct page *, isolate_mode_t);
> >  	/* migrate the contents of a page to the specified target */
> >  	int (*migratepage) (struct page *, struct page *);
> > +	/* put the page back to right list */
> > +	void (*putback_page) (struct page *);
> >  	int (*launder_page) (struct page *);
> > +
> >  	int (*is_partially_uptodate) (struct page *, unsigned long,
> >  					unsigned long);
> >  	void (*is_dirty_writeback) (struct page *, bool *, bool *);
> > diff --git a/fs/proc/page.c b/fs/proc/page.c
> > index 712f1b9992cc..e2066e73a9b8 100644
> > --- a/fs/proc/page.c
> > +++ b/fs/proc/page.c
> > @@ -157,6 +157,9 @@ u64 stable_page_flags(struct page *page)
> >  	if (page_is_idle(page))
> >  		u |= 1 << KPF_IDLE;
> >  
> > +	if (PageMovable(page))
> > +		u |= 1 << KPF_MOVABLE;
> > +
> >  	u |= kpf_copy_bit(k, KPF_LOCKED,	PG_locked);
> >  
> >  	u |= kpf_copy_bit(k, KPF_SLAB,		PG_slab);
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index 14a97194b34b..b7ef2e41fa4a 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -401,6 +401,8 @@ struct address_space_operations {
> >  	 */
> >  	int (*migratepage) (struct address_space *,
> >  			struct page *, struct page *, enum migrate_mode);
> > +	bool (*isolate_page)(struct page *, isolate_mode_t);
> > +	void (*putback_page)(struct page *);
> >  	int (*launder_page) (struct page *);
> >  	int (*is_partially_uptodate) (struct page *, unsigned long,
> >  					unsigned long);
> > diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> > index 9b50325e4ddf..404fbfefeb33 100644
> > --- a/include/linux/migrate.h
> > +++ b/include/linux/migrate.h
> > @@ -37,6 +37,8 @@ extern int migrate_page(struct address_space *,
> >  			struct page *, struct page *, enum migrate_mode);
> >  extern int migrate_pages(struct list_head *l, new_page_t new, free_page_t free,
> >  		unsigned long private, enum migrate_mode mode, int reason);
> > +extern bool isolate_movable_page(struct page *page, isolate_mode_t mode);
> > +extern void putback_movable_page(struct page *page);
> >  
> >  extern int migrate_prep(void);
> >  extern int migrate_prep_local(void);
> > diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> > index f4ed4f1b0c77..3885064641c4 100644
> > --- a/include/linux/page-flags.h
> > +++ b/include/linux/page-flags.h
> > @@ -129,6 +129,10 @@ enum pageflags {
> >  
> >  	/* Compound pages. Stored in first tail page's flags */
> >  	PG_double_map = PG_private_2,
> > +
> > +	/* non-lru movable pages */
> > +	PG_movable = PG_reclaim,
> > +	PG_isolated = PG_owner_priv_1,
> >  };
> >  
> >  #ifndef __GENERATING_BOUNDS_H
> > @@ -614,6 +618,31 @@ static inline void __ClearPageBalloon(struct page *page)
> >  	atomic_set(&page->_mapcount, -1);
> >  }
> >  
> > +#define PAGE_MOVABLE_MAPCOUNT_VALUE (-255)
> > +
> > +static inline int PageMovable(struct page *page)
> > +{
> > +	return ((test_bit(PG_movable, &(page)->flags) &&
> > +		atomic_read(&page->_mapcount) == PAGE_MOVABLE_MAPCOUNT_VALUE)
> > +		|| PageBalloon(page));
> > +}
> > +
> > +/*
> > + * Caller should hold a PG_lock */
> > +static inline void __SetPageMovable(struct page *page)
> > +{
> > +	__set_bit(PG_movable, &page->flags);
> > +	atomic_set(&page->_mapcount, PAGE_MOVABLE_MAPCOUNT_VALUE);
> > +}
> 
> I think there is no big benefit to use non-atomic version here.
> PageMovable() is speculatively checked without holding a PG_lock
> so some cpu can miss this flag set if we use non-atomic version.

I wanted to show that double underscore is non-atomic so caller
should take care of the lock(i.e., PG_lock).
If we use atomic version, what kinds of benefit do we have?
Without holding PG_lock, atomic version could be raced, too.

> 
> > +
> > +static inline void __ClearPageMovable(struct page *page)
> > +{
> > +	atomic_set(&page->_mapcount, -1);
> > +	__clear_bit(PG_movable, &(page)->flags);
> > +}
> > +
> > +PAGEFLAG(Isolated, isolated, PF_ANY);
> > +
> >  /*
> >   * If network-based swap is enabled, sl*b must keep track of whether pages
> >   * were allocated from pfmemalloc reserves.
> > diff --git a/include/uapi/linux/kernel-page-flags.h b/include/uapi/linux/kernel-page-flags.h
> > index 5da5f8751ce7..a184fd2434fa 100644
> > --- a/include/uapi/linux/kernel-page-flags.h
> > +++ b/include/uapi/linux/kernel-page-flags.h
> > @@ -34,6 +34,7 @@
> >  #define KPF_BALLOON		23
> >  #define KPF_ZERO_PAGE		24
> >  #define KPF_IDLE		25
> > +#define KPF_MOVABLE		26
> >  
> >  
> >  #endif /* _UAPILINUX_KERNEL_PAGE_FLAGS_H */
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index ccf97b02b85f..7557aedddaee 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -703,7 +703,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
> >  
> >  		/*
> >  		 * Check may be lockless but that's ok as we recheck later.
> > -		 * It's possible to migrate LRU pages and balloon pages
> > +		 * It's possible to migrate LRU and movable kernel pages.
> >  		 * Skip any other type of page
> >  		 */
> >  		is_lru = PageLRU(page);
> > @@ -714,6 +714,18 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
> >  					goto isolate_success;
> >  				}
> >  			}
> > +
> > +			if (unlikely(PageMovable(page)) &&
> > +					!PageIsolated(page)) {
> > +				if (locked) {
> > +					spin_unlock_irqrestore(&zone->lru_lock,
> > +									flags);
> > +					locked = false;
> > +				}
> > +
> > +				if (isolate_movable_page(page, isolate_mode))
> > +					goto isolate_success;
> > +			}
> >  		}
> >  
> >  		/*
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index b65c84267ce0..fc2842a15807 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -73,6 +73,75 @@ int migrate_prep_local(void)
> >  	return 0;
> >  }
> >  
> > +bool isolate_movable_page(struct page *page, isolate_mode_t mode)
> > +{
> > +	bool ret = false;
> > +
> > +	/*
> > +	 * Avoid burning cycles with pages that are yet under __free_pages(),
> > +	 * or just got freed under us.
> > +	 *
> > +	 * In case we 'win' a race for a movable page being freed under us and
> > +	 * raise its refcount preventing __free_pages() from doing its job
> > +	 * the put_page() at the end of this block will take care of
> > +	 * release this page, thus avoiding a nasty leakage.
> > +	 */
> > +	if (unlikely(!get_page_unless_zero(page)))
> > +		goto out;
> 
> After getting the ref counter, we need to re-check PageMovable()
> to ensure that we indeed handle PageMovable() type page. Without it,
> the page we handle can be freed and re-allocated to someone else
> that isn't related to PageMovable() before grabbing the page. Trying
> trylock_page() in this case could cause a problem.

I don't get it. Why do you think trylock_page could cause a problem?
Could you elaborate it more?

> 
> > +	/*
> > +	 * As movable pages are not isolated from LRU lists, concurrent
> > +	 * compaction threads can race against page migration functions
> > +	 * as well as race against the releasing a page.
> > +	 *
> > +	 * In order to avoid having an already isolated movable page
> > +	 * being (wrongly) re-isolated while it is under migration,
> > +	 * or to avoid attempting to isolate pages being released,
> > +	 * lets be sure we have the page lock
> > +	 * before proceeding with the movable page isolation steps.
> > +	 */
> > +	if (unlikely(!trylock_page(page)))
> > +		goto out_putpage;
> > +
> > +	if (!PageMovable(page) || PageIsolated(page))
> > +		goto out_no_isolated;
> > +
> > +	ret = page->mapping->a_ops->isolate_page(page, mode);
> > +	if (!ret)
> > +		goto out_no_isolated;
> > +
> > +	WARN_ON_ONCE(!PageIsolated(page));
> > +	unlock_page(page);
> > +	return ret;
> > +
> > +out_no_isolated:
> > +	unlock_page(page);
> > +out_putpage:
> > +	put_page(page);
> > +out:
> > +	return ret;
> > +}
> > +
> > +void putback_movable_page(struct page *page)
> > +{
> > +	struct address_space *mapping;
> > +
> > +	/*
> > +	 * 'lock_page()' stabilizes the page and prevents races against
> > +	 * concurrent isolation threads attempting to re-isolate it.
> > +	 */
> > +	lock_page(page);
> > +	mapping = page_mapping(page);
> > +	if (mapping) {
> > +		mapping->a_ops->putback_page(page);
> > +		WARN_ON_ONCE(PageIsolated(page));
> > +	}
> > +	unlock_page(page);
> > +	/* drop the extra ref count taken for movable page isolation */
> > +	put_page(page);
> > +}
> 
> This is complicated part for me. mapping can disappear? In this case,
> who clear PageIsolated()?

Page's owner, for exmaple, zsmalloc, virtio-balloon.
They can free page whenever they want once it holds a PG_lock.
They should clear mapping and PG_movable with PG_lock.

> 
> > +
> > +
> >  /*
> >   * Put previously isolated pages back onto the appropriate lists
> >   * from where they were once taken off for compaction/migration.
> > @@ -96,6 +165,8 @@ void putback_movable_pages(struct list_head *l)
> >  				page_is_file_cache(page));
> >  		if (unlikely(isolated_balloon_page(page)))
> >  			balloon_page_putback(page);
> > +		else if (unlikely(PageIsolated(page)))
> > +			putback_movable_page(page);
> >  		else
> >  			putback_lru_page(page);
> >  	}
> 
> I think that this will not work. You uses PG_owner_priv_1 as
> PG_isolated and it is possible that some lru pages has this flag.
> I guess you need to add PageMovable() check but it seems that mapping
> and this flag can be cleared by others.

Hmm, PageMovable check may work because If PageMovable check fails,
it means page's owner free the page so we can simple put the page to
release refcount in here.
I will check it.

> 
> > @@ -592,7 +663,7 @@ void migrate_page_copy(struct page *newpage, struct page *page)
> >   ***********************************************************/
> >  
> >  /*
> > - * Common logic to directly migrate a single page suitable for
> > + * Common logic to directly migrate a single LRU page suitable for
> >   * pages that do not use PagePrivate/PagePrivate2.
> >   *
> >   * Pages are locked upon entry and exit.
> > @@ -755,24 +826,53 @@ static int move_to_new_page(struct page *newpage, struct page *page,
> >  				enum migrate_mode mode)
> >  {
> >  	struct address_space *mapping;
> > -	int rc;
> > +	int rc = -EAGAIN;
> > +	bool isolated_lru_page;
> >  
> >  	VM_BUG_ON_PAGE(!PageLocked(page), page);
> >  	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
> >  
> >  	mapping = page_mapping(page);
> > -	if (!mapping)
> > -		rc = migrate_page(mapping, newpage, page, mode);
> > -	else if (mapping->a_ops->migratepage)
> > +	/*
> > +	 * In case of non-lru page, it could be released after
> > +	 * isolation step. In that case, we shouldn't try
> > +	 * fallback migration which was designed for LRU pages.
> 
> So, page we try to migrate can be released during migration.
> In this case, who does clear mapping and flag? And, without mapping,
> how we can clear PageIsolated()?

As I wrote down in description, it's role of user.

> 
> > +	 * To identify such pages, we cannot use PageMovable
> > +	 * because owner of the page can reset it. So intead,
> > +	 * use PG_isolated bit.
> > +	 */
> > +	isolated_lru_page = !PageIsolated(page);
> 
> Ditto. PageIsolated() isn't sufficient to distinguish non-lru page.

Okay, I will see it.

> 
> My comment mainly points out rules about when/who clear mapping
> and flag. Maybe, you need to answer just one of them. :)

I agree document is really lack of information at the moment.
I will put more words.

Thanks for the review, Joonsoo!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
