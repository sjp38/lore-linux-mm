Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 78D7A6B03A7
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 08:18:43 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w30so2255131wrc.2
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 05:18:43 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k83si20528395wmh.126.2017.04.19.05.18.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 05:18:40 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3JCDusr026999
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 08:18:39 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29x728285d-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 08:18:38 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 19 Apr 2017 13:18:36 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC 1/4] Add additional range parameter to GUP() and handle_page_fault()
Date: Wed, 19 Apr 2017 14:18:24 +0200
In-Reply-To: <cover.1492595897.git.ldufour@linux.vnet.ibm.com>
References: <cover.1492595897.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1492595897.git.ldufour@linux.vnet.ibm.com>
References: <cover.1492595897.git.ldufour@linux.vnet.ibm.com>
Message-Id: <c538ce923eeb55020a439e0cda243bf465816b47.1492595897.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, Paul.McKenney@us.ibm.com, linux-kernel@vger.kernel.org

Some functions which are called with the mmap_sem held by the caller
may want to release it. Since mmap_sem will become a range lock a
range_rwlock parameter must be added to allow the lock to freed
correctly.

This patch add the additional parameter in the caller and the callee
and also in the vm_fault structure.

Despite this additional parameter which is not used, there is no
functional change in the patch.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/powerpc/mm/copro_fault.c               |  2 +-
 arch/powerpc/mm/fault.c                     |  2 +-
 arch/x86/mm/fault.c                         |  2 +-
 arch/x86/mm/mpx.c                           |  2 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c     |  2 +-
 drivers/gpu/drm/etnaviv/etnaviv_gem.c       |  3 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c     |  2 +-
 drivers/gpu/drm/radeon/radeon_ttm.c         |  2 +-
 drivers/infiniband/core/umem.c              |  2 +-
 drivers/infiniband/core/umem_odp.c          |  2 +-
 drivers/infiniband/hw/mthca/mthca_memfree.c |  3 +-
 drivers/infiniband/hw/qib/qib_user_pages.c  |  2 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c    |  2 +-
 drivers/iommu/intel-svm.c                   |  2 +-
 drivers/media/v4l2-core/videobuf-dma-sg.c   |  2 +-
 drivers/misc/mic/scif/scif_rma.c            |  2 +-
 fs/exec.c                                   |  2 +-
 fs/userfaultfd.c                            |  3 +-
 include/linux/hugetlb.h                     |  4 +--
 include/linux/mm.h                          | 21 ++++++++-----
 include/linux/pagemap.h                     |  8 +++--
 include/linux/userfaultfd_k.h               |  6 ++--
 kernel/events/uprobes.c                     |  4 +--
 kernel/futex.c                              |  2 +-
 mm/filemap.c                                |  5 ++--
 mm/frame_vector.c                           |  2 +-
 mm/gup.c                                    | 46 ++++++++++++++++-------------
 mm/hugetlb.c                                |  3 +-
 mm/internal.h                               |  3 +-
 mm/khugepaged.c                             | 17 +++++++----
 mm/ksm.c                                    |  3 +-
 mm/madvise.c                                | 14 +++++----
 mm/memory.c                                 | 12 ++++----
 mm/mempolicy.c                              |  2 +-
 mm/mmap.c                                   |  4 +--
 mm/mprotect.c                               |  2 +-
 mm/process_vm_access.c                      |  3 +-
 mm/userfaultfd.c                            |  8 +++--
 security/tomoyo/domain.c                    |  2 +-
 virt/kvm/kvm_main.c                         | 12 ++++----
 40 files changed, 130 insertions(+), 92 deletions(-)

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
index fd6484fc2fa9..20f470486177 100644
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
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 428e31763cb9..d81cd399544a 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1394,7 +1394,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	 * the fault.  Since we never set FAULT_FLAG_RETRY_NOWAIT, if
 	 * we get VM_FAULT_RETRY back, the mmap_sem has been unlocked.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, NULL);
 	major |= fault & VM_FAULT_MAJOR;
 
 	/*
diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index cd44ae727df7..864a47193b6c 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -547,7 +547,7 @@ static int mpx_resolve_fault(long __user *addr, int write)
 	int nr_pages = 1;
 
 	gup_ret = get_user_pages((unsigned long)addr, nr_pages,
-			write ? FOLL_WRITE : 0,	NULL, NULL);
+			write ? FOLL_WRITE : 0,	NULL, NULL, NULL);
 	/*
 	 * get_user_pages() returns number of pages gotten.
 	 * 0 means we failed to fault in and get anything,
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
index 4c6094eefc51..14e02d3a6984 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
@@ -627,7 +627,7 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct page **pages)
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
index 22b46398831e..1f8e8eecb6df 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -516,7 +516,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 					 obj->userptr.ptr + pinned * PAGE_SIZE,
 					 npages - pinned,
 					 flags,
-					 pvec + pinned, NULL, NULL);
+					 pvec + pinned, NULL, NULL, NULL);
 				if (ret < 0)
 					break;
 
diff --git a/drivers/gpu/drm/radeon/radeon_ttm.c b/drivers/gpu/drm/radeon/radeon_ttm.c
index aaa3e80fecb4..86ced4d0092c 100644
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
index 27f155d2df8d..0fe3bfb6839d 100644
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
index cb2742b548bb..0ac3c739a986 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -649,7 +649,7 @@ int ib_umem_odp_map_dma_pages(struct ib_umem *umem, u64 user_virt, u64 bcnt,
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
index 65145a3df065..49a3a19816f0 100644
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
 
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index f7555fc25877..b83117741b11 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -698,7 +698,8 @@ void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx *vm_ctx,
 }
 
 bool userfaultfd_remove(struct vm_area_struct *vma,
-			unsigned long start, unsigned long end)
+			unsigned long start, unsigned long end,
+			struct range_rwlock *range)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct userfaultfd_ctx *ctx;
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index b857fc8cc2ec..c586f0d40995 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -66,7 +66,7 @@ int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_ar
 long follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *,
 			 struct page **, struct vm_area_struct **,
 			 unsigned long *, unsigned long *, long, unsigned int,
-			 int *);
+			 int *, struct range_rwlock *);
 void unmap_hugepage_range(struct vm_area_struct *,
 			  unsigned long, unsigned long, struct page *);
 void __unmap_hugepage_range_final(struct mmu_gather *tlb,
@@ -137,7 +137,7 @@ static inline unsigned long hugetlb_total_pages(void)
 	return 0;
 }
 
-#define follow_hugetlb_page(m,v,p,vs,a,b,i,w,n)	({ BUG(); 0; })
+#define follow_hugetlb_page(m,v,p,vs,a,b,i,w,n,r)	({ BUG(); 0; })
 #define follow_huge_addr(mm, addr, write)	ERR_PTR(-EINVAL)
 #define copy_hugetlb_page_range(src, dst, vma)	({ BUG(); 0; })
 static inline void hugetlb_report_meminfo(struct seq_file *m)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 00a8fa7e366a..dbd77258baae 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -23,6 +23,7 @@
 #include <linux/page_ext.h>
 #include <linux/err.h>
 #include <linux/page_ref.h>
+#include <linux/range_rwlock.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -344,6 +345,7 @@ struct vm_fault {
 					 * page table to avoid allocation from
 					 * atomic context.
 					 */
