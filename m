Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 61E7C6B0338
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:30 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h76so150148632pfh.15
        for <linux-mm@kvack.org>; Wed, 24 May 2017 04:20:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n22si886343pgd.182.2017.05.24.04.20.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 04:20:28 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4OBARjH040814
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:28 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2an1m13jyc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:27 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 24 May 2017 12:20:24 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v2 07/10] mm: Add a range lock parameter to GUP() and handle_page_fault()
Date: Wed, 24 May 2017 13:19:58 +0200
In-Reply-To: <1495624801-8063-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1495624801-8063-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1495624801-8063-8-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, Andi Kleen <andi@firstfloor.org>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

As get_user_pages*(), handle_page_fault(), fixup_user_fault() and
populate_vma_page_range() functions may release the mmap_sem, they
have to know the range when dealing with range locks.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/powerpc/mm/copro_fault.c               |   2 +-
 arch/powerpc/mm/fault.c                     |   2 +-
 arch/powerpc/platforms/powernv/npu-dma.c    |   2 +-
 arch/x86/mm/fault.c                         |   2 +-
 arch/x86/mm/mpx.c                           |   2 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c     |   2 +-
 drivers/gpu/drm/etnaviv/etnaviv_gem.c       |   3 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c     |   2 +-
 drivers/gpu/drm/radeon/radeon_ttm.c         |   2 +-
 drivers/infiniband/core/umem.c              |   2 +-
 drivers/infiniband/core/umem_odp.c          |   2 +-
 drivers/infiniband/hw/mthca/mthca_memfree.c |   3 +-
 drivers/infiniband/hw/qib/qib_user_pages.c  |   2 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c    |   2 +-
 drivers/iommu/intel-svm.c                   |   2 +-
 drivers/media/v4l2-core/videobuf-dma-sg.c   |   2 +-
 drivers/misc/mic/scif/scif_rma.c            |   2 +-
 fs/exec.c                                   |   2 +-
 include/linux/mm.h                          |  58 +++++++++++---
 kernel/events/uprobes.c                     |   4 +-
 kernel/futex.c                              |   2 +-
 mm/frame_vector.c                           |   2 +-
 mm/gup.c                                    | 113 ++++++++++++++++++++++------
 mm/internal.h                               |  11 ++-
 mm/ksm.c                                    |   3 +-
 mm/memory.c                                 |  27 +++++--
 mm/mempolicy.c                              |   2 +-
 mm/mmap.c                                   |   4 +-
 mm/mprotect.c                               |   2 +-
 mm/process_vm_access.c                      |   3 +-
 security/tomoyo/domain.c                    |   2 +-
 virt/kvm/kvm_main.c                         |   6 +-
 32 files changed, 202 insertions(+), 75 deletions(-)

diff --git a/arch/powerpc/mm/copro_fault.c b/arch/powerpc/mm/copro_fault.c
index 697b70ad1195..81fbf79d2e97 100644
--- a/arch/powerpc/mm/copro_fault.c
+++ b/arch/powerpc/mm/copro_fault.c
@@ -77,7 +77,7 @@ int copro_handle_mm_fault(struct mm_struct *mm, unsigned long ea,
 	}
 
 	ret = 0;
