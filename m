Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 6ABC76B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 08:48:30 -0400 (EDT)
Received: by wibhm6 with SMTP id hm6so5008266wib.8
        for <linux-mm@kvack.org>; Thu, 06 Sep 2012 05:48:28 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC v2] memory-hotplug: remove MIGRATE_ISOLATE from free_area->free_list
In-Reply-To: <1346900018-14759-1-git-send-email-minchan@kernel.org>
References: <1346900018-14759-1-git-send-email-minchan@kernel.org>
Date: Thu, 06 Sep 2012 14:48:21 +0200
Message-ID: <xa1tsjav9v1m.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wen Congyang <wency@cn.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 06 2012, Minchan Kim wrote:
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
> * Changelog v1
>  * Fix from Michal's many suggestion

> ---
> It's very early version which show the concept so I still marked it with =
RFC.
> I just tested it with simple test and works.
> This patch is needed indepth review from memory-hotplug guys from fujitsu
> because I saw there are lots of patches recenlty they sent to about
> memory-hotplug change. Please take a look at this patch.

> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 2daa54f..438bab8 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -57,8 +57,8 @@ enum {
>  	 */
>  	MIGRATE_CMA,
>  #endif
> -	MIGRATE_ISOLATE,	/* can't allocate from here */
> -	MIGRATE_TYPES
> +	MIGRATE_TYPES,
> +	MIGRATE_ISOLATE
>  };

So now you're saying that MIGRATE_ISOLATE is not a migrate type at all,
since its not < MIGRATE_TYPES.  And still,  I don't see any reason to
remove the comment.

>=20=20
>  #ifdef CONFIG_CMA
> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolatio=
n.h
> index 105077a..1ae2cd6 100644
> --- a/include/linux/page-isolation.h
> +++ b/include/linux/page-isolation.h
> @@ -1,11 +1,16 @@
>  #ifndef __LINUX_PAGEISOLATION_H
>  #define __LINUX_PAGEISOLATION_H
>=20=20
> +extern struct list_head isolated_pages;

I don't think this is needed.

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

You could submit this as a separate patch because this documentation fix
is obviously correct.  Not sure how maintainers respond to one-line
patches though. ;)

