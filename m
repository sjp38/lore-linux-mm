Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 95A4D6B06F0
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 06:58:05 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 129-v6so1294239pfx.11
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 03:58:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 81-v6sor8804887pfk.64.2018.11.09.03.58.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Nov 2018 03:58:03 -0800 (PST)
MIME-Version: 1.0
References: <20181109082448.150302-1-drinkcat@chromium.org>
 <20181109082448.150302-2-drinkcat@chromium.org> <00afe803-22dd-5a75-70aa-dda0c7752470@suse.cz>
In-Reply-To: <00afe803-22dd-5a75-70aa-dda0c7752470@suse.cz>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Fri, 9 Nov 2018 19:57:50 +0800
Message-ID: <CANMq1KB84Lpe_QbiuaKaBOwSsYr9Cis-gv5xpXaV5qjU=ON=7w@mail.gmail.com>
Subject: Re: [PATCH RFC 1/3] mm: When CONFIG_ZONE_DMA32 is set, use DMA32 for SLAB_CACHE_DMA
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vbabka@suse.cz
Cc: robin.murphy@arm.com, will.deacon@arm.com, joro@8bytes.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, mgorman@techsingularity.net, yehs1@lenovo.com, rppt@linux.vnet.ibm.com, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, iommu@lists.linux-foundation.org, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, yong.wu@mediatek.com, Matthias Brugger <matthias.bgg@gmail.com>, tfiga@google.com, yingjoe.chen@mediatek.com, Alexander.Levin@microsoft.com

On Fri, Nov 9, 2018 at 6:43 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 11/9/18 9:24 AM, Nicolas Boichat wrote:
> > Some callers, namely iommu/io-pgtable-arm-v7s, expect the physical
> > address returned by kmem_cache_alloc with GFP_DMA parameter to be
> > a 32-bit address.
> >
> > Instead of adding a separate SLAB_CACHE_DMA32 (and then audit
> > all the calls to check if they require memory from DMA or DMA32
> > zone), we simply allocate SLAB_CACHE_DMA cache in DMA32 region,
> > if CONFIG_ZONE_DMA32 is set.
> >
> > Fixes: ad67f5a6545f ("arm64: replace ZONE_DMA with ZONE_DMA32")
> > Signed-off-by: Nicolas Boichat <drinkcat@chromium.org>
> > ---
> >  include/linux/slab.h | 13 ++++++++++++-
> >  mm/slab.c            |  2 +-
> >  mm/slub.c            |  2 +-
> >  3 files changed, 14 insertions(+), 3 deletions(-)
> >
> > diff --git a/include/linux/slab.h b/include/linux/slab.h
> > index 918f374e7156f4..390afe90c5dec0 100644
> > --- a/include/linux/slab.h
> > +++ b/include/linux/slab.h
> > @@ -30,7 +30,7 @@
> >  #define SLAB_POISON          ((slab_flags_t __force)0x00000800U)
> >  /* Align objs on cache lines */
> >  #define SLAB_HWCACHE_ALIGN   ((slab_flags_t __force)0x00002000U)
> > -/* Use GFP_DMA memory */
> > +/* Use GFP_DMA or GFP_DMA32 memory */
> >  #define SLAB_CACHE_DMA               ((slab_flags_t __force)0x00004000U)
> >  /* DEBUG: Store the last owner for bug hunting */
> >  #define SLAB_STORE_USER              ((slab_flags_t __force)0x00010000U)
> > @@ -126,6 +126,17 @@
> >  #define ZERO_OR_NULL_PTR(x) ((unsigned long)(x) <= \
> >                               (unsigned long)ZERO_SIZE_PTR)
> >
> > +/*
> > + * When ZONE_DMA32 is defined, have SLAB_CACHE_DMA allocate memory with
> > + * GFP_DMA32 instead of GFP_DMA, as this is what some of the callers
> > + * require (instead of duplicating cache for DMA and DMA32 zones).
> > + */
> > +#ifdef CONFIG_ZONE_DMA32
> > +#define SLAB_CACHE_DMA_GFP GFP_DMA32
> > +#else
> > +#define SLAB_CACHE_DMA_GFP GFP_DMA
> > +#endif
>
> AFAICS this will break e.g. x86 which can have both ZONE_DMA and
> ZONE_DMA32, and now you would make kmalloc(__GFP_DMA) return objects
> from ZONE_DMA32 instead of __ZONE_DMA, which can break something.

Oh, I was not aware that both ZONE_DMA and ZONE_DMA32 can be defined
at the same time. I guess the test should be inverted, something like
this (can be simplified...):
#ifdef CONFIG_ZONE_DMA
#define SLAB_CACHE_DMA_GFP GFP_DMA
#elif defined(CONFIG_ZONE_DMA32)
#define SLAB_CACHE_DMA_GFP GFP_DMA32
#else
#define SLAB_CACHE_DMA_GFP GFP_DMA // ?
#endif

> Also I'm probably missing the point of this all. In patch 3 you use
> __get_dma32_pages() thus __get_free_pages(__GFP_DMA32), which uses
> alloc_pages, thus the page allocator directly, and there's no slab
> caches involved.

__get_dma32_pages fixes level 1 page allocations in the patch 3.

This change fixes level 2 page allocations
(kmem_cache_zalloc(data->l2_tables, gfp | GFP_DMA)), by transparently
remapping GFP_DMA to an underlying ZONE_DMA32.

The alternative would be to create a new SLAB_CACHE_DMA32 when
CONFIG_ZONE_DMA32 is defined, but then I'm concerned that the callers
would need to choose between the 2 (GFP_DMA or GFP_DMA32...), and also
need to use some ifdefs (but maybe that's not a valid concern?).

> It makes little sense to involve slab for page table
> allocations anyway, as those tend to be aligned to a page size (or
> high-order page size). So what am I missing?

Level 2 tables are ARM_V7S_TABLE_SIZE(2) => 1kb, so we'd waste 3kb if
we allocated a full page.

Thanks,
