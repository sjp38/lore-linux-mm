Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B8DCC6B0078
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 11:15:50 -0400 (EDT)
Received: by pvc12 with SMTP id 12so992200pvc.14
        for <linux-mm@kvack.org>; Thu, 09 Jun 2011 08:15:47 -0700 (PDT)
Date: Fri, 10 Jun 2011 00:15:38 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v3 06/10] In order putback lru core
Message-ID: <20110609151538.GE4878@barrios-laptop>
References: <cover.1307455422.git.minchan.kim@gmail.com>
 <caae35dd91966d7a94bfa407693ff633fcaee040.1307455422.git.minchan.kim@gmail.com>
 <20110609142752.GY5247@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110609142752.GY5247@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu, Jun 09, 2011 at 03:27:52PM +0100, Mel Gorman wrote:
> On Tue, Jun 07, 2011 at 11:38:19PM +0900, Minchan Kim wrote:
> > This patch defines new APIs to put back the page into previous position of LRU.
> > The idea I suggested in LSF/MM is simple.
> > 
> > When we try to put back the page into lru list and if friends(prev, next) of the page
> > still is nearest neighbor, we can insert isolated page into prev's next instead of
> > head of LRU list. So it keeps LRU history without losing the LRU information.
> > 
> > Before :
> >        LRU POV : H - P1 - P2 - P3 - P4 -T
> > 
> > Isolate P3 :
> >        LRU POV : H - P1 - P2 - P4 - T
> > 
> > Putback P3 :
> >        if (P2->next == P4)
> >                putback(P3, P2);
> >        So,
> >        LRU POV : H - P1 - P2 - P3 - P4 -T
> > 
> > I implemented this idea in RFC but it had two problems.
> > 
> > 1)
> > For implement, I defined new structure _pages_lru_ which remembers
> > both lru friend pages of isolated one and handling functions.
> > For space of pages_lru, I allocated the space dynamically in kmalloc(GFP_AOTMIC)
> 
> ATOMIC

Will fix.

> 
> > but as we know, compaction is a reclaim path so it's not good idea to allocate memory
> > dynamically in the path. The space need to store pages_lru is enough to allocate just a page
> > as current compaction migrates unit of chunk of 32 pages.
> > In addition, compaction makes sure lots of order-0 free pages before starting
> > so it wouldn't a big problem, I think. But I admit it can pin some pages
> > so migration successful ratio might be down if concurrent compaction happens.
> > 
> > I decide changing my mind. I don't use dynamic memory space any more.
> > As I see migration, we don't need doubly linked list of page->lru.
> > Whole of operation is performed with enumeration so I think singly linked list is enough.
> > If we can use singly linked list, we can use a pointer as another buffer.
> > In here, we use it to store prev LRU page of page isolated.
> > 
> > 2)
> > The page-relation approach had a problem on contiguous pages.
> > That's because the idea can not work since friend pages are isolated, too.
> > It means prev_page->next == next_page always is _false_ and both pages are not
> > LRU any more at that time. It's pointed out by Rik at LSF/MM summit.
> > So for solving the problem, I changed the idea.
> > We don't need both friend(prev, next) pages relation but just consider
> > either prev or next page that it is still same LRU
> > 
> > Worst case in this approach, prev or next page is free and allocate new
> > so it's in head of LRU and our isolated page is located on next of head.
> > But it's almost same situation with current problem. So it doesn't make worse
> > than now.
> > New idea works below.
> > 
> > ===
> > 
> > assume : we isolate pages P3~P7 and we consider only prev LRU pointer.
> > notation : (P3,P2) = (isolated page,prev LRU page of isolated page)
> > 
> > H - P1 - P2 - P3 - P4 - P5 - P6 - P7 - P8 - P9 - P10 - T
> > 
> > If we isolate P3, following as
> > 
> > H - P1 - P2 - P4 - P5 - P6 - P7 - P8 - P9 - P10 - T
> > Isolated page list - (P3,P2)
> > 
> > If we isolate P4, following as
> > 
> > H - P1 - P2 - P5 - P6 - P7 - P8 - P9 - P10 - T
> > Isolated page list - (P4,P2) - (P3,P2)
> > 
> > If we isolate P5, following as
> > 
> > H - P1 - P2 - P6 - P7 - P8 - P9 - P10 - T
> > Isolated page list - (P5,P2) - (P4,P2) - (P3,P2)
> > 
> > ..
> > ..
> > 
> > If we isolate P7, following as
> > 
> > H - P1 - P2 - P8 - P9 - P10 - T
> > 
> > Isolated page list - (P7,P2) - (P6,P2) - (P5,P2) - (P4,P2) - (P3,P2)
> > 
> > Let's start putback from P7
> > 
> > P7)
> > 
> > H - P1 - P2 - P8 - P9 - P10 - T
> > prev P2 is valid, too. So,
> > 
> > H - P1 - P2 - P7 - P8 - P9 - P10 - T
> > 
> > P6)
> > 
> > H - P1 - P2 - P7 - P8 - P9 - P10 - T
> > Prev P2 is valid, too. So,
> > 
> > H - P1 - P2 - P6 - P7 - P8 - P9 - P10 - T
> > 
> > ..
> > ..
> > 
> > P3)
> > H - P1 - P2 - P4 - P5 - P6 - P7 - P8 - P9 - P10 - T
> > Prev P2 is valid, too. So,
> > 
> > H - P1 - P2 - P3 - P4 - P5 - P6 - P7 - P8 - P9 - P10 - T
> > 
> 
> Could move this explanation into migrate.h where you talk about why the
> list is singly-linked instead of doubly-linked.

