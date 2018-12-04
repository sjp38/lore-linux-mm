Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4AC6B6FAC
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 11:41:24 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id p131so6577865oia.21
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 08:41:24 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o9si8469931otl.122.2018.12.04.08.41.22
        for <linux-mm@kvack.org>;
        Tue, 04 Dec 2018 08:41:23 -0800 (PST)
Date: Tue, 4 Dec 2018 16:41:42 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v3, RFC] iommu/io-pgtable-arm-v7s: Use page_frag to
 request DMA32 memory
Message-ID: <20181204164142.GA8520@arm.com>
References: <20181204082300.95106-1-drinkcat@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204082300.95106-1-drinkcat@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Boichat <drinkcat@chromium.org>
Cc: Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <joro@8bytes.org>, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com, hch@infradead.org, Matthew Wilcox <willy@infradead.org>

On Tue, Dec 04, 2018 at 04:23:00PM +0800, Nicolas Boichat wrote:
> IOMMUs using ARMv7 short-descriptor format require page tables
> (level 1 and 2) to be allocated within the first 4GB of RAM, even
> on 64-bit systems.
> 
> For level 1/2 tables, ensure GFP_DMA32 is used if CONFIG_ZONE_DMA32
> is defined (e.g. on arm64 platforms).
> 
> For level 2 tables (1 KB), we use page_frag to allocate these pages,
> as we cannot directly use kmalloc (no slab cache for GFP_DMA32) or
> kmem_cache (mm/ code treats GFP_DMA32 as an invalid flag).
> 
> One downside is that we only free the allocated page if all the
> 4 fragments (4 IOMMU L2 tables) are freed, but given that we
> usually only allocate limited number of IOMMU L2 tables, this
> should not have too much impact on memory usage: In the absolute
> worst case (4096 L2 page tables, each on their own 4K page),
> we would use 16 MB of memory for 4 MB of L2 tables.
> 
> Also, print an error when the physical address does not fit in
> 32-bit, to make debugging easier in the future.
> 
> Fixes: ad67f5a6545f ("arm64: replace ZONE_DMA with ZONE_DMA32")
> Signed-off-by: Nicolas Boichat <drinkcat@chromium.org>
> ---
> 
> As an alternative to the series [1], which adds support for GFP_DMA32
> to kmem_cache in mm/. IMHO the solution in [1] is cleaner and more
> efficient, as it allows freed fragments (L2 tables) to be reused, but
> this approach does not require any core change.
> 
> [1] https://patchwork.kernel.org/cover/10677529/, 3 patches
> 
>  drivers/iommu/io-pgtable-arm-v7s.c | 32 ++++++++++++++++--------------
>  1 file changed, 17 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/iommu/io-pgtable-arm-v7s.c b/drivers/iommu/io-pgtable-arm-v7s.c
> index 445c3bde04800c..0de6a51eb6755f 100644
> --- a/drivers/iommu/io-pgtable-arm-v7s.c
> +++ b/drivers/iommu/io-pgtable-arm-v7s.c
> @@ -161,6 +161,12 @@
>  
>  #define ARM_V7S_TCR_PD1			BIT(5)
>  
> +#ifdef CONFIG_ZONE_DMA32
> +#define ARM_V7S_TABLE_GFP_DMA GFP_DMA32
> +#else
> +#define ARM_V7S_TABLE_GFP_DMA GFP_DMA
> +#endif

We may as well include __GFP_ZERO in here too.
Anyway, this looks alright to me:

Acked-by: Will Deacon <will.deacon@arm.com>

But it sounds like you're still on the fence about this patch, so I won't
pick it up unless you ask explicitly.

Will
