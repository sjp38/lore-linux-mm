Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 952FD6B000A
	for <linux-mm@kvack.org>; Mon,  7 May 2018 22:18:39 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id b31-v6so901340plb.5
        for <linux-mm@kvack.org>; Mon, 07 May 2018 19:18:39 -0700 (PDT)
Received: from dev31.localdomain ([103.244.59.4])
        by mx.google.com with ESMTP id j9-v6si1989920plk.587.2018.05.07.19.18.37
        for <linux-mm@kvack.org>;
        Mon, 07 May 2018 19:18:37 -0700 (PDT)
From: Huaisheng Ye <yehs1@lenovo.com>
Subject: [RFC PATCH v1 0/6] use mm to manage NVDIMM (pmem) zone
Date: Tue,  8 May 2018 10:30:22 +0800
Message-Id: <1525746628-114136-1-git-send-email-yehs1@lenovo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: mhocko@suse.com, willy@infradead.org, vbabka@suse.cz, mgorman@techsingularity.net, pasha.tatashin@oracle.com, alexander.levin@verizon.com, hannes@cmpxchg.org, penguin-kernel@I-love.SAKURA.ne.jp, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, Huaisheng Ye <yehs1@lenovo.com>

Traditionally, NVDIMMs are treated by mm(memory management) subsystem as
DEVICE zone, which is a virtual zone and both its start and end of pfn
are equal to 0, mm wouldna??t manage NVDIMM directly as DRAM, kernel uses
corresponding drivers, which locate at \drivers\nvdimm\ and
\drivers\acpi\nfit and fs, to realize NVDIMM memory alloc and free with
memory hot plug implementation.

With current kernel, many mma??s classical features like the buddy
system, swap mechanism and page cache couldna??t be supported to NVDIMM.
What we are doing is to expand kernel mma??s capacity to make it to handle
NVDIMM like DRAM. Furthermore we make mm could treat DRAM and NVDIMM
separately, that means mm can only put the critical pages to NVDIMM
zone, here we created a new zone type as NVM zone. That is to say for
traditional(or normal) pages which would be stored at DRAM scope like
Normal, DMA32 and DMA zones. But for the critical pages, which we hope
them could be recovered from power fail or system crash, we make them
to be persistent by storing them to NVM zone.

We installed two NVDIMMs to Lenovo Thinksystem product as development
platform, which has 125GB storage capacity respectively. With these
patches below, mm can create NVM zones for NVDIMMs.

Here is dmesg info,
 Initmem setup node 0 [mem 0x0000000000001000-0x000000237fffffff]
 On node 0 totalpages: 36879666
   DMA zone: 64 pages used for memmap
   DMA zone: 23 pages reserved
   DMA zone: 3999 pages, LIFO batch:0
 mminit::memmap_init Initialising map node 0 zone 0 pfns 1 -> 4096
   DMA32 zone: 10935 pages used for memmap
   DMA32 zone: 699795 pages, LIFO batch:31
 mminit::memmap_init Initialising map node 0 zone 1 pfns 4096 -> 1048576
   Normal zone: 53248 pages used for memmap
   Normal zone: 3407872 pages, LIFO batch:31
 mminit::memmap_init Initialising map node 0 zone 2 pfns 1048576 -> 4456448
   NVM zone: 512000 pages used for memmap
   NVM zone: 32768000 pages, LIFO batch:31
 mminit::memmap_init Initialising map node 0 zone 3 pfns 4456448 -> 37224448
 Initmem setup node 1 [mem 0x0000002380000000-0x00000046bfffffff]
 On node 1 totalpages: 36962304
   Normal zone: 65536 pages used for memmap
   Normal zone: 4194304 pages, LIFO batch:31
 mminit::memmap_init Initialising map node 1 zone 2 pfns 37224448 -> 41418752
   NVM zone: 512000 pages used for memmap
   NVM zone: 32768000 pages, LIFO batch:31
 mminit::memmap_init Initialising map node 1 zone 3 pfns 41418752 -> 74186752

This comes /proc/zoneinfo
Node 0, zone      NVM
  pages free     32768000
        min      15244
        low      48012
        high     80780
        spanned  32768000
        present  32768000
        managed  32768000
        protection: (0, 0, 0, 0, 0, 0)
        nr_free_pages 32768000
Node 1, zone      NVM
  pages free     32768000
        min      15244
        low      48012
        high     80780
        spanned  32768000
        present  32768000
        managed  32768000


Huaisheng Ye (6):
  mm/memblock: Expand definition of flags to support NVDIMM
  mm/page_alloc.c: get pfn range with flags of memblock
  mm, zone_type: create ZONE_NVM and fill into GFP_ZONE_TABLE
  arch/x86/kernel: mark NVDIMM regions from e820_table
  mm: get zone spanned pages separately for DRAM and NVDIMM
  arch/x86/mm: create page table mapping for DRAM and NVDIMM both

 arch/x86/include/asm/e820/api.h |  3 +++
 arch/x86/kernel/e820.c          | 20 +++++++++++++-
 arch/x86/kernel/setup.c         |  8 ++++++
 arch/x86/mm/init_64.c           | 16 +++++++++++
 include/linux/gfp.h             | 57 ++++++++++++++++++++++++++++++++++++---
 include/linux/memblock.h        | 19 +++++++++++++
 include/linux/mm.h              |  4 +++
 include/linux/mmzone.h          |  3 +++
 mm/Kconfig                      | 16 +++++++++++
 mm/memblock.c                   | 46 +++++++++++++++++++++++++++----
 mm/nobootmem.c                  |  5 ++--
 mm/page_alloc.c                 | 60 ++++++++++++++++++++++++++++++++++++++++-
 12 files changed, 245 insertions(+), 12 deletions(-)

-- 
1.8.3.1
