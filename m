Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 340826B026D
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 13:36:09 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id k201so69987432qke.6
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:36:09 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 34si3812984qtg.305.2016.12.16.10.36.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 10:36:08 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 11/14] sparc64: add routines to look for vmsa which can share context
Date: Fri, 16 Dec 2016 10:35:34 -0800
Message-Id: <1481913337-9331-12-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "David S . Miller" <davem@davemloft.net>, Bob Picco <bob.picco@oracle.com>, Nitin Gupta <nitin.m.gupta@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, Julian Calaby <julian.calaby@gmail.com>, Adam Buchbinder <adam.buchbinder@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

When a shared context mapping is requested, a search of the other
vmas mapping the same object is searched.  For simplicity, vmas
can only share context if the following is true:
- They both request shared context mapping
- The are at the same virtual address
- They are of the same size
In addition, a task is only allowed to have a single vma with shared
context.

Some of these contstraints can be relaxed at a later date.  They
make the code simpler for now.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 arch/sparc/include/asm/mmu_context_64.h |  1 +
 arch/sparc/include/asm/page_64.h        |  1 +
 arch/sparc/mm/hugetlbpage.c             | 78 ++++++++++++++++++++++++++++++++-
 arch/sparc/mm/init_64.c                 | 19 ++++++++
 mm/hugetlb.c                            |  9 ++++
 5 files changed, 106 insertions(+), 2 deletions(-)

diff --git a/arch/sparc/include/asm/mmu_context_64.h b/arch/sparc/include/asm/mmu_context_64.h
index 0dc95cb5..46c2c7e 100644
--- a/arch/sparc/include/asm/mmu_context_64.h
+++ b/arch/sparc/include/asm/mmu_context_64.h
@@ -23,6 +23,7 @@ void get_new_mmu_shared_context(struct mm_struct *mm);
 void put_shared_context(struct mm_struct *mm);
 void set_mm_shared_ctx(struct mm_struct *mm, struct shared_mmu_ctx *ctx);
 void destroy_shared_context(struct mm_struct *mm);
+void set_vma_shared_ctx(struct vm_area_struct *vma);
 #endif
 #ifdef CONFIG_SMP
 void smp_new_mmu_context_version(void);
diff --git a/arch/sparc/include/asm/page_64.h b/arch/sparc/include/asm/page_64.h
index c1263fc..ccceb76 100644
--- a/arch/sparc/include/asm/page_64.h
+++ b/arch/sparc/include/asm/page_64.h
@@ -33,6 +33,7 @@
 #if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 struct pt_regs;
 void hugetlb_setup(struct pt_regs *regs);
+void hugetlb_shared_setup(struct pt_regs *regs);
 #endif
 
 #define WANT_PAGE_VIRTUAL
diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
index 2039d45..5681df6 100644
--- a/arch/sparc/mm/hugetlbpage.c
+++ b/arch/sparc/mm/hugetlbpage.c
@@ -127,6 +127,80 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 				pgoff, flags);
 }
 
