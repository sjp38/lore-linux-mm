Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id ADFF36B71DD
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 21:04:13 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id g7so6410632plp.10
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 18:04:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n15sor25021401plp.65.2018.12.04.18.04.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 18:04:12 -0800 (PST)
MIME-Version: 1.0
References: <20181111090341.120786-1-drinkcat@chromium.org>
 <CANMq1KDxmRcWhtaJbrLHqx6yPGkNaK7WNYYf+iFjH1e8XdrwRg@mail.gmail.com> <b99dd00f-fe1c-1cac-8ee3-5b0c1af9a92e@suse.cz>
In-Reply-To: <b99dd00f-fe1c-1cac-8ee3-5b0c1af9a92e@suse.cz>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Wed, 5 Dec 2018 10:04:00 +0800
Message-ID: <CANMq1KDzKJqJwGsW3A90JY_0kgDtAMjOikT-3C9zQG01=3dibQ@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] iommu/io-pgtable-arm-v7s: Use DMA32 zone for page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Robin Murphy <robin.murphy@arm.com>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Matthias Brugger <matthias.bgg@gmail.com>, hch@infradead.org, Matthew Wilcox <willy@infradead.org>, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, iommu@lists.linux-foundation.org, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com, Hsin-Yi Wang <hsinyi@chromium.org>, Daniel Kurtz <djkurtz@chromium.org>

On Tue, Dec 4, 2018 at 10:35 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 12/4/18 10:37 AM, Nicolas Boichat wrote:
> > On Sun, Nov 11, 2018 at 5:04 PM Nicolas Boichat <drinkcat@chromium.org> wrote:
> >>
> >> This is a follow-up to the discussion in [1], to make sure that the page
> >> tables allocated by iommu/io-pgtable-arm-v7s are contained within 32-bit
> >> physical address space.
> >>
> >> [1] https://lists.linuxfoundation.org/pipermail/iommu/2018-November/030876.html
> >
> > Hi everyone,
> >
> > Let's try to summarize here.
> >
> > First, we confirmed that this is a regression, and IOMMU errors happen
> > on 4.19 and linux-next/master on MT8173 (elm, Acer Chromebook R13).
> > The issue most likely starts from ad67f5a6545f ("arm64: replace
> > ZONE_DMA with ZONE_DMA32"), i.e. 4.15, and presumably breaks a number
> > of Mediatek platforms (and maybe others?).
> >
> > We have a few options here:
> > 1. This series [2], that adds support for GFP_DMA32 slab caches,
> > _without_ adding kmalloc caches (since there are no users of
> > kmalloc(..., GFP_DMA32)). I think I've addressed all the comments on
> > the 3 patches, and AFAICT this solution works fine.
> > 2. genalloc. That works, but unless we preallocate 4MB for L2 tables
> > (which is wasteful as we usually only need a handful of L2 tables),
> > we'll need changes in the core (use GFP_ATOMIC) to allow allocating on
> > demand, and as it stands we'd have no way to shrink the allocation.
> > 3. page_frag [3]. That works fine, and the code is quite simple. One
> > drawback is that fragments in partially freed pages cannot be reused
> > (from limited experiments, I see that IOMMU L2 tables are rarely
> > freed, so it's unlikely a whole page would get freed). But given the
> > low number of L2 tables, maybe we can live with that.
> >
> > I think 2 is out. Any preference between 1 and 3? I think 1 makes
> > better use of the memory, so that'd be my preference. But I'm probably
> > missing something.
>
> I would prefer 1 as well. IIRC you already confirmed that alignment
> requirements are not broken for custom kmem caches even in presence of
> SLUB debug options (and I would say it's a bug to be fixed if they
> weren't).

> I just asked (and didn't get a reply I think) about your
> ability to handle the GFP_ATOMIC allocation failures. They should be
> rare when only single page allocations are needed for the kmem cache.
> But in case they are not an option, then preallocating would be needed,
> thus probably option 2.

Oh, sorry, I missed your question.

I don't have a full answer, but:
- The allocations themselves are rare (I count a few 10s of L2 tables
at most on my system, I assume we rarely have >100), and yes, we only
need a single page, so the failures should be exceptional.
- My change is probably not making anything worse: I assume that even
with the current approach using GFP_DMA slab caches on older kernels,
failures could potentially happen. I don't think we've seen those. If
we are really concerned about this, maybe we'd need to modify
mtk_iommu_map to not hold a spinlock (if that's possible), so we don't
need to use GFP_ATOMIC. I suggest we just keep an eye on such issues,
and address them if they show up (we can even revisit genalloc at that
stage).

Anyway, I'll clean up patches for 1 (mostly commit message changes
based on the comments in the threads) and resend.

Thanks,

> > [2] https://patchwork.kernel.org/cover/10677529/, 3 patches
> > [3] https://patchwork.codeaurora.org/patch/671639/
> >
> > Thanks,
> >
> > Nicolas
> >
>
