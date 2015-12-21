Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 69F176B0022
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 00:45:38 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id n128so65963028pfn.0
        for <linux-mm@kvack.org>; Sun, 20 Dec 2015 21:45:38 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id r88si4959805pfa.151.2015.12.20.21.45.37
        for <linux-mm@kvack.org>;
        Sun, 20 Dec 2015 21:45:37 -0800 (PST)
Subject: [-mm PATCH v4 12/18] mm, dax: convert vmf_insert_pfn_pmd() to pfn_t
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 20 Dec 2015 21:45:10 -0800
Message-ID: <20151221054510.34542.28666.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
References: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Dave Hansen <dave@sr71.net>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-nvdimm@lists.01.org

Similar to the conversion of vm_insert_mixed() use pfn_t in the
vmf_insert_pfn_pmd() to tag the resulting pte with _PAGE_DEVICE when the
pfn is backed by a devm_memremap_pages() mapping.

Cc: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/include/asm/pgtable.h |    5 +++++
 arch/x86/mm/pat.c              |    5 +++--
 fs/dax.c                       |    2 +-
 include/asm-generic/pgtable.h  |    6 ++++--
 include/linux/huge_mm.h        |    2 +-
 include/linux/pfn_t.h          |    8 ++++++++
 mm/huge_memory.c               |   11 +++++++----
 mm/memory.c                    |    2 +-
 8 files changed, 30 insertions(+), 11 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 176b9c4403fc..dc962ae41597 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -289,6 +289,11 @@ static inline pmd_t pmd_mkdirty(pmd_t pmd)
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
diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 188e3e07eeeb..6c7259fdcf6d 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -12,6 +12,7 @@
 #include <linux/debugfs.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
+#include <linux/pfn_t.h>
 #include <linux/slab.h>
 #include <linux/mm.h>
 #include <linux/fs.h>
@@ -949,7 +950,7 @@ int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
 }
 
 int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
-		     unsigned long pfn)
+		     pfn_t pfn)
 {
 	enum page_cache_mode pcm;
 
@@ -957,7 +958,7 @@ int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
 		return 0;
 
 	/* Set prot based on lookup */
-	pcm = lookup_memtype((resource_size_t)pfn << PAGE_SHIFT);
+	pcm = lookup_memtype(pfn_t_to_phys(pfn));
 	*prot = __pgprot((pgprot_val(vma->vm_page_prot) & (~_PAGE_CACHE_MASK)) |
 			 cachemode2protval(pcm));
 
diff --git a/fs/dax.c b/fs/dax.c
index 574763eed8a3..96ac3072463d 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -693,7 +693,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		dax_unmap_atomic(bdev, &dax);
 
 		result |= vmf_insert_pfn_pmd(vma, address, pmd,
-				pfn_t_to_pfn(dax.pfn), write);
+				dax.pfn, write);
 	}
 
  out:
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 63abda1ac06d..bdff35e90889 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_GENERIC_PGTABLE_H
 #define _ASM_GENERIC_PGTABLE_H
 
+#include <linux/pfn.h>
+
 #ifndef __ASSEMBLY__
 #ifdef CONFIG_MMU
 
@@ -549,7 +551,7 @@ static inline int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
  * by vm_insert_pfn().
  */
 static inline int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
-				   unsigned long pfn)
+				   pfn_t pfn)
 {
 	return 0;
 }
@@ -577,7 +579,7 @@ extern int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
 			   unsigned long pfn, unsigned long addr,
 			   unsigned long size);
 extern int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
-			    unsigned long pfn);
+			    pfn_t pfn);
 extern int track_pfn_copy(struct vm_area_struct *vma);
 extern void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
 			unsigned long size);
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 0160201993d4..8ca35a131904 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -37,7 +37,7 @@ extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, pgprot_t newprot,
 			int prot_numa);
 int vmf_insert_pfn_pmd(struct vm_area_struct *, unsigned long addr, pmd_t *,
-			unsigned long pfn, bool write);
+			pfn_t pfn, bool write);
 
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
diff --git a/include/linux/pfn_t.h b/include/linux/pfn_t.h
index bdaa275d7623..0703b5360d31 100644
--- a/include/linux/pfn_t.h
+++ b/include/linux/pfn_t.h
@@ -77,6 +77,13 @@ static inline pte_t pfn_t_pte(pfn_t pfn, pgprot_t pgprot)
 }
 #endif
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static inline pmd_t pfn_t_pmd(pfn_t pfn, pgprot_t pgprot)
+{
+	return pfn_pmd(pfn_t_to_pfn(pfn), pgprot);
+}
+#endif
+
 #ifdef __HAVE_ARCH_PTE_DEVMAP
 static inline bool pfn_t_devmap(pfn_t pfn)
 {
@@ -90,5 +97,6 @@ static inline bool pfn_t_devmap(pfn_t pfn)
 	return false;
 }
 pte_t pte_mkdevmap(pte_t pte);
+pmd_t pmd_mkdevmap(pmd_t pmd);
 #endif
 #endif /* _LINUX_PFN_T_H_ */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a4bfeb07394b..7356857d7356 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -20,6 +20,7 @@
 #include <linux/kthread.h>
 #include <linux/khugepaged.h>
 #include <linux/freezer.h>
+#include <linux/pfn_t.h>
 #include <linux/mman.h>
 #include <linux/pagemap.h>
 #include <linux/migrate.h>
@@ -960,14 +961,16 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 }
 
 static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
-		pmd_t *pmd, unsigned long pfn, pgprot_t prot, bool write)
+		pmd_t *pmd, pfn_t pfn, pgprot_t prot, bool write)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pmd_t entry;
 	spinlock_t *ptl;
 
 	ptl = pmd_lock(mm, pmd);
-	entry = pmd_mkhuge(pfn_pmd(pfn, prot));
+	entry = pmd_mkhuge(pfn_t_pmd(pfn, prot));
+	if (pfn_t_devmap(pfn))
+		entry = pmd_mkdevmap(entry);
 	if (write) {
 		entry = pmd_mkyoung(pmd_mkdirty(entry));
 		entry = maybe_pmd_mkwrite(entry, vma);
@@ -978,7 +981,7 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 }
 
 int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
-			pmd_t *pmd, unsigned long pfn, bool write)
+			pmd_t *pmd, pfn_t pfn, bool write)
 {
 	pgprot_t pgprot = vma->vm_page_prot;
 	/*
@@ -990,7 +993,7 @@ int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 	BUG_ON((vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) ==
 						(VM_PFNMAP|VM_MIXEDMAP));
 	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
-	BUG_ON((vma->vm_flags & VM_MIXEDMAP) && pfn_valid(pfn));
+	BUG_ON(!pfn_t_devmap(pfn));
 
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return VM_FAULT_SIGBUS;
diff --git a/mm/memory.c b/mm/memory.c
index d328ea7542b1..9483d2b1dd3b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1567,7 +1567,7 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return -EFAULT;
-	if (track_pfn_insert(vma, &pgprot, pfn))
+	if (track_pfn_insert(vma, &pgprot, __pfn_to_pfn_t(pfn, PFN_DEV)))
 		return -EINVAL;
 
 	ret = insert_pfn(vma, addr, __pfn_to_pfn_t(pfn, PFN_DEV), pgprot);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
