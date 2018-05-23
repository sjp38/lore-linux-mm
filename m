Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Huaisheng Ye <yehs2007@163.com>
Subject: [RFC PATCH v3 0/9] get rid of GFP_ZONE_TABLE/BAD
Date: Wed, 23 May 2018 22:57:45 +0800
Message-Id: <1527087474-93986-1-git-send-email-yehs2007@163.com>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: mhocko@suse.com, willy@infradead.org, hch@lst.de, vbabka@suse.cz, mgorman@techsingularity.net, kstewart@linuxfoundation.org, gregkh@linuxfoundation.org, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-btrfs@vger.kernel.org, Huaisheng Ye <yehs1@lenovo.com>
List-ID: <linux-mm.kvack.org>

From: Huaisheng Ye <yehs1@lenovo.com>

Changes since v2: [2]
* According to Christoph's suggestion, rebase patches to current
  mainline from v4.16.

* Follow the advice of Matthew, create macros like GFP_NORMAL and
  GFP_NORMAL_UNMOVABLE to clear bottom 3 and 4 bits of GFP bitmask.

* Delete some patches because of kernel updating.

[2]: https://marc.info/?l=linux-mm&m=152691610014027&w=2

Tested by Lenovo Thinksystem server.

Initmem setup node 0 [mem 0x0000000000001000-0x000000043fffffff]
[    0.000000] On node 0 totalpages: 4111666
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 23 pages reserved
[    0.000000]   DMA zone: 3999 pages, LIFO batch:0
[    0.000000] mminit::memmap_init Initialising map node 0 zone 0 pfns 1 -> 4096 
[    0.000000]   DMA32 zone: 10935 pages used for memmap
[    0.000000]   DMA32 zone: 699795 pages, LIFO batch:31
[    0.000000] mminit::memmap_init Initialising map node 0 zone 1 pfns 4096 -> 1048576
[    0.000000]   Normal zone: 53248 pages used for memmap
[    0.000000]   Normal zone: 3407872 pages, LIFO batch:31
[    0.000000] mminit::memmap_init Initialising map node 0 zone 2 pfns 1048576 -> 4456448
[    0.000000] mminit::memmap_init Initialising map node 0 zone 3 pfns 1 -> 4456448
[    0.000000] Initmem setup node 1 [mem 0x0000002380000000-0x000000277fffffff]
[    0.000000] On node 1 totalpages: 4194304
[    0.000000]   Normal zone: 65536 pages used for memmap
[    0.000000]   Normal zone: 4194304 pages, LIFO batch:31
[    0.000000] mminit::memmap_init Initialising map node 1 zone 2 pfns 37224448 -> 41418752
[    0.000000] mminit::memmap_init Initialising map node 1 zone 3 pfns 37224448 -> 41418752
...
[    0.000000] mminit::zonelist general 0:DMA = 0:DMA
[    0.000000] mminit::zonelist general 0:DMA32 = 0:DMA32 0:DMA
[    0.000000] mminit::zonelist general 0:Normal = 0:Normal 0:DMA32 0:DMA 1:Normal
[    0.000000] mminit::zonelist thisnode 0:DMA = 0:DMA
[    0.000000] mminit::zonelist thisnode 0:DMA32 = 0:DMA32 0:DMA
[    0.000000] mminit::zonelist thisnode 0:Normal = 0:Normal 0:DMA32 0:DMA
[    0.000000] mminit::zonelist general 1:Normal = 1:Normal 0:Normal 0:DMA32 0:DMA
[    0.000000] mminit::zonelist thisnode 1:Normal = 1:Normal
[    0.000000] Built 2 zonelists, mobility grouping on.  Total pages: 8176164
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-4.17.0-rc6-gfp09+ 
root=/dev/mapper/fedora-root ro rd.lvm.lv=fedora/root rd.lvm.lv=fedora/swap debug 
LANG=en_US.UTF-8 mminit_loglevel=4 console=tty0 console=ttyS0,115200n8 memblock=debug
earlyprintk=serial,0x3f8,115200

---

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

Changes since v1:[1]

* Create __GFP_ZONE_MOVABLE and modify GFP_HIGHUSER_MOVABLE to help
  callers to get ZONE_MOVABLE. Try to create __GFP_ZONE_MASK to mask
  lowest 3 bits of GFP bitmasks.

* Modify some callers' gfp flag to update usage of address zone
  modifiers.

* Modify inline function gfp_zone to get better performance according
  to Matthew's suggestion.

[1]: https://marc.info/?l=linux-mm&m=152596791931266&w=2

---

Huaisheng Ye (9):
  include/linux/gfp.h: get rid of GFP_ZONE_TABLE/BAD
  include/linux/dma-mapping: update usage of zone modifiers
  drivers/xen/swiotlb-xen: update usage of zone modifiers
  fs/btrfs/extent_io: update usage of zone modifiers
  drivers/block/zram/zram_drv: update usage of zone modifiers
  mm/vmpressure: update usage of zone modifiers
  mm/zsmalloc: update usage of zone modifiers
  include/linux/highmem.h: update usage of movableflags
  arch/x86/include/asm/page.h: update usage of movableflags

 arch/x86/include/asm/page.h   |   3 +-
 drivers/block/zram/zram_drv.c |   6 +--
 drivers/xen/swiotlb-xen.c     |   2 +-
 fs/btrfs/extent_io.c          |   2 +-
 include/linux/dma-mapping.h   |   2 +-
 include/linux/gfp.h           | 107 ++++++++----------------------------------
 include/linux/highmem.h       |   4 +-
 mm/vmpressure.c               |   2 +-
 mm/zsmalloc.c                 |   4 +-
 9 files changed, 32 insertions(+), 100 deletions(-)

-- 
1.8.3.1
