Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id F3414900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 17:36:55 -0400 (EDT)
Received: by padjw17 with SMTP id jw17so15210646pad.2
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 14:36:55 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ag9si2699481pbd.75.2015.06.03.14.36.54
        for <linux-mm@kvack.org>;
        Wed, 03 Jun 2015 14:36:54 -0700 (PDT)
Subject: [PATCH v3 0/6] pmem api, generic ioremap_cache, and memremap
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 03 Jun 2015 17:34:12 -0400
Message-ID: <20150603211948.13749.85816.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arnd@arndb.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, ross.zwisler@linux.intel.com, akpm@linux-foundation.org
Cc: jgross@suse.com, x86@kernel.org, toshi.kani@hp.com, linux-nvdimm@lists.01.org, benh@kernel.crashing.org, mcgrof@suse.com, konrad.wilk@oracle.com, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, linux-mm@kvack.org, geert@linux-m68k.org, ralf@linux-mips.org, hmh@hmh.eng.br, mpe@ellerman.id.au, tj@kernel.org, paulus@samba.org, hch@lst.de

The pmem api is responsible for shepherding data out to persistent
media.  The pmem driver uses this api, when available, to assert that
data is durable by the time bio_endio() is invoked.  When an
architecture or cpu can not make persistence guarantees the driver warns
and falls back to "best effort" implementation.

Changes since v2 [1]:

1/ Rebased on bp.git/tip-mm-2 (pat cleanups from Boris and ioremap_wt
   from Toshi).

2/ Fixes for build breakage caught by 0day.

3/ Rework IORESOURCE_CACHEABLE to allow it to be safely used in
   devm_ioremap_resource(). (Arnd)

4/ Rename pmem apis from persistent_<action> to <action>_pmem (Boaz)

5/ Introduce the __pmem annotation to let sparse check proper handling
   of a pointer to pmem.

6/ Unify the ioremap function prototype on:
       ioremap(resource_size_t offset, unsigned long size)
   ...across all archs.

7/ Limit the memremap apis to memremap_wt() and memremap_cache(), add
   ARCH_HAS_MEMREMAP to allow drivers to skip architectures where the
   return value from ioremap() is not a simple pointer to memory, and catch
   attempts to memremap addresses that are covered by the kernel's linear
   mapping. (Arnd)

---

Dan Williams (5):
      arch: unify ioremap prototypes and macro aliases
      cleanup IORESOURCE_CACHEABLE vs ioremap()
      arch/*/asm/io.h: add ioremap_cache() to all architectures
      devm: fix ioremap_cache() usage
      arch: introduce memremap_cache() and memremap_wt()

Ross Zwisler (1):
      arch, x86: pmem api for ensuring durability of persistent memory updates


 arch/arc/include/asm/io.h               |    1 
 arch/arm/Kconfig                        |    1 
 arch/arm/include/asm/io.h               |    2 +
 arch/arm/mach-clps711x/board-cdb89712.c |    2 -
 arch/arm64/Kconfig                      |    1 
 arch/arm64/include/asm/io.h             |    3 +
 arch/arm64/kernel/efi.c                 |    4 +
 arch/arm64/kernel/smp_spin_table.c      |   10 ++-
 arch/avr32/include/asm/io.h             |    1 
 arch/cris/include/asm/io.h              |    8 +-
 arch/cris/mm/ioremap.c                  |    6 +-
 arch/frv/Kconfig                        |    1 
 arch/frv/include/asm/io.h               |    6 ++
 arch/ia64/include/asm/io.h              |    9 +--
 arch/ia64/mm/ioremap.c                  |    4 +
 arch/m32r/include/asm/io.h              |    1 
 arch/m68k/Kconfig                       |    1 
 arch/m68k/include/asm/io_mm.h           |    7 ++
 arch/m68k/include/asm/io_no.h           |    5 ++
 arch/metag/Kconfig                      |    1 
 arch/metag/include/asm/io.h             |    5 ++
 arch/microblaze/include/asm/io.h        |    1 
 arch/mips/Kconfig                       |    1 
 arch/mips/include/asm/io.h              |   17 ++++-
 arch/mn10300/include/asm/io.h           |    1 
 arch/nios2/include/asm/io.h             |    1 
 arch/powerpc/Kconfig                    |    1 
 arch/powerpc/include/asm/io.h           |    2 -
 arch/powerpc/kernel/pci_of_scan.c       |    2 -
 arch/s390/include/asm/io.h              |    1 
 arch/sparc/include/asm/io_32.h          |    1 
 arch/sparc/include/asm/io_64.h          |    9 ++-
 arch/sparc/kernel/pci.c                 |    3 -
 arch/tile/include/asm/io.h              |    1 
 arch/x86/Kconfig                        |    2 +
 arch/x86/include/asm/cacheflush.h       |   36 +++++++++++
 arch/x86/include/asm/io.h               |    7 ++
 arch/x86/kernel/crash_dump_64.c         |    6 +-
 arch/x86/kernel/kdebugfs.c              |    8 +-
 arch/x86/kernel/ksysfs.c                |   28 ++++-----
 arch/x86/mm/ioremap.c                   |   12 ++--
 arch/xtensa/Kconfig                     |    1 
 arch/xtensa/include/asm/io.h            |    3 +
 drivers/acpi/apei/einj.c                |    8 +-
 drivers/acpi/apei/erst.c                |    4 +
 drivers/block/Kconfig                   |    1 
 drivers/block/pmem.c                    |   76 +++++++++++++++++++++--
 drivers/firmware/google/memconsole.c    |    4 +
 drivers/pci/probe.c                     |    3 -
 drivers/pnp/manager.c                   |    2 -
 drivers/scsi/aic94xx/aic94xx_init.c     |    7 --
 drivers/scsi/arcmsr/arcmsr_hba.c        |    5 --
 drivers/scsi/mvsas/mv_init.c            |   15 +----
 drivers/video/fbdev/ocfb.c              |    1 
 include/asm-generic/io.h                |    8 ++
 include/asm-generic/iomap.h             |    4 +
 include/linux/compiler.h                |    2 +
 include/linux/device.h                  |    5 ++
 include/linux/io.h                      |    6 ++
 include/linux/pmem.h                    |  102 +++++++++++++++++++++++++++++++
 kernel/resource.c                       |   41 ++++++++++++
 lib/Kconfig                             |    8 ++
 lib/devres.c                            |   48 ++++++---------
 lib/pci_iomap.c                         |    7 +-
 64 files changed, 441 insertions(+), 139 deletions(-)
 create mode 100644 include/linux/pmem.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
