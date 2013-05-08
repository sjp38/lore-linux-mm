Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id BD0586B00B5
	for <linux-mm@kvack.org>; Wed,  8 May 2013 11:18:35 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb10so1386132pad.23
        for <linux-mm@kvack.org>; Wed, 08 May 2013 08:18:35 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v5, part3 00/15] accurately calculate memory statisitic information
Date: Wed,  8 May 2013 23:16:59 +0800
Message-Id: <1368026235-5976-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

The original goal of this patchset is to fix the bug reported by
https://bugzilla.kernel.org/show_bug.cgi?id=53501
Now it has also been expanded to reduce common code used by memory
initializion.

This is the third part, previous two patch sets could be accessed at:
http://marc.info/?l=linux-mm&m=136289696323825&w=2
http://marc.info/?l=linux-mm&m=136290291524901&w=2

This patchset applies to
git://git.cmpxchg.org/linux-mmotm.git v3.9-rc8-mmotm-2013-04-25-16-24

V2->V4:
1) rebase to git://git.cmpxchg.org/linux-mmotm.git
2) fix some build warnings and other minor bugs of previous patches

V4->V5:
1) rebase to v3.9-rc8-mmotm-2013-04-25-16-24
2) address comments from last round of review

We have only tested these patchset on x86 platforms, and have done basic
compliation tests using cross-compilers from ftp.kernel.org. That means
some code may not pass compilation on some architectures. So any help
to test this patchset are welcomed!

Patch 1-7:
	Bugfixes and more work for part1 and part2
Patch 8-9:
	Fix typo and minor bugs in mm core
Patch 10-14:
	Enhance the way to manage totalram_pages, totalhigh_pages and
	zone->managed_pages.
Patch 15:
	Report available pages within the node as "MemTotal" for sysfs
	interface /sys/.../node/nodex/meminfo

Jiang Liu (15):
  mm: fix build warnings caused by free_reserved_area()
  mm: enhance free_reserved_area() to support poisoning memory with
    zero
  mm/ARM64: kill poison_init_mem()
  mm/x86: use free_reserved_area() to simplify code
  mm/tile: use common help functions to free reserved pages
  mm, powertv: use free_reserved_area() to simplify code
  mm, acornfb: use free_reserved_area() to simplify code
  mm: fix some trivial typos in comments
  mm: use managed_pages to calculate default zonelist order
  mm: accurately calculate zone->managed_pages for highmem zones
  mm: use a dedicated lock to protect totalram_pages and
    zone->managed_pages
  mm: make __free_pages_bootmem() only available at boot time
  mm: correctly update zone->mamaged_pages
  mm: concentrate modification of totalram_pages into the mm core
  mm: report available pages as "MemTotal" for each NUMA node

 arch/alpha/kernel/sys_nautilus.c      |    2 +-
 arch/alpha/mm/init.c                  |    6 ++---
 arch/alpha/mm/numa.c                  |    2 +-
 arch/arc/mm/init.c                    |    2 +-
 arch/arm/mm/init.c                    |   13 ++++-----
 arch/arm64/mm/init.c                  |   15 ++---------
 arch/avr32/mm/init.c                  |    6 ++---
 arch/blackfin/mm/init.c               |    6 ++---
 arch/c6x/mm/init.c                    |    6 ++---
 arch/cris/mm/init.c                   |    4 +--
 arch/frv/mm/init.c                    |    6 ++---
 arch/h8300/mm/init.c                  |    6 ++---
 arch/hexagon/mm/init.c                |    2 +-
 arch/ia64/mm/init.c                   |    4 +--
 arch/m32r/mm/init.c                   |    6 ++---
 arch/m68k/mm/init.c                   |    8 +++---
 arch/metag/mm/init.c                  |   11 +++++---
 arch/microblaze/mm/init.c             |    6 ++---
 arch/mips/mm/init.c                   |    2 +-
 arch/mips/powertv/asic/asic_devices.c |   13 ++-------
 arch/mips/sgi-ip27/ip27-memory.c      |    2 +-
 arch/mn10300/mm/init.c                |    2 +-
 arch/openrisc/mm/init.c               |    6 ++---
 arch/parisc/mm/init.c                 |    8 +++---
 arch/powerpc/kernel/kvm.c             |    2 +-
 arch/powerpc/mm/mem.c                 |    7 +++--
 arch/s390/mm/init.c                   |    4 +--
 arch/score/mm/init.c                  |    2 +-
 arch/sh/mm/init.c                     |    6 ++---
 arch/sparc/mm/init_32.c               |    3 +--
 arch/sparc/mm/init_64.c               |    2 +-
 arch/tile/mm/init.c                   |    9 +++----
 arch/um/kernel/mem.c                  |    4 +--
 arch/unicore32/mm/init.c              |    6 ++---
 arch/x86/mm/highmem_32.c              |    6 +++++
 arch/x86/mm/init.c                    |   14 +++-------
 arch/x86/mm/init_32.c                 |    2 +-
 arch/x86/mm/init_64.c                 |   25 ++++-------------
 arch/xtensa/mm/init.c                 |    6 ++---
 drivers/video/acornfb.c               |   28 ++-----------------
 drivers/virtio/virtio_balloon.c       |    8 +++---
 drivers/xen/balloon.c                 |   23 ++++------------
 include/linux/bootmem.h               |    1 +
 include/linux/mm.h                    |   17 ++++++------
 include/linux/mmzone.h                |   14 +++++++---
 mm/bootmem.c                          |   41 +++++++++++++++++-----------
 mm/hugetlb.c                          |    2 +-
 mm/memory_hotplug.c                   |   33 +++++------------------
 mm/nobootmem.c                        |   35 ++++++++++++++----------
 mm/page_alloc.c                       |   48 ++++++++++++++++++++-------------
 50 files changed, 215 insertions(+), 277 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
