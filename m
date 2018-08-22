Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id E84126B233F
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 03:50:23 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id z17-v6so1062085wrr.16
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 00:50:23 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v19-v6sor251876wmh.36.2018.08.22.00.50.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 00:50:22 -0700 (PDT)
Date: Wed, 22 Aug 2018 09:50:20 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC v2 2/2] mm/memory_hotplug: Shrink spanned pages when
 offlining memory
Message-ID: <20180822075020.GA14550@techadventures.net>
References: <20180817154127.28602-1-osalvador@techadventures.net>
 <20180817154127.28602-3-osalvador@techadventures.net>
 <a18525a5-ea5f-5e7a-8765-a6c0e38ddd21@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a18525a5-ea5f-5e7a-8765-a6c0e38ddd21@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, jglisse@redhat.com, jonathan.cameron@huawei.com, Pavel.Tatashin@microsoft.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Tue, Aug 21, 2018 at 03:17:10PM +0200, David Hildenbrand wrote:
> > add_device_memory is in charge of
> 
> I wouldn't use the terminology of onlining/offlining here. That applies
> rather to memory that is exposed to the rest of the system (e.g. buddy
> allocator, has underlying memory block devices). I guess it is rather a
> pure setup/teardown of that device memory.

Hi David,

I am not sure if you are referring to:

"
a) calling either arch_add_memory() or add_pages(), depending on whether
   we want a linear mapping
b) online the memory sections that correspond to the pfn range
c) calling move_pfn_range_to_zone() being zone ZONE_DEVICE to
   expand zone/pgdat spanned pages and initialize its pages
"

Well, that is partialy true.
I mean, in order to make this work, we need to offline/online the memory
sections, because shrink_pages will rely on that from now on.
Is what we do when online/offline pages, but since device memory
does not go through the "official" channels, we need to do it there
as well.

Sure I can use another terminology, but since that is what
offline/online_mem_sections do, I just came up with that.

> I would really like to see the mem_hotplug_begin/end also getting moved
> inside add_device_memory()/del_device_memory(). (just like for
> add/remove_memory)
> 
> I wonder if kasan_ stuff actually requires this lock, or if it could
> also be somehow moved inside add_device_memory/del_device_memory.

Yes, that was my first approach, but then I saw that the kasan stuff is being
handled whithin those locks, so I was not sure and I backed off leaving the
mem_hotplug_begin/end where they were.

Maybe Jerome can shed some light and, and we can just handle the kasan stuff
out of the locks.

> Maybe shorten that a bit
> 
> "HMM/devm memory does not have IORESOURCE_SYSTEM_RAM set. They use
>  devm_request_mem_region/devm_release_mem_region to add/release a
>  resource. Just back off here."

Uhm, fair enough.

> Any reason for these indirections?

I wanted to hide the internals in the memory_hotplug code.
I thought about removing them, but I finally left them.
If people think that we are better off without them, I can just
remove them.

> I guess for readability, this patch could be split up into several
> patches. E.g. factoring out of add_device_memory/del_device_memory,
> release_mem_region_adjustable change ...

Yes, really true.
But I wanted first to gather feedback mainly from HMM/devm people to see
if they saw an outright bug within the series because I am not so
familiar with that part of the code.

Feedback from Jerome/Dan will be appreciate as well to see if this is a good
direction.

But you are right, in the end, this will have to be slipt up into several
parts to ease the review.

Thanks for reviewing this David!
I will try to address your concerns.

Thanks 
-- 
Oscar Salvador
SUSE L3
