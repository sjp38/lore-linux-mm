Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8F56B0011
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 16:43:54 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id m66so1037817oig.13
        for <linux-mm@kvack.org>; Fri, 26 Jan 2018 13:43:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b8si2838190otb.312.2018.01.26.13.43.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jan 2018 13:43:53 -0800 (PST)
Date: Fri, 26 Jan 2018 23:43:43 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v24 1/2] mm: support reporting free page blocks
Message-ID: <20180126233950-mutt-send-email-mst@kernel.org>
References: <1516790562-37889-1-git-send-email-wei.w.wang@intel.com>
 <1516790562-37889-2-git-send-email-wei.w.wang@intel.com>
 <20180125152933-mutt-send-email-mst@kernel.org>
 <5A6AA08B.2080508@intel.com>
 <20180126155224-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180126155224-mutt-send-email-mst@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On Fri, Jan 26, 2018 at 05:00:09PM +0200, Michael S. Tsirkin wrote:
> On Fri, Jan 26, 2018 at 11:29:15AM +0800, Wei Wang wrote:
> > On 01/25/2018 09:41 PM, Michael S. Tsirkin wrote:
> > > On Wed, Jan 24, 2018 at 06:42:41PM +0800, Wei Wang wrote:
> > > > This patch adds support to walk through the free page blocks in the
> > > > system and report them via a callback function. Some page blocks may
> > > > leave the free list after zone->lock is released, so it is the caller's
> > > > responsibility to either detect or prevent the use of such pages.
> > > > 
> > > > One use example of this patch is to accelerate live migration by skipping
> > > > the transfer of free pages reported from the guest. A popular method used
> > > > by the hypervisor to track which part of memory is written during live
> > > > migration is to write-protect all the guest memory. So, those pages that
> > > > are reported as free pages but are written after the report function
> > > > returns will be captured by the hypervisor, and they will be added to the
> > > > next round of memory transfer.
> > > > 
> > > > Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> > > > Signed-off-by: Liang Li <liang.z.li@intel.com>
> > > > Cc: Michal Hocko <mhocko@kernel.org>
> > > > Cc: Michael S. Tsirkin <mst@redhat.com>
> > > > Acked-by: Michal Hocko <mhocko@kernel.org>
> > > > ---
> > > >   include/linux/mm.h |  6 ++++
> > > >   mm/page_alloc.c    | 91 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
> > > >   2 files changed, 97 insertions(+)
> > > > 
> > > > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > > > index ea818ff..b3077dd 100644
> > > > --- a/include/linux/mm.h
> > > > +++ b/include/linux/mm.h
> > > > @@ -1938,6 +1938,12 @@ extern void free_area_init_node(int nid, unsigned long * zones_size,
> > > >   		unsigned long zone_start_pfn, unsigned long *zholes_size);
> > > >   extern void free_initmem(void);
> > > > +extern void walk_free_mem_block(void *opaque,
> > > > +				int min_order,
> > > > +				bool (*report_pfn_range)(void *opaque,
> > > > +							 unsigned long pfn,
> > > > +							 unsigned long num));
> > > > +
> > > >   /*
> > > >    * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
> > > >    * into the buddy system. The freed pages will be poisoned with pattern
> > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > index 76c9688..705de22 100644
> > > > --- a/mm/page_alloc.c
> > > > +++ b/mm/page_alloc.c
> > > > @@ -4899,6 +4899,97 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
> > > >   	show_swap_cache_info();
> > > >   }
> > > > +/*
> > > > + * Walk through a free page list and report the found pfn range via the
> > > > + * callback.
> > > > + *
> > > > + * Return false if the callback requests to stop reporting. Otherwise,
> > > > + * return true.
> > > > + */
> > > > +static bool walk_free_page_list(void *opaque,
> > > > +				struct zone *zone,
> > > > +				int order,
> > > > +				enum migratetype mt,
> > > > +				bool (*report_pfn_range)(void *,
> > > > +							 unsigned long,
> > > > +							 unsigned long))
> > > > +{
> > > > +	struct page *page;
> > > > +	struct list_head *list;
> > > > +	unsigned long pfn, flags;
> > > > +	bool ret;
> > > > +
> > > > +	spin_lock_irqsave(&zone->lock, flags);
> > > > +	list = &zone->free_area[order].free_list[mt];
> > > > +	list_for_each_entry(page, list, lru) {
> > > > +		pfn = page_to_pfn(page);
> > > > +		ret = report_pfn_range(opaque, pfn, 1 << order);
> > > > +		if (!ret)
> > > > +			break;
> > > > +	}
> > > > +	spin_unlock_irqrestore(&zone->lock, flags);
> > > > +
> > > > +	return ret;
> > > > +}
> > > There are two issues with this API. One is that it is not
> > > restarteable: if you return false, you start from the
> > > beginning. So no way to drop lock, do something slow
> > > and then proceed.
> > > 
> > > Another is that you are using it to report free page hints. Presumably
> > > the point is to drop these pages - keeping them near head of the list
> > > and reusing the reported ones will just make everything slower
> > > invalidating the hint.
> > > 
> > > How about rotating these pages towards the end of the list?
> > > Probably not on each call, callect reported pages and then
> > > move them to tail when we exit.
> > 
> > 
> > I'm not sure how this would help. For example, we have a list of 2M free
> > page blocks:
> > A-->B-->C-->D-->E-->F-->G--H
> > 
> > After reporting A and B, and put them to the end and exit, when the caller
> > comes back,
> > 1) if the list remains unchanged, then it will be
> > C-->D-->E-->F-->G-->H-->A-->B
> 
> Right. So here we can just scan until we see A, right?  It's a harder
> question what to do if A and only A has been consumed.  We don't want B
> to be sent twice ideally. OTOH maybe that isn't a big deal if it's only
> twice. Host might know page is already gone - how about host gives us a
> hint after using the buffer?
> 
> > 2) If worse, all the blocks have been split into smaller blocks and used
> > after the caller comes back.
> > 
> > where could we continue?
> 
> I'm not sure. But an alternative appears to be to hold a lock
> and just block whoever wanted to use any pages.  Yes we are sending
> hints faster but apparently something wanted these pages, and holding
> the lock is interfering with this something.

I've been thinking about it. How about the following scheme:
1. register balloon to get a (new) callback when free list runs empty
2. take pages off the free list, add them to the balloon specific list
3. report to host
4. readd to free list at tail
5. if callback triggers, interrupt balloon reporting to host,
   and readd to free list at tail


This needs some thought wrt what happens when there are
multiple users of this API, but looks like it will work.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
