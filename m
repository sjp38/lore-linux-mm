Message-ID: <3E6530B3.2000906@us.ibm.com>
Date: Tue, 04 Mar 2003 15:03:15 -0800
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: [PATCH] remove __pte_offset
References: <3E653012.5040503@us.ibm.com>
Content-Type: multipart/mixed;
 boundary="------------050901090104020009010807"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050901090104020009010807
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

ptes this time
-- 
Dave Hansen
haveblue@us.ibm.com


--------------050901090104020009010807
Content-Type: text/plain;
 name="pteindex-2.5.63-0.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pteindex-2.5.63-0.patch"

diff -ru linux-2.5.63-pmdindex/include/asm-i386/pgtable.h linux-2.5.63-pteindex/include/asm-i386/pgtable.h
--- linux-2.5.63-pmdindex/include/asm-i386/pgtable.h	Tue Mar  4 14:39:45 2003
+++ linux-2.5.63-pteindex/include/asm-i386/pgtable.h	Tue Mar  4 14:45:22 2003
@@ -245,21 +245,21 @@
 		(((address) >> PMD_SHIFT) & (PTRS_PER_PMD-1))
 
 /* Find an entry in the third-level page table.. */
-#define __pte_offset(address) \
+#define pte_index(address) \
 		(((address) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))
 #define pte_offset_kernel(dir, address) \
-	((pte_t *) pmd_page_kernel(*(dir)) +  __pte_offset(address))
+	((pte_t *) pmd_page_kernel(*(dir)) +  pte_index(address))
 
 #if defined(CONFIG_HIGHPTE)
 #define pte_offset_map(dir, address) \
-	((pte_t *)kmap_atomic(pmd_page(*(dir)),KM_PTE0) + __pte_offset(address))
+	((pte_t *)kmap_atomic(pmd_page(*(dir)),KM_PTE0) + pte_index(address))
 #define pte_offset_map_nested(dir, address) \
-	((pte_t *)kmap_atomic(pmd_page(*(dir)),KM_PTE1) + __pte_offset(address))
+	((pte_t *)kmap_atomic(pmd_page(*(dir)),KM_PTE1) + pte_index(address))
 #define pte_unmap(pte) kunmap_atomic(pte, KM_PTE0)
 #define pte_unmap_nested(pte) kunmap_atomic(pte, KM_PTE1)
 #else
 #define pte_offset_map(dir, address) \
-	((pte_t *)page_address(pmd_page(*(dir))) + __pte_offset(address))
+	((pte_t *)page_address(pmd_page(*(dir))) + pte_index(address))
 #define pte_offset_map_nested(dir, address) pte_offset_map(dir, address)
 #define pte_unmap(pte) do { } while (0)
 #define pte_unmap_nested(pte) do { } while (0)
diff -ru linux-2.5.63-pmdindex/include/asm-ia64/pgtable.h linux-2.5.63-pteindex/include/asm-ia64/pgtable.h
--- linux-2.5.63-pmdindex/include/asm-ia64/pgtable.h	Tue Mar  4 14:36:40 2003
+++ linux-2.5.63-pteindex/include/asm-ia64/pgtable.h	Tue Mar  4 14:44:49 2003
@@ -317,8 +317,8 @@
  * Find an entry in the third-level page table.  This looks more complicated than it
  * should be because some platforms place page tables in high memory.
  */
-#define __pte_offset(addr)	 	(((addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))
-#define pte_offset_kernel(dir,addr)	((pte_t *) pmd_page_kernel(*(dir)) + __pte_offset(addr))
+#define pte_index(addr)	 	(((addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))
+#define pte_offset_kernel(dir,addr)	((pte_t *) pmd_page_kernel(*(dir)) + pte_index(addr))
 #define pte_offset_map(dir,addr)	pte_offset_kernel(dir, addr)
 #define pte_offset_map_nested(dir,addr)	pte_offset_map(dir, addr)
 #define pte_unmap(pte)			do { } while (0)
