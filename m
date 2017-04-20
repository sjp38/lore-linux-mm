Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF57A6B03B6
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 10:28:39 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id l196so75977470ioe.19
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 07:28:39 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q62si7244928iod.62.2017.04.20.07.28.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 07:28:35 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3KENbM0042085
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 10:28:34 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29xmw5b6gq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 10:28:32 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 20 Apr 2017 15:28:25 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC 4/4] Change mmap_sem to range lock
Date: Thu, 20 Apr 2017 16:28:20 +0200
In-Reply-To: <cover.1492595897.git.ldufour@linux.vnet.ibm.com>
References: <cover.1492595897.git.ldufour@linux.vnet.ibm.com>
Message-Id: <1492698500-24219-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, Paul.McKenney@us.ibm.com, linux-kernel@vger.kernel.org

[resent this patch which seems to have not reached the mailing lists]

Change the mmap_sem to a range lock to allow finer grain locking on
the memory layout of a task.

This patch rename mmap_sem into mmap_rw_tree to avoid confusion and
replace any locking (read or write) by complete range locking.  So
there is no functional change except in the way the underlying locking
is achieved.

Currently, this patch only supports x86 and PowerPc architectures,
furthermore it should break the build of any others.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/powerpc/kernel/vdso.c                         |  8 ++--
 arch/powerpc/kvm/book3s_64_mmu_hv.c                |  6 ++-
 arch/powerpc/kvm/book3s_64_mmu_radix.c             |  6 ++-
 arch/powerpc/kvm/book3s_64_vio.c                   |  6 ++-
 arch/powerpc/kvm/book3s_hv.c                       |  8 ++--
 arch/powerpc/kvm/e500_mmu_host.c                   |  7 +++-
 arch/powerpc/mm/copro_fault.c                      |  6 ++-
 arch/powerpc/mm/fault.c                            | 12 +++---
 arch/powerpc/mm/mmu_context_iommu.c                |  6 ++-
 arch/powerpc/mm/subpage-prot.c                     | 16 +++++---
 arch/powerpc/oprofile/cell/spu_task_sync.c         |  8 ++--
 arch/powerpc/platforms/cell/spufs/file.c           |  4 +-
 arch/x86/entry/vdso/vma.c                          | 14 ++++---
 arch/x86/kernel/tboot.c                            |  2 +-
 arch/x86/kernel/vm86_32.c                          |  6 ++-
 arch/x86/mm/fault.c                                | 39 +++++++++++--------
 arch/x86/mm/mpx.c                                  | 18 ++++++---
 drivers/android/binder.c                           |  8 ++--
 drivers/firmware/efi/arm-runtime.c                 |  2 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c             |  9 +++--
 drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c            |  8 ++--
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c             |  8 ++--
 drivers/gpu/drm/amd/amdkfd/kfd_events.c            |  6 ++-
 drivers/gpu/drm/amd/amdkfd/kfd_process.c           |  6 ++-
 drivers/gpu/drm/etnaviv/etnaviv_gem.c              |  6 ++-
 drivers/gpu/drm/i915/i915_gem.c                    |  6 ++-
 drivers/gpu/drm/i915/i915_gem_userptr.c            | 12 ++++--
 drivers/gpu/drm/radeon/radeon_cs.c                 |  9 +++--
 drivers/gpu/drm/radeon/radeon_gem.c                |  8 ++--
 drivers/gpu/drm/radeon/radeon_mn.c                 |  8 ++--
 drivers/gpu/drm/ttm/ttm_bo_vm.c                    |  6 ++-
 drivers/gpu/drm/via/via_dmablit.c                  |  6 ++-
 drivers/infiniband/core/umem.c                     | 20 ++++++----
 drivers/infiniband/core/umem_odp.c                 |  6 ++-
 drivers/infiniband/hw/hfi1/user_pages.c            | 18 ++++++---
 drivers/infiniband/hw/mlx4/main.c                  |  6 ++-
 drivers/infiniband/hw/mlx5/main.c                  |  6 ++-
 drivers/infiniband/hw/qib/qib_user_pages.c         | 16 +++++---
 drivers/infiniband/hw/usnic/usnic_uiom.c           | 20 ++++++----
 drivers/iommu/amd_iommu_v2.c                       |  8 ++--
 drivers/iommu/intel-svm.c                          |  6 ++-
 drivers/media/v4l2-core/videobuf-core.c            |  9 +++--
 drivers/media/v4l2-core/videobuf-dma-contig.c      |  6 ++-
 drivers/media/v4l2-core/videobuf-dma-sg.c          |  6 ++-
 drivers/misc/cxl/fault.c                           |  6 ++-
 drivers/misc/mic/scif/scif_rma.c                   | 17 +++++---
 drivers/oprofile/buffer_sync.c                     | 14 ++++---
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  4 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  6 ++-
 .../interface/vchiq_arm/vchiq_2835_arm.c           |  7 +++-
 .../vc04_services/interface/vchiq_arm/vchiq_arm.c  |  6 ++-
 drivers/vfio/vfio_iommu_spapr_tce.c                | 13 +++++--
 drivers/vfio/vfio_iommu_type1.c                    | 24 +++++++-----
 drivers/virt/fsl_hypervisor.c                      |  6 ++-
 drivers/xen/gntdev.c                               |  6 ++-
 drivers/xen/privcmd.c                              | 14 ++++---
 fs/aio.c                                           |  7 +++-
 fs/coredump.c                                      |  6 ++-
 fs/exec.c                                          | 24 ++++++++----
 fs/proc/base.c                                     | 38 +++++++++++-------
 fs/proc/internal.h                                 |  1 +
 fs/proc/task_mmu.c                                 | 30 +++++++++------
 fs/proc/task_nommu.c                               | 27 ++++++++-----
 fs/userfaultfd.c                                   | 24 +++++++-----
 include/linux/mm_types.h                           |  3 +-
 ipc/shm.c                                          | 13 +++++--
 kernel/acct.c                                      |  6 ++-
 kernel/events/core.c                               |  6 ++-
 kernel/events/uprobes.c                            | 24 ++++++++----
 kernel/exit.c                                      | 10 +++--
 kernel/fork.c                                      | 21 ++++++----
 kernel/futex.c                                     |  8 ++--
 kernel/sched/fair.c                                |  7 ++--
 kernel/sys.c                                       | 31 ++++++++++-----
 kernel/trace/trace_output.c                        |  6 ++-
 mm/filemap.c                                       |  4 +-
 mm/frame_vector.c                                  |  9 +++--
 mm/gup.c                                           | 22 ++++++-----
 mm/init-mm.c                                       |  2 +-
 mm/khugepaged.c                                    | 44 +++++++++++++--------
 mm/ksm.c                                           | 45 ++++++++++++++--------
 mm/madvise.c                                       | 28 ++++++++------
 mm/memcontrol.c                                    | 14 ++++---
 mm/memory.c                                        | 21 +++++++---
 mm/mempolicy.c                                     | 30 +++++++++------
 mm/migrate.c                                       | 12 ++++--
 mm/mincore.c                                       |  6 ++-
 mm/mlock.c                                         | 25 ++++++++----
 mm/mmap.c                                          | 43 ++++++++++++++-------
 mm/mmu_notifier.c                                  |  6 ++-
 mm/mprotect.c                                      | 19 ++++++---
 mm/mremap.c                                        |  6 ++-
 mm/msync.c                                         | 10 +++--
 mm/nommu.c                                         | 31 ++++++++++-----
 mm/oom_kill.c                                      |  9 +++--
 mm/process_vm_access.c                             |  8 ++--
 mm/shmem.c                                         |  3 +-
 mm/swapfile.c                                      |  8 ++--
 mm/userfaultfd.c                                   | 19 +++++----
 mm/util.c                                          | 15 ++++++--
 virt/kvm/async_pf.c                                |  8 ++--
 virt/kvm/kvm_main.c                                | 21 ++++++----
 102 files changed, 838 insertions(+), 452 deletions(-)

diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
index 22b01a3962f0..3805c643de8c 100644
--- a/arch/powerpc/kernel/vdso.c
+++ b/arch/powerpc/kernel/vdso.c
@@ -154,6 +154,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	struct page **vdso_pagelist;
 	unsigned long vdso_pages;
 	unsigned long vdso_base;
+	struct range_rwlock range;
 	int rc;
 
 	if (!vdso_ready)
@@ -196,7 +197,8 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	 * and end up putting it elsewhere.
 	 * Add enough to the size so that the result can be aligned.
 	 */
-	if (down_write_killable(&mm->mmap_sem))
+	range_rwlock_init_full(&range);
+	if (range_write_lock_interruptible(&mm->mmap_rw_tree, &range))
 		return -EINTR;
 	vdso_base = get_unmapped_area(NULL, vdso_base,
 				      (vdso_pages << PAGE_SHIFT) +
@@ -236,11 +238,11 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 		goto fail_mmapsem;
 	}
 
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	return 0;
 
  fail_mmapsem:
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	return rc;
 }
 
diff --git a/arch/powerpc/kvm/book3s_64_mmu_hv.c b/arch/powerpc/kvm/book3s_64_mmu_hv.c
index 710e491206ed..31026e3e11ec 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_hv.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_hv.c
@@ -485,6 +485,7 @@ int kvmppc_book3s_hv_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 	struct vm_area_struct *vma;
 	unsigned long rcbits;
 	long mmio_update;
+	struct range_rwlock range;
 
 	if (kvm_is_radix(kvm))
 		return kvmppc_book3s_radix_page_fault(run, vcpu, ea, dsisr);
