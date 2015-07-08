Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id B52E96B0256
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 06:50:19 -0400 (EDT)
Received: by qkhu186 with SMTP id u186so159830267qkh.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 03:50:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r187si2224263qha.27.2015.07.08.03.50.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 03:50:12 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 2/5] userfaultfd: allow signals to interrupt a userfault
Date: Wed,  8 Jul 2015 12:50:05 +0200
Message-Id: <1436352608-8455-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1436352608-8455-1-git-send-email-aarcange@redhat.com>
References: <1436352608-8455-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, Dave Hansen <dave.hansen@intel.com>

This is only simple to achieve if the userfault is going to return to
userland (not to the kernel) because we can avoid returning
VM_FAULT_RETRY despite we temporarily released the mmap_sem. The fault
would just be retried by userland then. This is safe at least on x86
and powerpc (the two archs with the syscall implemented so far).

Hint to verify for which archs this is safe: after handle_mm_fault returns, no
access to data structures protected by the mmap_sem must be done by the fault
code in arch/*/mm/fault.c until up_read(&mm->mmap_sem) is called.

This has two main benefits: signals can run with lower latency in production
(signals aren't blocked by userfaults and userfaults are immediately repeated
after signal processing) and gdb can then trivially debug the threads blocked
in this kind of userfaults coming directly from userland.

On a side note: while gdb has a need to get signal processed, coredumps always
worked perfectly with userfaults, no matter if the userfault is triggered by
GUP a kernel copy_user or directly from userland.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 35 ++++++++++++++++++++++++++++++++---
 1 file changed, 32 insertions(+), 3 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 901d52a..851d575 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -262,7 +262,7 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 	struct userfaultfd_ctx *ctx;
 	struct userfaultfd_wait_queue uwq;
 	int ret;
-	bool must_wait;
+	bool must_wait, return_to_userland;
 
 	BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
 
@@ -327,6 +327,9 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 	uwq.msg = userfault_msg(address, flags, reason);
 	uwq.ctx = ctx;
 
+	return_to_userland = (flags & (FAULT_FLAG_USER|FAULT_FLAG_KILLABLE)) ==
+		(FAULT_FLAG_USER|FAULT_FLAG_KILLABLE);
+
 	spin_lock(&ctx->fault_pending_wqh.lock);
 	/*
 	 * After the __add_wait_queue the uwq is visible to userland
@@ -338,14 +341,16 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 	 * following the spin_unlock to happen before the list_add in
 	 * __add_wait_queue.
 	 */
-	set_current_state(TASK_KILLABLE);
+	set_current_state(return_to_userland ? TASK_INTERRUPTIBLE :
+			  TASK_KILLABLE);
 	spin_unlock(&ctx->fault_pending_wqh.lock);
 
 	must_wait = userfaultfd_must_wait(ctx, address, flags, reason);
 	up_read(&mm->mmap_sem);
 
 	if (likely(must_wait && !ACCESS_ONCE(ctx->released) &&
-		   !fatal_signal_pending(current))) {
+		   (return_to_userland ? !signal_pending(current) :
+		    !fatal_signal_pending(current)))) {
 		wake_up_poll(&ctx->fd_wqh, POLLIN);
 		schedule();
 		ret |= VM_FAULT_MAJOR;
@@ -353,6 +358,30 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 
 	__set_current_state(TASK_RUNNING);
 
+	if (return_to_userland) {
+		if (signal_pending(current) &&
+		    !fatal_signal_pending(current)) {
+			/*
+			 * If we got a SIGSTOP or SIGCONT and this is
+			 * a normal userland page fault, just let
+			 * userland return so the signal will be
+			 * handled and gdb debugging works.  The page
+			 * fault code immediately after we return from
+			 * this function is going to release the
+			 * mmap_sem and it's not depending on it
+			 * (unlike gup would if we were not to return
+			 * VM_FAULT_RETRY).
+			 *
+			 * If a fatal signal is pending we still take
+			 * the streamlined VM_FAULT_RETRY failure path
+			 * and there's no need to retake the mmap_sem
+			 * in such case.
+			 */
+			down_read(&mm->mmap_sem);
+			ret = 0;
+		}
+	}
+
 	/*
 	 * Here we race with the list_del; list_add in
 	 * userfaultfd_ctx_read(), however because we don't ever run

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
