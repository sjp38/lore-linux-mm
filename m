From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Thu, 13 Jul 2006 14:28:15 +1000
Message-Id: <20060713042815.9978.49789.sendpatchset@localhost.localdomain>
In-Reply-To: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
References: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
Subject: [PATCH 10/18] PTI - Copy iterator abstraction
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

Abstracts copy_page_range iterator from memory.c to pt_default.c

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 memory.c     |  108 +------------------------------------------------------
 pt-default.c |  114 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 116 insertions(+), 106 deletions(-)
Index: linux-2.6.17.2/mm/pt-default.c
===================================================================
--- linux-2.6.17.2.orig/mm/pt-default.c	2006-07-08 19:37:21.480345200 +1000
+++ linux-2.6.17.2/mm/pt-default.c	2006-07-08 19:39:36.358840552 +1000
@@ -285,3 +285,117 @@
 	return 0;
 }
 #endif /* __PAGETABLE_PMD_FOLDED */
+
+static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+		pmd_t *dst_pmd, pmd_t *src_pmd, struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end)
+{
+	pte_t *src_pte, *dst_pte;
+	spinlock_t *src_ptl, *dst_ptl;
+	int progress = 0;
+	int rss[2];
+
+again:
+	rss[1] = rss[0] = 0;
+	dst_pte = pte_alloc_map_lock(dst_mm, dst_pmd, addr, &dst_ptl);
+	if (!dst_pte)
+		return -ENOMEM;
+	src_pte = pte_offset_map_nested(src_pmd, addr);
+	src_ptl = pte_lockptr(src_mm, src_pmd);
+	spin_lock(src_ptl);
+
+	do {
+		/*
+		 * We are holding two locks at this point - either of them
+		 * could generate latencies in another task on another CPU.
+		 */
+		if (progress >= 32) {
+			progress = 0;
+			if (need_resched() ||
+			    need_lockbreak(src_ptl) ||
+			    need_lockbreak(dst_ptl))
+				break;
+		}
+		if (pte_none(*src_pte)) {
+			progress++;
+			continue;
+		}
+		copy_one_pte(dst_mm, src_mm, dst_pte, src_pte, vma, addr, rss);
+		progress += 8;
+	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
+
+	spin_unlock(src_ptl);
+	pte_unmap_nested(src_pte - 1);
+	add_mm_rss(dst_mm, rss[0], rss[1]);
+	pte_unmap_unlock(dst_pte - 1, dst_ptl);
+	cond_resched();
+	if (addr != end)
+		goto again;
+	return 0;
+}
+
+static inline int copy_pmd_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+		pud_t *dst_pud, pud_t *src_pud, struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end)
+{
+	pmd_t *src_pmd, *dst_pmd;
+	unsigned long next;
+
+	dst_pmd = pmd_alloc(dst_mm, dst_pud, addr);
+	if (!dst_pmd)
+		return -ENOMEM;
+	src_pmd = pmd_offset(src_pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(src_pmd))
+			continue;
+		if (copy_pte_range(dst_mm, src_mm, dst_pmd, src_pmd,
+						vma, addr, next))
+			return -ENOMEM;
+	} while (dst_pmd++, src_pmd++, addr = next, addr != end);
+	return 0;
+}
+
+static inline int copy_pud_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+		pgd_t *dst_pgd, pgd_t *src_pgd, struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end)
+{
+	pud_t *src_pud, *dst_pud;
+	unsigned long next;
+
+	dst_pud = pud_alloc(dst_mm, dst_pgd, addr);
+	if (!dst_pud)
+		return -ENOMEM;
+	src_pud = pud_offset(src_pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(src_pud))
+			continue;
+		if (copy_pmd_range(dst_mm, src_mm, dst_pud, src_pud,
+						vma, addr, next))
+			return -ENOMEM;
+	} while (dst_pud++, src_pud++, addr = next, addr != end);
+	return 0;
+}
+
+int copy_dual_iterator(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+		unsigned long addr, unsigned long end, struct vm_area_struct *vma)
+{
+	pgd_t *src_pgd;
+	pgd_t *dst_pgd;
+	unsigned long next;
+
+	dst_pgd = pgd_offset(dst_mm, addr);
+	src_pgd = pgd_offset(src_mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(src_pgd))
+			continue;
+
+		if (copy_pud_range(dst_mm, src_mm, dst_pgd,
+			src_pgd, vma, addr, next))
+			return -ENOMEM;
+
+	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
+	return 0;
+}
Index: linux-2.6.17.2/mm/memory.c
===================================================================
--- linux-2.6.17.2.orig/mm/memory.c	2006-07-08 19:37:21.480345200 +1000
+++ linux-2.6.17.2/mm/memory.c	2006-07-08 19:41:49.099660880 +1000
@@ -193,7 +193,7 @@
  * covered by this vma.
  */
 
