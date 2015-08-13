Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id E0BCD6B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 06:05:46 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so34770123pac.2
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 03:05:46 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id i3si2988418pdp.75.2015.08.13.03.05.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Aug 2015 03:05:45 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/hwpoison: fix race between soft_offline_page and
 unpoison_memory
Date: Thu, 13 Aug 2015 10:04:07 +0000
Message-ID: <20150813100407.GA2993@hori1.linux.bs1.fc.nec.co.jp>
References: <BLU436-SMTP256072767311DFB0FD3AE1B807D0@phx.gbl>
 <20150813085332.GA30163@hori1.linux.bs1.fc.nec.co.jp>
 <BLU437-SMTP1006340696EDBC91961809807D0@phx.gbl>
In-Reply-To: <BLU437-SMTP1006340696EDBC91961809807D0@phx.gbl>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <6515C8AB5D1E4B449C55D5FA8EBBF915@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Aug 13, 2015 at 05:18:56PM +0800, Wanpeng Li wrote:
> On 8/13/15 4:53 PM, Naoya Horiguchi wrote:
...
> >
> > I think that unpoison is used only in testing so this race never affect=
s
> > our end-users/customers, so going back to this migratetype change stuff
> > looks unworthy to me.
>
> Migratetype stuff is just removed by you two months ago, then this bug
> occurs recently since the more and more patches which you fix some races.

Yes, this race (which existed before my recent changes) became more visible
with that changes. But I don't think that simply reverting them is a right =
solution.

> >
> > If I read correctly, the old migratetype approach has a few problems:
> >   1) it doesn't fix the problem completely, because
> >      set_migratetype_isolate() can fail to set MIGRATE_ISOLATE to the
> >      target page if the pageblock of the page contains one or more
> >      unmovable pages (i.e. has_unmovable_pages() returns true).
> >   2) the original code changes migratetype to MIGRATE_ISOLATE forcibly,
> >      and sets it to MIGRATE_MOVABLE forcibly after soft offline, regard=
less
> >      of the original migratetype state, which could impact other subsys=
tems
> >      like memory hotplug or compaction.
>
> Maybe we can add a "FIXME" comment on the Migratetype stuff, since the
> current linus tree calltrace and it should be fixed immediately, and I
> don't see obvious bugs appear on migratetype stuffs at least currently,
> so "FIXME" is enough. :-)

Sorry if confusing, but my intention in saying about "FIXME" comment was
that we can find another solution for this race rather than just reverting,
so adding comment about the reported bug in current code (keeping code from
4491f712606) is OK for very short term.
I understand that leaving a race window of BUG_ON is not the best thing, bu=
t
as I said, this race shouldn't affect end-users, so this is not an urgent b=
ug.
# It's enough if testers know this.

> >
> > So in my opinion, the best option is to fix this within unpoison code,
> > but it might be hard because we don't know whether the target page is
>
> Exactly.
>
> > under migration. The second option is to add a race check in the if (re=
ason
> > =3D=3D MR_MEMORY_FAILURE) branch in unmap_and_move(), although this loo=
ks ad-hoc
>
> You have already add MR_MEMORY_FAILURE, however, that is not enough to
> fix unpoison race.

Right, some additional code is necessary. I'll try the second approach.

Thanks,
Naoya Horiguchi

