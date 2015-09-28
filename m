Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id D450B6B0265
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 15:18:35 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so182139958pad.1
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 12:18:35 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id pg2si30752755pbb.36.2015.09.28.12.18.23
        for <linux-mm@kvack.org>;
        Mon, 28 Sep 2015 12:18:23 -0700 (PDT)
Subject: [PATCH 11/25] x86, pkeys: notify userspace about protection key faults
From: Dave Hansen <dave@sr71.net>
Date: Mon, 28 Sep 2015 12:18:22 -0700
References: <20150928191817.035A64E2@viggo.jf.intel.com>
In-Reply-To: <20150928191817.035A64E2@viggo.jf.intel.com>
Message-Id: <20150928191822.3F1C7D2F@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

A protection key fault is very similar to any other access error.
There must be a VMA, etc...  We even want to take the same action
(SIGSEGV) that we do with a normal access fault.

However, we do need to let userspace know that something is
different.  We do this the same way what we did with SEGV_BNDERR
with Memory Protection eXtensions (MPX): define a new SEGV code:
SEGV_PKUERR.

We also add a siginfo field: si_pkey that reveals to userspace
which protection key was set on the PTE that we faulted on.
There is no other easy way for userspace to figure this out.
They could parse smaps but that would be a bit cruel.

Note though that *ALL* protection key faults have to be generated
by a valid, present PTE at some point.  But this code does no PTE
lookups which seeds odd.  The reason is that we take advantage of
the way we generate PTEs from VMAs.  All PTEs under a VMA share
some attributes.  For instance, they are _all_ either PROT_READ
*OR* PROT_NONE.  They also always share a protection key, so we
never have to walk the page tables; we just use the VMA.

We share space with in siginfo with _addr_bnd.  #BR faults from
MPX are completely separate from page faults (#PF) that trigger
from protection key violations, so we never need both at the same
time.

Note that _pkey is a 64-bit value.  The current hardware only
supports 4-bit protection keys.  We do this because there is
_plenty_ of space in _sigfault and it is possible that future
processors would support more than 4 bits of protection keys.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/include/asm/pgtable_types.h |    5 ++
 b/arch/x86/mm/fault.c                  |   59 ++++++++++++++++++++++++++++++++-
 b/include/uapi/asm-generic/siginfo.h   |   17 ++++++---
 b/kernel/signal.c                      |    4 ++
 4 files changed, 79 insertions(+), 6 deletions(-)

diff -puN arch/x86/include/asm/pgtable_types.h~pkeys-09-siginfo arch/x86/include/asm/pgtable_types.h
--- a/arch/x86/include/asm/pgtable_types.h~pkeys-09-siginfo	2015-09-28 11:39:45.859178812 -0700
+++ b/arch/x86/include/asm/pgtable_types.h	2015-09-28 11:39:45.868179221 -0700
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
diff -puN arch/x86/mm/fault.c~pkeys-09-siginfo arch/x86/mm/fault.c
--- a/arch/x86/mm/fault.c~pkeys-09-siginfo	2015-09-28 11:39:45.861178903 -0700
+++ b/arch/x86/mm/fault.c	2015-09-28 11:39:45.868179221 -0700
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
 
@@ -847,7 +901,10 @@ static noinline void
 bad_area_access_error(struct pt_regs *regs, unsigned long error_code,
 		      unsigned long address, struct vm_area_struct *vma)
 {
-	__bad_area(regs, error_code, address, vma, SEGV_ACCERR);
+	if (boot_cpu_has(X86_FEATURE_OSPKE) && (error_code & PF_PK))
+		__bad_area(regs, error_code, address, vma, SEGV_PKUERR);
+	else
+		__bad_area(regs, error_code, address, vma, SEGV_ACCERR);
 }
 
 static void
diff -puN include/uapi/asm-generic/siginfo.h~pkeys-09-siginfo include/uapi/asm-generic/siginfo.h
--- a/include/uapi/asm-generic/siginfo.h~pkeys-09-siginfo	2015-09-28 11:39:45.863178994 -0700
+++ b/include/uapi/asm-generic/siginfo.h	2015-09-28 11:39:45.869179266 -0700
@@ -91,10 +91,15 @@ typedef struct siginfo {
 			int _trapno;	/* TRAP # which caused the signal */
 #endif
 			short _addr_lsb; /* LSB of the reported address */
-			struct {
-				void __user *_lower;
-				void __user *_upper;
-			} _addr_bnd;
+			union {
+				/* used when si_code=SEGV_BNDERR */
+				struct {
+					void __user *_lower;
+					void __user *_upper;
+				} _addr_bnd;
+				/* used when si_code=SEGV_PKUERR */
+				u64 _pkey;
+			};
 		} _sigfault;
 
 		/* SIGPOLL */
@@ -137,6 +142,7 @@ typedef struct siginfo {
 #define si_addr_lsb	_sifields._sigfault._addr_lsb
 #define si_lower	_sifields._sigfault._addr_bnd._lower
 #define si_upper	_sifields._sigfault._addr_bnd._upper
+#define si_pkey		_sifields._sigfault._pkey
 #define si_band		_sifields._sigpoll._band
 #define si_fd		_sifields._sigpoll._fd
 #ifdef __ARCH_SIGSYS
@@ -206,7 +212,8 @@ typedef struct siginfo {
 #define SEGV_MAPERR	(__SI_FAULT|1)	/* address not mapped to object */
 #define SEGV_ACCERR	(__SI_FAULT|2)	/* invalid permissions for mapped object */
 #define SEGV_BNDERR	(__SI_FAULT|3)  /* failed address bound checks */
-#define NSIGSEGV	3
+#define SEGV_PKUERR	(__SI_FAULT|4)  /* failed protection key checks */
+#define NSIGSEGV	4
 
 /*
  * SIGBUS si_codes
diff -puN kernel/signal.c~pkeys-09-siginfo kernel/signal.c
--- a/kernel/signal.c~pkeys-09-siginfo	2015-09-28 11:39:45.864179039 -0700
+++ b/kernel/signal.c	2015-09-28 11:39:45.870179312 -0700
@@ -2758,6 +2758,10 @@ int copy_siginfo_to_user(siginfo_t __use
 			err |= __put_user(from->si_upper, &to->si_upper);
 		}
 #endif
+#ifdef SEGV_BNDERR
+		if (from->si_signo == SIGSEGV && from->si_code == SEGV_PKUERR)
+			err |= __put_user(from->si_pkey, &to->si_pkey);
+#endif
 		break;
 	case __SI_CHLD:
 		err |= __put_user(from->si_pid, &to->si_pid);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
