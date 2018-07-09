Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8FFBB6B02BF
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 08:20:27 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id b5-v6so10036453ple.20
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 05:20:27 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id f62-v6si15408400pfg.165.2018.07.09.05.20.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 05:20:26 -0700 (PDT)
Received: from eucas1p2.samsung.com (unknown [182.198.249.207])
	by mailout2.w1.samsung.com (KnoxPortal) with ESMTP id 20180709122020euoutp02a84b79cca56a8c4609d42c69d09939b3~-sqUwrJGn0051900519euoutp02j
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 12:20:20 +0000 (GMT)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 0/2] CMA: remove unsupported gfp mask parameter
Date: Mon,  9 Jul 2018 14:19:54 +0200
Message-Id: <20180709122018eucas1p277147b1e6385d552b5a8930d0a8ba91c~-sqSan6292733527335eucas1p2-@eucas1p2.samsung.com>
Content-Type: text/plain; charset="utf-8"
References: <CGME20180709122018eucas1p277147b1e6385d552b5a8930d0a8ba91c@eucas1p2.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Paul Mackerras <paulus@ozlabs.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Chris Zankel <chris@zankel.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Joerg Roedel <joro@8bytes.org>, Sumit Semwal <sumit.semwal@linaro.org>, Robin Murphy <robin.murphy@arm.com>, Laura Abbott <labbott@redhat.com>, linaro-mm-sig@lists.linaro.org

Dear All,

The CMA related functions cma_alloc() and dma_alloc_from_contiguous()
have gfp mask parameter, but sadly they only support __GFP_NOWARN flag.
This gave their users a misleading feeling that any standard memory
allocation flags are supported, what resulted in the security issue when
caller have set __GFP_ZERO flag and expected the buffer to be cleared.

This patchset changes gfp_mask parameter to a simple boolean no_warn
argument, which covers all the underlaying code supports.

This patchset is a result of the following discussion:
https://patchwork.kernel.org/patch/10461919/

Best regards
Marek Szyprowski
Samsung R&D Institute Poland


Patch summary:

Marek Szyprowski (2):
  mm/cma: remove unsupported gfp_mask parameter from cma_alloc()
  dma: remove unsupported gfp_mask parameter from
    dma_alloc_from_contiguous()

 arch/arm/mm/dma-mapping.c                  | 5 +++--
 arch/arm64/mm/dma-mapping.c                | 4 ++--
 arch/powerpc/kvm/book3s_hv_builtin.c       | 2 +-
 arch/xtensa/kernel/pci-dma.c               | 2 +-
 drivers/iommu/amd_iommu.c                  | 2 +-
 drivers/iommu/intel-iommu.c                | 3 ++-
 drivers/s390/char/vmcp.c                   | 2 +-
 drivers/staging/android/ion/ion_cma_heap.c | 2 +-
 include/linux/cma.h                        | 2 +-
 include/linux/dma-contiguous.h             | 4 ++--
 kernel/dma/contiguous.c                    | 6 +++---
 kernel/dma/direct.c                        | 3 ++-
 mm/cma.c                                   | 8 ++++----
 mm/cma_debug.c                             | 2 +-
 14 files changed, 25 insertions(+), 22 deletions(-)

-- 
2.17.1
