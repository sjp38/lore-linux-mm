Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1A5776B0008
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 13:30:21 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id do7so285381pab.2
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 10:30:21 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id kp14si37265756pab.99.2016.01.05.10.30.14
        for <linux-mm@kvack.org>;
        Tue, 05 Jan 2016 10:30:14 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v2 3/8] mm: Add optional support for PUD-sized transparent hugepages
Date: Tue,  5 Jan 2016 13:30:05 -0500
Message-Id: <1452018610-26090-4-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1452018610-26090-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1452018610-26090-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

From: Matthew Wilcox <willy@linux.intel.com>

The current transparent hugepage code only supports PMDs.  This patch
adds support for transparent use of PUDs with DAX.  It does not include
support for anonymous pages.

Most of this patch simply parallels the work that was done for huge PMDs.
The only major difference is how the new ->pud_entry method in mm_walk
works.  The ->pmd_entry method replaces the ->pte_entry method, whereas
the ->pud_entry method works along with either ->pmd_entry or ->pte_entry.
The pagewalk code takes care of locking the PUD before calling ->pud_walk,
so handlers do not need to worry whether the PUD is stable.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 arch/Kconfig                  |   3 +
 include/asm-generic/pgtable.h |  62 +++++++++++++++--
 include/asm-generic/tlb.h     |  14 ++++
 include/linux/huge_mm.h       |  52 ++++++++++++++-
 include/linux/mm.h            |  30 +++++++++
 include/linux/mmu_notifier.h  |  13 ++++
 mm/huge_memory.c              | 151 ++++++++++++++++++++++++++++++++++++++++++
 mm/memory.c                   |  71 ++++++++++++++++++++
 mm/pagewalk.c                 |  19 +++++-
 mm/pgtable-generic.c          |  14 ++++
 10 files changed, 423 insertions(+), 6 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index dc5e0f2..3864ad8 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -462,6 +462,9 @@ config HAVE_IRQ_TIME_ACCOUNTING
 config HAVE_ARCH_TRANSPARENT_HUGEPAGE
 	bool
 
+config HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+	bool
+
 config HAVE_ARCH_HUGE_VMAP
 	bool
 
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 5459a66..9ea433a 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -36,6 +36,9 @@ extern int ptep_set_access_flags(struct vm_area_struct *vma,
 extern int pmdp_set_access_flags(struct vm_area_struct *vma,
 				 unsigned long address, pmd_t *pmdp,
 				 pmd_t entry, int dirty);
+extern int pudp_set_access_flags(struct vm_area_struct *vma,
+				 unsigned long address, pud_t *pudp,
+				 pud_t entry, int dirty);
 #else
 static inline int pmdp_set_access_flags(struct vm_area_struct *vma,
 					unsigned long address, pmd_t *pmdp,
@@ -44,6 +47,13 @@ static inline int pmdp_set_access_flags(struct vm_area_struct *vma,
 	BUILD_BUG();
 	return 0;
 }
+static inline int pudp_set_access_flags(struct vm_area_struct *vma,
+					unsigned long address, pud_t *pudp,
+					pud_t entry, int dirty)
+{
+	BUILD_BUG();
+	return 0;
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
@@ -121,8 +131,8 @@ static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
 }
 #endif
 
-#ifndef __HAVE_ARCH_PMDP_HUGE_GET_AND_CLEAR
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#ifndef __HAVE_ARCH_PMDP_HUGE_GET_AND_CLEAR
 static inline pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
 					    unsigned long address,
 					    pmd_t *pmdp)
@@ -131,20 +141,39 @@ static inline pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
 	pmd_clear(pmdp);
 	return pmd;
 }
+#endif /* __HAVE_ARCH_PMDP_HUGE_GET_AND_CLEAR */
+#ifndef __HAVE_ARCH_PUDP_HUGE_GET_AND_CLEAR
+static inline pud_t pudp_huge_get_and_clear(struct mm_struct *mm,
+					    unsigned long address,
+					    pud_t *pudp)
+{
+	pud_t pud = *pudp;
+	pud_clear(pudp);
+	return pud;
+}
+#endif /* __HAVE_ARCH_PUDP_HUGE_GET_AND_CLEAR */
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
-#endif
 
