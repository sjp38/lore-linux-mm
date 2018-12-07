Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 156A26B7F6A
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 03:06:15 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id l22so2685520pfb.2
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 00:06:15 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s4si2321066plr.306.2018.12.07.00.06.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Dec 2018 00:06:14 -0800 (PST)
Date: Fri, 7 Dec 2018 00:05:51 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v5 2/3] iommu/io-pgtable-arm-v7s: Request DMA32 memory,
 and improve debugging
Message-ID: <20181207080551.GA15120@bombadil.infradead.org>
References: <20181207061620.107881-1-drinkcat@chromium.org>
 <20181207061620.107881-3-drinkcat@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181207061620.107881-3-drinkcat@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Boichat <drinkcat@chromium.org>
Cc: Will Deacon <will.deacon@arm.com>, Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <joro@8bytes.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com, hch@infradead.org

On Fri, Dec 07, 2018 at 02:16:19PM +0800, Nicolas Boichat wrote:
> +#ifdef CONFIG_ZONE_DMA32
> +#define ARM_V7S_TABLE_GFP_DMA GFP_DMA32
> +#define ARM_V7S_TABLE_SLAB_CACHE SLAB_CACHE_DMA32

This name doesn't make any sense.  Why not ARM_V7S_TABLE_SLAB_FLAGS ?

> +#else
> +#define ARM_V7S_TABLE_GFP_DMA GFP_DMA
> +#define ARM_V7S_TABLE_SLAB_CACHE SLAB_CACHE_DMA

Can you remind me again why it is, on machines which don't support
ZONE_DMA32, why we have to allocate from ZONE_DMA?  My understanding
is that 64-bit machines have ZONE_DMA32 and 32-bit machines don't.
So shouldn't this rather be GFP_KERNEL?

Actually, maybe we could centralise this in gfp.h:

#ifdef CONFIG_64BIT
# ifdef CONFIG_ZONE_DMA32
#define GFP_32BIT	GFP_DMA32
# else
#define GFP_32BIT	GFP_DMA
#else /* 32-bit */
#define GFP_32BIT	GFP_KERNEL
#endif
