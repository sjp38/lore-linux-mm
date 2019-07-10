Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B91DC74A35
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 21:57:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03C7B208E4
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 21:57:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dmjhIXhH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03C7B208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 898FC8E009B; Wed, 10 Jul 2019 17:57:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84A258E0032; Wed, 10 Jul 2019 17:57:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7104E8E009B; Wed, 10 Jul 2019 17:57:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4BA1D8E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 17:57:09 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id c5so4374282iom.18
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 14:57:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=2DXpX7J3HbCHtTb/QlhNzHfNQIwcitCaXZndyLAl7JY=;
        b=L9f8H0/s/GJzOA3aY00vDI47g2mse2avSQC5/PP/RSoJgrWdIcZxMookmESQhp6HsW
         XXU47LANtidS8uOvfr6GZN504clXAvnH4g6ch+zAv/B+2Tv0317cHEUTQu0uYba7/i5g
         5Hhc+6XYGEt7rZ+YjTrdSCP+FIRQAItmtPAsh5DerSWZk21aMHjgB3BAUI/DZfp/WeOc
         5A2aVoLBrCV/Qv1MxyxyQy1aoBAlkXjNVSFbxePXt6P3vjH2GJoI+QsMaLJY0k6nfeqH
         qEWjI7Y+tnGXY9qLhZh8ntoPO4Bnlo2MdR6vqKZh/VWUYWnwBVvazETjy0GbTjcpuCQK
         65BQ==
X-Gm-Message-State: APjAAAWJKewZVqqabiu7LuudPZa7I5Gm4WqasJjNQNeM5+NEHdn/Admu
	+tBEhii25mo8G7JQzBJpCaXEYf4dtaVxjfeWPKVe/6vZY+voC0+ku3jvS5pIntvkUAXGA/m5ol9
	dwDuKoyJ5BJOP6KB4Yt0bq/x2jwJCL4mzqRxp0WLMlsxHX9rt47ikeawVUkI9ymRmLg==
X-Received: by 2002:a02:b713:: with SMTP id g19mr400518jam.77.1562795828973;
        Wed, 10 Jul 2019 14:57:08 -0700 (PDT)
X-Received: by 2002:a02:b713:: with SMTP id g19mr400410jam.77.1562795827646;
        Wed, 10 Jul 2019 14:57:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562795827; cv=none;
        d=google.com; s=arc-20160816;
        b=NMAeq3OgKZW+vhh3LXq/rOMn7cqRgybZl39H5reDYMKEph3MurKoBcuZhjU6fGNsPD
         yQOIir8ulaN7vXsChS4UelX5O8Pr5xLotCdLtML2eeOP2Q/xB889ROBUcgC8pMF85zAY
         v0Dq2fw31x90YftamFUYalyy13OWtfEYyVKn68S1Hd7oGXEhNP9Zo8ruFNyoHVWFUKj/
         5wFuU73olciPesKT7ihABvJtnSSZppgQS271MQggNgJaL6TxYWFNT09HXUhaoN83MzWL
         mhQADWzjk1mF6QTlElQEQzE3viNlKZJ9PKEVWyrUYgzghkyTkTaGwqht57IQ3G5L9wQ/
         er5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=2DXpX7J3HbCHtTb/QlhNzHfNQIwcitCaXZndyLAl7JY=;
        b=sbx/shN4TUUGVBQ86NIbKl1YwkBo0TH+7GQWGk2ljA9ZDOXhgR+0hPzFDmlaL+qoZY
         5QwpH9yzSZZhY3MipNPYcxbW3iRObq5P2a5JidIkmva5j2xsULlrs2jt0f0sIkBjdeqT
         v345Ny7/2ncuUhce3A3NOpINiE+mGGH66DzVHzhvZc52cpIvWQcuQVRCq6IW/GOSsXRx
         CA3EZgRXm3duW4hlzCtiA9W7uPiSBIDdNp+vgEd49BF28+J9SJRE8btRDdazkzWsK59m
         yByulXXcWL2ONN6GGB57j1XpH7zDTB9VLyB6RmqWhW+Hq53M/S5sjDK7uOh8CsdnEB1s
         dyeA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dmjhIXhH;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q9sor3092955iog.65.2019.07.10.14.57.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 14:57:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dmjhIXhH;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2DXpX7J3HbCHtTb/QlhNzHfNQIwcitCaXZndyLAl7JY=;
        b=dmjhIXhH5EgiSQu16xwMBVxMRhV/w8AObn/lnXwOIqgVlXeulQlyoiAkN/nZev1v6o
         RRmeeTft1CbxBuD03xCwc9FBStEwpRNgrpJcrSbjZ8wI176yJN0EYtO+W+6KmnPr9O1v
         DmW9RAx/J9/ydrRrWwcbfBu0tIZ7oeKBgsKqpUtGd0z29ACJgOtyZBNEcnYV91wLs2Fc
         uXdfq88cLPTrAff7RTW1hdy6zaOojVmY3dW8pGLorNzy7C8813Rrea2L/KhzyNGbnh9Z
         SAAFeCEuDF3i218jeTJZAWnzTJvzvinLRIt8XWj71Rrmd4NxWMnkFVGvq0MzPFqlc1Uo
         7xcQ==
