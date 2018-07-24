Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E259D6B0269
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 08:11:43 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 31-v6so2803988pld.6
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 05:11:43 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id x3-v6si12443279pfj.289.2018.07.24.05.11.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 05:11:42 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 2/3] mm: Use vma_init() to initialize VMAs on stack and data segments
Date: Tue, 24 Jul 2018 15:11:38 +0300
Message-Id: <20180724121139.62570-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180724121139.62570-1-kirill.shutemov@linux.intel.com>
References: <20180724121139.62570-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Make sure to initialize all VMAs properly, not only which comes from
vm_area_cachep.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/arm/kernel/process.c    | 1 +
 arch/arm/mach-rpc/ecard.c    | 2 +-
 arch/arm64/include/asm/tlb.h | 4 +++-
 arch/arm64/mm/hugetlbpage.c  | 7 +++++--
 arch/ia64/include/asm/tlb.h  | 2 +-
 arch/ia64/mm/init.c          | 2 +-
 arch/x86/um/mem_32.c         | 2 +-
 fs/hugetlbfs/inode.c         | 2 ++
 mm/mempolicy.c               | 1 +
 mm/shmem.c                   | 1 +
 10 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/arch/arm/kernel/process.c b/arch/arm/kernel/process.c
index 225d1c58d2de..d9c299133111 100644
--- a/arch/arm/kernel/process.c
+++ b/arch/arm/kernel/process.c
@@ -338,6 +338,7 @@ static struct vm_area_struct gate_vma = {
 
 static int __init gate_vma_init(void)
 {
+	vma_init(&gate_vma, NULL);
 	gate_vma.vm_page_prot = PAGE_READONLY_EXEC;
 	return 0;
 }
diff --git a/arch/arm/mach-rpc/ecard.c b/arch/arm/mach-rpc/ecard.c
index 39aef4876ed4..8db62cc54a6a 100644
--- a/arch/arm/mach-rpc/ecard.c
+++ b/arch/arm/mach-rpc/ecard.c
@@ -237,8 +237,8 @@ static void ecard_init_pgtables(struct mm_struct *mm)
 
 	memcpy(dst_pgd, src_pgd, sizeof(pgd_t) * (EASI_SIZE / PGDIR_SIZE));
 
+	vma_init(&vma, mm);
 	vma.vm_flags = VM_EXEC;
-	vma.vm_mm = mm;
 
 	flush_tlb_range(&vma, IO_START, IO_START + IO_SIZE);
 	flush_tlb_range(&vma, EASI_START, EASI_START + EASI_SIZE);
diff --git a/arch/arm64/include/asm/tlb.h b/arch/arm64/include/asm/tlb.h
index ffdaea7954bb..d87f2d646caa 100644
--- a/arch/arm64/include/asm/tlb.h
+++ b/arch/arm64/include/asm/tlb.h
@@ -37,7 +37,9 @@ static inline void __tlb_remove_table(void *_table)
 
 static inline void tlb_flush(struct mmu_gather *tlb)
 {
-	struct vm_area_struct vma = { .vm_mm = tlb->mm, };
+	struct vm_area_struct vma;
+
+	vma_init(&vma, tlb->mm);
 
 	/*
 	 * The ASID allocator will either invalidate the ASID or mark
diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index ecc6818191df..1854e49aa18a 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -108,11 +108,13 @@ static pte_t get_clear_flush(struct mm_struct *mm,
 			     unsigned long pgsize,
 			     unsigned long ncontig)
 {
-	struct vm_area_struct vma = { .vm_mm = mm };
+	struct vm_area_struct vma;
 	pte_t orig_pte = huge_ptep_get(ptep);
 	bool valid = pte_valid(orig_pte);
 	unsigned long i, saddr = addr;
 
+	vma_init(&vma, mm);
+
 	for (i = 0; i < ncontig; i++, addr += pgsize, ptep++) {
 		pte_t pte = ptep_get_and_clear(mm, addr, ptep);
 
@@ -145,9 +147,10 @@ static void clear_flush(struct mm_struct *mm,
 			     unsigned long pgsize,
 			     unsigned long ncontig)
 {
-	struct vm_area_struct vma = { .vm_mm = mm };
+	struct vm_area_struct vma;
 	unsigned long i, saddr = addr;
 
+	vma_init(&vma, mm);
 	for (i = 0; i < ncontig; i++, addr += pgsize, ptep++)
 		pte_clear(mm, addr, ptep);
 
diff --git a/arch/ia64/include/asm/tlb.h b/arch/ia64/include/asm/tlb.h
index 44f0ac0df308..db89e7306081 100644
--- a/arch/ia64/include/asm/tlb.h
+++ b/arch/ia64/include/asm/tlb.h
@@ -120,7 +120,7 @@ ia64_tlb_flush_mmu_tlbonly(struct mmu_gather *tlb, unsigned long start, unsigned
 		 */
 		struct vm_area_struct vma;
 
-		vma.vm_mm = tlb->mm;
+		vma_init(&vma, tlb->mm);
 		/* flush the address range from the tlb: */
 		flush_tlb_range(&vma, start, end);
 		/* now flush the virt. page-table area mapping the address range: */
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index bdb14a369137..e6c6dfd98de2 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -273,7 +273,7 @@ static struct vm_area_struct gate_vma;
 
 static int __init gate_vma_init(void)
 {
-	gate_vma.vm_mm = NULL;
+	vma_init(&gate_vma, NULL);
 	gate_vma.vm_start = FIXADDR_USER_START;
 	gate_vma.vm_end = FIXADDR_USER_END;
 	gate_vma.vm_flags = VM_READ | VM_MAYREAD | VM_EXEC | VM_MAYEXEC;
diff --git a/arch/x86/um/mem_32.c b/arch/x86/um/mem_32.c
index 744afdc18cf3..56c44d865f7b 100644
--- a/arch/x86/um/mem_32.c
+++ b/arch/x86/um/mem_32.c
@@ -16,7 +16,7 @@ static int __init gate_vma_init(void)
 	if (!FIXADDR_USER_START)
 		return 0;
 
-	gate_vma.vm_mm = NULL;
+	vma_init(&gate_vma, NULL);
 	gate_vma.vm_start = FIXADDR_USER_START;
 	gate_vma.vm_end = FIXADDR_USER_END;
 	gate_vma.vm_flags = VM_READ | VM_MAYREAD | VM_EXEC | VM_MAYEXEC;
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index d508c7844681..40d4c66c7751 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -411,6 +411,7 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 	bool truncate_op = (lend == LLONG_MAX);
 
 	memset(&pseudo_vma, 0, sizeof(struct vm_area_struct));
+	vma_init(&pseudo_vma, current->mm);
 	pseudo_vma.vm_flags = (VM_HUGETLB | VM_MAYSHARE | VM_SHARED);
 	pagevec_init(&pvec);
 	next = start;
@@ -595,6 +596,7 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 	 * as input to create an allocation policy.
 	 */
 	memset(&pseudo_vma, 0, sizeof(struct vm_area_struct));
+	vma_init(&pseudo_vma, mm);
 	pseudo_vma.vm_flags = (VM_HUGETLB | VM_MAYSHARE | VM_SHARED);
 	pseudo_vma.vm_file = file;
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 9ac49ef17b4e..01f1a14facc4 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2505,6 +2505,7 @@ void mpol_shared_policy_init(struct shared_policy *sp, struct mempolicy *mpol)
 
 		/* Create pseudo-vma that contains just the policy */
 		memset(&pvma, 0, sizeof(struct vm_area_struct));
+		vma_init(&pvma, NULL);
 		pvma.vm_end = TASK_SIZE;	/* policy covers entire file */
 		mpol_set_shared_policy(sp, &pvma, new); /* adds ref */
 
diff --git a/mm/shmem.c b/mm/shmem.c
index 2cab84403055..41b9bbf24e16 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1421,6 +1421,7 @@ static void shmem_pseudo_vma_init(struct vm_area_struct *vma,
 {
 	/* Create a pseudo vma that just contains the policy */
 	memset(vma, 0, sizeof(*vma));
+	vma_init(vma, NULL);
 	/* Bias interleave by inode number to distribute better across nodes */
 	vma->vm_pgoff = index + info->vfs_inode.i_ino;
 	vma->vm_policy = mpol_shared_policy_lookup(&info->policy, index);
-- 
2.18.0
