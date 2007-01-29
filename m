Message-ID: <45BD6A7B.7070501@yahoo.com.au>
Date: Mon, 29 Jan 2007 14:31:07 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch] mm: mremap correct rmap accounting
References: <45B61967.5000302@yahoo.com.au> <Pine.LNX.4.64.0701232041330.2461@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0701232041330.2461@blonde.wat.veritas.com>
Content-Type: multipart/mixed;
 boundary="------------070401070408050600040101"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Ralf Baechle <ralf@linux-mips.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070401070408050600040101
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hugh Dickins wrote:
> On Wed, 24 Jan 2007, Nick Piggin wrote:
> 
>>When mremap()ing virtual addresses, some architectures (read: MIPS) switches
>>underlying pages if encountering ZERO_PAGE(old_vaddr) != ZERO_PAGE(new_vaddr).
>>
>>The problem is that the refcount and mapcount remain on the old page, while
>>the actual pte is switched to the new one. This would counter underruns and
>>confuse the rmap code.
> 
> 
> Good point.  Nasty.
> 
> 
>>Fix it by actually moving accounting info to the new page. Would it be neater
>>to do this in move_pte? maybe rmap.c? (nick mumbles something about not
>>accounting ZERO_PAGE()s)
> 
> 
> Tiresome, I can quite see why it brings you to mumbling.
> 
> Though it looks right, I do hate the patch cluttering up move_ptes()
> like that: will the compiler be able to work out that that "unlikely"
> means impossible (and optimize away the code) on all arches but MIPS?
> Even if it can, I'd rather not see it there.
> 
> Could you make the MIPS move_pte() a proper function, say in
> arch/mips/mm/init.c next to setup_zero_pages(), and do that tiresome
> stuff there - should then be able to assume ZERO_PAGEs and skip the
> BUG_ON embellishments.
> 
> Utter nit-of-nits: my sense of symmetry prefers that you put_page()
> after page_remove_rmap() instead of before.

OK, how's this one?

Not tested on MIPS, but the same move_pte compiled on i386 here.

I sent Ralf a little test program that should eventually free a ZERO_PAGE
if it is run a few times (with a non-zero zero_page_mask). Do you have
time to confirm, Ralf?

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.

--------------070401070408050600040101
Content-Type: text/plain;
 name="rmap-mremap-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rmap-mremap-fix.patch"

When mremap()ing virtual addresses, some architectures (read: MIPS) switches
underlying pages if encountering ZERO_PAGE(old_vaddr) != ZERO_PAGE(new_vaddr).

The problem is that the refcount and mapcount remain on the old page, while
the actual pte is switched to the new one. This would counter underruns and
confuse the rmap code.

Fix it by actually moving accounting info to the new page in the MIPS
architecture code.

Also, clean up mremap slightly, so we can see where the old and the new pte
is being used.

Signed-off-by: Nick Piggin <npiggin@suse.de>


