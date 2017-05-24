Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4ACBE6B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:13 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g15so21093917wmc.8
        for <linux-mm@kvack.org>; Wed, 24 May 2017 04:20:13 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x17si9730595wrd.172.2017.05.24.04.20.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 04:20:11 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4OBGXjA046740
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:10 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2an22kjhhq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:09 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 24 May 2017 12:20:07 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v2 00/10] Replace mmap_sem by a range lock
Date: Wed, 24 May 2017 13:19:51 +0200
Message-Id: <1495624801-8063-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, Andi Kleen <andi@firstfloor.org>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

Following the series pushed by Davidlohr Bueso based on the Jan Kara's
work [1] which introduces range locks, this series implements the
first step of the attempt to replace the mmap_sem by a range lock.

While this series simply replaces the mmap_sem by a full range lock,
the final goal is to introduce finer grain locking to allow better
multi-thread performance in regards to the process's memory layout
changes.

This series currently supports x86 and PowerPc architectures only.
Some drivers are also impacted to allow build and basic test on few
platforms but a lot of additional works is required to complete the
job for all the supported architectures.

The goal of this series is to check that no major performance hit
happens for mono threaded process, as we could hope major improvements
in the multi-threaded case once the finer grain locking is
implemented.

I didn't do massive performance checking yet, but building a full
kernel on a 80 threaded Power node, doesn't show performance hits. The
build time is 11m56.701s on a vanilla kernel and 12m4.679s when range
lock is used.

The next steps will attempt to implement finer grain locking but
specific locking would certainly be required to protect mm data like
the VMA cache.

If this series is conform to the community expectation, I'll extend
the other architectures, allowing the swith to a range lock to be
turned on easily. This series will be a nightmare to maintain so it
will be nice if it could merge as soon as possible.

This series applies on top of 4.12-rc2 with range lock series from
Davidlohr [1] applies on top.

The first 2 patches temporary disable some assert which were based on
lock service which are not provided by the range lock API. While some
of these checks will not be valid with range locks, most of them will
have to be reviewed later.

The next 5 patches add a new parameter to some memory service which
need to release the lock, since range lock require the range to
specify, caller has to know about it.

The last 2 patches are doing the job of replacing the mmap_sem by a
range lock, and introduce a new config variable to enable that
changes.

[1] "locking: Introduce range reader/writer lock"
https://lwn.net/Articles/722741/

