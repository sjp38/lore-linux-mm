Message-ID: <3E65307F.7040008@us.ibm.com>
Date: Tue, 04 Mar 2003 15:02:23 -0800
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: [PATCH] remove __pmd_offset
References: <3E653012.5040503@us.ibm.com>
Content-Type: multipart/mixed;
 boundary="------------080505050205080200090405"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------080505050205080200090405
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Same thing as the __pgd_offset one, just for pmds this time to keep the
naming consistent.
-- 
Dave Hansen
haveblue@us.ibm.com

--------------080505050205080200090405
Content-Type: text/plain;
 name="pmdindex-2.5.63-0.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pmdindex-2.5.63-0.patch"

diff -ru linux-2.5.63-pgdindex/arch/i386/mm/init.c linux-2.5.63-pmdindex/arch/i386/mm/init.c
--- linux-2.5.63-pgdindex/arch/i386/mm/init.c	Tue Mar  4 14:38:43 2003
+++ linux-2.5.63-pmdindex/arch/i386/mm/init.c	Tue Mar  4 14:40:45 2003
@@ -98,12 +98,12 @@
 {
 	pgd_t *pgd;
 	pmd_t *pmd;
-	int pgd_idx, pmd_ofs;
+	int pgd_idx, pmd_idx;
 	unsigned long vaddr;
 
 	vaddr = start;
 	pgd_idx = pgd_index(vaddr);
-	pmd_ofs = __pmd_offset(vaddr);
+	pmd_idx = pmd_index(vaddr);
 	pgd = pgd_base + pgd_idx;
 
 	for ( ; (pgd_idx < PTRS_PER_PGD) && (vaddr != end); pgd++, pgd_idx++) {
@@ -111,13 +111,13 @@
 			one_md_table_init(pgd);
 
 		pmd = pmd_offset(pgd, vaddr);
-		for (; (pmd_ofs < PTRS_PER_PMD) && (vaddr != end); pmd++, pmd_ofs++) {
+		for (; (pmd_idx < PTRS_PER_PMD) && (vaddr != end); pmd++, pmd_idx++) {
 			if (pmd_none(*pmd)) 
 				one_page_table_init(pmd);
 
 			vaddr += PMD_SIZE;
 		}
-		pmd_ofs = 0;
+		pmd_idx = 0;
 	}
 }
 
@@ -132,7 +132,7 @@
 	pgd_t *pgd;
 	pmd_t *pmd;
 	pte_t *pte;
-	int pgd_idx, pmd_ofs, pte_ofs;
+	int pgd_idx, pmd_idx, pte_ofs;
 
 	pgd_idx = pgd_index(PAGE_OFFSET);
 	pgd = pgd_base + pgd_idx;
@@ -142,7 +142,7 @@
 		pmd = one_md_table_init(pgd);
 		if (pfn >= max_low_pfn)
 			continue;
-		for (pmd_ofs = 0; pmd_ofs < PTRS_PER_PMD && pfn < max_low_pfn; pmd++, pmd_ofs++) {
+		for (pmd_idx = 0; pmd_idx < PTRS_PER_PMD && pfn < max_low_pfn; pmd++, pmd_idx++) {
 			/* Map with big pages if possible, otherwise create normal page tables. */
 			if (cpu_has_pse) {
 				set_pmd(pmd, pfn_pmd(pfn, PAGE_KERNEL_LARGE));
diff -ru linux-2.5.63-pgdindex/arch/um/kernel/mem.c linux-2.5.63-pmdindex/arch/um/kernel/mem.c
--- linux-2.5.63-pgdindex/arch/um/kernel/mem.c	Tue Mar  4 14:34:13 2003
+++ linux-2.5.63-pmdindex/arch/um/kernel/mem.c	Tue Mar  4 14:40:54 2003
@@ -155,7 +155,7 @@
 
 	vaddr = start;
 	i = pgd_index(vaddr);
-	j = __pmd_offset(vaddr);
+	j = pmd_index(vaddr);
 	pgd = pgd_base + i;
 
 	for ( ; (i < PTRS_PER_PGD) && (vaddr < end); pgd++, i++) {
Only in linux-2.5.63-pmdindex/include/asm-i386: .pgtable.h.swp
diff -ru linux-2.5.63-pgdindex/include/asm-i386/pgtable-3level.h linux-2.5.63-pmdindex/include/asm-i386/pgtable-3level.h
--- linux-2.5.63-pgdindex/include/asm-i386/pgtable-3level.h	Tue Mar  4 14:23:09 2003
+++ linux-2.5.63-pmdindex/include/asm-i386/pgtable-3level.h	Tue Mar  4 14:41:30 2003
@@ -69,7 +69,7 @@
 
 /* Find an entry in the second-level page table.. */
 #define pmd_offset(dir, address) ((pmd_t *) pgd_page(*(dir)) + \
-			__pmd_offset(address))
+			pmd_index(address))
 
 static inline pte_t ptep_get_and_clear(pte_t *ptep)
 {
diff -ru linux-2.5.63-pgdindex/include/asm-i386/pgtable.h linux-2.5.63-pmdindex/include/asm-i386/pgtable.h
--- linux-2.5.63-pgdindex/include/asm-i386/pgtable.h	Tue Mar  4 14:24:36 2003
+++ linux-2.5.63-pmdindex/include/asm-i386/pgtable.h	Tue Mar  4 14:39:45 2003
@@ -241,7 +241,7 @@
 /* to find an entry in a kernel page-table-directory */
 #define pgd_offset_k(address) pgd_offset(&init_mm, address)
 
-#define __pmd_offset(address) \
+#define pmd_index(address) \
 		(((address) >> PMD_SHIFT) & (PTRS_PER_PMD-1))
 
 /* Find an entry in the third-level page table.. */
diff -ru linux-2.5.63-pgdindex/include/asm-s390x/pgtable.h linux-2.5.63-pmdindex/include/asm-s390x/pgtable.h
--- linux-2.5.63-pgdindex/include/asm-s390x/pgtable.h	Tue Mar  4 14:23:08 2003
+++ linux-2.5.63-pmdindex/include/asm-s390x/pgtable.h	Tue Mar  4 14:41:35 2003
@@ -488,9 +488,9 @@
 #define pgd_offset_k(address) pgd_offset(&init_mm, address)
 
 /* Find an entry in the second-level page table.. */
-#define __pmd_offset(address) (((address) >> PMD_SHIFT) & (PTRS_PER_PMD-1))
+#define pmd_index(address) (((address) >> PMD_SHIFT) & (PTRS_PER_PMD-1))
 #define pmd_offset(dir,addr) \
-	((pmd_t *) pgd_page_kernel(*(dir)) + __pmd_offset(addr))
+	((pmd_t *) pgd_page_kernel(*(dir)) + pmd_index(addr))
 
 /* Find an entry in the third-level page table.. */
 #define __pte_offset(address) (((address) >> PAGE_SHIFT) & (PTRS_PER_PTE-1))
diff -ru linux-2.5.63-pgdindex/include/asm-um/pgtable.h linux-2.5.63-pmdindex/include/asm-um/pgtable.h
--- linux-2.5.63-pgdindex/include/asm-um/pgtable.h	Tue Mar  4 14:32:42 2003
+++ linux-2.5.63-pmdindex/include/asm-um/pgtable.h	Tue Mar  4 14:39:54 2003
@@ -365,7 +365,7 @@
 /* to find an entry in a kernel page-table-directory */
 #define pgd_offset_k(address) pgd_offset(&init_mm, address)
 
-#define __pmd_offset(address) \
+#define pmd_index(address) \
 		(((address) >> PMD_SHIFT) & (PTRS_PER_PMD-1))
 
 /* Find an entry in the second-level page table.. */
diff -ru linux-2.5.63-pgdindex/include/asm-x86_64/pgtable.h linux-2.5.63-pmdindex/include/asm-x86_64/pgtable.h
--- linux-2.5.63-pgdindex/include/asm-x86_64/pgtable.h	Tue Mar  4 14:23:09 2003
+++ linux-2.5.63-pmdindex/include/asm-x86_64/pgtable.h	Tue Mar  4 14:41:38 2003
@@ -321,9 +321,9 @@
 #define pmd_page_kernel(pmd) ((unsigned long) __va(pmd_val(pmd) & PTE_MASK))
 #define pmd_page(pmd)		(pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
 
-#define __pmd_offset(address) (((address) >> PMD_SHIFT) & (PTRS_PER_PMD-1))
+#define pmd_index(address) (((address) >> PMD_SHIFT) & (PTRS_PER_PMD-1))
 #define pmd_offset(dir, address) ((pmd_t *) pgd_page(*(dir)) + \
-			__pmd_offset(address))
+			pmd_index(address))
 #define pmd_none(x)	(!pmd_val(x))
 #define pmd_present(x)	(pmd_val(x) & _PAGE_PRESENT)
 #define pmd_clear(xp)	do { set_pmd(xp, __pmd(0)); } while (0)

--------------080505050205080200090405--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