+	struct range_rwlock *lockrange;	/* RW range lock interval */
 };
 
 /* page entry size for vm->huge_fault() */
@@ -1272,13 +1274,14 @@ int invalidate_inode_page(struct page *page);
 
 #ifdef CONFIG_MMU
 extern int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
-		unsigned int flags);
+		unsigned int flags, struct range_rwlock *range);
 extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long address, unsigned int fault_flags,
-			    bool *unlocked);
+			    bool *unlocked, struct range_rwlock *range);
 #else
 static inline int handle_mm_fault(struct vm_area_struct *vma,
-		unsigned long address, unsigned int flags)
+		unsigned long address, unsigned int flags,
+		struct range_rwlock *range)
 {
 	/* should never happen if there's no MMU */
 	BUG();
@@ -1286,7 +1289,8 @@ static inline int handle_mm_fault(struct vm_area_struct *vma,
 }
 static inline int fixup_user_fault(struct task_struct *tsk,
 		struct mm_struct *mm, unsigned long address,
-		unsigned int fault_flags, bool *unlocked)
+		unsigned int fault_flags, bool *unlocked,
+		struct range_rwlock *range)
 {
 	/* should never happen if there's no MMU */
 	BUG();
@@ -1304,12 +1308,15 @@ extern int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long start, unsigned long nr_pages,
 			    unsigned int gup_flags, struct page **pages,
-			    struct vm_area_struct **vmas, int *locked);
+			    struct vm_area_struct **vmas, int *locked,
+			    struct range_rwlock *range);
 long get_user_pages(unsigned long start, unsigned long nr_pages,
 			    unsigned int gup_flags, struct page **pages,
-			    struct vm_area_struct **vmas);
+			    struct vm_area_struct **vmas,
+			    struct range_rwlock *range);
 long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
