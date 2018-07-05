Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id A7CD66B000A
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 02:59:01 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id az8-v6so1079116plb.15
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 23:59:01 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id v36-v6si2677283pga.336.2018.07.04.23.59.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 23:59:00 -0700 (PDT)
Subject: [PATCH 00/13] mm: Asynchronous + multithreaded memmap init for
 ZONE_DEVICE
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 04 Jul 2018 23:49:02 -0700
Message-ID: <153077334130.40830.2714147692560185329.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Tony Luck <tony.luck@intel.com>, Huaisheng Ye <yehs1@lenovo.com>, Vishal Verma <vishal.l.verma@intel.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Rich Felker <dalias@libc.org>, Fenghua Yu <fenghua.yu@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michal Hocko <mhocko@suse.com>, Paul Mackerras <paulus@samba.org>, Christoph Hellwig <hch@lst.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Ingo Molnar <mingo@redhat.com>, Johannes Thumshirn <jthumshirn@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Heiko Carstens <heiko.carstens@de.ibm.com>, x86@kernel.org, Logan Gunthorpe <logang@deltatee.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jeff Moyer <jmoyer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In order to keep pfn_to_page() a simple offset calculation the 'struct
page' memmap needs to be mapped and initialized in advance of any usage
of a page. This poses a problem for large memory systems as it delays
full availability of memory resources for 10s to 100s of seconds.

For typical 'System RAM' the problem is mitigated by the fact that large
memory allocations tend to happen after the kernel has fully initialized
and userspace services / applications are launched. A small amount, 2GB
of memory, is initialized up front. The remainder is initialized in the
background and freed to the page allocator over time.

Unfortunately, that scheme is not directly reusable for persistent
memory and dax because userspace has visibility to the entire resource
pool and can choose to access any offset directly at its choosing. In
other words there is no allocator indirection where the kernel can
satisfy requests with arbitrary pages as they become initialized.

That said, we can approximate the optimization by performing the
initialization in the background, allow the kernel to fully boot the
platform, start up pmem block devices, mount filesystems in dax mode,
and only incur the delay at the first userspace dax fault.

With this change an 8 socket system was observed to initialize pmem
namespaces in ~4 seconds whereas it was previously taking ~4 minutes.

These patches apply on top of the HMM + devm_memremap_pages() reworks
[1]. Andrew, once the reviews come back, please consider this series for
-mm as well.

[1]: https://lkml.org/lkml/2018/6/19/108

---

Dan Williams (9):
      mm: Plumb dev_pagemap instead of vmem_altmap to memmap_init_zone()
      mm: Enable asynchronous __add_pages() and vmemmap_populate_hugepages()
      mm: Teach memmap_init_zone() to initialize ZONE_DEVICE pages
      mm: Multithread ZONE_DEVICE initialization
      mm: Allow an external agent to wait for memmap initialization
      filesystem-dax: Make mount time pfn validation a debug check
      libnvdimm, pmem: Initialize the memmap in the background
      device-dax: Initialize the memmap in the background
      libnvdimm, namespace: Publish page structure init state / control

Huaisheng Ye (4):
      nvdimm/pmem: check the validity of the pointer pfn
      nvdimm/pmem-dax: check the validity of the pointer pfn
      s390/block/dcssblk: check the validity of the pointer pfn
      fs/dax: Assign NULL to pfn of dax_direct_access if useless


 arch/ia64/mm/init.c             |    5 +
 arch/powerpc/mm/mem.c           |    5 +
 arch/s390/mm/init.c             |    8 +
 arch/sh/mm/init.c               |    5 +
 arch/x86/mm/init_32.c           |    8 +
 arch/x86/mm/init_64.c           |   27 +++--
 drivers/dax/Kconfig             |   10 ++
 drivers/dax/dax-private.h       |    2 
 drivers/dax/device-dax.h        |    2 
 drivers/dax/device.c            |   16 +++
 drivers/dax/pmem.c              |    5 +
 drivers/dax/super.c             |   64 +++++++-----
 drivers/nvdimm/nd.h             |    2 
 drivers/nvdimm/pfn_devs.c       |   54 ++++++++--
 drivers/nvdimm/pmem.c           |   17 ++-
 drivers/nvdimm/pmem.h           |    1 
 drivers/s390/block/dcssblk.c    |    5 +
 fs/dax.c                        |   10 +-
 include/linux/memmap_async.h    |   55 ++++++++++
 include/linux/memory_hotplug.h  |   18 ++-
 include/linux/memremap.h        |   31 ++++++
 include/linux/mm.h              |    8 +
 kernel/memremap.c               |   85 ++++++++-------
 mm/memory_hotplug.c             |   73 ++++++++++---
 mm/page_alloc.c                 |  215 +++++++++++++++++++++++++++++++++------
 mm/sparse-vmemmap.c             |   56 ++++++++--
 tools/testing/nvdimm/pmem-dax.c |   11 ++
 27 files changed, 610 insertions(+), 188 deletions(-)
 create mode 100644 include/linux/memmap_async.h
