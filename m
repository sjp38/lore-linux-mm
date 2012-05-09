Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 1EA606B010A
	for <linux-mm@kvack.org>; Wed,  9 May 2012 05:01:03 -0400 (EDT)
Received: from euspt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M3Q00M3MZPGQ0@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 09 May 2012 10:00:52 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M3Q0009QZPLSU@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 09 May 2012 10:00:58 +0100 (BST)
Date: Wed, 09 May 2012 10:59:30 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH v7] mm: compaction: handle incorrect MIGRATE_UNMOVABLE type
 pageblocks
In-reply-to: <20120507154926.e9ea8b3e.akpm@linux-foundation.org>
Message-id: <201205091059.30227.b.zolnierkie@samsung.com>
MIME-version: 1.0
Content-type: Text/Plain; charset=utf-8
Content-transfer-encoding: quoted-printable
References: <201205071146.22736.b.zolnierkie@samsung.com>
 <20120507154926.e9ea8b3e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>


Hi,

On Tuesday 08 May 2012 00:49:26 Andrew Morton wrote:
> On Mon, 07 May 2012 11:46:22 +0200
> Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com> wrote:
>=20
> > From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > Subject: [PATCH v7] mm: compaction: handle incorrect MIGRATE_UNMOVABLE =
type pageblocks
>=20
> I have a bunch of minorish things..
>=20
> > When MIGRATE_UNMOVABLE pages are freed from MIGRATE_UNMOVABLE
> > type pageblock (and some MIGRATE_MOVABLE pages are left in it)
> > waiting until an allocation takes ownership of the block may
> > take too long.  The type of the pageblock remains unchanged
> > so the pageblock cannot be used as a migration target during
> > compaction.
> >=20
> > Fix it by:
> >=20
> > * Adding enum compact_mode (COMPACT_ASYNC_[MOVABLE,UNMOVABLE],
> >   and COMPACT_SYNC) and then converting sync field in struct
> >   compact_control to use it.
> >=20
> > * Adding nr_pageblocks_skipped field to struct compact_control
> >   and tracking how many destination pageblocks were of
> >   MIGRATE_UNMOVABLE type.  If COMPACT_ASYNC_MOVABLE mode compaction
> >   ran fully in try_to_compact_pages() (COMPACT_COMPLETE) it implies
> >   that there is not a suitable page for allocation.  In this case
> >   then check how if there were enough MIGRATE_UNMOVABLE pageblocks
> >   to try a second pass in COMPACT_ASYNC_UNMOVABLE mode.
> >=20
> > * Scanning the MIGRATE_UNMOVABLE pageblocks (during COMPACT_SYNC
> >   and COMPACT_ASYNC_UNMOVABLE compaction modes) and building
> >   a count based on finding PageBuddy pages, page_count(page) =3D=3D 0
> >   or PageLRU pages.  If all pages within the MIGRATE_UNMOVABLE
> >   pageblock are in one of those three sets change the whole
> >   pageblock type to MIGRATE_MOVABLE.
> >=20
> >=20
> > My particular test case (on a ARM EXYNOS4 device with 512 MiB,
> > which means 131072 standard 4KiB pages in 'Normal' zone) is to:
> > - allocate 120000 pages for kernel's usage
> > - free every second page (60000 pages) of memory just allocated
> > - allocate and use 60000 pages from user space
> > - free remaining 60000 pages of kernel memory
> > (now we have fragmented memory occupied mostly by user space pages)
> > - try to allocate 100 order-9 (2048 KiB) pages for kernel's usage
> >=20
> > The results:
> > - with compaction disabled I get 11 successful allocations
> > - with compaction enabled - 14 successful allocations
> > - with this patch I'm able to get all 100 successful allocations
> >=20
> >=20
> > NOTE: If we can make kswapd aware of order-0 request during
> > compaction, we can enhance kswapd with changing mode to
> > COMPACT_ASYNC_FULL (COMPACT_ASYNC_MOVABLE + COMPACT_ASYNC_UNMOVABLE).
> > Please see the following thread:
> >=20
> > 	http://marc.info/?l=3Dlinux-mm&m=3D133552069417068&w=3D2
> >=20
> >=20
> > Minor cleanups from Minchan Kim.
>=20
> A common way to do this sort of thing is to add
>=20
> [minchan@kernel.org: minor cleanups]
>=20
> just before the Cc: list, and to also Cc: that person in the Cc: list.=20
> At least, that's what I do, and that makes it common ;)

