Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 8C9CD6B0072
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 14:54:12 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so2836448pdj.26
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 11:54:12 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id uc9si337496pac.123.2014.02.27.11.54.11
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 11:54:11 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 1/2] mm: introduce vm_ops->map_pages()
Date: Thu, 27 Feb 2014 21:53:46 +0200
Message-Id: <1393530827-25450-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patch introduces new vm_ops callback ->map_pages() and uses it for
mapping easy accessible pages around fault address.

On read page fault, if filesystem provides ->map_pages(), we try to map
up to FAULT_AROUND_PAGES pages around page fault address in hope to
reduce number of minor page faults.

We call ->map_pages first and use ->fault() as fallback if page by the
offset is not ready to be mapped (cold page cache or something).

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/filesystems/Locking | 10 ++++++
 include/linux/mm.h                |  8 +++++
 mm/memory.c                       | 67 +++++++++++++++++++++++++++++++++++++--
 3 files changed, 82 insertions(+), 3 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index 5b0c083d7c0e..767930f04a12 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -525,6 +525,7 @@ locking rules:
 open:		yes
 close:		yes
 fault:		yes		can return with page locked
+map_pages:	yes
 page_mkwrite:	yes		can return with page locked
 access:		yes
 
@@ -536,6 +537,15 @@ the page, then ensure it is not already truncated (the page lock will block
 subsequent truncate), and then return with VM_FAULT_LOCKED, and the page
 locked. The VM will unlock the page.
 
+	->map_pages() is called when VM asks to map easy accessible pages.
+Filesystem should find and map pages associated with offsets from "pgoff"
+till "max_pgoff". ->map_pages() is called with page table locked and must
+not block.  If it's not possible to reach a page without blocking,
+filesystem should skip it. Filesystem should use do_set_pte() to setup
+page table entry. Pointer to entry associated with offset "pgoff" is
+passed in "pte" field in vm_fault structure. Pointers to entries for other
+offsets should be calculated relative to "pte".
+
 	->page_mkwrite() is called when a previously read-only pte is
 about to become writeable. The filesystem again must ensure that there are
 no truncate/invalidate races, and then return with the page locked. If
diff --git a/include/linux/mm.h b/include/linux/mm.h
index f28f46eade6a..aed92cb17127 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -210,6 +210,10 @@ struct vm_fault {
 					 * is set (which is also implied by
 					 * VM_FAULT_ERROR).
 					 */
+	/* for ->map_pages() only */
+	pgoff_t max_pgoff;		/* map pages for offset from pgoff till
+					 * max_pgoff inclusive */
+	pte_t *pte;			/* pte entry associated with ->pgoff */
 };
 
 /*
@@ -221,6 +225,7 @@ struct vm_operations_struct {
 	void (*open)(struct vm_area_struct * area);
 	void (*close)(struct vm_area_struct * area);
 	int (*fault)(struct vm_area_struct *vma, struct vm_fault *vmf);
+	void (*map_pages)(struct vm_area_struct *vma, struct vm_fault *vmf);
 
 	/* notification that a previously read-only page is about to become
 	 * writable, if an error is returned it will cause a SIGBUS */
@@ -571,6 +576,9 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 		pte = pte_mkwrite(pte);
 	return pte;
 }
+
+void do_set_pte(struct vm_area_struct *vma, unsigned long address,
+		struct page *page, pte_t *pte, bool write, bool anon);
 #endif
 
 /*
diff --git a/mm/memory.c b/mm/memory.c
index 7f52c46ef1e1..3f17a60e817f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3318,7 +3318,8 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
 	return ret;
 }
 
-static void do_set_pte(struct vm_area_struct *vma, unsigned long address,
+
+void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 		struct page *page, pte_t *pte, bool write, bool anon)
 {
 	pte_t entry;
@@ -3342,6 +3343,52 @@ static void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 	update_mmu_cache(vma, address, pte);
 }
 
+#define FAULT_AROUND_ORDER 4
+#define FAULT_AROUND_PAGES (1UL << FAULT_AROUND_ORDER)
+#define FAULT_AROUND_MASK ~((1UL << (PAGE_SHIFT + FAULT_AROUND_ORDER)) - 1)
+
+static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
+		pte_t *pte, pgoff_t pgoff, unsigned int flags)
+{
+	unsigned long start_addr;
+	pgoff_t max_pgoff;
+	struct vm_fault vmf;
+	int off;
+
+	BUILD_BUG_ON(FAULT_AROUND_PAGES > PTRS_PER_PTE);
+
+	start_addr = max(address & FAULT_AROUND_MASK, vma->vm_start);
+	off = ((address - start_addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
+	pte -= off;
+	pgoff -= off;
+
+	/*
+	 *  max_pgoff is either end of page table or end of vma
+	 *  or FAULT_AROUND_PAGES from pgoff, depending what is neast.
+	 */
+	max_pgoff = pgoff - ((start_addr >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)) +
+		PTRS_PER_PTE - 1;
+	max_pgoff = min3(max_pgoff, vma_pages(vma) + vma->vm_pgoff - 1,
+			pgoff + FAULT_AROUND_PAGES - 1);
+
+	/* Check if it makes any sense to call ->map_pages */
+	while (!pte_none(*pte)) {
+		if (++pgoff > max_pgoff)
+			return;
+		start_addr += PAGE_SIZE;
+		if (start_addr >= vma->vm_end)
+			return;
+		pte++;
+	}
+
+	vmf.virtual_address = (void __user *) start_addr;
+	vmf.pte = pte;
+	vmf.pgoff = pgoff;
+	vmf.max_pgoff = max_pgoff;
+	vmf.flags = flags;
+	vma->vm_ops->map_pages(vma, &vmf);
+}
+
 static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd,
 		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
@@ -3349,7 +3396,20 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *fault_page;
 	spinlock_t *ptl;
 	pte_t *pte;
-	int ret;
+	int ret = 0;
+
+	/*
+	 * Let's call ->map_pages() first and use ->fault() as fallback
+	 * if page by the offset is not ready to be mapped (cold cache or
+	 * something).
+	 */
+	if (vma->vm_ops->map_pages) {
+		pte = pte_offset_map_lock(mm, pmd, address, &ptl);
+		do_fault_around(vma, address, pte, pgoff, flags);
+		if (!pte_same(*pte, orig_pte))
+			goto unlock_out;
+		pte_unmap_unlock(pte, ptl);
+	}
 
 	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
@@ -3363,8 +3423,9 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		return ret;
 	}
 	do_set_pte(vma, address, fault_page, pte, false, false);
-	pte_unmap_unlock(pte, ptl);
 	unlock_page(fault_page);
+unlock_out:
+	pte_unmap_unlock(pte, ptl);
 	return ret;
 }
 
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
