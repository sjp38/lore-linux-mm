Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 28FD86B0350
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:38 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id i63so110553154pgd.15
        for <linux-mm@kvack.org>; Wed, 24 May 2017 04:20:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t26si25073289pgo.414.2017.05.24.04.20.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 04:20:34 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4OBI7QZ090160
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:33 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2amyy9xuvb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:31 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 24 May 2017 12:20:27 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v2 09/10] mm: Change mmap_sem to range lock
Date: Wed, 24 May 2017 13:20:00 +0200
In-Reply-To: <1495624801-8063-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1495624801-8063-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1495624801-8063-10-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, Andi Kleen <andi@firstfloor.org>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

Change the mmap_sem to a range lock to allow finer grain locking on
the memory layout of a task.

This patch move the mmap_sem to a range lock.
To achieve that in a configurable way, all call to down_read(),
up_read(), etc. to the mmap_sem are encapsulated into new mm specific
services. This will allow to change this call to range lock operation.

The range lock operation requires an additional parameter which
declare using a dedicated macro. This avoids declaration of unused
variable in the case CONFIG_MEM_RANGE_LOCK is not defined.
This macro create a full range variable so no functional changes is
expected through this patch even if CONFIG_MEM_RANGE_LOCK is defined.

Currently, this patch only supports x86 and PowerPc architectures,
furthermore it should break the build of any others.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/powerpc/kernel/vdso.c                         |  7 ++-
 arch/powerpc/kvm/book3s_64_mmu_hv.c                |  5 +-
 arch/powerpc/kvm/book3s_64_mmu_radix.c             |  5 +-
 arch/powerpc/kvm/book3s_64_vio.c                   |  5 +-
 arch/powerpc/kvm/book3s_hv.c                       |  7 ++-
 arch/powerpc/kvm/e500_mmu_host.c                   |  6 +-
 arch/powerpc/mm/copro_fault.c                      |  5 +-
 arch/powerpc/mm/fault.c                            | 11 ++--
 arch/powerpc/mm/mmu_context_iommu.c                |  5 +-
 arch/powerpc/mm/subpage-prot.c                     | 14 +++--
 arch/powerpc/oprofile/cell/spu_task_sync.c         |  7 ++-
 arch/powerpc/platforms/cell/spufs/file.c           |  4 +-
 arch/x86/entry/vdso/vma.c                          | 12 ++--
 arch/x86/kernel/tboot.c                            |  6 +-
 arch/x86/kernel/vm86_32.c                          |  5 +-
 arch/x86/mm/fault.c                                | 67 ++++++++++++++++------
 arch/x86/mm/mpx.c                                  | 15 +++--
 drivers/android/binder.c                           |  7 ++-
 drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c             |  5 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c            |  7 ++-
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c             |  7 ++-
 drivers/gpu/drm/amd/amdkfd/kfd_events.c            |  5 +-
 drivers/gpu/drm/amd/amdkfd/kfd_process.c           |  5 +-
 drivers/gpu/drm/etnaviv/etnaviv_gem.c              |  5 +-
 drivers/gpu/drm/i915/i915_gem.c                    |  5 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c            | 10 ++--
 drivers/gpu/drm/radeon/radeon_cs.c                 |  5 +-
 drivers/gpu/drm/radeon/radeon_gem.c                |  8 ++-
 drivers/gpu/drm/radeon/radeon_mn.c                 |  7 ++-
 drivers/gpu/drm/ttm/ttm_bo_vm.c                    |  4 +-
 drivers/infiniband/core/umem.c                     | 17 +++---
 drivers/infiniband/core/umem_odp.c                 |  5 +-
 drivers/infiniband/hw/hfi1/user_pages.c            | 16 ++++--
 drivers/infiniband/hw/mlx4/main.c                  |  5 +-
 drivers/infiniband/hw/mlx5/main.c                  |  5 +-
 drivers/infiniband/hw/qib/qib_user_pages.c         | 11 ++--
 drivers/infiniband/hw/usnic/usnic_uiom.c           | 17 +++---
 drivers/iommu/amd_iommu_v2.c                       |  7 ++-
 drivers/iommu/intel-svm.c                          |  5 +-
 drivers/media/v4l2-core/videobuf-core.c            |  5 +-
 drivers/media/v4l2-core/videobuf-dma-contig.c      |  5 +-
 drivers/media/v4l2-core/videobuf-dma-sg.c          |  5 +-
 drivers/misc/cxl/fault.c                           |  5 +-
 drivers/misc/mic/scif/scif_rma.c                   | 16 ++++--
 drivers/oprofile/buffer_sync.c                     | 12 ++--
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  3 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  5 +-
 .../interface/vchiq_arm/vchiq_2835_arm.c           |  6 +-
 .../vc04_services/interface/vchiq_arm/vchiq_arm.c  |  5 +-
 drivers/vfio/vfio_iommu_spapr_tce.c                | 11 ++--
 drivers/vfio/vfio_iommu_type1.c                    | 16 +++---
 drivers/xen/gntdev.c                               |  5 +-
 drivers/xen/privcmd.c                              | 12 ++--
 fs/aio.c                                           |  5 +-
 fs/coredump.c                                      |  5 +-
 fs/exec.c                                          | 20 ++++---
 fs/proc/base.c                                     | 32 ++++++-----
 fs/proc/internal.h                                 |  3 +
 fs/proc/task_mmu.c                                 | 24 ++++----
 fs/proc/task_nommu.c                               | 24 ++++----
 fs/userfaultfd.c                                   | 21 ++++---
 ipc/shm.c                                          | 10 ++--
 kernel/acct.c                                      |  5 +-
 kernel/events/core.c                               |  5 +-
 kernel/events/uprobes.c                            | 20 ++++---
 kernel/exit.c                                      |  9 +--
 kernel/fork.c                                      | 20 +++++--
 kernel/futex.c                                     |  7 ++-
 kernel/sched/fair.c                                |  6 +-
 kernel/sys.c                                       | 22 ++++---
 kernel/trace/trace_output.c                        |  5 +-
 mm/filemap.c                                       |  4 +-
 mm/frame_vector.c                                  |  8 ++-
 mm/gup.c                                           | 18 +++---
 mm/init-mm.c                                       |  4 ++
 mm/khugepaged.c                                    | 35 +++++------
 mm/ksm.c                                           | 36 +++++++-----
 mm/madvise.c                                       | 17 +++---
 mm/memcontrol.c                                    | 12 ++--
 mm/memory.c                                        | 17 ++++--
 mm/mempolicy.c                                     | 26 +++++----
 mm/migrate.c                                       | 10 ++--
 mm/mincore.c                                       |  5 +-
 mm/mlock.c                                         | 20 ++++---
 mm/mmap.c                                          | 34 ++++++-----
 mm/mmu_notifier.c                                  |  5 +-
 mm/mprotect.c                                      | 15 +++--
 mm/mremap.c                                        |  5 +-
 mm/msync.c                                         |  9 +--
 mm/nommu.c                                         | 26 +++++----
 mm/oom_kill.c                                      |  7 ++-
 mm/process_vm_access.c                             |  7 ++-
 mm/shmem.c                                         |  2 +-
 mm/swapfile.c                                      |  7 ++-
 mm/userfaultfd.c                                   | 15 ++---
 mm/util.c                                          | 11 ++--
 virt/kvm/async_pf.c                                |  7 ++-
 virt/kvm/kvm_main.c                                | 29 +++++++---
 98 files changed, 667 insertions(+), 432 deletions(-)

diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
index 22b01a3962f0..338da057c24e 100644
--- a/arch/powerpc/kernel/vdso.c
+++ b/arch/powerpc/kernel/vdso.c
@@ -155,6 +155,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	unsigned long vdso_pages;
 	unsigned long vdso_base;
 	int rc;
+	mm_range_define(range);
 
 	if (!vdso_ready)
 		return 0;
@@ -196,7 +197,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	 * and end up putting it elsewhere.
 	 * Add enough to the size so that the result can be aligned.
 	 */
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &range))
 		return -EINTR;
 	vdso_base = get_unmapped_area(NULL, vdso_base,
 				      (vdso_pages << PAGE_SHIFT) +
@@ -236,11 +237,11 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 		goto fail_mmapsem;
 	}
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	return 0;
 
  fail_mmapsem:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	return rc;
 }
 
diff --git a/arch/powerpc/kvm/book3s_64_mmu_hv.c b/arch/powerpc/kvm/book3s_64_mmu_hv.c
index 710e491206ed..3260d3fa49c0 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_hv.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_hv.c
@@ -485,6 +485,7 @@ int kvmppc_book3s_hv_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 	struct vm_area_struct *vma;
 	unsigned long rcbits;
 	long mmio_update;
+	mm_range_define(range);
 
 	if (kvm_is_radix(kvm))
 		return kvmppc_book3s_radix_page_fault(run, vcpu, ea, dsisr);
@@ -568,7 +569,7 @@ int kvmppc_book3s_hv_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 	npages = get_user_pages_fast(hva, 1, writing, pages);
 	if (npages < 1) {
 		/* Check if it's an I/O mapping */
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &range);
 		vma = find_vma(current->mm, hva);
 		if (vma && vma->vm_start <= hva && hva + psize <= vma->vm_end &&
 		    (vma->vm_flags & VM_PFNMAP)) {
@@ -578,7 +579,7 @@ int kvmppc_book3s_hv_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 			is_ci = pte_ci(__pte((pgprot_val(vma->vm_page_prot))));
 			write_ok = vma->vm_flags & VM_WRITE;
 		}
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &range);
 		if (!pfn)
 			goto out_put;
 	} else {
diff --git a/arch/powerpc/kvm/book3s_64_mmu_radix.c b/arch/powerpc/kvm/book3s_64_mmu_radix.c
index f6b3e67c5762..9aa215cb87a2 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_radix.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_radix.c
@@ -305,6 +305,7 @@ int kvmppc_book3s_radix_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 	pte_t pte, *ptep;
 	unsigned long pgflags;
 	unsigned int shift, level;
+	mm_range_define(range);
 
 	/* Check for unusual errors */
 	if (dsisr & DSISR_UNSUPP_MMU) {
@@ -394,7 +395,7 @@ int kvmppc_book3s_radix_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 	npages = get_user_pages_fast(hva, 1, writing, pages);
 	if (npages < 1) {
 		/* Check if it's an I/O mapping */
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &range);
 		vma = find_vma(current->mm, hva);
 		if (vma && vma->vm_start <= hva && hva < vma->vm_end &&
 		    (vma->vm_flags & VM_PFNMAP)) {
@@ -402,7 +403,7 @@ int kvmppc_book3s_radix_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 				((hva - vma->vm_start) >> PAGE_SHIFT);
 			pgflags = pgprot_val(vma->vm_page_prot);
 		}
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &range);
 		if (!pfn)
 			return -EFAULT;
 	} else {
diff --git a/arch/powerpc/kvm/book3s_64_vio.c b/arch/powerpc/kvm/book3s_64_vio.c
index a160c14304eb..599d7a882597 100644
--- a/arch/powerpc/kvm/book3s_64_vio.c
+++ b/arch/powerpc/kvm/book3s_64_vio.c
@@ -60,11 +60,12 @@ static unsigned long kvmppc_stt_pages(unsigned long tce_pages)
 static long kvmppc_account_memlimit(unsigned long stt_pages, bool inc)
 {
 	long ret = 0;
+	mm_range_define(range);
 
 	if (!current || !current->mm)
 		return ret; /* process exited */
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm, &range);
 
 	if (inc) {
 		unsigned long locked, lock_limit;
@@ -89,7 +90,7 @@ static long kvmppc_account_memlimit(unsigned long stt_pages, bool inc)
 			rlimit(RLIMIT_MEMLOCK),
 			ret ? " - exceeded" : "");
 
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &range);
 
 	return ret;
 }
diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index 42b7a4fd57d9..88005961a816 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -3201,6 +3201,7 @@ static int kvmppc_hv_setup_htab_rma(struct kvm_vcpu *vcpu)
 	unsigned long lpcr = 0, senc;
 	unsigned long psize, porder;
 	int srcu_idx;
+	mm_range_define(range);
 
 	mutex_lock(&kvm->lock);
 	if (kvm->arch.hpte_setup_done)
@@ -3237,7 +3238,7 @@ static int kvmppc_hv_setup_htab_rma(struct kvm_vcpu *vcpu)
 
 	/* Look up the VMA for the start of this memory slot */
 	hva = memslot->userspace_addr;
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &range);
 	vma = find_vma(current->mm, hva);
 	if (!vma || vma->vm_start > hva || (vma->vm_flags & VM_IO))
 		goto up_out;
@@ -3245,7 +3246,7 @@ static int kvmppc_hv_setup_htab_rma(struct kvm_vcpu *vcpu)
 	psize = vma_kernel_pagesize(vma);
 	porder = __ilog2(psize);
 
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &range);
 
 	/* We can handle 4k, 64k or 16M pages in the VRMA */
 	err = -EINVAL;
@@ -3279,7 +3280,7 @@ static int kvmppc_hv_setup_htab_rma(struct kvm_vcpu *vcpu)
 	return err;
 
  up_out:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &range);
 	goto out_srcu;
 }
 
diff --git a/arch/powerpc/kvm/e500_mmu_host.c b/arch/powerpc/kvm/e500_mmu_host.c
index 77fd043b3ecc..1539f977d5c7 100644
--- a/arch/powerpc/kvm/e500_mmu_host.c
+++ b/arch/powerpc/kvm/e500_mmu_host.c
@@ -357,7 +357,9 @@ static inline int kvmppc_e500_shadow_map(struct kvmppc_vcpu_e500 *vcpu_e500,
 
 	if (tlbsel == 1) {
 		struct vm_area_struct *vma;
-		down_read(&current->mm->mmap_sem);
+		mm_range_define(range);
+
+		mm_read_lock(current->mm, &range);
 
 		vma = find_vma(current->mm, hva);
 		if (vma && hva >= vma->vm_start &&
@@ -443,7 +445,7 @@ static inline int kvmppc_e500_shadow_map(struct kvmppc_vcpu_e500 *vcpu_e500,
 			tsize = max(BOOK3E_PAGESZ_4K, tsize & ~1);
 		}
 
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &range);
 	}
 
 	if (likely(!pfnmap)) {
diff --git a/arch/powerpc/mm/copro_fault.c b/arch/powerpc/mm/copro_fault.c
index 81fbf79d2e97..f7d8766369af 100644
--- a/arch/powerpc/mm/copro_fault.c
+++ b/arch/powerpc/mm/copro_fault.c
@@ -39,6 +39,7 @@ int copro_handle_mm_fault(struct mm_struct *mm, unsigned long ea,
 	struct vm_area_struct *vma;
 	unsigned long is_write;
 	int ret;
+	mm_range_define(range);
 
 	if (mm == NULL)
 		return -EFAULT;
@@ -46,7 +47,7 @@ int copro_handle_mm_fault(struct mm_struct *mm, unsigned long ea,
 	if (mm->pgd == NULL)
 		return -EFAULT;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	ret = -EFAULT;
 	vma = find_vma(mm, ea);
 	if (!vma)
@@ -95,7 +96,7 @@ int copro_handle_mm_fault(struct mm_struct *mm, unsigned long ea,
 		current->min_flt++;
 
 out_unlock:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(copro_handle_mm_fault);
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 278550794dea..824143e12873 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -208,6 +208,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
  	int is_exec = trap == 0x400;
 	int fault;
 	int rc = 0, store_update_sp = 0;
+	mm_range_define(range);
 
 #if !(defined(CONFIG_4xx) || defined(CONFIG_BOOKE))
 	/*
@@ -308,12 +309,12 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	 * source.  If this is invalid we can skip the address space check,
 	 * thus avoiding the deadlock.
 	 */
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!mm_read_trylock(mm, &range)) {
 		if (!user_mode(regs) && !search_exception_tables(regs->nip))
 			goto bad_area_nosemaphore;
 
 retry:
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &range);
 	} else {
 		/*
 		 * The above down_read_trylock() might have succeeded in
@@ -446,7 +447,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags, NULL);
+	fault = handle_mm_fault(vma, address, flags, &range);
 
 	/*
 	 * Handle the retry right now, the mmap_sem has been released in that
@@ -466,7 +467,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 		}
 		/* We will enter mm_fault_error() below */
 	} else
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(mm, &range);
 
 	if (unlikely(fault & (VM_FAULT_RETRY|VM_FAULT_ERROR))) {
 		if (fault & VM_FAULT_SIGSEGV)
@@ -505,7 +506,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	goto bail;
 
 bad_area:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 
 bad_area_nosemaphore:
 	/* User mode accesses cause a SIGSEGV */
diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
index e0a2d8e806ed..b8e051b55e00 100644
--- a/arch/powerpc/mm/mmu_context_iommu.c
+++ b/arch/powerpc/mm/mmu_context_iommu.c
@@ -36,11 +36,12 @@ static long mm_iommu_adjust_locked_vm(struct mm_struct *mm,
 		unsigned long npages, bool incr)
 {
 	long ret = 0, locked, lock_limit;
+	mm_range_define(range);
 
 	if (!npages)
 		return 0;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &range);
 
 	if (incr) {
 		locked = mm->locked_vm + npages;
@@ -61,7 +62,7 @@ static long mm_iommu_adjust_locked_vm(struct mm_struct *mm,
 			npages << PAGE_SHIFT,
 			mm->locked_vm << PAGE_SHIFT,
 			rlimit(RLIMIT_MEMLOCK));
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 
 	return ret;
 }
diff --git a/arch/powerpc/mm/subpage-prot.c b/arch/powerpc/mm/subpage-prot.c
index e94fbd4c8845..f6e64c050ea4 100644
--- a/arch/powerpc/mm/subpage-prot.c
+++ b/arch/powerpc/mm/subpage-prot.c
@@ -98,8 +98,9 @@ static void subpage_prot_clear(unsigned long addr, unsigned long len)
 	unsigned long i;
 	size_t nw;
 	unsigned long next, limit;
+	mm_range_define(range);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &range);
 	limit = addr + len;
 	if (limit > spt->maxaddr)
 		limit = spt->maxaddr;
@@ -127,7 +128,7 @@ static void subpage_prot_clear(unsigned long addr, unsigned long len)
 		/* now flush any existing HPTEs for the range */
 		hpte_flush_range(mm, addr, nw);
 	}
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -194,6 +195,7 @@ long sys_subpage_prot(unsigned long addr, unsigned long len, u32 __user *map)
 	size_t nw;
 	unsigned long next, limit;
 	int err;
+	mm_range_define(range);
 
 	/* Check parameters */
 	if ((addr & ~PAGE_MASK) || (len & ~PAGE_MASK) ||
@@ -213,7 +215,7 @@ long sys_subpage_prot(unsigned long addr, unsigned long len, u32 __user *map)
 	if (!access_ok(VERIFY_READ, map, (len >> PAGE_SHIFT) * sizeof(u32)))
 		return -EFAULT;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &range);
 	subpage_mark_vma_nohuge(mm, addr, len);
 	for (limit = addr + len; addr < limit; addr = next) {
 		next = pmd_addr_end(addr, limit);
@@ -248,11 +250,11 @@ long sys_subpage_prot(unsigned long addr, unsigned long len, u32 __user *map)
 		if (addr + (nw << PAGE_SHIFT) > next)
 			nw = (next - addr) >> PAGE_SHIFT;
 
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &range);
 		if (__copy_from_user(spp, map, nw * sizeof(u32)))
 			return -EFAULT;
 		map += nw;
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm, &range);
 
 		/* now flush any existing HPTEs for the range */
 		hpte_flush_range(mm, addr, nw);
@@ -261,6 +263,6 @@ long sys_subpage_prot(unsigned long addr, unsigned long len, u32 __user *map)
 		spt->maxaddr = limit;
 	err = 0;
  out:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	return err;
 }
