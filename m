Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id DEEFF6B03A6
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 08:18:38 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id m127so8933604itg.8
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 05:18:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r81si2499726pfk.4.2017.04.19.05.18.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 05:18:37 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3JCDoxt060325
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 08:18:37 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29x0wy95wp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 08:18:37 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 19 Apr 2017 13:18:34 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC 0/4] Replace mmap_sem by a range lock
Date: Wed, 19 Apr 2017 14:18:23 +0200
Message-Id: <cover.1492595897.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, Paul.McKenney@us.ibm.com, linux-kernel@vger.kernel.org

Following the series pushed by Davidlohr Bueso based on the Jan Kara's
work [1] which introduces range locks, this series implements the
first step of the attempt to replace the mmap_sem by a range lock.

While this series simply replaces the mmap_sem by a full range lock,
the final goal is to introduce finer grain locking to allow better
multi-thread performance in regards to the process's memory layout
changes.

This series is currently supports x86 and PowerPc architectures only.
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

This series applies on top of 4.11-rc7.

The first patch introduce a new parameter to some memory service which
need to release the lock, since range lock require the range to
specify, caller has to know about it.

The second patch is removing some assert which were based on lock
service which are not provided by the range lock API. While some of
these checks will not be valid with range locks, some may be reviewed.

The third patch is replacing nest locking operation on mmap_sem to
simple locking operation has the nest lock check is not yet provided
by the range lock API.

The latest patch is doing the job of replacing the mmap_sem by a range
lock.

[1] "locking: Introduce range reader/writer lock"
http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1371431.html

