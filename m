Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id B096E6B0005
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 12:31:09 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id i66so4435071oih.5
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 09:31:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b73si2481585oih.365.2018.01.25.09.31.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jan 2018 09:31:08 -0800 (PST)
Date: Thu, 25 Jan 2018 19:31:03 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v24 1/2] mm: support reporting free page blocks
Message-ID: <20180125192213-mutt-send-email-mst@kernel.org>
References: <1516790562-37889-1-git-send-email-wei.w.wang@intel.com>
 <1516790562-37889-2-git-send-email-wei.w.wang@intel.com>
 <20180125152933-mutt-send-email-mst@kernel.org>
 <1582107341.3995759.1516892161298.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1582107341.3995759.1516892161298.JavaMail.zimbra@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>
Cc: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang opensource <liliang.opensource@gmail.com>, yang zhang wz <yang.zhang.wz@gmail.com>, quan xu0 <quan.xu0@gmail.com>, nilal@redhat.com, Rik van Riel <riel@surriel.com>, niteshnarayanlal@hotmail.com

On Thu, Jan 25, 2018 at 09:56:01AM -0500, Pankaj Gupta wrote:
> 
> > 
> > On Wed, Jan 24, 2018 at 06:42:41PM +0800, Wei Wang wrote:
> > > This patch adds support to walk through the free page blocks in the
> > > system and report them via a callback function. Some page blocks may
> > > leave the free list after zone->lock is released, so it is the caller's
> > > responsibility to either detect or prevent the use of such pages.
> > > 
> > > One use example of this patch is to accelerate live migration by skipping
> > > the transfer of free pages reported from the guest. A popular method used
> > > by the hypervisor to track which part of memory is written during live
> > > migration is to write-protect all the guest memory. So, those pages that
> > > are reported as free pages but are written after the report function
> > > returns will be captured by the hypervisor, and they will be added to the
> > > next round of memory transfer.
> > > 
> > > Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> > > Signed-off-by: Liang Li <liang.z.li@intel.com>
> > > Cc: Michal Hocko <mhocko@kernel.org>
> > > Cc: Michael S. Tsirkin <mst@redhat.com>
> > > Acked-by: Michal Hocko <mhocko@kernel.org>
> > > ---
> > >  include/linux/mm.h |  6 ++++
> > >  mm/page_alloc.c    | 91
> > >  ++++++++++++++++++++++++++++++++++++++++++++++++++++++
> > >  2 files changed, 97 insertions(+)
> > > 
> > > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > > index ea818ff..b3077dd 100644
> > > --- a/include/linux/mm.h
> > > +++ b/include/linux/mm.h
> > > @@ -1938,6 +1938,12 @@ extern void free_area_init_node(int nid, unsigned
> > > long * zones_size,
> > >  		unsigned long zone_start_pfn, unsigned long *zholes_size);
> > >  extern void free_initmem(void);
> > >  
> > > +extern void walk_free_mem_block(void *opaque,
> > > +				int min_order,
> > > +				bool (*report_pfn_range)(void *opaque,
> > > +							 unsigned long pfn,
> > > +							 unsigned long num));
> > > +
> > >  /*
> > >   * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
> > >   * into the buddy system. The freed pages will be poisoned with pattern
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 76c9688..705de22 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -4899,6 +4899,97 @@ void show_free_areas(unsigned int filter, nodemask_t
> > > *nodemask)
> > >  	show_swap_cache_info();
> > >  }
> > >  
> > > +/*
> > > + * Walk through a free page list and report the found pfn range via the
> > > + * callback.
> > > + *
> > > + * Return false if the callback requests to stop reporting. Otherwise,
> > > + * return true.
> > > + */
> > > +static bool walk_free_page_list(void *opaque,
> > > +				struct zone *zone,
> > > +				int order,
> > > +				enum migratetype mt,
> > > +				bool (*report_pfn_range)(void *,
> > > +							 unsigned long,
> > > +							 unsigned long))
> > > +{
> > > +	struct page *page;
> > > +	struct list_head *list;
> > > +	unsigned long pfn, flags;
> > > +	bool ret;
> > > +
> > > +	spin_lock_irqsave(&zone->lock, flags);
> > > +	list = &zone->free_area[order].free_list[mt];
> > > +	list_for_each_entry(page, list, lru) {
> > > +		pfn = page_to_pfn(page);
> > > +		ret = report_pfn_range(opaque, pfn, 1 << order);
> > > +		if (!ret)
> > > +			break;
> > > +	}
> > > +	spin_unlock_irqrestore(&zone->lock, flags);
> > > +
> > > +	return ret;
> > > +}
> > 
> > There are two issues with this API. One is that it is not
> > restarteable: if you return false, you start from the
> > beginning. So no way to drop lock, do something slow
> > and then proceed.
> > 
> > Another is that you are using it to report free page hints. Presumably
> > the point is to drop these pages - keeping them near head of the list
> > and reusing the reported ones will just make everything slower
> > invalidating the hint.
> 
> I think that's where patches[1] by 'Nitesh' will help: This patch-set
> will send free page hints transparently to host and host decides to delete such 
> pages.
>
> If I compare with patchset by 'Wei', host gets/asks free page hints and ignore 
> such pages during live migration. But as already discussed, if free pages are 
> still in guest memory there is no point of traversing & getting all such pages
> again.
> 
> [1] https://www.spinics.net/lists/kvm/msg159790.html

The main difference between Wei's and Nitesh's patches add hints to page
alloc/free path. It's this more risky performance-wise: you need to
enable it at guest boot, not just at migration time.
Maybe the overhead isn't big, unfortunately no one posted any
numbers yet.


-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
