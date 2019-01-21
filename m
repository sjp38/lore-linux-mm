Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 96E038E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:04:33 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 82so15405892pfs.20
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 00:04:33 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f7si8607863pga.87.2019.01.21.00.04.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 00:04:31 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0L83ngN132193
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:04:31 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q59werw5e-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:04:31 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 21 Jan 2019 08:04:27 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH v2 00/21] Refine memblock API
Date: Mon, 21 Jan 2019 10:03:47 +0200
Message-Id: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, devicetree@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-usb@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, x86@kernel.org, xen-devel@lists.xenproject.org, Mike Rapoport <rppt@linux.ibm.com>

Hi,

Current memblock API is quite extensive and, which is more annoying,
duplicated. Except the low-level functions that allow searching for a free
memory region and marking it as reserved, memblock provides three (well,
two and a half) sets of functions to allocate memory. There are several
overlapping functions that return a physical address and there are
functions that return virtual address. Those that return the virtual
address may also clear the allocated memory. And, on top of all that, some
allocators panic and some return NULL in case of error.

This set tries to reduce the mess, and trim down the amount of memblock
allocation methods.

Patches 1-10 consolidate the functions that return physical address of
the allocated memory

Patches 11-13 are some trivial cleanups

Patches 14-19 add checks for the return value of memblock_alloc*() and
panics in case of errors. The patches 14-18 include some minor refactoring
to have better readability of the resulting code and patch 19 is a
mechanical addition of

	if (!ptr)
		panic();

after memblock_alloc*() calls.

And, finally, patches 20 and 21 remove panic() calls memblock and _nopanic
variants from memblock.

v2 changes:
* replace some more %lu with %zu
* remove panics where they are not needed in s390 and in printk
* collect Acked-by and Reviewed-by.


Christophe Leroy (1):
  powerpc: use memblock functions returning virtual address

