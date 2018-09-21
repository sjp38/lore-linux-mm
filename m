Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3FF2A8E0002
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 11:43:06 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j17-v6so12083792oii.8
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 08:43:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k67-v6sor16303648otc.153.2018.09.21.08.43.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Sep 2018 08:43:04 -0700 (PDT)
MIME-Version: 1.0
References: <1537522709-7519-1-git-send-email-arunks@codeaurora.org>
In-Reply-To: <1537522709-7519-1-git-send-email-arunks@codeaurora.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 21 Sep 2018 08:42:52 -0700
Message-ID: <CAPcyv4ijAitQwK1JBpxQ_wBS9afUKFzMdpq1se7aAw+cJk-24Q@mail.gmail.com>
Subject: Re: [PATCH] memory_hotplug: Free pages as higher order
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arunks@codeaurora.org
Cc: "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Pavel Tatashin <pasha.tatashin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, osalvador@suse.de, malat@debian.org, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, devel@linuxdriverproject.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, xen-devel <xen-devel@lists.xenproject.org>, svaddagi@codeaurora.org, vinmenon@codeaurora.org

On Fri, Sep 21, 2018 at 2:40 AM Arun KS <arunks@codeaurora.org> wrote:
>
> When free pages are done with higher order, time spend on
> coalescing pages by buddy allocator can be reduced. With
> section size of 256MB, hot add latency of a single section
> shows improvement from 50-60 ms to less than 1 ms, hence
> improving the hot add latency by 60%.
>
> Modify external providers of online callback to align with
> the change.
>
> Signed-off-by: Arun KS <arunks@codeaurora.org>
>
> ---
>
> Changes since RFC:
> - Rebase.
> - As suggested by Michal Hocko remove pages_per_block.
> - Modifed external providers of online_page_callback.
>
> RFC:
> https://lore.kernel.org/patchwork/patch/984754/
> ---
>  drivers/hv/hv_balloon.c        |  6 +++--
>  drivers/xen/balloon.c          | 18 +++++++++++---
>  include/linux/memory_hotplug.h |  2 +-
>  mm/memory_hotplug.c            | 55 +++++++++++++++++++++++++++++++++---------
>  4 files changed, 63 insertions(+), 18 deletions(-)
>
> diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
> index b1b7880..c5bc0b5 100644
> --- a/drivers/hv/hv_balloon.c
> +++ b/drivers/hv/hv_balloon.c
> @@ -771,7 +771,7 @@ static void hv_mem_hot_add(unsigned long start, unsigned long size,
>         }
>  }
>
> -static void hv_online_page(struct page *pg)
> +static int hv_online_page(struct page *pg, unsigned int order)
>  {
>         struct hv_hotadd_state *has;
>         unsigned long flags;
> @@ -783,10 +783,12 @@ static void hv_online_page(struct page *pg)
>                 if ((pfn < has->start_pfn) || (pfn >= has->end_pfn))
>                         continue;
>
> -               hv_page_online_one(has, pg);
> +               hv_bring_pgs_online(has, pfn, (1UL << order));
>                 break;
>         }
>         spin_unlock_irqrestore(&dm_device.ha_lock, flags);
> +
> +       return 0;
>  }
>
>  static int pfn_covered(unsigned long start_pfn, unsigned long pfn_cnt)
> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> index e12bb25..010cf4d 100644
> --- a/drivers/xen/balloon.c
> +++ b/drivers/xen/balloon.c
> @@ -390,8 +390,8 @@ static enum bp_state reserve_additional_memory(void)
>
>         /*
>          * add_memory_resource() will call online_pages() which in its turn
> -        * will call xen_online_page() callback causing deadlock if we don't
> -        * release balloon_mutex here. Unlocking here is safe because the
> +        * will call xen_bring_pgs_online() callback causing deadlock if we
> +        * don't release balloon_mutex here. Unlocking here is safe because the
>          * callers drop the mutex before trying again.
>          */
>         mutex_unlock(&balloon_mutex);
> @@ -422,6 +422,18 @@ static void xen_online_page(struct page *page)
>         mutex_unlock(&balloon_mutex);
>  }
>
> +static int xen_bring_pgs_online(struct page *pg, unsigned int order)
> +{
> +       unsigned long i, size = (1 << order);
> +       unsigned long start_pfn = page_to_pfn(pg);
> +
> +       pr_debug("Online %lu pages starting at pfn 0x%lx\n", size, start_pfn);
> +       for (i = 0; i < size; i++)
> +               xen_online_page(pfn_to_page(start_pfn + i));
> +
> +       return 0;
> +}
> +
>  static int xen_memory_notifier(struct notifier_block *nb, unsigned long val, void *v)
>  {
>         if (val == MEM_ONLINE)
> @@ -744,7 +756,7 @@ static int __init balloon_init(void)
>         balloon_stats.max_retry_count = RETRY_UNLIMITED;
>
>  #ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
> -       set_online_page_callback(&xen_online_page);
> +       set_online_page_callback(&xen_bring_pgs_online);
>         register_memory_notifier(&xen_memory_nb);
>         register_sysctl_table(xen_root);
>
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 34a2822..7b04c1d 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -87,7 +87,7 @@ extern int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
>         unsigned long *valid_start, unsigned long *valid_end);
>  extern void __offline_isolated_pages(unsigned long, unsigned long);
>
> -typedef void (*online_page_callback_t)(struct page *page);
> +typedef int (*online_page_callback_t)(struct page *page, unsigned int order);
>
>  extern int set_online_page_callback(online_page_callback_t callback);
>  extern int restore_online_page_callback(online_page_callback_t callback);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 38d94b7..24c2b8e 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -47,7 +47,7 @@
>   * and restore_online_page_callback() for generic callback restore.
>   */
>
> -static void generic_online_page(struct page *page);
> +static int generic_online_page(struct page *page, unsigned int order);
>
>  static online_page_callback_t online_page_callback = generic_online_page;
>  static DEFINE_MUTEX(online_page_callback_lock);
> @@ -655,26 +655,57 @@ void __online_page_free(struct page *page)
>  }
>  EXPORT_SYMBOL_GPL(__online_page_free);
>
> -static void generic_online_page(struct page *page)
> +static int generic_online_page(struct page *page, unsigned int order)
>  {
> -       __online_page_set_limits(page);
> -       __online_page_increment_counters(page);
> -       __online_page_free(page);
> +       unsigned long nr_pages = 1 << order;
> +       struct page *p = page;
> +       unsigned int loop;
> +
> +       prefetchw(p);
> +       for (loop = 0 ; loop < (nr_pages - 1) ; loop++, p++) {
> +               prefetch(p + 1);

Given commits like:

e66eed651fd1 list: remove prefetching from regular list iterators
75d65a425c01 hlist: remove software prefetching in hlist iterators

...are you sure these explicit prefetch() calls are improving
performance? My understanding is that hardware prefetchers don't need
much help these days.
