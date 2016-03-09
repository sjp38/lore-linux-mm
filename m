Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 635F16B0255
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 17:00:20 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id 129so51256661pfw.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 14:00:20 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id q62si851641pfi.214.2016.03.09.14.00.18
        for <linux-mm@kvack.org>;
        Wed, 09 Mar 2016 14:00:18 -0800 (PST)
Subject: [PATCH 6/9] x86, pkeys: allocation/free syscalls
From: Dave Hansen <dave@sr71.net>
Date: Wed, 09 Mar 2016 14:00:17 -0800
References: <20160309220008.D61AF421@viggo.jf.intel.com>
In-Reply-To: <20160309220008.D61AF421@viggo.jf.intel.com>
Message-Id: <20160309220017.46AAF70F@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org


From: Dave Hansen <dave.hansen@linux.intel.com>

This patch adds two new system calls:

	int pkey_alloc(unsigned long flags, unsigned long init_access_rights)
	int pkey_free(int pkey);

These implement an "allocator" for the protection keys
themselves, which can be thought of as analogous to the allocator
that the kernel has for file descriptors.  The kernel tracks
which numbers are in use, and only allows operations on keys that
are valid.  A key which was not obtained by pkey_alloc() may not,
for instance, be passed to pkey_mprotect() (or the forthcoming
get/set syscalls).

These system calls are also very important given the kernel's use
of pkeys to implement execute-only support.  These help ensure
that userspace can never assume that it has control of a key
unless it first asks the kernel.

The 'init_access_rights' argument to pkey_alloc() specifies the
rights that will be established for the returned pkey.  For
instance:

	pkey = pkey_alloc(flags, PKEY_DENY_WRITE);

will allocate 'pkey', but also sets the bits in PKRU[1] such that
writing to 'pkey' is already denied.  This keeps userspace from
needing to have knowledge about manipulating PKRU with the
RDPKRU/WRPKRU instructions.  Userspace is still free to use these
instructions as it wishes, but this facility ensures it is no
longer required.

The kernel does _not_ enforce that this interface must be used for
changes to PKRU, even for keys it does not control.

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
Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org
---

 b/arch/alpha/include/uapi/asm/mman.h     |    5 +
 b/arch/mips/include/uapi/asm/mman.h      |    5 +
 b/arch/parisc/include/uapi/asm/mman.h    |    5 +
 b/arch/x86/entry/syscalls/syscall_32.tbl |    2 
 b/arch/x86/entry/syscalls/syscall_64.tbl |    2 
 b/arch/x86/include/asm/mmu.h             |    8 +++
 b/arch/x86/include/asm/mmu_context.h     |   10 +++
 b/arch/x86/include/asm/pkeys.h           |   78 +++++++++++++++++++++++++++++--
 b/arch/x86/kernel/fpu/xstate.c           |    3 +
 b/arch/x86/mm/pkeys.c                    |   38 +++++++++++----
 b/arch/xtensa/include/uapi/asm/mman.h    |    5 +
 b/include/linux/pkeys.h                  |   30 +++++++++--
 b/include/uapi/asm-generic/mman-common.h |    5 +
 b/mm/mprotect.c                          |   55 +++++++++++++++++++++
 14 files changed, 231 insertions(+), 20 deletions(-)

diff -puN arch/alpha/include/uapi/asm/mman.h~pkeys-116-syscalls-allocation arch/alpha/include/uapi/asm/mman.h
--- a/arch/alpha/include/uapi/asm/mman.h~pkeys-116-syscalls-allocation	2016-03-09 13:55:21.521514549 -0800
+++ b/arch/alpha/include/uapi/asm/mman.h	2016-03-09 13:55:21.545515635 -0800
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
--- a/arch/mips/include/uapi/asm/mman.h~pkeys-116-syscalls-allocation	2016-03-09 13:55:21.523514639 -0800
+++ b/arch/mips/include/uapi/asm/mman.h	2016-03-09 13:55:21.546515681 -0800
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
--- a/arch/parisc/include/uapi/asm/mman.h~pkeys-116-syscalls-allocation	2016-03-09 13:55:21.524514685 -0800
+++ b/arch/parisc/include/uapi/asm/mman.h	2016-03-09 13:55:21.546515681 -0800
@@ -75,4 +75,9 @@
 #define MAP_HUGE_SHIFT	26
 #define MAP_HUGE_MASK	0x3f
 
+#define PKEY_DISABLE_ACCESS	0x1
+#define PKEY_DISABLE_WRITE	0x2
+#define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
+				 PKEY_DISABLE_WRITE)
+
 #endif /* __PARISC_MMAN_H__ */
