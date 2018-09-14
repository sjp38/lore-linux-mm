Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 11F4B8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:11:12 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id c18-v6so9318287oiy.3
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 05:11:12 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d37-v6si1470651otb.437.2018.09.14.05.11.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 05:11:09 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8EC4Yu1096283
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:11:08 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mgay24uqn-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:11:08 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 14 Sep 2018 13:11:05 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 00/30] mm: remove bootmem allocator
Date: Fri, 14 Sep 2018 15:10:15 +0300
Message-Id: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, "David S. Miller" <davem@davemloft.net>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jonas Bonn <jonas@southpole.se>, Jonathan Corbet <corbet@lwn.net>, Ley Foon Tan <lftan@altera.com>, Mark Salter <msalter@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Palmer Dabbelt <palmer@sifive.com>, Paul Burton <paul.burton@mips.com>, Richard Kuo <rkuo@codeaurora.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Serge Semin <fancer.lancer@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

These patches switch early memory management to use memblock directly
without any bootmem compatibility wrappers. As the result both bootmem and
nobootmem are removed.

The patchset survived allyesconfig builds on arm, arm64, i386, mips, nds32,
parisc, powerpc, riscv, s390 and x86 and most of the *_defconfig builds for
all architectures except unicore32.

The patchset is based on v4.19-rc3-mmotm-2018-09-12-16-40, so I needed a
small PSI fix from [1] for some of the builds.

I did my best to verify that the failures are not caused by my changes, but
I may have missed something. Most defconfig build failures I've seen were
caused by assembler being unhappy about unsupported opcode, wrong encoding
or something else. Some builds for allyesconfig also failed because of it
and others failed because of symbol mismatch in spi-sprd or n_hdlc.

I've done boot testing on real x86-64 and Power8 machines and on
qemu-system-alpha and qemu-system-mips64el VMs.

I've tried to keep the distribution list as small as possible, but it's
still pretty log; my apologies for spamming.

Changes since RFC:
* updated MIPS conversion to nobootmem: 
  - set memblock limit to max_low_pfn to avoid allocation attempts from
    high memory
  - use boottom-up mode for allocation of the exceptions base
* added elaborate changelogs
* updated boot-time-mm documentation

[1] https://lkml.org/lkml/2018/9/13/88

