Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4D28E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 14:08:08 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id j13so1778572oii.8
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 11:08:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 101sor11666101otu.130.2018.12.18.11.08.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Dec 2018 11:08:06 -0800 (PST)
MIME-Version: 1.0
References: <154483851047.1672629.15001135860756738866.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154483852617.1672629.2068988045031389440.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20181216124335.GB30212@rapoport-lnx> <CAPcyv4hXPm4GnBheTZ5WN6s5Kiw02MW1aWA-s2qC8BqfthT3Yg@mail.gmail.com>
 <20181218091121.GA25499@rapoport-lnx>
In-Reply-To: <20181218091121.GA25499@rapoport-lnx>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 18 Dec 2018 11:07:55 -0800
Message-ID: <CAPcyv4iDkEo+xG-AJetOfp12RO8qDV0t=AF3rvoq5GKc5VFuzw@mail.gmail.com>
Subject: Re: [PATCH v5 3/5] mm: Shuffle initial free memory to improve
 memory-side-cache utilization
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Linux MM <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Dec 18, 2018 at 1:11 AM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> On Mon, Dec 17, 2018 at 11:56:36AM -0800, Dan Williams wrote:
> > On Sun, Dec 16, 2018 at 4:43 AM Mike Rapoport <rppt@linux.ibm.com> wrote:
> > >
> > > On Fri, Dec 14, 2018 at 05:48:46PM -0800, Dan Williams wrote:
> > > > Randomization of the page allocator improves the average utilization of
> > > > a direct-mapped memory-side-cache. Memory side caching is a platform
> > > > capability that Linux has been previously exposed to in HPC
> > > > (high-performance computing) environments on specialty platforms. In
> > > > that instance it was a smaller pool of high-bandwidth-memory relative to
> > > > higher-capacity / lower-bandwidth DRAM. Now, this capability is going to
> > > > be found on general purpose server platforms where DRAM is a cache in
> > > > front of higher latency persistent memory [1].
> > [..]
> > > > diff --git a/mm/memblock.c b/mm/memblock.c
> > > > index 185bfd4e87bb..fd617928ccc1 100644
> > > > --- a/mm/memblock.c
> > > > +++ b/mm/memblock.c
> > > > @@ -834,8 +834,16 @@ int __init_memblock memblock_set_sidecache(phys_addr_t base, phys_addr_t size,
> > > >               return ret;
> > > >
> > > >       for (i = start_rgn; i < end_rgn; i++) {
> > > > -             type->regions[i].cache_size = cache_size;
> > > > -             type->regions[i].direct_mapped = direct_mapped;
> > > > +             struct memblock_region *r = &type->regions[i];
> > > > +
> > > > +             r->cache_size = cache_size;
> > > > +             r->direct_mapped = direct_mapped;
> > >
> > > I think this change can be merged into the previous patch
> >
> > Ok, will do.
> >
> > > > +             /*
> > > > +              * Enable randomization for amortizing direct-mapped
> > > > +              * memory-side-cache conflicts.
> > > > +              */
> > > > +             if (r->size > r->cache_size && r->direct_mapped)
> > > > +                     page_alloc_shuffle_enable();
> > >
> > > It seems that this is the only use for ->direct_mapped in the memblock
> > > code. Wouldn't cache_size != 0 suffice? I.e., in the code that sets the
> > > memblock region attributes, the cache_size can be set to 0 for the non
> > > direct mapped caches, isn't it?
> > >
> >
> > The HMAT specification allows for other cache-topologies, so it's not
> > sufficient to just look for non-zero size when a platform implements a
> > set-associative cache. The expectation is that a set-associative cache
> > would not need the kernel to perform memory randomization to improve
> > the cache utilization.
> >
> > The check for memory size > cache-size is a sanity check for a
> > platform BIOS or system configuration that mis-reports or mis-sizes
> > the cache.
>
> Apparently I didn't explain my point well.
>
> The acpi_numa_memory_affinity_init() already knows whether the cache is
> direct mapped or a set-associative. It can just skip calling
> memblock_set_sidecache() for the set-associative case.
>
> Another thing I've noticed only now, is that memory randomization is
> enabled if there is at least one memory region with a direct mapped side
> cache attached and once the randomization is on the cache size and the
> mapping mode do not matter. So, I think it's not necessary to store them in
> the memory region at all.

Fair enough. I was anticipating the case when non-ACPI systems gain
this capability, but you're right no need to design that now. The size
sanity check has some small value, but given there is an override and
broken platform firmware would need to be fixed I don't think we lose
much by getting rid of it. Will re-flow without memblock integration.
