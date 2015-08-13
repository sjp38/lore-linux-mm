Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id E85D76B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 23:06:42 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so27542765pac.3
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 20:06:42 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id hp8si1280618pac.226.2015.08.12.20.06.41
        for <linux-mm@kvack.org>;
        Wed, 12 Aug 2015 20:06:42 -0700 (PDT)
Subject: [PATCH v5 0/5] introduce __pfn_t for unmapped pfn I/O and DAX
 lifetime
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Aug 2015 23:00:59 -0400
Message-ID: <20150813025112.36703.21333.stgit@otcpl-skl-sds-2.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: axboe@kernel.dk, riel@redhat.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, mgorman@suse.de, torvalds@linux-foundation.org, hch@lst.de

Changes since v4 [1]:

1/ Allow up to PAGE_SHIFT bits in PFN_ flags.  Previously the __pfn_t
   value was a union with a 'struct page *', but now __pfn_t_to_page()
   internally does a pfn_to_page() instead of type-punning the value.
   (Linus, Matthew)

2/ Move the definition to include/linux/mm.h and squash the
   kmap_atomic_pfn_t() definition into the same patch. (Christoph)

3/ Kill dax_get_pfn().  Now replaced with dax_map_bh() (Matthew)

4/ The scatterlist cleanup patches are moved to their own series being
   carried by Christoph.

[1]: https://lists.01.org/pipermail/linux-nvdimm/2015-June/001094.html

---

We want persistent memory to have 4 modes of access:

1/ Block device: persistent memory treated as a ram disk (done)

2/ DAX: userspace mmap (done)

3/ Kernel "page-less". (this series)

4/ Kernel and userspace references to page-mapped persistent memory
   (future series)

The "kernel 'page-less'" case leverages the fact that a 'struct page'
object is not necessarily required for describing a DMA transfer from a
device to a persistent memory address.  A pfn will do, but code needs to
be careful to not perform a pfn_to_page() operation on unmapped
persistent memory. The __pfn_t type enforces that safety and
kmap_atomic_pfn_t() covers cases where the I/O stack needs to touch the
buffer on its way to the low-level-device-driver (i.e. current usages of
kmap_atomic() in the block-layer).

A subsequent patch series will add struct page coverage for persistent,
"device", memory.

We also use kmap_atomic_pfn_t() to solve races of pmem driver unbind vs
usage in DAX. rcu_read_lock() protects the driver from unbinding while a
mapping is held.

---

Christoph Hellwig (1):
      mm: move __phys_to_pfn and __pfn_to_phys to asm/generic/memory_model.h

Dan Williams (4):
      allow mapping page-less memremaped areas into KVA
      dax: drop size parameter to ->direct_access()
      dax: fix mapping lifetime handling, convert to __pfn_t + kmap_atomic_pfn_t()
      scatterlist: convert to __pfn_t


 arch/arm/include/asm/memory.h       |    6 --
 arch/arm64/include/asm/memory.h     |    6 --
 arch/powerpc/platforms/Kconfig      |    1 
 arch/powerpc/sysdev/axonram.c       |   24 +++++--
 arch/unicore32/include/asm/memory.h |    6 --
 drivers/block/brd.c                 |    9 +--
 drivers/nvdimm/Kconfig              |    1 
 drivers/nvdimm/pmem.c               |   24 ++++---
 drivers/s390/block/Kconfig          |    1 
 drivers/s390/block/dcssblk.c        |   23 ++++++-
 fs/Kconfig                          |    1 
 fs/block_dev.c                      |    4 +
 fs/dax.c                            |   79 +++++++++++++++++-------
 include/asm-generic/memory_model.h  |    6 ++
 include/linux/blkdev.h              |    7 +-
 include/linux/kmap_pfn.h            |   31 +++++++++
 include/linux/mm.h                  |   78 +++++++++++++++++++++++
 include/linux/scatterlist.h         |  111 +++++++++++++++++++++++----------
 mm/Kconfig                          |    3 +
 mm/Makefile                         |    1 
 mm/kmap_pfn.c                       |  117 +++++++++++++++++++++++++++++++++++
 samples/kfifo/dma-example.c         |    8 +-
 22 files changed, 435 insertions(+), 112 deletions(-)
 create mode 100644 include/linux/kmap_pfn.h
 create mode 100644 mm/kmap_pfn.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
