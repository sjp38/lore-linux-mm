Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 325D96B0034
	for <linux-mm@kvack.org>; Thu, 23 May 2013 13:08:12 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id e11so2172108wgh.26
        for <linux-mm@kvack.org>; Thu, 23 May 2013 10:08:10 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [PATCH 01/11] mm: hugetlb: Copy huge_pmd_share from x86 to mm.
Date: Thu, 23 May 2013 18:07:48 +0100
Message-Id: <1369328878-11706-2-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1369328878-11706-1-git-send-email-steve.capper@linaro.org>
References: <1369328878-11706-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, patches@linaro.org, Steve Capper <steve.capper@linaro.org>

Under x86, multiple puds can be made to reference the same bank of
huge pmds provided that they represent a full PUD_SIZE of shared
huge memory that is aligned to a PUD_SIZE boundary.

The code to share pmds does not require any architecture specific
knowledge other than the fact that pmds can be indexed, thus can
be beneficial to some other architectures.

This patch copies the huge pmd sharing (and unsharing) logic from
x86/ to mm/ and introduces a new config option to activate it:
CONFIG_ARCH_WANTS_HUGE_PMD_SHARE

Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
 include/linux/hugetlb.h |   4 ++
 mm/hugetlb.c            | 122 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 126 insertions(+)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 6b4890f..981546a 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -69,6 +69,10 @@ void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
 int dequeue_hwpoisoned_huge_page(struct page *page);
 void copy_huge_page(struct page *dst, struct page *src);
 
+#ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
+pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud);
+#endif
+
 extern unsigned long hugepages_treat_as_movable;
 extern const unsigned long hugetlb_zero, hugetlb_infinity;
 extern int sysctl_hugetlb_shm_group;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index f8feeec..b0bfb29 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3169,6 +3169,128 @@ void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
 	hugetlb_acct_memory(h, -(chg - freed));
 }
 
+#ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
+static unsigned long page_table_shareable(struct vm_area_struct *svma,
+				struct vm_area_struct *vma,
+				unsigned long addr, pgoff_t idx)
+{
+	unsigned long saddr = ((idx - svma->vm_pgoff) << PAGE_SHIFT) +
+				svma->vm_start;
+	unsigned long sbase = saddr & PUD_MASK;
+	unsigned long s_end = sbase + PUD_SIZE;
+
+	/* Allow segments to share if only one is marked locked */
+	unsigned long vm_flags = vma->vm_flags & ~VM_LOCKED;
+	unsigned long svm_flags = svma->vm_flags & ~VM_LOCKED;
+
+	/*
+	 * match the virtual addresses, permission and the alignment of the
+	 * page table page.
+	 */
+	if (pmd_index(addr) != pmd_index(saddr) ||
+	    vm_flags != svm_flags ||
+	    sbase < svma->vm_start || svma->vm_end < s_end)
+		return 0;
+
+	return saddr;
+}
+
+static int vma_shareable(struct vm_area_struct *vma, unsigned long addr)
+{
+	unsigned long base = addr & PUD_MASK;
+	unsigned long end = base + PUD_SIZE;
+
+	/*
+	 * check on proper vm_flags and page table alignment
+	 */
+	if (vma->vm_flags & VM_MAYSHARE &&
+	    vma->vm_start <= base && end <= vma->vm_end)
+		return 1;
+	return 0;
+}
+
+/*
+ * Search for a shareable pmd page for hugetlb. In any case calls pmd_alloc()
+ * and returns the corresponding pte. While this is not necessary for the
+ * !shared pmd case because we can allocate the pmd later as well, it makes the
+ * code much cleaner. pmd allocation is essential for the shared case because
+ * pud has to be populated inside the same i_mmap_mutex section - otherwise
+ * racing tasks could either miss the sharing (see huge_pte_offset) or select a
+ * bad pmd for sharing.
+ */
+pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
+{
+	struct vm_area_struct *vma = find_vma(mm, addr);
+	struct address_space *mapping = vma->vm_file->f_mapping;
+	pgoff_t idx = ((addr - vma->vm_start) >> PAGE_SHIFT) +
+			vma->vm_pgoff;
+	struct vm_area_struct *svma;
+	unsigned long saddr;
+	pte_t *spte = NULL;
+	pte_t *pte;
+
+	if (!vma_shareable(vma, addr))
+		return (pte_t *)pmd_alloc(mm, pud, addr);
+
+	mutex_lock(&mapping->i_mmap_mutex);
+	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
+		if (svma == vma)
+			continue;
+
+		saddr = page_table_shareable(svma, vma, addr, idx);
+		if (saddr) {
+			spte = huge_pte_offset(svma->vm_mm, saddr);
+			if (spte) {
+				get_page(virt_to_page(spte));
+				break;
+			}
+		}
+	}
+
+	if (!spte)
+		goto out;
+
+	spin_lock(&mm->page_table_lock);
+	if (pud_none(*pud))
+		pud_populate(mm, pud,
+				(pmd_t *)((unsigned long)spte & PAGE_MASK));
+	else
+		put_page(virt_to_page(spte));
+	spin_unlock(&mm->page_table_lock);
+out:
+	pte = (pte_t *)pmd_alloc(mm, pud, addr);
+	mutex_unlock(&mapping->i_mmap_mutex);
+	return pte;
+}
+
+/*
+ * unmap huge page backed by shared pte.
+ *
+ * Hugetlb pte page is ref counted at the time of mapping.  If pte is shared
+ * indicated by page_count > 1, unmap is achieved by clearing pud and
+ * decrementing the ref count. If count == 1, the pte page is not shared.
+ *
+ * called with vma->vm_mm->page_table_lock held.
+ *
+ * returns: 1 successfully unmapped a shared pte page
+ *	    0 the underlying pte page is not shared, or it is the last user
+ */
+int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
+{
+	pgd_t *pgd = pgd_offset(mm, *addr);
+	pud_t *pud = pud_offset(pgd, *addr);
+
+	BUG_ON(page_count(virt_to_page(ptep)) == 0);
+	if (page_count(virt_to_page(ptep)) == 1)
+		return 0;
+
+	pud_clear(pud);
+	put_page(virt_to_page(ptep));
+	*addr = ALIGN(*addr, HPAGE_SIZE * PTRS_PER_PTE) - HPAGE_SIZE;
+	return 1;
+}
+#endif /* CONFIG_ARCH_WANT_HUGE_PMD_SHARE */
+
 #ifdef CONFIG_MEMORY_FAILURE
 
 /* Should be called in hugetlb_lock */
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