Okay.

> 
> > ===
> > 
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > Acked-by: Rik van Riel <riel@redhat.com>
> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> > ---
> >  include/linux/migrate.h  |   35 ++++++++++++++++++++++
> >  include/linux/mm_types.h |   16 +++++++++-
> >  include/linux/swap.h     |    4 ++-
> >  mm/compaction.c          |    2 +-
> >  mm/internal.h            |    2 +
> >  mm/memcontrol.c          |    2 +-
> >  mm/migrate.c             |   24 +++++++++++++++
> >  mm/swap.c                |    2 +-
> >  mm/vmscan.c              |   72 ++++++++++++++++++++++++++++++++++++++++++++--
> >  9 files changed, 151 insertions(+), 8 deletions(-)
> > 
> > diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> > index e39aeec..5914282 100644
> > --- a/include/linux/migrate.h
> > +++ b/include/linux/migrate.h
> > @@ -9,7 +9,42 @@ typedef struct page *new_page_t(struct page *, unsigned long private, int **);
> >  #ifdef CONFIG_MIGRATION
> >  #define PAGE_MIGRATION 1
> >  
> > +/*
> > + * Migratelist for compaction is singly linked list instead of double linked list.
> > + * Current list utility is useful in some sense but we can't make sure compatibilty.
> > + * Please use below functions instead of common list's ones.
> > + */
> > +static inline void INIT_MIGRATE_LIST(struct inorder_lru *list)
> > +{
> > +	list->prev_page = NULL;
> > +	list->next = list;
> > +}
> > +
> > +static inline int migratelist_empty(const struct inorder_lru *head)
> > +{
> > +	return head->next == head;
> > +}
> > +
> > +static inline void migratelist_add(struct page *page,
> > +			struct page *prev_page, struct inorder_lru *head)
> > +{
> > +	VM_BUG_ON(PageLRU(page));
> > +
> > +	page->ilru.prev_page = prev_page;
> > +	page->ilru.next = head->next;
> > +	head->next = &page->ilru;
> > +}
> > +
> > +static inline void migratelist_del(struct page *page, struct inorder_lru *head)
> > +{
> > +	head->next = page->ilru.next;
> > +}
> > +
> 
> Does this sort of list mangling not get upset when CONFIG_LIST_DEBUG is
> set?

It's no problem as I didn't use general list utility functions.
For handling inorder_lru, we must use migratelist_[xxx] functions.
I mentioned it at heading.

