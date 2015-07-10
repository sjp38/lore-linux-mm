Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8D2A96B0038
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 09:41:25 -0400 (EDT)
Received: by lbbyj8 with SMTP id yj8so7891282lbb.0
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 06:41:24 -0700 (PDT)
Received: from mail-lb0-x22e.google.com (mail-lb0-x22e.google.com. [2a00:1450:4010:c04::22e])
        by mx.google.com with ESMTPS id w5si7396854laa.59.2015.07.10.06.41.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jul 2015 06:41:23 -0700 (PDT)
Received: by lbbpo10 with SMTP id po10so92796793lbb.3
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 06:41:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1436243785-24105-3-git-send-email-gioh.kim@lge.com>
References: <1436243785-24105-1-git-send-email-gioh.kim@lge.com>
	<1436243785-24105-3-git-send-email-gioh.kim@lge.com>
Date: Fri, 10 Jul 2015 16:41:22 +0300
Message-ID: <CALYGNiN2D8s4=6AdjoAp_R9Znd0Wm5gS0vC2zviyw+9Lu4NyGA@mail.gmail.com>
Subject: Re: [RFCv3 2/5] mm/compaction: enable mobile-page migration
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: Jeff Layton <jlayton@poochiereds.net>, Bruce Fields <bfields@fieldses.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Al Viro <viro@zeniv.linux.org.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Minchan Kim <minchan@kernel.org>, Rafael Aquini <aquini@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, virtualization@lists.linux-foundation.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, gunho.lee@lge.com, Andrew Morton <akpm@linux-foundation.org>, Gioh Kim <gurugio@hanmail.net>

One more note below.

