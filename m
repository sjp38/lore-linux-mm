Date: Thu, 15 Mar 2001 14:50:50 -0500 (EST)
From: Ben LaHaise <bcrl@redhat.com>
Subject: [PATCH/RFC] fix missing tlb flush on x86 smp+pae
Message-ID: <Pine.LNX.4.30.0103151438140.16542-100000@today.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Linus,

Below is a patch for 2.4 (it's against 2.4.2-ac20) that fixes a case where
pmd_alloc could install a new entry without causing a tlb flush on other
CPUs.  This was fatal with PAE because the CPU caches the top level of the
page tables, which was showing up as an infinite stream of identical page
faults.  The nature of the beast was made more confusing by the fact that
the lazy tlb code makes non-threaded apps more vulnerable to this problem.
The fix is to replace __flush_tlb in pmd_alloc with flush_tlb_mm.  Let me
know what you think of this patch and any tidying you want done.  Cheers!

		-ben


diff -ur v2.4.2-ac20/fs/binfmt_elf.c test-v2.4.2-ac20/fs/binfmt_elf.c
--- v2.4.2-ac20/fs/binfmt_elf.c	Wed Mar 14 18:32:34 2001
+++ test-v2.4.2-ac20/fs/binfmt_elf.c	Wed Mar 14 18:41:06 2001
@@ -1205,7 +1205,7 @@
 			pte_t *pte;

 			pgd = pgd_offset(vma->vm_mm, addr);
-			pmd = pmd_alloc(pgd, addr);
+			pmd = pmd_alloc_mm(vma->vm_mm, pgd, addr);

 			if (!pmd)
 				goto end_coredump;
diff -ur v2.4.2-ac20/fs/exec.c test-v2.4.2-ac20/fs/exec.c
--- v2.4.2-ac20/fs/exec.c	Wed Mar 14 18:32:34 2001
+++ test-v2.4.2-ac20/fs/exec.c	Wed Mar 14 19:03:03 2001
@@ -262,7 +262,7 @@
 	if (page_count(page) != 1)
 		printk("mem_map disagrees with %p at %08lx\n", page, address);
 	pgd = pgd_offset(tsk->mm, address);
-	pmd = pmd_alloc(pgd, address);
+	pmd = pmd_alloc_mm(tsk->mm, pgd, address);
 	if (!pmd) {
 		__free_page(page);
 		force_sig(SIGKILL, tsk);
diff -ur v2.4.2-ac20/include/asm-alpha/pgalloc.h test-v2.4.2-ac20/include/asm-alpha/pgalloc.h
--- v2.4.2-ac20/include/asm-alpha/pgalloc.h	Fri Dec 29 17:07:23 2000
+++ test-v2.4.2-ac20/include/asm-alpha/pgalloc.h	Wed Mar 14 18:41:58 2001
@@ -348,6 +348,7 @@
 	return (pte_t *) pmd_page(*pmd) + address;
 }

+#define pmd_alloc_mm(mm, pgd, address)	pmd_alloc(pgd, address)
 static inline pmd_t * pmd_alloc(pgd_t *pgd, unsigned long address)
 {
 	address = (address >> PMD_SHIFT) & (PTRS_PER_PMD - 1);
diff -ur v2.4.2-ac20/include/asm-arm/pgalloc.h test-v2.4.2-ac20/include/asm-arm/pgalloc.h
--- v2.4.2-ac20/include/asm-arm/pgalloc.h	Mon Sep 18 18:15:24 2000
+++ test-v2.4.2-ac20/include/asm-arm/pgalloc.h	Wed Mar 14 18:42:21 2001
@@ -170,6 +170,7 @@
 #define pmd_free(pmd)		do { } while (0)

 #define pmd_alloc_kernel	pmd_alloc
+#define pmd_alloc_mm(mm, pgd, address)	pmd_alloc(pgd, address)
 extern __inline__ pmd_t *pmd_alloc(pgd_t *pgd, unsigned long address)
 {
 	return (pmd_t *) pgd;
diff -ur v2.4.2-ac20/include/asm-cris/pgalloc.h test-v2.4.2-ac20/include/asm-cris/pgalloc.h
--- v2.4.2-ac20/include/asm-cris/pgalloc.h	Mon Feb 26 10:20:13 2001
+++ test-v2.4.2-ac20/include/asm-cris/pgalloc.h	Wed Mar 14 18:42:41 2001
@@ -180,6 +180,7 @@
 #define pmd_free(pmd)      free_pmd_slow(pmd)
 #define pmd_free_kernel    pmd_free
 #define pmd_alloc_kernel   pmd_alloc
+#define pmd_alloc_mm(mm, pgd, address)	pmd_alloc(pgd, address)

 extern inline pmd_t * pmd_alloc(pgd_t *pgd, unsigned long address)
 {
diff -ur v2.4.2-ac20/include/asm-i386/pgalloc-2level.h test-v2.4.2-ac20/include/asm-i386/pgalloc-2level.h
--- v2.4.2-ac20/include/asm-i386/pgalloc-2level.h	Sat Nov 20 13:09:05 1999
+++ test-v2.4.2-ac20/include/asm-i386/pgalloc-2level.h	Wed Mar 14 18:35:30 2001
@@ -13,6 +13,7 @@
 extern __inline__ void free_pmd_fast(pmd_t *pmd) { }
 extern __inline__ void free_pmd_slow(pmd_t *pmd) { }

+#define pmd_alloc_mm(mm, pgd, address)	pmd_alloc(pgd, address)
 extern inline pmd_t * pmd_alloc(pgd_t *pgd, unsigned long address)
 {
 	if (!pgd)
diff -ur v2.4.2-ac20/include/asm-i386/pgalloc-3level.h test-v2.4.2-ac20/include/asm-i386/pgalloc-3level.h
--- v2.4.2-ac20/include/asm-i386/pgalloc-3level.h	Fri Dec  3 14:12:23 1999
+++ test-v2.4.2-ac20/include/asm-i386/pgalloc-3level.h	Wed Mar 14 18:33:16 2001
@@ -42,7 +42,8 @@
 	free_page((unsigned long)pmd);
 }

-extern inline pmd_t * pmd_alloc(pgd_t *pgd, unsigned long address)
+#define pmd_alloc(pgd, address)	pmd_alloc_mm(current->mm, pgd, address)
+extern inline pmd_t * pmd_alloc_mm(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
 {
 	if (!pgd)
 		BUG();
@@ -55,7 +56,7 @@
 		if (page) {
 			if (pgd_none(*pgd)) {
 				set_pgd(pgd, __pgd(1 + __pa(page)));
-				__flush_tlb();
+				flush_tlb_mm(mm);
 				return page + address;
 			} else
 				free_pmd_fast(page);
diff -ur v2.4.2-ac20/include/asm-i386/pgalloc.h test-v2.4.2-ac20/include/asm-i386/pgalloc.h
--- v2.4.2-ac20/include/asm-i386/pgalloc.h	Wed Mar 14 18:51:25 2001
+++ test-v2.4.2-ac20/include/asm-i386/pgalloc.h	Wed Mar 14 18:54:51 2001
@@ -11,6 +11,84 @@
 #define pte_quicklist (current_cpu_data.pte_quick)
 #define pgtable_cache_size (current_cpu_data.pgtable_cache_sz)

+/*
+ * TLB flushing:
+ *
+ *  - flush_tlb() flushes the current mm struct TLBs
+ *  - flush_tlb_all() flushes all processes TLBs
+ *  - flush_tlb_mm(mm) flushes the specified mm context TLB's
+ *  - flush_tlb_page(vma, vmaddr) flushes one page
+ *  - flush_tlb_range(mm, start, end) flushes a range of pages
+ *  - flush_tlb_pgtables(mm, start, end) flushes a range of page tables
+ *
+ * ..but the i386 has somewhat limited tlb flushing capabilities,
+ * and page-granular flushes are available only on i486 and up.
+ */
+
+#ifndef CONFIG_SMP
+
+#define flush_tlb() __flush_tlb()
+#define flush_tlb_all() __flush_tlb_all()
+#define local_flush_tlb() __flush_tlb()
+
+static inline void flush_tlb_mm(struct mm_struct *mm)
+{
+	if (mm == current->active_mm)
+		__flush_tlb();
+}
+
+static inline void flush_tlb_page(struct vm_area_struct *vma,
+	unsigned long addr)
+{
+	if (vma->vm_mm == current->active_mm)
+		__flush_tlb_one(addr);
+}
+
+static inline void flush_tlb_range(struct mm_struct *mm,
+	unsigned long start, unsigned long end)
+{
+	if (mm == current->active_mm)
+		__flush_tlb();
+}
+
+#else
+
+#include <asm/smp.h>
+
+#define local_flush_tlb() \
+	__flush_tlb()
+
+extern void flush_tlb_all(void);
+extern void flush_tlb_current_task(void);
+extern void flush_tlb_mm(struct mm_struct *);
+extern void flush_tlb_page(struct vm_area_struct *, unsigned long);
+
+#define flush_tlb()	flush_tlb_current_task()
+
+static inline void flush_tlb_range(struct mm_struct * mm, unsigned long start, unsigned long end)
+{
+	flush_tlb_mm(mm);
+}
+
+#define TLBSTATE_OK	1
+#define TLBSTATE_LAZY	2
+
+struct tlb_state
+{
+	struct mm_struct *active_mm;
+	int state;
+};
+extern struct tlb_state cpu_tlbstate[NR_CPUS];
+
+
+#endif
+
+extern inline void flush_tlb_pgtables(struct mm_struct *mm,
+				      unsigned long start, unsigned long end)
+{
+	/* i386 does not keep any page table caches in TLB */
+}
+
 #if CONFIG_X86_PAE
 # include <asm/pgalloc-3level.h>
 #else
@@ -151,83 +229,5 @@
 #define pmd_alloc_kernel	pmd_alloc

 extern int do_check_pgt_cache(int, int);
-
-/*
- * TLB flushing:
- *
- *  - flush_tlb() flushes the current mm struct TLBs
- *  - flush_tlb_all() flushes all processes TLBs
- *  - flush_tlb_mm(mm) flushes the specified mm context TLB's
- *  - flush_tlb_page(vma, vmaddr) flushes one page
- *  - flush_tlb_range(mm, start, end) flushes a range of pages
- *  - flush_tlb_pgtables(mm, start, end) flushes a range of page tables
- *
- * ..but the i386 has somewhat limited tlb flushing capabilities,
- * and page-granular flushes are available only on i486 and up.
- */
-
-#ifndef CONFIG_SMP
-
-#define flush_tlb() __flush_tlb()
-#define flush_tlb_all() __flush_tlb_all()
-#define local_flush_tlb() __flush_tlb()
-
-static inline void flush_tlb_mm(struct mm_struct *mm)
-{
-	if (mm == current->active_mm)
-		__flush_tlb();
-}
-
-static inline void flush_tlb_page(struct vm_area_struct *vma,
-	unsigned long addr)
-{
-	if (vma->vm_mm == current->active_mm)
-		__flush_tlb_one(addr);
-}
-
-static inline void flush_tlb_range(struct mm_struct *mm,
-	unsigned long start, unsigned long end)
-{
-	if (mm == current->active_mm)
-		__flush_tlb();
-}
-
-#else
-
-#include <asm/smp.h>
-
-#define local_flush_tlb() \
-	__flush_tlb()
-
-extern void flush_tlb_all(void);
-extern void flush_tlb_current_task(void);
-extern void flush_tlb_mm(struct mm_struct *);
-extern void flush_tlb_page(struct vm_area_struct *, unsigned long);
-
-#define flush_tlb()	flush_tlb_current_task()
-
-static inline void flush_tlb_range(struct mm_struct * mm, unsigned long start, unsigned long end)
-{
-	flush_tlb_mm(mm);
-}
-
-#define TLBSTATE_OK	1
-#define TLBSTATE_LAZY	2
-
-struct tlb_state
-{
-	struct mm_struct *active_mm;
-	int state;
-};
-extern struct tlb_state cpu_tlbstate[NR_CPUS];
-
-
-#endif
-
-extern inline void flush_tlb_pgtables(struct mm_struct *mm,
-				      unsigned long start, unsigned long end)
-{
-	/* i386 does not keep any page table caches in TLB */
-}

 #endif /* _I386_PGALLOC_H */
diff -ur v2.4.2-ac20/include/asm-ia64/pgalloc.h test-v2.4.2-ac20/include/asm-ia64/pgalloc.h
--- v2.4.2-ac20/include/asm-ia64/pgalloc.h	Thu Jan  4 15:50:18 2001
+++ test-v2.4.2-ac20/include/asm-ia64/pgalloc.h	Wed Mar 14 18:43:28 2001
@@ -164,6 +164,7 @@
 	return (pte_t *) pmd_page(*pmd) + offset;
 }

+#define pmd_alloc_mm(mm, pgd, address)	pmd_alloc(pgd, address)
 static __inline__ pmd_t*
 pmd_alloc (pgd_t *pgd, unsigned long vmaddr)
 {
diff -ur v2.4.2-ac20/include/asm-mips/pgalloc.h test-v2.4.2-ac20/include/asm-mips/pgalloc.h
--- v2.4.2-ac20/include/asm-mips/pgalloc.h	Mon May 15 15:10:26 2000
+++ test-v2.4.2-ac20/include/asm-mips/pgalloc.h	Wed Mar 14 18:46:02 2001
@@ -176,6 +176,7 @@
 {
 }

+#define pmd_alloc_mm(mm, pgd, address)	pmd_alloc(pgd, address)
 extern inline pmd_t * pmd_alloc(pgd_t * pgd, unsigned long address)
 {
 	return (pmd_t *) pgd;
diff -ur v2.4.2-ac20/include/asm-mips64/pgalloc.h test-v2.4.2-ac20/include/asm-mips64/pgalloc.h
--- v2.4.2-ac20/include/asm-mips64/pgalloc.h	Wed Mar 14 18:44:58 2001
+++ test-v2.4.2-ac20/include/asm-mips64/pgalloc.h	Wed Mar 14 18:45:09 2001
@@ -172,6 +172,7 @@
 	return (pte_t *) pmd_page(*pmd) + address;
 }

+#define pmd_alloc_mm(mm, pgd, address)	pmd_alloc(pgd, address)
 extern inline pmd_t *pmd_alloc(pgd_t * pgd, unsigned long address)
 {
 	address = (address >> PMD_SHIFT) & (PTRS_PER_PMD - 1);
diff -ur v2.4.2-ac20/include/asm-parisc/pgalloc.h test-v2.4.2-ac20/include/asm-parisc/pgalloc.h
--- v2.4.2-ac20/include/asm-parisc/pgalloc.h	Wed Mar 14 18:32:34 2001
+++ test-v2.4.2-ac20/include/asm-parisc/pgalloc.h	Wed Mar 14 18:46:28 2001
@@ -278,6 +278,7 @@

 extern void __bad_pgd(pgd_t *pgd);

+#define pmd_alloc_mm(mm, pgd, address)	pmd_alloc(pgd, address)
 extern inline pmd_t * pmd_alloc(pgd_t *pgd, unsigned long address)
 {
 	address = (address >> PMD_SHIFT) & (PTRS_PER_PMD - 1);
diff -ur v2.4.2-ac20/include/asm-ppc/pgalloc.h test-v2.4.2-ac20/include/asm-ppc/pgalloc.h
--- v2.4.2-ac20/include/asm-ppc/pgalloc.h	Sat Nov 11 21:23:11 2000
+++ test-v2.4.2-ac20/include/asm-ppc/pgalloc.h	Wed Mar 14 18:46:53 2001
@@ -74,6 +74,7 @@
 {
 }

+#define pmd_alloc_mm(mm, pgd, address)	pmd_alloc(pgd, address)
 extern inline pmd_t * pmd_alloc(pgd_t * pgd, unsigned long address)
 {
 	return (pmd_t *) pgd;
diff -ur v2.4.2-ac20/include/asm-s390/pgalloc.h test-v2.4.2-ac20/include/asm-s390/pgalloc.h
--- v2.4.2-ac20/include/asm-s390/pgalloc.h	Mon Feb 26 10:20:14 2001
+++ test-v2.4.2-ac20/include/asm-s390/pgalloc.h	Wed Mar 14 18:47:19 2001
@@ -87,6 +87,7 @@
 {
 }

+#define pmd_alloc_mm(mm, pgd, address)	pmd_alloc(pgd, address)
 extern inline pmd_t * pmd_alloc(pgd_t * pgd, unsigned long address)
 {
         return (pmd_t *) pgd;
diff -ur v2.4.2-ac20/include/asm-s390x/pgalloc.h test-v2.4.2-ac20/include/asm-s390x/pgalloc.h
--- v2.4.2-ac20/include/asm-s390x/pgalloc.h	Mon Feb 26 10:20:14 2001
+++ test-v2.4.2-ac20/include/asm-s390x/pgalloc.h	Wed Mar 14 18:47:40 2001
@@ -108,6 +108,7 @@
 	free_pages((unsigned long) pmd, 2);
 }

+#define pmd_alloc_mm(mm, pgd, address)	pmd_alloc(pgd, address)
 extern __inline__ pmd_t *pmd_alloc (pgd_t *pgd, unsigned long vmaddr)
 {
 	unsigned long offset;
diff -ur v2.4.2-ac20/include/asm-sh/pgalloc.h test-v2.4.2-ac20/include/asm-sh/pgalloc.h
--- v2.4.2-ac20/include/asm-sh/pgalloc.h	Fri Oct 13 15:06:52 2000
+++ test-v2.4.2-ac20/include/asm-sh/pgalloc.h	Wed Mar 14 18:47:55 2001
@@ -139,6 +139,7 @@

 #define pmd_free_kernel		pmd_free
 #define pmd_alloc_kernel	pmd_alloc
+#define pmd_alloc_mm(mm, pgd, address)	pmd_alloc(pgd, address)

 extern int do_check_pgt_cache(int, int);

diff -ur v2.4.2-ac20/include/asm-sparc/pgalloc.h test-v2.4.2-ac20/include/asm-sparc/pgalloc.h
--- v2.4.2-ac20/include/asm-sparc/pgalloc.h	Wed Mar 14 18:48:28 2001
+++ test-v2.4.2-ac20/include/asm-sparc/pgalloc.h	Wed Mar 14 18:48:40 2001
@@ -120,6 +120,7 @@

 #define pmd_free_kernel(pmd) BTFIXUP_CALL(pmd_free_kernel)(pmd)
 #define pmd_alloc_kernel(pgd,addr) BTFIXUP_CALL(pmd_alloc_kernel)(pgd,addr)
+#define pmd_alloc_mm(mm, pgd, address)	pmd_alloc(pgd, address)

 BTFIXUPDEF_CALL(void,    pte_free, pte_t *)
 BTFIXUPDEF_CALL(pte_t *, pte_alloc, pmd_t *, unsigned long)
diff -ur v2.4.2-ac20/include/asm-sparc64/pgalloc.h test-v2.4.2-ac20/include/asm-sparc64/pgalloc.h
--- v2.4.2-ac20/include/asm-sparc64/pgalloc.h	Wed Mar 14 18:32:34 2001
+++ test-v2.4.2-ac20/include/asm-sparc64/pgalloc.h	Wed Mar 14 18:48:11 2001
@@ -300,6 +300,7 @@
 	return (pte_t *) pmd_page(*pmd) + address;
 }

+#define pmd_alloc_mm(mm, pgd, address)	pmd_alloc(pgd, address)
 extern inline pmd_t * pmd_alloc(pgd_t *pgd, unsigned long address)
 {
 	address = (address >> PMD_SHIFT) & (REAL_PTRS_PER_PMD - 1);
diff -ur v2.4.2-ac20/mm/memory.c test-v2.4.2-ac20/mm/memory.c
--- v2.4.2-ac20/mm/memory.c	Wed Mar 14 18:32:34 2001
+++ test-v2.4.2-ac20/mm/memory.c	Wed Mar 14 18:37:05 2001
@@ -178,7 +178,7 @@
 			continue;
 		}
 		if (pgd_none(*dst_pgd)) {
-			if (!pmd_alloc(dst_pgd, 0))
+			if (!pmd_alloc_mm(dst, dst_pgd, 0))
 				goto nomem;
 		}

@@ -1208,7 +1208,7 @@

 	current->state = TASK_RUNNING;
 	pgd = pgd_offset(mm, address);
-	pmd = pmd_alloc(pgd, address);
+	pmd = pmd_alloc_mm(mm, pgd, address);

 	if (pmd) {
 		pte_t * pte = pte_alloc(pmd, address);
diff -ur v2.4.2-ac20/mm/mremap.c test-v2.4.2-ac20/mm/mremap.c
--- v2.4.2-ac20/mm/mremap.c	Wed Mar 14 18:32:34 2001
+++ test-v2.4.2-ac20/mm/mremap.c	Wed Mar 14 18:37:31 2001
@@ -51,7 +51,7 @@
 	pmd_t * pmd;
 	pte_t * pte = NULL;

-	pmd = pmd_alloc(pgd_offset(mm, addr), addr);
+	pmd = pmd_alloc_mm(mm, pgd_offset(mm, addr), addr);
 	if (pmd)
 		pte = pte_alloc(pmd, addr);
 	return pte;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
