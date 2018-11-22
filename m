Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 834BC6B289C
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 20:20:59 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id e68so11729588plb.3
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 17:20:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p186sor56481799pgp.79.2018.11.21.17.20.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Nov 2018 17:20:58 -0800 (PST)
MIME-Version: 1.0
References: <20181111090341.120786-1-drinkcat@chromium.org>
 <20181111090341.120786-4-drinkcat@chromium.org> <20181121164638.GD24883@arm.com>
 <20181121180000.GU12932@dhcp22.suse.cz>
In-Reply-To: <20181121180000.GU12932@dhcp22.suse.cz>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Thu, 22 Nov 2018 09:20:46 +0800
Message-ID: <CANMq1KCHGZ2vEWg+OQQ-SwvHcU-oMp4qKzEYfLwRYD5ZmRdRsA@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] iommu/io-pgtable-arm-v7s: Request DMA32 memory,
 and improve debugging
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Will Deacon <will.deacon@arm.com>, Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <joro@8bytes.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, iommu@lists.linux-foundation.org, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com

On Thu, Nov 22, 2018 at 2:02 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 21-11-18 16:46:38, Will Deacon wrote:
> > On Sun, Nov 11, 2018 at 05:03:41PM +0800, Nicolas Boichat wrote:
> > > For level 1/2 pages, ensure GFP_DMA32 is used if CONFIG_ZONE_DMA32
> > > is defined (e.g. on arm64 platforms).
> > >
> > > For level 2 pages, allocate a slab cache in SLAB_CACHE_DMA32.
> > >
> > > Also, print an error when the physical address does not fit in
> > > 32-bit, to make debugging easier in the future.
> > >
> > > Fixes: ad67f5a6545f ("arm64: replace ZONE_DMA with ZONE_DMA32")
> > > Signed-off-by: Nicolas Boichat <drinkcat@chromium.org>
> > > ---
> > >
> > > Changes since v1:
> > >  - Changed approach to use SLAB_CACHE_DMA32 added by the previous
> > >    commit.
> > >  - Use DMA or DMA32 depending on the architecture (DMA for arm,
> > >    DMA32 for arm64).
> > >
> > > drivers/iommu/io-pgtable-arm-v7s.c | 20 ++++++++++++++++----
> > >  1 file changed, 16 insertions(+), 4 deletions(-)
> > >
> > > diff --git a/drivers/iommu/io-pgtable-arm-v7s.c b/drivers/iommu/io-pgtable-arm-v7s.c
> > > index 445c3bde04800c..996f7b6d00b44a 100644
> > > --- a/drivers/iommu/io-pgtable-arm-v7s.c
> > > +++ b/drivers/iommu/io-pgtable-arm-v7s.c
> > > @@ -161,6 +161,14 @@
> > >
> > >  #define ARM_V7S_TCR_PD1                    BIT(5)
> > >
> > > +#ifdef CONFIG_ZONE_DMA32
> > > +#define ARM_V7S_TABLE_GFP_DMA GFP_DMA32
> > > +#define ARM_V7S_TABLE_SLAB_CACHE SLAB_CACHE_DMA32
> > > +#else
> > > +#define ARM_V7S_TABLE_GFP_DMA GFP_DMA
> > > +#define ARM_V7S_TABLE_SLAB_CACHE SLAB_CACHE_DMA
> > > +#endif
> >
> > It's a bit grotty that GFP_DMA32 doesn't just map to GFP_DMA on 32-bit
> > architectures, since then we wouldn't need this #ifdeffery afaict.
>
> But GFP_DMA32 should map to GFP_KERNEL on 32b, no? Or what exactly is
> going on in here?

GFP_DMA32 will fail due to check_slab_flags (aka GFP_SLAB_BUG_MASK
before patch 1/3 of this series)... But yes, it may be neater if there
was transparent remapping of GFP_DMA32/SLAB_CACHE_DMA32 to
GFP_DMA/SLAB_CACHE_DMA on 32-bit arch...

> --
> Michal Hocko
> SUSE Labs