-static inline void
+void
 copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		pte_t *dst_pte, pte_t *src_pte, struct vm_area_struct *vma,
 		unsigned long addr, int *rss)
@@ -246,103 +246,9 @@
 	set_pte_at(dst_mm, addr, dst_pte, pte);
 }
 
-static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		pmd_t *dst_pmd, pmd_t *src_pmd, struct vm_area_struct *vma,
-		unsigned long addr, unsigned long end)
-{
-	pte_t *src_pte, *dst_pte;
-	spinlock_t *src_ptl, *dst_ptl;
-	int progress = 0;
-	int rss[2];
-
-again:
-	rss[1] = rss[0] = 0;
-	dst_pte = pte_alloc_map_lock(dst_mm, dst_pmd, addr, &dst_ptl);
-	if (!dst_pte)
-		return -ENOMEM;
-	src_pte = pte_offset_map_nested(src_pmd, addr);
-	src_ptl = pte_lockptr(src_mm, src_pmd);
-	spin_lock(src_ptl);
-
-	do {
-		/*
-		 * We are holding two locks at this point - either of them
-		 * could generate latencies in another task on another CPU.
-		 */
-		if (progress >= 32) {
-			progress = 0;
-			if (need_resched() ||
-			    need_lockbreak(src_ptl) ||
-			    need_lockbreak(dst_ptl))
-				break;
-		}
-		if (pte_none(*src_pte)) {
-			progress++;
-			continue;
-		}
-		copy_one_pte(dst_mm, src_mm, dst_pte, src_pte, vma, addr, rss);
-		progress += 8;
-	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
-
-	spin_unlock(src_ptl);
-	pte_unmap_nested(src_pte - 1);
-	add_mm_rss(dst_mm, rss[0], rss[1]);
-	pte_unmap_unlock(dst_pte - 1, dst_ptl);
-	cond_resched();
-	if (addr != end)
-		goto again;
-	return 0;
-}
-
-static inline int copy_pmd_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		pud_t *dst_pud, pud_t *src_pud, struct vm_area_struct *vma,
-		unsigned long addr, unsigned long end)
-{
-	pmd_t *src_pmd, *dst_pmd;
-	unsigned long next;
-
-	dst_pmd = pmd_alloc(dst_mm, dst_pud, addr);
-	if (!dst_pmd)
-		return -ENOMEM;
-	src_pmd = pmd_offset(src_pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (pmd_none_or_clear_bad(src_pmd))
-			continue;
-		if (copy_pte_range(dst_mm, src_mm, dst_pmd, src_pmd,
-						vma, addr, next))
-			return -ENOMEM;
-	} while (dst_pmd++, src_pmd++, addr = next, addr != end);
-	return 0;
-}
-
-static inline int copy_pud_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		pgd_t *dst_pgd, pgd_t *src_pgd, struct vm_area_struct *vma,
-		unsigned long addr, unsigned long end)
-{
-	pud_t *src_pud, *dst_pud;
-	unsigned long next;
-
-	dst_pud = pud_alloc(dst_mm, dst_pgd, addr);
-	if (!dst_pud)
-		return -ENOMEM;
-	src_pud = pud_offset(src_pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(src_pud))
-			continue;
-		if (copy_pmd_range(dst_mm, src_mm, dst_pud, src_pud,
-						vma, addr, next))
-			return -ENOMEM;
-	} while (dst_pud++, src_pud++, addr = next, addr != end);
-	return 0;
-}
-
 int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		struct vm_area_struct *vma)
 {
-	pgd_t *src_pgd, *dst_pgd;
-	unsigned long next;
 	unsigned long addr = vma->vm_start;
 	unsigned long end = vma->vm_end;
 
@@ -360,17 +266,7 @@
 	if (is_vm_hugetlb_page(vma))
 		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
 
-	dst_pgd = pgd_offset(dst_mm, addr);
-	src_pgd = pgd_offset(src_mm, addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(src_pgd))
-			continue;
-		if (copy_pud_range(dst_mm, src_mm, dst_pgd, src_pgd,
-						vma, addr, next))
-			return -ENOMEM;
-	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
-	return 0;
+	return copy_dual_iterator(dst_mm, src_mm, addr, end, vma);
 }
 
 static unsigned long zap_pte_range(struct mmu_gather *tlb,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
