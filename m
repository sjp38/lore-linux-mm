Message-ID: <3E653012.5040503@us.ibm.com>
Date: Tue, 04 Mar 2003 15:00:34 -0800
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: [PATCH] remove __pgd_offset
Content-Type: multipart/mixed;
 boundary="------------050607090202010209030708"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050607090202010209030708
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

__pgd_offset() and pgd_offset() are completely different functions.
__pgd_offset() is really just a helper to figure out which entry in a
pgd an address would fall into.   pgd_offset() does all the leg work and
actually fetches the real pgd entry.

pgd_index() is a much saner name for what __pgd_offset() does.  In fact,
we do this:
#define __pgd_offset(address) pgd_index(address)

The attached patch removes all instances of __pgd_offset and just
replaces them with pgd_index.

Compiles with and without PAE on x86.
-- 
Dave Hansen
haveblue@us.ibm.com

--------------050607090202010209030708
Content-Type: text/plain;
 name="pgdindex-2.5.63-0.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pgdindex-2.5.63-0.patch"

diff -ur ../linux-2.5.63-clean/arch/alpha/mm/fault.c linux-2.5.63-pgdindex/arch/alpha/mm/fault.c
--- ../linux-2.5.63-clean/arch/alpha/mm/fault.c	Mon Feb 24 11:05:14 2003
+++ linux-2.5.63-pgdindex/arch/alpha/mm/fault.c	Tue Mar  4 14:33:00 2003
@@ -232,11 +232,11 @@
 	else {
 		/* Synchronize this task's top level page-table
 		   with the "reference" page table from init.  */
-		long offset = __pgd_offset(address);
+		long index = pgd_index(address);
 		pgd_t *pgd, *pgd_k;
 
-		pgd = current->active_mm->pgd + offset;
-		pgd_k = swapper_pg_dir + offset;
+		pgd = current->active_mm->pgd + index;
+		pgd_k = swapper_pg_dir + index;
 		if (!pgd_present(*pgd) && pgd_present(*pgd_k)) {
 			pgd_val(*pgd) = pgd_val(*pgd_k);
 			return;
diff -ur ../linux-2.5.63-clean/arch/arm/mm/fault-common.c linux-2.5.63-pgdindex/arch/arm/mm/fault-common.c
--- ../linux-2.5.63-clean/arch/arm/mm/fault-common.c	Mon Feb 24 11:05:34 2003
+++ linux-2.5.63-pgdindex/arch/arm/mm/fault-common.c	Tue Mar  4 14:33:42 2003
@@ -342,20 +342,20 @@
 			 struct pt_regs *regs)
 {
 	struct task_struct *tsk;
-	unsigned int offset;
+	unsigned int index;
 	pgd_t *pgd, *pgd_k;
 	pmd_t *pmd, *pmd_k;
 
 	if (addr < TASK_SIZE)
 		return do_page_fault(addr, fsr, regs);
 
-	offset = __pgd_offset(addr);
+	index = pgd_index(addr);
 
 	/*
 	 * FIXME: CP15 C1 is write only on ARMv3 architectures.
 	 */
-	pgd = cpu_get_pgd() + offset;
-	pgd_k = init_mm.pgd + offset;
+	pgd = cpu_get_pgd() + index;
+	pgd_k = init_mm.pgd + index;
 
 	if (pgd_none(*pgd_k))
 		goto bad_area;
diff -ur ../linux-2.5.63-clean/arch/i386/mm/fault.c linux-2.5.63-pgdindex/arch/i386/mm/fault.c
--- ../linux-2.5.63-clean/arch/i386/mm/fault.c	Mon Feb 24 11:05:04 2003
+++ linux-2.5.63-pgdindex/arch/i386/mm/fault.c	Tue Mar  4 14:25:06 2003
@@ -394,14 +394,14 @@
 		 * Do _not_ use "tsk" here. We might be inside
 		 * an interrupt in the middle of a task switch..
 		 */
-		int offset = __pgd_offset(address);
+		int index = pgd_index(address);
 		pgd_t *pgd, *pgd_k;
 		pmd_t *pmd, *pmd_k;
 		pte_t *pte_k;
 
 		asm("movl %%cr3,%0":"=r" (pgd));
-		pgd = offset + (pgd_t *)__va(pgd);
-		pgd_k = init_mm.pgd + offset;
+		pgd = index + (pgd_t *)__va(pgd);
+		pgd_k = init_mm.pgd + index;
 
 		if (!pgd_present(*pgd_k))
 			goto no_context;
diff -ur ../linux-2.5.63-clean/arch/i386/mm/init.c linux-2.5.63-pgdindex/arch/i386/mm/init.c
--- ../linux-2.5.63-clean/arch/i386/mm/init.c	Mon Feb 24 11:05:39 2003
+++ linux-2.5.63-pgdindex/arch/i386/mm/init.c	Tue Mar  4 14:38:43 2003
@@ -98,15 +98,15 @@
 {
 	pgd_t *pgd;
 	pmd_t *pmd;
-	int pgd_ofs, pmd_ofs;
+	int pgd_idx, pmd_ofs;
 	unsigned long vaddr;
 
 	vaddr = start;
-	pgd_ofs = __pgd_offset(vaddr);
+	pgd_idx = pgd_index(vaddr);
 	pmd_ofs = __pmd_offset(vaddr);
-	pgd = pgd_base + pgd_ofs;
+	pgd = pgd_base + pgd_idx;
 
-	for ( ; (pgd_ofs < PTRS_PER_PGD) && (vaddr != end); pgd++, pgd_ofs++) {
+	for ( ; (pgd_idx < PTRS_PER_PGD) && (vaddr != end); pgd++, pgd_idx++) {
 		if (pgd_none(*pgd)) 
 			one_md_table_init(pgd);
 
@@ -132,13 +132,13 @@
 	pgd_t *pgd;
 	pmd_t *pmd;
 	pte_t *pte;
-	int pgd_ofs, pmd_ofs, pte_ofs;
+	int pgd_idx, pmd_ofs, pte_ofs;
 
-	pgd_ofs = __pgd_offset(PAGE_OFFSET);
-	pgd = pgd_base + pgd_ofs;
+	pgd_idx = pgd_index(PAGE_OFFSET);
+	pgd = pgd_base + pgd_idx;
 	pfn = 0;
 
-	for (; pgd_ofs < PTRS_PER_PGD; pgd++, pgd_ofs++) {
+	for (; pgd_idx < PTRS_PER_PGD; pgd++, pgd_idx++) {
 		pmd = one_md_table_init(pgd);
 		if (pfn >= max_low_pfn)
 			continue;
@@ -214,7 +214,7 @@
 	vaddr = PKMAP_BASE;
 	page_table_range_init(vaddr, vaddr + PAGE_SIZE*LAST_PKMAP, pgd_base);
 
-	pgd = swapper_pg_dir + __pgd_offset(vaddr);
+	pgd = swapper_pg_dir + pgd_index(vaddr);
 	pmd = pmd_offset(pgd, vaddr);
 	pte = pte_offset_kernel(pmd, vaddr);
 	pkmap_page_table = pte;	
diff -ur ../linux-2.5.63-clean/arch/i386/mm/pgtable.c linux-2.5.63-pgdindex/arch/i386/mm/pgtable.c
--- ../linux-2.5.63-clean/arch/i386/mm/pgtable.c	Mon Feb 24 11:06:03 2003
+++ linux-2.5.63-pgdindex/arch/i386/mm/pgtable.c	Tue Mar  4 14:28:05 2003
@@ -63,7 +63,7 @@
 	pmd_t *pmd;
 	pte_t *pte;
 
-	pgd = swapper_pg_dir + __pgd_offset(vaddr);
+	pgd = swapper_pg_dir + pgd_index(vaddr);
 	if (pgd_none(*pgd)) {
 		BUG();
 		return;
@@ -103,7 +103,7 @@
 		printk ("set_pmd_pfn: pfn misaligned\n");
 		return; /* BUG(); */
 	}
-	pgd = swapper_pg_dir + __pgd_offset(vaddr);
+	pgd = swapper_pg_dir + pgd_index(vaddr);
 	if (pgd_none(*pgd)) {
 		printk ("set_pmd_pfn: pgd_none\n");
 		return; /* BUG(); */
diff -ur ../linux-2.5.63-clean/arch/um/kernel/mem.c linux-2.5.63-pgdindex/arch/um/kernel/mem.c
--- ../linux-2.5.63-clean/arch/um/kernel/mem.c	Mon Feb 24 11:05:16 2003
+++ linux-2.5.63-pgdindex/arch/um/kernel/mem.c	Tue Mar  4 14:34:13 2003
@@ -154,7 +154,7 @@
 	unsigned long vaddr;
 
 	vaddr = start;
-	i = __pgd_offset(vaddr);
+	i = pgd_index(vaddr);
 	j = __pmd_offset(vaddr);
 	pgd = pgd_base + i;
 
@@ -257,7 +257,7 @@
 	vaddr = PKMAP_BASE;
 	fixrange_init(vaddr, vaddr + PAGE_SIZE*LAST_PKMAP, swapper_pg_dir);
 
-	pgd = swapper_pg_dir + __pgd_offset(vaddr);
+	pgd = swapper_pg_dir + pgd_index(vaddr);
 	pmd = pmd_offset(pgd, vaddr);
 	pte = pte_offset_kernel(pmd, vaddr);
 	pkmap_page_table = pte;
diff -ur ../linux-2.5.63-clean/include/asm-alpha/pgtable.h linux-2.5.63-pgdindex/include/asm-alpha/pgtable.h
--- ../linux-2.5.63-clean/include/asm-alpha/pgtable.h	Mon Feb 24 11:05:14 2003
+++ linux-2.5.63-pgdindex/include/asm-alpha/pgtable.h	Tue Mar  4 14:32:31 2003
@@ -273,7 +273,6 @@
 
 /* to find an entry in a page-table-directory. */
 #define pgd_index(address)	((address >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1))
-#define __pgd_offset(address)	pgd_index(address)
 #define pgd_offset(mm, address)	((mm)->pgd+pgd_index(address))
 
 /* Find an entry in the second-level page table.. */
diff -ur ../linux-2.5.63-clean/include/asm-arm/pgtable.h linux-2.5.63-pgdindex/include/asm-arm/pgtable.h
--- ../linux-2.5.63-clean/include/asm-arm/pgtable.h	Mon Feb 24 11:05:14 2003
+++ linux-2.5.63-pgdindex/include/asm-arm/pgtable.h	Tue Mar  4 14:32:37 2003
@@ -116,7 +116,6 @@
 
 /* to find an entry in a page-table-directory */
 #define pgd_index(addr)		((addr) >> PGDIR_SHIFT)
-#define __pgd_offset(addr)	pgd_index(addr)
 
 #define pgd_offset(mm, addr)	((mm)->pgd+pgd_index(addr))
 
diff -ur ../linux-2.5.63-clean/include/asm-i386/pgtable.h linux-2.5.63-pgdindex/include/asm-i386/pgtable.h
--- ../linux-2.5.63-clean/include/asm-i386/pgtable.h	Mon Feb 24 11:05:39 2003
+++ linux-2.5.63-pgdindex/include/asm-i386/pgtable.h	Tue Mar  4 14:24:36 2003
@@ -236,8 +236,6 @@
 /* to find an entry in a page-table-directory. */
 #define pgd_index(address) (((address) >> PGDIR_SHIFT) & (PTRS_PER_PGD-1))
 
-#define __pgd_offset(address) pgd_index(address)
-
 #define pgd_offset(mm, address) ((mm)->pgd+pgd_index(address))
 
 /* to find an entry in a kernel page-table-directory */
diff -ur ../linux-2.5.63-clean/include/asm-sh/pgtable.h linux-2.5.63-pgdindex/include/asm-sh/pgtable.h
--- ../linux-2.5.63-clean/include/asm-sh/pgtable.h	Mon Feb 24 11:06:03 2003
+++ linux-2.5.63-pgdindex/include/asm-sh/pgtable.h	Tue Mar  4 14:32:40 2003
@@ -274,7 +274,6 @@
 
 /* to find an entry in a page-table-directory. */
 #define pgd_index(address) (((address) >> PGDIR_SHIFT) & (PTRS_PER_PGD-1))
-#define __pgd_offset(address) pgd_index(address)
 #define pgd_offset(mm, address) ((mm)->pgd+pgd_index(address))
 
 /* to find an entry in a kernel page-table-directory */
diff -ur ../linux-2.5.63-clean/include/asm-um/pgtable.h linux-2.5.63-pgdindex/include/asm-um/pgtable.h
--- ../linux-2.5.63-clean/include/asm-um/pgtable.h	Mon Feb 24 11:06:03 2003
+++ linux-2.5.63-pgdindex/include/asm-um/pgtable.h	Tue Mar  4 14:32:42 2003
@@ -357,7 +357,6 @@
 
 /* to find an entry in a page-table-directory. */
 #define pgd_index(address) ((address >> PGDIR_SHIFT) & (PTRS_PER_PGD-1))
-#define __pgd_offset(address) pgd_index(address)
 
 /* to find an entry in a page-table-directory */
 #define pgd_offset(mm, address) \

--------------050607090202010209030708--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
