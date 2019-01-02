Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id DFC868E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 00:51:57 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id m37so38106243qte.10
        for <linux-mm@kvack.org>; Tue, 01 Jan 2019 21:51:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l11sor44208235qtk.1.2019.01.01.21.51.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 01 Jan 2019 21:51:56 -0800 (PST)
MIME-Version: 1.0
References: <20181210011504.122604-1-drinkcat@chromium.org>
In-Reply-To: <20181210011504.122604-1-drinkcat@chromium.org>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Wed, 2 Jan 2019 13:51:45 +0800
Message-ID: <CANMq1KAmFKpcxi49wJyfP4N01A80B2d-2RGY2Wrwg0BvaFxAxg@mail.gmail.com>
Subject: Re: [PATCH v6 0/3] iommu/io-pgtable-arm-v7s: Use DMA32 zone for page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <joro@8bytes.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, iommu@lists.linux-foundation.org, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, Yingjoe Chen <yingjoe.chen@mediatek.com>, hch@infradead.org, Matthew Wilcox <willy@infradead.org>, Hsin-Yi Wang <hsinyi@chromium.org>, stable@vger.kernel.org

Hi all,

On Mon, Dec 10, 2018 at 9:15 AM Nicolas Boichat <drinkcat@chromium.org> wrote:
>
> This is a follow-up to the discussion in [1], [2].
>
> IOMMUs using ARMv7 short-descriptor format require page tables
> (level 1 and 2) to be allocated within the first 4GB of RAM, even
> on 64-bit systems.
>
> For L1 tables that are bigger than a page, we can just use __get_free_pages
> with GFP_DMA32 (on arm64 systems only, arm would still use GFP_DMA).
>
> For L2 tables that only take 1KB, it would be a waste to allocate a full
> page, so we considered 3 approaches:
>  1. This series, adding support for GFP_DMA32 slab caches.
>  2. genalloc, which requires pre-allocating the maximum number of L2 page
>     tables (4096, so 4MB of memory).
>  3. page_frag, which is not very memory-efficient as it is unable to reuse
>     freed fragments until the whole page is freed. [3]
>
> This series is the most memory-efficient approach.

Does anyone have any further comment on this series? If not, which
maintainer is going to pick this up? I assume Andrew Morton?

Thanks,

> stable@ note:
>   We confirmed that this is a regression, and IOMMU errors happen on 4.19
>   and linux-next/master on MT8173 (elm, Acer Chromebook R13). The issue
>   most likely starts from commit ad67f5a6545f ("arm64: replace ZONE_DMA
>   with ZONE_DMA32"), i.e. 4.15, and presumably breaks a number of Mediatek
>   platforms (and maybe others?).
>
> [1] https://lists.linuxfoundation.org/pipermail/iommu/2018-November/030876.html
> [2] https://lists.linuxfoundation.org/pipermail/iommu/2018-December/031696.html
> [3] https://patchwork.codeaurora.org/patch/671639/
>
> Changes since v1:
>  - Add support for SLAB_CACHE_DMA32 in slab and slub (patches 1/2)
>  - iommu/io-pgtable-arm-v7s (patch 3):
>    - Changed approach to use SLAB_CACHE_DMA32 added by the previous
>      commit.
>    - Use DMA or DMA32 depending on the architecture (DMA for arm,
>      DMA32 for arm64).
>
> Changes since v2:
>  - Reworded and expanded commit messages
>  - Added cache_dma32 documentation in PATCH 2/3.
>
> v3 used the page_frag approach, see [3].
>
> Changes since v4:
>  - Dropped change that removed GFP_DMA32 from GFP_SLAB_BUG_MASK:
>    instead we can just call kmem_cache_*alloc without GFP_DMA32
>    parameter. This also means that we can drop PATCH v4 1/3, as we
>    do not make any changes in GFP flag verification.
>  - Dropped hunks that added cache_dma32 sysfs file, and moved
>    the hunks to PATCH v5 3/3, so that maintainer can decide whether
>    to pick the change independently.
>
> Changes since v5:
>  - Rename ARM_V7S_TABLE_SLAB_CACHE to ARM_V7S_TABLE_SLAB_FLAGS.
>  - Add stable@ to cc.
>
> Nicolas Boichat (3):
>   mm: Add support for kmem caches in DMA32 zone
>   iommu/io-pgtable-arm-v7s: Request DMA32 memory, and improve debugging
>   mm: Add /sys/kernel/slab/cache/cache_dma32
>
>  Documentation/ABI/testing/sysfs-kernel-slab |  9 +++++++++
>  drivers/iommu/io-pgtable-arm-v7s.c          | 19 +++++++++++++++----
>  include/linux/slab.h                        |  2 ++
>  mm/slab.c                                   |  2 ++
>  mm/slab.h                                   |  3 ++-
>  mm/slab_common.c                            |  2 +-
>  mm/slub.c                                   | 16 ++++++++++++++++
>  tools/vm/slabinfo.c                         |  7 ++++++-
>  8 files changed, 53 insertions(+), 7 deletions(-)
>
> --
> 2.20.0.rc2.403.gdbc3b29805-goog
>
