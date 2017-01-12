Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 89EDF6B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 10:29:31 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id t84so19507660qke.7
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 07:29:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n128si1151935qkf.179.2017.01.12.07.29.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 07:29:30 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v16 00/16] HMM (Heterogeneous Memory Management) v16
Date: Thu, 12 Jan 2017 11:30:27 -0500
Message-Id: <1484238642-10674-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Cliff note: HMM offers 2 things (each standing on its own). First
it allows to use device memory transparently inside any process
without any modifications to process program code. Second it allows
to mirror process address space on a device.

Change since v15:
  - drop safety net patch
  - s/devm_memremap_pages_remove/devm_memunmap_pages

Work is under way to use this feature inside nouveau (the upstream
open source driver for NVidia GPU) either in 4.11 or 4.12 timeframe.
But this patchset have been otherwise tested with the close source
driver for NVidia GPU and thus we are confident it works and allow
to use the hardware for seamless interaction between CPU and GPU
in common address space of a process.

I also discussed the features with other company and i am confident
it can be use on other, yet, unrelease hardware.

So hope this time it can be consider for 4.11 or i would like to know
any reasons to not accept this patchset.


Know issues:

Device memory pick some random unuse physical address range. Latter
memory hotplug might fails because of this. Intention is to fix this
in latter patchset to use physical address above the platform limit
thus making sure that no real memory can be hotplug at conflicting
address.


Patchset overview:

Patchset is divided into 3 features that can each be use independently
from one another. First is changes to ZONE_DEVICE so we can have struct
page for device un-addressable memory (patch 2-6). Second is process
address space mirroring (patch 8 to 10), this allow to snapshot CPU
page table and to keep the device page table synchronize with the CPU
one.

Last is a new page migration helper which allow migration for range of
virtual address using hardware copy engine (patch 11-14).

Other patches just introduce common definitions or add safety net to
catch wrong use of some of the features.


Future plan:

In this patchset i restricted myself to set of core features what
is missing:
  - force read only on CPU for memory duplication and GPU atomic
  - changes to mmu_notifier for optimization purposes
  - migration of file back page to device memory

I plan to submit a couple more patchset to implement those features
once core HMM is upstream.

Git tree:
https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-v16


Previous patchset posting :
    v1 http://lwn.net/Articles/597289/
    v2 https://lkml.org/lkml/2014/6/12/559
    v3 https://lkml.org/lkml/2014/6/13/633
    v4 https://lkml.org/lkml/2014/8/29/423
    v5 https://lkml.org/lkml/2014/11/3/759
    v6 http://lwn.net/Articles/619737/
    v7 http://lwn.net/Articles/627316/
    v8 https://lwn.net/Articles/645515/
    v9 https://lwn.net/Articles/651553/
    v10 https://lwn.net/Articles/654430/
    v11 http://www.gossamer-threads.com/lists/linux/kernel/2286424
    v12 http://www.kernelhub.org/?msg=972982&p=2
    v13 https://lwn.net/Articles/706856/
    v14 https://lkml.org/lkml/2016/12/8/344
    v15 http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1304107.html

JA(C)rA'me Glisse (15):
  mm/memory/hotplug: convert device bool to int to allow for more flags
    v2
  mm/ZONE_DEVICE/devmem_pages_remove: allow early removal of device
    memory v2
  mm/ZONE_DEVICE/free-page: callback when page is freed
  mm/ZONE_DEVICE/unaddressable: add support for un-addressable device
    memory v2
  mm/ZONE_DEVICE/x86: add support for un-addressable device memory
  mm/hmm: heterogeneous memory management (HMM for short)
  mm/hmm/mirror: mirror process address space on device with HMM helpers
  mm/hmm/mirror: helper to snapshot CPU page table
  mm/hmm/mirror: device page fault handler
  mm/hmm/migrate: support un-addressable ZONE_DEVICE page in migration
  mm/hmm/migrate: add new boolean copy flag to migratepage() callback
  mm/hmm/migrate: new memory migration helper for use with device memory
    v2
  mm/hmm/migrate: optimize page map once in vma being migrated
  mm/hmm/devmem: device driver helper to hotplug ZONE_DEVICE memory v2
  mm/hmm/devmem: dummy HMM device as an helper for ZONE_DEVICE memory

 MAINTAINERS                                |    7 +
 arch/ia64/mm/init.c                        |   23 +-
 arch/powerpc/mm/mem.c                      |   22 +-
 arch/s390/mm/init.c                        |   10 +-
 arch/sh/mm/init.c                          |   22 +-
 arch/tile/mm/init.c                        |   10 +-
 arch/x86/mm/init_32.c                      |   23 +-
 arch/x86/mm/init_64.c                      |   41 +-
 drivers/dax/pmem.c                         |    3 +-
 drivers/nvdimm/pmem.c                      |    7 +-
 drivers/staging/lustre/lustre/llite/rw26.c |    8 +-
 fs/aio.c                                   |    7 +-
 fs/btrfs/disk-io.c                         |   11 +-
 fs/hugetlbfs/inode.c                       |    9 +-
 fs/nfs/internal.h                          |    5 +-
 fs/nfs/write.c                             |    9 +-
 fs/proc/task_mmu.c                         |   10 +-
 fs/ubifs/file.c                            |    8 +-
 include/linux/balloon_compaction.h         |    3 +-
 include/linux/fs.h                         |   13 +-
 include/linux/hmm.h                        |  525 ++++++++++++++
 include/linux/ioport.h                     |    1 +
 include/linux/memory_hotplug.h             |   31 +-
 include/linux/memremap.h                   |   59 +-
 include/linux/migrate.h                    |    7 +-
 include/linux/mm_types.h                   |    5 +
 include/linux/swap.h                       |   18 +-
 include/linux/swapops.h                    |   67 ++
 kernel/fork.c                              |    2 +
 kernel/memremap.c                          |   69 +-
 mm/Kconfig                                 |   51 ++
 mm/Makefile                                |    1 +
 mm/balloon_compaction.c                    |    2 +-
 mm/hmm.c                                   | 1085 ++++++++++++++++++++++++++++
 mm/memory.c                                |   64 +-
 mm/memory_hotplug.c                        |   14 +-
 mm/migrate.c                               |  687 +++++++++++++++++-
 mm/mprotect.c                              |   12 +
 mm/rmap.c                                  |   47 ++
 mm/zsmalloc.c                              |   12 +-
 tools/testing/nvdimm/test/iomap.c          |    3 +-
 41 files changed, 2926 insertions(+), 87 deletions(-)
 create mode 100644 include/linux/hmm.h
 create mode 100644 mm/hmm.c

-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
