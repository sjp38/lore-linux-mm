Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8C0386B0075
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 15:06:42 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id p10so930378pdj.4
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 12:06:42 -0800 (PST)
Received: from psmtp.com ([74.125.245.130])
        by mx.google.com with SMTP id m9si12366340pba.233.2013.11.19.12.06.40
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 12:06:41 -0800 (PST)
From: Thomas Hellstrom <thellstrom@vmware.com>
Subject: [PATCH RFC 2/3] mm: Add a non-populating version of apply_to_page_range()
Date: Tue, 19 Nov 2013 12:06:15 -0800
Message-Id: <1384891576-7851-3-git-send-email-thellstrom@vmware.com>
In-Reply-To: <1384891576-7851-1-git-send-email-thellstrom@vmware.com>
References: <1384891576-7851-1-git-send-email-thellstrom@vmware.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: linux-graphics-maintainer@vmware.com, Thomas Hellstrom <thellstrom@vmware.com>

For some tasks, like cleaning ptes it's desirable to operate on only
populated ptes. This avoids the overhead of page table memory allocation and
also avoids memory allocation errors.

Adds apply_to_pt_range() which, in addition to apply_to_page_range(),
optionally skips the populating step. Share code with apply_to_page_range().

Signed-off-by: Thomas Hellstrom <thellstrom@vmware.com>
---
 mm/memory.c |   73 +++++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 48 insertions(+), 25 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 8ae9a6e..79178c2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2433,19 +2433,22 @@ int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long
 EXPORT_SYMBOL(vm_iomap_memory);
 
 static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
-				     unsigned long addr, unsigned long end,
-				     pte_fn_t fn, void *data)
+			      unsigned long addr, unsigned long end,
+			      pte_fn_t fn, void *data, bool fill)
 {
 	pte_t *pte;
 	int err;
 	pgtable_t token;
 	spinlock_t *uninitialized_var(ptl);
 
-	pte = (mm == &init_mm) ?
-		pte_alloc_kernel(pmd, addr) :
-		pte_alloc_map_lock(mm, pmd, addr, &ptl);
-	if (!pte)
-		return -ENOMEM;
+	if (fill) {
+		pte = (mm == &init_mm) ?
+			pte_alloc_kernel(pmd, addr) :
+			pte_alloc_map_lock(mm, pmd, addr, &ptl);
+		if (!pte)
+			return -ENOMEM;
+	} else
+		pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 
 	BUG_ON(pmd_huge(*pmd));
 
@@ -2461,27 +2464,32 @@ static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
 
 	arch_leave_lazy_mmu_mode();
 
-	if (mm != &init_mm)
+	if (!fill || mm != &init_mm)
 		pte_unmap_unlock(pte-1, ptl);
 	return err;
 }
 
 static int apply_to_pmd_range(struct mm_struct *mm, pud_t *pud,
-				     unsigned long addr, unsigned long end,
-				     pte_fn_t fn, void *data)
+			      unsigned long addr, unsigned long end,
+			      pte_fn_t fn, void *data, bool fill)
 {
 	pmd_t *pmd;
 	unsigned long next;
-	int err;
+	int err = 0;
 
 	BUG_ON(pud_huge(*pud));
 
-	pmd = pmd_alloc(mm, pud, addr);
-	if (!pmd)
-		return -ENOMEM;
+	if (fill) {
+		pmd = pmd_alloc(mm, pud, addr);
+		if (!pmd)
+			return -ENOMEM;
+	} else
+		pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
-		err = apply_to_pte_range(mm, pmd, addr, next, fn, data);
+		if (!fill && pmd_none_or_clear_bad(pmd))
+			continue;
+		err = apply_to_pte_range(mm, pmd, addr, next, fn, data, fill);
 		if (err)
 			break;
 	} while (pmd++, addr = next, addr != end);
@@ -2489,19 +2497,24 @@ static int apply_to_pmd_range(struct mm_struct *mm, pud_t *pud,
 }
 
 static int apply_to_pud_range(struct mm_struct *mm, pgd_t *pgd,
-				     unsigned long addr, unsigned long end,
-				     pte_fn_t fn, void *data)
+			      unsigned long addr, unsigned long end,
+			      pte_fn_t fn, void *data, bool fill)
 {
 	pud_t *pud;
 	unsigned long next;
-	int err;
+	int err = 0;
 
-	pud = pud_alloc(mm, pgd, addr);
-	if (!pud)
-		return -ENOMEM;
+	if (fill) {
+		pud = pud_alloc(mm, pgd, addr);
+		if (!pud)
+			return -ENOMEM;
+	} else
+		pud = pud_offset(pgd, addr);
 	do {
 		next = pud_addr_end(addr, end);
-		err = apply_to_pmd_range(mm, pud, addr, next, fn, data);
+		if (!fill && pud_none_or_clear_bad(pud))
+			continue;
+		err = apply_to_pmd_range(mm, pud, addr, next, fn, data, fill);
 		if (err)
 			break;
 	} while (pud++, addr = next, addr != end);
@@ -2512,25 +2525,35 @@ static int apply_to_pud_range(struct mm_struct *mm, pgd_t *pgd,
  * Scan a region of virtual memory, filling in page tables as necessary
  * and calling a provided function on each leaf page table.
  */
-int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
-			unsigned long size, pte_fn_t fn, void *data)
+static int apply_to_pt_range(struct mm_struct *mm, unsigned long addr,
+			     unsigned long size, pte_fn_t fn, void *data,
+			     bool fill)
 {
 	pgd_t *pgd;
 	unsigned long next;
 	unsigned long end = addr + size;
 	int err;
 
+	BUG_ON(!fill && mm == &init_mm);
 	BUG_ON(addr >= end);
+
 	pgd = pgd_offset(mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
-		err = apply_to_pud_range(mm, pgd, addr, next, fn, data);
+		err = apply_to_pud_range(mm, pgd, addr, next, fn, data,
+					 fill);
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
 
 	return err;
 }
+
+int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
+			unsigned long size, pte_fn_t fn, void *data)
+{
+	return apply_to_pt_range(mm, addr, size, fn, data, true);
+}
 EXPORT_SYMBOL_GPL(apply_to_page_range);
 
 /*
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