+#if defined(CONFIG_SHARED_MMU_CTX)
+static bool huge_vma_can_share_ctx(struct vm_area_struct *vma,
+					struct vm_area_struct *tvma)
+{
+	/*
+	 * Do not match unless there is an actual context value.  It
+	 * could be the case that tvma is a new mapping with VM_SHARED_CTX
+	 * set, but still not associated with a shared context ID.
+	 */
+	if (!vma_shared_ctx_val(tvma))
+		return false;
+
+	/*
+	 * For simple functionality now, vmas must be exactly the same
+	 */
+	if ((vma->vm_flags & VM_LOCKED_CLEAR_MASK) ==
+	    (tvma->vm_flags & VM_LOCKED_CLEAR_MASK) &&
+	    vma->vm_pgoff == tvma->vm_pgoff &&
+	    vma->vm_start == tvma->vm_start &&
+	    vma->vm_end == tvma->vm_end)
+		return true;
+
+	return false;
+}
+
+/*
+ * If vma is marked as desiring shared contexxt, search for a context to
+ * share.  If no context found, assign one.
+ */
+void huge_get_shared_ctx(struct mm_struct *mm, unsigned long addr)
+{
+	struct vm_area_struct *vma = find_vma(mm, addr);
+	struct address_space *mapping = vma->vm_file->f_mapping;
+	pgoff_t idx = ((addr - vma->vm_start) >> PAGE_SHIFT) +
+			vma->vm_pgoff;
+	struct vm_area_struct *tvma;
+
+	/*
+	 * FIXME
+	 *
+	 * For now limit a task to a single shared context mapping
+	 */
+	if (!(vma->vm_flags & VM_SHARED_CTX) || vma_shared_ctx_val(vma) ||
+	    mm_shared_ctx_val(mm))
+		return;
+
+	i_mmap_lock_write(mapping);
+	vma_interval_tree_foreach(tvma, &mapping->i_mmap, idx, idx) {
+		if (tvma == vma)
+			continue;
+
+		if (huge_vma_can_share_ctx(vma, tvma)) {
+			set_mm_shared_ctx(mm, tvma->vm_shared_mmu_ctx.ctx);
+			set_vma_shared_ctx(vma);
+			if (likely(mm_shared_ctx_val(mm))) {
+				load_secondary_context(mm);
+				/*
+				 * What about multiple matches ?
+				 */
+				break;
+			}
+		}
+	}
+
+	if (!mm_shared_ctx_val(mm)) {
+		get_new_mmu_shared_context(mm);
+		set_vma_shared_ctx(vma);
+		load_secondary_context(mm);
+	}
+
+	i_mmap_unlock_write(mapping);
+}
+#endif
+
 pte_t *huge_pte_alloc(struct mm_struct *mm,
 			unsigned long addr, unsigned long sz)
 {
@@ -164,7 +238,7 @@ void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 
 	if (!pte_present(*ptep) && pte_present(entry)) {
 #if defined(CONFIG_SHARED_MMU_CTX)
-		if (pte_val(entry) | _PAGE_SHR_CTX_4V)
+		if (is_sharedctx_pte(entry))
 			mm->context.shared_hugetlb_pte_count++;
 		else
 #endif
@@ -188,7 +262,7 @@ pte_t huge_ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
 	entry = *ptep;
 	if (pte_present(entry)) {
 #if defined(CONFIG_SHARED_MMU_CTX)
-		if (pte_val(entry) | _PAGE_SHR_CTX_4V)
+		if (is_sharedctx_pte(entry))
 			mm->context.shared_hugetlb_pte_count--;
 		else
 #endif
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 2b310e5..25ad5bd 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -813,6 +813,25 @@ void set_mm_shared_ctx(struct mm_struct *mm, struct shared_mmu_ctx *ctx)
 	atomic_inc(&ctx->refcount);
 	mm->context.shared_ctx = ctx;
 }
+
+/*
+ * Set the shared context value in the vma to that in the mm.
+ *
+ *
+ * Note that we are called from mmap with mmap_sem held.
+ */
+void set_vma_shared_ctx(struct vm_area_struct *vma)
+{
+	struct mm_struct *mm = vma->vm_mm;
+
+	BUG_ON(vma->vm_shared_mmu_ctx.ctx);
+
+	if (!mm_shared_ctx_val(mm))
+		return;
+
+	atomic_inc(&mm->context.shared_ctx->refcount);
+	vma->vm_shared_mmu_ctx.ctx = mm->context.shared_ctx;
+}
 #endif
 
 static int numa_enabled = 1;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 418bf01..3733ba1 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3150,6 +3150,15 @@ static pte_t make_huge_pte(struct vm_area_struct *vma, struct page *page,
 	entry = pte_mkhuge(entry);
 	entry = arch_make_huge_pte(entry, vma, page, writable);
 
+#if defined(CONFIG_SHARED_MMU_CTX)
+	/*
+	 * FIXME
+	 * needs arch independent way of setting - perhaps arch_make_huge_pte
+	 */
+	if (vma->vm_flags & VM_SHARED_CTX)
+		pte_val(entry) |= _PAGE_SHR_CTX_4V;
+#endif
+
 	return entry;
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