diff -ru linux-2.5.63-pmdindex/include/asm-m68k/sun3_pgtable.h linux-2.5.63-pteindex/include/asm-m68k/sun3_pgtable.h
--- linux-2.5.63-pmdindex/include/asm-m68k/sun3_pgtable.h	Tue Mar  4 14:36:40 2003
+++ linux-2.5.63-pteindex/include/asm-m68k/sun3_pgtable.h	Tue Mar  4 14:44:49 2003
@@ -196,10 +196,10 @@
 }
 
 /* Find an entry in the third-level pagetable. */
-#define __pte_offset(address) ((address >> PAGE_SHIFT) & (PTRS_PER_PTE-1))
-#define pte_offset_kernel(pmd, address) ((pte_t *) __pmd_page(*pmd) + __pte_offset(address))
+#define pte_index(address) ((address >> PAGE_SHIFT) & (PTRS_PER_PTE-1))
+#define pte_offset_kernel(pmd, address) ((pte_t *) __pmd_page(*pmd) + pte_index(address))
 /* FIXME: should we bother with kmap() here? */
-#define pte_offset_map(pmd, address) ((pte_t *)kmap(pmd_page(*pmd)) + __pte_offset(address))
+#define pte_offset_map(pmd, address) ((pte_t *)kmap(pmd_page(*pmd)) + pte_index(address))
 #define pte_offset_map_nested(pmd, address) pte_offset_map(pmd, address)
 #define pte_unmap(pte) kunmap(pte)
 #define pte_unmap_nested(pte) kunmap(pte)
diff -ru linux-2.5.63-pmdindex/include/asm-parisc/pgtable.h linux-2.5.63-pteindex/include/asm-parisc/pgtable.h
--- linux-2.5.63-pmdindex/include/asm-parisc/pgtable.h	Tue Mar  4 14:36:40 2003
+++ linux-2.5.63-pteindex/include/asm-parisc/pgtable.h	Tue Mar  4 14:44:49 2003
@@ -329,9 +329,9 @@
 #endif
 
 /* Find an entry in the third-level page table.. */ 
-#define __pte_offset(address) (((address) >> PAGE_SHIFT) & (PTRS_PER_PTE-1))
+#define pte_index(address) (((address) >> PAGE_SHIFT) & (PTRS_PER_PTE-1))
 #define pte_offset_kernel(pmd, address) \
-	((pte_t *) pmd_page_kernel(*(pmd)) + __pte_offset(address))
+	((pte_t *) pmd_page_kernel(*(pmd)) + pte_index(address))
 #define pte_offset_map(pmd, address) pte_offset_kernel(pmd, address)
 #define pte_offset_map_nested(pmd, address) pte_offset_kernel(pmd, address)
 #define pte_unmap(pte) do { } while (0)
diff -ru linux-2.5.63-pmdindex/include/asm-ppc/pgtable.h linux-2.5.63-pteindex/include/asm-ppc/pgtable.h
--- linux-2.5.63-pmdindex/include/asm-ppc/pgtable.h	Tue Mar  4 14:36:40 2003
+++ linux-2.5.63-pteindex/include/asm-ppc/pgtable.h	Tue Mar  4 14:44:49 2003
@@ -494,14 +494,14 @@
 }
 
 /* Find an entry in the third-level page table.. */
-#define __pte_offset(address)		\
+#define pte_index(address)		\
 	(((address) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))
 #define pte_offset_kernel(dir, addr)	\
-	((pte_t *) pmd_page_kernel(*(dir)) + __pte_offset(addr))
+	((pte_t *) pmd_page_kernel(*(dir)) + pte_index(addr))
 #define pte_offset_map(dir, addr)		\
