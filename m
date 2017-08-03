Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5419C6B0699
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 07:28:34 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l3so1581384wrc.12
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 04:28:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t188si1162341wmg.36.2017.08.03.04.28.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Aug 2017 04:28:33 -0700 (PDT)
Date: Thu, 3 Aug 2017 13:28:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v13 4/5] mm: support reporting free page blocks
Message-ID: <20170803112831.GN12521@dhcp22.suse.cz>
References: <1501742299-4369-1-git-send-email-wei.w.wang@intel.com>
 <1501742299-4369-5-git-send-email-wei.w.wang@intel.com>
 <20170803091151.GF12521@dhcp22.suse.cz>
 <5982FE07.3040207@intel.com>
 <20170803104417.GI12521@dhcp22.suse.cz>
 <59830897.2060203@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59830897.2060203@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mawilcox@microsoft.com, akpm@linux-foundation.org, virtio-dev@lists.oasis-open.org, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Thu 03-08-17 19:27:19, Wei Wang wrote:
> On 08/03/2017 06:44 PM, Michal Hocko wrote:
> >On Thu 03-08-17 18:42:15, Wei Wang wrote:
> >>On 08/03/2017 05:11 PM, Michal Hocko wrote:
> >>>On Thu 03-08-17 14:38:18, Wei Wang wrote:
> >[...]
> >>>>+static int report_free_page_block(struct zone *zone, unsigned int order,
> >>>>+				  unsigned int migratetype, struct page **page)
> >>>This is just too ugly and wrong actually. Never provide struct page
> >>>pointers outside of the zone->lock. What I've had in mind was to simply
> >>>walk free lists of the suitable order and call the callback for each one.
> >>>Something as simple as
> >>>
> >>>	for (i = 0; i < MAX_NR_ZONES; i++) {
> >>>		struct zone *zone = &pgdat->node_zones[i];
> >>>
> >>>		if (!populated_zone(zone))
> >>>			continue;
> >>>		spin_lock_irqsave(&zone->lock, flags);
> >>>		for (order = min_order; order < MAX_ORDER; ++order) {
> >>>			struct free_area *free_area = &zone->free_area[order];
> >>>			enum migratetype mt;
> >>>			struct page *page;
> >>>
> >>>			if (!free_area->nr_pages)
> >>>				continue;
> >>>
> >>>			for_each_migratetype_order(order, mt) {
> >>>				list_for_each_entry(page,
> >>>						&free_area->free_list[mt], lru) {
> >>>
> >>>					pfn = page_to_pfn(page);
> >>>					visit(opaque2, prn, 1<<order);
> >>>				}
> >>>			}
> >>>		}
> >>>
> >>>		spin_unlock_irqrestore(&zone->lock, flags);
> >>>	}
> >>>
> >>>[...]
> >>
> >>I think the above would take the lock for too long time. That's why we
> >>prefer to take one free page block each time, and taking it one by one
> >>also doesn't make a difference, in terms of the performance that we
> >>need.
> >I think you should start with simple approach and impove incrementally
> >if this turns out to be not optimal. I really detest taking struct pages
> >outside of the lock. You never know what might happen after the lock is
> >dropped. E.g. can you race with the memory hotremove?
> 
> 
> The caller won't use pages returned from the function, so I think there
> shouldn't be an issue or race if the returned pages are used (i.e. not free
> anymore) or simply gone due to hotremove.

No, this is just too error prone. Consider that struct page pointer
itself could get invalid in the meantime. Please always keep robustness
in mind first. Optimizations are nice but it is even not clear whether
the simple variant will cause any problems.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