-#ifndef __HAVE_ARCH_PMDP_HUGE_GET_AND_CLEAR_FULL
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#ifndef __HAVE_ARCH_PMDP_HUGE_GET_AND_CLEAR_FULL
 static inline pmd_t pmdp_huge_get_and_clear_full(struct mm_struct *mm,
 					    unsigned long address, pmd_t *pmdp,
 					    int full)
 {
 	return pmdp_huge_get_and_clear(mm, address, pmdp);
 }
-#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
+#ifndef __HAVE_ARCH_PUDP_HUGE_GET_AND_CLEAR_FULL
+static inline pud_t pudp_huge_get_and_clear_full(struct mm_struct *mm,
+					    unsigned long address, pud_t *pudp,
+					    int full)
+{
+	return pudp_huge_get_and_clear(mm, address, pudp);
+}
+#endif
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+
 #ifndef __HAVE_ARCH_PTEP_GET_AND_CLEAR_FULL
 static inline pte_t ptep_get_and_clear_full(struct mm_struct *mm,
 					    unsigned long address, pte_t *ptep,
@@ -181,6 +210,9 @@ extern pte_t ptep_clear_flush(struct vm_area_struct *vma,
 extern pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vma,
 			      unsigned long address,
 			      pmd_t *pmdp);
+extern pud_t pudp_huge_clear_flush(struct vm_area_struct *vma,
+			      unsigned long address,
+			      pud_t *pudp);
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_SET_WRPROTECT
@@ -265,12 +297,23 @@ static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
 {
 	return pmd_val(pmd_a) == pmd_val(pmd_b);
 }
+
+static inline int pud_same(pud_t pud_a, pud_t pud_b)
+{
+	return pud_val(pud_a) == pud_val(pud_b);
+}
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
 {
 	BUILD_BUG();
 	return 0;
 }
+
+static inline int pud_same(pud_t pud_a, pud_t pud_b)
+{
+	BUILD_BUG();
+	return 0;
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
@@ -629,6 +672,17 @@ static inline int pmd_write(pmd_t pmd)
 #endif /* __HAVE_ARCH_PMD_WRITE */
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
+#ifndef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+static inline int pud_trans_huge(pud_t pud)
+{
+	return 0;
+}
+static inline int pud_devmap(pud_t pud)
+{
+	return 0;
+}
+#endif /* CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
+
 #ifndef pmd_read_atomic
 static inline pmd_t pmd_read_atomic(pmd_t *pmdp)
 {
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index 9dbb739..9d310c8 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -196,6 +196,20 @@ static inline void __tlb_reset_range(struct mmu_gather *tlb)
 		__tlb_remove_pmd_tlb_entry(tlb, pmdp, address);	\
 	} while (0)
 
+/**
+ * tlb_remove_pud_tlb_entry - remember a pud mapping for later tlb invalidation
+ * This is a nop so far, because only x86 needs it.
+ */
+#ifndef __tlb_remove_pud_tlb_entry
+#define __tlb_remove_pud_tlb_entry(tlb, pudp, address) do {} while (0)
+#endif
+
+#define tlb_remove_pud_tlb_entry(tlb, pudp, address)		\
+	do {							\
+		__tlb_adjust_range(tlb, address);		\
+		__tlb_remove_pud_tlb_entry(tlb, pudp, address);	\
+	} while (0)
+
 #define pte_free_tlb(tlb, ptep, address)			\
 	do {							\
 		__tlb_adjust_range(tlb, address);		\
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index bc141a6..d58cd19 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -12,6 +12,20 @@ extern void huge_pmd_set_accessed(struct mm_struct *mm,
 				  struct vm_area_struct *vma,
 				  unsigned long address, pmd_t *pmd,
 				  pmd_t orig_pmd, int dirty);
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+extern void huge_pud_set_accessed(struct mm_struct *mm,
+				  struct vm_area_struct *vma,
+				  unsigned long address, pud_t *pud,
+				  pud_t orig_pud, int dirty);
+#else
+static inline void huge_pud_set_accessed(struct mm_struct *mm,
+				  struct vm_area_struct *vma,
+				  unsigned long address, pud_t *pud,
+				  pud_t orig_pud, int dirty)
+{
+}
+#endif
+
 extern int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			       unsigned long address, pmd_t *pmd,
 			       pmd_t orig_pmd);
@@ -25,6 +39,9 @@ extern int madvise_free_huge_pmd(struct mmu_gather *tlb,
 extern int zap_huge_pmd(struct mmu_gather *tlb,
 			struct vm_area_struct *vma,
 			pmd_t *pmd, unsigned long addr);
+extern int zap_huge_pud(struct mmu_gather *tlb,
+			struct vm_area_struct *vma,
+			pud_t *pud, unsigned long addr);
 extern int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, unsigned long end,
 			unsigned char *vec);
@@ -38,6 +55,8 @@ extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			int prot_numa);
 int vmf_insert_pfn_pmd(struct vm_area_struct *, unsigned long addr, pmd_t *,
 			pfn_t pfn, bool write);
+int vmf_insert_pfn_pud(struct vm_area_struct *, unsigned long addr, pud_t *,
+			pfn_t pfn, bool write);
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
 	TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
@@ -61,6 +80,10 @@ struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
 #define HPAGE_PMD_SIZE	((1UL) << HPAGE_PMD_SHIFT)
 #define HPAGE_PMD_MASK	(~(HPAGE_PMD_SIZE - 1))
 
+#define HPAGE_PUD_SHIFT PUD_SHIFT
+#define HPAGE_PUD_SIZE	((1UL) << HPAGE_PUD_SHIFT)
+#define HPAGE_PUD_MASK	(~(HPAGE_PUD_SIZE - 1))
+
 extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
 
 #define transparent_hugepage_enabled(__vma)				\
@@ -111,6 +134,17 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			__split_huge_pmd(__vma, __pmd, __address);	\
 	}  while (0)
 