-		    unsigned int gup_flags, struct page **pages, int *locked);
+		    unsigned int gup_flags, struct page **pages, int *locked,
+		    struct range_rwlock *range);
 long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 		    struct page **pages, unsigned int gup_flags);
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 84943e8057ef..a4c0d2d36d37 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -434,7 +434,7 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
 extern void __lock_page(struct page *page);
 extern int __lock_page_killable(struct page *page);
 extern int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
-				unsigned int flags);
+				unsigned int flags, struct range_rwlock *range);
 extern void unlock_page(struct page *page);
 
 static inline int trylock_page(struct page *page)
@@ -474,10 +474,12 @@ static inline int lock_page_killable(struct page *page)
  * __lock_page_or_retry().
  */
 static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
-				     unsigned int flags)
+				     unsigned int flags,
+				     struct range_rwlock *range)
 {
 	might_sleep();
-	return trylock_page(page) || __lock_page_or_retry(page, mm, flags);
+	return trylock_page(page) || __lock_page_or_retry(page, mm, flags,
+							  range);
 }
 
 /*
diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index 48a3483dccb1..9c73362cf4f6 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -63,7 +63,8 @@ extern void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx *,
 
 extern bool userfaultfd_remove(struct vm_area_struct *vma,
 			       unsigned long start,
-			       unsigned long end);
+			       unsigned long end,
+			       struct range_rwlock *range);
 
 extern int userfaultfd_unmap_prep(struct vm_area_struct *vma,
 				  unsigned long start, unsigned long end,
@@ -119,7 +120,8 @@ static inline void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx *ctx,
 
 static inline bool userfaultfd_remove(struct vm_area_struct *vma,
 				      unsigned long start,
-				      unsigned long end)
+				      unsigned long end,
+				      struct range_rwlock *range)
 {
 	return true;
 }
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
index 45858ec73941..4dd1bba09831 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -727,7 +727,7 @@ static int fault_in_user_writeable(u32 __user *uaddr)
 
 	down_read(&mm->mmap_sem);
 	ret = fixup_user_fault(current, mm, (unsigned long)uaddr,
-			       FAULT_FLAG_WRITE, NULL);
+			       FAULT_FLAG_WRITE, NULL, NULL);
 	up_read(&mm->mmap_sem);
 
 	return ret < 0 ? ret : 0;
diff --git a/mm/filemap.c b/mm/filemap.c
index 1694623a6289..3a5945f2fd3c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1053,7 +1053,7 @@ EXPORT_SYMBOL_GPL(__lock_page_killable);
  * with the page locked and the mmap_sem unperturbed.
  */
 int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
-			 unsigned int flags)
+			 unsigned int flags, struct range_rwlock *range)
 {
 	if (flags & FAULT_FLAG_ALLOW_RETRY) {
 		/*
@@ -2232,7 +2232,8 @@ int filemap_fault(struct vm_fault *vmf)
 			goto no_cached_page;
 	}
 
-	if (!lock_page_or_retry(page, vmf->vma->vm_mm, vmf->flags)) {
+	if (!lock_page_or_retry(page, vmf->vma->vm_mm, vmf->flags,
+				vmf->lockrange)) {
 		put_page(page);
 		return ret | VM_FAULT_RETRY;
 	}
diff --git a/mm/frame_vector.c b/mm/frame_vector.c
index db77dcb38afd..579d1cbe039c 100644
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
index 04aa405350dc..b83b47804c6e 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -379,7 +379,8 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
  * If it is, *@nonblocking will be set to 0 and -EBUSY returned.
  */
 static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
-		unsigned long address, unsigned int *flags, int *nonblocking)
+		unsigned long address, unsigned int *flags, int *nonblocking,
+		struct range_rwlock *range)
 {
 	unsigned int fault_flags = 0;
 	int ret;
@@ -405,7 +406,7 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 		fault_flags |= FAULT_FLAG_TRIED;
 	}
 
