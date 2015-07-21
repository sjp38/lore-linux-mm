Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 114BF9003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 15:59:57 -0400 (EDT)
Received: by qged69 with SMTP id d69so64034542qge.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 12:59:56 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175])
        by mx.google.com with ESMTP id r88si29635596qkh.64.2015.07.21.12.59.42
        for <linux-mm@kvack.org>;
        Tue, 21 Jul 2015 12:59:43 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH V4 3/6] mm: gup: Add mm_lock_present()
Date: Tue, 21 Jul 2015 15:59:38 -0400
Message-Id: <1437508781-28655-4-git-send-email-emunson@akamai.com>
In-Reply-To: <1437508781-28655-1-git-send-email-emunson@akamai.com>
References: <1437508781-28655-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The upcoming mlock(MLOCK_ONFAULT) implementation will need a way to
request that all present pages in a range are locked without faulting in
pages that are not present.  This logic is very close to what the
__mm_populate() call handles without faulting pages so the patch pulls
out the pieces that can be shared and adds mm_lock_present() to gup.c.
The following patch will call it from do_mlock() when MLOCK_ONFAULT is
specified.

Signed-off-by: Eric B Munson <emunson@akamai.com>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/gup.c | 172 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 157 insertions(+), 15 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 6297f6b..233ef17 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -818,6 +818,30 @@ long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 }
 EXPORT_SYMBOL(get_user_pages);
 
+/*
+ * Helper function used by both populate_vma_page_range() and pin_user_pages
+ */
+static int get_gup_flags(vm_flags_t vm_flags)
+{
+	int gup_flags = FOLL_TOUCH | FOLL_POPULATE;
+	/*
+	 * We want to touch writable mappings with a write fault in order
+	 * to break COW, except for shared mappings because these don't COW
+	 * and we would not want to dirty them for nothing.
+	 */
+	if ((vm_flags & (VM_WRITE | VM_SHARED)) == VM_WRITE)
+		gup_flags |= FOLL_WRITE;
+
+	/*
+	 * We want mlock to succeed for regions that have any permissions
+	 * other than PROT_NONE.
+	 */
+	if (vm_flags & (VM_READ | VM_WRITE | VM_EXEC))
+		gup_flags |= FOLL_FORCE;
+
+	return gup_flags;
+}
+
 /**
  * populate_vma_page_range() -  populate a range of pages in the vma.
  * @vma:   target vma
@@ -850,21 +874,7 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 	VM_BUG_ON_VMA(end   > vma->vm_end, vma);
 	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
 
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
+	gup_flags = get_gup_flags(vma->vm_flags);
 
 	/*
 	 * We made sure addr is within a VMA, so the following will
@@ -874,6 +884,138 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 				NULL, NULL, nonblocking);
 }
 
+static long pin_user_pages(struct vm_area_struct *vma, unsigned long start,
+			unsigned long end, int *nonblocking)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long nr_pages = (end - start) / PAGE_SIZE;
+	int gup_flags;
+	long i = 0;
+	unsigned int page_mask;
+
+	VM_BUG_ON(start & ~PAGE_MASK);
+	VM_BUG_ON(end   & ~PAGE_MASK);
+	VM_BUG_ON_VMA(start < vma->vm_start, vma);
+	VM_BUG_ON_VMA(end   > vma->vm_end, vma);
+	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
+
+	if (!nr_pages)
+		return 0;
+
+	gup_flags = get_gup_flags(vma->vm_flags);
+
+	/*
+	 * If FOLL_FORCE is set then do not force a full fault as the hinting
+	 * fault information is unrelated to the reference behaviour of a task
+	 * using the address space
+	 */
+	if (!(gup_flags & FOLL_FORCE))
+		gup_flags |= FOLL_NUMA;
+
+	vma = NULL;
+
+	do {
+		struct page *page;
+		unsigned int foll_flags = gup_flags;
+		unsigned int page_increm;
+
+		/* first iteration or cross vma bound */
+		if (!vma || start >= vma->vm_end) {
+			vma = find_extend_vma(mm, start);
+			if (!vma && in_gate_area(mm, start)) {
+				int ret;
+				ret = get_gate_page(mm, start & PAGE_MASK,
+						gup_flags, &vma, NULL);
+				if (ret)
+					return i ? : ret;
+				page_mask = 0;
+				goto next_page;
+			}
+
+			if (!vma)
+				return i ? : -EFAULT;
+			if (is_vm_hugetlb_page(vma)) {
+				i = follow_hugetlb_page(mm, vma, NULL, NULL,
+						&start, &nr_pages, i,
+						gup_flags);
+				continue;
+			}
+		}
+
+		/*
+		 * If we have a pending SIGKILL, don't keep pinning pages
+		 */
+		if (unlikely(fatal_signal_pending(current)))
+			return i ? i : -ERESTARTSYS;
+		cond_resched();
+		page = follow_page_mask(vma, start, foll_flags, &page_mask);
+		if (!page)
+			goto next_page;
+		if (IS_ERR(page))
+			return i ? i : PTR_ERR(page);
+next_page:
+		page_increm = 1 + (~(start >> PAGE_SHIFT) & page_mask);
+		if (page_increm > nr_pages)
+			page_increm = nr_pages;
+		i += page_increm;
+		start += page_increm * PAGE_SIZE;
+		nr_pages -= page_increm;
+	} while (nr_pages);
+	return i;
+}
+
+/*
+ * mm_lock_present - lock present pages within a range of address space.
+ *
+ * This is used to implement mlock2(MLOCK_LOCKONFAULT).  VMAs must be already
+ * marked with the desired vm_flags, and mmap_sem must not be held.
+ */
+int mm_lock_present(unsigned long start, unsigned long len)
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
+
+		ret = pin_user_pages(vma, nstart, nend, &locked);
+		if (ret < 0)
+			break;
+		nend = nstart + ret * PAGE_SIZE;
+		ret = 0;
+	}
+	if (locked)
+		up_read(&mm->mmap_sem);
+	return ret;	/* 0 or negative error code */
+}
+
 /*
  * __mm_populate - populate and/or mlock pages within a range of address space.
  *
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