-	*flt = handle_mm_fault(vma, ea, is_write ? FAULT_FLAG_WRITE : 0);
+	*flt = handle_mm_fault(vma, ea, is_write ? FAULT_FLAG_WRITE : 0, NULL);
 	if (unlikely(*flt & VM_FAULT_ERROR)) {
 		if (*flt & VM_FAULT_OOM) {
 			ret = -ENOMEM;
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 3a7d580fdc59..278550794dea 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -446,7 +446,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, NULL);
 
 	/*
 	 * Handle the retry right now, the mmap_sem has been released in that
diff --git a/arch/powerpc/platforms/powernv/npu-dma.c b/arch/powerpc/platforms/powernv/npu-dma.c
index e75f1c1911c6..b05dd9d72f8c 100644
--- a/arch/powerpc/platforms/powernv/npu-dma.c
+++ b/arch/powerpc/platforms/powernv/npu-dma.c
@@ -764,7 +764,7 @@ int pnv_npu2_handle_fault(struct npu_context *context, uintptr_t *ea,
 		is_write = flags[i] & NPU2_WRITE;
 		rc = get_user_pages_remote(NULL, mm, ea[i], 1,
 					is_write ? FOLL_WRITE : 0,
-					page, NULL, NULL);
+					page, NULL, NULL, NULL);
 
 		/*
 		 * To support virtualised environments we will have to do an
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 8ad91a01cbc8..f078bc9458b0 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1442,7 +1442,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	 * the fault.  Since we never set FAULT_FLAG_RETRY_NOWAIT, if
 	 * we get VM_FAULT_RETRY back, the mmap_sem has been unlocked.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, NULL);
 	major |= fault & VM_FAULT_MAJOR;
 
 	/*
diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index 1c34b767c84c..313e6fcb550e 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -539,7 +539,7 @@ static int mpx_resolve_fault(long __user *addr, int write)
 	int nr_pages = 1;
 
 	gup_ret = get_user_pages((unsigned long)addr, nr_pages,
-			write ? FOLL_WRITE : 0,	NULL, NULL);
+			write ? FOLL_WRITE : 0,	NULL, NULL, NULL);
 	/*
 	 * get_user_pages() returns number of pages gotten.
 	 * 0 means we failed to fault in and get anything,
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
index 5db0230e45c6..0fbd1d284535 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
@@ -613,7 +613,7 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct page **pages)
 		list_add(&guptask.list, &gtt->guptasks);
 		spin_unlock(&gtt->guptasklock);
 
-		r = get_user_pages(userptr, num_pages, flags, p, NULL);
+		r = get_user_pages(userptr, num_pages, flags, p, NULL, NULL);
 
 		spin_lock(&gtt->guptasklock);
 		list_del(&guptask.list);
diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gem.c b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
index fd56f92f3469..75ca18aaa34e 100644
--- a/drivers/gpu/drm/etnaviv/etnaviv_gem.c
+++ b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
@@ -761,7 +761,8 @@ static struct page **etnaviv_gem_userptr_do_get_pages(
 	down_read(&mm->mmap_sem);
 	while (pinned < npages) {
 		ret = get_user_pages_remote(task, mm, ptr, npages - pinned,
-					    flags, pvec + pinned, NULL, NULL);
+					    flags, pvec + pinned, NULL, NULL,
+					    NULL);
 		if (ret < 0)
 			break;
 
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 58ccf8b8ca1c..491bb58cab09 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -524,7 +524,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 					 obj->userptr.ptr + pinned * PAGE_SIZE,
 					 npages - pinned,
 					 flags,
-					 pvec + pinned, NULL, NULL);
+					 pvec + pinned, NULL, NULL, NULL);
 				if (ret < 0)
 					break;
 
diff --git a/drivers/gpu/drm/radeon/radeon_ttm.c b/drivers/gpu/drm/radeon/radeon_ttm.c
index 8b7623b5a624..98a778501f21 100644
--- a/drivers/gpu/drm/radeon/radeon_ttm.c
+++ b/drivers/gpu/drm/radeon/radeon_ttm.c
@@ -569,7 +569,7 @@ static int radeon_ttm_tt_pin_userptr(struct ttm_tt *ttm)
 		struct page **pages = ttm->pages + pinned;
 
 		r = get_user_pages(userptr, num_pages, write ? FOLL_WRITE : 0,
-				   pages, NULL);
+				   pages, NULL, NULL);
 		if (r < 0)
 			goto release_pages;
 
diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index 3dbf811d3c51..73749d6d18f1 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -194,7 +194,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 		ret = get_user_pages(cur_base,
 				     min_t(unsigned long, npages,
 					   PAGE_SIZE / sizeof (struct page *)),
-				     gup_flags, page_list, vma_list);
+				     gup_flags, page_list, vma_list, NULL);
 
 		if (ret < 0)
 			goto out;
diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index 0780b1afefa9..6e1e574db5d3 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -665,7 +665,7 @@ int ib_umem_odp_map_dma_pages(struct ib_umem *umem, u64 user_virt, u64 bcnt,
 		 */
 		npages = get_user_pages_remote(owning_process, owning_mm,
 				user_virt, gup_num_pages,
-				flags, local_page_list, NULL, NULL);
+				flags, local_page_list, NULL, NULL, NULL);
 		up_read(&owning_mm->mmap_sem);
 
 		if (npages < 0)
diff --git a/drivers/infiniband/hw/mthca/mthca_memfree.c b/drivers/infiniband/hw/mthca/mthca_memfree.c
index c6fe89d79248..9024f956669a 100644
--- a/drivers/infiniband/hw/mthca/mthca_memfree.c
+++ b/drivers/infiniband/hw/mthca/mthca_memfree.c
@@ -472,7 +472,8 @@ int mthca_map_user_db(struct mthca_dev *dev, struct mthca_uar *uar,
 		goto out;
 	}
 