OK :)

> > ...
> >
> > --- a/include/linux/compaction.h	2012-05-07 11:34:50.000000000 +0200
> > +++ b/include/linux/compaction.h	2012-05-07 11:35:29.032707770 +0200
> > @@ -1,6 +1,8 @@
> >  #ifndef _LINUX_COMPACTION_H
> >  #define _LINUX_COMPACTION_H
> > =20
> > +#include <linux/node.h>
> > +
> >  /* Return values for compact_zone() and try_to_compact_pages() */
> >  /* compaction didn't start as it was not possible or direct reclaim wa=
s more suitable */
> >  #define COMPACT_SKIPPED		0
> > @@ -11,6 +13,23 @@
> >  /* The full zone was compacted */
> >  #define COMPACT_COMPLETE	3
> > =20
> > +/*
> > + * compaction supports three modes
> > + *
> > + * COMPACT_ASYNC_MOVABLE uses asynchronous migration and only scans
> > + *    MIGRATE_MOVABLE pageblocks as migration sources and targets.
> > + * COMPACT_ASYNC_UNMOVABLE uses asynchronous migration and only scans
> > + *    MIGRATE_MOVABLE pageblocks as migration sources.
> > + *    MIGRATE_UNMOVABLE pageblocks are scanned as potential migration
> > + *    targets and convers them to MIGRATE_MOVABLE if possible
> > + * COMPACT_SYNC uses synchronous migration and scans all pageblocks
> > + */
> > +enum compact_mode {
> > +	COMPACT_ASYNC_MOVABLE,
> > +	COMPACT_ASYNC_UNMOVABLE,
> > +	COMPACT_SYNC,
> > +};
>=20
> Why was the include <linux/node.h> added?  The enum definition didn't
> need that.

It is needed to fix build failure, please see:
http://www.spinics.net/lists/linux-mm/msg33901.html

