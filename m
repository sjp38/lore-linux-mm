Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B7B756B2E79
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 06:55:45 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id z22-v6so4916615pfi.0
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 03:55:45 -0800 (PST)
Received: from suse.de (charybdis-ext.suse.de. [195.135.221.2])
        by mx.google.com with ESMTP id o3si26832801pgq.139.2018.11.23.03.55.44
        for <linux-mm@kvack.org>;
        Fri, 23 Nov 2018 03:55:44 -0800 (PST)
Date: Fri, 23 Nov 2018 12:55:41 +0100
From: Oscar Salvador <osalvador@d104.suse.de>
Subject: Re: [RFC PATCH 0/4] mm, memory_hotplug: allocate memmap from
 hotadded memory
Message-ID: <20181123115519.2dnzscmmgv63fdub@d104.suse.de>
References: <20181116101222.16581-1-osalvador@suse.com>
 <2571308d-0460-e8b9-ad40-75d6b13b2d09@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2571308d-0460-e8b9-ad40-75d6b13b2d09@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.com>, linux-mm@kvack.org, mhocko@suse.com, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, arunks@codeaurora.org, bhe@redhat.com, dan.j.williams@intel.com, Pavel.Tatashin@microsoft.com, Jonathan.Cameron@huawei.com, jglisse@redhat.com, linux-kernel@vger.kernel.org

On Thu, Nov 22, 2018 at 10:21:24AM +0100, David Hildenbrand wrote:
> 1. How are we going to present such memory to the system statistics?
> 
> In my opinion, this vmemmap memory should
> a) still account to total memory
> b) show up as allocated
> 
> So just like before.

No, it does not show up under total memory and neither as allocated memory.
This memory is not for use for anything but for creating the pagetables
for the memmap array for the section/s.

It is not memory that the system can use.

I also guess that if there is a strong opinion on this, we could create
a counter, something like NR_VMEMMAP_PAGES, and show it under /proc/meminfo.

> 2. Is this optional, in other words, can a device driver decide to not
> to it like that?

Right now, is a per arch setup.
For example, x86_64/powerpc/arm64 will do it inconditionally.

If we want to restrict this a per device-driver thing, I guess that we could
allow to pass a flag to add_memory()->add_memory_resource(), and there
unset MHP_MEMMAP_FROM_RANGE in case that flag is enabled.

> You mention ballooning. Now, both XEN and Hyper-V (the only balloon
> drivers that add new memory as of now), usually add e.g. a 128MB segment
> to only actually some part of it (e.g. 64MB, but could vary). Now, going
> ahead and assuming that all memory of a section can be read/written is
> wrong. A device driver will indicate which pages may actually be used
> via set_online_page_callback() when new memory is added. But at that
> point you already happily accessed some memory for vmmap - which might
> lead to crashes.
> 
> For now the rule was: Memory that was not onlined will not be
> read/written, that's why it works for XEN and Hyper-V.

We do not write all memory of the hot-added section, we just write the
first 2MB (first 512 pages), the other 126MB are left untouched.

Assuming that you add a memory-chunk section aligned (128MB), but you only present
the first 64MB or 32MB to the guest as onlined, we still need to allocate the memmap
for the whole section.

I do not really know the tricks behind Hyper-V/Xen, could you expand on that?

So far I only tested this with qemu simulating large machines, but I plan
to try the balloning thing on Xen.

At this moment I am working on a second version of this patchset
to address Dave's feedback.

----
Oscar Salvador
SUSE L3 