Mike Rapoport (30):
  mips: switch to NO_BOOTMEM
  mm: remove CONFIG_NO_BOOTMEM
  mm: remove CONFIG_HAVE_MEMBLOCK
  mm: remove bootmem allocator implementation.
  mm: nobootmem: remove dead code
  memblock: rename memblock_alloc{_nid,_try_nid} to memblock_phys_alloc*
  memblock: remove _virt from APIs returning virtual address
  memblock: replace alloc_bootmem_align with memblock_alloc
  memblock: replace alloc_bootmem_low with memblock_alloc_low
  memblock: replace __alloc_bootmem_node_nopanic with
    memblock_alloc_try_nid_nopanic
  memblock: replace alloc_bootmem_pages_nopanic with
    memblock_alloc_nopanic
  memblock: replace alloc_bootmem_low with memblock_alloc_low
  memblock: replace __alloc_bootmem_nopanic with
    memblock_alloc_from_nopanic
  memblock: add align parameter to memblock_alloc_node()
  memblock: replace alloc_bootmem_pages_node with memblock_alloc_node
  memblock: replace __alloc_bootmem_node with appropriate memblock_ API
  memblock: replace alloc_bootmem_node with memblock_alloc_node
  memblock: replace alloc_bootmem_low_pages with memblock_alloc_low
  memblock: replace alloc_bootmem_pages with memblock_alloc
  memblock: replace __alloc_bootmem with memblock_alloc_from
  memblock: replace alloc_bootmem with memblock_alloc
  mm: nobootmem: remove bootmem allocation APIs
  memblock: replace free_bootmem{_node} with memblock_free
  memblock: replace free_bootmem_late with memblock_free_late
  memblock: rename free_all_bootmem to memblock_free_all
  memblock: rename __free_pages_bootmem to memblock_free_pages
  mm: remove nobootmem
  memblock: replace BOOTMEM_ALLOC_* with MEMBLOCK variants
  mm: remove include/linux/bootmem.h
  docs/boot-time-mm: remove bootmem documentation

 Documentation/core-api/boot-time-mm.rst     |  71 +--
 arch/alpha/Kconfig                          |   2 -
 arch/alpha/kernel/core_cia.c                |   4 +-
 arch/alpha/kernel/core_irongate.c           |   4 +-
 arch/alpha/kernel/core_marvel.c             |   6 +-
 arch/alpha/kernel/core_titan.c              |   2 +-
 arch/alpha/kernel/core_tsunami.c            |   2 +-
 arch/alpha/kernel/pci-noop.c                |   6 +-
 arch/alpha/kernel/pci.c                     |   6 +-
 arch/alpha/kernel/pci_iommu.c               |  14 +-
 arch/alpha/kernel/setup.c                   |   3 +-
 arch/alpha/kernel/sys_nautilus.c            |   2 +-
 arch/alpha/mm/init.c                        |   4 +-
 arch/alpha/mm/numa.c                        |   1 -
 arch/arc/Kconfig                            |   2 -
 arch/arc/kernel/unwind.c                    |   6 +-
 arch/arc/mm/highmem.c                       |   4 +-
 arch/arc/mm/init.c                          |   3 +-
 arch/arm/Kconfig                            |   2 -
 arch/arm/kernel/devtree.c                   |   1 -
 arch/arm/kernel/setup.c                     |   5 +-
 arch/arm/mach-omap2/omap_hwmod.c            |   8 +-
 arch/arm/mm/dma-mapping.c                   |   1 -
 arch/arm/mm/init.c                          |   3 +-
 arch/arm/mm/mmu.c                           |   2 +-
 arch/arm/xen/mm.c                           |   1 -
 arch/arm/xen/p2m.c                          |   2 +-
 arch/arm64/Kconfig                          |   2 -
 arch/arm64/kernel/acpi.c                    |   1 -
 arch/arm64/kernel/acpi_numa.c               |   1 -
 arch/arm64/kernel/setup.c                   |   3 +-
 arch/arm64/mm/dma-mapping.c                 |   2 +-
 arch/arm64/mm/init.c                        |   5 +-
 arch/arm64/mm/kasan_init.c                  |   3 +-
 arch/arm64/mm/mmu.c                         |   2 +-
 arch/arm64/mm/numa.c                        |   5 +-
 arch/c6x/Kconfig                            |   2 -
 arch/c6x/kernel/setup.c                     |   1 -
 arch/c6x/mm/dma-coherent.c                  |   4 +-
 arch/c6x/mm/init.c                          |   7 +-
 arch/h8300/Kconfig                          |   2 -
 arch/h8300/kernel/setup.c                   |   1 -
 arch/h8300/mm/init.c                        |   6 +-
 arch/hexagon/Kconfig                        |   2 -
 arch/hexagon/kernel/dma.c                   |   2 +-
 arch/hexagon/kernel/setup.c                 |   2 +-
 arch/hexagon/mm/init.c                      |   3 +-
 arch/ia64/Kconfig                           |   2 -
 arch/ia64/kernel/crash.c                    |   2 +-
 arch/ia64/kernel/efi.c                      |   2 +-
 arch/ia64/kernel/ia64_ksyms.c               |   2 +-
 arch/ia64/kernel/iosapic.c                  |   2 +-
 arch/ia64/kernel/mca.c                      |  10 +-
 arch/ia64/kernel/mca_drv.c                  |   2 +-
 arch/ia64/kernel/setup.c                    |   1 -
 arch/ia64/kernel/smpboot.c                  |   2 +-
 arch/ia64/kernel/topology.c                 |   2 +-
 arch/ia64/kernel/unwind.c                   |   2 +-
 arch/ia64/mm/contig.c                       |   6 +-
 arch/ia64/mm/discontig.c                    |   7 +-
 arch/ia64/mm/init.c                         |  11 +-
 arch/ia64/mm/numa.c                         |   2 +-
 arch/ia64/mm/tlb.c                          |   6 +-
 arch/ia64/pci/pci.c                         |   2 +-
 arch/ia64/sn/kernel/bte.c                   |   2 +-
 arch/ia64/sn/kernel/io_common.c             |   9 +-
 arch/ia64/sn/kernel/setup.c                 |   6 +-
 arch/m68k/Kconfig                           |   2 -
 arch/m68k/atari/stram.c                     |   5 +-
 arch/m68k/coldfire/m54xx.c                  |   2 +-
 arch/m68k/kernel/setup_mm.c                 |   1 -
 arch/m68k/kernel/setup_no.c                 |   1 -
 arch/m68k/kernel/uboot.c                    |   2 +-
 arch/m68k/mm/init.c                         |   6 +-
 arch/m68k/mm/mcfmmu.c                       |   5 +-
 arch/m68k/mm/motorola.c                     |   8 +-
 arch/m68k/mm/sun3mmu.c                      |   6 +-
 arch/m68k/sun3/config.c                     |   2 +-
 arch/m68k/sun3/dvma.c                       |   2 +-
 arch/m68k/sun3/mmu_emu.c                    |   2 +-
 arch/m68k/sun3/sun3dvma.c                   |   5 +-
 arch/m68k/sun3x/dvma.c                      |   2 +-
 arch/microblaze/Kconfig                     |   2 -
 arch/microblaze/mm/consistent.c             |   2 +-
 arch/microblaze/mm/init.c                   |   7 +-
 arch/microblaze/pci/pci-common.c            |   2 +-
 arch/mips/Kconfig                           |   1 -
 arch/mips/ar7/memory.c                      |   2 +-
 arch/mips/ath79/setup.c                     |   2 +-
 arch/mips/bcm63xx/prom.c                    |   2 +-
 arch/mips/bcm63xx/setup.c                   |   2 +-
 arch/mips/bmips/setup.c                     |   2 +-
 arch/mips/cavium-octeon/dma-octeon.c        |   4 +-
 arch/mips/dec/prom/memory.c                 |   2 +-
 arch/mips/emma/common/prom.c                |   2 +-
 arch/mips/fw/arc/memory.c                   |   2 +-
 arch/mips/jazz/jazzdma.c                    |   2 +-
 arch/mips/kernel/crash.c                    |   2 +-
 arch/mips/kernel/crash_dump.c               |   2 +-
 arch/mips/kernel/prom.c                     |   2 +-
 arch/mips/kernel/setup.c                    | 104 +---
 arch/mips/kernel/traps.c                    |   6 +-
 arch/mips/kernel/vpe.c                      |   2 +-
 arch/mips/kvm/commpage.c                    |   2 +-
 arch/mips/kvm/dyntrans.c                    |   2 +-
 arch/mips/kvm/emulate.c                     |   2 +-
 arch/mips/kvm/interrupt.c                   |   2 +-
 arch/mips/kvm/mips.c                        |   2 +-
 arch/mips/lantiq/prom.c                     |   2 +-
 arch/mips/lasat/prom.c                      |   2 +-
 arch/mips/loongson64/common/init.c          |   2 +-
 arch/mips/loongson64/loongson-3/numa.c      |  37 +-
 arch/mips/mm/init.c                         |   7 +-
 arch/mips/mm/pgtable-32.c                   |   2 +-
 arch/mips/mti-malta/malta-memory.c          |   2 +-
 arch/mips/netlogic/xlp/dt.c                 |   2 +-
 arch/mips/pci/pci-legacy.c                  |   2 +-
 arch/mips/pci/pci.c                         |   2 +-
 arch/mips/ralink/of.c                       |   2 +-
 arch/mips/rb532/prom.c                      |   2 +-
 arch/mips/sgi-ip27/ip27-memory.c            |  14 +-
 arch/mips/sibyte/common/cfe.c               |   2 +-
 arch/mips/sibyte/swarm/setup.c              |   2 +-
 arch/mips/txx9/rbtx4938/prom.c              |   2 +-
 arch/nds32/Kconfig                          |   2 -
 arch/nds32/kernel/setup.c                   |   3 +-
 arch/nds32/mm/highmem.c                     |   2 +-
 arch/nds32/mm/init.c                        |  13 +-
 arch/nios2/Kconfig                          |   2 -
 arch/nios2/kernel/prom.c                    |   2 +-
 arch/nios2/kernel/setup.c                   |   1 -
 arch/nios2/mm/init.c                        |   4 +-
 arch/openrisc/Kconfig                       |   2 -
 arch/openrisc/kernel/setup.c                |   3 +-
 arch/openrisc/mm/init.c                     |   7 +-
 arch/openrisc/mm/ioremap.c                  |   2 +-
 arch/parisc/Kconfig                         |   2 -
 arch/parisc/mm/init.c                       |   3 +-
 arch/powerpc/Kconfig                        |   2 -
 arch/powerpc/kernel/dt_cpu_ftrs.c           |   4 +-
 arch/powerpc/kernel/paca.c                  |   2 +-
 arch/powerpc/kernel/pci_32.c                |   4 +-
 arch/powerpc/kernel/prom.c                  |   2 +-
 arch/powerpc/kernel/setup-common.c          |   3 +-
 arch/powerpc/kernel/setup_32.c              |  10 +-
 arch/powerpc/kernel/setup_64.c              |  11 +-
 arch/powerpc/lib/alloc.c                    |   4 +-
 arch/powerpc/mm/hugetlbpage.c               |   1 -
 arch/powerpc/mm/mem.c                       |   5 +-
 arch/powerpc/mm/mmu_context_nohash.c        |   8 +-
 arch/powerpc/mm/numa.c                      |   5 +-
 arch/powerpc/mm/pgtable_32.c                |   2 +-
 arch/powerpc/mm/ppc_mmu_32.c                |   2 +-
 arch/powerpc/platforms/pasemi/iommu.c       |   2 +-
 arch/powerpc/platforms/powermac/nvram.c     |   4 +-
 arch/powerpc/platforms/powernv/opal.c       |   2 +-
 arch/powerpc/platforms/powernv/pci-ioda.c   |   9 +-
 arch/powerpc/platforms/ps3/setup.c          |   4 +-
 arch/powerpc/sysdev/dart_iommu.c            |   2 +-
 arch/powerpc/sysdev/msi_bitmap.c            |   4 +-
 arch/riscv/Kconfig                          |   2 -
 arch/riscv/mm/init.c                        |   5 +-
 arch/s390/Kconfig                           |   2 -
 arch/s390/kernel/crash_dump.c               |   5 +-
 arch/s390/kernel/setup.c                    |  16 +-
 arch/s390/kernel/smp.c                      |   5 +-
 arch/s390/kernel/topology.c                 |   6 +-
 arch/s390/kernel/vdso.c                     |   2 +-
 arch/s390/mm/extmem.c                       |   2 +-
 arch/s390/mm/init.c                         |   5 +-
 arch/s390/mm/vmem.c                         |   7 +-
 arch/s390/numa/mode_emu.c                   |   3 +-
 arch/s390/numa/numa.c                       |   3 +-
 arch/s390/numa/toptree.c                    |   4 +-
 arch/sh/Kconfig                             |   2 -
 arch/sh/mm/init.c                           |   9 +-
 arch/sh/mm/ioremap_fixed.c                  |   2 +-
 arch/sparc/Kconfig                          |   2 -
 arch/sparc/kernel/mdesc.c                   |   7 +-
 arch/sparc/kernel/prom_32.c                 |   4 +-
 arch/sparc/kernel/prom_64.c                 |   2 +-
 arch/sparc/kernel/setup_64.c                |  12 +-
 arch/sparc/kernel/smp_64.c                  |  18 +-
 arch/sparc/mm/init_32.c                     |   5 +-
 arch/sparc/mm/init_64.c                     |  27 +-
 arch/sparc/mm/srmmu.c                       |  12 +-
 arch/um/Kconfig                             |   2 -
 arch/um/drivers/net_kern.c                  |   4 +-
 arch/um/drivers/vector_kern.c               |   4 +-
 arch/um/kernel/initrd.c                     |   4 +-
 arch/um/kernel/mem.c                        |  16 +-
 arch/um/kernel/physmem.c                    |   1 -
 arch/unicore32/Kconfig                      |   2 -
 arch/unicore32/kernel/hibernate.c           |   2 +-
 arch/unicore32/kernel/setup.c               |   5 +-
 arch/unicore32/mm/init.c                    |   7 +-
 arch/unicore32/mm/mmu.c                     |   3 +-
 arch/x86/Kconfig                            |   4 -
 arch/x86/kernel/acpi/boot.c                 |   5 +-
 arch/x86/kernel/acpi/sleep.c                |   1 -
 arch/x86/kernel/apic/apic.c                 |   2 +-
 arch/x86/kernel/apic/io_apic.c              |   7 +-
 arch/x86/kernel/cpu/common.c                |   2 +-
 arch/x86/kernel/e820.c                      |   5 +-
 arch/x86/kernel/mpparse.c                   |   1 -
 arch/x86/kernel/pci-dma.c                   |   2 +-
 arch/x86/kernel/pci-swiotlb.c               |   2 +-
 arch/x86/kernel/pvclock.c                   |   2 +-
 arch/x86/kernel/setup.c                     |   1 -
 arch/x86/kernel/setup_percpu.c              |  14 +-
 arch/x86/kernel/smpboot.c                   |   2 +-
 arch/x86/kernel/tce_64.c                    |   6 +-
 arch/x86/mm/amdtopology.c                   |   1 -
 arch/x86/mm/fault.c                         |   2 +-
 arch/x86/mm/highmem_32.c                    |   4 +-
 arch/x86/mm/init.c                          |   1 -
 arch/x86/mm/init_32.c                       |   5 +-
 arch/x86/mm/init_64.c                       |   7 +-
 arch/x86/mm/ioremap.c                       |   2 +-
 arch/x86/mm/kasan_init_64.c                 |  11 +-
 arch/x86/mm/numa.c                          |   3 +-
 arch/x86/mm/numa_32.c                       |   1 -
 arch/x86/mm/numa_64.c                       |   2 +-
 arch/x86/mm/numa_emulation.c                |   1 -
 arch/x86/mm/pageattr-test.c                 |   2 +-
 arch/x86/mm/pageattr.c                      |   2 +-
 arch/x86/mm/pat.c                           |   2 +-
 arch/x86/mm/physaddr.c                      |   2 +-
 arch/x86/pci/i386.c                         |   2 +-
 arch/x86/platform/efi/efi.c                 |   3 +-
 arch/x86/platform/efi/efi_64.c              |   2 +-
 arch/x86/platform/efi/quirks.c              |   7 +-
 arch/x86/platform/olpc/olpc_dt.c            |   4 +-
 arch/x86/power/hibernate_32.c               |   2 +-
 arch/x86/xen/enlighten.c                    |   2 +-
 arch/x86/xen/enlighten_pv.c                 |   3 +-
 arch/x86/xen/mmu_pv.c                       |   2 +-
 arch/x86/xen/p2m.c                          |   6 +-
 arch/xtensa/Kconfig                         |   2 -
 arch/xtensa/kernel/pci.c                    |   2 +-
 arch/xtensa/mm/cache.c                      |   2 +-
 arch/xtensa/mm/init.c                       |   4 +-
 arch/xtensa/mm/kasan_init.c                 |   5 +-
 arch/xtensa/mm/mmu.c                        |   4 +-
 arch/xtensa/platforms/iss/network.c         |   4 +-
 arch/xtensa/platforms/iss/setup.c           |   2 +-
 block/blk-settings.c                        |   2 +-
 block/bounce.c                              |   2 +-
 drivers/acpi/numa.c                         |   1 -
 drivers/acpi/tables.c                       |   3 +-
 drivers/base/platform.c                     |   2 +-
 drivers/clk/ti/clk.c                        |   4 +-
 drivers/firmware/dmi_scan.c                 |   2 +-
 drivers/firmware/efi/apple-properties.c     |   4 +-
 drivers/firmware/efi/memmap.c               |   2 +-
 drivers/firmware/iscsi_ibft_find.c          |   2 +-
 drivers/firmware/memmap.c                   |   4 +-
 drivers/iommu/mtk_iommu.c                   |   2 +-
 drivers/iommu/mtk_iommu_v1.c                |   2 +-
 drivers/macintosh/smu.c                     |   7 +-
 drivers/mtd/ar7part.c                       |   2 +-
 drivers/net/arcnet/arc-rimi.c               |   2 +-
 drivers/net/arcnet/com20020-isa.c           |   2 +-
 drivers/net/arcnet/com90io.c                |   2 +-
 drivers/of/fdt.c                            |   5 +-
 drivers/of/of_reserved_mem.c                |  13 +-
 drivers/of/unittest.c                       |   4 +-
 drivers/s390/char/fs3270.c                  |   2 +-
 drivers/s390/char/tty3270.c                 |   2 +-
 drivers/s390/cio/cmf.c                      |   2 +-
 drivers/s390/virtio/virtio_ccw.c            |   2 +-
 drivers/sfi/sfi_core.c                      |   2 +-
 drivers/staging/android/ion/Kconfig         |   2 +-
 drivers/tty/serial/cpm_uart/cpm_uart_core.c |   2 +-
 drivers/tty/serial/cpm_uart/cpm_uart_cpm1.c |   2 +-
 drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c |   2 +-
 drivers/usb/early/xhci-dbc.c                |  14 +-
 drivers/xen/balloon.c                       |   2 +-
 drivers/xen/events/events_base.c            |   2 +-
 drivers/xen/grant-table.c                   |   2 +-
 drivers/xen/swiotlb-xen.c                   |   8 +-
 drivers/xen/xen-selfballoon.c               |   2 +-
 fs/dcache.c                                 |   2 +-
 fs/inode.c                                  |   2 +-
 fs/namespace.c                              |   2 +-
 fs/proc/kcore.c                             |   2 +-
 fs/proc/page.c                              |   2 +-
 fs/proc/vmcore.c                            |   2 +-
 fs/pstore/Kconfig                           |   1 -
 include/linux/bootmem.h                     | 404 --------------
 include/linux/memblock.h                    | 159 +++++-
 include/linux/mm.h                          |   2 +-
 include/linux/mmzone.h                      |   5 +-
 init/main.c                                 |  12 +-
 kernel/dma/swiotlb.c                        |  10 +-
 kernel/futex.c                              |   2 +-
 kernel/locking/qspinlock_paravirt.h         |   2 +-
 kernel/pid.c                                |   2 +-
 kernel/power/snapshot.c                     |   4 +-
 kernel/printk/printk.c                      |   5 +-
 kernel/profile.c                            |   2 +-
 lib/Kconfig.debug                           |   3 +-
 lib/cpumask.c                               |   4 +-
 mm/Kconfig                                  |   8 +-
 mm/Makefile                                 |   8 +-
 mm/bootmem.c                                | 811 ----------------------------
 mm/hugetlb.c                                |   6 +-
 mm/internal.h                               |   2 +-
 mm/kasan/kasan_init.c                       |   7 +-
 mm/kmemleak.c                               |   2 +-
 mm/memblock.c                               | 153 +++++-
 mm/memory_hotplug.c                         |   1 -
 mm/nobootmem.c                              | 445 ---------------
 mm/page_alloc.c                             |  17 +-
 mm/page_ext.c                               |   6 +-
 mm/page_idle.c                              |   2 +-
 mm/page_owner.c                             |   2 +-
 mm/page_poison.c                            |   2 +-
 mm/percpu.c                                 |  30 +-
 mm/sparse-vmemmap.c                         |   6 +-
 mm/sparse.c                                 |  18 +-
 net/ipv4/inet_hashtables.c                  |   2 +-
 net/ipv4/tcp.c                              |   2 +-
 net/ipv4/udp.c                              |   2 +-
 net/sctp/protocol.c                         |   2 +-
 net/xfrm/xfrm_hash.c                        |   2 +-
 326 files changed, 866 insertions(+), 2539 deletions(-)
 delete mode 100644 include/linux/bootmem.h
 delete mode 100644 mm/bootmem.c
 delete mode 100644 mm/nobootmem.c

-- 
2.7.4
