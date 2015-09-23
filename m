Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id D958182F64
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 00:48:15 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so29389945pad.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 21:48:15 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id e5si7649837pas.193.2015.09.22.21.48.15
        for <linux-mm@kvack.org>;
        Tue, 22 Sep 2015 21:48:15 -0700 (PDT)
Subject: [PATCH 13/15] mm, dax: convert vmf_insert_pfn_pmd() to __pfn_t
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 23 Sep 2015 00:42:22 -0400
Message-ID: <20150923044222.36490.67675.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Dave Hansen <dave@sr71.net>, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>

Similar to the conversion of vm_insert_mixed() use __pfn_t in the
vmf_insert_pfn_pmd() to tag the resulting pte with _PAGE_DEVICE when the
pfn is backed by a devm_memremap_pages() mapping.

Cc: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/sparc/include/asm/pgtable_64.h |    2 ++
 arch/x86/include/asm/pgtable.h      |    6 ++++++
 arch/x86/mm/pat.c                   |    4 ++--
 fs/dax.c                            |    2 +-
 include/asm-generic/pgtable.h       |    6 ++++--
 include/linux/huge_mm.h             |    2 +-
 include/linux/mm.h                  |   27 +++++++++++++++++----------
 include/linux/pfn.h                 |    9 +++++++++
 mm/huge_memory.c                    |   10 ++++++----
 mm/memory.c                         |    2 +-
 10 files changed, 49 insertions(+), 21 deletions(-)

diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 131d36fcd07a..496ef783c68c 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -234,6 +234,7 @@ extern struct page *mem_map_zero;
  * the first physical page in the machine is at some huge physical address,
  * such as 4GB.   This is common on a partitioned E10000, for example.
  */
+#define pfn_pte pfn_pte
 static inline pte_t pfn_pte(unsigned long pfn, pgprot_t prot)
 {
 	unsigned long paddr = pfn << PAGE_SHIFT;
@@ -244,6 +245,7 @@ static inline pte_t pfn_pte(unsigned long pfn, pgprot_t prot)
 #define mk_pte(page, pgprot)	pfn_pte(page_to_pfn(page), (pgprot))
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define pfn_pmd pfn_pmd
 static inline pmd_t pfn_pmd(unsigned long page_nr, pgprot_t pgprot)
 {
 	pte_t pte = pfn_pte(page_nr, pgprot);
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 02a54e5b7930..84d1346e1cda 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -282,6 +282,11 @@ static inline pmd_t pmd_mkdirty(pmd_t pmd)
 	return pmd_set_flags(pmd, _PAGE_DIRTY | _PAGE_SOFT_DIRTY);
 }
 
+static inline pmd_t pmd_mkdevmap(pmd_t pmd)
+{
+	return pmd_set_flags(pmd, _PAGE_DEVMAP);
+}
+
 static inline pmd_t pmd_mkhuge(pmd_t pmd)
 {
 	return pmd_set_flags(pmd, _PAGE_PSE);
@@ -346,6 +351,7 @@ static inline pte_t pfn_pte(unsigned long page_nr, pgprot_t pgprot)
 		     massage_pgprot(pgprot));
 }
 
+#define pfn_pmd pfn_pmd
 static inline pmd_t pfn_pmd(unsigned long page_nr, pgprot_t pgprot)
 {
 	return __pmd(((phys_addr_t)page_nr << PAGE_SHIFT) |
diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 188e3e07eeeb..2e02064dbe45 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -949,7 +949,7 @@ int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
 }
 
 int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
-		     unsigned long pfn)
+		     __pfn_t pfn)
 {
 	enum page_cache_mode pcm;
 
@@ -957,7 +957,7 @@ int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
 		return 0;
 
 	/* Set prot based on lookup */
-	pcm = lookup_memtype((resource_size_t)pfn << PAGE_SHIFT);
+	pcm = lookup_memtype(__pfn_t_to_phys(pfn));
 	*prot = __pgprot((pgprot_val(vma->vm_page_prot) & (~_PAGE_CACHE_MASK)) |
 			 cachemode2protval(pcm));
 
diff --git a/fs/dax.c b/fs/dax.c
index b93dbf363dc2..321966335f33 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -681,7 +681,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 			goto fallback;
 
 		result |= vmf_insert_pfn_pmd(vma, address, pmd,
-				__pfn_t_to_pfn(pfn), write);
+				pfn, write);
 	}
 
  out:
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 29c57b2cb344..a65f86061563 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_GENERIC_PGTABLE_H
 #define _ASM_GENERIC_PGTABLE_H
 
+#include <linux/pfn.h>
+
 #ifndef __ASSEMBLY__
 #ifdef CONFIG_MMU
 
@@ -521,7 +523,7 @@ static inline int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
  * by vm_insert_pfn().
  */
 static inline int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
-				   unsigned long pfn)
+				   __pfn_t pfn)
 {
 	return 0;
 }
@@ -549,7 +551,7 @@ extern int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
 			   unsigned long pfn, unsigned long addr,
 			   unsigned long size);
 extern int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