> > and need testing. The third option is to leave it with some "FIXME" com=
ment.
>
> I *prefer* add "FIXME" to migratetype stuffs.
>
> Regards,
> Wanpeng Li
>
> >
> > Thanks,
> > Naoya Horiguchi
> >
> >> ---
> >>  include/linux/page-isolation.h |    5 +++++
> >>  mm/memory-failure.c            |   16 ++++++++++++----
> >>  mm/migrate.c                   |    3 +--
> >>  mm/page_isolation.c            |    4 ++--
> >>  4 files changed, 20 insertions(+), 8 deletions(-)
> >>
> >> diff --git a/include/linux/page-isolation.h b/include/linux/page-isola=
tion.h
> >> index 047d647..ff5751e 100644
> >> --- a/include/linux/page-isolation.h
> >> +++ b/include/linux/page-isolation.h
> >> @@ -65,6 +65,11 @@ undo_isolate_page_range(unsigned long start_pfn, un=
signed long end_pfn,
> >>  int test_pages_isolated(unsigned long start_pfn, unsigned long end_pf=
n,
> >>  			bool skip_hwpoisoned_pages);
> >>
> >> +/*
> >> + *  Internal functions. Changes pageblock's migrate type.
> >> + */
> >> +int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_p=
ages);
> >> +void unset_migratetype_isolate(struct page *page, unsigned migratetyp=
e);
> >>  struct page *alloc_migrate_target(struct page *page, unsigned long pr=
ivate,
> >>  				int **resultp);
> >>
> >> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> >> index eca613e..0ed3814 100644
> >> --- a/mm/memory-failure.c
> >> +++ b/mm/memory-failure.c
> >> @@ -1647,8 +1647,6 @@ static int __soft_offline_page(struct page *page=
, int flags)
> >>  		inc_zone_page_state(page, NR_ISOLATED_ANON +
> >>  					page_is_file_cache(page));
> >>  		list_add(&page->lru, &pagelist);
> >> -		if (!TestSetPageHWPoison(page))
> >> -			atomic_long_inc(&num_poisoned_pages);
> >>  		ret =3D migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
> >>  					MIGRATE_SYNC, MR_MEMORY_FAILURE);
> >>  		if (ret) {
> >> @@ -1663,8 +1661,9 @@ static int __soft_offline_page(struct page *page=
, int flags)
> >>  				pfn, ret, page->flags);
> >>  			if (ret > 0)
> >>  				ret =3D -EIO;
> >> -			if (TestClearPageHWPoison(page))
> >> -				atomic_long_dec(&num_poisoned_pages);
> >> +		} else {
> >> +			if (!TestSetPageHWPoison(page))
> >> +				atomic_long_inc(&num_poisoned_pages);
> >>  		}
> >>  	} else {
> >>  		pr_info("soft offline: %#lx: isolation failed: %d, page count %d, t=
ype %lx\n",
> >> @@ -1715,6 +1714,14 @@ int soft_offline_page(struct page *page, int fl=
ags)
> >>
> >>  	get_online_mems();
> >>
> >> +	/*
> >> +	 * Isolate the page, so that it doesn't get reallocated if it
> >> +	 * was free. This flag should be kept set until the source page
> >> +	 * is freed and PG_hwpoison on it is set.
> >> +	 */
> >> +	if (get_pageblock_migratetype(page) !=3D MIGRATE_ISOLATE)
> >> +		set_migratetype_isolate(page, false);
> >> +
> >>  	ret =3D get_any_page(page, pfn, flags);
> >>  	put_online_mems();
> >>  	if (ret > 0) { /* for in-use pages */
> >> @@ -1733,5 +1740,6 @@ int soft_offline_page(struct page *page, int fla=
gs)
> >>  				atomic_long_inc(&num_poisoned_pages);
> >>  		}
> >>  	}
> >> +	unset_migratetype_isolate(page, MIGRATE_MOVABLE);
> >>  	return ret;
> >>  }
> >> diff --git a/mm/migrate.c b/mm/migrate.c
> >> index 1f8369d..472baf5 100644
> >> --- a/mm/migrate.c
> >> +++ b/mm/migrate.c
> >> @@ -880,8 +880,7 @@ static int __unmap_and_move(struct page *page, str=
uct page *newpage,
> >>  	/* Establish migration ptes or remove ptes */
> >>  	if (page_mapped(page)) {
> >>  		try_to_unmap(page,
> >> -			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS|
> >> -			TTU_IGNORE_HWPOISON);
> >> +			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
> >>  		page_was_mapped =3D 1;
> >>  	}
> >>
> >> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> >> index 4568fd5..654662a 100644
> >> --- a/mm/page_isolation.c
> >> +++ b/mm/page_isolation.c
> >> @@ -9,7 +9,7 @@
> >>  #include <linux/hugetlb.h>
> >>  #include "internal.h"
> >>
> >> -static int set_migratetype_isolate(struct page *page,
> >> +int set_migratetype_isolate(struct page *page,
> >>  				bool skip_hwpoisoned_pages)
> >>  {
> >>  	struct zone *zone;
> >> @@ -73,7 +73,7 @@ out:
> >>  	return ret;
> >>  }
> >>
> >> -static void unset_migratetype_isolate(struct page *page, unsigned mig=
ratetype)
> >> +void unset_migratetype_isolate(struct page *page, unsigned migratetyp=
e)
> >>  {
> >>  	struct zone *zone;
> >>  	unsigned long flags, nr_pages;
> >> --
> >> 1.7.1
>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
