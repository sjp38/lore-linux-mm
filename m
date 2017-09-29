Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E2BFC6B0260
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 08:14:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y29so2786991pff.6
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 05:14:00 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id u6si2906865pld.207.2017.09.29.05.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Sep 2017 05:13:59 -0700 (PDT)
Subject: Re: [PATCH 3/4] iommu/arm-smmu-v3: Use NUMA memory allocations for
 stream tables and comamnd queues
From: Marek Szyprowski <m.szyprowski@samsung.com>
Message-id: <7e270ffc-963c-c1c7-410c-ff3c2e767984@samsung.com>
Date: Fri, 29 Sep 2017 14:13:50 +0200
MIME-version: 1.0
In-reply-to: <db28d6ff-77e5-ed59-c1b8-57c917564a68@arm.com>
Content-type: text/plain; charset="utf-8"; format="flowed"
Content-transfer-encoding: 7bit
Content-language: en-US
References: <20170921085922.11659-1-ganapatrao.kulkarni@cavium.com>
	<20170921085922.11659-4-ganapatrao.kulkarni@cavium.com>
	<CGME20170921115811epcas5p49012d8793fc765bb86830bfc377b6d36@epcas5p4.samsung.com>
	<db28d6ff-77e5-ed59-c1b8-57c917564a68@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>, Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>
Cc: Will.Deacon@arm.com, lorenzo.pieralisi@arm.com, hanjun.guo@linaro.org, joro@8bytes.org, vbabka@suse.cz, akpm@linux-foundation.org, mhocko@suse.com, Tomasz.Nowicki@cavium.com, Robert.Richter@cavium.com, jnair@caviumnetworks.com, gklkml16@gmail.com

Hi Robin,

On 2017-09-21 13:58, Robin Murphy wrote:
> [+Christoph and Marek]
>
> On 21/09/17 09:59, Ganapatrao Kulkarni wrote:
>> Introduce smmu_alloc_coherent and smmu_free_coherent functions to
>> allocate/free dma coherent memory from NUMA node associated with SMMU.
>> Replace all calls of dmam_alloc_coherent with smmu_alloc_coherent
>> for SMMU stream tables and command queues.
> This doesn't work - not only do you lose the 'managed' aspect and risk
> leaking various tables on probe failure or device removal, but more
> importantly, unless you add DMA syncs around all the CPU accesses to the
> tables, you lose the critical 'coherent' aspect, and that's a horribly
> invasive change that I really don't want to make.
>
> Christoph, Marek; how reasonable do you think it is to expect
> dma_alloc_coherent() to be inherently NUMA-aware on NUMA-capable
> systems? SWIOTLB looks fairly straightforward to fix up (for the simple
> allocation case; I'm not sure it's even worth it for bounce-buffering),
> but the likes of CMA might be a little trickier...

I'm not sure if there is any dma-coherent implementation that is NUMA aware.

Maybe author should provide some benchmarks, which show that those 
structures
should be allocated in NUMA-aware way?

On the other hand it is not that hard to add required dma_sync_* calls 
around
all the code which updated those tables.

 > ...

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