-	((pte_t *) kmap_atomic(pmd_page(*(dir)), KM_PTE0) + __pte_offset(addr))
+	((pte_t *) kmap_atomic(pmd_page(*(dir)), KM_PTE0) + pte_index(addr))
 #define pte_offset_map_nested(dir, addr)	\
-	((pte_t *) kmap_atomic(pmd_page(*(dir)), KM_PTE1) + __pte_offset(addr))
+	((pte_t *) kmap_atomic(pmd_page(*(dir)), KM_PTE1) + pte_index(addr))
 
 #define pte_unmap(pte)		kunmap_atomic(pte, KM_PTE0)
 #define pte_unmap_nested(pte)	kunmap_atomic(pte, KM_PTE1)
diff -ru linux-2.5.63-pmdindex/include/asm-s390/pgtable.h linux-2.5.63-pteindex/include/asm-s390/pgtable.h
--- linux-2.5.63-pmdindex/include/asm-s390/pgtable.h	Tue Mar  4 14:36:41 2003
+++ linux-2.5.63-pteindex/include/asm-s390/pgtable.h	Tue Mar  4 14:44:49 2003
@@ -467,9 +467,9 @@
 }
 
 /* Find an entry in the third-level page table.. */
-#define __pte_offset(address) (((address) >> PAGE_SHIFT) & (PTRS_PER_PTE-1))
+#define pte_index(address) (((address) >> PAGE_SHIFT) & (PTRS_PER_PTE-1))
 #define pte_offset_kernel(pmd, address) \
-	((pte_t *) pmd_page_kernel(*(pmd)) + __pte_offset(address))
+	((pte_t *) pmd_page_kernel(*(pmd)) + pte_index(address))
 #define pte_offset_map(pmd, address) pte_offset_kernel(pmd, address)
 #define pte_offset_map_nested(pmd, address) pte_offset_kernel(pmd, address)
 #define pte_unmap(pte) do { } while (0)
diff -ru linux-2.5.63-pmdindex/include/asm-s390x/pgtable.h linux-2.5.63-pteindex/include/asm-s390x/pgtable.h
--- linux-2.5.63-pmdindex/include/asm-s390x/pgtable.h	Tue Mar  4 14:41:35 2003
+++ linux-2.5.63-pteindex/include/asm-s390x/pgtable.h	Tue Mar  4 14:44:49 2003
@@ -493,9 +493,9 @@
 	((pmd_t *) pgd_page_kernel(*(dir)) + pmd_index(addr))
 
 /* Find an entry in the third-level page table.. */
-#define __pte_offset(address) (((address) >> PAGE_SHIFT) & (PTRS_PER_PTE-1))
+#define pte_index(address) (((address) >> PAGE_SHIFT) & (PTRS_PER_PTE-1))
 #define pte_offset_kernel(pmd, address) \
-	((pte_t *) pmd_page_kernel(*(pmd)) + __pte_offset(address))
+	((pte_t *) pmd_page_kernel(*(pmd)) + pte_index(address))
 #define pte_offset_map(pmd, address) pte_offset_kernel(pmd, address)
 #define pte_offset_map_nested(pmd, address) pte_offset_kernel(pmd, address)
 #define pte_unmap(pte) do { } while (0)
diff -ru linux-2.5.63-pmdindex/include/asm-sh/pgtable.h linux-2.5.63-pteindex/include/asm-sh/pgtable.h
--- linux-2.5.63-pmdindex/include/asm-sh/pgtable.h	Tue Mar  4 14:36:41 2003
+++ linux-2.5.63-pteindex/include/asm-sh/pgtable.h	Tue Mar  4 14:44:49 2003
@@ -280,10 +280,10 @@
 #define pgd_offset_k(address) pgd_offset(&init_mm, address)
 
 /* Find an entry in the third-level page table.. */
-#define __pte_offset(address) \
+#define pte_index(address) \
 		((address >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))
 #define pte_offset(dir, address) ((pte_t *) pmd_page(*(dir)) + \