Mike Rapoport (20):
  openrisc: prefer memblock APIs returning virtual address
  memblock: replace memblock_alloc_base(ANYWHERE) with memblock_phys_alloc
  memblock: drop memblock_alloc_base_nid()
  memblock: emphasize that memblock_alloc_range() returns a physical address
  memblock: memblock_phys_alloc_try_nid(): don't panic
  memblock: memblock_phys_alloc(): don't panic
  memblock: drop __memblock_alloc_base()
  memblock: drop memblock_alloc_base()
  memblock: refactor internal allocation functions
  memblock: make memblock_find_in_range_node() and choose_memblock_flags() static
  arch: use memblock_alloc() instead of memblock_alloc_from(size, align, 0)
  arch: don't memset(0) memory returned by memblock_alloc()
  ia64: add checks for the return value of memblock_alloc*()
  sparc: add checks for the return value of memblock_alloc*()
  mm/percpu: add checks for the return value of memblock_alloc*()
  init/main: add checks for the return value of memblock_alloc*()
  swiotlb: add checks for the return value of memblock_alloc*()
  treewide: add checks for the return value of memblock_alloc*()
  memblock: memblock_alloc_try_nid: don't panic
  memblock: drop memblock_alloc_*_nopanic() variants

 arch/alpha/kernel/core_cia.c              |   5 +-
 arch/alpha/kernel/core_marvel.c           |   6 +
 arch/alpha/kernel/pci-noop.c              |  13 +-
 arch/alpha/kernel/pci.c                   |  11 +-
 arch/alpha/kernel/pci_iommu.c             |  16 +-
 arch/alpha/kernel/setup.c                 |   2 +-
 arch/arc/kernel/unwind.c                  |   3 +-
 arch/arc/mm/highmem.c                     |   4 +
 arch/arm/kernel/setup.c                   |   6 +
 arch/arm/mm/init.c                        |   6 +-
 arch/arm/mm/mmu.c                         |  14 +-
 arch/arm64/kernel/setup.c                 |   8 +-
 arch/arm64/mm/kasan_init.c                |  10 ++
 arch/arm64/mm/mmu.c                       |   2 +
 arch/arm64/mm/numa.c                      |   4 +
 arch/c6x/mm/dma-coherent.c                |   4 +
 arch/c6x/mm/init.c                        |   4 +-
 arch/csky/mm/highmem.c                    |   5 +
 arch/h8300/mm/init.c                      |   4 +-
 arch/ia64/kernel/mca.c                    |  25 +--
 arch/ia64/mm/contig.c                     |   8 +-
 arch/ia64/mm/discontig.c                  |   4 +
 arch/ia64/mm/init.c                       |  38 ++++-
 arch/ia64/mm/tlb.c                        |   6 +
 arch/ia64/sn/kernel/io_common.c           |   3 +
 arch/ia64/sn/kernel/setup.c               |  12 +-
 arch/m68k/atari/stram.c                   |   4 +
 arch/m68k/mm/init.c                       |   3 +
 arch/m68k/mm/mcfmmu.c                     |   7 +-
 arch/m68k/mm/motorola.c                   |   9 ++
 arch/m68k/mm/sun3mmu.c                    |   6 +
 arch/m68k/sun3/sun3dvma.c                 |   3 +
 arch/microblaze/mm/init.c                 |  10 +-
 arch/mips/cavium-octeon/dma-octeon.c      |   3 +
 arch/mips/kernel/setup.c                  |   3 +
 arch/mips/kernel/traps.c                  |   5 +-
 arch/mips/mm/init.c                       |   5 +
 arch/nds32/mm/init.c                      |  12 ++
 arch/openrisc/mm/init.c                   |   5 +-
 arch/openrisc/mm/ioremap.c                |   8 +-
 arch/powerpc/kernel/dt_cpu_ftrs.c         |   8 +-
 arch/powerpc/kernel/irq.c                 |   5 -
 arch/powerpc/kernel/paca.c                |   6 +-
 arch/powerpc/kernel/pci_32.c              |   3 +
 arch/powerpc/kernel/prom.c                |   5 +-
 arch/powerpc/kernel/rtas.c                |   6 +-
 arch/powerpc/kernel/setup-common.c        |   3 +
 arch/powerpc/kernel/setup_32.c            |  26 ++--
 arch/powerpc/kernel/setup_64.c            |   4 +
 arch/powerpc/lib/alloc.c                  |   3 +
 arch/powerpc/mm/hash_utils_64.c           |  11 +-
 arch/powerpc/mm/mmu_context_nohash.c      |   9 ++
 arch/powerpc/mm/numa.c                    |   4 +
 arch/powerpc/mm/pgtable-book3e.c          |  12 +-
 arch/powerpc/mm/pgtable-book3s64.c        |   3 +
 arch/powerpc/mm/pgtable-radix.c           |   9 +-
 arch/powerpc/mm/ppc_mmu_32.c              |   3 +
 arch/powerpc/platforms/pasemi/iommu.c     |   3 +
 arch/powerpc/platforms/powermac/nvram.c   |   3 +
 arch/powerpc/platforms/powernv/opal.c     |   3 +
 arch/powerpc/platforms/powernv/pci-ioda.c |   8 +
 arch/powerpc/platforms/ps3/setup.c        |   3 +
 arch/powerpc/sysdev/dart_iommu.c          |   3 +
 arch/powerpc/sysdev/msi_bitmap.c          |   3 +
 arch/s390/kernel/crash_dump.c             |   3 +
 arch/s390/kernel/setup.c                  |  16 ++
 arch/s390/kernel/smp.c                    |   9 +-
 arch/s390/kernel/topology.c               |   6 +
 arch/s390/numa/mode_emu.c                 |   3 +
 arch/s390/numa/numa.c                     |   6 +-
 arch/sh/boards/mach-ap325rxa/setup.c      |   5 +-
 arch/sh/boards/mach-ecovec24/setup.c      |  10 +-
 arch/sh/boards/mach-kfr2r09/setup.c       |   5 +-
 arch/sh/boards/mach-migor/setup.c         |   5 +-
 arch/sh/boards/mach-se/7724/setup.c       |  10 +-
 arch/sh/kernel/machine_kexec.c            |   3 +-
 arch/sh/mm/init.c                         |   8 +-
 arch/sh/mm/numa.c                         |   4 +
 arch/sparc/kernel/prom_32.c               |   6 +-
 arch/sparc/kernel/setup_64.c              |   6 +
 arch/sparc/kernel/smp_64.c                |  12 ++
 arch/sparc/mm/init_32.c                   |   2 +-
 arch/sparc/mm/init_64.c                   |  11 ++
 arch/sparc/mm/srmmu.c                     |  18 ++-
 arch/um/drivers/net_kern.c                |   3 +
 arch/um/drivers/vector_kern.c             |   3 +
 arch/um/kernel/initrd.c                   |   2 +
 arch/um/kernel/mem.c                      |  16 ++
 arch/unicore32/kernel/setup.c             |   4 +
 arch/unicore32/mm/mmu.c                   |  15 +-
 arch/x86/kernel/acpi/boot.c               |   3 +
 arch/x86/kernel/apic/io_apic.c            |   5 +
 arch/x86/kernel/e820.c                    |   5 +-
 arch/x86/kernel/setup_percpu.c            |  10 +-
 arch/x86/mm/kasan_init_64.c               |  14 +-
 arch/x86/mm/numa.c                        |  12 +-
 arch/x86/platform/olpc/olpc_dt.c          |   3 +
 arch/x86/xen/p2m.c                        |  11 +-
 arch/xtensa/mm/kasan_init.c               |  10 +-
 arch/xtensa/mm/mmu.c                      |   3 +
 drivers/clk/ti/clk.c                      |   3 +
 drivers/firmware/memmap.c                 |   2 +-
 drivers/macintosh/smu.c                   |   5 +-
 drivers/of/fdt.c                          |   8 +-
 drivers/of/of_reserved_mem.c              |   7 +-
 drivers/of/unittest.c                     |   8 +-
 drivers/usb/early/xhci-dbc.c              |   2 +-
 drivers/xen/swiotlb-xen.c                 |   7 +-
 include/linux/memblock.h                  |  59 +------
 init/main.c                               |  26 +++-
 kernel/dma/swiotlb.c                      |  21 ++-
 kernel/power/snapshot.c                   |   3 +
 kernel/printk/printk.c                    |   9 +-
 lib/cpumask.c                             |   3 +
 mm/cma.c                                  |  10 +-
 mm/kasan/init.c                           |  10 +-
 mm/memblock.c                             | 249 ++++++++++--------------------
 mm/page_alloc.c                           |  10 +-
 mm/page_ext.c                             |   2 +-
 mm/percpu.c                               |  84 +++++++---
 mm/sparse.c                               |  25 ++-
 121 files changed, 860 insertions(+), 412 deletions(-)

-- 
2.7.4
