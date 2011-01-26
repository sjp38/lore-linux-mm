Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EE6C38D0039
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 18:12:06 -0500 (EST)
Received: by iwn40 with SMTP id 40so1479808iwn.14
        for <linux-mm@kvack.org>; Wed, 26 Jan 2011 15:12:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110125051015.13762.13429.stgit@localhost6.localdomain6>
References: <20110125051003.13762.35120.stgit@localhost6.localdomain6>
	<20110125051015.13762.13429.stgit@localhost6.localdomain6>
Date: Thu, 27 Jan 2011 08:12:02 +0900
Message-ID: <AANLkTikHLw0Qg+odOB-bDtBSB-5UbTJ5ZOM-ZAdMqXgh@mail.gmail.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages (v4)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi Balbir,

On Tue, Jan 25, 2011 at 2:10 PM, Balbir Singh <balbir@linux.vnet.ibm.com> w=
rote:
> Changelog v4
> 1. Add max_unmapped_ratio and use that as the upper limit
> to check when to shrink the unmapped page cache (Christoph
> Lameter)
>
> Changelog v2
> 1. Use a config option to enable the code (Andrew Morton)
> 2. Explain the magic tunables in the code or at-least attempt
> =A0 to explain them (General comment)
> 3. Hint uses of the boot parameter with unlikely (Andrew Morton)
> 4. Use better names (balanced is not a good naming convention)
>
> Provide control using zone_reclaim() and a boot parameter. The
> code reuses functionality from zone_reclaim() to isolate unmapped
> pages and reclaim them as a priority, ahead of other mapped pages.
> A new sysctl for max_unmapped_ratio is provided and set to 16,
> indicating 16% of the total zone pages are unmapped, we start
> shrinking unmapped page cache.
>
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> =A0Documentation/kernel-parameters.txt | =A0 =A08 +++
> =A0include/linux/mmzone.h =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A05 ++
> =A0include/linux/swap.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 23 ++++++++-
> =A0init/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 12 +=
++++
> =A0kernel/sysctl.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 11 ++++
> =A0mm/page_alloc.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 25 +++++=
+++++
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 87 +=
++++++++++++++++++++++++++++++++++
> =A07 files changed, 166 insertions(+), 5 deletions(-)
>
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-p=
arameters.txt
> index fee5f57..65a4ee6 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -2500,6 +2500,14 @@ and is between 256 and 4096 characters. It is defi=
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
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 2485acc..18f0f09 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -306,7 +306,10 @@ struct zone {
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * zone reclaim becomes active if more unmapped pages exis=
t.
> =A0 =A0 =A0 =A0 */
> +#if defined(CONFIG_UNMAPPED_PAGE_CONTROL) || defined(CONFIG_NUMA)
> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 min_unmapped_pages;
> + =A0 =A0 =A0 unsigned long =A0 =A0 =A0 =A0 =A0 max_unmapped_pages;
> +#endif
> =A0#ifdef CONFIG_NUMA
> =A0 =A0 =A0 =A0int node;
> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 min_slab_pages;
> @@ -773,6 +776,8 @@ int percpu_pagelist_fraction_sysctl_handler(struct ct=
l_table *, int,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0void __user *, size_t *, loff_t *);
> =A0int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *, int,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void __user *, size_t *, l=
off_t *);
> +int sysctl_max_unmapped_ratio_sysctl_handler(struct ctl_table *, int,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void __user *, size_t *, lo=
ff_t *);
> =A0int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void __user *, size_t *, l=
off_t *);
>
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 7b75626..ae62a03 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -255,19 +255,34 @@ extern int vm_swappiness;
> =A0extern int remove_mapping(struct address_space *mapping, struct page *=
page);
> =A0extern long vm_total_pages;
>
> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL) || defined(CONFIG_NUMA)
> =A0extern int sysctl_min_unmapped_ratio;
> +extern int sysctl_max_unmapped_ratio;
> +
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
> index 4f6cdbf..2dfbc09 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -828,6 +828,18 @@ config SCHED_AUTOGROUP
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
> index 12e8f26..63dbba6 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -1224,6 +1224,7 @@ static struct ctl_table vm_table[] =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.extra1 =A0 =A0 =A0 =A0 =3D &zero,
> =A0 =A0 =A0 =A0},
> =A0#endif
> +#if defined(CONFIG_UNMAPPED_PAGE_CONTROL) || defined(CONFIG_NUMA)
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.procname =A0 =A0 =A0 =3D "min_unmapped_ra=
tio",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.data =A0 =A0 =A0 =A0 =A0 =3D &sysctl_min_=
unmapped_ratio,
> @@ -1233,6 +1234,16 @@ static struct ctl_table vm_table[] =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.extra1 =A0 =A0 =A0 =A0 =3D &zero,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.extra2 =A0 =A0 =A0 =A0 =3D &one_hundred,
> =A0 =A0 =A0 =A0},
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .procname =A0 =A0 =A0 =3D "max_unmapped_rat=
io",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .data =A0 =A0 =A0 =A0 =A0 =3D &sysctl_max_u=
nmapped_ratio,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .maxlen =A0 =A0 =A0 =A0 =3D sizeof(sysctl_m=
ax_unmapped_ratio),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mode =A0 =A0 =A0 =A0 =A0 =3D 0644,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .proc_handler =A0 =3D sysctl_max_unmapped_r=
atio_sysctl_handler,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .extra1 =A0 =A0 =A0 =A0 =3D &zero,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .extra2 =A0 =A0 =A0 =A0 =3D &one_hundred,
> + =A0 =A0 =A0 },
> +#endif
> =A0#ifdef CONFIG_NUMA
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.procname =A0 =A0 =A0 =3D "zone_reclaim_mo=
de",
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7b56473..2ac8549 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1660,6 +1660,9 @@ zonelist_scan:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long mark;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int ret;
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (should_reclaim_unmapped=
_pages(zone))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wakeup_kswa=
pd(zone, order, classzone_idx);
> +