+void __split_huge_pud(struct vm_area_struct *vma, pud_t *pud,
+		unsigned long address);
+
+#define split_huge_pud(__vma, __pud, __address)				\
+	do {								\
+		pud_t *____pud = (__pud);				\
+		if (pud_trans_huge(*____pud)				\
+					|| pud_devmap(*____pud))	\
+			__split_huge_pud(__vma, __pud, __address);	\
+	}  while (0)
+
 #if HPAGE_PMD_ORDER >= MAX_ORDER
 #error "hugepages can't be allocated by the buddy allocator"
 #endif
@@ -122,16 +156,27 @@ extern void vma_adjust_trans_huge(struct vm_area_struct *vma,
 				    long adjust_next);
 extern bool __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
 		spinlock_t **ptl);
+extern bool __pud_trans_huge_lock(pud_t *pud, struct vm_area_struct *vma,
+		spinlock_t **ptl);
 /* mmap_sem must be held on entry */
 static inline bool pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
 		spinlock_t **ptl)
 {
 	VM_BUG_ON_VMA(!rwsem_is_locked(&vma->vm_mm->mmap_sem), vma);
-	if (pmd_trans_huge(*pmd))
+	if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd))
 		return __pmd_trans_huge_lock(pmd, vma, ptl);
 	else
 		return false;
 }
+static inline bool pud_trans_huge_lock(pud_t *pud, struct vm_area_struct *vma,
+		spinlock_t **ptl)
+{
+	VM_BUG_ON_VMA(!rwsem_is_locked(&vma->vm_mm->mmap_sem), vma);
+	if (pud_trans_huge(*pud) || pud_devmap(*pud))
+		return __pud_trans_huge_lock(pud, vma, ptl);
+	else
+		return false;
+}
 static inline int hpage_nr_pages(struct page *page)
 {
 	if (unlikely(PageTransHuge(page)))
@@ -154,6 +199,11 @@ static inline bool is_huge_zero_pmd(pmd_t pmd)
 	return is_huge_zero_page(pmd_page(pmd));
 }
 
