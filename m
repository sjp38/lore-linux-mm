Message-Id: <200508292245.j7TMjaaZ029207@shell0.pdx.osdl.net>
Subject: hugetlb-add-pte_huge-macro.patch added to -mm tree
From: akpm@osdl.org
Date: Mon, 29 Aug 2005 15:48:03 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: agl@us.ibm.com, linux-mm@kvack.org, mm-commits@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The patch titled

     hugetlb: add pte_huge() macro

has been added to the -mm tree.  Its filename is

     hugetlb-add-pte_huge-macro.patch

Patches currently in -mm which might be from agl@us.ibm.com are

hugetlb-add-pte_huge-macro.patch
hugetlb-move-stale-pte-check-into-huge_pte_alloc.patch
hugetlb-check-pd_present-in-huge_pte_offset.patch



From: Adam Litke <agl@us.ibm.com>

This patch adds a macro pte_huge(pte) for i386/x86_64 which is needed by a
patch later in the series.  Instead of repeating (_PAGE_PRESENT |
_PAGE_PSE), I've added __LARGE_PTE to i386 to match x86_64.

Signed-off-by: Adam Litke <agl@us.ibm.com>
Cc: <linux-mm@kvack.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 include/asm-i386/pgtable.h   |    4 +++-
 include/asm-x86_64/pgtable.h |    3 ++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff -puN include/asm-i386/pgtable.h~hugetlb-add-pte_huge-macro include/asm-i386/pgtable.h
--- 25/include/asm-i386/pgtable.h~hugetlb-add-pte_huge-macro	Mon Aug 29 15:48:01 2005
+++ 25-akpm/include/asm-i386/pgtable.h	Mon Aug 29 15:48:01 2005
@@ -215,11 +215,13 @@ extern unsigned long pg0[];
  * The following only work if pte_present() is true.
  * Undefined behaviour if not..
  */
+#define __LARGE_PTE (_PAGE_PSE | _PAGE_PRESENT)
 static inline int pte_user(pte_t pte)		{ return (pte).pte_low & _PAGE_USER; }
 static inline int pte_read(pte_t pte)		{ return (pte).pte_low & _PAGE_USER; }
 static inline int pte_dirty(pte_t pte)		{ return (pte).pte_low & _PAGE_DIRTY; }
 static inline int pte_young(pte_t pte)		{ return (pte).pte_low & _PAGE_ACCESSED; }
 static inline int pte_write(pte_t pte)		{ return (pte).pte_low & _PAGE_RW; }
+static inline int pte_huge(pte_t pte)		{ return ((pte).pte_low & __LARGE_PTE) == __LARGE_PTE; }
 
 /*
  * The following only works if pte_present() is not true.
@@ -236,7 +238,7 @@ static inline pte_t pte_mkexec(pte_t pte
 static inline pte_t pte_mkdirty(pte_t pte)	{ (pte).pte_low |= _PAGE_DIRTY; return pte; }
 static inline pte_t pte_mkyoung(pte_t pte)	{ (pte).pte_low |= _PAGE_ACCESSED; return pte; }
 static inline pte_t pte_mkwrite(pte_t pte)	{ (pte).pte_low |= _PAGE_RW; return pte; }
-static inline pte_t pte_mkhuge(pte_t pte)	{ (pte).pte_low |= _PAGE_PRESENT | _PAGE_PSE; return pte; }
+static inline pte_t pte_mkhuge(pte_t pte)	{ (pte).pte_low |= __LARGE_PTE; return pte; }
 
 #ifdef CONFIG_X86_PAE
 # include <asm/pgtable-3level.h>
diff -puN include/asm-x86_64/pgtable.h~hugetlb-add-pte_huge-macro include/asm-x86_64/pgtable.h
--- 25/include/asm-x86_64/pgtable.h~hugetlb-add-pte_huge-macro	Mon Aug 29 15:48:01 2005
+++ 25-akpm/include/asm-x86_64/pgtable.h	Mon Aug 29 15:48:01 2005
@@ -247,6 +247,7 @@ static inline pte_t pfn_pte(unsigned lon
  * The following only work if pte_present() is true.
  * Undefined behaviour if not..
  */
+#define __LARGE_PTE (_PAGE_PSE|_PAGE_PRESENT)
 static inline int pte_user(pte_t pte)		{ return pte_val(pte) & _PAGE_USER; }
 extern inline int pte_read(pte_t pte)		{ return pte_val(pte) & _PAGE_USER; }
 extern inline int pte_exec(pte_t pte)		{ return pte_val(pte) & _PAGE_USER; }
@@ -254,8 +255,8 @@ extern inline int pte_dirty(pte_t pte)		
 extern inline int pte_young(pte_t pte)		{ return pte_val(pte) & _PAGE_ACCESSED; }
 extern inline int pte_write(pte_t pte)		{ return pte_val(pte) & _PAGE_RW; }
 static inline int pte_file(pte_t pte)		{ return pte_val(pte) & _PAGE_FILE; }
+static inline int pte_huge(pte_t pte)		{ return (pte_val(pte) & __LARGE_PTE) == __LARGE_PTE; }
 
-#define __LARGE_PTE (_PAGE_PSE|_PAGE_PRESENT)
 extern inline pte_t pte_rdprotect(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_USER)); return pte; }
 extern inline pte_t pte_exprotect(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_USER)); return pte; }
 extern inline pte_t pte_mkclean(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_DIRTY)); return pte; }
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
