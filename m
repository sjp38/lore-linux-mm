Message-Id: <200603151003.k2FA30g14232@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [discuss] Re: BUG in x86_64 hugepage support
Date: Wed, 15 Mar 2006 02:03:00 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <4417E359.76F0.0078.0@novell.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Jan Beulich' <JBeulich@novell.com>, Nishanth Aravamudan <nacc@us.ibm.com>
Cc: david@gibson.dropbear.id.au, linux-mm@kvack.org, Andreas Kleen <ak@suse.de>, agl@us.ibm.com, discuss@x86-64.org
List-ID: <linux-mm.kvack.org>

Nishanth Aravamudan wrote on Tuesday, March 14, 2006 11:31 PM
> Description: We currently fail mprotect testing in libhugetlbfs because
> the PSE bit in the hugepage PTEs gets unset. In the case where we know
> that a filled hugetlb PTE is going to have its protection changed, make
> sure it stays a hugetlb PTE by setting the PSE bit in the new protection
> flags.

Jan Beulich wrote on Wednesday, March 15, 2006 12:50 AM
> This is architecture independent code - you shouldn't be using
> _PAGE_PSE here. Probably x86-64 (and then likely also i386) should
> define their own set_huge_pte_at(), and use that# to or in the
> needed flag?


Yeah, that will do.  i386, x86_64 should also clean up pte_mkhuge() macro.
The unconditional setting of _PAGE_PRESENT bit was a leftover stuff from
the good'old day of pre-faulting hugetlb page.  



[patch] fix i386/x86-64 _PAGE_PSE bit when changing page protection

On i386 and x86-64, pte flag _PAGE_PSE collides with _PAGE_PROTNONE.
The identify of hugetlb pte is lost when changing page protection
via mprotect. A page fault occurs later will trigger a bug check in
huge_pte_alloc().

The fix is to always make new pte a hugetlb pte and also to clean up
legacy code where _PAGE_PRESENT is forced on in the pre-faulting day.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


diff -Nurp linux-2.6.15/include/asm-i386/pgtable.h linux-2.6.15-mm/include/asm-i386/pgtable.h
--- linux-2.6.15/include/asm-i386/pgtable.h	2006-01-02 19:21:10.000000000 -0800
+++ linux-2.6.15-mm/include/asm-i386/pgtable.h	2006-03-15 00:35:03.000000000 -0800
@@ -219,13 +219,12 @@ extern unsigned long pg0[];
  * The following only work if pte_present() is true.
  * Undefined behaviour if not..
  */
-#define __LARGE_PTE (_PAGE_PSE | _PAGE_PRESENT)
 static inline int pte_user(pte_t pte)		{ return (pte).pte_low & _PAGE_USER; }
 static inline int pte_read(pte_t pte)		{ return (pte).pte_low & _PAGE_USER; }
 static inline int pte_dirty(pte_t pte)		{ return (pte).pte_low & _PAGE_DIRTY; }
 static inline int pte_young(pte_t pte)		{ return (pte).pte_low & _PAGE_ACCESSED; }
 static inline int pte_write(pte_t pte)		{ return (pte).pte_low & _PAGE_RW; }