diff --git a/arch/powerpc/oprofile/cell/spu_task_sync.c b/arch/powerpc/oprofile/cell/spu_task_sync.c
index 44d67b167e0b..0fdc92a30f9d 100644
--- a/arch/powerpc/oprofile/cell/spu_task_sync.c
+++ b/arch/powerpc/oprofile/cell/spu_task_sync.c
@@ -325,6 +325,7 @@ get_exec_dcookie_and_offset(struct spu *spu, unsigned int *offsetp,
 	struct vm_area_struct *vma;
 	struct file *exe_file;
 	struct mm_struct *mm = spu->mm;
+	mm_range_define(range);
 
 	if (!mm)
 		goto out;
@@ -336,7 +337,7 @@ get_exec_dcookie_and_offset(struct spu *spu, unsigned int *offsetp,
 		fput(exe_file);
 	}
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (vma->vm_start > spu_ref || vma->vm_end <= spu_ref)
 			continue;
@@ -353,13 +354,13 @@ get_exec_dcookie_and_offset(struct spu *spu, unsigned int *offsetp,
 	*spu_bin_dcookie = fast_get_dcookie(&vma->vm_file->f_path);
 	pr_debug("got dcookie for %pD\n", vma->vm_file);
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 
 out:
 	return app_cookie;
 
 fail_no_image_cookie:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 
 	printk(KERN_ERR "SPU_PROF: "
 		"%s, line %d: Cannot find dcookie for SPU binary\n",
diff --git a/arch/powerpc/platforms/cell/spufs/file.c b/arch/powerpc/platforms/cell/spufs/file.c
index ae2f740a82f1..0360d9c7dd9c 100644
--- a/arch/powerpc/platforms/cell/spufs/file.c
+++ b/arch/powerpc/platforms/cell/spufs/file.c
@@ -347,11 +347,11 @@ static int spufs_ps_fault(struct vm_fault *vmf,
 		goto refault;
 
 	if (ctx->state == SPU_STATE_SAVED) {
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm->mmap_sem, vmf->lockrange);
 		spu_context_nospu_trace(spufs_ps_fault__sleep, ctx);
 		ret = spufs_wait(ctx->run_wq, ctx->state == SPU_STATE_RUNNABLE);
 		spu_context_trace(spufs_ps_fault__wake, ctx, ctx->spu);
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm->mmap_sem, vmf->lockrange);
 	} else {
 		area = ctx->spu->problem_phys + ps_offs;
 		vm_insert_pfn(vmf->vma, vmf->address, (area + offset) >> PAGE_SHIFT);
diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 139ad7726e10..6f754b7675d8 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -157,8 +157,9 @@ static int map_vdso(const struct vdso_image *image, unsigned long addr)
 	struct vm_area_struct *vma;
 	unsigned long text_start;
 	int ret = 0;
+	mm_range_define(range);
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &range))
 		return -EINTR;
 
 	addr = get_unmapped_area(NULL, addr,
@@ -201,7 +202,7 @@ static int map_vdso(const struct vdso_image *image, unsigned long addr)
 	}
 
 up_fail:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	return ret;
 }
 
@@ -262,8 +263,9 @@ int map_vdso_once(const struct vdso_image *image, unsigned long addr)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
+	mm_range_define(range);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &range);
 	/*
 	 * Check if we have already mapped vdso blob - fail to prevent
 	 * abusing from userspace install_speciall_mapping, which may
@@ -274,11 +276,11 @@ int map_vdso_once(const struct vdso_image *image, unsigned long addr)
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (vma_is_special_mapping(vma, &vdso_mapping) ||
 				vma_is_special_mapping(vma, &vvar_mapping)) {
-			up_write(&mm->mmap_sem);
+			mm_write_unlock(mm, &range);
 			return -EEXIST;
 		}
 	}
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 
 	return map_vdso(image, addr);
 }
diff --git a/arch/x86/kernel/tboot.c b/arch/x86/kernel/tboot.c
index 4b1724059909..4a854f7dc1e9 100644
--- a/arch/x86/kernel/tboot.c
+++ b/arch/x86/kernel/tboot.c
@@ -104,7 +104,11 @@ static struct mm_struct tboot_mm = {
 	.pgd            = swapper_pg_dir,
 	.mm_users       = ATOMIC_INIT(2),
 	.mm_count       = ATOMIC_INIT(1),
-	.mmap_sem       = __RWSEM_INITIALIZER(init_mm.mmap_sem),
+#ifdef CONFIG_MEM_RANGE_LOCK
+	.mmap_sem   = __RANGE_LOCK_TREE_INITIALIZER(init_mm.mmap_sem),
+#else
+	.mmap_sem   = __RWSEM_INITIALIZER(init_mm.mmap_sem),
+#endif
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
 	.mmlist         = LIST_HEAD_INIT(init_mm.mmlist),
 };
diff --git a/arch/x86/kernel/vm86_32.c b/arch/x86/kernel/vm86_32.c
index 7924a5356c8a..c927e46231eb 100644
--- a/arch/x86/kernel/vm86_32.c
+++ b/arch/x86/kernel/vm86_32.c
@@ -169,8 +169,9 @@ static void mark_screen_rdonly(struct mm_struct *mm)
 	pmd_t *pmd;
 	pte_t *pte;
 	int i;
+	mm_range_define(range);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &range);
 	pgd = pgd_offset(mm, 0xA0000);
 	if (pgd_none_or_clear_bad(pgd))
 		goto out;
@@ -196,7 +197,7 @@ static void mark_screen_rdonly(struct mm_struct *mm)
 	}
 	pte_unmap_unlock(pte, ptl);
 out:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	flush_tlb_mm_range(mm, 0xA0000, 0xA0000 + 32*PAGE_SIZE, 0UL);
 }
 
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index f078bc9458b0..4ecdec2bd264 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -962,7 +962,11 @@ bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
 
 static void
 __bad_area(struct pt_regs *regs, unsigned long error_code,
-	   unsigned long address,  struct vm_area_struct *vma, int si_code)
+	   unsigned long address,  struct vm_area_struct *vma, int si_code
+#ifdef CONFIG_MEM_RANGE_LOCK
+	   , struct range_lock *range
+#endif
+	)
 {
 	struct mm_struct *mm = current->mm;
 
@@ -970,17 +974,31 @@ __bad_area(struct pt_regs *regs, unsigned long error_code,
 	 * Something tried to access memory that isn't in our memory map..
 	 * Fix it, but check if it's kernel or user first..
 	 */
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, range);
 
 	__bad_area_nosemaphore(regs, error_code, address, vma, si_code);
 }
 
 static noinline void
-bad_area(struct pt_regs *regs, unsigned long error_code, unsigned long address)
+_bad_area(struct pt_regs *regs, unsigned long error_code, unsigned long address
+#ifdef CONFIG_MEM_RANGE_LOCK
+	 , struct range_lock *range
+#endif
+	)
 {
-	__bad_area(regs, error_code, address, NULL, SEGV_MAPERR);
+	__bad_area(regs, error_code, address, NULL, SEGV_MAPERR
+#ifdef CONFIG_MEM_RANGE_LOCK
+		   , range
+#endif
+		);
 }
 
+#ifdef CONFIG_MEM_RANGE_LOCK
+#define bad_area _bad_area
+#else
+#define bad_area(r, e, a, _r) _bad_area(r, e, a)
+#endif
+
 static inline bool bad_area_access_from_pkeys(unsigned long error_code,
 		struct vm_area_struct *vma)
 {
@@ -1000,7 +1018,11 @@ static inline bool bad_area_access_from_pkeys(unsigned long error_code,
 
 static noinline void
 bad_area_access_error(struct pt_regs *regs, unsigned long error_code,
-		      unsigned long address, struct vm_area_struct *vma)
+		      unsigned long address, struct vm_area_struct *vma
+#ifdef CONFIG_MEM_RANGE_LOCK
+		      , struct range_lock *range
+#endif
+	)
 {
 	/*
 	 * This OSPKE check is not strictly necessary at runtime.
@@ -1008,9 +1030,17 @@ bad_area_access_error(struct pt_regs *regs, unsigned long error_code,
 	 * if pkeys are compiled out.
 	 */
 	if (bad_area_access_from_pkeys(error_code, vma))
-		__bad_area(regs, error_code, address, vma, SEGV_PKUERR);
+		__bad_area(regs, error_code, address, vma, SEGV_PKUERR
+#ifdef CONFIG_MEM_RANGE_LOCK
+			   , range
+#endif
+			);
 	else
-		__bad_area(regs, error_code, address, vma, SEGV_ACCERR);
+		__bad_area(regs, error_code, address, vma, SEGV_ACCERR
+#ifdef CONFIG_MEM_RANGE_LOCK
+			   , range
+#endif
+			);
 }
 
 static void
@@ -1268,6 +1298,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	struct mm_struct *mm;
 	int fault, major = 0;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	mm_range_define(range);
 
 	tsk = current;
 	mm = tsk->mm;
@@ -1381,14 +1412,14 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	 * validate the source. If this is invalid we can skip the address
 	 * space check, thus avoiding the deadlock:
 	 */
-	if (unlikely(!down_read_trylock(&mm->mmap_sem))) {
+	if (unlikely(!mm_read_trylock(mm, &range))) {
 		if ((error_code & PF_USER) == 0 &&
 		    !search_exception_tables(regs->ip)) {
 			bad_area_nosemaphore(regs, error_code, address, NULL);
 			return;
 		}
 retry:
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &range);
 	} else {
 		/*
 		 * The above down_read_trylock() might have succeeded in
@@ -1400,13 +1431,13 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 
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
@@ -1417,12 +1448,12 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
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
 
@@ -1432,7 +1463,11 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	 */
 good_area:
 	if (unlikely(access_error(error_code, vma))) {
-		bad_area_access_error(regs, error_code, address, vma);
+		bad_area_access_error(regs, error_code, address, vma
+#ifdef CONFIG_MEM_RANGE_LOCK
+				      , &range
+#endif
+			);
 		return;
 	}
 
@@ -1442,7 +1477,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	 * the fault.  Since we never set FAULT_FLAG_RETRY_NOWAIT, if
 	 * we get VM_FAULT_RETRY back, the mmap_sem has been unlocked.
 	 */
-	fault = handle_mm_fault(vma, address, flags, NULL);
+	fault = handle_mm_fault(vma, address, flags, &range);
 	major |= fault & VM_FAULT_MAJOR;
 
 	/*
@@ -1468,7 +1503,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		return;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		mm_fault_error(regs, error_code, address, vma, fault);
 		return;
diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index 313e6fcb550e..0c16c4b37b29 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -45,15 +45,16 @@ static unsigned long mpx_mmap(unsigned long len)
 {
 	struct mm_struct *mm = current->mm;
 	unsigned long addr, populate;
+	mm_range_define(range);
 
 	/* Only bounds table can be allocated here */
 	if (len != mpx_bt_size_bytes(mm))
 		return -EINVAL;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &range);
 	addr = do_mmap(NULL, 0, len, PROT_READ | PROT_WRITE,
 		       MAP_ANONYMOUS | MAP_PRIVATE, VM_MPX, 0, &populate, NULL);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	if (populate)
 		mm_populate(addr, populate);
 
@@ -341,6 +342,7 @@ int mpx_enable_management(void)
 	void __user *bd_base = MPX_INVALID_BOUNDS_DIR;
 	struct mm_struct *mm = current->mm;
 	int ret = 0;
+	mm_range_define(range);
 
 	/*
 	 * runtime in the userspace will be responsible for allocation of
@@ -354,25 +356,26 @@ int mpx_enable_management(void)
 	 * unmap path; we can just use mm->context.bd_addr instead.
 	 */
 	bd_base = mpx_get_bounds_dir();
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &range);
 	mm->context.bd_addr = bd_base;
 	if (mm->context.bd_addr == MPX_INVALID_BOUNDS_DIR)
 		ret = -ENXIO;
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	return ret;
 }
 
 int mpx_disable_management(void)
 {
 	struct mm_struct *mm = current->mm;
+	mm_range_define(range);
 
 	if (!cpu_feature_enabled(X86_FEATURE_MPX))
 		return -ENXIO;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &range);
 	mm->context.bd_addr = MPX_INVALID_BOUNDS_DIR;
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	return 0;
 }
 
