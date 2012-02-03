Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 7D61E6B13F4
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 09:19:56 -0500 (EST)
Received: by wgbdt12 with SMTP id dt12so3276348wgb.26
        for <linux-mm@kvack.org>; Fri, 03 Feb 2012 06:19:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1328271538-14502-9-git-send-email-m.szyprowski@samsung.com>
References: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
	<1328271538-14502-9-git-send-email-m.szyprowski@samsung.com>
Date: Fri, 3 Feb 2012 22:19:54 +0800
Message-ID: <CAJd=RBByc_wLEJTK66J4eY03CWnCoCRiwAeEYjXCZ5xEZhp3ag@mail.gmail.com>
Subject: Re: [PATCH 08/15] mm: mmzone: MIGRATE_CMA migration type added
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hello Marek

On Fri, Feb 3, 2012 at 8:18 PM, Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
> From: Michal Nazarewicz <mina86@mina86.com>
>
> The MIGRATE_CMA migration type has two main characteristics:
> (i) only movable pages can be allocated from MIGRATE_CMA
> pageblocks and (ii) page allocator will never change migration
> type of MIGRATE_CMA pageblocks.
>
> This guarantees (to some degree) that page in a MIGRATE_CMA page
> block can always be migrated somewhere else (unless there's no
> memory left in the system).
>
> It is designed to be used for allocating big chunks (eg. 10MiB)
> of physically contiguous memory. =C2=A0Once driver requests
> contiguous memory, pages from MIGRATE_CMA pageblocks may be
> migrated away to create a contiguous block.
>
> To minimise number of migrations, MIGRATE_CMA migration type
> is the last type tried when page allocator falls back to other
> migration types then requested.
>
> Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> Tested-by: Rob Clark <rob.clark@linaro.org>
> Tested-by: Ohad Ben-Cohen <ohad@wizery.com>
> Tested-by: Benjamin Gaignard <benjamin.gaignard@linaro.org>
> ---
> =C2=A0include/linux/gfp.h =C2=A0 =C2=A0| =C2=A0 =C2=A03 ++
> =C2=A0include/linux/mmzone.h | =C2=A0 38 +++++++++++++++++++----
> =C2=A0mm/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=
=A02 +-
> =C2=A0mm/compaction.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 11 +++++--
> =C2=A0mm/page_alloc.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 78 ++++++++++++=
++++++++++++++++++++++++++----------
> =C2=A0mm/vmstat.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=
=A03 ++
> =C2=A06 files changed, 108 insertions(+), 27 deletions(-)
>
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 052a5b6..78d32a7 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -397,6 +397,9 @@ static inline bool pm_suspended_storage(void)
> =C2=A0extern int alloc_contig_range(unsigned long start, unsigned long en=
d);
> =C2=A0extern void free_contig_range(unsigned long pfn, unsigned nr_pages)=
;
>
> +/* CMA stuff */
> +extern void init_cma_reserved_pageblock(struct page *page);
> +
> =C2=A0#endif
>
> =C2=A0#endif /* __LINUX_GFP_H */
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 650ba2f..82f4fa5 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -35,13 +35,37 @@
> =C2=A0*/
> =C2=A0#define PAGE_ALLOC_COSTLY_ORDER 3
>
> -#define MIGRATE_UNMOVABLE =C2=A0 =C2=A0 0
> -#define MIGRATE_RECLAIMABLE =C2=A0 1
> -#define MIGRATE_MOVABLE =C2=A0 =C2=A0 =C2=A0 2
> -#define MIGRATE_PCPTYPES =C2=A0 =C2=A0 =C2=A03 /* the number of types on=
 the pcp lists */
