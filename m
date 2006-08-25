Date: Fri, 25 Aug 2006 08:56:24 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Message-Id: <20060825135624.24086.74604.sendpatch@wildcat>
Subject: [PATCH] Fix more pxx_page macro locations
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Paul Jackson <pj@sgi.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

It looks like I missed a couple of places.  I guess I forgot to
doublecheck for new code with pmd_page_kernel in it.  Here's a 
patch with the additional places fixed.

Dave McCracken

Signed-off-by: Dave McCracken <dmccr@us.ibm.com>

------------------------

Diffstat:

 arch/arm/mm/ioremap.c       |    2 +-
 include/asm-avr32/pgtable.h |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

------------------------

--- 2.6.18-rc4-mm2/./arch/arm/mm/ioremap.c	2006-08-25 08:24:33.000000000 -0500
+++ 2.6.18-rc4-mm2-mfix/./arch/arm/mm/ioremap.c	2006-08-25 08:25:58.000000000 -0500
@@ -177,7 +177,7 @@ static void unmap_area_sections(unsigned
 			 * Free the page table, if there was one.
 			 */
 			if ((pmd_val(pmd) & PMD_TYPE_MASK) == PMD_TYPE_TABLE)
-				pte_free_kernel(pmd_page_kernel(pmd));
+				pte_free_kernel(pmd_page_vaddr(pmd));
 		}
 
 		addr += PGDIR_SIZE;
--- 2.6.18-rc4-mm2/./include/asm-avr32/pgtable.h	2006-08-25 08:20:15.000000000 -0500
+++ 2.6.18-rc4-mm2-mfix/./include/asm-avr32/pgtable.h	2006-08-25 08:27:46.000000000 -0500
@@ -324,7 +324,7 @@ static inline pte_t pte_modify(pte_t pte
 
 #define page_pte(page)	page_pte_prot(page, __pgprot(0))
 
-#define pmd_page_kernel(pmd)					\
+#define pmd_page_vaddr(pmd)					\
 	((unsigned long) __va(pmd_val(pmd) & PAGE_MASK))
 
 #define pmd_page(pmd)	(phys_to_page(pmd_val(pmd)))
@@ -342,9 +342,9 @@ static inline pte_t pte_modify(pte_t pte
 #define pte_index(address)				\
 	((address >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))
 #define pte_offset(dir, address)					\
-	((pte_t *) pmd_page_kernel(*(dir)) + pte_index(address))
+	((pte_t *) pmd_page_vaddr(*(dir)) + pte_index(address))
 #define pte_offset_kernel(dir, address)					\
-	((pte_t *) pmd_page_kernel(*(dir)) + pte_index(address))
+	((pte_t *) pmd_page_vaddr(*(dir)) + pte_index(address))
 #define pte_offset_map(dir, address) pte_offset_kernel(dir, address)
 #define pte_offset_map_nested(dir, address) pte_offset_kernel(dir, address)
 #define pte_unmap(pte)		do { } while (0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
