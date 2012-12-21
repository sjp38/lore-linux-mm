Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 39C546B0087
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 19:50:24 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id bh2so2453226pad.33
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 16:50:23 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 8/9] mm: directly use __mlock_vma_pages_range() in find_extend_vma()
Date: Thu, 20 Dec 2012 16:49:56 -0800
Message-Id: <1356050997-2688-9-git-send-email-walken@google.com>
In-Reply-To: <1356050997-2688-1-git-send-email-walken@google.com>
References: <1356050997-2688-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In find_extend_vma(), we don't need mlock_vma_pages_range() to verify the
vma type - we know we're working with a stack. So, we can call directly
into __mlock_vma_pages_range(), and remove the last make_pages_present()
call site.

Note that we don't use mm_populate() here, so we can't release the mmap_sem
while allocating new stack pages. This is deemed acceptable, because the
stack vmas grow by a bounded number of pages at a time, and these are
anon pages so we don't have to read from disk to populate them.

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 include/linux/mm.h |    1 -
 mm/internal.h      |    4 +-
 mm/memory.c        |   24 ---------------------
 mm/mlock.c         |   57 ++-------------------------------------------------
 mm/mmap.c          |   10 +++-----
 5 files changed, 9 insertions(+), 87 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3b2912f6e91a..d32ace5fba93 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1007,7 +1007,6 @@ static inline int fixup_user_fault(struct task_struct *tsk,
 }
 #endif
 
-extern int make_pages_present(unsigned long addr, unsigned long end);
 extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, int len, int write);
 extern int access_remote_vm(struct mm_struct *mm, unsigned long addr,
 		void *buf, int len, int write);
diff --git a/mm/internal.h b/mm/internal.h
index a4fa284f6bc2..e646c46c0d63 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -158,8 +158,8 @@ void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct vm_area_struct *prev, struct rb_node *rb_parent);
 
 #ifdef CONFIG_MMU
-extern long mlock_vma_pages_range(struct vm_area_struct *vma,
-			unsigned long start, unsigned long end);
+extern long __mlock_vma_pages_range(struct vm_area_struct *vma,
+		unsigned long start, unsigned long end, int *nonblocking);
 extern void munlock_vma_pages_range(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end);
 static inline void munlock_vma_pages_all(struct vm_area_struct *vma)
diff --git a/mm/memory.c b/mm/memory.c
index 221fc9ffcab1..e4ab66b94bb8 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3629,30 +3629,6 @@ int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
 }
 #endif /* __PAGETABLE_PMD_FOLDED */
 
-int make_pages_present(unsigned long addr, unsigned long end)
-{
-	int ret, len, write;
-	struct vm_area_struct * vma;
-
-	vma = find_vma(current->mm, addr);
-	if (!vma)
-		return -ENOMEM;
-	/*
-	 * We want to touch writable mappings with a write fault in order
-	 * to break COW, except for shared mappings because these don't COW
-	 * and we would not want to dirty them for nothing.
-	 */
-	write = (vma->vm_flags & (VM_WRITE | VM_SHARED)) == VM_WRITE;
-	BUG_ON(addr >= end);
-	BUG_ON(end > vma->vm_end);
-	len = DIV_ROUND_UP(end, PAGE_SIZE) - addr/PAGE_SIZE;
-	ret = get_user_pages(current, current->mm, addr,
-			len, write, 0, NULL, NULL);
-	if (ret < 0)
-		return ret;
-	return ret == len ? 0 : -EFAULT;
-}
-
 #if !defined(__HAVE_ARCH_GATE_AREA)
 
 #if defined(AT_SYSINFO_EHDR)
diff --git a/mm/mlock.c b/mm/mlock.c
index 7f94bc3b46ef..ab0cfe21f538 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -155,9 +155,8 @@ void munlock_vma_page(struct page *page)
  *
  * vma->vm_mm->mmap_sem must be held for at least read.
  */
-static long __mlock_vma_pages_range(struct vm_area_struct *vma,
-				    unsigned long start, unsigned long end,
-				    int *nonblocking)
+long __mlock_vma_pages_range(struct vm_area_struct *vma,
+		unsigned long start, unsigned long end, int *nonblocking)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long addr = start;
@@ -202,56 +201,6 @@ static int __mlock_posix_error_return(long retval)
 	return retval;
 }
 
-/**
- * mlock_vma_pages_range() - mlock pages in specified vma range.
- * @vma - the vma containing the specfied address range
- * @start - starting address in @vma to mlock
- * @end   - end address [+1] in @vma to mlock
- *
- * For mmap()/mremap()/expansion of mlocked vma.
- *
- * return 0 on success for "normal" vmas.
- *
- * return number of pages [> 0] to be removed from locked_vm on success
- * of "special" vmas.
- */
-long mlock_vma_pages_range(struct vm_area_struct *vma,
-			unsigned long start, unsigned long end)
-{
-	int nr_pages = (end - start) / PAGE_SIZE;
-	BUG_ON(!(vma->vm_flags & VM_LOCKED));
-
-	/*
-	 * filter unlockable vmas
-	 */
-	if (vma->vm_flags & (VM_IO | VM_PFNMAP))
-		goto no_mlock;
-
-	if (!((vma->vm_flags & VM_DONTEXPAND) ||
-			is_vm_hugetlb_page(vma) ||
-			vma == get_gate_vma(current->mm))) {
-
-		__mlock_vma_pages_range(vma, start, end, NULL);
-
-		/* Hide errors from mmap() and other callers */
-		return 0;
-	}
-
-	/*
-	 * User mapped kernel pages or huge pages:
-	 * make these pages present to populate the ptes, but
-	 * fall thru' to reset VM_LOCKED--no need to unlock, and
-	 * return nr_pages so these don't get counted against task's
-	 * locked limit.  huge pages are already counted against
-	 * locked vm limit.
-	 */
-	make_pages_present(start, end);
-
-no_mlock:
-	vma->vm_flags &= ~VM_LOCKED;	/* and don't come back! */
-	return nr_pages;		/* error or pages NOT mlocked */
-}
-
 /*
  * munlock_vma_pages_range() - munlock all pages in the vma range.'
  * @vma - vma containing range to be munlock()ed.
@@ -303,7 +252,7 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
  *
  * Filters out "special" vmas -- VM_LOCKED never gets set for these, and
  * munlock is a no-op.  However, for some special vmas, we go ahead and
- * populate the ptes via make_pages_present().
+ * populate the ptes.
  *
  * For vmas that pass the filters, merge/split as appropriate.
  */
diff --git a/mm/mmap.c b/mm/mmap.c
index b0a341e5685f..290d023632e6 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1881,9 +1881,8 @@ find_extend_vma(struct mm_struct *mm, unsigned long addr)
 		return vma;
 	if (!prev || expand_stack(prev, addr))
 		return NULL;
-	if (prev->vm_flags & VM_LOCKED) {
-		mlock_vma_pages_range(prev, addr, prev->vm_end);
-	}
+	if (prev->vm_flags & VM_LOCKED)
+		__mlock_vma_pages_range(prev, addr, prev->vm_end, NULL);
 	return prev;
 }
 #else
@@ -1909,9 +1908,8 @@ find_extend_vma(struct mm_struct * mm, unsigned long addr)
 	start = vma->vm_start;
 	if (expand_stack(vma, addr))
 		return NULL;
-	if (vma->vm_flags & VM_LOCKED) {
-		mlock_vma_pages_range(vma, addr, start);
-	}
+	if (vma->vm_flags & VM_LOCKED)
+		__mlock_vma_pages_range(vma, addr, start, NULL);
 	return vma;
 }
 #endif
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