> 
> > +#define list_for_each_migrate_entry		list_for_each_entry
> > +#define list_for_each_migrate_entry_safe	list_for_each_entry_safe
> > +
> >  extern void putback_lru_pages(struct list_head *l);
> > +extern void putback_ilru_pages(struct inorder_lru *l);
> >  extern int migrate_page(struct address_space *,
> >  			struct page *, struct page *);
> >  extern int migrate_pages(struct list_head *l, new_page_t x,
> > diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> > index 02aa561..af46614 100644
> > --- a/include/linux/mm_types.h
> > +++ b/include/linux/mm_types.h
> > @@ -24,6 +24,17 @@ struct address_space;
> >  
> >  #define USE_SPLIT_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
> >  
> > +struct page;
> > +
> > +/*
> > + * The inorder_lru is used by compaction for keeping LRU order
> > + * during migration.
> > + */
> > +struct inorder_lru {
> > +	struct page *prev_page; 	/* prev LRU page of isolated page */
> > +	struct inorder_lru *next;	/* next pointer for singly linked list*/
> > +};
> > +
> >  /*
> >   * Each physical page in the system has a struct page associated with
> >   * it to keep track of whatever it is we are using the page for at the
> > @@ -72,9 +83,12 @@ struct page {
> >  		pgoff_t index;		/* Our offset within mapping. */
> >  		void *freelist;		/* SLUB: freelist req. slab lock */
> >  	};
> > -	struct list_head lru;		/* Pageout list, eg. active_list
> > +	union {
> > +		struct inorder_lru ilru;/* compaction: migrated page list */
> > +		struct list_head lru;	/* Pageout list, eg. active_list
> >  					 * protected by zone->lru_lock !
> >  					 */
> > +	};
> >  	/*
> >  	 * On machines where all RAM is mapped into kernel address space,
> >  	 * we can simply calculate the virtual address. On machines with
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index 731f5dd..854244a 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -226,6 +226,8 @@ extern int lru_add_drain_all(void);
> >  extern void rotate_reclaimable_page(struct page *page);
> >  extern void deactivate_page(struct page *page);
> >  extern void swap_setup(void);
> > +extern void update_page_reclaim_stat(struct zone *zone, struct page *page,
> > +		int file, int rotated);
> >  
> >  extern void add_page_to_unevictable_list(struct page *page);
> >  
> > @@ -263,7 +265,7 @@ extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
> >  						unsigned int swappiness,
> >  						struct zone *zone);
> >  extern int __isolate_lru_page(struct page *page, enum ISOLATE_MODE mode,
> > -					int file);
> > +				int file, struct page **prev_page);
> >  extern unsigned long shrink_all_memory(unsigned long nr_pages);
> >  extern int vm_swappiness;
> >  extern int remove_mapping(struct address_space *mapping, struct page *page);
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 8079346..54dbdbe 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -331,7 +331,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
> >  			mode |= ISOLATE_CLEAN;
> >   
> >  		/* Try isolate the page */
> > -		if (__isolate_lru_page(page, mode, 0) != 0)
> > +		if (__isolate_lru_page(page, mode, 0, NULL) != 0)
> >  			continue;
> >  
> >  		VM_BUG_ON(PageTransCompound(page));
> > diff --git a/mm/internal.h b/mm/internal.h
> > index 9d0ced8..a08d8c6 100644
> > --- a/mm/internal.h
> > +++ b/mm/internal.h
> > @@ -42,6 +42,8 @@ extern unsigned long highest_memmap_pfn;
> >  /*
> >   * in mm/vmscan.c:
> >   */
> > +extern bool same_lru(struct page *page, struct page *prev);
> > +extern void putback_page_to_lru(struct page *page, struct page *head_page);
> >  extern int isolate_lru_page(struct page *page);
> >  extern void putback_lru_page(struct page *page);
> >  
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index f4c0b71..04d460d 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1141,7 +1141,7 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
> >  			continue;
> >  
> >  		scan++;
> > -		ret = __isolate_lru_page(page, mode, file);
> > +		ret = __isolate_lru_page(page, mode, file, NULL);
> >  		switch (ret) {
> >  		case 0:
> >  			list_move(&page->lru, dst);
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index e797b5c..874c081 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -84,6 +84,30 @@ void putback_lru_pages(struct list_head *l)
> >  	}
> >  }
> >  
> > +void putback_ilru_pages(struct inorder_lru *l)
> > +{
> > +	struct zone *zone;
> > +	struct page *page, *page2, *prev;
> > +
> > +	list_for_each_migrate_entry_safe(page, page2, l, ilru) {
> > +		dec_zone_page_state(page, NR_ISOLATED_ANON +
> > +				page_is_file_cache(page));
> > +		zone = page_zone(page);
> > +		spin_lock_irq(&zone->lru_lock);
> > +		prev = page->ilru.prev_page;
> > +		if (same_lru(page, prev)) {
> > +			putback_page_to_lru(page, prev);
> > +			spin_unlock_irq(&zone->lru_lock);
> > +		}
> 
> 
> Ouch. So with putback_lru_pages(), pages get added to a pagevec but
> now we are taking the zone LRU lock for every page we want to put
> back? That is very painful. We're talking about THP promotion having to
> take the zone lru lock, many hundreds if not thousands of times.

True but putback_ilru_pages is called only when migration is failed.
In my test, it was very _rare_(0.1% of total compaction) but I am not sure in
other workload.
In addition, we already have done it on unevictable pages.
It would be problem in many mlocked pages rather than compaction.

The my point is putback_ilru_pages calling(ie, fail of migrate_pages)
should be rare.

> 
> Minimally, I now think this patchset needs to be split into two -
> the first set which avoids isolating pages from the LRU when it's
> pointless like dirty pages for async compaction and __zone_reclaim. I
> think that has clear merit and should be without cost. The second
> set would be this to determine how taking the lru_lock an excessive
> number of times can be avoided.
> 
> > +		else {
> > +			spin_unlock_irq(&zone->lru_lock);
> > +			putback_lru_page(page);
> > +		}
> > +
> > +		l->next = &page2->ilru;
> > +	}
> > +}
> > +
> >  /*
> >   * Restore a potential migration pte to a working pte entry
> >   */
> > diff --git a/mm/swap.c b/mm/swap.c
> > index 5602f1a..6c24a75 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -252,7 +252,7 @@ void rotate_reclaimable_page(struct page *page)
> >  	}
> >  }
> >  
> > -static void update_page_reclaim_stat(struct zone *zone, struct page *page,
> > +void update_page_reclaim_stat(struct zone *zone, struct page *page,
> >  				     int file, int rotated)
> >  {
> >  	struct zone_reclaim_stat *reclaim_stat = &zone->reclaim_stat;
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index c08911d..7668e8d 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -550,6 +550,56 @@ int remove_mapping(struct address_space *mapping, struct page *page)
> >  	return 0;
> >  }
> >  
> > +/*
> > + * If prev and page are on same LRU still, we can keep LRU order of page.
> > + * zone->lru_lock must be hold.
> > + */
> > +bool same_lru(struct page *page, struct page *prev)
> > +{
> > +	bool ret = false;
> > +	if (!prev || !PageLRU(prev))
> > +		goto out;
> > +
> > +	if (unlikely(PageUnevictable(prev)))
> > +		goto out;
> > +
> > +	if (page_lru_base_type(page) != page_lru_base_type(prev))
> > +		goto out;
> > +
> > +	ret = true;
> > +out:
> > +	return ret;
> > +}
> > +
> > +/**
> > + * putback_page_to_lru - put isolated @page onto @head
> > + * @page: page to be put back to appropriate lru list
> > + * @head_page: lru position to be put back
> > + *
> > + * Insert previously isolated @page to appropriate position of lru list
> > + * zone->lru_lock must be hold.
> > + */
> > +void putback_page_to_lru(struct page *page, struct page *head_page)
> > +{
> > +	int lru, active, file;
> > +	struct zone *zone = page_zone(page);
> > +
> > +	VM_BUG_ON(PageLRU(page));
> > +
> > +	lru = page_lru(head_page);
> > +	active = is_active_lru(lru);
> > +	file = is_file_lru(lru);
> > +
> > +	if (active)
> > +		SetPageActive(page);
> > +	else
> > +		ClearPageActive(page);
> > +
> > +	update_page_reclaim_stat(zone, page, file, active);
> > +	SetPageLRU(page);
> > +	__add_page_to_lru_list(zone, page, lru, &head_page->lru);
> > +}
> > +
> >  /**
> >   * putback_lru_page - put previously isolated page onto appropriate LRU list's head
> >   * @page: page to be put back to appropriate lru list
> > @@ -954,10 +1004,13 @@ keep_lumpy:
> >   *
> >   * page:	page to consider
> >   * mode:	one of the LRU isolation modes defined above
> > + * file:	True [1] if isolating file [!anon] pages
> > + * prev_page:	prev page of isolated page as LRU order
> >   *
> >   * returns 0 on success, -ve errno on failure.
> >   */
> > -int __isolate_lru_page(struct page *page, enum ISOLATE_MODE mode, int file)
> > +int __isolate_lru_page(struct page *page, enum ISOLATE_MODE mode,
> > +			int file, struct page **prev_page)
> >  {
> >  	bool all_lru_mode;
> >  	int ret = -EINVAL;
> > @@ -1003,6 +1056,18 @@ int __isolate_lru_page(struct page *page, enum ISOLATE_MODE mode, int file)
> >  		 * page release code relies on it.
> >  		 */
> >  		ClearPageLRU(page);
> > +		if (prev_page != NULL) {
> > +			struct zone *zone = page_zone(page);
> > +			enum lru_list l = page_lru(page);
> > +						
> > +			if (&zone->lru[l].list == page->lru.prev) {
> > +				*prev_page = NULL;
> > +				goto out;
> > +			}
> > +
> > +			*prev_page = lru_to_page(&page->lru);
> > +		}
> > +out:
> >  		ret = 0;
> >  	}
> >  
> > @@ -1052,7 +1117,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> >  
> >  		VM_BUG_ON(!PageLRU(page));
> >  
> > -		switch (__isolate_lru_page(page, mode, file)) {
> > +		switch (__isolate_lru_page(page, mode, file, NULL)) {
> >  		case 0:
> >  			list_move(&page->lru, dst);
> >  			mem_cgroup_del_lru(page);
> > @@ -1111,7 +1176,8 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> >  			    !PageSwapCache(cursor_page))
> >  				break;
> >  
> > -			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
> > +			if (__isolate_lru_page(cursor_page,
> > +						mode, file, NULL) == 0) {
> >  				list_move(&cursor_page->lru, dst);
> >  				mem_cgroup_del_lru(cursor_page);
> >  				nr_taken += hpage_nr_pages(page);
> 
> -- 
> Mel Gorman
> SUSE Labs

-- 
Kind regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
