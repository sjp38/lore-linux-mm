Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E9D166B0525
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 07:10:08 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id q50so38222454wrb.14
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 04:10:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i72si8559888wmc.121.2017.07.28.04.10.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 04:10:07 -0700 (PDT)
Date: Fri, 28 Jul 2017 13:10:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 09/15] mm/hmm/devmem: device memory hotplug using
 ZONE_DEVICE v6
Message-ID: <20170728111003.GA2278@dhcp22.suse.cz>
References: <20170628180047.5386-1-jglisse@redhat.com>
 <20170628180047.5386-10-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170628180047.5386-10-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

I haven't seen a newer version posted but the same comment applies on
your hmm-v25-4.9 git version from
git://people.freedesktop.org/~glisse/linux

On Wed 28-06-17 14:00:41, Jerome Glisse wrote:
> This introduce a simple struct and associated helpers for device driver
> to use when hotpluging un-addressable device memory as ZONE_DEVICE. It
> will find a unuse physical address range and trigger memory hotplug for
> it which allocates and initialize struct page for the device memory.

Please document the hotplug semantic some more please (who is in charge,
what is the lifetime, userspace API to add/remove this memory if any
etc...).

I can see you call add_pages. Please document why arch_add_memory (like
devm_memremap_pages) is not used. You also never seem to online the
range which is in line with nvdim usage and it is OK. But then I fail to
understand why you need

[...]
> +	mem_hotplug_begin();
> +	ret = add_pages(nid, align_start >> PAGE_SHIFT,
> +			align_size >> PAGE_SHIFT, false);
> +	if (ret) {
> +		mem_hotplug_done();
> +		goto error_add_memory;
> +	}
> +	move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
> +				align_start >> PAGE_SHIFT,
> +				align_size >> PAGE_SHIFT);
> +	mem_hotplug_done();
> +
> +	for (pfn = devmem->pfn_first; pfn < devmem->pfn_last; pfn++) {
> +		struct page *page = pfn_to_page(pfn);
> +
> +		/*
> +		 * ZONE_DEVICE pages union ->lru with a ->pgmap back
> +		 * pointer.  It is a bug if a ZONE_DEVICE page is ever
> +		 * freed or placed on a driver-private list. Therefore,
> +		 * seed the storage with LIST_POISON* values.
> +		 */
> +		list_del(&page->lru);

this? The page is not on any list yet - it hasn't been added to the page
allocator.

> +		page->pgmap = &devmem->pagemap;
> +	}
> +	return 0;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
