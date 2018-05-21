Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7F6E06B0006
	for <linux-mm@kvack.org>; Mon, 21 May 2018 11:20:43 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id x32-v6so10184253pld.16
        for <linux-mm@kvack.org>; Mon, 21 May 2018 08:20:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n3-v6sor556915pga.330.2018.05.21.08.20.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 May 2018 08:20:42 -0700 (PDT)
From: Huaisheng Ye <yehs2007@gmail.com>
Subject: [RFC PATCH v2 00/12] get rid of GFP_ZONE_TABLE/BAD
Date: Mon, 21 May 2018 23:20:21 +0800
Message-Id: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: mhocko@suse.com, willy@infradead.org, vbabka@suse.cz, mgorman@techsingularity.net, kstewart@linuxfoundation.org, alexander.levin@verizon.com, gregkh@linuxfoundation.org, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-btrfs@vger.kernel.org, Huaisheng Ye <yehs1@lenovo.com>

From: Huaisheng Ye <yehs1@lenovo.com>

Replace GFP_ZONE_TABLE and GFP_ZONE_BAD with encoded zone number.

Delete ___GFP_DMA, ___GFP_HIGHMEM and ___GFP_DMA32 from GFP bitmasks,
the bottom three bits of GFP mask is reserved for storing encoded
zone number.

The encoding method is XOR. Get zone number from enum zone_type,
then encode the number with ZONE_NORMAL by XOR operation.
The goal is to make sure ZONE_NORMAL can be encoded to zero. So,
the compatibility can be guaranteed, such as GFP_KERNEL and GFP_ATOMIC
can be used as before.

Reserve __GFP_MOVABLE in bit 3, so that it can continue to be used as
a flag. Same as before, __GFP_MOVABLE respresents movable migrate type
for ZONE_DMA, ZONE_DMA32, and ZONE_NORMAL. But when it is enabled with
__GFP_HIGHMEM, ZONE_MOVABLE shall be returned instead of ZONE_HIGHMEM.
__GFP_ZONE_MOVABLE is created to realize it.

With this patch, just enabling __GFP_MOVABLE and __GFP_HIGHMEM is not
enough to get ZONE_MOVABLE from gfp_zone. All callers should use
GFP_HIGHUSER_MOVABLE or __GFP_ZONE_MOVABLE directly to achieve that.

Decode zone number directly from bottom three bits of flags in gfp_zone.
The theory of encoding and decoding is,
        A ^ B ^ B = A

Changes since v1,

v2: Add __GFP_ZONE_MOVABLE and modify GFP_HIGHUSER_MOVABLE to help
callers to get ZONE_MOVABLE. Add __GFP_ZONE_MASK to mask lowest 3
bits of GFP bitmasks.
Modify some callers' gfp flag to update usage of address zone
modifiers.
Modify inline function gfp_zone to get better performance according
to Matthew's suggestion.

Link: https://marc.info/?l=linux-mm&m=152596791931266&w=2

Huaisheng Ye (12):
  include/linux/gfp.h: get rid of GFP_ZONE_TABLE/BAD
  arch/x86/kernel/amd_gart_64: update usage of address zone modifiers
  arch/x86/kernel/pci-calgary_64: update usage of address zone modifiers
  drivers/iommu/amd_iommu: update usage of address zone modifiers
  include/linux/dma-mapping: update usage of address zone modifiers
  drivers/xen/swiotlb-xen: update usage of address zone modifiers
  fs/btrfs/extent_io: update usage of address zone modifiers
  drivers/block/zram/zram_drv: update usage of address zone modifiers
  mm/vmpressure: update usage of address zone modifiers
  mm/zsmalloc: update usage of address zone modifiers
  include/linux/highmem: update usage of movableflags
  arch/x86/include/asm/page.h: update usage of movableflags

 arch/x86/include/asm/page.h      |  3 +-
 arch/x86/kernel/amd_gart_64.c    |  2 +-
 arch/x86/kernel/pci-calgary_64.c |  2 +-
 drivers/block/zram/zram_drv.c    |  6 +--
 drivers/iommu/amd_iommu.c        |  2 +-
 drivers/xen/swiotlb-xen.c        |  2 +-
 fs/btrfs/extent_io.c             |  2 +-
 include/linux/dma-mapping.h      |  2 +-
 include/linux/gfp.h              | 98 +++++-----------------------------------
 include/linux/highmem.h          |  4 +-
 mm/vmpressure.c                  |  2 +-
 mm/zsmalloc.c                    |  4 +-
 12 files changed, 26 insertions(+), 103 deletions(-)

-- 
1.8.3.1
