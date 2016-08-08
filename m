Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 310586B0261
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 19:18:32 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 63so700677216pfx.0
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 16:18:32 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id v7si38341342pal.10.2016.08.08.16.18.26
        for <linux-mm@kvack.org>;
        Mon, 08 Aug 2016 16:18:26 -0700 (PDT)
Subject: [PATCH 04/10] x86, pkeys: allocation/free syscalls
From: Dave Hansen <dave@sr71.net>
Date: Mon, 08 Aug 2016 16:18:25 -0700
References: <20160808231820.F7A9C4D8@viggo.jf.intel.com>
In-Reply-To: <20160808231820.F7A9C4D8@viggo.jf.intel.com>
Message-Id: <20160808231825.7731354F@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, luto@kernel.org, mgorman@techsingularity.net, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, arnd@arndb.de


From: Dave Hansen <dave.hansen@linux.intel.com>

This patch adds two new system calls:

	int pkey_alloc(unsigned long flags, unsigned long init_access_rights)
	int pkey_free(int pkey);

These implement an "allocator" for the protection keys
themselves, which can be thought of as analogous to the allocator
that the kernel has for file descriptors.  The kernel tracks
which numbers are in use, and only allows operations on keys that
are valid.  A key which was not obtained by pkey_alloc() may not,
for instance, be passed to pkey_mprotect().

These system calls are also very important given the kernel's use
of pkeys to implement execute-only support.  These help ensure
that userspace can never assume that it has control of a key
unless it first asks the kernel.  The kernel does not promise to
preserve PKRU (right register) contents except for allocated
pkeys.

The 'init_access_rights' argument to pkey_alloc() specifies the
rights that will be established for the returned pkey.  For
instance:

	pkey = pkey_alloc(flags, PKEY_DENY_WRITE);

will allocate 'pkey', but also sets the bits in PKRU[1] such that
writing to 'pkey' is already denied.

The kernel does not prevent pkey_free() from successfully freeing
in-use pkeys (those still assigned to a memory range by
pkey_mprotect()).  It would be expensive to implement the checks
for this, so we instead say, "Just don't do it" since sane
software will never do it anyway.

Any piece of userspace calling pkey_alloc() needs to be prepared
for it to fail.  Why?  pkey_alloc() returns the same error code
(ENOSPC) when there are no pkeys and when pkeys are unsupported.
They can be unsupported for a whole host of reasons, so apps must
be prepared for this.  Also, libraries or LD_PRELOADs might steal
keys before an application gets access to them.

This allocation mechanism could be implemented in userspace.
Even if we did it in userspace, we would still need additional
user/kernel interfaces to tell userspace which keys are being
used by the kernel internally (such as for execute-only
mappings).  Having the kernel provide this facility completely
removes the need for these additional interfaces, or having an
implementation of this in userspace at all.

Note that we have to make changes to all of the architectures
that do not use mman-common.h because we use the new
PKEY_DENY_ACCESS/WRITE macros in arch-independent code.

1. PKRU is the Protection Key Rights User register.  It is a
   usermode-accessible register that controls whether writes
   and/or access to each individual pkey is allowed or denied.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org
Cc: Arnd Bergmann <arnd@arndb.de>
---

 b/arch/alpha/include/uapi/asm/mman.h     |    5 ++
 b/arch/mips/include/uapi/asm/mman.h      |    5 ++
 b/arch/parisc/include/uapi/asm/mman.h    |    5 ++
 b/arch/x86/include/asm/mmu.h             |    8 +++
 b/arch/x86/include/asm/mmu_context.h     |   10 +++-
 b/arch/x86/include/asm/pkeys.h           |   73 ++++++++++++++++++++++++++++---
 b/arch/x86/kernel/fpu/xstate.c           |    5 +-
 b/arch/x86/mm/pkeys.c                    |   38 ++++++++++++----
 b/arch/xtensa/include/uapi/asm/mman.h    |    5 ++
 b/include/linux/pkeys.h                  |   28 +++++++++--
 b/include/uapi/asm-generic/mman-common.h |    5 ++
 b/mm/mprotect.c                          |   61 +++++++++++++++++++++++--
 12 files changed, 221 insertions(+), 27 deletions(-)

