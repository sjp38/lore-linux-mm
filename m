Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id A99B66B0038
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 22:06:11 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so7102405pbb.31
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 19:06:11 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id pk8si17356359pab.184.2014.02.10.19.06.03
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 19:06:10 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/2] mm: extend ->fault interface to fault in few pages around fault address
Date: Tue, 11 Feb 2014 05:05:56 +0200
Message-Id: <1392087957-15730-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1392087957-15730-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1392087957-15730-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

If (flags & FAULT_FLAG_AROUND) fault handler asks ->fault to fill
->pages array with ->nr_pages pages if they are ready to map.

If a page is not ready to be map, no need to wait for it: skip to the
next.

It's okay to have some (or all) elements of the array set to NULL.

Indexes of pages must be in range between ->min and ->max inclusive.
Array must not contain page with index ->pgoff, in should be in ->pages.

->fault must set VM_FAULT_AROUND bit in return code, if it fills the
array.

Pages must be locked.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h | 24 +++++++++++++++++++++
 mm/memory.c        | 61 ++++++++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 79 insertions(+), 6 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f28f46eade6a..fe5629bc9e5b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -191,6 +191,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_KILLABLE	0x20	/* The fault task is in SIGKILL killable region */
 #define FAULT_FLAG_TRIED	0x40	/* second try */
 #define FAULT_FLAG_USER		0x80	/* The fault originated in userspace */
+#define FAULT_FLAG_AROUND	0x100   /* Try to get few pages a time */
 
 /*
  * vm_fault is filled by the the pagefault handler and passed to the vma's
@@ -210,6 +211,28 @@ struct vm_fault {
 					 * is set (which is also implied by
 					 * VM_FAULT_ERROR).
 					 */
+
+	/*
+	 * If (flags & FAULT_FLAG_AROUND) fault handler asks ->fault to fill
+	 * ->pages array with ->nr_pages pages if they are ready to map.
+	 *
+	 * If a page is not ready to be map, no need to wait for it: skip to
+	 * the next.
+	 *
+	 * It's okay to have some (or all) elements of the array set to NULL.
+	 *
+	 * Indexes of pages must be in range between ->min and ->max inclusive.
+	 * Array must not contain page with index ->pgoff, in should be in
+	 * ->pages.
+	 *
+	 * ->fault must set VM_FAULT_AROUND bit in return code, if it fills the
+	 * array.
+	 *
+	 * Pages must be locked.
+	 */
+	int nr_pages;
+	pgoff_t min, max;
+	struct page **pages;
 };
 
 /*
@@ -1004,6 +1027,7 @@ static inline int page_mapped(struct page *page)
 #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
 #define VM_FAULT_RETRY	0x0400	/* ->fault blocked, must retry */
 #define VM_FAULT_FALLBACK 0x0800	/* huge page fault failed, fall back to small */
+#define VM_FAULT_AROUND 0x1000	/* ->pages is filled */
 
 #define VM_FAULT_HWPOISON_LARGE_MASK 0xf000 /* encodes hpage index for large hwpoison */
 
diff --git a/mm/memory.c b/mm/memory.c
index 68c3dc141059..47ab9d6e1666 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3287,27 +3287,52 @@ oom:
 }
 
 static int __do_fault(struct vm_area_struct *vma, unsigned long address,
-		pgoff_t pgoff, unsigned int flags, struct page **page)
+		pgoff_t pgoff, unsigned int flags, struct page **page,
+		struct page **pages, int nr_pages)
 {
 	struct vm_fault vmf;
-	int ret;
+	int i, ret;
 
 	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
 	vmf.pgoff = pgoff;
 	vmf.flags = flags;
 	vmf.page = NULL;
 
+	if (flags & FAULT_FLAG_AROUND) {
+		vmf.pages = pages;
+		vmf.nr_pages = nr_pages;
+
+		/*
+		 * From page for address aligned down to FAULT_AROUND_PAGES
+		 * baundary, to the end of page table.
+		 */
+		vmf.min = pgoff - ((address >> PAGE_SHIFT) & (nr_pages - 1));
+		vmf.min = min(pgoff, vmf.min); /* underflow */
+		vmf.max = pgoff + PTRS_PER_PTE - 1 -
+			((address >> PAGE_SHIFT) & (PTRS_PER_PTE - 1));
+		/* Both should be inside the vma */
+		vmf.min = max(vma->vm_pgoff, vmf.min);
+		vmf.max = min(vma_pages(vma) + vma->vm_pgoff - 1, vmf.max);
+	}
+
 	ret = vma->vm_ops->fault(vma, &vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
 	if (unlikely(PageHWPoison(vmf.page))) {
+		for (i = 0; (ret & VM_FAULT_AROUND) && i < nr_pages; i++) {
+			if (!pages[i])
+				continue;
+			unlock_page(pages[i]);
+			page_cache_release(vmf.page);
+		}
 		if (ret & VM_FAULT_LOCKED)
 			unlock_page(vmf.page);
 		page_cache_release(vmf.page);
 		return VM_FAULT_HWPOISON;
 	}
 
+	/* pages on ->nr_pages are always return locked */
 	if (unlikely(!(ret & VM_FAULT_LOCKED)))
 		lock_page(vmf.page);
 	else
@@ -3341,16 +3366,21 @@ static void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 	update_mmu_cache(vma, address, pte);
 }
 
+#define FAULT_AROUND_PAGES 32
 static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd,
 		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
 {
 	struct page *fault_page;
+	struct page *pages[FAULT_AROUND_PAGES];
 	spinlock_t *ptl;
 	pte_t *pte;
-	int ret;
+	int i, ret;
 
-	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
+	if (!(flags & FAULT_FLAG_NONLINEAR))
+		flags |= FAULT_FLAG_AROUND;
+	ret = __do_fault(vma, address, pgoff, flags, &fault_page,
+			pages, ARRAY_SIZE(pages));
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
@@ -3362,6 +3392,25 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		return ret;
 	}
 	do_set_pte(vma, address, fault_page, pte, false, false);
+	for (i = 0; (ret & VM_FAULT_AROUND) && i < ARRAY_SIZE(pages); i++) {
+		pte_t *_pte;
+		unsigned long addr;
+		if (!pages[i])
+			continue;
+		VM_BUG_ON_PAGE(!PageLocked(pages[i]), pages[i]);
+		if (PageHWPoison(pages[i]))
+			goto skip;
+		_pte = pte + pages[i]->index - pgoff;
+		if (!pte_none(*_pte))
+			goto skip;
+		addr = address + PAGE_SIZE * (pages[i]->index - pgoff);
+		do_set_pte(vma, addr, pages[i], _pte, false, false);
+		unlock_page(pages[i]);
+		continue;
+skip:
+		unlock_page(pages[i]);
+		put_page(pages[i]);
+	}
 	pte_unmap_unlock(pte, ptl);
 	unlock_page(fault_page);
 	return ret;
@@ -3388,7 +3437,7 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		return VM_FAULT_OOM;
 	}
 
-	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
+	ret = __do_fault(vma, address, pgoff, flags, &fault_page, NULL, 0);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		goto uncharge_out;
 
@@ -3423,7 +3472,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	int dirtied = 0;
 	int ret, tmp;
 
-	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
+	ret = __do_fault(vma, address, pgoff, flags, &fault_page, NULL, 0);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
