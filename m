From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [patch] shared page table for hugetlb page - v2
Date: Wed, 27 Sep 2006 01:34:21 -0700
Message-ID: <000c01c6e20f$bc2cd780$7684030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <Pine.LNX.4.64.0609262018270.3857@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Hugh Dickins' <hugh@veritas.com>
Cc: 'Andrew Morton' <akpm@osdl.org>, 'Dave McCracken' <dmccr@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote on Tuesday, September 26, 2006 1:03 PM
> I was impressed by how small and unintrusive this patch is, and how
> nicely it adheres to CodingStyle throughout.  But I've spotted one
> easily fixed bug, and quite a lot of raciness (depressingly, often
> issues already pointed out and hopefully by now fixed in Dave's;
> but one of the racinesses is already there before your patch).
> 
> Unfit for mainline until those are dealt with: though I don't think
> the fixes are going to expand and complicate it terribly, so it
> should remain palatable.  My main fear is that the longer I look,
> the more raciness I may find: it just seems hard to get shared page
> table locking right; I am hoping that once it is right, it won't be
> so correspondingly fragile.

Yeah, I completely overlooked the locking for the shared page table
page, given the fact that mm_struct->page_table_lock is no longer
appropriate to protect multiple mm that share the same page table
page. Duh, the locking need to be done at higher level.

Below is my new RFC patch on the locking implementation: my first cut
is to use i_mmap_lock throughout to protect these pages. I will implement
atomic ref count later to see which one is better. Here is a rough
outline of what I did:

Change unmap_hugepage_range() to __unmap_hugepage_range so it can be
used in the truncating path.  In the munmap path, added new function
unmap_hugepage_range to hold i_mmap_lock and then calls __unmap... In
function hugetlb_change_protection(), i_mmap_lock is added around
page table manipulation.  Is this acceptable?  Or am I going to get
screamed at for adding i_mmap_lock in the mprotect and munmap path?