X-Google-Smtp-Source: APXvYqzRNxyz/xj2S6lFPADfKqVKGRqCS0g1lCPIanu9PbmBmhuHVPvb6bu0wTnVULKY/foZ0cdT5wOmPfLs7M/II1s=
X-Received: by 2002:a6b:5106:: with SMTP id f6mr359718iob.15.1562795827030;
 Wed, 10 Jul 2019 14:57:07 -0700 (PDT)
MIME-Version: 1.0
References: <20190710195158.19640-1-nitesh@redhat.com> <20190710195158.19640-2-nitesh@redhat.com>
In-Reply-To: <20190710195158.19640-2-nitesh@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 10 Jul 2019 14:56:55 -0700
Message-ID: <CAKgT0Ue3mVZ_J0GgMUP4PBW4SUD1=L9ixD5nUZybw9_vmBAT0A@mail.gmail.com>
Subject: Re: [RFC][Patch v11 1/2] mm: page_hinting: core infrastructure
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, 
	pagupta@redhat.com, wei.w.wang@intel.com, 
	Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>, 
	David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>, john.starks@microsoft.com, 
	Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 10, 2019 at 12:52 PM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>
> This patch introduces the core infrastructure for free page hinting in
> virtual environments. It enables the kernel to track the free pages which
> can be reported to its hypervisor so that the hypervisor could
> free and reuse that memory as per its requirement.
>
> While the pages are getting processed in the hypervisor (e.g.,
> via MADV_FREE), the guest must not use them, otherwise, data loss
> would be possible. To avoid such a situation, these pages are
> temporarily removed from the buddy. The amount of pages removed
> temporarily from the buddy is governed by the backend(virtio-balloon
> in our case).
>
> To efficiently identify free pages that can to be hinted to the
> hypervisor, bitmaps in a coarse granularity are used. Only fairly big
> chunks are reported to the hypervisor - especially, to not break up THP
> in the hypervisor - "MAX_ORDER - 2" on x86, and to save space. The bits
> in the bitmap are an indication whether a page *might* be free, not a
> guarantee. A new hook after buddy merging sets the bits.
>
> Bitmaps are stored per zone, protected by the zone lock. A workqueue
> asynchronously processes the bitmaps, trying to isolate and report pages
> that are still free. The backend (virtio-balloon) is responsible for
> reporting these batched pages to the host synchronously. Once reporting/
> freeing is complete, isolated pages are returned back to the buddy.
>
> There are still various things to look into (e.g., memory hotplug, more
> efficient locking, possible races when disabling).
>
> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
> ---
>  include/linux/page_hinting.h |  45 +++++++
>  mm/Kconfig                   |   6 +
>  mm/Makefile                  |   1 +
>  mm/page_alloc.c              |  18 +--
>  mm/page_hinting.c            | 250 +++++++++++++++++++++++++++++++++++
>  5 files changed, 312 insertions(+), 8 deletions(-)
>  create mode 100644 include/linux/page_hinting.h
>  create mode 100644 mm/page_hinting.c
>
> diff --git a/include/linux/page_hinting.h b/include/linux/page_hinting.h
> new file mode 100644
> index 000000000000..4900feb796f9
> --- /dev/null
> +++ b/include/linux/page_hinting.h
> @@ -0,0 +1,45 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +#ifndef _LINUX_PAGE_HINTING_H
> +#define _LINUX_PAGE_HINTING_H
> +
> +/*
> + * Minimum page order required for a page to be hinted to the host.
> + */
> +#define PAGE_HINTING_MIN_ORDER         (MAX_ORDER - 2)
> +

