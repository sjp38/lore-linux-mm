Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 81EB66B0031
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 22:50:22 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fb1so6486875pad.28
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 19:50:22 -0700 (PDT)
Received: from exprod6og108.obsmtp.com (exprod6og108.obsmtp.com [64.18.1.21])
        by mx.google.com with SMTP id fn2si42378906pab.164.2014.07.07.19.50.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 07 Jul 2014 19:50:20 -0700 (PDT)
Received: from rueplumet.us.cray.com (rueplumet.us.cray.com [172.28.18.208])
	by sealmr01.us.cray.com (8.14.3/8.13.8/hubv2-LastChangedRevision: 14089) with ESMTP id s682oJwD020688
	for <linux-mm@kvack.org>; Mon, 7 Jul 2014 19:50:19 -0700
Received: from rueplumet.us.cray.com (localhost [127.0.0.1])
	by rueplumet.us.cray.com (8.14.3/8.13.6/client-5260) with ESMTP id s682oIWY027987
	for <linux-mm@kvack.org>; Mon, 7 Jul 2014 19:50:18 -0700
Received: from localhost (cassella@localhost)
	by rueplumet.us.cray.com (8.14.3/8.12.8/Submit) with ESMTP id s682oIPd027982
	for <linux-mm@kvack.org>; Mon, 7 Jul 2014 19:50:18 -0700
Date: Mon, 7 Jul 2014 19:50:18 -0700 (PDT)
From: Paul Cassella <cassella@cray.com>
Subject: [PATCH] Describe mmap_sem rules for __lock_page_or_retry() and
 callers
Message-ID: <alpine.LNX.2.00.1407071533180.31986@rueplumet.us.cray.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Add a comment describing the circumstances in which
__lock_page_or_retry() will or will not release the mmap_sem when
returning 0.

Add comments to lock_page_or_retry()'s callers (filemap_fault(),
do_swap_page()) noting the impact on VM_FAULT_RETRY returns.

Add comments on up the call tree, particularly replacing the false
"We return with mmap_sem still held" comments.

Signed-off-by: Paul Cassella <cassella@cray.com> on behalf of Cray Inc.
---
 arch/x86/mm/fault.c     |  3 ++-
 include/linux/pagemap.h |  3 +++
 mm/filemap.c            | 23 +++++++++++++++++++++++
 mm/gup.c                | 18 +++++++++++++++---
 mm/memory.c             | 34 +++++++++++++++++++++++++++++++---
 mm/mlock.c              |  9 ++++++++-
 6 files changed, 82 insertions(+), 8 deletions(-)


The interaction between __lock_page_and_retry() and handle_mm_fault()'s
callers with respect to the mmap_sem seems complicated enough that I
thought it could use some commentary.

I'm not entirely satisfied with the wording, or the locations of the 
content vs the "see also"s.  Feel free to reword or move things around. 
I've only described the behavior I've found -- if I've missed the forest 
for the trees, please let me know.


This patch adds a comment to only one __do_page_fault(), the one in 
arch/x86.  A similar comment no doubt could apply to other architectures, 
but I looked at a few only long enough to see that the code wasn't quite 
the same from one to another.


There are a few things I wasn't sure enough of to include in the patch:

1. The comment on __get_user_pages() says
 
 * @nonblocking: whether waiting for disk IO or mmap_sem contention
   
and

 * If @nonblocking != NULL, __get_user_pages will not wait for disk IO
 * or mmap_sem contention,

But I don't see any path where it could wait for "mmap_sem contention", 
only for a page lock; at least in the paths related to @nonblocking.  Is 
that reference stale?


2. The comment on fixup_user_fault() says

 * The main difference with get_user_pages() is that this function will
 * unconditionally call handle_mm_fault() which will in turn perform all the
 * necessary SW fixup of the dirty and young bits in the PTE, while
 * handle_mm_fault() only guarantees to update these in the struct page.

I presume that both branches of that sentence aren't meant to refer to 
handle_mm_fault().  My guess is that the second one should be 
get_user_pages() instead?
 

3. I didn't try to come up with a description of the @nonblocking
parameter to __mlock_pages_vma_range(), just added a line for it to the
comment.



diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 3664279..a72f9d4 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1212,7 +1212,8 @@ good_area:
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
-	 * the fault:
+	 * the fault.  Since we never set FAULT_FLAG_RETRY_NOWAIT, if
+	 * we get VM_FAULT_RETRY back, the mmap_sem has been unlocked.
 	 */
 	fault = handle_mm_fault(mm, vma, address, flags);
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 0a97b58..a5f0346 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -472,6 +472,9 @@ static inline int lock_page_killable(struct page *page)
 /*
  * lock_page_or_retry - Lock the page, unless this would block and the
  * caller indicated that it can handle a retry.
+ *
+ * Return value and mmap_sem implications depend on flags; see
+ * __lock_page_or_retry().
  */
 static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
 				     unsigned int flags)
diff --git a/mm/filemap.c b/mm/filemap.c
index dafb06f..6e717aa 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -820,6 +820,17 @@ int __lock_page_killable(struct page *page)
 }
 EXPORT_SYMBOL_GPL(__lock_page_killable);
 
+/*
+ * Return values:
+ * 1 - page is locked; mmap_sem is still held.
+ * 0 - page is not locked.
+ *     mmap_sem has been released (up_read()), unless flags had both
+ *     FAULT_FLAG_ALLOW_RETRY and FAULT_FLAG_RETRY_NOWAIT set, in
+ *     which case mmap_sem is still held.
+ *
+ * If neither ALLOW_RETRY nor KILLABLE are set, will always return 1
+ * with the page locked and the mmap_sem unperturbed.
+ */
 int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 			 unsigned int flags)
 {
@@ -1836,6 +1847,18 @@ static void do_async_mmap_readahead(struct vm_area_struct *vma,
  * The goto's are kind of ugly, but this streamlines the normal case of having
  * it in the page cache, and handles the special cases reasonably without
  * having a lot of duplicated code.
+ *
+ * vma->vm_mm->mmap_sem must be held on entry.
+ *
+ * If our return value has VM_FAULT_RETRY set, it's because
+ * lock_page_or_retry() returned 0.
+ * The mmap_sem has usually been released in this case.
+ * See __lock_page_or_retry() for the exception.
+ *
+ * If our return value does not have VM_FAULT_RETRY set, the mmap_sem
+ * has not been released.
+ *
+ * We never return with VM_FAULT_RETRY and a bit from VM_FAULT_ERROR set.
  */
 int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
diff --git a/mm/gup.c b/mm/gup.c
index cc5a9e7..91d044b 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -258,6 +258,11 @@ unmap:
 	return ret;
 }
 
+/*
+ * mmap_sem must be held on entry.  If @nonblocking != NULL and
+ * *@flags does not include FOLL_NOWAIT, the mmap_sem may be released.
+ * If it is, *@nonblocking will be set to 0 and -EBUSY returned.
+ */
 static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 		unsigned long address, unsigned int *flags, int *nonblocking)
 {
@@ -373,7 +378,7 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
  * with a put_page() call when it is finished with. vmas will only
  * remain valid while mmap_sem is held.
  *
- * Must be called with mmap_sem held for read or write.
+ * Must be called with mmap_sem held.  It may be released.  See below.
  *
  * __get_user_pages walks a process's page tables and takes a reference to
  * each struct page that each user address corresponds to at a given
@@ -396,7 +401,14 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
  *
  * If @nonblocking != NULL, __get_user_pages will not wait for disk IO
  * or mmap_sem contention, and if waiting is needed to pin all pages,
- * *@nonblocking will be set to 0.
+ * *@nonblocking will be set to 0.  Further, if @gup_flags does not
+ * include FOLL_NOWAIT, the mmap_sem will be released via up_read() in
+ * this case.
+ *
+ * A caller using such a combination of @nonblocking and @gup_flags
+ * must therefore hold the mmap_sem for reading only, and recognize
+ * when it's been released.  Otherwise, it must be held for either
+ * reading or writing and will not be released.
  *
  * In most cases, get_user_pages or get_user_pages_fast should be used
  * instead of __get_user_pages. __get_user_pages should be used only if
@@ -528,7 +540,7 @@ EXPORT_SYMBOL(__get_user_pages);
  * such architectures, gup() will not be enough to make a subsequent access
  * succeed.
  *
- * This should be called with the mm_sem held for read.
+ * This has the same semantics wrt the @mm->mmap_sem as does filemap_fault().
  */
 int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 		     unsigned long address, unsigned int fault_flags)
