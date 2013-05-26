Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 953266B009D
	for <linux-mm@kvack.org>; Sun, 26 May 2013 09:41:09 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z11so5769056pdj.16
        for <linux-mm@kvack.org>; Sun, 26 May 2013 06:41:08 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v8, part3 00/14] accurately calculate memory statisitic information
Date: Sun, 26 May 2013 21:38:28 +0800
Message-Id: <1369575522-26405-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

The original goal of this patchset is to fix the bug reported by
https://bugzilla.kernel.org/show_bug.cgi?id=53501
Now it has also been expanded to reduce common code used by memory
initializion.

This is the third part, previous two patch sets have been merged into
the main stream kernel and could also be accessed at:
http://marc.info/?l=linux-mm&m=136289696323825&w=2
http://marc.info/?l=linux-mm&m=136290291524901&w=2

This patchset applies to
git://git.cmpxchg.org/linux-mmotm.git v3.10-rc2-mmotm-2013-05-22-16-40

V2->V4:
1) rebase to git://git.cmpxchg.org/linux-mmotm.git
2) fix some build warnings and other minor bugs of previous patches

V4->V5:
1) rebase to v3.9-rc8-mmotm-2013-04-25-16-24
2) address comments from last round of review

V5->V6:
1) Change signature of free_reserved_area() according to Russell King's
   suggestion to fix following build warnings.
2) rebase to v3.9-mmotm-2013-05-09-15-57

V6->V7:
1) use asm-generic/param.h and uapi/asm-generic/param.h for AVR32
2) fix typo in log messages.

V7->V8:
1) fix building warnings in V7
2) export free_reserved_area()
3) rebase to v3.10-rc2-mmotm-2013-05-22-16-40

We have only tested these patchset on x86 platforms, and have done basic
compliation tests using cross-compilers from ftp.kernel.org. That means
some code may not pass compilation on some architectures. So any help
to test this patchset are welcomed!

Patch 1-6:
	Bugfixes and more work for part1 and part2
Patch 7-8:
	Fix typo and minor bugs in mm core
Patch 9-13:
	Enhance the way to manage totalram_pages, totalhigh_pages and
	zone->managed_pages.
Patch 14:
	Report available pages within the node as "MemTotal" for sysfs
	interface /sys/.../node/nodex/meminfo

Jiang Liu (14):
  mm: change signature of free_reserved_area() to fix building warnings
  mm: enhance free_reserved_area() to support poisoning memory with zero
  mm/ARM64: kill poison_init_mem()
  mm/x86: use free_reserved_area() to simplify code
  mm/tile: use common help functions to free reserved pages
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

 arch/alpha/kernel/sys_nautilus.c |  4 +--
 arch/alpha/mm/init.c             |  6 ++--
 arch/alpha/mm/numa.c             |  2 +-
 arch/arc/mm/init.c               |  6 ++--
 arch/arm/mm/init.c               | 11 ++++---
 arch/arm64/mm/init.c             | 17 ++---------
 arch/avr32/mm/init.c             |  6 ++--
 arch/blackfin/mm/init.c          |  6 ++--
 arch/c6x/mm/init.c               |  6 ++--
 arch/cris/mm/init.c              |  4 +--
 arch/frv/mm/init.c               |  6 ++--
 arch/h8300/mm/init.c             |  6 ++--
 arch/hexagon/mm/init.c           |  2 +-
 arch/ia64/mm/init.c              |  7 ++---
 arch/m32r/mm/init.c              |  6 ++--
 arch/m68k/mm/init.c              |  8 ++---
 arch/metag/mm/init.c             | 14 +++++----
 arch/microblaze/mm/init.c        |  6 ++--
 arch/mips/mm/init.c              |  5 ++--
 arch/mips/sgi-ip27/ip27-memory.c |  2 +-
 arch/mn10300/mm/init.c           |  5 ++--
 arch/openrisc/mm/init.c          |  6 ++--
 arch/parisc/mm/init.c            |  9 +++---
 arch/powerpc/kernel/kvm.c        |  9 ++----
 arch/powerpc/mm/mem.c            |  7 ++---
 arch/s390/mm/init.c              |  7 +++--
 arch/score/mm/init.c             |  5 ++--
 arch/sh/mm/init.c                |  6 ++--
 arch/sparc/mm/init_32.c          |  7 ++---
 arch/sparc/mm/init_64.c          |  6 ++--
 arch/tile/mm/init.c              |  9 ++----
 arch/um/kernel/mem.c             |  4 +--
 arch/unicore32/mm/init.c         |  6 ++--
 arch/x86/mm/highmem_32.c         |  6 ++++
 arch/x86/mm/init.c               | 14 ++-------
 arch/x86/mm/init_32.c            |  2 +-
 arch/x86/mm/init_64.c            | 25 ++++------------
 arch/xtensa/mm/init.c            |  6 ++--
 drivers/video/acornfb.c          | 45 ++++------------------------
 drivers/virtio/virtio_balloon.c  |  8 +++--
 drivers/xen/balloon.c            | 23 ++++----------
 include/linux/bootmem.h          |  1 +
 include/linux/mm.h               | 18 +++++------
 include/linux/mmzone.h           | 14 ++++++---
 mm/bootmem.c                     | 41 +++++++++++++++----------
 mm/hugetlb.c                     |  2 +-
 mm/memory_hotplug.c              | 34 ++++-----------------
 mm/nobootmem.c                   | 35 +++++++++++++---------
 mm/page_alloc.c                  | 65 +++++++++++++++++++++++-----------------
 49 files changed, 245 insertions(+), 310 deletions(-)

-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