> > +
> > +	spin_lock(&mapping->i_mmap_lock);
> > +	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap,
> > +			      vma->vm_pgoff, vma->vm_pgoff) {
> > +		if (svma == vma ||
> > +		    !page_table_shareable(svma, vma, addr, PUD_SIZE))
> > +			continue;
> 
> No.  Holding i_mmap_lock is indeed good enough to protect against racing
> changes to vm_start, vm_end, vm_pgoff (since vma_adjust has to be careful
> not to undermine the prio_tree without it), but it's not enough to protect
> against racing changes to vm_flags (e.g. by mprotect), and that's a part
> of what page_table_shareable has to check (though you might in the end
> want to separate it out, if it's going to be more efficient to check the
> safe ones first before getting adequate locking for vm_flags).  We went
> around this with Dave before, he now does down_read_trylock on mmap_sem
> to secure vm_flags.

I agree with you that vm_flags need to be secured.  But I don't see why
mmap_sem is the only qualifying candidate. Perhaps it was because lack of
lock protection in the unshare path in the earlier version?  If I take
svma->page_table_lock, check against matching vm_flags and then increment
a ref count on the shared page table page, won't that be enough?  Even if
another mm (call it P) changed vm_flags after the check, the ref count will
keep the page around and the pte we got will preserve the original protection
flags. And because of the ref count, P will notice the sharing state when it
unshares the page. Actually the exact timing doesn't really matter as P will
let go the mapping unconditionally anyway.

Along with the patch is a fix to address a bug in matching vma. Now it will
match actual backing file offset of the faulting page and the virtual address.
(It doesn't have to match all virtual address bit.  I will do more in the
next rev).


diff -Nurp linux-2.6.18/arch/i386/mm/hugetlbpage.c linux-2.6.18.ken/arch/i386/mm/hugetlbpage.c
--- linux-2.6.18/arch/i386/mm/hugetlbpage.c	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18.ken/arch/i386/mm/hugetlbpage.c	2006-09-26 23:42:51.000000000 -0700
@@ -17,16 +17,122 @@
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
 
+static int page_table_shareable(struct vm_area_struct *svma,
+			 struct vm_area_struct *vma,
+			 unsigned long addr, unsigned long idx)
+{
+	unsigned long base = addr & ~(PUD_SIZE - 1);
+	unsigned long end = base + PUD_SIZE;
+
+	unsigned long saddr = ((idx - svma->vm_pgoff) << PAGE_SHIFT) +
+				svma->vm_start;
+	unsigned long sbase = saddr & ~(PUD_SIZE - 1);
+	unsigned long s_end = sbase + PUD_SIZE;
+
+	/*
+	 * match the virtual addresses, permission  and the alignment of the
+	 * page table page.
+	 */
+	if (addr != saddr || vma->vm_flags != svma->vm_flags ||
+	    base < vma->vm_start || vma->vm_end < end ||
+	    sbase < svma->vm_start || svma->vm_end < s_end)
+		return 0;
+
+	return 1;
+}
+
+/*
+ * search for a shareable pmd page for hugetlb.
+ */
+static void pmd_share(struct vm_area_struct *vma, pud_t *pud,
+			unsigned long addr)
+{
+	unsigned long idx = ((addr - vma->vm_start) >> PAGE_SHIFT) +
+			    vma->vm_pgoff;
+	struct address_space *mapping = vma->vm_file->f_mapping;
+	struct prio_tree_iter iter;
+	struct vm_area_struct *svma;
+	pte_t *spte = NULL;
+
+	if (!vma->vm_flags & VM_MAYSHARE)
+		return;
+
+	spin_lock(&mapping->i_mmap_lock);
+	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap, idx, idx) {
+		if (svma == vma || !page_table_shareable(svma, vma, addr, idx))
+			continue;
+
+		/*
+		 * now that we found a suitable vma, next step is to find a
+		 * valid hugetlb pte page.  Recheck svma->vm_flags with
+		 * paga_table_lock held since checking above is done
+		 * without lock.
+		 */
+		spin_lock(&svma->vm_mm->page_table_lock);
+		if (vma->vm_flags == svma->vm_flags) {
+			spte = huge_pte_offset(svma->vm_mm, addr);
+			if (spte)
+				get_page(virt_to_page(spte));
+		}
+		spin_unlock(&svma->vm_mm->page_table_lock);
+		if (spte)
+			break;
+	}
+
+	if (!spte)
+		goto out;
+
+	spin_lock(&vma->vm_mm->page_table_lock);
+	if (pud_none(*pud))
+		pud_populate(mm, pud, (unsigned long) spte & PAGE_MASK);
+	else
+		put_page(virt_to_page(spte));
+	spin_unlock(&vma->vm_mm->page_table_lock);
+out:
+	spin_unlock(&mapping->i_mmap_lock);
+}
+
+/*
+ * unmap huge page backed by shared pte.
+ *
+ * Hugetlb pte page is ref counted at the time of mapping.  If pte is shared
+ * indicated by page_count > 1, unmap is achieved by clearing pud and
+ * decrementing the ref count. If count == 1, the pte page is not shared.
+ * 
+ * called with vma->vm_file->f_mapping->i_mmap_lock and 
+ *	       vma->vm_mm->page_table_lock held.
+ *
+ * returns: 1 successfully unmapped a shared pte page
+ *	    0 the underlying pte page is not shared, or it is the last user
+ */
+int huge_pte_put(struct vm_area_struct *vma, unsigned long *addr, pte_t *ptep)
+{
+	pgd_t *pgd = pgd_offset(vma->vm_mm, *addr);
+	pud_t *pud = pud_offset(pgd, *addr);
+
+	if (page_count(virt_to_page(ptep)) <= 1)
+		return 0;
+
+	pud_clear(pud);
+	put_page(virt_to_page(ptep));
+	*addr = ALIGN(*addr, HPAGE_SIZE * PTRS_PER_PTE) - HPAGE_SIZE;
+	return 1;
+}
+
 pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr)
 {
+	struct vm_area_struct *vma = find_vma(mm, addr);
 	pgd_t *pgd;
 	pud_t *pud;
 	pte_t *pte = NULL;
 
 	pgd = pgd_offset(mm, addr);
 	pud = pud_alloc(mm, pgd, addr);
-	if (pud)
+	if (pud) {
+		if (pud_none(*pud))
+			pmd_share(vma, pud, addr);
 		pte = (pte_t *) pmd_alloc(mm, pud, addr);
+	}
 	BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));
 
 	return pte;
diff -Nurp linux-2.6.18/fs/hugetlbfs/inode.c linux-2.6.18.ken/fs/hugetlbfs/inode.c
--- linux-2.6.18/fs/hugetlbfs/inode.c	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18.ken/fs/hugetlbfs/inode.c	2006-09-26 21:57:24.000000000 -0700
@@ -293,7 +293,7 @@ hugetlb_vmtruncate_list(struct prio_tree
 		if (h_vm_pgoff >= h_pgoff)
 			v_offset = 0;
 
-		unmap_hugepage_range(vma,
+		__unmap_hugepage_range(vma,
 				vma->vm_start + v_offset, vma->vm_end);
 	}
 }
