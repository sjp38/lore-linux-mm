Date: Thu, 25 Aug 2005 13:14:26 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] Only process_die notifier in ia64_do_page_fault if KPROBES
 is configured.
Message-ID: <Pine.LNX.4.62.0508251312010.7100@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-ia64@vger.kernel.org
Cc: linux-mm@kvack.org, prasanna@in.ibm.com
List-ID: <linux-mm.kvack.org>

ia64_do_page_fault is a path critical for system performance. The code to call
notify_die() should not be compiled into that critical path if the system
is not configured to use KPROBES.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.13-rc7/arch/ia64/mm/fault.c
===================================================================
--- linux-2.6.13-rc7.orig/arch/ia64/mm/fault.c	2005-08-23 20:39:14.000000000 -0700
+++ linux-2.6.13-rc7/arch/ia64/mm/fault.c	2005-08-25 13:04:57.000000000 -0700
@@ -103,12 +103,16 @@ ia64_do_page_fault (unsigned long addres
 		goto bad_area_no_up;
 #endif
 
+#ifdef CONFIG_KPROBES
 	/*
-	 * This is to handle the kprobes on user space access instructions
+	 * This is to handle the kprobes on user space access instructions.
+	 * This is a path criticial for system performance. So only
+	 * process this notifier if we are compiled with kprobes support.
 	 */
 	if (notify_die(DIE_PAGE_FAULT, "page fault", regs, code, TRAP_BRKPT,
 					SIGSEGV) == NOTIFY_STOP)
 		return;
+#endif
 
 	down_read(&mm->mmap_sem);
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
