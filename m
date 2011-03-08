Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A63F38D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 10:59:48 -0500 (EST)
From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH] mm: handle mm_fault_error in kernel space (v2)
Date: Tue,  8 Mar 2011 18:59:25 +0300
Message-Id: <1299599965-28995-1-git-send-email-avagin@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

mm_fault_error() should not execute oom-killer, if page fault occurs
in kernel space. E.g. in copy_from_user/copy_to_user.

This would happen if we find ourselves in OOM on a copy_to_user(),
or a copy_from_user() which faults.

Without this patch, the kernels hangs up in copy_from_user, because
OOM killer sends SIG_KILL to current process, but it can't handle a
signal while in syscall, then the kernel returns to copy_from_user,
reexcute current command and provokes page_fault again.

With this patch the kernel return -EFAULT from copy_from_user.

The code, which checks that page fault occurred in kernel space, has been
copied from do_sigbus.

This situation is handled by the same way on powerpc, xtensa, tile, ...

Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 arch/x86/mm/fault.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 7d90ceb..ffc7be1 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -828,6 +828,13 @@ mm_fault_error(struct pt_regs *regs, unsigned long error_code,
 	       unsigned long address, unsigned int fault)
 {
 	if (fault & VM_FAULT_OOM) {
+		/* Kernel mode? Handle exceptions or die: */
+		if (!(error_code & PF_USER)) {
+			up_read(&current->mm->mmap_sem);
+			no_context(regs, error_code, address);
+			return;
+		}
+
 		out_of_memory(regs, error_code, address);
 	} else {
 		if (fault & (VM_FAULT_SIGBUS|VM_FAULT_HWPOISON|
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
