Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 97C286B2672
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 11:46:25 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id p128so2436054oib.2
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 08:46:25 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k3si6581330otn.156.2018.11.21.08.46.23
        for <linux-mm@kvack.org>;
        Wed, 21 Nov 2018 08:46:23 -0800 (PST)
Date: Wed, 21 Nov 2018 16:46:38 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v2 3/3] iommu/io-pgtable-arm-v7s: Request DMA32 memory,
 and improve debugging
Message-ID: <20181121164638.GD24883@arm.com>
References: <20181111090341.120786-1-drinkcat@chromium.org>
 <20181111090341.120786-4-drinkcat@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181111090341.120786-4-drinkcat@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Boichat <drinkcat@chromium.org>
Cc: Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <joro@8bytes.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com

On Sun, Nov 11, 2018 at 05:03:41PM +0800, Nicolas Boichat wrote:
> For level 1/2 pages, ensure GFP_DMA32 is used if CONFIG_ZONE_DMA32
> is defined (e.g. on arm64 platforms).
> 
> For level 2 pages, allocate a slab cache in SLAB_CACHE_DMA32.
> 
> Also, print an error when the physical address does not fit in
> 32-bit, to make debugging easier in the future.
> 
> Fixes: ad67f5a6545f ("arm64: replace ZONE_DMA with ZONE_DMA32")
> Signed-off-by: Nicolas Boichat <drinkcat@chromium.org>
> ---
> 
> Changes since v1:
>  - Changed approach to use SLAB_CACHE_DMA32 added by the previous
>    commit.
>  - Use DMA or DMA32 depending on the architecture (DMA for arm,
>    DMA32 for arm64).
> 
> drivers/iommu/io-pgtable-arm-v7s.c | 20 ++++++++++++++++----
>  1 file changed, 16 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/iommu/io-pgtable-arm-v7s.c b/drivers/iommu/io-pgtable-arm-v7s.c
> index 445c3bde04800c..996f7b6d00b44a 100644
> --- a/drivers/iommu/io-pgtable-arm-v7s.c
> +++ b/drivers/iommu/io-pgtable-arm-v7s.c
> @@ -161,6 +161,14 @@
>  
>  #define ARM_V7S_TCR_PD1			BIT(5)
>  
> +#ifdef CONFIG_ZONE_DMA32
> +#define ARM_V7S_TABLE_GFP_DMA GFP_DMA32
> +#define ARM_V7S_TABLE_SLAB_CACHE SLAB_CACHE_DMA32
> +#else
> +#define ARM_V7S_TABLE_GFP_DMA GFP_DMA
> +#define ARM_V7S_TABLE_SLAB_CACHE SLAB_CACHE_DMA
> +#endif

It's a bit grotty that GFP_DMA32 doesn't just map to GFP_DMA on 32-bit
architectures, since then we wouldn't need this #ifdeffery afaict.

Will
