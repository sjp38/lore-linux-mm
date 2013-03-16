Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 1E33D6B0037
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 13:03:46 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id ma3so5143840pbc.39
        for <linux-mm@kvack.org>; Sat, 16 Mar 2013 10:03:45 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part3 00/12] accurately calculate zone->managed_pages
Date: Sun, 17 Mar 2013 01:03:21 +0800
Message-Id: <1363453413-8139-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The original goal of this patchset is to fix the bug reported by
https://bugzilla.kernel.org/show_bug.cgi?id=53501
Now it has also been expanded to reduce common code used by memory
initializion.

This is the third part, previous two patch sets could be accessed at:
http://marc.info/?l=linux-mm&m=136289696323825&w=2
http://marc.info/?l=linux-mm&m=136290291524901&w=2

This patchset applies to
https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-3.8

Patch 1-6 are minor fixes and furthur work for preview patchset,
which uses common helper functions to free reserved pages.

Patch 7-11 enhance the way to calculate zone->managed_pages and report
available pages as "MemTotal" for each NUMA node

Patch 12 concentrates adjusting of totalram_pages, which reduces 37
references to totalram_pages from arch/ subdirectories.

We have only tested these patchset on x86 platforms, and have done basic
compliation tests using cross-compilers from ftp.kernel.org. That means
some code may not pass compilation on some architectures. So any help
to test this patchset are welcomed!

There is still another part still under development:
Part4: introduce helper functions to simplify mem_init() and remove the
	global variable num_physpages.

Jiang Liu (12):
  mm: enhance free_reserved_area() to support poisoning memory with
    zero
  mm/ARM64: kill poison_init_mem()
  mm/x86: use common help functions to furthur simplify code
  mm/tile: use common help functions to free reserved pages
  mm/powertv: use common help functions to free reserved pages
  mm/acornfb: use common help functions to free reserved pages
  mm: accurately calculate zone->managed_pages for highmem zones
  mm: use a dedicated lock to protect totalram_pages and
    zone->managed_pages
  mm: avoid using __free_pages_bootmem() at runtime
  mm: correctly update zone->mamaged_pages
  mm: report available pages as "MemTotal" for each NUMA node
  mm: concentrate adjusting of totalram_pages

 arch/alpha/kernel/sys_nautilus.c      |    2 +-
 arch/alpha/mm/init.c                  |    6 ++--
 arch/alpha/mm/numa.c                  |    2 +-
 arch/arm/mm/init.c                    |   11 ++++----
 arch/arm64/mm/init.c                  |   15 ++--------
 arch/avr32/mm/init.c                  |    6 ++--
 arch/blackfin/mm/init.c               |    6 ++--
 arch/c6x/mm/init.c                    |    6 ++--
 arch/cris/mm/init.c                   |    4 +--
 arch/frv/mm/init.c                    |    6 ++--
 arch/h8300/mm/init.c                  |    6 ++--
 arch/hexagon/mm/init.c                |    3 +-
 arch/ia64/mm/init.c                   |    4 +--
 arch/m32r/mm/init.c                   |    6 ++--
 arch/m68k/mm/init.c                   |    8 +++---
 arch/microblaze/mm/init.c             |    6 ++--
 arch/mips/mm/init.c                   |    2 +-
 arch/mips/powertv/asic/asic_devices.c |   13 ++-------
 arch/mips/sgi-ip27/ip27-memory.c      |    2 +-
 arch/mn10300/mm/init.c                |    2 +-
 arch/openrisc/mm/init.c               |    6 ++--
 arch/parisc/mm/init.c                 |    8 +++---
 arch/powerpc/kernel/kvm.c             |    2 +-
 arch/powerpc/mm/mem.c                 |    7 ++---
 arch/s390/mm/init.c                   |    4 +--
 arch/score/mm/init.c                  |    2 +-
 arch/sh/mm/init.c                     |    6 ++--
 arch/sparc/mm/init_32.c               |    3 +-
 arch/sparc/mm/init_64.c               |   10 +++----
 arch/tile/mm/init.c                   |    9 ++----
 arch/um/kernel/mem.c                  |    4 +--
 arch/unicore32/mm/init.c              |    6 ++--
 arch/x86/mm/highmem_32.c              |    5 ++++
 arch/x86/mm/init.c                    |   14 ++--------
 arch/x86/mm/init_32.c                 |    2 +-
 arch/x86/mm/init_64.c                 |   24 ++++------------
 arch/xtensa/mm/init.c                 |    6 ++--
 drivers/video/acornfb.c               |   28 ++-----------------
 drivers/virtio/virtio_balloon.c       |    8 ++++--
 drivers/xen/balloon.c                 |   23 ++++------------
 include/linux/bootmem.h               |    1 +
 include/linux/mm.h                    |   17 ++++++------
 include/linux/mmzone.h                |   14 +++++++---
 mm/bootmem.c                          |   41 +++++++++++++++++----------
 mm/hugetlb.c                          |    2 +-
 mm/memory_hotplug.c                   |   31 ++++-----------------
 mm/nobootmem.c                        |   35 +++++++++++++----------
 mm/page_alloc.c                       |   49 ++++++++++++++++++++++-----------
 48 files changed, 210 insertions(+), 273 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
