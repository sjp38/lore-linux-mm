Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9BDW402008838
	for <linux-mm@kvack.org>; Wed, 11 Oct 2006 09:32:04 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9BDW497249924
	for <linux-mm@kvack.org>; Wed, 11 Oct 2006 09:32:04 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9BDW3o4023698
	for <linux-mm@kvack.org>; Wed, 11 Oct 2006 09:32:04 -0400
Subject: [RFC] hugetlb: Move hugetlb_get_unmapped_area
From: Adam Litke <agl@us.ibm.com>
Content-Type: text/plain
Date: Wed, 11 Oct 2006 08:31:59 -0500
Message-Id: <1160573520.9894.27.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, "ADAM G. LITKE [imap]" <agl@us.ibm.com>, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

I am trying to do some hugetlb interface cleanups which include
separation of the hugetlb utility functions (mostly in mm/hugetlb.c)
from the hugetlbfs interface to huge pages (fs/hugetlbfs/inode.c).

This patch simply moves hugetlb_get_unmapped_area() (which I'll argue is
more of a utility function than an interface) to mm/hugetlb.c.  

Signed-off-by: Adam Litke <agl@us.ibm.com>
---
 fs/hugetlbfs/inode.c    |   58 ------------------------------------------------
 include/linux/hugetlb.h |    3 ++
 mm/hugetlb.c            |   54 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 57 insertions(+), 58 deletions(-)
diff -upN reference/fs/hugetlbfs/inode.c current/fs/hugetlbfs/inode.c
--- reference/fs/hugetlbfs/inode.c
+++ current/fs/hugetlbfs/inode.c
@@ -100,64 +100,6 @@ out:
 }
 
 /*
- * Called under down_write(mmap_sem).
- */
-
-#ifdef HAVE_ARCH_HUGETLB_UNMAPPED_AREA
-unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags);
-#else
-static unsigned long
-hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags)
-{
-	struct mm_struct *mm = current->mm;
-	struct vm_area_struct *vma;
-	unsigned long start_addr;
-
-	if (len & ~HPAGE_MASK)
-		return -EINVAL;
-	if (len > TASK_SIZE)
-		return -ENOMEM;
-
-	if (addr) {
-		addr = ALIGN(addr, HPAGE_SIZE);
-		vma = find_vma(mm, addr);
-		if (TASK_SIZE - len >= addr &&
-		    (!vma || addr + len <= vma->vm_start))
-			return addr;
-	}
-
-	start_addr = mm->free_area_cache;
-
-	if (len <= mm->cached_hole_size)
-		start_addr = TASK_UNMAPPED_BASE;
-
-full_search:
-	addr = ALIGN(start_addr, HPAGE_SIZE);
-
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
-		/* At this point:  (!vma || addr < vma->vm_end). */
-		if (TASK_SIZE - len < addr) {
-			/*
-			 * Start a new search - just in case we missed
-			 * some holes.
-			 */
-			if (start_addr != TASK_UNMAPPED_BASE) {
-				start_addr = TASK_UNMAPPED_BASE;
-				goto full_search;
-			}
-			return -ENOMEM;
-		}
-
-		if (!vma || addr + len <= vma->vm_start)
-			return addr;
-		addr = ALIGN(vma->vm_end, HPAGE_SIZE);
-	}
-}
-#endif
-
-/*
  * Read a page. Again trivial. If it didn't already exist
  * in the page cache, it is zero-filled.
  */
diff -upN reference/include/linux/hugetlb.h current/include/linux/hugetlb.h
--- reference/include/linux/hugetlb.h
+++ current/include/linux/hugetlb.h
@@ -87,6 +87,9 @@ pte_t huge_ptep_get_and_clear(struct mm_
 void hugetlb_prefault_arch_hook(struct mm_struct *mm);
 #endif
 
+unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
+		unsigned long len, unsigned long pgoff, unsigned long flags);
+
 #else /* !CONFIG_HUGETLB_PAGE */
 
 static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
diff -upN reference/mm/hugetlb.c current/mm/hugetlb.c
--- reference/mm/hugetlb.c
+++ current/mm/hugetlb.c
@@ -796,3 +796,57 @@ void hugetlb_unreserve_pages(struct inod
 	long chg = region_truncate(&inode->i_mapping->private_list, offset);
 	hugetlb_acct_memory(freed - chg);
 }
+
+/*
+ * Called under down_write(mmap_sem).
+ */
+
+#ifndef HAVE_ARCH_HUGETLB_UNMAPPED_AREA
+unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
+		unsigned long len, unsigned long pgoff, unsigned long flags)
+{
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
+	unsigned long start_addr;
+
+	if (len & ~HPAGE_MASK)
+		return -EINVAL;
+	if (len > TASK_SIZE)
+		return -ENOMEM;
+
+	if (addr) {
+		addr = ALIGN(addr, HPAGE_SIZE);
+		vma = find_vma(mm, addr);
+		if (TASK_SIZE - len >= addr &&
+		    (!vma || addr + len <= vma->vm_start))
+			return addr;
+	}
+
+	start_addr = mm->free_area_cache;
+
+	if (len <= mm->cached_hole_size)
+		start_addr = TASK_UNMAPPED_BASE;
+
+full_search:
+	addr = ALIGN(start_addr, HPAGE_SIZE);
+
+	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+		/* At this point:  (!vma || addr < vma->vm_end). */
+		if (TASK_SIZE - len < addr) {
+			/*
+			 * Start a new search - just in case we missed
+			 * some holes.
+			 */
+			if (start_addr != TASK_UNMAPPED_BASE) {
+				start_addr = TASK_UNMAPPED_BASE;
+				goto full_search;
+			}
+			return -ENOMEM;
+		}
+
+		if (!vma || addr + len <= vma->vm_start)
+			return addr;
+		addr = ALIGN(vma->vm_end, HPAGE_SIZE);
+	}
+}
+#endif

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
