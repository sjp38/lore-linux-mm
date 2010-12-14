Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A2F906B0093
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 06:02:49 -0500 (EST)
Received: by iwn40 with SMTP id 40so654224iwn.14
        for <linux-mm@kvack.org>; Tue, 14 Dec 2010 03:02:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101210143112.29934.22944.stgit@localhost6.localdomain6>
References: <20101210142745.29934.29186.stgit@localhost6.localdomain6>
	<20101210143112.29934.22944.stgit@localhost6.localdomain6>
Date: Tue, 14 Dec 2010 20:02:45 +0900
Message-ID: <AANLkTinaTUUfvK+Nc-Whck21r-OzT+0CFVnS4W_jG5aw@mail.gmail.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages (v2)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Fri, Dec 10, 2010 at 11:32 PM, Balbir Singh
<balbir@linux.vnet.ibm.com> wrote:
> Changelog v2
> 1. Use a config option to enable the code (Andrew Morton)
> 2. Explain the magic tunables in the code or at-least attempt
> =A0 to explain them (General comment)
> 3. Hint uses of the boot parameter with unlikely (Andrew Morton)
> 4. Use better names (balanced is not a good naming convention)
> 5. Updated Documentation/kernel-parameters.txt (Andrew Morton)
>
> Provide control using zone_reclaim() and a boot parameter. The
> code reuses functionality from zone_reclaim() to isolate unmapped
> pages and reclaim them as a priority, ahead of other mapped pages.
>
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> =A0Documentation/kernel-parameters.txt | =A0 =A08 +++
> =A0include/linux/swap.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 21 ++++++--
> =A0init/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 12 +=
+++
> =A0kernel/sysctl.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +
> =A0mm/page_alloc.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A09 +++
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 97 +=
++++++++++++++++++++++++++++++++++
> =A06 files changed, 142 insertions(+), 7 deletions(-)
>
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-p=
arameters.txt
> index dd8fe2b..f52b0bd 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -2515,6 +2515,14 @@ and is between 256 and 4096 characters. It is defi=
ned in the file
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0[X86]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Set unknown_nmi_panic=3D1 =
early on boot.
>
> + =A0 =A0 =A0 unmapped_page_control
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 [KNL] Available if CONFIG_U=
NMAPPED_PAGECACHE_CONTROL
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 is enabled. It controls the=
 amount of unmapped memory
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 that is present in the syst=
em. This boot option plus
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vm.min_unmapped_ratio (sysc=
tl) provide granular control
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 over how much unmapped page=
 cache can exist in the system
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 before kswapd starts reclai=
ming unmapped page cache pages.
> +
> =A0 =A0 =A0 =A0usbcore.autosuspend=3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0[USB] The autosuspend time=
 delay (in seconds) used
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for newly-detected USB dev=
ices (default 2). =A0This
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index ac5c06e..773d7e5 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -253,19 +253,32 @@ extern int vm_swappiness;
> =A0extern int remove_mapping(struct address_space *mapping, struct page *=
page);
> =A0extern long vm_total_pages;
>
> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL) || defined(CONFIG_NUMA)
> =A0extern int sysctl_min_unmapped_ratio;
> =A0extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
> -#ifdef CONFIG_NUMA
> -extern int zone_reclaim_mode;
> -extern int sysctl_min_slab_ratio;
> =A0#else
> -#define zone_reclaim_mode 0
> =A0static inline int zone_reclaim(struct zone *z, gfp_t mask, unsigned in=
t order)
> =A0{
> =A0 =A0 =A0 =A0return 0;
> =A0}
> =A0#endif
>
> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
> +extern bool should_reclaim_unmapped_pages(struct zone *zone);
> +#else
> +static inline bool should_reclaim_unmapped_pages(struct zone *zone)
> +{
> + =A0 =A0 =A0 return false;
> +}
> +#endif
> +
> +#ifdef CONFIG_NUMA
> +extern int zone_reclaim_mode;
> +extern int sysctl_min_slab_ratio;
> +#else
> +#define zone_reclaim_mode 0
> +#endif
> +
> =A0extern int page_evictable(struct page *page, struct vm_area_struct *vm=
a);
> =A0extern void scan_mapping_unevictable_pages(struct address_space *);
>
> diff --git a/init/Kconfig b/init/Kconfig
> index 3eb22ad..78c9169 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -782,6 +782,18 @@ endif # NAMESPACES
> =A0config MM_OWNER
> =A0 =A0 =A0 =A0bool
>
> +config UNMAPPED_PAGECACHE_CONTROL
> + =A0 =A0 =A0 bool "Provide control over unmapped page cache"
> + =A0 =A0 =A0 default n
> + =A0 =A0 =A0 help
> + =A0 =A0 =A0 =A0 This option adds support for controlling unmapped page =
cache
> + =A0 =A0 =A0 =A0 via a boot parameter (unmapped_page_control). The boot =
parameter
> + =A0 =A0 =A0 =A0 with sysctl (vm.min_unmapped_ratio) control the total n=
umber
> + =A0 =A0 =A0 =A0 of unmapped pages in the system. This feature is useful=
 if
