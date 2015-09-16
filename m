Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7191E6B0254
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 13:49:10 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so215286025pad.1
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:49:10 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id e5si15347140pas.193.2015.09.16.10.49.07
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 10:49:07 -0700 (PDT)
Subject: [PATCH 10/26] x86, pkeys: notify userspace about protection key faults
From: Dave Hansen <dave@sr71.net>
Date: Wed, 16 Sep 2015 10:49:06 -0700
References: <20150916174903.E112E464@viggo.jf.intel.com>
In-Reply-To: <20150916174903.E112E464@viggo.jf.intel.com>
Message-Id: <20150916174906.51062FBC@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


A protection key fault is very similar to any other access
error.  There must be a VMA, etc...  We even want to take
the same action (SIGSEGV) that we do with a normal access
fault.

However, we do need to let userspace know that something
is different.  We do this the same way what we did with
SEGV_BNDERR with Memory Protection eXtensions (MPX):
define a new SEGV code: SEGV_PKUERR.

We also add a siginfo field: si_pkey that reveals to
userspace which protection key was set on the PTE that
we faulted on.  There is no other easy way for
userspace to figure this out.  They could parse smaps
but that would be a bit cruel.

---

 b/arch/x86/include/asm/mmu_context.h   |   15 ++++++++++
 b/arch/x86/include/asm/pgtable.h       |   10 ++++++
 b/arch/x86/include/asm/pgtable_types.h |    5 +++
 b/arch/x86/mm/fault.c                  |   49 ++++++++++++++++++++++++++++++++-
 b/include/linux/mm.h                   |    2 +
 b/include/uapi/asm-generic/siginfo.h   |   11 ++++++-
 b/mm/memory.c                          |    4 +-
 7 files changed, 92 insertions(+), 4 deletions(-)

diff -puN arch/x86/include/asm/mmu_context.h~pkeys-09-siginfo arch/x86/include/asm/mmu_context.h
--- a/arch/x86/include/asm/mmu_context.h~pkeys-09-siginfo	2015-09-16 10:48:15.575161451 -0700
+++ b/arch/x86/include/asm/mmu_context.h	2015-09-16 10:48:15.589162086 -0700
@@ -243,4 +243,19 @@ static inline void arch_unmap(struct mm_
 		mpx_notify_unmap(mm, vma, start, end);
 }
 
+static inline u16 vma_pkey(struct vm_area_struct *vma)
+{
+	u16 pkey = 0;
+#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+	unsigned long f = vma->vm_flags;
+	pkey |= (!!(f & VM_HIGH_ARCH_0)) << 0;
+	pkey |= (!!(f & VM_HIGH_ARCH_1)) << 1;
+	pkey |= (!!(f & VM_HIGH_ARCH_2)) << 2;
+	pkey |= (!!(f & VM_HIGH_ARCH_3)) << 3;
+#endif
+
+	return pkey;
+}
+
+
 #endif /* _ASM_X86_MMU_CONTEXT_H */
diff -puN arch/x86/include/asm/pgtable.h~pkeys-09-siginfo arch/x86/include/asm/pgtable.h
--- a/arch/x86/include/asm/pgtable.h~pkeys-09-siginfo	2015-09-16 10:48:15.577161542 -0700
+++ b/arch/x86/include/asm/pgtable.h	2015-09-16 10:48:15.590162131 -0700
@@ -881,6 +881,16 @@ static inline pte_t pte_swp_clear_soft_d
 }
 #endif
 
+static inline u32 pte_pkey(pte_t pte)
+{
+#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+	/* ifdef to avoid doing 59-bit shift on 32-bit values */
+	return (pte_flags(pte) & _PAGE_PKEY_MASK) >> _PAGE_BIT_PKEY_BIT0;
+#else
+	return 0;
+#endif
+}
+
 #include <asm-generic/pgtable.h>
 #endif	/* __ASSEMBLY__ */
 
diff -puN arch/x86/include/asm/pgtable_types.h~pkeys-09-siginfo arch/x86/include/asm/pgtable_types.h
--- a/arch/x86/include/asm/pgtable_types.h~pkeys-09-siginfo	2015-09-16 10:48:15.579161632 -0700
+++ b/arch/x86/include/asm/pgtable_types.h	2015-09-16 10:48:15.590162131 -0700
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
--- a/arch/x86/mm/fault.c~pkeys-09-siginfo	2015-09-16 10:48:15.580161678 -0700
+++ b/arch/x86/mm/fault.c	2015-09-16 10:48:15.591162177 -0700
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
@@ -169,6 +171,45 @@ is_prefetch(struct pt_regs *regs, unsign
 	return prefetch;
 }
 