-			    unsigned long pfn);
+			    __pfn_t pfn);
 extern int track_pfn_copy(struct vm_area_struct *vma);
 extern void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
 			unsigned long size);
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index ecb080d6ff42..824eb98c53fc 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -34,7 +34,7 @@ extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, pgprot_t newprot,
 			int prot_numa);
 int vmf_insert_pfn_pmd(struct vm_area_struct *, unsigned long addr, pmd_t *,
-			unsigned long pfn, bool write);
+			__pfn_t pfn, bool write);
 
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 54fbeda5b896..989c5459bee7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -906,15 +906,6 @@ static inline void set_page_links(struct page *page, enum zone_type zone,
 }
 
 /*
- * __pfn_t: encapsulates a page-frame number that is optionally backed
- * by memmap (struct page).  Whether a __pfn_t has a 'struct page'
- * backing is indicated by flags in the low bits of the value;
- */
-typedef struct {
-	unsigned long val;
-} __pfn_t;
-
-/*
  * PFN_SG_CHAIN - pfn is a pointer to the next scatterlist entry
  * PFN_SG_LAST - pfn references a page and is the last scatterlist entry
  * PFN_DEV - pfn is not covered by system memmap by default
@@ -989,7 +980,14 @@ static inline pte_t __pfn_t_pte(__pfn_t pfn, pgprot_t pgprot)
 }
 #endif
 
-#ifdef __HAVE_ARCH_PTE_DEVICE
+#ifdef pfn_pmd
+static inline pmd_t __pfn_t_pmd(__pfn_t pfn, pgprot_t pgprot)
+{
+	return pfn_pmd(__pfn_t_to_pfn(pfn), pgprot);
+}
+#endif
+
+#ifdef __HAVE_ARCH_PTE_DEVMAP
 static inline bool __pfn_t_has_dev_pagemap(__pfn_t pfn)
 {
 	const unsigned long flags = PFN_DEV|PFN_MAP;
@@ -1002,6 +1000,7 @@ static inline bool __pfn_t_has_dev_pagemap(__pfn_t pfn)
 	return false;
 }
 pte_t pte_mkdevmap(pte_t pte);
+pmd_t pmd_mkdevmap(pmd_t pmd);
 #endif
 
 /*
@@ -1767,6 +1766,14 @@ static inline void pgtable_pmd_page_dtor(struct page *page) {}
 
 #endif
 
+#ifndef pmd_devmap
+#define pmd_devmap(x) (0)
+#endif
+
+#ifndef pte_devmap
+#define pte_devmap(x) (0)
+#endif
+
 static inline spinlock_t *pmd_lock(struct mm_struct *mm, pmd_t *pmd)
 {
 	spinlock_t *ptl = pmd_lockptr(mm, pmd);
diff --git a/include/linux/pfn.h b/include/linux/pfn.h
index 7646637221f3..ebe7b30ff912 100644
--- a/include/linux/pfn.h
+++ b/include/linux/pfn.h
@@ -3,6 +3,15 @@
 
 #ifndef __ASSEMBLY__
 #include <linux/types.h>
+
+/*
+ * __pfn_t: encapsulates a page-frame number that is optionally backed
+ * by memmap (struct page).  Whether a __pfn_t has a 'struct page'
+ * backing is indicated by flags in the low bits of the value;
+ */
+typedef struct {
+	unsigned long val;
+} __pfn_t;
 #endif
 
 #define PFN_ALIGN(x)	(((unsigned long)(x) + (PAGE_SIZE - 1)) & PAGE_MASK)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4b06b8db9df2..d8f01783ab88 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -870,7 +870,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 }
 
 static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
-		pmd_t *pmd, unsigned long pfn, pgprot_t prot, bool write)
+		pmd_t *pmd, __pfn_t pfn, pgprot_t prot, bool write)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pmd_t entry;
@@ -878,7 +878,9 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 
 	ptl = pmd_lock(mm, pmd);
 	if (pmd_none(*pmd)) {
-		entry = pmd_mkhuge(pfn_pmd(pfn, prot));
+		entry = pmd_mkhuge(__pfn_t_pmd(pfn, prot));
+		if (__pfn_t_has_dev_pagemap(pfn))
+			entry = pmd_mkdevmap(entry);
 		if (write) {
 			entry = pmd_mkyoung(pmd_mkdirty(entry));
 			entry = maybe_pmd_mkwrite(entry, vma);
@@ -890,7 +892,7 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 }
 
 int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
-			pmd_t *pmd, unsigned long pfn, bool write)
+			pmd_t *pmd, __pfn_t pfn, bool write)
 {
 	pgprot_t pgprot = vma->vm_page_prot;
 	/*
@@ -902,7 +904,7 @@ int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 	BUG_ON((vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) ==
 						(VM_PFNMAP|VM_MIXEDMAP));
 	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
-	BUG_ON((vma->vm_flags & VM_MIXEDMAP) && pfn_valid(pfn));
+	BUG_ON((vma->vm_flags & VM_MIXEDMAP) && __pfn_t_valid(pfn));
 
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return VM_FAULT_SIGBUS;
diff --git a/mm/memory.c b/mm/memory.c
index 6ec61c120289..2e178d8fdeba 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1583,7 +1583,7 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return -EFAULT;
-	if (track_pfn_insert(vma, &pgprot, pfn))
+	if (track_pfn_insert(vma, &pgprot, pfn_to_pfn_t(pfn, PFN_DEV)))
 		return -EINVAL;
 
 	ret = insert_pfn(vma, addr, pfn_to_pfn_t(pfn, PFN_DEV), pgprot);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
