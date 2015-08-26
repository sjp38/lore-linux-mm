Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C78069003C7
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 21:33:08 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so142007107pac.2
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 18:33:08 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id xo9si22290027pab.125.2015.08.25.18.33.07
        for <linux-mm@kvack.org>;
        Tue, 25 Aug 2015 18:33:07 -0700 (PDT)
Subject: [PATCH v2 0/9] initial struct page support for pmem
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 25 Aug 2015 21:27:24 -0400
Message-ID: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: mingo@kernel.org, boaz@plexistor.com, Rik van Riel <riel@redhat.com>, Toshi Kani <toshi.kani@hp.com>, Dave Hansen <dave.hansen@linux.intel.com>, david@fromorbit.com, linux-kernel@vger.kernel.org, hch@lst.de, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, hpa@zytor.com, Jerome Glisse <j.glisse@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, ross.zwisler@linux.intel.com

Changes since v1 [1]:

1/ Several simplifications from Christoph including dropping the __pfn_t
   dependency, and merging ZONE_DEVICE into the base arch_add_memory()
   implementation.

2/ Drop the deeper changes to the memory hotplug code that enabled
   allocating the backing 'struct page' array from pmem (struct
   vmem_altmap).  This functionality is still needed when large capacity
   PMEM devices arrive.  However, for now we can take this simple step to
   enable struct page mapping in RAM and enable it by default for small
   capacity CONFIG_X86_PMEM_LEGACY devices.

3/ A rework of the PMEM api to allow usage of the non-temporal
   memcpy_to_pmem() implementation even on platforms without pcommit
   instruction support.

[1]: https://lists.01.org/pipermail/linux-nvdimm/2015-August/001809.html

---

When we last left this debate [2] it was becoming clear that the
'page-less' approach left too many I/O scenarios off the table.  The
page-less enabling is still useful for avoiding the overhead of struct
page where it is not needed, but in the end, page-backed persistent
memory seems to be a requirement.  We confirmed as much at the recently
concluded Persistent Memory Microconference at Linux Plumbers.

Whereas the initial RFC of this functionality enabled userspace to pick
whether struct page is allocated from RAM or PMEM.  This new version
only enables RAM-backed for now.  This is suitable for existing NVDIMM
devices and a starting point to incrementally build "allocate struct
page from PMEM" support.

[2]: https://lists.01.org/pipermail/linux-nvdimm/2015-May/000748.html

---

Christoph Hellwig (2):
      mm: move __phys_to_pfn and __pfn_to_phys to asm/generic/memory_model.h
      add devm_memremap_pages

Dan Williams (7):
      dax: drop size parameter to ->direct_access()
      mm: ZONE_DEVICE for "device memory"
      x86, pmem: push fallback handling to arch code
      libnvdimm, pfn: 'struct page' provider infrastructure
      libnvdimm, pmem: 'struct page' for pmem
      libnvdimm, pmem: direct map legacy pmem by default
      devm_memremap_pages: protect against pmem device unbind


 arch/arm/include/asm/memory.h       |    6 -
 arch/arm64/include/asm/memory.h     |    6 -
 arch/ia64/mm/init.c                 |    4 
 arch/powerpc/mm/mem.c               |    4 
 arch/powerpc/sysdev/axonram.c       |    2 
 arch/s390/mm/init.c                 |    2 
 arch/sh/mm/init.c                   |    5 -
 arch/tile/mm/init.c                 |    2 
 arch/unicore32/include/asm/memory.h |    6 -
 arch/x86/include/asm/io.h           |    2 
 arch/x86/include/asm/pmem.h         |   41 ++++
 arch/x86/mm/init_32.c               |    4 
 arch/x86/mm/init_64.c               |    4 
 drivers/acpi/nfit.c                 |    2 
 drivers/block/brd.c                 |    6 -
 drivers/nvdimm/Kconfig              |   23 ++
 drivers/nvdimm/Makefile             |    2 
 drivers/nvdimm/btt.c                |    6 -
 drivers/nvdimm/btt_devs.c           |  172 +-----------------
 drivers/nvdimm/claim.c              |  201 +++++++++++++++++++++
 drivers/nvdimm/e820.c               |    1 
 drivers/nvdimm/namespace_devs.c     |   62 +++++-
 drivers/nvdimm/nd-core.h            |    9 +
 drivers/nvdimm/nd.h                 |   59 ++++++
 drivers/nvdimm/pfn.h                |   35 ++++
 drivers/nvdimm/pfn_devs.c           |  337 +++++++++++++++++++++++++++++++++++
 drivers/nvdimm/pmem.c               |  220 +++++++++++++++++++++--
 drivers/nvdimm/region.c             |    2 
 drivers/nvdimm/region_devs.c        |   20 ++
 drivers/s390/block/dcssblk.c        |    4 
 fs/block_dev.c                      |    2 
 include/asm-generic/memory_model.h  |    6 +
 include/asm-generic/pmem.h          |   72 +++++++
 include/linux/blkdev.h              |    2 
 include/linux/io.h                  |   57 ++++++
 include/linux/libnvdimm.h           |    4 
 include/linux/memory_hotplug.h      |    5 -
 include/linux/mmzone.h              |   23 ++
 include/linux/pmem.h                |   73 +-------
 kernel/memremap.c                   |  136 ++++++++++++++
 mm/Kconfig                          |   17 ++
 mm/memory_hotplug.c                 |   14 +
 mm/page_alloc.c                     |    3 
 tools/testing/nvdimm/Kbuild         |    3 
 tools/testing/nvdimm/test/iomap.c   |   13 +
 45 files changed, 1369 insertions(+), 310 deletions(-)
 create mode 100644 drivers/nvdimm/claim.c
 create mode 100644 drivers/nvdimm/pfn.h
 create mode 100644 drivers/nvdimm/pfn_devs.c
 create mode 100644 include/asm-generic/pmem.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
