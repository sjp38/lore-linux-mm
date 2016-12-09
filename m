Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 879256B0253
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 21:45:09 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f188so11209737pgc.1
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 18:45:09 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 6si31302652pfl.234.2016.12.08.18.45.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 18:45:05 -0800 (PST)
Subject: [PATCH v2 00/11] mm: sub-section memory hotplug support
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 08 Dec 2016 18:40:54 -0800
Message-ID: <148125125407.13512.1253904589564772668.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: toshi.kani@hpe.com, Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org, Stephen Bates <stephen.bates@microsemi.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>

Changes since v1 [1]:

1/ fixed the pgmap_radix to index pfns instead of full physical
   addresses

2/ reflowed the follow-on patches and fixed a conflict in patch 10, but
   no other functional changes.

[1]: https://lkml.org/lkml/2016/12/1/740

---

Same cover letter from v1:

Quoting "[PATCH 09/11] mm: support section-unaligned ZONE_DEVICE memory
ranges":

---

The initial motivation for this change is persistent memory platforms
that, unfortunately, align the pmem range on a boundary less than a full
section (64M vs 128M), and may change the alignment from one boot to the
next. A secondary motivation is the arrival of prospective ZONE_DEVICE
users that want devm_memremap_pages() to map PCI-E device memory ranges
to enable peer-to-peer DMA.

Currently the nvdimm core injects padding when 'pfn' (struct page
mapping configuration) instances are created. However, not all users of
devm_memremap_pages() have the opportunity to inject such padding. Users
of the memmap=ss!nn kernel command line option can trigger the following
failure with unaligned parameters like "memmap=0xfc000000!8G":

 WARNING: CPU: 0 PID: 558 at kernel/memremap.c:300 devm_memremap_pages+0x3b5/0x4c0
 devm_memremap_pages attempted on mixed region [mem 0x200000000-0x2fbffffff flags 0x200]
 [..]
 Call Trace:
  [<ffffffff814c0393>] dump_stack+0x86/0xc3
  [<ffffffff810b173b>] __warn+0xcb/0xf0
  [<ffffffff810b17bf>] warn_slowpath_fmt+0x5f/0x80
  [<ffffffff811eb105>] devm_memremap_pages+0x3b5/0x4c0
  [<ffffffffa006f308>] __wrap_devm_memremap_pages+0x58/0x70 [nfit_test_iomap]
  [<ffffffffa00e231a>] pmem_attach_disk+0x19a/0x440 [nd_pmem]

Without this change a user could inadvertently lose access to nvdimm
namespaces by adding/removing other DIMMs in the platform leading to the
BIOS changing the base alignment of the namespace in an incompatible
fashion. With this support we can accommodate a BIOS changing the
namespace to any alignment provided it is >= SECTION_ACTIVE_SIZE.

---

Andrew, yes, this is rather late for 4.10, but it is ostensibly a fix
for devm_memremap_pages(). Both the memmap=ss!nn and qemu-kvm methods of
defining persistent memory can generate the misaligned configuration.
However, in those cases the existing devm_memremap_pages() would have
failed so no one could be relying on that.

The greater concern is new misalignment injected by the BIOS after the
libnvdimm sub-system already recorded that the namespace does not need
alignment padding. In that case the user would need to figure out how to
undo the BIOS change to regain access to their nvdimm device.

The patches have received a build success notification from the
0day-kbuild robot across 177 configs and pass the ndctl unit test suite.
They merge cleanly on top of current -next (test merge with
next-20161201).

---

New diffstat:

Dan Williams (11):
      mm, devm_memremap_pages: use multi-order radix for ZONE_DEVICE lookups
      mm: introduce struct mem_section_usage to track partial population of a section
      mm: introduce common definitions for the size and mask of a section
      mm: cleanup sparse_init_one_section() return value
      mm: track active portions of a section at boot
      mm: fix register_new_memory() zone type detection
      mm: convert kmalloc_section_memmap() to populate_section_memmap()
      mm: prepare for hot-{add,remove} of sub-section ranges
      mm: support section-unaligned ZONE_DEVICE memory ranges
      mm: enable section-unaligned devm_memremap_pages()
      libnvdimm, pfn, dax: stop padding pmem namespaces to section alignment


 arch/x86/mm/init_64.c          |   15 +
 drivers/base/memory.c          |   26 +-
 drivers/nvdimm/pfn_devs.c      |   42 +---
 include/linux/memory.h         |    4 
 include/linux/memory_hotplug.h |    6 -
 include/linux/mm.h             |    3 
 include/linux/mmzone.h         |   26 ++
 kernel/memremap.c              |   75 ++++---
 mm/Kconfig                     |    1 
 mm/memory_hotplug.c            |   95 ++++----
 mm/page_alloc.c                |    6 -
 mm/sparse-vmemmap.c            |   24 +-
 mm/sparse.c                    |  454 +++++++++++++++++++++++++++++-----------
 13 files changed, 510 insertions(+), 267 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
