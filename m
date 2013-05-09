Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 2AA1D6B0070
	for <linux-mm@kvack.org>; Thu,  9 May 2013 02:06:32 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id un1so1742602pbc.26
        for <linux-mm@kvack.org>; Wed, 08 May 2013 23:06:31 -0700 (PDT)
From: Francis Deslauriers <fdeslaur@gmail.com>
Subject: [page fault tracepoint 2/2] x86:Instruments page fault trace event
Date: Thu,  9 May 2013 02:05:20 -0400
Message-Id: <1368079520-11015-2-git-send-email-fdeslaur@gmail.com>
In-Reply-To: <1368079520-11015-1-git-send-email-fdeslaur@gmail.com>
References: <1368079520-11015-1-git-send-email-fdeslaur@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, rostedt@goodmis.org, fweisbec@gmail.com
Cc: raphael.beamonte@gmail.com, mathieu.desnoyers@efficios.com, linux-kernel@vger.kernel.org, Francis Deslauriers <fdeslaur@gmail.com>

Signed-off-by: Francis Deslauriers <fdeslaur@gmail.com>
Reviewed-by: RaphaA<<l Beamonte <raphael.beamonte@gmail.com>
---
 arch/x86/mm/fault.c |   11 +++++++++++
 mm/memory.c         |    5 +++++
 2 files changed, 16 insertions(+)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 654be4a..e227828 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -20,6 +20,9 @@
 #include <asm/kmemcheck.h>		/* kmemcheck_*(), ...		*/
 #include <asm/fixmap.h>			/* VSYSCALL_START		*/
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/fault.h>		/* trace_page_fault_*(), ...	*/
+
 /*
  * Page fault error code bits:
  *
@@ -756,12 +759,18 @@ __bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
 
 		if (likely(show_unhandled_signals))
 			show_signal_msg(regs, error_code, address, tsk);
+		trace_page_fault_entry(regs, address, error_code & PF_WRITE);
 
 		tsk->thread.cr2		= address;
 		tsk->thread.error_code	= error_code;
 		tsk->thread.trap_nr	= X86_TRAP_PF;
 
 		force_sig_info_fault(SIGSEGV, si_code, address, tsk, 0);
+		/*
+		 * Using -1 here, since there is no VM_FAULT flag to identify
+		 * user accesses triggering SIGSEGV.
+		 */
+		trace_page_fault_exit(-1);
 
 		return;
 	}
@@ -1185,7 +1194,9 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault:
 	 */
+	trace_page_fault_entry(regs, address, write);
 	fault = handle_mm_fault(mm, vma, address, flags);
+	trace_page_fault_exit(fault);
 
 	if (unlikely(fault & (VM_FAULT_RETRY|VM_FAULT_ERROR))) {
 		if (mm_fault_error(regs, error_code, address, fault))
diff --git a/mm/memory.c b/mm/memory.c
index 6dc1882..0bd86f8 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -67,6 +67,8 @@
 #include <asm/tlbflush.h>
 #include <asm/pgtable.h>
 
+#include <trace/events/fault.h>
+
 #include "internal.h"
 
 #ifdef LAST_NID_NOT_IN_PAGE_FLAGS
@@ -1829,8 +1831,11 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 				if (foll_flags & FOLL_NOWAIT)
 					fault_flags |= (FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT);
 
+				trace_page_fault_entry(0, start,
+						foll_flags & FOLL_WRITE);
 				ret = handle_mm_fault(mm, vma, start,
 							fault_flags);
+				trace_page_fault_exit(ret);
 
 				if (ret & VM_FAULT_ERROR) {
 					if (ret & VM_FAULT_OOM)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
