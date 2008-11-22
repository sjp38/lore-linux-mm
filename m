Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id mAM6ll40032669
	for <linux-mm@kvack.org>; Fri, 21 Nov 2008 22:47:47 -0800
Received: from rv-out-0708.google.com (rvbf25.prod.google.com [10.140.82.25])
	by spaceape7.eur.corp.google.com with ESMTP id mAM6liVQ026309
	for <linux-mm@kvack.org>; Fri, 21 Nov 2008 22:47:45 -0800
Received: by rv-out-0708.google.com with SMTP id f25so1691426rvb.18
        for <linux-mm@kvack.org>; Fri, 21 Nov 2008 22:47:44 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 21 Nov 2008 22:47:44 -0800
Message-ID: <604427e00811212247k1fe6b63u9efe8cfe37bddfb5@mail.gmail.com>
Subject: [RFC v1][PATCH]page_fault retry with NOPAGE_RETRY
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, Mike Waychison <mikew@google.com>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

page fault retry with NOPAGE_RETRY
Allow major faults to drop the mmap_sem read lock while waitting for
synchronous disk read. This allows another thread which wishes to grab
down_read(mmap_sem) to proceed while the current is waitting the disk IO.

The patch flags current->flags to PF_FAULT_MAYRETRY as identify that the
caller can tolerate the retry in the filemap_fault call patch.

Benchmark is done by mmap in huge file and spaw 64 thread each faulting in
pages in reverse order, the the result shows 8% porformance hit with the
patch.

Future Improvement:
1. It could be more efficient to check if the mm_struct has been changed or
not. So we don't need to back all the way out of pagefault handler for the
cases mm_struct not changed.
2. It is a bit hacky and using a flag in current->flags to determine
whether we have done the retry or now. More generic way of doing it is pass
back the page_fault handler something like page_fault_args which introduce
the reason for the retry, so the higher level could be able to better
handle.

 Signed-off-by: Mike Waychison <mikew@google.com>
 Signed-off-by: Ying Han <yinghan@google.com>


 arch/x86/mm/fault.c   |   25 +++++++++++++++++++---
 include/linux/mm.h    |    1 +
 include/linux/sched.h |    1 +
 mm/filemap.c          |   53 +++++++++++++++++++++++++++++++++++++++++++++++-
 mm/memory.c           |    6 +++++
 5 files changed, 80 insertions(+), 6 deletions(-)


diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 31e8730..883e9c5 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -577,10 +577,8 @@ int show_unhandled_signals = 1;
  * and the problem, and then passes it off to one of the appropriate
  * routines.
  */
-#ifdef CONFIG_X86_64
-asmlinkage
-#endif
-void __kprobes do_page_fault(struct pt_regs *regs, unsigned long error_code)
+static void __kprobes __do_page_fault(struct pt_regs *regs,
+					unsigned long error_code)
 {
 	struct task_struct *tsk;
 	struct mm_struct *mm;
@@ -689,6 +687,7 @@ again:
 		down_read(&mm->mmap_sem);
 	}

+retry:
 	vma = find_vma(mm, address);
 	if (!vma)
 		goto bad_area;
@@ -743,6 +742,15 @@ good_area:
 			goto do_sigbus;
 		BUG();
 	}
+
+	if (fault & VM_FAULT_RETRY) {
+		if (current->flags & PF_FAULT_MAYRETRY) {
+			current->flags &= ~PF_FAULT_MAYRETRY;
+			goto retry;
+		}
+		BUG();
+	}
+
 	if (fault & VM_FAULT_MAJOR)
 		tsk->maj_flt++;
 	else
@@ -893,6 +901,16 @@ do_sigbus:
 	force_sig_info_fault(SIGBUS, BUS_ADRERR, address, tsk);
 }