> + =A0 =A0 =A0 =A0 you want to limit the amount of unmapped page cache or =
want
> + =A0 =A0 =A0 =A0 to reduce page cache duplication in a virtualized envir=
onment.
> + =A0 =A0 =A0 =A0 If unsure say 'N'
> +
> =A0config SYSFS_DEPRECATED
> =A0 =A0 =A0 =A0bool "enable deprecated sysfs features to support old user=
space tools"
> =A0 =A0 =A0 =A0depends on SYSFS
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index e40040e..ab2c60a 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -1211,6 +1211,7 @@ static struct ctl_table vm_table[] =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.extra1 =A0 =A0 =A0 =A0 =3D &zero,
> =A0 =A0 =A0 =A0},
> =A0#endif
> +#if defined(CONFIG_UNMAPPED_PAGE_CONTROL) || defined(CONFIG_NUMA)
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.procname =A0 =A0 =A0 =3D "min_unmapped_ra=
tio",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.data =A0 =A0 =A0 =A0 =A0 =3D &sysctl_min_=
unmapped_ratio,
> @@ -1220,6 +1221,7 @@ static struct ctl_table vm_table[] =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.extra1 =A0 =A0 =A0 =A0 =3D &zero,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.extra2 =A0 =A0 =A0 =A0 =3D &one_hundred,
> =A0 =A0 =A0 =A0},
> +#endif
> =A0#ifdef CONFIG_NUMA
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.procname =A0 =A0 =A0 =3D "zone_reclaim_mo=
de",
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1845a97..1c9fbab 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1662,6 +1662,9 @@ zonelist_scan:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long mark;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int ret;
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (should_reclaim_unmapped=
_pages(zone))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wakeup_kswa=
pd(zone, order);

I think we can put the logic into zone_watermark_okay.

> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mark =3D zone->watermark[a=
lloc_flags & ALLOC_WMARK_MASK];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (zone_watermark_ok(zone=
, order, mark,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cl=
asszone_idx, alloc_flags))
> @@ -4154,10 +4157,12 @@ static void __paginginit free_area_init_core(stru=
ct pglist_data *pgdat,
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->spanned_pages =3D size;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->present_pages =3D realsize;
> -#ifdef CONFIG_NUMA
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->node =3D nid;
> +#if defined(CONFIG_UNMAPPED_PAGE_CONTROL) || defined(CONFIG_NUMA)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->min_unmapped_pages =3D (realsize*sys=
ctl_min_unmapped_ratio)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0/ 100;
> +#endif
> +#ifdef CONFIG_NUMA
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->node =3D nid;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->min_slab_pages =3D (realsize * sysct=
l_min_slab_ratio) / 100;
> =A0#endif
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->name =3D zone_names[j];
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 4e2ad05..daf2ad1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -158,6 +158,29 @@ static DECLARE_RWSEM(shrinker_rwsem);
> =A0#define scanning_global_lru(sc) =A0 =A0 =A0 =A0(1)
> =A0#endif
>
> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
> +static unsigned long reclaim_unmapped_pages(int priority, struct zone *z=
one,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct scan_control *sc);
> +static int unmapped_page_control __read_mostly;
> +
> +static int __init unmapped_page_control_parm(char *str)
> +{
> + =A0 =A0 =A0 unmapped_page_control =3D 1;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* XXX: Should we tweak swappiness here?
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 return 1;
> +}
> +__setup("unmapped_page_control", unmapped_page_control_parm);
> +
> +#else /* !CONFIG_UNMAPPED_PAGECACHE_CONTROL */
> +static inline unsigned long reclaim_unmapped_pages(int priority,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone=
 *zone, struct scan_control *sc)
