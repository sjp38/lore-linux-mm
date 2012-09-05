Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id C3C486B005A
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 13:28:33 -0400 (EDT)
Received: by wibhq4 with SMTP id hq4so360572wib.8
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 10:28:32 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC] memory-hotplug: remove MIGRATE_ISOLATE from free_area->free_list
In-Reply-To: <1346830033-32069-1-git-send-email-minchan@kernel.org>
References: <1346830033-32069-1-git-send-email-minchan@kernel.org>
Date: Wed, 05 Sep 2012 19:28:23 +0200
Message-ID: <xa1t1uigpefc.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 05 2012, Minchan Kim wrote:
> Normally, MIGRATE_ISOLATE type is used for memory-hotplug.
> But it's irony type because the pages isolated would exist
> as free page in free_area->free_list[MIGRATE_ISOLATE] so people
> can think of it as allocatable pages but it is *never* allocatable.
> It ends up confusing NR_FREE_PAGES vmstat so it would be
> totally not accurate so some of place which depend on such vmstat
> could reach wrong decision by the context.
>
> There were already report about it.[1]
> [1] 702d1a6e, memory-hotplug: fix kswapd looping forever problem
>
> Then, there was other report which is other problem.[2]
> [2] http://www.spinics.net/lists/linux-mm/msg41251.html
>
> I believe it can make problems in future, too.
> So I hope removing such irony type by another design.
>
> I hope this patch solves it and let's revert [1] and doesn't need [2].
>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

If you ask me, I'm not convinced that this improves anything.

> ---
>
> It's very early version which show the concept and just tested it with si=
mple
> test and works. This patch is needed indepth review from memory-hotplug
> guys from fujitsu because I saw there are lots of patches recenlty they s=
ent to
> about memory-hotplug change. Please take a look at this patch.
>
>  drivers/xen/balloon.c          |    3 +-
>  include/linux/mmzone.h         |    2 +-
>  include/linux/page-isolation.h |   11 ++-
>  mm/internal.h                  |    4 +
>  mm/memory_hotplug.c            |   38 +++++----
>  mm/page_alloc.c                |   35 ++++----
>  mm/page_isolation.c            |  184 ++++++++++++++++++++++++++++++++++=
+-----
>  7 files changed, 218 insertions(+), 59 deletions(-)
>
> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> index 31ab82f..617d7a3 100644
> --- a/drivers/xen/balloon.c
> +++ b/drivers/xen/balloon.c
> @@ -50,6 +50,7 @@
>  #include <linux/notifier.h>
>  #include <linux/memory.h>
>  #include <linux/memory_hotplug.h>
> +#include <linux/page-isolation.h>
>=20=20
>  #include <asm/page.h>
>  #include <asm/pgalloc.h>
> @@ -66,7 +67,6 @@
>  #include <xen/balloon.h>
>  #include <xen/features.h>
>  #include <xen/page.h>
> -

Unrelated and in fact should not be here at all.

>  /*
>   * balloon_process() state:
>   *
> @@ -268,6 +268,7 @@ static void xen_online_page(struct page *page)
>  	else
>  		--balloon_stats.balloon_hotplug;
>=20=20
> +	delete_from_isolated_list(page);
>  	mutex_unlock(&balloon_mutex);
>  }
>=20=20
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 2daa54f..977dceb 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -57,7 +57,7 @@ enum {
>  	 */
>  	MIGRATE_CMA,
>  #endif
> -	MIGRATE_ISOLATE,	/* can't allocate from here */
> +	MIGRATE_ISOLATE,
>  	MIGRATE_TYPES
>  };

Why remove that comment?

> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolatio=
n.h
> index 105077a..a26eb8a 100644
> --- a/include/linux/page-isolation.h
> +++ b/include/linux/page-isolation.h
> @@ -1,11 +1,16 @@
>  #ifndef __LINUX_PAGEISOLATION_H
>  #define __LINUX_PAGEISOLATION_H
>=20=20
> +extern struct list_head isolated_pages;
>=20=20
>  bool has_unmovable_pages(struct zone *zone, struct page *page, int count=
);
>  void set_pageblock_migratetype(struct page *page, int migratetype);
>  int move_freepages_block(struct zone *zone, struct page *page,
>  				int migratetype);
> +
> +void isolate_free_page(struct page *page, unsigned int order);
> +void delete_from_isolated_list(struct page *page);
> +
>  /*
>   * Changes migrate type in [start_pfn, end_pfn) to be MIGRATE_ISOLATE.
>   * If specified range includes migrate types other than MOVABLE or CMA,
> @@ -20,9 +25,13 @@ start_isolate_page_range(unsigned long start_pfn, unsi=
gned long end_pfn,
>  			 unsigned migratetype);
>=20=20
>  /*
> - * Changes MIGRATE_ISOLATE to MIGRATE_MOVABLE.
> + * Changes MIGRATE_ISOLATE to @migratetype.
>   * target range is [start_pfn, end_pfn)
>   */
> +void
> +undo_isolate_pageblock(unsigned long start_pfn, unsigned long end_pfn,
> +			unsigned migratetype);
> +
>  int
>  undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>  			unsigned migratetype);
> diff --git a/mm/internal.h b/mm/internal.h
> index 3314f79..4551179 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -96,6 +96,7 @@ extern void putback_lru_page(struct page *page);
>   */
>  extern void __free_pages_bootmem(struct page *page, unsigned int order);
>  extern void prep_compound_page(struct page *page, unsigned long order);
> +extern int destroy_compound_page(struct page *page, unsigned long order);
>  #ifdef CONFIG_MEMORY_FAILURE
>  extern bool is_free_buddy_page(struct page *page);
>  #endif
> @@ -144,6 +145,9 @@ isolate_migratepages_range(struct zone *zone, struct =
compact_control *cc,
>   * function for dealing with page's order in buddy system.
>   * zone->lock is already acquired when we use these.
>   * So, we don't need atomic page->flags operations here.
> + *
> + * Page order should be put on page->private because
> + * memory-hotplug depends on it. Look mm/page_isolate.c.
>   */
>  static inline unsigned long page_order(struct page *page)
>  {
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 3ad25f9..e297370 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -410,26 +410,29 @@ void __online_page_set_limits(struct page *page)
>  	unsigned long pfn =3D page_to_pfn(page);
>=20=20
>  	if (pfn >=3D num_physpages)
> -		num_physpages =3D pfn + 1;
> +		num_physpages =3D pfn + (1 << page_order(page));
>  }
>  EXPORT_SYMBOL_GPL(__online_page_set_limits);
>=20=20
>  void __online_page_increment_counters(struct page *page)
>  {
> -	totalram_pages++;
> +	totalram_pages +=3D (1 << page_order(page));
>=20=20
>  #ifdef CONFIG_HIGHMEM
>  	if (PageHighMem(page))
> -		totalhigh_pages++;
> +		totalhigh_pages +=3D (1 << page_order(page));
>  #endif
>  }
>  EXPORT_SYMBOL_GPL(__online_page_increment_counters);
>=20=20
>  void __online_page_free(struct page *page)
>  {
> -	ClearPageReserved(page);
> -	init_page_count(page);
> -	__free_page(page);
> +	int i;
> +	unsigned long order =3D page_order(page);
> +	for (i =3D 0; i < (1 << order); i++)
> +		ClearPageReserved(page + i);
> +	set_page_private(page, 0);
> +	__free_pages(page, order);
>  }
>  EXPORT_SYMBOL_GPL(__online_page_free);
>=20=20
> @@ -437,26 +440,29 @@ static void generic_online_page(struct page *page)
>  {
>  	__online_page_set_limits(page);
>  	__online_page_increment_counters(page);
> +	delete_from_isolated_list(page);
>  	__online_page_free(page);
>  }
>=20=20
>  static int online_pages_range(unsigned long start_pfn, unsigned long nr_=
pages,
>  			void *arg)
>  {
> -	unsigned long i;
> +	unsigned long pfn;
> +	unsigned long end_pfn =3D start_pfn + nr_pages;
>  	unsigned long onlined_pages =3D *(unsigned long *)arg;
> -	struct page *page;
> -	if (PageReserved(pfn_to_page(start_pfn)))
> -		for (i =3D 0; i < nr_pages; i++) {
> -			page =3D pfn_to_page(start_pfn + i);
> -			(*online_page_callback)(page);
> -			onlined_pages++;
> +	struct page *cursor, *tmp;
> +	list_for_each_entry_safe(cursor, tmp, &isolated_pages, lru) {
> +		pfn =3D page_to_pfn(cursor);
> +		if (pfn >=3D start_pfn && pfn < end_pfn) {
> +			(*online_page_callback)(cursor);
> +			onlined_pages +=3D (1 << page_order(cursor));
>  		}
> +	}
> +
>  	*(unsigned long *)arg =3D onlined_pages;
>  	return 0;
>  }
>=20=20
> -
>  int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
>  {
>  	unsigned long onlined_pages =3D 0;
> @@ -954,11 +960,11 @@ repeat:
>  		goto failed_removal;
>  	}
>  	printk(KERN_INFO "Offlined Pages %ld\n", offlined_pages);
> -	/* Ok, all of our target is islaoted.
> +	/* Ok, all of our target is isolated.
>  	   We cannot do rollback at this point. */
>  	offline_isolated_pages(start_pfn, end_pfn);
>  	/* reset pagetype flags and makes migrate type to be MOVABLE */
> -	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
> +	undo_isolate_pageblock(start_pfn, end_pfn, MIGRATE_MOVABLE);
>  	/* removal success */
>  	zone->present_pages -=3D offlined_pages;
>  	zone->zone_pgdat->node_present_pages -=3D offlined_pages;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ba3100a..24c1adb 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -362,7 +362,7 @@ void prep_compound_page(struct page *page, unsigned l=
ong order)
>  }
>=20=20
>  /* update __split_huge_page_refcount if you change this function */
> -static int destroy_compound_page(struct page *page, unsigned long order)
> +int destroy_compound_page(struct page *page, unsigned long order)
>  {
>  	int i;
>  	int nr_pages =3D 1 << order;
> @@ -721,6 +721,7 @@ static void __free_pages_ok(struct page *page, unsign=
ed int order)
>  {
>  	unsigned long flags;
>  	int wasMlocked =3D __TestClearPageMlocked(page);
> +	int migratetype;
>=20=20
>  	if (!free_pages_prepare(page, order))
>  		return;
> @@ -729,8 +730,14 @@ static void __free_pages_ok(struct page *page, unsig=
ned int order)
>  	if (unlikely(wasMlocked))
>  		free_page_mlock(page);
>  	__count_vm_events(PGFREE, 1 << order);
> -	free_one_page(page_zone(page), page, order,
> -					get_pageblock_migratetype(page));
> +
> +	migratetype =3D get_pageblock_migratetype(page);
> +	if (likely(migratetype !=3D MIGRATE_ISOLATE))
> +		free_one_page(page_zone(page), page, order,
> +				migratetype);
> +	else
> +		isolate_free_page(page, order);
> +
>  	local_irq_restore(flags);
>  }
>=20=20
> @@ -906,7 +913,6 @@ static int fallbacks[MIGRATE_TYPES][4] =3D {
>  	[MIGRATE_MOVABLE]     =3D { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE,   M=
IGRATE_RESERVE },
>  #endif
>  	[MIGRATE_RESERVE]     =3D { MIGRATE_RESERVE }, /* Never used */
> -	[MIGRATE_ISOLATE]     =3D { MIGRATE_RESERVE }, /* Never used */
>  };

This change is mute.

>=20=20
>  /*
> @@ -948,8 +954,13 @@ static int move_freepages(struct zone *zone,
>  		}
>=20=20
>  		order =3D page_order(page);
> -		list_move(&page->lru,
> -			  &zone->free_area[order].free_list[migratetype]);
> +		if (migratetype !=3D MIGRATE_ISOLATE) {
> +			list_move(&page->lru,
> +				&zone->free_area[order].free_list[migratetype]);
> +		} else {
> +			list_del(&page->lru);
> +			isolate_free_page(page, order);
> +		}
>  		page +=3D 1 << order;
>  		pages_moved +=3D 1 << order;
>  	}
> @@ -1316,7 +1327,7 @@ void free_hot_cold_page(struct page *page, int cold)
>  	 */
>  	if (migratetype >=3D MIGRATE_PCPTYPES) {
>  		if (unlikely(migratetype =3D=3D MIGRATE_ISOLATE)) {
> -			free_one_page(zone, page, 0, migratetype);
> +			isolate_free_page(page, 0);
>  			goto out;
>  		}
>  		migratetype =3D MIGRATE_MOVABLE;
> @@ -5908,7 +5919,6 @@ __offline_isolated_pages(unsigned long start_pfn, u=
nsigned long end_pfn)
>  	struct zone *zone;
>  	int order, i;
>  	unsigned long pfn;
> -	unsigned long flags;
>  	/* find the first valid pfn */
>  	for (pfn =3D start_pfn; pfn < end_pfn; pfn++)
>  		if (pfn_valid(pfn))
> @@ -5916,7 +5926,6 @@ __offline_isolated_pages(unsigned long start_pfn, u=
nsigned long end_pfn)
>  	if (pfn =3D=3D end_pfn)
>  		return;
>  	zone =3D page_zone(pfn_to_page(pfn));
> -	spin_lock_irqsave(&zone->lock, flags);
>  	pfn =3D start_pfn;
>  	while (pfn < end_pfn) {
>  		if (!pfn_valid(pfn)) {
> @@ -5924,23 +5933,15 @@ __offline_isolated_pages(unsigned long start_pfn,=
 unsigned long end_pfn)
>  			continue;
>  		}
>  		page =3D pfn_to_page(pfn);
> -		BUG_ON(page_count(page));
> -		BUG_ON(!PageBuddy(page));
>  		order =3D page_order(page);
>  #ifdef CONFIG_DEBUG_VM
>  		printk(KERN_INFO "remove from free list %lx %d %lx\n",
>  		       pfn, 1 << order, end_pfn);
>  #endif
> -		list_del(&page->lru);
> -		rmv_page_order(page);
> -		zone->free_area[order].nr_free--;
> -		__mod_zone_page_state(zone, NR_FREE_PAGES,
> -				      - (1UL << order));
>  		for (i =3D 0; i < (1 << order); i++)
>  			SetPageReserved((page+i));
>  		pfn +=3D (1 << order);
>  	}
> -	spin_unlock_irqrestore(&zone->lock, flags);
>  }
>  #endif
>=20=20
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 247d1f1..918bb5b 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -8,6 +8,136 @@
>  #include <linux/memory.h>
>  #include "internal.h"
>=20=20
> +LIST_HEAD(isolated_pages);
> +static DEFINE_SPINLOCK(lock);
> +
> +/*
> + * Add the page into isolated_pages which is sort of pfn ascending list.
> + */
> +void __add_isolated_page(struct page *page)

static

> +{
> +	struct page *cursor;
> +	unsigned long pfn;
> +	unsigned long new_pfn =3D page_to_pfn(page);
> +
> +	list_for_each_entry_reverse(cursor, &isolated_pages, lru) {
> +		pfn =3D page_to_pfn(cursor);
> +		if (pfn < new_pfn)
> +			break;
> +	}
> +
> +	list_add(&page->lru, &cursor->lru);
> +}
> +
> +/*
> + * Isolate free page. It is used by memory-hotplug for stealing
> + * free page from free_area or freeing path of allocator.
> + */
> +void isolate_free_page(struct page *page, unsigned int order)
> +{
> +	unsigned long flags;
> +
> +	/*
> +	 * We increase refcount for further freeing when online_pages
> +	 * happens and record order into @page->private so that
> +	 * online_pages can know what order page freeing.
> +	 */
> +	set_page_refcounted(page);
> +	set_page_private(page, order);
> +
> +	/* move_freepages is alredy hold zone->lock */
> +	if (PageBuddy(page))
> +		__ClearPageBuddy(page);
> +
> +	spin_lock_irqsave(&lock, flags);
> +	__add_isolated_page(page);
> +	spin_unlock_irqrestore(&lock, flags);
> +}
> +
> +void delete_from_isolated_list(struct page *page)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&lock, flags);
> +	list_del(&page->lru);
> +	spin_unlock_irqrestore(&lock, flags);
> +}
> +
> +/* free pages in the pageblock which include @page */
> +static void free_isolated_pageblock(struct page *page)
> +{
> +	struct page *cursor;
> +	unsigned long start_pfn, end_pfn, pfn;
> +	unsigned long flags;
> +	bool found =3D false;
> +
> +	start_pfn =3D page_to_pfn(page);
> +	start_pfn =3D start_pfn & ~(pageblock_nr_pages-1);
> +	end_pfn =3D start_pfn + pageblock_nr_pages;
> +again:
> +	spin_lock_irqsave(&lock, flags);
> +
> +	list_for_each_entry(cursor, &isolated_pages, lru) {
> +		pfn =3D page_to_pfn(cursor);
> +		if (pfn >=3D start_pfn && pfn < end_pfn) {
> +			found =3D true;
> +			break;
> +		}
> +
> +		if (pfn >=3D end_pfn)
> +			break;
> +	}
> +	if (found)
> +		list_del(&cursor->lru);
> +
> +	spin_unlock_irqrestore(&lock, flags);
> +
> +	if (found) {
> +		int order =3D page_order(cursor);
> +		__free_pages(cursor, order);
> +		found =3D false;
> +		goto again;
> +	}

This looks overly complicated.  Why not have a temporary list?  And why
iterate the list over and over again?  If there are many pages in
pageblock near the end of the list, the code will iterate through the
whole list many times.  How about:

static void free_isolated_pageblock(struct page *page)
{
	unsigned long start_pfn, end_pfn, pfn;
	unsigned long flags;
	LIST_HEAD(pages);

	start_pfn =3D page_to_pfn(page);
	start_pfn =3D start_pfn & ~(pageblock_nr_pages-1);
	end_pfn =3D start_pfn + pageblock_nr_pages;

	spin_lock_irqsave(&lock, flags);
	list_for_each_entry(page, &isolated_pages, lru) {
		pfn =3D page_to_pfn(cursor);
		if (pfn >=3D end_pfn)
			break;
		if (pfn >=3D start_pfn) {
			list_del(&page->lru);
			list_add(&page->lru, &pages);
		}
	}
	spin_unlock_irqrestore(&lock, flags);

	list_for_each_entry(page, &pages, lru) {
		int order =3D page_order(page);
		__free_pages(page, order);
	}
}

> +}
> +
> +/*
> + * Check that *all* [start_pfn...end_pfn) pages are isolated.
> + */
> +static bool is_isolate_pfn_range(unsigned long start_pfn, unsigned long =
end_pfn)
> +{
> +	struct page *start_page, *page;
> +	unsigned long pfn;
> +	unsigned long prev_pfn;
> +	unsigned int prev_order;
> +	bool found =3D false;
> +
> +	list_for_each_entry(start_page, &isolated_pages, lru) {
> +		pfn =3D page_to_pfn(start_page);

Missing:

	if (pfn >=3D end_pfn)
		break;

> +		if (pfn >=3D start_pfn && pfn < end_pfn) {
> +			found =3D true;
> +			break;

So if page at start_pfn is not isolated is it ok?

I would remove the =E2=80=9Cfound=E2=80=9D variable and instead do =E2=80=
=9Cgoto found=E2=80=9D,
something like:

	list_for_each_entry(...) {
		if (...)
			goto found;
	}
	return false;

found:
	...

> +		}
> +	}
> +
> +	if (!found)
> +		return false;
> +
> +	prev_pfn =3D page_to_pfn(start_page);

	prev_pfn =3D pfn;

> +	prev_order =3D page_order(start_page);
> +
> +	list_for_each_entry(page, &start_page->lru, lru) {
> +		pfn =3D page_to_pfn(page);
> +		if (pfn >=3D end_pfn)
> +			break;
> +		if (pfn !=3D (prev_pfn + (1 << prev_order)))
> +			return false;
> +		prev_pfn =3D pfn;
> +		prev_order =3D page_order(page);
> +	}
> +
> +	return true;

A problem here is that if this loops touches the very last page from the
list.  list_for_each_entry_continue should be used here.  How about:

static bool is_isolate_pfn_range(unsigned long start_pfn, unsigned long end=
_pfn)
{
	unsigned long pfn, next_pfn;
	struct page *page;

	list_for_each_entry(page, &isolated_pages, lru) {
		if (&page->lru =3D=3D &isolated_pages)=20
			return false;
		pfn =3D page_to_pfn(page);
		if (pfn >=3D end_pfn || pfn > start_pfn)
			return false;
		if (pfn >=3D start_pfn)
			goto found;
	}
	return false;

	list_for_each_entry_continue(page, &isolated_pages, lru) {
		if (page_to_pfn(page) !=3D next_pfn)
			return false;
found:
		next_pfn =3D pfn + (1UL << page_order(page));
		if (next_pfn >=3D end_pfn)
			return true;
	}
	return false;
}

> +}
> +
>  /* called while holding zone->lock */
>  static void set_pageblock_isolate(struct page *page)
>  {
> @@ -91,13 +221,15 @@ void unset_migratetype_isolate(struct page *page, un=
signed migratetype)
>  	struct zone *zone;
>  	unsigned long flags;
>  	zone =3D page_zone(page);
> +
>  	spin_lock_irqsave(&zone->lock, flags);
>  	if (get_pageblock_migratetype(page) !=3D MIGRATE_ISOLATE)
>  		goto out;
> -	move_freepages_block(zone, page, migratetype);
> +
>  	restore_pageblock_isolate(page, migratetype);
>  out:
>  	spin_unlock_irqrestore(&zone->lock, flags);
> +	free_isolated_pageblock(page);
>  }