+#ifdef CONFIG_X86_64
+asmlinkage
+#endif
+void do_page_fault(struct pt_regs *regs, unsigned long error_code)
+{
+	current->flags |= PF_FAULT_MAYRETRY;
+	__do_page_fault(regs, error_code);
+	current->flags &= ~PF_FAULT_MAYRETRY;
+}
+
 DEFINE_SPINLOCK(pgd_lock);
 LIST_HEAD(pgd_list);

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ffee2f7..d325ae8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -694,6 +694,7 @@ static inline int page_mapped(struct page *page)
 #define VM_FAULT_SIGBUS	0x0002
 #define VM_FAULT_MAJOR	0x0004
 #define VM_FAULT_WRITE	0x0008	/* Special case for get_user_pages */
+#define VM_FAULT_RETRY	0x0010

 #define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page
 #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index b483f39..8c41746 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1559,7 +1559,7 @@ extern cputime_t task_gtime(struct task_struct *p);
 #define PF_MUTEX_TESTER	0x20000000	/* Thread belongs to the rt mutex tester *
 #define PF_FREEZER_SKIP	0x40000000	/* Freezer should not count it as freezeab
 #define PF_FREEZER_NOSIG 0x80000000	/* Freezer won't send signals to it */
-
+#define PF_FAULT_MAYRETRY 0x08000000	/* may drop mmap_sem during fault */
 /*
  * Only the _current_ task can read/write to tsk->flags, but other
  * tasks can access tsk->flags in readonly mode for example
diff --git a/mm/filemap.c b/mm/filemap.c
index f3e5f89..2baa519 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1458,6 +1458,8 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_
 	 */
 retry_find:
 	page = find_lock_page(mapping, vmf->pgoff);
+
+retry_find_nopage:
 	/*
 	 * For sequential accesses, we use the generic readahead logic.
 	 */
@@ -1512,6 +1514,7 @@ retry_find:
 	if (!did_readaround)
 		ra->mmap_miss--;

+retry_page_update:
 	/*
 	 * We have a locked page in the page cache, now we need to check
 	 * that it's up-to-date. If not, it is going to be due to an error.
@@ -1547,8 +1550,54 @@ no_cached_page:
 	 * In the unlikely event that someone removed it in the
 	 * meantime, we'll just come back here and read it again.
 	 */
-	if (error >= 0)
-		goto retry_find;
+	if (error >= 0) {
+		/*
+		 * If caller cannot tolerate a retry in the ->fault path
+		 * go back to check the page again.
+		 */
+		if (!(current->flags & PF_FAULT_MAYRETRY))
+			goto retry_find;
+
+		/*
+		 * Caller is flagged with retry. If page is deleted
+		 * already, go back to get a new page, otherwise
+		 * check the page is locked or not. If page is
+		 * locked, do nopage_retry.
+		 */
+		page = find_get_page(mapping, vmf->pgoff);
+		if (!page)
+			goto retry_find_nopage;
+		if (!trylock_page(page)) {
+			struct mm_struct *mm = vma->vm_mm;
+			/*
+			 * Page is already locked by someone else.
+			 *
+			 * We don't want to be holding down_read(mmap_sem)
+			 * inside lock_page(). We use wait_on_page_lock here
+			 * to just wait until the page is unlocked, but we
+			 * don't really need
+			 * to lock it.
+			 */
+			up_read(&mm->mmap_sem);
+			wait_on_page_locked(page);
+			down_read(&mm->mmap_sem);
+			/*
+			 * The VMA tree may have changed at this point.
+			 */
+			page_cache_release(page);
+			return VM_FAULT_RETRY;
+		}
+
+		/* Has the page been truncated */
+		if (unlikely(page->mapping != mapping)) {
+			unlock_page(page);
+			page_cache_release(page);
+			goto retry_find;
+		}
+
+		goto retry_page_update;
+
+	}

 	/*
 	 * An error return from page_cache_read can result if the
diff --git a/mm/memory.c b/mm/memory.c
index 164951c..38bd63b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2467,6 +2467,12 @@ static int __do_fault(struct mm_struct *mm, struct vm_a
 	vmf.page = NULL;

 	ret = vma->vm_ops->fault(vma, &vmf);
+
+	/* page may be available, but we have to restart the process
+	 * because mmap_sem was dropped during the ->fault */
+	if (ret == VM_FAULT_RETRY)
+		return ret;
+
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
 		return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