-	ret = handle_mm_fault(vma, address, fault_flags);
+	ret = handle_mm_fault(vma, address, fault_flags, range);
 	if (ret & VM_FAULT_ERROR) {
 		if (ret & VM_FAULT_OOM)
 			return -ENOMEM;
@@ -546,7 +547,8 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
 static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas, int *nonblocking)
+		struct vm_area_struct **vmas, int *nonblocking,
+		struct range_rwlock *range)
 {
 	long i = 0;
 	unsigned int page_mask;
@@ -589,7 +591,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			if (is_vm_hugetlb_page(vma)) {
 				i = follow_hugetlb_page(mm, vma, pages, vmas,
 						&start, &nr_pages, i,
-						gup_flags, nonblocking);
+						gup_flags, nonblocking, range);
 				continue;
 			}
 		}
@@ -605,7 +607,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		if (!page) {
 			int ret;
 			ret = faultin_page(tsk, vma, start, &foll_flags,
-					nonblocking);
+					nonblocking, range);
 			switch (ret) {
 			case 0:
 				goto retry;
@@ -704,7 +706,7 @@ static bool vma_permits_fault(struct vm_area_struct *vma,
  */
 int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 		     unsigned long address, unsigned int fault_flags,
-		     bool *unlocked)
+		     bool *unlocked, struct range_rwlock *range)
 {
 	struct vm_area_struct *vma;
 	int ret, major = 0;
@@ -720,7 +722,7 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	if (!vma_permits_fault(vma, fault_flags))
 		return -EFAULT;
 
-	ret = handle_mm_fault(vma, address, fault_flags);
+	ret = handle_mm_fault(vma, address, fault_flags, range);
 	major |= ret & VM_FAULT_MAJOR;
 	if (ret & VM_FAULT_ERROR) {
 		if (ret & VM_FAULT_OOM)
@@ -759,6 +761,7 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 						struct page **pages,
 						struct vm_area_struct **vmas,
 						int *locked, bool notify_drop,
+						struct range_rwlock *range,
 						unsigned int flags)
 {
 	long ret, pages_done;
@@ -778,7 +781,7 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 	lock_dropped = false;
 	for (;;) {
 		ret = __get_user_pages(tsk, mm, start, nr_pages, flags, pages,
-				       vmas, locked);
+				       vmas, locked, range);
 		if (!locked)
 			/* VM_FAULT_RETRY couldn't trigger, bypass */
 			return ret;
@@ -818,7 +821,7 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 		lock_dropped = true;
 		down_read(&mm->mmap_sem);
 		ret = __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
-				       pages, NULL, NULL);
+				       pages, NULL, NULL, range);
 		if (ret != 1) {
 			BUG_ON(ret > 1);
 			if (!pages_done)
@@ -866,10 +869,10 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
  */
 long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 			   unsigned int gup_flags, struct page **pages,
-			   int *locked)
+			   int *locked, struct range_rwlock *range)
 {
 	return __get_user_pages_locked(current, current->mm, start, nr_pages,
-				       pages, NULL, locked, true,
+				       pages, NULL, locked, true, range,
 				       gup_flags | FOLL_TOUCH);
 }
 EXPORT_SYMBOL(get_user_pages_locked);
@@ -892,7 +895,7 @@ static __always_inline long __get_user_pages_unlocked(struct task_struct *tsk,
 
 	down_read(&mm->mmap_sem);
 	ret = __get_user_pages_locked(tsk, mm, start, nr_pages, pages, NULL,
-				      &locked, false, gup_flags);
+				      &locked, false, NULL, gup_flags);
 	if (locked)
 		up_read(&mm->mmap_sem);
 	return ret;
@@ -980,10 +983,11 @@ EXPORT_SYMBOL(get_user_pages_unlocked);
 long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas, int *locked)