Index: linux-2.6/mm/mremap.c
===================================================================
--- linux-2.6.orig/mm/mremap.c	2007-01-24 01:00:53.000000000 +1100
+++ linux-2.6/mm/mremap.c	2007-01-29 14:17:13.000000000 +1100
@@ -72,7 +72,7 @@ static void move_ptes(struct vm_area_str
 {
 	struct address_space *mapping = NULL;
 	struct mm_struct *mm = vma->vm_mm;
-	pte_t *old_pte, *new_pte, pte;
+	pte_t *old_pte, *new_pte;
 	spinlock_t *old_ptl, *new_ptl;
 
 	if (vma->vm_file) {
@@ -102,12 +102,17 @@ static void move_ptes(struct vm_area_str
 
 	for (; old_addr < old_end; old_pte++, old_addr += PAGE_SIZE,
 				   new_pte++, new_addr += PAGE_SIZE) {
+		pte_t new, old;
+
 		if (pte_none(*old_pte))
 			continue;
-		pte = ptep_clear_flush(vma, old_addr, old_pte);
-		/* ZERO_PAGE can be dependant on virtual addr */
-		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
-		set_pte_at(mm, new_addr, new_pte, pte);
+		old = ptep_clear_flush(vma, old_addr, old_pte);
+		/*
+		 * ZERO_PAGE can be dependant on virtual addr, so pte may
+		 * actually have to be changed
+		 */
+		new = move_pte(old, new_vma->vm_page_prot, vma, old_addr, new_addr);
+		set_pte_at(mm, new_addr, new_pte, new);
 	}
 
 	arch_leave_lazy_mmu_mode();
Index: linux-2.6/arch/mips/mm/init.c
===================================================================
--- linux-2.6.orig/arch/mips/mm/init.c	2007-01-29 13:57:07.000000000 +1100
+++ linux-2.6/arch/mips/mm/init.c	2007-01-29 14:28:20.000000000 +1100
@@ -25,6 +25,7 @@
 #include <linux/swap.h>
 #include <linux/proc_fs.h>
 #include <linux/pfn.h>
+#include <linux/rmap.h>
 
 #include <asm/bootinfo.h>
 #include <asm/cachectl.h>
@@ -103,6 +104,41 @@ unsigned long setup_zero_pages(void)
 	return 1UL << order;
 }
 
+
+pte_t move_pte(pte_t pte, pgprot_t prot, struct vm_area_struct *old_vma,
+			unsigned long old_addr, unsigned long new_addr)
+{
+	unsigned long pfn;
+	struct page *old_page, *new_page;
+ 	pte_t newpte = pte;
+
+	if (!pte_present(pte))
+		goto out;
+
+	pfn = pte_pfn(pte);
+	if (!pfn_valid(pfn))
+		goto out;
+
+	old_page = vm_normal_page(old_vma, old_addr, pte);
+	if (likely(old_page != ZERO_PAGE(old_addr)))
+		goto out;
+
+	new_page = ZERO_PAGE(new_addr);
+	if (old_page == new_page)
+		goto out;
+
+	get_page(new_page);
+	page_add_file_rmap(new_page);
+
+	page_remove_rmap(old_page, old_vma);
+	put_page(old_page);
+
+	newpte = mk_pte(new_page, prot);
+
+out:
+	return newpte;
+}
+
 /*
  * These are almost like kmap_atomic / kunmap_atmic except they take an
  * additional address argument as the hint.
Index: linux-2.6/include/asm-generic/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-generic/pgtable.h	2007-01-29 13:56:10.000000000 +1100
+++ linux-2.6/include/asm-generic/pgtable.h	2007-01-29 14:19:06.000000000 +1100
@@ -159,7 +159,14 @@ static inline void ptep_set_wrprotect(st
 #endif
 
 #ifndef __HAVE_ARCH_MOVE_PTE
-#define move_pte(pte, prot, old_addr, new_addr)	(pte)
+/*
+ * Those architectures that define __HAVE_ARCH_MOVE_PTE must take care
+ * to update the rmap information on a vm_normal_page (which includes
+ * ZERO_PAGE), if they update the pte to some other page here.
+ *
+ * See MIPS for an example.
+ */
+#define move_pte(pte, prot, old_vma, old_addr, new_addr)	(pte)
 #endif
 
 /*
Index: linux-2.6/include/asm-mips/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-mips/pgtable.h	2007-01-29 13:55:38.000000000 +1100
+++ linux-2.6/include/asm-mips/pgtable.h	2007-01-29 14:28:20.000000000 +1100
@@ -70,14 +70,8 @@ extern unsigned long zero_page_mask;
 	(virt_to_page((void *)(empty_zero_page + (((unsigned long)(vaddr)) & zero_page_mask))))
 
 #define __HAVE_ARCH_MOVE_PTE
-#define move_pte(pte, prot, old_addr, new_addr)				\
-({									\
- 	pte_t newpte = (pte);						\
-	if (pte_present(pte) && pfn_valid(pte_pfn(pte)) &&		\
-			pte_page(pte) == ZERO_PAGE(old_addr))		\
-		newpte = mk_pte(ZERO_PAGE(new_addr), (prot));		\
-	newpte;								\
-})
+extern pte_t move_pte(pte_t pte, pgprot_t prot, struct vm_area_struct *old_vma,
+			unsigned long old_addr, unsigned long new_addr);
 
 extern void paging_init(void);
 
Index: linux-2.6/include/asm-sparc64/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-sparc64/pgtable.h	2007-01-29 14:10:38.000000000 +1100
+++ linux-2.6/include/asm-sparc64/pgtable.h	2007-01-29 14:11:32.000000000 +1100
@@ -691,7 +691,7 @@ static inline void set_pte_at(struct mm_
 
 #ifdef DCACHE_ALIASING_POSSIBLE
 #define __HAVE_ARCH_MOVE_PTE
-#define move_pte(pte, prot, old_addr, new_addr)				\
+#define move_pte(pte, prot, old_vma, old_addr, new_addr)		\
 ({									\
  	pte_t newpte = (pte);						\
 	if (tlb_type != hypervisor && pte_present(pte)) {		\

--------------070401070408050600040101--
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