Laurent Dufour (4):
  Add additional range parameter to GUP() and handle_page_fault()
  Deactivate mmap_sem assert
  Remove nest locking operation with mmap_sem
  Change mmap_sem to range lock

 arch/powerpc/kernel/vdso.c                         |  8 ++-
 arch/powerpc/kvm/book3s_64_mmu_hv.c                |  6 +-
 arch/powerpc/kvm/book3s_64_mmu_radix.c             |  6 +-
 arch/powerpc/kvm/book3s_64_vio.c                   |  6 +-
 arch/powerpc/kvm/book3s_hv.c                       |  8 ++-
 arch/powerpc/kvm/e500_mmu_host.c                   |  7 ++-
 arch/powerpc/mm/copro_fault.c                      |  8 ++-
 arch/powerpc/mm/fault.c                            | 12 ++--
 arch/powerpc/mm/mmu_context_iommu.c                |  6 +-
 arch/powerpc/mm/subpage-prot.c                     | 16 ++++--
 arch/powerpc/oprofile/cell/spu_task_sync.c         |  8 ++-
 arch/powerpc/platforms/cell/spufs/file.c           |  4 +-
 arch/x86/entry/vdso/vma.c                          | 14 +++--
 arch/x86/events/core.c                             |  1 -
 arch/x86/kernel/tboot.c                            |  2 +-
 arch/x86/kernel/vm86_32.c                          |  6 +-
 arch/x86/mm/fault.c                                | 39 +++++++------
 arch/x86/mm/mpx.c                                  | 20 ++++---
 drivers/android/binder.c                           |  8 ++-
 drivers/firmware/efi/arm-runtime.c                 |  2 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c             |  9 ++-
 drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c            |  8 ++-
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c             |  8 ++-
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c            |  2 +-
 drivers/gpu/drm/amd/amdkfd/kfd_events.c            |  6 +-
 drivers/gpu/drm/amd/amdkfd/kfd_process.c           |  6 +-
 drivers/gpu/drm/etnaviv/etnaviv_gem.c              |  9 ++-
 drivers/gpu/drm/i915/i915_gem.c                    |  6 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c            | 14 +++--
 drivers/gpu/drm/radeon/radeon_cs.c                 |  9 ++-
 drivers/gpu/drm/radeon/radeon_gem.c                |  8 ++-
 drivers/gpu/drm/radeon/radeon_mn.c                 |  8 ++-
 drivers/gpu/drm/radeon/radeon_ttm.c                |  2 +-
 drivers/gpu/drm/ttm/ttm_bo_vm.c                    |  6 +-
 drivers/gpu/drm/via/via_dmablit.c                  |  6 +-
 drivers/infiniband/core/umem.c                     | 22 +++++---
 drivers/infiniband/core/umem_odp.c                 |  8 ++-
 drivers/infiniband/hw/hfi1/user_pages.c            | 18 ++++--
 drivers/infiniband/hw/mlx4/main.c                  |  6 +-
 drivers/infiniband/hw/mlx5/main.c                  |  6 +-
 drivers/infiniband/hw/mthca/mthca_memfree.c        |  3 +-
 drivers/infiniband/hw/qib/qib_user_pages.c         | 18 ++++--
 drivers/infiniband/hw/usnic/usnic_uiom.c           | 22 +++++---
 drivers/iommu/amd_iommu_v2.c                       |  8 ++-
 drivers/iommu/intel-svm.c                          |  8 ++-
 drivers/media/v4l2-core/videobuf-core.c            |  9 ++-
 drivers/media/v4l2-core/videobuf-dma-contig.c      |  6 +-
 drivers/media/v4l2-core/videobuf-dma-sg.c          |  8 ++-
 drivers/misc/cxl/fault.c                           |  6 +-
 drivers/misc/mic/scif/scif_rma.c                   | 19 ++++---
 drivers/oprofile/buffer_sync.c                     | 14 +++--
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  4 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  6 +-
 .../interface/vchiq_arm/vchiq_2835_arm.c           |  7 ++-
 .../vc04_services/interface/vchiq_arm/vchiq_arm.c  |  6 +-
 drivers/vfio/vfio_iommu_spapr_tce.c                | 13 +++--
 drivers/vfio/vfio_iommu_type1.c                    | 24 +++++---
 drivers/virt/fsl_hypervisor.c                      |  6 +-
 drivers/xen/gntdev.c                               |  6 +-
 drivers/xen/privcmd.c                              | 14 +++--
 fs/aio.c                                           |  7 ++-
 fs/coredump.c                                      |  6 +-
 fs/exec.c                                          | 26 ++++++---
 fs/proc/base.c                                     | 38 ++++++++-----
 fs/proc/internal.h                                 |  1 +
 fs/proc/task_mmu.c                                 | 30 ++++++----
 fs/proc/task_nommu.c                               | 27 +++++----
 fs/userfaultfd.c                                   | 33 +++++------
 include/linux/huge_mm.h                            |  2 -
 include/linux/hugetlb.h                            |  4 +-
 include/linux/mm.h                                 | 21 ++++---
 include/linux/mm_types.h                           |  3 +-
 include/linux/pagemap.h                            |  8 ++-
 include/linux/userfaultfd_k.h                      |  6 +-
 ipc/shm.c                                          | 13 +++--
 kernel/acct.c                                      |  6 +-
 kernel/events/core.c                               |  6 +-
 kernel/events/uprobes.c                            | 28 ++++++----
 kernel/exit.c                                      | 10 ++--
 kernel/fork.c                                      | 21 ++++---
 kernel/futex.c                                     |  8 ++-
 kernel/sched/fair.c                                |  7 ++-
 kernel/sys.c                                       | 31 ++++++++---
 kernel/trace/trace_output.c                        |  6 +-
 mm/filemap.c                                       |  9 +--
 mm/frame_vector.c                                  |  9 ++-
 mm/gup.c                                           | 65 ++++++++++++----------
 mm/hugetlb.c                                       |  3 +-
 mm/init-mm.c                                       |  2 +-
 mm/internal.h                                      |  3 +-
 mm/khugepaged.c                                    | 59 ++++++++++++--------
 mm/ksm.c                                           | 48 ++++++++++------
 mm/madvise.c                                       | 38 +++++++------
 mm/memcontrol.c                                    | 14 +++--
 mm/memory.c                                        | 43 +++++++-------
 mm/mempolicy.c                                     | 32 +++++++----
 mm/migrate.c                                       | 12 ++--
 mm/mincore.c                                       |  6 +-
 mm/mlock.c                                         | 25 ++++++---
 mm/mmap.c                                          | 51 +++++++++++------
 mm/mmu_notifier.c                                  |  6 +-
 mm/mprotect.c                                      | 21 ++++---
 mm/mremap.c                                        |  6 +-
 mm/msync.c                                         | 10 ++--
 mm/nommu.c                                         | 31 +++++++----
 mm/oom_kill.c                                      |  9 ++-
 mm/pagewalk.c                                      |  3 -
 mm/process_vm_access.c                             |  9 ++-
 mm/shmem.c                                         |  3 +-
 mm/swapfile.c                                      |  8 ++-
 mm/userfaultfd.c                                   | 25 +++++----
 mm/util.c                                          | 15 +++--
 security/tomoyo/domain.c                           |  2 +-
 virt/kvm/async_pf.c                                |  8 ++-
 virt/kvm/kvm_main.c                                | 31 +++++++----
 115 files changed, 960 insertions(+), 555 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
