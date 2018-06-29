Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 36BD96B0005
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 22:30:07 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id n10-v6so7484197qtp.11
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 19:30:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k7-v6sor911959qvb.96.2018.06.28.19.30.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Jun 2018 19:30:06 -0700 (PDT)
From: Jia He <hejianet@gmail.com>
Subject: [PATCH v9 0/6] optimize memblock_next_valid_pfn and early_pfn_valid on arm and arm64
Date: Fri, 29 Jun 2018 10:29:17 +0800
Message-Id: <1530239363-2356-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <linux@armlinux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steve Capper <steve.capper@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, richard.weiyang@gmail.com, Jia He <hejianet@gmail.com>

Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
where possible") tried to optimize the loop in memmap_init_zone(). But
there is still some room for improvement.

Patch 1 introduce new config to make codes more generic
Patch 2 remain the memblock_next_valid_pfn on arm and arm64
Patch 3 optimizes the memblock_next_valid_pfn()
Patch 4~6 optimizes the early_pfn_valid()

As for the performance improvement, after this set, I can see the time
overhead of memmap_init() is reduced from 27956us to 13537us in my
armv8a server(QDF2400 with 96G memory, pagesize 64k).

Attached the memblock region information in my server.
[    0.000000] Zone ranges:
[    0.000000]   DMA32    [mem 0x0000000000200000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x00000017ffffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000200000-0x000000000021ffff]
[    0.000000]   node   0: [mem 0x0000000000820000-0x000000000307ffff]
[    0.000000]   node   0: [mem 0x0000000003080000-0x000000000308ffff]
[    0.000000]   node   0: [mem 0x0000000003090000-0x00000000031fffff]
[    0.000000]   node   0: [mem 0x0000000003200000-0x00000000033fffff]
[    0.000000]   node   0: [mem 0x0000000003410000-0x00000000034fffff]
[    0.000000]   node   0: [mem 0x0000000003500000-0x000000000351ffff]
[    0.000000]   node   0: [mem 0x0000000003520000-0x000000000353ffff]
[    0.000000]   node   0: [mem 0x0000000003540000-0x0000000003e3ffff]
[    0.000000]   node   0: [mem 0x0000000003e40000-0x0000000003e7ffff]
[    0.000000]   node   0: [mem 0x0000000003e80000-0x0000000003ecffff]
[    0.000000]   node   0: [mem 0x0000000003ed0000-0x0000000003ed5fff]
[    0.000000]   node   0: [mem 0x0000000003ed6000-0x0000000006eeafff]
[    0.000000]   node   0: [mem 0x0000000006eeb000-0x000000000710ffff]
[    0.000000]   node   0: [mem 0x0000000007110000-0x0000000007f0ffff]
[    0.000000]   node   0: [mem 0x0000000007f10000-0x0000000007faffff]
[    0.000000]   node   0: [mem 0x0000000007fb0000-0x000000000806ffff]
[    0.000000]   node   0: [mem 0x0000000008070000-0x00000000080affff]
[    0.000000]   node   0: [mem 0x00000000080b0000-0x000000000832ffff]
[    0.000000]   node   0: [mem 0x0000000008330000-0x000000000836ffff]
[    0.000000]   node   0: [mem 0x0000000008370000-0x000000000838ffff]
[    0.000000]   node   0: [mem 0x0000000008390000-0x00000000083a9fff]
[    0.000000]   node   0: [mem 0x00000000083aa000-0x00000000083bbfff]
[    0.000000]   node   0: [mem 0x00000000083bc000-0x00000000083fffff]
[    0.000000]   node   0: [mem 0x0000000008400000-0x000000000841ffff]
[    0.000000]   node   0: [mem 0x0000000008420000-0x000000000843ffff]
[    0.000000]   node   0: [mem 0x0000000008440000-0x000000000865ffff]
[    0.000000]   node   0: [mem 0x0000000008660000-0x000000000869ffff]
[    0.000000]   node   0: [mem 0x00000000086a0000-0x00000000086affff]
[    0.000000]   node   0: [mem 0x00000000086b0000-0x00000000086effff]
[    0.000000]   node   0: [mem 0x00000000086f0000-0x0000000008b6ffff]
[    0.000000]   node   0: [mem 0x0000000008b70000-0x0000000008bbffff]
[    0.000000]   node   0: [mem 0x0000000008bc0000-0x0000000008edffff]
[    0.000000]   node   0: [mem 0x0000000008ee0000-0x0000000008ee0fff]
[    0.000000]   node   0: [mem 0x0000000008ee1000-0x0000000008ee2fff]
[    0.000000]   node   0: [mem 0x0000000008ee3000-0x000000000decffff]
[    0.000000]   node   0: [mem 0x000000000ded0000-0x000000000defffff]
[    0.000000]   node   0: [mem 0x000000000df00000-0x000000000fffffff]
[    0.000000]   node   0: [mem 0x0000000010800000-0x0000000017feffff]
[    0.000000]   node   0: [mem 0x000000001c000000-0x000000001c00ffff]
[    0.000000]   node   0: [mem 0x000000001c010000-0x000000001c7fffff]
[    0.000000]   node   0: [mem 0x000000001c810000-0x000000007efbffff]
[    0.000000]   node   0: [mem 0x000000007efc0000-0x000000007efdffff]
[    0.000000]   node   0: [mem 0x000000007efe0000-0x000000007efeffff]
[    0.000000]   node   0: [mem 0x000000007eff0000-0x000000007effffff]
[    0.000000]   node   0: [mem 0x000000007f000000-0x00000017ffffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000200000-0x00000017ffffffff]
[    0.000000] On node 0 totalpages: 25145296
[    0.000000]   DMA32 zone: 16376 pages used for memmap
[    0.000000]   DMA32 zone: 0 pages reserved
[    0.000000]   DMA32 zone: 1028048 pages, LIFO batch:31
[    0.000000]   Normal zone: 376832 pages used for memmap
[    0.000000]   Normal zone: 24117248 pages, LIFO batch:31

