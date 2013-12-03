Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9E0746B006E
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 21:28:45 -0500 (EST)
Received: by mail-yh0-f42.google.com with SMTP id z6so9670025yhz.1
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 18:28:45 -0800 (PST)
Received: from bear.ext.ti.com (bear.ext.ti.com. [192.94.94.41])
        by mx.google.com with ESMTPS id 41si48857126yhf.227.2013.12.02.18.28.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 18:28:44 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH v2 00/23] mm: Use memblock interface instead of bootmem
Date: Mon, 2 Dec 2013 21:27:15 -0500
Message-ID: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Santosh Shilimkar <santosh.shilimkar@ti.com>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>

Andrew, Tejun and Yinghai,

Here is the re-send of the series as suggested by Andrew[1]. This series is
the last bottleneck now for me to enable the coherency on keystone ARM
LPAE architecture on which the physical memory starts after 4BG. I would
like to get these patches in next merge window(3.14), so it wil be great
to add these for for-next testing if you are happy with the patchset.
For convenience, the re-based series on top of 3.13-rc1 is available on
my git tree [2]. From last post, the series contains one less patch
because "patch 4, mm/block: remove unnecessary inclusion of bootmem.h"
already merged into 3.13-rc1.

To recap on the original issue, current memblock APIs don't work on
32 PAE or LPAE extension arches where the physical memory start
address beyond 4GB. The problem was discussed here [3] where
Tejun, Yinghai(thanks) proposed a way forward with memblock interfaces.
Based on the proposal, this series adds necessary memblock interfaces
and convert the core kernel code to use them. Architectures already
converted to NO_BOOTMEM use these new interfaces and other which still
uses bootmem, these new interfaces just fallback to exiting bootmem APIs.

So no functional change in behavior. In long run, once all the architectures
moves to NO_BOOTMEM, we can get rid of bootmem layer completely. This is
one step to remove the core code dependency with bootmem and also
gives path for architectures to move away from bootmem.

Testing is done on ARM architecture with 32 bit ARM LAPE machines
with normal as well sparse(faked) memory model.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King <linux@arm.linux.org.uk>

Grygorii Strashko (9):
  mm/memblock: debug: correct displaying of upper memory boundary
  mm/memblock: debug: don't free reserved array if
    !ARCH_DISCARD_MEMBLOCK
  mm/bootmem: remove duplicated declaration of __free_pages_bootmem()
  mm/memory_hotplug: remove unnecessary inclusion of bootmem.h
  mm/staging: remove unnecessary inclusion of bootmem.h
  mm/char: remove unnecessary inclusion of bootmem.h
  mm/memblock: drop WARN and use SMP_CACHE_BYTES as a default alignment
  mm/hugetlb: Use memblock apis for early memory allocations
  mm/page_cgroup: Use memblock apis for early memory allocations

Santosh Shilimkar (14):
  mm/memblock: Add memblock memory allocation apis
  mm/init: Use memblock apis for early memory allocations
  mm/printk: Use memblock apis for early memory allocations
  mm/page_alloc: Use memblock apis for early memory allocations
  mm/power: Use memblock apis for early memory allocations
  mm/lib/swiotlb: Use memblock apis for early memory allocations
  mm/lib/cpumask: Use memblock apis for early memory allocations
  mm/sparse: Use memblock apis for early memory allocations
  mm/percpu: Use memblock apis for early memory allocations
  mm/memory_hotplug: Use memblock apis for early memory allocations
  mm/firmware: Use memblock apis for early memory allocations
  mm/ARM: kernel: Use memblock apis for early memory allocations
  mm/ARM: mm: Use memblock apis for early memory allocations
  mm/ARM: OMAP: Use memblock apis for early memory allocations

 arch/arm/kernel/devtree.c        |    2 +-
 arch/arm/kernel/setup.c          |    2 +-
 arch/arm/mach-omap2/omap_hwmod.c |    8 +-
 arch/arm/mm/init.c               |    2 +-
 drivers/char/mem.c               |    1 -
 drivers/firmware/memmap.c        |    2 +-
 drivers/staging/speakup/main.c   |    2 -
 include/linux/bootmem.h          |   89 +++++++++++++++-
 init/main.c                      |    6 +-
 kernel/power/snapshot.c          |    2 +-
 kernel/printk/printk.c           |   10 +-
 lib/cpumask.c                    |    4 +-
 lib/swiotlb.c                    |   36 ++++---
 mm/hugetlb.c                     |   10 +-
 mm/memblock.c                    |  216 +++++++++++++++++++++++++++++++++++++-
 mm/memory_hotplug.c              |    3 +-
 mm/page_alloc.c                  |   27 ++---
 mm/page_cgroup.c                 |    5 +-
 mm/percpu.c                      |   41 +++++---
 mm/sparse-vmemmap.c              |    6 +-
 mm/sparse.c                      |   27 ++---
 21 files changed, 404 insertions(+), 97 deletions(-)

Regards,
Santosh
[1] https://lkml.org/lkml/2013/12/2/908
[2] git://git.kernel.org/pub/scm/linux/kernel/git/ssantosh/linux-keystone.git
for_3.14/memblock
[3] https://lkml.org/lkml/2013/6/29/77

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
