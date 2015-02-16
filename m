Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 86EF06B0070
	for <linux-mm@kvack.org>; Mon, 16 Feb 2015 06:28:31 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id rd3so27882295pab.4
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 03:28:31 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id cf8si15065230pdb.221.2015.02.16.03.28.30
        for <linux-mm@kvack.org>;
        Mon, 16 Feb 2015 03:28:30 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 4/4] mm: move mm_populate()-related code to mm/gup.c
Date: Mon, 16 Feb 2015 13:27:54 +0200
Message-Id: <1424086074-200683-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1424086074-200683-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1424086074-200683-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

It's odd that we have populate_vma_page_range() and __mm_populate() in
mm/mlock.c. It's implementation of generic memory population and
mlocking is one of possible side effect, if VM_LOCKED is set.

__get_user_pages() is core of the implementation. Let's move the code
mm/gup.c.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Linus Torvalds <torvalds@linux-foundation.org>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/gup.c   | 118 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/mlock.c | 118 -------------------------------------------------------------
 2 files changed, 118 insertions(+), 118 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 1b114ba9aebf..ca7b607ab671 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -819,6 +819,124 @@ long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 EXPORT_SYMBOL(get_user_pages);
 
 /**
+ * populate_vma_page_range() -  populate a range of pages in the vma.
+ * @vma:   target vma
+ * @start: start address
+ * @end:   end address
+ * @nonblocking:
+ *
+ * This takes care of mlocking the pages too if VM_LOCKED is set.
+ *
+ * return 0 on success, negative error code on error.
+ *
+ * vma->vm_mm->mmap_sem must be held.
+ *
+ * If @nonblocking is NULL, it may be held for read or write and will
+ * be unperturbed.
+ *
+ * If @nonblocking is non-NULL, it must held for read only and may be
+ * released.  If it's released, *@nonblocking will be set to 0.
+ */
+long populate_vma_page_range(struct vm_area_struct *vma,
+		unsigned long start, unsigned long end, int *nonblocking)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long nr_pages = (end - start) / PAGE_SIZE;
+	int gup_flags;
+
+	VM_BUG_ON(start & ~PAGE_MASK);
+	VM_BUG_ON(end   & ~PAGE_MASK);
+	VM_BUG_ON_VMA(start < vma->vm_start, vma);
+	VM_BUG_ON_VMA(end   > vma->vm_end, vma);
+	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
+
+	gup_flags = FOLL_TOUCH | FOLL_POPULATE;
+	/*
+	 * We want to touch writable mappings with a write fault in order
+	 * to break COW, except for shared mappings because these don't COW
+	 * and we would not want to dirty them for nothing.
+	 */
+	if ((vma->vm_flags & (VM_WRITE | VM_SHARED)) == VM_WRITE)
+		gup_flags |= FOLL_WRITE;
+
+	/*
+	 * We want mlock to succeed for regions that have any permissions
+	 * other than PROT_NONE.
+	 */
+	if (vma->vm_flags & (VM_READ | VM_WRITE | VM_EXEC))
+		gup_flags |= FOLL_FORCE;
+
+	/*
+	 * We made sure addr is within a VMA, so the following will
+	 * not result in a stack expansion that recurses back here.
+	 */
+	return __get_user_pages(current, mm, start, nr_pages, gup_flags,
+				NULL, NULL, nonblocking);
+}
+
+/*
+ * __mm_populate - populate and/or mlock pages within a range of address space.
+ *
+ * This is used to implement mlock() and the MAP_POPULATE / MAP_LOCKED mmap
+ * flags. VMAs must be already marked with the desired vm_flags, and
+ * mmap_sem must not be held.
+ */
+int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long end, nstart, nend;
+	struct vm_area_struct *vma = NULL;
+	int locked = 0;
+	long ret = 0;
+
+	VM_BUG_ON(start & ~PAGE_MASK);
+	VM_BUG_ON(len != PAGE_ALIGN(len));
+	end = start + len;
+
+	for (nstart = start; nstart < end; nstart = nend) {
+		/*
+		 * We want to fault in pages for [nstart; end) address range.
+		 * Find first corresponding VMA.
+		 */
+		if (!locked) {
+			locked = 1;
+			down_read(&mm->mmap_sem);
+			vma = find_vma(mm, nstart);
+		} else if (nstart >= vma->vm_end)
+			vma = vma->vm_next;
+		if (!vma || vma->vm_start >= end)
+			break;
+		/*
+		 * Set [nstart; nend) to intersection of desired address
+		 * range with the first VMA. Also, skip undesirable VMA types.
+		 */
+		nend = min(end, vma->vm_end);
+		if (vma->vm_flags & (VM_IO | VM_PFNMAP))
+			continue;
+		if (nstart < vma->vm_start)
+			nstart = vma->vm_start;
+		/*
+		 * Now fault in a range of pages. populate_vma_page_range()
+		 * double checks the vma flags, so that it won't mlock pages
+		 * if the vma was already munlocked.
+		 */
+		ret = populate_vma_page_range(vma, nstart, nend, &locked);
+		if (ret < 0) {
+			if (ignore_errors) {
+				ret = 0;
+				continue;	/* continue at next VMA */
+			}
+			break;
+		}
+		nend = nstart + ret * PAGE_SIZE;
+		ret = 0;
+	}
+	if (locked)
+		up_read(&mm->mmap_sem);
+	return ret;	/* 0 or negative error code */
+}
+
+/**
  * get_dump_page() - pin user page in memory while writing it to core dump
  * @addr: user address
  *
diff --git a/mm/mlock.c b/mm/mlock.c
index 9fbe611b1e93..283ff972ea43 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -205,62 +205,6 @@ out:
 	return nr_pages - 1;
 }
 
-/**
- * populate_vma_page_range() -  populate a range of pages in the vma.
- * @vma:   target vma
- * @start: start address
- * @end:   end address
- * @nonblocking:
- *
- * This takes care of mlocking the pages too if VM_LOCKED is set.
- *
- * return 0 on success, negative error code on error.
- *
- * vma->vm_mm->mmap_sem must be held.
- *
- * If @nonblocking is NULL, it may be held for read or write and will
- * be unperturbed.
- *
- * If @nonblocking is non-NULL, it must held for read only and may be
- * released.  If it's released, *@nonblocking will be set to 0.
- */
-long populate_vma_page_range(struct vm_area_struct *vma,
-		unsigned long start, unsigned long end, int *nonblocking)
-{
-	struct mm_struct *mm = vma->vm_mm;
-	unsigned long nr_pages = (end - start) / PAGE_SIZE;
-	int gup_flags;
-
-	VM_BUG_ON(start & ~PAGE_MASK);
-	VM_BUG_ON(end   & ~PAGE_MASK);
-	VM_BUG_ON_VMA(start < vma->vm_start, vma);
-	VM_BUG_ON_VMA(end   > vma->vm_end, vma);
-	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
-
-	gup_flags = FOLL_TOUCH | FOLL_POPULATE;
-	/*
-	 * We want to touch writable mappings with a write fault in order
-	 * to break COW, except for shared mappings because these don't COW
-	 * and we would not want to dirty them for nothing.
-	 */
-	if ((vma->vm_flags & (VM_WRITE | VM_SHARED)) == VM_WRITE)
-		gup_flags |= FOLL_WRITE;
-
-	/*
-	 * We want mlock to succeed for regions that have any permissions
-	 * other than PROT_NONE.
-	 */
-	if (vma->vm_flags & (VM_READ | VM_WRITE | VM_EXEC))
-		gup_flags |= FOLL_FORCE;
-
-	/*
-	 * We made sure addr is within a VMA, so the following will
-	 * not result in a stack expansion that recurses back here.
-	 */
-	return __get_user_pages(current, mm, start, nr_pages, gup_flags,
-				NULL, NULL, nonblocking);
-}
-
 /*
  * convert get_user_pages() return value to posix mlock() error
  */
