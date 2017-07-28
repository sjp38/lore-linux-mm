Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6BBDE6B0527
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 07:26:50 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w63so38293118wrc.5
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 04:26:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n143si12816447wmd.255.2017.07.28.04.26.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 04:26:48 -0700 (PDT)
Date: Fri, 28 Jul 2017 13:26:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/5] mm, memory_hotplug: allocate memmap from the
 added memory range for sparse-vmemmap
Message-ID: <20170728112643.GJ2274@dhcp22.suse.cz>
References: <20170726083333.17754-1-mhocko@kernel.org>
 <20170726083333.17754-4-mhocko@kernel.org>
 <20170726114539.GG3218@osiris>
 <20170726123040.GO2981@dhcp22.suse.cz>
 <20170726192039.48b81161@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726192039.48b81161@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dan Williams <dan.j.williams@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Martin Schwidefsky <mschwide@de.ibm.com>

On Wed 26-07-17 19:20:39, Gerald Schaefer wrote:
> On Wed, 26 Jul 2017 14:30:41 +0200
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Wed 26-07-17 13:45:39, Heiko Carstens wrote:
> > [...]
> > > In general I do like your idea, however if I understand your patches
> > > correctly we might have an ordering problem on s390: it is not possible to
> > > access hot-added memory on s390 before it is online (MEM_GOING_ONLINE
> > > succeeded).
> > 
> > Could you point me to the code please? I cannot seem to find the
> > notifier which implements that.
> 
> It is in drivers/s390/char/sclp_cmd.c: sclp_mem_notifier(). 

Thanks for the pointer. I will have a look.

> > > On MEM_GOING_ONLINE we ask the hypervisor to back the potential available
> > > hot-added memory region with physical pages. Accessing those ranges before
> > > that will result in an exception.
> > 
> > Can we make the range which backs the memmap range available? E.g from
> > s390 specific __vmemmap_populate path?
> 
> No, only the complete range of a storage increment can be made available.
> The size of those increments may vary between z/VM and LPAR, but at least
> with LPAR it will always be minimum 256 MB, IIRC.

Is there any problem doing that before we even get to __add_pages - e.g.
in arch_add_memory? X86 already does something along those lines by
calling init_memory_mapping AFAIU. Yes it is different thing than s390
but essentially it is preparing the physical address space for the new
memory so it is not that far away...

> > > However with your approach the memory is still allocated when add_memory()
> > > is being called, correct? That wouldn't be a change to the current
> > > behaviour; except for the ordering problem outlined above.
> > 
> > Could you be more specific please? I do not change when the memmap is
> > allocated.
> 
> I guess this is about the difference between s390 and others, wrt when
> we call add_memory(). It is also in drivers/s390/char/sclp_cmd.c, early
> during memory detection, as opposed to other archs, where I guess this
> could be triggered by an ACPI event during runtime, at least for newly
> added and to-be-onlined memory.

I guess this is trying to answer my question above about arch_add_memory
but I still to grasp what this means.

> This probably means that any approach that tries to allocate memmap
> memory during add_memory(), out of the "to-be-onlined but still offline"
> memory, will be difficult for s390, because we call add_memory() only once
> during memory detection for the complete range of (hypervisor) defined
> online and offline memory. The offline parts are then made available in
> the MEM_GOING_ONLINE notifier called from online_pages(). Only after
> this point the memory would then be available to allocate a memmap in it.

Yes, this scheme is really unfortunate for the mechanism I am proposing
and it is not compatible.

> Nevertheless, we have great interest in such a "allocate memmap from
> the added memory range" solution. I guess we would need some way to
> separate the memmap allocation from add_memory(), which sounds odd,
> or provide some way to have add_memory() only allocate a memmap for
> online memory, and a mechanism to add the memmaps for offline memory
> blocks later when they are being set online.

Well, we cannot move the memmap allocation to later. We do have users
which never online the memory (ZONE_DEVICE). And __add_pages is exactly
about adding memmap for the range. I believe this should be addressed
somewhere at arch_add_memory layer.

Jerome has noted that there will have to be an opt-out from using altmap
becuase his hotplug usecase (HMM) cannot allocate from the added range
as well. So I will use the same thing for the s390 until we figure how
to implement it there for now.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