-	ret = get_user_pages(uaddr & PAGE_MASK, 1, FOLL_WRITE, pages, NULL);
+	ret = get_user_pages(uaddr & PAGE_MASK, 1, FOLL_WRITE, pages, NULL,
+			     NULL);
 	if (ret < 0)
 		goto out;
 
diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
index ce83ba9a12ef..c1cf13f2722a 100644
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -70,7 +70,7 @@ static int __qib_get_user_pages(unsigned long start_page, size_t num_pages,
 		ret = get_user_pages(start_page + got * PAGE_SIZE,
 				     num_pages - got,
 				     FOLL_WRITE | FOLL_FORCE,
-				     p + got, NULL);
+				     p + got, NULL, NULL);
 		if (ret < 0)
 			goto bail_release;
 	}
diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniband/hw/usnic/usnic_uiom.c
index c49db7c33979..1591d0e78bfa 100644
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
@@ -146,7 +146,7 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 		ret = get_user_pages(cur_base,
 					min_t(unsigned long, npages,
 					PAGE_SIZE / sizeof(struct page *)),
-					gup_flags, page_list, NULL);
+					gup_flags, page_list, NULL, NULL);
 
 		if (ret < 0)
 			goto out;
diff --git a/drivers/iommu/intel-svm.c b/drivers/iommu/intel-svm.c
index 23c427602c55..4ba770b9cfbb 100644
--- a/drivers/iommu/intel-svm.c
+++ b/drivers/iommu/intel-svm.c
@@ -591,7 +591,7 @@ static irqreturn_t prq_event_thread(int irq, void *d)
 			goto invalid;
 
 		ret = handle_mm_fault(vma, address,
-				      req->wr_req ? FAULT_FLAG_WRITE : 0);
+				      req->wr_req ? FAULT_FLAG_WRITE : 0, NULL);
 		if (ret & VM_FAULT_ERROR)
 			goto invalid;
 
diff --git a/drivers/media/v4l2-core/videobuf-dma-sg.c b/drivers/media/v4l2-core/videobuf-dma-sg.c
index 0b5c43f7e020..b789070047df 100644
--- a/drivers/media/v4l2-core/videobuf-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
@@ -186,7 +186,7 @@ static int videobuf_dma_init_user_locked(struct videobuf_dmabuf *dma,
 		data, size, dma->nr_pages);
 
 	err = get_user_pages(data & PAGE_MASK, dma->nr_pages,
-			     flags, dma->pages, NULL);
+			     flags, dma->pages, NULL, NULL);
 
 	if (err != dma->nr_pages) {
 		dma->nr_pages = (err >= 0) ? err : 0;
diff --git a/drivers/misc/mic/scif/scif_rma.c b/drivers/misc/mic/scif/scif_rma.c
index 329727e00e97..30e3c524216d 100644
--- a/drivers/misc/mic/scif/scif_rma.c
+++ b/drivers/misc/mic/scif/scif_rma.c
@@ -1401,7 +1401,7 @@ int __scif_pin_pages(void *addr, size_t len, int *out_prot,
 				nr_pages,
 				(prot & SCIF_PROT_WRITE) ? FOLL_WRITE : 0,
 				pinned_pages->pages,
-				NULL);
+				NULL, NULL);
 		up_write(&mm->mmap_sem);
 		if (nr_pages != pinned_pages->nr_pages) {
 			if (try_upgrade) {
diff --git a/fs/exec.c b/fs/exec.c
index 72934df68471..ef44ce8302b6 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -214,7 +214,7 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 	 * doing the exec and bprm->mm is the new process's mm.
 	 */
 	ret = get_user_pages_remote(current, bprm->mm, pos, 1, gup_flags,
-			&page, NULL, NULL);
+				    &page, NULL, NULL, NULL);
 	if (ret <= 0)
 		return NULL;
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4ad96294c180..b09048386152 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1286,14 +1286,28 @@ int generic_error_remove_page(struct address_space *mapping, struct page *page);
 int invalidate_inode_page(struct page *page);
 
 #ifdef CONFIG_MMU
-extern int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
-		unsigned int flags);
-extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
-			    unsigned long address, unsigned int fault_flags,
-			    bool *unlocked);
-#else
+#ifdef CONFIG_MEM_RANGE_LOCK
+extern int _handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
+			    unsigned int flags, struct range_lock *range);
+extern int _fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
+			     unsigned long address, unsigned int fault_flags,
+			     bool *unlocked, struct range_lock *range);
+#define handle_mm_fault _handle_mm_fault
+#define fixup_user_fault _fixup_user_fault
+#else /* CONFIG_MEM_RANGE_LOCK */
+extern int _handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
+			    unsigned int flags);
+extern int _fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
+			     unsigned long address, unsigned int fault_flags,
+			     bool *unlocked);
+#define handle_mm_fault(v, a, f, r) _handle_mm_fault(v, a, f)
+#define fixup_user_fault(t, m, a, f, u, r) _fixup_user_fault(t, m, a, f, u)
+#endif /* CONFIG_MEM_RANGE_LOCK */
+
+#else /* CONFIG_MMU */
 static inline int handle_mm_fault(struct vm_area_struct *vma,
-		unsigned long address, unsigned int flags)
+		unsigned long address, unsigned int flags,
+		struct range_lock *range)
 {
 	/* should never happen if there's no MMU */
 	BUG();
@@ -1301,7 +1315,8 @@ static inline int handle_mm_fault(struct vm_area_struct *vma,
 }
 static inline int fixup_user_fault(struct task_struct *tsk,
 		struct mm_struct *mm, unsigned long address,
-		unsigned int fault_flags, bool *unlocked)
+		unsigned int fault_flags, bool *unlocked,
+		struct range_lock *range)
 {
 	/* should never happen if there's no MMU */
 	BUG();
@@ -1316,15 +1331,36 @@ extern int access_remote_vm(struct mm_struct *mm, unsigned long addr,
 extern int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long addr, void *buf, int len, unsigned int gup_flags);
 
-long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
+#ifdef CONFIG_MEM_RANGE_LOCK
+long _get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
+			    unsigned long start, unsigned long nr_pages,
+			    unsigned int gup_flags, struct page **pages,
+			    struct vm_area_struct **vmas, int *locked,
+			    struct range_lock *range);
+#define get_user_pages_remote _get_user_pages_remote
+#else
+long _get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long start, unsigned long nr_pages,
 			    unsigned int gup_flags, struct page **pages,
 			    struct vm_area_struct **vmas, int *locked);
