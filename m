Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id D61D26B0038
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 12:12:17 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id bj1so5265928pad.5
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 09:12:17 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ki9si1249487pdb.160.2015.02.11.09.12.16
        for <linux-mm@kvack.org>;
        Wed, 11 Feb 2015 09:12:16 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/4] mm: rename __mlock_vma_pages_range() to populate_vma_page_range()
Date: Wed, 11 Feb 2015 19:12:06 +0200
Message-Id: <1423674728-214192-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423674728-214192-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423674728-214192-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

__mlock_vma_pages_range() doesn't necessary mlock pages. It depends on
vma flags. The same codepath is used for MAP_POPULATE.

Let's rename __mlock_vma_pages_range() to populate_vma_page_range().

This patch also drops mlock_vma_pages_range() references from
documentation. It has gone in commit cea10a19b797.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Michel Lespinasse <walken@google.com>
---
 Documentation/vm/unevictable-lru.txt | 26 ++++++++------------------
 mm/internal.h                        |  2 +-
 mm/mlock.c                           | 12 ++++++------
 mm/mmap.c                            |  4 ++--
 4 files changed, 17 insertions(+), 27 deletions(-)

diff --git a/Documentation/vm/unevictable-lru.txt b/Documentation/vm/unevictable-lru.txt
index 744f82f86c58..86cb4624fc5a 100644
--- a/Documentation/vm/unevictable-lru.txt
+++ b/Documentation/vm/unevictable-lru.txt
@@ -317,7 +317,7 @@ If the VMA passes some filtering as described in "Filtering Special Vmas"
 below, mlock_fixup() will attempt to merge the VMA with its neighbors or split
 off a subset of the VMA if the range does not cover the entire VMA.  Once the
 VMA has been merged or split or neither, mlock_fixup() will call
-__mlock_vma_pages_range() to fault in the pages via get_user_pages() and to
+populate_vma_page_range() to fault in the pages via get_user_pages() and to
 mark the pages as mlocked via mlock_vma_page().
 
 Note that the VMA being mlocked might be mapped with PROT_NONE.  In this case,
@@ -327,7 +327,7 @@ fault path or in vmscan.
 
 Also note that a page returned by get_user_pages() could be truncated or
 migrated out from under us, while we're trying to mlock it.  To detect this,
-__mlock_vma_pages_range() checks page_mapping() after acquiring the page lock.
+populate_vma_page_range() checks page_mapping() after acquiring the page lock.
 If the page is still associated with its mapping, we'll go ahead and call
 mlock_vma_page().  If the mapping is gone, we just unlock the page and move on.
 In the worst case, this will result in a page mapped in a VM_LOCKED VMA
@@ -392,7 +392,7 @@ ignored for munlock.
 
 If the VMA is VM_LOCKED, mlock_fixup() again attempts to merge or split off the
 specified range.  The range is then munlocked via the function
-__mlock_vma_pages_range() - the same function used to mlock a VMA range -
+populate_vma_page_range() - the same function used to mlock a VMA range -
 passing a flag to indicate that munlock() is being performed.
 
 Because the VMA access protections could have been changed to PROT_NONE after
@@ -402,7 +402,7 @@ get_user_pages() was enhanced to accept a flag to ignore the permissions when
 fetching the pages - all of which should be resident as a result of previous
 mlocking.
 
-For munlock(), __mlock_vma_pages_range() unlocks individual pages by calling
+For munlock(), populate_vma_page_range() unlocks individual pages by calling
 munlock_vma_page().  munlock_vma_page() unconditionally clears the PG_mlocked
 flag using TestClearPageMlocked().  As with mlock_vma_page(),
 munlock_vma_page() use the Test*PageMlocked() function to handle the case where
@@ -463,21 +463,11 @@ populate the page table.
 
 To mlock a range of memory under the unevictable/mlock infrastructure, the
 mmap() handler and task address space expansion functions call
-mlock_vma_pages_range() specifying the vma and the address range to mlock.
-mlock_vma_pages_range() filters VMAs like mlock_fixup(), as described above in
-"Filtering Special VMAs".  It will clear the VM_LOCKED flag, which will have
-already been set by the caller, in filtered VMAs.  Thus these VMA's need not be
-visited for munlock when the region is unmapped.
-
-For "normal" VMAs, mlock_vma_pages_range() calls __mlock_vma_pages_range() to
-fault/allocate the pages and mlock them.  Again, like mlock_fixup(),
-mlock_vma_pages_range() downgrades the mmap semaphore to read mode before
-attempting to fault/allocate and mlock the pages and "upgrades" the semaphore
-back to write mode before returning.
-
-The callers of mlock_vma_pages_range() will have already added the memory range
+populate_vma_page_range() specifying the vma and the address range to mlock.
+
+The callers of populate_vma_page_range() will have already added the memory range
 to be mlocked to the task's "locked_vm".  To account for filtered VMAs,
