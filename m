Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E75996B02AE
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:29:46 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id h5so18600454pgv.21
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:29:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g1-v6si6334132plk.422.2018.02.04.17.28.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:06 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 33/64] arch/powerpc: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:23 +0100
Message-Id: <20180205012754.23615-34-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

This becomes quite straightforward with the mmrange in place.
For those mmap_sem callers who don't, we add it within the same
function context.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 arch/powerpc/kernel/vdso.c                 |  7 ++++---
 arch/powerpc/kvm/book3s_64_mmu_hv.c        |  6 ++++--
 arch/powerpc/kvm/book3s_64_mmu_radix.c     |  6 ++++--
 arch/powerpc/kvm/book3s_64_vio.c           |  5 +++--
 arch/powerpc/kvm/book3s_hv.c               |  7 ++++---
 arch/powerpc/kvm/e500_mmu_host.c           |  5 +++--
 arch/powerpc/mm/copro_fault.c              |  4 ++--
 arch/powerpc/mm/mmu_context_iommu.c        |  5 +++--
 arch/powerpc/mm/subpage-prot.c             | 13 +++++++------
 arch/powerpc/oprofile/cell/spu_task_sync.c |  7 ++++---
 arch/powerpc/platforms/cell/spufs/file.c   |  6 ++++--
 arch/powerpc/platforms/powernv/npu-dma.c   |  2 +-
 12 files changed, 43 insertions(+), 30 deletions(-)

diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
index 22b01a3962f0..869632b601b8 100644
--- a/arch/powerpc/kernel/vdso.c
+++ b/arch/powerpc/kernel/vdso.c
@@ -155,6 +155,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	unsigned long vdso_pages;
 	unsigned long vdso_base;
 	int rc;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (!vdso_ready)
 		return 0;
@@ -196,7 +197,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	 * and end up putting it elsewhere.
 	 * Add enough to the size so that the result can be aligned.
 	 */
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 	vdso_base = get_unmapped_area(NULL, vdso_base,
 				      (vdso_pages << PAGE_SHIFT) +
@@ -236,11 +237,11 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 		goto fail_mmapsem;
 	}
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return 0;
 
  fail_mmapsem:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return rc;
 }
 
diff --git a/arch/powerpc/kvm/book3s_64_mmu_hv.c b/arch/powerpc/kvm/book3s_64_mmu_hv.c
index b73dbc9e797d..c05a99209fc1 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_hv.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_hv.c
@@ -583,8 +583,10 @@ int kvmppc_book3s_hv_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 	hva = gfn_to_hva_memslot(memslot, gfn);
 	npages = get_user_pages_fast(hva, 1, writing, pages);
 	if (npages < 1) {
+		DEFINE_RANGE_LOCK_FULL(mmrange);
+
 		/* Check if it's an I/O mapping */
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &mmrange);
 		vma = find_vma(current->mm, hva);
 		if (vma && vma->vm_start <= hva && hva + psize <= vma->vm_end &&
 		    (vma->vm_flags & VM_PFNMAP)) {
@@ -594,7 +596,7 @@ int kvmppc_book3s_hv_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 			is_ci = pte_ci(__pte((pgprot_val(vma->vm_page_prot))));
 			write_ok = vma->vm_flags & VM_WRITE;
 		}
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 		if (!pfn)
 			goto out_put;
 	} else {
diff --git a/arch/powerpc/kvm/book3s_64_mmu_radix.c b/arch/powerpc/kvm/book3s_64_mmu_radix.c
index 0c854816e653..9a4d1758b0db 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_radix.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_radix.c
@@ -397,8 +397,10 @@ int kvmppc_book3s_radix_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 	level = 0;
 	npages = get_user_pages_fast(hva, 1, writing, pages);
 	if (npages < 1) {
+		DEFINE_RANGE_LOCK_FULL(mmrange);
+
 		/* Check if it's an I/O mapping */
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &mmrange);
 		vma = find_vma(current->mm, hva);
 		if (vma && vma->vm_start <= hva && hva < vma->vm_end &&
 		    (vma->vm_flags & VM_PFNMAP)) {
@@ -406,7 +408,7 @@ int kvmppc_book3s_radix_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 				((hva - vma->vm_start) >> PAGE_SHIFT);
 			pgflags = pgprot_val(vma->vm_page_prot);
 		}
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 		if (!pfn)
 			return -EFAULT;
 	} else {
diff --git a/arch/powerpc/kvm/book3s_64_vio.c b/arch/powerpc/kvm/book3s_64_vio.c
index 4dffa611376d..5e6fe2820009 100644
--- a/arch/powerpc/kvm/book3s_64_vio.c
+++ b/arch/powerpc/kvm/book3s_64_vio.c
@@ -60,11 +60,12 @@ static unsigned long kvmppc_stt_pages(unsigned long tce_pages)
 static long kvmppc_account_memlimit(unsigned long stt_pages, bool inc)
 {
 	long ret = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (!current || !current->mm)
 		return ret; /* process exited */
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm, &mmrange);
 
 	if (inc) {
 		unsigned long locked, lock_limit;
@@ -89,7 +90,7 @@ static long kvmppc_account_memlimit(unsigned long stt_pages, bool inc)
 			rlimit(RLIMIT_MEMLOCK),
 			ret ? " - exceeded" : "");
 
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 
 	return ret;
 }
diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index 473f6eebe34f..1bf281f37713 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -3610,6 +3610,7 @@ static int kvmppc_hv_setup_htab_rma(struct kvm_vcpu *vcpu)
 	unsigned long lpcr = 0, senc;
 	unsigned long psize, porder;
 	int srcu_idx;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/* Allocate hashed page table (if not done already) and reset it */
 	if (!kvm->arch.hpt.virt) {
@@ -3642,7 +3643,7 @@ static int kvmppc_hv_setup_htab_rma(struct kvm_vcpu *vcpu)
 
 	/* Look up the VMA for the start of this memory slot */
 	hva = memslot->userspace_addr;
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	vma = find_vma(current->mm, hva);
 	if (!vma || vma->vm_start > hva || (vma->vm_flags & VM_IO))
 		goto up_out;
@@ -3650,7 +3651,7 @@ static int kvmppc_hv_setup_htab_rma(struct kvm_vcpu *vcpu)
 	psize = vma_kernel_pagesize(vma);
 	porder = __ilog2(psize);
 
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 
 	/* We can handle 4k, 64k or 16M pages in the VRMA */
 	err = -EINVAL;
@@ -3680,7 +3681,7 @@ static int kvmppc_hv_setup_htab_rma(struct kvm_vcpu *vcpu)
 	return err;
 
  up_out:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 	goto out_srcu;
 }
 
