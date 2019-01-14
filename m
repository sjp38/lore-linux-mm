Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1CF8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 08:18:01 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id l45so9002346edb.1
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 05:18:01 -0800 (PST)
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id e3si3100669edq.338.2019.01.14.05.17.59
        for <linux-mm@kvack.org>;
        Mon, 14 Jan 2019 05:17:59 -0800 (PST)
Date: Mon, 14 Jan 2019 14:17:56 +0100
From: Oscar Salvador <osalvador@suse.de>
Subject: Re: [RFC PATCH 2/4] mm, memory_hotplug: provide a more generic
 restrictions for memory hotplug
Message-ID: <20190114131742.neivbac3lmsszkzc@d104.suse.de>
References: <20181116101222.16581-1-osalvador@suse.com>
 <20181116101222.16581-3-osalvador@suse.com>
 <20181123130043.GM8625@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181123130043.GM8625@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Oscar Salvador <osalvador@suse.com>, linux-mm@kvack.org, david@redhat.com, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, arunks@codeaurora.org, bhe@redhat.com, dan.j.williams@intel.com, Pavel.Tatashin@microsoft.com, Jonathan.Cameron@huawei.com, jglisse@redhat.com, linux-kernel@vger.kernel.org, Alexander Duyck <alexander.h.duyck@linux.intel.com>

On Fri, Nov 23, 2018 at 02:00:43PM +0100, Michal Hocko wrote:
> One note here as well. In the retrospect the API I have come up
> with here is quite hackish. Considering the recent discussion about
> special needs ZONE_DEVICE has for both initialization and struct page
> allocations with Alexander Duyck I believe we wanted a more abstracted
> API with allocator and constructor callbacks. This would allow different
> usecases to fine tune their needs without specialcasing deep in the core
> hotplug code paths.

Hi all,

so, now that vacation is gone, I wanted to come back to this.
I kind of get what you mean with this more abstacted API, but I am not really
sure how we could benefit from it (or maybe I am just short-sighted here).

Right now, struct mhp_restrictions would look like:

struct mhp_restrictions {
        unsigned long flags;
        struct vmem_altmap *altmap;
};

where flags tell us whether we want a memblock device and whether we should
allocate the memmap array from the hot-added range.
And altmap is the altmap we would use for it.

Indeed, we could add two callbacks, set_up() and construct() (random naming).

When talking about memmap-from-hot_added-range, set_up() could be called
to construct the altmap, i.e:

<--
struct vmem_altmap __memblk_altmap;

__memblk_altmap.base_pfn = phys_start_pfn;
__memblk_altmap.alloc = 0;
__memblk_altmap.align = 0;
__memblk_altmap.free = nr_pages;
-->

and construct() would be called at the very end of __add_pages(), which
basically would be mark_vmemmap_pages().

Now, looking at devm_memremap_pages(ZONE_DEVICE stuff), it does:

hotplug_lock();
 arch_add_memory
  add_pages
 move_pfn_range_to_zone
hotplug_lock();
memmap_init_zone_device

For the ZONE_DEVICE case, move_pfn_range_to_zone() only initializes the pages
containing the memory mapping, while all the remaining pages all initialized later on
in memmap_init_zone_device().
Besides initializing pages, memmap_init_zone_device() also sets page->pgmap field.
So you could say that memmap_init_zone_device would be the construct part.

Anyway, I am currently working on the patch3 of this series to improve it and make it less
complex, but it would be great to sort out this API thing.

Maybe Alexander or you, can provide some suggestions/ideas here.

Thanks

Oscar Salvador
-- 
Oscar Salvador
SUSE L3
