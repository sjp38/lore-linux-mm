Date: Tue, 6 May 2008 20:49:23 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH] x86: fix PAE pmd_bad bootup warning
In-Reply-To: <alpine.LFD.1.10.0805061138580.32269@woody.linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0805062043580.11647@blonde.site>
References: <b6a2187b0805051806v25fa1272xb08e0b70b9c3408@mail.gmail.com>
 <20080506124946.GA2146@elte.hu> <Pine.LNX.4.64.0805061435510.32567@blonde.site>
 <alpine.LFD.1.10.0805061138580.32269@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Jeff Chua <jeff.chua.linux@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Gabriel C <nix.or.die@googlemail.com>, Hans Rosenfeld <hans.rosenfeld@amd.com>, Arjan van de Ven <arjan@linux.intel.com>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Fix warning from pmd_bad() at bootup on a HIGHMEM64G HIGHPTE x86_32.

That came from 9fc34113f6880b215cbea4e7017fc818700384c2 x86: debug pmd_bad();
but we understand now that the typecasting was wrong for PAE in the previous
version: pagetable pages above 4GB looked bad and stopped Arjan from booting.

And revert that cded932b75ab0a5f9181ee3da34a0a488d1a14fd x86: fix pmd_bad
and pud_bad to support huge pages.  It was the wrong way round: we shouldn't
weaken every pmd_bad and pud_bad check to let huge pages slip through - in
part they check that we _don't_ have a huge page where it's not expected.

Put the x86 pmd_bad() and pud_bad() definitions back to what they have long
been: they can be improved (x86_32 should use PTE_MASK, to stop PAE thinking
junk in the upper word is good; and x86_64 should follow x86_32's stricter
comparison, to stop thinking any subset of required bits is good); but that
should be a later patch.

Fix Hans' good observation that follow_page() will never find pmd_huge()
because that would have already failed the pmd_bad test: test pmd_huge in
between the pmd_none and pmd_bad tests.  Tighten x86's pmd_huge() check?
No, once it's a hugepage entry, it can get quite far from a good pmd: for
example, PROT_NONE leaves it with only ACCESSED of the KERN_PGTABLE bits.

However... though follow_page() contains this and another test for huge
pages, so it's nice to keep it working on them, where does it actually get
called on a huge page?  get_user_pages() checks is_vm_hugetlb_page(vma) to
to call alternative hugetlb processing, as does unmap_vmas() and others.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
So Hans' original hugepage leak remains unexplained and unfixed.
Hans, did you find that hugepage leak with a standard kernel, or were
you perhaps trying out some hugepage-using patch of your own, without
marking the vma VM_HUGETLB?  Or were you expecting the hugetlbfs file
to truncate itself once all mmappers had gone?  If the standard kernel
leaks hugepages, I'm surprised the hugetlb guys don't know about it.

 arch/x86/mm/pgtable_32.c     |    7 -------
 include/asm-x86/pgtable_32.h |    9 +--------
 include/asm-x86/pgtable_64.h |    6 ++----
 mm/memory.c                  |    5 ++++-
 4 files changed, 7 insertions(+), 20 deletions(-)

--- 2.6.26-rc1/arch/x86/mm/pgtable_32.c	2008-05-03 21:54:41.000000000 +0100
+++ linux/arch/x86/mm/pgtable_32.c	2008-05-06 14:13:24.000000000 +0100
@@ -172,10 +172,3 @@ void reserve_top_address(unsigned long r
 	__FIXADDR_TOP = -reserve - PAGE_SIZE;
 	__VMALLOC_RESERVE += reserve;
 }
-
-int pmd_bad(pmd_t pmd)
-{
-	WARN_ON_ONCE(pmd_bad_v1(pmd) != pmd_bad_v2(pmd));
-
-	return pmd_bad_v1(pmd);
-}
--- 2.6.26-rc1/include/asm-x86/pgtable_32.h	2008-05-03 21:55:10.000000000 +0100
+++ linux/include/asm-x86/pgtable_32.h	2008-05-06 14:13:24.000000000 +0100
@@ -88,14 +88,7 @@ extern unsigned long pg0[];
 /* To avoid harmful races, pmd_none(x) should check only the lower when PAE */
 #define pmd_none(x)	(!(unsigned long)pmd_val((x)))
 #define pmd_present(x)	(pmd_val((x)) & _PAGE_PRESENT)
-
-extern int pmd_bad(pmd_t pmd);
-
-#define pmd_bad_v1(x)							\
-	(_KERNPG_TABLE != (pmd_val((x)) & ~(PAGE_MASK | _PAGE_USER)))
-#define	pmd_bad_v2(x)							\
-	(_KERNPG_TABLE != (pmd_val((x)) & ~(PAGE_MASK | _PAGE_USER |	\
-					    _PAGE_PSE | _PAGE_NX)))
+#define pmd_bad(x) ((pmd_val(x) & (~PAGE_MASK & ~_PAGE_USER)) != _KERNPG_TABLE)
 
 #define pages_to_mb(x) ((x) >> (20-PAGE_SHIFT))
 
--- 2.6.26-rc1/include/asm-x86/pgtable_64.h	2008-05-03 21:55:10.000000000 +0100
+++ linux/include/asm-x86/pgtable_64.h	2008-05-06 14:13:24.000000000 +0100
@@ -158,14 +158,12 @@ static inline unsigned long pgd_bad(pgd_
 
 static inline unsigned long pud_bad(pud_t pud)
 {
-	return pud_val(pud) &
-		~(PTE_MASK | _KERNPG_TABLE | _PAGE_USER | _PAGE_PSE | _PAGE_NX);
+	return pud_val(pud) & ~(PTE_MASK | _KERNPG_TABLE | _PAGE_USER);
 }
 
 static inline unsigned long pmd_bad(pmd_t pmd)
 {
-	return pmd_val(pmd) &
-		~(PTE_MASK | _KERNPG_TABLE | _PAGE_USER | _PAGE_PSE | _PAGE_NX);
+	return pmd_val(pmd) & ~(PTE_MASK | _KERNPG_TABLE | _PAGE_USER);
 }
 
 #define pte_none(x)	(!pte_val((x)))
--- 2.6.26-rc1/mm/memory.c	2008-05-03 21:55:12.000000000 +0100
+++ linux/mm/memory.c	2008-05-06 14:13:24.000000000 +0100
@@ -969,7 +969,7 @@ struct page *follow_page(struct vm_area_
 		goto no_page_table;
 	
 	pmd = pmd_offset(pud, address);
-	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
+	if (pmd_none(*pmd))
 		goto no_page_table;
 
 	if (pmd_huge(*pmd)) {
@@ -978,6 +978,9 @@ struct page *follow_page(struct vm_area_
 		goto out;
 	}
 
+	if (unlikely(pmd_bad(*pmd)))
+		goto no_page_table;
+
 	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
 	if (!ptep)
 		goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
