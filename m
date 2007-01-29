Date: Mon, 29 Jan 2007 21:24:08 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: mremap correct rmap accounting
In-Reply-To: <Pine.LNX.4.64.0701292029390.20859@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0701292107510.26482@blonde.wat.veritas.com>
References: <45B61967.5000302@yahoo.com.au> <Pine.LNX.4.64.0701232041330.2461@blonde.wat.veritas.com>
 <45BD6A7B.7070501@yahoo.com.au> <Pine.LNX.4.64.0701291901550.8996@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0701291123460.3611@woody.linux-foundation.org>
 <Pine.LNX.4.64.0701292002310.16279@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0701291219040.3611@woody.linux-foundation.org>
 <Pine.LNX.4.64.0701292029390.20859@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Ralf Baechle <ralf@linux-mips.org>, Carsten Otte <cotte@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2007, Hugh Dickins wrote:
> 
> I'm currently thinking the right answer will be to keep the MIPS
> multiple ZERO_PAGEs, for their performance benefit, but ditch the
> way MIPS moves from one ZERO_PAGE to another in move_pte, trying
> desperately to retain that performance benefit across mremap.
> 
> It never used to do that, it was something Nick noticed and put
> into 2.6.14.  I've the ghost of a memory that at that time he
> had some code which was actually relying on ZERO_PAGE(vaddr)
> always being the expected ZERO_PAGE for that vaddr.
> I'm about to search my old mailboxes.

Ah, it wasn't any special patch of Nick's that needed it for
correctness, it was filemap_xip and its use the ZERO_PAGE(address)
(to avoid unnecessary page allocations): with page_check_address()
an interface for checking just a single page, not a range of them.

Could make it loop over them all, but a quicker patch would be as
below.  I've no idea if the intersection of filemap_xip users and
MIPS users is the empty set or more interesting.  But I'd prefer
you don't just slam in the patch, better have an opinion from
Carsten and/or Nick first.


Nick Piggin points out that page accounting on MIPS multiple ZERO_PAGEs
is not maintained by its move_pte, and could lead to freeing a ZERO_PAGE.
Instead of complicating that move_pte, just forget the minor optimization
when mremapping, and change the one thing which needed it for correctness
- filemap_xip use ZERO_PAGE(0) throughout instead of according to address.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 include/asm-mips/pgtable.h |   10 ----------
 mm/filemap_xip.c           |    4 ++--
 mm/mremap.c                |    1 -
 3 files changed, 2 insertions(+), 13 deletions(-)

--- 2.6.20-rc6/include/asm-mips/pgtable.h	2007-01-25 08:25:19.000000000 +0000
+++ linux/include/asm-mips/pgtable.h	2007-01-29 20:57:35.000000000 +0000
@@ -69,16 +69,6 @@ extern unsigned long zero_page_mask;
 #define ZERO_PAGE(vaddr) \
 	(virt_to_page((void *)(empty_zero_page + (((unsigned long)(vaddr)) & zero_page_mask))))
 
-#define __HAVE_ARCH_MOVE_PTE
-#define move_pte(pte, prot, old_addr, new_addr)				\
-({									\
- 	pte_t newpte = (pte);						\
-	if (pte_present(pte) && pfn_valid(pte_pfn(pte)) &&		\
-			pte_page(pte) == ZERO_PAGE(old_addr))		\
-		newpte = mk_pte(ZERO_PAGE(new_addr), (prot));		\
-	newpte;								\
-})
-
 extern void paging_init(void);
 
 /*
--- 2.6.20-rc6/mm/filemap_xip.c	2007-01-25 08:25:27.000000000 +0000
+++ linux/mm/filemap_xip.c	2007-01-29 20:57:35.000000000 +0000
@@ -183,7 +183,7 @@ __xip_unmap (struct address_space * mapp
 		address = vma->vm_start +
 			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 		BUG_ON(address < vma->vm_start || address >= vma->vm_end);
-		page = ZERO_PAGE(address);
+		page = ZERO_PAGE(0);
 		pte = page_check_address(page, mm, address, &ptl);
 		if (pte) {
 			/* Nuke the page table entry. */
@@ -246,7 +246,7 @@ xip_file_nopage(struct vm_area_struct * 
 		__xip_unmap(mapping, pgoff);
 	} else {
 		/* not shared and writable, use ZERO_PAGE() */
-		page = ZERO_PAGE(address);
+		page = ZERO_PAGE(0);
 	}
 
 out:
--- 2.6.20-rc6/mm/mremap.c	2006-11-29 21:57:37.000000000 +0000
+++ linux/mm/mremap.c	2007-01-29 20:57:35.000000000 +0000
@@ -105,7 +105,6 @@ static void move_ptes(struct vm_area_str
 		if (pte_none(*old_pte))
 			continue;
 		pte = ptep_clear_flush(vma, old_addr, old_pte);
-		/* ZERO_PAGE can be dependant on virtual addr */
 		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
 		set_pte_at(mm, new_addr, new_pte, pte);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