@@ -660,68 +604,6 @@ static int do_mlock(unsigned long start, size_t len, int on)
 	return error;
 }
 
-/*
- * __mm_populate - populate and/or mlock pages within a range of address space.
- *
- * This is used to implement mlock() and the MAP_POPULATE / MAP_LOCKED mmap
- * flags. VMAs must be already marked with the desired vm_flags, and
- * mmap_sem must not be held.
- */
-int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
-{
-	struct mm_struct *mm = current->mm;
-	unsigned long end, nstart, nend;
-	struct vm_area_struct *vma = NULL;
-	int locked = 0;
-	long ret = 0;
-
-	VM_BUG_ON(start & ~PAGE_MASK);
-	VM_BUG_ON(len != PAGE_ALIGN(len));
-	end = start + len;
-
-	for (nstart = start; nstart < end; nstart = nend) {
-		/*
-		 * We want to fault in pages for [nstart; end) address range.
-		 * Find first corresponding VMA.
-		 */
-		if (!locked) {
-			locked = 1;
-			down_read(&mm->mmap_sem);
-			vma = find_vma(mm, nstart);
-		} else if (nstart >= vma->vm_end)
-			vma = vma->vm_next;
-		if (!vma || vma->vm_start >= end)
-			break;
-		/*
-		 * Set [nstart; nend) to intersection of desired address
-		 * range with the first VMA. Also, skip undesirable VMA types.
-		 */
-		nend = min(end, vma->vm_end);
-		if (vma->vm_flags & (VM_IO | VM_PFNMAP))
-			continue;
-		if (nstart < vma->vm_start)
-			nstart = vma->vm_start;
-		/*
-		 * Now fault in a range of pages. populate_vma_page_range()
-		 * double checks the vma flags, so that it won't mlock pages
-		 * if the vma was already munlocked.
-		 */
-		ret = populate_vma_page_range(vma, nstart, nend, &locked);
-		if (ret < 0) {
-			if (ignore_errors) {
-				ret = 0;
-				continue;	/* continue at next VMA */
-			}
-			break;
-		}
-		nend = nstart + ret * PAGE_SIZE;
-		ret = 0;
-	}
-	if (locked)
-		up_read(&mm->mmap_sem);
-	return ret;	/* 0 or negative error code */
-}
-
 SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 {
 	unsigned long locked;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
