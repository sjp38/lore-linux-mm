Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 562CE6B74CF
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 09:40:14 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id t184so12242619oih.22
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 06:40:14 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s34si6537103otb.70.2018.12.05.06.40.12
        for <linux-mm@kvack.org>;
        Wed, 05 Dec 2018 06:40:13 -0800 (PST)
Subject: Re: [PATCH v4 3/3] iommu/io-pgtable-arm-v7s: Request DMA32 memory,
 and improve debugging
References: <20181205054828.183476-1-drinkcat@chromium.org>
 <20181205054828.183476-4-drinkcat@chromium.org>
 <20181205135406.GA29031@infradead.org>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <1d211576-9153-cca1-5cd0-8c9881bd3fa4@arm.com>
Date: Wed, 5 Dec 2018 14:40:06 +0000
MIME-Version: 1.0
In-Reply-To: <20181205135406.GA29031@infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Nicolas Boichat <drinkcat@chromium.org>
Cc: Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com, Matthew Wilcox <willy@infradead.org>

On 05/12/2018 13:54, Christoph Hellwig wrote:
> On Wed, Dec 05, 2018 at 01:48:28PM +0800, Nicolas Boichat wrote:
>> IOMMUs using ARMv7 short-descriptor format require page tables
>> (level 1 and 2) to be allocated within the first 4GB of RAM, even
>> on 64-bit systems.
> 
>> +#ifdef CONFIG_ZONE_DMA32
>> +#define ARM_V7S_TABLE_GFP_DMA GFP_DMA32
>> +#define ARM_V7S_TABLE_SLAB_CACHE SLAB_CACHE_DMA32
>> +#else
>> +#define ARM_V7S_TABLE_GFP_DMA GFP_DMA
>> +#define ARM_V7S_TABLE_SLAB_CACHE SLAB_CACHE_DMA
>> +#endif
> 
> How does using GFP_DMA make sense based on the above?  If the system
> has more than 32-bits worth of RAM it should be using GFP_DMA32, else
> GFP_KERNEL, not GFP_DMA for an arch defined small addressability pool.

32-bit Arm doesn't have ZONE_DMA32, but has (or at least had at the 
time) a 2GB ZONE_DMA. Whether we actually need that or not depends on 
how this all interacts with LPAE and highmem, but I'm not sure of those 
details off-hand.

Robin.
