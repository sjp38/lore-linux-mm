Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CAF386B0003
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 03:55:08 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c26-v6so4610762eda.7
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 00:55:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h20-v6si317501ejb.309.2018.10.11.00.55.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 00:55:07 -0700 (PDT)
Date: Thu, 11 Oct 2018 09:55:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 1/2] memory_hotplug: Free pages as higher order
Message-ID: <20181011075503.GQ5873@dhcp22.suse.cz>
References: <1538727006-5727-1-git-send-email-arunks@codeaurora.org>
 <72215e75-6c7e-0aef-c06e-e3aba47cf806@suse.cz>
 <efb65160af41d0e18cb2dcb30c2fb86a@codeaurora.org>
 <20181010173334.GL5873@dhcp22.suse.cz>
 <a2d576a5fc82cdf54fc89409686e58f5@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a2d576a5fc82cdf54fc89409686e58f5@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, akpm@linux-foundation.org, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, gregkh@linuxfoundation.org, osalvador@suse.de, malat@debian.org, kirill.shutemov@linux.intel.com, jrdr.linux@gmail.com, yasu.isimatu@gmail.com, mgorman@techsingularity.net, aaron.lu@intel.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com

On Thu 11-10-18 07:59:32, Arun KS wrote:
> On 2018-10-10 23:03, Michal Hocko wrote:
> > On Wed 10-10-18 22:26:41, Arun KS wrote:
> > > On 2018-10-10 21:00, Vlastimil Babka wrote:
> > > > On 10/5/18 10:10 AM, Arun KS wrote:
> > > > > When free pages are done with higher order, time spend on
> > > > > coalescing pages by buddy allocator can be reduced. With
> > > > > section size of 256MB, hot add latency of a single section
> > > > > shows improvement from 50-60 ms to less than 1 ms, hence
> > > > > improving the hot add latency by 60%. Modify external
> > > > > providers of online callback to align with the change.
> > > > >
> > > > > Signed-off-by: Arun KS <arunks@codeaurora.org>
> > > >
> > > > [...]
> > > >
> > > > > @@ -655,26 +655,44 @@ void __online_page_free(struct page *page)
> > > > >  }
> > > > >  EXPORT_SYMBOL_GPL(__online_page_free);
> > > > >
> > > > > -static void generic_online_page(struct page *page)
> > > > > +static int generic_online_page(struct page *page, unsigned int order)
> > > > >  {
> > > > > -	__online_page_set_limits(page);
> > > >
> > > > This is now not called anymore, although the xen/hv variants still do
> > > > it. The function seems empty these days, maybe remove it as a followup
> > > > cleanup?
> > > >
> > > > > -	__online_page_increment_counters(page);
> > > > > -	__online_page_free(page);
> > > > > +	__free_pages_core(page, order);
> > > > > +	totalram_pages += (1UL << order);
> > > > > +#ifdef CONFIG_HIGHMEM
> > > > > +	if (PageHighMem(page))
> > > > > +		totalhigh_pages += (1UL << order);
> > > > > +#endif
> > > >
> > > > __online_page_increment_counters() would have used
> > > > adjust_managed_page_count() which would do the changes under
> > > > managed_page_count_lock. Are we safe without the lock? If yes, there
> > > > should perhaps be a comment explaining why.
> > > 
> > > Looks unsafe without managed_page_count_lock.
> > 
> > Why does it matter actually? We cannot online/offline memory in
> > parallel. This is not the case for the boot where we initialize memory
> > in parallel on multiple nodes. So this seems to be safe currently unless
> > I am missing something. A comment explaining that would be helpful
> > though.
> 
> Other main callers of adjust_manage_page_count(),
> 
> static inline void free_reserved_page(struct page *page)
> {
>         __free_reserved_page(page);
>         adjust_managed_page_count(page, 1);
> }
> 
> static inline void mark_page_reserved(struct page *page)
> {
>         SetPageReserved(page);
>         adjust_managed_page_count(page, -1);
> }
> 
> Won't they race with memory hotplug?
> 
> Few more,
> ./drivers/xen/balloon.c:519:            adjust_managed_page_count(page, -1);
> ./drivers/virtio/virtio_balloon.c:175:  adjust_managed_page_count(page, -1);
> ./drivers/virtio/virtio_balloon.c:196:  adjust_managed_page_count(page, 1);
> ./mm/hugetlb.c:2158:                    adjust_managed_page_count(page, 1 <<
> h->order);

They can, and I have missed those.

-- 
Michal Hocko
SUSE Labs
