From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: [patch 2/2] htlb forget rss with pt sharing
Date: Thu, 19 Oct 2006 12:12:19 -0700
Message-ID: <000101c6f3b2$7f9cf980$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Hugh Dickins' <hugh@veritas.com>, 'Andrew Morton' <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Imprecise RSS accounting is an irritating ill effect with pt sharing. 
After consulted with several VM experts, I have tried various methods to
solve that problem: (1) iterate through all mm_structs that share the PT
and increment count; (2) keep RSS count in page table structure and then
sum them up at reporting time.  None of the above methods yield any
satisfactory implementation.

Since process RSS accounting is pure information only, I propose we don't
count them at all for hugetlb page. rlimit has such field, though there is
absolutely no enforcement on limiting that resource.  One other method is
to account all RSS at hugetlb mmap time regardless they are faulted or not.
I opt for the simplicity of no accounting at all.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./mm/hugetlb.c.orig	2006-10-19 10:01:43.000000000 -0700
+++ ./mm/hugetlb.c	2006-10-19 10:02:15.000000000 -0700
@@ -344,7 +344,6 @@ int copy_hugetlb_page_range(struct mm_st
 			entry = *src_pte;
 			ptepage = pte_page(entry);
 			get_page(ptepage);
-			add_mm_counter(dst, file_rss, HPAGE_SIZE / PAGE_SIZE);
 			set_huge_pte_at(dst, addr, dst_pte, entry);
 		}
 		spin_unlock(&src->page_table_lock);
@@ -372,10 +371,6 @@ void __unmap_hugepage_range(struct vm_ar
 	BUG_ON(end & ~HPAGE_MASK);
 
 	spin_lock(&mm->page_table_lock);
-
-	/* Update high watermark before we lower rss */
-	update_hiwater_rss(mm);
-
 	for (address = start; address < end; address += HPAGE_SIZE) {
 		ptep = huge_pte_offset(mm, address);
 		if (!ptep)
@@ -390,9 +385,7 @@ void __unmap_hugepage_range(struct vm_ar
 
 		page = pte_page(pte);
 		list_add(&page->lru, &page_list);
-		add_mm_counter(mm, file_rss, (int) -(HPAGE_SIZE / PAGE_SIZE));
 	}
-
 	spin_unlock(&mm->page_table_lock);
 	flush_tlb_range(vma, start, end);
 	list_for_each_entry_safe(page, tmp, &page_list, lru) {
@@ -515,7 +508,6 @@ retry:
 	if (!pte_none(*ptep))
 		goto backout;
 
-	add_mm_counter(mm, file_rss, HPAGE_SIZE / PAGE_SIZE);
 	new_pte = make_huge_pte(vma, page, ((vma->vm_flags & VM_WRITE)
 				&& (vma->vm_flags & VM_SHARED)));
 	set_huge_pte_at(mm, address, ptep, new_pte);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
