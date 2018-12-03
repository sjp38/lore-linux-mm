Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id F2EE96B6AE2
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 15:18:33 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id k90so14711989qte.0
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 12:18:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j25si2954361qtr.152.2018.12.03.12.18.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 12:18:33 -0800 (PST)
From: jglisse@redhat.com
Subject: [PATCH 0/3] mmu notifier contextual informations
Date: Mon,  3 Dec 2018 15:18:14 -0500
Message-Id: <20181203201817.10759-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <zwisler@kernel.org>, Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>, Christian Koenig <christian.koenig@amd.com>, Felix Kuehling <felix.kuehling@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org, linux-rdma@vger.kernel.org, linux-fsdevel@vger.kernel.org, dri-devel@lists.freedesktop.org

From: Jérôme Glisse <jglisse@redhat.com>

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

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim Krčmář <rkrcmar@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Christian Koenig <christian.koenig@amd.com>
Cc: Felix Kuehling <felix.kuehling@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: kvm@vger.kernel.org
Cc: linux-rdma@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org
Cc: dri-devel@lists.freedesktop.org

Jérôme Glisse (3):
  mm/mmu_notifier: use structure for invalidate_range_start/end callback
  mm/mmu_notifier: use structure for invalidate_range_start/end calls
  mm/mmu_notifier: contextual information for event triggering
    invalidation

 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c  |  43 ++++-----
 drivers/gpu/drm/i915/i915_gem_userptr.c |  14 ++-
 drivers/gpu/drm/radeon/radeon_mn.c      |  16 ++--
 drivers/infiniband/core/umem_odp.c      |  20 ++---
 drivers/infiniband/hw/hfi1/mmu_rb.c     |  13 ++-
 drivers/misc/mic/scif/scif_dma.c        |  11 +--
 drivers/misc/sgi-gru/grutlbpurge.c      |  14 ++-
 drivers/xen/gntdev.c                    |  12 +--
 fs/dax.c                                |  11 ++-
 fs/proc/task_mmu.c                      |  10 ++-
 include/linux/mm.h                      |   4 +-
 include/linux/mmu_notifier.h            | 106 +++++++++++++++-------
 kernel/events/uprobes.c                 |  13 +--
 mm/hmm.c                                |  23 ++---
 mm/huge_memory.c                        |  58 ++++++------
 mm/hugetlb.c                            |  63 +++++++------
 mm/khugepaged.c                         |  13 +--
 mm/ksm.c                                |  26 +++---
 mm/madvise.c                            |  22 ++---
 mm/memory.c                             | 112 ++++++++++++++----------
 mm/migrate.c                            |  30 ++++---
 mm/mmu_notifier.c                       |  22 +++--
 mm/mprotect.c                           |  17 ++--
 mm/mremap.c                             |  14 +--
 mm/oom_kill.c                           |  20 +++--
 mm/rmap.c                               |  34 ++++---
 virt/kvm/kvm_main.c                     |  14 ++-
 27 files changed, 421 insertions(+), 334 deletions(-)

-- 
2.17.2