diff --git a/drivers/android/binder.c b/drivers/android/binder.c
index aae4d8d4be36..ebdd5864ae6e 100644
--- a/drivers/android/binder.c
+++ b/drivers/android/binder.c
@@ -581,6 +581,7 @@ static int binder_update_page_range(struct binder_proc *proc, int allocate,
 	unsigned long user_page_addr;
 	struct page **page;
 	struct mm_struct *mm;
+	mm_range_define(range);
 
 	binder_debug(BINDER_DEBUG_BUFFER_ALLOC,
 		     "%d: %s pages %p-%p\n", proc->pid,
@@ -597,7 +598,7 @@ static int binder_update_page_range(struct binder_proc *proc, int allocate,
 		mm = get_task_mm(proc->tsk);
 
 	if (mm) {
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm, &range);
 		vma = proc->vma;
 		if (vma && mm != proc->vma_vm_mm) {
 			pr_err("%d: vma mm and task mm mismatch\n",
@@ -647,7 +648,7 @@ static int binder_update_page_range(struct binder_proc *proc, int allocate,
 		/* vm_insert_page does not seem to increment the refcount */
 	}
 	if (mm) {
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &range);
 		mmput(mm);
 	}
 	return 0;
@@ -669,7 +670,7 @@ static int binder_update_page_range(struct binder_proc *proc, int allocate,
 	}
 err_no_vma:
 	if (mm) {
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &range);
 		mmput(mm);
 	}
 	return -ENOMEM;
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c
index 4e6b9501ab0a..3ddba04cedc4 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c
@@ -521,6 +521,7 @@ static int amdgpu_cs_parser_bos(struct amdgpu_cs_parser *p,
 	bool need_mmap_lock = false;
 	unsigned i, tries = 10;
 	int r;
+	mm_range_define(range);
 
 	INIT_LIST_HEAD(&p->validated);
 
@@ -538,7 +539,7 @@ static int amdgpu_cs_parser_bos(struct amdgpu_cs_parser *p,
 		list_add(&p->uf_entry.tv.head, &p->validated);
 
 	if (need_mmap_lock)
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &range);
 
 	while (1) {
 		struct list_head need_pages;
@@ -695,7 +696,7 @@ static int amdgpu_cs_parser_bos(struct amdgpu_cs_parser *p,
 error_free_pages:
 
 	if (need_mmap_lock)
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &range);
 
 	if (p->bo_list) {
 		for (i = p->bo_list->first_userptr;
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
index 94cb91cf93eb..712f26f3a7fc 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
@@ -312,6 +312,7 @@ int amdgpu_gem_userptr_ioctl(struct drm_device *dev, void *data,
 	struct amdgpu_bo *bo;
 	uint32_t handle;
 	int r;
+	mm_range_define(range);
 
 	if (offset_in_page(args->addr | args->size))
 		return -EINVAL;
@@ -350,7 +351,7 @@ int amdgpu_gem_userptr_ioctl(struct drm_device *dev, void *data,
 	}
 
 	if (args->flags & AMDGPU_GEM_USERPTR_VALIDATE) {
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &range);
 
 		r = amdgpu_ttm_tt_get_user_pages(bo->tbo.ttm,
 						 bo->tbo.ttm->pages);
@@ -367,7 +368,7 @@ int amdgpu_gem_userptr_ioctl(struct drm_device *dev, void *data,
 		if (r)
 			goto free_pages;
 
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &range);
 	}
 
 	r = drm_gem_handle_create(filp, gobj, &handle);
@@ -383,7 +384,7 @@ int amdgpu_gem_userptr_ioctl(struct drm_device *dev, void *data,
 	release_pages(bo->tbo.ttm->pages, bo->tbo.ttm->num_pages, false);
 
 unlock_mmap_sem:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &range);
 
 release_object:
 	drm_gem_object_unreference_unlocked(gobj);
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
index 38f739fb727b..8787a750fbae 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
@@ -231,9 +231,10 @@ static struct amdgpu_mn *amdgpu_mn_get(struct amdgpu_device *adev)
 	struct mm_struct *mm = current->mm;
 	struct amdgpu_mn *rmn;
 	int r;
+	mm_range_define(range);
 
 	mutex_lock(&adev->mn_lock);
-	if (down_write_killable(&mm->mmap_sem)) {
+	if (mm_write_lock_killable(mm, &range)) {
 		mutex_unlock(&adev->mn_lock);
 		return ERR_PTR(-EINTR);
 	}
@@ -261,13 +262,13 @@ static struct amdgpu_mn *amdgpu_mn_get(struct amdgpu_device *adev)
 	hash_add(adev->mn_hash, &rmn->node, (unsigned long)mm);
 
 release_locks:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	mutex_unlock(&adev->mn_lock);
 
 	return rmn;
 
 free_rmn:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	mutex_unlock(&adev->mn_lock);
 	kfree(rmn);
 
diff --git a/drivers/gpu/drm/amd/amdkfd/kfd_events.c b/drivers/gpu/drm/amd/amdkfd/kfd_events.c
index d1ce83d73a87..92ae40f3433f 100644
--- a/drivers/gpu/drm/amd/amdkfd/kfd_events.c
+++ b/drivers/gpu/drm/amd/amdkfd/kfd_events.c
@@ -897,6 +897,7 @@ void kfd_signal_iommu_event(struct kfd_dev *dev, unsigned int pasid,
 {
 	struct kfd_hsa_memory_exception_data memory_exception_data;
 	struct vm_area_struct *vma;
+	mm_range_define(range);
 
 	/*
 	 * Because we are called from arbitrary context (workqueue) as opposed
@@ -910,7 +911,7 @@ void kfd_signal_iommu_event(struct kfd_dev *dev, unsigned int pasid,
 
 	memset(&memory_exception_data, 0, sizeof(memory_exception_data));
 
-	down_read(&p->mm->mmap_sem);
+	mm_read_lock(p->mm->mmap_sem, &range);
 	vma = find_vma(p->mm, address);
 
 	memory_exception_data.gpu_id = dev->id;
@@ -937,7 +938,7 @@ void kfd_signal_iommu_event(struct kfd_dev *dev, unsigned int pasid,
 		}
 	}
 
-	up_read(&p->mm->mmap_sem);
+	mm_read_unlock(p->mm->mmap_sem, &range);
 
 	mutex_lock(&p->event_mutex);
 
diff --git a/drivers/gpu/drm/amd/amdkfd/kfd_process.c b/drivers/gpu/drm/amd/amdkfd/kfd_process.c
index 84d1ffd1eef9..f421eaead2e6 100644
--- a/drivers/gpu/drm/amd/amdkfd/kfd_process.c
+++ b/drivers/gpu/drm/amd/amdkfd/kfd_process.c
@@ -78,6 +78,7 @@ void kfd_process_destroy_wq(void)
 struct kfd_process *kfd_create_process(const struct task_struct *thread)
 {
 	struct kfd_process *process;
+	mm_range_define(range);
 
 	BUG_ON(!kfd_process_wq);
 
@@ -89,7 +90,7 @@ struct kfd_process *kfd_create_process(const struct task_struct *thread)
 		return ERR_PTR(-EINVAL);
 
 	/* Take mmap_sem because we call __mmu_notifier_register inside */
-	down_write(&thread->mm->mmap_sem);
+	mm_write_lock(thread->mm->mmap_sem, &range);
 
 	/*
 	 * take kfd processes mutex before starting of process creation
@@ -108,7 +109,7 @@ struct kfd_process *kfd_create_process(const struct task_struct *thread)
 
 	mutex_unlock(&kfd_processes_mutex);
 
-	up_write(&thread->mm->mmap_sem);
+	mm_write_unlock(thread->mm->mmap_sem, &range);
 
 	return process;
 }
diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gem.c b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
index 75ca18aaa34e..40d1ce202cf9 100644
--- a/drivers/gpu/drm/etnaviv/etnaviv_gem.c
+++ b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
@@ -747,6 +747,7 @@ static struct page **etnaviv_gem_userptr_do_get_pages(
 	struct page **pvec;
 	uintptr_t ptr;
 	unsigned int flags = 0;
+	mm_range_define(range);
 
 	pvec = drm_malloc_ab(npages, sizeof(struct page *));
 	if (!pvec)
@@ -758,7 +759,7 @@ static struct page **etnaviv_gem_userptr_do_get_pages(
 	pinned = 0;
 	ptr = etnaviv_obj->userptr.ptr;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	while (pinned < npages) {
 		ret = get_user_pages_remote(task, mm, ptr, npages - pinned,
 					    flags, pvec + pinned, NULL, NULL,
@@ -769,7 +770,7 @@ static struct page **etnaviv_gem_userptr_do_get_pages(
 		ptr += ret * PAGE_SIZE;
 		pinned += ret;
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 
 	if (ret < 0) {
 		release_pages(pvec, pinned, 0);
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index b6ac3df18b58..b5f63bacdaa6 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -1687,8 +1687,9 @@ i915_gem_mmap_ioctl(struct drm_device *dev, void *data,
 	if (args->flags & I915_MMAP_WC) {
 		struct mm_struct *mm = current->mm;
 		struct vm_area_struct *vma;
+		mm_range_define(range);
 
-		if (down_write_killable(&mm->mmap_sem)) {
+		if (mm_write_lock_killable(mm, &range)) {
 			i915_gem_object_put(obj);
 			return -EINTR;
 		}
@@ -1698,7 +1699,7 @@ i915_gem_mmap_ioctl(struct drm_device *dev, void *data,
 				pgprot_writecombine(vm_get_page_prot(vma->vm_flags));
 		else
 			addr = -ENOMEM;
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &range);
 
 		/* This may race, but that's ok, it only gets set */
 		WRITE_ONCE(obj->frontbuffer_ggtt_origin, ORIGIN_CPU);
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 491bb58cab09..2e852f987382 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -211,12 +211,13 @@ static struct i915_mmu_notifier *
 i915_mmu_notifier_find(struct i915_mm_struct *mm)
 {
 	struct i915_mmu_notifier *mn = mm->mn;
+	mm_range_define(range);
 
 	mn = mm->mn;
 	if (mn)
 		return mn;
 
-	down_write(&mm->mm->mmap_sem);
+	mm_write_lock(mm->mm, &range);
 	mutex_lock(&mm->i915->mm_lock);
 	if ((mn = mm->mn) == NULL) {
 		mn = i915_mmu_notifier_create(mm->mm);
@@ -224,7 +225,7 @@ i915_mmu_notifier_find(struct i915_mm_struct *mm)
 			mm->mn = mn;
 	}
 	mutex_unlock(&mm->i915->mm_lock);
-	up_write(&mm->mm->mmap_sem);
+	mm_write_unlock(mm->mm, &range);
 
 	return mn;
 }
@@ -511,13 +512,14 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 	if (pvec != NULL) {
 		struct mm_struct *mm = obj->userptr.mm->mm;
 		unsigned int flags = 0;
+		mm_range_define(range);
 
 		if (!obj->userptr.read_only)
 			flags |= FOLL_WRITE;
 
 		ret = -EFAULT;
 		if (mmget_not_zero(mm)) {
-			down_read(&mm->mmap_sem);
+			mm_read_lock(mm, &range);
 			while (pinned < npages) {
 				ret = get_user_pages_remote
 					(work->task, mm,
@@ -530,7 +532,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 
 				pinned += ret;
 			}
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm, &range);
 			mmput(mm);
 		}
 	}
diff --git a/drivers/gpu/drm/radeon/radeon_cs.c b/drivers/gpu/drm/radeon/radeon_cs.c
index 3ac671f6c8e1..d720ee7239bd 100644
--- a/drivers/gpu/drm/radeon/radeon_cs.c
+++ b/drivers/gpu/drm/radeon/radeon_cs.c
@@ -79,6 +79,7 @@ static int radeon_cs_parser_relocs(struct radeon_cs_parser *p)
 	unsigned i;
 	bool need_mmap_lock = false;
 	int r;
+	mm_range_define(range);
 
 	if (p->chunk_relocs == NULL) {
 		return 0;
@@ -189,12 +190,12 @@ static int radeon_cs_parser_relocs(struct radeon_cs_parser *p)
 		p->vm_bos = radeon_vm_get_bos(p->rdev, p->ib.vm,
 					      &p->validated);
 	if (need_mmap_lock)
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &range);
 
 	r = radeon_bo_list_validate(p->rdev, &p->ticket, &p->validated, p->ring);
 
 	if (need_mmap_lock)
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &range);
 
 	return r;
 }
diff --git a/drivers/gpu/drm/radeon/radeon_gem.c b/drivers/gpu/drm/radeon/radeon_gem.c
index dddb372de2b9..38864c2c32de 100644
--- a/drivers/gpu/drm/radeon/radeon_gem.c
+++ b/drivers/gpu/drm/radeon/radeon_gem.c
@@ -335,17 +335,19 @@ int radeon_gem_userptr_ioctl(struct drm_device *dev, void *data,
 	}
 
 	if (args->flags & RADEON_GEM_USERPTR_VALIDATE) {
-		down_read(&current->mm->mmap_sem);
+		mm_range_define(range);
+
+		mm_read_lock(current->mm, &range);
 		r = radeon_bo_reserve(bo, true);
 		if (r) {
-			up_read(&current->mm->mmap_sem);
+			mm_read_unlock(current->mm, &range);
 			goto release_object;
 		}
 
 		radeon_ttm_placement_from_domain(bo, RADEON_GEM_DOMAIN_GTT);
 		r = ttm_bo_validate(&bo->tbo, &bo->placement, true, false);
 		radeon_bo_unreserve(bo);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &range);
 		if (r)
 			goto release_object;
 	}
diff --git a/drivers/gpu/drm/radeon/radeon_mn.c b/drivers/gpu/drm/radeon/radeon_mn.c
index 896f2cf51e4e..f40703772c53 100644
--- a/drivers/gpu/drm/radeon/radeon_mn.c
+++ b/drivers/gpu/drm/radeon/radeon_mn.c
@@ -185,8 +185,9 @@ static struct radeon_mn *radeon_mn_get(struct radeon_device *rdev)
 	struct mm_struct *mm = current->mm;
 	struct radeon_mn *rmn;
 	int r;
+	mm_range_define(range);
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &range))
 		return ERR_PTR(-EINTR);
 
 	mutex_lock(&rdev->mn_lock);
@@ -215,13 +216,13 @@ static struct radeon_mn *radeon_mn_get(struct radeon_device *rdev)
 
 release_locks:
 	mutex_unlock(&rdev->mn_lock);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 
 	return rmn;
 
 free_rmn:
 	mutex_unlock(&rdev->mn_lock);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	kfree(rmn);
 
 	return ERR_PTR(r);
diff --git a/drivers/gpu/drm/ttm/ttm_bo_vm.c b/drivers/gpu/drm/ttm/ttm_bo_vm.c
index 9f53df95f35c..5355b17ea8fa 100644
--- a/drivers/gpu/drm/ttm/ttm_bo_vm.c
+++ b/drivers/gpu/drm/ttm/ttm_bo_vm.c
@@ -66,7 +66,7 @@ static int ttm_bo_vm_fault_idle(struct ttm_buffer_object *bo,
 			goto out_unlock;
 
 		ttm_bo_reference(bo);
-		up_read(&vmf->vma->vm_mm->mmap_sem);
+		mm_read_unlock(vmf->vma->vm_mm, vmf->lockrange);
 		(void) dma_fence_wait(bo->moving, true);
 		ttm_bo_unreserve(bo);
 		ttm_bo_unref(&bo);
@@ -124,7 +124,7 @@ static int ttm_bo_vm_fault(struct vm_fault *vmf)
 		if (vmf->flags & FAULT_FLAG_ALLOW_RETRY) {
 			if (!(vmf->flags & FAULT_FLAG_RETRY_NOWAIT)) {
 				ttm_bo_reference(bo);
-				up_read(&vmf->vma->vm_mm->mmap_sem);
+				mm_read_unlock(vmf->vma->vm_mm, vmf->lockrange);
 				(void) ttm_bo_wait_unreserved(bo);
 				ttm_bo_unref(&bo);
 			}
diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index 73749d6d18f1..9fe753b5cc32 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -96,6 +96,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 	struct scatterlist *sg, *sg_list_start;
 	int need_release = 0;
 	unsigned int gup_flags = FOLL_WRITE;
+	mm_range_define(range);
 
 	if (dmasync)
 		dma_attrs |= DMA_ATTR_WRITE_BARRIER;
@@ -163,7 +164,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 
 	npages = ib_umem_num_pages(umem);
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm, &range);
 
 	locked     = npages + current->mm->pinned_vm;
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
@@ -236,7 +237,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 	} else
 		current->mm->pinned_vm = locked;
 
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &range);
 	if (vma_list)
 		free_page((unsigned long) vma_list);
 	free_page((unsigned long) page_list);
@@ -248,10 +249,11 @@ EXPORT_SYMBOL(ib_umem_get);
 static void ib_umem_account(struct work_struct *work)
 {
 	struct ib_umem *umem = container_of(work, struct ib_umem, work);
+	mm_range_define(range);
 
-	down_write(&umem->mm->mmap_sem);
+	mm_write_lock(umem->mm, &range);
 	umem->mm->pinned_vm -= umem->diff;
-	up_write(&umem->mm->mmap_sem);
+	mm_write_unlock(umem->mm, &range);
 	mmput(umem->mm);
 	kfree(umem);
 }
@@ -266,6 +268,7 @@ void ib_umem_release(struct ib_umem *umem)
 	struct mm_struct *mm;
 	struct task_struct *task;
 	unsigned long diff;
+	mm_range_define(range);
 
 	if (umem->odp_data) {
 		ib_umem_odp_release(umem);
@@ -294,7 +297,7 @@ void ib_umem_release(struct ib_umem *umem)
 	 * we defer the vm_locked accounting to the system workqueue.
 	 */
 	if (context->closing) {
-		if (!down_write_trylock(&mm->mmap_sem)) {
+		if (!mm_write_trylock(mm, &range)) {
 			INIT_WORK(&umem->work, ib_umem_account);
 			umem->mm   = mm;
 			umem->diff = diff;
@@ -303,10 +306,10 @@ void ib_umem_release(struct ib_umem *umem)
 			return;
 		}
 	} else
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm, &range);
 
 	mm->pinned_vm -= diff;
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	mmput(mm);
 out:
 	kfree(umem);
diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index 6e1e574db5d3..1dec59a4f070 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -654,8 +654,9 @@ int ib_umem_odp_map_dma_pages(struct ib_umem *umem, u64 user_virt, u64 bcnt,
 		const size_t gup_num_pages = min_t(size_t,
 				(bcnt + BIT(page_shift) - 1) >> page_shift,
 				PAGE_SIZE / sizeof(struct page *));
+		mm_range_define(range);
 
-		down_read(&owning_mm->mmap_sem);
+		mm_read_lock(owning_mm, &range);
 		/*
 		 * Note: this might result in redundent page getting. We can
 		 * avoid this by checking dma_list to be 0 before calling
@@ -666,7 +667,7 @@ int ib_umem_odp_map_dma_pages(struct ib_umem *umem, u64 user_virt, u64 bcnt,
 		npages = get_user_pages_remote(owning_process, owning_mm,
 				user_virt, gup_num_pages,
 				flags, local_page_list, NULL, NULL, NULL);
-		up_read(&owning_mm->mmap_sem);
+		mm_read_unlock(owning_mm, &range);
 
 		if (npages < 0)
 			break;
diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
index e341e6dcc388..7f359e6fd23d 100644
--- a/drivers/infiniband/hw/hfi1/user_pages.c
+++ b/drivers/infiniband/hw/hfi1/user_pages.c
@@ -76,6 +76,7 @@ bool hfi1_can_pin_pages(struct hfi1_devdata *dd, struct mm_struct *mm,
 	unsigned int usr_ctxts =
 			dd->num_rcv_contexts - dd->first_dyn_alloc_ctxt;
 	bool can_lock = capable(CAP_IPC_LOCK);
+	mm_range_define(range);
 
 	/*
 	 * Calculate per-cache size. The calculation below uses only a quarter
@@ -91,9 +92,9 @@ bool hfi1_can_pin_pages(struct hfi1_devdata *dd, struct mm_struct *mm,
 	/* Convert to number of pages */
 	size = DIV_ROUND_UP(size, PAGE_SIZE);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	pinned = mm->pinned_vm;
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 
 	/* First, check the absolute limit against all pinned pages. */
 	if (pinned + npages >= ulimit && !can_lock)
@@ -106,14 +107,15 @@ int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t np
 			    bool writable, struct page **pages)
 {
 	int ret;
+	mm_range_define(range);
 
 	ret = get_user_pages_fast(vaddr, npages, writable, pages);
 	if (ret < 0)
 		return ret;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &range);
 	mm->pinned_vm += ret;
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 
 	return ret;
 }
@@ -130,8 +132,10 @@ void hfi1_release_user_pages(struct mm_struct *mm, struct page **p,
 	}
 
 	if (mm) { /* during close after signal, mm can be NULL */
-		down_write(&mm->mmap_sem);
+		mm_range_define(range);
+
+		mm_write_lock(mm, &range);
 		mm->pinned_vm -= npages;
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &range);
 	}
 }
diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 521d0def2d9e..2cb24b8c43e5 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1142,6 +1142,7 @@ static void mlx4_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 	struct mlx4_ib_ucontext *context = to_mucontext(ibcontext);
 	struct task_struct *owning_process  = NULL;
 	struct mm_struct   *owning_mm       = NULL;
+	mm_range_define(range);
 
 	owning_process = get_pid_task(ibcontext->tgid, PIDTYPE_PID);
 	if (!owning_process)
@@ -1173,7 +1174,7 @@ static void mlx4_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 	/* need to protect from a race on closing the vma as part of
 	 * mlx4_ib_vma_close().
 	 */
-	down_write(&owning_mm->mmap_sem);
+	mm_read_lock(owning_mm, &range);
 	for (i = 0; i < HW_BAR_COUNT; i++) {
 		vma = context->hw_bar_info[i].vma;
 		if (!vma)
@@ -1193,7 +1194,7 @@ static void mlx4_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 		context->hw_bar_info[i].vma->vm_ops = NULL;
 	}
 
-	up_write(&owning_mm->mmap_sem);
+	mm_read_unlock(owning_mm, &range);
 	mmput(owning_mm);
 	put_task_struct(owning_process);
 }
diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index d45772da0963..417603dfd044 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1513,6 +1513,7 @@ static void mlx5_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 	struct mlx5_ib_ucontext *context = to_mucontext(ibcontext);
 	struct task_struct *owning_process  = NULL;
 	struct mm_struct   *owning_mm       = NULL;
+	mm_range_define(range);
 
 	owning_process = get_pid_task(ibcontext->tgid, PIDTYPE_PID);
 	if (!owning_process)
@@ -1542,7 +1543,7 @@ static void mlx5_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 	/* need to protect from a race on closing the vma as part of
 	 * mlx5_ib_vma_close.
 	 */
-	down_write(&owning_mm->mmap_sem);
+	mm_read_lock(owning_mm->mmap_sem, &range);
 	list_for_each_entry_safe(vma_private, n, &context->vma_private_list,
 				 list) {
 		vma = vma_private->vma;
@@ -1557,7 +1558,7 @@ static void mlx5_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 		list_del(&vma_private->list);
 		kfree(vma_private);
 	}
-	up_write(&owning_mm->mmap_sem);
+	mm_read_unlock(owning_mm->mmap_sem, &range);
 	mmput(owning_mm);
 	put_task_struct(owning_process);
 }
diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
index c1cf13f2722a..6bcd396a09b1 100644
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -134,25 +134,28 @@ int qib_get_user_pages(unsigned long start_page, size_t num_pages,
 		       struct page **p)
 {
 	int ret;
+	mm_range_define(range);
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm, &range);
 
 	ret = __qib_get_user_pages(start_page, num_pages, p);
 
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &range);
 
 	return ret;
 }
 
 void qib_release_user_pages(struct page **p, size_t num_pages)
 {
+	mm_range_define(range);
+
 	if (current->mm) /* during close after signal, mm can be NULL */
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm, &range);
 
 	__qib_release_user_pages(p, num_pages, 1);
 
 	if (current->mm) {
 		current->mm->pinned_vm -= num_pages;
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm, &range);
 	}
 }
diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniband/hw/usnic/usnic_uiom.c
index 1591d0e78bfa..62244bed96db 100644
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
@@ -57,10 +57,11 @@ static void usnic_uiom_reg_account(struct work_struct *work)
 {
 	struct usnic_uiom_reg *umem = container_of(work,
 						struct usnic_uiom_reg, work);
+	mm_range_define(range);
 
-	down_write(&umem->mm->mmap_sem);
+	mm_write_lock(umem->mm->mmap_sem, &range);
 	umem->mm->locked_vm -= umem->diff;
-	up_write(&umem->mm->mmap_sem);
+	mm_write_unlock(umem->mm->mmap_sem, &range);
 	mmput(umem->mm);
 	kfree(umem);
 }
@@ -113,6 +114,7 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 	int flags;
 	dma_addr_t pa;
 	unsigned int gup_flags;
+	mm_range_define(range);
 
 	if (!can_do_mlock())
 		return -EPERM;
@@ -125,7 +127,7 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 
 	npages = PAGE_ALIGN(size + (addr & ~PAGE_MASK)) >> PAGE_SHIFT;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm, &range);
 
 	locked = npages + current->mm->locked_vm;
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
@@ -188,7 +190,7 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 	else
 		current->mm->locked_vm = locked;
 
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &range);
 	free_page((unsigned long) page_list);
 	return ret;
 }
@@ -424,6 +426,7 @@ void usnic_uiom_reg_release(struct usnic_uiom_reg *uiomr, int closing)
 {
 	struct mm_struct *mm;
 	unsigned long diff;
+	mm_range_define(range);
 
 	__usnic_uiom_reg_release(uiomr->pd, uiomr, 1);
 
@@ -444,7 +447,7 @@ void usnic_uiom_reg_release(struct usnic_uiom_reg *uiomr, int closing)
 	 * we defer the vm_locked accounting to the system workqueue.
 	 */
 	if (closing) {
-		if (!down_write_trylock(&mm->mmap_sem)) {
+		if (!range_write_trylock(&mm->mmap_sem, &range)) {
 			INIT_WORK(&uiomr->work, usnic_uiom_reg_account);
 			uiomr->mm = mm;
 			uiomr->diff = diff;
@@ -453,10 +456,10 @@ void usnic_uiom_reg_release(struct usnic_uiom_reg *uiomr, int closing)
 			return;
 		}
 	} else
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm, &range);
 
 	current->mm->locked_vm -= diff;
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	mmput(mm);
 	kfree(uiomr);
 }
diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
index 6629c472eafd..de4ef49e21d8 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -519,6 +519,7 @@ static void do_fault(struct work_struct *work)
 	unsigned int flags = 0;
 	struct mm_struct *mm;
 	u64 address;
+	mm_range_define(range);
 
 	mm = fault->state->mm;
 	address = fault->address;
@@ -529,7 +530,7 @@ static void do_fault(struct work_struct *work)
 		flags |= FAULT_FLAG_WRITE;
 	flags |= FAULT_FLAG_REMOTE;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	vma = find_extend_vma(mm, address);
 	if (!vma || address < vma->vm_start)
 		/* failed to get a vma in the right range */
@@ -539,9 +540,9 @@ static void do_fault(struct work_struct *work)
 	if (access_error(vma, fault))
 		goto out;
 
-	ret = handle_mm_fault(vma, address, flags);
+	ret = handle_mm_fault(vma, address, flags, NULL);
 out:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 
 	if (ret & VM_FAULT_ERROR)
 		/* failed to service fault */
diff --git a/drivers/iommu/intel-svm.c b/drivers/iommu/intel-svm.c
index 4ba770b9cfbb..74927e17c8d2 100644
--- a/drivers/iommu/intel-svm.c
+++ b/drivers/iommu/intel-svm.c
@@ -544,6 +544,7 @@ static irqreturn_t prq_event_thread(int irq, void *d)
 		struct qi_desc resp;
 		int ret, result;
 		u64 address;
