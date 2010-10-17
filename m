Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E5E586B009F
	for <linux-mm@kvack.org>; Sat, 16 Oct 2010 23:18:51 -0400 (EDT)
Received: by iwn1 with SMTP id 1so3201374iwn.14
        for <linux-mm@kvack.org>; Sat, 16 Oct 2010 20:18:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101013121738.933ff002.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
	<20101013121738.933ff002.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sun, 17 Oct 2010 12:18:48 +0900
Message-ID: <AANLkTikCZBLufoL7pH8LKSRZRzOeH0z508PwJ5KwyE-5@mail.gmail.com>
Subject: Re: [RFC][PATCH 2/3] find a contiguous range.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Kame,
Sorry for the late review.

On Wed, Oct 13, 2010 at 12:17 PM, KAMEZAWA Hiroyuki
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

Typo
function

> This function returns a pfn which is 1st page of isolated contigous chunk

Typo
contiguous

> of given length within [start, end).
>
> If no_search=3Dtrue is passed as argument, start address is always same t=
o

I don't like no_search argument name. It would be better to show not
the implement but context.
How about "bool strict" or "ALLOC_FIXED"?
> the specified "base" addresss.
Typo
address,
Let's add following description.
"Some devices want to bind memory to some memory bank. In this case,
no_search and base address fix
can be helpful."

>
> After isolation, free memory within this area will never be allocated.
> But some pages will remain as "Used/LRU" pages. They should be dropped by
> page reclaim or migration.

At first I saw the above description, I got confused. How about this?
After it isolates some pages in the range, the part of some pages are
freed but others could be used processes now.
Next patch[3/3] try to move or reclaim used pages by page
migration/reclaim for obtaining big contiguous page.

>
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0mm/page_isolation.c | =A0130 +++++++++++++++++++++++++++++++++++++++++=
+++++++++++
> =A01 file changed, 130 insertions(+)
>
> Index: mmotm-1008/mm/page_isolation.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-1008.orig/mm/page_isolation.c
> +++ mmotm-1008/mm/page_isolation.c
> @@ -9,6 +9,7 @@
> =A0#include <linux/pageblock-flags.h>
> =A0#include <linux/memcontrol.h>
> =A0#include <linux/migrate.h>
> +#include <linux/memory_hotplug.h>
> =A0#include <linux/mm_inline.h>
> =A0#include "internal.h"
>
> @@ -254,3 +255,132 @@ out:
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> +/*
> + * Functions for getting contiguous MOVABLE pages in a zone.
> + */
> +struct page_range {
> + =A0 =A0 =A0 unsigned long base; /* Base address of searching contigouou=
s block */

Typo contiguous.
Please, specify that it's a pfn number.

> + =A0 =A0 =A0 unsigned long end;
> + =A0 =A0 =A0 unsigned long pages;/* Length of contiguous block */
> +};
> +
> +static inline unsigned long =A0MAX_ORDER_ALIGN(unsigned long x)
> +{
> + =A0 =A0 =A0 return ALIGN(x, MAX_ORDER_NR_PAGES);
> +}
> +
> +static inline unsigned long MAX_ORDER_BASE(unsigned long x)
> +{
> + =A0 =A0 =A0 return x & ~(MAX_ORDER_NR_PAGES - 1);
> +}
> +
> +int __get_contig_block(unsigned long pfn, unsigned long nr_pages, void *=
arg)
> +{
> + =A0 =A0 =A0 struct page_range *blockinfo =3D arg;
> + =A0 =A0 =A0 unsigned long end;
> +
> + =A0 =A0 =A0 end =3D pfn + nr_pages;
> + =A0 =A0 =A0 pfn =3D MAX_ORDER_ALIGN(pfn);
> + =A0 =A0 =A0 end =3D MAX_ORDER_BASE(end);
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
> +static void __trim_zone(struct page_range *range)

Hmm..
I think this function name can't present enough meaning.
Let's move description in body of function to the head.

/*
 * In most case, each zone's [start_pfn, end_pfn) has no
 * overlap between each other. But some arch allows it and
 * we need to check it here. If it happens, range end is changed
 * to only include pfns in a zone.
 */

> +{
> + =A0 =A0 =A0 struct zone *zone;
> + =A0 =A0 =A0 unsigned long pfn;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* In most case, each zone's [start_pfn, end_pfn) has no
> + =A0 =A0 =A0 =A0* overlap between each other. But some arch allows it an=
d
> + =A0 =A0 =A0 =A0* we need to check it here.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 for (pfn =3D range->base, zone =3D page_zone(pfn_to_page(pf=
n));
> + =A0 =A0 =A0 =A0 =A0 =A0pfn < range->end;
> + =A0 =A0 =A0 =A0 =A0 =A0pfn +=3D MAX_ORDER_NR_PAGES) {
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (zone !=3D page_zone(pfn_to_page(pfn)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 range->end =3D min(pfn, range->end);
> + =A0 =A0 =A0 return;

Unnecessary return.

> +}
> +
> +/*
> + * This function is for finding a contiguous memory block which has leng=
th
> + * of pages and MOVABLE. If it finds, make the range of pages as ISOLATE=
D
> + * and return the first page's pfn.
> + * If no_search=3D=3Dtrue, this function doesn't scan the range but trie=
s to
> + * isolate the range of memory.
> + */
> +
> +static unsigned long find_contig_block(unsigned long base,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long end, unsigned long pages, boo=
l no_search)
> +{
> + =A0 =A0 =A0 unsigned long pfn, pos;
> + =A0 =A0 =A0 struct page_range blockinfo;
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 pages =3D MAX_ORDER_ALIGN(pages);
> +retry:
> + =A0 =A0 =A0 blockinfo.base =3D base;
> + =A0 =A0 =A0 blockinfo.end =3D end;
> + =A0 =A0 =A0 blockinfo.pages =3D pages;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* At first, check physical page layout and skip memory h=
oles.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 ret =3D walk_system_ram_range(base, end - base, &blockinfo,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __get_contig_block);
> + =A0 =A0 =A0 if (!ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 /* check contiguous pages in a zone */
> + =A0 =A0 =A0 __trim_zone(&blockinfo);
> +
> +
> + =A0 =A0 =A0 /* Ok, we found contiguous memory chunk of size. Isolate it=
.*/
> + =A0 =A0 =A0 for (pfn =3D blockinfo.base; pfn + pages < blockinfo.end;
> + =A0 =A0 =A0 =A0 =A0 =A0pfn +=3D MAX_ORDER_NR_PAGES) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If no_search=3D=3Dtrue, base addess shou=
ld be same to 'base' */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (no_search && pfn !=3D base)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Better code is necessary here.. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (pos =3D pfn; pos < pfn + pages; pos++)=
 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *p;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pfn_valid_within(pos))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p =3D pfn_to_page(pos);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageReserved(p))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* This may hit a page on p=
er-cpu queue. */

Couldn't we drain per-cpu queue before this function?

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (page_count(p) && !PageL=
RU(p))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Need to skip order of pa=
ges */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pos !=3D pfn + pages) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pfn =3D MAX_ORDER_BASE(pos)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Now, we know [base,end) of a contiguou=
s chunk.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Don't need to take care of memory hole=
s.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!start_isolate_page_range(pfn, pfn + pa=
ges))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return pfn;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* failed */
> + =A0 =A0 =A0 if (!no_search && blockinfo.end + pages < end) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Move base address and find the next bloc=
k of RAM. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 base =3D blockinfo.end;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto retry;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return 0;
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