Why use (MAX_ORDER - 2)? Is this just because of the issues I pointed
out earlier for is it due to something else? I'm just wondering if
this will have an impact on architectures outside of x86 as I had
chose pageblock_order which happened to be MAX_ORDER - 2 on x86, but I
don't know that the impact of doing that is on other architectures
versus the (MAX_ORDER - 2) approach you took here.

> +/*
> + * struct page_hinting_config: holds the information supplied by the balloon
> + * device to page hinting.
> + * @hint_pages:                Callback which reports the isolated pages
> + *                     synchornously to the host.
> + * @max_pages:         Maxmimum pages that are going to be hinted to the host
> + *                     at a time of granularity >= PAGE_HINTING_MIN_ORDER.
> + */
> +struct page_hinting_config {
> +       void (*hint_pages)(struct list_head *list);
> +       int max_pages;
> +};
> +
> +extern int __isolate_free_page(struct page *page, unsigned int order);
> +extern void __free_one_page(struct page *page, unsigned long pfn,
> +                           struct zone *zone, unsigned int order,
> +                           int migratetype, bool hint);
> +#ifdef CONFIG_PAGE_HINTING
> +void page_hinting_enqueue(struct page *page, int order);
> +int page_hinting_enable(const struct page_hinting_config *conf);
> +void page_hinting_disable(void);
> +#else
> +static inline void page_hinting_enqueue(struct page *page, int order)
> +{
> +}
> +
> +static inline int page_hinting_enable(const struct page_hinting_config *conf)
> +{
> +       return -EOPNOTSUPP;
> +}
> +
> +static inline void page_hinting_disable(void)
> +{
> +}
> +#endif
> +#endif /* _LINUX_PAGE_HINTING_H */
> diff --git a/mm/Kconfig b/mm/Kconfig
> index f0c76ba47695..e97fab429d9b 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -765,4 +765,10 @@ config GUP_BENCHMARK
>  config ARCH_HAS_PTE_SPECIAL
>         bool
>
> +# PAGE_HINTING will allow the guest to report the free pages to the
> +# host in fixed chunks as soon as the threshold is reached.
> +config PAGE_HINTING
> +       bool
> +       def_bool n
> +       depends on X86_64
>  endmenu

If there are no issue with using the term "PAGE_HINTING" I guess I
will update my patch set to use that term instead of aeration.

