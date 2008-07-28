Date: Mon, 28 Jul 2008 18:34:07 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [rfc][patch 1/3] mm: vmap rewrite
Message-ID: <20080728233407.GB10501@sgi.com>
References: <20080728123438.GA13926@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080728123438.GA13926@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, xfs@oss.sgi.com, xen-devel@lists.xensource.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, dri-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

> After:
>  78406 total                                      0.0081
>  40053 default_idle                              89.4040
>  33576 ia64_spinlock_contention                 349.7500 
>   1650 _spin_lock                                17.1875

Here is a patch that will unroll those two sample and let you see which
function is hitting the contention.  This has been submitted and
rejected at least once a few years ago.  I keep and old copy around
because it is often very handy.

I have not tested it in a couple years (usually working on performance with
a SLES kernel).  It applied with a couple minor fixups so I assume it
works.  If not, please let me know.



Index: ia64_spinlock_contention/arch/ia64/kernel/head.S
===================================================================
--- ia64_spinlock_contention.orig/arch/ia64/kernel/head.S	2008-07-28 17:35:21.000000000 -0500
+++ ia64_spinlock_contention/arch/ia64/kernel/head.S	2008-07-28 17:35:51.000000000 -0500
@@ -1137,6 +1137,8 @@ GLOBAL_ENTRY(ia64_spinlock_contention_pr
 	tbit.nz p15,p0=r27,IA64_PSR_I_BIT
 	.restore sp		// pop existing prologue after next insn
 	mov b6 = r28
+	.global ia64_spinlock_contention_pre3_4_beg	// for kernprof
+ia64_spinlock_contention_pre3_4_beg:
 	.prologue
 	.save ar.pfs, r0
 	.altrp b6
@@ -1185,6 +1187,8 @@ GLOBAL_ENTRY(ia64_spinlock_contention)
 (p14)	br.cond.sptk.few .wait
 
 	br.ret.sptk.many b6	// lock is now taken
+	.global ia64_spinlock_contention_end	// for determining if we are in ia64_spinlock_contention code.
+ia64_spinlock_contention_end:
 END(ia64_spinlock_contention)
 
 #endif
Index: ia64_spinlock_contention/arch/ia64/kernel/ia64_ksyms.c
===================================================================
--- ia64_spinlock_contention.orig/arch/ia64/kernel/ia64_ksyms.c	2008-07-28 17:35:21.000000000 -0500
+++ ia64_spinlock_contention/arch/ia64/kernel/ia64_ksyms.c	2008-07-28 17:35:51.000000000 -0500
@@ -95,6 +95,10 @@ EXPORT_SYMBOL(unw_init_running);
  */
 extern char ia64_spinlock_contention_pre3_4;
 EXPORT_SYMBOL(ia64_spinlock_contention_pre3_4);
+extern char ia64_spinlock_contention_pre3_4_beg;
+EXPORT_SYMBOL(ia64_spinlock_contention_pre3_4_beg);
+extern char ia64_spinlock_contention_pre3_4_end;
+EXPORT_SYMBOL(ia64_spinlock_contention_pre3_4_end);
 #  else
 /*
  * This is not a normal routine and we don't want a function descriptor for it, so we use
@@ -102,6 +106,8 @@ EXPORT_SYMBOL(ia64_spinlock_contention_p
  */
 extern char ia64_spinlock_contention;
 EXPORT_SYMBOL(ia64_spinlock_contention);
+extern char ia64_spinlock_contention_end;
+EXPORT_SYMBOL(ia64_spinlock_contention_end);
 #  endif
 # endif
 #endif
Index: ia64_spinlock_contention/arch/ia64/kernel/perfmon_default_smpl.c
===================================================================
--- ia64_spinlock_contention.orig/arch/ia64/kernel/perfmon_default_smpl.c	2008-07-28 17:35:21.000000000 -0500
+++ ia64_spinlock_contention/arch/ia64/kernel/perfmon_default_smpl.c	2008-07-28 18:18:56.000000000 -0500
@@ -11,6 +11,7 @@
 #include <linux/init.h>
 #include <asm/delay.h>
 #include <linux/smp.h>
+#include <linux/spinlock.h>
 
 #include <asm/perfmon.h>
 #include <asm/perfmon_default_smpl.h>
@@ -98,6 +99,16 @@ default_init(struct task_struct *task, v
 	return 0;
 }
 
+#ifdef CONFIG_SMP
+#if __GNUC__ < 3 || (__GNUC__ == 3 && __GNUC_MINOR__ < 3)
+extern char ia64_spinlock_contention_pre3_4_beg[], ia64_spinlock_contention_pre3_4_end[];
+#define ia64_spinlock_contention		ia64_spinlock_contention_pre3_4_beg
+#define ia64_spinlock_contention_end		ia64_spinlock_contention_pre3_4_end
+#else
+extern char ia64_spinlock_contention[], ia64_spinlock_contention_end[];
+#endif
+#endif
+
 static int
 default_handler(struct task_struct *task, void *buf, pfm_ovfl_arg_t *arg, struct pt_regs *regs, unsigned long stamp)
 {
@@ -164,6 +175,14 @@ default_handler(struct task_struct *task
 	 * where did the fault happen (includes slot number)
 	 */
 	ent->ip = regs->cr_iip | ((regs->cr_ipsr >> 41) & 0x3);
+#ifdef CONFIG_SMP
+	/* Fix up the ip for code in the spinlock contention path. */
+	if ((ent->ip >= (unsigned long)ia64_spinlock_contention) &&
+	    (ent->ip < (unsigned long)ia64_spinlock_contention_end))
+		ent->ip = regs->b6;
+#endif
+	if (in_lock_functions(ent->ip))
+		ent->ip = regs->r28;
 
 	ent->tstamp    = stamp;
 	ent->cpu       = smp_processor_id();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