> +{
> + =A0 =A0 =A0 return 0;
> +}
> +#endif
> +
> =A0static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0struct scan_control *sc)
> =A0{
> @@ -2297,6 +2320,12 @@ loop_again:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shrink_act=
ive_list(SWAP_CLUSTER_MAX, zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&sc, priority, 0);
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We do unmapped page re=
claim once here and once
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* below, so that we don'=
t lose out
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 reclaim_unmapped_pages(prio=
rity, zone, &sc);

It can make unnecessary stir of lru pages.
How about this?
zone_watermark_ok returns ZONE_UNMAPPED_PAGE_FULL.
wakeup_kswapd(..., please reclaim unmapped page cache).
If kswapd is woke up by unmapped page full, kswapd sets up sc with unmap =
=3D 0.
If the kswapd try to reclaim unmapped page, shrink_page_list doesn't
rotate non-unmapped pages.

> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!zone_watermark_ok_saf=
e(zone, order,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0high_wmark_pages(zone), 0, 0)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0end_zone =
=3D i;
> @@ -2332,6 +2361,11 @@ loop_again:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc.nr_scanned =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Reclaim unmapped pages=
 upfront, this should be
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* really cheap
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 reclaim_unmapped_pages(prio=
rity, zone, &sc);

Remove the hacky code.

>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Call soft limit reclaim=
 before calling shrink_zone.
> @@ -2587,7 +2621,8 @@ void wakeup_kswapd(struct zone *zone, int order)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgdat->kswapd_max_order =3D order;
> =A0 =A0 =A0 =A0if (!waitqueue_active(&pgdat->kswapd_wait))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> - =A0 =A0 =A0 if (zone_watermark_ok_safe(zone, order, low_wmark_pages(zon=
e), 0, 0))
> + =A0 =A0 =A0 if (zone_watermark_ok_safe(zone, order, low_wmark_pages(zon=
e), 0, 0) &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 !should_reclaim_unmapped_pages(zone))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> =A0 =A0 =A0 =A0trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zon=
e), order);
> @@ -2740,6 +2775,7 @@ static int __init kswapd_init(void)
>
> =A0module_init(kswapd_init)
>
> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL) || defined(CONFIG_NUMA)
> =A0/*
> =A0* Zone reclaim mode
> =A0*
> @@ -2960,6 +2996,65 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask=
, unsigned int order)
>
> =A0 =A0 =A0 =A0return ret;
> =A0}
> +#endif
> +
> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
> +/*
> + * Routine to reclaim unmapped pages, inspired from the code under
> + * CONFIG_NUMA that does unmapped page and slab page control by keeping
> + * min_unmapped_pages in the zone. We currently reclaim just unmapped
> + * pages, slab control will come in soon, at which point this routine
> + * should be called reclaim cached pages
> + */
> +unsigned long reclaim_unmapped_pages(int priority, struct zone *zone,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct scan_control *sc)
> +{
> + =A0 =A0 =A0 if (unlikely(unmapped_page_control) &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (zone_unmapped_file_pages(zone) > zone->min=
_unmapped_pages)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct scan_control nsc;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_pages;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nsc =3D *sc;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nsc.swappiness =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nsc.may_writepage =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nsc.may_unmap =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nsc.nr_reclaimed =3D 0;

This logic can be put in zone_reclaim_unmapped_pages.

> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_pages =3D zone_unmapped_file_pages(zone)=
 -
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->min_u=
nmapped_pages;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We don't want to be too aggressive wit=
h our
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* reclaim, it is our best effort to cont=
rol
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* unmapped pages
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_pages >>=3D 3;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone_reclaim_unmapped_pages(zone, &nsc, nr_=
pages);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return nsc.nr_reclaimed;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return 0;
> +}
> +
> +/*
> + * 16 is a magic number that was pulled out of a magician's
> + * hat. This number automatically provided the best performance
> + * to memory usage (unmapped pages). Lower than this and we spend
> + * a lot of time in frequent reclaims, higher and our control is
> + * weakend.
> + */
> +#define UNMAPPED_PAGE_RATIO 16
> +
> +bool should_reclaim_unmapped_pages(struct zone *zone)
> +{
> + =A0 =A0 =A0 if (unlikely(unmapped_page_control) &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (zone_unmapped_file_pages(zone) >
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 UNMAPPED_PAGE_RATIO * zone-=
>min_unmapped_pages))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> + =A0 =A0 =A0 return false;
> +}
> +#endif
> +
>
> =A0/*
> =A0* page_evictable - test whether a page is evictable
>
>

As I look first, the code isn't good shape.
But more important thing is how many there are users.
Could we pay cost to maintain feature few user?

It depends on your effort which proves the usage cases and benefit.
It would be good to give a real data.

If we want really this, how about the new cache lru idea as Kame suggests?
For example, add_to_page_cache_lru adds the page into cache lru.
page_add_file_rmap moves the page into inactive file.
page_remove_rmap moves the page into lru cache, again.
We can count the unmapped pages and if the size exceeds limit, we can
wake up kswapd.
whenever the memory pressure happens, first of all, reclaimer try to
reclaim cache lru.

It can enhance reclaim latency and is good to embedded people.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
