Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2A3AA6B0071
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 06:20:17 -0500 (EST)
Received: by iwn33 with SMTP id 33so3290603iwn.14
        for <linux-mm@kvack.org>; Mon, 22 Nov 2010 03:20:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101119171415.aa320cab.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101119171033.a8d9dc8f.kamezawa.hiroyu@jp.fujitsu.com>
	<20101119171415.aa320cab.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 22 Nov 2010 20:20:14 +0900
Message-ID: <AANLkTinvmJNAXAKFbSZvhyPAbZsEW1eBY2YDkqvr5FF5@mail.gmail.com>
Subject: Re: [PATCH 2/4] alloc_contig_pages() find appropriate physical memory range
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Bob Liu <lliubbo@gmail.com>, fujita.tomonori@lab.ntt.co.jp, m.nazarewicz@samsung.com, pawel@osciak.com, andi.kleen@intel.com, felipe.contreras@gmail.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 19, 2010 at 5:14 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Unlike memory hotplug, at an allocation of contigous memory range, addres=
s
> may not be a problem. IOW, if a requester of memory wants to allocate 100=
M of
> of contigous memory, placement of allocated memory may not be a problem.
> So, "finding a range of memory which seems to be MOVABLE" is required.
>
> This patch adds a functon to isolate a length of memory within [start, en=
d).
> This function returns a pfn which is 1st page of isolated contigous chunk
> of given length within [start, end).
>
> If no_search=3Dtrue is passed as argument, start address is always same t=
o
> the specified "base" addresss.
>
> After isolation, free memory within this area will never be allocated.
> But some pages will remain as "Used/LRU" pages. They should be dropped by
> page reclaim or migration.
>
> Changelog: 2010-11-17
> =A0- fixed some conding style (if-then-else)
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0mm/page_isolation.c | =A0146 +++++++++++++++++++++++++++++++++++++++++=
+++++++++++
> =A01 file changed, 146 insertions(+)
>
> Index: mmotm-1117/mm/page_isolation.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-1117.orig/mm/page_isolation.c
> +++ mmotm-1117/mm/page_isolation.c
> @@ -7,6 +7,7 @@
> =A0#include <linux/pageblock-flags.h>
> =A0#include <linux/memcontrol.h>
> =A0#include <linux/migrate.h>
> +#include <linux/memory_hotplug.h>
> =A0#include <linux/mm_inline.h>
> =A0#include "internal.h"
>
> @@ -250,3 +251,148 @@ int do_migrate_range(unsigned long start
> =A0out:
> =A0 =A0 =A0 =A0return ret;
> =A0}
> +
> +/*
> + * Functions for getting contiguous MOVABLE pages in a zone.
> + */
> +struct page_range {
> + =A0 =A0 =A0 unsigned long base; /* Base address of searching contigouou=
s block */
> + =A0 =A0 =A0 unsigned long end;
> + =A0 =A0 =A0 unsigned long pages;/* Length of contiguous block */

Nitpick.
You used nr_pages in other place.
I hope you use the name consistent.

> + =A0 =A0 =A0 int align_order;
> + =A0 =A0 =A0 unsigned long align_mask;

Does we really need this field 'align_mask'?
We can get always from align_order.

> +};
> +
> +int __get_contig_block(unsigned long pfn, unsigned long nr_pages, void *=
arg)
> +{
> + =A0 =A0 =A0 struct page_range *blockinfo =3D arg;
> + =A0 =A0 =A0 unsigned long end;
> +
> + =A0 =A0 =A0 end =3D pfn + nr_pages;
> + =A0 =A0 =A0 pfn =3D ALIGN(pfn, 1 << blockinfo->align_order);
> + =A0 =A0 =A0 end =3D end & ~(MAX_ORDER_NR_PAGES - 1);
> +
> + =A0 =A0 =A0 if (end < pfn)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 if (end - pfn >=3D blockinfo->pages) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 blockinfo->base =3D pfn;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 blockinfo->end =3D end;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static void __trim_zone(struct zone *zone, struct page_range *range)
> +{
> + =A0 =A0 =A0 unsigned long pfn;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* skip pages which dones'nt under the zone.

typo dones'nt -> doesn't :)

> + =A0 =A0 =A0 =A0* There are some archs which zones are not in linear lay=
out.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (page_zone(pfn_to_page(range->base)) !=3D zone) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (pfn =3D range->base;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pfn < range->end;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pfn +=3D MAX_ORDER_NR_PAGES=
) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (page_zone(pfn_to_page(p=
fn)) =3D=3D zone)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 range->base =3D min(pfn, range->end);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 /* Here, range-> base is in the zone if range->base !=3D ra=
nge->end */
> + =A0 =A0 =A0 for (pfn =3D range->base;
> + =A0 =A0 =A0 =A0 =A0 =A0pfn < range->end;
> + =A0 =A0 =A0 =A0 =A0 =A0pfn +=3D MAX_ORDER_NR_PAGES) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (zone !=3D page_zone(pfn_to_page(pfn))) =
{
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pfn =3D pfn - MAX_ORDER_NR_=
PAGES;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 range->end =3D min(pfn, range->end);
> + =A0 =A0 =A0 return;

Remove return

> +}
> +
> +/*
> + * This function is for finding a contiguous memory block which has leng=
th
> + * of pages and MOVABLE. If it finds, make the range of pages as ISOLATE=
D
> + * and return the first page's pfn.
> + * This checks all pages in the returned range is free of Pg_LRU. To red=
uce
> + * the risk of false-positive testing, lru_add_drain_all() should be cal=
led
> + * before this function to reduce pages on pagevec for zones.
> + */
> +
> +static unsigned long find_contig_block(unsigned long base,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long end, unsigned long pages,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int align_order, struct zone *zone)
> +{
> + =A0 =A0 =A0 unsigned long pfn, pos;
> + =A0 =A0 =A0 struct page_range blockinfo;
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 VM_BUG_ON(pages & (MAX_ORDER_NR_PAGES - 1));
> + =A0 =A0 =A0 VM_BUG_ON(base & ((1 << align_order) - 1));
> +retry:
> + =A0 =A0 =A0 blockinfo.base =3D base;
> + =A0 =A0 =A0 blockinfo.end =3D end;
> + =A0 =A0 =A0 blockinfo.pages =3D pages;
> + =A0 =A0 =A0 blockinfo.align_order =3D align_order;
> + =A0 =A0 =A0 blockinfo.align_mask =3D (1 << align_order) - 1;

We don't need this.

> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* At first, check physical page layout and skip memory h=
oles.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 ret =3D walk_system_ram_range(base, end - base, &blockinfo,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __get_contig_block);
> + =A0 =A0 =A0 if (!ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 /* check contiguous pages in a zone */
> + =A0 =A0 =A0 __trim_zone(zone, &blockinfo);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Ok, we found contiguous memory chunk of size. Isolate =
it.
> + =A0 =A0 =A0 =A0* We just search MAX_ORDER aligned range.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 for (pfn =3D blockinfo.base; pfn + pages <=3D blockinfo.end=
;
> + =A0 =A0 =A0 =A0 =A0 =A0pfn +=3D (1 << align_order)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *z =3D page_zone(pfn_to_page(pf=
n));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (z !=3D zone)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;

Could we make sure pass __trim_zone is to satisfy whole pfn in zone
what we want.
Repeated the zone check is rather annoying.
I mean let's __get_contig_block or __trim_zone already does check zone
so that we remove the zone check in here.

> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irq(&z->lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pos =3D pfn;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Check the range only contains free pag=
es or LRU pages.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (pos < pfn + pages) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *p;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pfn_valid_within(pos))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p =3D pfn_to_page(pos);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageReserved(p))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!page_count(p)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!PageBu=
ddy(p))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 pos++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 pos +=3D (1 << page_order(p));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (PageLRU(p)) {

Could we check get_pageblock_migratetype(page) =3D=3D MIGRATE_MOVABLE in
here and early bail out?

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pos++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irq(&z->lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((pos =3D=3D pfn + pages)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!start_isolate_page_ran=
ge(pfn, pfn + pages))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return pfn;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else/* the chunk including "pos" should b=
e skipped */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pfn =3D pos & ~((1 << align=
_order) - 1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cond_resched();
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* failed */
> + =A0 =A0 =A0 if (blockinfo.end + pages <=3D end) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Move base address and find the next bloc=
k of RAM. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 base =3D blockinfo.end;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto retry;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return 0;

If the base is 0, isn't it impossible return pfn 0?
x86 in FLAT isn't impossible but I think some architecture might be possibl=
e.
Just guessing.

How about returning negative value and return first page pfn and last
page pfn as out parameter base, end?

> +}
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