+static inline bool is_huge_zero_pud(pud_t pud)
+{
+	return 0;
+}
+
 struct page *get_huge_zero_page(void);
 
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 099e641..bf70c3d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1146,6 +1146,13 @@ static inline pmd_t pfn_t_pmd(pfn_t pfn, pgprot_t pgprot)
 }
 #endif
 
+#ifdef pfn_pud
+static inline pud_t pfn_t_pud(pfn_t pfn, pgprot_t pgprot)
+{
+	return pfn_pud(pfn_t_to_pfn(pfn), pgprot);
+}
+#endif
+
 #ifdef __HAVE_ARCH_PTE_DEVMAP
 static inline bool pfn_t_devmap(pfn_t pfn)
 {
@@ -1369,6 +1376,10 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 
 /**
  * mm_walk - callbacks for walk_page_range
+ * @pud_entry: if set, called for each non-empty PUD (2nd-level) entry
+ *	       this handler should only handle pud_trans_huge() puds.
+ *	       the pmd_entry or pte_entry callbacks will be used for
+ *	       regular PUDs.
  * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
  *	       this handler is required to be able to handle
  *	       pmd_trans_huge() pmds.  They may simply choose to
@@ -1388,6 +1399,8 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  * (see the comment on walk_page_range() for more details)
  */
 struct mm_walk {
+	int (*pud_entry)(pud_t *pud, unsigned long addr,
+			 unsigned long next, struct mm_walk *walk);
 	int (*pmd_entry)(pmd_t *pmd, unsigned long addr,
 			 unsigned long next, struct mm_walk *walk);
 	int (*pte_entry)(pte_t *pte, unsigned long addr,
@@ -1961,6 +1974,10 @@ static inline void pgtable_pmd_page_dtor(struct page *page) {}
 #define pmd_devmap(x) (0)
 #endif
 
+#ifndef pud_devmap
+#define pud_devmap(x) (0)
+#endif
+
 static inline spinlock_t *pmd_lock(struct mm_struct *mm, pmd_t *pmd)
 {
 	spinlock_t *ptl = pmd_lockptr(mm, pmd);
@@ -1968,6 +1985,19 @@ static inline spinlock_t *pmd_lock(struct mm_struct *mm, pmd_t *pmd)
 	return ptl;
 }
 
+/*
+ * No scalability reason to split PUD locks yet, but follow the same pattern
+ * as the PMD locks to make it easier if we have to.  There are places that
+ * will need to be converted to use pud_lock() instead of explicitly grabbing
+ * the page_table_lock, eg __pud_alloc().
+ */
+static inline spinlock_t *pud_lock(struct mm_struct *mm, pud_t *pud)
+{
+	spinlock_t *ptl = &mm->page_table_lock;
+	spin_lock(ptl);
+	return ptl;
+}
+
 extern void free_area_init(unsigned long * zones_size);
 extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index a1a210d..32be698 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -381,6 +381,19 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 	___pmd;								\
 })
 
+#define pudp_huge_clear_flush_notify(__vma, __haddr, __pud)		\
+({									\
+	unsigned long ___haddr = __haddr & HPAGE_PUD_MASK;		\
+	struct mm_struct *___mm = (__vma)->vm_mm;			\
+	pud_t ___pud;							\
+									\
+	___pud = pudp_huge_clear_flush(__vma, __haddr, __pud);		\
+	mmu_notifier_invalidate_range(___mm, ___haddr,			\
+				      ___haddr + HPAGE_PUD_SIZE);	\
+									\
+	___pud;								\
+})
+
 #define pmdp_huge_get_and_clear_notify(__mm, __haddr, __pmd)		\
 ({									\
 	unsigned long ___haddr = __haddr & HPAGE_PMD_MASK;		\
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 76ccead..1d538e4 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1002,6 +1002,58 @@ int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 	return VM_FAULT_NOPAGE;
 }
 
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+static pud_t maybe_pud_mkwrite(pud_t pud, struct vm_area_struct *vma)
+{
+	if (likely(vma->vm_flags & VM_WRITE))
+		pud = pud_mkwrite(pud);
+	return pud;
+}
+
+static void insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
+		pud_t *pud, pfn_t pfn, pgprot_t prot, bool write)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pud_t entry;
+	spinlock_t *ptl;
+
+	ptl = pud_lock(mm, pud);
+	entry = pud_mkhuge(pfn_t_pud(pfn, prot));
+	if (pfn_t_devmap(pfn))
+		entry = pud_mkdevmap(entry);
+	if (write) {
+		entry = pud_mkyoung(pud_mkdirty(entry));
+		entry = maybe_pud_mkwrite(entry, vma);
+	}
+	set_pud_at(mm, addr, pud, entry);
+	update_mmu_cache_pud(vma, addr, pud);
+	spin_unlock(ptl);
+}
+
+int vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
+			pud_t *pud, pfn_t pfn, bool write)
+{
+	pgprot_t pgprot = vma->vm_page_prot;
+	/*
+	 * If we had pud_special, we could avoid all these restrictions,
+	 * but we need to be consistent with PTEs and architectures that
+	 * can't support a 'special' bit.
+	 */
+	BUG_ON(!(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)));
+	BUG_ON((vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) ==
+						(VM_PFNMAP|VM_MIXEDMAP));
+	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
+	BUG_ON(!pfn_t_devmap(pfn));
+
+	if (addr < vma->vm_start || addr >= vma->vm_end)
+		return VM_FAULT_SIGBUS;
+	if (track_pfn_insert(vma, &pgprot, pfn))
+		return VM_FAULT_SIGBUS;
+	insert_pfn_pud(vma, addr, pud, pfn, pgprot, write);
+	return VM_FAULT_NOPAGE;
+}
+#endif /* CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
+
 static void touch_pmd(struct vm_area_struct *vma, unsigned long addr,
 		pmd_t *pmd)
 {
@@ -1126,6 +1178,29 @@ out:
 	return ret;
 }
 
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+void huge_pud_set_accessed(struct mm_struct *mm, struct vm_area_struct *vma,
+			   unsigned long address, pud_t *pud, pud_t orig_pud,
+			   int dirty)
+{
+	spinlock_t *ptl;
+	pud_t entry;
+	unsigned long haddr;
+
+	ptl = pud_lock(mm, pud);
+	if (unlikely(!pud_same(*pud, orig_pud)))
+		goto unlock;
+
+	entry = pud_mkyoung(orig_pud);
+	haddr = address & HPAGE_PMD_MASK;
+	if (pudp_set_access_flags(vma, haddr, pud, entry, dirty))
+		update_mmu_cache_pud(vma, address, pud);
+
+unlock:
+	spin_unlock(ptl);
+}
+#endif /* CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
+
 void huge_pmd_set_accessed(struct mm_struct *mm,
 			   struct vm_area_struct *vma,
 			   unsigned long address,
@@ -1797,6 +1872,22 @@ bool __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
 	return false;
 }
 
