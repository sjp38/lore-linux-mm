Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 175EA6B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 04:49:11 -0500 (EST)
Received: by bkwq16 with SMTP id q16so133546bkw.14
        for <linux-mm@kvack.org>; Wed, 29 Feb 2012 01:49:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1329929337-16648-13-git-send-email-m.szyprowski@samsung.com>
References: <1329929337-16648-1-git-send-email-m.szyprowski@samsung.com> <1329929337-16648-13-git-send-email-m.szyprowski@samsung.com>
From: Barry Song <21cnbao@gmail.com>
Date: Wed, 29 Feb 2012 17:48:49 +0800
Message-ID: <CAGsJ_4z_TR_UKhjxg-rzATodKJoNn2R-17KkqbeC-fLh3dK3sQ@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCHv23 12/16] mm: trigger page reclaim in
 alloc_contig_range() to stabilise watermarks
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Ohad Ben-Cohen <ohad@wizery.com>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Rob Clark <rob.clark@linaro.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

2012/2/23 Marek Szyprowski <m.szyprowski@samsung.com>:
> alloc_contig_range() performs memory allocation so it also should keep
> track on keeping the correct level of memory watermarks. This commit adds
> a call to *_slowpath style reclaim to grab enough pages to make sure that
> the final collection of contiguous pages from freelists will not starve
> the system.
>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> CC: Michal Nazarewicz <mina86@mina86.com>
> Tested-by: Rob Clark <rob.clark@linaro.org>
> Tested-by: Ohad Ben-Cohen <ohad@wizery.com>
> Tested-by: Benjamin Gaignard <benjamin.gaignard@linaro.org>
> Tested-by: Robert Nelson <robertcnelson@gmail.com>
> ---
> =C2=A0include/linux/mmzone.h | =C2=A0 =C2=A09 +++++++
> =C2=A0mm/page_alloc.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 62 ++++++++++++=
++++++++++++++++++++++++++++++++++++
> =C2=A02 files changed, 71 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 4781f30..77db8c0 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -63,8 +63,10 @@ enum {
>
> =C2=A0#ifdef CONFIG_CMA
> =C2=A0# =C2=A0define is_migrate_cma(migratetype) unlikely((migratetype) =
=3D=3D MIGRATE_CMA)
> +# =C2=A0define cma_wmark_pages(zone) =C2=A0 =C2=A0 =C2=A0 =C2=A0zone->mi=
n_cma_pages
> =C2=A0#else
> =C2=A0# =C2=A0define is_migrate_cma(migratetype) false
> +# =C2=A0define cma_wmark_pages(zone) 0
> =C2=A0#endif
>
> =C2=A0#define for_each_migratetype_order(order, type) \
> @@ -371,6 +373,13 @@ struct zone {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* see spanned/present_pages for more descript=
ion */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0seqlock_t =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 span_seqlock;
> =C2=A0#endif
> +#ifdef CONFIG_CMA
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* CMA needs to increase watermark levels dur=
ing the allocation
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* process to make sure that the system is no=
t starved.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 unsigned long =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 m=
in_cma_pages;
> +#endif
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct free_area =C2=A0 =C2=A0 =C2=A0 =C2=A0fr=
ee_area[MAX_ORDER];
>
> =C2=A0#ifndef CONFIG_SPARSEMEM
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7a0d286..39cd74f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5092,6 +5092,11 @@ static void __setup_per_zone_wmarks(void)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0low + (mi=
n >> 2);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone->watermark[WM=
ARK_HIGH] =3D min_wmark_pages(zone) +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0low + (mi=
n >> 1);
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone->watermark[WMARK_=
MIN] +=3D cma_wmark_pages(zone);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone->watermark[WMARK_=
LOW] +=3D cma_wmark_pages(zone);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone->watermark[WMARK_=
HIGH] +=3D cma_wmark_pages(zone);
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0setup_zone_migrate=
_reserve(zone);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irqres=
tore(&zone->lock, flags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> @@ -5695,6 +5700,56 @@ static int __alloc_contig_migrate_range(unsigned l=
ong start, unsigned long end)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret > 0 ? 0 : ret;
> =C2=A0}
>
> +/*
> + * Update zone's cma pages counter used for watermark level calculation.
> + */
> +static inline void __update_cma_watermarks(struct zone *zone, int count)
> +{
> + =C2=A0 =C2=A0 =C2=A0 unsigned long flags;
> + =C2=A0 =C2=A0 =C2=A0 spin_lock_irqsave(&zone->lock, flags);
> + =C2=A0 =C2=A0 =C2=A0 zone->min_cma_pages +=3D count;
> + =C2=A0 =C2=A0 =C2=A0 spin_unlock_irqrestore(&zone->lock, flags);
> + =C2=A0 =C2=A0 =C2=A0 setup_per_zone_wmarks();
> +}
> +
> +/*
> + * Trigger memory pressure bump to reclaim some pages in order to be abl=
e to
> + * allocate 'count' pages in single page units. Does similar work as
> + *__alloc_pages_slowpath() function.
> + */
> +static int __reclaim_pages(struct zone *zone, gfp_t gfp_mask, int count)
> +{
> + =C2=A0 =C2=A0 =C2=A0 enum zone_type high_zoneidx =3D gfp_zone(gfp_mask)=
;
> + =C2=A0 =C2=A0 =C2=A0 struct zonelist *zonelist =3D node_zonelist(0, gfp=
_mask);
> + =C2=A0 =C2=A0 =C2=A0 int did_some_progress =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 int order =3D 1;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long watermark;
> +
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Increase level of watermarks to force kswa=
pd do his job
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* to stabilise at new watermark level.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 __update_cma_watermarks(zone, count);
> +
> + =C2=A0 =C2=A0 =C2=A0 /* Obey watermarks as if the page was being alloca=
ted */
> + =C2=A0 =C2=A0 =C2=A0 watermark =3D low_wmark_pages(zone) + count;
> + =C2=A0 =C2=A0 =C2=A0 while (!zone_watermark_ok(zone, 0, watermark, 0, 0=
)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 wake_all_kswapd(order,=
 zonelist, high_zoneidx, zone_idx(zone));
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 did_some_progress =3D =
__perform_reclaim(gfp_mask, order, zonelist,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 NULL);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!did_some_progress=
) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /* Exhausted what can be done so it's blamo time */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 out_of_memory(zonelist, gfp_mask, order, NULL);

out_of_memory() has got another param in the newest next/master tree,
out_of_memory(zonelist, gfp_mask, order, NULL, false) should be OK.

-barry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