Changelog:
V9: - rebase to mmotm master, refine the log description. No major changes
V8: - introduce new config and move generic code to early_pfn.h
    - optimize memblock_next_valid_pfn as suggested by Matthew Wilcox
V7: - fix i386 compilation error. refine the commit description
V6: - simplify the codes, move arm/arm64 common codes to one file.
    - refine patches as suggested by Danial Vacek and Ard Biesheuvel
V5: - further refining as suggested by Danial Vacek. Make codes
      arm/arm64 more arch specific
V4: - refine patches as suggested by Danial Vacek and Wei Yang
    - optimized on arm besides arm64
V3: - fix 2 issues reported by kbuild test robot
V2: - rebase to mmotm latest
    - remain memblock_next_valid_pfn on arm64
    - refine memblock_search_pfn_regions and pfn_valid_region

Jia He (6):
  arm: arm64: introduce CONFIG_HAVE_MEMBLOCK_PFN_VALID
  mm: page_alloc: remain memblock_next_valid_pfn() on arm/arm64
  arm: arm64: page_alloc: reduce unnecessary binary search in
    memblock_next_valid_pfn()
  mm/memblock: introduce memblock_search_pfn_regions()
  arm: arm64: introduce pfn_valid_region()
  mm: page_alloc: reduce unnecessary binary search in early_pfn_valid()

 arch/arm/Kconfig          |  4 +++
 arch/arm/mm/init.c        |  1 +
 arch/arm64/Kconfig        |  4 +++
 arch/arm64/mm/init.c      |  1 +
 include/linux/early_pfn.h | 79 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/memblock.h  |  2 ++
 include/linux/mmzone.h    | 18 ++++++++++-
 mm/Kconfig                |  3 ++
 mm/memblock.c             |  9 ++++++
 mm/page_alloc.c           |  5 ++-
 10 files changed, 124 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/early_pfn.h

-- 
1.8.3.1