diff --git a/arch/powerpc/kvm/e500_mmu_host.c b/arch/powerpc/kvm/e500_mmu_host.c
index 423b21393bc9..72ce80fa9453 100644
--- a/arch/powerpc/kvm/e500_mmu_host.c
+++ b/arch/powerpc/kvm/e500_mmu_host.c
@@ -358,7 +358,8 @@ static inline int kvmppc_e500_shadow_map(struct kvmppc_vcpu_e500 *vcpu_e500,
 
 	if (tlbsel == 1) {
 		struct vm_area_struct *vma;
-		down_read(&current->mm->mmap_sem);
+		DEFINE_RANGE_LOCK_FULL(mmrange);
+		mm_read_lock(current->mm, &mmrange);
 
 		vma = find_vma(current->mm, hva);
 		if (vma && hva >= vma->vm_start &&
@@ -444,7 +445,7 @@ static inline int kvmppc_e500_shadow_map(struct kvmppc_vcpu_e500 *vcpu_e500,
 			tsize = max(BOOK3E_PAGESZ_4K, tsize & ~1);
 		}
 
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 	}
 
 	if (likely(!pfnmap)) {
diff --git a/arch/powerpc/mm/copro_fault.c b/arch/powerpc/mm/copro_fault.c
index 8f5e604828a1..570ebca7e2f8 100644
--- a/arch/powerpc/mm/copro_fault.c
+++ b/arch/powerpc/mm/copro_fault.c
@@ -47,7 +47,7 @@ int copro_handle_mm_fault(struct mm_struct *mm, unsigned long ea,
 	if (mm->pgd == NULL)
 		return -EFAULT;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	ret = -EFAULT;
 	vma = find_vma(mm, ea);
 	if (!vma)
@@ -97,7 +97,7 @@ int copro_handle_mm_fault(struct mm_struct *mm, unsigned long ea,
 		current->min_flt++;
 
 out_unlock:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(copro_handle_mm_fault);
diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
index 91ee2231c527..35d32a8ccb89 100644
--- a/arch/powerpc/mm/mmu_context_iommu.c
+++ b/arch/powerpc/mm/mmu_context_iommu.c
@@ -36,11 +36,12 @@ static long mm_iommu_adjust_locked_vm(struct mm_struct *mm,
 		unsigned long npages, bool incr)
 {
 	long ret = 0, locked, lock_limit;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (!npages)
 		return 0;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 
 	if (incr) {
 		locked = mm->locked_vm + npages;
@@ -61,7 +62,7 @@ static long mm_iommu_adjust_locked_vm(struct mm_struct *mm,
 			npages << PAGE_SHIFT,
 			mm->locked_vm << PAGE_SHIFT,
 			rlimit(RLIMIT_MEMLOCK));
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 
 	return ret;
 }
diff --git a/arch/powerpc/mm/subpage-prot.c b/arch/powerpc/mm/subpage-prot.c
index f14a07c2fb90..0afd636123fd 100644
--- a/arch/powerpc/mm/subpage-prot.c
+++ b/arch/powerpc/mm/subpage-prot.c
@@ -97,9 +97,10 @@ static void subpage_prot_clear(unsigned long addr, unsigned long len)
 	u32 **spm, *spp;
 	unsigned long i;
 	size_t nw;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	unsigned long next, limit;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	limit = addr + len;
 	if (limit > spt->maxaddr)
 		limit = spt->maxaddr;
@@ -127,7 +128,7 @@ static void subpage_prot_clear(unsigned long addr, unsigned long len)
 		/* now flush any existing HPTEs for the range */
 		hpte_flush_range(mm, addr, nw);
 	}
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -216,7 +217,7 @@ long sys_subpage_prot(unsigned long addr, unsigned long len, u32 __user *map)
 	if (!access_ok(VERIFY_READ, map, (len >> PAGE_SHIFT) * sizeof(u32)))
 		return -EFAULT;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	subpage_mark_vma_nohuge(mm, addr, len);
 	for (limit = addr + len; addr < limit; addr = next) {
 		next = pmd_addr_end(addr, limit);
@@ -251,11 +252,11 @@ long sys_subpage_prot(unsigned long addr, unsigned long len, u32 __user *map)
 		if (addr + (nw << PAGE_SHIFT) > next)
 			nw = (next - addr) >> PAGE_SHIFT;
 
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &mmrange);
 		if (__copy_from_user(spp, map, nw * sizeof(u32)))
 			return -EFAULT;
 		map += nw;
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm, &mmrange);
 
 		/* now flush any existing HPTEs for the range */
 		hpte_flush_range(mm, addr, nw);
@@ -264,6 +265,6 @@ long sys_subpage_prot(unsigned long addr, unsigned long len, u32 __user *map)
 		spt->maxaddr = limit;
 	err = 0;
  out:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return err;
 }
diff --git a/arch/powerpc/oprofile/cell/spu_task_sync.c b/arch/powerpc/oprofile/cell/spu_task_sync.c
index 44d67b167e0b..50ebb615fdab 100644
--- a/arch/powerpc/oprofile/cell/spu_task_sync.c
+++ b/arch/powerpc/oprofile/cell/spu_task_sync.c
@@ -325,6 +325,7 @@ get_exec_dcookie_and_offset(struct spu *spu, unsigned int *offsetp,
 	struct vm_area_struct *vma;
 	struct file *exe_file;
 	struct mm_struct *mm = spu->mm;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (!mm)
 		goto out;
@@ -336,7 +337,7 @@ get_exec_dcookie_and_offset(struct spu *spu, unsigned int *offsetp,
 		fput(exe_file);
 	}
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (vma->vm_start > spu_ref || vma->vm_end <= spu_ref)
 			continue;
@@ -353,13 +354,13 @@ get_exec_dcookie_and_offset(struct spu *spu, unsigned int *offsetp,
 	*spu_bin_dcookie = fast_get_dcookie(&vma->vm_file->f_path);
 	pr_debug("got dcookie for %pD\n", vma->vm_file);
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 out:
 	return app_cookie;
 
 fail_no_image_cookie:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	printk(KERN_ERR "SPU_PROF: "
 		"%s, line %d: Cannot find dcookie for SPU binary\n",
diff --git a/arch/powerpc/platforms/cell/spufs/file.c b/arch/powerpc/platforms/cell/spufs/file.c
index c1be486da899..f2017a915bd8 100644
--- a/arch/powerpc/platforms/cell/spufs/file.c
+++ b/arch/powerpc/platforms/cell/spufs/file.c
@@ -347,11 +347,13 @@ static int spufs_ps_fault(struct vm_fault *vmf,
 		goto refault;
 
 	if (ctx->state == SPU_STATE_SAVED) {
-		up_read(&current->mm->mmap_sem);
+		DEFINE_RANGE_LOCK_FULL(mmrange);
+
+		mm_read_unlock(current->mm, &mmrange);
 		spu_context_nospu_trace(spufs_ps_fault__sleep, ctx);
 		ret = spufs_wait(ctx->run_wq, ctx->state == SPU_STATE_RUNNABLE);
 		spu_context_trace(spufs_ps_fault__wake, ctx, ctx->spu);
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &mmrange);
 	} else {
 		area = ctx->spu->problem_phys + ps_offs;
 		vm_insert_pfn(vmf->vma, vmf->address, (area + offset) >> PAGE_SHIFT);
diff --git a/arch/powerpc/platforms/powernv/npu-dma.c b/arch/powerpc/platforms/powernv/npu-dma.c
index 759e9a4c7479..8cf4be123663 100644
--- a/arch/powerpc/platforms/powernv/npu-dma.c
+++ b/arch/powerpc/platforms/powernv/npu-dma.c
@@ -802,7 +802,7 @@ int pnv_npu2_handle_fault(struct npu_context *context, uintptr_t *ea,
 	if (!firmware_has_feature(FW_FEATURE_OPAL))
 		return -ENODEV;
 
-	WARN_ON(!rwsem_is_locked(&mm->mmap_sem));
+	WARN_ON(!mm_is_locked(mm, mmrange));
 
 	for (i = 0; i < count; i++) {
 		is_write = flags[i] & NPU2_WRITE;
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