Do we really need the check in fastpath?
There are lost of caller of alloc_pages.
Many of them are not related to mapped pages.
Could we move the check into add_to_page_cache_locked?

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mark =3D zone->watermark[a=
lloc_flags & ALLOC_WMARK_MASK];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (zone_watermark_ok(zone=
, order, mark,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cl=
asszone_idx, alloc_flags))
> @@ -4167,8 +4170,12 @@ static void __paginginit free_area_init_core(struc=
t pglist_data *pgdat,
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->spanned_pages =3D size;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->present_pages =3D realsize;
> +#if defined(CONFIG_UNMAPPED_PAGE_CONTROL) || defined(CONFIG_NUMA)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->min_unmapped_pages =3D (realsize*sys=
ctl_min_unmapped_ratio)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0/ 100;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->max_unmapped_pages =3D (realsize*sysc=
tl_max_unmapped_ratio)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 / 100;
> +#endif
> =A0#ifdef CONFIG_NUMA
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->node =3D nid;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->min_slab_pages =3D (realsize * sysct=
l_min_slab_ratio) / 100;
> @@ -5084,6 +5091,7 @@ int min_free_kbytes_sysctl_handler(ctl_table *table=
, int write,
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> +#if defined(CONFIG_UNMAPPED_PAGE_CONTROL) || defined(CONFIG_NUMA)
> =A0int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, int wri=
te,
> =A0 =A0 =A0 =A0void __user *buffer, size_t *length, loff_t *ppos)
> =A0{
> @@ -5100,6 +5108,23 @@ int sysctl_min_unmapped_ratio_sysctl_handler(ctl_t=
able *table, int write,
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> +int sysctl_max_unmapped_ratio_sysctl_handler(ctl_table *table, int write=
,
> + =A0 =A0 =A0 void __user *buffer, size_t *length, loff_t *ppos)
> +{
> + =A0 =A0 =A0 struct zone *zone;
> + =A0 =A0 =A0 int rc;
> +
> + =A0 =A0 =A0 rc =3D proc_dointvec_minmax(table, write, buffer, length, p=
pos);
> + =A0 =A0 =A0 if (rc)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return rc;
> +
> + =A0 =A0 =A0 for_each_zone(zone)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->max_unmapped_pages =3D (zone->present=
_pages *
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sysctl_max_=
unmapped_ratio) / 100;
> + =A0 =A0 =A0 return 0;
> +}
> +#endif
> +
> =A0#ifdef CONFIG_NUMA
> =A0int sysctl_min_slab_ratio_sysctl_handler(ctl_table *table, int write,
> =A0 =A0 =A0 =A0void __user *buffer, size_t *length, loff_t *ppos)
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 02cc82e..6377411 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -159,6 +159,29 @@ static DECLARE_RWSEM(shrinker_rwsem);
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
> @@ -2359,6 +2382,12 @@ loop_again:
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
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!zone_watermark_ok_saf=
e(zone, order,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0high_wmark_pages(zone), 0, 0)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0end_zone =
=3D i;
> @@ -2396,6 +2425,11 @@ loop_again:
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

Why should we do by two phase?
It's not a direct reclaim path. I mean it doesn't need to reclaim tighly
If we can't reclaim enough, next allocation would wake up kswapd again
and kswapd try it again.

And I have a concern. I already pointed out.
If memory pressure is heavy and unmappd_pages is more than our
threshold, this can move inactive's tail pages which are mapped into
heads by reclaim_unmapped_pages. It can make confusing LRU order so
working set can be evicted.

zone_reclaim is used by only NUMA until now but you are opening it in the w=
orld.
I think it would be a good feature in embedded system, too.
I hope we care of working set eviction problem.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
