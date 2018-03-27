Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8D02C6B0003
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 02:33:26 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 30-v6so9916470ple.19
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 23:33:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 85si428860pfz.271.2018.03.26.23.33.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Mar 2018 23:33:25 -0700 (PDT)
Date: Tue, 27 Mar 2018 08:33:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v29 1/4] mm: support reporting free page blocks
Message-ID: <20180327063322.GW5652@dhcp22.suse.cz>
References: <1522031994-7246-1-git-send-email-wei.w.wang@intel.com>
 <1522031994-7246-2-git-send-email-wei.w.wang@intel.com>
 <20180326142254.c4129c3a54ade686ee2a5e21@linux-foundation.org>
 <5AB9E377.30900@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5AB9E377.30900@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, huangzhichao@huawei.com

On Tue 27-03-18 14:23:51, Wei Wang wrote:
> On 03/27/2018 05:22 AM, Andrew Morton wrote:
> > On Mon, 26 Mar 2018 10:39:51 +0800 Wei Wang <wei.w.wang@intel.com> wrote:
> > 
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
> > > ...
> > > 
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -4912,6 +4912,102 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
> > >   	show_swap_cache_info();
> > >   }
> > > +/*
> > > + * Walk through a free page list and report the found pfn range via the
> > > + * callback.
> > > + *
> > > + * Return 0 if it completes the reporting. Otherwise, return the non-zero
> > > + * value returned from the callback.
> > > + */
> > > +static int walk_free_page_list(void *opaque,
> > > +			       struct zone *zone,
> > > +			       int order,
> > > +			       enum migratetype mt,
> > > +			       int (*report_pfn_range)(void *,
> > > +						       unsigned long,
> > > +						       unsigned long))
> > > +{
> > > +	struct page *page;
> > > +	struct list_head *list;
> > > +	unsigned long pfn, flags;
> > > +	int ret = 0;
> > > +
> > > +	spin_lock_irqsave(&zone->lock, flags);
> > > +	list = &zone->free_area[order].free_list[mt];
> > > +	list_for_each_entry(page, list, lru) {
> > > +		pfn = page_to_pfn(page);
> > > +		ret = report_pfn_range(opaque, pfn, 1 << order);
> > > +		if (ret)
> > > +			break;
> > > +	}
> > > +	spin_unlock_irqrestore(&zone->lock, flags);
> > > +
> > > +	return ret;
> > > +}
> > > +
> > > +/**
> > > + * walk_free_mem_block - Walk through the free page blocks in the system
> > > + * @opaque: the context passed from the caller
> > > + * @min_order: the minimum order of free lists to check
> > > + * @report_pfn_range: the callback to report the pfn range of the free pages
> > > + *
> > > + * If the callback returns a non-zero value, stop iterating the list of free
> > > + * page blocks. Otherwise, continue to report.
> > > + *
> > > + * Please note that there are no locking guarantees for the callback and
> > > + * that the reported pfn range might be freed or disappear after the
> > > + * callback returns so the caller has to be very careful how it is used.
> > > + *
> > > + * The callback itself must not sleep or perform any operations which would
> > > + * require any memory allocations directly (not even GFP_NOWAIT/GFP_ATOMIC)
> > > + * or via any lock dependency. It is generally advisable to implement
> > > + * the callback as simple as possible and defer any heavy lifting to a
> > > + * different context.
> > > + *
> > > + * There is no guarantee that each free range will be reported only once
> > > + * during one walk_free_mem_block invocation.
> > > + *
> > > + * pfn_to_page on the given range is strongly discouraged and if there is
> > > + * an absolute need for that make sure to contact MM people to discuss
> > > + * potential problems.
> > > + *
> > > + * The function itself might sleep so it cannot be called from atomic
> > > + * contexts.
> > I don't see how walk_free_mem_block() can sleep.
> 
> OK, it would be better to remove this sentence for the current version. But
> I think we could probably keep it if we decide to add cond_resched() below.

The point of this sentence was to make any user aware that the function
might sleep from the very begining rather than chase existing callers
when we need to add cond_resched or sleep for any other reason. So I
would rather keep it.
-- 
Michal Hocko
SUSE Labs
