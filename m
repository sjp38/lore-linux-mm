Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4C61A6B77E6
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 22:50:09 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id s71so18459463pfi.22
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 19:50:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q204sor29341651pgq.70.2018.12.05.19.50.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 19:50:07 -0800 (PST)
MIME-Version: 1.0
References: <20181205054828.183476-1-drinkcat@chromium.org>
 <20181205054828.183476-3-drinkcat@chromium.org> <5eddd264-5527-a98e-fc8b-31ea89f474db@suse.cz>
In-Reply-To: <5eddd264-5527-a98e-fc8b-31ea89f474db@suse.cz>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Thu, 6 Dec 2018 11:49:55 +0800
Message-ID: <CANMq1KAL7TcVa4xF8=NdK2cs0VakEq5i6MyCvfmYTGCmJ78-ag@mail.gmail.com>
Subject: Re: [PATCH v4 2/3] mm: Add support for kmem caches in DMA32 zone
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Will Deacon <will.deacon@arm.com>, Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <joro@8bytes.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, iommu@lists.linux-foundation.org, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com, hch@infradead.org, Matthew Wilcox <willy@infradead.org>

On Wed, Dec 5, 2018 at 10:02 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 12/5/18 6:48 AM, Nicolas Boichat wrote:
> > In some cases (e.g. IOMMU ARMv7s page allocator), we need to allocate
> > data structures smaller than a page with GFP_DMA32 flag.
> >
> > This change makes it possible to create a custom cache in DMA32 zone
> > using kmem_cache_create, then allocate memory using kmem_cache_alloc.
> >
> > We do not create a DMA32 kmalloc cache array, as there are currently
> > no users of kmalloc(..., GFP_DMA32). The new test in check_slab_flags
> > ensures that such calls still fail (as they do before this change).
> >
> > Fixes: ad67f5a6545f ("arm64: replace ZONE_DMA with ZONE_DMA32")
>
> Same as my comment for 1/3.

I'll drop.

> > Signed-off-by: Nicolas Boichat <drinkcat@chromium.org>
>
> In general,
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>
> Some comments below:
>
> > ---
> >
> > Changes since v2:
> >  - Clarified commit message
> >  - Add entry in sysfs-kernel-slab to document the new sysfs file
> >
> > (v3 used the page_frag approach)
> >
> > Documentation/ABI/testing/sysfs-kernel-slab |  9 +++++++++
> >  include/linux/slab.h                        |  2 ++
> >  mm/internal.h                               |  8 ++++++--
> >  mm/slab.c                                   |  4 +++-
> >  mm/slab.h                                   |  3 ++-
> >  mm/slab_common.c                            |  2 +-
> >  mm/slub.c                                   | 18 +++++++++++++++++-
> >  7 files changed, 40 insertions(+), 6 deletions(-)
> >
> > diff --git a/Documentation/ABI/testing/sysfs-kernel-slab b/Documentation/ABI/testing/sysfs-kernel-slab
> > index 29601d93a1c2ea..d742c6cfdffbe9 100644
> > --- a/Documentation/ABI/testing/sysfs-kernel-slab
> > +++ b/Documentation/ABI/testing/sysfs-kernel-slab
> > @@ -106,6 +106,15 @@ Description:
> >               are from ZONE_DMA.
> >               Available when CONFIG_ZONE_DMA is enabled.
> >
> > +What:                /sys/kernel/slab/cache/cache_dma32
> > +Date:                December 2018
> > +KernelVersion:       4.21
> > +Contact:     Nicolas Boichat <drinkcat@chromium.org>
> > +Description:
> > +             The cache_dma32 file is read-only and specifies whether objects
> > +             are from ZONE_DMA32.
> > +             Available when CONFIG_ZONE_DMA32 is enabled.
>
> I don't have a strong opinion. It's a new file, yeah, but consistent
> with already existing ones. I'd leave the decision with SL*B maintainers.
>
> >  What:                /sys/kernel/slab/cache/cpu_slabs
> >  Date:                May 2007
> >  KernelVersion:       2.6.22
> > diff --git a/include/linux/slab.h b/include/linux/slab.h
> > index 11b45f7ae4057c..9449b19c5f107a 100644
> > --- a/include/linux/slab.h
> > +++ b/include/linux/slab.h
> > @@ -32,6 +32,8 @@
> >  #define SLAB_HWCACHE_ALIGN   ((slab_flags_t __force)0x00002000U)
> >  /* Use GFP_DMA memory */
> >  #define SLAB_CACHE_DMA               ((slab_flags_t __force)0x00004000U)
> > +/* Use GFP_DMA32 memory */
> > +#define SLAB_CACHE_DMA32     ((slab_flags_t __force)0x00008000U)
> >  /* DEBUG: Store the last owner for bug hunting */
> >  #define SLAB_STORE_USER              ((slab_flags_t __force)0x00010000U)
> >  /* Panic if kmem_cache_create() fails */
> > diff --git a/mm/internal.h b/mm/internal.h
> > index a2ee82a0cd44ae..fd244ad716eaf8 100644
> > --- a/mm/internal.h
> > +++ b/mm/internal.h
> > @@ -14,6 +14,7 @@
> >  #include <linux/fs.h>
> >  #include <linux/mm.h>
> >  #include <linux/pagemap.h>
> > +#include <linux/slab.h>
> >  #include <linux/tracepoint-defs.h>
> >
> >  /*
> > @@ -34,9 +35,12 @@
> >  #define GFP_CONSTRAINT_MASK (__GFP_HARDWALL|__GFP_THISNODE)
> >
> >  /* Check for flags that must not be used with a slab allocator */
> > -static inline gfp_t check_slab_flags(gfp_t flags)
> > +static inline gfp_t check_slab_flags(gfp_t flags, slab_flags_t slab_flags)
> >  {
> > -     gfp_t bug_mask = __GFP_DMA32 | __GFP_HIGHMEM | ~__GFP_BITS_MASK;
> > +     gfp_t bug_mask = __GFP_HIGHMEM | ~__GFP_BITS_MASK;
> > +
> > +     if (!IS_ENABLED(CONFIG_ZONE_DMA32) || !(slab_flags & SLAB_CACHE_DMA32))
> > +             bug_mask |= __GFP_DMA32;
>
> I'll point out that this is not even strictly needed AFAICS, as only
> flags passed to kmem_cache_alloc() are checked - the cache->allocflags
> derived from SLAB_CACHE_DMA32 are appended only after check_slab_flags()
> (in both SLAB and SLUB AFAICS). And for a cache created with
> SLAB_CACHE_DMA32, the caller of kmem_cache_alloc() doesn't need to also
> include __GFP_DMA32, the allocation will be from ZONE_DMA32 regardless.

Yes, you're right. I also looked at existing users of SLAB_CACHE_DMA,
and there is one case in drivers/scsi/scsi_lib.c where GFP_DMA is not
be passed (all the other users pass it).

I can drop GFP_DMA32 from my call in io-pgtable-arm-v7s.c.

> So it would be fine even unchanged. The check would anyway need some
> more love to catch the same with __GFP_DMA to be consistent and cover
> all corner cases.

Yes, the test is not complete. If we really wanted this to be
accurate, we'd need to check that GFP_* exactly matches SLAB_CACHE_*.

The only problem with dropping this is test that we should restore
GFP_DMA32 warning/errors somewhere else (as Christopher pointed out
here: https://lkml.org/lkml/2018/11/22/430), especially for kmalloc
case.

Maybe this can be done in kmalloc_slab.

> >
> >       if (unlikely(flags & bug_mask)) {
> >               gfp_t invalid_mask = flags & bug_mask;