On Tue, Jul 7, 2015 at 7:36 AM, Gioh Kim <gioh.kim@lge.com> wrote:
> From: Gioh Kim <gurugio@hanmail.net>
>
> Add framework to register callback functions and check page mobility.
> There are some modes for page isolation so that isolate interface
> has arguments of page address and isolation mode while putback
> interface has only page address as argument.
>
> Signed-off-by: Gioh Kim <gioh.kim@lge.com>
> ---
>  fs/proc/page.c                         |  3 ++
>  include/linux/compaction.h             | 76 ++++++++++++++++++++++++++++++++++
>  include/linux/fs.h                     |  2 +
>  include/linux/page-flags.h             | 19 +++++++++
>  include/uapi/linux/kernel-page-flags.h |  1 +
>  5 files changed, 101 insertions(+)
>
> diff --git a/fs/proc/page.c b/fs/proc/page.c
> index 7eee2d8..a4f5a00 100644
> --- a/fs/proc/page.c
> +++ b/fs/proc/page.c
> @@ -146,6 +146,9 @@ u64 stable_page_flags(struct page *page)
>         if (PageBalloon(page))
>                 u |= 1 << KPF_BALLOON;
>
> +       if (PageMobile(page))
> +               u |= 1 << KPF_MOBILE;
> +
>         u |= kpf_copy_bit(k, KPF_LOCKED,        PG_locked);
>
>         u |= kpf_copy_bit(k, KPF_SLAB,          PG_slab);
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index aa8f61c..c375a89 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -1,6 +1,9 @@
>  #ifndef _LINUX_COMPACTION_H
>  #define _LINUX_COMPACTION_H
>
> +#include <linux/page-flags.h>
> +#include <linux/pagemap.h>
> +
>  /* Return values for compact_zone() and try_to_compact_pages() */
>  /* compaction didn't start as it was deferred due to past failures */
>  #define COMPACT_DEFERRED       0
> @@ -51,6 +54,66 @@ extern void compaction_defer_reset(struct zone *zone, int order,
>                                 bool alloc_success);
>  extern bool compaction_restarting(struct zone *zone, int order);
>
> +static inline bool mobile_page(struct page *page)
> +{
> +       return page->mapping && page->mapping->a_ops &&
> +               (PageMobile(page) || PageBalloon(page));
> +}
> +
> +static inline bool isolate_mobilepage(struct page *page, isolate_mode_t mode)
> +{
> +       bool ret;
> +
> +       /*
> +        * Avoid burning cycles with pages that are yet under __free_pages(),
> +        * or just got freed under us.
> +        *
> +        * In case we 'win' a race for a mobile page being freed under us and
> +        * raise its refcount preventing __free_pages() from doing its job
> +        * the put_page() at the end of this block will take care of
> +        * release this page, thus avoiding a nasty leakage.
> +        */
> +       if (likely(get_page_unless_zero(page))) {
> +               /*
> +                * As mobile pages are not isolated from LRU lists, concurrent
> +                * compaction threads can race against page migration functions
> +                * as well as race against the releasing a page.
> +                *
> +                * In order to avoid having an already isolated mobile page
> +                * being (wrongly) re-isolated while it is under migration,
> +                * or to avoid attempting to isolate pages being released,
> +                * lets be sure we have the page lock
> +                * before proceeding with the mobile page isolation steps.
> +                */
> +               if (likely(trylock_page(page))) {
> +                       if (mobile_page(page) &&
> +                           page->mapping->a_ops->isolatepage) {
> +                               ret = page->mapping->a_ops->isolatepage(page,
> +                                                                       mode);
> +                               unlock_page(page);

Here you leak page reference if isolatepage() fails.

> +                               return ret;
> +                       }
> +                       unlock_page(page);
> +               }
> +               put_page(page);
> +       }
> +       return false;
> +}
> +
> +static inline void putback_mobilepage(struct page *page)
> +{
> +       /*
> +        * 'lock_page()' stabilizes the page and prevents races against
> +        * concurrent isolation threads attempting to re-isolate it.
> +        */
> +       lock_page(page);
> +       if (mobile_page(page) && page->mapping->a_ops->putbackpage) {
> +               page->mapping->a_ops->putbackpage(page);
> +               /* drop the extra ref count taken for mobile page isolation */
> +               put_page(page);
> +       }
> +       unlock_page(page);
> +}
>  #else
>  static inline unsigned long try_to_compact_pages(gfp_t gfp_mask,
>                         unsigned int order, int alloc_flags,
> @@ -83,6 +146,19 @@ static inline bool compaction_deferred(struct zone *zone, int order)
>         return true;
>  }
>
> +static inline bool mobile_page(struct page *page)
> +{
> +       return false;
> +}
> +
> +static inline bool isolate_mobilepage(struct page *page, isolate_mode_t mode)
> +{
> +       return false;
> +}
> +
> +static inline void putback_mobilepage(struct page *page)
> +{
> +}
>  #endif /* CONFIG_COMPACTION */
>
>  #if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 35ec87e..33c9aa5 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -395,6 +395,8 @@ struct address_space_operations {
>          */
>         int (*migratepage) (struct address_space *,
>                         struct page *, struct page *, enum migrate_mode);
> +       bool (*isolatepage) (struct page *, isolate_mode_t);
> +       void (*putbackpage) (struct page *);
>         int (*launder_page) (struct page *);
>         int (*is_partially_uptodate) (struct page *, unsigned long,
>                                         unsigned long);
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index f34e040..abef145 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -582,6 +582,25 @@ static inline void __ClearPageBalloon(struct page *page)
>         atomic_set(&page->_mapcount, -1);
>  }
>
> +#define PAGE_MOBILE_MAPCOUNT_VALUE (-255)
> +
> +static inline int PageMobile(struct page *page)
> +{
> +       return atomic_read(&page->_mapcount) == PAGE_MOBILE_MAPCOUNT_VALUE;
> +}
> +
> +static inline void __SetPageMobile(struct page *page)
> +{
> +       VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
> +       atomic_set(&page->_mapcount, PAGE_MOBILE_MAPCOUNT_VALUE);
> +}
> +
> +static inline void __ClearPageMobile(struct page *page)
> +{
> +       VM_BUG_ON_PAGE(!PageMobile(page), page);
> +       atomic_set(&page->_mapcount, -1);
> +}
> +
>  /*
>   * If network-based swap is enabled, sl*b must keep track of whether pages
>   * were allocated from pfmemalloc reserves.
> diff --git a/include/uapi/linux/kernel-page-flags.h b/include/uapi/linux/kernel-page-flags.h
> index a6c4962..d50d9e8 100644
> --- a/include/uapi/linux/kernel-page-flags.h
> +++ b/include/uapi/linux/kernel-page-flags.h
> @@ -33,6 +33,7 @@
>  #define KPF_THP                        22
>  #define KPF_BALLOON            23
>  #define KPF_ZERO_PAGE          24
> +#define KPF_MOBILE             25
>
>
>  #endif /* _UAPILINUX_KERNEL_PAGE_FLAGS_H */
> --
> 2.1.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
