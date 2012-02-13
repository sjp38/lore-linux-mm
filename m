Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 426946B13F0
	for <linux-mm@kvack.org>; Mon, 13 Feb 2012 13:58:00 -0500 (EST)
Received: by wgbdt12 with SMTP id dt12so4314734wgb.26
        for <linux-mm@kvack.org>; Mon, 13 Feb 2012 10:57:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1328895151-5196-13-git-send-email-m.szyprowski@samsung.com>
References: <1328895151-5196-1-git-send-email-m.szyprowski@samsung.com>
	<1328895151-5196-13-git-send-email-m.szyprowski@samsung.com>
Date: Mon, 13 Feb 2012 12:57:58 -0600
Message-ID: <CAOCHtYi01NVp1j=MX+0-z7ygW5tJuoswn8eWTQp+0Z5mMGdeQw@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCHv21 12/16] mm: trigger page reclaim in
 alloc_contig_range() to stabilise watermarks
From: Robert Nelson <robertcnelson@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Ohad Ben-Cohen <ohad@wizery.com>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Rob Clark <rob.clark@linaro.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri, Feb 10, 2012 at 11:32 AM, Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
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
> ---
> =A0include/linux/mmzone.h | =A0 =A09 +++++++
> =A0mm/page_alloc.c =A0 =A0 =A0 =A0| =A0 62 ++++++++++++++++++++++++++++++=
++++++++++++++++++
> =A02 files changed, 71 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 82f4fa5..6a6c2cc 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -63,8 +63,10 @@ enum {
>
> =A0#ifdef CONFIG_CMA
> =A0# =A0define is_migrate_cma(migratetype) unlikely((migratetype) =3D=3D =
MIGRATE_CMA)
> +# =A0define cma_wmark_pages(zone) =A0 =A0 =A0 =A0zone->min_cma_pages
> =A0#else
> =A0# =A0define is_migrate_cma(migratetype) false
> +# =A0define cma_wmark_pages(zone) 0
> =A0#endif
>
> =A0#define for_each_migratetype_order(order, type) \
> @@ -371,6 +373,13 @@ struct zone {
> =A0 =A0 =A0 =A0/* see spanned/present_pages for more description */
> =A0 =A0 =A0 =A0seqlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 span_seqlock;
> =A0#endif
> +#ifdef CONFIG_CMA
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* CMA needs to increase watermark levels during the allo=
cation
> + =A0 =A0 =A0 =A0* process to make sure that the system is not starved.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 unsigned long =A0 =A0 =A0 =A0 =A0 min_cma_pages;
> +#endif
> =A0 =A0 =A0 =A0struct free_area =A0 =A0 =A0 =A0free_area[MAX_ORDER];
>
> =A0#ifndef CONFIG_SPARSEMEM
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 793c4e4..2fedd36 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5035,6 +5035,11 @@ static void __setup_per_zone_wmarks(void)
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->watermark[WMARK_LOW] =A0=3D min_wmar=
k_pages(zone) + (tmp >> 2);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->watermark[WMARK_HIGH] =3D min_wmark_=
pages(zone) + (tmp >> 1);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->watermark[WMARK_MIN] +=3D cma_wmark_p=
ages(zone);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->watermark[WMARK_LOW] +=3D cma_wmark_p=
ages(zone);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->watermark[WMARK_HIGH] +=3D cma_wmark_=
pages(zone);
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0setup_zone_migrate_reserve(zone);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_irqrestore(&zone->lock, flags)=
;
> =A0 =A0 =A0 =A0}
> @@ -5637,6 +5642,56 @@ static int __alloc_contig_migrate_range(unsigned l=
ong start, unsigned long end)
> =A0 =A0 =A0 =A0return ret > 0 ? 0 : ret;
> =A0}
>
> +/*
> + * Update zone's cma pages counter used for watermark level calculation.
> + */
> +static inline void __update_cma_wmark_pages(struct zone *zone, int count=
)
> +{
> + =A0 =A0 =A0 unsigned long flags;
> + =A0 =A0 =A0 spin_lock_irqsave(&zone->lock, flags);
> + =A0 =A0 =A0 zone->min_cma_pages +=3D count;
> + =A0 =A0 =A0 spin_unlock_irqrestore(&zone->lock, flags);
> + =A0 =A0 =A0 setup_per_zone_wmarks();
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
> + =A0 =A0 =A0 enum zone_type high_zoneidx =3D gfp_zone(gfp_mask);
> + =A0 =A0 =A0 struct zonelist *zonelist =3D node_zonelist(0, gfp_mask);
> + =A0 =A0 =A0 int did_some_progress =3D 0;
> + =A0 =A0 =A0 int order =3D 1;
> + =A0 =A0 =A0 unsigned long watermark;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Increase level of watermarks to force kswapd do his jo=
b
> + =A0 =A0 =A0 =A0* to stabilise at new watermark level.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 __modify_min_cma_pages(zone, count);

Hi Marek,   This ^^^ function doesn't seem to exist in this patchset,
is it in another set posted to lkml?

While (build error)testing this patchset on v3.3-rc3 with the
beagle/panda omapdrm driver..

mm/page_alloc.c: In function =91__reclaim_pages=92:
mm/page_alloc.c:5674:2: error: implicit declaration of function
=91__modify_min_cma_pages=92 [-Werror=3Dimplicit-function-declaration]
cc1: some warnings being treated as errors

make[1]: *** [mm/page_alloc.o] Error 1
make: *** [mm] Error 2
make: *** Waiting for unfinished jobs....

:/KERNEL$ grep -R "modify_min_cma_pages" ./*
./mm/page_alloc.c:      __modify_min_cma_pages(zone, count);
./mm/page_alloc.c:      __modify_min_cma_pages(zone, -count);

Regards,

--=20
Robert Nelson
http://www.rcn-ee.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