> -#define MIGRATE_RESERVE =C2=A0 =C2=A0 =C2=A0 3
> -#define MIGRATE_ISOLATE =C2=A0 =C2=A0 =C2=A0 4 /* can't allocate from he=
re */
> -#define MIGRATE_TYPES =C2=A0 =C2=A0 =C2=A0 =C2=A0 5
> +enum {
> + =C2=A0 =C2=A0 =C2=A0 MIGRATE_UNMOVABLE,
> + =C2=A0 =C2=A0 =C2=A0 MIGRATE_RECLAIMABLE,
> + =C2=A0 =C2=A0 =C2=A0 MIGRATE_MOVABLE,
> + =C2=A0 =C2=A0 =C2=A0 MIGRATE_PCPTYPES, =C2=A0 =C2=A0 =C2=A0 /* the numb=
er of types on the pcp lists */
> + =C2=A0 =C2=A0 =C2=A0 MIGRATE_RESERVE =3D MIGRATE_PCPTYPES,
> +#ifdef CONFIG_CMA
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* MIGRATE_CMA migration type is designed to =
mimic the way
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* ZONE_MOVABLE works. =C2=A0Only movable pag=
es can be allocated
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* from MIGRATE_CMA pageblocks and page alloc=
ator never
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* implicitly change migration type of MIGRAT=
E_CMA pageblock.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* The way to use it is to change migratetype=
 of a range of
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* pageblocks to MIGRATE_CMA which can be don=
e by
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* __free_pageblock_cma() function. =C2=A0Wha=
t is important though
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* is that a range of pageblocks must be alig=
ned to
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* MAX_ORDER_NR_PAGES should biggest page be =
bigger then
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* a single pageblock.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 MIGRATE_CMA,
> +#endif
> + =C2=A0 =C2=A0 =C2=A0 MIGRATE_ISOLATE, =C2=A0 =C2=A0 =C2=A0 =C2=A0/* can=
't allocate from here */
> + =C2=A0 =C2=A0 =C2=A0 MIGRATE_TYPES
> +};
> +
> +#ifdef CONFIG_CMA
> +# =C2=A0define is_migrate_cma(migratetype) unlikely((migratetype) =3D=3D=
 MIGRATE_CMA)
> +#else
> +# =C2=A0define is_migrate_cma(migratetype) false
> +#endif
>
> =C2=A0#define for_each_migratetype_order(order, type) \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (order =3D 0; order < MAX_ORDER; order++) =
\
> diff --git a/mm/Kconfig b/mm/Kconfig
> index e338407..3922002 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -198,7 +198,7 @@ config COMPACTION
> =C2=A0config MIGRATION
> =C2=A0 =C2=A0 =C2=A0 =C2=A0bool "Page migration"
> =C2=A0 =C2=A0 =C2=A0 =C2=A0def_bool y
> - =C2=A0 =C2=A0 =C2=A0 depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE ||=
 COMPACTION
> + =C2=A0 =C2=A0 =C2=A0 depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE ||=
 COMPACTION || CMA
> =C2=A0 =C2=A0 =C2=A0 =C2=A0help
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Allows the migration of the physical lo=
cation of pages of processes
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0while the virtual addresses are not cha=
nged. This is useful in
> diff --git a/mm/compaction.c b/mm/compaction.c
> index d5174c4..a6e7c64 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -45,6 +45,11 @@ static void map_pages(struct list_head *list)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0}
>
> +static inline bool migrate_async_suitable(int migratetype)

Just nitpick, since the helper is not directly related to what async means,
how about migrate_suitable(int migrate_type) ?

> +{
> + =C2=A0 =C2=A0 =C2=A0 return is_migrate_cma(migratetype) || migratetype =
=3D=3D MIGRATE_MOVABLE;
> +}
> +
> =C2=A0/*
> =C2=A0* Isolate free pages onto a private freelist. Caller must hold zone=
->lock.
> =C2=A0* If @strict is true, will abort returning 0 on any invalid PFNs or=
 non-free
> @@ -277,7 +282,7 @@ isolate_migratepages_range(struct zone *zone, struct =
compact_control *cc,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pageblock_nr =3D l=
ow_pfn >> pageblock_order;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!cc->sync && l=
ast_pageblock_nr !=3D pageblock_nr &&
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 get_pageblock_migratetype(page) !=3D MIG=
RATE_MOVABLE) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 migrate_=
async_suitable(get_pageblock_migratetype(page))) {

Here compaction looks corrupted if CMA not enabled, Mel?

btw, Kame-san is not Cced correctly 8;/

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
