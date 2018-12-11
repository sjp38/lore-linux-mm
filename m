Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id A29AF8E00C9
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 17:50:31 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id u63so8443771oie.17
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 14:50:31 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 4sor8487100otl.67.2018.12.11.14.50.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 14:50:29 -0800 (PST)
MIME-Version: 1.0
References: <20181211010310.8551-1-keith.busch@intel.com> <20181211010310.8551-3-keith.busch@intel.com>
 <CAPcyv4gEpxigPqc0PgDE0YCL3Ot+wPfvChAZqUTtdYR2WDxaJg@mail.gmail.com>
 <20181211165518.GB8101@localhost.localdomain> <CAPcyv4id0mgjdBPPw8Y26rodOEQ=EHfaTrgasU5g4X7u=dS2xw@mail.gmail.com>
 <20181211204451.GD8101@localhost.localdomain>
In-Reply-To: <20181211204451.GD8101@localhost.localdomain>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 11 Dec 2018 14:50:17 -0800
Message-ID: <CAPcyv4hmCJLg6mT=Fc1gwz7E7D5Nm5fO0erqqF0yUb=HbvGf6g@mail.gmail.com>
Subject: Re: [PATCHv2 02/12] acpi/hmat: Parse and report heterogeneous memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ACPI <linux-acpi@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Tue, Dec 11, 2018 at 12:47 PM Keith Busch <keith.busch@intel.com> wrote:
>
> On Tue, Dec 11, 2018 at 12:29:45PM -0800, Dan Williams wrote:
> > On Tue, Dec 11, 2018 at 8:58 AM Keith Busch <keith.busch@intel.com> wrote:
> > > +static int __init
> > > +acpi_parse_cache(union acpi_subtable_headers *header, const unsigned long end)
> > > +{
> > > +       struct acpi_hmat_cache *cache = (void *)header;
> > > +       u32 attrs;
> > > +
> > > +       attrs = cache->cache_attributes;
> > > +       if (((attrs & ACPI_HMAT_CACHE_ASSOCIATIVITY) >> 8) ==
> > > +                                               ACPI_HMAT_CA_DIRECT_MAPPED)
> > > +               set_bit(cache->memory_PD, node_side_cached);
> >
> > I'm not sure I see a use case for 'node_side_cached'. Instead I need
> > to know if a cache intercepts a "System RAM" resource, because a cache
> > in front of a reserved address range would not be impacted by page
> > allocator randomization. Or, are you saying have memblock generically
> > describes this capability and move the responsibility of acting on
> > that data to a higher level?
>
> The "node_side_cached" array isn't intended to be used directly. It's
> just holding the PXM's that HMAT says have a side cache so we know which
> PXM's have that attribute before parsing SRAT's memory affinity.
>
> The intention was that this is just another attribute of a memory range
> similiar to hotpluggable. Whoever needs to use it may query it from
> the memblock, if that makes sense.
>
> > The other detail to consider is the cache ratio size, but that would
> > be a follow on feature. The use case is to automatically determine the
> > ratio to pass to numa_emulation:
> >
> >     cc9aec03e58f x86/numa_emulation: Introduce uniform split capability
>
> Will look into that.
>
> > > diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> > > index aee299a6aa76..a24c918a4496 100644
> > > --- a/include/linux/memblock.h
> > > +++ b/include/linux/memblock.h
> > > @@ -44,6 +44,7 @@ enum memblock_flags {
> > >         MEMBLOCK_HOTPLUG        = 0x1,  /* hotpluggable region */
> > >         MEMBLOCK_MIRROR         = 0x2,  /* mirrored region */
> > >         MEMBLOCK_NOMAP          = 0x4,  /* don't add to kernel direct mapping */
> > > +       MEMBLOCK_SIDECACHED     = 0x8,  /* System side caches memory access */
> >
> > I'm concerned that we may be stretching memblock past its intended use
> > case especially for just this randomization case. For example, I think
> > memblock_find_in_range() gets confused in the presence of
> > MEMBLOCK_SIDECACHED memblocks.
>
> Ok, I see. Is there a better structure or interface that you may recommend
> for your use case to identify which memory ranges contain this attribute?

Well, no I don't think there is one. We just need to either audit
existing memblock users to make sure they are prepared for this new
type, or move the cache information somewhere else. I'd be inclined to
just move it to new fields, or a sub-struct in struct memblock_region.
Then we can put the cache set-way info and near memory size
information in there as well. Likely need a new
CONFIG_HAVE_MEMBLOCK_CACHE_INFO gated by the presence of HMAT support.
