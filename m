Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D82FC8E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 05:16:12 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id r2-v6so12151826pgp.3
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 02:16:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s81-v6si20343534pfk.213.2018.09.11.02.16.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 02:16:11 -0700 (PDT)
Date: Tue, 11 Sep 2018 11:16:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memory_hotplug: fix the panic when memory end is not on
 the section boundary
Message-ID: <20180911091608.GQ10951@dhcp22.suse.cz>
References: <20180910123527.71209-1-zaslonko@linux.ibm.com>
 <20180910131754.GG10951@dhcp22.suse.cz>
 <e8d75768-9122-332b-3b16-cad032aeb27f@microsoft.com>
 <20180910135959.GI10951@dhcp22.suse.cz>
 <CAGM2reZuGAPmfO8x0TnHnqHci_Hsga3-CfM9+udJs=gUQCw-1g@mail.gmail.com>
 <20180910141946.GJ10951@dhcp22.suse.cz>
 <CAGM2reZ5OD9SRW8j9iaQAk9jpr86pF2NqpBjv-dxH+1vJZs0=g@mail.gmail.com>
 <20180910144152.GL10951@dhcp22.suse.cz>
 <abf84f61-82f3-e3d5-2e6e-82a11cb5dcf5@microsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <abf84f61-82f3-e3d5-2e6e-82a11cb5dcf5@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Cc: "zaslonko@linux.ibm.com" <zaslonko@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "osalvador@suse.de" <osalvador@suse.de>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>

On Mon 10-09-18 15:26:55, Pavel Tatashin wrote:
> 
> 
> On 9/10/18 10:41 AM, Michal Hocko wrote:
> > On Mon 10-09-18 14:32:16, Pavel Tatashin wrote:
> >> On Mon, Sep 10, 2018 at 10:19 AM Michal Hocko <mhocko@kernel.org> wrote:
> >>>
> >>> On Mon 10-09-18 14:11:45, Pavel Tatashin wrote:
> >>>> Hi Michal,
> >>>>
> >>>> It is tricky, but probably can be done. Either change
> >>>> memmap_init_zone() or its caller to also cover the ends and starts of
> >>>> unaligned sections to initialize and reserve pages.
> >>>>
> >>>> The same thing would also need to be done in deferred_init_memmap() to
> >>>> cover the deferred init case.
> >>>
> >>> Well, I am not sure TBH. I have to think about that much more. Maybe it
> >>> would be much more simple to make sure that we will never add incomplete
> >>> memblocks and simply refuse them during the discovery. At least for now.
> >>
> >> On x86 memblocks can be upto 2G on machines with over 64G of RAM.
> > 
> > sorry I meant pageblock_nr_pages rather than memblocks.
> 
> OK. This sound reasonable, but, to be honest I am not sure how to
> achieve this yet, I need to think more about this. In theory, if we have
> sparse memory model, it makes sense to enforce memory alignment to
> section sizes, sounds a lot safer.

Memory hotplug is sparsemem only. You do not have to think about other
memory models fortunately.
 
> >> Also, memory size is way to easy too change via qemu arguments when VM
> >> starts. If we simply disable unaligned trailing memblocks, I am sure
> >> we would get tons of noise of missing memory.
> >>
> >> I think, adding check_hotplug_memory_range() would work to fix the
> >> immediate problem. But, we do need to figure out  a better solution.
> >>
> >> memblock design is based on archaic assumption that hotplug units are
> >> physical dimms. VMs and hypervisors changed all of that, and we can
> >> have much finer hotplug requests on machines with huge DIMMs. Yet, we
> >> do not want to pollute sysfs with millions of tiny memory devices. I
> >> am not sure what a long term proper solution for this problem should
> >> be, but I see that linux hotplug/hotremove subsystems must be
> >> redesigned based on the new requirements.
> > 
> > Not an easy task though. Anyway, sparse memory modely is highly based on
> > memory sections so it makes some sense to have hotplug section based as
> > well. Memblocks as a higher logical unit on top of that is kinda hack.
> > The userspace API has never been properly thought through I am afraid.
> 
> I agree memoryblock is a hack, it fails to do both things it was
> designed to do:
> 
> 1. On bare metal you cannot free a physical dimm of memory using
> memoryblock granularity because memory devices do not equal to physical
> dimms. Thus, if for some reason a particular dimm must be
> remove/replaced, memoryblock does not help us.

agreed

> 2. On machines with hypervisors it fails to provide an adequate
> granularity to add/remove memory.
> 
> We should define a new user interface where memory can be added/removed
> at a finer granularity: sparse section size, but without a memory
> devices for each section. We should also provide an optional access to
> legacy interface where memory devices are exported but each is of
> section size.
> 
> So, when legacy interface is enabled, current way would work:
> 
> echo offline > /sys/devices/system/memory/memoryXXX/state
> 
> And new interface would allow us to do something like this:
> 
> echo offline 256M > /sys/devices/system/node/nodeXXX/memory
> 
> With optional start address for offline memory.
> echo offline [start_pa] size > /sys/devices/system/node/nodeXXX/memory
> start_pa and size must be section size aligned (128M).

I am not sure what is the expected semantic of the version without
start_pa.

> It would probably be a good discussion for the next MM Summit how to
> solve the current memory hotplug interface limitations.

Yes, sounds good to me. In any case let's not pollute this email thread
with this discussion now.
-- 
Michal Hocko
SUSE Labs
