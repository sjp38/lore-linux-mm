Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id ECEC88E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 11:15:37 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id d18so16425800pfe.0
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 08:15:37 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id c22si648701pgb.254.2019.01.14.08.15.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 08:15:36 -0800 (PST)
Message-ID: <a041b1fa9b8d94f89c544015f8ff88d29343645d.camel@linux.intel.com>
Subject: Re: [PATCH v9] mm/page_alloc.c: memory_hotplug: free pages as
 higher order
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Mon, 14 Jan 2019 08:15:35 -0800
In-Reply-To: <fa3dc06536a8ba980c4434806204017a@codeaurora.org>
References: <1547098543-26452-1-git-send-email-arunks@codeaurora.org>
	 <f65b1b22426855ff261b3af719e58eded576a168.camel@linux.intel.com>
	 <fa3dc06536a8ba980c4434806204017a@codeaurora.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: arunks.linux@gmail.com, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, getarunks@gmail.com

On Mon, 2019-01-14 at 19:29 +0530, Arun KS wrote:
> On 2019-01-10 21:53, Alexander Duyck wrote:
> > On Thu, 2019-01-10 at 11:05 +0530, Arun KS wrote:
> > > When freeing pages are done with higher order, time spent on 
> > > coalescing
> > > pages by buddy allocator can be reduced.  With section size of 256MB, 
> > > hot
> > > add latency of a single section shows improvement from 50-60 ms to 
> > > less
> > > than 1 ms, hence improving the hot add latency by 60 times.  Modify
> > > external providers of online callback to align with the change.
> > > 
> > > Signed-off-by: Arun KS <arunks@codeaurora.org>
> > > Acked-by: Michal Hocko <mhocko@suse.com>
> > > Reviewed-by: Oscar Salvador <osalvador@suse.de>
> > 
> > So I decided to give this one last thorough review and I think I might
> > have found a few more minor issues, but not anything that is
> > necessarily a showstopper.
> > 
> > Reviewed-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 
> > > ---
> > > Changes since v8:
> > > - Remove return type change for online_page_callback.
> > > - Use consistent names for external online_page providers.
> > > - Fix onlined_pages accounting.
> > > 
> > > Changes since v7:
> > > - Rebased to 5.0-rc1.
> > > - Fixed onlined_pages accounting.
> > > - Added comment for return value of online_page_callback.
> > > - Renamed xen_bring_pgs_online to xen_online_pages.
> > > 
> > > Changes since v6:
> > > - Rebased to 4.20
> > > - Changelog updated.
> > > - No improvement seen on arm64, hence removed removal of prefetch.
> > > 
> > > Changes since v5:
> > > - Rebased to 4.20-rc1.
> > > - Changelog updated.
> > > 
> > > Changes since v4:
> > > - As suggested by Michal Hocko,
> > > - Simplify logic in online_pages_block() by using get_order().
> > > - Seperate out removal of prefetch from __free_pages_core().
> > > 
> > > Changes since v3:
> > > - Renamed _free_pages_boot_core -> __free_pages_core.
> > > - Removed prefetch from __free_pages_core.
> > > - Removed xen_online_page().
> > > 
> > > Changes since v2:
> > > - Reuse code from __free_pages_boot_core().
> > > 
> > > Changes since v1:
> > > - Removed prefetch().
> > > 
> > > Changes since RFC:
> > > - Rebase.
> > > - As suggested by Michal Hocko remove pages_per_block.
> > > - Modifed external providers of online_page_callback.
> > > 
> > > v8: https://lore.kernel.org/patchwork/patch/1030332/
> > > v7: https://lore.kernel.org/patchwork/patch/1028908/
> > > v6: https://lore.kernel.org/patchwork/patch/1007253/
> > > v5: https://lore.kernel.org/patchwork/patch/995739/
> > > v4: https://lore.kernel.org/patchwork/patch/995111/
> > > v3: https://lore.kernel.org/patchwork/patch/992348/
> > > v2: https://lore.kernel.org/patchwork/patch/991363/
> > > v1: https://lore.kernel.org/patchwork/patch/989445/
> > > RFC: https://lore.kernel.org/patchwork/patch/984754/
> > > ---
> > > ---
> > >  drivers/hv/hv_balloon.c        |  4 ++--
> > >  drivers/xen/balloon.c          | 15 ++++++++++-----
> > >  include/linux/memory_hotplug.h |  2 +-
> > >  mm/internal.h                  |  1 +
> > >  mm/memory_hotplug.c            | 37 
> > > +++++++++++++++++++++++++------------
> > >  mm/page_alloc.c                |  8 ++++----
> > >  6 files changed, 43 insertions(+), 24 deletions(-)
> > > 
> > > diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
> > > index 5301fef..55d79f8 100644
> > > --- a/drivers/hv/hv_balloon.c
> > > +++ b/drivers/hv/hv_balloon.c
> > > @@ -771,7 +771,7 @@ static void hv_mem_hot_add(unsigned long start, 
> > > unsigned long size,
> > >  	}
> > >  }
> > > 
> > > -static void hv_online_page(struct page *pg)
> > > +static void hv_online_page(struct page *pg, unsigned int order)
> > >  {
> > >  	struct hv_hotadd_state *has;
> > >  	unsigned long flags;
> > > @@ -783,7 +783,7 @@ static void hv_online_page(struct page *pg)
> > >  		if ((pfn < has->start_pfn) || (pfn >= has->end_pfn))
> > >  			continue;
> > > 
> > 
> > I haven't followed earlier reviews, but do we know for certain the
> > entire range being onlined will fit within a single hv_hotadd_state? If
> > nothing else it seems like this check should be updated so that we are
> > checking to verify that pfn + (1UL << order) is less than or equal to
> > has->end_pfn.
> 
> Good catch. I ll change the check to,
>           if ((pfn < has->start_pfn) ||
>                    (pfn + (1UL << order) >= has->end_pfn))
>                continue;
> 
> > 
> > > -		hv_page_online_one(has, pg);
> > > +		hv_bring_pgs_online(has, pfn, (1UL << order));
> > >  		break;
> > >  	}
> > >  	spin_unlock_irqrestore(&dm_device.ha_lock, flags);
> > > diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> > > index ceb5048..d107447 100644
> > > --- a/drivers/xen/balloon.c
> > > +++ b/drivers/xen/balloon.c
> > > @@ -369,14 +369,19 @@ static enum bp_state 
> > > reserve_additional_memory(void)
> > >  	return BP_ECANCELED;
> > >  }
> > > 
> > > -static void xen_online_page(struct page *page)
> > > +static void xen_online_page(struct page *page, unsigned int order)
> > >  {
> > > -	__online_page_set_limits(page);
> > > +	unsigned long i, size = (1 << order);
> > > +	unsigned long start_pfn = page_to_pfn(page);
> > > +	struct page *p;
> > > 
> > > +	pr_debug("Online %lu pages starting at pfn 0x%lx\n", size, 
> > > start_pfn);
> > >  	mutex_lock(&balloon_mutex);
> > > -
> > > -	__balloon_append(page);
> > > -
> > > +	for (i = 0; i < size; i++) {
> > > +		p = pfn_to_page(start_pfn + i);
> > > +		__online_page_set_limits(p);
> > > +		__balloon_append(p);
> > > +	}
> > >  	mutex_unlock(&balloon_mutex);
> > >  }
> > > 
> > > diff --git a/include/linux/memory_hotplug.h 
> > > b/include/linux/memory_hotplug.h
> > > index 07da5c6..e368730 100644
> > > --- a/include/linux/memory_hotplug.h
> > > +++ b/include/linux/memory_hotplug.h
> > > @@ -87,7 +87,7 @@ extern int test_pages_in_a_zone(unsigned long 
> > > start_pfn, unsigned long end_pfn,
> > >  	unsigned long *valid_start, unsigned long *valid_end);
> > >  extern void __offline_isolated_pages(unsigned long, unsigned long);
> > > 
> > > -typedef void (*online_page_callback_t)(struct page *page);
> > > +typedef void (*online_page_callback_t)(struct page *page, unsigned 
> > > int order);
> > > 
> > >  extern int set_online_page_callback(online_page_callback_t callback);
> > >  extern int restore_online_page_callback(online_page_callback_t 
> > > callback);
> > > diff --git a/mm/internal.h b/mm/internal.h
> > > index f4a7bb0..536bc2a 100644
> > > --- a/mm/internal.h
> > > +++ b/mm/internal.h
> > > @@ -163,6 +163,7 @@ static inline struct page 
> > > *pageblock_pfn_to_page(unsigned long start_pfn,
> > >  extern int __isolate_free_page(struct page *page, unsigned int 
> > > order);
> > >  extern void memblock_free_pages(struct page *page, unsigned long pfn,
> > >  					unsigned int order);
> > > +extern void __free_pages_core(struct page *page, unsigned int order);
> > >  extern void prep_compound_page(struct page *page, unsigned int 
> > > order);
> > >  extern void post_alloc_hook(struct page *page, unsigned int order,
> > >  					gfp_t gfp_flags);
> > > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > > index b9a667d..77dff24 100644
> > > --- a/mm/memory_hotplug.c
> > > +++ b/mm/memory_hotplug.c
> > > @@ -47,7 +47,7 @@
> > >   * and restore_online_page_callback() for generic callback restore.
> > >   */
> > > 
> > > -static void generic_online_page(struct page *page);
> > > +static void generic_online_page(struct page *page, unsigned int 
> > > order);
> > > 
> > >  static online_page_callback_t online_page_callback = 
> > > generic_online_page;
> > >  static DEFINE_MUTEX(online_page_callback_lock);
> > > @@ -656,26 +656,39 @@ void __online_page_free(struct page *page)
> > >  }
> > >  EXPORT_SYMBOL_GPL(__online_page_free);
> > > 
> > > -static void generic_online_page(struct page *page)
> > > +static void generic_online_page(struct page *page, unsigned int 
> > > order)
> > >  {
> > > -	__online_page_set_limits(page);
> > > -	__online_page_increment_counters(page);
> > > -	__online_page_free(page);
> > > +	__free_pages_core(page, order);
> > > +	totalram_pages_add(1UL << order);
> > > +#ifdef CONFIG_HIGHMEM
> > > +	if (PageHighMem(page))
> > > +		totalhigh_pages_add(1UL << order);
> > > +#endif
> > > +}
> > > +
> > > +static int online_pages_blocks(unsigned long start, unsigned long 
> > > nr_pages)
> > > +{
> > > +	unsigned long end = start + nr_pages;
> > > +	int order, ret, onlined_pages = 0;
> > > +
> > > +	while (start < end) {
> > > +		order = min(MAX_ORDER - 1,
> > > +			get_order(PFN_PHYS(end) - PFN_PHYS(start)));
> > 
> > So this is mostly just optimization related so you can ignore this
> > suggestion if you want. I was looking at this and it occurred to me
> > that I don't think you need to convert this to a physical address do
> > you?
> > 
> > Couldn't you just do something like the following:
> > 		if ((end - start) >= (1UL << (MAX_ORDER - 1))
> > 			order = MAX_ORDER - 1;
> > 		else
> > 			order = __fls(end - start);
> > 
> > I would think this would save you a few steps in terms of conversions
> > and such since you are already working in page frame numbers anyway so
> > a block of 8 pfns would represent an order 3 page wouldn't it?
> > 
> > Also it seems like an alternative to using "end" would be to just track
> > nr_pages. Then you wouldn't have to do the "end - start" math in a few
> > spots as long as you remembered to decrement nr_pages by the amount you
> > increment start by.
> 
> Thanks for that. How about this?
> 
> static int online_pages_blocks(unsigned long start, unsigned long 
> nr_pages)
> {
>          unsigned long end = start + nr_pages;
>          int order;
> 
>          while (nr_pages) {
>                  if (nr_pages >= (1UL << (MAX_ORDER - 1)))
>                          order = MAX_ORDER - 1;
>                  else
>                          order = __fls(nr_pages);
> 
>                  (*online_page_callback)(pfn_to_page(start), order);
>                  nr_pages -= (1UL << order);
>                  start += (1UL << order);
>          }
>          return end - start;
> }
> 
> Regards,
> Arun

You would still need to return onlined_pages or something similar at
the end of the function. The problem is end - start should always be 0
if your loop succeeds. Either that or you could save of nr_pages to
onlined_pages directly and then return that and the end of the
function.
