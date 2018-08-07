Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A82406B0003
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 16:48:37 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r13-v6so209990wmc.8
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 13:48:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t12-v6sor989943wrs.28.2018.08.07.13.48.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Aug 2018 13:48:36 -0700 (PDT)
Date: Tue, 7 Aug 2018 22:48:34 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC PATCH 2/3] mm/memory_hotplug: Create __shrink_pages and
 move it to offline_pages
Message-ID: <20180807204834.GA6844@techadventures.net>
References: <20180807133757.18352-1-osalvador@techadventures.net>
 <20180807133757.18352-3-osalvador@techadventures.net>
 <20180807135221.GA3301@redhat.com>
 <a6e4e654-fc95-497f-16f3-8c1550cf03d6@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a6e4e654-fc95-497f-16f3-8c1550cf03d6@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Jerome Glisse <jglisse@redhat.com>, akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, pasha.tatashin@oracle.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Tue, Aug 07, 2018 at 04:54:57PM +0200, David Hildenbrand wrote:
> I wonder if we could instead forward from the callers whether we are
> dealing with ZONE_DEVICE memory (is_device ...), at least that seems
> feasible in hmm code. Not having looked at details yet.

Yes, this looks like the most straightforward way right now.
We would have to pass it from arch_remove_memory to __remove_pages though.

It is not the most elegant way, but looking at the code of devm_memremap_pages_release
and hmm_devmem_release I cannot really think of anything better.

In hmm_devmem_release is should be easy because AFAIK (unless I am missing something), hmm always works
with ZONE_DEVICE.
At least hmm_devmem_pages_create() moves the range to ZONE_DEVICE.

After looking at devm_memremap_pages(), I think it does the same:

...
move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
					align_start >> PAGE_SHIFT,
					align_size >> PAGE_SHIFT, altmap);
...

So I guess it is safe to assume that arch_remove_memory/__remove_pages are called
from those functions while zone being ZONE_DEVICE.

Is that right, Jerome?

And since we know for sure that memhotplug-code cannot call it with ZONE_DEVICE,
I think this can be done easily.

Thanks
-- 
Oscar Salvador
SUSE L3
