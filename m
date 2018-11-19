Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1BF5E6B1CE9
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 17:15:52 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id 135-v6so5789377itz.1
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 14:15:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 201-v6sor4412672ita.1.2018.11.19.14.15.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 14:15:51 -0800 (PST)
MIME-Version: 1.0
References: <1538727006-5727-1-git-send-email-arunks@codeaurora.org>
 <72215e75-6c7e-0aef-c06e-e3aba47cf806@suse.cz> <efb65160af41d0e18cb2dcb30c2fb86a@codeaurora.org>
 <97d8db4c-f117-8216-5f48-d5991692c867@suse.cz>
In-Reply-To: <97d8db4c-f117-8216-5f48-d5991692c867@suse.cz>
From: Wei Yang <richard.weiyang@gmail.com>
Date: Tue, 20 Nov 2018 06:15:39 +0800
Message-ID: <CADZGycYeB_sZmsFJ-RV5LQavHZNJTv1_pTrnpRjs7owhYSNKSA@mail.gmail.com>
Subject: Re: [PATCH v5 1/2] memory_hotplug: Free pages as higher order
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: arunks@codeaurora.org, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, jgross@suse.com, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, iamjoonsoo.kim@lge.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oscar Salvador <osalvador@suse.de>, Mathieu Malaterre <malat@debian.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, jrdr.linux@gmail.com, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, aaron.lu@intel.com, devel@linuxdriverproject.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xen-devel@lists.xenproject.org, vatsa@codeaurora.org, Vinayak Menon <vinmenon@codeaurora.org>, getarunks@gmail.com

On Thu, Oct 11, 2018 at 6:05 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 10/10/18 6:56 PM, Arun KS wrote:
> > On 2018-10-10 21:00, Vlastimil Babka wrote:
> >> On 10/5/18 10:10 AM, Arun KS wrote:
> >>> When free pages are done with higher order, time spend on
> >>> coalescing pages by buddy allocator can be reduced. With
> >>> section size of 256MB, hot add latency of a single section
> >>> shows improvement from 50-60 ms to less than 1 ms, hence
> >>> improving the hot add latency by 60%. Modify external
> >>> providers of online callback to align with the change.
> >>>
> >>> Signed-off-by: Arun KS <arunks@codeaurora.org>
> >>
> >> [...]
> >>
> >>> @@ -655,26 +655,44 @@ void __online_page_free(struct page *page)
> >>>  }
> >>>  EXPORT_SYMBOL_GPL(__online_page_free);
> >>>
> >>> -static void generic_online_page(struct page *page)
> >>> +static int generic_online_page(struct page *page, unsigned int order)
> >>>  {
> >>> -   __online_page_set_limits(page);
> >>
> >> This is now not called anymore, although the xen/hv variants still do
> >> it. The function seems empty these days, maybe remove it as a followup
> >> cleanup?
> >>
> >>> -   __online_page_increment_counters(page);
> >>> -   __online_page_free(page);
> >>> +   __free_pages_core(page, order);
> >>> +   totalram_pages += (1UL << order);
> >>> +#ifdef CONFIG_HIGHMEM
> >>> +   if (PageHighMem(page))
> >>> +           totalhigh_pages += (1UL << order);
> >>> +#endif
> >>
> >> __online_page_increment_counters() would have used
> >> adjust_managed_page_count() which would do the changes under
> >> managed_page_count_lock. Are we safe without the lock? If yes, there
> >> should perhaps be a comment explaining why.
> >
> > Looks unsafe without managed_page_count_lock. I think better have a
> > similar implementation of free_boot_core() in memory_hotplug.c like we
> > had in version 1 of patch. And use adjust_managed_page_count() instead
> > of page_zone(page)->managed_pages += nr_pages;
> >
> > https://lore.kernel.org/patchwork/patch/989445/
>
> Looks like deferred_free_range() has the same problem calling
> __free_pages_core() to adjust zone->managed_pages. I expect
> __free_pages_bootmem() is OK because at that point the system is still
> single-threaded?
> Could be solved by moving that out of __free_pages_core().
>

Seems deferred_free_range() is protected by
pgdat_resize_lock()/pgdat_resize_unlock().

Which protects pgdat's zones, if I am right.

> But do we care about readers potentially seeing a store tear? If yes
> then maybe these counters should be converted to atomics...
>
> > -static void generic_online_page(struct page *page)
> > +static int generic_online_page(struct page *page, unsigned int order)
> >   {
> > -     __online_page_set_limits(page);
> > -     __online_page_increment_counters(page);
> > -     __online_page_free(page);
> > +     unsigned long nr_pages = 1 << order;
> > +     struct page *p = page;
> > +
> > +     for (loop = 0 ; loop < nr_pages ; loop++, p++) {
> > +             __ClearPageReserved(p);
> > +             set_page_count(p, 0);
> > +     }
> > +
> > +     adjust_managed_page_count(page, nr_pages);
> > +     set_page_refcounted(page);
> > +     __free_pages(page, order);
> > +
> > +     return 0;
> > +}
> >
> >
> > Regards,
> > Arun
> >
>
