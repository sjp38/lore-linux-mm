Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7032B6B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 23:55:43 -0400 (EDT)
Received: by pdrh1 with SMTP id h1so14448649pdr.0
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 20:55:43 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id sm5si1525746pac.38.2015.08.12.20.55.42
        for <linux-mm@kvack.org>;
        Wed, 12 Aug 2015 20:55:42 -0700 (PDT)
Subject: [RFC PATCH 0/7] 'struct page' driver for persistent memory
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Aug 2015 23:50:00 -0400
Message-ID: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: boaz@plexistor.com, riel@redhat.com, linux-nvdimm@lists.01.org, Dave Hansen <dave.hansen@linux.intel.com>, david@fromorbit.com, mingo@kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, mgorman@suse.de, "H. Peter Anvin" <hpa@zytor.com>, ross.zwisler@linux.intel.com, torvalds@linux-foundation.org, hch@lst.de

When we last left this debate [1] it was becoming clear that the
'page-less' approach left too many I/O scenarios off the table.  The
page-less enabling is still useful for avoiding the overhead of struct
page where it is not needed, but in the end, page-backed persistent
memory seems to be a requirement.

With that assumption in place the next debate was where to allocate the
storage for the memmap array, or otherwise reduce the overhead of 'struct
page' with a fancier object like variable length pages.

This series takes the position of mapping persistent memory with
standard 'struct page' and pushes the policy decision of allocating the
storage for the memmap array, from RAM or PMEM, to userspace.  It turns
out the best place to allocate 64-bytes per 4K page will be platform
specific.

If PMEM capacities are low then mapping in RAM is a good choice.
Otherwise, for very large capacities storing the memmap in PMEM might be
a better choice. Yet again, PMEM might not have the performance
characteristics favorable to a high rate of change object like 'struct
page'. The kernel can make a reasonable guess, but it seems we will need
to maintain the ability to override any default.

Outside of the new libvdimm sysfs mechanisms to specify the memmap
allocation policy for a given PMEM device, the core of this
implementation is 'struct vmem_altmap'.  'vmem_altmap' alters the memory
hotplug code to optionally use a reserved PMEM-pfn range rather than
dynamic allocation for the memmap.

Only lightly tested so far to confirm valid pfn_to_page() and
page_address() conversions across a range of persistent memory specified
by 'memmap=ss!nn' (kernel command line option to simulate a PMEM
range).

[1]: https://lists.01.org/pipermail/linux-nvdimm/2015-May/000748.html

---

Dan Williams (7):
      x86, mm: ZONE_DEVICE for "device memory"
      x86, mm: introduce struct vmem_altmap
      x86, mm: arch_add_dev_memory()
      mm: register_dev_memmap()
      libnvdimm, e820: make CONFIG_X86_PMEM_LEGACY a tristate option
      libnvdimm, pfn: 'struct page' provider infrastructure
      libnvdimm, pmem: 'struct page' for pmem


 arch/powerpc/mm/init_64.c         |    7 +
 arch/x86/Kconfig                  |   19 ++
 arch/x86/include/uapi/asm/e820.h  |    2 
 arch/x86/kernel/Makefile          |    2 
 arch/x86/kernel/pmem.c            |   79 +--------
 arch/x86/mm/init_64.c             |  160 +++++++++++++-----
 drivers/nvdimm/Kconfig            |   26 +++
 drivers/nvdimm/Makefile           |    5 +
 drivers/nvdimm/btt.c              |    8 -
 drivers/nvdimm/btt_devs.c         |  172 +------------------
 drivers/nvdimm/claim.c            |  201 ++++++++++++++++++++++
 drivers/nvdimm/e820.c             |   86 ++++++++++
 drivers/nvdimm/namespace_devs.c   |   34 +++-
 drivers/nvdimm/nd-core.h          |    9 +
 drivers/nvdimm/nd.h               |   59 ++++++-
 drivers/nvdimm/pfn.h              |   35 ++++
 drivers/nvdimm/pfn_devs.c         |  334 +++++++++++++++++++++++++++++++++++++
 drivers/nvdimm/pmem.c             |  213 +++++++++++++++++++++++-
 drivers/nvdimm/region.c           |    2 
 drivers/nvdimm/region_devs.c      |   19 ++
 include/linux/kmap_pfn.h          |   33 ++++
 include/linux/memory_hotplug.h    |   21 ++
 include/linux/mm.h                |   53 ++++++
 include/linux/mmzone.h            |   23 +++
 mm/kmap_pfn.c                     |  195 ++++++++++++++++++++++
 mm/memory_hotplug.c               |   84 ++++++---
 mm/page_alloc.c                   |   18 ++
 mm/sparse-vmemmap.c               |   60 ++++++-
 mm/sparse.c                       |   44 +++--
 tools/testing/nvdimm/Kbuild       |    7 +
 tools/testing/nvdimm/test/iomap.c |   13 +
 31 files changed, 1673 insertions(+), 350 deletions(-)
 create mode 100644 drivers/nvdimm/claim.c
 create mode 100644 drivers/nvdimm/e820.c
 create mode 100644 drivers/nvdimm/pfn.h
 create mode 100644 drivers/nvdimm/pfn_devs.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
