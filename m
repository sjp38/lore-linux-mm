Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A9AF6B72B4
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 00:37:03 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id w185so19162934qka.9
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 21:37:03 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x83si125211qka.105.2018.12.04.21.37.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 21:37:02 -0800 (PST)
From: jglisse@redhat.com
Subject: [PATCH v2 0/3] mmu notifier contextual informations
Date: Wed,  5 Dec 2018 00:36:25 -0500
Message-Id: <20181205053628.3210-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Jérôme Glisse <jglisse@redhat.com>

Changes since v1:

- Fixed the case where mmu notifier is not enabled and avoid wasting
  memory and resource when that is the case.
- Fixed bug in migrate code.
- Use kernel doc format for describing kernel enum


v1 cover letter:

This patchset add contextual information, why an invalidation is
happening, to mmu notifier callback. This is necessary for user
of mmu notifier that wish to maintains their own data structure
without having to add new fields to struct vm_area_struct (vma).

For instance device can have they own page table that mirror the
process address space. When a vma is unmap (munmap() syscall) the
device driver can free the device page table for the range.

Today we do not have any information on why a mmu notifier call
back is happening and thus device driver have to assume that it
is always an munmap(). This is inefficient at it means that it
needs to re-allocate device page table on next page fault and
rebuild the whole device driver data structure for the range.

Other use case beside munmap() also exist, for instance it is
pointless for device driver to invalidate the device page table
when the invalidation is for the soft dirtyness tracking. Or
device driver can optimize away mprotect() that change the page
table permission access for the range.

This patchset enable all this optimizations for device driver.
I do not include any of those in this serie but other patchset
i am posting will leverage this.


>From code point of view the patchset is pretty simple, the first
two patches consolidate all mmu notifier arguments into a struct
so that it is easier to add/change arguments. The last patch adds
the contextual information (munmap, protection, soft dirty, clear,
...).

Cheers,
Jérôme

Jérôme Glisse (3):
  mm/mmu_notifier: use structure for invalidate_range_start/end callback
  mm/mmu_notifier: use structure for invalidate_range_start/end calls v2
  mm/mmu_notifier: contextual information for event triggering
    invalidation v2

 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c  |  43 ++++----
 drivers/gpu/drm/i915/i915_gem_userptr.c |  14 ++-
 drivers/gpu/drm/radeon/radeon_mn.c      |  16 ++-
 drivers/infiniband/core/umem_odp.c      |  20 ++--
 drivers/infiniband/hw/hfi1/mmu_rb.c     |  13 +--
 drivers/misc/mic/scif/scif_dma.c        |  11 +-
 drivers/misc/sgi-gru/grutlbpurge.c      |  14 ++-
 drivers/xen/gntdev.c                    |  12 +--
 fs/dax.c                                |  15 ++-
 fs/proc/task_mmu.c                      |   8 +-
 include/linux/mm.h                      |   4 +-
 include/linux/mmu_notifier.h            | 132 ++++++++++++++++++------
 kernel/events/uprobes.c                 |  11 +-
 mm/hmm.c                                |  23 ++---
 mm/huge_memory.c                        |  58 +++++------
 mm/hugetlb.c                            |  54 +++++-----
 mm/khugepaged.c                         |  11 +-
 mm/ksm.c                                |  23 ++---
 mm/madvise.c                            |  22 ++--
 mm/memory.c                             | 103 +++++++++---------
 mm/migrate.c                            |  26 ++---
 mm/mmu_notifier.c                       |  22 ++--
 mm/mprotect.c                           |  16 +--
 mm/mremap.c                             |  11 +-
 mm/oom_kill.c                           |  17 +--
 mm/rmap.c                               |  32 +++---
 virt/kvm/kvm_main.c                     |  14 +--
 27 files changed, 404 insertions(+), 341 deletions(-)

-- 
2.17.2
