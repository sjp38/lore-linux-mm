Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id A28E1828DF
	for <linux-mm@kvack.org>; Sun, 31 Jan 2016 07:09:50 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id uo6so67420435pac.1
        for <linux-mm@kvack.org>; Sun, 31 Jan 2016 04:09:50 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id iu1si16522839pac.43.2016.01.31.04.09.44
        for <linux-mm@kvack.org>;
        Sun, 31 Jan 2016 04:09:44 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v4 3/8] mm: Add support for PUD-sized transparent hugepages
Date: Sun, 31 Jan 2016 23:09:30 +1100
Message-Id: <1454242175-16870-4-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1454242175-16870-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1454242175-16870-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
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
 include/asm-generic/pgtable.h |  74 ++++++++++++-
 include/asm-generic/tlb.h     |  14 +++
 include/linux/huge_mm.h       |  78 +++++++++++++-
 include/linux/mm.h            |  28 +++++
 include/linux/mmu_notifier.h  |  14 +++
 include/linux/pfn_t.h         |   8 ++
 mm/gup.c                      |   7 ++
 mm/huge_memory.c              | 246 ++++++++++++++++++++++++++++++++++++++++++
 mm/memory.c                   |  97 ++++++++++++++++-
 mm/pagewalk.c                 |  19 +++-
 mm/pgtable-generic.c          |  14 +++
 12 files changed, 591 insertions(+), 11 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 155e6cd..ab00f4f 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -459,6 +459,9 @@ config HAVE_IRQ_TIME_ACCOUNTING
 config HAVE_ARCH_TRANSPARENT_HUGEPAGE
 	bool
 
+config HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+	bool
+
 config HAVE_ARCH_HUGE_VMAP
 	bool
 
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 0b3c0d3..52c9185 100644
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
@@ -208,6 +240,22 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm,
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
+#ifndef __HAVE_ARCH_PUDP_SET_WRPROTECT
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+static inline void pudp_set_wrprotect(struct mm_struct *mm,
+				      unsigned long address, pud_t *pudp)
+{
+	pud_t old_pud = *pudp;
+	set_pud_at(mm, address, pudp, pud_wrprotect(old_pud));
+}
+#else
+static inline void pudp_set_wrprotect(struct mm_struct *mm,
+				      unsigned long address, pud_t *pudp)
+{
+	BUILD_BUG();
+}
+#endif /* CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
+#endif
 
 #ifndef pmdp_collapse_flush
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -265,12 +313,23 @@ static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
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
 
@@ -633,6 +692,13 @@ static inline int pmd_write(pmd_t pmd)
 #endif /* __HAVE_ARCH_PMD_WRITE */
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
+#ifndef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+static inline int pud_trans_huge(pud_t pud)
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
index fd5b474..4602cf4 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -8,10 +8,27 @@ extern int do_huge_pmd_anonymous_page(struct mm_struct *mm,
 extern int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			 pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
 			 struct vm_area_struct *vma);
+extern int copy_huge_pud(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+			 pud_t *dst_pud, pud_t *src_pud, unsigned long addr,
+			 struct vm_area_struct *vma);
 extern void huge_pmd_set_accessed(struct mm_struct *mm,
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
@@ -25,6 +42,9 @@ extern int madvise_free_huge_pmd(struct mmu_gather *tlb,
 extern int zap_huge_pmd(struct mmu_gather *tlb,
 			struct vm_area_struct *vma,
 			pmd_t *pmd, unsigned long addr);
+extern int zap_huge_pud(struct mmu_gather *tlb,
+			struct vm_area_struct *vma,
+			pud_t *pud, unsigned long addr);
 extern int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, unsigned long end,
 			unsigned char *vec);
@@ -38,6 +58,8 @@ extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			int prot_numa);
 int vmf_insert_pfn_pmd(struct vm_area_struct *, unsigned long addr, pmd_t *,
 			pfn_t pfn, bool write);
+int vmf_insert_pfn_pud(struct vm_area_struct *, unsigned long addr, pud_t *,
+			pfn_t pfn, bool write);
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
 	TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
@@ -54,13 +76,14 @@ enum transparent_hugepage_flag {
 #define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
-		pmd_t *pmd, int flags);
-
 #define HPAGE_PMD_SHIFT PMD_SHIFT
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
@@ -122,6 +156,8 @@ extern void vma_adjust_trans_huge(struct vm_area_struct *vma,
 				    long adjust_next);
 extern spinlock_t *__pmd_trans_huge_lock(pmd_t *pmd,
 		struct vm_area_struct *vma);