+		mm_range_define(range);
 
 		handled = 1;
 
@@ -582,7 +583,7 @@ static irqreturn_t prq_event_thread(int irq, void *d)
 		/* If the mm is already defunct, don't handle faults. */
 		if (!mmget_not_zero(svm->mm))
 			goto bad_req;
-		down_read(&svm->mm->mmap_sem);
+		mm_read_lock(svm->mm, &range);
 		vma = find_extend_vma(svm->mm, address);
 		if (!vma || address < vma->vm_start)
 			goto invalid;
@@ -597,7 +598,7 @@ static irqreturn_t prq_event_thread(int irq, void *d)
 
 		result = QI_RESP_SUCCESS;
 	invalid:
-		up_read(&svm->mm->mmap_sem);
+		mm_read_unlock(svm->mm, &range);
 		mmput(svm->mm);
 	bad_req:
 		/* Accounting for major/minor faults? */
diff --git a/drivers/media/v4l2-core/videobuf-core.c b/drivers/media/v4l2-core/videobuf-core.c
index 1dbf6f7785bb..ec9eab28e531 100644
--- a/drivers/media/v4l2-core/videobuf-core.c
+++ b/drivers/media/v4l2-core/videobuf-core.c
@@ -533,11 +533,12 @@ int videobuf_qbuf(struct videobuf_queue *q, struct v4l2_buffer *b)
 	enum v4l2_field field;
 	unsigned long flags = 0;
 	int retval;
+	mm_range_define(range);
 
 	MAGIC_CHECK(q->int_ops->magic, MAGIC_QTYPE_OPS);
 
 	if (b->memory == V4L2_MEMORY_MMAP)
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &range);
 
 	videobuf_queue_lock(q);
 	retval = -EBUSY;
@@ -624,7 +625,7 @@ int videobuf_qbuf(struct videobuf_queue *q, struct v4l2_buffer *b)
 	videobuf_queue_unlock(q);
 
 	if (b->memory == V4L2_MEMORY_MMAP)
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &range);
 
 	return retval;
 }
diff --git a/drivers/media/v4l2-core/videobuf-dma-contig.c b/drivers/media/v4l2-core/videobuf-dma-contig.c
index e02353e340dd..682b70a69753 100644
--- a/drivers/media/v4l2-core/videobuf-dma-contig.c
+++ b/drivers/media/v4l2-core/videobuf-dma-contig.c
@@ -166,12 +166,13 @@ static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
 	unsigned long pages_done, user_address;
 	unsigned int offset;
 	int ret;
+	mm_range_define(range);
 
 	offset = vb->baddr & ~PAGE_MASK;
 	mem->size = PAGE_ALIGN(vb->size + offset);
 	ret = -EINVAL;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 
 	vma = find_vma(mm, vb->baddr);
 	if (!vma)
@@ -203,7 +204,7 @@ static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
 	}
 
 out_up:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &range);
 
 	return ret;
 }
diff --git a/drivers/media/v4l2-core/videobuf-dma-sg.c b/drivers/media/v4l2-core/videobuf-dma-sg.c
index b789070047df..32e73381b9b7 100644
--- a/drivers/media/v4l2-core/videobuf-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
@@ -200,10 +200,11 @@ static int videobuf_dma_init_user(struct videobuf_dmabuf *dma, int direction,
 			   unsigned long data, unsigned long size)
 {
 	int ret;
+	mm_range_define(range);
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &range);
 	ret = videobuf_dma_init_user_locked(dma, direction, data, size);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &range);
 
 	return ret;
 }
diff --git a/drivers/misc/cxl/fault.c b/drivers/misc/cxl/fault.c
index 5344448f514e..96e4f9327c1e 100644
--- a/drivers/misc/cxl/fault.c
+++ b/drivers/misc/cxl/fault.c
@@ -296,6 +296,7 @@ static void cxl_prefault_vma(struct cxl_context *ctx)
 	struct vm_area_struct *vma;
 	int rc;
 	struct mm_struct *mm;
+	mm_range_define(range);
 
 	mm = get_mem_context(ctx);
 	if (mm == NULL) {
@@ -304,7 +305,7 @@ static void cxl_prefault_vma(struct cxl_context *ctx)
 		return;
 	}
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		for (ea = vma->vm_start; ea < vma->vm_end;
 				ea = next_segment(ea, slb.vsid)) {
@@ -319,7 +320,7 @@ static void cxl_prefault_vma(struct cxl_context *ctx)
 			last_esid = slb.esid;
 		}
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 
 	mmput(mm);
 }
diff --git a/drivers/misc/mic/scif/scif_rma.c b/drivers/misc/mic/scif/scif_rma.c
index 30e3c524216d..b446bfff42e7 100644
--- a/drivers/misc/mic/scif/scif_rma.c
+++ b/drivers/misc/mic/scif/scif_rma.c
@@ -275,19 +275,21 @@ static inline int
 __scif_dec_pinned_vm_lock(struct mm_struct *mm,
 			  int nr_pages, bool try_lock)
 {
+	mm_range_define(range);
+
 	if (!mm || !nr_pages || !scif_ulimit_check)
 		return 0;
 	if (try_lock) {
-		if (!down_write_trylock(&mm->mmap_sem)) {
+		if (!range_write_trylock(&mm->mmap_sem, &range)) {
 			dev_err(scif_info.mdev.this_device,
 				"%s %d err\n", __func__, __LINE__);
 			return -1;
 		}
 	} else {
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm, &range);
 	}
 	mm->pinned_vm -= nr_pages;
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	return 0;
 }
 
@@ -1333,6 +1335,7 @@ int __scif_pin_pages(void *addr, size_t len, int *out_prot,
 	int prot = *out_prot;
 	int ulimit = 0;
 	struct mm_struct *mm = NULL;
+	mm_range_define(range);
 
 	/* Unsupported flags */
 	if (map_flags & ~(SCIF_MAP_KERNEL | SCIF_MAP_ULIMIT))
@@ -1386,11 +1389,12 @@ int __scif_pin_pages(void *addr, size_t len, int *out_prot,
 		prot |= SCIF_PROT_WRITE;
 retry:
 		mm = current->mm;
-		down_write(&mm->mmap_sem);
+
+		mm_write_lock(mm, &range);
 		if (ulimit) {
 			err = __scif_check_inc_pinned_vm(mm, nr_pages);
 			if (err) {
-				up_write(&mm->mmap_sem);
+				mm_write_unlock(mm, &range);
 				pinned_pages->nr_pages = 0;
 				goto error_unmap;
 			}
@@ -1402,7 +1406,7 @@ int __scif_pin_pages(void *addr, size_t len, int *out_prot,
 				(prot & SCIF_PROT_WRITE) ? FOLL_WRITE : 0,
 				pinned_pages->pages,
 				NULL, NULL);
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &range);
 		if (nr_pages != pinned_pages->nr_pages) {
 			if (try_upgrade) {
 				if (ulimit)
diff --git a/drivers/oprofile/buffer_sync.c b/drivers/oprofile/buffer_sync.c
index ac27f3d3fbb4..f25d7bb1ea0d 100644
--- a/drivers/oprofile/buffer_sync.c
+++ b/drivers/oprofile/buffer_sync.c
@@ -90,12 +90,13 @@ munmap_notify(struct notifier_block *self, unsigned long val, void *data)
 	unsigned long addr = (unsigned long)data;
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *mpnt;
+	mm_range_define(range);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 
 	mpnt = find_vma(mm, addr);
 	if (mpnt && mpnt->vm_file && (mpnt->vm_flags & VM_EXEC)) {
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &range);
 		/* To avoid latency problems, we only process the current CPU,
 		 * hoping that most samples for the task are on this CPU
 		 */
@@ -103,7 +104,7 @@ munmap_notify(struct notifier_block *self, unsigned long val, void *data)
 		return 0;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 	return 0;
 }
 
@@ -255,8 +256,9 @@ lookup_dcookie(struct mm_struct *mm, unsigned long addr, off_t *offset)
 {
 	unsigned long cookie = NO_COOKIE;
 	struct vm_area_struct *vma;
+	mm_range_define(range);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	for (vma = find_vma(mm, addr); vma; vma = vma->vm_next) {
 
 		if (addr < vma->vm_start || addr >= vma->vm_end)
@@ -276,7 +278,7 @@ lookup_dcookie(struct mm_struct *mm, unsigned long addr, off_t *offset)
 
 	if (!vma)
 		cookie = INVALID_COOKIE;
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 
 	return cookie;
 }
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index cbbfdaf127a7..9853b6c4cd4d 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -61,9 +61,10 @@ struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
 			       size_t count)
 {
 	struct vm_area_struct *vma, *ret = NULL;
+	mm_range_define(range);
 
 	/* mmap_sem must have been held by caller. */
-	LASSERT(!down_write_trylock(&mm->mmap_sem));
+	LASSERT(!range_write_trylock(&mm->mmap_sem, &range));
 
 	for (vma = find_vma(mm, addr);
 	    vma && vma->vm_start < (addr + count); vma = vma->vm_next) {
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index aa31bc0a58a6..ce0bd479a1c5 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -377,6 +377,7 @@ static int vvp_mmap_locks(const struct lu_env *env,
 	int		 result = 0;
 	struct iov_iter i;
 	struct iovec iov;
+	mm_range_define(range);
 
 	LASSERT(io->ci_type == CIT_READ || io->ci_type == CIT_WRITE);
 
@@ -396,7 +397,7 @@ static int vvp_mmap_locks(const struct lu_env *env,
 		count += addr & (~PAGE_MASK);
 		addr &= PAGE_MASK;
 
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &range);
 		while ((vma = our_vma(mm, addr, count)) != NULL) {
 			struct inode *inode = file_inode(vma->vm_file);
 			int flags = CEF_MUST;
@@ -437,7 +438,7 @@ static int vvp_mmap_locks(const struct lu_env *env,
 			count -= vma->vm_end - addr;
 			addr = vma->vm_end;
 		}
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &range);
 		if (result < 0)
 			break;
 	}
diff --git a/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c b/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c
index d04db3f55519..bf70914e2bea 100644
--- a/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c
+++ b/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c
@@ -468,14 +468,16 @@ create_pagelist(char __user *buf, size_t count, unsigned short type,
 		}
 		/* do not try and release vmalloc pages */
 	} else {
-		down_read(&task->mm->mmap_sem);
+		mm_range_define(range);
+
+		mm_read_lock(task->mm->mmap_sem, &range);
 		actual_pages = get_user_pages(
 				          (unsigned long)buf & ~(PAGE_SIZE - 1),
 					  num_pages,
 					  (type == PAGELIST_READ) ? FOLL_WRITE : 0,
 					  pages,
 					  NULL /*vmas */);
-		up_read(&task->mm->mmap_sem);
+		mm_read_unlock(task->mm->mmap_sem, &range);
 
 		if (actual_pages != num_pages) {
 			vchiq_log_info(vchiq_arm_log_level,
diff --git a/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_arm.c b/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_arm.c
index e823f1d5d177..2177f7852e68 100644
--- a/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_arm.c
+++ b/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_arm.c
@@ -2069,6 +2069,7 @@ dump_phys_mem(void *virt_addr, u32 num_bytes)
 	struct page   *page;
 	struct page  **pages;
 	u8            *kmapped_virt_ptr;
+	mm_range_define(range);
 
 	/* Align virtAddr and endVirtAddr to 16 byte boundaries. */
 
@@ -2089,14 +2090,14 @@ dump_phys_mem(void *virt_addr, u32 num_bytes)
 		return;
 	}
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &range);
 	rc = get_user_pages(
 		(unsigned long)virt_addr, /* start */
 		num_pages,                /* len */
 		0,                        /* gup_flags */
 		pages,                    /* pages (array of page pointers) */
 		NULL);                    /* vmas */
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &range);
 
 	prev_idx = -1;
 	page = NULL;
diff --git a/drivers/vfio/vfio_iommu_spapr_tce.c b/drivers/vfio/vfio_iommu_spapr_tce.c
index 63112c36ab2d..a8af18ac0e3b 100644
--- a/drivers/vfio/vfio_iommu_spapr_tce.c
+++ b/drivers/vfio/vfio_iommu_spapr_tce.c
@@ -37,6 +37,7 @@ static void tce_iommu_detach_group(void *iommu_data,
 static long try_increment_locked_vm(struct mm_struct *mm, long npages)
 {
 	long ret = 0, locked, lock_limit;
+	mm_range_define(range);
 
 	if (WARN_ON_ONCE(!mm))
 		return -EPERM;
@@ -44,7 +45,7 @@ static long try_increment_locked_vm(struct mm_struct *mm, long npages)
 	if (!npages)
 		return 0;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &range);
 	locked = mm->locked_vm + npages;
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
 	if (locked > lock_limit && !capable(CAP_IPC_LOCK))
@@ -58,17 +59,19 @@ static long try_increment_locked_vm(struct mm_struct *mm, long npages)
 			rlimit(RLIMIT_MEMLOCK),
 			ret ? " - exceeded" : "");
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 
 	return ret;
 }
 
 static void decrement_locked_vm(struct mm_struct *mm, long npages)
 {
+	mm_range_define(range);
+
 	if (!mm || !npages)
 		return;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &range);
 	if (WARN_ON_ONCE(npages > mm->locked_vm))
 		npages = mm->locked_vm;
 	mm->locked_vm -= npages;
@@ -76,7 +79,7 @@ static void decrement_locked_vm(struct mm_struct *mm, long npages)
 			npages << PAGE_SHIFT,
 			mm->locked_vm << PAGE_SHIFT,
 			rlimit(RLIMIT_MEMLOCK));
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 }
 
 /*
diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index 8549cb111627..ac6c86a5fa75 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -251,6 +251,7 @@ static int vfio_lock_acct(struct task_struct *task, long npage, bool *lock_cap)
 	struct mm_struct *mm;
 	bool is_current;
 	int ret;
+	mm_range_define(range);
 
 	if (!npage)
 		return 0;
@@ -261,7 +262,7 @@ static int vfio_lock_acct(struct task_struct *task, long npage, bool *lock_cap)
 	if (!mm)
 		return -ESRCH; /* process exited */
 
-	ret = down_write_killable(&mm->mmap_sem);
+	ret = mm_write_trylock(mm, &range);
 	if (!ret) {
 		if (npage > 0) {
 			if (lock_cap ? !*lock_cap :
@@ -279,7 +280,7 @@ static int vfio_lock_acct(struct task_struct *task, long npage, bool *lock_cap)
 		if (!ret)
 			mm->locked_vm += npage;
 
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm);
 	}
 
 	if (!is_current)
@@ -339,6 +340,7 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 	struct page *page[1];
 	struct vm_area_struct *vma;
 	int ret;
+	mm_range_define(range);
 
 	if (mm == current->mm) {
 		ret = get_user_pages_fast(vaddr, 1, !!(prot & IOMMU_WRITE),
@@ -349,10 +351,10 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 		if (prot & IOMMU_WRITE)
 			flags |= FOLL_WRITE;
 
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &range);
 		ret = get_user_pages_remote(NULL, mm, vaddr, 1, flags, page,
-					    NULL, NULL);
-		up_read(&mm->mmap_sem);
+					    NULL, NULL, NULL);
+		mm_read_unlock(mm, &range);
 	}
 
 	if (ret == 1) {
@@ -360,7 +362,7 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 		return 0;
 	}
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 
 	vma = find_vma_intersection(mm, vaddr, vaddr + 1);
 
@@ -370,7 +372,7 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 			ret = 0;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 	return ret;
 }
 
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index f3bf8f4e2d6c..b0be7f3b48ec 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -658,12 +658,13 @@ static long gntdev_ioctl_get_offset_for_vaddr(struct gntdev_priv *priv,
 	struct vm_area_struct *vma;
 	struct grant_map *map;
 	int rv = -EINVAL;
+	mm_range_define(range);
 
 	if (copy_from_user(&op, u, sizeof(op)) != 0)
 		return -EFAULT;
 	pr_debug("priv %p, offset for vaddr %lx\n", priv, (unsigned long)op.vaddr);
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &range);
 	vma = find_vma(current->mm, op.vaddr);
 	if (!vma || vma->vm_ops != &gntdev_vmops)
 		goto out_unlock;
@@ -677,7 +678,7 @@ static long gntdev_ioctl_get_offset_for_vaddr(struct gntdev_priv *priv,
 	rv = 0;
 
  out_unlock:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &range);
 
 	if (rv == 0 && copy_to_user(u, &op, sizeof(op)) != 0)
 		return -EFAULT;
diff --git a/drivers/xen/privcmd.c b/drivers/xen/privcmd.c
index 7a92a5e1d40c..156a708bfff4 100644
--- a/drivers/xen/privcmd.c
+++ b/drivers/xen/privcmd.c
@@ -260,6 +260,7 @@ static long privcmd_ioctl_mmap(struct file *file, void __user *udata)
 	int rc;
 	LIST_HEAD(pagelist);
 	struct mmap_gfn_state state;
+	mm_range_define(range);
 
 	/* We only support privcmd_ioctl_mmap_batch for auto translated. */
 	if (xen_feature(XENFEAT_auto_translated_physmap))