+/*
+ * Returns true if a given pud maps a thp, false otherwise.
+ *
+ * Note that if it returns true, this routine returns without unlocking page
+ * table lock. So callers must unlock it.
+ */
+bool __pud_trans_huge_lock(pud_t *pud, struct vm_area_struct *vma,
+		spinlock_t **ptl)
+{
+	*ptl = pud_lock(vma->vm_mm, pud);
+	if (likely(pud_trans_huge(*pud) || pud_devmap(*pud)))
+		return true;
+	spin_unlock(*ptl);
+	return false;
+}
+
 #define VM_NO_THP (VM_SPECIAL | VM_HUGETLB | VM_SHARED | VM_MAYSHARE)
 
 int hugepage_madvise(struct vm_area_struct *vma,
@@ -2867,6 +2958,66 @@ static int khugepaged(void *none)
 	return 0;
 }
 
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+int zap_huge_pud(struct mmu_gather *tlb, struct vm_area_struct *vma,
+		 pud_t *pud, unsigned long addr)
+{
+	pud_t orig_pud;
+	spinlock_t *ptl;
+
+	if (!__pud_trans_huge_lock(pud, vma, &ptl))
+		return 0;
+	/*
+	 * For architectures like ppc64 we look at deposited pgtable
+	 * when calling pudp_huge_get_and_clear. So do the
+	 * pgtable_trans_huge_withdraw after finishing pudp related
+	 * operations.
+	 */
+	orig_pud = pudp_huge_get_and_clear_full(tlb->mm, addr, pud,
+			tlb->fullmm);
+	tlb_remove_pud_tlb_entry(tlb, pud, addr);
+	if (vma_is_dax(vma)) {
+		spin_unlock(ptl);
+		/* No zero page support yet */
+	} else {
+		/* No support for anonymous PUD pages yet */
+		BUG();
+	}
+	return 1;
+}
+
+static void __split_huge_pud_locked(struct vm_area_struct *vma, pud_t *pud,
+		unsigned long haddr)
+{
+	VM_BUG_ON(haddr & ~HPAGE_PUD_MASK);
+	VM_BUG_ON_VMA(vma->vm_start > haddr, vma);
+	VM_BUG_ON_VMA(vma->vm_end < haddr + HPAGE_PUD_SIZE, vma);
+	VM_BUG_ON(!pud_trans_huge(*pud) && !pud_devmap(*pud));
+
+	count_vm_event(THP_SPLIT_PMD);
+
+	pudp_huge_clear_flush_notify(vma, haddr, pud);
+}
+
+void __split_huge_pud(struct vm_area_struct *vma, pud_t *pud,
+		unsigned long address)
+{
+	spinlock_t *ptl;
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long haddr = address & HPAGE_PUD_MASK;
+
+	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PUD_SIZE);
+	ptl = pud_lock(mm, pud);
+	if (unlikely(!pud_trans_huge(*pud) && !pud_devmap(*pud)))
+		goto out;
+	__split_huge_pud_locked(vma, pud, haddr);
+
+out:
+	spin_unlock(ptl);
+	mmu_notifier_invalidate_range_end(mm, haddr, haddr + HPAGE_PUD_SIZE);
+}
+#endif /* CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
+
 static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
 		unsigned long haddr, pmd_t *pmd)
 {
diff --git a/mm/memory.c b/mm/memory.c
index f5d7e9a..be5326e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1212,9 +1212,19 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
 	pud = pud_offset(pgd, addr);
 	do {
 		next = pud_addr_end(addr, end);
+		if (pud_trans_huge(*pud) || pud_devmap(*pud)) {
+			if (next - addr != HPAGE_PUD_SIZE) {
+				VM_BUG_ON_VMA(!rwsem_is_locked(&tlb->mm->mmap_sem), vma);
+				split_huge_pud(vma, pud, addr);
+			} else if (zap_huge_pud(tlb, vma, pud, addr))
+				goto next;
+			/* fall through */
+		}
 		if (pud_none_or_clear_bad(pud))
 			continue;
 		next = zap_pmd_range(tlb, vma, pud, addr, next, details);
+next:
+		cond_resched();
 	} while (pud++, addr = next, addr != end);
 
 	return addr;
@@ -3268,6 +3278,41 @@ static int wp_huge_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
 	return VM_FAULT_FALLBACK;
 }
 