> >  #ifdef CONFIG_COMPACTION
> >  extern int sysctl_compact_memory;
> >  extern int sysctl_compaction_handler(struct ctl_table *table, int writ=
e,
> > Index: b/mm/compaction.c
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > --- a/mm/compaction.c	2012-05-07 11:34:53.000000000 +0200
> > +++ b/mm/compaction.c	2012-05-07 11:39:06.668707335 +0200
> > @@ -235,7 +235,7 @@
> >  	 */
> >  	while (unlikely(too_many_isolated(zone))) {
> >  		/* async migration should just abort */
> > -		if (!cc->sync)
> > +		if (cc->mode !=3D COMPACT_SYNC)
> >  			return 0;
> > =20
> >  		congestion_wait(BLK_RW_ASYNC, HZ/10);
> > @@ -303,7 +303,8 @@
> >  		 * satisfies the allocation
> >  		 */
> >  		pageblock_nr =3D low_pfn >> pageblock_order;
> > -		if (!cc->sync && last_pageblock_nr !=3D pageblock_nr &&
> > +		if (cc->mode !=3D COMPACT_SYNC &&
> > +		    last_pageblock_nr !=3D pageblock_nr &&
> >  		    !migrate_async_suitable(get_pageblock_migratetype(page))) {
> >  			low_pfn +=3D pageblock_nr_pages;
> >  			low_pfn =3D ALIGN(low_pfn, pageblock_nr_pages) - 1;
> > @@ -324,7 +325,7 @@
> >  			continue;
> >  		}
> > =20
> > -		if (!cc->sync)
> > +		if (cc->mode !=3D COMPACT_SYNC)
> >  			mode |=3D ISOLATE_ASYNC_MIGRATE;
> > =20
> >  		/* Try isolate the page */
> > @@ -357,27 +358,82 @@
> > =20
> >  #endif /* CONFIG_COMPACTION || CONFIG_CMA */
> >  #ifdef CONFIG_COMPACTION
> > +static bool rescue_unmovable_pageblock(struct page *page)
>=20
> This could do with a bit of documentation.  It returns a bool, but what
> does that bool *mean*?  Presumably it means "it worked".  But what was
> "it"?

OK

> > +{
> > +	unsigned long pfn, start_pfn, end_pfn;
> > +	struct page *start_page, *end_page;
> > +
> > +	pfn =3D page_to_pfn(page);
> > +	start_pfn =3D pfn & ~(pageblock_nr_pages - 1);
>=20
> Could use round_down() here, but that doesn't add much if any value IMO.
>=20
> > +	end_pfn =3D start_pfn + pageblock_nr_pages;
> > +
> > +	start_page =3D pfn_to_page(start_pfn);
> > +	end_page =3D pfn_to_page(end_pfn);
> > +
> > +	/* Do not deal with pageblocks that overlap zones */
> > +	if (page_zone(start_page) !=3D page_zone(end_page))
> > +		return false;
> > +
> > +	for (page =3D start_page, pfn =3D start_pfn; page < end_page; pfn++,
> > +								  page++) {
> > +		if (!pfn_valid_within(pfn))
> > +			continue;
> > +
> > +		if (PageBuddy(page)) {
> > +			int order =3D page_order(page);
> > +
> > +			pfn +=3D (1 << order) - 1;
> > +			page +=3D (1 << order) - 1;
> > +
> > +			continue;
> > +		} else if (page_count(page) =3D=3D 0 || PageLRU(page))
> > +			continue;
> > +
> > +		return false;
> > +	}
> > +
> > +	set_pageblock_migratetype(page, MIGRATE_MOVABLE);
> > +	move_freepages_block(page_zone(page), page, MIGRATE_MOVABLE);
> > +	return true;
> > +}
> > +
> > +enum result_smt {
>=20
> <thinks for a while>
>=20
> Ah, I get it: "smt" =3D "suitable_migration_target".  So "smt_result"
> would be a better name.

OK

> > +	GOOD_AS_MIGRATION_TARGET,
> > +	FAIL_UNMOVABLE,
> > +	FAIL_ETC_REASON,
>=20
> But I can't work out what ETC means.

OK, I changed it to FAIL_BAD_TARGET.

> > +};
> > =20
> >  /* Returns true if the page is within a block suitable for migration t=
o */
>=20
> This comment is now incorrect.

=46ixed.

> > -static bool suitable_migration_target(struct page *page)
> > +static enum result_smt suitable_migration_target(struct page *page,
> > +				      struct compact_control *cc)
> >  {
> > =20
> >  	int migratetype =3D get_pageblock_migratetype(page);
> > =20
> >  	/* Don't interfere with memory hot-remove or the min_free_kbytes bloc=
ks */
> >  	if (migratetype =3D=3D MIGRATE_ISOLATE || migratetype =3D=3D MIGRATE_=
RESERVE)
> > -		return false;
> > +		return FAIL_ETC_REASON;
> > =20
> >  	/* If the page is a large free page, then allow migration */
> >  	if (PageBuddy(page) && page_order(page) >=3D pageblock_order)
> > -		return true;
> > +		return GOOD_AS_MIGRATION_TARGET;
> > =20
> >  	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
> > -	if (migrate_async_suitable(migratetype))
> > -		return true;
> > +	if (cc->mode !=3D COMPACT_ASYNC_UNMOVABLE &&
> > +	    migrate_async_suitable(migratetype))
> > +		return GOOD_AS_MIGRATION_TARGET;
> > +
> > +	if (cc->mode =3D=3D COMPACT_ASYNC_MOVABLE &&
> > +	    migratetype =3D=3D MIGRATE_UNMOVABLE)
> > +		return FAIL_UNMOVABLE;
> > +
> > +	if (cc->mode !=3D COMPACT_ASYNC_MOVABLE &&
> > +	    migratetype =3D=3D MIGRATE_UNMOVABLE &&
> > +	    rescue_unmovable_pageblock(page))
> > +		return GOOD_AS_MIGRATION_TARGET;
> > =20
> >  	/* Otherwise skip the block */
> > -	return false;
> > +	return FAIL_ETC_REASON;
> >  }
> > =20
> >  /*
> > @@ -410,6 +466,8 @@
> > =20
> >  	zone_end_pfn =3D zone->zone_start_pfn + zone->spanned_pages;
> > =20
> > +	cc->nr_pageblocks_skipped =3D 0;
>=20
> The handling of nr_pageblocks_skipped is awkward - we're repeatedly
> clearing a field in the compaction_control at a quite different level
> from the other parts of the code and there's a decent chance of us
> screwing up the ->nr_pageblocks_skipped protocol in the future.
>=20
> Do we need to add it at all?  Would it be cleaner to add a ulong*
> argument to migrate_pages()?

The other users of migrate_pages() have no need for nr_pageblocks_skipped
so I think that the current approach is better.

> Alternatively, can we initialise nr_pageblocks_skipped in
> compact_zone_order(), alongside everything else?  If that doesn't work
> then we must be rezeroing this field multiople times in the lifetime of
> a single compact_control.  That's an odd thing to do, so please let's
> at least document the ->nr_pageblocks_skipped protocol carefully.

Unfortunately sometimes isolate_freepages() can be called more than
once during compact_zone_order() run and we want only the most recent
count..

> >  	/*
> >  	 * Isolate free pages until enough are available to migrate the
> >  	 * pages on cc->migratepages. We stop searching if the migrate
> >
> > ...
> >
> > @@ -682,8 +745,9 @@
> > =20
> >  		nr_migrate =3D cc->nr_migratepages;
> >  		err =3D migrate_pages(&cc->migratepages, compaction_alloc,
> > -				(unsigned long)cc, false,
> > -				cc->sync ? MIGRATE_SYNC_LIGHT : MIGRATE_ASYNC);
> > +			(unsigned long)cc, false,
>=20
> ugh ugh.  The code is (and was) assuming that the fist field in the
> compact_control is a list_head.  Please let's use container_of(cc,
> struct list_head, freepages).

It doesn't look correct:

mm/compaction.c: In function =E2=80=98compact_zone=E2=80=99:
mm/compaction.c:757: error: =E2=80=98struct list_head=E2=80=99 has no membe=
r named =E2=80=98freepages=E2=80=99
mm/compaction.c:757: warning: type defaults to =E2=80=98int=E2=80=99 in dec=
laration of =E2=80=98__mptr=E2=80=99
mm/compaction.c:757: warning: initialization from incompatible pointer type
mm/compaction.c:757: error: =E2=80=98struct list_head=E2=80=99 has no membe=
r named =E2=80=98freepages=E2=80=99

I've changed it to (unsigned long)&cc->freepages instead.

> > +			(cc->mode =3D=3D COMPACT_SYNC) ? MIGRATE_SYNC_LIGHT
> > +						      : MIGRATE_ASYNC);
> >  		update_nr_listpages(cc);
> >  		nr_remaining =3D cc->nr_migratepages;
> > =20
> >
> > ...
> >
> > --- a/mm/internal.h	2012-05-07 11:34:53.000000000 +0200
> > +++ b/mm/internal.h	2012-05-07 11:36:57.548707591 +0200
> > @@ -95,6 +95,9 @@
> >  /*
> >   * in mm/page_alloc.c
> >   */
> > +extern void set_pageblock_migratetype(struct page *page, int migratety=
pe);
> > +extern int move_freepages_block(struct zone *zone, struct page *page,
> > +				int migratetype);
> >  extern void __free_pages_bootmem(struct page *page, unsigned int order=
);
> >  extern void prep_compound_page(struct page *page, unsigned long order);
> >  #ifdef CONFIG_MEMORY_FAILURE
> > @@ -102,6 +105,7 @@
> >  #endif
> > =20
> >  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
> > +#include <linux/compaction.h>
>=20
> It's a bit ungainly to include compaction.h from within internal.h.=20
> And it's a bit dangerous when this is donw halfway through the file,
> inside ifdefs.
>=20
> For mm/internal.h I think it's reasonable to require that the .c file
> has provided internal.h's prerequisites.  This will improve compilation
> speed a tad as well.  So let's proceed your way for now, but perhaps
> someone can come up with a cleanup patch sometime which zaps the
> #includes from internal.h
>=20
> Alternatively: enums are awkward because they can't be forward-declared
> (probably because the compiler can choose different sizeof(enum foo),
> based on the enum's value range).  One way around this is to place the
> enum's definition in its own little header file.
>=20
> >  /*
> >   * in mm/compaction.c
> > @@ -120,11 +124,14 @@
> >  	unsigned long nr_migratepages;	/* Number of pages to migrate */
> >  	unsigned long free_pfn;		/* isolate_freepages search base */
> >  	unsigned long migrate_pfn;	/* isolate_migratepages search base */
> > -	bool sync;			/* Synchronous migration */
> > +	enum compact_mode mode;		/* Compaction mode */
> > =20
> >  	int order;			/* order a direct compactor needs */
> >  	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
> >  	struct zone *zone;
> > +
> > +	/* Number of UNMOVABLE destination pageblocks skipped during scan */
> > +	unsigned long nr_pageblocks_skipped;
> >  };
> > =20
> >  unsigned long
> >
> > ...
> >

Here is the incremental patch (it can be folded into the original one) hope=
fully
fixing all outstanding issues (including FAIL_UNMOVABLE_TARGET handling fix=
 for
problem noticed by Minchan Kim):

=46rom: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH v7] mm: compaction: handle incorrect MIGRATE_UNMOVABLE type=
 pageblocks (part 2)

=2D document rescue_unmovable_pageblock()
=2D enum result_smt -> enum_smt_result
=2D fix suitable_migration_target() documentation
=2D add comment about zeroing cc->nr_pageblocks_skipped
=2D fix FAIL_UNMOVABLE_TARGET handling in isolate_freepages()

Cc: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
=2D--
 mm/compaction.c |   38 ++++++++++++++++++++++++++------------
 1 file changed, 26 insertions(+), 12 deletions(-)

Index: b/mm/compaction.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=2D-- a/mm/compaction.c	2012-05-09 09:24:53.143124978 +0200
+++ b/mm/compaction.c	2012-05-09 10:34:14.666441168 +0200
@@ -358,6 +358,10 @@
=20
 #endif /* CONFIG_COMPACTION || CONFIG_CMA */
 #ifdef CONFIG_COMPACTION
+/*
+ * Returns true if MIGRATE_UNMOVABLE pageblock was successfully
+ * converted to MIGRATE_MOVABLE type, false otherwise.
+ */
 static bool rescue_unmovable_pageblock(struct page *page)
 {
 	unsigned long pfn, start_pfn, end_pfn;
@@ -397,14 +401,18 @@
 	return true;
 }
=20
=2Denum result_smt {
+enum smt_result {
 	GOOD_AS_MIGRATION_TARGET,
=2D	FAIL_UNMOVABLE,
=2D	FAIL_ETC_REASON,
+	FAIL_UNMOVABLE_TARGET,
+	FAIL_BAD_TARGET,
 };
=20
=2D/* Returns true if the page is within a block suitable for migration to =
*/
=2Dstatic enum result_smt suitable_migration_target(struct page *page,
+/*
+ * Returns GOOD_AS_MIGRATION_TARGET if the page is within a block
+ * suitable for migration to, FAIL_UNMOVABLE_TARGET if the page
+ * is within a MIGRATE_UNMOVABLE block, FAIL_BAD_TARGET otherwise.
+ */
+static enum smt_result suitable_migration_target(struct page *page,
 				      struct compact_control *cc)
 {
=20
@@ -412,7 +420,7 @@
=20
 	/* Don't interfere with memory hot-remove or the min_free_kbytes blocks */
 	if (migratetype =3D=3D MIGRATE_ISOLATE || migratetype =3D=3D MIGRATE_RESE=
RVE)
=2D		return FAIL_ETC_REASON;
+		return FAIL_BAD_TARGET;
=20
 	/* If the page is a large free page, then allow migration */
 	if (PageBuddy(page) && page_order(page) >=3D pageblock_order)
@@ -425,7 +433,7 @@
=20
 	if (cc->mode =3D=3D COMPACT_ASYNC_MOVABLE &&
 	    migratetype =3D=3D MIGRATE_UNMOVABLE)
=2D		return FAIL_UNMOVABLE;
+		return FAIL_UNMOVABLE_TARGET;
=20
 	if (cc->mode !=3D COMPACT_ASYNC_MOVABLE &&
 	    migratetype =3D=3D MIGRATE_UNMOVABLE &&
@@ -433,7 +441,7 @@
 		return GOOD_AS_MIGRATION_TARGET;
=20
 	/* Otherwise skip the block */
=2D	return FAIL_ETC_REASON;
+	return FAIL_BAD_TARGET;
 }
=20
 /*
@@ -466,6 +474,11 @@
=20
 	zone_end_pfn =3D zone->zone_start_pfn + zone->spanned_pages;
=20
+	/*
+	 * isolate_freepages() may be called more than once during
+	 * compact_zone_order() run and we want only the most recent
+	 * count.
+	 */
 	cc->nr_pageblocks_skipped =3D 0;
=20
 	/*
@@ -476,7 +489,7 @@
 	for (; pfn > low_pfn && cc->nr_migratepages > nr_freepages;
 					pfn -=3D pageblock_nr_pages) {
 		unsigned long isolated;
=2D		enum result_smt ret;
+		enum smt_result ret;
=20
 		if (!pfn_valid(pfn))
 			continue;
@@ -495,7 +508,7 @@
 		/* Check the block is suitable for migration */
 		ret =3D suitable_migration_target(page, cc);
 		if (ret !=3D GOOD_AS_MIGRATION_TARGET) {
=2D			if (ret =3D=3D FAIL_UNMOVABLE)
+			if (ret =3D=3D FAIL_UNMOVABLE_TARGET)
 				cc->nr_pageblocks_skipped++;
 			continue;
 		}
@@ -513,7 +526,8 @@
 			isolated =3D isolate_freepages_block(pfn, end_pfn,
 							   freelist, false);
 			nr_freepages +=3D isolated;
=2D		}
+		} else if (ret =3D=3D FAIL_UNMOVABLE_TARGET)
+			cc->nr_pageblocks_skipped++;
 		spin_unlock_irqrestore(&zone->lock, flags);
=20
 		/*
@@ -745,7 +759,7 @@
=20
 		nr_migrate =3D cc->nr_migratepages;
 		err =3D migrate_pages(&cc->migratepages, compaction_alloc,
=2D			(unsigned long)cc, false,
+			(unsigned long)&cc->freepages, false,
 			(cc->mode =3D=3D COMPACT_SYNC) ? MIGRATE_SYNC_LIGHT
 						      : MIGRATE_ASYNC);
 		update_nr_listpages(cc);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
