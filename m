Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 129BC6B0038
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 13:22:18 -0400 (EDT)
Received: by qged89 with SMTP id d89so9261744qge.0
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 10:22:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k75si8590899qhc.43.2015.06.15.10.22.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 10:22:17 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 3/7] userfaultfd: allow signals to interrupt a userfault
Date: Mon, 15 Jun 2015 19:22:07 +0200
Message-Id: <1434388931-24487-4-git-send-email-aarcange@redhat.com>
In-Reply-To: <1434388931-24487-1-git-send-email-aarcange@redhat.com>
References: <1434388931-24487-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org
Cc: Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

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
index b69d236..8286ec8 100644
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
