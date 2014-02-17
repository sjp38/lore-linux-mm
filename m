Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3BEEA6B0031
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 13:39:08 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id rr13so15608685pbb.7
        for <linux-mm@kvack.org>; Mon, 17 Feb 2014 10:39:07 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id bp2si15620619pab.272.2014.02.17.10.39.06
        for <linux-mm@kvack.org>;
        Mon, 17 Feb 2014 10:39:07 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/2] mm: introduce vm_ops->fault_nonblock()
Date: Mon, 17 Feb 2014 20:38:52 +0200
Message-Id: <1392662333-25470-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1392662333-25470-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1392662333-25470-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patch introduces new vm_ops callback ->fault_nonblock() and uses it
for mapping easy accessible pages around fault address.

On read page fault, if filesystem provides ->fault_nonblock(), we try to
map up to FAULT_AROUND_PAGES (32 at the moment) pages around page fault
address in hope to reduce number of minor page faults.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/filesystems/Locking |  8 ++++++++
 include/linux/mm.h                |  3 +++
 mm/memory.c                       | 38 +++++++++++++++++++++++++++++++++++++-
 3 files changed, 48 insertions(+), 1 deletion(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index 5b0c083d7c0e..11506b97e3b7 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -525,6 +525,7 @@ locking rules:
 open:		yes
 close:		yes
 fault:		yes		can return with page locked
+fault_nonblock	yes		must return with page locked
 page_mkwrite:	yes		can return with page locked
 access:		yes
 
@@ -536,6 +537,13 @@ the page, then ensure it is not already truncated (the page lock will block
 subsequent truncate), and then return with VM_FAULT_LOCKED, and the page
 locked. The VM will unlock the page.
 
+	->fault_nonblock() is called when VM tries to map easy accessible
+pages. Filesystem must find and return the page associated with the passed
+in "pgoff" in the vm_fault structure. If it's not possible to return a
+page without blocking, NULL should be returned. The page must be locked
+and filesystem must ensure page is not truncated. The VM will unlock the
+page. ->fault_nonblock() is called with page table locked.
+
 	->page_mkwrite() is called when a previously read-only pte is
 about to become writeable. The filesystem again must ensure that there are
 no truncate/invalidate races, and then return with the page locked. If
diff --git a/include/linux/mm.h b/include/linux/mm.h
index f28f46eade6a..b9a688dbd62a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -221,6 +221,8 @@ struct vm_operations_struct {
 	void (*open)(struct vm_area_struct * area);
 	void (*close)(struct vm_area_struct * area);
 	int (*fault)(struct vm_area_struct *vma, struct vm_fault *vmf);
+	void (*fault_nonblock)(struct vm_area_struct *vma,
+			struct vm_fault *vmf);
 
 	/* notification that a previously read-only page is about to become
 	 * writable, if an error is returned it will cause a SIGBUS */
@@ -1810,6 +1812,7 @@ extern void truncate_inode_pages_range(struct address_space *,
 
 /* generic vm_area_ops exported for stackable file systems */
 extern int filemap_fault(struct vm_area_struct *, struct vm_fault *);
+extern void filemap_fault_nonblock(struct vm_area_struct *, struct vm_fault *);
 extern int filemap_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf);
 
 /* mm/page-writeback.c */
diff --git a/mm/memory.c b/mm/memory.c
index 7f52c46ef1e1..f4990fb66770 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3342,6 +3342,39 @@ static void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 	update_mmu_cache(vma, address, pte);
 }
 
+#define FAULT_AROUND_ORDER 5
+#define FAULT_AROUND_PAGES (1UL << FAULT_AROUND_ORDER)
+#define FAULT_AROUND_MASK ~((1UL << (PAGE_SHIFT + FAULT_AROUND_ORDER)) - 1)
+
+static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
+		pte_t *pte, pgoff_t pgoff, unsigned int flags)
+{
+	struct vm_fault vmf;
+	unsigned long start_addr = address & FAULT_AROUND_MASK;
+	int off = (address - start_addr) >> PAGE_SHIFT;
+	int i;
+
+	for (i = 0; i < FAULT_AROUND_PAGES; i++) {
+		unsigned long addr = start_addr + i * PAGE_SIZE;
+		pte_t *_pte = pte - off +i;
+
+		if (!pte_none(*_pte))
+			continue;
+		if (addr < vma->vm_start || addr >= vma->vm_end)
+			continue;
+
+		vmf.virtual_address = (void __user *) addr;
+		vmf.pgoff = pgoff - off + i;
+		vmf.flags = flags;
+		vmf.page = NULL;
+		vma->vm_ops->fault_nonblock(vma, &vmf);
+		if (!vmf.page)
+			continue;
+		do_set_pte(vma, addr, vmf.page, _pte, false, false);
+		unlock_page(vmf.page);
+	}
+}
+
 static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd,
 		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
@@ -3363,8 +3396,11 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		return ret;
 	}
 	do_set_pte(vma, address, fault_page, pte, false, false);
-	pte_unmap_unlock(pte, ptl);
 	unlock_page(fault_page);
+
+	if (vma->vm_ops->fault_nonblock)
+		do_fault_around(vma, address, pte, pgoff, flags);
+	pte_unmap_unlock(pte, ptl);
 	return ret;
 }
 
-- 
1.9.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