@@ -279,7 +280,7 @@ static long privcmd_ioctl_mmap(struct file *file, void __user *udata)
 	if (rc || list_empty(&pagelist))
 		goto out;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &range);
 
 	{
 		struct page *page = list_first_entry(&pagelist,
@@ -304,7 +305,7 @@ static long privcmd_ioctl_mmap(struct file *file, void __user *udata)
 
 
 out_up:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 
 out:
 	free_page_list(&pagelist);
@@ -454,6 +455,7 @@ static long privcmd_ioctl_mmap_batch(
 	unsigned long nr_pages;
 	LIST_HEAD(pagelist);
 	struct mmap_batch_state state;
+	mm_range_define(range);
 
 	switch (version) {
 	case 1:
@@ -500,7 +502,7 @@ static long privcmd_ioctl_mmap_batch(
 		}
 	}
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &range);
 
 	vma = find_vma(mm, m.addr);
 	if (!vma ||
@@ -556,7 +558,7 @@ static long privcmd_ioctl_mmap_batch(
 	BUG_ON(traverse_pages_block(m.num, sizeof(xen_pfn_t),
 				    &pagelist, mmap_batch_fn, &state));
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 
 	if (state.global_error) {
 		/* Write back errors in second pass. */
@@ -577,7 +579,7 @@ static long privcmd_ioctl_mmap_batch(
 	return ret;
 
 out_unlock:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	goto out;
 }
 
diff --git a/fs/aio.c b/fs/aio.c
index f52d925ee259..5c3057c0b85f 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -450,6 +450,7 @@ static int aio_setup_ring(struct kioctx *ctx)
 	int nr_pages;
 	int i;
 	struct file *file;
+	mm_range_define(range);
 
 	/* Compensate for the ring buffer's head/tail overlap entry */
 	nr_events += 2;	/* 1 is required, 2 for good luck */
@@ -504,7 +505,7 @@ static int aio_setup_ring(struct kioctx *ctx)
 	ctx->mmap_size = nr_pages * PAGE_SIZE;
 	pr_debug("attempting mmap of %lu bytes\n", ctx->mmap_size);
 
-	if (down_write_killable(&mm->mmap_sem)) {
+	if (mm_write_lock_killable(mm, &range)) {
 		ctx->mmap_size = 0;
 		aio_free_ring(ctx);
 		return -EINTR;
@@ -513,7 +514,7 @@ static int aio_setup_ring(struct kioctx *ctx)
 	ctx->mmap_base = do_mmap_pgoff(ctx->aio_ring_file, 0, ctx->mmap_size,
 				       PROT_READ | PROT_WRITE,
 				       MAP_SHARED, 0, &unused, NULL);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	if (IS_ERR((void *)ctx->mmap_base)) {
 		ctx->mmap_size = 0;
 		aio_free_ring(ctx);
diff --git a/fs/coredump.c b/fs/coredump.c
index 592683711c64..9a08dcc78bcb 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -411,17 +411,18 @@ static int coredump_wait(int exit_code, struct core_state *core_state)
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
 	int core_waiters = -EBUSY;
+	mm_range_define(range);
 
 	init_completion(&core_state->startup);
 	core_state->dumper.task = tsk;
 	core_state->dumper.next = NULL;
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &range))
 		return -EINTR;
 
 	if (!mm->core_state)
 		core_waiters = zap_threads(tsk, mm, core_state, exit_code);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 
 	if (core_waiters > 0) {
 		struct core_thread *ptr;
diff --git a/fs/exec.c b/fs/exec.c
index ef44ce8302b6..32b06728580b 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -268,12 +268,13 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
 	int err;
 	struct vm_area_struct *vma = NULL;
 	struct mm_struct *mm = bprm->mm;
+	mm_range_define(range);
 
 	bprm->vma = vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
 	if (!vma)
 		return -ENOMEM;
 
-	if (down_write_killable(&mm->mmap_sem)) {
+	if (mm_write_lock_killable(mm, &range)) {
 		err = -EINTR;
 		goto err_free;
 	}
@@ -298,11 +299,11 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
 
 	mm->stack_vm = mm->total_vm = 1;
 	arch_bprm_mm_init(mm, vma);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	bprm->p = vma->vm_end - sizeof(void *);
 	return 0;
 err:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 err_free:
 	bprm->vma = NULL;
 	kmem_cache_free(vm_area_cachep, vma);
@@ -673,6 +674,7 @@ int setup_arg_pages(struct linux_binprm *bprm,
 	unsigned long stack_size;
 	unsigned long stack_expand;
 	unsigned long rlim_stack;
+	mm_range_define(range);
 
 #ifdef CONFIG_STACK_GROWSUP
 	/* Limit stack size */
@@ -710,7 +712,7 @@ int setup_arg_pages(struct linux_binprm *bprm,
 		bprm->loader -= stack_shift;
 	bprm->exec -= stack_shift;
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &range))
 		return -EINTR;
 
 	vm_flags = VM_STACK_FLAGS;
@@ -767,7 +769,7 @@ int setup_arg_pages(struct linux_binprm *bprm,
 		ret = -EFAULT;
 
 out_unlock:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	return ret;
 }
 EXPORT_SYMBOL(setup_arg_pages);
@@ -1001,6 +1003,7 @@ static int exec_mmap(struct mm_struct *mm)
 {
 	struct task_struct *tsk;
 	struct mm_struct *old_mm, *active_mm;
+	mm_range_define(range);
 
 	/* Notify parent that we're no longer interested in the old VM */
 	tsk = current;
@@ -1015,9 +1018,10 @@ static int exec_mmap(struct mm_struct *mm)
 		 * through with the exec.  We must hold mmap_sem around
 		 * checking core_state and changing tsk->mm.
 		 */
-		down_read(&old_mm->mmap_sem);
+
+		mm_read_lock(old_mm, &range);
 		if (unlikely(old_mm->core_state)) {
-			up_read(&old_mm->mmap_sem);
+			mm_read_unlock(old_mm, &range);
 			return -EINTR;
 		}
 	}
@@ -1030,7 +1034,7 @@ static int exec_mmap(struct mm_struct *mm)
 	vmacache_flush(tsk);
 	task_unlock(tsk);
 	if (old_mm) {
-		up_read(&old_mm->mmap_sem);
+		mm_read_unlock(old_mm, &range);
 		BUG_ON(active_mm != old_mm);
 		setmax_mm_hiwater_rss(&tsk->signal->maxrss, old_mm);
 		mm_update_next_owner(old_mm);
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 45f6bf68fff3..39b80fd96c77 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -216,6 +216,7 @@ static ssize_t proc_pid_cmdline_read(struct file *file, char __user *buf,
 	unsigned long p;
 	char c;
 	ssize_t rv;
+	mm_range_define(range);
 
 	BUG_ON(*pos < 0);
 
@@ -238,12 +239,12 @@ static ssize_t proc_pid_cmdline_read(struct file *file, char __user *buf,
 		goto out_mmput;
 	}
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	arg_start = mm->arg_start;
 	arg_end = mm->arg_end;
 	env_start = mm->env_start;
 	env_end = mm->env_end;
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 
 	BUG_ON(arg_start > arg_end);
 	BUG_ON(env_start > env_end);
@@ -913,6 +914,7 @@ static ssize_t environ_read(struct file *file, char __user *buf,
 	int ret = 0;
 	struct mm_struct *mm = file->private_data;
 	unsigned long env_start, env_end;
+	mm_range_define(range);
 
 	/* Ensure the process spawned far enough to have an environment. */
 	if (!mm || !mm->env_end)
@@ -926,10 +928,10 @@ static ssize_t environ_read(struct file *file, char __user *buf,
 	if (!mmget_not_zero(mm))
 		goto free;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	env_start = mm->env_start;
 	env_end = mm->env_end;
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 
 	while (count > 0) {
 		size_t this_len, max_len;
@@ -1877,6 +1879,7 @@ static int map_files_d_revalidate(struct dentry *dentry, unsigned int flags)
 	struct task_struct *task;
 	struct inode *inode;
 	int status = 0;
+	mm_range_define(range);
 
 	if (flags & LOOKUP_RCU)
 		return -ECHILD;
@@ -1891,9 +1894,9 @@ static int map_files_d_revalidate(struct dentry *dentry, unsigned int flags)
 		goto out;
 
 	if (!dname_to_vma_addr(dentry, &vm_start, &vm_end)) {
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &range);
 		exact_vma_exists = !!find_exact_vma(mm, vm_start, vm_end);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &range);
 	}
 
 	mmput(mm);
@@ -1924,6 +1927,7 @@ static int map_files_get_link(struct dentry *dentry, struct path *path)
 	struct task_struct *task;
 	struct mm_struct *mm;
 	int rc;
+	mm_range_define(range);
 
 	rc = -ENOENT;
 	task = get_proc_task(d_inode(dentry));
@@ -1940,14 +1944,14 @@ static int map_files_get_link(struct dentry *dentry, struct path *path)
 		goto out_mmput;
 
 	rc = -ENOENT;
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	vma = find_exact_vma(mm, vm_start, vm_end);
 	if (vma && vma->vm_file) {
 		*path = vma->vm_file->f_path;
 		path_get(path);
 		rc = 0;
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 
 out_mmput:
 	mmput(mm);
@@ -2020,6 +2024,7 @@ static struct dentry *proc_map_files_lookup(struct inode *dir,
 	struct task_struct *task;
 	int result;
 	struct mm_struct *mm;
+	mm_range_define(range);
 
 	result = -ENOENT;
 	task = get_proc_task(dir);
@@ -2038,7 +2043,7 @@ static struct dentry *proc_map_files_lookup(struct inode *dir,
 	if (!mm)
 		goto out_put_task;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	vma = find_exact_vma(mm, vm_start, vm_end);
 	if (!vma)
 		goto out_no_vma;
@@ -2048,7 +2053,7 @@ static struct dentry *proc_map_files_lookup(struct inode *dir,
 				(void *)(unsigned long)vma->vm_file->f_mode);
 
 out_no_vma:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 	mmput(mm);
 out_put_task:
 	put_task_struct(task);
@@ -2073,6 +2078,7 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
 	struct map_files_info info;
 	struct map_files_info *p;
 	int ret;
+	mm_range_define(range);
 
 	ret = -ENOENT;
 	task = get_proc_task(file_inode(file));
@@ -2090,7 +2096,7 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
 	mm = get_task_mm(task);
 	if (!mm)
 		goto out_put_task;
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 
 	nr_files = 0;
 
@@ -2117,7 +2123,7 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
 			ret = -ENOMEM;
 			if (fa)
 				flex_array_free(fa);
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm, &range);
 			mmput(mm);
 			goto out_put_task;
 		}
@@ -2136,7 +2142,7 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
 				BUG();
 		}
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 
 	for (i = 0; i < nr_files; i++) {
 		p = flex_array_get(fa, i);
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index c5ae09b6c726..26f402a02ebc 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -279,6 +279,9 @@ struct proc_maps_private {
 #ifdef CONFIG_NUMA
 	struct mempolicy *task_mempolicy;
 #endif
+#ifdef CONFIG_MEM_RANGE_LOCK
+	struct range_lock range;
+#endif
 };
 
 struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode);
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index f0c8b33d99b1..9a0137c287db 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -133,7 +133,7 @@ static void vma_stop(struct proc_maps_private *priv)
 	struct mm_struct *mm = priv->mm;
 
 	release_task_mempolicy(priv);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &priv->range);
 	mmput(mm);
 }
 
@@ -171,7 +171,7 @@ static void *m_start(struct seq_file *m, loff_t *ppos)
 	if (!mm || !mmget_not_zero(mm))
 		return NULL;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &priv->range);
 	hold_task_mempolicy(priv);
 	priv->tail_vma = get_gate_vma(mm);
 
@@ -1015,6 +1015,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 	enum clear_refs_types type;
 	int itype;
 	int rv;
+	mm_range_define(range);
 
 	memset(buffer, 0, sizeof(buffer));
 	if (count > sizeof(buffer) - 1)
@@ -1044,7 +1045,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 		};
 
 		if (type == CLEAR_REFS_MM_HIWATER_RSS) {
-			if (down_write_killable(&mm->mmap_sem)) {
+			if (mm_write_lock_killable(mm, &range)) {
 				count = -EINTR;
 				goto out_mm;
 			}
@@ -1054,17 +1055,17 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 			 * resident set size to this mm's current rss value.
 			 */
 			reset_mm_hiwater_rss(mm);
-			up_write(&mm->mmap_sem);
+			mm_write_unlock(mm, &range);
 			goto out_mm;
 		}
 
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &range);
 		if (type == CLEAR_REFS_SOFT_DIRTY) {
 			for (vma = mm->mmap; vma; vma = vma->vm_next) {
 				if (!(vma->vm_flags & VM_SOFTDIRTY))
 					continue;
-				up_read(&mm->mmap_sem);
-				if (down_write_killable(&mm->mmap_sem)) {
+				mm_read_unlock(mm, &range);
+				if (mm_write_lock_killable(mm, &range)) {
 					count = -EINTR;
 					goto out_mm;
 				}
@@ -1072,7 +1073,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 					vma->vm_flags &= ~VM_SOFTDIRTY;
 					vma_set_page_prot(vma);
 				}
-				downgrade_write(&mm->mmap_sem);
+				mm_downgrade_write(mm, &range);
 				break;
 			}
 			mmu_notifier_invalidate_range_start(mm, 0, -1);
@@ -1081,7 +1082,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 		if (type == CLEAR_REFS_SOFT_DIRTY)
 			mmu_notifier_invalidate_range_end(mm, 0, -1);
 		flush_tlb_mm(mm);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &range);
 out_mm:
 		mmput(mm);
 	}
@@ -1365,6 +1366,7 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 	unsigned long start_vaddr;
 	unsigned long end_vaddr;
 	int ret = 0, copied = 0;
+	mm_range_define(range);
 
 	if (!mm || !mmget_not_zero(mm))
 		goto out;
@@ -1420,9 +1422,9 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 		/* overflow ? */
 		if (end < start_vaddr || end > end_vaddr)
 			end = end_vaddr;
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &range);
 		ret = walk_page_range(start_vaddr, end, &pagemap_walk);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &range);
 		start_vaddr = end;
 
 		len = min(count, PM_ENTRY_BYTES * pm.pos);
diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index 23266694db11..7ef4db48636e 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -23,8 +23,9 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 	struct vm_region *region;
 	struct rb_node *p;
 	unsigned long bytes = 0, sbytes = 0, slack = 0, size;
-        
-	down_read(&mm->mmap_sem);
+	mm_range_define(range);
+
+	mm_read_lock(mm, &range);
 	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p)) {
 		vma = rb_entry(p, struct vm_area_struct, vm_rb);
 
@@ -76,7 +77,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		"Shared:\t%8lu bytes\n",
 		bytes, slack, sbytes);
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 }
 
 unsigned long task_vsize(struct mm_struct *mm)
@@ -84,13 +85,14 @@ unsigned long task_vsize(struct mm_struct *mm)
 	struct vm_area_struct *vma;
 	struct rb_node *p;
 	unsigned long vsize = 0;
+	mm_range_define(range);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p)) {
 		vma = rb_entry(p, struct vm_area_struct, vm_rb);
 		vsize += vma->vm_end - vma->vm_start;
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 	return vsize;
 }
 
@@ -102,8 +104,9 @@ unsigned long task_statm(struct mm_struct *mm,
 	struct vm_region *region;
 	struct rb_node *p;
 	unsigned long size = kobjsize(mm);
+	mm_range_define(range);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p)) {
 		vma = rb_entry(p, struct vm_area_struct, vm_rb);
 		size += kobjsize(vma);
@@ -118,7 +121,7 @@ unsigned long task_statm(struct mm_struct *mm,
 		>> PAGE_SHIFT;
 	*data = (PAGE_ALIGN(mm->start_stack) - (mm->start_data & PAGE_MASK))
 		>> PAGE_SHIFT;
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 	size >>= PAGE_SHIFT;
 	size += *text + *data;
 	*resident = size;
@@ -224,13 +227,14 @@ static void *m_start(struct seq_file *m, loff_t *pos)
 	if (!mm || !mmget_not_zero(mm))
 		return NULL;
 
-	down_read(&mm->mmap_sem);
+	range_lock_init_full(&priv->range);
+	mm_read_lock(mm->mmap_sem, &priv->range);
 	/* start from the Nth VMA */
 	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p))
 		if (n-- == 0)
 			return p;
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm->mmap_sem, &priv->range);
 	mmput(mm);
 	return NULL;
 }
@@ -240,7 +244,7 @@ static void m_stop(struct seq_file *m, void *_vml)
 	struct proc_maps_private *priv = m->private;
 
 	if (!IS_ERR_OR_NULL(_vml)) {
-		up_read(&priv->mm->mmap_sem);
+		mm_read_unlock(priv->mm->mmap_sem, &priv->range);
 		mmput(priv->mm);
 	}
 	if (priv->task) {
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 7d56c21ef65d..2d769640b9db 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -443,7 +443,7 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 	else
 		must_wait = userfaultfd_huge_must_wait(ctx, vmf->address,
 						       vmf->flags, reason);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, vmf->lockrange);
 
 	if (likely(must_wait && !ACCESS_ONCE(ctx->released) &&
 		   (return_to_userland ? !signal_pending(current) :
@@ -497,7 +497,7 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 			 * and there's no need to retake the mmap_sem
 			 * in such case.
 			 */
-			down_read(&mm->mmap_sem);
+			mm_read_lock(mm, vmf->lockrange);
 			ret = VM_FAULT_NOPAGE;
 		}
 	}
@@ -719,7 +719,7 @@ bool _userfaultfd_remove(struct vm_area_struct *vma,
 		return true;
 
 	userfaultfd_ctx_get(ctx);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, range);
 
 	msg_init(&ewq.msg);
 
@@ -798,6 +798,7 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 	/* len == 0 means wake all */
 	struct userfaultfd_wake_range range = { .len = 0, };
 	unsigned long new_flags;
+	mm_range_define(lockrange);
 
 	ACCESS_ONCE(ctx->released) = true;
 
@@ -812,7 +813,7 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 	 * it's critical that released is set to true (above), before
 	 * taking the mmap_sem for writing.
 	 */
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &lockrange);
 	prev = NULL;
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		cond_resched();
@@ -835,7 +836,7 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 		vma->vm_flags = new_flags;
 		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
 	}
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &lockrange);
 	mmput(mm);
 wakeup:
 	/*
@@ -1195,6 +1196,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	bool found;
 	bool non_anon_pages;
 	unsigned long start, end, vma_end;
+	mm_range_define(range);
 
 	user_uffdio_register = (struct uffdio_register __user *) arg;
 
@@ -1234,7 +1236,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	if (!mmget_not_zero(mm))
 		goto out;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &range);
 	vma = find_vma_prev(mm, start, &prev);
 	if (!vma)
 		goto out_unlock;
@@ -1362,7 +1364,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		vma = vma->vm_next;
 	} while (vma && vma->vm_start < end);
 out_unlock:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	mmput(mm);
 	if (!ret) {
 		/*
@@ -1390,6 +1392,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	bool found;
 	unsigned long start, end, vma_end;
 	const void __user *buf = (void __user *)arg;
+	mm_range_define(range);
 
 	ret = -EFAULT;
 	if (copy_from_user(&uffdio_unregister, buf, sizeof(uffdio_unregister)))
@@ -1407,7 +1410,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	if (!mmget_not_zero(mm))
 		goto out;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &range);
 	vma = find_vma_prev(mm, start, &prev);
 	if (!vma)
 		goto out_unlock;
@@ -1520,7 +1523,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		vma = vma->vm_next;
 	} while (vma && vma->vm_start < end);
 out_unlock:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	mmput(mm);
 out:
 	return ret;
diff --git a/ipc/shm.c b/ipc/shm.c
index 34c4344e8d4b..29806da63b85 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -1107,6 +1107,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg,
 	struct path path;
 	fmode_t f_mode;
 	unsigned long populate = 0;
+	mm_range_define(range);
 
 	err = -EINVAL;
 	if (shmid < 0)
@@ -1211,7 +1212,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg,
 	if (err)
 		goto out_fput;
 
-	if (down_write_killable(&current->mm->mmap_sem)) {
+	if (mm_write_lock_killable(current->mm, &range)) {
 		err = -EINTR;
 		goto out_fput;
 	}
@@ -1231,7 +1232,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg,
 	if (IS_ERR_VALUE(addr))
 		err = (long)addr;
 invalid:
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &range);
 	if (populate)
 		mm_populate(addr, populate);
 
@@ -1282,11 +1283,12 @@ SYSCALL_DEFINE1(shmdt, char __user *, shmaddr)
 	struct file *file;
 	struct vm_area_struct *next;
 #endif
+	mm_range_define(range);
 
 	if (addr & ~PAGE_MASK)
 		return retval;
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &range))
 		return -EINTR;
 
 	/*
@@ -1374,7 +1376,7 @@ SYSCALL_DEFINE1(shmdt, char __user *, shmaddr)
 
 #endif
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	return retval;
 }
 
diff --git a/kernel/acct.c b/kernel/acct.c
index 5b1284370367..5a3c7fe2ddd1 100644
--- a/kernel/acct.c
+++ b/kernel/acct.c
@@ -537,14 +537,15 @@ void acct_collect(long exitcode, int group_dead)
 
 	if (group_dead && current->mm) {
 		struct vm_area_struct *vma;
+		mm_range_define(range);
 
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &range);
 		vma = current->mm->mmap;
 		while (vma) {
 			vsize += vma->vm_end - vma->vm_start;
 			vma = vma->vm_next;
 		}
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &range);
 	}
 
 	spin_lock_irq(&current->sighand->siglock);
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 6e75a5c9412d..ec06c764742d 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -8223,6 +8223,7 @@ static void perf_event_addr_filters_apply(struct perf_event *event)
 	struct mm_struct *mm = NULL;
 	unsigned int count = 0;
 	unsigned long flags;
+	mm_range_define(range);
 
 	/*
 	 * We may observe TASK_TOMBSTONE, which means that the event tear-down
@@ -8238,7 +8239,7 @@ static void perf_event_addr_filters_apply(struct perf_event *event)
 	if (!mm)
 		goto restart;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 
 	raw_spin_lock_irqsave(&ifh->lock, flags);
 	list_for_each_entry(filter, &ifh->list, entry) {
@@ -8258,7 +8259,7 @@ static void perf_event_addr_filters_apply(struct perf_event *event)
 	event->addr_filters_gen++;
 	raw_spin_unlock_irqrestore(&ifh->lock, flags);
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 
 	mmput(mm);
 
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index dc2e5f7a8bb8..9cb52b895cb0 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -806,11 +806,12 @@ register_for_each_vma(struct uprobe *uprobe, struct uprobe_consumer *new)
 	while (info) {
 		struct mm_struct *mm = info->mm;
 		struct vm_area_struct *vma;
+		mm_range_define(range);
 
 		if (err && is_register)
 			goto free;
 
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm, &range);
 		vma = find_vma(mm, info->vaddr);
 		if (!vma || !valid_vma(vma, is_register) ||
 		    file_inode(vma->vm_file) != uprobe->inode)
@@ -832,7 +833,7 @@ register_for_each_vma(struct uprobe *uprobe, struct uprobe_consumer *new)
 		}
 
  unlock:
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &range);
  free:
 		mmput(mm);
 		info = free_map_info(info);
@@ -972,8 +973,9 @@ static int unapply_uprobe(struct uprobe *uprobe, struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
 	int err = 0;
+	mm_range_define(range);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		unsigned long vaddr;
 		loff_t offset;
@@ -990,7 +992,7 @@ static int unapply_uprobe(struct uprobe *uprobe, struct mm_struct *mm)
 		vaddr = offset_to_vaddr(vma, uprobe->offset);
 		err |= remove_breakpoint(uprobe, mm, vaddr);
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 
 	return err;
 }
@@ -1139,8 +1141,9 @@ static int xol_add_vma(struct mm_struct *mm, struct xol_area *area)
 {
 	struct vm_area_struct *vma;
 	int ret;
+	mm_range_define(range);
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &range))
 		return -EINTR;
 
 	if (mm->uprobes_state.xol_area) {
@@ -1170,7 +1173,7 @@ static int xol_add_vma(struct mm_struct *mm, struct xol_area *area)
 	smp_wmb();	/* pairs with get_xol_area() */
 	mm->uprobes_state.xol_area = area;
  fail:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 
 	return ret;
 }
