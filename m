Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6FC4D6007F3
	for <linux-mm@kvack.org>; Sun, 18 Jul 2010 07:53:27 -0400 (EDT)
Received: by pxi7 with SMTP id 7so1791719pxi.14
        for <linux-mm@kvack.org>; Sun, 18 Jul 2010 04:53:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1279448311-29788-1-git-send-email-minchan.kim@gmail.com>
References: <1279448311-29788-1-git-send-email-minchan.kim@gmail.com>
Date: Sun, 18 Jul 2010 20:53:25 +0900
Message-ID: <AANLkTilQf-43GMAIDa-MKmcB2afdVgkERMg0b5mhIbhE@mail.gmail.com>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v2
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>, Kukjin Kim <kgene.kim@samsung.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
List-ID: <linux-mm.kvack.org>

Hi Minchan,

Please see the OneDRAM spec. it's OneDRAM memory usage.
Actually memory size is 80MiB + 16MiB at AP side and it's used 80MiB
for dedicated AP.
The shared 16MiB used between AP and CP. So we also use the 16MiB.

Thank you,
Kyungmin Park

On Sun, Jul 18, 2010 at 7:18 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> Kukjin reported oops happen while he change min_free_kbytes
> http://www.spinics.net/lists/arm-kernel/msg92894.html
> It happen by memory map on sparsemem.
>
> The system has a memory map following as.
> =A0 =A0 section 0 =A0 =A0 =A0 =A0 =A0 =A0 section 1 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0section 2
> 0x20000000-0x25000000, 0x40000000-0x50000000, 0x50000000-0x58000000
> SECTION_SIZE_BITS 28(256M)
>
> It means section 0 is an incompletely filled section.
> Nontheless, current pfn_valid of sparsemem checks pfn loosely.
> It checks only mem_section's validation but ARM can free mem_map on hole
> to save memory space. So in above case, pfn on 0x25000000 can pass pfn_va=
lid's
> validation check. It's not what we want.
>
> We can match section size to smallest valid size.(ex, above case, 16M)
> But Russell doesn't like it due to mem_section's memory overhead with dif=
ferent
> configuration(ex, 512K section).
>
> I tried to add valid pfn range in mem_section but everyone doesn't like i=
t
> due to size overhead. This patch is suggested by KAMEZAWA-san.
> I just fixed compile error and change some naming.
>
> This patch registers address of mem_section to memmap itself's page struc=
t's
> pg->private field. This means the page is used for memmap of the section.
> Otherwise, the page is used for other purpose and memmap has a hole.
>
> This patch is based on mmotm-2010-07-01-12-19.
>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reported-by: Kukjin Kim <kgene.kim@samsung.com>
> ---
> =A0arch/arm/mm/init.c =A0 =A0 | =A0 =A09 ++++++++-
> =A0include/linux/mmzone.h | =A0 21 ++++++++++++++++++++-
> =A0mm/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A05 +++++
> =A0mm/sparse.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 41 ++++++++++++++++++++++++++=
+++++++++++++++
> =A04 files changed, 74 insertions(+), 2 deletions(-)
>
> diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
> index cfe4c5e..4586f40 100644
> --- a/arch/arm/mm/init.c
> +++ b/arch/arm/mm/init.c
> @@ -234,6 +234,11 @@ static void __init arm_bootmem_free(struct meminfo *=
mi)
> =A0 =A0 =A0 =A0arch_adjust_zones(zone_size, zhole_size);
>
> =A0 =A0 =A0 =A0free_area_init_node(0, zone_size, min, zhole_size);
> +
> + =A0 =A0 =A0 for_each_bank(i, mi) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mark_memmap_hole(bank_pfn_start(&mi->bank[i=
]),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bank_pfn_en=
d(&mi->bank[i]), true);
> + =A0 =A0 =A0 }
> =A0}
>
> =A0#ifndef CONFIG_SPARSEMEM
> @@ -386,8 +391,10 @@ free_memmap(unsigned long start_pfn, unsigned long e=
nd_pfn)
> =A0 =A0 =A0 =A0 * If there are free pages between these,
> =A0 =A0 =A0 =A0 * free the section of the memmap array.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 if (pg < pgend)
> + =A0 =A0 =A0 if (pg < pgend) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mark_memmap_hole(pg >> PAGE_SHIFT, pgend >>=
 PAGE_SHIFT, false);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0free_bootmem(pg, pgend - pg);
