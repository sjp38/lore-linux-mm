Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 7EB8C6B0062
	for <linux-mm@kvack.org>; Wed,  4 Jan 2012 15:40:49 -0500 (EST)
Received: by obcwo8 with SMTP id wo8so18665134obc.14
        for <linux-mm@kvack.org>; Wed, 04 Jan 2012 12:40:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <e78b4ac9d3d51ac16180114c08733e4bf62ec65e.1325696593.git.leonid.moiseichuk@nokia.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
	<e78b4ac9d3d51ac16180114c08733e4bf62ec65e.1325696593.git.leonid.moiseichuk@nokia.com>
Date: Wed, 4 Jan 2012 22:40:48 +0200
Message-ID: <CAOJsxLFf7TvLy0HgEwFw4myZS1mF=5Q4NQrztH-1=dCMKhOQgg@mail.gmail.com>
Subject: Re: [PATCH 3.2.0-rc1 2/3] MM hook for page allocation and release
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, gregkh@suse.de, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

On Wed, Jan 4, 2012 at 7:21 PM, Leonid Moiseichuk
<leonid.moiseichuk@nokia.com> wrote:
> That is required by Used Memory Meter (UMM) pseudo-device
> to track memory utilization in system. It is expected that
> hook MUST be very light to prevent performance impact
> on the hot allocation path. Accuracy of number managed pages
> does not expected to be absolute but fact of allocation or
> deallocation must be registered.
>
> Signed-off-by: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>
> ---
> =A0include/linux/mm.h | =A0 15 +++++++++++++++
> =A0mm/Kconfig =A0 =A0 =A0 =A0 | =A0 =A08 ++++++++
> =A0mm/page_alloc.c =A0 =A0| =A0 31 +++++++++++++++++++++++++++++++
> =A03 files changed, 54 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 3dc3a8c..d133f73 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1618,6 +1618,21 @@ extern int soft_offline_page(struct page *page, in=
t flags);
>
> =A0extern void dump_page(struct page *page);
>
> +#ifdef CONFIG_MM_ALLOC_FREE_HOOK
> +/*
> + * Hook function type which called when some pages allocated or released=
.
> + * Value of nr_pages is positive for post-allocation calls and negative
> + * after free.
> + */
> +typedef void (*mm_alloc_free_hook_t)(int nr_pages);
> +
> +/*
> + * Setups specified hook function for tracking pages allocation.
> + * Returns value of old hook to organize chains of calls if necessary.
> + */
> +mm_alloc_free_hook_t set_mm_alloc_free_hook(mm_alloc_free_hook_t hook);
> +#endif
> +
> =A0#if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
> =A0extern void clear_huge_page(struct page *page,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long addr=
,
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 011b110..2aaa1e9 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -373,3 +373,11 @@ config CLEANCACHE
> =A0 =A0 =A0 =A0 =A0in a negligible performance hit.
>
> =A0 =A0 =A0 =A0 =A0If unsure, say Y to enable cleancache
> +
> +config MM_ALLOC_FREE_HOOK
> + =A0 =A0 =A0 bool "Enable callback support for pages allocation and rele=
asing"
> + =A0 =A0 =A0 default n
> + =A0 =A0 =A0 help
> + =A0 =A0 =A0 =A0 Required for some features like used memory meter.
> + =A0 =A0 =A0 =A0 If unsure, say N to disable alloc/free hook.
> +
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9dd443d..9307800 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -236,6 +236,30 @@ static void set_pageblock_migratetype(struct page *p=
age, int migratetype)
>
> =A0bool oom_killer_disabled __read_mostly;
>
> +#ifdef CONFIG_MM_ALLOC_FREE_HOOK
> +static atomic_long_t alloc_free_hook __read_mostly =3D ATOMIC_LONG_INIT(=
0);
> +
> +mm_alloc_free_hook_t set_mm_alloc_free_hook(mm_alloc_free_hook_t hook)
> +{
> + =A0 =A0 =A0 const mm_alloc_free_hook_t old_hook =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (mm_alloc_free_hook_t)atomic_long_read(&all=
oc_free_hook);
> +
> + =A0 =A0 =A0 atomic_long_set(&alloc_free_hook, (long)hook);
> + =A0 =A0 =A0 pr_info("MM alloc/free hook set to 0x%p (was 0x%p)\n", hook=
, old_hook);
> +
> + =A0 =A0 =A0 return old_hook;
> +}
> +EXPORT_SYMBOL(set_mm_alloc_free_hook);
> +
> +static inline void call_alloc_free_hook(int pages)
> +{
> + =A0 =A0 =A0 const mm_alloc_free_hook_t hook =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (mm_alloc_free_hook_t)atomic_long_read(&all=
oc_free_hook);
> + =A0 =A0 =A0 if (hook)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hook(pages);
> +}
> +#endif
> +
> =A0#ifdef CONFIG_DEBUG_VM
> =A0static int page_outside_zone_boundaries(struct zone *zone, struct page=
 *page)
> =A0{
> @@ -2298,6 +2322,10 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned in=
t order,
> =A0 =A0 =A0 =A0put_mems_allowed();
>
> =A0 =A0 =A0 =A0trace_mm_page_alloc(page, order, gfp_mask, migratetype);
> +#ifdef CONFIG_MM_ALLOC_FREE_HOOK
> + =A0 =A0 =A0 call_alloc_free_hook(1 << order);
> +#endif
> +
> =A0 =A0 =A0 =A0return page;
> =A0}
> =A0EXPORT_SYMBOL(__alloc_pages_nodemask);
> @@ -2345,6 +2373,9 @@ void __free_pages(struct page *page, unsigned int o=
rder)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0free_hot_cold_page(page, 0=
);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__free_pages_ok(page, orde=
r);
> +#ifdef CONFIG_MM_ALLOC_FREE_HOOK
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 call_alloc_free_hook(-(1 << order));
> +#endif
> =A0 =A0 =A0 =A0}
> =A0}

No, we definitely don't want to allow random modules to insert hooks
to the page allocator:

  Nacked-by: Pekka Enberg <penberg@kernel.org>

Can't we introduce some super-lightweight lowmem_{alloc|free}_hook()
hooks that live in mm/lowmem.c and call those directly? If you need to
support different ABIs for lowmem notifier, N9, and Android, you could
make that observer code more generic, no? The swaphook people might be
interested in that as well.

                           Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
