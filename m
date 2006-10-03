From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: [patch] enforce proper tlb flush in unmap_hugepage_range
Date: Tue, 3 Oct 2006 02:28:37 -0700
Message-ID: <000001c6e6ce$4eb93590$bb80030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Hugh Dickins' <hugh@veritas.com>, 'Andrew Morton' <akpm@osdl.org>, bill.irwin@oracle.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Spotted by Hugh that hugetlb page is free'ed back to global pool
before performing any TLB flush in unmap_hugepage_range(). This
potentially allow threads to abuse free-alloc race condition.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

---
The generic tlb gather code is unsuitable to use by hugetlb, I
just open coded a page gathering list and delayed put_page until
tlb flush is performed.  Huge, please sign-off if you are OK
with this patch.


--- ./mm/hugetlb.c.orig	2006-09-19 20:42:06.000000000 -0700
+++ ./mm/hugetlb.c	2006-10-03 00:04:11.000000000 -0700
@@ -363,12 +363,14 @@ void unmap_hugepage_range(struct vm_area
 	unsigned long address;
 	pte_t *ptep;
 	pte_t pte;
-	struct page *page;
+	struct page *page, *tmp;
+	struct list_head page_list;
 
 	WARN_ON(!is_vm_hugetlb_page(vma));
 	BUG_ON(start & ~HPAGE_MASK);
 	BUG_ON(end & ~HPAGE_MASK);
 
+	INIT_LIST_HEAD(&page_list);
 	spin_lock(&mm->page_table_lock);
 
 	/* Update high watermark before we lower rss */
@@ -384,12 +386,16 @@ void unmap_hugepage_range(struct vm_area
 			continue;
 
 		page = pte_page(pte);
-		put_page(page);
+		list_add(&page->lru, &page_list);
 		add_mm_counter(mm, file_rss, (int) -(HPAGE_SIZE / PAGE_SIZE));
 	}
 
 	spin_unlock(&mm->page_table_lock);
 	flush_tlb_range(vma, start, end);
+	list_for_each_entry_safe(page, tmp, &page_list, lru) {
+		list_del(&page->lru);
+		put_page(page);
+	}
 }
 
 static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