@@ -568,7 +569,8 @@ int kvmppc_book3s_hv_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 	npages = get_user_pages_fast(hva, 1, writing, pages);
 	if (npages < 1) {
 		/* Check if it's an I/O mapping */
-		down_read(&current->mm->mmap_sem);
+		range_rwlock_init_full(&range);
+		range_read_lock(&current->mm->mmap_rw_tree, &range);
 		vma = find_vma(current->mm, hva);
 		if (vma && vma->vm_start <= hva && hva + psize <= vma->vm_end &&
 		    (vma->vm_flags & VM_PFNMAP)) {
@@ -578,7 +580,7 @@ int kvmppc_book3s_hv_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 			is_ci = pte_ci(__pte((pgprot_val(vma->vm_page_prot))));
 			write_ok = vma->vm_flags & VM_WRITE;
 		}
-		up_read(&current->mm->mmap_sem);
+		range_read_unlock(&current->mm->mmap_rw_tree, &range);
 		if (!pfn)
 			goto out_put;
 	} else {
diff --git a/arch/powerpc/kvm/book3s_64_mmu_radix.c b/arch/powerpc/kvm/book3s_64_mmu_radix.c
index f6b3e67c5762..85c8a66bd45c 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_radix.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_radix.c
@@ -305,6 +305,7 @@ int kvmppc_book3s_radix_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 	pte_t pte, *ptep;
 	unsigned long pgflags;
 	unsigned int shift, level;
+	struct range_rwlock range;
 
 	/* Check for unusual errors */
 	if (dsisr & DSISR_UNSUPP_MMU) {
@@ -394,7 +395,8 @@ int kvmppc_book3s_radix_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 	npages = get_user_pages_fast(hva, 1, writing, pages);
 	if (npages < 1) {
 		/* Check if it's an I/O mapping */
-		down_read(&current->mm->mmap_sem);
+		range_rwlock_init_full(&range);
+		range_read_lock(&current->mm->mmap_rw_tree, &range);
 		vma = find_vma(current->mm, hva);
 		if (vma && vma->vm_start <= hva && hva < vma->vm_end &&
 		    (vma->vm_flags & VM_PFNMAP)) {
@@ -402,7 +404,7 @@ int kvmppc_book3s_radix_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 				((hva - vma->vm_start) >> PAGE_SHIFT);
 			pgflags = pgprot_val(vma->vm_page_prot);
 		}
-		up_read(&current->mm->mmap_sem);
+		range_read_unlock(&current->mm->mmap_rw_tree, &range);
 		if (!pfn)
 			return -EFAULT;
 	} else {
diff --git a/arch/powerpc/kvm/book3s_64_vio.c b/arch/powerpc/kvm/book3s_64_vio.c
index 3e26cd4979f9..3199d072ddd3 100644
--- a/arch/powerpc/kvm/book3s_64_vio.c
+++ b/arch/powerpc/kvm/book3s_64_vio.c
@@ -57,11 +57,13 @@ static unsigned long kvmppc_stt_pages(unsigned long tce_pages)
 static long kvmppc_account_memlimit(unsigned long stt_pages, bool inc)
 {
 	long ret = 0;
+	struct range_rwlock range;
 
 	if (!current || !current->mm)
 		return ret; /* process exited */
 
-	down_write(&current->mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&current->mm->mmap_rw_tree, &range);
 
 	if (inc) {
 		unsigned long locked, lock_limit;
@@ -86,7 +88,7 @@ static long kvmppc_account_memlimit(unsigned long stt_pages, bool inc)
 			rlimit(RLIMIT_MEMLOCK),
 			ret ? " - exceeded" : "");
 
-	up_write(&current->mm->mmap_sem);
+	range_write_unlock(&current->mm->mmap_rw_tree, &range);
 
 	return ret;
 }
diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index 1ec86d9e2a82..998b800b1ea8 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -3192,6 +3192,7 @@ static int kvmppc_hv_setup_htab_rma(struct kvm_vcpu *vcpu)
 	unsigned long lpcr = 0, senc;
 	unsigned long psize, porder;
 	int srcu_idx;
+	struct range_rwlock range;
 
 	mutex_lock(&kvm->lock);
 	if (kvm->arch.hpte_setup_done)
@@ -3228,7 +3229,8 @@ static int kvmppc_hv_setup_htab_rma(struct kvm_vcpu *vcpu)
 
 	/* Look up the VMA for the start of this memory slot */
 	hva = memslot->userspace_addr;
-	down_read(&current->mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&current->mm->mmap_rw_tree, &range);
 	vma = find_vma(current->mm, hva);
 	if (!vma || vma->vm_start > hva || (vma->vm_flags & VM_IO))
 		goto up_out;
@@ -3236,7 +3238,7 @@ static int kvmppc_hv_setup_htab_rma(struct kvm_vcpu *vcpu)
 	psize = vma_kernel_pagesize(vma);
 	porder = __ilog2(psize);
 
-	up_read(&current->mm->mmap_sem);
+	range_read_unlock(&current->mm->mmap_rw_tree, &range);
 
 	/* We can handle 4k, 64k or 16M pages in the VRMA */
 	err = -EINVAL;
@@ -3270,7 +3272,7 @@ static int kvmppc_hv_setup_htab_rma(struct kvm_vcpu *vcpu)
 	return err;
 
  up_out:
-	up_read(&current->mm->mmap_sem);
+	range_read_unlock(&current->mm->mmap_rw_tree, &range);
 	goto out_srcu;
 }
 
diff --git a/arch/powerpc/kvm/e500_mmu_host.c b/arch/powerpc/kvm/e500_mmu_host.c
index 0fda4230f6c0..e50456aaf86c 100644
--- a/arch/powerpc/kvm/e500_mmu_host.c
+++ b/arch/powerpc/kvm/e500_mmu_host.c
@@ -357,7 +357,10 @@ static inline int kvmppc_e500_shadow_map(struct kvmppc_vcpu_e500 *vcpu_e500,
 
 	if (tlbsel == 1) {
 		struct vm_area_struct *vma;
-		down_read(&current->mm->mmap_sem);
+		struct range_rwlock range;
+
+		range_rwlock_init_full(&range);
+		range_read_lock(&current->mm->mmap_rw_tree, &range);
 
 		vma = find_vma(current->mm, hva);
 		if (vma && hva >= vma->vm_start &&
@@ -443,7 +446,7 @@ static inline int kvmppc_e500_shadow_map(struct kvmppc_vcpu_e500 *vcpu_e500,
 			tsize = max(BOOK3E_PAGESZ_4K, tsize & ~1);
 		}
 
-		up_read(&current->mm->mmap_sem);
+		range_read_unlock(&current->mm->mmap_rw_tree, &range);
 	}
 
 	if (likely(!pfnmap)) {
diff --git a/arch/powerpc/mm/copro_fault.c b/arch/powerpc/mm/copro_fault.c
index 81fbf79d2e97..386e9b614f4c 100644
--- a/arch/powerpc/mm/copro_fault.c
+++ b/arch/powerpc/mm/copro_fault.c
@@ -37,6 +37,7 @@ int copro_handle_mm_fault(struct mm_struct *mm, unsigned long ea,
 		unsigned long dsisr, unsigned *flt)
 {
 	struct vm_area_struct *vma;
+	struct range_rwlock range;
 	unsigned long is_write;
 	int ret;
 
@@ -46,7 +47,8 @@ int copro_handle_mm_fault(struct mm_struct *mm, unsigned long ea,
 	if (mm->pgd == NULL)
 		return -EFAULT;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	ret = -EFAULT;
 	vma = find_vma(mm, ea);
 	if (!vma)
@@ -95,7 +97,7 @@ int copro_handle_mm_fault(struct mm_struct *mm, unsigned long ea,
 		current->min_flt++;
 
 out_unlock:
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(copro_handle_mm_fault);
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 20f470486177..9cd547e97f65 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -208,6 +208,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
  	int is_exec = trap == 0x400;
 	int fault;
 	int rc = 0, store_update_sp = 0;
+	struct range_rwlock range;
 
 #if !(defined(CONFIG_4xx) || defined(CONFIG_BOOKE))
 	/*
@@ -308,12 +309,13 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	 * source.  If this is invalid we can skip the address space check,
 	 * thus avoiding the deadlock.
 	 */
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	range_rwlock_init_full(&range); /* XXX finer grain required here */
+	if (!range_read_trylock(&mm->mmap_rw_tree, &range)) {
 		if (!user_mode(regs) && !search_exception_tables(regs->nip))
 			goto bad_area_nosemaphore;
 
 retry:
-		down_read(&mm->mmap_sem);
+		range_read_lock(&mm->mmap_rw_tree, &range);
 	} else {
 		/*
 		 * The above down_read_trylock() might have succeeded in
@@ -446,7 +448,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags, NULL);
+	fault = handle_mm_fault(vma, address, flags, &range);
 
 	/*
 	 * Handle the retry right now, the mmap_sem has been released in that
@@ -466,7 +468,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 		}
 		/* We will enter mm_fault_error() below */
 	} else
-		up_read(&current->mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, &range);
 
 	if (unlikely(fault & (VM_FAULT_RETRY|VM_FAULT_ERROR))) {
 		if (fault & VM_FAULT_SIGSEGV)
@@ -505,7 +507,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	goto bail;
 
 bad_area:
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 
 bad_area_nosemaphore:
 	/* User mode accesses cause a SIGSEGV */
diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
index 497130c5c742..c9c89b6f559a 100644
--- a/arch/powerpc/mm/mmu_context_iommu.c
+++ b/arch/powerpc/mm/mmu_context_iommu.c
@@ -36,11 +36,13 @@ static long mm_iommu_adjust_locked_vm(struct mm_struct *mm,
 		unsigned long npages, bool incr)
 {
 	long ret = 0, locked, lock_limit;
+	struct range_rwlock range;
 
 	if (!npages)
 		return 0;
 
-	down_write(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&mm->mmap_rw_tree, &range);
 
 	if (incr) {
 		locked = mm->locked_vm + npages;
@@ -61,7 +63,7 @@ static long mm_iommu_adjust_locked_vm(struct mm_struct *mm,
 			npages << PAGE_SHIFT,
 			mm->locked_vm << PAGE_SHIFT,
 			rlimit(RLIMIT_MEMLOCK));
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 
 	return ret;
 }
diff --git a/arch/powerpc/mm/subpage-prot.c b/arch/powerpc/mm/subpage-prot.c
index 94210940112f..3eeb81767581 100644
--- a/arch/powerpc/mm/subpage-prot.c
+++ b/arch/powerpc/mm/subpage-prot.c
@@ -98,8 +98,10 @@ static void subpage_prot_clear(unsigned long addr, unsigned long len)
 	unsigned long i;
 	size_t nw;
 	unsigned long next, limit;
+	struct range_rwlock range;
 
-	down_write(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&mm->mmap_rw_tree, &range);
 	limit = addr + len;
 	if (limit > spt->maxaddr)
 		limit = spt->maxaddr;
@@ -127,7 +129,7 @@ static void subpage_prot_clear(unsigned long addr, unsigned long len)
 		/* now flush any existing HPTEs for the range */
 		hpte_flush_range(mm, addr, nw);
 	}
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -194,6 +196,7 @@ long sys_subpage_prot(unsigned long addr, unsigned long len, u32 __user *map)
 	size_t nw;
 	unsigned long next, limit;
 	int err;
+	struct range_rwlock range;
 
 	/* Check parameters */
 	if ((addr & ~PAGE_MASK) || (len & ~PAGE_MASK) ||
@@ -212,7 +215,8 @@ long sys_subpage_prot(unsigned long addr, unsigned long len, u32 __user *map)
 	if (!access_ok(VERIFY_READ, map, (len >> PAGE_SHIFT) * sizeof(u32)))
 		return -EFAULT;
 
-	down_write(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&mm->mmap_rw_tree, &range);
 	subpage_mark_vma_nohuge(mm, addr, len);
 	for (limit = addr + len; addr < limit; addr = next) {
 		next = pmd_addr_end(addr, limit);
@@ -247,11 +251,11 @@ long sys_subpage_prot(unsigned long addr, unsigned long len, u32 __user *map)
 		if (addr + (nw << PAGE_SHIFT) > next)
 			nw = (next - addr) >> PAGE_SHIFT;
 
-		up_write(&mm->mmap_sem);
+		range_write_unlock(&mm->mmap_rw_tree, &range);
 		if (__copy_from_user(spp, map, nw * sizeof(u32)))
 			return -EFAULT;
 		map += nw;
-		down_write(&mm->mmap_sem);
+		range_write_lock(&mm->mmap_rw_tree, &range);
 
 		/* now flush any existing HPTEs for the range */
 		hpte_flush_range(mm, addr, nw);
@@ -260,6 +264,6 @@ long sys_subpage_prot(unsigned long addr, unsigned long len, u32 __user *map)
 		spt->maxaddr = limit;
 	err = 0;
  out:
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	return err;
 }
diff --git a/arch/powerpc/oprofile/cell/spu_task_sync.c b/arch/powerpc/oprofile/cell/spu_task_sync.c
index 44d67b167e0b..70d8ea31940a 100644
--- a/arch/powerpc/oprofile/cell/spu_task_sync.c
+++ b/arch/powerpc/oprofile/cell/spu_task_sync.c
@@ -325,6 +325,7 @@ get_exec_dcookie_and_offset(struct spu *spu, unsigned int *offsetp,
 	struct vm_area_struct *vma;
 	struct file *exe_file;
 	struct mm_struct *mm = spu->mm;
+	struct range_rwlock range;
 
 	if (!mm)
 		goto out;
@@ -336,7 +337,8 @@ get_exec_dcookie_and_offset(struct spu *spu, unsigned int *offsetp,
 		fput(exe_file);
 	}
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (vma->vm_start > spu_ref || vma->vm_end <= spu_ref)
 			continue;
@@ -353,13 +355,13 @@ get_exec_dcookie_and_offset(struct spu *spu, unsigned int *offsetp,
 	*spu_bin_dcookie = fast_get_dcookie(&vma->vm_file->f_path);
 	pr_debug("got dcookie for %pD\n", vma->vm_file);
 
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 
 out:
 	return app_cookie;
 
 fail_no_image_cookie:
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 
 	printk(KERN_ERR "SPU_PROF: "
 		"%s, line %d: Cannot find dcookie for SPU binary\n",
diff --git a/arch/powerpc/platforms/cell/spufs/file.c b/arch/powerpc/platforms/cell/spufs/file.c
index ae2f740a82f1..87d2bcf59f46 100644
--- a/arch/powerpc/platforms/cell/spufs/file.c
+++ b/arch/powerpc/platforms/cell/spufs/file.c
@@ -347,11 +347,11 @@ static int spufs_ps_fault(struct vm_fault *vmf,
 		goto refault;
 
 	if (ctx->state == SPU_STATE_SAVED) {
-		up_read(&current->mm->mmap_sem);
+		range_read_unlock(&current->mm->mmap_rw_tree, vmf->lockrange);
 		spu_context_nospu_trace(spufs_ps_fault__sleep, ctx);
 		ret = spufs_wait(ctx->run_wq, ctx->state == SPU_STATE_RUNNABLE);
 		spu_context_trace(spufs_ps_fault__wake, ctx, ctx->spu);
-		down_read(&current->mm->mmap_sem);
+		range_read_lock(&current->mm->mmap_rw_tree, vmf->lockrange);
 	} else {
 		area = ctx->spu->problem_phys + ps_offs;
 		vm_insert_pfn(vmf->vma, vmf->address, (area + offset) >> PAGE_SHIFT);
diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 226ca70dc6bd..f8093b7ce2c1 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -148,10 +148,12 @@ static int map_vdso(const struct vdso_image *image, unsigned long addr)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
+	struct range_rwlock range;
 	unsigned long text_start;
 	int ret = 0;
 
-	if (down_write_killable(&mm->mmap_sem))
+	range_rwlock_init_full(&range);
+	if (range_write_lock_interruptible(&mm->mmap_rw_tree, &range))
 		return -EINTR;
 
 	addr = get_unmapped_area(NULL, addr,
@@ -194,7 +196,7 @@ static int map_vdso(const struct vdso_image *image, unsigned long addr)
 	}
 
 up_fail:
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	return ret;
 }
 
@@ -255,8 +257,10 @@ int map_vdso_once(const struct vdso_image *image, unsigned long addr)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
+	struct range_rwlock range;
 
-	down_write(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&mm->mmap_rw_tree, &range);
 	/*
 	 * Check if we have already mapped vdso blob - fail to prevent
 	 * abusing from userspace install_speciall_mapping, which may
@@ -267,11 +271,11 @@ int map_vdso_once(const struct vdso_image *image, unsigned long addr)
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (vma_is_special_mapping(vma, &vdso_mapping) ||
 				vma_is_special_mapping(vma, &vvar_mapping)) {
-			up_write(&mm->mmap_sem);
+			range_write_unlock(&mm->mmap_rw_tree, &range);
 			return -EEXIST;
 		}
 	}
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 
 	return map_vdso(image, addr);
 }
diff --git a/arch/x86/kernel/tboot.c b/arch/x86/kernel/tboot.c
index b868fa1b812b..340364fa8b21 100644
--- a/arch/x86/kernel/tboot.c
+++ b/arch/x86/kernel/tboot.c
@@ -104,7 +104,7 @@ static struct mm_struct tboot_mm = {
 	.pgd            = swapper_pg_dir,
 	.mm_users       = ATOMIC_INIT(2),
 	.mm_count       = ATOMIC_INIT(1),
-	.mmap_sem       = __RWSEM_INITIALIZER(init_mm.mmap_sem),
+	.mmap_rw_tree   = __RANGE_RWLOCK_TREE_INITIALIZER(init_mm.mmap_rw_tree),
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
 	.mmlist         = LIST_HEAD_INIT(init_mm.mmlist),
 };
diff --git a/arch/x86/kernel/vm86_32.c b/arch/x86/kernel/vm86_32.c
index 23ee89ce59a9..541f4e5515e5 100644
--- a/arch/x86/kernel/vm86_32.c
+++ b/arch/x86/kernel/vm86_32.c
@@ -162,6 +162,7 @@ void save_v86_state(struct kernel_vm86_regs *regs, int retval)
 static void mark_screen_rdonly(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
+	struct range_rwlock range;
 	spinlock_t *ptl;
 	pgd_t *pgd;
 	pud_t *pud;
@@ -169,7 +170,8 @@ static void mark_screen_rdonly(struct mm_struct *mm)
 	pte_t *pte;
 	int i;
 
-	down_write(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&mm->mmap_rw_tree, &range);
 	pgd = pgd_offset(mm, 0xA0000);
 	if (pgd_none_or_clear_bad(pgd))
 		goto out;
@@ -192,7 +194,7 @@ static void mark_screen_rdonly(struct mm_struct *mm)
 	}
 	pte_unmap_unlock(pte, ptl);
 out:
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	flush_tlb();
 }
 
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index d81cd399544a..b7abcc782792 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -922,7 +922,8 @@ bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
 
 static void
 __bad_area(struct pt_regs *regs, unsigned long error_code,
-	   unsigned long address,  struct vm_area_struct *vma, int si_code)
+	   unsigned long address,  struct vm_area_struct *vma, int si_code,
+	   struct range_rwlock *range)
 {
 	struct mm_struct *mm = current->mm;
 
@@ -930,15 +931,16 @@ __bad_area(struct pt_regs *regs, unsigned long error_code,
 	 * Something tried to access memory that isn't in our memory map..
 	 * Fix it, but check if it's kernel or user first..
 	 */
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, range);
 
 	__bad_area_nosemaphore(regs, error_code, address, vma, si_code);
 }
 
 static noinline void
-bad_area(struct pt_regs *regs, unsigned long error_code, unsigned long address)
+bad_area(struct pt_regs *regs, unsigned long error_code, unsigned long address,
+	 struct range_rwlock *range)
 {
-	__bad_area(regs, error_code, address, NULL, SEGV_MAPERR);
+	__bad_area(regs, error_code, address, NULL, SEGV_MAPERR, range);
 }
 
 static inline bool bad_area_access_from_pkeys(unsigned long error_code,
@@ -960,7 +962,8 @@ static inline bool bad_area_access_from_pkeys(unsigned long error_code,
 
 static noinline void
 bad_area_access_error(struct pt_regs *regs, unsigned long error_code,
-		      unsigned long address, struct vm_area_struct *vma)
+		      unsigned long address, struct vm_area_struct *vma,
+		      struct range_rwlock *range)
 {
 	/*
 	 * This OSPKE check is not strictly necessary at runtime.
@@ -968,9 +971,9 @@ bad_area_access_error(struct pt_regs *regs, unsigned long error_code,
 	 * if pkeys are compiled out.
 	 */
 	if (bad_area_access_from_pkeys(error_code, vma))
-		__bad_area(regs, error_code, address, vma, SEGV_PKUERR);
+		__bad_area(regs, error_code, address, vma, SEGV_PKUERR, range);
 	else
-		__bad_area(regs, error_code, address, vma, SEGV_ACCERR);
+		__bad_area(regs, error_code, address, vma, SEGV_ACCERR, range);
 }
 
 static void
@@ -1218,6 +1221,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	struct vm_area_struct *vma;
 	struct task_struct *tsk;
 	struct mm_struct *mm;
+	struct range_rwlock range;
 	int fault, major = 0;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
@@ -1230,7 +1234,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	 */
 	if (kmemcheck_active(regs))
 		kmemcheck_hide(regs);
-	prefetchw(&mm->mmap_sem);
+	prefetchw(&mm->mmap_rw_tree);
 
 	if (unlikely(kmmio_fault(regs, address)))
 		return;
@@ -1333,14 +1337,15 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	 * validate the source. If this is invalid we can skip the address
 	 * space check, thus avoiding the deadlock:
 	 */
-	if (unlikely(!down_read_trylock(&mm->mmap_sem))) {
+	range_rwlock_init_full(&range);
+	if (unlikely(!range_read_trylock(&mm->mmap_rw_tree, &range))) {
 		if ((error_code & PF_USER) == 0 &&
 		    !search_exception_tables(regs->ip)) {
 			bad_area_nosemaphore(regs, error_code, address, NULL);
 			return;
 		}
 retry:
-		down_read(&mm->mmap_sem);
+		range_read_lock(&mm->mmap_rw_tree, &range);
 	} else {
 		/*
 		 * The above down_read_trylock() might have succeeded in
@@ -1352,13 +1357,13 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 
 	vma = find_vma(mm, address);
 	if (unlikely(!vma)) {
-		bad_area(regs, error_code, address);
+		bad_area(regs, error_code, address, &range);
 		return;
 	}
 	if (likely(vma->vm_start <= address))
 		goto good_area;
 	if (unlikely(!(vma->vm_flags & VM_GROWSDOWN))) {
-		bad_area(regs, error_code, address);
+		bad_area(regs, error_code, address, &range);
 		return;
 	}
 	if (error_code & PF_USER) {
@@ -1369,12 +1374,12 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		 * 32 pointers and then decrements %sp by 65535.)
 		 */
 		if (unlikely(address + 65536 + 32 * sizeof(unsigned long) < regs->sp)) {
-			bad_area(regs, error_code, address);
+			bad_area(regs, error_code, address, &range);
 			return;
 		}
 	}
 	if (unlikely(expand_stack(vma, address))) {
-		bad_area(regs, error_code, address);
+		bad_area(regs, error_code, address, &range);
 		return;
 	}
 
@@ -1384,7 +1389,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	 */
 good_area:
 	if (unlikely(access_error(error_code, vma))) {
-		bad_area_access_error(regs, error_code, address, vma);
+		bad_area_access_error(regs, error_code, address, vma, &range);
 		return;
 	}
 
@@ -1394,7 +1399,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	 * the fault.  Since we never set FAULT_FLAG_RETRY_NOWAIT, if
 	 * we get VM_FAULT_RETRY back, the mmap_sem has been unlocked.
 	 */
-	fault = handle_mm_fault(vma, address, flags, NULL);
+	fault = handle_mm_fault(vma, address, flags, &range);
 	major |= fault & VM_FAULT_MAJOR;
 
 	/*
@@ -1420,7 +1425,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		return;
 	}
 
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		mm_fault_error(regs, error_code, address, vma, fault);
 		return;
diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index 864a47193b6c..65c032d23c5b 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -44,16 +44,18 @@ static inline unsigned long mpx_bt_size_bytes(struct mm_struct *mm)
 static unsigned long mpx_mmap(unsigned long len)
 {
 	struct mm_struct *mm = current->mm;
+	struct range_rwlock range;
 	unsigned long addr, populate;
 
 	/* Only bounds table can be allocated here */
 	if (len != mpx_bt_size_bytes(mm))
 		return -EINVAL;
 
-	down_write(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&mm->mmap_rw_tree, &range);
 	addr = do_mmap(NULL, 0, len, PROT_READ | PROT_WRITE,
 		       MAP_ANONYMOUS | MAP_PRIVATE, VM_MPX, 0, &populate, NULL);
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	if (populate)
 		mm_populate(addr, populate);
 
@@ -340,6 +342,7 @@ int mpx_enable_management(void)
 {
 	void __user *bd_base = MPX_INVALID_BOUNDS_DIR;
 	struct mm_struct *mm = current->mm;
+	struct range_rwlock range;
 	int ret = 0;
 
 	/*
@@ -354,25 +357,28 @@ int mpx_enable_management(void)
 	 * unmap path; we can just use mm->context.bd_addr instead.
 	 */
 	bd_base = mpx_get_bounds_dir();
-	down_write(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&mm->mmap_rw_tree, &range);
 	mm->context.bd_addr = bd_base;
 	if (mm->context.bd_addr == MPX_INVALID_BOUNDS_DIR)
 		ret = -ENXIO;
 
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	return ret;
 }
 
 int mpx_disable_management(void)
 {
 	struct mm_struct *mm = current->mm;
+	struct range_rwlock range;
 
 	if (!cpu_feature_enabled(X86_FEATURE_MPX))
 		return -ENXIO;
 
-	down_write(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&mm->mmap_rw_tree, &range);
 	mm->context.bd_addr = MPX_INVALID_BOUNDS_DIR;
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	return 0;
 }
 
diff --git a/drivers/android/binder.c b/drivers/android/binder.c
index aae4d8d4be36..425d70d49ef6 100644
--- a/drivers/android/binder.c
+++ b/drivers/android/binder.c
@@ -581,6 +581,7 @@ static int binder_update_page_range(struct binder_proc *proc, int allocate,
 	unsigned long user_page_addr;
 	struct page **page;
 	struct mm_struct *mm;
+	struct range_rwlock range;
 
 	binder_debug(BINDER_DEBUG_BUFFER_ALLOC,
 		     "%d: %s pages %p-%p\n", proc->pid,
@@ -597,7 +598,8 @@ static int binder_update_page_range(struct binder_proc *proc, int allocate,
 		mm = get_task_mm(proc->tsk);
 
 	if (mm) {
-		down_write(&mm->mmap_sem);
+		range_rwlock_init_full(&range);
+		range_write_lock(&mm->mmap_rw_tree, &range);
 		vma = proc->vma;
 		if (vma && mm != proc->vma_vm_mm) {
 			pr_err("%d: vma mm and task mm mismatch\n",
@@ -647,7 +649,7 @@ static int binder_update_page_range(struct binder_proc *proc, int allocate,
 		/* vm_insert_page does not seem to increment the refcount */
 	}
 	if (mm) {
-		up_write(&mm->mmap_sem);
+		range_write_unlock(&mm->mmap_rw_tree, &range);
 		mmput(mm);
 	}
 	return 0;
@@ -669,7 +671,7 @@ static int binder_update_page_range(struct binder_proc *proc, int allocate,
 	}
 err_no_vma:
 	if (mm) {
-		up_write(&mm->mmap_sem);
+		range_write_unlock(&mm->mmap_rw_tree, &range);
 		mmput(mm);
 	}
 	return -ENOMEM;
diff --git a/drivers/firmware/efi/arm-runtime.c b/drivers/firmware/efi/arm-runtime.c
index 974c5a31a005..e36999eeea95 100644
--- a/drivers/firmware/efi/arm-runtime.c
+++ b/drivers/firmware/efi/arm-runtime.c
@@ -34,7 +34,7 @@ static struct mm_struct efi_mm = {
 	.mm_rb			= RB_ROOT,
 	.mm_users		= ATOMIC_INIT(2),
 	.mm_count		= ATOMIC_INIT(1),
-	.mmap_sem		= __RWSEM_INITIALIZER(efi_mm.mmap_sem),
+	.mmap_rw_tree		= __RANGE_RWLOCK_TREE_INITIALIZER(efi_mm.mmap_rw_tree),
 	.page_table_lock	= __SPIN_LOCK_UNLOCKED(efi_mm.page_table_lock),
 	.mmlist			= LIST_HEAD_INIT(efi_mm.mmlist),
 };
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c
index 99424cb8020b..c6dd32bb7f4d 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c
@@ -509,6 +509,7 @@ static int amdgpu_cs_parser_bos(struct amdgpu_cs_parser *p,
 	struct amdgpu_fpriv *fpriv = p->filp->driver_priv;
 	struct amdgpu_bo_list_entry *e;
 	struct list_head duplicates;
+	struct range_rwlock range;
 	bool need_mmap_lock = false;
 	unsigned i, tries = 10;
 	int r;
@@ -528,8 +529,10 @@ static int amdgpu_cs_parser_bos(struct amdgpu_cs_parser *p,
 	if (p->uf_entry.robj)
 		list_add(&p->uf_entry.tv.head, &p->validated);
 
-	if (need_mmap_lock)
-		down_read(&current->mm->mmap_sem);
+	if (need_mmap_lock) {
+		range_rwlock_init_full(&range);
+		range_read_lock(&current->mm->mmap_rw_tree, &range);
+	}
 
 	while (1) {
 		struct list_head need_pages;
@@ -686,7 +689,7 @@ static int amdgpu_cs_parser_bos(struct amdgpu_cs_parser *p,
 error_free_pages:
 
 	if (need_mmap_lock)
-		up_read(&current->mm->mmap_sem);
+		range_read_unlock(&current->mm->mmap_rw_tree, &range);
 
 	if (p->bo_list) {
 		for (i = p->bo_list->first_userptr;
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
index 106cf83c2e6b..20af4a036de5 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
@@ -269,6 +269,7 @@ int amdgpu_gem_userptr_ioctl(struct drm_device *dev, void *data,
 	struct drm_amdgpu_gem_userptr *args = data;
 	struct drm_gem_object *gobj;
 	struct amdgpu_bo *bo;
+	struct range_rwlock range;
 	uint32_t handle;
 	int r;
 
@@ -309,7 +310,8 @@ int amdgpu_gem_userptr_ioctl(struct drm_device *dev, void *data,
 	}
 
 	if (args->flags & AMDGPU_GEM_USERPTR_VALIDATE) {
-		down_read(&current->mm->mmap_sem);
+		range_rwlock_init_full(&range);
+		range_read_lock(&current->mm->mmap_rw_tree, &range);
 
 		r = amdgpu_ttm_tt_get_user_pages(bo->tbo.ttm,
 						 bo->tbo.ttm->pages);
@@ -326,7 +328,7 @@ int amdgpu_gem_userptr_ioctl(struct drm_device *dev, void *data,
 		if (r)
 			goto free_pages;
 
-		up_read(&current->mm->mmap_sem);
+		range_read_unlock(&current->mm->mmap_rw_tree, &range);
 	}
 
 	r = drm_gem_handle_create(filp, gobj, &handle);
@@ -342,7 +344,7 @@ int amdgpu_gem_userptr_ioctl(struct drm_device *dev, void *data,
 	release_pages(bo->tbo.ttm->pages, bo->tbo.ttm->num_pages, false);
 
 unlock_mmap_sem:
-	up_read(&current->mm->mmap_sem);
+	range_read_unlock(&current->mm->mmap_rw_tree, &range);
 
 release_object:
 	drm_gem_object_unreference_unlocked(gobj);
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
index 7ea3cacf9f9f..dd6d1a620655 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
@@ -229,10 +229,12 @@ static struct amdgpu_mn *amdgpu_mn_get(struct amdgpu_device *adev)
 {
 	struct mm_struct *mm = current->mm;
 	struct amdgpu_mn *rmn;
+	struct range_rwlock range;
 	int r;
 
+	range_rwlock_init_full(&range);
 	mutex_lock(&adev->mn_lock);
-	if (down_write_killable(&mm->mmap_sem)) {
+	if (range_write_lock_interruptible(&mm->mmap_rw_tree, &range)) {
 		mutex_unlock(&adev->mn_lock);
 		return ERR_PTR(-EINTR);
 	}
@@ -260,13 +262,13 @@ static struct amdgpu_mn *amdgpu_mn_get(struct amdgpu_device *adev)
 	hash_add(adev->mn_hash, &rmn->node, (unsigned long)mm);
 
 release_locks:
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	mutex_unlock(&adev->mn_lock);
 
 	return rmn;
 
 free_rmn:
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	mutex_unlock(&adev->mn_lock);
 	kfree(rmn);
 
diff --git a/drivers/gpu/drm/amd/amdkfd/kfd_events.c b/drivers/gpu/drm/amd/amdkfd/kfd_events.c
index d1ce83d73a87..1dad7d24e706 100644
--- a/drivers/gpu/drm/amd/amdkfd/kfd_events.c
+++ b/drivers/gpu/drm/amd/amdkfd/kfd_events.c
@@ -897,6 +897,7 @@ void kfd_signal_iommu_event(struct kfd_dev *dev, unsigned int pasid,
 {
 	struct kfd_hsa_memory_exception_data memory_exception_data;
 	struct vm_area_struct *vma;
+	struct range_rwlock range;
 
 	/*
 	 * Because we are called from arbitrary context (workqueue) as opposed
@@ -910,7 +911,8 @@ void kfd_signal_iommu_event(struct kfd_dev *dev, unsigned int pasid,
 
 	memset(&memory_exception_data, 0, sizeof(memory_exception_data));
 
-	down_read(&p->mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&p->mm->mmap_rw_tree, &range);
 	vma = find_vma(p->mm, address);
 
 	memory_exception_data.gpu_id = dev->id;
@@ -937,7 +939,7 @@ void kfd_signal_iommu_event(struct kfd_dev *dev, unsigned int pasid,
 		}
 	}
 
-	up_read(&p->mm->mmap_sem);
+	range_read_unlock(&p->mm->mmap_rw_tree, &range);
 
 	mutex_lock(&p->event_mutex);
 
diff --git a/drivers/gpu/drm/amd/amdkfd/kfd_process.c b/drivers/gpu/drm/amd/amdkfd/kfd_process.c
index 84d1ffd1eef9..d43b57417041 100644
--- a/drivers/gpu/drm/amd/amdkfd/kfd_process.c
+++ b/drivers/gpu/drm/amd/amdkfd/kfd_process.c
@@ -78,6 +78,7 @@ void kfd_process_destroy_wq(void)
 struct kfd_process *kfd_create_process(const struct task_struct *thread)
 {
 	struct kfd_process *process;
+	struct range_rwlock range;
 
 	BUG_ON(!kfd_process_wq);
 
@@ -89,7 +90,8 @@ struct kfd_process *kfd_create_process(const struct task_struct *thread)
 		return ERR_PTR(-EINVAL);
 
 	/* Take mmap_sem because we call __mmu_notifier_register inside */
-	down_write(&thread->mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&thread->mm->mmap_rw_tree, &range);
 
 	/*
 	 * take kfd processes mutex before starting of process creation
@@ -108,7 +110,7 @@ struct kfd_process *kfd_create_process(const struct task_struct *thread)
 
 	mutex_unlock(&kfd_processes_mutex);
 
-	up_write(&thread->mm->mmap_sem);
+	range_write_unlock(&thread->mm->mmap_rw_tree, &range);
 
 	return process;
 }
diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gem.c b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
index 75ca18aaa34e..20d7de5b9eb7 100644
--- a/drivers/gpu/drm/etnaviv/etnaviv_gem.c
+++ b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
@@ -745,6 +745,7 @@ static struct page **etnaviv_gem_userptr_do_get_pages(
 {
 	int ret = 0, pinned, npages = etnaviv_obj->base.size >> PAGE_SHIFT;
 	struct page **pvec;
+	struct range_rwlock range;
 	uintptr_t ptr;
 	unsigned int flags = 0;
 
@@ -758,7 +759,8 @@ static struct page **etnaviv_gem_userptr_do_get_pages(
 	pinned = 0;
 	ptr = etnaviv_obj->userptr.ptr;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	while (pinned < npages) {
 		ret = get_user_pages_remote(task, mm, ptr, npages - pinned,
 					    flags, pvec + pinned, NULL, NULL,
@@ -769,7 +771,7 @@ static struct page **etnaviv_gem_userptr_do_get_pages(
 		ptr += ret * PAGE_SIZE;
 		pinned += ret;
 	}
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 
 	if (ret < 0) {
 		release_pages(pvec, pinned, 0);
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index fe531f904062..33a9c9c1ae9a 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -1673,8 +1673,10 @@ i915_gem_mmap_ioctl(struct drm_device *dev, void *data,
 	if (args->flags & I915_MMAP_WC) {
 		struct mm_struct *mm = current->mm;
 		struct vm_area_struct *vma;
+		struct range_rwlock range;
 
-		if (down_write_killable(&mm->mmap_sem)) {
+		range_rwlock_init_full(&range);
+		if (range_write_lock_interruptible(&mm->mmap_rw_tree, &range)) {
 			i915_gem_object_put(obj);
 			return -EINTR;
 		}
@@ -1684,7 +1686,7 @@ i915_gem_mmap_ioctl(struct drm_device *dev, void *data,
 				pgprot_writecombine(vm_get_page_prot(vma->vm_flags));
 		else
 			addr = -ENOMEM;
-		up_write(&mm->mmap_sem);
+		range_write_unlock(&mm->mmap_rw_tree, &range);
 
 		/* This may race, but that's ok, it only gets set */
 		WRITE_ONCE(obj->frontbuffer_ggtt_origin, ORIGIN_CPU);
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 1f8e8eecb6df..b2a676450aa5 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -203,12 +203,14 @@ static struct i915_mmu_notifier *
 i915_mmu_notifier_find(struct i915_mm_struct *mm)
 {
 	struct i915_mmu_notifier *mn = mm->mn;
+	struct range_rwlock range;
 
 	mn = mm->mn;
 	if (mn)
 		return mn;
 
-	down_write(&mm->mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&mm->mm->mmap_rw_tree, &range);
 	mutex_lock(&mm->i915->mm_lock);
 	if ((mn = mm->mn) == NULL) {
 		mn = i915_mmu_notifier_create(mm->mm);
@@ -216,7 +218,7 @@ i915_mmu_notifier_find(struct i915_mm_struct *mm)
 			mm->mn = mn;
 	}
 	mutex_unlock(&mm->i915->mm_lock);
-	up_write(&mm->mm->mmap_sem);
+	range_write_unlock(&mm->mm->mmap_rw_tree, &range);
 
 	return mn;
 }
@@ -501,6 +503,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 
 	pvec = drm_malloc_gfp(npages, sizeof(struct page *), GFP_TEMPORARY);
 	if (pvec != NULL) {
+		struct range_rwlock range;
 		struct mm_struct *mm = obj->userptr.mm->mm;
 		unsigned int flags = 0;
 
@@ -509,7 +512,8 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 
 		ret = -EFAULT;
 		if (mmget_not_zero(mm)) {
-			down_read(&mm->mmap_sem);
+			range_rwlock_init_full(&range);
+			range_read_lock(&mm->mmap_rw_tree, &range);
 			while (pinned < npages) {
 				ret = get_user_pages_remote
 					(work->task, mm,
@@ -522,7 +526,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 
 				pinned += ret;
 			}
-			up_read(&mm->mmap_sem);
+			range_read_unlock(&mm->mmap_rw_tree, &range);
 			mmput(mm);
 		}
 	}
diff --git a/drivers/gpu/drm/radeon/radeon_cs.c b/drivers/gpu/drm/radeon/radeon_cs.c
index a8442f7196d6..b5b02f6a81b4 100644
--- a/drivers/gpu/drm/radeon/radeon_cs.c
+++ b/drivers/gpu/drm/radeon/radeon_cs.c
@@ -76,6 +76,7 @@ static int radeon_cs_parser_relocs(struct radeon_cs_parser *p)
 {
 	struct radeon_cs_chunk *chunk;
 	struct radeon_cs_buckets buckets;
+	struct range_rwlock range;
 	unsigned i;
 	bool need_mmap_lock = false;
 	int r;
@@ -176,13 +177,15 @@ static int radeon_cs_parser_relocs(struct radeon_cs_parser *p)
 	if (p->cs_flags & RADEON_CS_USE_VM)
 		p->vm_bos = radeon_vm_get_bos(p->rdev, p->ib.vm,
 					      &p->validated);
-	if (need_mmap_lock)
-		down_read(&current->mm->mmap_sem);
+	if (need_mmap_lock) {
+		range_rwlock_init_full(&range);
+		range_read_lock(&current->mm->mmap_rw_tree, &range);
+	}
 
 	r = radeon_bo_list_validate(p->rdev, &p->ticket, &p->validated, p->ring);
 
 	if (need_mmap_lock)
-		up_read(&current->mm->mmap_sem);
+		range_read_unlock(&current->mm->mmap_rw_tree, &range);
 
 	return r;
 }
diff --git a/drivers/gpu/drm/radeon/radeon_gem.c b/drivers/gpu/drm/radeon/radeon_gem.c
index 96683f5b2b1b..0c21cb398ff8 100644
--- a/drivers/gpu/drm/radeon/radeon_gem.c
+++ b/drivers/gpu/drm/radeon/radeon_gem.c
@@ -285,6 +285,7 @@ int radeon_gem_userptr_ioctl(struct drm_device *dev, void *data,
 	struct drm_radeon_gem_userptr *args = data;
 	struct drm_gem_object *gobj;
 	struct radeon_bo *bo;
+	struct range_rwlock range;
 	uint32_t handle;
 	int r;
 
@@ -331,17 +332,18 @@ int radeon_gem_userptr_ioctl(struct drm_device *dev, void *data,
 	}
 
 	if (args->flags & RADEON_GEM_USERPTR_VALIDATE) {
-		down_read(&current->mm->mmap_sem);
+		range_rwlock_init_full(&range);
+		range_read_lock(&current->mm->mmap_rw_tree, &range);
 		r = radeon_bo_reserve(bo, true);
 		if (r) {
-			up_read(&current->mm->mmap_sem);
+			range_read_unlock(&current->mm->mmap_rw_tree, &range);
 			goto release_object;
 		}
 
 		radeon_ttm_placement_from_domain(bo, RADEON_GEM_DOMAIN_GTT);
 		r = ttm_bo_validate(&bo->tbo, &bo->placement, true, false);
 		radeon_bo_unreserve(bo);
-		up_read(&current->mm->mmap_sem);
+		range_read_unlock(&current->mm->mmap_rw_tree, &range);
 		if (r)
 			goto release_object;
 	}
diff --git a/drivers/gpu/drm/radeon/radeon_mn.c b/drivers/gpu/drm/radeon/radeon_mn.c
index 896f2cf51e4e..d2f600325511 100644
--- a/drivers/gpu/drm/radeon/radeon_mn.c
+++ b/drivers/gpu/drm/radeon/radeon_mn.c
@@ -184,9 +184,11 @@ static struct radeon_mn *radeon_mn_get(struct radeon_device *rdev)
 {
 	struct mm_struct *mm = current->mm;
 	struct radeon_mn *rmn;
+	struct range_rwlock range;
 	int r;
 
-	if (down_write_killable(&mm->mmap_sem))
+	range_rwlock_init_full(&range);
+	if (range_write_lock_interruptible(&mm->mmap_rw_tree, &range))
 		return ERR_PTR(-EINTR);
 
 	mutex_lock(&rdev->mn_lock);
@@ -215,13 +217,13 @@ static struct radeon_mn *radeon_mn_get(struct radeon_device *rdev)
 
 release_locks:
 	mutex_unlock(&rdev->mn_lock);
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 
 	return rmn;
 
 free_rmn:
 	mutex_unlock(&rdev->mn_lock);
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	kfree(rmn);
 
 	return ERR_PTR(r);
diff --git a/drivers/gpu/drm/ttm/ttm_bo_vm.c b/drivers/gpu/drm/ttm/ttm_bo_vm.c
index 35ffb3754feb..4690ab0eae75 100644
--- a/drivers/gpu/drm/ttm/ttm_bo_vm.c
+++ b/drivers/gpu/drm/ttm/ttm_bo_vm.c
@@ -66,7 +66,8 @@ static int ttm_bo_vm_fault_idle(struct ttm_buffer_object *bo,
 			goto out_unlock;
 
 		ttm_bo_reference(bo);
-		up_read(&vmf->vma->vm_mm->mmap_sem);
+		range_read_unlock(&vmf->vma->vm_mm->mmap_rw_tree,
+				  vmf->lockrange);
 		(void) dma_fence_wait(bo->moving, true);
 		ttm_bo_unreserve(bo);
 		ttm_bo_unref(&bo);
@@ -124,7 +125,8 @@ static int ttm_bo_vm_fault(struct vm_fault *vmf)
 		if (vmf->flags & FAULT_FLAG_ALLOW_RETRY) {
 			if (!(vmf->flags & FAULT_FLAG_RETRY_NOWAIT)) {
 				ttm_bo_reference(bo);
-				up_read(&vmf->vma->vm_mm->mmap_sem);
+				range_read_unlock(&vmf->vma->vm_mm->mmap_rw_tree,
+						  vmf->lockrange);
 				(void) ttm_bo_wait_unreserved(bo);
 				ttm_bo_unref(&bo);
 			}
diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
index 1a3ad769f8c8..88d05d6a6eaf 100644
--- a/drivers/gpu/drm/via/via_dmablit.c
+++ b/drivers/gpu/drm/via/via_dmablit.c
@@ -230,6 +230,7 @@ via_fire_dmablit(struct drm_device *dev, drm_via_sg_info_t *vsg, int engine)
 static int
 via_lock_all_dma_pages(drm_via_sg_info_t *vsg,  drm_via_dmablit_t *xfer)
 {
+	struct range_rwlock range;
 	int ret;
 	unsigned long first_pfn = VIA_PFN(xfer->mem_addr);
 	vsg->num_pages = VIA_PFN(xfer->mem_addr + (xfer->num_lines * xfer->mem_stride - 1)) -
@@ -238,13 +239,14 @@ via_lock_all_dma_pages(drm_via_sg_info_t *vsg,  drm_via_dmablit_t *xfer)
 	vsg->pages = vzalloc(sizeof(struct page *) * vsg->num_pages);
 	if (NULL == vsg->pages)
 		return -ENOMEM;
-	down_read(&current->mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&current->mm->mmap_rw_tree, &range);
 	ret = get_user_pages((unsigned long)xfer->mem_addr,
 			     vsg->num_pages,
 			     (vsg->direction == DMA_FROM_DEVICE) ? FOLL_WRITE : 0,
 			     vsg->pages, NULL);
 
-	up_read(&current->mm->mmap_sem);
+	range_read_unlock(&current->mm->mmap_rw_tree, &range);
 	if (ret != vsg->num_pages) {
 		if (ret < 0)
 			return ret;
diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index 0fe3bfb6839d..b88addd18858 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -86,6 +86,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 	struct ib_umem *umem;
 	struct page **page_list;
 	struct vm_area_struct **vma_list;
+	struct range_rwlock range;
 	unsigned long locked;
 	unsigned long lock_limit;
 	unsigned long cur_base;
@@ -163,7 +164,8 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 
 	npages = ib_umem_num_pages(umem);
 
-	down_write(&current->mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&current->mm->mmap_rw_tree, &range);
 
 	locked     = npages + current->mm->pinned_vm;
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
@@ -236,7 +238,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 	} else
 		current->mm->pinned_vm = locked;
 
-	up_write(&current->mm->mmap_sem);
+	range_write_unlock(&current->mm->mmap_rw_tree, &range);
 	if (vma_list)
 		free_page((unsigned long) vma_list);
 	free_page((unsigned long) page_list);
@@ -248,10 +250,12 @@ EXPORT_SYMBOL(ib_umem_get);
 static void ib_umem_account(struct work_struct *work)
 {
 	struct ib_umem *umem = container_of(work, struct ib_umem, work);
+	struct range_rwlock range;
 
-	down_write(&umem->mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&umem->mm->mmap_rw_tree, &range);
 	umem->mm->pinned_vm -= umem->diff;
-	up_write(&umem->mm->mmap_sem);
+	range_write_unlock(&umem->mm->mmap_rw_tree, &range);
 	mmput(umem->mm);
 	kfree(umem);
 }
@@ -265,6 +269,7 @@ void ib_umem_release(struct ib_umem *umem)
 	struct ib_ucontext *context = umem->context;
 	struct mm_struct *mm;
 	struct task_struct *task;
+	struct range_rwlock range;
 	unsigned long diff;
 
 	if (umem->odp_data) {
@@ -293,8 +298,9 @@ void ib_umem_release(struct ib_umem *umem)
 	 * up here and not be able to take the mmap_sem.  In that case
 	 * we defer the vm_locked accounting to the system workqueue.
 	 */
+	range_rwlock_init_full(&range);
 	if (context->closing) {
-		if (!down_write_trylock(&mm->mmap_sem)) {
+		if (!range_write_trylock(&mm->mmap_rw_tree, &range)) {
 			INIT_WORK(&umem->work, ib_umem_account);
 			umem->mm   = mm;
 			umem->diff = diff;
@@ -303,10 +309,10 @@ void ib_umem_release(struct ib_umem *umem)
 			return;
 		}
 	} else
-		down_write(&mm->mmap_sem);
+		range_write_lock(&mm->mmap_rw_tree, &range);
 
 	mm->pinned_vm -= diff;
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	mmput(mm);
 out:
 	kfree(umem);
diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index 0ac3c739a986..590ad2d3ab35 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -595,6 +595,7 @@ int ib_umem_odp_map_dma_pages(struct ib_umem *umem, u64 user_virt, u64 bcnt,
 	struct task_struct *owning_process  = NULL;
 	struct mm_struct   *owning_mm       = NULL;
 	struct page       **local_page_list = NULL;
+	struct range_rwlock range;
 	u64 off;
 	int j, k, ret = 0, start_idx, npages = 0;
 	u64 base_virt_addr;
@@ -639,7 +640,8 @@ int ib_umem_odp_map_dma_pages(struct ib_umem *umem, u64 user_virt, u64 bcnt,
 			min_t(size_t, ALIGN(bcnt, PAGE_SIZE) / PAGE_SIZE,
 			      PAGE_SIZE / sizeof(struct page *));
 
-		down_read(&owning_mm->mmap_sem);
+		range_rwlock_init_full(&range);
+		range_read_lock(&owning_mm->mmap_rw_tree, &range);
 		/*
 		 * Note: this might result in redundent page getting. We can
 		 * avoid this by checking dma_list to be 0 before calling
@@ -650,7 +652,7 @@ int ib_umem_odp_map_dma_pages(struct ib_umem *umem, u64 user_virt, u64 bcnt,
 		npages = get_user_pages_remote(owning_process, owning_mm,
 				user_virt, gup_num_pages,
 				flags, local_page_list, NULL, NULL, NULL);
-		up_read(&owning_mm->mmap_sem);
+		range_read_unlock(&owning_mm->mmap_rw_tree, &range);
 
 		if (npages < 0)
 			break;
diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
index 68295a12b771..86fe4147f991 100644
--- a/drivers/infiniband/hw/hfi1/user_pages.c
+++ b/drivers/infiniband/hw/hfi1/user_pages.c
@@ -71,6 +71,7 @@ MODULE_PARM_DESC(cache_size, "Send and receive side cache size limit (in MB)");
 bool hfi1_can_pin_pages(struct hfi1_devdata *dd, struct mm_struct *mm,
 			u32 nlocked, u32 npages)
 {
+	struct range_rwlock range;
 	unsigned long ulimit = rlimit(RLIMIT_MEMLOCK), pinned, cache_limit,
 		size = (cache_size * (1UL << 20)); /* convert to bytes */
 	unsigned usr_ctxts = dd->num_rcv_contexts - dd->first_user_ctxt;
@@ -90,9 +91,10 @@ bool hfi1_can_pin_pages(struct hfi1_devdata *dd, struct mm_struct *mm,
 	/* Convert to number of pages */
 	size = DIV_ROUND_UP(size, PAGE_SIZE);
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	pinned = mm->pinned_vm;
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 
 	/* First, check the absolute limit against all pinned pages. */
 	if (pinned + npages >= ulimit && !can_lock)
@@ -104,15 +106,17 @@ bool hfi1_can_pin_pages(struct hfi1_devdata *dd, struct mm_struct *mm,
 int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t npages,
 			    bool writable, struct page **pages)
 {
+	struct range_rwlock range;
 	int ret;
 
 	ret = get_user_pages_fast(vaddr, npages, writable, pages);
 	if (ret < 0)
 		return ret;
 
-	down_write(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&mm->mmap_rw_tree, &range);
 	mm->pinned_vm += ret;
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 
 	return ret;
 }
@@ -120,6 +124,7 @@ int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t np
 void hfi1_release_user_pages(struct mm_struct *mm, struct page **p,
 			     size_t npages, bool dirty)
 {
+	struct range_rwlock range;
 	size_t i;
 
 	for (i = 0; i < npages; i++) {
@@ -129,8 +134,9 @@ void hfi1_release_user_pages(struct mm_struct *mm, struct page **p,
 	}
 
 	if (mm) { /* during close after signal, mm can be NULL */
-		down_write(&mm->mmap_sem);
+		range_rwlock_init_full(&range);
+		range_write_lock(&mm->mmap_rw_tree, &range);
 		mm->pinned_vm -= npages;
-		up_write(&mm->mmap_sem);
+		range_write_unlock(&mm->mmap_rw_tree, &range);
 	}
 }
diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index fba94df28cf1..a540f45add11 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1142,6 +1142,7 @@ static void mlx4_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 	struct mlx4_ib_ucontext *context = to_mucontext(ibcontext);
 	struct task_struct *owning_process  = NULL;
 	struct mm_struct   *owning_mm       = NULL;
+	struct range_rwlock range;
 
 	owning_process = get_pid_task(ibcontext->tgid, PIDTYPE_PID);
 	if (!owning_process)
@@ -1173,7 +1174,8 @@ static void mlx4_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 	/* need to protect from a race on closing the vma as part of
 	 * mlx4_ib_vma_close().
 	 */
-	down_read(&owning_mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&owning_mm->mmap_rw_tree, &range);
 	for (i = 0; i < HW_BAR_COUNT; i++) {
 		vma = context->hw_bar_info[i].vma;
 		if (!vma)
@@ -1191,7 +1193,7 @@ static void mlx4_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 		context->hw_bar_info[i].vma->vm_ops = NULL;
 	}
 
-	up_read(&owning_mm->mmap_sem);
+	range_read_unlock(&owning_mm->mmap_rw_tree, &range);
 	mmput(owning_mm);
 	put_task_struct(owning_process);
 }
diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 4dc0a8785fe0..215935c6ae4e 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1449,6 +1449,7 @@ static void mlx5_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 	struct mlx5_ib_ucontext *context = to_mucontext(ibcontext);
 	struct task_struct *owning_process  = NULL;
 	struct mm_struct   *owning_mm       = NULL;
+	struct range_rwlock range;
 
 	owning_process = get_pid_task(ibcontext->tgid, PIDTYPE_PID);
 	if (!owning_process)
@@ -1478,7 +1479,8 @@ static void mlx5_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 	/* need to protect from a race on closing the vma as part of
 	 * mlx5_ib_vma_close.
 	 */
-	down_read(&owning_mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&owning_mm->mmap_rw_tree, &range);
 	list_for_each_entry_safe(vma_private, n, &context->vma_private_list,
 				 list) {
 		vma = vma_private->vma;
@@ -1492,7 +1494,7 @@ static void mlx5_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 		list_del(&vma_private->list);
 		kfree(vma_private);
 	}
-	up_read(&owning_mm->mmap_sem);
+	range_read_unlock(&owning_mm->mmap_rw_tree, &range);
 	mmput(owning_mm);
 	put_task_struct(owning_process);
 }
diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
index c1cf13f2722a..4b15be6f22b8 100644
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -133,26 +133,32 @@ dma_addr_t qib_map_page(struct pci_dev *hwdev, struct page *page,
 int qib_get_user_pages(unsigned long start_page, size_t num_pages,
 		       struct page **p)
 {
+	struct range_rwlock range;
 	int ret;
 
-	down_write(&current->mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&current->mm->mmap_rw_tree, &range);
 
 	ret = __qib_get_user_pages(start_page, num_pages, p);
 
-	up_write(&current->mm->mmap_sem);
+	range_write_unlock(&current->mm->mmap_rw_tree, &range);
 
 	return ret;
 }
 
 void qib_release_user_pages(struct page **p, size_t num_pages)
 {
-	if (current->mm) /* during close after signal, mm can be NULL */
-		down_write(&current->mm->mmap_sem);
+	struct range_rwlock range;
+
+	if (current->mm) { /* during close after signal, mm can be NULL */
+		range_rwlock_init_full(&range);
+		range_write_lock(&current->mm->mmap_rw_tree, &range);
+	}
 
 	__qib_release_user_pages(p, num_pages, 1);
 
 	if (current->mm) {
 		current->mm->pinned_vm -= num_pages;
-		up_write(&current->mm->mmap_sem);
+		range_write_unlock(&current->mm->mmap_rw_tree, &range);
 	}
 }
diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniband/hw/usnic/usnic_uiom.c
index 1591d0e78bfa..c99f032d490b 100644
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
@@ -55,12 +55,14 @@ static struct workqueue_struct *usnic_uiom_wq;
 
 static void usnic_uiom_reg_account(struct work_struct *work)
 {
+	struct range_rwlock range;
 	struct usnic_uiom_reg *umem = container_of(work,
 						struct usnic_uiom_reg, work);
 
-	down_write(&umem->mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&umem->mm->mmap_rw_tree, &range);
 	umem->mm->locked_vm -= umem->diff;
-	up_write(&umem->mm->mmap_sem);
+	range_write_unlock(&umem->mm->mmap_rw_tree, &range);
 	mmput(umem->mm);
 	kfree(umem);
 }
@@ -103,6 +105,7 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 	struct page **page_list;
 	struct scatterlist *sg;
 	struct usnic_uiom_chunk *chunk;
+	struct range_rwlock range;
 	unsigned long locked;
 	unsigned long lock_limit;
 	unsigned long cur_base;
@@ -125,7 +128,8 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 
 	npages = PAGE_ALIGN(size + (addr & ~PAGE_MASK)) >> PAGE_SHIFT;
 
-	down_write(&current->mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&current->mm->mmap_rw_tree, &range);
 
 	locked = npages + current->mm->locked_vm;
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
@@ -188,7 +192,7 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 	else
 		current->mm->locked_vm = locked;
 
-	up_write(&current->mm->mmap_sem);
+	range_write_unlock(&current->mm->mmap_rw_tree, &range);
 	free_page((unsigned long) page_list);
 	return ret;
 }
@@ -423,6 +427,7 @@ struct usnic_uiom_reg *usnic_uiom_reg_get(struct usnic_uiom_pd *pd,
 void usnic_uiom_reg_release(struct usnic_uiom_reg *uiomr, int closing)
 {
 	struct mm_struct *mm;
+	struct range_rwlock range;
 	unsigned long diff;
 
 	__usnic_uiom_reg_release(uiomr->pd, uiomr, 1);
@@ -443,8 +448,9 @@ void usnic_uiom_reg_release(struct usnic_uiom_reg *uiomr, int closing)
 	 * up here and not be able to take the mmap_sem.  In that case
 	 * we defer the vm_locked accounting to the system workqueue.
 	 */
+	range_rwlock_init_full(&range);
 	if (closing) {
-		if (!down_write_trylock(&mm->mmap_sem)) {
+		if (!range_write_trylock(&mm->mmap_rw_tree, &range)) {
 			INIT_WORK(&uiomr->work, usnic_uiom_reg_account);
 			uiomr->mm = mm;
 			uiomr->diff = diff;
@@ -453,10 +459,10 @@ void usnic_uiom_reg_release(struct usnic_uiom_reg *uiomr, int closing)
 			return;
 		}
 	} else
-		down_write(&mm->mmap_sem);
+		range_write_lock(&mm->mmap_rw_tree, &range);
 
 	current->mm->locked_vm -= diff;
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	mmput(mm);
 	kfree(uiomr);
 }
diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
index 063343909b0d..e2a8e154adeb 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -518,6 +518,7 @@ static void do_fault(struct work_struct *work)
 	int ret = VM_FAULT_ERROR;
 	unsigned int flags = 0;
 	struct mm_struct *mm;
+	struct range_rwlock range;
 	u64 address;
 
 	mm = fault->state->mm;
@@ -529,7 +530,8 @@ static void do_fault(struct work_struct *work)
 		flags |= FAULT_FLAG_WRITE;
 	flags |= FAULT_FLAG_REMOTE;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	vma = find_extend_vma(mm, address);
 	if (!vma || address < vma->vm_start)
 		/* failed to get a vma in the right range */
@@ -539,9 +541,9 @@ static void do_fault(struct work_struct *work)
 	if (access_error(vma, fault))
 		goto out;
 
-	ret = handle_mm_fault(vma, address, flags);
+	ret = handle_mm_fault(vma, address, flags, NULL);
 out:
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 
 	if (ret & VM_FAULT_ERROR)
 		/* failed to service fault */
diff --git a/drivers/iommu/intel-svm.c b/drivers/iommu/intel-svm.c
index 4ba770b9cfbb..fc67b4ce00da 100644
--- a/drivers/iommu/intel-svm.c
+++ b/drivers/iommu/intel-svm.c
@@ -542,6 +542,7 @@ static irqreturn_t prq_event_thread(int irq, void *d)
 		struct vm_area_struct *vma;
 		struct page_req_dsc *req;
 		struct qi_desc resp;
+		struct range_rwlock range;
 		int ret, result;
 		u64 address;
 
@@ -582,7 +583,8 @@ static irqreturn_t prq_event_thread(int irq, void *d)
 		/* If the mm is already defunct, don't handle faults. */
 		if (!mmget_not_zero(svm->mm))
 			goto bad_req;
-		down_read(&svm->mm->mmap_sem);
+		range_rwlock_init_full(&range);
+		range_read_lock(&svm->mm->mmap_rw_tree, &range);
 		vma = find_extend_vma(svm->mm, address);
 		if (!vma || address < vma->vm_start)
 			goto invalid;
@@ -597,7 +599,7 @@ static irqreturn_t prq_event_thread(int irq, void *d)
 
 		result = QI_RESP_SUCCESS;
 	invalid:
-		up_read(&svm->mm->mmap_sem);
+		range_read_unlock(&svm->mm->mmap_rw_tree, &range);
 		mmput(svm->mm);
 	bad_req:
 		/* Accounting for major/minor faults? */
diff --git a/drivers/media/v4l2-core/videobuf-core.c b/drivers/media/v4l2-core/videobuf-core.c
index 1dbf6f7785bb..9a26d0a5d7d3 100644
--- a/drivers/media/v4l2-core/videobuf-core.c
+++ b/drivers/media/v4l2-core/videobuf-core.c
@@ -530,14 +530,17 @@ EXPORT_SYMBOL_GPL(videobuf_querybuf);
 int videobuf_qbuf(struct videobuf_queue *q, struct v4l2_buffer *b)
 {
 	struct videobuf_buffer *buf;
+	struct range_rwlock range;
 	enum v4l2_field field;
 	unsigned long flags = 0;
 	int retval;
 
 	MAGIC_CHECK(q->int_ops->magic, MAGIC_QTYPE_OPS);
 
-	if (b->memory == V4L2_MEMORY_MMAP)
-		down_read(&current->mm->mmap_sem);
+	if (b->memory == V4L2_MEMORY_MMAP) {
+		range_rwlock_init_full(&range);
+		range_read_lock(&current->mm->mmap_rw_tree, &range);
+	}
 
 	videobuf_queue_lock(q);
 	retval = -EBUSY;
@@ -624,7 +627,7 @@ int videobuf_qbuf(struct videobuf_queue *q, struct v4l2_buffer *b)
 	videobuf_queue_unlock(q);
 
 	if (b->memory == V4L2_MEMORY_MMAP)
-		up_read(&current->mm->mmap_sem);
+		range_read_unlock(&current->mm->mmap_rw_tree, &range);
 
 	return retval;
 }
diff --git a/drivers/media/v4l2-core/videobuf-dma-contig.c b/drivers/media/v4l2-core/videobuf-dma-contig.c
index e02353e340dd..e74cf7f1119c 100644
--- a/drivers/media/v4l2-core/videobuf-dma-contig.c
+++ b/drivers/media/v4l2-core/videobuf-dma-contig.c
@@ -162,6 +162,7 @@ static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
+	struct range_rwlock range;
 	unsigned long prev_pfn, this_pfn;
 	unsigned long pages_done, user_address;
 	unsigned int offset;
@@ -171,7 +172,8 @@ static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
 	mem->size = PAGE_ALIGN(vb->size + offset);
 	ret = -EINVAL;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 
 	vma = find_vma(mm, vb->baddr);
 	if (!vma)
@@ -203,7 +205,7 @@ static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
 	}
 
 out_up:
-	up_read(&current->mm->mmap_sem);
+	range_read_unlock(&current->mm->mmap_rw_tree, &range);
 
 	return ret;
 }
diff --git a/drivers/media/v4l2-core/videobuf-dma-sg.c b/drivers/media/v4l2-core/videobuf-dma-sg.c
index b789070047df..785b69a5d52b 100644
--- a/drivers/media/v4l2-core/videobuf-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
@@ -199,11 +199,13 @@ static int videobuf_dma_init_user_locked(struct videobuf_dmabuf *dma,
 static int videobuf_dma_init_user(struct videobuf_dmabuf *dma, int direction,
 			   unsigned long data, unsigned long size)
 {
+	struct range_rwlock range;
 	int ret;
 
-	down_read(&current->mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&current->mm->mmap_rw_tree, &range);
 	ret = videobuf_dma_init_user_locked(dma, direction, data, size);
-	up_read(&current->mm->mmap_sem);
+	range_read_unlock(&current->mm->mmap_rw_tree, &range);
 
 	return ret;
 }
diff --git a/drivers/misc/cxl/fault.c b/drivers/misc/cxl/fault.c
index 2fa015c05561..45cefdf30656 100644
--- a/drivers/misc/cxl/fault.c
+++ b/drivers/misc/cxl/fault.c
@@ -338,6 +338,7 @@ static void cxl_prefault_vma(struct cxl_context *ctx)
 	struct vm_area_struct *vma;
 	int rc;
 	struct mm_struct *mm;
+	struct range_rwlock range;
 
 	mm = get_mem_context(ctx);
 	if (mm == NULL) {
@@ -346,7 +347,8 @@ static void cxl_prefault_vma(struct cxl_context *ctx)
 		return;
 	}
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		for (ea = vma->vm_start; ea < vma->vm_end;
 				ea = next_segment(ea, slb.vsid)) {
@@ -361,7 +363,7 @@ static void cxl_prefault_vma(struct cxl_context *ctx)
 			last_esid = slb.esid;
 		}
 	}
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 
 	mmput(mm);
 }
diff --git a/drivers/misc/mic/scif/scif_rma.c b/drivers/misc/mic/scif/scif_rma.c
index 30e3c524216d..6376e70efdb4 100644
--- a/drivers/misc/mic/scif/scif_rma.c
+++ b/drivers/misc/mic/scif/scif_rma.c
@@ -275,19 +275,22 @@ static inline int
 __scif_dec_pinned_vm_lock(struct mm_struct *mm,
 			  int nr_pages, bool try_lock)
 {
+	struct range_rwlock range;
+
 	if (!mm || !nr_pages || !scif_ulimit_check)
 		return 0;
+	range_rwlock_init_full(&range);
 	if (try_lock) {
-		if (!down_write_trylock(&mm->mmap_sem)) {
+		if (!range_write_trylock(&mm->mmap_rw_tree, &range)) {
 			dev_err(scif_info.mdev.this_device,
 				"%s %d err\n", __func__, __LINE__);
 			return -1;
 		}
 	} else {
-		down_write(&mm->mmap_sem);
+		range_write_lock(&mm->mmap_rw_tree, &range);
 	}
 	mm->pinned_vm -= nr_pages;
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	return 0;
 }
 
@@ -1333,6 +1336,7 @@ int __scif_pin_pages(void *addr, size_t len, int *out_prot,
 	int prot = *out_prot;
 	int ulimit = 0;
 	struct mm_struct *mm = NULL;
+	struct range_rwlock range;
 
 	/* Unsupported flags */
 	if (map_flags & ~(SCIF_MAP_KERNEL | SCIF_MAP_ULIMIT))
@@ -1386,11 +1390,12 @@ int __scif_pin_pages(void *addr, size_t len, int *out_prot,
 		prot |= SCIF_PROT_WRITE;
 retry:
 		mm = current->mm;
-		down_write(&mm->mmap_sem);
+		range_rwlock_init_full(&range);
+		range_write_lock(&mm->mmap_rw_tree, &range);
 		if (ulimit) {
 			err = __scif_check_inc_pinned_vm(mm, nr_pages);
 			if (err) {
-				up_write(&mm->mmap_sem);
+				range_write_unlock(&mm->mmap_rw_tree, &range);
 				pinned_pages->nr_pages = 0;
 				goto error_unmap;
 			}
@@ -1402,7 +1407,7 @@ int __scif_pin_pages(void *addr, size_t len, int *out_prot,
 				(prot & SCIF_PROT_WRITE) ? FOLL_WRITE : 0,
 				pinned_pages->pages,
 				NULL, NULL);
-		up_write(&mm->mmap_sem);
+		range_write_unlock(&mm->mmap_rw_tree, &range);
 		if (nr_pages != pinned_pages->nr_pages) {
 			if (try_upgrade) {
 				if (ulimit)
diff --git a/drivers/oprofile/buffer_sync.c b/drivers/oprofile/buffer_sync.c
index ac27f3d3fbb4..c0ce1baf7975 100644
--- a/drivers/oprofile/buffer_sync.c
+++ b/drivers/oprofile/buffer_sync.c
@@ -90,12 +90,14 @@ munmap_notify(struct notifier_block *self, unsigned long val, void *data)
 	unsigned long addr = (unsigned long)data;
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *mpnt;
+	struct range_rwlock range;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 
 	mpnt = find_vma(mm, addr);
 	if (mpnt && mpnt->vm_file && (mpnt->vm_flags & VM_EXEC)) {
-		up_read(&mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, &range);
 		/* To avoid latency problems, we only process the current CPU,
 		 * hoping that most samples for the task are on this CPU
 		 */
@@ -103,7 +105,7 @@ munmap_notify(struct notifier_block *self, unsigned long val, void *data)
 		return 0;
 	}
 
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 	return 0;
 }
 
@@ -255,8 +257,10 @@ lookup_dcookie(struct mm_struct *mm, unsigned long addr, off_t *offset)
 {
 	unsigned long cookie = NO_COOKIE;
 	struct vm_area_struct *vma;
+	struct range_rwlock range;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	for (vma = find_vma(mm, addr); vma; vma = vma->vm_next) {
 
 		if (addr < vma->vm_start || addr >= vma->vm_end)
@@ -276,7 +280,7 @@ lookup_dcookie(struct mm_struct *mm, unsigned long addr, off_t *offset)
 
 	if (!vma)
 		cookie = INVALID_COOKIE;
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 
 	return cookie;
 }
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index 896196c74cd2..4a4fb38661c8 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -61,9 +61,11 @@ struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
 			       size_t count)
 {
 	struct vm_area_struct *vma, *ret = NULL;
+	struct range_rwlock range;
 
 	/* mmap_sem must have been held by caller. */
-	LASSERT(!down_write_trylock(&mm->mmap_sem));
+	range_rwlock_init_full(&range);
+	LASSERT(!range_write_trylock(&mm->mmap_rw_tree, &range));
 
 	for (vma = find_vma(mm, addr);
 	    vma && vma->vm_start < (addr + count); vma = vma->vm_next) {
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 4c57755e06e7..508c02953946 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -376,6 +376,7 @@ static int vvp_mmap_locks(const struct lu_env *env,
 	int		 result = 0;
 	struct iov_iter i;
 	struct iovec iov;
+	struct range_rwlock range;
 
 	LASSERT(io->ci_type == CIT_READ || io->ci_type == CIT_WRITE);
 
@@ -395,7 +396,8 @@ static int vvp_mmap_locks(const struct lu_env *env,
 		count += addr & (~PAGE_MASK);
 		addr &= PAGE_MASK;
 
-		down_read(&mm->mmap_sem);
+		range_rwlock_init_full(&range);
+		range_read_lock(&mm->mmap_rw_tree, &range);
 		while ((vma = our_vma(mm, addr, count)) != NULL) {
 			struct inode *inode = file_inode(vma->vm_file);
 			int flags = CEF_MUST;
@@ -436,7 +438,7 @@ static int vvp_mmap_locks(const struct lu_env *env,
 			count -= vma->vm_end - addr;
 			addr = vma->vm_end;
 		}
-		up_read(&mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, &range);
 		if (result < 0)
 			break;
 	}
diff --git a/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c b/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c
index 3aeffcb9c87e..90f8fb91bdef 100644
--- a/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c
+++ b/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c
@@ -467,14 +467,17 @@ create_pagelist(char __user *buf, size_t count, unsigned short type,
 		}
 		/* do not try and release vmalloc pages */
 	} else {
-		down_read(&task->mm->mmap_sem);
+		struct range_rwlock range;
+
+		range_rwlock_init_full(&range);
+		range_read_lock(&task->mm->mmap_rw_tree, &range);
 		actual_pages = get_user_pages(
 				          (unsigned long)buf & ~(PAGE_SIZE - 1),
 					  num_pages,
 					  (type == PAGELIST_READ) ? FOLL_WRITE : 0,
 					  pages,
 					  NULL /*vmas */);
-		up_read(&task->mm->mmap_sem);
+		range_read_unlock(&task->mm->mmap_rw_tree, &range);
 
 		if (actual_pages != num_pages) {
 			vchiq_log_info(vchiq_arm_log_level,
diff --git a/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_arm.c b/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_arm.c
index 8a0d214f6e9b..24fd9317f220 100644
--- a/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_arm.c
+++ b/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_arm.c
@@ -1560,6 +1560,7 @@ dump_phys_mem(void *virt_addr, u32 num_bytes)
 	struct page   *page;
 	struct page  **pages;
 	u8            *kmapped_virt_ptr;
+	struct range_rwlock range;
 
 	/* Align virtAddr and endVirtAddr to 16 byte boundaries. */
 
@@ -1580,14 +1581,15 @@ dump_phys_mem(void *virt_addr, u32 num_bytes)
 		return;
 	}
 
-	down_read(&current->mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&current->mm->mmap_rw_tree, &range);
 	rc = get_user_pages(
 		(unsigned long)virt_addr, /* start */
 		num_pages,                /* len */
 		0,                        /* gup_flags */
 		pages,                    /* pages (array of page pointers) */
 		NULL);                    /* vmas */
-	up_read(&current->mm->mmap_sem);
+	range_read_unlock(&current->mm->mmap_rw_tree, &range);
 
 	prev_idx = -1;
 	page = NULL;
diff --git a/drivers/vfio/vfio_iommu_spapr_tce.c b/drivers/vfio/vfio_iommu_spapr_tce.c
index cf3de91fbfe7..69ca50c6d67c 100644
--- a/drivers/vfio/vfio_iommu_spapr_tce.c
+++ b/drivers/vfio/vfio_iommu_spapr_tce.c
@@ -37,6 +37,7 @@ static void tce_iommu_detach_group(void *iommu_data,
 static long try_increment_locked_vm(struct mm_struct *mm, long npages)
 {
 	long ret = 0, locked, lock_limit;
+	struct range_rwlock range;
 
 	if (WARN_ON_ONCE(!mm))
 		return -EPERM;
@@ -44,7 +45,8 @@ static long try_increment_locked_vm(struct mm_struct *mm, long npages)
 	if (!npages)
 		return 0;
 
-	down_write(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&mm->mmap_rw_tree, &range);
 	locked = mm->locked_vm + npages;
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
 	if (locked > lock_limit && !capable(CAP_IPC_LOCK))
@@ -58,17 +60,20 @@ static long try_increment_locked_vm(struct mm_struct *mm, long npages)
 			rlimit(RLIMIT_MEMLOCK),
 			ret ? " - exceeded" : "");
 
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 
 	return ret;
 }
 
 static void decrement_locked_vm(struct mm_struct *mm, long npages)
 {
+	struct range_rwlock range;
+
 	if (!mm || !npages)
 		return;
 
-	down_write(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&mm->mmap_rw_tree, &range);
 	if (WARN_ON_ONCE(npages > mm->locked_vm))
 		npages = mm->locked_vm;
 	mm->locked_vm -= npages;
@@ -76,7 +81,7 @@ static void decrement_locked_vm(struct mm_struct *mm, long npages)
 			npages << PAGE_SHIFT,
 			mm->locked_vm << PAGE_SHIFT,
 			rlimit(RLIMIT_MEMLOCK));
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 }
 
 /*
diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index 32d2633092a3..984cc1e71977 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -257,11 +257,13 @@ static void vfio_lock_acct_bg(struct work_struct *work)
 {
 	struct vwork *vwork = container_of(work, struct vwork, work);
 	struct mm_struct *mm;
+	struct range_rwlock range;
 
 	mm = vwork->mm;
-	down_write(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&mm->mmap_rw_tree, &range);
 	mm->locked_vm += vwork->npage;
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	mmput(mm);
 	kfree(vwork);
 }
@@ -270,6 +272,7 @@ static void vfio_lock_acct(struct task_struct *task, long npage)
 {
 	struct vwork *vwork;
 	struct mm_struct *mm;
+	struct range_rwlock range;
 	bool is_current;
 
 	if (!npage)
@@ -281,9 +284,10 @@ static void vfio_lock_acct(struct task_struct *task, long npage)
 	if (!mm)
 		return; /* process exited */
 
-	if (down_write_trylock(&mm->mmap_sem)) {
+	range_rwlock_init_full(&range);
+	if (range_write_trylock(&mm->mmap_rw_tree, &range)) {
 		mm->locked_vm += npage;
-		up_write(&mm->mmap_sem);
+		range_write_unlock(&mm->mmap_rw_tree, &range);
 		if (!is_current)
 			mmput(mm);
 		return;
@@ -361,8 +365,10 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 {
 	struct page *page[1];
 	struct vm_area_struct *vma;
+	struct range_rwlock range;
 	int ret;
 
+	range_rwlock_init_full(&range);
 	if (mm == current->mm) {
 		ret = get_user_pages_fast(vaddr, 1, !!(prot & IOMMU_WRITE),
 					  page);
@@ -372,10 +378,10 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 		if (prot & IOMMU_WRITE)
 			flags |= FOLL_WRITE;
 
-		down_read(&mm->mmap_sem);
+		range_read_lock(&mm->mmap_rw_tree, &range);
 		ret = get_user_pages_remote(NULL, mm, vaddr, 1, flags, page,
-					    NULL, NULL);
-		up_read(&mm->mmap_sem);
+					    NULL, NULL, NULL);
+		range_read_unlock(&mm->mmap_rw_tree, &range);
 	}
 
 	if (ret == 1) {
@@ -383,7 +389,7 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 		return 0;
 	}
 
-	down_read(&mm->mmap_sem);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 
 	vma = find_vma_intersection(mm, vaddr, vaddr + 1);
 
@@ -393,7 +399,7 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 			ret = 0;
 	}
 
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 	return ret;
 }
 
diff --git a/drivers/virt/fsl_hypervisor.c b/drivers/virt/fsl_hypervisor.c
index 150ce2abf6c8..544bcc67e357 100644
--- a/drivers/virt/fsl_hypervisor.c
+++ b/drivers/virt/fsl_hypervisor.c
@@ -146,6 +146,7 @@ static long ioctl_stop(struct fsl_hv_ioctl_stop __user *p)
  */
 static long ioctl_memcpy(struct fsl_hv_ioctl_memcpy __user *p)
 {
+	struct range_rwlock range;
 	struct fsl_hv_ioctl_memcpy param;
 
 	struct page **pages = NULL;
@@ -243,11 +244,12 @@ static long ioctl_memcpy(struct fsl_hv_ioctl_memcpy __user *p)
 	sg_list = PTR_ALIGN(sg_list_unaligned, sizeof(struct fh_sg_list));
 
 	/* Get the physical addresses of the source buffer */
-	down_read(&current->mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&current->mm->mmap_rw_tree, &range);
 	num_pinned = get_user_pages(param.local_vaddr - lb_offset,
 		num_pages, (param.source == -1) ? 0 : FOLL_WRITE,
 		pages, NULL);
-	up_read(&current->mm->mmap_sem);
+	range_read_unlock(&current->mm->mmap_rw_tree, &range);
 
 	if (num_pinned != num_pages) {
 		/* get_user_pages() failed */
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index f3bf8f4e2d6c..89ff9b6f6f89 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -657,13 +657,15 @@ static long gntdev_ioctl_get_offset_for_vaddr(struct gntdev_priv *priv,
 	struct ioctl_gntdev_get_offset_for_vaddr op;
 	struct vm_area_struct *vma;
 	struct grant_map *map;
+	struct range_rwlock range;
 	int rv = -EINVAL;
 
 	if (copy_from_user(&op, u, sizeof(op)) != 0)
 		return -EFAULT;
 	pr_debug("priv %p, offset for vaddr %lx\n", priv, (unsigned long)op.vaddr);
 
-	down_read(&current->mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&current->mm->mmap_rw_tree, &range);
 	vma = find_vma(current->mm, op.vaddr);
 	if (!vma || vma->vm_ops != &gntdev_vmops)
 		goto out_unlock;
@@ -677,7 +679,7 @@ static long gntdev_ioctl_get_offset_for_vaddr(struct gntdev_priv *priv,
 	rv = 0;
 
  out_unlock:
-	up_read(&current->mm->mmap_sem);
+	range_read_unlock(&current->mm->mmap_rw_tree, &range);
 
 	if (rv == 0 && copy_to_user(u, &op, sizeof(op)) != 0)
 		return -EFAULT;
diff --git a/drivers/xen/privcmd.c b/drivers/xen/privcmd.c
index 7a92a5e1d40c..a35de7996f1d 100644
--- a/drivers/xen/privcmd.c
+++ b/drivers/xen/privcmd.c
@@ -260,6 +260,7 @@ static long privcmd_ioctl_mmap(struct file *file, void __user *udata)
 	int rc;
 	LIST_HEAD(pagelist);
 	struct mmap_gfn_state state;
+	struct range_rwlock range;
 
 	/* We only support privcmd_ioctl_mmap_batch for auto translated. */
 	if (xen_feature(XENFEAT_auto_translated_physmap))
@@ -279,7 +280,8 @@ static long privcmd_ioctl_mmap(struct file *file, void __user *udata)
 	if (rc || list_empty(&pagelist))
 		goto out;
 
-	down_write(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&mm->mmap_rw_tree, &range);
 
 	{
 		struct page *page = list_first_entry(&pagelist,
@@ -304,7 +306,7 @@ static long privcmd_ioctl_mmap(struct file *file, void __user *udata)
 
 
 out_up:
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 
 out:
 	free_page_list(&pagelist);
@@ -454,6 +456,7 @@ static long privcmd_ioctl_mmap_batch(
 	unsigned long nr_pages;
 	LIST_HEAD(pagelist);
 	struct mmap_batch_state state;
+	struct range_rwlock range;
 
 	switch (version) {
 	case 1:
@@ -500,7 +503,8 @@ static long privcmd_ioctl_mmap_batch(
 		}
 	}
 
-	down_write(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&mm->mmap_rw_tree, &range);
 
 	vma = find_vma(mm, m.addr);
 	if (!vma ||
@@ -556,7 +560,7 @@ static long privcmd_ioctl_mmap_batch(
 	BUG_ON(traverse_pages_block(m.num, sizeof(xen_pfn_t),
 				    &pagelist, mmap_batch_fn, &state));
 
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 
 	if (state.global_error) {
 		/* Write back errors in second pass. */
@@ -577,7 +581,7 @@ static long privcmd_ioctl_mmap_batch(
 	return ret;
 
 out_unlock:
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	goto out;
 }
 
diff --git a/fs/aio.c b/fs/aio.c
index f52d925ee259..0858bf26c6c5 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -450,6 +450,9 @@ static int aio_setup_ring(struct kioctx *ctx)
 	int nr_pages;
 	int i;
 	struct file *file;
+	struct range_rwlock range;
+
+	range_rwlock_init_full(&range);
 
 	/* Compensate for the ring buffer's head/tail overlap entry */
 	nr_events += 2;	/* 1 is required, 2 for good luck */
@@ -504,7 +507,7 @@ static int aio_setup_ring(struct kioctx *ctx)
 	ctx->mmap_size = nr_pages * PAGE_SIZE;
 	pr_debug("attempting mmap of %lu bytes\n", ctx->mmap_size);
 
-	if (down_write_killable(&mm->mmap_sem)) {
+	if (range_write_lock_interruptible(&mm->mmap_rw_tree, &range)) {
 		ctx->mmap_size = 0;
 		aio_free_ring(ctx);
 		return -EINTR;
@@ -513,7 +516,7 @@ static int aio_setup_ring(struct kioctx *ctx)
 	ctx->mmap_base = do_mmap_pgoff(ctx->aio_ring_file, 0, ctx->mmap_size,
 				       PROT_READ | PROT_WRITE,
 				       MAP_SHARED, 0, &unused, NULL);
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	if (IS_ERR((void *)ctx->mmap_base)) {
 		ctx->mmap_size = 0;
 		aio_free_ring(ctx);
diff --git a/fs/coredump.c b/fs/coredump.c
index 592683711c64..1aac9bc29b03 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -411,17 +411,19 @@ static int coredump_wait(int exit_code, struct core_state *core_state)
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
 	int core_waiters = -EBUSY;
+	struct range_rwlock range;
 
+	range_rwlock_init_full(&range);
 	init_completion(&core_state->startup);
 	core_state->dumper.task = tsk;
 	core_state->dumper.next = NULL;
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (range_write_lock_interruptible(&mm->mmap_rw_tree, &range))
 		return -EINTR;
 
 	if (!mm->core_state)
 		core_waiters = zap_threads(tsk, mm, core_state, exit_code);
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 
 	if (core_waiters > 0) {
 		struct core_thread *ptr;
diff --git a/fs/exec.c b/fs/exec.c
index 49a3a19816f0..0a75d1cd1946 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -268,12 +268,14 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
 	int err;
 	struct vm_area_struct *vma = NULL;
 	struct mm_struct *mm = bprm->mm;
+	struct range_rwlock range;
 
 	bprm->vma = vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
 	if (!vma)
 		return -ENOMEM;
 
-	if (down_write_killable(&mm->mmap_sem)) {
+	range_rwlock_init_full(&range);
+	if (range_write_lock_interruptible(&mm->mmap_rw_tree, &range)) {
 		err = -EINTR;
 		goto err_free;
 	}
@@ -298,11 +300,11 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
 
 	mm->stack_vm = mm->total_vm = 1;
 	arch_bprm_mm_init(mm, vma);
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	bprm->p = vma->vm_end - sizeof(void *);
 	return 0;
 err:
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 err_free:
 	bprm->vma = NULL;
 	kmem_cache_free(vm_area_cachep, vma);
@@ -673,6 +675,7 @@ int setup_arg_pages(struct linux_binprm *bprm,
 	unsigned long stack_size;
 	unsigned long stack_expand;
 	unsigned long rlim_stack;
+	struct range_rwlock range;
 
 #ifdef CONFIG_STACK_GROWSUP
 	/* Limit stack size */
@@ -710,7 +713,8 @@ int setup_arg_pages(struct linux_binprm *bprm,
 		bprm->loader -= stack_shift;
 	bprm->exec -= stack_shift;
 
-	if (down_write_killable(&mm->mmap_sem))
+	range_rwlock_init_full(&range);
+	if (range_write_lock_interruptible(&mm->mmap_rw_tree, &range))
 		return -EINTR;
 
 	vm_flags = VM_STACK_FLAGS;
@@ -767,7 +771,7 @@ int setup_arg_pages(struct linux_binprm *bprm,
 		ret = -EFAULT;
 
 out_unlock:
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	return ret;
 }
 EXPORT_SYMBOL(setup_arg_pages);
@@ -1001,6 +1005,9 @@ static int exec_mmap(struct mm_struct *mm)
 {
 	struct task_struct *tsk;
 	struct mm_struct *old_mm, *active_mm;
+	struct range_rwlock range;
+
+	range_rwlock_init_full(&range);
 
 	/* Notify parent that we're no longer interested in the old VM */
 	tsk = current;
@@ -1015,9 +1022,10 @@ static int exec_mmap(struct mm_struct *mm)
 		 * through with the exec.  We must hold mmap_sem around
 		 * checking core_state and changing tsk->mm.
 		 */
-		down_read(&old_mm->mmap_sem);
+
+		range_read_lock(&old_mm->mmap_rw_tree, &range);
 		if (unlikely(old_mm->core_state)) {
-			up_read(&old_mm->mmap_sem);
+			range_read_unlock(&old_mm->mmap_rw_tree, &range);
 			return -EINTR;
 		}
 	}
@@ -1030,7 +1038,7 @@ static int exec_mmap(struct mm_struct *mm)
 	vmacache_flush(tsk);
 	task_unlock(tsk);
 	if (old_mm) {
-		up_read(&old_mm->mmap_sem);
+		range_read_unlock(&old_mm->mmap_rw_tree, &range);
 		BUG_ON(active_mm != old_mm);
 		setmax_mm_hiwater_rss(&tsk->signal->maxrss, old_mm);
 		mm_update_next_owner(old_mm);
diff --git a/fs/proc/base.c b/fs/proc/base.c
index c87b6b9a8a76..9e252fe49aa4 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -216,7 +216,9 @@ static ssize_t proc_pid_cmdline_read(struct file *file, char __user *buf,
 	unsigned long p;
 	char c;
 	ssize_t rv;
+	struct range_rwlock range;
 
+	range_rwlock_init_full(&range);
 	BUG_ON(*pos < 0);
 
 	tsk = get_proc_task(file_inode(file));
@@ -238,12 +240,12 @@ static ssize_t proc_pid_cmdline_read(struct file *file, char __user *buf,
 		goto out_mmput;
 	}
 
-	down_read(&mm->mmap_sem);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	arg_start = mm->arg_start;
 	arg_end = mm->arg_end;
 	env_start = mm->env_start;
 	env_end = mm->env_end;
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 
 	BUG_ON(arg_start > arg_end);
 	BUG_ON(env_start > env_end);
@@ -916,7 +918,9 @@ static ssize_t environ_read(struct file *file, char __user *buf,
 	int ret = 0;
 	struct mm_struct *mm = file->private_data;
 	unsigned long env_start, env_end;
+	struct range_rwlock range;
 
+	range_rwlock_init_full(&range);
 	/* Ensure the process spawned far enough to have an environment. */
 	if (!mm || !mm->env_end)
 		return 0;
@@ -929,10 +933,10 @@ static ssize_t environ_read(struct file *file, char __user *buf,
 	if (!mmget_not_zero(mm))
 		goto free;
 
-	down_read(&mm->mmap_sem);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	env_start = mm->env_start;
 	env_end = mm->env_end;
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 
 	while (count > 0) {
 		size_t this_len, max_len;
@@ -1880,6 +1884,7 @@ static int map_files_d_revalidate(struct dentry *dentry, unsigned int flags)
 	struct task_struct *task;
 	struct inode *inode;
 	int status = 0;
+	struct range_rwlock range;
 
 	if (flags & LOOKUP_RCU)
 		return -ECHILD;
@@ -1894,9 +1899,10 @@ static int map_files_d_revalidate(struct dentry *dentry, unsigned int flags)
 		goto out;
 
 	if (!dname_to_vma_addr(dentry, &vm_start, &vm_end)) {
-		down_read(&mm->mmap_sem);
+		range_rwlock_init_full(&range);
+		range_read_lock(&mm->mmap_rw_tree, &range);
 		exact_vma_exists = !!find_exact_vma(mm, vm_start, vm_end);
-		up_read(&mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, &range);
 	}
 
 	mmput(mm);
@@ -1927,6 +1933,7 @@ static int map_files_get_link(struct dentry *dentry, struct path *path)
 	struct task_struct *task;
 	struct mm_struct *mm;
 	int rc;
+	struct range_rwlock range;
 
 	rc = -ENOENT;
 	task = get_proc_task(d_inode(dentry));
@@ -1943,14 +1950,15 @@ static int map_files_get_link(struct dentry *dentry, struct path *path)
 		goto out_mmput;
 
 	rc = -ENOENT;
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	vma = find_exact_vma(mm, vm_start, vm_end);
 	if (vma && vma->vm_file) {
 		*path = vma->vm_file->f_path;
 		path_get(path);
 		rc = 0;
 	}
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 
 out_mmput:
 	mmput(mm);
@@ -2023,6 +2031,7 @@ static struct dentry *proc_map_files_lookup(struct inode *dir,
 	struct task_struct *task;
 	int result;
 	struct mm_struct *mm;
+	struct range_rwlock range;
 
 	result = -ENOENT;
 	task = get_proc_task(dir);
@@ -2041,7 +2050,8 @@ static struct dentry *proc_map_files_lookup(struct inode *dir,
 	if (!mm)
 		goto out_put_task;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	vma = find_exact_vma(mm, vm_start, vm_end);
 	if (!vma)
 		goto out_no_vma;
@@ -2051,7 +2061,7 @@ static struct dentry *proc_map_files_lookup(struct inode *dir,
 				(void *)(unsigned long)vma->vm_file->f_mode);
 
 out_no_vma:
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 	mmput(mm);
 out_put_task:
 	put_task_struct(task);
@@ -2076,7 +2086,9 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
 	struct map_files_info info;
 	struct map_files_info *p;
 	int ret;
+	struct range_rwlock range;
 
+	range_rwlock_init_full(&range);
 	ret = -ENOENT;
 	task = get_proc_task(file_inode(file));
 	if (!task)
@@ -2093,7 +2105,7 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
 	mm = get_task_mm(task);
 	if (!mm)
 		goto out_put_task;
-	down_read(&mm->mmap_sem);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 
 	nr_files = 0;
 
@@ -2120,7 +2132,7 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
 			ret = -ENOMEM;
 			if (fa)
 				flex_array_free(fa);
-			up_read(&mm->mmap_sem);
+			range_read_unlock(&mm->mmap_rw_tree, &range);
 			mmput(mm);
 			goto out_put_task;
 		}
@@ -2139,7 +2151,7 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
 				BUG();
 		}
 	}
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 
 	for (i = 0; i < nr_files; i++) {
 		p = flex_array_get(fa, i);
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index c5ae09b6c726..c2991bfa9a6c 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -279,6 +279,7 @@ struct proc_maps_private {
 #ifdef CONFIG_NUMA
 	struct mempolicy *task_mempolicy;
 #endif
+	struct range_rwlock range;
 };
 
 struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode);
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 312578089544..3fceea238474 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -133,7 +133,7 @@ static void vma_stop(struct proc_maps_private *priv)
 	struct mm_struct *mm = priv->mm;
 
 	release_task_mempolicy(priv);
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &priv->range);
 	mmput(mm);
 }
 
@@ -171,7 +171,8 @@ static void *m_start(struct seq_file *m, loff_t *ppos)
 	if (!mm || !mmget_not_zero(mm))
 		return NULL;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&priv->range);
+	range_read_lock(&mm->mmap_rw_tree, &priv->range);
 	hold_task_mempolicy(priv);
 	priv->tail_vma = get_gate_vma(mm);
 
@@ -1009,7 +1010,9 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 	enum clear_refs_types type;
 	int itype;
 	int rv;
+	struct range_rwlock range;
 
+	range_rwlock_init_full(&range);
 	memset(buffer, 0, sizeof(buffer));
 	if (count > sizeof(buffer) - 1)
 		count = sizeof(buffer) - 1;
@@ -1038,7 +1041,8 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 		};
 
 		if (type == CLEAR_REFS_MM_HIWATER_RSS) {
-			if (down_write_killable(&mm->mmap_sem)) {
+			if (range_write_lock_interruptible(&mm->mmap_rw_tree,
+							   &range)) {
 				count = -EINTR;
 				goto out_mm;
 			}
@@ -1048,17 +1052,18 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 			 * resident set size to this mm's current rss value.
 			 */
 			reset_mm_hiwater_rss(mm);
-			up_write(&mm->mmap_sem);
+			range_write_unlock(&mm->mmap_rw_tree, &range);
 			goto out_mm;
 		}
 
-		down_read(&mm->mmap_sem);
+		range_read_lock(&mm->mmap_rw_tree, &range);
 		if (type == CLEAR_REFS_SOFT_DIRTY) {
 			for (vma = mm->mmap; vma; vma = vma->vm_next) {
 				if (!(vma->vm_flags & VM_SOFTDIRTY))
 					continue;
-				up_read(&mm->mmap_sem);
-				if (down_write_killable(&mm->mmap_sem)) {
+				range_read_unlock(&mm->mmap_rw_tree, &range);
+				if (range_write_lock_interruptible(&mm->mmap_rw_tree,
+								   &range)) {
 					count = -EINTR;
 					goto out_mm;
 				}
@@ -1066,7 +1071,8 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 					vma->vm_flags &= ~VM_SOFTDIRTY;
 					vma_set_page_prot(vma);
 				}
-				downgrade_write(&mm->mmap_sem);
+				range_downgrade_write(&mm->mmap_rw_tree,
+						      &range);
 				break;
 			}
 			mmu_notifier_invalidate_range_start(mm, 0, -1);
@@ -1075,7 +1081,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 		if (type == CLEAR_REFS_SOFT_DIRTY)
 			mmu_notifier_invalidate_range_end(mm, 0, -1);
 		flush_tlb_mm(mm);
-		up_read(&mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, &range);
 out_mm:
 		mmput(mm);
 	}
@@ -1359,6 +1365,7 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 	unsigned long start_vaddr;
 	unsigned long end_vaddr;
 	int ret = 0, copied = 0;
+	struct range_rwlock range;
 
 	if (!mm || !mmget_not_zero(mm))
 		goto out;
@@ -1414,9 +1421,10 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 		/* overflow ? */
 		if (end < start_vaddr || end > end_vaddr)
 			end = end_vaddr;
-		down_read(&mm->mmap_sem);
+		range_rwlock_init_full(&range);
+		range_read_lock(&mm->mmap_rw_tree, &range);
 		ret = walk_page_range(start_vaddr, end, &pagemap_walk);
-		up_read(&mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, &range);
 		start_vaddr = end;
 
 		len = min(count, PM_ENTRY_BYTES * pm.pos);
diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index 23266694db11..50fa34b6a4bb 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -23,8 +23,10 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 	struct vm_region *region;
 	struct rb_node *p;
 	unsigned long bytes = 0, sbytes = 0, slack = 0, size;
-        
-	down_read(&mm->mmap_sem);
+	struct range_rwlock range;
+
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p)) {
 		vma = rb_entry(p, struct vm_area_struct, vm_rb);
 
@@ -76,7 +78,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		"Shared:\t%8lu bytes\n",
 		bytes, slack, sbytes);
 
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 }
 
 unsigned long task_vsize(struct mm_struct *mm)
@@ -84,13 +86,15 @@ unsigned long task_vsize(struct mm_struct *mm)
 	struct vm_area_struct *vma;
 	struct rb_node *p;
 	unsigned long vsize = 0;
+	struct range_rwlock range;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p)) {
 		vma = rb_entry(p, struct vm_area_struct, vm_rb);
 		vsize += vma->vm_end - vma->vm_start;
 	}
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 	return vsize;
 }
 
@@ -102,8 +106,10 @@ unsigned long task_statm(struct mm_struct *mm,
 	struct vm_region *region;
 	struct rb_node *p;
 	unsigned long size = kobjsize(mm);
+	struct range_rwlock range;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p)) {
 		vma = rb_entry(p, struct vm_area_struct, vm_rb);
 		size += kobjsize(vma);
@@ -118,7 +124,7 @@ unsigned long task_statm(struct mm_struct *mm,
 		>> PAGE_SHIFT;
 	*data = (PAGE_ALIGN(mm->start_stack) - (mm->start_data & PAGE_MASK))
 		>> PAGE_SHIFT;
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 	size >>= PAGE_SHIFT;
 	size += *text + *data;
 	*resident = size;
@@ -224,13 +230,14 @@ static void *m_start(struct seq_file *m, loff_t *pos)
 	if (!mm || !mmget_not_zero(mm))
 		return NULL;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&priv->range);
+	range_read_lock(&mm->mmap_rw_tree, &priv->range);
 	/* start from the Nth VMA */
 	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p))
 		if (n-- == 0)
 			return p;
 
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &priv->range);
 	mmput(mm);
 	return NULL;
 }
@@ -240,7 +247,7 @@ static void m_stop(struct seq_file *m, void *_vml)
 	struct proc_maps_private *priv = m->private;
 
 	if (!IS_ERR_OR_NULL(_vml)) {
-		up_read(&priv->mm->mmap_sem);
+		range_read_unlock(&priv->mm->mmap_rw_tree, &priv->range);
 		mmput(priv->mm);
 	}
 	if (priv->task) {
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 5752b3b65638..9852b4711d29 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -431,7 +431,7 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 	else
 		must_wait = userfaultfd_huge_must_wait(ctx, vmf->address,
 						       vmf->flags, reason);
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, vmf->lockrange);
 
 	if (likely(must_wait && !ACCESS_ONCE(ctx->released) &&
 		   (return_to_userland ? !signal_pending(current) :
@@ -485,7 +485,7 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 			 * and there's no need to retake the mmap_sem
 			 * in such case.
 			 */
-			down_read(&mm->mmap_sem);
+			range_read_lock(&mm->mmap_rw_tree, vmf->lockrange);
 			ret = VM_FAULT_NOPAGE;
 		}
 	}
@@ -704,7 +704,7 @@ bool userfaultfd_remove(struct vm_area_struct *vma,
 		return true;
 
 	userfaultfd_ctx_get(ctx);
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, range);
 
 	msg_init(&ewq.msg);
 
@@ -783,7 +783,9 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 	/* len == 0 means wake all */
 	struct userfaultfd_wake_range range = { .len = 0, };
 	unsigned long new_flags;
+	struct range_rwlock lockrange;
 
+	range_rwlock_init_full(&lockrange);
 	ACCESS_ONCE(ctx->released) = true;
 
 	if (!mmget_not_zero(mm))
@@ -797,7 +799,7 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 	 * it's critical that released is set to true (above), before
 	 * taking the mmap_sem for writing.
 	 */
-	down_write(&mm->mmap_sem);
+	range_write_lock(&mm->mmap_rw_tree, &lockrange);
 	prev = NULL;
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		cond_resched();
@@ -820,7 +822,7 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 		vma->vm_flags = new_flags;
 		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
 	}
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &lockrange);
 	mmput(mm);
 wakeup:
 	/*
@@ -1180,6 +1182,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	bool found;
 	bool non_anon_pages;
 	unsigned long start, end, vma_end;
+	struct range_rwlock range;
 
 	user_uffdio_register = (struct uffdio_register __user *) arg;
 
@@ -1219,7 +1222,8 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	if (!mmget_not_zero(mm))
 		goto out;
 
-	down_write(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&mm->mmap_rw_tree, &range);
 	vma = find_vma_prev(mm, start, &prev);
 	if (!vma)
 		goto out_unlock;
@@ -1347,7 +1351,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		vma = vma->vm_next;
 	} while (vma && vma->vm_start < end);
 out_unlock:
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	mmput(mm);
 	if (!ret) {
 		/*
@@ -1375,6 +1379,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	bool found;
 	unsigned long start, end, vma_end;
 	const void __user *buf = (void __user *)arg;
+	struct range_rwlock range;
 
 	ret = -EFAULT;
 	if (copy_from_user(&uffdio_unregister, buf, sizeof(uffdio_unregister)))
@@ -1392,7 +1397,8 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	if (!mmget_not_zero(mm))
 		goto out;
 
-	down_write(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&mm->mmap_rw_tree, &range);
 	vma = find_vma_prev(mm, start, &prev);
 	if (!vma)
 		goto out_unlock;
@@ -1505,7 +1511,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		vma = vma->vm_next;
 	} while (vma && vma->vm_start < end);
 out_unlock:
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	mmput(mm);
 out:
 	return ret;
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index f60f45fe226f..fcea774be217 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -8,6 +8,7 @@
 #include <linux/spinlock.h>
 #include <linux/rbtree.h>
 #include <linux/rwsem.h>
+#include <linux/range_rwlock.h>
 #include <linux/completion.h>
 #include <linux/cpumask.h>
 #include <linux/uprobes.h>
@@ -398,7 +399,7 @@ struct mm_struct {
 	int map_count;				/* number of VMAs */
 
 	spinlock_t page_table_lock;		/* Protects page tables and some counters */
-	struct rw_semaphore mmap_sem;
+	struct range_rwlock_tree mmap_rw_tree;	/* formerly mmap_sem */
 
 	struct list_head mmlist;		/* List of maybe swapped mm's.	These are globally strung
 						 * together off init_mm.mmlist, and are protected
diff --git a/ipc/shm.c b/ipc/shm.c
index 481d2a9c298a..f1a885962ac8 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -1107,6 +1107,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg,
 	struct path path;
 	fmode_t f_mode;
 	unsigned long populate = 0;
+	struct range_rwlock range;
 
 	err = -EINVAL;
 	if (shmid < 0)
@@ -1213,7 +1214,9 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg,
 	if (err)
 		goto out_fput;
 
-	if (down_write_killable(&current->mm->mmap_sem)) {
+	range_rwlock_init_full(&range);
+	if (range_write_lock_interruptible(&current->mm->mmap_rw_tree,
+					   &range)) {
 		err = -EINTR;
 		goto out_fput;
 	}
@@ -1233,7 +1236,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg,
 	if (IS_ERR_VALUE(addr))
 		err = (long)addr;
 invalid:
-	up_write(&current->mm->mmap_sem);
+	range_write_unlock(&current->mm->mmap_rw_tree, &range);
 	if (populate)
 		mm_populate(addr, populate);
 
@@ -1284,11 +1287,13 @@ SYSCALL_DEFINE1(shmdt, char __user *, shmaddr)
 	struct file *file;
 	struct vm_area_struct *next;
 #endif
+	struct range_rwlock range;
 
 	if (addr & ~PAGE_MASK)
 		return retval;
 
-	if (down_write_killable(&mm->mmap_sem))
+	range_rwlock_init_full(&range);
+	if (range_write_lock_interruptible(&mm->mmap_rw_tree, &range))
 		return -EINTR;
 
 	/*
@@ -1376,7 +1381,7 @@ SYSCALL_DEFINE1(shmdt, char __user *, shmaddr)
 
 #endif
 
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	return retval;
 }
 
diff --git a/kernel/acct.c b/kernel/acct.c
index 5b1284370367..928c1e75c025 100644
--- a/kernel/acct.c
+++ b/kernel/acct.c
@@ -534,17 +534,19 @@ void acct_collect(long exitcode, int group_dead)
 	struct pacct_struct *pacct = &current->signal->pacct;
 	u64 utime, stime;
 	unsigned long vsize = 0;
+	struct range_rwlock range;
 
+	range_rwlock_init_full(&range);
 	if (group_dead && current->mm) {
 		struct vm_area_struct *vma;
 
-		down_read(&current->mm->mmap_sem);
+		range_read_lock(&current->mm->mmap_rw_tree, &range);
 		vma = current->mm->mmap;
 		while (vma) {
 			vsize += vma->vm_end - vma->vm_start;
 			vma = vma->vm_next;
 		}
-		up_read(&current->mm->mmap_sem);
+		range_read_unlock(&current->mm->mmap_rw_tree, &range);
 	}
 
 	spin_lock_irq(&current->sighand->siglock);
diff --git a/kernel/events/core.c b/kernel/events/core.c
index ff01cba86f43..4ecf3d5c783b 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -8091,7 +8091,9 @@ static void perf_event_addr_filters_apply(struct perf_event *event)
 	struct mm_struct *mm = NULL;
 	unsigned int count = 0;
 	unsigned long flags;
+	struct range_rwlock range;
 
+	range_rwlock_init_full(&range);
 	/*
 	 * We may observe TASK_TOMBSTONE, which means that the event tear-down
 	 * will stop on the parent's child_mutex that our caller is also holding
@@ -8106,7 +8108,7 @@ static void perf_event_addr_filters_apply(struct perf_event *event)
 	if (!mm)
 		goto restart;
 
-	down_read(&mm->mmap_sem);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 
 	raw_spin_lock_irqsave(&ifh->lock, flags);
 	list_for_each_entry(filter, &ifh->list, entry) {
@@ -8126,7 +8128,7 @@ static void perf_event_addr_filters_apply(struct perf_event *event)
 	event->addr_filters_gen++;
 	raw_spin_unlock_irqrestore(&ifh->lock, flags);
 
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 
 	mmput(mm);
 
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index dc2e5f7a8bb8..cbfbd020459e 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -806,11 +806,13 @@ register_for_each_vma(struct uprobe *uprobe, struct uprobe_consumer *new)
 	while (info) {
 		struct mm_struct *mm = info->mm;
 		struct vm_area_struct *vma;
+		struct range_rwlock range;
 
 		if (err && is_register)
 			goto free;
 
-		down_write(&mm->mmap_sem);
+		range_rwlock_init_full(&range);
+		range_write_lock(&mm->mmap_rw_tree, &range);
 		vma = find_vma(mm, info->vaddr);
 		if (!vma || !valid_vma(vma, is_register) ||
 		    file_inode(vma->vm_file) != uprobe->inode)
@@ -832,7 +834,7 @@ register_for_each_vma(struct uprobe *uprobe, struct uprobe_consumer *new)
 		}
 
  unlock:
-		up_write(&mm->mmap_sem);
+		range_write_unlock(&mm->mmap_rw_tree, &range);
  free:
 		mmput(mm);
 		info = free_map_info(info);
@@ -971,9 +973,11 @@ EXPORT_SYMBOL_GPL(uprobe_unregister);
 static int unapply_uprobe(struct uprobe *uprobe, struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
+	struct range_rwlock range;
 	int err = 0;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		unsigned long vaddr;
 		loff_t offset;
@@ -990,7 +994,7 @@ static int unapply_uprobe(struct uprobe *uprobe, struct mm_struct *mm)
 		vaddr = offset_to_vaddr(vma, uprobe->offset);
 		err |= remove_breakpoint(uprobe, mm, vaddr);
 	}
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 
 	return err;
 }
@@ -1138,9 +1142,11 @@ void uprobe_munmap(struct vm_area_struct *vma, unsigned long start, unsigned lon
 static int xol_add_vma(struct mm_struct *mm, struct xol_area *area)
 {
 	struct vm_area_struct *vma;
+	struct range_rwlock range;
 	int ret;
 
-	if (down_write_killable(&mm->mmap_sem))
+	range_rwlock_init_full(&range);
+	if (range_write_lock_interruptible(&mm->mmap_rw_tree, &range))
 		return -EINTR;
 
 	if (mm->uprobes_state.xol_area) {
@@ -1170,7 +1176,7 @@ static int xol_add_vma(struct mm_struct *mm, struct xol_area *area)
 	smp_wmb();	/* pairs with get_xol_area() */
 	mm->uprobes_state.xol_area = area;
  fail:
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 
 	return ret;
 }
@@ -1736,8 +1742,10 @@ static struct uprobe *find_active_uprobe(unsigned long bp_vaddr, int *is_swbp)
 	struct mm_struct *mm = current->mm;
 	struct uprobe *uprobe = NULL;
 	struct vm_area_struct *vma;
+	struct range_rwlock range;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	vma = find_vma(mm, bp_vaddr);
 	if (vma && vma->vm_start <= bp_vaddr) {
 		if (valid_vma(vma, false)) {
@@ -1755,7 +1763,7 @@ static struct uprobe *find_active_uprobe(unsigned long bp_vaddr, int *is_swbp)
 
 	if (!uprobe && test_and_clear_bit(MMF_RECALC_UPROBES, &mm->flags))
 		mmf_recalc_uprobes(mm);
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 
 	return uprobe;
 }
diff --git a/kernel/exit.c b/kernel/exit.c
index 516acdb0e0ec..f59702a99289 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -508,6 +508,7 @@ static void exit_mm(void)
 {
 	struct mm_struct *mm = current->mm;
 	struct core_state *core_state;
+	struct range_rwlock range;
 
 	mm_release(current, mm);
 	if (!mm)
@@ -520,12 +521,13 @@ static void exit_mm(void)
 	 * will increment ->nr_threads for each thread in the
 	 * group with ->mm != NULL.
 	 */
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	core_state = mm->core_state;
 	if (core_state) {
 		struct core_thread self;
 
-		up_read(&mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, &range);
 
 		self.task = current;
 		self.next = xchg(&core_state->dumper.next, &self);
@@ -543,14 +545,14 @@ static void exit_mm(void)
 			freezable_schedule();
 		}
 		__set_current_state(TASK_RUNNING);
-		down_read(&mm->mmap_sem);
+		range_read_lock(&mm->mmap_rw_tree, &range);
 	}
 	mmgrab(mm);
 	BUG_ON(mm != current->active_mm);
 	/* more a memory barrier than a real lock */
 	task_lock(current);
 	current->mm = NULL;
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 	enter_lazy_tlb(mm, current);
 	task_unlock(current);
 	mm_update_next_owner(mm);
diff --git a/kernel/fork.c b/kernel/fork.c
index 6c463c80e93d..478e85cc3e5c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -573,9 +573,13 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 	int retval;
 	unsigned long charge;
 	LIST_HEAD(uf);
+	struct range_rwlock range, oldrange;
+
+	range_rwlock_init_full(&range);
+	range_rwlock_init_full(&oldrange);
 
 	uprobe_start_dup_mmap();
-	if (down_write_killable(&oldmm->mmap_sem)) {
+	if (range_write_lock_interruptible(&oldmm->mmap_rw_tree, &oldrange)) {
 		retval = -EINTR;
 		goto fail_uprobe_end;
 	}
@@ -584,7 +588,7 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 	/*
 	 * Not linked in yet - no deadlock potential:
 	 */
-	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
+	range_write_lock(&mm->mmap_rw_tree, &range);
 
 	/* No ordering required: file already has been exposed. */
 	RCU_INIT_POINTER(mm->exe_file, get_mm_exe_file(oldmm));
@@ -688,9 +692,9 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 	arch_dup_mmap(oldmm, mm);
 	retval = 0;
 out:
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	flush_tlb_mm(oldmm);
-	up_write(&oldmm->mmap_sem);
+	range_write_unlock(&oldmm->mmap_rw_tree, &oldrange);
 	dup_userfaultfd_complete(&uf);
 fail_uprobe_end:
 	uprobe_end_dup_mmap();
@@ -720,9 +724,12 @@ static inline void mm_free_pgd(struct mm_struct *mm)
 #else
 static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 {
-	down_write(&oldmm->mmap_sem);
+	struct range_rwlock oldrange;
+
+	range_rwlock_init_full(&oldrange);
+	range_write_lock(&oldmm->mmap_rw_tree, &oldrange);
 	RCU_INIT_POINTER(mm->exe_file, get_mm_exe_file(oldmm));
-	up_write(&oldmm->mmap_sem);
+	range_write_unlock(&oldmm->mmap_rw_tree, &oldrange);
 	return 0;
 }
 #define mm_alloc_pgd(mm)	(0)
@@ -771,7 +778,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 	mm->vmacache_seqnum = 0;
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
-	init_rwsem(&mm->mmap_sem);
+	range_rwlock_tree_init(&mm->mmap_rw_tree);
 	INIT_LIST_HEAD(&mm->mmlist);
 	mm->core_state = NULL;
 	atomic_long_set(&mm->nr_ptes, 0);
diff --git a/kernel/futex.c b/kernel/futex.c
index 4dd1bba09831..0ac51c925fa8 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -723,12 +723,14 @@ static inline void put_futex_key(union futex_key *key)
 static int fault_in_user_writeable(u32 __user *uaddr)
 {
 	struct mm_struct *mm = current->mm;
+	struct range_rwlock range;
 	int ret;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range); /* XXX finer grain required here */
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	ret = fixup_user_fault(current, mm, (unsigned long)uaddr,
-			       FAULT_FLAG_WRITE, NULL, NULL);
-	up_read(&mm->mmap_sem);
+			       FAULT_FLAG_WRITE, NULL, &range);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 
 	return ret < 0 ? ret : 0;
 }
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index dea138964b91..a8e4243e8510 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -2425,6 +2425,7 @@ void task_numa_work(struct callback_head *work)
 	unsigned long start, end;
 	unsigned long nr_pte_updates = 0;
 	long pages, virtpages;
+	struct range_rwlock range;
 
 	SCHED_WARN_ON(p != container_of(work, struct task_struct, numa_work));
 
@@ -2474,8 +2475,8 @@ void task_numa_work(struct callback_head *work)
 	if (!pages)
 		return;
 
-
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	vma = find_vma(mm, start);
 	if (!vma) {
 		reset_ptenuma_scan(p);
@@ -2542,7 +2543,7 @@ void task_numa_work(struct callback_head *work)
 		mm->numa_scan_offset = start;
 	else
 		reset_ptenuma_scan(p);
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 
 	/*
 	 * Make sure tasks use at least 32x as much time to run other code
diff --git a/kernel/sys.c b/kernel/sys.c
index 7ff6d1b10cec..4d449281575d 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1663,6 +1663,9 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 	struct file *old_exe, *exe_file;
 	struct inode *inode;
 	int err;
+	struct range_rwlock range;
+
+	range_rwlock_init_full(&range);
 
 	exe = fdget(fd);
 	if (!exe.file)
@@ -1691,7 +1694,7 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 	if (exe_file) {
 		struct vm_area_struct *vma;
 
-		down_read(&mm->mmap_sem);
+		range_read_lock(&mm->mmap_rw_tree, &range);
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
 			if (!vma->vm_file)
 				continue;
@@ -1700,7 +1703,7 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 				goto exit_err;
 		}
 
-		up_read(&mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, &range);
 		fput(exe_file);
 	}
 
@@ -1714,7 +1717,7 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 	fdput(exe);
 	return err;
 exit_err:
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 	fput(exe_file);
 	goto exit;
 }
@@ -1821,6 +1824,9 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 	unsigned long user_auxv[AT_VECTOR_SIZE];
 	struct mm_struct *mm = current->mm;
 	int error;
+	struct range_rwlock range;
+
+	range_rwlock_init_full(&range);
 
 	BUILD_BUG_ON(sizeof(user_auxv) != sizeof(mm->saved_auxv));
 	BUILD_BUG_ON(sizeof(struct prctl_mm_map) > 256);
@@ -1857,7 +1863,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 			return error;
 	}
 
-	down_write(&mm->mmap_sem);
+	range_write_lock(&mm->mmap_rw_tree, &range);
 
 	/*
 	 * We don't validate if these members are pointing to
@@ -1894,7 +1900,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 	if (prctl_map.auxv_size)
 		memcpy(mm->saved_auxv, user_auxv, sizeof(user_auxv));
 
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	return 0;
 }
 #endif /* CONFIG_CHECKPOINT_RESTORE */
@@ -1936,6 +1942,9 @@ static int prctl_set_mm(int opt, unsigned long addr,
 	struct prctl_mm_map prctl_map;
 	struct vm_area_struct *vma;
 	int error;
+	struct range_rwlock range;
+
+	range_rwlock_init_full(&range);
 
 	if (arg5 || (arg4 && (opt != PR_SET_MM_AUXV &&
 			      opt != PR_SET_MM_MAP &&
@@ -1961,7 +1970,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
 
 	error = -EINVAL;
 
-	down_write(&mm->mmap_sem);
+	range_write_lock(&mm->mmap_rw_tree, &range);
 	vma = find_vma(mm, addr);
 
 	prctl_map.start_code	= mm->start_code;
@@ -2054,7 +2063,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
 
 	error = 0;
 out:
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	return error;
 }
 
@@ -2094,6 +2103,9 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 	struct task_struct *me = current;
 	unsigned char comm[sizeof(me->comm)];
 	long error;
+	struct range_rwlock range;
+
+	range_rwlock_init_full(&range);
 
 	error = security_task_prctl(option, arg2, arg3, arg4, arg5);
 	if (error != -ENOSYS)
@@ -2266,13 +2278,14 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 	case PR_SET_THP_DISABLE:
 		if (arg3 || arg4 || arg5)
 			return -EINVAL;
-		if (down_write_killable(&me->mm->mmap_sem))
+		if (range_write_lock_interruptible(&me->mm->mmap_rw_tree,
+						   &range))
 			return -EINTR;
 		if (arg2)
 			me->mm->def_flags |= VM_NOHUGEPAGE;
 		else
 			me->mm->def_flags &= ~VM_NOHUGEPAGE;
-		up_write(&me->mm->mmap_sem);
+		range_write_unlock(&me->mm->mmap_rw_tree, &range);
 		break;
 	case PR_MPX_ENABLE_MANAGEMENT:
 		if (arg2 || arg3 || arg4 || arg5)
diff --git a/kernel/trace/trace_output.c b/kernel/trace/trace_output.c
index 02a4aeb22c47..ad8b11c47855 100644
--- a/kernel/trace/trace_output.c
+++ b/kernel/trace/trace_output.c
@@ -380,6 +380,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
 	struct file *file = NULL;
 	unsigned long vmstart = 0;
 	int ret = 1;
+	struct range_rwlock range;
 
 	if (s->full)
 		return 0;
@@ -387,7 +388,8 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
 	if (mm) {
 		const struct vm_area_struct *vma;
 
-		down_read(&mm->mmap_sem);
+		range_rwlock_init_full(&range);
+		range_read_lock(&mm->mmap_rw_tree, &range);
 		vma = find_vma(mm, ip);
 		if (vma) {
 			file = vma->vm_file;
@@ -399,7 +401,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
 				trace_seq_printf(s, "[+0x%lx]",
 						 ip - vmstart);
 		}
-		up_read(&mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, &range);
 	}
 	if (ret && ((sym_flags & TRACE_ITER_SYM_ADDR) || !file))
 		trace_seq_printf(s, " <" IP_FMT ">", ip);
diff --git a/mm/filemap.c b/mm/filemap.c
index 3a5945f2fd3c..50518a2f8dde 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1063,7 +1063,7 @@ int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 		if (flags & FAULT_FLAG_RETRY_NOWAIT)
 			return 0;
 
-		up_read(&mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, range);
 		if (flags & FAULT_FLAG_KILLABLE)
 			wait_on_page_locked_killable(page);
 		else
@@ -1075,7 +1075,7 @@ int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 
 			ret = __lock_page_killable(page);
 			if (ret) {
-				up_read(&mm->mmap_sem);
+				range_read_unlock(&mm->mmap_rw_tree, range);
 				return 0;
 			}
 		} else
diff --git a/mm/frame_vector.c b/mm/frame_vector.c
index 579d1cbe039c..ea0014a513a0 100644
--- a/mm/frame_vector.c
+++ b/mm/frame_vector.c
@@ -35,6 +35,7 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
+	struct range_rwlock range;
 	int ret = 0;
 	int err;
 	int locked;
@@ -45,7 +46,8 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 	if (WARN_ON_ONCE(nr_frames > vec->nr_allocated))
 		nr_frames = vec->nr_allocated;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	locked = 1;
 	vma = find_vma_intersection(mm, start, start + 1);
 	if (!vma) {
@@ -56,7 +58,8 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 		vec->got_ref = true;
 		vec->is_pfns = false;
 		ret = get_user_pages_locked(start, nr_frames,
-			gup_flags, (struct page **)(vec->ptrs), &locked, NULL);
+			gup_flags, (struct page **)(vec->ptrs),
+			&locked, &range);
 		goto out;
 	}
 
@@ -85,7 +88,7 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 	} while (vma && vma->vm_flags & (VM_IO | VM_PFNMAP));
 out:
 	if (locked)
-		up_read(&mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, &range);
 	if (!ret)
 		ret = -EFAULT;
 	if (ret > 0)
diff --git a/mm/gup.c b/mm/gup.c
index ad83cfa38649..218cc0b8c032 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -735,7 +735,7 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	}
 
 	if (ret & VM_FAULT_RETRY) {
-		down_read(&mm->mmap_sem);
+		range_read_lock(&mm->mmap_rw_tree, range);
 		if (!(fault_flags & FAULT_FLAG_TRIED)) {
 			*unlocked = true;
 			fault_flags &= ~FAULT_FLAG_ALLOW_RETRY;
@@ -819,7 +819,7 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 		 */
 		*locked = 1;
 		lock_dropped = true;
-		down_read(&mm->mmap_sem);
+		range_read_lock(&mm->mmap_rw_tree, range);
 		ret = __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
 				       pages, NULL, NULL, range);
 		if (ret != 1) {
@@ -840,7 +840,7 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 		 * We must let the caller know we temporarily dropped the lock
 		 * and so the critical section protected by it was lost.
 		 */
-		up_read(&mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, range);
 		*locked = 0;
 	}
 	return pages_done;
@@ -892,12 +892,14 @@ static __always_inline long __get_user_pages_unlocked(struct task_struct *tsk,
 {
 	long ret;
 	int locked = 1;
+	struct range_rwlock range;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	ret = __get_user_pages_locked(tsk, mm, start, nr_pages, pages, NULL,
-				      &locked, false, NULL, gup_flags);
+				      &locked, false, &range, gup_flags);
 	if (locked)
-		up_read(&mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, &range);
 	return ret;
 }
 
@@ -1081,6 +1083,7 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 	struct vm_area_struct *vma = NULL;
 	int locked = 0;
 	long ret = 0;
+	struct range_rwlock range;
 
 	VM_BUG_ON(start & ~PAGE_MASK);
 	VM_BUG_ON(len != PAGE_ALIGN(len));
@@ -1093,7 +1096,8 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 		 */
 		if (!locked) {
 			locked = 1;
-			down_read(&mm->mmap_sem);
+			range_rwlock_init_full(&range);
+			range_read_lock(&mm->mmap_rw_tree, &range);
 			vma = find_vma(mm, nstart);
 		} else if (nstart >= vma->vm_end)
 			vma = vma->vm_next;
@@ -1114,7 +1118,7 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 		 * if the vma was already munlocked.
 		 */
 		ret = populate_vma_page_range(vma, nstart, nend, &locked,
-					      NULL);
+					      &range);
 		if (ret < 0) {
 			if (ignore_errors) {
 				ret = 0;
@@ -1126,7 +1130,7 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 		ret = 0;
 	}
 	if (locked)
-		up_read(&mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, &range);
 	return ret;	/* 0 or negative error code */
 }
 
diff --git a/mm/init-mm.c b/mm/init-mm.c
index 975e49f00f34..7d980728ba26 100644
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -19,7 +19,7 @@ struct mm_struct init_mm = {
 	.pgd		= swapper_pg_dir,
 	.mm_users	= ATOMIC_INIT(2),
 	.mm_count	= ATOMIC_INIT(1),
-	.mmap_sem	= __RWSEM_INITIALIZER(init_mm.mmap_sem),
+	.mmap_rw_tree	= __RANGE_RWLOCK_TREE_INITIALIZER(init_mm.mmap_rw_tree),
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
 	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
 	.user_ns	= &init_user_ns,
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index d2b2a06f7853..2e40c4449166 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -453,6 +453,9 @@ void __khugepaged_exit(struct mm_struct *mm)
 {
 	struct mm_slot *mm_slot;
 	int free = 0;
+	struct range_rwlock range;
+
+	range_rwlock_init_full(&range);
 
 	spin_lock(&khugepaged_mm_lock);
 	mm_slot = get_mm_slot(mm);
@@ -476,8 +479,8 @@ void __khugepaged_exit(struct mm_struct *mm)
 		 * khugepaged has finished working on the pagetables
 		 * under the mmap_sem.
 		 */
-		down_write(&mm->mmap_sem);
-		up_write(&mm->mmap_sem);
+		range_write_lock(&mm->mmap_rw_tree, &range);
+		range_write_unlock(&mm->mmap_rw_tree, &range);
 	}
 }
 
@@ -904,7 +907,7 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 
 		/* do_swap_page returns VM_FAULT_RETRY with released mmap_sem */
 		if (ret & VM_FAULT_RETRY) {
-			down_read(&mm->mmap_sem);
+			range_read_lock(&mm->mmap_rw_tree, range);
 			if (hugepage_vma_revalidate(mm, address, &vmf.vma)) {
 				/* vma is no longer available, don't continue to swapin */
 				trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
@@ -956,7 +959,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * sync compaction, and we do not need to hold the mmap_sem during
 	 * that. We will recheck the vma after taking it again in write mode.
 	 */
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, range);
 	new_page = khugepaged_alloc_page(hpage, gfp, node);
 	if (!new_page) {
 		result = SCAN_ALLOC_HUGE_PAGE_FAIL;
@@ -968,11 +971,11 @@ static void collapse_huge_page(struct mm_struct *mm,
 		goto out_nolock;
 	}
 
-	down_read(&mm->mmap_sem);
+	range_read_lock(&mm->mmap_rw_tree, range);
 	result = hugepage_vma_revalidate(mm, address, &vma);
 	if (result) {
 		mem_cgroup_cancel_charge(new_page, memcg, true);
-		up_read(&mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, range);
 		goto out_nolock;
 	}
 
@@ -980,7 +983,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	if (!pmd) {
 		result = SCAN_PMD_NULL;
 		mem_cgroup_cancel_charge(new_page, memcg, true);
-		up_read(&mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, range);
 		goto out_nolock;
 	}
 
@@ -992,17 +995,17 @@ static void collapse_huge_page(struct mm_struct *mm,
 	if (!__collapse_huge_page_swapin(mm, vma, address, pmd, referenced,
 					 range)) {
 		mem_cgroup_cancel_charge(new_page, memcg, true);
-		up_read(&mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, range);
 		goto out_nolock;
 	}
 
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, range);
 	/*
 	 * Prevent all access to pagetables with the exception of
 	 * gup_fast later handled by the ptep_clear_flush and the VM
 	 * handled by the anon_vma lock + PG_lock.
 	 */
-	down_write(&mm->mmap_sem);
+	range_write_lock(&mm->mmap_rw_tree, range);
 	result = hugepage_vma_revalidate(mm, address, &vma);
 	if (result)
 		goto out;
@@ -1085,7 +1088,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	khugepaged_pages_collapsed++;
 	result = SCAN_SUCCEED;
 out_up_write:
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, range);
 out_nolock:
 	trace_mm_collapse_huge_page(mm, isolated, result);
 	return;
@@ -1249,6 +1252,9 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 	struct vm_area_struct *vma;
 	unsigned long addr;
 	pmd_t *pmd, _pmd;
+	struct range_rwlock range;
+
+	range_rwlock_init_full(&range); /* XXX finer grain doable here */
 
 	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
@@ -1269,12 +1275,12 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 		 * re-fault. Not ideal, but it's more important to not disturb
 		 * the system too much.
 		 */
-		if (down_write_trylock(&vma->vm_mm->mmap_sem)) {
+		if (range_write_trylock(&vma->vm_mm->mmap_rw_tree, &range)) {
 			spinlock_t *ptl = pmd_lock(vma->vm_mm, pmd);
 			/* assume page table is clear */
 			_pmd = pmdp_collapse_flush(vma, addr, pmd);
 			spin_unlock(ptl);
-			up_write(&vma->vm_mm->mmap_sem);
+			range_write_unlock(&vma->vm_mm->mmap_rw_tree, &range);
 			atomic_long_dec(&vma->vm_mm->nr_ptes);
 			pte_free(vma->vm_mm, pmd_pgtable(_pmd));
 		}
@@ -1664,6 +1670,9 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	int progress = 0;
+	struct range_rwlock range;
+
+	range_rwlock_init_full(&range); /* XXX is finer grain doable here ? */
 
 	VM_BUG_ON(!pages);
 	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&khugepaged_mm_lock));
@@ -1679,7 +1688,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 	spin_unlock(&khugepaged_mm_lock);
 
 	mm = mm_slot->mm;
-	down_read(&mm->mmap_sem);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	if (unlikely(khugepaged_test_exit(mm)))
 		vma = NULL;
 	else
@@ -1725,7 +1734,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 				if (!shmem_huge_enabled(vma))
 					goto skip;
 				file = get_file(vma->vm_file);
-				up_read(&mm->mmap_sem);
+				range_read_unlock(&mm->mmap_rw_tree, &range);
 				ret = 1;
 				khugepaged_scan_shmem(mm, file->f_mapping,
 						pgoff, hpage);
@@ -1733,7 +1742,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 			} else {
 				ret = khugepaged_scan_pmd(mm, vma,
 						khugepaged_scan.address,
-						hpage, NULL);
+						hpage, &range);
 			}
 			/* move to next address */
 			khugepaged_scan.address += HPAGE_PMD_SIZE;
@@ -1746,7 +1755,8 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 		}
 	}
 breakouterloop:
-	up_read(&mm->mmap_sem); /* exit_mmap will destroy ptes after this */
+	range_read_unlock(&mm->mmap_rw_tree,
+			  &range); /* exit_mmap will destroy ptes after this */
 breakouterloop_mmap_sem:
 
 	spin_lock(&khugepaged_mm_lock);
diff --git a/mm/ksm.c b/mm/ksm.c
index c419f53912ba..f4e16b6f960e 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -447,18 +447,20 @@ static void break_cow(struct rmap_item *rmap_item)
 	struct mm_struct *mm = rmap_item->mm;
 	unsigned long addr = rmap_item->address;
 	struct vm_area_struct *vma;
+	struct range_rwlock range;
 
+	range_rwlock_init_full(&range);
 	/*
 	 * It is not an accident that whenever we want to break COW
 	 * to undo, we also need to drop a reference to the anon_vma.
 	 */
 	put_anon_vma(rmap_item->anon_vma);
 
-	down_read(&mm->mmap_sem);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	vma = find_mergeable_vma(mm, addr);
 	if (vma)
 		break_ksm(vma, addr);
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 }
 
 static struct page *get_mergeable_page(struct rmap_item *rmap_item)
@@ -467,8 +469,10 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 	unsigned long addr = rmap_item->address;
 	struct vm_area_struct *vma;
 	struct page *page;
+	struct range_rwlock range;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	vma = find_mergeable_vma(mm, addr);
 	if (!vma)
 		goto out;
@@ -484,7 +488,7 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 out:
 		page = NULL;
 	}
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 	return page;
 }
 
@@ -775,7 +779,9 @@ static int unmerge_and_remove_all_rmap_items(void)
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	int err = 0;
+	struct range_rwlock range;
 
+	range_rwlock_init_full(&range);
 	spin_lock(&ksm_mmlist_lock);
 	ksm_scan.mm_slot = list_entry(ksm_mm_head.mm_list.next,
 						struct mm_slot, mm_list);
@@ -784,7 +790,7 @@ static int unmerge_and_remove_all_rmap_items(void)
 	for (mm_slot = ksm_scan.mm_slot;
 			mm_slot != &ksm_mm_head; mm_slot = ksm_scan.mm_slot) {
 		mm = mm_slot->mm;
-		down_read(&mm->mmap_sem);
+		range_read_lock(&mm->mmap_rw_tree, &range);
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
 			if (ksm_test_exit(mm))
 				break;
@@ -797,7 +803,7 @@ static int unmerge_and_remove_all_rmap_items(void)
 		}
 
 		remove_trailing_rmap_items(mm_slot, &mm_slot->rmap_list);
-		up_read(&mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, &range);
 
 		spin_lock(&ksm_mmlist_lock);
 		ksm_scan.mm_slot = list_entry(mm_slot->mm_list.next,
@@ -820,7 +826,7 @@ static int unmerge_and_remove_all_rmap_items(void)
 	return 0;
 
 error:
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 	spin_lock(&ksm_mmlist_lock);
 	ksm_scan.mm_slot = &ksm_mm_head;
 	spin_unlock(&ksm_mmlist_lock);
@@ -1088,8 +1094,11 @@ static int try_to_merge_with_ksm_page(struct rmap_item *rmap_item,
 	struct mm_struct *mm = rmap_item->mm;
 	struct vm_area_struct *vma;
 	int err = -EFAULT;
+	struct range_rwlock range;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range); /* XXX finer grain required here */
+
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	vma = find_mergeable_vma(mm, rmap_item->address);
 	if (!vma)
 		goto out;
@@ -1105,7 +1114,7 @@ static int try_to_merge_with_ksm_page(struct rmap_item *rmap_item,
 	rmap_item->anon_vma = vma->anon_vma;
 	get_anon_vma(vma->anon_vma);
 out:
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 	return err;
 }
 
@@ -1579,6 +1588,9 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 	struct vm_area_struct *vma;
 	struct rmap_item *rmap_item;
 	int nid;
+	struct range_rwlock range;
+
+	range_rwlock_init_full(&range);	/* XXX finer grain required here */
 
 	if (list_empty(&ksm_mm_head.mm_list))
 		return NULL;
@@ -1635,7 +1647,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 	}
 
 	mm = slot->mm;
-	down_read(&mm->mmap_sem);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	if (ksm_test_exit(mm))
 		vma = NULL;
 	else
@@ -1669,7 +1681,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 					ksm_scan.address += PAGE_SIZE;
 				} else
 					put_page(*page);
-				up_read(&mm->mmap_sem);
+				range_read_unlock(&mm->mmap_rw_tree, &range);
 				return rmap_item;
 			}
 			put_page(*page);
@@ -1707,10 +1719,10 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 
 		free_mm_slot(slot);
 		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
-		up_read(&mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, &range);
 		mmdrop(mm);
 	} else {
-		up_read(&mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, &range);
 		/*
 		 * up_read(&mm->mmap_sem) first because after
 		 * spin_unlock(&ksm_mmlist_lock) run, the "mm" may
@@ -1869,6 +1881,9 @@ void __ksm_exit(struct mm_struct *mm)
 {
 	struct mm_slot *mm_slot;
 	int easy_to_free = 0;
+	struct range_rwlock range;
+
+	range_rwlock_init_full(&range);
 
 	/*
 	 * This process is exiting: if it's straightforward (as is the
@@ -1898,8 +1913,8 @@ void __ksm_exit(struct mm_struct *mm)
 		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
 		mmdrop(mm);
 	} else if (mm_slot) {
-		down_write(&mm->mmap_sem);
-		up_write(&mm->mmap_sem);
+		range_write_lock(&mm->mmap_rw_tree, &range);
+		range_write_unlock(&mm->mmap_rw_tree, &range);
 	}
 }
 
diff --git a/mm/madvise.c b/mm/madvise.c
index 7eb62e3995ca..05442bb8b9c3 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -517,7 +517,7 @@ static long madvise_dontneed(struct vm_area_struct *vma,
 	if (!userfaultfd_remove(vma, start, end, range)) {
 		*prev = NULL; /* mmap_sem has been dropped, prev is stale */
 
-		down_read(&current->mm->mmap_sem);
+		range_read_lock(&current->mm->mmap_rw_tree, range);
 		vma = find_vma(current->mm, start);
 		if (!vma)
 			return -ENOMEM;
@@ -560,8 +560,9 @@ static long madvise_dontneed(struct vm_area_struct *vma,
  * This is effectively punching a hole into the middle of a file.
  */
 static long madvise_remove(struct vm_area_struct *vma,
-				struct vm_area_struct **prev,
-				unsigned long start, unsigned long end)
+			   struct vm_area_struct **prev,
+			   unsigned long start, unsigned long end,
+			   struct range_rwlock *range)
 {
 	loff_t offset;
 	int error;
@@ -591,15 +592,15 @@ static long madvise_remove(struct vm_area_struct *vma,
 	 * mmap_sem.
 	 */
 	get_file(f);
-	if (userfaultfd_remove(vma, start, end, NULL) {
+	if (userfaultfd_remove(vma, start, end, range)) {
 		/* mmap_sem was not released by userfaultfd_remove() */
-		up_read(&current->mm->mmap_sem);
+		range_read_unlock(&current->mm->mmap_rw_tree, range);
 	}
 	error = vfs_fallocate(f,
 				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
 				offset, end - start);
 	fput(f);
-	down_read(&current->mm->mmap_sem);
+	range_read_lock(&current->mm->mmap_rw_tree, range);
 	return error;
 }
 
@@ -649,7 +650,7 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 {
 	switch (behavior) {
 	case MADV_REMOVE:
-		return madvise_remove(vma, prev, start, end);
+		return madvise_remove(vma, prev, start, end, range);
 	case MADV_WILLNEED:
 		return madvise_willneed(vma, prev, start, end);
 	case MADV_FREE:
@@ -762,6 +763,7 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 	int write;
 	size_t len;
 	struct blk_plug plug;
+	struct range_rwlock range;
 
 #ifdef CONFIG_MEMORY_FAILURE
 	if (behavior == MADV_HWPOISON || behavior == MADV_SOFT_OFFLINE)
@@ -786,12 +788,14 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 	if (end == start)
 		return error;
 
+	range_rwlock_init_full(&range);
 	write = madvise_need_mmap_write(behavior);
 	if (write) {
-		if (down_write_killable(&current->mm->mmap_sem))
+		if (range_write_lock_interruptible(&current->mm->mmap_rw_tree,
+						   &range))
 			return -EINTR;
 	} else {
-		down_read(&current->mm->mmap_sem);
+		range_read_lock(&current->mm->mmap_rw_tree, &range);
 	}
 
 	/*
@@ -824,7 +828,7 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 			tmp = end;
 
 		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
-		error = madvise_vma(vma, &prev, start, tmp, behavior, NULL);
+		error = madvise_vma(vma, &prev, start, tmp, behavior, &range);
 		if (error)
 			goto out;
 		start = tmp;
@@ -841,9 +845,9 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 out:
 	blk_finish_plug(&plug);
 	if (write)
-		up_write(&current->mm->mmap_sem);
+		range_write_unlock(&current->mm->mmap_rw_tree, &range);
 	else
-		up_read(&current->mm->mmap_sem);
+		range_read_unlock(&current->mm->mmap_rw_tree, &range);
 
 	return error;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2bd7541d7c11..cfa5e6623d4e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4687,15 +4687,17 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
 static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 {
 	unsigned long precharge;
-
 	struct mm_walk mem_cgroup_count_precharge_walk = {
 		.pmd_entry = mem_cgroup_count_precharge_pte_range,
 		.mm = mm,
 	};
-	down_read(&mm->mmap_sem);
+	struct range_rwlock range;
+
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	walk_page_range(0, mm->highest_vm_end,
 			&mem_cgroup_count_precharge_walk);
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 
 	precharge = mc.precharge;
 	mc.precharge = 0;
@@ -4956,7 +4958,9 @@ static void mem_cgroup_move_charge(void)
 		.pmd_entry = mem_cgroup_move_charge_pte_range,
 		.mm = mc.mm,
 	};
+	struct range_rwlock range;
 
+	range_rwlock_init_full(&range);
 	lru_add_drain_all();
 	/*
 	 * Signal lock_page_memcg() to take the memcg's move_lock
@@ -4966,7 +4970,7 @@ static void mem_cgroup_move_charge(void)
 	atomic_inc(&mc.from->moving_account);
 	synchronize_rcu();
 retry:
-	if (unlikely(!down_read_trylock(&mc.mm->mmap_sem))) {
+	if (unlikely(!range_read_trylock(&mc.mm->mmap_rw_tree, &range))) {
 		/*
 		 * Someone who are holding the mmap_sem might be waiting in
 		 * waitq. So we cancel all extra charges, wake up all waiters,
@@ -4984,7 +4988,7 @@ static void mem_cgroup_move_charge(void)
 	 */
 	walk_page_range(0, mc.mm->highest_vm_end, &mem_cgroup_move_charge_walk);
 
-	up_read(&mc.mm->mmap_sem);
+	range_read_unlock(&mc.mm->mmap_rw_tree, &range);
 	atomic_dec(&mc.from->moving_account);
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index 9adb7d4396bf..45fad119fc21 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1630,12 +1630,16 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
 int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 			struct page *page)
 {
+	struct range_rwlock range;
+
+	range_rwlock_init_full(&range);
+
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return -EFAULT;
 	if (!page_count(page))
 		return -EINVAL;
 	if (!(vma->vm_flags & VM_MIXEDMAP)) {
-		BUG_ON(down_read_trylock(&vma->vm_mm->mmap_sem));
+		BUG_ON(range_read_trylock(&vma->vm_mm->mmap_rw_tree, &range));
 		BUG_ON(vma->vm_flags & VM_PFNMAP);
 		vma->vm_flags |= VM_MIXEDMAP;
 	}
@@ -4160,8 +4164,10 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 	struct vm_area_struct *vma;
 	void *old_buf = buf;
 	int write = gup_flags & FOLL_WRITE;
+	struct range_rwlock range;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	/* ignore errors, just check how much was successfully transferred */
 	while (len) {
 		int bytes, ret, offset;
@@ -4169,7 +4175,8 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		struct page *page = NULL;
 
 		ret = get_user_pages_remote(tsk, mm, addr, 1,
-					    gup_flags, &page, &vma, NULL, NULL);
+					    gup_flags, &page, &vma, NULL,
+					    NULL /* mm range lock untouched */);
 		if (ret <= 0) {
 #ifndef CONFIG_HAVE_IOREMAP_PROT
 			break;
@@ -4210,7 +4217,7 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		buf += bytes;
 		addr += bytes;
 	}
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 
 	return buf - old_buf;
 }
@@ -4261,6 +4268,7 @@ void print_vma_addr(char *prefix, unsigned long ip)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
+	struct range_rwlock range;
 
 	/*
 	 * Do not print if we are in atomic
@@ -4269,7 +4277,8 @@ void print_vma_addr(char *prefix, unsigned long ip)
 	if (preempt_count())
 		return;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	vma = find_vma(mm, ip);
 	if (vma && vma->vm_file) {
 		struct file *f = vma->vm_file;
@@ -4286,7 +4295,7 @@ void print_vma_addr(char *prefix, unsigned long ip)
 			free_page((unsigned long)buf);
 		}
 	}
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 }
 
 #if defined(CONFIG_PROVE_LOCKING) || defined(CONFIG_DEBUG_ATOMIC_SLEEP)
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 0658c7240e54..69e3b5bb9406 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -445,11 +445,13 @@ void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new,
 void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
 {
 	struct vm_area_struct *vma;
+	struct range_rwlock range;
 
-	down_write(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&mm->mmap_rw_tree, &range);
 	for (vma = mm->mmap; vma; vma = vma->vm_next)
 		mpol_rebind_policy(vma->vm_policy, new, MPOL_REBIND_ONCE);
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 }
 
 static const struct mempolicy_operations mpol_ops[MPOL_MAX] = {
@@ -871,6 +873,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma = NULL;
 	struct mempolicy *pol = current->mempolicy;
+	struct range_rwlock range;
 
 	if (flags &
 		~(unsigned long)(MPOL_F_NODE|MPOL_F_ADDR|MPOL_F_MEMS_ALLOWED))
@@ -892,10 +895,11 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 		 * vma/shared policy at addr is NULL.  We
 		 * want to return MPOL_DEFAULT in this case.
 		 */
-		down_read(&mm->mmap_sem);
+		range_rwlock_init_full(&range);
+		range_read_lock(&mm->mmap_rw_tree, &range);
 		vma = find_vma_intersection(mm, addr, addr+1);
 		if (!vma) {
-			up_read(&mm->mmap_sem);
+			range_read_unlock(&mm->mmap_rw_tree, &range);
 			return -EFAULT;
 		}
 		if (vma->vm_ops && vma->vm_ops->get_policy)
@@ -932,7 +936,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 	}
 
 	if (vma) {
-		up_read(&current->mm->mmap_sem);
+		range_read_unlock(&current->mm->mmap_rw_tree, &range);
 		vma = NULL;
 	}
 
@@ -950,7 +954,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
  out:
 	mpol_cond_put(pol);
 	if (vma)
-		up_read(&current->mm->mmap_sem);
+		range_read_unlock(&current->mm->mmap_rw_tree, &range);
 	return err;
 }
 
@@ -1028,12 +1032,14 @@ int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
 	int busy = 0;
 	int err;
 	nodemask_t tmp;
+	struct range_rwlock range;
 
 	err = migrate_prep();
 	if (err)
 		return err;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 
 	/*
 	 * Find a 'source' bit set in 'tmp' whose corresponding 'dest'
@@ -1114,7 +1120,7 @@ int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
 		if (err < 0)
 			break;
 	}
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 	if (err < 0)
 		return err;
 	return busy;
@@ -1178,7 +1184,9 @@ static long do_mbind(unsigned long start, unsigned long len,
 	unsigned long end;
 	int err;
 	LIST_HEAD(pagelist);
+	struct range_rwlock range;
 
+	range_rwlock_init_full(&range);
 	if (flags & ~(unsigned long)MPOL_MF_VALID)
 		return -EINVAL;
 	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
@@ -1225,12 +1233,12 @@ static long do_mbind(unsigned long start, unsigned long len,
 	{
 		NODEMASK_SCRATCH(scratch);
 		if (scratch) {
-			down_write(&mm->mmap_sem);
+			range_write_lock(&mm->mmap_rw_tree, &range);
 			task_lock(current);
 			err = mpol_set_nodemask(new, nmask, scratch);
 			task_unlock(current);
 			if (err)
-				up_write(&mm->mmap_sem);
+				range_write_unlock(&mm->mmap_rw_tree, &range);
 		} else
 			err = -ENOMEM;
 		NODEMASK_SCRATCH_FREE(scratch);
@@ -1259,7 +1267,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 	} else
 		putback_movable_pages(&pagelist);
 
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
  mpol_out:
 	mpol_put(new);
 	return err;
diff --git a/mm/migrate.c b/mm/migrate.c
index ed97c2c14fa8..0ee1409c1723 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1405,8 +1405,10 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 	int err;
 	struct page_to_node *pp;
 	LIST_HEAD(pagelist);
+	struct range_rwlock range;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 
 	/*
 	 * Build a list of pages to migrate
@@ -1477,7 +1479,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 			putback_movable_pages(&pagelist);
 	}
 
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 	return err;
 }
 
@@ -1575,8 +1577,10 @@ static void do_pages_stat_array(struct mm_struct *mm, unsigned long nr_pages,
 				const void __user **pages, int *status)
 {
 	unsigned long i;
+	struct range_rwlock range;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 
 	for (i = 0; i < nr_pages; i++) {
 		unsigned long addr = (unsigned long)(*pages);
@@ -1603,7 +1607,7 @@ static void do_pages_stat_array(struct mm_struct *mm, unsigned long nr_pages,
 		status++;
 	}
 
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 }
 
 /*
diff --git a/mm/mincore.c b/mm/mincore.c
index c5687c45c326..3d455eb4fa35 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -226,6 +226,7 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
 	long retval;
 	unsigned long pages;
 	unsigned char *tmp;
+	struct range_rwlock range;
 
 	/* Check the start address: needs to be page-aligned.. */
 	if (start & ~PAGE_MASK)
@@ -252,9 +253,10 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
 		 * Do at most PAGE_SIZE entries per iteration, due to
 		 * the temporary buffer size.
 		 */
-		down_read(&current->mm->mmap_sem);
+		range_rwlock_init_full(&range);
+		range_read_lock(&current->mm->mmap_rw_tree, &range);
 		retval = do_mincore(start, min(pages, PAGE_SIZE), tmp);
-		up_read(&current->mm->mmap_sem);
+		range_read_unlock(&current->mm->mmap_rw_tree, &range);
 
 		if (retval <= 0)
 			break;
diff --git a/mm/mlock.c b/mm/mlock.c
index 0dd9ca18e19e..92028e885ba1 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -668,6 +668,7 @@ static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t fla
 	unsigned long locked;
 	unsigned long lock_limit;
 	int error = -ENOMEM;
+	struct range_rwlock range;
 
 	if (!can_do_mlock())
 		return -EPERM;
@@ -681,7 +682,8 @@ static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t fla
 	lock_limit >>= PAGE_SHIFT;
 	locked = len >> PAGE_SHIFT;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	range_rwlock_init_full(&range);
+	if (range_write_lock_interruptible(&current->mm->mmap_rw_tree, &range))
 		return -EINTR;
 
 	locked += current->mm->locked_vm;
@@ -700,7 +702,7 @@ static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t fla
 	if ((locked <= lock_limit) || capable(CAP_IPC_LOCK))
 		error = apply_vma_lock_flags(start, len, flags);
 
-	up_write(&current->mm->mmap_sem);
+	range_write_unlock(&current->mm->mmap_rw_tree, &range);
 	if (error)
 		return error;
 
@@ -731,14 +733,16 @@ SYSCALL_DEFINE3(mlock2, unsigned long, start, size_t, len, int, flags)
 SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
 {
 	int ret;
+	struct range_rwlock range;
 
 	len = PAGE_ALIGN(len + (offset_in_page(start)));
 	start &= PAGE_MASK;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	range_rwlock_init_full(&range);
+	if (range_write_lock_interruptible(&current->mm->mmap_rw_tree, &range))
 		return -EINTR;
 	ret = apply_vma_lock_flags(start, len, 0);
-	up_write(&current->mm->mmap_sem);
+	range_write_unlock(&current->mm->mmap_rw_tree, &range);
 
 	return ret;
 }
@@ -793,6 +797,9 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 {
 	unsigned long lock_limit;
 	int ret;
+	struct range_rwlock range;
+
+	range_rwlock_init_full(&range);
 
 	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE | MCL_ONFAULT)))
 		return -EINVAL;
@@ -806,14 +813,14 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	lock_limit = rlimit(RLIMIT_MEMLOCK);
 	lock_limit >>= PAGE_SHIFT;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	if (range_write_lock_interruptible(&current->mm->mmap_rw_tree, &range))
 		return -EINTR;
 
 	ret = -ENOMEM;
 	if (!(flags & MCL_CURRENT) || (current->mm->total_vm <= lock_limit) ||
 	    capable(CAP_IPC_LOCK))
 		ret = apply_mlockall_flags(flags);
-	up_write(&current->mm->mmap_sem);
+	range_write_unlock(&current->mm->mmap_rw_tree, &range);
 	if (!ret && (flags & MCL_CURRENT))
 		mm_populate(0, TASK_SIZE);
 
@@ -823,11 +830,13 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 SYSCALL_DEFINE0(munlockall)
 {
 	int ret;
+	struct range_rwlock range;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	range_rwlock_init_full(&range);
+	if (range_write_lock_interruptible(&current->mm->mmap_rw_tree, &range))
 		return -EINTR;
 	ret = apply_mlockall_flags(0);
-	up_write(&current->mm->mmap_sem);
+	range_write_unlock(&current->mm->mmap_rw_tree, &range);
 	return ret;
 }
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 4df13e633e92..e31d2bb6a245 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -186,8 +186,11 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 	unsigned long min_brk;
 	bool populate;
 	LIST_HEAD(uf);
+	struct range_rwlock range;
 
-	if (down_write_killable(&mm->mmap_sem))
+	range_rwlock_init_full(&range); /* we should do better here */
+
+	if (range_write_lock_interruptible(&mm->mmap_rw_tree, &range))
 		return -EINTR;
 
 #ifdef CONFIG_COMPAT_BRK
@@ -239,7 +242,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 set_brk:
 	mm->brk = brk;
 	populate = newbrk > oldbrk && (mm->def_flags & VM_LOCKED) != 0;
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	userfaultfd_unmap_complete(mm, &uf);
 	if (populate)
 		mm_populate(oldbrk, newbrk - oldbrk);
@@ -247,7 +250,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 
 out:
 	retval = mm->brk;
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	return retval;
 }
 
@@ -2681,12 +2684,15 @@ int vm_munmap(unsigned long start, size_t len)
 	int ret;
 	struct mm_struct *mm = current->mm;
 	LIST_HEAD(uf);
+	struct range_rwlock range;
+
+	range_rwlock_init_full(&range);
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (range_write_lock_interruptible(&mm->mmap_rw_tree, &range))
 		return -EINTR;
 
 	ret = do_munmap(mm, start, len, &uf);
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	userfaultfd_unmap_complete(mm, &uf);
 	return ret;
 }
@@ -2711,6 +2717,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	unsigned long populate = 0;
 	unsigned long ret = -EINVAL;
 	struct file *file;
+	struct range_rwlock range;
 
 	pr_warn_once("%s (%d) uses deprecated remap_file_pages() syscall. See Documentation/vm/remap_file_pages.txt.\n",
 		     current->comm, current->pid);
@@ -2727,7 +2734,8 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	if (pgoff + (size >> PAGE_SHIFT) < pgoff)
 		return ret;
 
-	if (down_write_killable(&mm->mmap_sem))
+	range_rwlock_init_full(&range);
+	if (range_write_lock_interruptible(&mm->mmap_rw_tree, &range))
 		return -EINTR;
 
 	vma = find_vma(mm, start);
@@ -2790,7 +2798,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 			prot, flags, pgoff, &populate, NULL);
 	fput(file);
 out:
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	if (populate)
 		mm_populate(ret, populate);
 	if (!IS_ERR_VALUE(ret))
@@ -2801,9 +2809,12 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 static inline void verify_mm_writelocked(struct mm_struct *mm)
 {
 #ifdef CONFIG_DEBUG_VM
-	if (unlikely(down_read_trylock(&mm->mmap_sem))) {
+	struct range_rwlock range;
+
+	range_rwlock_init_full(&range);
+	if (unlikely(range_read_trylock(&mm->mmap_rw_tree, &range))) {
 		WARN_ON(1);
-		up_read(&mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, &range);
 	}
 #endif
 }
@@ -2910,13 +2921,15 @@ int vm_brk_flags(unsigned long addr, unsigned long len, unsigned long flags)
 	int ret;
 	bool populate;
 	LIST_HEAD(uf);
+	struct range_rwlock range;
 
-	if (down_write_killable(&mm->mmap_sem))
+	range_rwlock_init_full(&range); /* XXXX apply finer grain lock */
+	if (range_write_lock_interruptible(&mm->mmap_rw_tree, &range))
 		return -EINTR;
 
 	ret = do_brk_flags(addr, len, flags, &uf);
 	populate = ((mm->def_flags & VM_LOCKED) != 0);
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	userfaultfd_unmap_complete(mm, &uf);
 	if (populate && !ret)
 		mm_populate(addr, len);
@@ -3359,8 +3372,10 @@ int mm_take_all_locks(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
 	struct anon_vma_chain *avc;
+	struct range_rwlock range;
 
-	BUG_ON(down_read_trylock(&mm->mmap_sem));
+	range_rwlock_init_full(&range);
+	BUG_ON(range_read_trylock(&mm->mmap_rw_tree, &range));
 
 	mutex_lock(&mm_all_locks_mutex);
 
@@ -3439,8 +3454,10 @@ void mm_drop_all_locks(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
 	struct anon_vma_chain *avc;
+	struct range_rwlock range;
 
-	BUG_ON(down_read_trylock(&mm->mmap_sem));
+	range_rwlock_init_full(&range);
+	BUG_ON(range_read_trylock(&mm->mmap_rw_tree, &range));
 	BUG_ON(!mutex_is_locked(&mm_all_locks_mutex));
 
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index a7652acd2ab9..1a61278116dc 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -249,7 +249,9 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 {
 	struct mmu_notifier_mm *mmu_notifier_mm;
 	int ret;
+	struct range_rwlock range;
 
+	range_rwlock_init_full(&range);
 	BUG_ON(atomic_read(&mm->mm_users) <= 0);
 
 	/*
@@ -264,7 +266,7 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 		goto out;
 
 	if (take_mmap_sem)
-		down_write(&mm->mmap_sem);
+		range_write_lock(&mm->mmap_rw_tree, &range);
 	ret = mm_take_all_locks(mm);
 	if (unlikely(ret))
 		goto out_clean;
@@ -293,7 +295,7 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 	mm_drop_all_locks(mm);
 out_clean:
 	if (take_mmap_sem)
-		up_write(&mm->mmap_sem);
+		range_write_unlock(&mm->mmap_rw_tree, &range);
 	kfree(mmu_notifier_mm);
 out:
 	BUG_ON(atomic_read(&mm->mm_users) <= 0);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index fef798619b06..fbafcc30b252 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -383,6 +383,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
 	const int grows = prot & (PROT_GROWSDOWN|PROT_GROWSUP);
 	const bool rier = (current->personality & READ_IMPLIES_EXEC) &&
 				(prot & PROT_READ);
+	struct range_rwlock range;
 
 	prot &= ~(PROT_GROWSDOWN|PROT_GROWSUP);
 	if (grows == (PROT_GROWSDOWN|PROT_GROWSUP)) /* can't be both */
@@ -401,7 +402,8 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
 
 	reqprot = prot;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	range_rwlock_init_full(&range);
+	if (range_write_lock_interruptible(&current->mm->mmap_rw_tree, &range))
 		return -EINTR;
 
 	/*
@@ -491,7 +493,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
 		prot = reqprot;
 	}
 out:
-	up_write(&current->mm->mmap_sem);
+	range_write_unlock(&current->mm->mmap_rw_tree, &range);
 	return error;
 }
 
@@ -513,6 +515,9 @@ SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
 {
 	int pkey;
 	int ret;
+	struct range_rwlock range;
+
+	range_rwlock_init_full(&range);
 
 	/* No flags supported yet. */
 	if (flags)
@@ -521,7 +526,7 @@ SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
 	if (init_val & ~PKEY_ACCESS_MASK)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
+	range_write_lock(&current->mm->mmap_rw_tree, &range);
 	pkey = mm_pkey_alloc(current->mm);
 
 	ret = -ENOSPC;
@@ -535,17 +540,19 @@ SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
 	}
 	ret = pkey;
 out:
-	up_write(&current->mm->mmap_sem);
+	range_write_unlock(&current->mm->mmap_rw_tree, &range);
 	return ret;
 }
 
 SYSCALL_DEFINE1(pkey_free, int, pkey)
 {
 	int ret;
+	struct range_rwlock range;
 
-	down_write(&current->mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&current->mm->mmap_rw_tree, &range);
 	ret = mm_pkey_free(current->mm, pkey);
-	up_write(&current->mm->mmap_sem);
+	range_write_unlock(&current->mm->mmap_rw_tree, &range);
 
 	/*
 	 * We could provie warnings or errors if any VMA still
diff --git a/mm/mremap.c b/mm/mremap.c
index cd8a1b199ef9..0565fa644da7 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -515,6 +515,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	bool locked = false;
 	struct vm_userfaultfd_ctx uf = NULL_VM_UFFD_CTX;
 	LIST_HEAD(uf_unmap);
+	struct range_rwlock range;
 
 	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
 		return ret;
@@ -536,7 +537,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	if (!new_len)
 		return ret;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	range_rwlock_init_full(&range); /* XXX should be finer grain */
+	if (range_write_lock_interruptible(&current->mm->mmap_rw_tree, &range))
 		return -EINTR;
 
 	if (flags & MREMAP_FIXED) {
@@ -618,7 +620,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 		vm_unacct_memory(charged);
 		locked = 0;
 	}
-	up_write(&current->mm->mmap_sem);
+	range_write_unlock(&current->mm->mmap_rw_tree, &range);
 	if (locked && new_len > old_len)
 		mm_populate(new_addr + old_len, new_len - old_len);
 	mremap_userfaultfd_complete(&uf, addr, new_addr, old_len);
diff --git a/mm/msync.c b/mm/msync.c
index 24e612fefa04..4e2554b2bc55 100644
--- a/mm/msync.c
+++ b/mm/msync.c
@@ -35,6 +35,7 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 	struct vm_area_struct *vma;
 	int unmapped_error = 0;
 	int error = -EINVAL;
+	struct range_rwlock range;
 
 	if (flags & ~(MS_ASYNC | MS_INVALIDATE | MS_SYNC))
 		goto out;
@@ -54,7 +55,8 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 	 * If the interval [start,end) covers some unmapped address ranges,
 	 * just ignore them, but return -ENOMEM at the end.
 	 */
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	vma = find_vma(mm, start);
 	for (;;) {
 		struct file *file;
@@ -85,12 +87,12 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 		if ((flags & MS_SYNC) && file &&
 				(vma->vm_flags & VM_SHARED)) {
 			get_file(file);
-			up_read(&mm->mmap_sem);
+			range_read_unlock(&mm->mmap_rw_tree, &range);
 			error = vfs_fsync_range(file, fstart, fend, 1);
 			fput(file);
 			if (error || start >= end)
 				goto out;
-			down_read(&mm->mmap_sem);
+			range_read_lock(&mm->mmap_rw_tree, &range);
 			vma = find_vma(mm, start);
 		} else {
 			if (start >= end) {
@@ -101,7 +103,7 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 		}
 	}
 out_unlock:
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 out:
 	return error ? : unmapped_error;
 }
diff --git a/mm/nommu.c b/mm/nommu.c
index 2d131b97a851..c75c0a2ac835 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -183,10 +183,13 @@ static long __get_user_pages_unlocked(struct task_struct *tsk,
 			unsigned int gup_flags)
 {
 	long ret;
-	down_read(&mm->mmap_sem);
+	struct range_rwlock range;
+
+	range_rwlock_init_full(range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	ret = __get_user_pages(tsk, mm, start, nr_pages, gup_flags, pages,
 				NULL, NULL);
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 	return ret;
 }
 
@@ -245,12 +248,14 @@ void *vmalloc_user(unsigned long size)
 			PAGE_KERNEL);
 	if (ret) {
 		struct vm_area_struct *vma;
+		struct range_rwlock range;
 
-		down_write(&current->mm->mmap_sem);
+		range_rwlock_init_full(&range);
+		range_write_lock(&current->mm->mmap_rw_tree, &range);
 		vma = find_vma(current->mm, (unsigned long)ret);
 		if (vma)
 			vma->vm_flags |= VM_USERMAP;
-		up_write(&current->mm->mmap_sem);
+		range_write_unlock(&current->mm->mmap_rw_tree, &range);
 	}
 
 	return ret;
@@ -1642,11 +1647,13 @@ EXPORT_SYMBOL(do_munmap);
 int vm_munmap(unsigned long addr, size_t len)
 {
 	struct mm_struct *mm = current->mm;
+	struct range_rwlock range;
 	int ret;
 
-	down_write(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&mm->mmap_rw_tree, &range);
 	ret = do_munmap(mm, addr, len, NULL);
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_rw_tree, &range);
 	return ret;
 }
 EXPORT_SYMBOL(vm_munmap);
@@ -1732,10 +1739,12 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 		unsigned long, new_addr)
 {
 	unsigned long ret;
+	struct range_rwlock range;
 
-	down_write(&current->mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_write_lock(&current->mm->mmap_rw_tree, &range);
 	ret = do_mremap(addr, old_len, new_len, flags, new_addr);
-	up_write(&current->mm->mmap_sem);
+	range_write_unlock(&current->mm->mmap_rw_tree, &range);
 	return ret;
 }
 
@@ -1814,9 +1823,11 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long addr, void *buf, int len, unsigned int gup_flags)
 {
 	struct vm_area_struct *vma;
+	struct range_rwlock range;
 	int write = gup_flags & FOLL_WRITE;
 
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 
 	/* the access must start within one of the target process's mappings */
 	vma = find_vma(mm, addr);
@@ -1838,7 +1849,7 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		len = 0;
 	}
 
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 
 	return len;
 }
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d083714a2bb9..c3a57e85ff22 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -471,6 +471,9 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
 	bool ret = true;
+	struct range_rwlock range;
+
+	range_rwlock_init_full(&range);
 
 	/*
 	 * We have to make sure to not race with the victim exit path
@@ -488,7 +491,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 */
 	mutex_lock(&oom_lock);
 
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!range_read_trylock(&mm->mmap_rw_tree, &range)) {
 		ret = false;
 		goto unlock_oom;
 	}
@@ -499,7 +502,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 * and delayed __mmput doesn't matter that much
 	 */
 	if (!mmget_not_zero(mm)) {
-		up_read(&mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, &range);
 		goto unlock_oom;
 	}
 
@@ -536,7 +539,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 			K(get_mm_counter(mm, MM_ANONPAGES)),
 			K(get_mm_counter(mm, MM_FILEPAGES)),
 			K(get_mm_counter(mm, MM_SHMEMPAGES)));
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 
 	/*
 	 * Drop our reference but make sure the mmput slow path is called from a
diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index fb4f2b96d488..d7d175c38500 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -90,6 +90,7 @@ static int process_vm_rw_single_vec(unsigned long addr,
 	unsigned long max_pages_per_loop = PVM_MAX_KMALLOC_PAGES
 		/ sizeof(struct pages *);
 	unsigned int flags = 0;
+	struct range_rwlock range;
 
 	/* Work out address and page range required */
 	if (len == 0)
@@ -109,12 +110,13 @@ static int process_vm_rw_single_vec(unsigned long addr,
 		 * access remotely because task/mm might not
 		 * current/current->mm
 		 */
-		down_read(&mm->mmap_sem);
+		range_rwlock_init_full(&range);
+		range_read_lock(&mm->mmap_rw_tree, &range);
 		pages = get_user_pages_remote(task, mm, pa, pages, flags,
 					      process_pages, NULL, &locked,
-					      NULL);
+					      &range);
 		if (locked)
-			up_read(&mm->mmap_sem);
+			range_read_unlock(&mm->mmap_rw_tree, &range);
 		if (pages <= 0)
 			return -EFAULT;
 
diff --git a/mm/shmem.c b/mm/shmem.c
index e67d6ba4e98e..c0f873cdd0f1 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1951,7 +1951,8 @@ static int shmem_fault(struct vm_fault *vmf)
 			if ((vmf->flags & FAULT_FLAG_ALLOW_RETRY) &&
 			   !(vmf->flags & FAULT_FLAG_RETRY_NOWAIT)) {
 				/* It's polite to up mmap_sem if we can */
-				up_read(&vma->vm_mm->mmap_sem);
+				range_read_unlock(&vma->vm_mm->mmap_rw_tree,
+						  vmf->lockrange);
 				ret = VM_FAULT_RETRY;
 			}
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 178130880b90..a1c09332cb22 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1592,15 +1592,17 @@ static int unuse_mm(struct mm_struct *mm,
 {
 	struct vm_area_struct *vma;
 	int ret = 0;
+	struct range_rwlock range;
 
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	range_rwlock_init_full(&range);
+	if (!range_read_trylock(&mm->mmap_rw_tree, &range)) {
 		/*
 		 * Activate page so shrink_inactive_list is unlikely to unmap
 		 * its ptes while lock is dropped, so swapoff can make progress.
 		 */
 		activate_page(page);
 		unlock_page(page);
-		down_read(&mm->mmap_sem);
+		range_read_lock(&mm->mmap_rw_tree, &range);
 		lock_page(page);
 	}
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
@@ -1608,7 +1610,7 @@ static int unuse_mm(struct mm_struct *mm,
 			break;
 		cond_resched();
 	}
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 	return (ret < 0)? ret: 0;
 }
 
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 923a1ef22bc2..bf5b00b92c55 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -179,7 +179,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 	 * feature is not supported.
 	 */
 	if (zeropage) {
-		up_read(&dst_mm->mmap_sem);
+		range_read_unlock(&dst_mm->mmap_rw_tree, range);
 		return -EINVAL;
 	}
 
@@ -277,7 +277,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 		cond_resched();
 
 		if (unlikely(err == -EFAULT)) {
-			up_read(&dst_mm->mmap_sem);
+			range_read_unlock(&dst_mm->mmap_rw_tree, range);
 			BUG_ON(!page);
 
 			err = copy_huge_page_from_user(page,
@@ -287,7 +287,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 				err = -EFAULT;
 				goto out;
 			}
-			down_read(&dst_mm->mmap_sem);
+			range_read_lock(&dst_mm->mmap_rw_tree, range);
 
 			dst_vma = NULL;
 			goto retry;
@@ -307,7 +307,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 	}
 
 out_unlock:
-	up_read(&dst_mm->mmap_sem);
+	range_read_unlock(&dst_mm->mmap_rw_tree, range);
 out:
 	if (page) {
 		/*
@@ -385,6 +385,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	unsigned long src_addr, dst_addr;
 	long copied;
 	struct page *page;
+	struct range_rwlock range;
 
 	/*
 	 * Sanitize the command parameters:
@@ -400,8 +401,9 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	dst_addr = dst_start;
 	copied = 0;
 	page = NULL;
+	range_rwlock_init_full(&range);
 retry:
-	down_read(&dst_mm->mmap_sem);
+	range_read_lock(&dst_mm->mmap_rw_tree, &range);
 
 	/*
 	 * Make sure the vma is not shared, that the dst range is
@@ -441,7 +443,8 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	 */
 	if (is_vm_hugetlb_page(dst_vma))
 		return  __mcopy_atomic_hugetlb(dst_mm, dst_vma, dst_start,
-					       src_start, len, zeropage, NULL);
+					       src_start, len, zeropage,
+					       &range);
 
 	if (!vma_is_anonymous(dst_vma) && !vma_is_shmem(dst_vma))
 		goto out_unlock;
@@ -510,7 +513,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 		if (unlikely(err == -EFAULT)) {
 			void *page_kaddr;
 
-			up_read(&dst_mm->mmap_sem);
+			range_read_unlock(&dst_mm->mmap_rw_tree, &range);
 			BUG_ON(!page);
 
 			page_kaddr = kmap(page);
@@ -539,7 +542,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	}
 
 out_unlock:
-	up_read(&dst_mm->mmap_sem);
+	range_read_unlock(&dst_mm->mmap_rw_tree, &range);
 out:
 	if (page)
 		put_page(page);
diff --git a/mm/util.c b/mm/util.c
index 656dc5e37a87..df0ea6f6f1ff 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -301,14 +301,17 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 	struct mm_struct *mm = current->mm;
 	unsigned long populate;
 	LIST_HEAD(uf);
+	struct range_rwlock range;
+
+	range_rwlock_init_full(&range);
 
 	ret = security_mmap_file(file, prot, flag);
 	if (!ret) {
-		if (down_write_killable(&mm->mmap_sem))
+		if (range_write_lock_interruptible(&mm->mmap_rw_tree, &range))
 			return -EINTR;
 		ret = do_mmap_pgoff(file, addr, len, prot, flag, pgoff,
 				    &populate, &uf);
-		up_write(&mm->mmap_sem);
+		range_write_unlock(&mm->mmap_rw_tree, &range);
 		userfaultfd_unmap_complete(mm, &uf);
 		if (populate)
 			mm_populate(ret, populate);
@@ -614,17 +617,21 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
 	unsigned int len;
 	struct mm_struct *mm = get_task_mm(task);
 	unsigned long arg_start, arg_end, env_start, env_end;
+	struct range_rwlock range;
+
+	range_rwlock_init_full(&range);
+
 	if (!mm)
 		goto out;
 	if (!mm->arg_end)
 		goto out_mm;	/* Shh! No looking before we're done */
 
-	down_read(&mm->mmap_sem);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	arg_start = mm->arg_start;
 	arg_end = mm->arg_end;
 	env_start = mm->env_start;
 	env_end = mm->env_end;
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_rw_tree, &range);
 
 	len = arg_end - arg_start;
 
diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
index bb298a200cd3..733b604a3471 100644
--- a/virt/kvm/async_pf.c
+++ b/virt/kvm/async_pf.c
@@ -74,6 +74,7 @@ static void async_pf_execute(struct work_struct *work)
 	struct kvm_async_pf *apf =
 		container_of(work, struct kvm_async_pf, work);
 	struct mm_struct *mm = apf->mm;
+	struct range_rwlock range;
 	struct kvm_vcpu *vcpu = apf->vcpu;
 	unsigned long addr = apf->addr;
 	gva_t gva = apf->gva;
@@ -86,11 +87,12 @@ static void async_pf_execute(struct work_struct *work)
 	 * mm and might be done in another context, so we must
 	 * access remotely.
 	 */
-	down_read(&mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&mm->mmap_rw_tree, &range);
 	get_user_pages_remote(NULL, mm, addr, 1, FOLL_WRITE, NULL, NULL,
-			&locked);
+			      &locked, &range);
 	if (locked)
-		up_read(&mm->mmap_sem);
+		range_read_unlock(&mm->mmap_rw_tree, &range);
 
 	kvm_async_page_present_sync(vcpu, apf);
 
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 43b8a01ac131..519f0f16d623 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1252,6 +1252,7 @@ unsigned long kvm_host_page_size(struct kvm *kvm, gfn_t gfn)
 {
 	struct vm_area_struct *vma;
 	unsigned long addr, size;
+	struct range_rwlock range;
 
 	size = PAGE_SIZE;
 
@@ -1259,7 +1260,8 @@ unsigned long kvm_host_page_size(struct kvm *kvm, gfn_t gfn)
 	if (kvm_is_error_hva(addr))
 		return PAGE_SIZE;
 
-	down_read(&current->mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&current->mm->mmap_rw_tree, &range);
 	vma = find_vma(current->mm, addr);
 	if (!vma)
 		goto out;
@@ -1267,7 +1269,7 @@ unsigned long kvm_host_page_size(struct kvm *kvm, gfn_t gfn)
 	size = vma_kernel_pagesize(vma);
 
 out:
-	up_read(&current->mm->mmap_sem);
+	range_read_unlock(&current->mm->mmap_rw_tree, &range);
 
 	return size;
 }
@@ -1407,6 +1409,9 @@ static int hva_to_pfn_slow(unsigned long addr, bool *async, bool write_fault,
 {
 	struct page *page[1];
 	int npages = 0;
+	struct range_rwlock range;
+
+	range_rwlock_init_full(&range); /* XXX finer grain required here */
 
 	might_sleep();
 
@@ -1414,9 +1419,9 @@ static int hva_to_pfn_slow(unsigned long addr, bool *async, bool write_fault,
 		*writable = write_fault;
 
 	if (async) {
-		down_read(&current->mm->mmap_sem);
+		range_read_lock(&current->mm->mmap_rw_tree, &range);
 		npages = get_user_page_nowait(addr, write_fault, page);
-		up_read(&current->mm->mmap_sem);
+		range_read_unlock(&current->mm->mmap_rw_tree, &range);
 	} else {
 		unsigned int flags = FOLL_HWPOISON;
 
@@ -1523,6 +1528,7 @@ static kvm_pfn_t hva_to_pfn(unsigned long addr, bool atomic, bool *async,
 	struct vm_area_struct *vma;
 	kvm_pfn_t pfn = 0;
 	int npages, r;
+	struct range_rwlock range;
 
 	/* we can do it either atomically or asynchronously, not both */
 	BUG_ON(atomic && async);
@@ -1537,7 +1543,8 @@ static kvm_pfn_t hva_to_pfn(unsigned long addr, bool atomic, bool *async,
 	if (npages == 1)
 		return pfn;
 
-	down_read(&current->mm->mmap_sem);
+	range_rwlock_init_full(&range);
+	range_read_lock(&current->mm->mmap_rw_tree, &range);
 	if (npages == -EHWPOISON ||
 	      (!async && check_user_page_hwpoison(addr))) {
 		pfn = KVM_PFN_ERR_HWPOISON;
@@ -1551,7 +1558,7 @@ static kvm_pfn_t hva_to_pfn(unsigned long addr, bool atomic, bool *async,
 		pfn = KVM_PFN_ERR_FAULT;
 	else if (vma->vm_flags & (VM_IO | VM_PFNMAP)) {
 		r = hva_to_pfn_remapped(vma, addr, async, write_fault, &pfn,
-					NULL);
+					&range);
 		if (r == -EAGAIN)
 			goto retry;
 		if (r < 0)
@@ -1562,7 +1569,7 @@ static kvm_pfn_t hva_to_pfn(unsigned long addr, bool atomic, bool *async,
 		pfn = KVM_PFN_ERR_FAULT;
 	}
 exit:
-	up_read(&current->mm->mmap_sem);
+	range_read_unlock(&current->mm->mmap_rw_tree, &range);
 	return pfn;
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