+extern spinlock_t *__pud_trans_huge_lock(pud_t *pud,
+		struct vm_area_struct *vma);
 /* mmap_sem must be held on entry */
 static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
 		struct vm_area_struct *vma)
@@ -132,6 +168,15 @@ static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
 	else
 		return NULL;
 }
+static inline spinlock_t *pud_trans_huge_lock(pud_t *pud,
+		struct vm_area_struct *vma)
+{
+	VM_BUG_ON_VMA(!rwsem_is_locked(&vma->vm_mm->mmap_sem), vma);
+	if (pud_trans_huge(*pud) || pud_devmap(*pud))
+		return __pud_trans_huge_lock(pud, vma);
+	else
+		return NULL;
+}
 static inline int hpage_nr_pages(struct page *page)
 {
 	if (unlikely(PageTransHuge(page)))
@@ -139,6 +184,11 @@ static inline int hpage_nr_pages(struct page *page)
 	return 1;
 }
 
+struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
+		pmd_t *pmd, int flags);
+struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
+		pud_t *pud, int flags);
+
 extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				unsigned long addr, pmd_t pmd, pmd_t *pmdp);
 
@@ -154,6 +204,11 @@ static inline bool is_huge_zero_pmd(pmd_t pmd)
 	return is_huge_zero_page(pmd_page(pmd));
 }
 
+static inline bool is_huge_zero_pud(pud_t pud)
+{
+	return 0;
+}
+
 struct page *get_huge_zero_page(void);
 
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
@@ -161,6 +216,10 @@ struct page *get_huge_zero_page(void);
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_SIZE ({ BUILD_BUG(); 0; })
 
+#define HPAGE_PUD_SHIFT ({ BUILD_BUG(); 0; })
+#define HPAGE_PUD_MASK ({ BUILD_BUG(); 0; })
+#define HPAGE_PUD_SIZE ({ BUILD_BUG(); 0; })
+
 #define hpage_nr_pages(x) 1
 
 #define transparent_hugepage_enabled(__vma) 0
@@ -178,6 +237,8 @@ static inline int split_huge_page(struct page *page)
 static inline void deferred_split_huge_page(struct page *page) {}
 #define split_huge_pmd(__vma, __pmd, __address)	\
 	do { } while (0)
+#define split_huge_pud(__vma, __pmd, __address)	\
+	do { } while (0)
 static inline int hugepage_madvise(struct vm_area_struct *vma,
 				   unsigned long *vm_flags, int advice)
 {
@@ -195,6 +256,11 @@ static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
 {
 	return NULL;
 }
+static inline spinlock_t *pud_trans_huge_lock(pud_t *pud,
+		struct vm_area_struct *vma)
+{
+	return NULL;
+}
 
 static inline int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 					unsigned long addr, pmd_t pmd, pmd_t *pmdp)
