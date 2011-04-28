Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 414E36B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 07:06:30 -0400 (EDT)
Date: Thu, 28 Apr 2011 12:06:23 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC 6/8] In order putback lru core
Message-ID: <20110428110623.GU4658@suse.de>
References: <cover.1303833415.git.minchan.kim@gmail.com>
 <51e7412097fa62f86656c77c1934e3eb96d5eef6.1303833417.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <51e7412097fa62f86656c77c1934e3eb96d5eef6.1303833417.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, Apr 27, 2011 at 01:25:23AM +0900, Minchan Kim wrote:
> This patch defines new APIs to putback the page into previous position of LRU.
> The idea is simple.
> 
> When we try to putback the page into lru list and if friends(prev, next) of the pages
> still is nearest neighbor, we can insert isolated page into prev's next instead of
> head of LRU list. So it keeps LRU history without losing the LRU information.
> 
> Before :
> 	LRU POV : H - P1 - P2 - P3 - P4 -T
> 
> Isolate P3 :
> 	LRU POV : H - P1 - P2 - P4 - T
> 
> Putback P3 :
> 	if (P2->next == P4)
> 		putback(P3, P2);
> 	So,
> 	LRU POV : H - P1 - P2 - P3 - P4 -T
> 
> For implement, we defines new structure pages_lru which remebers
> both lru friend pages of isolated one and handling functions.
> 
> But this approach has a problem on contiguous pages.
> In this case, my idea can not work since friend pages are isolated, too.
> It means prev_page->next == next_page always is false and both pages are not
> LRU any more at that time. It's pointed out by Rik at LSF/MM summit.
> So for solving the problem, I can change the idea.
> I think we don't need both friend(prev, next) pages relation but
> just consider either prev or next page that it is still same LRU.
> Worset case in this approach, prev or next page is free and allocate new
> so it's in head of LRU and our isolated page is located on next of head.
> But it's almost same situation with current problem. So it doesn't make worse
> than now and it would be rare. But in this version, I implement based on idea
> discussed at LSF/MM. If my new idea makes sense, I will change it.
> 
> Any comment?
> 
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  include/linux/migrate.h  |    2 +
>  include/linux/mm_types.h |    7 ++++
>  include/linux/swap.h     |    4 ++-
>  mm/compaction.c          |    3 +-
>  mm/internal.h            |    2 +
>  mm/memcontrol.c          |    2 +-
>  mm/migrate.c             |   36 +++++++++++++++++++++
>  mm/swap.c                |    2 +-
>  mm/vmscan.c              |   79 +++++++++++++++++++++++++++++++++++++++++++--
>  9 files changed, 129 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index e39aeec..3aa5ab6 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -9,6 +9,7 @@ typedef struct page *new_page_t(struct page *, unsigned long private, int **);
>  #ifdef CONFIG_MIGRATION
>  #define PAGE_MIGRATION 1
>  
> +extern void putback_pages_lru(struct list_head *l);
>  extern void putback_lru_pages(struct list_head *l);
>  extern int migrate_page(struct address_space *,
>  			struct page *, struct page *);
> @@ -33,6 +34,7 @@ extern int migrate_huge_page_move_mapping(struct address_space *mapping,
>  #else
>  #define PAGE_MIGRATION 0
>  
> +static inline void putback_pages_lru(struct list_head *l) {}
>  static inline void putback_lru_pages(struct list_head *l) {}
>  static inline int migrate_pages(struct list_head *l, new_page_t x,
>  		unsigned long private, bool offlining,
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index ca01ab2..35e80fb 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -102,6 +102,13 @@ struct page {
>  #endif
>  };
>  
> +/* This structure is used for keeping LRU ordering of isolated page */
> +struct pages_lru {
> +        struct page *page;      /* isolated page */
> +        struct page *prev_page; /* previous page of isolate page as LRU order */
> +        struct page *next_page; /* next page of isolate page as LRU order */
> +        struct list_head lru;
> +};
>  /*

So this thing has to be allocated from somewhere. We can't put it
on the stack as we're already in danger there so we must be using
kmalloc. In the reclaim paths, this should be avoided obviously.
For compaction, we might hurt the compaction success rates if pages
are pinned with control structures. It's something to be wary of.

At LSF/MM, I stated a preference for swapping the source and
destination pages in the LRU. This unfortunately means that the LRU
now contains a page in the process of being migrated to and the backout
paths for migration failure become a lot more complex. Reclaim should
be ok as it'll should fail to lock the page and recycle it in the list.
This avoids allocations but I freely admit that I'm not in the position
to implement such a thing right now :(

>   * A region containing a mapping of a non-memory backed file under NOMMU
>   * conditions.  These are held in a global tree and are pinned by the VMAs that
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index baef4ad..4ad0a0c 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -227,6 +227,8 @@ extern void rotate_reclaimable_page(struct page *page);
>  extern void deactivate_page(struct page *page);
>  extern void swap_setup(void);
>  
> +extern void update_page_reclaim_stat(struct zone *zone, struct page *page,
> +                                    int file, int rotated);
>  extern void add_page_to_unevictable_list(struct page *page);
>  
>  /**
> @@ -260,7 +262,7 @@ extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
>  						struct zone *zone,
>  						unsigned long *nr_scanned);
>  extern int __isolate_lru_page(struct page *page, int mode, int file,
> -				int not_dirty, int not_mapped);
> +		int not_dirty, int not_mapped, struct pages_lru *pages_lru);
>  extern unsigned long shrink_all_memory(unsigned long nr_pages);
>  extern int vm_swappiness;
>  extern int remove_mapping(struct address_space *mapping, struct page *page);
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 653b02b..c453000 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -335,7 +335,8 @@ static unsigned long isolate_migratepages(struct zone *zone,
>  		}
>  
>  		/* Try isolate the page */
> -		if (__isolate_lru_page(page, ISOLATE_BOTH, 0, !cc->sync, 0) != 0)
> +		if (__isolate_lru_page(page, ISOLATE_BOTH, 0,
> +					!cc->sync, 0, NULL) != 0)
>  			continue;
>  
>  		VM_BUG_ON(PageTransCompound(page));
> diff --git a/mm/internal.h b/mm/internal.h
> index d071d38..3c8182c 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -43,6 +43,8 @@ extern unsigned long highest_memmap_pfn;
>   * in mm/vmscan.c:
>   */
>  extern int isolate_lru_page(struct page *page);
> +extern bool keep_lru_order(struct pages_lru *pages_lru);
> +extern void putback_page_to_lru(struct page *page, struct list_head *head);
>  extern void putback_lru_page(struct page *page);
>  
>  /*
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 471e7fd..92a9046 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1193,7 +1193,7 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>  			continue;
>  
>  		scan++;
> -		ret = __isolate_lru_page(page, mode, file, 0, 0);
> +		ret = __isolate_lru_page(page, mode, file, 0, 0, NULL);
>  		switch (ret) {
>  		case 0:
>  			list_move(&page->lru, dst);
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 819d233..9cfb63b 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -85,6 +85,42 @@ void putback_lru_pages(struct list_head *l)
>  }
>  
>  /*
> + * This function is almost same iwth putback_lru_pages.
> + * The difference is that function receives struct pages_lru list
> + * and if possible, we add pages into original position of LRU
> + * instead of LRU's head.
> + */
> +void putback_pages_lru(struct list_head *l)
> +{
> +        struct pages_lru *isolated_page;
> +        struct pages_lru *isolated_page2;
> +        struct page *page;
> +
> +        list_for_each_entry_safe(isolated_page, isolated_page2, l, lru) {
> +                struct zone *zone;
> +                page = isolated_page->page;
> +                list_del(&isolated_page->lru);
> +
> +                dec_zone_page_state(page, NR_ISOLATED_ANON +
> +                                page_is_file_cache(page));
> +
> +                zone = page_zone(page);
> +                spin_lock_irq(&zone->lru_lock);
> +                if (keep_lru_order(isolated_page)) {
> +                        putback_page_to_lru(page, &isolated_page->prev_page->lru);
> +                        spin_unlock_irq(&zone->lru_lock);
> +                }
> +                else {
> +                        spin_unlock_irq(&zone->lru_lock);
> +                        putback_lru_page(page);
> +                }
> +
> +                kfree(isolated_page);
> +        }
> +}

I think we also need counters at least at discussion stage to see
how successful this is.

For example, early in the system there is a casual relationship
between the age of a page and its location in physical memory. The
buddy allocator gives pages back in PFN order where possible and
there is a loose relationship between when pages get allocated and
when they get reclaimed. As compaction is a linear scanner, there
is a likelihood (that is highly variable) that physically contiguous
pages will have similar positions in the LRU. They'll be isolated at
the same time meaning they also won't be put back in order.

This might cease to matter when the system is running for some time but
it's a concern.

> +
> +
> +/*
>   * Restore a potential migration pte to a working pte entry
>   */
>  static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
> diff --git a/mm/swap.c b/mm/swap.c
> index a83ec5a..0cb15b7 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -252,7 +252,7 @@ void rotate_reclaimable_page(struct page *page)
>  	}
>  }
>  
> -static void update_page_reclaim_stat(struct zone *zone, struct page *page,
> +void update_page_reclaim_stat(struct zone *zone, struct page *page,
>  				     int file, int rotated)
>  {
>  	struct zone_reclaim_stat *reclaim_stat = &zone->reclaim_stat;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 5196f0c..06a7c9b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -550,6 +550,58 @@ int remove_mapping(struct address_space *mapping, struct page *page)
>  	return 0;
>  }
>  
> +/* zone->lru_lock must be hold */
> +bool keep_lru_order(struct pages_lru *pages_lru)
> +{
> +        bool ret = false;
> +        struct page *prev, *next;
> +
> +        if (!pages_lru->prev_page)
> +                return ret;
> +
> +        prev = pages_lru->prev_page;
> +        next = pages_lru->next_page;
> +
> +        if (!PageLRU(prev) || !PageLRU(next))
> +                return ret;
> +
> +        if (prev->lru.next == &next->lru)
> +                ret = true;
> +
> +	if (unlikely(PageUnevictable(prev)))
> +		ret = false;
> +
> +        return ret;
> +}

Some whitespace issues there. There are a few formatting issues in the
patch but it's not the right time to worry about them.

> +
> +/**
> + * putback_page_to_lru - put isolated @page onto @head
> + * @page: page to be put back to appropriate lru list
> + * @head: lru position to be put back
> + *
> + * Insert previously isolated @page to appropriate position of lru list
> + * zone->lru_lock must be hold.
> + */
> +void putback_page_to_lru(struct page *page, struct list_head *head)
> +{
> +        int lru, active, file;
> +        struct zone *zone = page_zone(page);
> +        struct page *prev_page = container_of(head, struct page, lru);
> +
> +        lru = page_lru(prev_page);
> +        active = is_active_lru(lru);
> +        file = is_file_lru(lru);
> +
> +        if (active)
> +                SetPageActive(page);
> +	else
> +		ClearPageActive(page);
> +
> +        update_page_reclaim_stat(zone, page, file, active);
> +        SetPageLRU(page);
> +        __add_page_to_lru_list(zone, page, lru, head);
> +}
> +
>  /**
>   * putback_lru_page - put previously isolated page onto appropriate LRU list's head
>   * @page: page to be put back to appropriate lru list
> @@ -959,8 +1011,8 @@ keep_lumpy:
>   * not_mapped:	page should be not mapped
>   * returns 0 on success, -ve errno on failure.
>   */
> -int __isolate_lru_page(struct page *page, int mode, int file,
> -				int not_dirty, int not_mapped)
> +int __isolate_lru_page(struct page *page, int mode, int file, int not_dirty,
> +				int not_mapped, struct pages_lru *pages_lru)
>  {
>  	int ret = -EINVAL;
>  
> @@ -996,12 +1048,31 @@ int __isolate_lru_page(struct page *page, int mode, int file,
>  	ret = -EBUSY;
>  
>  	if (likely(get_page_unless_zero(page))) {
> +		struct zone *zone = page_zone(page);
> +		enum lru_list l = page_lru(page);
>  		/*
>  		 * Be careful not to clear PageLRU until after we're
>  		 * sure the page is not being freed elsewhere -- the
>  		 * page release code relies on it.
>  		 */
>  		ClearPageLRU(page);
> +
> +		if (!pages_lru)
> +			goto skip;
> +
> +		pages_lru->page = page;
> +		if (&zone->lru[l].list == pages_lru->lru.prev ||
> +			&zone->lru[l].list == pages_lru->lru.next) {
> +			pages_lru->prev_page = NULL;
> +			pages_lru->next_page = NULL;
> +			goto skip;
> +		}
> +
> +		pages_lru->prev_page =
> +			list_entry(page->lru.prev, struct page, lru);
> +		pages_lru->next_page =
> +			list_entry(page->lru.next, struct page, lru);
> +skip:
>  		ret = 0;
>  	}
>  
> @@ -1054,7 +1125,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  		VM_BUG_ON(!PageLRU(page));
>  
>  		switch (__isolate_lru_page(page, mode, file,
> -					not_dirty, not_mapped)) {
> +					not_dirty, not_mapped, NULL)) {
>  		case 0:
>  			list_move(&page->lru, dst);
>  			mem_cgroup_del_lru(page);
> @@ -1114,7 +1185,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  				break;
>  
>  			if (__isolate_lru_page(cursor_page, mode, file,
> -					not_dirty, not_mapped) == 0) {
> +					not_dirty, not_mapped, NULL) == 0) {
>  				list_move(&cursor_page->lru, dst);
>  				mem_cgroup_del_lru(cursor_page);
>  				nr_taken += hpage_nr_pages(page);
> -- 
> 1.7.1
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