@@ -1736,8 +1739,9 @@ static struct uprobe *find_active_uprobe(unsigned long bp_vaddr, int *is_swbp)
 	struct mm_struct *mm = current->mm;
 	struct uprobe *uprobe = NULL;
 	struct vm_area_struct *vma;
+	mm_range_define(range);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	vma = find_vma(mm, bp_vaddr);
 	if (vma && vma->vm_start <= bp_vaddr) {
 		if (valid_vma(vma, false)) {
@@ -1755,7 +1759,7 @@ static struct uprobe *find_active_uprobe(unsigned long bp_vaddr, int *is_swbp)
 
 	if (!uprobe && test_and_clear_bit(MMF_RECALC_UPROBES, &mm->flags))
 		mmf_recalc_uprobes(mm);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 
 	return uprobe;
 }
diff --git a/kernel/exit.c b/kernel/exit.c
index 516acdb0e0ec..f2f6c99ffd0f 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -508,6 +508,7 @@ static void exit_mm(void)
 {
 	struct mm_struct *mm = current->mm;
 	struct core_state *core_state;
+	mm_range_define(range);
 
 	mm_release(current, mm);
 	if (!mm)
@@ -520,12 +521,12 @@ static void exit_mm(void)
 	 * will increment ->nr_threads for each thread in the
 	 * group with ->mm != NULL.
 	 */
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	core_state = mm->core_state;
 	if (core_state) {
 		struct core_thread self;
 
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &range);
 
 		self.task = current;
 		self.next = xchg(&core_state->dumper.next, &self);
@@ -543,14 +544,14 @@ static void exit_mm(void)
 			freezable_schedule();
 		}
 		__set_current_state(TASK_RUNNING);
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &range);
 	}
 	mmgrab(mm);
 	BUG_ON(mm != current->active_mm);
 	/* more a memory barrier than a real lock */
 	task_lock(current);
 	current->mm = NULL;
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 	enter_lazy_tlb(mm, current);
 	task_unlock(current);
 	mm_update_next_owner(mm);
diff --git a/kernel/fork.c b/kernel/fork.c
index aa1076c5e4a9..d9696585d125 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -597,9 +597,11 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 	int retval;
 	unsigned long charge;
 	LIST_HEAD(uf);
+	mm_range_define(range);
+	mm_range_define(oldrange);
 
 	uprobe_start_dup_mmap();
-	if (down_write_killable(&oldmm->mmap_sem)) {
+	if (mm_write_lock_killable(oldmm, &oldrange)) {
 		retval = -EINTR;
 		goto fail_uprobe_end;
 	}
@@ -608,7 +610,7 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 	/*
 	 * Not linked in yet - no deadlock potential:
 	 */
-	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
+	mm_write_lock(mm, &range);
 
 	/* No ordering required: file already has been exposed. */
 	RCU_INIT_POINTER(mm->exe_file, get_mm_exe_file(oldmm));
@@ -712,9 +714,9 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 	arch_dup_mmap(oldmm, mm);
 	retval = 0;
 out:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	flush_tlb_mm(oldmm);
-	up_write(&oldmm->mmap_sem);
+	mm_write_unlock(oldmm, &oldrange);
 	dup_userfaultfd_complete(&uf);
 fail_uprobe_end:
 	uprobe_end_dup_mmap();
@@ -744,9 +746,11 @@ static inline void mm_free_pgd(struct mm_struct *mm)
 #else
 static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 {
-	down_write(&oldmm->mmap_sem);
+	mm_range_define(oldrange);
+
+	mm_write_lock(oldmm, &oldrange);
 	RCU_INIT_POINTER(mm->exe_file, get_mm_exe_file(oldmm));
-	up_write(&oldmm->mmap_sem);
+	mm_write_unlock(oldmm, &oldrange);
 	return 0;
 }
 #define mm_alloc_pgd(mm)	(0)
@@ -795,7 +799,11 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 	mm->vmacache_seqnum = 0;
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
+#ifdef CONFIG_MEM_RANGE_LOCK
+	range_lock_tree_init(&mm->mmap_sem);
+#else
 	init_rwsem(&mm->mmap_sem);
+#endif
 	INIT_LIST_HEAD(&mm->mmlist);
 	mm->core_state = NULL;
 	atomic_long_set(&mm->nr_ptes, 0);
diff --git a/kernel/futex.c b/kernel/futex.c
index 531a497eefbd..27d88340d3e4 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -724,11 +724,12 @@ static int fault_in_user_writeable(u32 __user *uaddr)
 {
 	struct mm_struct *mm = current->mm;
 	int ret;
+	mm_range_define(range);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	ret = fixup_user_fault(current, mm, (unsigned long)uaddr,
-			       FAULT_FLAG_WRITE, NULL, NULL);
-	up_read(&mm->mmap_sem);
+			       FAULT_FLAG_WRITE, NULL, &range);
+	mm_read_unlock(mm, &range);
 
 	return ret < 0 ? ret : 0;
 }
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index d71109321841..e2481d73635c 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -2419,6 +2419,7 @@ void task_numa_work(struct callback_head *work)
 	unsigned long start, end;
 	unsigned long nr_pte_updates = 0;
 	long pages, virtpages;
+	mm_range_define(range);
 
 	SCHED_WARN_ON(p != container_of(work, struct task_struct, numa_work));
 
@@ -2468,8 +2469,7 @@ void task_numa_work(struct callback_head *work)
 	if (!pages)
 		return;
 
-
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	vma = find_vma(mm, start);
 	if (!vma) {
 		reset_ptenuma_scan(p);
@@ -2536,7 +2536,7 @@ void task_numa_work(struct callback_head *work)
 		mm->numa_scan_offset = start;
 	else
 		reset_ptenuma_scan(p);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 
 	/*
 	 * Make sure tasks use at least 32x as much time to run other code
diff --git a/kernel/sys.c b/kernel/sys.c
index 8a94b4eabcaa..da53c7bc50c1 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1668,6 +1668,7 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 	struct file *old_exe, *exe_file;
 	struct inode *inode;
 	int err;
+	mm_range_define(range);
 
 	exe = fdget(fd);
 	if (!exe.file)
@@ -1696,7 +1697,7 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 	if (exe_file) {
 		struct vm_area_struct *vma;
 
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &range);
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
 			if (!vma->vm_file)
 				continue;
@@ -1705,7 +1706,7 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 				goto exit_err;
 		}
 
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &range);
 		fput(exe_file);
 	}
 
@@ -1719,7 +1720,7 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 	fdput(exe);
 	return err;
 exit_err:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 	fput(exe_file);
 	goto exit;
 }
@@ -1826,6 +1827,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 	unsigned long user_auxv[AT_VECTOR_SIZE];
 	struct mm_struct *mm = current->mm;
 	int error;
+	mm_range_define(range);
 
 	BUILD_BUG_ON(sizeof(user_auxv) != sizeof(mm->saved_auxv));
 	BUILD_BUG_ON(sizeof(struct prctl_mm_map) > 256);
@@ -1862,7 +1864,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 			return error;
 	}
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &range);
 
 	/*
 	 * We don't validate if these members are pointing to
@@ -1899,7 +1901,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 	if (prctl_map.auxv_size)
 		memcpy(mm->saved_auxv, user_auxv, sizeof(user_auxv));
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	return 0;
 }
 #endif /* CONFIG_CHECKPOINT_RESTORE */
@@ -1941,6 +1943,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
 	struct prctl_mm_map prctl_map;
 	struct vm_area_struct *vma;
 	int error;
+	mm_range_define(range);
 
 	if (arg5 || (arg4 && (opt != PR_SET_MM_AUXV &&
 			      opt != PR_SET_MM_MAP &&
@@ -1966,7 +1969,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
 
 	error = -EINVAL;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &range);
 	vma = find_vma(mm, addr);
 
 	prctl_map.start_code	= mm->start_code;
@@ -2059,7 +2062,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
 
 	error = 0;
 out:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	return error;
 }
 
@@ -2099,6 +2102,7 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 	struct task_struct *me = current;
 	unsigned char comm[sizeof(me->comm)];
 	long error;
+	mm_range_define(range);
 
 	error = security_task_prctl(option, arg2, arg3, arg4, arg5);
 	if (error != -ENOSYS)
@@ -2271,13 +2275,13 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 	case PR_SET_THP_DISABLE:
 		if (arg3 || arg4 || arg5)
 			return -EINVAL;
-		if (down_write_killable(&me->mm->mmap_sem))
+		if (mm_write_lock_killable(me->mm, &range))
 			return -EINTR;
 		if (arg2)
 			me->mm->def_flags |= VM_NOHUGEPAGE;
 		else
 			me->mm->def_flags &= ~VM_NOHUGEPAGE;
-		up_write(&me->mm->mmap_sem);
+		mm_write_unlock(me->mm, &range);
 		break;
 	case PR_MPX_ENABLE_MANAGEMENT:
 		if (arg2 || arg3 || arg4 || arg5)
diff --git a/kernel/trace/trace_output.c b/kernel/trace/trace_output.c
index 08f9bab8089e..a8ebb73aff25 100644
--- a/kernel/trace/trace_output.c
+++ b/kernel/trace/trace_output.c
@@ -379,6 +379,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
 	struct file *file = NULL;
 	unsigned long vmstart = 0;
 	int ret = 1;
+	mm_range_define(range);
 
 	if (s->full)
 		return 0;
@@ -386,7 +387,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
 	if (mm) {
 		const struct vm_area_struct *vma;
 
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &range);
 		vma = find_vma(mm, ip);
 		if (vma) {
 			file = vma->vm_file;
@@ -398,7 +399,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
 				trace_seq_printf(s, "[+0x%lx]",
 						 ip - vmstart);
 		}
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &range);
 	}
 	if (ret && ((sym_flags & TRACE_ITER_SYM_ADDR) || !file))
 		trace_seq_printf(s, " <" IP_FMT ">", ip);
diff --git a/mm/filemap.c b/mm/filemap.c
index adb7c15b8aa4..e593ebadaf7e 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1067,7 +1067,7 @@ int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 		if (flags & FAULT_FLAG_RETRY_NOWAIT)
 			return 0;
 
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, range);
 		if (flags & FAULT_FLAG_KILLABLE)
 			wait_on_page_locked_killable(page);
 		else
@@ -1079,7 +1079,7 @@ int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 
 			ret = __lock_page_killable(page);
 			if (ret) {
-				up_read(&mm->mmap_sem);
+				mm_read_unlock(mm, range);
 				return 0;
 			}
 		} else
diff --git a/mm/frame_vector.c b/mm/frame_vector.c
index d2c1675ff466..e93dd7675510 100644
--- a/mm/frame_vector.c
+++ b/mm/frame_vector.c
@@ -38,6 +38,7 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 	int ret = 0;
 	int err;
 	int locked;
+	mm_range_define(range);
 
 	if (nr_frames == 0)
 		return 0;
@@ -45,7 +46,7 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 	if (WARN_ON_ONCE(nr_frames > vec->nr_allocated))
 		nr_frames = vec->nr_allocated;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	locked = 1;
 	vma = find_vma_intersection(mm, start, start + 1);
 	if (!vma) {
@@ -56,7 +57,8 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 		vec->got_ref = true;
 		vec->is_pfns = false;
 		ret = get_user_pages_locked(start, nr_frames,
-			gup_flags, (struct page **)(vec->ptrs), &locked, NULL);
+			gup_flags, (struct page **)(vec->ptrs),
+			&locked, &range);
 		goto out;
 	}
 
@@ -85,7 +87,7 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 	} while (vma && vma->vm_flags & (VM_IO | VM_PFNMAP));
 out:
 	if (locked)
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &range);
 	if (!ret)
 		ret = -EFAULT;
 	if (ret > 0)
diff --git a/mm/gup.c b/mm/gup.c
index 3a8ba8cfae3f..d308173af11b 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -750,7 +750,7 @@ int _fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	}
 
 	if (ret & VM_FAULT_RETRY) {
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, range);
 		if (!(fault_flags & FAULT_FLAG_TRIED)) {
 			*unlocked = true;
 			fault_flags &= ~FAULT_FLAG_ALLOW_RETRY;
@@ -840,7 +840,7 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 		 */
 		*locked = 1;
 		lock_dropped = true;
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, range);
 		ret = __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
 				       pages, NULL, NULL
 #ifdef CONFIG_MEM_RANGE_LOCK
@@ -865,7 +865,7 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 		 * We must let the caller know we temporarily dropped the lock
 		 * and so the critical section protected by it was lost.
 		 */
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, range);
 		*locked = 0;
 	}
 	return pages_done;
@@ -920,8 +920,9 @@ static __always_inline long __get_user_pages_unlocked(struct task_struct *tsk,
 {
 	long ret;
 	int locked = 1;
+	mm_range_define(range);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	ret = __get_user_pages_locked(tsk, mm, start, nr_pages, pages, NULL,
 				      &locked, false,
 #ifdef CONFIG_MEM_RANGE_LOCK
@@ -929,7 +930,7 @@ static __always_inline long __get_user_pages_unlocked(struct task_struct *tsk,
 #endif
 				      gup_flags);
 	if (locked)
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &range);
 	return ret;
 }
 
@@ -1137,6 +1138,7 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 	struct vm_area_struct *vma = NULL;
 	int locked = 0;
 	long ret = 0;
+	mm_range_define(range);
 
 	VM_BUG_ON(start & ~PAGE_MASK);
 	VM_BUG_ON(len != PAGE_ALIGN(len));
@@ -1149,7 +1151,7 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 		 */
 		if (!locked) {
 			locked = 1;
-			down_read(&mm->mmap_sem);
+			mm_read_lock(mm, &range);
 			vma = find_vma(mm, nstart);
 		} else if (nstart >= vma->vm_end)
 			vma = vma->vm_next;
@@ -1170,7 +1172,7 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 		 * if the vma was already munlocked.
 		 */
 		ret = populate_vma_page_range(vma, nstart, nend, &locked,
-					      NULL);
+					      &range);
 		if (ret < 0) {
 			if (ignore_errors) {
 				ret = 0;
@@ -1182,7 +1184,7 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 		ret = 0;
 	}
 	if (locked)
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &range);
 	return ret;	/* 0 or negative error code */
 }
 
diff --git a/mm/init-mm.c b/mm/init-mm.c
index 975e49f00f34..9e8c84a0ee24 100644
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -19,7 +19,11 @@ struct mm_struct init_mm = {
 	.pgd		= swapper_pg_dir,
 	.mm_users	= ATOMIC_INIT(2),
 	.mm_count	= ATOMIC_INIT(1),
+#ifdef CONFIG_MEM_RANGE_LOCK
+	.mmap_sem	= __RANGE_LOCK_TREE_INITIALIZER(init_mm.mmap_sem),
+#else
 	.mmap_sem	= __RWSEM_INITIALIZER(init_mm.mmap_sem),
+#endif
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
 	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
 	.user_ns	= &init_user_ns,
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 6357f32608a5..f668f73fa19e 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -453,6 +453,7 @@ void __khugepaged_exit(struct mm_struct *mm)
 {
 	struct mm_slot *mm_slot;
 	int free = 0;
+	mm_range_define(range);
 
 	spin_lock(&khugepaged_mm_lock);
 	mm_slot = get_mm_slot(mm);
@@ -476,8 +477,8 @@ void __khugepaged_exit(struct mm_struct *mm)
 		 * khugepaged has finished working on the pagetables
 		 * under the mmap_sem.
 		 */
-		down_write(&mm->mmap_sem);
-		up_write(&mm->mmap_sem);
+		mm_write_lock(mm, &range);
+		mm_write_unlock(mm, &range);
 	}
 }
 
@@ -906,7 +907,7 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 
 		/* do_swap_page returns VM_FAULT_RETRY with released mmap_sem */
 		if (ret & VM_FAULT_RETRY) {
-			down_read(&mm->mmap_sem);
+			mm_read_lock(mm, range);
 			if (hugepage_vma_revalidate(mm, address, &vmf.vma)) {
 				/* vma is no longer available, don't continue to swapin */
 				trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
@@ -963,7 +964,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * sync compaction, and we do not need to hold the mmap_sem during
 	 * that. We will recheck the vma after taking it again in write mode.
 	 */
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, range);
 	new_page = khugepaged_alloc_page(hpage, gfp, node);
 	if (!new_page) {
 		result = SCAN_ALLOC_HUGE_PAGE_FAIL;
@@ -975,11 +976,11 @@ static void collapse_huge_page(struct mm_struct *mm,
 		goto out_nolock;
 	}
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, range);
 	result = hugepage_vma_revalidate(mm, address, &vma);
 	if (result) {
 		mem_cgroup_cancel_charge(new_page, memcg, true);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, range);
 		goto out_nolock;
 	}
 
@@ -987,7 +988,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	if (!pmd) {
 		result = SCAN_PMD_NULL;
 		mem_cgroup_cancel_charge(new_page, memcg, true);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, range);
 		goto out_nolock;
 	}
 
@@ -1002,17 +1003,17 @@ static void collapse_huge_page(struct mm_struct *mm,
 #endif
 		    )) {
 		mem_cgroup_cancel_charge(new_page, memcg, true);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, range);
 		goto out_nolock;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, range);
 	/*
 	 * Prevent all access to pagetables with the exception of
 	 * gup_fast later handled by the ptep_clear_flush and the VM
 	 * handled by the anon_vma lock + PG_lock.
 	 */
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, range);
 	result = hugepage_vma_revalidate(mm, address, &vma);
 	if (result)
 		goto out;
@@ -1095,7 +1096,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	khugepaged_pages_collapsed++;
 	result = SCAN_SUCCEED;
 out_up_write:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, range);
 out_nolock:
 	trace_mm_collapse_huge_page(mm, isolated, result);
 	return;
@@ -1266,6 +1267,7 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 	struct vm_area_struct *vma;
 	unsigned long addr;
 	pmd_t *pmd, _pmd;
+	mm_range_define(range);
 
 	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
@@ -1286,12 +1288,12 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 		 * re-fault. Not ideal, but it's more important to not disturb
 		 * the system too much.
 		 */