@@ -213,6 +279,12 @@ static inline struct page *follow_devmap_pmd(struct vm_area_struct *vma,
 {
 	return NULL;
 }
+
+static inline struct page *follow_devmap_pud(struct vm_area_struct *vma,
+		unsigned long addr, pud_t *pud, int flags)
+{
+	return NULL;
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b9d0979..03f56ff 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -345,6 +345,10 @@ static inline int pmd_devmap(pmd_t pmd)
 {
 	return 0;
 }
+static inline int pud_devmap(pud_t pud)
+{
+	return 0;
+}
 #endif
 
 /*
@@ -1137,6 +1141,10 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 
 /**
  * mm_walk - callbacks for walk_page_range
+ * @pud_entry: if set, called for each non-empty PUD (2nd-level) entry
+ *	       this handler should only handle pud_trans_huge() puds.
+ *	       the pmd_entry or pte_entry callbacks will be used for
+ *	       regular PUDs.
  * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
  *	       this handler is required to be able to handle
  *	       pmd_trans_huge() pmds.  They may simply choose to
@@ -1156,6 +1164,8 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  * (see the comment on walk_page_range() for more details)
  */
 struct mm_walk {
+	int (*pud_entry)(pud_t *pud, unsigned long addr,
+			 unsigned long next, struct mm_walk *walk);
 	int (*pmd_entry)(pmd_t *pmd, unsigned long addr,
 			 unsigned long next, struct mm_walk *walk);
 	int (*pte_entry)(pte_t *pte, unsigned long addr,
@@ -1735,6 +1745,24 @@ static inline spinlock_t *pmd_lock(struct mm_struct *mm, pmd_t *pmd)
 	return ptl;
 }
 
+/*
+ * No scalability reason to split PUD locks yet, but follow the same pattern
+ * as the PMD locks to make it easier if we decide to.  The VM should not be
+ * considered ready to switch to split PUD locks yet; there may be places
+ * which need to be converted from page_table_lock.
+ */
+static inline spinlock_t *pud_lockptr(struct mm_struct *mm, pud_t *pud)
+{
+	return &mm->page_table_lock;
+}
+
+static inline spinlock_t *pud_lock(struct mm_struct *mm, pud_t *pud)
+{
+	spinlock_t *ptl = pud_lockptr(mm, pud);
+	spin_lock(ptl);
+	return ptl;
+}
+
 extern void free_area_init(unsigned long * zones_size);
 extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index a1a210d..51891fb 100644
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
@@ -475,6 +488,7 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 #define pmdp_clear_young_notify pmdp_test_and_clear_young
 #define	ptep_clear_flush_notify ptep_clear_flush
 #define pmdp_huge_clear_flush_notify pmdp_huge_clear_flush
+#define pudp_huge_clear_flush_notify pudp_huge_clear_flush
 #define pmdp_huge_get_and_clear_notify pmdp_huge_get_and_clear
 #define set_pte_at_notify set_pte_at
 
diff --git a/include/linux/pfn_t.h b/include/linux/pfn_t.h
index 37448ab..07d18a8 100644
--- a/include/linux/pfn_t.h
+++ b/include/linux/pfn_t.h
@@ -82,6 +82,13 @@ static inline pmd_t pfn_t_pmd(pfn_t pfn, pgprot_t pgprot)
 {
 	return pfn_pmd(pfn_t_to_pfn(pfn), pgprot);
 }
+
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+static inline pud_t pfn_t_pud(pfn_t pfn, pgprot_t pgprot)
+{
+	return pfn_pud(pfn_t_to_pfn(pfn), pgprot);
+}
+#endif
 #endif
 
 #ifdef __HAVE_ARCH_PTE_DEVMAP
@@ -98,5 +105,6 @@ static inline bool pfn_t_devmap(pfn_t pfn)
 }
 pte_t pte_mkdevmap(pte_t pte);
 pmd_t pmd_mkdevmap(pmd_t pmd);
+pud_t pud_mkdevmap(pud_t pud);
 #endif
 #endif /* _LINUX_PFN_T_H_ */
diff --git a/mm/gup.c b/mm/gup.c
index b64a361..a5257ea 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -242,6 +242,13 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 			return page;
 		return no_page_table(vma, flags);
 	}
+	if (pud_devmap(*pud)) {
+		ptl = pud_lock(mm, pud);
+		page = follow_devmap_pud(vma, address, pud, flags);
+		spin_unlock(ptl);
+		if (page)
+			return page;
+	}
 	if (unlikely(pud_bad(*pud)))
 		return no_page_table(vma, flags);
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 883ac58..4b9f2cb 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1003,6 +1003,58 @@ int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
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
@@ -1021,6 +1073,24 @@ static void touch_pmd(struct vm_area_struct *vma, unsigned long addr,
 		update_mmu_cache_pmd(vma, addr, pmd);
 }
 
+static void touch_pud(struct vm_area_struct *vma, unsigned long addr,
+		pud_t *pud)
+{
+	pud_t _pud;
+
+	/*
+	 * We should set the dirty bit only for FOLL_WRITE but for now
+	 * the dirty bit in the pud is meaningless.  And if the dirty
+	 * bit will become meaningful and we'll only set it with
+	 * FOLL_WRITE, an atomic set_bit will be required on the pud to
+	 * set the young bit, instead of the current set_pud_at.
+	 */
+	_pud = pud_mkyoung(pud_mkdirty(*pud));
+	if (pudp_set_access_flags(vma, addr & HPAGE_PUD_MASK,
+				pud, _pud,  1))
+		update_mmu_cache_pud(vma, addr, pud);
+}
+
 struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
 		pmd_t *pmd, int flags)
 {
@@ -1060,6 +1130,45 @@ struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
 	return page;
 }
 
+struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
+		pud_t *pud, int flags)
+{
+	unsigned long pfn = pud_pfn(*pud);
+	struct mm_struct *mm = vma->vm_mm;
+	struct dev_pagemap *pgmap;
+	struct page *page;
+
+	assert_spin_locked(pud_lockptr(mm, pud));
+
+	if (flags & FOLL_WRITE && !pud_write(*pud))
+		return NULL;
+
+	if (pud_present(*pud) && pud_devmap(*pud))
+		/* pass */;
+	else
+		return NULL;
+
+	if (flags & FOLL_TOUCH)
+		touch_pud(vma, addr, pud);
+
+	/*
+	 * device mapped pages can only be returned if the
+	 * caller will manage the page reference count.
+	 */
+	if (!(flags & FOLL_GET))
+		return ERR_PTR(-EEXIST);
+
+	pfn += (addr & ~PUD_MASK) >> PAGE_SHIFT;
+	pgmap = get_dev_pagemap(pfn, NULL);
+	if (!pgmap)
+		return ERR_PTR(-EFAULT);
+	page = pfn_to_page(pfn);
+	get_page(page);
+	put_dev_pagemap(pgmap);
+
+	return page;
+}
+
 int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		  pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
 		  struct vm_area_struct *vma)
@@ -1127,6 +1236,66 @@ out:
 	return ret;
 }
 
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+int copy_huge_pud(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+		  pud_t *dst_pud, pud_t *src_pud, unsigned long addr,
+		  struct vm_area_struct *vma)
+{
+	spinlock_t *dst_ptl, *src_ptl;
+	pud_t pud;
+	int ret;
+
+	dst_ptl = pud_lock(dst_mm, dst_pud);
+	src_ptl = pud_lockptr(src_mm, src_pud);
+	spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
+
+	ret = -EAGAIN;
+	pud = *src_pud;
+	if (unlikely(!pud_trans_huge(pud) && !pud_devmap(pud)))
+		goto out_unlock;
+
+	/*
+	 * When page table lock is held, the huge zero pud should not be
+	 * under splitting since we don't split the page itself, only pud to
+	 * a page table.
+	 */
+	if (is_huge_zero_pud(pud)) {
+		/* No huge zero pud yet */
+	}
+
+	pudp_set_wrprotect(src_mm, addr, src_pud);
+	pud = pud_mkold(pud_wrprotect(pud));
+	set_pud_at(dst_mm, addr, dst_pud, pud);
+
+	ret = 0;
+out_unlock:
+	spin_unlock(src_ptl);
+	spin_unlock(dst_ptl);
+	return ret;
+}
+
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
@@ -1802,6 +1971,22 @@ spinlock_t *__pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma)
 	return NULL;
 }
 