-long get_user_pages(unsigned long start, unsigned long nr_pages,
+#define get_user_pages_remote(t, m, s, n, g, p, v, l, r) \
+	_get_user_pages_remote(t, m, s, n, g, p, v, l)
+#endif
+#ifdef CONFIG_MEM_RANGE_LOCK
+long _get_user_pages(unsigned long start, unsigned long nr_pages,
+			    unsigned int gup_flags, struct page **pages,
+			    struct vm_area_struct **vmas,
+			    struct range_lock *range);
+#define get_user_pages _get_user_pages
+#else
+long _get_user_pages(unsigned long start, unsigned long nr_pages,
 			    unsigned int gup_flags, struct page **pages,
 			    struct vm_area_struct **vmas);
+#define get_user_pages(s, n, g, p, v, r) _get_user_pages(s, n, g, p, v)
+#endif
 long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
-		    unsigned int gup_flags, struct page **pages, int *locked);
+		    unsigned int gup_flags, struct page **pages, int *locked,
+		    struct range_lock *range);
 long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 		    struct page **pages, unsigned int gup_flags);
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 0e137f98a50c..dc2e5f7a8bb8 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -309,7 +309,7 @@ int uprobe_write_opcode(struct mm_struct *mm, unsigned long vaddr,
 retry:
 	/* Read the page with vaddr into memory */
 	ret = get_user_pages_remote(NULL, mm, vaddr, 1,
-			FOLL_FORCE | FOLL_SPLIT, &old_page, &vma, NULL);
+			FOLL_FORCE | FOLL_SPLIT, &old_page, &vma, NULL, NULL);
 	if (ret <= 0)
 		return ret;
 
@@ -1720,7 +1720,7 @@ static int is_trap_at_addr(struct mm_struct *mm, unsigned long vaddr)
 	 * essentially a kernel access to the memory.
 	 */
 	result = get_user_pages_remote(NULL, mm, vaddr, 1, FOLL_FORCE, &page,
-			NULL, NULL);
+			NULL, NULL, NULL);
 	if (result < 0)
 		return result;
 
diff --git a/kernel/futex.c b/kernel/futex.c
index 357348a6cf6b..531a497eefbd 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -727,7 +727,7 @@ static int fault_in_user_writeable(u32 __user *uaddr)
 
 	down_read(&mm->mmap_sem);
 	ret = fixup_user_fault(current, mm, (unsigned long)uaddr,
-			       FAULT_FLAG_WRITE, NULL);
+			       FAULT_FLAG_WRITE, NULL, NULL);
 	up_read(&mm->mmap_sem);
 
 	return ret < 0 ? ret : 0;