+		struct vm_area_struct **vmas, int *locked,
+		struct range_rwlock *range)
 {
 	return __get_user_pages_locked(tsk, mm, start, nr_pages, pages, vmas,
-				       locked, true,
+				       locked, true, range,
 				       gup_flags | FOLL_TOUCH | FOLL_REMOTE);
 }
 EXPORT_SYMBOL(get_user_pages_remote);
@@ -997,10 +1001,10 @@ EXPORT_SYMBOL(get_user_pages_remote);
  */
 long get_user_pages(unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas)
+		struct vm_area_struct **vmas, struct range_rwlock *range)
 {
 	return __get_user_pages_locked(current, current->mm, start, nr_pages,
-				       pages, vmas, NULL, false,
+				       pages, vmas, NULL, false, range,
 				       gup_flags | FOLL_TOUCH);
 }
 EXPORT_SYMBOL(get_user_pages);
@@ -1025,7 +1029,8 @@ EXPORT_SYMBOL(get_user_pages);
  * released.  If it's released, *@nonblocking will be set to 0.
  */
 long populate_vma_page_range(struct vm_area_struct *vma,
-		unsigned long start, unsigned long end, int *nonblocking)
+		unsigned long start, unsigned long end, int *nonblocking,
+		struct range_rwlock *range)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long nr_pages = (end - start) / PAGE_SIZE;
@@ -1060,7 +1065,7 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 	 * not result in a stack expansion that recurses back here.
 	 */
 	return __get_user_pages(current, mm, start, nr_pages, gup_flags,
-				NULL, NULL, nonblocking);
+				NULL, NULL, nonblocking, range);
 }
 
 /*
@@ -1109,7 +1114,8 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 		 * double checks the vma flags, so that it won't mlock pages
 		 * if the vma was already munlocked.
 		 */
-		ret = populate_vma_page_range(vma, nstart, nend, &locked);
+		ret = populate_vma_page_range(vma, nstart, nend, &locked,
+					      NULL);
 		if (ret < 0) {
 			if (ignore_errors) {
 				ret = 0;
@@ -1147,7 +1153,7 @@ struct page *get_dump_page(unsigned long addr)
 
 	if (__get_user_pages(current, current->mm, addr, 1,
 			     FOLL_FORCE | FOLL_DUMP | FOLL_GET, &page, &vma,
-			     NULL) < 1)
+			     NULL, NULL) < 1)
 		return NULL;
 	flush_cache_page(vma, addr, page_to_pfn(page));
 	return page;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e5828875f7bb..f63e50975017 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4089,7 +4089,8 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			 struct page **pages, struct vm_area_struct **vmas,
 			 unsigned long *position, unsigned long *nr_pages,
