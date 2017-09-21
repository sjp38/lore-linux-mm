Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B46156B0038
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 10:26:41 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k20so6508824wre.6
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 07:26:41 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id b9si1203915wrh.303.2017.09.21.07.26.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Sep 2017 07:26:40 -0700 (PDT)
Date: Thu, 21 Sep 2017 16:26:39 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 3/4] iommu/arm-smmu-v3: Use NUMA memory allocations for
	stream tables and comamnd queues
Message-ID: <20170921142639.GA18211@lst.de>
References: <20170921085922.11659-1-ganapatrao.kulkarni@cavium.com> <20170921085922.11659-4-ganapatrao.kulkarni@cavium.com> <db28d6ff-77e5-ed59-c1b8-57c917564a68@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <db28d6ff-77e5-ed59-c1b8-57c917564a68@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Will.Deacon@arm.com, lorenzo.pieralisi@arm.com, hanjun.guo@linaro.org, joro@8bytes.org, vbabka@suse.cz, akpm@linux-foundation.org, mhocko@suse.com, Tomasz.Nowicki@cavium.com, Robert.Richter@cavium.com, jnair@caviumnetworks.com, gklkml16@gmail.com

On Thu, Sep 21, 2017 at 12:58:04PM +0100, Robin Murphy wrote:
> Christoph, Marek; how reasonable do you think it is to expect
> dma_alloc_coherent() to be inherently NUMA-aware on NUMA-capable
> systems? SWIOTLB looks fairly straightforward to fix up (for the simple
> allocation case; I'm not sure it's even worth it for bounce-buffering),
> but the likes of CMA might be a little trickier...

I think allocating data node local to dev is a good default.  I'm not
sure if we'd still need a version that takes an explicit node, though.

On the one hand devices like NVMe or RDMA nics have queues that are
assigned to specific cpus and thus have an inherent affinity to given
nodes.  On the other hand we'd still need to access the PCIe device,
so for it to make sense we'd need to access the dma memory a lot more
from the host than from the device, and I'm not sure if we ever have
devices where that is the case (which would not be optimal to start
with).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