diff --git a/mm/frame_vector.c b/mm/frame_vector.c
index 72ebec18629c..d2c1675ff466 100644
--- a/mm/frame_vector.c
+++ b/mm/frame_vector.c
@@ -56,7 +56,7 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 		vec->got_ref = true;
 		vec->is_pfns = false;
 		ret = get_user_pages_locked(start, nr_frames,
-			gup_flags, (struct page **)(vec->ptrs), &locked);
+			gup_flags, (struct page **)(vec->ptrs), &locked, NULL);
 		goto out;
 	}
 
diff --git a/mm/gup.c b/mm/gup.c
index 0f81ac1a9881..3a8ba8cfae3f 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -379,7 +379,11 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
  * If it is, *@nonblocking will be set to 0 and -EBUSY returned.
  */
 static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
-		unsigned long address, unsigned int *flags, int *nonblocking)
+		unsigned long address, unsigned int *flags, int *nonblocking
+#ifdef CONFIG_MEM_RANGE_LOCK
+		, struct range_lock *range
+#endif
+		)
 {
 	unsigned int fault_flags = 0;
 	int ret;
@@ -405,7 +409,7 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 		fault_flags |= FAULT_FLAG_TRIED;
 	}
 
-	ret = handle_mm_fault(vma, address, fault_flags);
+	ret = handle_mm_fault(vma, address, fault_flags, range);
 	if (ret & VM_FAULT_ERROR) {
 		if (ret & VM_FAULT_OOM)
 			return -ENOMEM;
@@ -500,6 +504,7 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
  * @vmas:	array of pointers to vmas corresponding to each page.
  *		Or NULL if the caller does not require them.
  * @nonblocking: whether waiting for disk IO or mmap_sem contention
+ * @range:	range the lock is applying wheN CONFIG_MEM_RANGE_LOCK is set
  *
  * Returns number of pages pinned. This may be fewer than the number
  * requested. If nr_pages is 0 or negative, returns 0. If no pages
@@ -544,9 +549,13 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
  * you need some special @gup_flags.
  */
 static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		unsigned long start, unsigned long nr_pages,
-		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas, int *nonblocking)
+			     unsigned long start, unsigned long nr_pages,
+			     unsigned int gup_flags, struct page **pages,
+			     struct vm_area_struct **vmas, int *nonblocking
+#ifdef CONFIG_MEM_RANGE_LOCK
+			     , struct range_lock *range
+#endif
+	)
 {
 	long i = 0;
 	unsigned int page_mask;
@@ -605,7 +614,11 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		if (!page) {
 			int ret;
 			ret = faultin_page(tsk, vma, start, &foll_flags,
-					nonblocking);
+					   nonblocking
+#ifdef CONFIG_MEM_RANGE_LOCK
+					   , range
+#endif
+				);
 			switch (ret) {
 			case 0:
 				goto retry;
@@ -702,9 +715,13 @@ static bool vma_permits_fault(struct vm_area_struct *vma,
  * This function will not return with an unlocked mmap_sem. So it has not the
  * same semantics wrt the @mm->mmap_sem as does filemap_fault().
  */
-int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
+int _fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 		     unsigned long address, unsigned int fault_flags,
-		     bool *unlocked)
+		     bool *unlocked
+#ifdef CONFIG_MEM_RANGE_LOCK
+		      , struct range_lock *range
+#endif
+	)
 {
 	struct vm_area_struct *vma;
 	int ret, major = 0;
@@ -720,7 +737,7 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	if (!vma_permits_fault(vma, fault_flags))
 		return -EFAULT;
 
-	ret = handle_mm_fault(vma, address, fault_flags);
+	ret = handle_mm_fault(vma, address, fault_flags, range);
 	major |= ret & VM_FAULT_MAJOR;
 	if (ret & VM_FAULT_ERROR) {
 		if (ret & VM_FAULT_OOM)
@@ -750,7 +767,7 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	}
 	return 0;
 }
-EXPORT_SYMBOL_GPL(fixup_user_fault);
+EXPORT_SYMBOL_GPL(_fixup_user_fault);
 
 static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 						struct mm_struct *mm,
@@ -759,6 +776,9 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 						struct page **pages,
 						struct vm_area_struct **vmas,
 						int *locked, bool notify_drop,
+#ifdef CONFIG_MEM_RANGE_LOCK
+						struct range_lock *range,
+#endif
 						unsigned int flags)
 {
 	long ret, pages_done;
@@ -778,7 +798,11 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 	lock_dropped = false;
 	for (;;) {
 		ret = __get_user_pages(tsk, mm, start, nr_pages, flags, pages,
-				       vmas, locked);
+				       vmas, locked
+#ifdef CONFIG_MEM_RANGE_LOCK
+				       , range
+#endif
+			);
 		if (!locked)
 			/* VM_FAULT_RETRY couldn't trigger, bypass */
 			return ret;
@@ -818,7 +842,11 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 		lock_dropped = true;
 		down_read(&mm->mmap_sem);
 		ret = __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
-				       pages, NULL, NULL);
+				       pages, NULL, NULL
+#ifdef CONFIG_MEM_RANGE_LOCK
+				       , range
+#endif
+			);
 		if (ret != 1) {
 			BUG_ON(ret > 1);
 			if (!pages_done)
@@ -866,10 +894,13 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
  */
 long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 			   unsigned int gup_flags, struct page **pages,
-			   int *locked)
+			   int *locked, struct range_lock *range)
 {
 	return __get_user_pages_locked(current, current->mm, start, nr_pages,
 				       pages, NULL, locked, true,
+#ifdef CONFIG_MEM_RANGE_LOCK
+				       range,
+#endif
 				       gup_flags | FOLL_TOUCH);
 }
 EXPORT_SYMBOL(get_user_pages_locked);