-			 long i, unsigned int flags, int *nonblocking)
+			 long i, unsigned int flags, int *nonblocking,
+			 struct range_rwlock *range)
 {
 	unsigned long pfn_offset;
 	unsigned long vaddr = *position;
diff --git a/mm/internal.h b/mm/internal.h
index 266efaeaa370..dddb86c1a43b 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -278,7 +278,8 @@ void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
 
 #ifdef CONFIG_MMU
 extern long populate_vma_page_range(struct vm_area_struct *vma,
-		unsigned long start, unsigned long end, int *nonblocking);
+		unsigned long start, unsigned long end, int *nonblocking,
+		struct range_rwlock *range);
 extern void munlock_vma_pages_range(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end);
 static inline void munlock_vma_pages_all(struct vm_area_struct *vma)
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index ba40b7f673f4..d2b2a06f7853 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -875,7 +875,8 @@ static int hugepage_vma_revalidate(struct mm_struct *mm, unsigned long address,
 static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long address, pmd_t *pmd,
-					int referenced)
+					int referenced,
+					struct range_rwlock *range)
 {
 	int swapped_in = 0, ret = 0;
 	struct vm_fault vmf = {
@@ -884,6 +885,7 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 		.flags = FAULT_FLAG_ALLOW_RETRY,
 		.pmd = pmd,
 		.pgoff = linear_page_index(vma, address),
+		.lockrange = range,
 	};
 
 	/* we only decide to swapin, if there is enough young ptes */
@@ -928,7 +930,8 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 static void collapse_huge_page(struct mm_struct *mm,
 				   unsigned long address,
 				   struct page **hpage,
-				   int node, int referenced)
+				   int node, int referenced,
+				   struct range_rwlock *range)
 {
 	pmd_t *pmd, _pmd;
 	pte_t *pte;
@@ -986,7 +989,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * If it fails, we release mmap_sem and jump out_nolock.
 	 * Continuing to collapse causes inconsistency.
 	 */
-	if (!__collapse_huge_page_swapin(mm, vma, address, pmd, referenced)) {
+	if (!__collapse_huge_page_swapin(mm, vma, address, pmd, referenced,
+					 range)) {
 		mem_cgroup_cancel_charge(new_page, memcg, true);
 		up_read(&mm->mmap_sem);
 		goto out_nolock;
@@ -1093,7 +1097,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 static int khugepaged_scan_pmd(struct mm_struct *mm,
 			       struct vm_area_struct *vma,
 			       unsigned long address,
-			       struct page **hpage)
+			       struct page **hpage,
+			       struct range_rwlock *range)
 {
 	pmd_t *pmd;
 	pte_t *pte, *_pte;
@@ -1207,7 +1212,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 	if (ret) {
 		node = khugepaged_find_target_node();
 		/* collapse_huge_page will return with the mmap_sem released */
-		collapse_huge_page(mm, address, hpage, node, referenced);
+		collapse_huge_page(mm, address, hpage, node, referenced, range);
 	}
 out:
 	trace_mm_khugepaged_scan_pmd(mm, page, writable, referenced,
@@ -1728,7 +1733,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 			} else {
 				ret = khugepaged_scan_pmd(mm, vma,
 						khugepaged_scan.address,
-						hpage);
+						hpage, NULL);
 			}
 			/* move to next address */
 			khugepaged_scan.address += HPAGE_PMD_SIZE;
diff --git a/mm/ksm.c b/mm/ksm.c
index 19b4f2dea7a5..c419f53912ba 100644
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
diff --git a/mm/madvise.c b/mm/madvise.c
index 7a2abf0127ae..7eb62e3995ca 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -507,13 +507,14 @@ static long madvise_free(struct vm_area_struct *vma,
  */
 static long madvise_dontneed(struct vm_area_struct *vma,
 			     struct vm_area_struct **prev,
-			     unsigned long start, unsigned long end)
+			     unsigned long start, unsigned long end,
+			     struct range_rwlock *range)
 {
 	*prev = vma;
 	if (!can_madv_dontneed_vma(vma))
 		return -EINVAL;
 
-	if (!userfaultfd_remove(vma, start, end)) {
+	if (!userfaultfd_remove(vma, start, end, range)) {
 		*prev = NULL; /* mmap_sem has been dropped, prev is stale */
 
 		down_read(&current->mm->mmap_sem);
@@ -590,7 +591,7 @@ static long madvise_remove(struct vm_area_struct *vma,
 	 * mmap_sem.
 	 */
 	get_file(f);
-	if (userfaultfd_remove(vma, start, end)) {
+	if (userfaultfd_remove(vma, start, end, NULL) {
 		/* mmap_sem was not released by userfaultfd_remove() */
 		up_read(&current->mm->mmap_sem);
 	}
@@ -643,7 +644,8 @@ static int madvise_hwpoison(int bhv, unsigned long start, unsigned long end)
 
 static long
 madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
-		unsigned long start, unsigned long end, int behavior)
+	    unsigned long start, unsigned long end, int behavior,
+	    struct range_rwlock *range)
 {
 	switch (behavior) {
 	case MADV_REMOVE:
@@ -659,7 +661,7 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 			return madvise_free(vma, prev, start, end);
 		/* passthrough */
 	case MADV_DONTNEED:
-		return madvise_dontneed(vma, prev, start, end);
+		return madvise_dontneed(vma, prev, start, end, range);
 	default:
 		return madvise_behavior(vma, prev, start, end, behavior);
 	}
@@ -822,7 +824,7 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 			tmp = end;
 
 		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
-		error = madvise_vma(vma, &prev, start, tmp, behavior);
+		error = madvise_vma(vma, &prev, start, tmp, behavior, NULL);
 		if (error)
 			goto out;
 		start = tmp;
diff --git a/mm/memory.c b/mm/memory.c
index 235ba51b2fbf..745acb75b3b4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2732,7 +2732,8 @@ int do_swap_page(struct vm_fault *vmf)
 	}
 
 	swapcache = page;
-	locked = lock_page_or_retry(page, vma->vm_mm, vmf->flags);
+	locked = lock_page_or_retry(page, vma->vm_mm, vmf->flags,
+				    vmf->lockrange);
 
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 	if (!locked) {
@@ -3765,7 +3766,7 @@ static int handle_pte_fault(struct vm_fault *vmf)
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
 static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
-		unsigned int flags)
+		unsigned int flags, struct range_rwlock *range)
 {
 	struct vm_fault vmf = {
 		.vma = vma,
@@ -3773,6 +3774,7 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		.flags = flags,
 		.pgoff = linear_page_index(vma, address),
 		.gfp_mask = __get_fault_gfp_mask(vma),
+		.lockrange = range,
 	};
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgd;
@@ -3848,7 +3850,7 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
 int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
-		unsigned int flags)
+		unsigned int flags, struct range_rwlock *range)
 {
 	int ret;
 
@@ -3875,7 +3877,7 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		ret = hugetlb_fault(vma->vm_mm, vma, address, flags);
 	else
-		ret = __handle_mm_fault(vma, address, flags);
+		ret = __handle_mm_fault(vma, address, flags, range);
 
 	if (flags & FAULT_FLAG_USER) {
 		mem_cgroup_oom_disable();
@@ -4169,7 +4171,7 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
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
index bfbe8856d134..cd8fa7e74784 100644
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
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 8bcb501bce60..923a1ef22bc2 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -156,7 +156,8 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 					      unsigned long dst_start,
 					      unsigned long src_start,
 					      unsigned long len,
-					      bool zeropage)
+					      bool zeropage,
+					      struct range_rwlock *range)
 {
 	int vm_alloc_shared = dst_vma->vm_flags & VM_SHARED;
 	int vm_shared = dst_vma->vm_flags & VM_SHARED;
@@ -368,7 +369,8 @@ extern ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 				      unsigned long dst_start,
 				      unsigned long src_start,
 				      unsigned long len,
-				      bool zeropage);
+				      bool zeropage,
+				      struct range_rwlock *range);
 #endif /* CONFIG_HUGETLB_PAGE */
 
 static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
@@ -439,7 +441,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	 */
 	if (is_vm_hugetlb_page(dst_vma))
 		return  __mcopy_atomic_hugetlb(dst_mm, dst_vma, dst_start,
-						src_start, len, zeropage);
+					       src_start, len, zeropage, NULL);
 
 	if (!vma_is_anonymous(dst_vma) && !vma_is_shmem(dst_vma))
 		goto out_unlock;
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
index 88257b311cb5..43b8a01ac131 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1354,14 +1354,14 @@ static int get_user_page_nowait(unsigned long start, int write,
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
 
@@ -1458,7 +1458,8 @@ static bool vma_is_valid(struct vm_area_struct *vma, bool write_fault)
 
 static int hva_to_pfn_remapped(struct vm_area_struct *vma,
 			       unsigned long addr, bool *async,
-			       bool write_fault, kvm_pfn_t *p_pfn)
+			       bool write_fault, kvm_pfn_t *p_pfn,
+			       struct range_rwlock *range)
 {
 	unsigned long pfn;
 	int r;
@@ -1472,7 +1473,7 @@ static int hva_to_pfn_remapped(struct vm_area_struct *vma,
 		bool unlocked = false;
 		r = fixup_user_fault(current, current->mm, addr,
 				     (write_fault ? FAULT_FLAG_WRITE : 0),
-				     &unlocked);
+				     &unlocked, range);
 		if (unlocked)
 			return -EAGAIN;
 		if (r)
@@ -1549,7 +1550,8 @@ static kvm_pfn_t hva_to_pfn(unsigned long addr, bool atomic, bool *async,
 	if (vma == NULL)
 		pfn = KVM_PFN_ERR_FAULT;
 	else if (vma->vm_flags & (VM_IO | VM_PFNMAP)) {
-		r = hva_to_pfn_remapped(vma, addr, async, write_fault, &pfn);
+		r = hva_to_pfn_remapped(vma, addr, async, write_fault, &pfn,
+					NULL);
 		if (r == -EAGAIN)
 			goto retry;
 		if (r < 0)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
