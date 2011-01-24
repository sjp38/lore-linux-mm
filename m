Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 19B316B00EB
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 17:56:23 -0500 (EST)
From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: [PATCH 2/9] mm: add apply_to_page_range_batch()
Date: Mon, 24 Jan 2011 14:56:00 -0800
Message-Id: <7f635db45f8e921c9203fdfb904d0095b7af6480.1295653400.git.jeremy.fitzhardinge@citrix.com>
In-Reply-To: <cover.1295653400.git.jeremy.fitzhardinge@citrix.com>
References: <cover.1295653400.git.jeremy.fitzhardinge@citrix.com>
In-Reply-To: <cover.1295653400.git.jeremy.fitzhardinge@citrix.com>
References: <cover.1295653400.git.jeremy.fitzhardinge@citrix.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Haavard Skinnemoen <hskinnemoen@atmel.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@kernel.dk>, Xen-devel <xen-devel@lists.xensource.com>, Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
List-ID: <linux-mm.kvack.org>

From: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>

apply_to_page_range() calls its callback function once for each pte, which
is pretty inefficient since it will almost always be operating on a batch
of adjacent ptes.  apply_to_page_range_batch() calls its callback
with both a pte_t * and a count, so it can operate on multiple ptes at
once.

The callback is expected to handle all its ptes, or return an error.  For
both apply_to_page_range and apply_to_page_range_batch, it is up to
the caller to work out how much progress was made if either fails with
an error.

Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
---
 include/linux/mm.h |    6 +++++
 mm/memory.c        |   57 +++++++++++++++++++++++++++++++++++++--------------
 2 files changed, 47 insertions(+), 16 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index bb898ec..5a32a8a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1533,6 +1533,12 @@ typedef int (*pte_fn_t)(pte_t *pte, unsigned long addr, void *data);
 extern int apply_to_page_range(struct mm_struct *mm, unsigned long address,
 			       unsigned long size, pte_fn_t fn, void *data);
 
+typedef int (*pte_batch_fn_t)(pte_t *pte, unsigned count,
+			      unsigned long addr, void *data);
+extern int apply_to_page_range_batch(struct mm_struct *mm,
+				     unsigned long address, unsigned long size,
+				     pte_batch_fn_t fn, void *data);
+
 #ifdef CONFIG_PROC_FS
 void vm_stat_account(struct mm_struct *, unsigned long, struct file *, long);
 #else
diff --git a/mm/memory.c b/mm/memory.c
index 740470c..496e4e6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2012,11 +2012,10 @@ EXPORT_SYMBOL(remap_pfn_range);
 
 static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
 				     unsigned long addr, unsigned long end,
-				     pte_fn_t fn, void *data)
+				     pte_batch_fn_t fn, void *data)
 {
 	pte_t *pte;
 	int err;
-	pgtable_t token;
 	spinlock_t *uninitialized_var(ptl);
 
 	pte = (mm == &init_mm) ?
@@ -2028,25 +2027,17 @@ static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
 	BUG_ON(pmd_huge(*pmd));
 
 	arch_enter_lazy_mmu_mode();
-
-	token = pmd_pgtable(*pmd);
-
-	do {
-		err = fn(pte++, addr, data);
-		if (err)
-			break;
-	} while (addr += PAGE_SIZE, addr != end);
-
+	err = fn(pte, (end - addr) / PAGE_SIZE, addr, data);
 	arch_leave_lazy_mmu_mode();
 
 	if (mm != &init_mm)
-		pte_unmap_unlock(pte-1, ptl);
+		pte_unmap_unlock(pte, ptl);
 	return err;
 }
 
 static int apply_to_pmd_range(struct mm_struct *mm, pud_t *pud,
 				     unsigned long addr, unsigned long end,
-				     pte_fn_t fn, void *data)
+				     pte_batch_fn_t fn, void *data)
 {
 	pmd_t *pmd;
 	unsigned long next;
@@ -2068,7 +2059,7 @@ static int apply_to_pmd_range(struct mm_struct *mm, pud_t *pud,
 
 static int apply_to_pud_range(struct mm_struct *mm, pgd_t *pgd,
 				     unsigned long addr, unsigned long end,
-				     pte_fn_t fn, void *data)
+				     pte_batch_fn_t fn, void *data)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -2090,8 +2081,9 @@ static int apply_to_pud_range(struct mm_struct *mm, pgd_t *pgd,
  * Scan a region of virtual memory, filling in page tables as necessary
  * and calling a provided function on each leaf page table.
  */
-int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
-			unsigned long size, pte_fn_t fn, void *data)
+int apply_to_page_range_batch(struct mm_struct *mm,
+			      unsigned long addr, unsigned long size,
+			      pte_batch_fn_t fn, void *data)
 {
 	pgd_t *pgd;
 	unsigned long next;
@@ -2109,6 +2101,39 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
 
 	return err;
 }
+EXPORT_SYMBOL_GPL(apply_to_page_range_batch);
+
+struct pte_single_fn
+{
+	pte_fn_t fn;
+	void *data;
+};
+
+static int apply_pte_batch(pte_t *pte, unsigned count,
+			   unsigned long addr, void *data)
+{
+	struct pte_single_fn *single = data;
+	int err = 0;
+
+	while (count--) {
+		err = single->fn(pte, addr, single->data);
+		if (err)
+			break;
+
+		addr += PAGE_SIZE;
+		pte++;
+	}
+
+	return err;
+}
+
+int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
+			unsigned long size, pte_fn_t fn, void *data)
+{
+	struct pte_single_fn single = { .fn = fn, .data = data };
+	return apply_to_page_range_batch(mm, addr, size,
+					 apply_pte_batch, &single);
+}
 EXPORT_SYMBOL_GPL(apply_to_page_range);
 
 /*
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
