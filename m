Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DB82F6B0078
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 01:05:02 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o9154xUc009390
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 22:04:59 -0700
Received: from pxi5 (pxi5.prod.google.com [10.243.27.5])
	by wpaz33.hot.corp.google.com with ESMTP id o9154wjx007621
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 22:04:58 -0700
Received: by pxi5 with SMTP id 5so895775pxi.28
        for <linux-mm@kvack.org>; Thu, 30 Sep 2010 22:04:58 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 2/2] Release mmap_sem when page fault blocks on disk transfer.
Date: Thu, 30 Sep 2010 22:04:44 -0700
Message-Id: <1285909484-30958-3-git-send-email-walken@google.com>
In-Reply-To: <1285909484-30958-1-git-send-email-walken@google.com>
References: <1285909484-30958-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Ying Han <yinghan@google.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

This change reduces mmap_sem hold times that are caused by waiting for
disk transfers when accessing file mapped VMAs. It introduces the
VM_FAULT_RELEASED flag, which indicates that the call site holds mmap_lock
and wishes for it to be released if blocking on a pending disk transfer.
In that case, filemap_fault() returns the VM_FAULT_RELEASED status bit
and do_page_fault() will then re-acquire mmap_sem and retry the page fault.
It is expected that the retry will hit the same page which will now be cached,
and thus it will complete with a low mmap_sem hold time.


Signed-off-by: Michel Lespinasse <walken@google.com>
---
 arch/x86/mm/fault.c |   35 ++++++++++++++++++++++++++---------
 include/linux/mm.h  |    2 ++
 mm/filemap.c        |   20 +++++++++++++++++++-
 mm/memory.c         |    3 ++-
 4 files changed, 49 insertions(+), 11 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 4c4508e..58109ba 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -954,6 +954,7 @@ do_page_fault(struct pt_regs *regs, unsigned long error_code)
 	struct mm_struct *mm;
 	int write;
 	int fault;
+	unsigned int release_flag = FAULT_FLAG_RELEASE;
 
 	tsk = current;
 	mm = tsk->mm;
@@ -1064,6 +1065,7 @@ do_page_fault(struct pt_regs *regs, unsigned long error_code)
 			bad_area_nosemaphore(regs, error_code, address);
 			return;
 		}
+retry:
 		down_read(&mm->mmap_sem);
 	} else {
 		/*
@@ -1119,21 +1121,36 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault:
 	 */
-	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address,
+				release_flag | (write ? FAULT_FLAG_WRITE : 0));
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		mm_fault_error(regs, error_code, address, fault);
 		return;
 	}
 
-	if (fault & VM_FAULT_MAJOR) {
-		tsk->maj_flt++;
-		perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MAJ, 1, 0,
-				     regs, address);
-	} else {
-		tsk->min_flt++;
-		perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MIN, 1, 0,
-				     regs, address);
+	if (release_flag) {	/* Did not go through a retry */
+		if (fault & VM_FAULT_MAJOR) {
+			tsk->maj_flt++;
+			perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MAJ, 1, 0,
+				      regs, address);
+		} else {
+			tsk->min_flt++;
+			perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MIN, 1, 0,
+				      regs, address);
+		}
+		if (fault & VM_FAULT_RELEASED) {
+			/*
+			 * handle_mm_fault() found that the desired page was
+			 * locked. We asked for it to release mmap_sem in that
+			 * case, so as to avoid holding it for too long.
+			 * Retry starting at the mmap_sem acquire, this time
+			 * without FAULT_FLAG_RETRY so that we avoid any
+			 * risk of starvation.
+			 */
+			release_flag = 0;
+			goto retry;
+		}
 	}
 
 	check_v8086_mode(regs, address, tsk);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 74949fb..7782c30 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -144,6 +144,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_WRITE	0x01	/* Fault was a write access */
 #define FAULT_FLAG_NONLINEAR	0x02	/* Fault was via a nonlinear mapping */
 #define FAULT_FLAG_MKWRITE	0x04	/* Fault was mkwrite of existing pte */
+#define FAULT_FLAG_RELEASE	0x08	/* Release mmap_sem if blocking */
 
 /*
  * This interface is used by x86 PAT code to identify a pfn mapping that is
@@ -722,6 +723,7 @@ static inline int page_mapped(struct page *page)
 
 #define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page */
 #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
+#define VM_FAULT_RELEASED	0x0400	/* mmap_sem got released */
 
 #define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_HWPOISON)
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 8ed709a..74197e2 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1550,7 +1550,25 @@ retry_find:
 			goto no_cached_page;
 	}
 
-	lock_page(page);
+	/* Lock the page. */
+	if (!trylock_page(page)) {
+		if (!(vmf->flags & FAULT_FLAG_RELEASE))
+			__lock_page(page);
+		else {
+			/*
+			 * Caller passed FAULT_FLAG_RELEASE flag.
+			 * This indicates it has read-acquired mmap_sem,
+			 * and requests that it be released if we have to
+			 * wait for the page to be transferred from disk.
+			 * Caller will then retry starting with the
+			 * mmap_sem read-acquire.
+			 */
+			up_read(&vma->vm_mm->mmap_sem);
+			wait_on_page_locked(page);
+			page_cache_release(page);
+			return ret | VM_FAULT_RELEASED;
+		}
+	}
 
 	/* Did it get truncated? */
 	if (unlikely(page->mapping != mapping)) {
diff --git a/mm/memory.c b/mm/memory.c
index 0e18b4d..2efb59d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2926,7 +2926,8 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	vmf.page = NULL;
 
 	ret = vma->vm_ops->fault(vma, &vmf);
-	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
+	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE |
+			    VM_FAULT_RELEASED)))
 		return ret;
 
 	if (unlikely(PageHWPoison(vmf.page))) {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
