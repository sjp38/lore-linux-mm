Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 524956B007E
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 03:54:03 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o957rw83021954
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 00:53:59 -0700
Received: from pva18 (pva18.prod.google.com [10.241.209.18])
	by kpbe20.cbf.corp.google.com with ESMTP id o957rtcE010694
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 00:53:57 -0700
Received: by pva18 with SMTP id 18so4419789pva.2
        for <linux-mm@kvack.org>; Tue, 05 Oct 2010 00:53:57 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 2/3] Retry page fault when blocking on disk transfer.
Date: Tue,  5 Oct 2010 00:53:34 -0700
Message-Id: <1286265215-9025-3-git-send-email-walken@google.com>
In-Reply-To: <1286265215-9025-1-git-send-email-walken@google.com>
References: <1286265215-9025-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Ying Han <yinghan@google.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

This change reduces mmap_sem hold times that are caused by waiting for
disk transfers when accessing file mapped VMAs. It introduces the
VM_FAULT_ALLOW_RETRY flag, which indicates that the call site wants
mmap_sem to be released if blocking on a pending disk transfer.
In that case, filemap_fault() returns the VM_FAULT_RETRY status bit
and do_page_fault() will then re-acquire mmap_sem and retry the page fault.
It is expected that the retry will hit the same page which will now be
cached, and thus it will complete with a low mmap_sem hold time.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 arch/x86/mm/fault.c |   38 ++++++++++++++++++++++++++------------
 include/linux/mm.h  |    2 ++
 mm/filemap.c        |   23 ++++++++++++++++++++++-
 mm/memory.c         |    3 ++-
 4 files changed, 52 insertions(+), 14 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 4c4508e..b355b92 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -952,8 +952,10 @@ do_page_fault(struct pt_regs *regs, unsigned long error_code)
 	struct task_struct *tsk;
 	unsigned long address;
 	struct mm_struct *mm;
-	int write;
 	int fault;
+	int write = error_code & PF_WRITE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY |
+					(write ? FAULT_FLAG_WRITE : 0);
 
 	tsk = current;
 	mm = tsk->mm;
@@ -1064,6 +1066,7 @@ do_page_fault(struct pt_regs *regs, unsigned long error_code)
 			bad_area_nosemaphore(regs, error_code, address);
 			return;
 		}
+retry:
 		down_read(&mm->mmap_sem);
 	} else {
 		/*
@@ -1107,8 +1110,6 @@ do_page_fault(struct pt_regs *regs, unsigned long error_code)
 	 * we can handle it..
 	 */
 good_area:
-	write = error_code & PF_WRITE;
-
 	if (unlikely(access_error(error_code, write, vma))) {
 		bad_area_access_error(regs, error_code, address);
 		return;
@@ -1119,21 +1120,34 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault:
 	 */
-	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 
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
+	/*
+	 * Major/minor page fault accounting is only done on the
+	 * initial attempt. If we go through a retry, it is extremely
+	 * likely that the page will be found in page cache at that point.
+	 */
+	if (flags & FAULT_FLAG_ALLOW_RETRY) {
+		if (fault & VM_FAULT_MAJOR) {
+			tsk->maj_flt++;
+			perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MAJ, 1, 0,
+				      regs, address);
+		} else {
+			tsk->min_flt++;
+			perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MIN, 1, 0,
+				      regs, address);
+		}
+		if (fault & VM_FAULT_RETRY) {
+			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
+			 * of starvation. */
+			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			goto retry;
+		}
 	}
 
 	check_v8086_mode(regs, address, tsk);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 74949fb..0b4f9b2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -144,6 +144,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_WRITE	0x01	/* Fault was a write access */
 #define FAULT_FLAG_NONLINEAR	0x02	/* Fault was via a nonlinear mapping */
 #define FAULT_FLAG_MKWRITE	0x04	/* Fault was mkwrite of existing pte */
+#define FAULT_FLAG_ALLOW_RETRY	0x08	/* Retry fault if blocking */
 
 /*
  * This interface is used by x86 PAT code to identify a pfn mapping that is
@@ -722,6 +723,7 @@ static inline int page_mapped(struct page *page)
 
 #define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page */
 #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
+#define VM_FAULT_RETRY	0x0400	/* ->fault blocked, must retry */
 
 #define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_HWPOISON)
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 8ed709a..7cba9bf 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1501,6 +1501,26 @@ static void do_async_mmap_readahead(struct vm_area_struct *vma,
 					   page, offset, ra->ra_pages);
 }
 
+/*
+ * Lock the page, unless this would block and the caller indicated that it
+ * can handle a retry.
+ */
+static int lock_page_or_retry(struct page *page,
+			      struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	if (trylock_page(page))
+		return 1;
+	if (!(vmf->flags & FAULT_FLAG_ALLOW_RETRY)) {
+		__lock_page(page);
+		return 1;
+	}
+
+	up_read(&vma->vm_mm->mmap_sem);
+	wait_on_page_locked(page);
+	page_cache_release(page);
+	return 0;
+}
+
 /**
  * filemap_fault - read in file data for page fault handling
  * @vma:	vma in which the fault was taken
@@ -1550,7 +1570,8 @@ retry_find:
 			goto no_cached_page;
 	}
 
-	lock_page(page);
+	if (!lock_page_or_retry(page, vma, vmf))
+		return ret | VM_FAULT_RETRY;
 
 	/* Did it get truncated? */
 	if (unlikely(page->mapping != mapping)) {
diff --git a/mm/memory.c b/mm/memory.c
index 0e18b4d..b068c68 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2926,7 +2926,8 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	vmf.page = NULL;
 
 	ret = vma->vm_ops->fault(vma, &vmf);
-	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
+	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE |
+			    VM_FAULT_RETRY)))
 		return ret;
 
 	if (unlikely(PageHWPoison(vmf.page))) {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
