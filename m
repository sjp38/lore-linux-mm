Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id CA8EC6B01F7
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 18:42:49 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so2893917pab.12
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 15:42:49 -0800 (PST)
Received: from psmtp.com ([74.125.245.114])
        by mx.google.com with SMTP id p2si8086034pbe.128.2013.11.08.15.42.47
        for <linux-mm@kvack.org>;
        Fri, 08 Nov 2013 15:42:48 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH 00/24] mm: Use memblock interface instead of bootmem
Date: Fri, 8 Nov 2013 18:41:36 -0500
Message-ID: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Santosh Shilimkar <santosh.shilimkar@ti.com>, Yinghai Lu <yinghai@kernel.org>, "H.
 Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Nicolas Pitre <nicolas.pitre@linaro.org>, Olof Johansson <olof@lixom.net>

Tejun and others,

Following up with the earlier RFC [1] comments, here is the updated
patch series based on the discussion. This series is the last bottleneck
now for me to enable the coherency on keystone ARM LPAE architecture on which
the physical memory starts after 4BG. I would like to get these patches
in next merge window(3.14), so any help in terms of testing/comments is
appreciated.

To recap on the original issue, current memblock APIs don't work on
32 PAE or LPAE extension arches where the physical memory start
address beyond 4GB. The problem was discussed here [2] where
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
with normal as well sparse(faked) memory model. To convert ARM to
NO_BOOTMEM, we have used Russell's work [3] and couple of patches
on top of that. I will be posting those patches as well after 3.13-rc1

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Olof Johansson <olof@lixom.net>

Grygorii Strashko (10):
  mm/memblock: debug: correct displaying of upper memory boundary
  mm/memblock: debug: don't free reserved array if
    !ARCH_DISCARD_MEMBLOCK
  mm/bootmem: remove duplicated declaration of __free_pages_bootmem()
  mm/block: remove unnecessary inclusion of bootmem.h
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
 block/blk-ioc.c                  |    1 -
 drivers/char/mem.c               |    1 -
 drivers/firmware/memmap.c        |    2 +-
 drivers/staging/speakup/main.c   |    2 -
 include/linux/bootmem.h          |   84 ++++++++++++++-
 init/main.c                      |    4 +-
 kernel/power/snapshot.c          |    2 +-
 kernel/printk/printk.c           |   10 +-
 lib/cpumask.c                    |    4 +-
 lib/swiotlb.c                    |   36 ++++---
 mm/hugetlb.c                     |   10 +-
 mm/memblock.c                    |  215 +++++++++++++++++++++++++++++++++++++-
 mm/memory_hotplug.c              |    3 +-
 mm/page_alloc.c                  |   27 ++---
 mm/page_cgroup.c                 |    5 +-
 mm/percpu.c                      |   41 +++++---
 mm/sparse-vmemmap.c              |    6 +-
 mm/sparse.c                      |   27 ++---
 22 files changed, 397 insertions(+), 97 deletions(-)

Regards,
Santosh

[1] https://lkml.org/lkml/2013/10/12/147
[2] https://lkml.org/lkml/2013/6/29/77
[3] http://lwn.net/Articles/561854/

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