diff -puN arch/alpha/include/uapi/asm/mman.h~pkeys-116-syscalls-allocation arch/alpha/include/uapi/asm/mman.h
--- a/arch/alpha/include/uapi/asm/mman.h~pkeys-116-syscalls-allocation	2016-08-08 16:15:11.118055806 -0700
+++ b/arch/alpha/include/uapi/asm/mman.h	2016-08-08 16:15:11.141056851 -0700
@@ -78,4 +78,9 @@
 #define MAP_HUGE_SHIFT	26
 #define MAP_HUGE_MASK	0x3f
 
+#define PKEY_DISABLE_ACCESS	0x1
+#define PKEY_DISABLE_WRITE	0x2
+#define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
+				 PKEY_DISABLE_WRITE)
+
 #endif /* __ALPHA_MMAN_H__ */
diff -puN arch/mips/include/uapi/asm/mman.h~pkeys-116-syscalls-allocation arch/mips/include/uapi/asm/mman.h
--- a/arch/mips/include/uapi/asm/mman.h~pkeys-116-syscalls-allocation	2016-08-08 16:15:11.119055851 -0700
+++ b/arch/mips/include/uapi/asm/mman.h	2016-08-08 16:15:11.142056897 -0700
@@ -105,4 +105,9 @@
 #define MAP_HUGE_SHIFT	26
 #define MAP_HUGE_MASK	0x3f
 
+#define PKEY_DISABLE_ACCESS	0x1
+#define PKEY_DISABLE_WRITE	0x2
+#define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
+				 PKEY_DISABLE_WRITE)
+
 #endif /* _ASM_MMAN_H */
diff -puN arch/parisc/include/uapi/asm/mman.h~pkeys-116-syscalls-allocation arch/parisc/include/uapi/asm/mman.h
--- a/arch/parisc/include/uapi/asm/mman.h~pkeys-116-syscalls-allocation	2016-08-08 16:15:11.121055942 -0700
+++ b/arch/parisc/include/uapi/asm/mman.h	2016-08-08 16:15:11.142056897 -0700
@@ -75,4 +75,9 @@
 #define MAP_HUGE_SHIFT	26
 #define MAP_HUGE_MASK	0x3f
 
+#define PKEY_DISABLE_ACCESS	0x1
+#define PKEY_DISABLE_WRITE	0x2
+#define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
+				 PKEY_DISABLE_WRITE)
+
 #endif /* __PARISC_MMAN_H__ */
diff -puN arch/x86/include/asm/mmu_context.h~pkeys-116-syscalls-allocation arch/x86/include/asm/mmu_context.h
--- a/arch/x86/include/asm/mmu_context.h~pkeys-116-syscalls-allocation	2016-08-08 16:15:11.122055987 -0700
+++ b/arch/x86/include/asm/mmu_context.h	2016-08-08 16:15:11.142056897 -0700
@@ -108,7 +108,16 @@ static inline void enter_lazy_tlb(struct
 static inline int init_new_context(struct task_struct *tsk,
 				   struct mm_struct *mm)
 {
+	#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+	if (cpu_feature_enabled(X86_FEATURE_OSPKE)) {
+		/* pkey 0 is the default and always allocated */
+		mm->context.pkey_allocation_map = 0x1;
+		/* -1 means unallocated or invalid */
+		mm->context.execute_only_pkey = -1;
+	}
+	#endif
 	init_new_context_ldt(tsk, mm);
+
 	return 0;
 }
 static inline void destroy_context(struct mm_struct *mm)
@@ -263,5 +272,4 @@ static inline bool arch_pte_access_permi
 {
 	return __pkru_allows_pkey(pte_flags_pkey(pte_flags(pte)), write);
 }
