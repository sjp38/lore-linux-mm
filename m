Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1663E6B0391
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:04:03 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id j127so42143652qke.2
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:04:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t126si4078322qkf.303.2017.03.16.08.03.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 08:03:45 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 00/16] HMM (Heterogeneous Memory Management) v18
Date: Thu, 16 Mar 2017 12:05:19 -0400
Message-Id: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Cliff note: HMM offers 2 things (each standing on its own). First
it allows to use device memory transparently inside any process
without any modifications to process program code. Second it allows
to mirror process address space on a device.

Changes since v17:
  - typos
  - ZONE_DEVICE page refcount move put_zone_device_page()

Work is still underway to use this feature inside the upstream
nouveau driver. It has been tested with closed source driver
and test are still underway on top of new kernel. So far we have
found no issues. I expect to get a tested-by soon. Also this
feature is not only useful for NVidia GPU, i expect AMD GPU will
need it too if they want to support some of the new industry API.
I also expect some FPGA company to use it and probably other
hardware.

That being said I don't expect i will ever get a review-by anyone
for reasons beyond my control. Many people have read the code and
i included their comments each time they had any. So i believe this
code had sufficient scrutiny from various people to warrent it being
merge. I am willing to face and deal with the fallout but i don't
expect any as this is an opt-in code thought i believe all major
distribution will enable it in order to support new hardware.

I do not wish to compete for the patchset with the highest revision
count and i would like a clear cut position on wether it can be
merge or not. If not i would like to know why because i am more than
willing to address any issues people might have. I just don't want
to keep submitting it over and over until i end up in hell.

So please consider applying for 4.12


Know issues:

Device memory pick some random unuse physical address range. Latter
memory hotplug might fails because of this. Intention is to fix this
in latter patchset to use physical address above the platform limit
thus making sure that no real memory can be hotplug at conflicting
address.


Patchset overview:

Patchset is divided into 3 features that can each be use independently
from one another. First is changes to ZONE_DEVICE so we can have struct
page for device un-addressable memory (patch 1-4 and 13-14). Second is
process address space mirroring (patch 8 to 11), this allow to snapshot
CPU page table and to keep the device page table synchronize with the
CPU one.

Last is a new page migration helper which allow migration for range of
virtual address using hardware copy engine (patch 5-7 for new migrate
function and 12 for migration of un-addressable memory).


Future plan:

In this patchset i restricted myself to set of core features what
is missing:
  - force read only on CPU for memory duplication and GPU atomic
  - changes to mmu_notifier for optimization purposes
  - migration of file back page to device memory

I plan to submit a couple more patchset to implement those features
once core HMM is upstream.

Git tree:
https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-v18


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
    v16 http://www.spinics.net/lists/linux-mm/msg119814.html
    v17 https://lkml.org/lkml/2017/1/27/847

JA(C)rA'me Glisse (16):
  mm/memory/hotplug: convert device bool to int to allow for more flags
    v3
  mm/put_page: move ref decrement to put_zone_device_page()
  mm/ZONE_DEVICE/free-page: callback when page is freed v3
  mm/ZONE_DEVICE/unaddressable: add support for un-addressable device
    memory v3
  mm/ZONE_DEVICE/x86: add support for un-addressable device memory
  mm/migrate: add new boolean copy flag to migratepage() callback
  mm/migrate: new memory migration helper for use with device memory v4
  mm/migrate: migrate_vma() unmap page from vma while collecting pages
  mm/hmm: heterogeneous memory management (HMM for short)
  mm/hmm/mirror: mirror process address space on device with HMM helpers
  mm/hmm/mirror: helper to snapshot CPU page table v2
  mm/hmm/mirror: device page fault handler
  mm/hmm/migrate: support un-addressable ZONE_DEVICE page in migration
  mm/migrate: allow migrate_vma() to alloc new page on empty entry
  mm/hmm/devmem: device memory hotplug using ZONE_DEVICE
  mm/hmm/devmem: dummy HMM device for ZONE_DEVICE memory v2

 MAINTAINERS                                |    7 +
 arch/ia64/mm/init.c                        |   23 +-
 arch/powerpc/mm/mem.c                      |   23 +-
 arch/s390/mm/init.c                        |   10 +-
 arch/sh/mm/init.c                          |   22 +-
 arch/tile/mm/init.c                        |   10 +-
 arch/x86/mm/init_32.c                      |   23 +-
 arch/x86/mm/init_64.c                      |   41 +-
 drivers/staging/lustre/lustre/llite/rw26.c |    8 +-
 fs/aio.c                                   |    7 +-
 fs/btrfs/disk-io.c                         |   11 +-
 fs/f2fs/data.c                             |    8 +-
 fs/f2fs/f2fs.h                             |    2 +-
 fs/hugetlbfs/inode.c                       |    9 +-
 fs/nfs/internal.h                          |    5 +-
 fs/nfs/write.c                             |    9 +-
 fs/proc/task_mmu.c                         |    7 +
 fs/ubifs/file.c                            |    8 +-
 include/linux/balloon_compaction.h         |    3 +-
 include/linux/fs.h                         |   13 +-
 include/linux/hmm.h                        |  468 +++++++++++
 include/linux/ioport.h                     |    1 +
 include/linux/memory_hotplug.h             |   31 +-
 include/linux/memremap.h                   |   37 +
 include/linux/migrate.h                    |   86 +-
 include/linux/mm.h                         |    8 +-
 include/linux/mm_types.h                   |    5 +
 include/linux/swap.h                       |   18 +-
 include/linux/swapops.h                    |   67 ++
 kernel/fork.c                              |    2 +
 kernel/memremap.c                          |   34 +-
 mm/Kconfig                                 |   38 +
 mm/Makefile                                |    1 +
 mm/balloon_compaction.c                    |    2 +-
 mm/hmm.c                                   | 1231 ++++++++++++++++++++++++++++
 mm/memory.c                                |   66 +-
 mm/memory_hotplug.c                        |   14 +-
 mm/migrate.c                               |  786 +++++++++++++++++-
 mm/mprotect.c                              |   12 +
 mm/page_vma_mapped.c                       |   10 +
 mm/rmap.c                                  |   25 +
 mm/zsmalloc.c                              |   12 +-
 42 files changed, 3119 insertions(+), 84 deletions(-)
 create mode 100644 include/linux/hmm.h
 create mode 100644 mm/hmm.c

-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