> diff --git a/mm/Makefile b/mm/Makefile
> index ac5e5ba78874..73be49177656 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -94,6 +94,7 @@ obj-$(CONFIG_Z3FOLD)  += z3fold.o
>  obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
>  obj-$(CONFIG_CMA)      += cma.o
>  obj-$(CONFIG_MEMORY_BALLOON) += balloon_compaction.o
> +obj-$(CONFIG_PAGE_HINTING) += page_hinting.o
>  obj-$(CONFIG_PAGE_EXTENSION) += page_ext.o
>  obj-$(CONFIG_CMA_DEBUGFS) += cma_debug.o
>  obj-$(CONFIG_USERFAULTFD) += userfaultfd.o
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d66bc8abe0af..8a44338bd04e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -69,6 +69,7 @@
>  #include <linux/lockdep.h>
>  #include <linux/nmi.h>
>  #include <linux/psi.h>
> +#include <linux/page_hinting.h>
>
>  #include <asm/sections.h>
>  #include <asm/tlbflush.h>
> @@ -874,10 +875,10 @@ compaction_capture(struct capture_control *capc, struct page *page,
>   * -- nyc
>   */
>
> -static inline void __free_one_page(struct page *page,
> +inline void __free_one_page(struct page *page,
>                 unsigned long pfn,
>                 struct zone *zone, unsigned int order,
> -               int migratetype)
> +               int migratetype, bool hint)
>  {
>         unsigned long combined_pfn;
>         unsigned long uninitialized_var(buddy_pfn);
> @@ -980,7 +981,8 @@ static inline void __free_one_page(struct page *page,
>                                 migratetype);
>         else
>                 add_to_free_area(page, &zone->free_area[order], migratetype);
> -
> +       if (hint)
> +               page_hinting_enqueue(page, order);
>  }

I'm not sure I am a fan of the way the word "hint" is used here. At
first I thought this was supposed to be !hint since I thought hint
meant that it was a hinted page, not that we need to record that this
page has been freed. Maybe "record" or "report" might be a better word
to use here.

>  /*
> @@ -1263,7 +1265,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>                 if (unlikely(isolated_pageblocks))
>                         mt = get_pageblock_migratetype(page);
>
> -               __free_one_page(page, page_to_pfn(page), zone, 0, mt);
> +               __free_one_page(page, page_to_pfn(page), zone, 0, mt, true);
>                 trace_mm_page_pcpu_drain(page, 0, mt);
>         }
>         spin_unlock(&zone->lock);
> @@ -1272,14 +1274,14 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  static void free_one_page(struct zone *zone,
>                                 struct page *page, unsigned long pfn,
>                                 unsigned int order,
> -                               int migratetype)
> +                               int migratetype, bool hint)
>  {
>         spin_lock(&zone->lock);
>         if (unlikely(has_isolate_pageblock(zone) ||
>                 is_migrate_isolate(migratetype))) {
>                 migratetype = get_pfnblock_migratetype(page, pfn);
>         }
> -       __free_one_page(page, pfn, zone, order, migratetype);
> +       __free_one_page(page, pfn, zone, order, migratetype, hint);
>         spin_unlock(&zone->lock);
>  }
>
> @@ -1369,7 +1371,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
>         migratetype = get_pfnblock_migratetype(page, pfn);
>         local_irq_save(flags);
>         __count_vm_events(PGFREE, 1 << order);
> -       free_one_page(page_zone(page), page, pfn, order, migratetype);
> +       free_one_page(page_zone(page), page, pfn, order, migratetype, true);
>         local_irq_restore(flags);
>  }
>
> @@ -2969,7 +2971,7 @@ static void free_unref_page_commit(struct page *page, unsigned long pfn)
>          */
>         if (migratetype >= MIGRATE_PCPTYPES) {
>                 if (unlikely(is_migrate_isolate(migratetype))) {
> -                       free_one_page(zone, page, pfn, 0, migratetype);
> +                       free_one_page(zone, page, pfn, 0, migratetype, true);
>                         return;
>                 }
>                 migratetype = MIGRATE_MOVABLE;
> diff --git a/mm/page_hinting.c b/mm/page_hinting.c
> new file mode 100644
> index 000000000000..0bfa09f8c3ed
> --- /dev/null
> +++ b/mm/page_hinting.c
> @@ -0,0 +1,250 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/*
> + * Page hinting core infrastructure to enable a VM to report free pages to its
> + * hypervisor.
> + *
> + * Copyright Red Hat, Inc. 2019
> + *
> + * Author(s): Nitesh Narayan Lal <nitesh@redhat.com>
> + */
> +
> +#include <linux/mm.h>
> +#include <linux/slab.h>
> +#include <linux/page_hinting.h>
> +#include <linux/kvm_host.h>
> +
> +/*
> + * struct zone_free_area: For a single zone across NUMA nodes, it holds the
> + * bitmap pointer to track the free pages and other required parameters
> + * used to recover these pages by scanning the bitmap.
> + * @bitmap:            Pointer to the bitmap in PAGE_HINTING_MIN_ORDER
> + *                     granularity.
> + * @base_pfn:          Starting PFN value for the zone whose bitmap is stored.
> + * @end_pfn:           Indicates the last PFN value for the zone.
> + * @free_pages:                Tracks the number of free pages of granularity
> + *                     PAGE_HINTING_MIN_ORDER.
> + * @nbits:             Indicates the total size of the bitmap in bits allocated
> + *                     at the time of initialization.
> + */
> +struct zone_free_area {
> +       unsigned long *bitmap;
> +       unsigned long base_pfn;
> +       unsigned long end_pfn;
> +       atomic_t free_pages;
> +       unsigned long nbits;
> +} free_area[MAX_NR_ZONES];
> +

You still haven't addressed the NUMA issue I pointed out with v10. You
are only able to address the first set of zones with this setup. As
such you can end up missing large sections of memory if it is split
over multiple nodes.

> +static void init_hinting_wq(struct work_struct *work);
> +static DEFINE_MUTEX(page_hinting_init);
> +const struct page_hinting_config *page_hitning_conf;
> +struct work_struct hinting_work;
> +atomic_t page_hinting_active;
> +
> +void free_area_cleanup(int nr_zones)
> +{

I'm not sure why you are passing nr_zones as an argument here. Won't
this always be MAX_NR_ZONES?

> +       int zone_idx;
> +
> +       for (zone_idx = 0; zone_idx < nr_zones; zone_idx++) {
> +               bitmap_free(free_area[zone_idx].bitmap);
> +               free_area[zone_idx].base_pfn = 0;
> +               free_area[zone_idx].end_pfn = 0;
> +               free_area[zone_idx].nbits = 0;
> +               atomic_set(&free_area[zone_idx].free_pages, 0);
> +       }
> +}
> +
> +int page_hinting_enable(const struct page_hinting_config *conf)
> +{
> +       unsigned long bitmap_size = 0;
> +       int zone_idx = 0, ret = -EBUSY;
> +       struct zone *zone;
> +
> +       mutex_lock(&page_hinting_init);
> +       if (!page_hitning_conf) {
> +               for_each_populated_zone(zone) {

So for_each_populated_zone will go through all of the NUMA nodes. So
if I am not mistaken you will overwrite the free_area values of all
the previous nodes with the last node in the system. So if we have a
setup that has all the memory in the first node, and none in the
second it would effectively disable free page hinting would it not?

> +                       zone_idx = zone_idx(zone);
> +#ifdef CONFIG_ZONE_DEVICE
> +                       if (zone_idx == ZONE_DEVICE)
> +                               continue;
> +#endif
> +                       spin_lock(&zone->lock);
> +                       if (free_area[zone_idx].base_pfn) {
> +                               free_area[zone_idx].base_pfn =
> +                                       min(free_area[zone_idx].base_pfn,
> +                                           zone->zone_start_pfn);
> +                               free_area[zone_idx].end_pfn =
> +                                       max(free_area[zone_idx].end_pfn,
> +                                           zone->zone_start_pfn +
> +                                           zone->spanned_pages);
> +                       } else {
> +                               free_area[zone_idx].base_pfn =
> +                                       zone->zone_start_pfn;
> +                               free_area[zone_idx].end_pfn =
> +                                       zone->zone_start_pfn +
> +                                       zone->spanned_pages;
> +                       }
> +                       spin_unlock(&zone->lock);
> +               }
> +
> +               for (zone_idx = 0; zone_idx < MAX_NR_ZONES; zone_idx++) {
> +                       unsigned long pages = free_area[zone_idx].end_pfn -
> +                                       free_area[zone_idx].base_pfn;
> +                       bitmap_size = (pages >> PAGE_HINTING_MIN_ORDER) + 1;
> +                       if (!bitmap_size)
> +                               continue;
> +                       free_area[zone_idx].bitmap = bitmap_zalloc(bitmap_size,
> +                                                                  GFP_KERNEL);
> +                       if (!free_area[zone_idx].bitmap) {
> +                               free_area_cleanup(zone_idx);
> +                               mutex_unlock(&page_hinting_init);
> +                               return -ENOMEM;
> +                       }
> +                       free_area[zone_idx].nbits = bitmap_size;
> +               }

So this is the bit that still needs to address hotplug right? I would
imagine you need to reallocate this if the spanned_pages range changes
correct?

> +               page_hitning_conf = conf;
> +               INIT_WORK(&hinting_work, init_hinting_wq);
> +               ret = 0;
> +       }
> +       mutex_unlock(&page_hinting_init);
> +       return ret;
> +}
> +EXPORT_SYMBOL_GPL(page_hinting_enable);
> +
> +void page_hinting_disable(void)
> +{
> +       cancel_work_sync(&hinting_work);
> +       page_hitning_conf = NULL;
> +       free_area_cleanup(MAX_NR_ZONES);
> +}
> +EXPORT_SYMBOL_GPL(page_hinting_disable);
> +
> +static unsigned long pfn_to_bit(struct page *page, int zone_idx)
> +{
> +       unsigned long bitnr;
> +
> +       bitnr = (page_to_pfn(page) - free_area[zone_idx].base_pfn)
> +                        >> PAGE_HINTING_MIN_ORDER;
> +       return bitnr;
> +}
> +
> +static void release_buddy_pages(struct list_head *pages)
> +{
> +       int mt = 0, zone_idx, order;
> +       struct page *page, *next;
> +       unsigned long bitnr;
> +       struct zone *zone;
> +
> +       list_for_each_entry_safe(page, next, pages, lru) {
> +               zone_idx = page_zonenum(page);
> +               zone = page_zone(page);
> +               bitnr = pfn_to_bit(page, zone_idx);
> +               spin_lock(&zone->lock);
> +               list_del(&page->lru);
> +               order = page_private(page);
> +               set_page_private(page, 0);
> +               mt = get_pageblock_migratetype(page);
> +               __free_one_page(page, page_to_pfn(page), zone,
> +                               order, mt, false);
> +               spin_unlock(&zone->lock);
> +       }
> +}
> +
> +static void bm_set_pfn(struct page *page)
> +{
> +       struct zone *zone = page_zone(page);
> +       int zone_idx = page_zonenum(page);
> +       unsigned long bitnr = 0;
> +
> +       lockdep_assert_held(&zone->lock);
> +       bitnr = pfn_to_bit(page, zone_idx);
> +       /*
> +        * TODO: fix possible underflows.
> +        */
> +       if (free_area[zone_idx].bitmap &&
> +           bitnr < free_area[zone_idx].nbits &&
> +           !test_and_set_bit(bitnr, free_area[zone_idx].bitmap))
> +               atomic_inc(&free_area[zone_idx].free_pages);
> +}
> +
> +static void scan_zone_free_area(int zone_idx, int free_pages)
> +{
> +       int ret = 0, order, isolated_cnt = 0;
> +       unsigned long set_bit, start = 0;
> +       LIST_HEAD(isolated_pages);
> +       struct page *page;
> +       struct zone *zone;
> +
> +       for (;;) {
> +               ret = 0;
> +               set_bit = find_next_bit(free_area[zone_idx].bitmap,
> +                                       free_area[zone_idx].nbits, start);
> +               if (set_bit >= free_area[zone_idx].nbits)
> +                       break;
> +               page = pfn_to_online_page((set_bit << PAGE_HINTING_MIN_ORDER) +
> +                               free_area[zone_idx].base_pfn);
> +               if (!page)
> +                       continue;
> +               zone = page_zone(page);
> +               spin_lock(&zone->lock);
> +
> +               if (PageBuddy(page) && page_private(page) >=
> +                   PAGE_HINTING_MIN_ORDER) {
> +                       order = page_private(page);
> +                       ret = __isolate_free_page(page, order);
> +               }
> +               clear_bit(set_bit, free_area[zone_idx].bitmap);
> +               atomic_dec(&free_area[zone_idx].free_pages);
> +               spin_unlock(&zone->lock);
> +               if (ret) {
> +                       /*
> +                        * restoring page order to use it while releasing
> +                        * the pages back to the buddy.
> +                        */
> +                       set_page_private(page, order);
> +                       list_add_tail(&page->lru, &isolated_pages);
> +                       isolated_cnt++;
> +                       if (isolated_cnt == page_hitning_conf->max_pages) {
> +                               page_hitning_conf->hint_pages(&isolated_pages);
> +                               release_buddy_pages(&isolated_pages);
> +                               isolated_cnt = 0;
> +                       }
> +               }
> +               start = set_bit + 1;
> +       }
> +       if (isolated_cnt) {
> +               page_hitning_conf->hint_pages(&isolated_pages);
> +               release_buddy_pages(&isolated_pages);
> +       }
> +}
> +

I really worry that this loop is going to become more expensive as the
size of memory increases. For example if we hint on just 16 pages we
would have to walk something like 4K bits, 512 longs, if a system had
64G of memory. Have you considered testing with a larger memory
footprint to see if it has an impact on performance?

> +static void init_hinting_wq(struct work_struct *work)
> +{
> +       int zone_idx, free_pages;
> +
> +       atomic_set(&page_hinting_active, 1);
> +       for (zone_idx = 0; zone_idx < MAX_NR_ZONES; zone_idx++) {
> +               free_pages = atomic_read(&free_area[zone_idx].free_pages);
> +               if (free_pages >= page_hitning_conf->max_pages)
> +                       scan_zone_free_area(zone_idx, free_pages);
> +       }
> +       atomic_set(&page_hinting_active, 0);
> +}
> +
> +void page_hinting_enqueue(struct page *page, int order)
> +{
> +       int zone_idx;
> +
> +       if (!page_hitning_conf || order < PAGE_HINTING_MIN_ORDER)
> +               return;

I would think it is going to be expensive to be jumping into this
function for every freed page. You should probably have an inline
taking care of the order check before you even get here since it would
be faster that way.

> +
> +       bm_set_pfn(page);
> +       if (atomic_read(&page_hinting_active))
> +               return;

So I would think this piece is racy. Specifically if you set a PFN
that is somewhere below the PFN you are currently processing in your
scan it is going to remain unset until you have another page freed
after the scan is completed. I would worry you can end up with a batch
free of memory resulting in a group of pages sitting at the start of
your bitmap unhinted.

In my patches I resolved this by looping through all of the zones,
however your approach is missing the necessary pieces to make that
safe as you could end up in a soft lockup with the scanning thread
spinning on a noisy system.

> +       zone_idx = zone_idx(page_zone(page));
> +       if (atomic_read(&free_area[zone_idx].free_pages) >=
> +                       page_hitning_conf->max_pages) {
> +               int cpu = smp_processor_id();
> +
> +               queue_work_on(cpu, system_wq, &hinting_work);
> +       }
> +}