The =E2=80=9Cgoto out=E2=80=9D now looks rather stupid here, just do:

	if (get_pageblock_migratetype(page) =3D=3D MIGRATE_ISOLATE)
		restore_pageblock_isolate(page, migratetype);

>=20=20
>  static inline struct page *
> @@ -155,6 +287,30 @@ undo:
>  	return -EBUSY;
>  }
>=20=20
> +void undo_isolate_pageblock(unsigned long start_pfn, unsigned long end_p=
fn,
> +		unsigned migratetype)

The name seems misleading as it in fact can deal with many pageblocks
and not just one pageblock.

> +{
> +	unsigned long pfn;
> +	struct page *page;
> +	struct zone *zone;
> +	unsigned long flags;
> +
> +	BUG_ON((start_pfn) & (pageblock_nr_pages - 1));
> +	BUG_ON((end_pfn) & (pageblock_nr_pages - 1));

Unnecessary () around start_pfn and end_pfn.

> +
> +	for (pfn =3D start_pfn;
> +			pfn < end_pfn;
> +			pfn +=3D pageblock_nr_pages) {
> +		page =3D __first_valid_page(pfn, pageblock_nr_pages);
> +		if (!page || get_pageblock_migratetype(page) !=3D MIGRATE_ISOLATE)
> +			continue;
> +		zone =3D page_zone(page);
> +		spin_lock_irqsave(&zone->lock, flags);
> +		restore_pageblock_isolate(page, migratetype);
> +		spin_unlock_irqrestore(&zone->lock, flags);
> +	}
> +}
> +
>  /*
>   * Make isolated pages available again.
>   */
> @@ -180,30 +336,12 @@ int undo_isolate_page_range(unsigned long start_pfn=
, unsigned long end_pfn,
>   * all pages in [start_pfn...end_pfn) must be in the same zone.
>   * zone->lock must be held before call this.
>   *
> - * Returns 1 if all pages in the range are isolated.
> + * Returns true if all pages in the range are isolated.
>   */
> -static int
> +static bool
>  __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_p=
fn)
>  {
> -	struct page *page;
> -
> -	while (pfn < end_pfn) {
> -		if (!pfn_valid_within(pfn)) {
> -			pfn++;
> -			continue;
> -		}
> -		page =3D pfn_to_page(pfn);
> -		if (PageBuddy(page))
> -			pfn +=3D 1 << page_order(page);
> -		else if (page_count(page) =3D=3D 0 &&
> -				page_private(page) =3D=3D MIGRATE_ISOLATE)
> -			pfn +=3D 1;
> -		else
> -			break;
> -	}
> -	if (pfn < end_pfn)
> -		return 0;
> -	return 1;
> +	return is_isolate_pfn_range(pfn, end_pfn);

Wait, what?  So what's the purpose of this function if all it does is
call is_isolate_pfn_range()?  Or in other words, why
is_isolate_pfn_range() introduced?

>  }
>=20=20
>  int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
> @@ -211,7 +349,7 @@ int test_pages_isolated(unsigned long start_pfn, unsi=
gned long end_pfn)
>  	unsigned long pfn, flags;
>  	struct page *page;
>  	struct zone *zone;
> -	int ret;
> +	bool ret;
>=20=20
>  	/*
>  	 * Note: pageblock_nr_page !=3D MAX_ORDER. Then, chunks of free page
> --=20
> 1.7.9.5
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--
--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAEBAgAGBQJQR4u3AAoJECBgQBJQdR/0YsQQAIrtznBHP57zWcONLrQWFlLk
qMNxqIKHJQJGkVX6kxgZsi05D6pqXsSIx8lopt85dBGdxOSCbMoBvGTIr2boWZz7
pm0nJR9NgFNn1Pwh632E6IVk9AoUGR9MWrgni0zCL1jMNtAMbZswZR52/K9SDnw4
BtF+BJfhmZcvbT2baCRbPPR2heQd3P0U3qKqqyLAFqDXPaIS9qJmoH5woC3IYj++
gLmCJS4mng/uy5fTBrMM/pu+bQjH8xQWdiiLhhl3QenMgHd2rU5VCkrkFlQJ9iy8
vLY7KdnRb/TwnnGL+5uisF2QZm8q2AdD1W/a7sgwY6RczaV+rE83UXgyCX7MrTWg
DE3upZami2ZWFhP7cGnKJmuIAd5VZwQUiPbEJxSO/D77R8KSCE0pjC6+LN88WK2t
lEFtBFwFESwr2GU1k6uEyzDwdShmF7MNsq7027pIZax1kS/FCMKh6NJQRQCJCig1
5VD39eC4nKPhAPvBMu6ohRI+uy6o/BB8SWj9xf+pRwqhwM2tVHPzMTZ/wmY+bIf4
8uH/7q+07lVz5PBJcahyP3yYHgCnwVgHwLGGyftzDDIz7wIo480rsKd7AhLMRBeN
7XZKYtgeOIaYRjnrtTxeCE4JttCzU8NwkTgV6S0udYCHhGV6z0KyV5xusExRnxN0
DFq2MTqOLg0Fkg/8DiVL
=b4kN
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
