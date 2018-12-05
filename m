Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id CA5A06B72C5
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 00:48:47 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id t72so15922024pfi.21
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 21:48:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 5sor15611960plx.26.2018.12.04.21.48.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 21:48:46 -0800 (PST)
From: Nicolas Boichat <drinkcat@chromium.org>
Subject: [PATCH v4 0/3] iommu/io-pgtable-arm-v7s: Use DMA32 zone for page tables
Date: Wed,  5 Dec 2018 13:48:25 +0800
Message-Id: <20181205054828.183476-1-drinkcat@chromium.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <joro@8bytes.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com, hch@infradead.org, Matthew Wilcox <willy@infradead.org>

This is a follow-up to the discussion in [1], [2].

IOMMUs using ARMv7 short-descriptor format require page tables
(level 1 and 2) to be allocated within the first 4GB of RAM, even
on 64-bit systems.

For L1 tables that are bigger than a page, we can just use __get_free_pages
with GFP_DMA32 (on arm64 systems only, arm would still use GFP_DMA).

For L2 tables that only take 1KB, it would be a waste to allocate a full
page, so we considered 3 approaches:
 1. This series, adding support for GFP_DMA32 slab caches.
 2. genalloc, which requires pre-allocating the maximum number of L2 page
    tables (4096, so 4MB of memory).
 3. page_frag, which is not very memory-efficient as it is unable to reuse
    freed fragments until the whole page is freed. [3]

This series is the most memory-efficient approach.

[1] https://lists.linuxfoundation.org/pipermail/iommu/2018-November/030876.html
[2] https://lists.linuxfoundation.org/pipermail/iommu/2018-December/031696.html
[3] https://patchwork.codeaurora.org/patch/671639/

Changes since v1:
 - Add support for SLAB_CACHE_DMA32 in slab and slub (patches 1/2)
 - iommu/io-pgtable-arm-v7s (patch 3):
   - Changed approach to use SLAB_CACHE_DMA32 added by the previous
     commit.
   - Use DMA or DMA32 depending on the architecture (DMA for arm,
     DMA32 for arm64).

Changes since v2:
 - Reworded and expanded commit messages
 - Added cache_dma32 documentation in PATCH 2/3.

v3 used the page_frag approach, see [3].

Nicolas Boichat (3):
  mm: slab/slub: Add check_slab_flags function to check for valid flags
  mm: Add support for kmem caches in DMA32 zone
  iommu/io-pgtable-arm-v7s: Request DMA32 memory, and improve debugging

 Documentation/ABI/testing/sysfs-kernel-slab |  9 ++++++++
 drivers/iommu/io-pgtable-arm-v7s.c          | 20 +++++++++++++----
 include/linux/slab.h                        |  2 ++
 mm/internal.h                               | 22 +++++++++++++++++--
 mm/slab.c                                   | 10 +++------
 mm/slab.h                                   |  3 ++-
 mm/slab_common.c                            |  2 +-
 mm/slub.c                                   | 24 +++++++++++++++------
 8 files changed, 70 insertions(+), 22 deletions(-)

-- 
2.20.0.rc1.387.gf8505762e3-goog