-static inline int pte_huge(pte_t pte)		{ return ((pte).pte_low & __LARGE_PTE) == __LARGE_PTE; }
+static inline int pte_huge(pte_t pte)		{ return (pte).pte_low & _PAGE_PSE; }
 
 /*
  * The following only works if pte_present() is not true.
@@ -242,7 +241,7 @@ static inline pte_t pte_mkexec(pte_t pte
 static inline pte_t pte_mkdirty(pte_t pte)	{ (pte).pte_low |= _PAGE_DIRTY; return pte; }
 static inline pte_t pte_mkyoung(pte_t pte)	{ (pte).pte_low |= _PAGE_ACCESSED; return pte; }
 static inline pte_t pte_mkwrite(pte_t pte)	{ (pte).pte_low |= _PAGE_RW; return pte; }
-static inline pte_t pte_mkhuge(pte_t pte)	{ (pte).pte_low |= __LARGE_PTE; return pte; }
+static inline pte_t pte_mkhuge(pte_t pte)	{ (pte).pte_low |= _PAGE_PSE; return pte; }
 
 #ifdef CONFIG_X86_PAE
 # include <asm/pgtable-3level.h>
diff -Nurp linux-2.6.15/include/asm-ia64/pgtable.h linux-2.6.15-mm/include/asm-ia64/pgtable.h
--- linux-2.6.15/include/asm-ia64/pgtable.h	2006-03-15 00:46:18.000000000 -0800
+++ linux-2.6.15-mm/include/asm-ia64/pgtable.h	2006-03-14 21:53:00.000000000 -0800
@@ -314,7 +314,7 @@ ia64_phys_addr_valid (unsigned long addr
 #define pte_mkyoung(pte)	(__pte(pte_val(pte) | _PAGE_A))
 #define pte_mkclean(pte)	(__pte(pte_val(pte) & ~_PAGE_D))
 #define pte_mkdirty(pte)	(__pte(pte_val(pte) | _PAGE_D))
-#define pte_mkhuge(pte)		(__pte(pte_val(pte) | _PAGE_P))
+#define pte_mkhuge(pte)		(__pte(pte_val(pte)))
 
 /*
  * Macro to a page protection value as "uncacheable".  Note that "protection" is really a
diff -Nurp linux-2.6.15/include/asm-x86_64/pgtable.h linux-2.6.15-mm/include/asm-x86_64/pgtable.h
--- linux-2.6.15/include/asm-x86_64/pgtable.h	2006-03-15 00:30:16.000000000 -0800
+++ linux-2.6.15-mm/include/asm-x86_64/pgtable.h	2006-03-15 00:35:55.000000000 -0800
@@ -273,7 +272,7 @@ static inline int pte_dirty(pte_t pte)		
 static inline int pte_young(pte_t pte)		{ return pte_val(pte) & _PAGE_ACCESSED; }
 static inline int pte_write(pte_t pte)		{ return pte_val(pte) & _PAGE_RW; }
 static inline int pte_file(pte_t pte)		{ return pte_val(pte) & _PAGE_FILE; }
-static inline int pte_huge(pte_t pte)		{ return (pte_val(pte) & __LARGE_PTE) == __LARGE_PTE; }
+static inline int pte_huge(pte_t pte)		{ return pte_val(pte) & _PAGE_PSE; }
 
 static inline pte_t pte_rdprotect(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_USER)); return pte; }
 static inline pte_t pte_exprotect(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_USER)); return pte; }
@@ -285,7 +284,7 @@ static inline pte_t pte_mkexec(pte_t pte
 static inline pte_t pte_mkdirty(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_DIRTY)); return pte; }
 static inline pte_t pte_mkyoung(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_ACCESSED)); return pte; }
 static inline pte_t pte_mkwrite(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_RW)); return pte; }
-static inline pte_t pte_mkhuge(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | __LARGE_PTE)); return pte; }
+static inline pte_t pte_mkhuge(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_PSE)); return pte; }
 
 struct vm_area_struct;
 
diff -Nurp linux-2.6.15/mm/hugetlb.c linux-2.6.15-mm/mm/hugetlb.c
--- linux-2.6.15/mm/hugetlb.c	2006-03-15 00:30:20.000000000 -0800
+++ linux-2.6.15-mm/mm/hugetlb.c	2006-03-14 23:49:55.000000000 -0800
@@ -731,7 +731,7 @@ void hugetlb_change_protection(struct vm
 			continue;
 		if (!pte_none(*ptep)) {
 			pte = huge_ptep_get_and_clear(mm, address, ptep);
-			pte = pte_modify(pte, newprot);
+			pte = pte_mkhuge(pte_modify(pte, newprot));
 			set_huge_pte_at(mm, address, ptep, pte);
 			lazy_mmu_prot_update(pte);
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