-		if (down_write_trylock(&vma->vm_mm->mmap_sem)) {
+		if (mm_write_trylock(vma->vm_mm, &range)) {
 			spinlock_t *ptl = pmd_lock(vma->vm_mm, pmd);
 			/* assume page table is clear */
 			_pmd = pmdp_collapse_flush(vma, addr, pmd);
 			spin_unlock(ptl);
-			up_write(&vma->vm_mm->mmap_sem);
+			mm_write_unlock(vma->vm_mm, &range);
 			atomic_long_dec(&vma->vm_mm->nr_ptes);
 			pte_free(vma->vm_mm, pmd_pgtable(_pmd));
 		}
@@ -1681,6 +1683,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	int progress = 0;
+	mm_range_define(range);
 
 	VM_BUG_ON(!pages);
 	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&khugepaged_mm_lock));
@@ -1696,7 +1699,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 	spin_unlock(&khugepaged_mm_lock);
 
 	mm = mm_slot->mm;
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	if (unlikely(khugepaged_test_exit(mm)))
 		vma = NULL;
 	else
@@ -1742,7 +1745,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 				if (!shmem_huge_enabled(vma))
 					goto skip;
 				file = get_file(vma->vm_file);
-				up_read(&mm->mmap_sem);
+				mm_read_unlock(mm, &range);
 				ret = 1;
 				khugepaged_scan_shmem(mm, file->f_mapping,
 						pgoff, hpage);
@@ -1767,7 +1770,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 		}
 	}
 breakouterloop:
-	up_read(&mm->mmap_sem); /* exit_mmap will destroy ptes after this */
+	mm_read_unlock(mm, &range); /* exit_mmap will destroy ptes after this */
 breakouterloop_mmap_sem:
 
 	spin_lock(&khugepaged_mm_lock);
diff --git a/mm/ksm.c b/mm/ksm.c
index 36a0a12e336d..44a465f99388 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -447,6 +447,7 @@ static void break_cow(struct rmap_item *rmap_item)
 	struct mm_struct *mm = rmap_item->mm;
 	unsigned long addr = rmap_item->address;
 	struct vm_area_struct *vma;
+	mm_range_define(range);
 
 	/*
 	 * It is not an accident that whenever we want to break COW
@@ -454,11 +455,11 @@ static void break_cow(struct rmap_item *rmap_item)
 	 */
 	put_anon_vma(rmap_item->anon_vma);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	vma = find_mergeable_vma(mm, addr);
 	if (vma)
 		break_ksm(vma, addr);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 }
 
 static struct page *get_mergeable_page(struct rmap_item *rmap_item)
@@ -467,8 +468,9 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 	unsigned long addr = rmap_item->address;
 	struct vm_area_struct *vma;
 	struct page *page;
+	mm_range_define(range);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	vma = find_mergeable_vma(mm, addr);
 	if (!vma)
 		goto out;
@@ -484,7 +486,7 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 out:
 		page = NULL;
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 	return page;
 }
 
@@ -775,6 +777,7 @@ static int unmerge_and_remove_all_rmap_items(void)
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	int err = 0;
+	mm_range_define(range);
 
 	spin_lock(&ksm_mmlist_lock);
 	ksm_scan.mm_slot = list_entry(ksm_mm_head.mm_list.next,
@@ -784,7 +787,7 @@ static int unmerge_and_remove_all_rmap_items(void)
 	for (mm_slot = ksm_scan.mm_slot;
 			mm_slot != &ksm_mm_head; mm_slot = ksm_scan.mm_slot) {
 		mm = mm_slot->mm;
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &range);
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
 			if (ksm_test_exit(mm))
 				break;
@@ -797,7 +800,7 @@ static int unmerge_and_remove_all_rmap_items(void)
 		}
 
 		remove_trailing_rmap_items(mm_slot, &mm_slot->rmap_list);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &range);
 
 		spin_lock(&ksm_mmlist_lock);
 		ksm_scan.mm_slot = list_entry(mm_slot->mm_list.next,
@@ -820,7 +823,7 @@ static int unmerge_and_remove_all_rmap_items(void)
 	return 0;
 
 error:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 	spin_lock(&ksm_mmlist_lock);
 	ksm_scan.mm_slot = &ksm_mm_head;
 	spin_unlock(&ksm_mmlist_lock);
@@ -1088,8 +1091,9 @@ static int try_to_merge_with_ksm_page(struct rmap_item *rmap_item,
 	struct mm_struct *mm = rmap_item->mm;
 	struct vm_area_struct *vma;
 	int err = -EFAULT;
+	mm_range_define(range);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	vma = find_mergeable_vma(mm, rmap_item->address);
 	if (!vma)
 		goto out;
@@ -1105,7 +1109,7 @@ static int try_to_merge_with_ksm_page(struct rmap_item *rmap_item,
 	rmap_item->anon_vma = vma->anon_vma;
 	get_anon_vma(vma->anon_vma);
 out:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 	return err;
 }
 
@@ -1579,6 +1583,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 	struct vm_area_struct *vma;
 	struct rmap_item *rmap_item;
 	int nid;
+	mm_range_define(range);
 
 	if (list_empty(&ksm_mm_head.mm_list))
 		return NULL;
@@ -1635,7 +1640,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 	}
 
 	mm = slot->mm;
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	if (ksm_test_exit(mm))
 		vma = NULL;
 	else
@@ -1669,7 +1674,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 					ksm_scan.address += PAGE_SIZE;
 				} else
 					put_page(*page);
-				up_read(&mm->mmap_sem);
+				mm_read_unlock(mm, &range);
 				return rmap_item;
 			}
 			put_page(*page);
@@ -1707,10 +1712,10 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 
 		free_mm_slot(slot);
 		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &range);
 		mmdrop(mm);
 	} else {
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &range);
 		/*
 		 * up_read(&mm->mmap_sem) first because after
 		 * spin_unlock(&ksm_mmlist_lock) run, the "mm" may
@@ -1869,6 +1874,7 @@ void __ksm_exit(struct mm_struct *mm)
 {
 	struct mm_slot *mm_slot;
 	int easy_to_free = 0;
+	mm_range_define(range);
 
 	/*
 	 * This process is exiting: if it's straightforward (as is the
@@ -1898,8 +1904,8 @@ void __ksm_exit(struct mm_struct *mm)
 		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
 		mmdrop(mm);
 	} else if (mm_slot) {
-		down_write(&mm->mmap_sem);
-		up_write(&mm->mmap_sem);
+		mm_write_lock(mm, &range);
+		mm_write_unlock(mm, &range);
 	}
 }
 
diff --git a/mm/madvise.c b/mm/madvise.c
index 437f35778f07..bfd048564956 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -519,7 +519,7 @@ static long madvise_dontneed(struct vm_area_struct *vma,
 	if (!userfaultfd_remove(vma, start, end, range)) {
 		*prev = NULL; /* mmap_sem has been dropped, prev is stale */
 
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, range);
 		vma = find_vma(current->mm, start);
 		if (!vma)
 			return -ENOMEM;
@@ -597,15 +597,15 @@ static long madvise_remove(struct vm_area_struct *vma,
 	 * mmap_sem.
 	 */
 	get_file(f);
-	if (userfaultfd_remove(vma, start, end, NULL)) {
+	if (userfaultfd_remove(vma, start, end, range)) {
 		/* mmap_sem was not released by userfaultfd_remove() */
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, range);
 	}
 	error = vfs_fallocate(f,
 				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
 				offset, end - start);
 	fput(f);
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, range);
 	return error;
 }
 
@@ -783,6 +783,7 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 	int write;
 	size_t len;
 	struct blk_plug plug;
+	mm_range_define(range);
 
 	if (!madvise_behavior_valid(behavior))
 		return error;
@@ -810,10 +811,10 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 
 	write = madvise_need_mmap_write(behavior);
 	if (write) {
-		if (down_write_killable(&current->mm->mmap_sem))
+		if (mm_write_lock_killable(current->mm, &range))
 			return -EINTR;
 	} else {
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &range);
 	}
 
 	/*
@@ -867,9 +868,9 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 out:
 	blk_finish_plug(&plug);
 	if (write)
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm, &range);
 	else
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &range);
 
 	return error;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 94172089f52f..ca22fa420ba6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4681,15 +4681,16 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
 static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 {
 	unsigned long precharge;
-
 	struct mm_walk mem_cgroup_count_precharge_walk = {
 		.pmd_entry = mem_cgroup_count_precharge_pte_range,
 		.mm = mm,
 	};
-	down_read(&mm->mmap_sem);
+	mm_range_define(range);
+
+	mm_read_lock(mm, &range);
 	walk_page_range(0, mm->highest_vm_end,
 			&mem_cgroup_count_precharge_walk);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 
 	precharge = mc.precharge;
 	mc.precharge = 0;
@@ -4950,6 +4951,7 @@ static void mem_cgroup_move_charge(void)
 		.pmd_entry = mem_cgroup_move_charge_pte_range,
 		.mm = mc.mm,
 	};
+	mm_range_define(range);
 
 	lru_add_drain_all();
 	/*
@@ -4960,7 +4962,7 @@ static void mem_cgroup_move_charge(void)
 	atomic_inc(&mc.from->moving_account);
 	synchronize_rcu();
 retry:
-	if (unlikely(!down_read_trylock(&mc.mm->mmap_sem))) {
+	if (unlikely(!mm_read_trylock(mc.mm, &range))) {
 		/*
 		 * Someone who are holding the mmap_sem might be waiting in
 		 * waitq. So we cancel all extra charges, wake up all waiters,
@@ -4978,7 +4980,7 @@ static void mem_cgroup_move_charge(void)
 	 */
 	walk_page_range(0, mc.mm->highest_vm_end, &mem_cgroup_move_charge_walk);
 
-	up_read(&mc.mm->mmap_sem);
+	mm_read_unlock(mc.mm, &range);
 	atomic_dec(&mc.from->moving_account);
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index f98ecbe35e8f..a27ee1c8f07e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1637,12 +1637,14 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
 int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 			struct page *page)
 {
+	mm_range_define(range);
+
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return -EFAULT;
 	if (!page_count(page))
 		return -EINVAL;
 	if (!(vma->vm_flags & VM_MIXEDMAP)) {
-		BUG_ON(down_read_trylock(&vma->vm_mm->mmap_sem));
+		BUG_ON(mm_read_trylock(vma->vm_mm, &range));
 		BUG_ON(vma->vm_flags & VM_PFNMAP);
 		vma->vm_flags |= VM_MIXEDMAP;
 	}
@@ -4181,8 +4183,9 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 	struct vm_area_struct *vma;
 	void *old_buf = buf;
 	int write = gup_flags & FOLL_WRITE;
+	mm_range_define(range);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	/* ignore errors, just check how much was successfully transferred */
 	while (len) {
 		int bytes, ret, offset;
@@ -4190,7 +4193,8 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		struct page *page = NULL;
 
 		ret = get_user_pages_remote(tsk, mm, addr, 1,
-					    gup_flags, &page, &vma, NULL, NULL);
+					    gup_flags, &page, &vma, NULL,
+					    NULL /* mm range lock untouched */);
 		if (ret <= 0) {
 #ifndef CONFIG_HAVE_IOREMAP_PROT
 			break;
@@ -4231,7 +4235,7 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		buf += bytes;
 		addr += bytes;
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 
 	return buf - old_buf;
 }
@@ -4282,6 +4286,7 @@ void print_vma_addr(char *prefix, unsigned long ip)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
+	mm_range_define(range);
 
 	/*
 	 * Do not print if we are in atomic
@@ -4290,7 +4295,7 @@ void print_vma_addr(char *prefix, unsigned long ip)
 	if (preempt_count())
 		return;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	vma = find_vma(mm, ip);
 	if (vma && vma->vm_file) {
 		struct file *f = vma->vm_file;
@@ -4307,7 +4312,7 @@ void print_vma_addr(char *prefix, unsigned long ip)
 			free_page((unsigned long)buf);
 		}
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 }
 
 #if defined(CONFIG_PROVE_LOCKING) || defined(CONFIG_DEBUG_ATOMIC_SLEEP)
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 0658c7240e54..68f1ed522fea 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -445,11 +445,12 @@ void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new,
 void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
 {
 	struct vm_area_struct *vma;
+	mm_range_define(range);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &range);
 	for (vma = mm->mmap; vma; vma = vma->vm_next)
 		mpol_rebind_policy(vma->vm_policy, new, MPOL_REBIND_ONCE);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 }
 
 static const struct mempolicy_operations mpol_ops[MPOL_MAX] = {
@@ -871,6 +872,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma = NULL;
 	struct mempolicy *pol = current->mempolicy;
+	mm_range_define(range);
 
 	if (flags &
 		~(unsigned long)(MPOL_F_NODE|MPOL_F_ADDR|MPOL_F_MEMS_ALLOWED))
@@ -892,10 +894,10 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 		 * vma/shared policy at addr is NULL.  We
 		 * want to return MPOL_DEFAULT in this case.
 		 */
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &range);
 		vma = find_vma_intersection(mm, addr, addr+1);
 		if (!vma) {
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm, &range);
 			return -EFAULT;
 		}
 		if (vma->vm_ops && vma->vm_ops->get_policy)
@@ -932,7 +934,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 	}
 
 	if (vma) {
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &range);
 		vma = NULL;
 	}
 
@@ -950,7 +952,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
  out:
 	mpol_cond_put(pol);
 	if (vma)
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &range);
 	return err;
 }
 
@@ -1028,12 +1030,13 @@ int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
 	int busy = 0;
 	int err;
 	nodemask_t tmp;
+	mm_range_define(range);
 
 	err = migrate_prep();
 	if (err)
 		return err;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 
 	/*
 	 * Find a 'source' bit set in 'tmp' whose corresponding 'dest'
@@ -1114,7 +1117,7 @@ int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
 		if (err < 0)
 			break;
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 	if (err < 0)
 		return err;
 	return busy;
@@ -1178,6 +1181,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 	unsigned long end;
 	int err;
 	LIST_HEAD(pagelist);
+	mm_range_define(range);
 
 	if (flags & ~(unsigned long)MPOL_MF_VALID)
 		return -EINVAL;
@@ -1225,12 +1229,12 @@ static long do_mbind(unsigned long start, unsigned long len,
 	{
 		NODEMASK_SCRATCH(scratch);
 		if (scratch) {
-			down_write(&mm->mmap_sem);
+			mm_write_lock(mm, &range);
 			task_lock(current);
 			err = mpol_set_nodemask(new, nmask, scratch);
 			task_unlock(current);
 			if (err)
-				up_write(&mm->mmap_sem);
+				mm_write_unlock(mm, &range);
 		} else
 			err = -ENOMEM;
 		NODEMASK_SCRATCH_FREE(scratch);
@@ -1259,7 +1263,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 	} else
 		putback_movable_pages(&pagelist);
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
  mpol_out:
 	mpol_put(new);
 	return err;
diff --git a/mm/migrate.c b/mm/migrate.c
index 89a0a1707f4c..3726547a2dc9 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1405,8 +1405,9 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 	int err;
 	struct page_to_node *pp;
 	LIST_HEAD(pagelist);
+	mm_range_define(range);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 
 	/*
 	 * Build a list of pages to migrate
@@ -1477,7 +1478,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 			putback_movable_pages(&pagelist);
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 	return err;
 }
 
@@ -1575,8 +1576,9 @@ static void do_pages_stat_array(struct mm_struct *mm, unsigned long nr_pages,
 				const void __user **pages, int *status)
 {
 	unsigned long i;
+	mm_range_define(range);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 
 	for (i = 0; i < nr_pages; i++) {
 		unsigned long addr = (unsigned long)(*pages);
@@ -1603,7 +1605,7 @@ static void do_pages_stat_array(struct mm_struct *mm, unsigned long nr_pages,
 		status++;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 }
 
 /*
diff --git a/mm/mincore.c b/mm/mincore.c
index c5687c45c326..7c2a580cd461 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -226,6 +226,7 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
 	long retval;
 	unsigned long pages;
 	unsigned char *tmp;
+	mm_range_define(range);
 
 	/* Check the start address: needs to be page-aligned.. */
 	if (start & ~PAGE_MASK)
@@ -252,9 +253,9 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
 		 * Do at most PAGE_SIZE entries per iteration, due to
 		 * the temporary buffer size.
 		 */
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &range);
 		retval = do_mincore(start, min(pages, PAGE_SIZE), tmp);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &range);
 
 		if (retval <= 0)
 			break;
diff --git a/mm/mlock.c b/mm/mlock.c
index c483c5c20b4b..9b74ecd70ce0 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -666,6 +666,7 @@ static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t fla
 	unsigned long locked;
 	unsigned long lock_limit;
 	int error = -ENOMEM;
+	mm_range_define(range);
 
 	if (!can_do_mlock())
 		return -EPERM;
@@ -679,7 +680,7 @@ static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t fla
 	lock_limit >>= PAGE_SHIFT;
 	locked = len >> PAGE_SHIFT;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	if (mm_write_lock_killable(current->mm, &range))
 		return -EINTR;
 
 	locked += current->mm->locked_vm;
@@ -698,7 +699,7 @@ static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t fla
 	if ((locked <= lock_limit) || capable(CAP_IPC_LOCK))
 		error = apply_vma_lock_flags(start, len, flags);
 
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &range);
 	if (error)
 		return error;
 
@@ -729,14 +730,15 @@ SYSCALL_DEFINE3(mlock2, unsigned long, start, size_t, len, int, flags)
 SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
 {
 	int ret;
+	mm_range_define(range);
 
 	len = PAGE_ALIGN(len + (offset_in_page(start)));
 	start &= PAGE_MASK;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	if (mm_write_lock_killable(current->mm, &range))
 		return -EINTR;
 	ret = apply_vma_lock_flags(start, len, 0);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &range);
 
 	return ret;
 }
@@ -791,6 +793,7 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 {
 	unsigned long lock_limit;
 	int ret;
+	mm_range_define(range);
 
 	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE | MCL_ONFAULT)))
 		return -EINVAL;
@@ -804,14 +807,14 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	lock_limit = rlimit(RLIMIT_MEMLOCK);
 	lock_limit >>= PAGE_SHIFT;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	if (mm_write_lock_killable(current->mm, &range))
 		return -EINTR;
 
 	ret = -ENOMEM;
 	if (!(flags & MCL_CURRENT) || (current->mm->total_vm <= lock_limit) ||
 	    capable(CAP_IPC_LOCK))
 		ret = apply_mlockall_flags(flags);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &range);
 	if (!ret && (flags & MCL_CURRENT))
 		mm_populate(0, TASK_SIZE);
 
@@ -821,11 +824,12 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 SYSCALL_DEFINE0(munlockall)
 {
 	int ret;
+	mm_range_define(range);
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	if (mm_write_lock_killable(current->mm, &range))
 		return -EINTR;
 	ret = apply_mlockall_flags(0);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &range);
 	return ret;
 }
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 1796b9ae540d..e3b84b78917d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -186,8 +186,9 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 	unsigned long min_brk;
 	bool populate;
 	LIST_HEAD(uf);
+	mm_range_define(range);
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &range))
 		return -EINTR;
 
 #ifdef CONFIG_COMPAT_BRK
@@ -239,7 +240,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 set_brk:
 	mm->brk = brk;
 	populate = newbrk > oldbrk && (mm->def_flags & VM_LOCKED) != 0;
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	userfaultfd_unmap_complete(mm, &uf);
 	if (populate)
 		mm_populate(oldbrk, newbrk - oldbrk);
@@ -247,7 +248,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 
 out:
 	retval = mm->brk;
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	return retval;
 }
 
@@ -2681,12 +2682,13 @@ int vm_munmap(unsigned long start, size_t len)
 	int ret;
 	struct mm_struct *mm = current->mm;
 	LIST_HEAD(uf);
+	mm_range_define(range);
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &range))
 		return -EINTR;
 
 	ret = do_munmap(mm, start, len, &uf);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	userfaultfd_unmap_complete(mm, &uf);
 	return ret;
 }
@@ -2711,6 +2713,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	unsigned long populate = 0;
 	unsigned long ret = -EINVAL;
 	struct file *file;