-mlock_vma_pages_range() returns the number of pages NOT mlocked.  All of the
+populate_vma_page_range() returns the number of pages NOT mlocked.  All of the
 callers then subtract a non-negative return value from the task's locked_vm.  A
 negative return value represent an error - for example, from get_user_pages()
 attempting to fault in a VMA with PROT_NONE access.  In this case, we leave the
diff --git a/mm/internal.h b/mm/internal.h
index c4d6c9b43491..5445860bfc08 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -240,7 +240,7 @@ void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct vm_area_struct *prev, struct rb_node *rb_parent);
 
 #ifdef CONFIG_MMU
-extern long __mlock_vma_pages_range(struct vm_area_struct *vma,
+extern long populate_vma_page_range(struct vm_area_struct *vma,
 		unsigned long start, unsigned long end, int *nonblocking);
 extern void munlock_vma_pages_range(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end);
diff --git a/mm/mlock.c b/mm/mlock.c
index 7712d8ab6fe5..c3ea18323034 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -206,13 +206,13 @@ out:
 }
 
 /**
- * __mlock_vma_pages_range() -  mlock a range of pages in the vma.
+ * populate_vma_page_range() -  populate a range of pages in the vma.
  * @vma:   target vma
  * @start: start address
  * @end:   end address
  * @nonblocking:
  *
- * This takes care of making the pages present too.
+ * This takes care of mlocking the pages too if VM_LOCKED is set.
  *
  * return 0 on success, negative error code on error.
  *
@@ -224,7 +224,7 @@ out:
  * If @nonblocking is non-NULL, it must held for read only and may be
  * released.  If it's released, *@nonblocking will be set to 0.
  */
-long __mlock_vma_pages_range(struct vm_area_struct *vma,
+long populate_vma_page_range(struct vm_area_struct *vma,
 		unsigned long start, unsigned long end, int *nonblocking)
 {
 	struct mm_struct *mm = vma->vm_mm;
@@ -596,7 +596,7 @@ success:
 	/*
 	 * vm_flags is protected by the mmap_sem held in write mode.
 	 * It's okay if try_to_unmap_one unmaps a page just after we
-	 * set VM_LOCKED, __mlock_vma_pages_range will bring it back.
+	 * set VM_LOCKED, populate_vma_page_range will bring it back.
 	 */
 
 	if (lock)
@@ -702,11 +702,11 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 		if (nstart < vma->vm_start)
 			nstart = vma->vm_start;
 		/*
-		 * Now fault in a range of pages. __mlock_vma_pages_range()
+		 * Now fault in a range of pages. populate_vma_page_range()
 		 * double checks the vma flags, so that it won't mlock pages
 		 * if the vma was already munlocked.
 		 */
-		ret = __mlock_vma_pages_range(vma, nstart, nend, &locked);
+		ret = populate_vma_page_range(vma, nstart, nend, &locked);
 		if (ret < 0) {
 			if (ignore_errors) {
 				ret = 0;
diff --git a/mm/mmap.c b/mm/mmap.c
index da9990acc08b..943c6ad18b1d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2318,7 +2318,7 @@ find_extend_vma(struct mm_struct *mm, unsigned long addr)
 	if (!prev || expand_stack(prev, addr))
 		return NULL;
 	if (prev->vm_flags & VM_LOCKED)
-		__mlock_vma_pages_range(prev, addr, prev->vm_end, NULL);
+		populate_vma_page_range(prev, addr, prev->vm_end, NULL);
 	return prev;
 }
 #else
@@ -2353,7 +2353,7 @@ find_extend_vma(struct mm_struct *mm, unsigned long addr)
 	if (expand_stack(vma, addr))
 		return NULL;
 	if (vma->vm_flags & VM_LOCKED)
-		__mlock_vma_pages_range(vma, addr, start, NULL);
+		populate_vma_page_range(vma, addr, start, NULL);
 	return vma;
 }
 #endif
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