@@ -892,7 +923,11 @@ static __always_inline long __get_user_pages_unlocked(struct task_struct *tsk,
 
 	down_read(&mm->mmap_sem);
 	ret = __get_user_pages_locked(tsk, mm, start, nr_pages, pages, NULL,
-				      &locked, false, gup_flags);
+				      &locked, false,
+#ifdef CONFIG_MEM_RANGE_LOCK
+				      &range,
+#endif
+				      gup_flags);
 	if (locked)
 		up_read(&mm->mmap_sem);
 	return ret;
@@ -977,16 +1012,23 @@ EXPORT_SYMBOL(get_user_pages_unlocked);
  * should use get_user_pages because it cannot pass
  * FAULT_FLAG_ALLOW_RETRY to handle_mm_fault.
  */
-long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
+long _get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas, int *locked)
+		struct vm_area_struct **vmas, int *locked
+#ifdef CONFIG_MEM_RANGE_LOCK
+		, struct range_lock *range
+#endif
+		)
 {
 	return __get_user_pages_locked(tsk, mm, start, nr_pages, pages, vmas,
 				       locked, true,
+#ifdef CONFIG_MEM_RANGE_LOCK
+				       range,
+#endif
 				       gup_flags | FOLL_TOUCH | FOLL_REMOTE);
 }
-EXPORT_SYMBOL(get_user_pages_remote);
+EXPORT_SYMBOL(_get_user_pages_remote);
 
 /*
  * This is the same as get_user_pages_remote(), just with a
@@ -995,15 +1037,22 @@ EXPORT_SYMBOL(get_user_pages_remote);
  * passing of a locked parameter.  We also obviously don't pass
  * FOLL_REMOTE in here.
  */
-long get_user_pages(unsigned long start, unsigned long nr_pages,
+long _get_user_pages(unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas)
+		struct vm_area_struct **vmas
+#ifdef CONFIG_MEM_RANGE_LOCK
+		, struct range_lock *range
+#endif
+		)
 {
 	return __get_user_pages_locked(current, current->mm, start, nr_pages,
 				       pages, vmas, NULL, false,
+#ifdef CONFIG_MEM_RANGE_LOCK
+				       range,
+#endif
 				       gup_flags | FOLL_TOUCH);
 }
-EXPORT_SYMBOL(get_user_pages);
+EXPORT_SYMBOL(_get_user_pages);
 
 /**
  * populate_vma_page_range() -  populate a range of pages in the vma.
@@ -1024,8 +1073,13 @@ EXPORT_SYMBOL(get_user_pages);
  * If @nonblocking is non-NULL, it must held for read only and may be
  * released.  If it's released, *@nonblocking will be set to 0.
  */
-long populate_vma_page_range(struct vm_area_struct *vma,
-		unsigned long start, unsigned long end, int *nonblocking)
+long _populate_vma_page_range(struct vm_area_struct *vma,
+			      unsigned long start, unsigned long end,
+			      int *nonblocking
+#ifdef CONFIG_MEM_RANGE_LOCK
+			      , struct range_lock *range
+#endif
+	)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long nr_pages = (end - start) / PAGE_SIZE;
@@ -1062,7 +1116,11 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 	 * not result in a stack expansion that recurses back here.
 	 */
 	return __get_user_pages(current, mm, start, nr_pages, gup_flags,
-				NULL, NULL, nonblocking);
+				NULL, NULL, nonblocking
+#ifdef CONFIG_MEM_RANGE_LOCK
+				, range
+#endif
+		);
 }
 
 /*
@@ -1111,7 +1169,8 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 		 * double checks the vma flags, so that it won't mlock pages
 		 * if the vma was already munlocked.
 		 */
