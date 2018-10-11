Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CB7666B0010
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 04:15:14 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h24-v6so4676603eda.10
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 01:15:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w12-v6si7283923ede.46.2018.10.11.01.15.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 01:15:13 -0700 (PDT)
Date: Thu, 11 Oct 2018 10:15:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 1/2] memory_hotplug: Free pages as higher order
Message-ID: <20181011081510.GR5873@dhcp22.suse.cz>
References: <1538727006-5727-1-git-send-email-arunks@codeaurora.org>
 <72215e75-6c7e-0aef-c06e-e3aba47cf806@suse.cz>
 <efb65160af41d0e18cb2dcb30c2fb86a@codeaurora.org>
 <97d8db4c-f117-8216-5f48-d5991692c867@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <97d8db4c-f117-8216-5f48-d5991692c867@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Arun KS <arunks@codeaurora.org>, kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, akpm@linux-foundation.org, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, gregkh@linuxfoundation.org, osalvador@suse.de, malat@debian.org, kirill.shutemov@linux.intel.com, jrdr.linux@gmail.com, yasu.isimatu@gmail.com, mgorman@techsingularity.net, aaron.lu@intel.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com

On Thu 11-10-18 10:07:02, Vlastimil Babka wrote:
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
> >>> -	__online_page_set_limits(page);
> >>
> >> This is now not called anymore, although the xen/hv variants still do
> >> it. The function seems empty these days, maybe remove it as a followup
> >> cleanup?
> >>
> >>> -	__online_page_increment_counters(page);
> >>> -	__online_page_free(page);
> >>> +	__free_pages_core(page, order);
> >>> +	totalram_pages += (1UL << order);
> >>> +#ifdef CONFIG_HIGHMEM
> >>> +	if (PageHighMem(page))
> >>> +		totalhigh_pages += (1UL << order);
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
> __free_pages_core() to adjust zone->managed_pages.

deferred initialization has one thread per node AFAIR so we cannot race
on managed_pages updates. Well, unless some of the mentioned can run
that early which I dunno.

> __free_pages_bootmem() is OK because at that point the system is still
> single-threaded?
> Could be solved by moving that out of __free_pages_core().
> 
> But do we care about readers potentially seeing a store tear? If yes
> then maybe these counters should be converted to atomics...

I wanted to suggest that already but I have no idea whether the lock
instructions would cause more overhead.
-- 
Michal Hocko
SUSE Labs
