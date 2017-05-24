Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 173906B02F3
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:16 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p74so192409982pfd.11
        for <linux-mm@kvack.org>; Wed, 24 May 2017 04:20:16 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 82si5616530pga.93.2017.05.24.04.20.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 04:20:15 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4OB9mhI050877
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:14 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2an2gfa1h9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:14 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 24 May 2017 12:20:11 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v2 01/10] mm: Deactivate mmap_sem assert
Date: Wed, 24 May 2017 13:19:52 +0200
In-Reply-To: <1495624801-8063-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1495624801-8063-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1495624801-8063-2-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, Andi Kleen <andi@firstfloor.org>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

When mmap_sem will be moved to a range lock, some assertion done in
the code will have to be reviewed to work with the range locking as
well.

This patch disables these assertions for the moment but it has be
reviewed later once the range locking API will provide the dedicated
services.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/powerpc/platforms/powernv/npu-dma.c | 2 ++
 arch/x86/events/core.c                   | 2 ++
 fs/userfaultfd.c                         | 6 ++++++
 include/linux/huge_mm.h                  | 4 ++++
 mm/gup.c                                 | 2 ++
 mm/memory.c                              | 7 ++++++-
 mm/pagewalk.c                            | 5 +++++
 7 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/platforms/powernv/npu-dma.c b/arch/powerpc/platforms/powernv/npu-dma.c
