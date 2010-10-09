Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DF5486B006A
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 21:22:14 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id o991MBwu003893
	for <linux-mm@kvack.org>; Fri, 8 Oct 2010 18:22:11 -0700
Received: from pwi7 (pwi7.prod.google.com [10.241.219.7])
	by hpaq1.eem.corp.google.com with ESMTP id o991M9dx020850
	for <linux-mm@kvack.org>; Fri, 8 Oct 2010 18:22:09 -0700
Received: by pwi7 with SMTP id 7so269594pwi.16
        for <linux-mm@kvack.org>; Fri, 08 Oct 2010 18:22:08 -0700 (PDT)
Date: Fri, 8 Oct 2010 18:22:04 -0700
From: Michel Lespinasse <walken@google.com>
Subject: Re: [PATCH 2/3] Retry page fault when blocking on disk transfer.
Message-ID: <20101009012204.GA17458@google.com>
References: <1286265215-9025-1-git-send-email-walken@google.com>
 <1286265215-9025-3-git-send-email-walken@google.com>
 <4CAB628D.3030205@redhat.com>
 <AANLkTimdACZ9Xm01DM2+E64+T5XfLffrkFBhf7CJ286p@mail.gmail.com>
 <20101008043956.GA25662@google.com>
 <4CAF1B90.3080703@redhat.com>
 <AANLkTinWxTT=+m_fAudc080OUMwacSefnMbSMBFZgPMH@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTinWxTT=+m_fAudc080OUMwacSefnMbSMBFZgPMH@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Ying Han <yinghan@google.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>


Second try on adding the VM_FAULT_RETRY functionality to the swap in path.

This proposal would replace [patch 2/3] of this series (the initial
version of it, which was approved by linus / rik / hpa).

Changes since the approved version:

- split lock_page_or_retry() into an inline function in  pagemap.h,
  handling the trylock_page() fast path, and __lock_page_or_retry() in
  filemap.c, handling the blocking path (with or without retry).

- make do_swap_page() call lock_page_or_retry() in place of lock_page(),
  and handle the retry case.

---------------------------------- 8< -----------------------------------

Retry page fault when blocking on disk transfer.
    
This change reduces mmap_sem hold times that are caused by waiting for
disk transfers when accessing file mapped VMAs or swap space.
It introduces the VM_FAULT_ALLOW_RETRY flag, which indicates that the
call site wants mmap_sem to be released if blocking on a pending
disk transfer. In that case, handle_mm_fault() returns the
VM_FAULT_RETRY status flag and do_page_fault() will then re-acquire
mmap_sem and retry the page fault. It is expected that the retry will
hit the same page which will now be cached, and thus it will
complete with a low mmap_sem hold time.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 arch/x86/mm/fault.c     |   38 ++++++++++++++++++++++++++------------
 include/linux/mm.h      |    2 ++
 include/linux/pagemap.h |   13 +++++++++++++
 mm/filemap.c            |   16 +++++++++++++++-
 mm/memory.c             |   10 ++++++++--
 5 files changed, 64 insertions(+), 15 deletions(-)

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
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index e12cdc6..2d1ffe3 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -299,6 +299,8 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
 extern void __lock_page(struct page *page);
 extern int __lock_page_killable(struct page *page);
 extern void __lock_page_nosync(struct page *page);
+extern int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
+				unsigned int flags);
 extern void unlock_page(struct page *page);
 
 static inline void __set_page_locked(struct page *page)
@@ -351,6 +353,17 @@ static inline void lock_page_nosync(struct page *page)
 }
 	
 /*
+ * lock_page_or_retry - Lock the page, unless this would block and the
+ * caller indicated that it can handle a retry.
+ */
+static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
+				     unsigned int flags)
+{
+	might_sleep();
+	return trylock_page(page) || __lock_page_or_retry(page, mm, flags);
+}
+
+/*
  * This is exported only for wait_on_page_locked/wait_on_page_writeback.
  * Never use this directly!
  */
diff --git a/mm/filemap.c b/mm/filemap.c
index 8ed709a..2eeb6c5 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -612,6 +612,19 @@ void __lock_page_nosync(struct page *page)
 							TASK_UNINTERRUPTIBLE);
 }
 
+int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
+			 unsigned int flags)
+{
+	if (!(flags & FAULT_FLAG_ALLOW_RETRY)) {
+		__lock_page(page);
+		return 1;
+	} else {
+		up_read(&mm->mmap_sem);
+		wait_on_page_locked(page);
+		return 0;
+	}
+}
+
 /**
  * find_get_page - find and get a page reference
  * @mapping: the address_space to search
@@ -1550,7 +1563,8 @@ retry_find:
 			goto no_cached_page;
 	}
 
-	lock_page(page);
+	if (!lock_page_or_retry(page, &vma->vm_mm, vmf->flags))
+		return ret | VM_FAULT_RETRY;
 
 	/* Did it get truncated? */
 	if (unlikely(page->mapping != mapping)) {
diff --git a/mm/memory.c b/mm/memory.c
index 0e18b4d..362e803 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2626,6 +2626,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *page, *swapcache = NULL;
 	swp_entry_t entry;
 	pte_t pte;
+	int locked;
 	struct mem_cgroup *ptr = NULL;
 	int exclusive = 0;
 	int ret = 0;
@@ -2676,8 +2677,12 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto out_release;
 	}
 
-	lock_page(page);
+	locked = lock_page_or_retry(page, mm, flags);
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
+	if (!locked) {
+		ret |= VM_FAULT_RETRY;
+		goto out_release;
+	}
 
 	/*
 	 * Make sure try_to_free_swap or reuse_swap_page or swapoff did not
@@ -2926,7 +2931,8 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	vmf.page = NULL;
 
 	ret = vma->vm_ops->fault(vma, &vmf);
-	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
+	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE |
+			    VM_FAULT_RETRY)))
 		return ret;
 
 	if (unlikely(PageHWPoison(vmf.page))) {


-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