-
 #endif /* _ASM_X86_MMU_CONTEXT_H */
diff -puN arch/x86/include/asm/mmu.h~pkeys-116-syscalls-allocation arch/x86/include/asm/mmu.h
--- a/arch/x86/include/asm/mmu.h~pkeys-116-syscalls-allocation	2016-08-08 16:15:11.124056078 -0700
+++ b/arch/x86/include/asm/mmu.h	2016-08-08 16:15:11.143056942 -0700
@@ -23,6 +23,14 @@ typedef struct {
 	const struct vdso_image *vdso_image;	/* vdso image in use */
 
 	atomic_t perf_rdpmc_allowed;	/* nonzero if rdpmc is allowed */
+#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+	/*
+	 * One bit per protection key says whether userspace can
+	 * use it or not.  protected by mmap_sem.
+	 */
+	u16 pkey_allocation_map;
+	s16 execute_only_pkey;
+#endif
 } mm_context_t;
 
 #ifdef CONFIG_SMP
diff -puN arch/x86/include/asm/pkeys.h~pkeys-116-syscalls-allocation arch/x86/include/asm/pkeys.h
--- a/arch/x86/include/asm/pkeys.h~pkeys-116-syscalls-allocation	2016-08-08 16:15:11.127056215 -0700
+++ b/arch/x86/include/asm/pkeys.h	2016-08-08 16:15:11.143056942 -0700
@@ -1,12 +1,7 @@
 #ifndef _ASM_X86_PKEYS_H
 #define _ASM_X86_PKEYS_H
 
-#define PKEY_DEDICATED_EXECUTE_ONLY 15
-/*
- * Consider the PKEY_DEDICATED_EXECUTE_ONLY key unavailable.
- */
-#define arch_max_pkey() (boot_cpu_has(X86_FEATURE_OSPKE) ? \
-		PKEY_DEDICATED_EXECUTE_ONLY : 1)
+#define arch_max_pkey() (boot_cpu_has(X86_FEATURE_OSPKE) ? 16 : 1)
 
 extern int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 		unsigned long init_val);
@@ -40,4 +35,70 @@ extern int __arch_set_user_pkey_access(s
 
 #define ARCH_VM_PKEY_FLAGS (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | VM_PKEY_BIT3)
 
+#define mm_pkey_allocation_map(mm)	(mm->context.pkey_allocation_map)
+#define mm_set_pkey_allocated(mm, pkey) do {		\
+	mm_pkey_allocation_map(mm) |= (1U << pkey);	\
+} while (0)
+#define mm_set_pkey_free(mm, pkey) do {			\
+	mm_pkey_allocation_map(mm) &= ~(1U << pkey);	\
+} while (0)
+
+static inline
+bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
+{
+	return mm_pkey_allocation_map(mm) & (1U << pkey);
+}
+
+/*
+ * Returns a positive, 4-bit key on success, or -1 on failure.
+ */
+static inline
+int mm_pkey_alloc(struct mm_struct *mm)
+{
+	/*
+	 * Note: this is the one and only place we make sure
+	 * that the pkey is valid as far as the hardware is
+	 * concerned.  The rest of the kernel trusts that
+	 * only good, valid pkeys come out of here.
+	 */
+	u16 all_pkeys_mask = ((1U << arch_max_pkey()) - 1);
+	int ret;
+
+	/*
+	 * Are we out of pkeys?  We must handle this specially
+	 * because ffz() behavior is undefined if there are no
+	 * zeros.
+	 */
+	if (mm_pkey_allocation_map(mm) == all_pkeys_mask)
+		return -1;
+
+	ret = ffz(mm_pkey_allocation_map(mm));
+
+	mm_set_pkey_allocated(mm, ret);
+
+	return ret;
+}
+
+static inline
+int mm_pkey_free(struct mm_struct *mm, int pkey)
+{
+	/*
+	 * pkey 0 is special, always allocated and can never
+	 * be freed.
+	 */
+	if (!pkey)
+		return -EINVAL;
+	if (!mm_pkey_is_allocated(mm, pkey))
+		return -EINVAL;
+
+	mm_set_pkey_free(mm, pkey);
+
+	return 0;
+}
+
+extern int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
+		unsigned long init_val);
+extern int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
+		unsigned long init_val);
+
 #endif /*_ASM_X86_PKEYS_H */
