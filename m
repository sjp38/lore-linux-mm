Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 875356B0279
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 14:06:51 -0500 (EST)
Received: by pfbo64 with SMTP id o64so31311750pfb.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 11:06:51 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id u63si18784143pfa.181.2015.12.14.11.06.33
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 11:06:33 -0800 (PST)
Subject: [PATCH 31/32] x86, pkeys: execute-only support
From: Dave Hansen <dave@sr71.net>
Date: Mon, 14 Dec 2015 11:06:32 -0800
References: <20151214190542.39C4886D@viggo.jf.intel.com>
In-Reply-To: <20151214190542.39C4886D@viggo.jf.intel.com>
Message-Id: <20151214190632.6A741188@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, torvalds@linux-foundation.org, akpm@linux-foundation.org, keescook@google.com, luto@amacapital.net, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

Protection keys provide new page-based protection in hardware.
But, they have an interesting attribute: they only affect data
accesses and never affect instruction fetches.  That means that
if we set up some memory which is set as "access-disabled" via
protection keys, we can still execute from it.

This patch uses protection keys to set up mappings to do just that.
If a user calls:

	mmap(..., PROT_EXEC);
or
	mprotect(ptr, sz, PROT_EXEC);

(note PROT_EXEC-only without PROT_READ/WRITE), the kernel will
notice this, and set a special protection key on the memory.  It
also sets the appropriate bits in the Protection Keys User Rights
(PKRU) register so that the memory becomes unreadable and
unwritable.

I haven't found any userspace that does this today.

The security provided by this approach is not comprehensive.  The
PKRU register which controls access permissions is a normal
user register writable from unprivileged userspace.  An attacker
who can execute the 'wrpkru' instruction can easily disable the
protection provided by this feature.

The protection key that is used for execute-only support is
permanently dedicated in a process.  Even if all of the
execute-only mappings go away, the key stays allocated.  This
could be fixed, but it will involve a reference count or a walk
of all of the VMAs.

Cc: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org
Cc: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
Cc: keescook@google.com
Cc: luto@amacapital.net
Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/include/asm/pkeys.h |   25 ++++++++++
 b/arch/x86/kernel/fpu/xstate.c |    2 
 b/arch/x86/mm/Makefile         |    2 
 b/arch/x86/mm/fault.c          |   13 +++++
 b/arch/x86/mm/pkeys.c          |  101 +++++++++++++++++++++++++++++++++++++++++
 b/include/linux/pkeys.h        |    3 +
 b/mm/mmap.c                    |   10 +++-
 b/mm/mprotect.c                |   10 ++--
 8 files changed, 159 insertions(+), 7 deletions(-)

diff -puN arch/x86/include/asm/pkeys.h~pkeys-79-xonly arch/x86/include/asm/pkeys.h
--- a/arch/x86/include/asm/pkeys.h~pkeys-79-xonly	2015-12-14 10:42:52.853253410 -0800
+++ b/arch/x86/include/asm/pkeys.h	2015-12-14 10:42:52.866253993 -0800
@@ -6,4 +6,29 @@
 extern int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 		unsigned long init_val);
 
+/*
+ * Try to dedicate one of the protection keys to be used as an
+ * execute-only protection key.
+ */
+#define PKEY_DEDICATED_EXECUTE_ONLY 15
+extern int __execute_only_pkey(struct mm_struct *mm);
+static inline int execute_only_pkey(struct mm_struct *mm)
+{
+	if (!boot_cpu_has(X86_FEATURE_OSPKE))
+		return 0;
+
+	return __execute_only_pkey(mm);
+}
+
+extern int __arch_override_mprotect_pkey(struct vm_area_struct *vma,
+		int prot, int pkey);
+static inline int arch_override_mprotect_pkey(struct vm_area_struct *vma,
+		int prot, int pkey)
+{
+	if (!boot_cpu_has(X86_FEATURE_OSPKE))
+		return 0;
+
+	return __arch_override_mprotect_pkey(vma, prot, pkey);
+}
+
 #endif /*_ASM_X86_PKEYS_H */
