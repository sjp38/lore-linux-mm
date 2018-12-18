Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 045EB8E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 04:11:34 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id t10so11430588plo.13
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 01:11:33 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h67si13978230pfb.146.2018.12.18.01.11.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 01:11:32 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBI98x6d129221
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 04:11:32 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pevbnv7aj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 04:11:31 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 18 Dec 2018 09:11:29 -0000
Date: Tue, 18 Dec 2018 11:11:21 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH v5 3/5] mm: Shuffle initial free memory to improve
 memory-side-cache utilization
References: <154483851047.1672629.15001135860756738866.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154483852617.1672629.2068988045031389440.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20181216124335.GB30212@rapoport-lnx>
 <CAPcyv4hXPm4GnBheTZ5WN6s5Kiw02MW1aWA-s2qC8BqfthT3Yg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hXPm4GnBheTZ5WN6s5Kiw02MW1aWA-s2qC8BqfthT3Yg@mail.gmail.com>
Message-Id: <20181218091121.GA25499@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Linux MM <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Dec 17, 2018 at 11:56:36AM -0800, Dan Williams wrote:
> On Sun, Dec 16, 2018 at 4:43 AM Mike Rapoport <rppt@linux.ibm.com> wrote:
> >
> > On Fri, Dec 14, 2018 at 05:48:46PM -0800, Dan Williams wrote:
> > > Randomization of the page allocator improves the average utilization of
> > > a direct-mapped memory-side-cache. Memory side caching is a platform
> > > capability that Linux has been previously exposed to in HPC
> > > (high-performance computing) environments on specialty platforms. In
> > > that instance it was a smaller pool of high-bandwidth-memory relative to
> > > higher-capacity / lower-bandwidth DRAM. Now, this capability is going to
> > > be found on general purpose server platforms where DRAM is a cache in
> > > front of higher latency persistent memory [1].
> [..]
> > > diff --git a/mm/memblock.c b/mm/memblock.c
> > > index 185bfd4e87bb..fd617928ccc1 100644
> > > --- a/mm/memblock.c
> > > +++ b/mm/memblock.c
> > > @@ -834,8 +834,16 @@ int __init_memblock memblock_set_sidecache(phys_addr_t base, phys_addr_t size,
> > >               return ret;
> > >
> > >       for (i = start_rgn; i < end_rgn; i++) {
> > > -             type->regions[i].cache_size = cache_size;
> > > -             type->regions[i].direct_mapped = direct_mapped;
> > > +             struct memblock_region *r = &type->regions[i];
> > > +
> > > +             r->cache_size = cache_size;
> > > +             r->direct_mapped = direct_mapped;
> >
> > I think this change can be merged into the previous patch
> 
> Ok, will do.
> 
> > > +             /*
> > > +              * Enable randomization for amortizing direct-mapped
> > > +              * memory-side-cache conflicts.
> > > +              */
> > > +             if (r->size > r->cache_size && r->direct_mapped)
> > > +                     page_alloc_shuffle_enable();
> >
> > It seems that this is the only use for ->direct_mapped in the memblock
> > code. Wouldn't cache_size != 0 suffice? I.e., in the code that sets the
> > memblock region attributes, the cache_size can be set to 0 for the non
> > direct mapped caches, isn't it?
> >
> 
> The HMAT specification allows for other cache-topologies, so it's not
> sufficient to just look for non-zero size when a platform implements a
> set-associative cache. The expectation is that a set-associative cache
> would not need the kernel to perform memory randomization to improve
> the cache utilization.
> 
> The check for memory size > cache-size is a sanity check for a
> platform BIOS or system configuration that mis-reports or mis-sizes
> the cache.

Apparently I didn't explain my point well.

The acpi_numa_memory_affinity_init() already knows whether the cache is
direct mapped or a set-associative. It can just skip calling
memblock_set_sidecache() for the set-associative case.

Another thing I've noticed only now, is that memory randomization is
enabled if there is at least one memory region with a direct mapped side
cache attached and once the randomization is on the cache size and the
mapping mode do not matter. So, I think it's not necessary to store them in
the memory region at all.

-- 
Sincerely yours,
Mike.