diff -puN arch/x86/kernel/fpu/xstate.c~pkeys-116-syscalls-allocation arch/x86/kernel/fpu/xstate.c
--- a/arch/x86/kernel/fpu/xstate.c~pkeys-116-syscalls-allocation	2016-08-08 16:15:11.128056260 -0700
+++ b/arch/x86/kernel/fpu/xstate.c	2016-08-08 16:15:11.143056942 -0700
@@ -5,6 +5,7 @@
  */
 #include <linux/compat.h>
 #include <linux/cpu.h>
+#include <linux/mman.h>
 #include <linux/pkeys.h>
 
 #include <asm/fpu/api.h>
@@ -866,9 +867,10 @@ const void *get_xsave_field_ptr(int xsav
 	return get_xsave_addr(&fpu->state.xsave, xsave_state);
 }
 
+#ifdef CONFIG_ARCH_HAS_PKEYS
+
 #define NR_VALID_PKRU_BITS (CONFIG_NR_PROTECTION_KEYS * 2)
 #define PKRU_VALID_MASK (NR_VALID_PKRU_BITS - 1)
-
 /*
  * This will go out and modify PKRU register to set the access
  * rights for @pkey to @init_val.
@@ -914,6 +916,7 @@ int arch_set_user_pkey_access(struct tas
 
 	return 0;
 }
+#endif /* ! CONFIG_ARCH_HAS_PKEYS */
 
 /*
  * This is similar to user_regset_copyout(), but will not add offset to
diff -puN arch/x86/mm/pkeys.c~pkeys-116-syscalls-allocation arch/x86/mm/pkeys.c
--- a/arch/x86/mm/pkeys.c~pkeys-116-syscalls-allocation	2016-08-08 16:15:11.131056397 -0700
+++ b/arch/x86/mm/pkeys.c	2016-08-08 16:15:11.144056988 -0700
@@ -21,8 +21,19 @@
 
 int __execute_only_pkey(struct mm_struct *mm)
 {
+	bool need_to_set_mm_pkey = false;
+	int execute_only_pkey = mm->context.execute_only_pkey;
 	int ret;
 
+	/* Do we need to assign a pkey for mm's execute-only maps? */
+	if (execute_only_pkey == -1) {
+		/* Go allocate one to use, which might fail */
+		execute_only_pkey = mm_pkey_alloc(mm);
+		if (execute_only_pkey < 0)
+			return -1;
+		need_to_set_mm_pkey = true;
+	}
+
 	/*
 	 * We do not want to go through the relatively costly
 	 * dance to set PKRU if we do not need to.  Check it
@@ -32,22 +43,33 @@ int __execute_only_pkey(struct mm_struct
 	 * can make fpregs inactive.
 	 */
 	preempt_disable();
