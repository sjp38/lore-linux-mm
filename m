Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E3A036B0116
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 12:53:07 -0400 (EDT)
Message-Id: <20110628165303.010143380@goodmis.org>
Date: Tue, 28 Jun 2011 12:47:52 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH 2/2] mm: Document handle_mm_fault()
References: <20110628164750.281686775@goodmis.org>
Content-Disposition: inline; filename=0002-mm-Document-handle_mm_fault.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Russell King <rmk+kernel@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Gleb Natapov <gleb@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>

From: Steven Rostedt <srostedt@redhat.com>

The function handle_mm_fault() is long overdue for comments.
Adding a kernel doc header for the function and explaining the subtle
use of the flags with respect to mmap_sem will prove useful in the
future when others work with this code.

Russell King noticed that the code in arch/x86/mm/fault.c looked
buggy as the do_page_fault() code would grab the mmap_sem multiple
times without letting it go. But it only did this when the
handle_mm_fault() would return VM_FAULT_RETRY.

Examining the code and reading the git change logs, it was discovered
that commit d065bd810b6deb67d4897a14bfe21f8eb526ba99
  mm: retry page fault when blocking on disk transfer
added code to remove contention with the mmap_sem when the page_lock
was being held for IO. As waiting on IO holding the mmap_sem can
cause lots of contention between threads. The flag
FAULT_FLAG_ALLOW_RETRY was added to let handle_mm_fault() know
that it can safely release the mmap_sem.

Adding to the confusion here with handle_mm_fault(), another
  commit 318b275fbca1ab9ec0862de71420e0e92c3d1aa7
  mm: allow GUP to fail instead of waiting on a page
was added that would not release the mmap_sem, even if
FAULT_FLAG_ALLOW_RETRY was set and the page_lock was not taken
and VM_FAULT_RETRY was returned, if FAULT_FLAGS_RETRY_NOWAIT was
set.

All of this is poorly documented and makes using or modifying
handle_mm_fault() fragile. Documenting all of these subtle changes
at the head of handle_mm_fault() should help future developers
understand what is happening.

Reported-by: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: Gleb Natapov <gleb@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Avi Kivity <avi@redhat.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
---
 mm/memory.c |   22 ++++++++++++++++++++--
 1 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 5371b5e..3cf30f6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3378,8 +3378,26 @@ unlock:
 	return 0;
 }
 
-/*
- * By the time we get here, we already hold the mm semaphore
+/**
+ * handle_mm_fault - main routine for handling page faults
+ * @mm:		the mm_struct of the target address space
+ * @vma:	vm_area_struct holding the applicable pages
+ * @address:	the address that took the fault
+ * @flags:	flags modifying lookup behaviour
+ *
+ * Must have @mm->mmap_sem held.
+ *
+ * Note: if @flags has FAULT_FLAG_ALLOW_RETRY set then the mmap_sem
+ *       may be released if it failed to arquire the page_lock. If the
+ *       mmap_sem is released then it will return VM_FAULT_RETRY set.
+ *       This is to keep the time mmap_sem is held when the page_lock
+ *       is taken for IO.
+ * Exception: If FAULT_FLAG_RETRY_NOWAIT is set, then it will
+ *       not release the mmap_sem, but will still return VM_FAULT_RETRY
+ *       if it failed to acquire the page_lock.
+ *       This is for helping virtualization. See get_user_page_nowait().
+ *
+ * Returns status flags based on the VM_FAULT_* flags in <linux/mm.h>
  */
 int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, unsigned int flags)
-- 
1.7.5.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
