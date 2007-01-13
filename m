From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:47:20 +1100
Message-Id: <20070113024720.29682.54508.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 19/29] Abstract remap pfn range
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 19
 * Move remap_pfn_range iterator implementation from memory.c to pt-default.c
 * Abstract an operator function, remap_one_pte from the iterator and
 put it into pt-iterator-ops.h

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 include/linux/pt-iterator-ops.h |   11 ++++-
 mm/memory.c                     |   79 --------------------------------------
 mm/pt-default.c                 |   83 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 94 insertions(+), 79 deletions(-)
Index: linux-2.6.20-rc4/mm/memory.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/memory.c	2007-01-11 13:37:46.832438000 +1100
+++ linux-2.6.20-rc4/mm/memory.c	2007-01-11 13:37:53.600438000 +1100
@@ -625,72 +625,6 @@
 }
 EXPORT_SYMBOL(vm_insert_page);
 
-/*
- * maps a range of physical memory into the requested pages. the old
- * mappings are removed. any references to nonexistent pages results
- * in null mappings (currently treated as "copy-on-access")
- */
-static int remap_pte_range(struct mm_struct *mm, pmd_t *pmd,
-			unsigned long addr, unsigned long end,
-			unsigned long pfn, pgprot_t prot)
-{
-	pte_t *pte;
-	spinlock_t *ptl;
-
-	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
-	if (!pte)
-		return -ENOMEM;
-	arch_enter_lazy_mmu_mode();
-	do {
-		BUG_ON(!pte_none(*pte));
-		set_pte_at(mm, addr, pte, pfn_pte(pfn, prot));
-		pfn++;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	arch_leave_lazy_mmu_mode();
-	pte_unmap_unlock(pte - 1, ptl);
-	return 0;
-}
-
-static inline int remap_pmd_range(struct mm_struct *mm, pud_t *pud,
-			unsigned long addr, unsigned long end,
-			unsigned long pfn, pgprot_t prot)
-{
-	pmd_t *pmd;
-	unsigned long next;
-
-	pfn -= addr >> PAGE_SHIFT;
-	pmd = pmd_alloc(mm, pud, addr);
-	if (!pmd)
-		return -ENOMEM;
-	do {
-		next = pmd_addr_end(addr, end);
-		if (remap_pte_range(mm, pmd, addr, next,
-				pfn + (addr >> PAGE_SHIFT), prot))
-			return -ENOMEM;
-	} while (pmd++, addr = next, addr != end);
-	return 0;
-}
-
-static inline int remap_pud_range(struct mm_struct *mm, pgd_t *pgd,
-			unsigned long addr, unsigned long end,
-			unsigned long pfn, pgprot_t prot)
-{
-	pud_t *pud;
-	unsigned long next;
-
-	pfn -= addr >> PAGE_SHIFT;
-	pud = pud_alloc(mm, pgd, addr);
-	if (!pud)
-		return -ENOMEM;
-	do {
-		next = pud_addr_end(addr, end);
-		if (remap_pmd_range(mm, pud, addr, next,
-				pfn + (addr >> PAGE_SHIFT), prot))
-			return -ENOMEM;
-	} while (pud++, addr = next, addr != end);
-	return 0;
-}
-
 /**
  * remap_pfn_range - remap kernel memory to userspace
  * @vma: user vma to map to
@@ -704,11 +638,8 @@
 int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
 		    unsigned long pfn, unsigned long size, pgprot_t prot)
 {
-	pgd_t *pgd;
-	unsigned long next;
 	unsigned long end = addr + PAGE_ALIGN(size);
 	struct mm_struct *mm = vma->vm_mm;
-	int err;
 
 	/*
 	 * Physically remapped pages are special. Tell the
@@ -738,16 +669,8 @@
 
 	BUG_ON(addr >= end);
 	pfn -= addr >> PAGE_SHIFT;
-	pgd = pgd_offset(mm, addr);
 	flush_cache_range(vma, addr, end);
-	do {
-		next = pgd_addr_end(addr, end);
-		err = remap_pud_range(mm, pgd, addr, next,
-				pfn + (addr >> PAGE_SHIFT), prot);
-		if (err)
-			break;
-	} while (pgd++, addr = next, addr != end);
-	return err;
+	return remap_build_iterator(mm, addr, end, pfn, prot);
 }
 EXPORT_SYMBOL(remap_pfn_range);
 
Index: linux-2.6.20-rc4/mm/pt-default.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/pt-default.c	2007-01-11 13:37:46.828438000 +1100
+++ linux-2.6.20-rc4/mm/pt-default.c	2007-01-11 13:37:53.600438000 +1100
@@ -561,3 +561,86 @@
 	} while (pgd++, addr = next, addr != end);
 	return 0;
 }
+
+/*
+ * maps a range of physical memory into the requested pages. the old
+ * mappings are removed. any references to nonexistent pages results
+ * in null mappings (currently treated as "copy-on-access")
+ */
+static int remap_pte_range(struct mm_struct *mm, pmd_t *pmd,
+			unsigned long addr, unsigned long end,
+			unsigned long pfn, pgprot_t prot)
+{
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
+	if (!pte)
+		return -ENOMEM;
+	arch_enter_lazy_mmu_mode();
+	do {
+		remap_one_pte(mm, pte, addr, pfn++, prot);
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	arch_leave_lazy_mmu_mode();
+	pte_unmap_unlock(pte - 1, ptl);
+	return 0;
+}
+
+static inline int remap_pmd_range(struct mm_struct *mm, pud_t *pud,
+			unsigned long addr, unsigned long end,
+			unsigned long pfn, pgprot_t prot)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pfn -= addr >> PAGE_SHIFT;
+	pmd = pmd_alloc(mm, pud, addr);
+	if (!pmd)
+		return -ENOMEM;
+	do {
+		next = pmd_addr_end(addr, end);
+		if (remap_pte_range(mm, pmd, addr, next,
+				pfn + (addr >> PAGE_SHIFT), prot))
+			return -ENOMEM;
+	} while (pmd++, addr = next, addr != end);
+	return 0;
+}
+
+static inline int remap_pud_range(struct mm_struct *mm, pgd_t *pgd,
+			unsigned long addr, unsigned long end,
+			unsigned long pfn, pgprot_t prot)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pfn -= addr >> PAGE_SHIFT;
+	pud = pud_alloc(mm, pgd, addr);
+	if (!pud)
+		return -ENOMEM;
+	do {
+		next = pud_addr_end(addr, end);
+		if (remap_pmd_range(mm, pud, addr, next,
+				pfn + (addr >> PAGE_SHIFT), prot))
+			return -ENOMEM;
+	} while (pud++, addr = next, addr != end);
+	return 0;
+}
+
+int remap_build_iterator(struct mm_struct *mm,
+		unsigned long addr, unsigned long end, unsigned long pfn,
+		pgprot_t prot)
+{
+	pgd_t *pgd;
+	unsigned long next;
+	int err;
+
+	pgd = pgd_offset(mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		err = remap_pud_range(mm, pgd, addr, next,
+				pfn + (addr >> PAGE_SHIFT), prot);
+		if (err)
+			break;
+	} while (pgd++, addr = next, addr != end);
+	return 0;
+}
Index: linux-2.6.20-rc4/include/linux/pt-iterator-ops.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/pt-iterator-ops.h	2007-01-11 13:37:46.832438000 +1100
+++ linux-2.6.20-rc4/include/linux/pt-iterator-ops.h	2007-01-11 13:37:53.612438000 +1100
@@ -78,7 +78,8 @@
 	set_pte_at(dst_mm, addr, dst_pte, pte);
 }
 
-static inline void zap_one_pte(pte_t *pte, struct mm_struct *mm, unsigned long addr,
+static inline void 
+zap_one_pte(pte_t *pte, struct mm_struct *mm, unsigned long addr,
 		struct vm_area_struct *vma, long *zap_work, struct zap_details *details,
 		struct mmu_gather *tlb, int *anon_rss, int* file_rss)
 {
@@ -157,3 +158,11 @@
 	BUG_ON(!pte_none(*pte));
 	set_pte_at(mm, addr, pte, zero_pte);
 }
+
+static inline void
+remap_one_pte(struct mm_struct *mm, pte_t *pte, unsigned long addr,
+			   unsigned long pfn, pgprot_t prot)
+{
+	BUG_ON(!pte_none(*pte));
+	set_pte_at(mm, addr, pte, pfn_pte(pfn, prot));
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