-	if (fpregs_active() &&
-	    !__pkru_allows_read(read_pkru(), PKEY_DEDICATED_EXECUTE_ONLY)) {
+	if (!need_to_set_mm_pkey &&
+	    fpregs_active() &&
+	    !__pkru_allows_read(read_pkru(), execute_only_pkey)) {
 		preempt_enable();
-		return PKEY_DEDICATED_EXECUTE_ONLY;
+		return execute_only_pkey;
 	}
 	preempt_enable();
-	ret = arch_set_user_pkey_access(current, PKEY_DEDICATED_EXECUTE_ONLY,
+
+	/*
+	 * Set up PKRU so that it denies access for everything
+	 * other than execution.
+	 */
+	ret = arch_set_user_pkey_access(current, execute_only_pkey,
 			PKEY_DISABLE_ACCESS);
 	/*
 	 * If the PKRU-set operation failed somehow, just return
 	 * 0 and effectively disable execute-only support.
 	 */
-	if (ret)
-		return 0;
+	if (ret) {
+		mm_set_pkey_free(mm, execute_only_pkey);
+		return -1;
+	}
 
-	return PKEY_DEDICATED_EXECUTE_ONLY;
+	/* We got one, store it and use it from here on out */
+	if (need_to_set_mm_pkey)
+		mm->context.execute_only_pkey = execute_only_pkey;
+	return execute_only_pkey;
 }
 
 static inline bool vma_is_pkey_exec_only(struct vm_area_struct *vma)
@@ -55,7 +77,7 @@ static inline bool vma_is_pkey_exec_only
 	/* Do this check first since the vm_flags should be hot */
 	if ((vma->vm_flags & (VM_READ | VM_WRITE | VM_EXEC)) != VM_EXEC)
 		return false;
-	if (vma_pkey(vma) != PKEY_DEDICATED_EXECUTE_ONLY)
+	if (vma_pkey(vma) != vma->vm_mm->context.execute_only_pkey)
 		return false;
 
 	return true;
diff -puN arch/xtensa/include/uapi/asm/mman.h~pkeys-116-syscalls-allocation arch/xtensa/include/uapi/asm/mman.h
--- a/arch/xtensa/include/uapi/asm/mman.h~pkeys-116-syscalls-allocation	2016-08-08 16:15:11.133056488 -0700
+++ b/arch/xtensa/include/uapi/asm/mman.h	2016-08-08 16:15:11.144056988 -0700
@@ -117,4 +117,9 @@
 #define MAP_HUGE_SHIFT	26
 #define MAP_HUGE_MASK	0x3f
 
+#define PKEY_DISABLE_ACCESS	0x1
+#define PKEY_DISABLE_WRITE	0x2
+#define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
+				 PKEY_DISABLE_WRITE)
+
 #endif /* _XTENSA_MMAN_H */
diff -puN include/linux/pkeys.h~pkeys-116-syscalls-allocation include/linux/pkeys.h
--- a/include/linux/pkeys.h~pkeys-116-syscalls-allocation	2016-08-08 16:15:11.134056533 -0700
+++ b/include/linux/pkeys.h	2016-08-08 16:15:11.144056988 -0700
@@ -4,11 +4,6 @@
 #include <linux/mm_types.h>
 #include <asm/mmu_context.h>
 
-#define PKEY_DISABLE_ACCESS	0x1
-#define PKEY_DISABLE_WRITE	0x2
-#define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
-				 PKEY_DISABLE_WRITE)
-
 #ifdef CONFIG_ARCH_HAS_PKEYS
 #include <asm/pkeys.h>
 #else /* ! CONFIG_ARCH_HAS_PKEYS */
@@ -17,6 +12,29 @@
 #define arch_override_mprotect_pkey(vma, prot, pkey) (0)
 #define PKEY_DEDICATED_EXECUTE_ONLY 0
 #define ARCH_VM_PKEY_FLAGS 0
+
+static inline bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
+{
+	return (pkey == 0);
+}
+
+static inline int mm_pkey_alloc(struct mm_struct *mm)
+{
+	return -1;
+}
+
+static inline int mm_pkey_free(struct mm_struct *mm, int pkey)
+{
+	WARN_ONCE(1, "free of protection key when disabled");
+	return -EINVAL;
+}
+
+static inline int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
+			unsigned long init_val)
+{
+	return 0;
+}
+
 #endif /* ! CONFIG_ARCH_HAS_PKEYS */
 
 #endif /* _LINUX_PKEYS_H */
