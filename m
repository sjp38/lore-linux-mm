Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 10E466B2887
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 20:05:44 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id m1-v6so12022007plb.13
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 17:05:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o10-v6sor44361578plk.56.2018.11.21.17.05.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Nov 2018 17:05:42 -0800 (PST)
MIME-Version: 1.0
References: <20181111090341.120786-1-drinkcat@chromium.org>
 <0100016737801f14-84f1265d-4577-4dcf-ad57-90dbc8e0a78f-000000@email.amazonses.com>
 <20181121213853.GL3065@bombadil.infradead.org> <c5ccde1e-a711-ad33-537c-2d5a0bd9edd4@arm.com>
In-Reply-To: <c5ccde1e-a711-ad33-537c-2d5a0bd9edd4@arm.com>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Thu, 22 Nov 2018 09:05:30 +0800
Message-ID: <CANMq1KASTr_zCZnymfT173BLgGH0p0Pr7ortO1sdm_yb9rjKUg@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] iommu/io-pgtable-arm-v7s: Use DMA32 zone for page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: willy@infradead.org, Christoph Lameter <cl@linux.com>, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, iommu@lists.linux-foundation.org, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com

On Thu, Nov 22, 2018 at 6:27 AM Robin Murphy <robin.murphy@arm.com> wrote:
>
> On 2018-11-21 9:38 pm, Matthew Wilcox wrote:
> > On Wed, Nov 21, 2018 at 06:20:02PM +0000, Christopher Lameter wrote:
> >> On Sun, 11 Nov 2018, Nicolas Boichat wrote:
> >>
> >>> This is a follow-up to the discussion in [1], to make sure that the page
> >>> tables allocated by iommu/io-pgtable-arm-v7s are contained within 32-bit
> >>> physical address space.
> >>
> >> Page tables? This means you need a page frame? Why go through the slab
> >> allocators?
> >
> > Because this particular architecture has sub-page-size PMD page tables.
> > We desperately need to hoist page table allocation out of the architectures;
> > there're a bunch of different implementations and they're mostly bad,
> > one way or another.
>
> These are IOMMU page tables, rather than CPU ones, so we're already well
> outside arch code - indeed the original motivation of io-pgtable was to
> be entirely independent of the p*d types and arch-specific MM code (this
> Armv7 short-descriptor format is already "non-native" when used by
> drivers in an arm64 kernel).
>
> There are various efficiency reasons for using regular kernel memory
> instead of coherent DMA allocations - for the most part it works well,
> we just have the odd corner case like this one where the 32-bit format
> gets used on 64-bit systems such that the tables themselves still need
> to be allocated below 4GB (although the final output address can point
> at higher memory by virtue of the IOMMU in question not implementing
> permissions and repurposing some of those PTE fields as extra address bits).
>
> TBH, if this DMA32 stuff is going to be contentious we could possibly
> just rip out the offending kmem_cache - it seemed like good practice for
> the use-case, but provided kzalloc(SZ_1K, gfp | GFP_DMA32) can be relied
> upon to give the same 1KB alignment and chance of succeeding as the
> equivalent kmem_cache_alloc(), then we could quite easily make do with
> that instead.

Yes, but if we want to use kzalloc, we'll need to create
kmalloc_caches for DMA32, which seems wasteful as there are no other
users (see my comment here:
https://patchwork.kernel.org/patch/10677525/#22332697).

Thanks,

> Thanks,
> Robin.
>
> > For each level of page table we generally have three cases:
> >
> > 1. single page
> > 2. sub-page, naturally aligned
> > 3. multiple pages, naturally aligned
> >
> > for 1 and 3, the page allocator will do just fine.
> > for 2, we should have a per-MM page_frag allocator.  s390 already has
> > something like this, although it's more complicated.  ppc also has
> > something a little more complex for the cases when it's configured with
> > a 64k page size but wants to use a 4k page table entry.
> >
> > I'd like x86 to be able to simply do:
> >
> > #define pte_alloc_one(mm, addr)       page_alloc_table(mm, addr, 0)
> > #define pmd_alloc_one(mm, addr)       page_alloc_table(mm, addr, 0)
> > #define pud_alloc_one(mm, addr)       page_alloc_table(mm, addr, 0)
> > #define p4d_alloc_one(mm, addr)       page_alloc_table(mm, addr, 0)
> >
> > An architecture with 4k page size and needing a 16k PMD would do:
> >
> > #define pmd_alloc_one(mm, addr) page_alloc_table(mm, addr, 2)
> >
> > while an architecture with a 64k page size needing a 4k PTE would do:
> >
> > #define ARCH_PAGE_TABLE_FRAG
> > #define pte_alloc_one(mm, addr) pagefrag_alloc_table(mm, addr, 4096)
> >
> > I haven't had time to work on this, but perhaps someone with a problem
> > that needs fixing would like to, instead of burying yet another awful
> > implementation away in arch/ somewhere.
> >
