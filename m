Message-ID: <4181EFFF.1070309@yahoo.com.au>
Date: Fri, 29 Oct 2004 17:23:43 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 7/7] abstract pagetable locking and pte updates
References: <4181EF2D.5000407@yahoo.com.au> <4181EF54.6080308@yahoo.com.au> <4181EF69.4070201@yahoo.com.au> <4181EF80.3030709@yahoo.com.au> <4181EF96.2030602@yahoo.com.au> <4181EFBD.6000007@yahoo.com.au> <4181EFD7.7000902@yahoo.com.au>
In-Reply-To: <4181EFD7.7000902@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------060109030705000700010007"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060109030705000700010007
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

7/7

--------------060109030705000700010007
Content-Type: text/x-patch;
 name="vm-x86_64-lockless-page-table.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-x86_64-lockless-page-table.patch"



x86_64: implement lockless page tables using cmpxchg


---

 linux-2.6-npiggin/arch/x86_64/mm/ioremap.c     |   19 ++++++++++++++-----
 linux-2.6-npiggin/include/asm-x86_64/pgtable.h |   24 ++++++++++++++++++++++++
 2 files changed, 38 insertions(+), 5 deletions(-)

diff -puN include/asm-x86_64/pgtable.h~vm-x86_64-lockless-page-table include/asm-x86_64/pgtable.h
--- linux-2.6/include/asm-x86_64/pgtable.h~vm-x86_64-lockless-page-table	2004-10-29 16:48:39.000000000 +1000
+++ linux-2.6-npiggin/include/asm-x86_64/pgtable.h	2004-10-29 16:48:39.000000000 +1000
@@ -417,6 +417,30 @@ extern inline pte_t pte_modify(pte_t pte
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val })
 
+#define __HAVE_ARCH_PTEP_CMPXCHG
+
+#define ptep_cmpxchg(xp, oldval, newval)	\
+   (cmpxchg(&(xp)->pte, pte_val(oldval), pte_val(newval)) != pte_val(oldval))
+
+#define PGD_NONE 0UL
+
+#define pgd_test_and_populate(__mm, ___pgd, ___pmd)			\
+({									\
+ 	unlikely(cmpxchg((int *)___pgd, PGD_NONE, _PAGE_TABLE | __pa(___pmd))	!= PGD_NONE); \
+})
+
+#define PMD_NONE 0UL
+
+#define pmd_test_and_populate(__mm, ___pmd, ___pte)			\
+({									\
+	unlikely(cmpxchg((int *)___pmd, PMD_NONE, _PAGE_TABLE | (page_to_pfn(___pte) << PAGE_SHIFT)) != PMD_NONE); \
+})
+
+#define pmd_test_and_populate_kernel(__mm, ___pmd, ___pte)		\
+({									\
+ 	unlikely(cmpxchg((int *)___pmd, PMD_NONE, _PAGE_TABLE | __pa(___pte))); \
+})
+
 #endif /* !__ASSEMBLY__ */
 
 extern int kern_addr_valid(unsigned long addr); 
diff -puN arch/x86_64/mm/ioremap.c~vm-x86_64-lockless-page-table arch/x86_64/mm/ioremap.c
--- linux-2.6/arch/x86_64/mm/ioremap.c~vm-x86_64-lockless-page-table	2004-10-29 16:48:39.000000000 +1000
+++ linux-2.6-npiggin/arch/x86_64/mm/ioremap.c	2004-10-29 16:48:39.000000000 +1000
@@ -32,12 +32,21 @@ static inline void remap_area_pte(pte_t 
 		BUG();
 	pfn = phys_addr >> PAGE_SHIFT;
 	do {
-		if (!pte_none(*pte)) {
+		struct pte_modify pmod;
+		pte_t new;
+again:
+		new = ptep_begin_modify(&pmod, &init_mm, pte);
+		if (!pte_none(new)) {
 			printk("remap_area_pte: page already exists\n");
 			BUG();
 		}
-		set_pte(pte, pfn_pte(pfn, __pgprot(_PAGE_PRESENT | _PAGE_RW | 
-					_PAGE_GLOBAL | _PAGE_DIRTY | _PAGE_ACCESSED | flags)));
+		new = pfn_pte(pfn, __pgprot(_PAGE_PRESENT | _PAGE_RW |
+					_PAGE_GLOBAL | _PAGE_DIRTY |
+					_PAGE_ACCESSED | flags));
+		if (ptep_commit(&pmod, &init_mm, pte, new)) {
+			printk("remap_area_pte: ptep_commit raced\n");
+			goto again;
+		}
 		address += PAGE_SIZE;
 		pfn++;
 		pte++;
@@ -79,7 +88,7 @@ static int remap_area_pages(unsigned lon
 	flush_cache_all();
 	if (address >= end)
 		BUG();
-	spin_lock(&init_mm.page_table_lock);
+	mm_lock_page_table(&init_mm);
 	do {
 		pmd_t *pmd;
 		pmd = pmd_alloc(&init_mm, dir, address);
@@ -93,7 +102,7 @@ static int remap_area_pages(unsigned lon
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		dir++;
 	} while (address && (address < end));
-	spin_unlock(&init_mm.page_table_lock);
+	mm_unlock_page_table(&init_mm);
 	flush_tlb_all();
 	return error;
 }

_

--------------060109030705000700010007--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
