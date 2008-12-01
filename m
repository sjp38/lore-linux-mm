Date: Mon, 1 Dec 2008 00:42:36 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 3/8] badpage: replace page_remove_rmap Eeek and BUG
In-Reply-To: <Pine.LNX.4.64.0812010032210.10131@blonde.site>
Message-ID: <Pine.LNX.4.64.0812010041460.11401@blonde.site>
References: <Pine.LNX.4.64.0812010032210.10131@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Dave Jones <davej@redhat.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Now that bad pages are kept out of circulation, there is no need for the
infamous page_remove_rmap() BUG() - once that page is freed, its negative
mapcount will issue a "Bad page state" message and the page won't be freed.
Removing the BUG() allows more info, on subsequent pages, to be gathered.

We do have more info about the page at this point than bad_page() can know
- notably, what the pmd is, which might pinpoint something like low 64kB
corruption - but page_remove_rmap() isn't given the address to find that.

In practice, there is only one call to page_remove_rmap() which has ever
reported anything, that from zap_pte_range() (usually on exit, sometimes
on munmap).  It has all the info, so remove page_remove_rmap()'s "Eeek"
message and leave it all to zap_pte_range().

mm/memory.c already has a hardly used print_bad_pte() function, showing
some of the appropriate info: extend it to show what we want for the rmap
case: pte info, page info (when there is a page) and vma info to compare.
zap_pte_range() already knows the pmd, but print_bad_pte() is easier to
use if it works that out for itself.

Some of this info is also shown in bad_page()'s "Bad page state" message.
Keep them separate, but adjust them to match each other as far as possible.
Say "Bad page map" in print_bad_pte(), and add a TAINT_BAD_PAGE there too.

print_bad_pte() show current->comm unconditionally (though it should get
repeated in the usually irrelevant stack trace): sorry, I misled Nick
Piggin to make it conditional on vm_mm == current->mm, but current->mm
is already NULL in the exit case.  Usually current->comm is good, though
exceptionally it may not be that of the mm (when "swapoff" for example).

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/memory.c     |   50 +++++++++++++++++++++++++++++++++++-----------
 mm/page_alloc.c |   14 ++++++------
 mm/rmap.c       |   16 --------------
 3 files changed, 46 insertions(+), 34 deletions(-)

--- badpage2/mm/memory.c	2008-11-26 12:19:00.000000000 +0000
+++ badpage3/mm/memory.c	2008-11-28 20:40:40.000000000 +0000
@@ -52,6 +52,9 @@
 #include <linux/writeback.h>
 #include <linux/memcontrol.h>
 #include <linux/mmu_notifier.h>
+#include <linux/kallsyms.h>
+#include <linux/swapops.h>
+#include <linux/elf.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -59,9 +62,6 @@
 #include <asm/tlbflush.h>
 #include <asm/pgtable.h>
 
-#include <linux/swapops.h>
-#include <linux/elf.h>
-
 #include "internal.h"
 
 #ifndef CONFIG_NEED_MULTIPLE_NODES
@@ -375,15 +375,41 @@ static inline void add_mm_rss(struct mm_
  *
  * The calling function must still handle the error.
  */
-static void print_bad_pte(struct vm_area_struct *vma, pte_t pte,
-			  unsigned long vaddr)
+static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
+			  pte_t pte, struct page *page)
 {
-	printk(KERN_ERR "Bad pte = %08llx, process = %s, "
-			"vm_flags = %lx, vaddr = %lx\n",
-		(long long)pte_val(pte),
-		(vma->vm_mm == current->mm ? current->comm : "???"),
-		vma->vm_flags, vaddr);
+	pgd_t *pgd = pgd_offset(vma->vm_mm, addr);
+	pud_t *pud = pud_offset(pgd, addr);
+	pmd_t *pmd = pmd_offset(pud, addr);
+	struct address_space *mapping;
+	pgoff_t index;
+
+	mapping = vma->vm_file ? vma->vm_file->f_mapping : NULL;
+	index = linear_page_index(vma, addr);
+
+	printk(KERN_EMERG "Bad page map in process %s  pte:%08llx pmd:%08llx\n",
+		current->comm,
+		(long long)pte_val(pte), (long long)pmd_val(*pmd));
+	if (page) {
+		printk(KERN_EMERG
+		"page:%p flags:%p count:%d mapcount:%d mapping:%p index:%lx\n",
+		page, (void *)page->flags, page_count(page),
+		page_mapcount(page), page->mapping, page->index);
+	}
+	printk(KERN_EMERG
+		"addr:%p vm_flags:%08lx anon_vma:%p mapping:%p index:%lx\n",
+		(void *)addr, vma->vm_flags, vma->anon_vma, mapping, index);
+	/*
+	 * Choose text because data symbols depend on CONFIG_KALLSYMS_ALL=y
+	 */
+	if (vma->vm_ops)
+		print_symbol(KERN_EMERG "vma->vm_ops->fault: %s\n",
+				(unsigned long)vma->vm_ops->fault);
+	if (vma->vm_file && vma->vm_file->f_op)
+		print_symbol(KERN_EMERG "vma->vm_file->f_op->mmap: %s\n",
+				(unsigned long)vma->vm_file->f_op->mmap);
 	dump_stack();
+	add_taint(TAINT_BAD_PAGE);
 }
 
 static inline int is_cow_mapping(unsigned int flags)
