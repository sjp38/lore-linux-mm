Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7A94F6B0083
	for <linux-mm@kvack.org>; Fri, 29 May 2009 17:35:19 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <200905291135.124267638@firstfloor.org>
In-Reply-To: <200905291135.124267638@firstfloor.org>
Subject: [PATCH] [8/16] HWPOISON: x86: Add VM_FAULT_HWPOISON handling to x86 page fault handler
Message-Id: <20090529213533.E1AE91D0286@basil.firstfloor.org>
Date: Fri, 29 May 2009 23:35:33 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>


Add VM_FAULT_HWPOISON handling to the x86 page fault handler. This is 
very similar to VM_FAULT_OOM, the only difference is that a different
si_code is passed to user space and the new addr_lsb field is initialized.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 arch/x86/mm/fault.c |   18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

Index: linux/arch/x86/mm/fault.c
===================================================================
--- linux.orig/arch/x86/mm/fault.c	2009-05-29 23:32:09.000000000 +0200
+++ linux/arch/x86/mm/fault.c	2009-05-29 23:32:10.000000000 +0200
@@ -189,6 +189,7 @@
 	info.si_errno	= 0;
 	info.si_code	= si_code;
 	info.si_addr	= (void __user *)address;
+	info.si_addr_lsb = si_code == BUS_MCEERR_AR ? PAGE_SHIFT : 0;
 
 	force_sig_info(si_signo, &info, tsk);
 }
@@ -827,10 +828,12 @@
 }
 
 static void
-do_sigbus(struct pt_regs *regs, unsigned long error_code, unsigned long address)
+do_sigbus(struct pt_regs *regs, unsigned long error_code, unsigned long address,
+	  unsigned int fault)
 {
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
+	int code = BUS_ADRERR;
 
 	up_read(&mm->mmap_sem);
 
@@ -846,7 +849,14 @@
 	tsk->thread.error_code	= error_code;
 	tsk->thread.trap_no	= 14;
 
-	force_sig_info_fault(SIGBUS, BUS_ADRERR, address, tsk);
+#ifdef CONFIG_MEMORY_FAILURE
+	if (fault & VM_FAULT_HWPOISON) {
+		printk(KERN_ERR "MCE: Killing %s:%d due to hardware memory corruption\n",
+			tsk->comm, tsk->pid);
+		code = BUS_MCEERR_AR;
+	}
+#endif
+	force_sig_info_fault(SIGBUS, code, address, tsk);
 }
 
 static noinline void
@@ -856,8 +866,8 @@
 	if (fault & VM_FAULT_OOM) {
 		out_of_memory(regs, error_code, address);
 	} else {
-		if (fault & VM_FAULT_SIGBUS)
-			do_sigbus(regs, error_code, address);
+		if (fault & (VM_FAULT_SIGBUS|VM_FAULT_HWPOISON))
+			do_sigbus(regs, error_code, address, fault);
 		else
 			BUG();
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
