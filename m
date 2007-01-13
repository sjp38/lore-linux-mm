From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:48:30 +1100
Message-Id: <20070113024830.29682.99345.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 3/5] Abstact pgtable continued.
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH IA64 03
 * Continue abstracting implementation dependent pgtable.h code into 
 pgtable-default.h

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 arch/ia64/mm/init.c                |    2 
 include/asm-ia64/pgtable-default.h |   93 +++++++++++++++++++++++++++++++++++++
 include/asm-ia64/pgtable.h         |   84 ++-------------------------------
 3 files changed, 101 insertions(+), 78 deletions(-)
Index: linux-2.6.20-rc1/include/asm-ia64/pgtable-default.h
===================================================================
--- linux-2.6.20-rc1.orig/include/asm-ia64/pgtable-default.h	2006-12-23 20:24:57.791909000 +1100
+++ linux-2.6.20-rc1/include/asm-ia64/pgtable-default.h	2006-12-23 20:26:33.219909000 +1100
@@ -51,4 +51,97 @@
 #define PTRS_PER_PGD		(1UL << PTRS_PER_PGD_SHIFT)
 #define USER_PTRS_PER_PGD	(5*PTRS_PER_PGD/8)	/* regions 0-4 are user regions */
 
+# ifndef __ASSEMBLY__
+
+#include <linux/sched.h>	/* for mm_struct */
+#include <asm/bitops.h>
+#include <asm/cacheflush.h>
+#include <asm/mmu_context.h>
+#include <asm/processor.h>
+
+
+#define pgd_ERROR(e)	printk("%s:%d: bad pgd %016lx.\n", __FILE__, __LINE__, pgd_val(e))
+#ifdef CONFIG_PGTABLE_4
+#define pud_ERROR(e)	printk("%s:%d: bad pud %016lx.\n", __FILE__, __LINE__, pud_val(e))
+#endif
+#define pmd_ERROR(e)	printk("%s:%d: bad pmd %016lx.\n", __FILE__, __LINE__, pmd_val(e))
+
+
+#define pmd_none(pmd)			(!pmd_val(pmd))
+#define pmd_bad(pmd)			(!ia64_phys_addr_valid(pmd_val(pmd)))
+#define pmd_present(pmd)		(pmd_val(pmd) != 0UL)
+#define pmd_clear(pmdp)			(pmd_val(*(pmdp)) = 0UL)
+#define pmd_page_vaddr(pmd)		((unsigned long) __va(pmd_val(pmd) & _PFN_MASK))
+#define pmd_page(pmd)			virt_to_page((pmd_val(pmd) + PAGE_OFFSET))
+
+#define pud_none(pud)			(!pud_val(pud))
+#define pud_bad(pud)			(!ia64_phys_addr_valid(pud_val(pud)))
+#define pud_present(pud)		(pud_val(pud) != 0UL)
+#define pud_clear(pudp)			(pud_val(*(pudp)) = 0UL)
+#define pud_page_vaddr(pud)		((unsigned long) __va(pud_val(pud) & _PFN_MASK))
+#define pud_page(pud)			virt_to_page((pud_val(pud) + PAGE_OFFSET))
+
+#ifdef CONFIG_PGTABLE_4
+#define pgd_none(pgd)			(!pgd_val(pgd))
+#define pgd_bad(pgd)			(!ia64_phys_addr_valid(pgd_val(pgd)))
+#define pgd_present(pgd)		(pgd_val(pgd) != 0UL)
+#define pgd_clear(pgdp)			(pgd_val(*(pgdp)) = 0UL)
+#define pgd_page_vaddr(pgd)		((unsigned long) __va(pgd_val(pgd) & _PFN_MASK))
+#define pgd_page(pgd)			virt_to_page((pgd_val(pgd) + PAGE_OFFSET))
+#endif
+
+static inline unsigned long
+pgd_index (unsigned long address)
+{
+	unsigned long region = address >> 61;
+	unsigned long l1index = (address >> PGDIR_SHIFT) & ((PTRS_PER_PGD >> 3) - 1);
+
+	return (region << (PAGE_SHIFT - 6)) | l1index;
+}
+
+/* The offset in the 1-level directory is given by the 3 region bits
+   (61..63) and the level-1 bits.  */
+static inline pgd_t*
+pgd_offset (struct mm_struct *mm, unsigned long address)
+{
+	return mm->page_table.pgd + pgd_index(address);
+}
+
+/* In the kernel's mapped region we completely ignore the region number
+   (since we know it's in region number 5). */
+#define pgd_offset_k(addr) \
+	(init_mm.page_table.pgd + (((addr) >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1)))
+
+/* Look up a pgd entry in the gate area.  On IA-64, the gate-area
+   resides in the kernel-mapped segment, hence we use pgd_offset_k()
+   here.  */
+#define pgd_offset_gate(mm, addr)	pgd_offset_k(addr)
+
+#ifdef CONFIG_PGTABLE_4
+/* Find an entry in the second-level page table.. */
+#define pud_offset(dir,addr) \
+	((pud_t *) pgd_page_vaddr(*(dir)) + (((addr) >> PUD_SHIFT) & (PTRS_PER_PUD - 1)))
+#endif
+
+/* Find an entry in the third-level page table.. */
+#define pmd_offset(dir,addr) \
+	((pmd_t *) pud_page_vaddr(*(dir)) + (((addr) >> PMD_SHIFT) & (PTRS_PER_PMD - 1)))
+
+/*
+ * Find an entry in the third-level page table.  This looks more complicated than it
+ * should be because some platforms place page tables in high memory.
+ */
+#define pte_index(addr)	 	(((addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))
+#define pte_offset_kernel(dir,addr)	((pte_t *) pmd_page_vaddr(*(dir)) + pte_index(addr))
+#define pte_offset_map(dir,addr)	pte_offset_kernel(dir, addr)
+#define pte_offset_map_nested(dir,addr)	pte_offset_map(dir, addr)
+
+extern pgd_t swapper_pg_dir[PTRS_PER_PGD];
+
+#define RGN_MAP_SHIFT (PGDIR_SHIFT + PTRS_PER_PGD_SHIFT - 3)
+
+#define ALIGNVAL (1UL << PMD_SHIFT)
+
+# endif /* !__ASSEMBLY__ */
+
 #endif