diff -puN arch/x86/kernel/fpu/xstate.c~pkeys-79-xonly arch/x86/kernel/fpu/xstate.c
--- a/arch/x86/kernel/fpu/xstate.c~pkeys-79-xonly	2015-12-14 10:42:52.855253500 -0800
+++ b/arch/x86/kernel/fpu/xstate.c	2015-12-14 10:42:52.866253993 -0800
@@ -878,8 +878,6 @@ int arch_set_user_pkey_access(struct tas
 	int pkey_shift = (pkey * PKRU_BITS_PER_PKEY);
 	u32 new_pkru_bits = 0;
 
-	if (!validate_pkey(pkey))
-		return -EINVAL;
 	/*
 	 * This check implies XSAVE support.  OSPKE only gets
 	 * set if we enable XSAVE and we enable PKU in XCR0.
diff -puN arch/x86/mm/fault.c~pkeys-79-xonly arch/x86/mm/fault.c
--- a/arch/x86/mm/fault.c~pkeys-79-xonly	2015-12-14 10:42:52.856253545 -0800
+++ b/arch/x86/mm/fault.c	2015-12-14 10:42:52.867254038 -0800
@@ -14,6 +14,8 @@
 #include <linux/prefetch.h>		/* prefetchw			*/
 #include <linux/context_tracking.h>	/* exception_enter(), ...	*/
 #include <linux/uaccess.h>		/* faulthandler_disabled()	*/
+#include <linux/pkeys.h>		/* PKEY_*			*/
+#include <uapi/asm-generic/mman-common.h>
 
 #include <asm/cpufeature.h>		/* boot_cpu_has, ...		*/
 #include <asm/traps.h>			/* dotraplinkage, ...		*/
@@ -23,6 +25,7 @@
 #include <asm/vsyscall.h>		/* emulate_vsyscall		*/
 #include <asm/vm86.h>			/* struct vm86			*/
 #include <asm/mmu_context.h>		/* vma_pkey()			*/
+#include <asm/fpu/internal.h>		/* fpregs_active()		*/
 
 #define CREATE_TRACE_POINTS
 #include <asm/trace/exceptions.h>
@@ -1108,6 +1111,16 @@ access_error(unsigned long error_code, s
 	 */
 	if (error_code & PF_PK)
 		return 1;
+
+	if (!(error_code & PF_INSTR)) {
+		/*
+		 * Assume all accesses require either read or execute
+		 * permissions.  This is not an instruction access, so
+		 * it requires read permissions.
+		 */
+		if (!(vma->vm_flags & VM_READ))
+			return 1;
+	}
 	/*
 	 * Make sure to check the VMA so that we do not perform
 	 * faults just to hit a PF_PK as soon as we fill in a
diff -puN arch/x86/mm/Makefile~pkeys-79-xonly arch/x86/mm/Makefile
--- a/arch/x86/mm/Makefile~pkeys-79-xonly	2015-12-14 10:42:52.858253634 -0800
+++ b/arch/x86/mm/Makefile	2015-12-14 10:42:52.867254038 -0800
@@ -33,3 +33,5 @@ obj-$(CONFIG_ACPI_NUMA)		+= srat.o
 obj-$(CONFIG_NUMA_EMU)		+= numa_emulation.o
 
 obj-$(CONFIG_X86_INTEL_MPX)	+= mpx.o
+obj-$(CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS) += pkeys.o
+
diff -puN /dev/null arch/x86/mm/pkeys.c
--- /dev/null	2015-12-10 15:28:13.322405854 -0800
+++ b/arch/x86/mm/pkeys.c	2015-12-14 10:42:52.867254038 -0800
@@ -0,0 +1,101 @@
+/*
+ * Intel Memory Protection Keys management
+ * Copyright (c) 2015, Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+#include <linux/mm_types.h>             /* mm_struct, vma, etc...       */
+#include <linux/pkeys.h>                /* PKEY_*                       */
+#include <uapi/asm-generic/mman-common.h>
+
+#include <asm/cpufeature.h>             /* boot_cpu_has, ...            */
+#include <asm/mmu_context.h>            /* vma_pkey()                   */
+#include <asm/fpu/internal.h>           /* fpregs_active()              */
+
+int __execute_only_pkey(struct mm_struct *mm)
+{
+	int ret;
+
+	/*
+	 * We do not want to go through the relatively costly
+	 * dance to set PKRU if we do not need to.  Check it
+	 * first and assume that if the execute-only pkey is
+	 * write-disabled that we do not have to set it
+	 * ourselves.  We need preempt off so that nobody
+	 * can make fpregs inactive.
+	 */
+	preempt_disable();
+	if (fpregs_active() &&
+	    !__pkru_allows_read(read_pkru(), PKEY_DEDICATED_EXECUTE_ONLY)) {
+		preempt_enable();
+		return PKEY_DEDICATED_EXECUTE_ONLY;
+	}
+	preempt_enable();
+	ret = arch_set_user_pkey_access(current, PKEY_DEDICATED_EXECUTE_ONLY,
+			PKEY_DISABLE_ACCESS);
+	/*
+	 * If the PKRU-set operation failed somehow, just return
+	 * 0 and effectively disable execute-only support.
+	 */
+	if (ret)
+		return 0;
+
+	return PKEY_DEDICATED_EXECUTE_ONLY;
+}
+
+static inline bool vma_is_pkey_exec_only(struct vm_area_struct *vma)
+{
+	/* Do this check first since the vm_flags should be hot */
+	if ((vma->vm_flags & (VM_READ | VM_WRITE | VM_EXEC)) != VM_EXEC)
+		return false;
+	if (vma_pkey(vma) != PKEY_DEDICATED_EXECUTE_ONLY)
+		return false;
+
+	return true;
+}
+
+/*
+ * This is only called for *plain* mprotect calls.
+ */
+int __arch_override_mprotect_pkey(struct vm_area_struct *vma, int prot, int pkey)
+{
+	/*
+	 * Is this an mprotect_pkey() call?  If so, never
+	 * override the value that came from the user.
+	 */
+	if (pkey != -1)
+		return pkey;
+	/*
+	 * Look for a protection-key-drive execute-only mapping
+	 * which is now being given permissions that are not
+	 * execute-only.  Move it back to the default pkey.
+	 */
+	if (vma_is_pkey_exec_only(vma) &&
+	    (prot & (PROT_READ|PROT_WRITE))) {
+		return 0;
+	}
+	/*
+	 * The mapping is execute-only.  Go try to get the
+	 * execute-only protection key.  If we fail to do that,
+	 * fall through as if we do not have execute-only
+	 * support.
+	 */
+	if (prot == PROT_EXEC) {
+		pkey = execute_only_pkey(vma->vm_mm);
+		if (pkey > 0)
+			return pkey;
+	}
+	/*
+	 * This is a vanilla, non-pkey mprotect (or we failed to
+	 * setup execute-only), inherit the pkey from the VMA we
+	 * are working on.
+	 */
+	return vma_pkey(vma);
+}
diff -puN include/linux/pkeys.h~pkeys-79-xonly include/linux/pkeys.h
--- a/include/linux/pkeys.h~pkeys-79-xonly	2015-12-14 10:42:52.859253679 -0800
+++ b/include/linux/pkeys.h	2015-12-14 10:42:52.868254082 -0800
@@ -13,6 +13,9 @@
 #include <asm/pkeys.h>
 #else /* ! CONFIG_ARCH_HAS_PKEYS */
 #define arch_max_pkey() (1)
+#define execute_only_pkey(mm) (0)
+#define arch_override_mprotect_pkey(vma, prot, pkey) (0)
+#define PKEY_DEDICATED_EXECUTE_ONLY 0
 #endif /* ! CONFIG_ARCH_HAS_PKEYS */
 
 /*
diff -puN mm/mmap.c~pkeys-79-xonly mm/mmap.c
--- a/mm/mmap.c~pkeys-79-xonly	2015-12-14 10:42:52.861253769 -0800
+++ b/mm/mmap.c	2015-12-14 10:42:52.869254127 -0800
@@ -42,6 +42,7 @@
 #include <linux/memory.h>
 #include <linux/printk.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/pkeys.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -1266,6 +1267,7 @@ unsigned long do_mmap(struct file *file,
 			unsigned long pgoff, unsigned long *populate)
 {
 	struct mm_struct *mm = current->mm;
+	int pkey = 0;
 
 	*populate = 0;
 
@@ -1305,11 +1307,17 @@ unsigned long do_mmap(struct file *file,
 	if (offset_in_page(addr))
 		return addr;
 
+	if (prot == PROT_EXEC) {
+		pkey = execute_only_pkey(mm);
+		if (pkey < 0)
+			pkey = 0;
+	}
+
 	/* Do simple checking here so the lower-level routines won't have
 	 * to. we assume access permissions have been handled by the open
 	 * of the memory object, so we don't do any here.
 	 */
-	vm_flags |= calc_vm_prot_bits(prot, 0) | calc_vm_flag_bits(flags) |
+	vm_flags |= calc_vm_prot_bits(prot, pkey) | calc_vm_flag_bits(flags) |
 			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 
 	if (flags & MAP_LOCKED)
diff -puN mm/mprotect.c~pkeys-79-xonly mm/mprotect.c
--- a/mm/mprotect.c~pkeys-79-xonly	2015-12-14 10:42:52.863253858 -0800
+++ b/mm/mprotect.c	2015-12-14 10:42:52.869254127 -0800
@@ -24,6 +24,7 @@
 #include <linux/migrate.h>
 #include <linux/perf_event.h>
 #include <linux/ksm.h>
+#include <linux/pkeys.h>
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
@@ -347,10 +348,11 @@ fail:
 SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot)
 {
-	unsigned long vm_flags, nstart, end, tmp, reqprot;
+	unsigned long nstart, end, tmp, reqprot;
 	struct vm_area_struct *vma, *prev;
 	int error = -EINVAL;
 	const int grows = prot & (PROT_GROWSDOWN|PROT_GROWSUP);
+
 	prot &= ~(PROT_GROWSDOWN|PROT_GROWSUP);
 	if (grows == (PROT_GROWSDOWN|PROT_GROWSUP)) /* can't be both */
 		return -EINVAL;
@@ -373,14 +375,13 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
 	if ((prot & PROT_READ) && (current->personality & READ_IMPLIES_EXEC))
 		prot |= PROT_EXEC;
 
-	vm_flags = calc_vm_prot_bits(prot, 0);
-
 	down_write(&current->mm->mmap_sem);
 
 	vma = find_vma(current->mm, start);
 	error = -ENOMEM;
 	if (!vma)
 		goto out;
+
 	prev = vma->vm_prev;
 	if (unlikely(grows & PROT_GROWSDOWN)) {
 		if (vma->vm_start >= end)
@@ -404,10 +405,11 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
 
 	for (nstart = start ; ; ) {
 		unsigned long newflags;
+		int pkey = arch_override_mprotect_pkey(vma, prot, -1);
 
 		/* Here we know that vma->vm_start <= nstart < vma->vm_end. */
 
-		newflags = vm_flags;
+		newflags = calc_vm_prot_bits(prot, pkey);
 		newflags |= (vma->vm_flags & ~(VM_READ | VM_WRITE | VM_EXEC));
 
 		/* newflags >> 4 shift VM_MAY% in place of VM_% */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