+	mm_range_define(range);
 
 	pr_warn_once("%s (%d) uses deprecated remap_file_pages() syscall. See Documentation/vm/remap_file_pages.txt.\n",
 		     current->comm, current->pid);
@@ -2727,7 +2730,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	if (pgoff + (size >> PAGE_SHIFT) < pgoff)
 		return ret;
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &range))
 		return -EINTR;
 
 	vma = find_vma(mm, start);
@@ -2790,7 +2793,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 			prot, flags, pgoff, &populate, NULL);
 	fput(file);
 out:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	if (populate)
 		mm_populate(ret, populate);
 	if (!IS_ERR_VALUE(ret))
@@ -2801,9 +2804,11 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 static inline void verify_mm_writelocked(struct mm_struct *mm)
 {
 #ifdef CONFIG_DEBUG_VM
-	if (unlikely(down_read_trylock(&mm->mmap_sem))) {
+	mm_range_define(range);
+
+	if (unlikely(mm_read_lock_trylock(mm, &range))) {
 		WARN_ON(1);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &range);
 	}
 #endif
 }
@@ -2910,13 +2915,14 @@ int vm_brk_flags(unsigned long addr, unsigned long len, unsigned long flags)
 	int ret;
 	bool populate;
 	LIST_HEAD(uf);
+	mm_range_define(range);
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &range))
 		return -EINTR;
 
 	ret = do_brk_flags(addr, len, flags, &uf);
 	populate = ((mm->def_flags & VM_LOCKED) != 0);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	userfaultfd_unmap_complete(mm, &uf);
 	if (populate && !ret)
 		mm_populate(addr, len);
@@ -3367,8 +3373,9 @@ int mm_take_all_locks(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
 	struct anon_vma_chain *avc;
+	mm_range_define(range);
 
-	BUG_ON(down_read_trylock(&mm->mmap_sem));
+	BUG_ON(mm_read_trylock(mm, &range));
 
 	mutex_lock(&mm_all_locks_mutex);
 
@@ -3447,8 +3454,9 @@ void mm_drop_all_locks(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
 	struct anon_vma_chain *avc;
+	mm_range_define(range);
 
-	BUG_ON(down_read_trylock(&mm->mmap_sem));
+	BUG_ON(mm_read_trylock(mm, &range));
 	BUG_ON(!mutex_is_locked(&mm_all_locks_mutex));
 
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 54ca54562928..0d2ab3418afb 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -249,6 +249,7 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 {
 	struct mmu_notifier_mm *mmu_notifier_mm;
 	int ret;
+	mm_range_define(range);
 
 	BUG_ON(atomic_read(&mm->mm_users) <= 0);
 
@@ -258,7 +259,7 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 		goto out;
 
 	if (take_mmap_sem)
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm, &range);
 	ret = mm_take_all_locks(mm);
 	if (unlikely(ret))
 		goto out_clean;
@@ -287,7 +288,7 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 	mm_drop_all_locks(mm);
 out_clean:
 	if (take_mmap_sem)
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &range);
 	kfree(mmu_notifier_mm);
 out:
 	BUG_ON(atomic_read(&mm->mm_users) <= 0);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index fef798619b06..f14aef5824a7 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -383,6 +383,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
 	const int grows = prot & (PROT_GROWSDOWN|PROT_GROWSUP);
 	const bool rier = (current->personality & READ_IMPLIES_EXEC) &&
 				(prot & PROT_READ);
+	mm_range_define(range);
 
 	prot &= ~(PROT_GROWSDOWN|PROT_GROWSUP);
 	if (grows == (PROT_GROWSDOWN|PROT_GROWSUP)) /* can't be both */
@@ -401,7 +402,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
 
 	reqprot = prot;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	if (mm_write_lock_killable(current->mm, &range))
 		return -EINTR;
 
 	/*
@@ -491,7 +492,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
 		prot = reqprot;
 	}
 out:
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &range);
 	return error;
 }
 
@@ -513,6 +514,7 @@ SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
 {
 	int pkey;
 	int ret;
+	mm_range_define(range);
 
 	/* No flags supported yet. */
 	if (flags)
@@ -521,7 +523,7 @@ SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
 	if (init_val & ~PKEY_ACCESS_MASK)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm, &range);
 	pkey = mm_pkey_alloc(current->mm);
 
 	ret = -ENOSPC;
@@ -535,17 +537,18 @@ SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
 	}
 	ret = pkey;
 out:
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &range);
 	return ret;
 }
 
 SYSCALL_DEFINE1(pkey_free, int, pkey)
 {
 	int ret;
+	mm_range_define(range);
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm, &range);
 	ret = mm_pkey_free(current->mm, pkey);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &range);
 
 	/*
 	 * We could provie warnings or errors if any VMA still
diff --git a/mm/mremap.c b/mm/mremap.c
index cd8a1b199ef9..aa9377fc6db8 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -515,6 +515,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	bool locked = false;
 	struct vm_userfaultfd_ctx uf = NULL_VM_UFFD_CTX;
 	LIST_HEAD(uf_unmap);
+	mm_range_define(range);
 
 	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
 		return ret;
@@ -536,7 +537,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	if (!new_len)
 		return ret;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	if (mm_write_lock_killable(current->mm, &range))
 		return -EINTR;
 
 	if (flags & MREMAP_FIXED) {
@@ -618,7 +619,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 		vm_unacct_memory(charged);
 		locked = 0;
 	}
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &range);
 	if (locked && new_len > old_len)
 		mm_populate(new_addr + old_len, new_len - old_len);
 	mremap_userfaultfd_complete(&uf, addr, new_addr, old_len);
diff --git a/mm/msync.c b/mm/msync.c
index 24e612fefa04..8f00ef37e625 100644
--- a/mm/msync.c
+++ b/mm/msync.c
@@ -35,6 +35,7 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 	struct vm_area_struct *vma;
 	int unmapped_error = 0;
 	int error = -EINVAL;
+	mm_range_define(range);
 
 	if (flags & ~(MS_ASYNC | MS_INVALIDATE | MS_SYNC))
 		goto out;
@@ -54,7 +55,7 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 	 * If the interval [start,end) covers some unmapped address ranges,
 	 * just ignore them, but return -ENOMEM at the end.
 	 */
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	vma = find_vma(mm, start);
 	for (;;) {
 		struct file *file;
@@ -85,12 +86,12 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 		if ((flags & MS_SYNC) && file &&
 				(vma->vm_flags & VM_SHARED)) {
 			get_file(file);
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm, &range);
 			error = vfs_fsync_range(file, fstart, fend, 1);
 			fput(file);
 			if (error || start >= end)
 				goto out;
-			down_read(&mm->mmap_sem);
+			mm_read_lock(mm, &range);
 			vma = find_vma(mm, start);
 		} else {
 			if (start >= end) {
@@ -101,7 +102,7 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 		}
 	}
 out_unlock:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 out:
 	return error ? : unmapped_error;
 }
diff --git a/mm/nommu.c b/mm/nommu.c
index fc184f597d59..cee0359a8244 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -183,10 +183,12 @@ static long __get_user_pages_unlocked(struct task_struct *tsk,
 			unsigned int gup_flags)
 {
 	long ret;
-	down_read(&mm->mmap_sem);
+	mm_range_define(range);
+
+	mm_read_lock(mm, &range);
 	ret = __get_user_pages(tsk, mm, start, nr_pages, gup_flags, pages,
 				NULL, NULL);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 	return ret;
 }
 
@@ -249,12 +251,13 @@ void *vmalloc_user(unsigned long size)
 	ret = __vmalloc(size, GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
 	if (ret) {
 		struct vm_area_struct *vma;
+		mm_range_define(range);
 
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm, &range);
 		vma = find_vma(current->mm, (unsigned long)ret);
 		if (vma)
 			vma->vm_flags |= VM_USERMAP;
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm, &range);
 	}
 
 	return ret;
@@ -1647,10 +1650,11 @@ int vm_munmap(unsigned long addr, size_t len)
 {
 	struct mm_struct *mm = current->mm;
 	int ret;
+	mm_range_define(range);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &range);
 	ret = do_munmap(mm, addr, len, NULL);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &range);
 	return ret;
 }
 EXPORT_SYMBOL(vm_munmap);
@@ -1736,10 +1740,11 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 		unsigned long, new_addr)
 {
 	unsigned long ret;
+	mm_range_define(range);
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm, &range);
 	ret = do_mremap(addr, old_len, new_len, flags, new_addr);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &range);
 	return ret;
 }
 
@@ -1819,8 +1824,9 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 {
 	struct vm_area_struct *vma;
 	int write = gup_flags & FOLL_WRITE;
+	mm_range_define(range);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 
 	/* the access must start within one of the target process's mappings */
 	vma = find_vma(mm, addr);
@@ -1842,7 +1848,7 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		len = 0;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 
 	return len;
 }
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 04c9143a8625..8aaa00aa21bd 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -471,6 +471,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
 	bool ret = true;
+	mm_range_define(range);
 
 	/*
 	 * We have to make sure to not race with the victim exit path
@@ -488,7 +489,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 */
 	mutex_lock(&oom_lock);
 
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!mm_read_trylock(mm, &range)) {
 		ret = false;
 		goto unlock_oom;
 	}
@@ -499,7 +500,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 * and delayed __mmput doesn't matter that much
 	 */
 	if (!mmget_not_zero(mm)) {
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &range);
 		goto unlock_oom;
 	}
 
@@ -536,7 +537,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 			K(get_mm_counter(mm, MM_ANONPAGES)),
 			K(get_mm_counter(mm, MM_FILEPAGES)),
 			K(get_mm_counter(mm, MM_SHMEMPAGES)));
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 
 	/*
 	 * Drop our reference but make sure the mmput slow path is called from a
diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index fb4f2b96d488..27abb4f4ea9f 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -90,6 +90,7 @@ static int process_vm_rw_single_vec(unsigned long addr,
 	unsigned long max_pages_per_loop = PVM_MAX_KMALLOC_PAGES
 		/ sizeof(struct pages *);
 	unsigned int flags = 0;
+	mm_range_define(range);
 
 	/* Work out address and page range required */
 	if (len == 0)
@@ -109,12 +110,12 @@ static int process_vm_rw_single_vec(unsigned long addr,
 		 * access remotely because task/mm might not
 		 * current/current->mm
 		 */
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &range);
 		pages = get_user_pages_remote(task, mm, pa, pages, flags,
 					      process_pages, NULL, &locked,
-					      NULL);
+					      &range);
 		if (locked)
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm, &range);
 		if (pages <= 0)
 			return -EFAULT;
 
diff --git a/mm/shmem.c b/mm/shmem.c
index e67d6ba4e98e..d7b0658c8596 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1951,7 +1951,7 @@ static int shmem_fault(struct vm_fault *vmf)
 			if ((vmf->flags & FAULT_FLAG_ALLOW_RETRY) &&
 			   !(vmf->flags & FAULT_FLAG_RETRY_NOWAIT)) {
 				/* It's polite to up mmap_sem if we can */
-				up_read(&vma->vm_mm->mmap_sem);
+				mm_read_unlock(vma->vm_mm, vmf->lockrange);
 				ret = VM_FAULT_RETRY;
 			}
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 4f6cba1b6632..18c1645df43d 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1597,15 +1597,16 @@ static int unuse_mm(struct mm_struct *mm,
 {
 	struct vm_area_struct *vma;
 	int ret = 0;
+	mm_range_define(range);
 
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!mm_read_trylock(mm, &range)) {
 		/*
 		 * Activate page so shrink_inactive_list is unlikely to unmap
 		 * its ptes while lock is dropped, so swapoff can make progress.
 		 */
 		activate_page(page);
 		unlock_page(page);
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &range);
 		lock_page(page);
 	}
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
@@ -1613,7 +1614,7 @@ static int unuse_mm(struct mm_struct *mm,
 			break;
 		cond_resched();
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 	return (ret < 0)? ret: 0;
 }
 
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index ae2babc46fa5..a8f3b2955eda 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -182,7 +182,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 	 * feature is not supported.
 	 */
 	if (zeropage) {
-		up_read(&dst_mm->mmap_sem);
+		mm_read_unlock(dst_mm, range);
 		return -EINVAL;
 	}
 
@@ -280,7 +280,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 		cond_resched();
 
 		if (unlikely(err == -EFAULT)) {
-			up_read(&dst_mm->mmap_sem);
+			mm_read_unlock(dst_mm, range);
 			BUG_ON(!page);
 
 			err = copy_huge_page_from_user(page,
@@ -290,7 +290,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 				err = -EFAULT;
 				goto out;
 			}
-			down_read(&dst_mm->mmap_sem);
+			mm_read_lock(dst_mm, range);
 
 			dst_vma = NULL;
 			goto retry;
@@ -310,7 +310,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 	}
 
 out_unlock:
-	up_read(&dst_mm->mmap_sem);
+	mm_read_unlock(dst_mm, range);
 out:
 	if (page) {
 		/*
@@ -391,6 +391,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	unsigned long src_addr, dst_addr;
 	long copied;
 	struct page *page;
+	mm_range_define(range);
 
 	/*
 	 * Sanitize the command parameters:
@@ -407,7 +408,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	copied = 0;
 	page = NULL;
 retry:
-	down_read(&dst_mm->mmap_sem);
+	mm_read_lock(dst_mm, &range);
 
 	/*
 	 * Make sure the vma is not shared, that the dst range is
@@ -520,7 +521,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 		if (unlikely(err == -EFAULT)) {
 			void *page_kaddr;
 
-			up_read(&dst_mm->mmap_sem);
+			mm_read_unlock(dst_mm, &range);
 			BUG_ON(!page);
 
 			page_kaddr = kmap(page);
@@ -549,7 +550,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	}
 
 out_unlock:
-	up_read(&dst_mm->mmap_sem);
+	mm_read_unlock(dst_mm, &range);
 out:
 	if (page)
 		put_page(page);
diff --git a/mm/util.c b/mm/util.c
index 464df3489903..8c19e81c057a 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -301,14 +301,15 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 	struct mm_struct *mm = current->mm;
 	unsigned long populate;
 	LIST_HEAD(uf);
+	mm_range_define(range);
 
 	ret = security_mmap_file(file, prot, flag);
 	if (!ret) {
-		if (down_write_killable(&mm->mmap_sem))
+		if (mm_write_lock_killable(mm, &range))
 			return -EINTR;
 		ret = do_mmap_pgoff(file, addr, len, prot, flag, pgoff,
 				    &populate, &uf);
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &range);
 		userfaultfd_unmap_complete(mm, &uf);
 		if (populate)
 			mm_populate(ret, populate);
@@ -672,17 +673,19 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
 	unsigned int len;
 	struct mm_struct *mm = get_task_mm(task);
 	unsigned long arg_start, arg_end, env_start, env_end;
+	mm_range_define(range);
+
 	if (!mm)
 		goto out;
 	if (!mm->arg_end)
 		goto out_mm;	/* Shh! No looking before we're done */
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	arg_start = mm->arg_start;
 	arg_end = mm->arg_end;
 	env_start = mm->env_start;
 	env_end = mm->env_end;
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &range);
 
 	len = arg_end - arg_start;
 
diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
index bb298a200cd3..69820a9828c1 100644
--- a/virt/kvm/async_pf.c
+++ b/virt/kvm/async_pf.c
@@ -78,6 +78,7 @@ static void async_pf_execute(struct work_struct *work)
 	unsigned long addr = apf->addr;
 	gva_t gva = apf->gva;
 	int locked = 1;
+	mm_range_define(range);
 
 	might_sleep();
 
@@ -86,11 +87,11 @@ static void async_pf_execute(struct work_struct *work)
 	 * mm and might be done in another context, so we must
 	 * access remotely.
 	 */
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &range);
 	get_user_pages_remote(NULL, mm, addr, 1, FOLL_WRITE, NULL, NULL,
-			&locked);
+			      &locked, &range);
 	if (locked)
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &range);
 
 	kvm_async_page_present_sync(vcpu, apf);
 
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 9eb9a1998060..5e2c8a3945ce 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1242,6 +1242,7 @@ unsigned long kvm_host_page_size(struct kvm *kvm, gfn_t gfn)
 {
 	struct vm_area_struct *vma;
 	unsigned long addr, size;
+	mm_range_define(range);
 
 	size = PAGE_SIZE;
 
@@ -1249,7 +1250,7 @@ unsigned long kvm_host_page_size(struct kvm *kvm, gfn_t gfn)
 	if (kvm_is_error_hva(addr))
 		return PAGE_SIZE;
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &range);
 	vma = find_vma(current->mm, addr);
 	if (!vma)
 		goto out;
@@ -1257,7 +1258,7 @@ unsigned long kvm_host_page_size(struct kvm *kvm, gfn_t gfn)
 	size = vma_kernel_pagesize(vma);
 
 out:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &range);
 
 	return size;
 }
@@ -1397,6 +1398,7 @@ static int hva_to_pfn_slow(unsigned long addr, bool *async, bool write_fault,
 {
 	struct page *page[1];
 	int npages = 0;
+	mm_range_define(range);
 
 	might_sleep();
 
@@ -1404,9 +1406,9 @@ static int hva_to_pfn_slow(unsigned long addr, bool *async, bool write_fault,
 		*writable = write_fault;
 
 	if (async) {
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &range);
 		npages = get_user_page_nowait(addr, write_fault, page);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &range);
 	} else {
 		unsigned int flags = FOLL_HWPOISON;
 
@@ -1448,7 +1450,11 @@ static bool vma_is_valid(struct vm_area_struct *vma, bool write_fault)
 
 static int hva_to_pfn_remapped(struct vm_area_struct *vma,
 			       unsigned long addr, bool *async,
-			       bool write_fault, kvm_pfn_t *p_pfn)
+			       bool write_fault, kvm_pfn_t *p_pfn
+#ifdef CONFIG_MEM_RANGE_LOCK
+			       , struct range_lock *range
+#endif
+	)
 {
 	unsigned long pfn;
 	int r;
@@ -1462,7 +1468,7 @@ static int hva_to_pfn_remapped(struct vm_area_struct *vma,
 		bool unlocked = false;
 		r = fixup_user_fault(current, current->mm, addr,
 				     (write_fault ? FAULT_FLAG_WRITE : 0),
-				     &unlocked, NULL);
+				     &unlocked, range);
 		if (unlocked)
 			return -EAGAIN;
 		if (r)
@@ -1512,6 +1518,7 @@ static kvm_pfn_t hva_to_pfn(unsigned long addr, bool atomic, bool *async,
 	struct vm_area_struct *vma;
 	kvm_pfn_t pfn = 0;
 	int npages, r;
+	mm_range_define(range);
 
 	/* we can do it either atomically or asynchronously, not both */
 	BUG_ON(atomic && async);
@@ -1526,7 +1533,7 @@ static kvm_pfn_t hva_to_pfn(unsigned long addr, bool atomic, bool *async,
 	if (npages == 1)
 		return pfn;
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &range);
 	if (npages == -EHWPOISON ||
 	      (!async && check_user_page_hwpoison(addr))) {
 		pfn = KVM_PFN_ERR_HWPOISON;
@@ -1539,7 +1546,11 @@ static kvm_pfn_t hva_to_pfn(unsigned long addr, bool atomic, bool *async,
 	if (vma == NULL)
 		pfn = KVM_PFN_ERR_FAULT;
 	else if (vma->vm_flags & (VM_IO | VM_PFNMAP)) {
-		r = hva_to_pfn_remapped(vma, addr, async, write_fault, &pfn);
+		r = hva_to_pfn_remapped(vma, addr, async, write_fault, &pfn
+#ifdef CONFIG_MEM_RANGE_LOCK
+					, &range
+#endif
+			);
 		if (r == -EAGAIN)
 			goto retry;
 		if (r < 0)
@@ -1550,7 +1561,7 @@ static kvm_pfn_t hva_to_pfn(unsigned long addr, bool atomic, bool *async,
 		pfn = KVM_PFN_ERR_FAULT;
 	}
 exit:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &range);
 	return pfn;
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