> + =A0 =A0 =A0 }
> =A0}
>
> =A0/*
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 9ed9c45..2ed9728 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -15,6 +15,7 @@
> =A0#include <linux/seqlock.h>
> =A0#include <linux/nodemask.h>
> =A0#include <linux/pageblock-flags.h>
> +#include <linux/mm_types.h>
> =A0#include <generated/bounds.h>
> =A0#include <asm/atomic.h>
> =A0#include <asm/page.h>
> @@ -1047,11 +1048,29 @@ static inline struct mem_section *__pfn_to_sectio=
n(unsigned long pfn)
> =A0 =A0 =A0 =A0return __nr_to_section(pfn_to_section_nr(pfn));
> =A0}
>
> +void mark_memmap_hole(unsigned long start, unsigned long end, bool valid=
);
> +
> +#ifdef CONFIG_SPARSEMEM_HAS_HOLE
> +static inline int page_valid(struct mem_section *ms, unsigned long pfn)
> +{
> + =A0 =A0 =A0 struct page *page =3D pfn_to_page(pfn);
> + =A0 =A0 =A0 struct page *__pg =3D virt_to_page(page);
> + =A0 =A0 =A0 return __pg->private =3D=3D (unsigned long)ms;
> +}
> +#else
> +static inline int page_valid(struct mem_section *ms, unsigned long pfn)
> +{
> + =A0 =A0 =A0 return 1;
> +}
> +#endif
> +
> =A0static inline int pfn_valid(unsigned long pfn)
> =A0{
> + =A0 =A0 =A0 struct mem_section *ms;
> =A0 =A0 =A0 =A0if (pfn_to_section_nr(pfn) >=3D NR_MEM_SECTIONS)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
> - =A0 =A0 =A0 return valid_section(__nr_to_section(pfn_to_section_nr(pfn)=
));
> + =A0 =A0 =A0 ms =3D __nr_to_section(pfn_to_section_nr(pfn));
> + =A0 =A0 =A0 return valid_section(ms) && page_valid(ms, pfn);
> =A0}
>
> =A0static inline int pfn_present(unsigned long pfn)
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 527136b..959ac1d 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -128,6 +128,11 @@ config SPARSEMEM_VMEMMAP
> =A0 =A0 =A0 =A0 pfn_to_page and page_to_pfn operations. =A0This is the mo=
st
> =A0 =A0 =A0 =A0 efficient option when sufficient kernel resources are ava=
ilable.
>
> +config SPARSEMEM_HAS_HOLE
> + =A0 =A0 =A0 bool "allow holes in sparsemem's memmap"
> + =A0 =A0 =A0 depends on ARM && SPARSEMEM && !SPARSEMEM_VMEMMAP
> + =A0 =A0 =A0 default n
> +
> =A0# eventually, we can have this option just 'select SPARSEMEM'
> =A0config MEMORY_HOTPLUG
> =A0 =A0 =A0 =A0bool "Allow for memory hot-add"
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 95ac219..76d5012 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -615,6 +615,47 @@ void __init sparse_init(void)
> =A0 =A0 =A0 =A0free_bootmem(__pa(usemap_map), size);
> =A0}
>
> +#ifdef CONFIG_SPARSEMEM_HAS_HOLE
> +/*
> + * Fill memmap's pg->private with a pointer to mem_section.
> + * pfn_valid() will check this later. (see include/linux/mmzone.h)
> + * Evenry arch should call
> + * =A0 =A0 mark_memmap_hole(start, end, true) # for all allocated mem_ma=
p
> + * =A0 =A0 and, after that,
> + * =A0 =A0 mark_memmap_hole(start, end, false) # for all holes in mem_ma=
p.
> + * please see usage in ARM.
> + */
> +void mark_memmap_hole(unsigned long start, unsigned long end, bool valid=
)
> +{
> + =A0 =A0 =A0 struct mem_section *ms;
> + =A0 =A0 =A0 unsigned long pos, next;
> + =A0 =A0 =A0 struct page *pg;
> + =A0 =A0 =A0 void *memmap, *mapend;
> +
> + =A0 =A0 =A0 for (pos =3D start; pos < end; pos =3D next) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 next =3D (pos + PAGES_PER_SECTION) & PAGE_S=
ECTION_MASK;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ms =3D __pfn_to_section(pos);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!valid_section(ms))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (memmap =3D (void*)pfn_to_page(pos),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* The last page in section=
 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mapend =3D pfn_to_page(next=
-1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memmap < mapend; memmap +=
=3D PAGE_SIZE) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pg =3D virt_to_page(memmap)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (valid)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pg->private=
 =3D (unsigned long)ms;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pg->private=
 =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +}
> +#else
> +void mark_memmap_hole(unsigned long start, unsigned long end, bool valid=
)
> +{
> +}
> +#endif
> +
> =A0#ifdef CONFIG_MEMORY_HOTPLUG
> =A0#ifdef CONFIG_SPARSEMEM_VMEMMAP
> =A0static inline struct page *kmalloc_section_memmap(unsigned long pnum, =
int nid,
> --
> 1.7.0.5
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