Index: linux-2.6.20-rc1/include/asm-ia64/pgtable.h
===================================================================
--- linux-2.6.20-rc1.orig/include/asm-ia64/pgtable.h	2006-12-23 20:26:16.243909000 +1100
+++ linux-2.6.20-rc1/include/asm-ia64/pgtable.h	2006-12-23 20:32:51.431909000 +1100
@@ -23,6 +23,10 @@
 #include <asm/pgtable-default.h>
 #endif
 
+#ifdef CONFIG_PT_GPT
+#include <asm/pgtable-gpt.h>
+#endif
+
 #define IA64_MAX_PHYS_BITS	50	/* max. number of physical address bits (architected) */
 
 /*
@@ -137,14 +141,8 @@
 #define __S110	__pgprot(__ACCESS_BITS | _PAGE_PL_3 | _PAGE_AR_RWX)
 #define __S111	__pgprot(__ACCESS_BITS | _PAGE_PL_3 | _PAGE_AR_RWX)
 
-#define pgd_ERROR(e)	printk("%s:%d: bad pgd %016lx.\n", __FILE__, __LINE__, pgd_val(e))
-#ifdef CONFIG_PGTABLE_4
-#define pud_ERROR(e)	printk("%s:%d: bad pud %016lx.\n", __FILE__, __LINE__, pud_val(e))
-#endif
-#define pmd_ERROR(e)	printk("%s:%d: bad pmd %016lx.\n", __FILE__, __LINE__, pmd_val(e))
 #define pte_ERROR(e)	printk("%s:%d: bad pte %016lx.\n", __FILE__, __LINE__, pte_val(e))
 
-
 /*
  * Some definitions to translate between mem_map, PTEs, and page addresses:
  */
@@ -198,7 +196,6 @@
 #define	kc_vaddr_to_offset(v) ((v) - RGN_BASE(RGN_GATE))
 #define	kc_offset_to_vaddr(o) ((o) + RGN_BASE(RGN_GATE))
 
-#define RGN_MAP_SHIFT (PGDIR_SHIFT + PTRS_PER_PGD_SHIFT - 3)
 #define RGN_MAP_LIMIT	((1UL << RGN_MAP_SHIFT) - PAGE_SIZE)	/* per region addr limit */
 
 /*
@@ -226,29 +223,6 @@
 /* pte_page() returns the "struct page *" corresponding to the PTE: */
 #define pte_page(pte)			virt_to_page(((pte_val(pte) & _PFN_MASK) + PAGE_OFFSET))
 
