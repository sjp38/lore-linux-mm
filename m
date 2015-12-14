Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id E6A516B0262
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 14:06:09 -0500 (EST)
Received: by pfbu66 with SMTP id u66so65613718pfb.3
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 11:06:09 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id q75si18765369pfa.105.2015.12.14.11.06.06
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 11:06:07 -0800 (PST)
Subject: [PATCH 13/32] x86, pkeys: fill in pkey field in siginfo
From: Dave Hansen <dave@sr71.net>
Date: Mon, 14 Dec 2015 11:06:06 -0800
References: <20151214190542.39C4886D@viggo.jf.intel.com>
In-Reply-To: <20151214190542.39C4886D@viggo.jf.intel.com>
Message-Id: <20151214190606.B56F50F7@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

This fills in the new siginfo field: si_pkey to indicate to
userspace which protection key was set on the PTE that we faulted
on.

Note though that *ALL* protection key faults have to be generated
by a valid, present PTE at some point.  But this code does no PTE
lookups which seeds odd.  The reason is that we take advantage of
the way we generate PTEs from VMAs.  All PTEs under a VMA share
some attributes.  For instance, they are _all_ either PROT_READ
*OR* PROT_NONE.  They also always share a protection key, so we
never have to walk the page tables; we just use the VMA.

Note that _pkey is a 64-bit value.  The current hardware only
supports 4-bit protection keys.  We do this because there is
_plenty_ of space in _sigfault and it is possible that future
processors would support more than 4 bits of protection keys.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/arch/x86/include/asm/pgtable_types.h |    5 ++
 b/arch/x86/mm/fault.c                  |   64 ++++++++++++++++++++++++++++++++-
 2 files changed, 68 insertions(+), 1 deletion(-)

diff -puN arch/x86/include/asm/pgtable_types.h~pkeys-09-siginfo-x86 arch/x86/include/asm/pgtable_types.h
--- a/arch/x86/include/asm/pgtable_types.h~pkeys-09-siginfo-x86	2015-12-14 10:42:44.428875878 -0800
+++ b/arch/x86/include/asm/pgtable_types.h	2015-12-14 10:42:44.432876057 -0800
@@ -64,6 +64,11 @@
 #endif
 #define __HAVE_ARCH_PTE_SPECIAL
 
+#define _PAGE_PKEY_MASK (_PAGE_PKEY_BIT0 | \
+			 _PAGE_PKEY_BIT1 | \
+			 _PAGE_PKEY_BIT2 | \
+			 _PAGE_PKEY_BIT3)
+
 #ifdef CONFIG_KMEMCHECK
 #define _PAGE_HIDDEN	(_AT(pteval_t, 1) << _PAGE_BIT_HIDDEN)
 #else
diff -puN arch/x86/mm/fault.c~pkeys-09-siginfo-x86 arch/x86/mm/fault.c
--- a/arch/x86/mm/fault.c~pkeys-09-siginfo-x86	2015-12-14 10:42:44.429875923 -0800
+++ b/arch/x86/mm/fault.c	2015-12-14 10:42:44.433876102 -0800
@@ -15,12 +15,14 @@
 #include <linux/context_tracking.h>	/* exception_enter(), ...	*/
 #include <linux/uaccess.h>		/* faulthandler_disabled()	*/
 
+#include <asm/cpufeature.h>		/* boot_cpu_has, ...		*/
 #include <asm/traps.h>			/* dotraplinkage, ...		*/
 #include <asm/pgalloc.h>		/* pgd_*(), ...			*/
 #include <asm/kmemcheck.h>		/* kmemcheck_*(), ...		*/
 #include <asm/fixmap.h>			/* VSYSCALL_ADDR		*/
 #include <asm/vsyscall.h>		/* emulate_vsyscall		*/
 #include <asm/vm86.h>			/* struct vm86			*/
+#include <asm/mmu_context.h>		/* vma_pkey()			*/
 
 #define CREATE_TRACE_POINTS
 #include <asm/trace/exceptions.h>
@@ -169,6 +171,56 @@ is_prefetch(struct pt_regs *regs, unsign
 	return prefetch;
 }
 
+/*
+ * A protection key fault means that the PKRU value did not allow
+ * access to some PTE.  Userspace can figure out what PKRU was
+ * from the XSAVE state, and this function fills out a field in
+ * siginfo so userspace can discover which protection key was set
+ * on the PTE.
+ *
+ * If we get here, we know that the hardware signaled a PF_PK
+ * fault and that there was a VMA once we got in the fault
+ * handler.  It does *not* guarantee that the VMA we find here
+ * was the one that we faulted on.
+ *
+ * 1. T1   : mprotect_key(foo, PAGE_SIZE, pkey=4);
+ * 2. T1   : set PKRU to deny access to pkey=4, touches page
+ * 3. T1   : faults...
+ * 4.    T2: mprotect_key(foo, PAGE_SIZE, pkey=5);
+ * 5. T1   : enters fault handler, takes mmap_sem, etc...
+ * 6. T1   : reaches here, sees vma_pkey(vma)=5, when we really
+ *	     faulted on a pte with its pkey=4.
+ */
+static void fill_sig_info_pkey(int si_code, siginfo_t *info,
+		struct vm_area_struct *vma)
+{
+	/* This is effectively an #ifdef */
+	if (!boot_cpu_has(X86_FEATURE_OSPKE))
+		return;
+
+	/* Fault not from Protection Keys: nothing to do */
+	if (si_code != SEGV_PKUERR)
+		return;
+	/*
+	 * force_sig_info_fault() is called from a number of
+	 * contexts, some of which have a VMA and some of which
+	 * do not.  The PF_PK handing happens after we have a
+	 * valid VMA, so we should never reach this without a
+	 * valid VMA.
+	 */
+	if (!vma) {
+		WARN_ONCE(1, "PKU fault with no VMA passed in");
+		info->si_pkey = 0;
+		return;
+	}
+	/*
+	 * si_pkey should be thought of as a strong hint, but not
+	 * absolutely guranteed to be 100% accurate because of
+	 * the race explained above.
+	 */
+	info->si_pkey = vma_pkey(vma);
+}
+
 static void
 force_sig_info_fault(int si_signo, int si_code, unsigned long address,
 		     struct task_struct *tsk, struct vm_area_struct *vma,
@@ -187,6 +239,8 @@ force_sig_info_fault(int si_signo, int s
 		lsb = PAGE_SHIFT;
 	info.si_addr_lsb = lsb;
 
+	fill_sig_info_pkey(si_code, &info, vma);
+
 	force_sig_info(si_signo, &info, tsk);
 }
 
@@ -847,7 +901,15 @@ static noinline void
 bad_area_access_error(struct pt_regs *regs, unsigned long error_code,
 		      unsigned long address, struct vm_area_struct *vma)
 {
-	__bad_area(regs, error_code, address, vma, SEGV_ACCERR);
+	/*
+	 * This OSPKE check is not strictly necessary at runtime.
+	 * But, doing it this way allows compiler optimizations
+	 * if pkeys are compiled out.
+	 */
+	if (boot_cpu_has(X86_FEATURE_OSPKE) && (error_code & PF_PK))
+		__bad_area(regs, error_code, address, vma, SEGV_PKUERR);
+	else
+		__bad_area(regs, error_code, address, vma, SEGV_ACCERR);
 }
 
 static void
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