diff -Nurp linux-2.6.18/include/linux/hugetlb.h linux-2.6.18.ken/include/linux/hugetlb.h
--- linux-2.6.18/include/linux/hugetlb.h	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18.ken/include/linux/hugetlb.h	2006-09-26 22:14:55.000000000 -0700
@@ -17,6 +17,7 @@ int hugetlb_sysctl_handler(struct ctl_ta
 int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
 int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *, struct page **, struct vm_area_struct **, unsigned long *, int
*, int);
 void unmap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned long);
+void __unmap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned long);
 int hugetlb_prefault(struct address_space *, struct vm_area_struct *);
 int hugetlb_report_meminfo(char *);
 int hugetlb_report_node_meminfo(int, char *);
diff -Nurp linux-2.6.18/mm/hugetlb.c linux-2.6.18.ken/mm/hugetlb.c
--- linux-2.6.18/mm/hugetlb.c	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18.ken/mm/hugetlb.c	2006-09-26 22:50:02.000000000 -0700
@@ -344,7 +344,6 @@ int copy_hugetlb_page_range(struct mm_st
 			entry = *src_pte;
 			ptepage = pte_page(entry);
 			get_page(ptepage);
-			add_mm_counter(dst, file_rss, HPAGE_SIZE / PAGE_SIZE);
 			set_huge_pte_at(dst, addr, dst_pte, entry);
 		}
 		spin_unlock(&src->page_table_lock);
@@ -356,7 +355,13 @@ nomem:
 	return -ENOMEM;
 }
 
-void unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
+__attribute__((weak))
+int huge_pte_put(struct vm_area_struct *vma, unsigned long *addr, pte_t *ptep)
+{
+	return 0;
+}
+
+void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
 			  unsigned long end)
 {
 	struct mm_struct *mm = vma->vm_mm;
@@ -370,28 +375,35 @@ void unmap_hugepage_range(struct vm_area
 	BUG_ON(end & ~HPAGE_MASK);
 
 	spin_lock(&mm->page_table_lock);
-
-	/* Update high watermark before we lower rss */
-	update_hiwater_rss(mm);
-
 	for (address = start; address < end; address += HPAGE_SIZE) {
 		ptep = huge_pte_offset(mm, address);
 		if (!ptep)
 			continue;
 
+		if (huge_pte_put(vma, &address, ptep))
+			continue;
+
 		pte = huge_ptep_get_and_clear(mm, address, ptep);
 		if (pte_none(pte))
 			continue;
 
 		page = pte_page(pte);
 		put_page(page);
-		add_mm_counter(mm, file_rss, (int) -(HPAGE_SIZE / PAGE_SIZE));
 	}
-
 	spin_unlock(&mm->page_table_lock);
 	flush_tlb_range(vma, start, end);
 }
 
+void unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
+			  unsigned long end)
+{
+	if (vma->vm_file) {
+		spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
+		__unmap_hugepage_range(vma, start, end);
+		spin_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
+	}
+}
+
 static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, pte_t *ptep, pte_t pte)
 {
@@ -488,7 +500,6 @@ retry:
 	if (!pte_none(*ptep))
 		goto backout;
 
-	add_mm_counter(mm, file_rss, HPAGE_SIZE / PAGE_SIZE);
 	new_pte = make_huge_pte(vma, page, ((vma->vm_flags & VM_WRITE)
 				&& (vma->vm_flags & VM_SHARED)));
 	set_huge_pte_at(mm, address, ptep, new_pte);
@@ -626,11 +637,14 @@ void hugetlb_change_protection(struct vm
 	BUG_ON(address >= end);
 	flush_cache_range(vma, address, end);
 
+	spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
 	spin_lock(&mm->page_table_lock);
 	for (; address < end; address += HPAGE_SIZE) {
 		ptep = huge_pte_offset(mm, address);
 		if (!ptep)
 			continue;
+		if (huge_pte_put(vma, &address, ptep))
+			continue;
 		if (!pte_none(*ptep)) {
 			pte = huge_ptep_get_and_clear(mm, address, ptep);
 			pte = pte_mkhuge(pte_modify(pte, newprot));
@@ -639,6 +653,7 @@ void hugetlb_change_protection(struct vm
 		}
 	}
 	spin_unlock(&mm->page_table_lock);
+	spin_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
 
 	flush_tlb_range(vma, start, end);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
