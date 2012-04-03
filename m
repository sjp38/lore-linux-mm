Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 99BB46B004A
	for <linux-mm@kvack.org>; Tue,  3 Apr 2012 10:10:27 -0400 (EDT)
Received: from euspt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M1W004ZXQ199G@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Tue, 03 Apr 2012 15:10:22 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M1W00DSUQ182J@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 03 Apr 2012 15:10:21 +0100 (BST)
Date: Tue, 03 Apr 2012 16:10:05 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv24 00/16] Contiguous Memory Allocator
Message-id: <1333462221-3987-1-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Rob Clark <rob.clark@linaro.org>, Ohad Ben-Cohen <ohad@wizery.com>, Sandeep Patil <psandeep.s@gmail.com>

Hi,

This is (yet another) update of CMA patches. I've rebased them onto
recent v3.4-rc1 kernel tree and integrated some minor bugfixes. The
first issue has been pointed by Sandeep Patil - alloc_contig_range
reclaimed two times too many pages, second issue (possible mismatch
between pageblock size and MAX_ORDER pages) has been recently spotted
by Michal Nazarewicz.

These patches are also available on my git repository:
git://git.linaro.org/people/mszyprowski/linux-dma-mapping.git 3.4-rc1-cma-v24

Best regards
Marek Szyprowski
Samsung Poland R&D Center

Links to previous versions of the patchset:
v23: <http://www.spinics.net/lists/linux-media/msg44547.html>
v22: <http://www.spinics.net/lists/linux-media/msg44370.html>
v21: <http://www.spinics.net/lists/linux-media/msg44155.html>
v20: <http://www.spinics.net/lists/linux-mm/msg29145.html>
v19: <http://www.spinics.net/lists/linux-mm/msg29145.html>
v18: <http://www.spinics.net/lists/linux-mm/msg28125.html>
v17: <http://www.spinics.net/lists/arm-kernel/msg148499.html>
v16: <http://www.spinics.net/lists/linux-mm/msg25066.html>
v15: <http://www.spinics.net/lists/linux-mm/msg23365.html>
v14: <http://www.spinics.net/lists/linux-media/msg36536.html>
v13: (internal, intentionally not released)
v12: <http://www.spinics.net/lists/linux-media/msg35674.html>
v11: <http://www.spinics.net/lists/linux-mm/msg21868.html>
v10: <http://www.spinics.net/lists/linux-mm/msg20761.html>
 v9: <http://article.gmane.org/gmane.linux.kernel.mm/60787>
 v8: <http://article.gmane.org/gmane.linux.kernel.mm/56855>
 v7: <http://article.gmane.org/gmane.linux.kernel.mm/55626>
 v6: <http://article.gmane.org/gmane.linux.kernel.mm/55626>
 v5: (intentionally left out as CMA v5 was identical to CMA v4)
 v4: <http://article.gmane.org/gmane.linux.kernel.mm/52010>
 v3: <http://article.gmane.org/gmane.linux.kernel.mm/51573>
 v2: <http://article.gmane.org/gmane.linux.kernel.mm/50986>
 v1: <http://article.gmane.org/gmane.linux.kernel.mm/50669>


Changelog:

v24:
    1. fixed handling of diffrent sizes of pageblock and MAX_ORDER size
       pages

    2. fixed number of the reclaimed pages before performing the allocation
       (thanks to Sandeep Patil for pointing this issue)

    3. rebased onto Linux v3.4-rc1

v23:
    1. fixed bug spotted by Aaro Koskinen (incorrect check inside VM_BUG_ON)

    2. rebased onto next-20120222 tree from
       git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git 

v22:
    1. Fixed compilation break caused by missing fixup patch in v21

    2. Fixed typos in the comments

    3. Removed superfluous #include entries

v21:
    1. Fixed incorrect check which broke memory compaction code

    2. Fixed hacky and racy min_free_kbytes handling

    3. Added serialization patch to watermark calculation

    4. Fixed typos here and there in the comments

v20 and earlier - see previous patchsets.


Patches in this patchset:

Marek Szyprowski (6):
  mm: extract reclaim code from __alloc_pages_direct_reclaim()
  mm: trigger page reclaim in alloc_contig_range() to stabilise
    watermarks
  drivers: add Contiguous Memory Allocator
  X86: integrate CMA with DMA-mapping subsystem
  ARM: integrate CMA with DMA-mapping subsystem
  ARM: Samsung: use CMA for 2 memory banks for s5p-mfc device

Mel Gorman (1):
  mm: Serialize access to min_free_kbytes

Michal Nazarewicz (9):
  mm: page_alloc: remove trailing whitespace
  mm: compaction: introduce isolate_migratepages_range()
  mm: compaction: introduce map_pages()
  mm: compaction: introduce isolate_freepages_range()
  mm: compaction: export some of the functions
  mm: page_alloc: introduce alloc_contig_range()
  mm: page_alloc: change fallbacks array handling
  mm: mmzone: MIGRATE_CMA migration type added
  mm: page_isolation: MIGRATE_CMA isolation functions added

 Documentation/kernel-parameters.txt   |    9 +
 arch/Kconfig                          |    3 +
 arch/arm/Kconfig                      |    2 +
 arch/arm/include/asm/dma-contiguous.h |   15 ++
 arch/arm/include/asm/mach/map.h       |    1 +
 arch/arm/kernel/setup.c               |    9 +-
 arch/arm/mm/dma-mapping.c             |  370 ++++++++++++++++++++++++------
 arch/arm/mm/init.c                    |   23 ++-
 arch/arm/mm/mm.h                      |    3 +
 arch/arm/mm/mmu.c                     |   31 ++-
 arch/arm/plat-s5p/dev-mfc.c           |   51 +----
 arch/x86/Kconfig                      |    1 +
 arch/x86/include/asm/dma-contiguous.h |   13 +
 arch/x86/include/asm/dma-mapping.h    |    4 +
 arch/x86/kernel/pci-dma.c             |   18 ++-
 arch/x86/kernel/pci-nommu.c           |    8 +-
 arch/x86/kernel/setup.c               |    2 +
 drivers/base/Kconfig                  |   89 +++++++
 drivers/base/Makefile                 |    1 +
 drivers/base/dma-contiguous.c         |  401 +++++++++++++++++++++++++++++++
 include/asm-generic/dma-contiguous.h  |   28 +++
 include/linux/device.h                |    4 +
 include/linux/dma-contiguous.h        |  110 +++++++++
 include/linux/gfp.h                   |   12 +
 include/linux/mmzone.h                |   47 +++-
 include/linux/page-isolation.h        |   18 +-
 mm/Kconfig                            |    2 +-
 mm/Makefile                           |    3 +-
 mm/compaction.c                       |  418 +++++++++++++++++++++------------
 mm/internal.h                         |   33 +++
 mm/memory-failure.c                   |    2 +-
 mm/memory_hotplug.c                   |    6 +-
 mm/page_alloc.c                       |  409 ++++++++++++++++++++++++++++----
 mm/page_isolation.c                   |   15 +-
 mm/vmstat.c                           |    3 +
 35 files changed, 1791 insertions(+), 373 deletions(-)
 create mode 100644 arch/arm/include/asm/dma-contiguous.h
 create mode 100644 arch/x86/include/asm/dma-contiguous.h
 create mode 100644 drivers/base/dma-contiguous.c
 create mode 100644 include/asm-generic/dma-contiguous.h
 create mode 100644 include/linux/dma-contiguous.h

-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