index 067defeea691..e75f1c1911c6 100644
--- a/arch/powerpc/platforms/powernv/npu-dma.c
+++ b/arch/powerpc/platforms/powernv/npu-dma.c
@@ -756,7 +756,9 @@ int pnv_npu2_handle_fault(struct npu_context *context, uintptr_t *ea,
 	if (!firmware_has_feature(FW_FEATURE_OPAL))
 		return -ENODEV;
 
+#ifndef CONFIG_MEM_RANGE_LOCK
 	WARN_ON(!rwsem_is_locked(&mm->mmap_sem));
+#endif
 
 	for (i = 0; i < count; i++) {
 		is_write = flags[i] & NPU2_WRITE;
diff --git a/arch/x86/events/core.c b/arch/x86/events/core.c
index 580b60f5ac83..807f6873d292 100644
--- a/arch/x86/events/core.c
+++ b/arch/x86/events/core.c
@@ -2120,7 +2120,9 @@ static void x86_pmu_event_mapped(struct perf_event *event)
 	 * For now, this can't happen because all callers hold mmap_sem
 	 * for write.  If this changes, we'll need a different solution.
 	 */
+#ifndef CONFIG_MEM_RANGE_LOCK
 	lockdep_assert_held_exclusive(&current->mm->mmap_sem);
+#endif
 
 	if (atomic_inc_return(&current->mm->context.perf_rdpmc_allowed) == 1)
 		on_each_cpu_mask(mm_cpumask(current->mm), refresh_pce, NULL, 1);
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index f7555fc25877..b3daffc589a2 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -222,7 +222,9 @@ static inline bool userfaultfd_huge_must_wait(struct userfaultfd_ctx *ctx,
 	pte_t *pte;
 	bool ret = true;
 
+#ifndef CONFIG_MEM_RANGE_LOCK
 	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
+#endif
 
 	pte = huge_pte_offset(mm, address);
 	if (!pte)
@@ -271,7 +273,9 @@ static inline bool userfaultfd_must_wait(struct userfaultfd_ctx *ctx,
 	pte_t *pte;
 	bool ret = true;
 
+#ifndef CONFIG_MEM_RANGE_LOCK
 	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
+#endif
 
 	pgd = pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
@@ -340,7 +344,9 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 	bool must_wait, return_to_userland;
 	long blocking_state;
 
+#ifndef CONFIG_MEM_RANGE_LOCK
 	BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
+#endif
 
 	ret = VM_FAULT_SIGBUS;
 	ctx = vmf->vma->vm_userfaultfd_ctx.ctx;
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index a3762d49ba39..0733dfc93d39 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -161,7 +161,9 @@ extern spinlock_t *__pud_trans_huge_lock(pud_t *pud,
 static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
 		struct vm_area_struct *vma)
 {
+#ifndef CONFIG_MEM_RANGE_LOCK
 	VM_BUG_ON_VMA(!rwsem_is_locked(&vma->vm_mm->mmap_sem), vma);
+#endif
 	if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd))
 		return __pmd_trans_huge_lock(pmd, vma);
 	else
@@ -170,7 +172,9 @@ static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
 static inline spinlock_t *pud_trans_huge_lock(pud_t *pud,
 		struct vm_area_struct *vma)
 {
+#ifndef CONFIG_MEM_RANGE_LOCK
 	VM_BUG_ON_VMA(!rwsem_is_locked(&vma->vm_mm->mmap_sem), vma);
+#endif
 	if (pud_trans_huge(*pud) || pud_devmap(*pud))
 		return __pud_trans_huge_lock(pud, vma);
 	else
diff --git a/mm/gup.c b/mm/gup.c
index d9e6fddcc51f..0f81ac1a9881 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1035,7 +1035,9 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 	VM_BUG_ON(end   & ~PAGE_MASK);
 	VM_BUG_ON_VMA(start < vma->vm_start, vma);
 	VM_BUG_ON_VMA(end   > vma->vm_end, vma);
+#ifndef CONFIG_MEM_RANGE_LOCK
 	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
+#endif
 
 	gup_flags = FOLL_TOUCH | FOLL_POPULATE | FOLL_MLOCK;
 	if (vma->vm_flags & VM_LOCKONFAULT)
diff --git a/mm/memory.c b/mm/memory.c
index 6ff5d729ded0..aa080e9814d4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1298,8 +1298,11 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 		next = pmd_addr_end(addr, end);
 		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE) {
+#ifndef CONFIG_MEM_RANGE_LOCK
 				VM_BUG_ON_VMA(vma_is_anonymous(vma) &&
 				    !rwsem_is_locked(&tlb->mm->mmap_sem), vma);
+#endif
+				VM_BUG_ON_VMA(vma_is_anonymous(vma), vma);
 				__split_huge_pmd(vma, pmd, addr, false, NULL);
 			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
 				goto next;
@@ -1335,7 +1338,9 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
 		next = pud_addr_end(addr, end);
 		if (pud_trans_huge(*pud) || pud_devmap(*pud)) {
 			if (next - addr != HPAGE_PUD_SIZE) {
+#ifndef CONFIG_MEM_RANGE_LOCK
 				VM_BUG_ON_VMA(!rwsem_is_locked(&tlb->mm->mmap_sem), vma);
+#endif
 				split_huge_pud(vma, pud, addr);
 			} else if (zap_huge_pud(tlb, vma, pud, addr))
 				goto next;
@@ -4303,7 +4308,7 @@ void __might_fault(const char *file, int line)
 	if (pagefault_disabled())
 		return;
 	__might_sleep(file, line, 0);
-#if defined(CONFIG_DEBUG_ATOMIC_SLEEP)
+#if defined(CONFIG_DEBUG_ATOMIC_SLEEP) && !defined(CONFIG_MEM_RANGE_LOCK)
 	if (current->mm)
 		might_lock_read(&current->mm->mmap_sem);
 #endif
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 60f7856e508f..0ff224cfd52b 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -293,7 +293,9 @@ int walk_page_range(unsigned long start, unsigned long end,
 	if (!walk->mm)
 		return -EINVAL;
 
+#ifndef CONFIG_MEM_RANGE_LOCK
 	VM_BUG_ON_MM(!rwsem_is_locked(&walk->mm->mmap_sem), walk->mm);
+#endif
 
 	vma = find_vma(walk->mm, start);
 	do {
@@ -336,7 +338,10 @@ int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk)
 	if (!walk->mm)
 		return -EINVAL;
 
+#ifndef CONFIG_MEM_RANGE_LOCK
 	VM_BUG_ON(!rwsem_is_locked(&walk->mm->mmap_sem));
+#endif
+
 	VM_BUG_ON(!vma);
 	walk->vma = vma;
 	err = walk_page_test(vma->vm_start, vma->vm_end, walk);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
