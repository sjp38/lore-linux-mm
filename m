Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1DAAB900123
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 04:23:07 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp03.au.ibm.com (8.14.4/8.13.1) with ESMTP id p658HtMr029767
	for <linux-mm@kvack.org>; Tue, 5 Jul 2011 18:17:55 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p658N3C2774360
	for <linux-mm@kvack.org>; Tue, 5 Jul 2011 18:23:03 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p658N2PX029854
	for <linux-mm@kvack.org>; Tue, 5 Jul 2011 18:23:02 +1000
From: Ankita Garg <ankita@in.ibm.com>
Subject: [PATCH 3/5] Capture kernel memory references
Date: Tue,  5 Jul 2011 13:52:37 +0530
Message-Id: <1309854159-8277-4-git-send-email-ankita@in.ibm.com>
In-Reply-To: <1309854159-8277-1-git-send-email-ankita@in.ibm.com>
References: <1309854159-8277-1-git-send-email-ankita@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: ankita@in.ibm.com, svaidy@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

Hi,

This patch introduces code to traverse the kernel page tables, starting from
the highest level pgdir table in init_level4_pgt.

Signed-off-by: Ankita Garg <ankita@in.ibm.com>
---
 arch/x86/include/asm/pgtable_64.h |    1 +
 drivers/misc/memref.c             |    1 +
 include/linux/memtrace.h          |    1 +
 lib/memtrace.c                    |   95 +++++++++++++++++++++++++++++++++++++
 4 files changed, 98 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 975f709..09c99e0 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -13,6 +13,7 @@
 #include <asm/processor.h>
 #include <linux/bitops.h>
 #include <linux/threads.h>
+#include <linux/module.h>
 
 extern pud_t level3_kernel_pgt[512];
 extern pud_t level3_ident_pgt[512];
diff --git a/drivers/misc/memref.c b/drivers/misc/memref.c
index 4e8785f..abf8b23 100644
--- a/drivers/misc/memref.c
+++ b/drivers/misc/memref.c
@@ -152,6 +152,7 @@ static int memref_thread(void *data)
 		seq = inc_seq_number();
 
 		walk_tasks(task);
+		kernel_mapping_ref();
 		update_and_log_data();
 		msleep(interval);
 	}
diff --git a/include/linux/memtrace.h b/include/linux/memtrace.h
index 0fa15e0..b1fce57 100644
--- a/include/linux/memtrace.h
+++ b/include/linux/memtrace.h
@@ -24,6 +24,7 @@ unsigned int inc_seq_number(void);
 void set_memtrace_block_sz(int sz);
 void mark_memtrace_block_accessed(unsigned long paddr);
 void init_memtrace_blocks(void);
+void kernel_mapping_ref(void);
 void update_and_log_data(void);
 
 #endif /* _LINUX_MEMTRACE_H */
diff --git a/lib/memtrace.c b/lib/memtrace.c
index 5ebd7c8..aec5b65 100644
--- a/lib/memtrace.c
+++ b/lib/memtrace.c
@@ -72,6 +72,101 @@ void set_memtrace_block_sz(int sz)
 }
 EXPORT_SYMBOL_GPL(set_memtrace_block_sz);
 
+#define PTE_LEVEL_MULT (PAGE_SIZE)
+#define PMD_LEVEL_MULT (PTRS_PER_PTE * PTE_LEVEL_MULT)
+#define PUD_LEVEL_MULT (PTRS_PER_PMD * PMD_LEVEL_MULT)
+#define PGD_LEVEL_MULT (PTRS_PER_PUD * PUD_LEVEL_MULT)
+
+static void walk_k_pte_level(pmd_t pmd, unsigned long addr)
+ {
+ 	pte_t *pte;
+ 	int i, ret;
+	unsigned long pfn;
+	struct page *pg;
+
+	pte = (pte_t*) pmd_page_vaddr(pmd);
+
+ 	for (i = 0; i < PTRS_PER_PTE; i++, pte++) {
+ 		if(!pte_present(*pte) && pte_none(*pte) && pte_huge(*pte))
+			continue;
+
+		pfn = pte_pfn(*pte);
+		if(pfn_valid(pfn) && pte_young(*pte)) {
+			ret = test_and_clear_bit(_PAGE_BIT_ACCESSED,
+						(unsigned long *) &pte->pte);
+			if (ret) {
+				pg = pfn_to_page(pfn);
+				ClearPageReferenced(pg);
+				mark_memtrace_block_accessed(pfn << PAGE_SHIFT);
+			}
+		}
+ 	}
+}
+
+#if PTRS_PER_PMD > 1
+
+static void walk_k_pmd_level(pud_t pud, unsigned long addr)
+ {
+ 	pmd_t *pmd;
+ 	int i;
+
+ 	pmd = (pmd_t *) pud_page_vaddr(pud);
+
+ 	for (i = 0; i < PTRS_PER_PMD; i++) {
+
+ 		if(!pmd_none(*pmd) && pmd_present(*pmd) && !pmd_large(*pmd))
+			walk_k_pte_level(*pmd, addr + i * PMD_LEVEL_MULT);
+
+ 		pmd++;
+ 	}
+ }
+
+#else
+#define walk_pmd_level(p,a) walk_pte_level(__pmd(pud_val(p)),a)
+#define pud_none(a)  pmd_none(__pmd(pud_val(a)))
+#define pud_large(a) pmd_large(__pmd(pud_val(a)))
+#endif
+
+#if PTRS_PER_PUD > 1
+
+static void walk_k_pud_level(pgd_t pgd, unsigned long addr)
+ {
+ 	pud_t *pud;
+ 	int i;
+
+ 	pud = (pud_t *) pgd_page_vaddr(pgd);
+
+ 	for (i = 0; i < PTRS_PER_PUD; i++) {
+
+ 		if(!pud_none(*pud) && pud_present(*pud) && !pud_large(*pud))
+ 			walk_k_pmd_level(*pud, addr + i * PUD_LEVEL_MULT);
+ 		pud++;
+ 	}
+ }
+
+#else
+#define walk_pud_level(p,a) walk_pmd_level(__pud(pgd_val(p)),a)
+#define pgd_none(a)  pud_none(__pud(pgd_val(a)))
+#define pgd_large(a) pud_large(__pud(pgd_val(a)))
+#endif
+
+void kernel_mapping_ref(void)
+{
+ 	pgd_t *pgd;
+ 	int i;
+
+        pgd = (pgd_t *) &init_level4_pgt;
+
+ 	for (i=0; i < PTRS_PER_PGD; i++) {
+
+ 		if(!pgd_none(*pgd) && pgd_present(*pgd) && !pgd_large(*pgd)) {
+ 			walk_k_pud_level(*pgd, i * PGD_LEVEL_MULT);
+		}
+ 		pgd++;
+ 	}
+}
+EXPORT_SYMBOL_GPL(kernel_mapping_ref);
+
 void mark_memtrace_block_accessed(unsigned long paddr)
  {
 	int memtrace_block;
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
