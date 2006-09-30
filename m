From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: [patch 2/2] htlb shared page table
Date: Fri, 29 Sep 2006 17:39:08 -0700
Message-ID: <000201c6e428$db1f8aa0$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Hugh Dickins' <hugh@veritas.com>, 'Andrew Morton' <akpm@osdl.org>, 'Dave McCracken' <dmccr@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Remove RSS accounting. Due to hugetlb PT sharing, rss accounting is
no longer precise.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- ./mm/hugetlb.c.orig	2006-09-29 14:55:13.000000000 -0700
+++ ./mm/hugetlb.c	2006-09-29 14:56:18.000000000 -0700
@@ -344,7 +344,6 @@ int copy_hugetlb_page_range(struct mm_st
 			entry = *src_pte;
 			ptepage = pte_page(entry);
 			get_page(ptepage);
-			add_mm_counter(dst, file_rss, HPAGE_SIZE / PAGE_SIZE);
 			set_huge_pte_at(dst, addr, dst_pte, entry);
 		}
 		spin_unlock(&src->page_table_lock);
@@ -370,10 +369,6 @@ void unmap_hugepage_range(struct vm_area
 	BUG_ON(end & ~HPAGE_MASK);
 
 	spin_lock(&mm->page_table_lock);
-
-	/* Update high watermark before we lower rss */
-	update_hiwater_rss(mm);
-
 	for (address = start; address < end; address += HPAGE_SIZE) {
 		ptep = huge_pte_offset(mm, address);
 		if (!ptep)
@@ -388,9 +383,7 @@ void unmap_hugepage_range(struct vm_area
 
 		page = pte_page(pte);
 		put_page(page);
-		add_mm_counter(mm, file_rss, (int) -(HPAGE_SIZE / PAGE_SIZE));
 	}
-
 	spin_unlock(&mm->page_table_lock);
 	flush_tlb_range(vma, start, end);
 }
@@ -491,7 +484,6 @@ retry:
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
