Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9D5EC6B0032
	for <linux-mm@kvack.org>; Sat, 30 May 2015 15:02:00 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so15896383pdb.2
        for <linux-mm@kvack.org>; Sat, 30 May 2015 12:02:00 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id z2si13296114par.138.2015.05.30.12.01.59
        for <linux-mm@kvack.org>;
        Sat, 30 May 2015 12:01:59 -0700 (PDT)
Subject: [PATCH v2 0/4] pmem api, generic ioremap_cache, and memremap
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 30 May 2015 14:59:18 -0400
Message-ID: <20150530185425.32590.3190.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arnd@arndb.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, ross.zwisler@linux.intel.com, akpm@linux-foundation.org
Cc: jgross@suse.com, x86@kernel.org, toshi.kani@hp.com, linux-nvdimm@lists.01.org, mcgrof@suse.com, konrad.wilk@oracle.com, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, linux-mm@kvack.org, geert@linux-m68k.org, hmh@hmh.eng.br, tj@kernel.org, hch@lst.de

The pmem api is responsible for shepherding data out to persistent
media.  The pmem driver uses this api, when available, to assert that
data is durable by the time bio_endio() is invoked.  When an
architecture or cpu can not make persistence guarantees the driver warns
and falls back to "best effort" implementation.

Changes since v1 [1]:

1/ Rebase on tip/master + Toshi's ioremap_wt() patches and enable
   ioremap_cache() to be used generically in drivers.  Fix
   devm_ioremap_resource() in the process.

2/ Rather than add yet another instance of "force cast away __iomem for
   non-io-memory" take the opportunity to introduce memremap() for this use
   case and fix up the current users that botch their handling of the
   __iomem annotation.

3/ Mandate that consumers of the pmem api handle the case when archs, or
   cpus within an arch are not able to make durability guarantees for
   writes to persistent memory.  See pmem_ops in drivers/block/pmem.c

4/ Drop the persistent_flush() api as there are no users until the BLK
   driver is introduced, and even then it is not a "flush to persistence"
   it is an invalidation of a previous mmio aperture setting
   (io_flush_cache_range()).

5/ Add persistent_remap() to the pmem api for the arch to pick its
   desired memory type that corresponds to the assumptions of
   persistent_copy() and persistent_sync().

[1]: https://lists.01.org/pipermail/linux-nvdimm/2015-May/000929.html

This boots and processes pmem writes on x86, cross-compile 0day results
are still pending.

---

Dan Williams (3):
      arch/*/asm/io.h: add ioremap_cache() to all architectures
      devm: fix ioremap_cache() usage
      arch: introduce memremap()

Ross Zwisler (1):
      arch, x86: cache management apis for persistent memory


 arch/arc/include/asm/io.h            |    1 
 arch/arm/include/asm/io.h            |    2 +
 arch/arm64/include/asm/io.h          |    2 +
 arch/arm64/kernel/efi.c              |    4 +
 arch/arm64/kernel/smp_spin_table.c   |   10 ++--
 arch/avr32/include/asm/io.h          |    1 
 arch/frv/include/asm/io.h            |    6 ++
 arch/m32r/include/asm/io.h           |    1 
 arch/m68k/include/asm/io_mm.h        |    7 +++
 arch/m68k/include/asm/io_no.h        |    5 ++
 arch/metag/include/asm/io.h          |    5 ++
 arch/microblaze/include/asm/io.h     |    1 
 arch/mn10300/include/asm/io.h        |    1 
 arch/nios2/include/asm/io.h          |    1 
 arch/s390/include/asm/io.h           |    1 
 arch/sparc/include/asm/io_32.h       |    1 
 arch/sparc/include/asm/io_64.h       |    1 
 arch/tile/include/asm/io.h           |    1 
 arch/x86/Kconfig                     |    1 
 arch/x86/include/asm/cacheflush.h    |   24 +++++++++
 arch/x86/include/asm/io.h            |    7 +++
 arch/x86/kernel/crash_dump_64.c      |    6 +-
 arch/x86/kernel/kdebugfs.c           |    8 +--
 arch/x86/kernel/ksysfs.c             |   28 +++++-----
 arch/x86/mm/ioremap.c                |   10 +---
 arch/xtensa/include/asm/io.h         |    3 +
 drivers/acpi/apei/einj.c             |    8 +--
 drivers/acpi/apei/erst.c             |   14 +++--
 drivers/block/pmem.c                 |   62 +++++++++++++++++++++--
 drivers/firmware/google/memconsole.c |    4 +
 include/asm-generic/io.h             |    8 +++
 include/asm-generic/iomap.h          |    4 +
 include/linux/device.h               |    5 ++
 include/linux/io.h                   |   38 ++++++++++++++
 include/linux/pmem.h                 |   93 ++++++++++++++++++++++++++++++++++
 lib/Kconfig                          |    3 +
 lib/devres.c                         |   48 ++++++++----------
 37 files changed, 347 insertions(+), 78 deletions(-)
 create mode 100644 include/linux/pmem.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
