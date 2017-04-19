Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 12BF56B03A8
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 08:18:45 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id z63so12507068ioz.23
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 05:18:45 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 74si2479727pga.211.2017.04.19.05.18.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 05:18:44 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3JCDoDe037971
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 08:18:43 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29x760sxtd-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 08:18:43 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 19 Apr 2017 13:18:39 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC 2/4] Deactivate mmap_sem assert
Date: Wed, 19 Apr 2017 14:18:25 +0200
In-Reply-To: <cover.1492595897.git.ldufour@linux.vnet.ibm.com>
References: <cover.1492595897.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1492595897.git.ldufour@linux.vnet.ibm.com>
References: <cover.1492595897.git.ldufour@linux.vnet.ibm.com>
Message-Id: <582009a3f9459de3d8def1e76db46e815ea6153c.1492595897.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, Paul.McKenney@us.ibm.com, linux-kernel@vger.kernel.org

When mmap_sem will be moved to a range lock, some assertion done in
the code are no more valid, like the one ensuring mmap_sem is held.

This patch should be reverted later and some check might be reviewed
once the range locking API provides dedicated services.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/x86/events/core.c  |  1 -
 fs/userfaultfd.c        |  6 ------
 include/linux/huge_mm.h |  2 --
 mm/gup.c                |  1 -
 mm/memory.c             | 12 +++---------
 mm/pagewalk.c           |  3 ---
 6 files changed, 3 insertions(+), 22 deletions(-)

diff --git a/arch/x86/events/core.c b/arch/x86/events/core.c
index 580b60f5ac83..86beb42376b8 100644
--- a/arch/x86/events/core.c
+++ b/arch/x86/events/core.c
@@ -2120,7 +2120,6 @@ static void x86_pmu_event_mapped(struct perf_event *event)
 	 * For now, this can't happen because all callers hold mmap_sem
 	 * for write.  If this changes, we'll need a different solution.
 	 */
-	lockdep_assert_held_exclusive(&current->mm->mmap_sem);
 
 	if (atomic_inc_return(&current->mm->context.perf_rdpmc_allowed) == 1)
 		on_each_cpu_mask(mm_cpumask(current->mm), refresh_pce, NULL, 1);
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index b83117741b11..5752b3b65638 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -222,8 +222,6 @@ static inline bool userfaultfd_huge_must_wait(struct userfaultfd_ctx *ctx,
 	pte_t *pte;
 	bool ret = true;
 
-	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
-
 	pte = huge_pte_offset(mm, address);
 	if (!pte)
 		goto out;
@@ -271,8 +269,6 @@ static inline bool userfaultfd_must_wait(struct userfaultfd_ctx *ctx,
 	pte_t *pte;
 	bool ret = true;
 
-	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
-
 	pgd = pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
 		goto out;
@@ -340,8 +336,6 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 	bool must_wait, return_to_userland;
 	long blocking_state;
 
-	BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
-
 	ret = VM_FAULT_SIGBUS;
 	ctx = vmf->vma->vm_userfaultfd_ctx.ctx;
 	if (!ctx)
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index a3762d49ba39..d400014892c7 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -161,7 +161,6 @@ extern spinlock_t *__pud_trans_huge_lock(pud_t *pud,
 static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
 		struct vm_area_struct *vma)
 {
-	VM_BUG_ON_VMA(!rwsem_is_locked(&vma->vm_mm->mmap_sem), vma);
 	if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd))
 		return __pmd_trans_huge_lock(pmd, vma);
 	else
@@ -170,7 +169,6 @@ static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
 static inline spinlock_t *pud_trans_huge_lock(pud_t *pud,
 		struct vm_area_struct *vma)
 {
-	VM_BUG_ON_VMA(!rwsem_is_locked(&vma->vm_mm->mmap_sem), vma);
 	if (pud_trans_huge(*pud) || pud_devmap(*pud))
 		return __pud_trans_huge_lock(pud, vma);
 	else
diff --git a/mm/gup.c b/mm/gup.c
index b83b47804c6e..ad83cfa38649 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1040,7 +1040,6 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 	VM_BUG_ON(end   & ~PAGE_MASK);
 	VM_BUG_ON_VMA(start < vma->vm_start, vma);
 	VM_BUG_ON_VMA(end   > vma->vm_end, vma);
-	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
 
 	gup_flags = FOLL_TOUCH | FOLL_POPULATE | FOLL_MLOCK;
 	if (vma->vm_flags & VM_LOCKONFAULT)
diff --git a/mm/memory.c b/mm/memory.c
index 745acb75b3b4..9adb7d4396bf 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1298,8 +1298,7 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 		next = pmd_addr_end(addr, end);
 		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE) {
-				VM_BUG_ON_VMA(vma_is_anonymous(vma) &&
-				    !rwsem_is_locked(&tlb->mm->mmap_sem), vma);
+				VM_BUG_ON_VMA(vma_is_anonymous(vma), vma);
 				__split_huge_pmd(vma, pmd, addr, false, NULL);
 			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
 				goto next;
@@ -1334,10 +1333,9 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
 	do {
 		next = pud_addr_end(addr, end);
 		if (pud_trans_huge(*pud) || pud_devmap(*pud)) {
-			if (next - addr != HPAGE_PUD_SIZE) {
-				VM_BUG_ON_VMA(!rwsem_is_locked(&tlb->mm->mmap_sem), vma);
+			if (next - addr != HPAGE_PUD_SIZE)
 				split_huge_pud(vma, pud, addr);
-			} else if (zap_huge_pud(tlb, vma, pud, addr))
+			else if (zap_huge_pud(tlb, vma, pud, addr))
 				goto next;
 			/* fall through */
 		}
@@ -4305,10 +4303,6 @@ void __might_fault(const char *file, int line)
 	if (pagefault_disabled())
 		return;
 	__might_sleep(file, line, 0);
-#if defined(CONFIG_DEBUG_ATOMIC_SLEEP)
-	if (current->mm)
-		might_lock_read(&current->mm->mmap_sem);
-#endif
 }
 EXPORT_SYMBOL(__might_fault);
 #endif
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 60f7856e508f..13429c7815c9 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -293,8 +293,6 @@ int walk_page_range(unsigned long start, unsigned long end,
 	if (!walk->mm)
 		return -EINVAL;
 
-	VM_BUG_ON_MM(!rwsem_is_locked(&walk->mm->mmap_sem), walk->mm);
-
 	vma = find_vma(walk->mm, start);
 	do {
 		if (!vma) { /* after the last vma */
@@ -336,7 +334,6 @@ int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk)
 	if (!walk->mm)
 		return -EINVAL;
 
-	VM_BUG_ON(!rwsem_is_locked(&walk->mm->mmap_sem));
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