diff -puN include/uapi/asm-generic/mman-common.h~pkeys-116-syscalls-allocation include/uapi/asm-generic/mman-common.h
--- a/include/uapi/asm-generic/mman-common.h~pkeys-116-syscalls-allocation	2016-08-08 16:15:11.136056624 -0700
+++ b/include/uapi/asm-generic/mman-common.h	2016-08-08 16:15:11.145057033 -0700
@@ -72,4 +72,9 @@
 #define MAP_HUGE_SHIFT	26
 #define MAP_HUGE_MASK	0x3f
 
+#define PKEY_DISABLE_ACCESS	0x1
+#define PKEY_DISABLE_WRITE	0x2
+#define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
+				 PKEY_DISABLE_WRITE)
+
 #endif /* __ASM_GENERIC_MMAN_COMMON_H */
diff -puN mm/mprotect.c~pkeys-116-syscalls-allocation mm/mprotect.c
--- a/mm/mprotect.c~pkeys-116-syscalls-allocation	2016-08-08 16:15:11.137056669 -0700
+++ b/mm/mprotect.c	2016-08-08 16:15:11.145057033 -0700
@@ -23,11 +23,13 @@
 #include <linux/mmu_notifier.h>
 #include <linux/migrate.h>
 #include <linux/perf_event.h>
+#include <linux/pkeys.h>
 #include <linux/ksm.h>
 #include <linux/pkeys.h>
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
+#include <asm/mmu_context.h>
 #include <asm/tlbflush.h>
 
 #include "internal.h"
@@ -364,12 +366,6 @@ static int do_mprotect_pkey(unsigned lon
 	const int grows = prot & (PROT_GROWSDOWN|PROT_GROWSUP);
 	const bool rier = (current->personality & READ_IMPLIES_EXEC) &&
 				(prot & PROT_READ);
-	/*
-	 * A temporary safety check since we are not validating
-	 * the pkey before we introduce the allocation code.
-	 */
-	if (pkey != -1)
-		return -EINVAL;
 
 	prot &= ~(PROT_GROWSDOWN|PROT_GROWSUP);
 	if (grows == (PROT_GROWSDOWN|PROT_GROWSUP)) /* can't be both */
@@ -391,6 +387,14 @@ static int do_mprotect_pkey(unsigned lon
 	if (down_write_killable(&current->mm->mmap_sem))
 		return -EINTR;
 
+	/*
+	 * If userspace did not allocate the pkey, do not let
+	 * them use it here.
+	 */
+	error = -EINVAL;
+	if ((pkey != -1) && !mm_pkey_is_allocated(current->mm, pkey))
+		goto out;
+
 	vma = find_vma(current->mm, start);
 	error = -ENOMEM;
 	if (!vma)
@@ -485,3 +489,48 @@ SYSCALL_DEFINE4(pkey_mprotect, unsigned
 {
 	return do_mprotect_pkey(start, len, prot, pkey);
 }
+
+SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
+{
+	int pkey;
+	int ret;
+
+	/* No flags supported yet. */
+	if (flags)
+		return -EINVAL;
+	/* check for unsupported init values */
+	if (init_val & ~PKEY_ACCESS_MASK)
+		return -EINVAL;
+
+	down_write(&current->mm->mmap_sem);
+	pkey = mm_pkey_alloc(current->mm);
+
+	ret = -ENOSPC;
+	if (pkey == -1)
+		goto out;
+
+	ret = arch_set_user_pkey_access(current, pkey, init_val);
+	if (ret) {
+		mm_pkey_free(current->mm, pkey);
+		goto out;
+	}
+	ret = pkey;
+out:
+	up_write(&current->mm->mmap_sem);
+	return ret;
+}
+
+SYSCALL_DEFINE1(pkey_free, int, pkey)
+{
+	int ret;
+
+	down_write(&current->mm->mmap_sem);
+	ret = mm_pkey_free(current->mm, pkey);
+	up_write(&current->mm->mmap_sem);
+
+	/*
+	 * We could provie warnings or errors if any VMA still
+	 * has the pkey set here.
+	 */
+	return ret;
+}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