-#define pmd_none(pmd)			(!pmd_val(pmd))
-#define pmd_bad(pmd)			(!ia64_phys_addr_valid(pmd_val(pmd)))
-#define pmd_present(pmd)		(pmd_val(pmd) != 0UL)
-#define pmd_clear(pmdp)			(pmd_val(*(pmdp)) = 0UL)
-#define pmd_page_vaddr(pmd)		((unsigned long) __va(pmd_val(pmd) & _PFN_MASK))
-#define pmd_page(pmd)			virt_to_page((pmd_val(pmd) + PAGE_OFFSET))
-
-#define pud_none(pud)			(!pud_val(pud))
-#define pud_bad(pud)			(!ia64_phys_addr_valid(pud_val(pud)))
-#define pud_present(pud)		(pud_val(pud) != 0UL)
-#define pud_clear(pudp)			(pud_val(*(pudp)) = 0UL)
-#define pud_page_vaddr(pud)		((unsigned long) __va(pud_val(pud) & _PFN_MASK))
-#define pud_page(pud)			virt_to_page((pud_val(pud) + PAGE_OFFSET))
-
-#ifdef CONFIG_PGTABLE_4
-#define pgd_none(pgd)			(!pgd_val(pgd))
-#define pgd_bad(pgd)			(!ia64_phys_addr_valid(pgd_val(pgd)))
-#define pgd_present(pgd)		(pgd_val(pgd) != 0UL)
-#define pgd_clear(pgdp)			(pgd_val(*(pgdp)) = 0UL)
-#define pgd_page_vaddr(pgd)		((unsigned long) __va(pgd_val(pgd) & _PFN_MASK))
-#define pgd_page(pgd)			virt_to_page((pgd_val(pgd) + PAGE_OFFSET))
-#endif
-
 /*
  * The following have defined behavior only work if pte_present() is true.
  */
@@ -287,51 +261,6 @@
 				     unsigned long size, pgprot_t vma_prot);
 #define __HAVE_PHYS_MEM_ACCESS_PROT
 
-static inline unsigned long
-pgd_index (unsigned long address)
-{
-	unsigned long region = address >> 61;
-	unsigned long l1index = (address >> PGDIR_SHIFT) & ((PTRS_PER_PGD >> 3) - 1);
-
-	return (region << (PAGE_SHIFT - 6)) | l1index;
-}
-
-/* The offset in the 1-level directory is given by the 3 region bits
-   (61..63) and the level-1 bits.  */
-static inline pgd_t*
-pgd_offset (struct mm_struct *mm, unsigned long address)
-{
-	return mm->page_table.pgd + pgd_index(address);
-}
-
-/* In the kernel's mapped region we completely ignore the region number
-   (since we know it's in region number 5). */
-#define pgd_offset_k(addr) \
-	(init_mm.page_table.pgd + (((addr) >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1)))
-
-/* Look up a pgd entry in the gate area.  On IA-64, the gate-area
-   resides in the kernel-mapped segment, hence we use pgd_offset_k()
-   here.  */
-#define pgd_offset_gate(mm, addr)	pgd_offset_k(addr)
-
-#ifdef CONFIG_PGTABLE_4
-/* Find an entry in the second-level page table.. */
-#define pud_offset(dir,addr) \
-	((pud_t *) pgd_page_vaddr(*(dir)) + (((addr) >> PUD_SHIFT) & (PTRS_PER_PUD - 1)))
-#endif
-
-/* Find an entry in the third-level page table.. */
-#define pmd_offset(dir,addr) \
-	((pmd_t *) pud_page_vaddr(*(dir)) + (((addr) >> PMD_SHIFT) & (PTRS_PER_PMD - 1)))
-
-/*
- * Find an entry in the third-level page table.  This looks more complicated than it
- * should be because some platforms place page tables in high memory.
- */
-#define pte_index(addr)	 	(((addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))
-#define pte_offset_kernel(dir,addr)	((pte_t *) pmd_page_vaddr(*(dir)) + pte_index(addr))
-#define pte_offset_map(dir,addr)	pte_offset_kernel(dir, addr)
-#define pte_offset_map_nested(dir,addr)	pte_offset_map(dir, addr)
 #define pte_unmap(pte)			do { } while (0)
 #define pte_unmap_nested(pte)		do { } while (0)
 
@@ -405,7 +334,6 @@
 
 #define update_mmu_cache(vma, address, pte) do { } while (0)
 
-extern pgd_t swapper_pg_dir[PTRS_PER_PGD];
 extern void paging_init (void);
 
 /*
@@ -554,7 +482,9 @@
 #ifndef CONFIG_PGTABLE_4
 #include <asm-generic/pgtable-nopud.h>
 #endif
-#include <asm-generic/pgtable.h>
 #endif
 
+#include <asm-generic/pgtable.h>
+
+
 #endif /* _ASM_IA64_PGTABLE_H */
Index: linux-2.6.20-rc1/arch/ia64/mm/init.c
===================================================================
--- linux-2.6.20-rc1.orig/arch/ia64/mm/init.c	2006-12-23 20:24:49.187909000 +1100
+++ linux-2.6.20-rc1/arch/ia64/mm/init.c	2006-12-23 20:33:20.435909000 +1100
@@ -426,7 +426,7 @@
 			end_address += PAGE_SIZE;
 			pte++;
 			if ((end_address < stop_address) &&
-			    (end_address != ALIGN(end_address, 1UL << PMD_SHIFT)))
+			    (end_address != ALIGN(end_address, ALIGNVAL)))
 				goto retry_pte;
 			continue;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