+static int create_huge_pud(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long address, pud_t *pud, unsigned int flags)
+{
+	struct vm_fault vmf = {
+		.virtual_address = (void __user *)address,
+		.flags = flags | FAULT_FLAG_SIZE_PUD,
+		.pud = pud,
+	};
+
+	/* No support for anonymous transparent PUD pages yet */
+	if (vma_is_anonymous(vma))
+		return VM_FAULT_FALLBACK;
+	if (vma->vm_ops->huge_fault)
+		return vma->vm_ops->huge_fault(vma, &vmf);
+	return VM_FAULT_FALLBACK;
+}
+
+static int wp_huge_pud(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long address, pud_t *pud, pud_t orig_pud,
+			unsigned int flags)
+{
+	struct vm_fault vmf = {
+		.virtual_address = (void __user *)address,
+		.flags = flags | FAULT_FLAG_SIZE_PUD,
+		.pud = pud,
+	};
+
+	/* No support for anonymous transparent PUD pages yet */
+	if (vma_is_anonymous(vma))
+		return VM_FAULT_FALLBACK;
+	if (vma->vm_ops->huge_fault)
+		return vma->vm_ops->huge_fault(vma, &vmf);
+	return VM_FAULT_FALLBACK;
+}
+
 /*
  * These routines also need to handle stuff like marking pages dirty
  * and/or accessed for architectures that don't do it in hardware (most
@@ -3366,6 +3411,32 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	pud = pud_alloc(mm, pgd, address);
 	if (!pud)
 		return VM_FAULT_OOM;
+	if (pud_none(*pud) && transparent_hugepage_enabled(vma)) {
+		int ret = create_huge_pud(mm, vma, address, pud, flags);
+		if (!(ret & VM_FAULT_FALLBACK))
+			return ret;
+	} else {
+		pud_t orig_pud = *pud;
+		int ret;
+
+		barrier();
+		if (pud_trans_huge(orig_pud) || pud_devmap(orig_pud)) {
+			unsigned int dirty = flags & FAULT_FLAG_WRITE;
+
+			/* NUMA case for anonymous PUDs would go here */
+
+			if (dirty && !pud_write(orig_pud)) {
+				ret = wp_huge_pud(mm, vma, address, pud,
+							orig_pud, flags);
+				if (!(ret & VM_FAULT_FALLBACK))
+					return ret;
+			} else {
+				huge_pud_set_accessed(mm, vma, address, pud,
+						      orig_pud, dirty);
+				return 0;
+			}
+		}
+	}
 	pmd = pmd_alloc(mm, pud, address);
 	if (!pmd)
 		return VM_FAULT_OOM;
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 2072444..200d771 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -78,14 +78,31 @@ static int walk_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end,
 
 	pud = pud_offset(pgd, addr);
 	do {
+ again:
 		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud)) {
+		if (pud_none(*pud) || !walk->vma) {
 			if (walk->pte_hole)
 				err = walk->pte_hole(addr, next, walk);
 			if (err)
 				break;
 			continue;
 		}
+
+		if (walk->pud_entry) {
+			spinlock_t *ptl;
+			if (pud_trans_huge_lock(pud, walk->vma, &ptl)) {
+				err = walk->pud_entry(pud, addr, next, walk);
+				spin_unlock(ptl);
+				if (err)
+					break;
+				continue;
+			}
+		}
+
+		split_huge_pud(walk->vma, pud, addr);
+		if (pud_none(*pud))
+			goto again;
+
 		if (walk->pmd_entry || walk->pte_entry)
 			err = walk_pmd_range(pud, addr, next, walk);
 		if (err)
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index 9d47676..415fa5a 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -96,6 +96,7 @@ pte_t ptep_clear_flush(struct vm_area_struct *vma, unsigned long address,
  * e.g. see arch/arc: flush_pmd_tlb_range
  */
 #define flush_pmd_tlb_range(vma, addr, end)	flush_tlb_range(vma, addr, end)
+#define flush_pud_tlb_range(vma, addr, end)	flush_tlb_range(vma, addr, end)
 #endif
 
 #ifndef __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS
@@ -137,6 +138,19 @@ pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vma, unsigned long address,
 	flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 	return pmd;
 }
+
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+pud_t pudp_huge_clear_flush(struct vm_area_struct *vma, unsigned long address,
+			    pud_t *pudp)
+{
+	pud_t pud;
+	VM_BUG_ON(address & ~HPAGE_PUD_MASK);
+	VM_BUG_ON(!pud_trans_huge(*pudp) && !pud_devmap(*pudp));
+	pud = pudp_huge_get_and_clear(vma->vm_mm, address, pudp);
+	flush_pud_tlb_range(vma, address, address + HPAGE_PUD_SIZE);
+	return pud;
+}
+#endif
 #endif
 
 #ifndef __HAVE_ARCH_PGTABLE_DEPOSIT
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