Changes from v1 [https://lwn.net/Articles/720373/]:
 - encapsulate change through #ifdef CONFIG_MEM_RANGE_LOCK
 - introduce new mem range lock operations to move easily from a
   semaphore to a range lock.
 - split the leading patches adding the range parameters to some
   services.

Laurent Dufour (10):
  mm: Deactivate mmap_sem assert
  mm: Remove nest locking operation with mmap_sem
  mm: Add a range parameter to the vm_fault structure
  mm: Handle range lock field when collapsing huge pages
  mm: Add a range lock parameter to userfaultfd_remove()
  mm: Add a range lock parameter to lock_page_or_retry()
  mm: Add a range lock parameter to GUP() and handle_page_fault()
  mm: Define mem range lock operations
  mm: Change mmap_sem to range lock
  mm: Introduce CONFIG_MEM_RANGE_LOCK

 arch/powerpc/kernel/vdso.c                         |   7 +-
 arch/powerpc/kvm/book3s_64_mmu_hv.c                |   5 +-
 arch/powerpc/kvm/book3s_64_mmu_radix.c             |   5 +-
 arch/powerpc/kvm/book3s_64_vio.c                   |   5 +-
 arch/powerpc/kvm/book3s_hv.c                       |   7 +-
 arch/powerpc/kvm/e500_mmu_host.c                   |   6 +-
 arch/powerpc/mm/copro_fault.c                      |   7 +-
 arch/powerpc/mm/fault.c                            |  11 +-
 arch/powerpc/mm/mmu_context_iommu.c                |   5 +-
 arch/powerpc/mm/subpage-prot.c                     |  14 ++-
 arch/powerpc/oprofile/cell/spu_task_sync.c         |   7 +-
 arch/powerpc/platforms/cell/spufs/file.c           |   4 +-
 arch/powerpc/platforms/powernv/npu-dma.c           |   4 +-
 arch/x86/entry/vdso/vma.c                          |  12 +-
 arch/x86/events/core.c                             |   2 +
 arch/x86/kernel/tboot.c                            |   6 +-
 arch/x86/kernel/vm86_32.c                          |   5 +-
 arch/x86/mm/fault.c                                |  67 ++++++++---
 arch/x86/mm/mpx.c                                  |  17 +--
 drivers/android/binder.c                           |   7 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c             |   5 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c            |   7 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c             |   7 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c            |   2 +-
 drivers/gpu/drm/amd/amdkfd/kfd_events.c            |   5 +-
 drivers/gpu/drm/amd/amdkfd/kfd_process.c           |   5 +-
 drivers/gpu/drm/etnaviv/etnaviv_gem.c              |   8 +-
 drivers/gpu/drm/i915/i915_gem.c                    |   5 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c            |  12 +-
 drivers/gpu/drm/radeon/radeon_cs.c                 |   5 +-
 drivers/gpu/drm/radeon/radeon_gem.c                |   8 +-
 drivers/gpu/drm/radeon/radeon_mn.c                 |   7 +-
 drivers/gpu/drm/radeon/radeon_ttm.c                |   2 +-
 drivers/gpu/drm/ttm/ttm_bo_vm.c                    |   4 +-
 drivers/infiniband/core/umem.c                     |  19 +--
 drivers/infiniband/core/umem_odp.c                 |   7 +-
 drivers/infiniband/hw/hfi1/user_pages.c            |  16 ++-
 drivers/infiniband/hw/mlx4/main.c                  |   5 +-
 drivers/infiniband/hw/mlx5/main.c                  |   5 +-
 drivers/infiniband/hw/mthca/mthca_memfree.c        |   3 +-
 drivers/infiniband/hw/qib/qib_user_pages.c         |  13 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c           |  19 +--
 drivers/iommu/amd_iommu_v2.c                       |   7 +-
 drivers/iommu/intel-svm.c                          |   7 +-
 drivers/media/v4l2-core/videobuf-core.c            |   5 +-
 drivers/media/v4l2-core/videobuf-dma-contig.c      |   5 +-
 drivers/media/v4l2-core/videobuf-dma-sg.c          |   7 +-
 drivers/misc/cxl/fault.c                           |   5 +-
 drivers/misc/mic/scif/scif_rma.c                   |  18 +--
 drivers/oprofile/buffer_sync.c                     |  12 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |   3 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |   5 +-
 .../interface/vchiq_arm/vchiq_2835_arm.c           |   6 +-
 .../vc04_services/interface/vchiq_arm/vchiq_arm.c  |   5 +-
 drivers/vfio/vfio_iommu_spapr_tce.c                |  11 +-
 drivers/vfio/vfio_iommu_type1.c                    |  16 +--
 drivers/xen/gntdev.c                               |   5 +-
 drivers/xen/privcmd.c                              |  12 +-
 fs/aio.c                                           |   5 +-
 fs/coredump.c                                      |   5 +-
 fs/exec.c                                          |  22 ++--
 fs/proc/base.c                                     |  32 +++--
 fs/proc/internal.h                                 |   3 +
 fs/proc/task_mmu.c                                 |  24 ++--
 fs/proc/task_nommu.c                               |  24 ++--
 fs/userfaultfd.c                                   |  35 ++++--
 include/linux/huge_mm.h                            |   4 +
 include/linux/mm.h                                 |  88 ++++++++++++--
 include/linux/mm_types.h                           |   5 +
 include/linux/pagemap.h                            |  17 +++
 include/linux/userfaultfd_k.h                      |  28 ++++-
 ipc/shm.c                                          |  10 +-
 kernel/acct.c                                      |   5 +-
 kernel/events/core.c                               |   5 +-
 kernel/events/uprobes.c                            |  24 ++--
 kernel/exit.c                                      |   9 +-
 kernel/fork.c                                      |  20 +++-
 kernel/futex.c                                     |   7 +-
 kernel/sched/fair.c                                |   6 +-
 kernel/sys.c                                       |  22 ++--
 kernel/trace/trace_output.c                        |   5 +-
 mm/Kconfig                                         |  12 ++
 mm/filemap.c                                       |  13 +-
 mm/frame_vector.c                                  |   8 +-
 mm/gup.c                                           | 131 ++++++++++++++++-----
 mm/init-mm.c                                       |   4 +
 mm/internal.h                                      |  11 +-
 mm/khugepaged.c                                    |  74 ++++++++----
 mm/ksm.c                                           |  39 +++---
 mm/madvise.c                                       |  57 ++++++---
 mm/memcontrol.c                                    |  12 +-
 mm/memory.c                                        |  52 ++++++--
 mm/mempolicy.c                                     |  28 +++--
 mm/migrate.c                                       |  10 +-
 mm/mincore.c                                       |   5 +-
 mm/mlock.c                                         |  20 ++--
 mm/mmap.c                                          |  46 +++++---
 mm/mmu_notifier.c                                  |   5 +-
 mm/mprotect.c                                      |  17 +--
 mm/mremap.c                                        |   5 +-
 mm/msync.c                                         |   9 +-
 mm/nommu.c                                         |  26 ++--
 mm/oom_kill.c                                      |   7 +-
 mm/pagewalk.c                                      |   5 +
 mm/process_vm_access.c                             |   8 +-
 mm/shmem.c                                         |   2 +-
 mm/swapfile.c                                      |   7 +-
 mm/userfaultfd.c                                   |  33 ++++--
 mm/util.c                                          |  11 +-
 security/tomoyo/domain.c                           |   2 +-
 virt/kvm/async_pf.c                                |   7 +-
 virt/kvm/kvm_main.c                                |  33 ++++--
 112 files changed, 1079 insertions(+), 526 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
