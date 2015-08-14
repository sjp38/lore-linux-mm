Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1968B6B0038
	for <linux-mm@kvack.org>; Fri, 14 Aug 2015 18:06:10 -0400 (EDT)
Received: by qgdd90 with SMTP id d90so60646847qgd.3
        for <linux-mm@kvack.org>; Fri, 14 Aug 2015 15:06:09 -0700 (PDT)
Received: from mail-qk0-x22d.google.com (mail-qk0-x22d.google.com. [2607:f8b0:400d:c09::22d])
        by mx.google.com with ESMTPS id s24si1793108qkl.3.2015.08.14.15.06.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Aug 2015 15:06:09 -0700 (PDT)
Received: by qkdv3 with SMTP id v3so30057742qkd.3
        for <linux-mm@kvack.org>; Fri, 14 Aug 2015 15:06:09 -0700 (PDT)
Date: Fri, 14 Aug 2015 18:06:06 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC PATCH 1/7] x86, mm: ZONE_DEVICE for "device memory"
Message-ID: <20150814220605.GB3265@gmail.com>
References: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com>
 <20150813035005.36913.77364.stgit@otcpl-skl-sds-2.jf.intel.com>
 <20150814213714.GA3265@gmail.com>
 <CAPcyv4ib244VMSdhHDWHRnmCvYdteUEzT+ehTzitSY42m2Tt=w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4ib244VMSdhHDWHRnmCvYdteUEzT+ehTzitSY42m2Tt=w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Boaz Harrosh <boaz@plexistor.com>, Rik van Riel <riel@redhat.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Hansen <dave.hansen@linux.intel.com>, david <david@fromorbit.com>, Ingo Molnar <mingo@kernel.org>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On Fri, Aug 14, 2015 at 02:52:15PM -0700, Dan Williams wrote:
> On Fri, Aug 14, 2015 at 2:37 PM, Jerome Glisse <j.glisse@gmail.com> wrote:
> > On Wed, Aug 12, 2015 at 11:50:05PM -0400, Dan Williams wrote:
> >> While pmem is usable as a block device or via DAX mappings to userspace
> >> there are several usage scenarios that can not target pmem due to its
> >> lack of struct page coverage. In preparation for "hot plugging" pmem
> >> into the vmemmap add ZONE_DEVICE as a new zone to tag these pages
> >> separately from the ones that are subject to standard page allocations.
> >> Importantly "device memory" can be removed at will by userspace
> >> unbinding the driver of the device.
> >>
> >> Having a separate zone prevents allocation and otherwise marks these
> >> pages that are distinct from typical uniform memory.  Device memory has
> >> different lifetime and performance characteristics than RAM.  However,
> >> since we have run out of ZONES_SHIFT bits this functionality currently
> >> depends on sacrificing ZONE_DMA.
> >>
> >> arch_add_memory() is reorganized a bit in preparation for a new
> >> arch_add_dev_memory() api, for now there is no functional change to the
> >> memory hotplug code.
> >>
> >> Cc: H. Peter Anvin <hpa@zytor.com>
> >> Cc: Ingo Molnar <mingo@redhat.com>
> >> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> >> Cc: Rik van Riel <riel@redhat.com>
> >> Cc: Mel Gorman <mgorman@suse.de>
> >> Cc: linux-mm@kvack.org
> >> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> >> ---
> >>  arch/x86/Kconfig       |   13 +++++++++++++
> >>  arch/x86/mm/init_64.c  |   32 +++++++++++++++++++++-----------
> >>  include/linux/mmzone.h |   23 +++++++++++++++++++++++
> >>  mm/memory_hotplug.c    |    5 ++++-
> >>  mm/page_alloc.c        |    3 +++
> >>  5 files changed, 64 insertions(+), 12 deletions(-)
> >>
> >> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> >> index b3a1a5d77d92..64829b17980b 100644
> >> --- a/arch/x86/Kconfig
> >> +++ b/arch/x86/Kconfig
> >> @@ -308,6 +308,19 @@ config ZONE_DMA
> >>
> >>         If unsure, say Y.
> >>
> >> +config ZONE_DEVICE
> >> +     bool "Device memory (pmem, etc...) hotplug support" if EXPERT
> >> +     default !ZONE_DMA
> >> +     depends on !ZONE_DMA
> >> +     help
> >> +       Device memory hotplug support allows for establishing pmem,
> >> +       or other device driver discovered memory regions, in the
> >> +       memmap. This allows pfn_to_page() lookups of otherwise
> >> +       "device-physical" addresses which is needed for using a DAX
> >> +       mapping in an O_DIRECT operation, among other things.
> >> +
> >> +       If FS_DAX is enabled, then say Y.
> >> +
> >>  config SMP
> >>       bool "Symmetric multi-processing support"
> >>       ---help---
> >> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> >> index 3fba623e3ba5..94f0fa56f0ed 100644
> >> --- a/arch/x86/mm/init_64.c
> >> +++ b/arch/x86/mm/init_64.c
> [..]
> >> @@ -701,11 +694,28 @@ int arch_add_memory(int nid, u64 start, u64 size)
> >>       ret = __add_pages(nid, zone, start_pfn, nr_pages);
> >>       WARN_ON_ONCE(ret);
> >>
> >> -     /* update max_pfn, max_low_pfn and high_memory */
> >> -     update_end_of_memory_vars(start, size);
> >> +     /*
> >> +      * Update max_pfn, max_low_pfn and high_memory, unless we added
> >> +      * "device memory" which should not effect max_pfn
> >> +      */
> >> +     if (!is_dev_zone(zone))
> >> +             update_end_of_memory_vars(start, size);
> >
> > What is the rational for not updating max_pfn, max_low_pfn, ... ?
> >
> 
> The idea is that this memory is not meant to be available to the page
> allocator and should not count as new memory capacity.  We're only
> hotplugging it to get struct page coverage.

But this sounds bogus to me to rely on max_pfn to stay smaller than
first_dev_pfn.  For instance you might plug a device that register
dev memory and then some regular memory might be hotplug, effectively
updating max_pfn to a value bigger than first_dev_pfn.

Also i do not think that the buddy allocator use max_pfn or max_low_pfn
to consider page/zone for allocation or not.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
