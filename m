Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 45E9A6B04AC
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 13:21:29 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id k14so93787618qkl.7
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 10:21:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i64si11421600qtb.371.2017.07.31.10.21.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 10:21:28 -0700 (PDT)
Date: Mon, 31 Jul 2017 13:21:24 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 09/15] mm/hmm/devmem: device memory hotplug using
 ZONE_DEVICE v6
Message-ID: <20170731172122.GA24626@redhat.com>
References: <20170628180047.5386-1-jglisse@redhat.com>
 <20170628180047.5386-10-jglisse@redhat.com>
 <20170728111003.GA2278@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170728111003.GA2278@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Fri, Jul 28, 2017 at 01:10:03PM +0200, Michal Hocko wrote:
> I haven't seen a newer version posted but the same comment applies on
> your hmm-v25-4.9 git version from
> git://people.freedesktop.org/~glisse/linux
> 
> On Wed 28-06-17 14:00:41, Jerome Glisse wrote:
> > This introduce a simple struct and associated helpers for device driver
> > to use when hotpluging un-addressable device memory as ZONE_DEVICE. It
> > will find a unuse physical address range and trigger memory hotplug for
> > it which allocates and initialize struct page for the device memory.
> 
> Please document the hotplug semantic some more please (who is in charge,
> what is the lifetime, userspace API to add/remove this memory if any
> etc...).
> 
> I can see you call add_pages. Please document why arch_add_memory (like
> devm_memremap_pages) is not used. You also never seem to online the
> range which is in line with nvdim usage and it is OK. But then I fail to
> understand why you need

I added documentation in function and in commit message:
https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-next&id=33e236a64da84423c83db401fc62ea13877111f2

Not much to say i am affraid as everything is under control of the device
driver (when hotplug/hotremove happens, memory management, userspace API,
...). 

> 
> [...]
> > +	mem_hotplug_begin();
> > +	ret = add_pages(nid, align_start >> PAGE_SHIFT,
> > +			align_size >> PAGE_SHIFT, false);
> > +	if (ret) {
> > +		mem_hotplug_done();
> > +		goto error_add_memory;
> > +	}
> > +	move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
> > +				align_start >> PAGE_SHIFT,
> > +				align_size >> PAGE_SHIFT);
> > +	mem_hotplug_done();
> > +
> > +	for (pfn = devmem->pfn_first; pfn < devmem->pfn_last; pfn++) {
> > +		struct page *page = pfn_to_page(pfn);
> > +
> > +		/*
> > +		 * ZONE_DEVICE pages union ->lru with a ->pgmap back
> > +		 * pointer.  It is a bug if a ZONE_DEVICE page is ever
> > +		 * freed or placed on a driver-private list. Therefore,
> > +		 * seed the storage with LIST_POISON* values.
> > +		 */
> > +		list_del(&page->lru);
> 
> this? The page is not on any list yet - it hasn't been added to the page
> allocator.

Like comments says it was to init page->lru.next|prev with poison values
it is not important so i remove it.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