diff -puN arch/x86/entry/syscalls/syscall_32.tbl~pkeys-116-syscalls-allocation arch/x86/entry/syscalls/syscall_32.tbl
--- a/arch/x86/entry/syscalls/syscall_32.tbl~pkeys-116-syscalls-allocation	2016-03-09 13:55:21.526514776 -0800
+++ b/arch/x86/entry/syscalls/syscall_32.tbl	2016-03-09 13:55:21.546515681 -0800
@@ -385,3 +385,5 @@
 376	i386	mlock2			sys_mlock2
 377	i386	copy_file_range		sys_copy_file_range
 378	i386	pkey_mprotect		sys_pkey_mprotect
+379	i386	pkey_alloc		sys_pkey_alloc
+380	i386	pkey_free		sys_pkey_free
diff -puN arch/x86/entry/syscalls/syscall_64.tbl~pkeys-116-syscalls-allocation arch/x86/entry/syscalls/syscall_64.tbl
--- a/arch/x86/entry/syscalls/syscall_64.tbl~pkeys-116-syscalls-allocation	2016-03-09 13:55:21.528514866 -0800
+++ b/arch/x86/entry/syscalls/syscall_64.tbl	2016-03-09 13:55:21.547515726 -0800
@@ -334,6 +334,8 @@
 325	common	mlock2			sys_mlock2
 326	common	copy_file_range		sys_copy_file_range
 327	common	pkey_mprotect		sys_pkey_mprotect
+328	common	pkey_alloc		sys_pkey_alloc
+329	common	pkey_free		sys_pkey_free
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff -puN arch/x86/include/asm/mmu_context.h~pkeys-116-syscalls-allocation arch/x86/include/asm/mmu_context.h
--- a/arch/x86/include/asm/mmu_context.h~pkeys-116-syscalls-allocation	2016-03-09 13:55:21.529514911 -0800
+++ b/arch/x86/include/asm/mmu_context.h	2016-03-09 13:55:21.547515726 -0800
@@ -108,7 +108,16 @@ static inline void enter_lazy_tlb(struct
 static inline int init_new_context(struct task_struct *tsk,
 				   struct mm_struct *mm)
 {
+	#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+	if (boot_cpu_has(X86_FEATURE_OSPKE)) {
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
@@ -354,5 +363,4 @@ static inline bool arch_pte_access_permi
 {
 	return __pkru_allows_pkey(pte_flags_pkey(pte_flags(pte)), write);
 }
-
 #endif /* _ASM_X86_MMU_CONTEXT_H */
diff -puN arch/x86/include/asm/mmu.h~pkeys-116-syscalls-allocation arch/x86/include/asm/mmu.h
--- a/arch/x86/include/asm/mmu.h~pkeys-116-syscalls-allocation	2016-03-09 13:55:21.531515002 -0800
+++ b/arch/x86/include/asm/mmu.h	2016-03-09 13:55:21.547515726 -0800
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
--- a/arch/x86/include/asm/pkeys.h~pkeys-116-syscalls-allocation	2016-03-09 13:55:21.533515092 -0800
+++ b/arch/x86/include/asm/pkeys.h	2016-03-09 13:55:21.548515771 -0800
@@ -1,12 +1,8 @@
 #ifndef _ASM_X86_PKEYS_H
 #define _ASM_X86_PKEYS_H
 
-#define PKEY_DEDICATED_EXECUTE_ONLY 15
-/*
- * Consider the PKEY_DEDICATED_EXECUTE_ONLY key unavailable.
- */
 #define arch_max_pkey() (boot_cpu_has(X86_FEATURE_OSPKE) ? \
-		PKEY_DEDICATED_EXECUTE_ONLY : 1)
+		16 : 1)
 
 extern int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 		unsigned long init_val);