diff --git a/mm/memory.c b/mm/memory.c
index d67fd9f..cf18147 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2399,7 +2399,10 @@ EXPORT_SYMBOL(unmap_mapping_range);
 /*
  * We enter with non-exclusive mmap_sem (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
- * We return with mmap_sem still held, but pte unmapped and unlocked.
+ * We return with pte unmapped and unlocked.
+ *
+ * We return with the mmap_sem locked or unlocked in the same cases
+ * as does filemap_fault().
  */
 static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
@@ -2688,6 +2691,11 @@ oom:
 	return VM_FAULT_OOM;
 }
 
+/*
+ * The mmap_sem must have been held on entry, and may have been
+ * released depending on flags and vma->vm_ops->fault() return value.
+ * See filemap_fault() and __lock_page_retry().
+ */
 static int __do_fault(struct vm_area_struct *vma, unsigned long address,
 		pgoff_t pgoff, unsigned int flags, struct page **page)
 {
@@ -3012,6 +3020,12 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return ret;
 }
 
+/*
+ * We enter with non-exclusive mmap_sem (to exclude vma changes,
+ * but allow concurrent faults).
+ * The mmap_sem may have been released depending on flags and our
+ * return value.  See filemap_fault() and __lock_page_or_retry().
+ */
 static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
 		unsigned int flags, pte_t orig_pte)
@@ -3036,7 +3050,9 @@ static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
  *
  * We enter with non-exclusive mmap_sem (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
- * We return with mmap_sem still held, but pte unmapped and unlocked.
+ * We return with pte unmapped and unlocked.
+ * The mmap_sem may have been released depending on flags and our
+ * return value.  See filemap_fault() and __lock_page_or_retry().
  */
 static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
@@ -3168,7 +3184,10 @@ out:
  *
  * We enter with non-exclusive mmap_sem (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
- * We return with mmap_sem still held, but pte unmapped and unlocked.
+ * We return with pte unmapped and unlocked.
+ *
+ * The mmap_sem may have been released depending on flags and our
+ * return value.  See filemap_fault() and __lock_page_or_retry().
  */
 static int handle_pte_fault(struct mm_struct *mm,
 		     struct vm_area_struct *vma, unsigned long address,
@@ -3228,6 +3247,9 @@ unlock:
 
 /*
  * By the time we get here, we already hold the mm semaphore
+ *
+ * The mmap_sem may have been released depending on flags and our
+ * return value.  See filemap_fault() and __lock_page_or_retry().
  */
 static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			     unsigned long address, unsigned int flags)
@@ -3309,6 +3331,12 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
 }
 
+/*
+ * By the time we get here, we already hold the mm semaphore
+ *
+ * The mmap_sem may have been released depending on flags and our
+ * return value.  See filemap_fault() and __lock_page_or_retry().
+ */
 int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		    unsigned long address, unsigned int flags)
 {
diff --git a/mm/mlock.c b/mm/mlock.c
index b1eb536..75e0d14 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -210,12 +210,19 @@ out:
  * @vma:   target vma
  * @start: start address
  * @end:   end address
+ * @nonblocking:
  *
  * This takes care of making the pages present too.
  *
  * return 0 on success, negative error code on error.
  *
- * vma->vm_mm->mmap_sem must be held for at least read.
+ * vma->vm_mm->mmap_sem must be held.
+ *
+ * If @nonblocking is NULL, it may be held for read or write and will
+ * be unperturbed.
+ *
+ * If @nonblocking is non-NULL, it must held for read only and may be
+ * released.  If it's released, *@nonblocking will be set to 0.
  */
 long __mlock_vma_pages_range(struct vm_area_struct *vma,
 		unsigned long start, unsigned long end, int *nonblocking)
-- 
1.8.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