-		ret = populate_vma_page_range(vma, nstart, nend, &locked);
+		ret = populate_vma_page_range(vma, nstart, nend, &locked,
+					      NULL);
 		if (ret < 0) {
 			if (ignore_errors) {
 				ret = 0;
@@ -1149,7 +1208,11 @@ struct page *get_dump_page(unsigned long addr)
 
 	if (__get_user_pages(current, current->mm, addr, 1,
 			     FOLL_FORCE | FOLL_DUMP | FOLL_GET, &page, &vma,
-			     NULL) < 1)
+			     NULL
+#ifdef CONFIG_MEM_RANGE_LOCK
+			     , NULL
+#endif
+		    ) < 1)
 		return NULL;
 	flush_cache_page(vma, addr, page_to_pfn(page));
 	return page;
diff --git a/mm/internal.h b/mm/internal.h
index 0e4f558412fb..00e7ddb27e9b 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -284,8 +284,17 @@ void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct vm_area_struct *prev, struct rb_node *rb_parent);
 
 #ifdef CONFIG_MMU
-extern long populate_vma_page_range(struct vm_area_struct *vma,
+#ifdef CONFIG_MEM_RANGE_LOCK
+extern long _populate_vma_page_range(struct vm_area_struct *vma,
+		unsigned long start, unsigned long end, int *nonblocking,
+		struct range_lock *range);
+#define populate_vma_page_range _populate_vma_page_range
+#else
+extern long _populate_vma_page_range(struct vm_area_struct *vma,
 		unsigned long start, unsigned long end, int *nonblocking);
+#define populate_vma_page_range(v, s, e, n, r) \
+	_populate_vma_page_range(v, s, e, n)
+#endif
 extern void munlock_vma_pages_range(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end);
 static inline void munlock_vma_pages_all(struct vm_area_struct *vma)
diff --git a/mm/ksm.c b/mm/ksm.c
index d9fc0e456128..36a0a12e336d 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -391,7 +391,8 @@ static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
 			break;
 		if (PageKsm(page))
 			ret = handle_mm_fault(vma, addr,
-					FAULT_FLAG_WRITE | FAULT_FLAG_REMOTE);
+					FAULT_FLAG_WRITE | FAULT_FLAG_REMOTE,
+					NULL);
 		else
 			ret = VM_FAULT_WRITE;
 		put_page(page);
diff --git a/mm/memory.c b/mm/memory.c
index 99f62156616e..f98ecbe35e8f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3771,7 +3771,11 @@ static int handle_pte_fault(struct vm_fault *vmf)
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
 static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
