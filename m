Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id BD7B56B0003
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 22:18:29 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id w12-v6so12421733plp.9
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 19:18:29 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d9-v6si22699618pll.414.2018.10.18.19.18.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 19:18:28 -0700 (PDT)
Date: Thu, 18 Oct 2018 19:18:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 1/2] memory_hotplug: Free pages as higher order
Message-Id: <20181018191825.fcad6e28f32a3686f201acdf@linux-foundation.org>
In-Reply-To: <20181011075503.GQ5873@dhcp22.suse.cz>
References: <1538727006-5727-1-git-send-email-arunks@codeaurora.org>
	<72215e75-6c7e-0aef-c06e-e3aba47cf806@suse.cz>
	<efb65160af41d0e18cb2dcb30c2fb86a@codeaurora.org>
	<20181010173334.GL5873@dhcp22.suse.cz>
	<a2d576a5fc82cdf54fc89409686e58f5@codeaurora.org>
	<20181011075503.GQ5873@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Arun KS <arunks@codeaurora.org>, Vlastimil Babka <vbabka@suse.cz>, kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, gregkh@linuxfoundation.org, osalvador@suse.de, malat@debian.org, kirill.shutemov@linux.intel.com, jrdr.linux@gmail.com, yasu.isimatu@gmail.com, mgorman@techsingularity.net, aaron.lu@intel.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com

On Thu, 11 Oct 2018 09:55:03 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> > > > > This is now not called anymore, although the xen/hv variants still do
> > > > > it. The function seems empty these days, maybe remove it as a followup
> > > > > cleanup?
> > > > >
> > > > > > -	__online_page_increment_counters(page);
> > > > > > -	__online_page_free(page);
> > > > > > +	__free_pages_core(page, order);
> > > > > > +	totalram_pages += (1UL << order);
> > > > > > +#ifdef CONFIG_HIGHMEM
> > > > > > +	if (PageHighMem(page))
> > > > > > +		totalhigh_pages += (1UL << order);
> > > > > > +#endif
> > > > >
> > > > > __online_page_increment_counters() would have used
> > > > > adjust_managed_page_count() which would do the changes under
> > > > > managed_page_count_lock. Are we safe without the lock? If yes, there
> > > > > should perhaps be a comment explaining why.
> > > > 
> > > > Looks unsafe without managed_page_count_lock.
> > > 
> > > Why does it matter actually? We cannot online/offline memory in
> > > parallel. This is not the case for the boot where we initialize memory
> > > in parallel on multiple nodes. So this seems to be safe currently unless
> > > I am missing something. A comment explaining that would be helpful
> > > though.
> > 
> > Other main callers of adjust_manage_page_count(),
> > 
> > static inline void free_reserved_page(struct page *page)
> > {
> >         __free_reserved_page(page);
> >         adjust_managed_page_count(page, 1);
> > }
> > 
> > static inline void mark_page_reserved(struct page *page)
> > {
> >         SetPageReserved(page);
> >         adjust_managed_page_count(page, -1);
> > }
> > 
> > Won't they race with memory hotplug?
> > 
> > Few more,
> > ./drivers/xen/balloon.c:519:            adjust_managed_page_count(page, -1);
> > ./drivers/virtio/virtio_balloon.c:175:  adjust_managed_page_count(page, -1);
> > ./drivers/virtio/virtio_balloon.c:196:  adjust_managed_page_count(page, 1);
> > ./mm/hugetlb.c:2158:                    adjust_managed_page_count(page, 1 <<
> > h->order);
> 
> They can, and I have missed those.

So this patch needs more work, yes?
