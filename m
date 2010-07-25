Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E1C116B024D
	for <linux-mm@kvack.org>; Sun, 25 Jul 2010 16:23:46 -0400 (EDT)
From: =?iso-8859-1?Q?Penttil=E4_Mika?= <mika.penttila@ixonos.com>
Subject: RE: [PATCH] Tight check of pfn_valid on sparsemem - v3
Date: Sun, 25 Jul 2010 20:22:51 +0000
Message-ID: <1A61D8EA6755AF458F06EA669A4EC818013896@JKLMAIL02.ixonos.local>
References: <1A61D8EA6755AF458F06EA669A4EC81801387C@JKLMAIL02.ixonos.local>
In-Reply-To: <1A61D8EA6755AF458F06EA669A4EC81801387C@JKLMAIL02.ixonos.local>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "minchan.kim@gmail.com" <minchan.kim@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Changelog since v2
>  o Change some function names
>  o Remove mark_memmap_hole in memmap bring up
>  o Change CONFIG_SPARSEMEM with CONFIG_ARCH_HAS_HOLES_MEMORYMODEL
>=20
> I have a plan following as after this patch is acked.
>=20
> TODO:
> 1) expand pfn_valid to FALTMEM in ARM
> I think we can enhance pfn_valid of FLATMEM in ARM.
> Now it is doing binary search and it's expesive.
> First of all, After we merge this patch, I expand it to FALTMEM of ARM.
>=20
> 2) remove memmap_valid_within
> We can remove memmap_valid_within by strict pfn_valid's tight check.
>=20
> 3) Optimize hole check in sparsemem
> In case of spasemem, we can optimize pfn_valid through defining new
> flag
> like SECTION_HAS_HOLE of hole mem_section.
>=20
> =3D=3D CUT HERE =3D=3D
>=20
> Kukjin reported oops happen while he change min_free_kbytes
> http://www.spinics.net/lists/arm-kernel/msg92894.html
> It happen by memory map on sparsemem.
>=20
> The system has a memory map following as.
>      section 0             section 1              section 2
> 0x20000000-0x25000000, 0x40000000-0x50000000, 0x50000000-0x58000000
> SECTION_SIZE_BITS 28(256M)
>=20
> It means section 0 is an incompletely filled section.
> Nontheless, current pfn_valid of sparsemem checks pfn loosely.
> It checks only mem_section's validation but ARM can free mem_map on
> hole
> to save memory space. So in above case, pfn on 0x25000000 can pass
> pfn_valid's
> validation check. It's not what we want.
>=20
> We can match section size to smallest valid size.(ex, above case, 16M)
> But Russell doesn't like it due to mem_section's memory overhead with
> different
> configuration(ex, 512K section).
>=20
> I tried to add valid pfn range in mem_section but everyone doesn't like
> it
> due to size overhead. This patch is suggested by KAMEZAWA-san.
> I just fixed compile error and change some naming.
>=20
> This patch registers address of mem_section to memmap itself's page
> struct's
> pg->private field. This means the page is used for memmap of the
> section.
> Otherwise, the page is used for other purpose and memmap has a hole.
>=20
> This patch is based on mmotm-2010-07-19
>=20
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reported-by: Kukjin Kim <kgene.kim@samsung.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Russell King <linux@arm.linux.org.uk>
> ---
>  arch/arm/mm/init.c                  |    4 +++-
>  include/linux/mmzone.h              |   22 +++++++++++++++++++++-
>  mm/mmzone.c                         |   34
> ++++++++++++++++++++++++++++++++++
>  5 files changed, 58 insertions(+), 2 deletions(-)
>=20
> diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
> index f6a9994..25e2670 100644
> --- a/arch/arm/mm/init.c
> +++ b/arch/arm/mm/init.c
> @@ -482,8 +482,10 @@ free_memmap(int node, unsigned long start_pfn,
> unsigned long end_pfn)
>  	 * If there are free pages between these,
>  	 * free the section of the memmap array.
>  	 */
> -	if (pg < pgend)
> +	if (pg < pgend) {
> + 		mark_invalid_memmap(pg >> PAGE_SHIFT, pgend >> PAGE_SHIFT);
>  		free_bootmem_node(NODE_DATA(node), pg, pgend - pg);
> +	}
>  }
>=20
>  /*
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index b4d109e..a3195bd 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -15,6 +15,7 @@
>  #include <linux/seqlock.h>
>  #include <linux/nodemask.h>
>  #include <linux/pageblock-flags.h>
> +#include <linux/mm_types.h>
>  #include <generated/bounds.h>
>  #include <asm/atomic.h>
>  #include <asm/page.h>
> @@ -1049,11 +1050,30 @@ static inline struct mem_section
> *__pfn_to_section(unsigned long pfn)
>  	return __nr_to_section(pfn_to_section_nr(pfn));
>  }
>=20
> +void mark_invalid_memmap(unsigned long start, unsigned long end);
> +
> +#ifdef CONFIG_ARCH_HAS_HOLES_MEMORYMODEL
> +#define MEMMAP_HOLE	(0x1UL)
> +static inline int memmap_valid(unsigned long pfn)
> +{
> +	struct page *page =3D pfn_to_page(pfn);
> +	struct page *__pg =3D virt_to_page(page);
> +	return !(__pg->private & MEMMAP_HOLE);
> +}
> +#else
> +static inline int memmap_valid(unsigned long pfn)
> +{
> +	return 1;
> +}
> +#endif
> +
>  static inline int pfn_valid(unsigned long pfn)
>  {
> +	struct mem_section *ms;
>  	if (pfn_to_section_nr(pfn) >=3D NR_MEM_SECTIONS)
>  		return 0;
> -	return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
> +	ms =3D __nr_to_section(pfn_to_section_nr(pfn));
> +	return valid_section(ms) && memmap_valid(pfn);
>  }
>=20
>  static inline int pfn_present(unsigned long pfn)
> diff --git a/mm/mmzone.c b/mm/mmzone.c
> index f5b7d17..7c84e5e 100644
> --- a/mm/mmzone.c
> +++ b/mm/mmzone.c
> @@ -86,4 +86,38 @@ int memmap_valid_within(unsigned long pfn,
>=20
>  	return 1;
>  }
> +
> +/*
> + * Fill pg->private on hole memmap with MEMMAP_HOLE.
> + * pfn_valid() will check this later. (see include/linux/mmzone.h)
> + * Evenry arch should call
> + * 	mark_invalid_memmap(start, end) # for all holes in mem_map.
> + * please see usage in ARM.
> + */
> +void mark_invalid_memmap(unsigned long start, unsigned long end)
> +{
> +	struct mem_section *ms;
> +	unsigned long pos, next;
> +	struct page *pg;
> +	void *memmap, *mapend;
> +
> +	for (pos =3D start; pos < end; pos =3D next) {
> +		next =3D (pos + PAGES_PER_SECTION) & PAGE_SECTION_MASK;
> +		ms =3D __pfn_to_section(pos);
> +		if (!valid_section(ms))
> +			continue;
> +
> +		for (memmap =3D (void*)pfn_to_page(pos),
> +			/* The last page in section */
> +			mapend =3D pfn_to_page(next-1);
> +			memmap < mapend; memmap +=3D PAGE_SIZE) {
> +			pg =3D virt_to_page(memmap);
> +			pg->private =3D MEMMAP_HOLE;
> +		}
> +	}
> +}
> +#else
> +void mark_invalid_memmap(unsigned long start, unsigned long end)
> +{
> +}
>  #endif /* CONFIG_ARCH_HAS_HOLES_MEMORYMODEL */
> --



I don't think this works because if the memmap pages get reused, the corres=
ponding struct page->private could be used by chance in such a way that it =
has the value of MEMMAP_HOLE. Of course unlikely but possible. And after al=
l the whole point of freeing part of the memmap is that it could be reused.

--Mika



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