+/*
+ * Returns true if a given pud maps a thp, false otherwise.
+ *
+ * Note that if it returns true, this routine returns without unlocking page
+ * table lock. So callers must unlock it.
+ */
+spinlock_t *__pud_trans_huge_lock(pud_t *pud, struct vm_area_struct *vma)
+{
+	spinlock_t *ptl;
+	ptl = pud_lock(vma->vm_mm, pud);
+	if (likely(pud_trans_huge(*pud) || pud_devmap(*pud)))
+		return ptl;
+	spin_unlock(ptl);
+	return NULL;
+}
+
 #define VM_NO_THP (VM_SPECIAL | VM_HUGETLB | VM_SHARED | VM_MAYSHARE)
 
 int hugepage_madvise(struct vm_area_struct *vma,
@@ -2872,6 +3057,67 @@ static int khugepaged(void *none)
 	return 0;
 }
 
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+int zap_huge_pud(struct mmu_gather *tlb, struct vm_area_struct *vma,
+		 pud_t *pud, unsigned long addr)
+{
+	pud_t orig_pud;
+	spinlock_t *ptl;
+
+	ptl = __pud_trans_huge_lock(pud, vma);
+	if (!ptl)
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
index ca48e65..554816b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -952,7 +952,7 @@ static inline int copy_pmd_range(struct mm_struct *dst_mm, struct mm_struct *src
 		next = pmd_addr_end(addr, end);
 		if (pmd_trans_huge(*src_pmd) || pmd_devmap(*src_pmd)) {
 			int err;
-			VM_BUG_ON(next-addr != HPAGE_PMD_SIZE);
+			VM_BUG_ON_VMA(vma, next-addr != HPAGE_PMD_SIZE);
 			err = copy_huge_pmd(dst_mm, src_mm,
 					    dst_pmd, src_pmd, addr, vma);
 			if (err == -ENOMEM)
@@ -983,6 +983,17 @@ static inline int copy_pud_range(struct mm_struct *dst_mm, struct mm_struct *src
 	src_pud = pud_offset(src_pgd, addr);
 	do {
 		next = pud_addr_end(addr, end);
+		if (pud_trans_huge(*src_pud) || pud_devmap(*src_pud)) {
+			int err;
+			VM_BUG_ON_VMA(vma, next-addr != HPAGE_PUD_SIZE);
+			err = copy_huge_pud(dst_mm, src_mm,
+					    dst_pud, src_pud, addr, vma);
+			if (err == -ENOMEM)
+				return -ENOMEM;
+			if (!err)
+				continue;
+			/* fall through */
+		}
 		if (pud_none_or_clear_bad(src_pud))
 			continue;
 		if (copy_pmd_range(dst_mm, src_mm, dst_pud, src_pud,
@@ -1219,9 +1230,19 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
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
@@ -3304,6 +3325,49 @@ static int wp_huge_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
 	return VM_FAULT_FALLBACK;
 }
 
+static int create_huge_pud(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long address, pud_t *pud, unsigned int flags)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	struct vm_fault vmf = {
+		.flags = flags | FAULT_FLAG_SIZE_PUD,
+		.gfp_mask = __get_fault_gfp_mask(vma),
+		.pgoff = linear_page_index(vma, address & HPAGE_PUD_MASK),
+		.virtual_address = (void __user *)address,
+		.pud = pud,
+	};
+
+	/* No support for anonymous transparent PUD pages yet */
+	if (vma_is_anonymous(vma))
+		return VM_FAULT_FALLBACK;
+	if (vma->vm_ops->huge_fault)
+		return vma->vm_ops->huge_fault(vma, &vmf);
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+	return VM_FAULT_FALLBACK;
+}
+
+static int wp_huge_pud(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long address, pud_t *pud, pud_t orig_pud,
+			unsigned int flags)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	struct vm_fault vmf = {
+		.flags = flags | FAULT_FLAG_SIZE_PUD,
+		.gfp_mask = __get_fault_gfp_mask(vma),
+		.pgoff = linear_page_index(vma, address & HPAGE_PUD_MASK),
+		.virtual_address = (void __user *)address,
+		.pud = pud,
+	};
+
+	/* No support for anonymous transparent PUD pages yet */
+	if (vma_is_anonymous(vma))
+		return VM_FAULT_FALLBACK;
+	if (vma->vm_ops->huge_fault)
+		return vma->vm_ops->huge_fault(vma, &vmf);
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+	return VM_FAULT_FALLBACK;
+}
+
 /*
  * These routines also need to handle stuff like marking pages dirty
  * and/or accessed for architectures that don't do it in hardware (most
@@ -3402,6 +3466,32 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
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
@@ -3530,13 +3620,14 @@ int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
  */
 int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
 {
+	spinlock_t *ptl;
 	pmd_t *new = pmd_alloc_one(mm, address);
 	if (!new)
 		return -ENOMEM;
 
 	smp_wmb(); /* See comment in __pte_alloc */
 
-	spin_lock(&mm->page_table_lock);
+	ptl = pud_lock(mm, pud);
 #ifndef __ARCH_HAS_4LEVEL_HACK
 	if (!pud_present(*pud)) {
 		mm_inc_nr_pmds(mm);
@@ -3550,7 +3641,7 @@ int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
 	} else /* Another has populated it */
 		pmd_free(mm, new);
 #endif /* __ARCH_HAS_4LEVEL_HACK */
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 	return 0;
 }
 #endif /* __PAGETABLE_PMD_FOLDED */
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 2072444..d6c2e6b 100644
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
+			spinlock_t *ptl = pud_trans_huge_lock(pud, walk->vma);
+			if (ptl) {
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
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
