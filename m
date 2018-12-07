Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 136CD6B7F96
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 03:49:08 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 4so2243093plc.5
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 00:49:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c10sor4269165pgq.28.2018.12.07.00.49.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Dec 2018 00:49:07 -0800 (PST)
MIME-Version: 1.0
References: <20181207061620.107881-1-drinkcat@chromium.org>
 <20181207061620.107881-3-drinkcat@chromium.org> <20181207080551.GA15120@bombadil.infradead.org>
In-Reply-To: <20181207080551.GA15120@bombadil.infradead.org>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Fri, 7 Dec 2018 16:48:54 +0800
Message-ID: <CANMq1KABLMgvGcP-KwKhxmZnO-GuRAKJHf0sBtFaYLnCuHMJOQ@mail.gmail.com>
Subject: Re: [PATCH v5 2/3] iommu/io-pgtable-arm-v7s: Request DMA32 memory,
 and improve debugging
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>, Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <joro@8bytes.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, iommu@lists.linux-foundation.org, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com, hch@infradead.org

On Fri, Dec 7, 2018 at 4:05 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Fri, Dec 07, 2018 at 02:16:19PM +0800, Nicolas Boichat wrote:
> > +#ifdef CONFIG_ZONE_DMA32
> > +#define ARM_V7S_TABLE_GFP_DMA GFP_DMA32
> > +#define ARM_V7S_TABLE_SLAB_CACHE SLAB_CACHE_DMA32
>
> This name doesn't make any sense.  Why not ARM_V7S_TABLE_SLAB_FLAGS ?

Sure, will fix in v6 then.

> > +#else
> > +#define ARM_V7S_TABLE_GFP_DMA GFP_DMA
> > +#define ARM_V7S_TABLE_SLAB_CACHE SLAB_CACHE_DMA
>
> Can you remind me again why it is, on machines which don't support
> ZONE_DMA32, why we have to allocate from ZONE_DMA?  My understanding
> is that 64-bit machines have ZONE_DMA32 and 32-bit machines don't.
> So shouldn't this rather be GFP_KERNEL?

Sorry I mean to reply on the v4 thread, Christoph raised the same
question (https://patchwork.kernel.org/patch/10713025/).

I don't know, and I don't have all the hardware needed to test this
,-( Robin and Will both didn't seem sure.

I'd rather not introduce a new regression, this patch series tries to
fix a known arm64 regression, where we _need_ tables to be in DMA32.
If we want to change 32-bit hardware to use GFP_KERNEL, and we're sure
it works, that's fine by me, but it should be in another patch set.

Hope this makes sense,

Thanks,

> Actually, maybe we could centralise this in gfp.h:
>
> #ifdef CONFIG_64BIT
> # ifdef CONFIG_ZONE_DMA32
> #define GFP_32BIT       GFP_DMA32
> # else
> #define GFP_32BIT       GFP_DMA
> #else /* 32-bit */
> #define GFP_32BIT       GFP_KERNEL
> #endif
>
