Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B3F9280310
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 02:18:17 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id r79so11392547wrb.0
        for <linux-mm@kvack.org>; Sun, 20 Aug 2017 23:18:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w94si9005158wrc.86.2017.08.20.23.18.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 20 Aug 2017 23:18:16 -0700 (PDT)
Date: Mon, 21 Aug 2017 08:18:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v14 4/5] mm: support reporting free page blocks
Message-ID: <20170821061812.GB13724@dhcp22.suse.cz>
References: <1502940416-42944-1-git-send-email-wei.w.wang@intel.com>
 <1502940416-42944-5-git-send-email-wei.w.wang@intel.com>
 <20170818201946-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170818201946-mutt-send-email-mst@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Fri 18-08-17 20:23:05, Michael S. Tsirkin wrote:
> On Thu, Aug 17, 2017 at 11:26:55AM +0800, Wei Wang wrote:
[...]
> > +void walk_free_mem_block(void *opaque1,
> > +			 unsigned int min_order,
> > +			 void (*visit)(void *opaque2,
> 
> You can just avoid opaque2 completely I think, then opaque1 can
> be renamed opaque.
> 
> > +				       unsigned long pfn,
> > +				       unsigned long nr_pages))
> > +{
> > +	struct zone *zone;
> > +	struct page *page;
> > +	struct list_head *list;
> > +	unsigned int order;
> > +	enum migratetype mt;
> > +	unsigned long pfn, flags;
> > +
> > +	for_each_populated_zone(zone) {
> > +		for (order = MAX_ORDER - 1;
> > +		     order < MAX_ORDER && order >= min_order; order--) {
> > +			for (mt = 0; mt < MIGRATE_TYPES; mt++) {
> > +				spin_lock_irqsave(&zone->lock, flags);
> > +				list = &zone->free_area[order].free_list[mt];
> > +				list_for_each_entry(page, list, lru) {
> > +					pfn = page_to_pfn(page);
> > +					visit(opaque1, pfn, 1 << order);
> 
> My only concern here is inability of callback to
> 1. break out of list
> 2. remove page from the list

As I've said before this has to be a read only API. You cannot simply
fiddle with the page allocator internals under its feet.

> So I would make the callback bool, and I would use
> list_for_each_entry_safe.

If a bool would tell to break out of the loop then I agree. This sounds
useful.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