@@ -40,4 +36,76 @@ extern int __arch_set_user_pkey_access(s
 
 #define ARCH_VM_PKEY_FLAGS (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | VM_PKEY_BIT3)
 
+#define mm_pkey_allocation_map(mm)	(mm->context.pkey_allocation_map)
+#define mm_set_pkey_allocated(mm, pkey) do {		\
+	mm_pkey_allocation_map(mm) |= (1 << pkey);	\
+} while (0)
+#define mm_set_pkey_free(mm, pkey) do {			\
+	mm_pkey_allocation_map(mm) &= ~(1 << pkey);	\
+} while (0)
+
+/*
+ * This is called from mprotect_pkey().
+ *
+ * Returns true if the protection keys is valid.
+ */
+static inline bool validate_pkey(int pkey)
+{
+	if (pkey < 0)
+		return false;
+	return (pkey < arch_max_pkey());
+}
+
+static inline
+bool mm_pkey_is_allocated(struct mm_struct *mm, unsigned long pkey)
+{
+	if (!validate_pkey(pkey))
+		return true;
+
+	return mm_pkey_allocation_map(mm) & (1 << pkey);
+}
+
+static inline
+int mm_pkey_alloc(struct mm_struct *mm)
+{
+	int all_pkeys_mask = ((1 << arch_max_pkey()) - 1);
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
+	if (!pkey || !validate_pkey(pkey))
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
--- a/arch/x86/kernel/fpu/xstate.c~pkeys-116-syscalls-allocation	2016-03-09 13:55:21.534515138 -0800
+++ b/arch/x86/kernel/fpu/xstate.c	2016-03-09 13:55:21.548515771 -0800
@@ -5,6 +5,7 @@
  */
 #include <linux/compat.h>
 #include <linux/cpu.h>
+#include <linux/mman.h>
 #include <linux/pkeys.h>
 
 #include <asm/fpu/api.h>
@@ -775,6 +776,7 @@ const void *get_xsave_field_ptr(int xsav
 	return get_xsave_addr(&fpu->state.xsave, xsave_state);
 }
 
+#ifdef CONFIG_ARCH_HAS_PKEYS
 
 /*
  * Set xfeatures (aka XSTATE_BV) bit for a feature that we want
@@ -940,3 +942,4 @@ int arch_set_user_pkey_access(struct tas
 		return -EINVAL;
 	return __arch_set_user_pkey_access(tsk, pkey, init_val);
 }
+#endif /* CONFIG_ARCH_HAS_PKEYS */
diff -puN arch/x86/mm/pkeys.c~pkeys-116-syscalls-allocation arch/x86/mm/pkeys.c
--- a/arch/x86/mm/pkeys.c~pkeys-116-syscalls-allocation	2016-03-09 13:55:21.536515228 -0800
+++ b/arch/x86/mm/pkeys.c	2016-03-09 13:55:21.549515816 -0800
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
+		if (!validate_pkey(execute_only_pkey))
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
-	ret = __arch_set_user_pkey_access(current, PKEY_DEDICATED_EXECUTE_ONLY,
+
+	/*
+	 * Set up PKRU so that it denies access for everything
+	 * other than execution.
+	 */
+	ret = __arch_set_user_pkey_access(current, execute_only_pkey,
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
--- a/arch/xtensa/include/uapi/asm/mman.h~pkeys-116-syscalls-allocation	2016-03-09 13:55:21.537515273 -0800
+++ b/arch/xtensa/include/uapi/asm/mman.h	2016-03-09 13:55:21.549515816 -0800
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
--- a/include/linux/pkeys.h~pkeys-116-syscalls-allocation	2016-03-09 13:55:21.539515364 -0800
+++ b/include/linux/pkeys.h	2016-03-09 13:55:21.549515816 -0800
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
@@ -17,7 +12,6 @@
 #define arch_override_mprotect_pkey(vma, prot, pkey) (0)
 #define PKEY_DEDICATED_EXECUTE_ONLY 0
 #define ARCH_VM_PKEY_FLAGS 0
-#endif /* ! CONFIG_ARCH_HAS_PKEYS */
 
 /*
  * This is called from mprotect_pkey().
@@ -31,4 +25,28 @@ static inline bool validate_pkey(int pke
 	return (pkey < arch_max_pkey());
 }
 
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
+#endif /* ! CONFIG_ARCH_HAS_PKEYS */
+
 #endif /* _LINUX_PKEYS_H */
diff -puN include/uapi/asm-generic/mman-common.h~pkeys-116-syscalls-allocation include/uapi/asm-generic/mman-common.h
--- a/include/uapi/asm-generic/mman-common.h~pkeys-116-syscalls-allocation	2016-03-09 13:55:21.541515455 -0800
+++ b/include/uapi/asm-generic/mman-common.h	2016-03-09 13:55:21.549515816 -0800
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
--- a/mm/mprotect.c~pkeys-116-syscalls-allocation	2016-03-09 13:55:21.542515500 -0800
+++ b/mm/mprotect.c	2016-03-09 13:55:21.550515862 -0800
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
@@ -386,6 +388,14 @@ static int do_mprotect_pkey(unsigned lon
 
 	down_write(&current->mm->mmap_sem);
 
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
@@ -477,3 +487,48 @@ SYSCALL_DEFINE4(pkey_mprotect, unsigned
 
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
