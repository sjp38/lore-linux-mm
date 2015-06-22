Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 485D16B0032
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 04:30:02 -0400 (EDT)
Received: by paceq1 with SMTP id eq1so104858032pac.3
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 01:30:02 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id rx6si28521482pab.219.2015.06.22.01.30.00
        for <linux-mm@kvack.org>;
        Mon, 22 Jun 2015 01:30:01 -0700 (PDT)
Subject: [PATCH v5 0/6] pmem api, generic ioremap_cache, and memremap
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 22 Jun 2015 04:24:17 -0400
Message-ID: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com>
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

Changes since v4 [1]:

1/ Christoph asked me to pull the dangling piece of yarn [2] and the
whole sweater came apart, but for the better.  This finally unifies all
the disparate ways archs had chosen to implement ioremap and friends,
and uncovered several cases where drivers were incorrectly including
<asm/io.h> instead of <linux/io.h>.

2/ Drop pmem ops and introduce a cheap arch_has_pmem_api() conditional
to use at each site where a pmem api call is made (Christoph and Andy)

3/ Document the wmb(), "sfence", in the x86 implementation of
arch_wmb_pmem() (Andy)

4/ Document and rename arch_sync_pmem(), now named arch_wmb_pmem(). (Andy)

This has been run through a defconfig build of all archs and is exposed
to the kbuild robot via nvdimm.git.

[1]: https://lists.01.org/pipermail/linux-nvdimm/2015-June/001189.html
[2]: https://lists.01.org/pipermail/linux-nvdimm/2015-June/001208.html

---

Dan Williams (5):
      arch, drivers: don't include <asm/io.h> directly, use <linux/io.h> instead
      arch: unify ioremap prototypes and macro aliases
      cleanup IORESOURCE_CACHEABLE vs ioremap()
      devm: fix ioremap_cache() usage
      arch: introduce memremap_cache() and memremap_wt()

Ross Zwisler (1):
      arch, x86: pmem api for ensuring durability of persistent memory updates


 arch/alpha/include/asm/io.h                 |    7 +-
 arch/arc/include/asm/io.h                   |    6 -
 arch/arm/Kconfig                            |    1 
 arch/arm/include/asm/io.h                   |   31 ++++++--
 arch/arm/mach-clps711x/board-cdb89712.c     |    2 
 arch/arm/mach-shmobile/pm-rcar.c            |    2 
 arch/arm64/Kconfig                          |    1 
 arch/arm64/include/asm/io.h                 |   23 ++++--
 arch/arm64/kernel/efi.c                     |    4 -
 arch/arm64/kernel/smp_spin_table.c          |   10 +-
 arch/avr32/include/asm/io.h                 |   22 +++--
 arch/avr32/mm/ioremap.c                     |    2 
 arch/cris/include/asm/io.h                  |    8 +-
 arch/cris/mm/ioremap.c                      |    2 
 arch/frv/Kconfig                            |    1 
 arch/frv/include/asm/io.h                   |   23 ++----
 arch/hexagon/include/asm/io.h               |    5 +
 arch/ia64/include/asm/io.h                  |   10 --
 arch/ia64/kernel/cyclone.c                  |    2 
 arch/ia64/mm/ioremap.c                      |    4 -
 arch/m32r/include/asm/io.h                  |    9 +-
 arch/m68k/Kconfig                           |    1 
 arch/m68k/include/asm/io_mm.h               |   21 +++--
 arch/m68k/include/asm/io_no.h               |   34 +++++---
 arch/m68k/include/asm/raw_io.h              |    3 -
 arch/m68k/mm/kmap.c                         |    2 
 arch/metag/Kconfig                          |    1 
 arch/metag/include/asm/io.h                 |   35 +++++----
 arch/microblaze/include/asm/io.h            |    6 -
 arch/microblaze/mm/pgtable.c                |    2 
 arch/mips/Kconfig                           |    1 
 arch/mips/include/asm/io.h                  |   42 ++++------
 arch/mn10300/include/asm/io.h               |   10 +-
 arch/nios2/include/asm/io.h                 |   15 +---
 arch/openrisc/include/asm/io.h              |    3 -
 arch/openrisc/mm/ioremap.c                  |    2 
 arch/parisc/include/asm/io.h                |    6 -
 arch/parisc/mm/ioremap.c                    |    2 
 arch/powerpc/Kconfig                        |    1 
 arch/powerpc/include/asm/io.h               |    7 +-
 arch/powerpc/kernel/pci_of_scan.c           |    2 
 arch/s390/include/asm/io.h                  |    8 +-
 arch/sh/include/asm/io.h                    |    9 ++
 arch/sparc/include/asm/io_32.h              |    7 --
 arch/sparc/include/asm/io_64.h              |    8 +-
 arch/sparc/kernel/ioport.c                  |    2 
 arch/sparc/kernel/pci.c                     |    3 -
 arch/tile/include/asm/io.h                  |   17 +++-
 arch/unicore32/include/asm/io.h             |   25 +++++-
 arch/x86/Kconfig                            |    2 
 arch/x86/include/asm/cacheflush.h           |   71 +++++++++++++++++
 arch/x86/include/asm/io.h                   |   15 +++-
 arch/x86/kernel/crash_dump_64.c             |    6 +
 arch/x86/kernel/kdebugfs.c                  |    8 +-
 arch/x86/kernel/ksysfs.c                    |   28 +++----
 arch/x86/mm/ioremap.c                       |   10 +-
 arch/xtensa/Kconfig                         |    1 
 arch/xtensa/include/asm/io.h                |   13 ++-
 drivers/acpi/apei/einj.c                    |    8 +-
 drivers/acpi/apei/erst.c                    |    4 -
 drivers/block/Kconfig                       |    1 
 drivers/block/pmem.c                        |   46 ++++++++++-
 drivers/firmware/google/memconsole.c        |    4 -
 drivers/isdn/icn/icn.h                      |    2 
 drivers/mtd/devices/slram.c                 |    2 
 drivers/mtd/nand/diskonchip.c               |    2 
 drivers/mtd/onenand/generic.c               |    2 
 drivers/net/ethernet/sfc/io.h               |    2 
 drivers/pci/probe.c                         |    3 -
 drivers/pnp/manager.c                       |    2 
 drivers/scsi/aic94xx/aic94xx_init.c         |    7 --
 drivers/scsi/arcmsr/arcmsr_hba.c            |    5 -
 drivers/scsi/mvsas/mv_init.c                |   15 +---
 drivers/scsi/sun3x_esp.c                    |    2 
 drivers/staging/comedi/drivers/ii_pci20kc.c |    1 
 drivers/tty/serial/8250/8250_core.c         |    2 
 drivers/video/fbdev/ocfb.c                  |    1 
 drivers/video/fbdev/s1d13xxxfb.c            |    3 -
 drivers/video/fbdev/stifb.c                 |    1 
 include/asm-generic/iomap.h                 |    8 --
 include/linux/compiler.h                    |    2 
 include/linux/device.h                      |    5 +
 include/linux/io-mapping.h                  |    2 
 include/linux/io.h                          |   64 ++++++++++++++++
 include/linux/mtd/map.h                     |    2 
 include/linux/pmem.h                        |  110 +++++++++++++++++++++++++++
 include/video/vga.h                         |    2 
 kernel/resource.c                           |   41 ++++++++++
 lib/Kconfig                                 |    8 ++
 lib/devres.c                                |   48 +++++-------
 lib/pci_iomap.c                             |    7 --
 91 files changed, 684 insertions(+), 334 deletions(-)
 create mode 100644 include/linux/pmem.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