@@ -763,6 +789,8 @@ static unsigned long zap_pte_range(struc
 				file_rss--;
 			}
 			page_remove_rmap(page, vma);
+			if (unlikely(page_mapcount(page) < 0))
+				print_bad_pte(vma, addr, ptent, page);
 			tlb_remove_page(tlb, page);
 			continue;
 		}
@@ -2657,7 +2685,7 @@ static int do_nonlinear_fault(struct mm_
 		/*
 		 * Page table corrupted: show pte and kill process.
 		 */
-		print_bad_pte(vma, orig_pte, address);
+		print_bad_pte(vma, address, orig_pte, NULL);
 		return VM_FAULT_OOM;
 	}
 
--- badpage2/mm/page_alloc.c	2008-11-28 20:40:36.000000000 +0000
+++ badpage3/mm/page_alloc.c	2008-11-28 20:40:40.000000000 +0000
@@ -222,14 +222,14 @@ static inline int bad_range(struct zone 
 
 static void bad_page(struct page *page)
 {
-	printk(KERN_EMERG "Bad page state in process '%s'\n" KERN_EMERG
-		"page:%p flags:0x%0*lx mapping:%p mapcount:%d count:%d\n",
-		current->comm, page, (int)(2*sizeof(unsigned long)),
-		(unsigned long)page->flags, page->mapping,
-		page_mapcount(page), page_count(page));
+	printk(KERN_EMERG "Bad page state in process %s  pfn:%05lx\n",
+		current->comm, page_to_pfn(page));
+	printk(KERN_EMERG
+		"page:%p flags:%p count:%d mapcount:%d mapping:%p index:%lx\n",
+		page, (void *)page->flags, page_count(page),
+		page_mapcount(page), page->mapping, page->index);
+	printk(KERN_EMERG "Trying to fix it up, but a reboot is needed\n");
 
-	printk(KERN_EMERG "Trying to fix it up, but a reboot is needed\n"
-		KERN_EMERG "Backtrace:\n");
 	dump_stack();
 
 	/* Leave bad fields for debug, except PageBuddy could make trouble */
--- badpage2/mm/rmap.c	2008-11-26 12:19:00.000000000 +0000
+++ badpage3/mm/rmap.c	2008-11-28 20:40:40.000000000 +0000
@@ -47,7 +47,6 @@
 #include <linux/rmap.h>
 #include <linux/rcupdate.h>
 #include <linux/module.h>
-#include <linux/kallsyms.h>
 #include <linux/memcontrol.h>
 #include <linux/mmu_notifier.h>
 #include <linux/migrate.h>
@@ -725,21 +724,6 @@ void page_dup_rmap(struct page *page, st
 void page_remove_rmap(struct page *page, struct vm_area_struct *vma)
 {
 	if (atomic_add_negative(-1, &page->_mapcount)) {
-		if (unlikely(page_mapcount(page) < 0)) {
-			printk (KERN_EMERG "Eeek! page_mapcount(page) went negative! (%d)\n", page_mapcount(page));
-			printk (KERN_EMERG "  page pfn = %lx\n", page_to_pfn(page));
-			printk (KERN_EMERG "  page->flags = %lx\n", page->flags);
-			printk (KERN_EMERG "  page->count = %x\n", page_count(page));
-			printk (KERN_EMERG "  page->mapping = %p\n", page->mapping);
-			print_symbol (KERN_EMERG "  vma->vm_ops = %s\n", (unsigned long)vma->vm_ops);
-			if (vma->vm_ops) {
-				print_symbol (KERN_EMERG "  vma->vm_ops->fault = %s\n", (unsigned long)vma->vm_ops->fault);
-			}
-			if (vma->vm_file && vma->vm_file->f_op)
-				print_symbol (KERN_EMERG "  vma->vm_file->f_op->mmap = %s\n", (unsigned long)vma->vm_file->f_op->mmap);
-			BUG();
-		}
-
 		/*
 		 * Now that the last pte has gone, s390 must transfer dirty
 		 * flag from storage key to struct page.  We can usually skip

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
