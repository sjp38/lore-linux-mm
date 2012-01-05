Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 3587B6B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 06:28:13 -0500 (EST)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [PATCH 3.2.0-rc1 2/3] MM hook for page allocation and release
Date: Thu, 5 Jan 2012 11:26:34 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB9826904554270@008-AM1MPN1-003.mgdnok.nokia.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
	<e78b4ac9d3d51ac16180114c08733e4bf62ec65e.1325696593.git.leonid.moiseichuk@nokia.com>
 <20120105155950.9e49651b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120105155950.9e49651b.kamezawa.hiroyu@jp.fujitsu.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, emunson@mgebm.net, penberg@kernel.org, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, gregkh@suse.de, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

Hi,

I agree that hooking alloc_pages is ugly way. So alternatives I see:

- shrinkers (as e.g. Android OOM used) but shrink_slab called only from try=
_to_free_pages only if we are on slow reclaim path on memory allocation, so=
 it cannot be used for e.g. 75% memory tracking or when pages released to n=
otify user space that we are OK. But according to easy to use it will be th=
e best approach.

- memcg-kind of changes like mem_cgroup_newpage_charge/uncharge_page but wi=
thout blocking decision making logic. Seems to me more changes. Threshold c=
urrently in memcg set 128 pages per CPU, that is quite often for level trac=
king needs.

- tracking situation using timer? Maybe not due to will impact battery.

With Best Wishes,
Leonid


-----Original Message-----
From: ext KAMEZAWA Hiroyuki [mailto:kamezawa.hiroyu@jp.fujitsu.com]=20
Sent: 05 January, 2012 09:00
To: Moiseichuk Leonid (Nokia-MP/Helsinki)
Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org; cesarb@cesarb.net; em=
unson@mgebm.net; penberg@kernel.org; aarcange@redhat.com; riel@redhat.com; =
mel@csn.ul.ie; rientjes@google.com; dima@android.com; gregkh@suse.de; rebec=
ca@android.com; san@google.com; akpm@linux-foundation.org; Jaaskelainen Ves=
a (Nokia-MP/Helsinki)
Subject: Re: [PATCH 3.2.0-rc1 2/3] MM hook for page allocation and release

On Wed,  4 Jan 2012 19:21:55 +0200
Leonid Moiseichuk <leonid.moiseichuk@nokia.com> wrote:

> That is required by Used Memory Meter (UMM) pseudo-device to track=20
> memory utilization in system. It is expected that hook MUST be very=20
> light to prevent performance impact on the hot allocation path.=20
> Accuracy of number managed pages does not expected to be absolute but=20
> fact of allocation or deallocation must be registered.
>=20
> Signed-off-by: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>

I never like arbitrary hooks to alloc_pages().
Could you find another way ?

Hmm. memcg uses per-cpu counters for counting event of alloc/free and trigg=
er threashold check per 128 event on a cpu.


Thanks,
-Kame


> ---
>  include/linux/mm.h |   15 +++++++++++++++
>  mm/Kconfig         |    8 ++++++++
>  mm/page_alloc.c    |   31 +++++++++++++++++++++++++++++++
>  3 files changed, 54 insertions(+), 0 deletions(-)
>=20
> diff --git a/include/linux/mm.h b/include/linux/mm.h index=20
> 3dc3a8c..d133f73 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1618,6 +1618,21 @@ extern int soft_offline_page(struct page *page,=20
> int flags);
> =20
>  extern void dump_page(struct page *page);
> =20
> +#ifdef CONFIG_MM_ALLOC_FREE_HOOK
> +/*
> + * Hook function type which called when some pages allocated or released=
.
> + * Value of nr_pages is positive for post-allocation calls and=20
> +negative
> + * after free.
> + */
> +typedef void (*mm_alloc_free_hook_t)(int nr_pages);
> +
> +/*
> + * Setups specified hook function for tracking pages allocation.
> + * Returns value of old hook to organize chains of calls if necessary.
> + */
> +mm_alloc_free_hook_t set_mm_alloc_free_hook(mm_alloc_free_hook_t=20
> +hook); #endif
> +
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS) =20
> extern void clear_huge_page(struct page *page,
>  			    unsigned long addr,
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 011b110..2aaa1e9 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -373,3 +373,11 @@ config CLEANCACHE
>  	  in a negligible performance hit.
> =20
>  	  If unsure, say Y to enable cleancache
> +
> +config MM_ALLOC_FREE_HOOK
> +	bool "Enable callback support for pages allocation and releasing"
> +	default n
> +	help
> +	  Required for some features like used memory meter.
> +	  If unsure, say N to disable alloc/free hook.
> +
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c index 9dd443d..9307800=20
> 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -236,6 +236,30 @@ static void set_pageblock_migratetype(struct page=20
> *page, int migratetype)
> =20
>  bool oom_killer_disabled __read_mostly;
> =20
> +#ifdef CONFIG_MM_ALLOC_FREE_HOOK
> +static atomic_long_t alloc_free_hook __read_mostly =3D=20
> +ATOMIC_LONG_INIT(0);
> +
> +mm_alloc_free_hook_t set_mm_alloc_free_hook(mm_alloc_free_hook_t=20
> +hook) {
> +	const mm_alloc_free_hook_t old_hook =3D
> +		(mm_alloc_free_hook_t)atomic_long_read(&alloc_free_hook);
> +
> +	atomic_long_set(&alloc_free_hook, (long)hook);
> +	pr_info("MM alloc/free hook set to 0x%p (was 0x%p)\n", hook,=20
> +old_hook);
> +
> +	return old_hook;
> +}
> +EXPORT_SYMBOL(set_mm_alloc_free_hook);
> +
> +static inline void call_alloc_free_hook(int pages) {
> +	const mm_alloc_free_hook_t hook =3D
> +		(mm_alloc_free_hook_t)atomic_long_read(&alloc_free_hook);
> +	if (hook)
> +		hook(pages);
> +}
> +#endif
> +
>  #ifdef CONFIG_DEBUG_VM
>  static int page_outside_zone_boundaries(struct zone *zone, struct=20
> page *page)  { @@ -2298,6 +2322,10 @@ __alloc_pages_nodemask(gfp_t=20
> gfp_mask, unsigned int order,
>  	put_mems_allowed();
> =20
>  	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
> +#ifdef CONFIG_MM_ALLOC_FREE_HOOK
> +	call_alloc_free_hook(1 << order);
> +#endif
> +
>  	return page;
>  }
>  EXPORT_SYMBOL(__alloc_pages_nodemask);
> @@ -2345,6 +2373,9 @@ void __free_pages(struct page *page, unsigned int o=
rder)
>  			free_hot_cold_page(page, 0);
>  		else
>  			__free_pages_ok(page, order);
> +#ifdef CONFIG_MM_ALLOC_FREE_HOOK
> +		call_alloc_free_hook(-(1 << order)); #endif
>  	}
>  }
> =20
> --
> 1.7.7.3
>=20
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