-			__pte_offset(address))
+			pte_index(address))
 
 extern void update_mmu_cache(struct vm_area_struct * vma,
 			     unsigned long address, pte_t pte);
diff -ru linux-2.5.63-pmdindex/include/asm-sparc64/pgtable.h linux-2.5.63-pteindex/include/asm-sparc64/pgtable.h
--- linux-2.5.63-pmdindex/include/asm-sparc64/pgtable.h	Tue Mar  4 14:36:41 2003
+++ linux-2.5.63-pteindex/include/asm-sparc64/pgtable.h	Tue Mar  4 14:44:49 2003
@@ -273,11 +273,11 @@
 					((address >> PMD_SHIFT) & (REAL_PTRS_PER_PMD-1)))
 
 /* Find an entry in the third-level page table.. */
-#define __pte_offset(dir, address)	((pte_t *) __pmd_page(*(dir)) + \
+#define pte_index(dir, address)	((pte_t *) __pmd_page(*(dir)) + \
 					((address >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)))
-#define pte_offset_kernel		__pte_offset
-#define pte_offset_map			__pte_offset
-#define pte_offset_map_nested		__pte_offset
+#define pte_offset_kernel		pte_index
+#define pte_offset_map			pte_index
+#define pte_offset_map_nested		pte_index
 #define pte_unmap(pte)			do { } while (0)
 #define pte_unmap_nested(pte)		do { } while (0)
 
diff -ru linux-2.5.63-pmdindex/include/asm-um/pgtable.h linux-2.5.63-pteindex/include/asm-um/pgtable.h
--- linux-2.5.63-pmdindex/include/asm-um/pgtable.h	Tue Mar  4 14:39:54 2003
+++ linux-2.5.63-pteindex/include/asm-um/pgtable.h	Tue Mar  4 14:44:49 2003
@@ -375,13 +375,13 @@
 }
 
 /* Find an entry in the third-level page table.. */ 
-#define __pte_offset(address) (((address) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))
+#define pte_index(address) (((address) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))
 #define pte_offset_kernel(dir, address) \
-	((pte_t *) pmd_page_kernel(*(dir)) +  __pte_offset(address))
+	((pte_t *) pmd_page_kernel(*(dir)) +  pte_index(address))
 #define pte_offset_map(dir, address) \
-        ((pte_t *)kmap_atomic(pmd_page(*(dir)),KM_PTE0) + __pte_offset(address))
+        ((pte_t *)kmap_atomic(pmd_page(*(dir)),KM_PTE0) + pte_index(address))
 #define pte_offset_map_nested(dir, address) \
-	((pte_t *)kmap_atomic(pmd_page(*(dir)),KM_PTE1) + __pte_offset(address))
+	((pte_t *)kmap_atomic(pmd_page(*(dir)),KM_PTE1) + pte_index(address))
 #define pte_unmap(pte) kunmap_atomic((pte), KM_PTE0)
 #define pte_unmap_nested(pte) kunmap_atomic((pte), KM_PTE1)
 
diff -ru linux-2.5.63-pmdindex/include/asm-x86_64/pgtable.h linux-2.5.63-pteindex/include/asm-x86_64/pgtable.h
--- linux-2.5.63-pmdindex/include/asm-x86_64/pgtable.h	Tue Mar  4 14:41:38 2003
+++ linux-2.5.63-pteindex/include/asm-x86_64/pgtable.h	Tue Mar  4 14:44:49 2003
@@ -353,10 +353,10 @@
        return pte; 
 }
 
-#define __pte_offset(address) \
+#define pte_index(address) \
 		((address >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))
 #define pte_offset_kernel(dir, address) ((pte_t *) pmd_page_kernel(*(dir)) + \
-			__pte_offset(address))
+			pte_index(address))
 
 /* x86-64 always has all page tables mapped. */
 #define pte_offset_map(dir,address) pte_offset_kernel(dir,address)

--------------050901090104020009010807--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