+static u16 fetch_pkey(unsigned long address, struct task_struct *tsk)
+{
+	u16 ret;
+	spinlock_t *ptl;
+	pte_t *ptep;
+	pte_t pte;
+	int follow_ret;
+
+	if (!boot_cpu_has(X86_FEATURE_OSPKE))
+		return 0;
+
+	follow_ret = follow_pte(tsk->mm, address, &ptep, &ptl);
+	if (!follow_ret) {
+		/*
+		 * On a successful follow, make sure to
+		 * drop the lock.
+		 */
+		pte = *ptep;
+		pte_unmap_unlock(ptep, ptl);
+		ret = pte_pkey(pte);
+	} else {
+		/*
+		 * There is no PTE.  Go looking for the pkey in
+		 * the VMA.  If we did not find a pkey violation
+		 * from either the PTE or the VMA, then it must
+		 * have been a fault from the hardware.  Perhaps
+		 * the PTE got zapped before we got in here.
+		 */
+		struct vm_area_struct *vma = find_vma(tsk->mm, address);
+		if (vma) {
+			ret = vma_pkey(vma);
+		} else {
+			WARN_ONCE(1, "no PTE or VMA @ %lx\n", address);
+			ret = 0;
+		}
+	}
+	return ret;
+}
+
 static void
 force_sig_info_fault(int si_signo, int si_code, unsigned long address,
 		     struct task_struct *tsk, int fault)
@@ -186,6 +227,9 @@ force_sig_info_fault(int si_signo, int s
 		lsb = PAGE_SHIFT;
 	info.si_addr_lsb = lsb;
 
+	if (boot_cpu_has(X86_FEATURE_OSPKE) && si_code == SEGV_PKUERR)
+		info.si_pkey = fetch_pkey(address, tsk);
+
 	force_sig_info(si_signo, &info, tsk);
 }
 
@@ -842,7 +886,10 @@ static noinline void
 bad_area_access_error(struct pt_regs *regs, unsigned long error_code,
 		      unsigned long address)
 {
-	__bad_area(regs, error_code, address, SEGV_ACCERR);
+	if (boot_cpu_has(X86_FEATURE_OSPKE) && (error_code & PF_PK))
+		__bad_area(regs, error_code, address, SEGV_PKUERR);
+	else
+		__bad_area(regs, error_code, address, SEGV_ACCERR);
 }
 
 static void
diff -puN include/linux/mm.h~pkeys-09-siginfo include/linux/mm.h
--- a/include/linux/mm.h~pkeys-09-siginfo	2015-09-16 10:48:15.582161768 -0700
+++ b/include/linux/mm.h	2015-09-16 10:48:15.591162177 -0700
@@ -1160,6 +1160,8 @@ void unmap_mapping_range(struct address_
 		loff_t const holebegin, loff_t const holelen, int even_cows);
 int follow_pfn(struct vm_area_struct *vma, unsigned long address,
 	unsigned long *pfn);
+int follow_pte(struct mm_struct *mm, unsigned long address,
+	pte_t **ptepp, spinlock_t **ptlp);
 int follow_phys(struct vm_area_struct *vma, unsigned long address,
 		unsigned int flags, unsigned long *prot, resource_size_t *phys);
 int generic_access_phys(struct vm_area_struct *vma, unsigned long addr,
diff -puN include/uapi/asm-generic/siginfo.h~pkeys-09-siginfo include/uapi/asm-generic/siginfo.h
--- a/include/uapi/asm-generic/siginfo.h~pkeys-09-siginfo	2015-09-16 10:48:15.584161859 -0700
+++ b/include/uapi/asm-generic/siginfo.h	2015-09-16 10:48:15.592162222 -0700
@@ -95,6 +95,13 @@ typedef struct siginfo {
 				void __user *_lower;
 				void __user *_upper;
 			} _addr_bnd;
+			int _pkey; /* FIXME: protection key value??
+				    * Do we really need this in here?
+				    * userspace can get the PKRU value in
+				    * the signal handler, but they do not
+				    * easily have access to the PKEY value
+				    * from the PTE.
+				    */
 		} _sigfault;
 
 		/* SIGPOLL */
@@ -137,6 +144,7 @@ typedef struct siginfo {
 #define si_addr_lsb	_sifields._sigfault._addr_lsb
 #define si_lower	_sifields._sigfault._addr_bnd._lower
 #define si_upper	_sifields._sigfault._addr_bnd._upper
+#define si_pkey		_sifields._sigfault._pkey
 #define si_band		_sifields._sigpoll._band
 #define si_fd		_sifields._sigpoll._fd
 #ifdef __ARCH_SIGSYS
@@ -206,7 +214,8 @@ typedef struct siginfo {
 #define SEGV_MAPERR	(__SI_FAULT|1)	/* address not mapped to object */
 #define SEGV_ACCERR	(__SI_FAULT|2)	/* invalid permissions for mapped object */
 #define SEGV_BNDERR	(__SI_FAULT|3)  /* failed address bound checks */
-#define NSIGSEGV	3
+#define SEGV_PKUERR	(__SI_FAULT|4)  /* failed address bound checks */
+#define NSIGSEGV	4
 
 /*
  * SIGBUS si_codes
diff -puN mm/memory.c~pkeys-09-siginfo mm/memory.c
--- a/mm/memory.c~pkeys-09-siginfo	2015-09-16 10:48:15.585161904 -0700
+++ b/mm/memory.c	2015-09-16 10:48:15.593162267 -0700
@@ -3548,8 +3548,8 @@ out:
 	return -EINVAL;
 }
 
-static inline int follow_pte(struct mm_struct *mm, unsigned long address,
-			     pte_t **ptepp, spinlock_t **ptlp)
+int follow_pte(struct mm_struct *mm, unsigned long address,
+		     pte_t **ptepp, spinlock_t **ptlp)
 {
 	int res;
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