> +void
> +undo_isolate_pageblocks(unsigned long start_pfn, unsigned long end_pfn,
> +			unsigned migratetype);
> +
>  int
>  undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>  			unsigned migratetype);
> diff --git a/mm/internal.h b/mm/internal.h
> index 3314f79..393197e 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -144,6 +144,9 @@ isolate_migratepages_range(struct zone *zone, struct =
compact_control *cc,
>   * function for dealing with page's order in buddy system.
>   * zone->lock is already acquired when we use these.
>   * So, we don't need atomic page->flags operations here.
> + *
> + * Page order should be put on page->private because
> + * memory-hotplug depends on it. Look mm/page_isolation.c.
>   */
>  static inline unsigned long page_order(struct page *page)
>  {
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 3ad25f9..30c36d5 100644
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
> +	undo_isolate_pageblocks(start_pfn, end_pfn, MIGRATE_MOVABLE);

Why is it changed here but not in other places undo_isolate_page_range()
is called?

Also, in this code, I'm missing the place where pages are moved from
isolated_pages back to a free_list.

>  	/* removal success */
>  	zone->present_pages -=3D offlined_pages;
>  	zone->zone_pgdat->node_present_pages -=3D offlined_pages;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ba3100a..3e516c5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
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
> index 247d1f1..27cf59e 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -8,6 +8,90 @@
>  #include <linux/memory.h>
>  #include "internal.h"
>=20=20
> +LIST_HEAD(isolated_pages);
> +static DEFINE_SPINLOCK(lock);
> +
> +/*
> + * Add the page into isolated_pages which is sort of pfn ascending list.
> + */
> +static void __add_isolated_page(struct page *page)
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

You could consider merging buddies here, ie. something like:

	while (__merge_buddies_maybe(page->lru.prev, &page) ||
	       __merge_buddies_maybe(&page->lru, &page)) {
		/* nop */
	}

bool __merge_buddies_maybe(struct list_head *head, struct page **retp)
{
	struct page *a, *b;
	unsigned order;

	if (head =3D=3D &isolated_pages || head->next =3D=3D &isolated_pages)
		return false;

	a =3D list_entry(head, struct page, lru);
	b =3D list_entry(head->next, struct page, lru);
	order =3D page_order(a);
	if (order =3D=3D min(MAX_ORDER - 1, pageblock_order) ||
	    order !=3D page_order(b) ||
	    (page_pfn(a) ^ page_pfn(b)) !=3D (1UL << order))
		return false;

	set_page_private(a, order + 1);
	list_del(head->next);
	*retp =3D a;
	return true;
}

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
> +	struct page *cursor, *tmp;
> +	unsigned long start_pfn, end_pfn, pfn;
> +	unsigned long flags;
> +	LIST_HEAD(pages);
> +
> +	start_pfn =3D page_to_pfn(page);
> +	start_pfn =3D start_pfn & ~(pageblock_nr_pages-1);
> +	end_pfn =3D start_pfn + pageblock_nr_pages;
> +
> +	spin_lock_irqsave(&lock, flags);
> +	list_for_each_entry_safe(cursor, tmp, &isolated_pages, lru) {
> +		pfn =3D page_to_pfn(cursor);
> +		if (pfn >=3D end_pfn)
> +			break;
> +		if (pfn >=3D start_pfn)
> +			list_move(&cursor->lru, &pages);
> +	}
> +	spin_unlock_irqrestore(&lock, flags);
> +
> +	list_for_each_entry_safe(cursor, tmp, &pages, lru) {
> +		int order =3D page_order(cursor);
> +		list_del(&cursor->lru);
> +		__free_pages(cursor, order);
> +	}

while (!list_empty(&pages)) {
	cursor =3D list_first_entry(&pages, struct page, lru);
	list_del(&cursor->lru);
	__free_pages(cursor, page_order(cursor));
}

> +}
> +
>  /* called while holding zone->lock */
>  static void set_pageblock_isolate(struct page *page)
>  {
> @@ -91,13 +175,12 @@ void unset_migratetype_isolate(struct page *page, un=
signed migratetype)
>  	struct zone *zone;
>  	unsigned long flags;
>  	zone =3D page_zone(page);
> +
>  	spin_lock_irqsave(&zone->lock, flags);
> -	if (get_pageblock_migratetype(page) !=3D MIGRATE_ISOLATE)
> -		goto out;
> -	move_freepages_block(zone, page, migratetype);
> -	restore_pageblock_isolate(page, migratetype);
> -out:
> +	if (get_pageblock_migratetype(page) =3D=3D MIGRATE_ISOLATE)
> +		restore_pageblock_isolate(page, migratetype);
>  	spin_unlock_irqrestore(&zone->lock, flags);
> +	free_isolated_pageblock(page);
>  }
>=20=20
>  static inline struct page *
> @@ -155,6 +238,30 @@ undo:
>  	return -EBUSY;
>  }
>=20=20
> +void undo_isolate_pageblocks(unsigned long start_pfn, unsigned long end_=
pfn,
> +		unsigned migratetype)
> +{
> +	unsigned long pfn;
> +	struct page *page;
> +	struct zone *zone;
> +	unsigned long flags;
> +
> +	BUG_ON(start_pfn & (pageblock_nr_pages - 1));
> +	BUG_ON(end_pfn & (pageblock_nr_pages - 1));
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
> @@ -180,30 +287,35 @@ int undo_isolate_page_range(unsigned long start_pfn=
, unsigned long end_pfn,
>   * all pages in [start_pfn...end_pfn) must be in the same zone.
>   * zone->lock must be held before call this.
>   *
> - * Returns 1 if all pages in the range are isolated.
> + * Returns true if all pages in the range are isolated.
>   */
> -static int
> -__test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_p=
fn)
> +static bool
> +__test_page_isolated_in_pageblock(unsigned long start_pfn, unsigned long=
 end_pfn)
>  {
> +	unsigned long pfn, next_pfn;
>  	struct page *page;
>=20=20
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
> +	list_for_each_entry(page, &isolated_pages, lru) {
> +		if (&page->lru =3D=3D &isolated_pages)
> +			return false;
> +		pfn =3D page_to_pfn(page);
> +		if (pfn >=3D end_pfn)
> +			return false;
> +		if (pfn >=3D start_pfn)
> +			goto found;
> +	}
> +	return false;
> +
> +	list_for_each_entry_continue(page, &isolated_pages, lru) {
> +		if (page_to_pfn(page) !=3D next_pfn)
> +			return false;
> +found:
> +		pfn =3D page_to_pfn(page);
> +		next_pfn =3D pfn + (1UL << page_order(page));
> +		if (next_pfn >=3D end_pfn)
> +			return true;
>  	}
> -	if (pfn < end_pfn)
> -		return 0;
> -	return 1;
> +	return false;
>  }
>=20=20
>  int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
> @@ -211,7 +323,7 @@ int test_pages_isolated(unsigned long start_pfn, unsi=
gned long end_pfn)
>  	unsigned long pfn, flags;
>  	struct page *page;
>  	struct zone *zone;
> -	int ret;
> +	bool ret;
>=20=20
>  	/*
>  	 * Note: pageblock_nr_page !=3D MAX_ORDER. Then, chunks of free page
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index df7a674..bb59ff7 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -616,7 +616,6 @@ static char * const migratetype_names[MIGRATE_TYPES] =
=3D {
>  #ifdef CONFIG_CMA
>  	"CMA",
>  #endif
> -	"Isolate",
>  };
>=20=20
>  static void *frag_start(struct seq_file *m, loff_t *pos)

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

iQIcBAEBAgAGBQJQSJuVAAoJECBgQBJQdR/06vcP/3ptRg1khs0Ty9LP8eKuoQzW
McLlTjbbttzVbcS21JJb1VgNcpoqPPb5y2tnHWwJk90fpUQkExtTKWD916JnpPBN
f041yFg8JPhz/apCmIzGWa3ITl2WVm6ueLJkKqc74NsfthDPgPo1CvzXSM7FvDRp
QxPzXDkD+QILnJCQDdrqtEZmSCW/xJGc0xL4yf4cF8rX3d4Vsa7pVwk/cC3kcekQ
jgpawuHQ2vgbg44ucDleFqDLmaF/oyHLDwXQE6eZwItYuOqxn4WYhVdfMNFKwvQc
lpjNhDImHVeCgjb1knOu6Q7lJ5gI4N1kJ34if7K90uYz72H0LyoIugUuwJFp+KcU
GabO1JH0b7kmHjXU3eXedCPGvvc+YcDmmo4xZ/9DieENvaoMsWNfSwM4JGq9IJax
lns5pDW97VNl425CwXpD6skY2NrpGvCFOgffQu+t170Sqrxf5hD1WVqWvZSi3zl7
UPmyY5Sd5r8UrIkg6H0ZEhbAQEAdVjkpTYSNk5Fuc5503RMzz00eg4R8o9k89nm2
EqrPhJ8pl07ISd8L0DjEc6lQgR2R3GI4Ob3zKRk7yPSxlOnb7tA496r/ZeneQNdc
mOEsFJkoOYEBMV8WgFnSqK283y3cnsTdYTs5jHw12lFts+u3+ADRPKmjwOrJrRSo
oxsx5yTIVGoHSLH3Y166
=fVjW
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