-		unsigned int flags)
+			     unsigned int flags
+#ifdef CONFIG_MEM_RANGE_LOCK
+			     , struct range_lock *range
+#endif
+	)
 {
 	struct vm_fault vmf = {
 		.vma = vma,
@@ -3779,6 +3783,9 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		.flags = flags,
 		.pgoff = linear_page_index(vma, address),
 		.gfp_mask = __get_fault_gfp_mask(vma),
+#ifdef CONFIG_MEM_RANGE_LOCK
+		.lockrange = range,
+#endif
 	};
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgd;
@@ -3853,8 +3860,12 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
-		unsigned int flags)
+int _handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
+		     unsigned int flags
+#ifdef CONFIG_MEM_RANGE_LOCK
+		     , struct range_lock *range
+#endif
+	)
 {
 	int ret;
 
@@ -3881,7 +3892,11 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		ret = hugetlb_fault(vma->vm_mm, vma, address, flags);
 	else
-		ret = __handle_mm_fault(vma, address, flags);
+		ret = __handle_mm_fault(vma, address, flags
+#ifdef CONFIG_MEM_RANGE_LOCK
+					, range
+#endif
+			);
 
 	if (flags & FAULT_FLAG_USER) {
 		mem_cgroup_oom_disable();
@@ -3910,7 +3925,7 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 
 	return ret;
 }
-EXPORT_SYMBOL_GPL(handle_mm_fault);
+EXPORT_SYMBOL_GPL(_handle_mm_fault);
 
 #ifndef __PAGETABLE_P4D_FOLDED
 /*
@@ -4175,7 +4190,7 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		struct page *page = NULL;
 
 		ret = get_user_pages_remote(tsk, mm, addr, 1,
-				gup_flags, &page, &vma, NULL);
+					    gup_flags, &page, &vma, NULL, NULL);
 		if (ret <= 0) {
 #ifndef CONFIG_HAVE_IOREMAP_PROT
 			break;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 37d0b334bfe9..0658c7240e54 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -855,7 +855,7 @@ static int lookup_node(unsigned long addr)
 	struct page *p;
 	int err;
 
-	err = get_user_pages(addr & PAGE_MASK, 1, 0, &p, NULL);
+	err = get_user_pages(addr & PAGE_MASK, 1, 0, &p, NULL, NULL);
 	if (err >= 0) {
 		err = page_to_nid(p);
 		put_page(p);
diff --git a/mm/mmap.c b/mm/mmap.c
index 87c8625ae91d..1796b9ae540d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2380,7 +2380,7 @@ find_extend_vma(struct mm_struct *mm, unsigned long addr)
 	if (!prev || expand_stack(prev, addr))
 		return NULL;
 	if (prev->vm_flags & VM_LOCKED)
-		populate_vma_page_range(prev, addr, prev->vm_end, NULL);
+		populate_vma_page_range(prev, addr, prev->vm_end, NULL, NULL);
 	return prev;
 }
 #else
@@ -2415,7 +2415,7 @@ find_extend_vma(struct mm_struct *mm, unsigned long addr)
 	if (expand_stack(vma, addr))
 		return NULL;
 	if (vma->vm_flags & VM_LOCKED)
-		populate_vma_page_range(vma, addr, start, NULL);
+		populate_vma_page_range(vma, addr, start, NULL, NULL);
 	return vma;
 }
 #endif
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 8edd0d576254..fef798619b06 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -358,7 +358,7 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	 */
 	if ((oldflags & (VM_WRITE | VM_SHARED | VM_LOCKED)) == VM_LOCKED &&
 			(newflags & VM_WRITE)) {
-		populate_vma_page_range(vma, start, end, NULL);
+		populate_vma_page_range(vma, start, end, NULL, NULL);
 	}
 
 	vm_stat_account(mm, oldflags, -nrpages);
diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index 8973cd231ece..fb4f2b96d488 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -111,7 +111,8 @@ static int process_vm_rw_single_vec(unsigned long addr,
 		 */
 		down_read(&mm->mmap_sem);
 		pages = get_user_pages_remote(task, mm, pa, pages, flags,
-					      process_pages, NULL, &locked);
+					      process_pages, NULL, &locked,
+					      NULL);
 		if (locked)
 			up_read(&mm->mmap_sem);
 		if (pages <= 0)
diff --git a/security/tomoyo/domain.c b/security/tomoyo/domain.c
index 00d223e9fb37..d2ef438ee887 100644
--- a/security/tomoyo/domain.c
+++ b/security/tomoyo/domain.c
@@ -883,7 +883,7 @@ bool tomoyo_dump_page(struct linux_binprm *bprm, unsigned long pos,
 	 * the execve().
 	 */
 	if (get_user_pages_remote(current, bprm->mm, pos, 1,
-				FOLL_FORCE, &page, NULL, NULL) <= 0)
+				  FOLL_FORCE, &page, NULL, NULL, NULL) <= 0)
 		return false;
 #else
 	page = bprm->page[pos / PAGE_SIZE];
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index f0fe9d02f6bb..9eb9a1998060 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1344,14 +1344,14 @@ static int get_user_page_nowait(unsigned long start, int write,
 	if (write)
 		flags |= FOLL_WRITE;
 
-	return get_user_pages(start, 1, flags, page, NULL);
+	return get_user_pages(start, 1, flags, page, NULL, NULL);
 }
 
 static inline int check_user_page_hwpoison(unsigned long addr)
 {
 	int rc, flags = FOLL_HWPOISON | FOLL_WRITE;
 
-	rc = get_user_pages(addr, 1, flags, NULL, NULL);
+	rc = get_user_pages(addr, 1, flags, NULL, NULL, NULL);
 	return rc == -EHWPOISON;
 }
 
@@ -1462,7 +1462,7 @@ static int hva_to_pfn_remapped(struct vm_area_struct *vma,
 		bool unlocked = false;
 		r = fixup_user_fault(current, current->mm, addr,
 				     (write_fault ? FAULT_FLAG_WRITE : 0),
-				     &unlocked);
+				     &unlocked, NULL);
 		if (unlocked)
 			return -EAGAIN;
 		if (r)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
