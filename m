Date: Fri, 26 Aug 2005 15:46:14 -0700
Message-Id: <200508262246.j7QMkEoT013490@linux.jf.intel.com>
From: Rusty Lynch <rusty.lynch@intel.com>
Subject: Re:[PATCH] Only process_die notifier in ia64_do_page_fault if KPROBES is configured.
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, prasanna@in.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, anil.s.keshavamurthy@intel.com
List-ID: <linux-mm.kvack.org>

>-----Original Message-----
>From: linux-ia64-owner@vger.kernel.org [mailto:linux-ia64-
>owner@vger.kernel.org] On Behalf Of Christoph Lameter
>Sent: Thursday, August 25, 2005 1:14 PM
>To: linux-ia64@vger.kernel.org
>Cc: linux-mm@kvack.org; prasanna@in.ibm.com
>Subject: [PATCH] Only process_die notifier in ia64_do_page_fault if KPROBES is configured.
>
>ia64_do_page_fault is a path critical for system performance. 
>The code to call notify_die() should not be compiled into that critical path 
>if the system is not configured to use KPROBES.

Just to be sure everyone understands the overhead involved, kprobes only 
registers a single notifier.  If kprobes is disabled (CONFIG_KPROBES is
off) then the overhead on a page fault is the overhead to execute an empty
notifier chain.

The debate over wrapping this notification call chain by a #define has
surfaced in the past for other architectures (and also when the initial ia64
kprobe patches were submitted to the MM tree), and when the dust settled
the notifier chain was left unwrapped.

If the consensus is that executing an empty notifier chain introduces a
measurable performance hit, then I think:
* A new config option should be introduced to disable this hook and then
  let CONFIG_KPROBES depend on this new option since other kernel components
  could choose to use this hook.
* The patch should do the same for all architectures, not just ia64

    --rusty

>Signed-off-by: Christoph Lameter <clameter@sgi.com>
>
>Index: linux-2.6.13-rc7/arch/ia64/mm/fault.c
>===================================================================
>--- linux-2.6.13-rc7.orig/arch/ia64/mm/fault.c	2005-08-23
>20:39:14.000000000 -0700
>+++ linux-2.6.13-rc7/arch/ia64/mm/fault.c	2005-08-25 13:04:57.000000000 - 0700
>@@ -103,12 +103,16 @@ ia64_do_page_fault (unsigned long addres
> 		goto bad_area_no_up;
> #endif
>
>+#ifdef CONFIG_KPROBES
> 	/*
>-	 * This is to handle the kprobes on user space access instructions
>+	 * This is to handle the kprobes on user space access instructions.
>+	 * This is a path criticial for system performance. So only
>+	 * process this notifier if we are compiled with kprobes support.
> 	 */
> 	if (notify_die(DIE_PAGE_FAULT, "page fault", regs, code, TRAP_BRKPT,
> 					SIGSEGV) == NOTIFY_STOP)
> 		return;
>+#endif
>
> 	down_read(&mm->mmap_sem);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
