Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 411F382F71
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 20:15:31 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so77847071pac.3
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 17:15:31 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id yf4si15473816pab.34.2015.12.03.17.15.26
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 17:15:27 -0800 (PST)
Subject: [PATCH 31/34] x86, pkeys: allocation/free syscalls
From: Dave Hansen <dave@sr71.net>
Date: Thu, 03 Dec 2015 17:15:07 -0800
References: <20151204011424.8A36E365@viggo.jf.intel.com>
In-Reply-To: <20151204011424.8A36E365@viggo.jf.intel.com>
Message-Id: <20151204011507.65449583@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, linux-api@vger.kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

This patch adds two new system calls:

	int pkey_alloc(unsigned long flags, unsigned long init_access_rights)
	int pkey_free(int pkey);

These establish which protection keys are valid for use by
userspace.  A key which was not obtained by pkey_alloc() may not
be passed to pkey_mprotect().

In addition, the 'init_access_rights' argument to pkey_alloc() specifies
the rights that will be established for the returned pkey.  For instance

	pkey = pkey_alloc(flags, PKEY_DENY_WRITE);

will return with the bits set in PKRU such that writing to 'pkey' is
already denied.  This keeps userspace from needing to have knowledge
about manipulating PKRU.  It is still free to do so if it wishes, but
it is no longer required.

The kernel does _not_ enforce that this interface must be used for
changes to PKRU, even for keys it does not control.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-api@vger.kernel.org
---

 b/arch/x86/entry/syscalls/syscall_32.tbl |    2 
 b/arch/x86/entry/syscalls/syscall_64.tbl |    2 
 b/arch/x86/include/asm/mmu.h             |    7 ++
 b/arch/x86/include/asm/mmu_context.h     |    8 +++
 b/arch/x86/include/asm/pgtable.h         |    5 +-
 b/arch/x86/include/asm/pkeys.h           |   55 ++++++++++++++++++++++
 b/arch/x86/kernel/fpu/xstate.c           |   75 +++++++++++++++++++++++++++++++
 b/include/linux/pkeys.h                  |   23 +++++++++
 b/include/uapi/asm-generic/mman-common.h |    5 ++
 b/mm/mprotect.c                          |   59 +++++++++++++++++++++++-
 10 files changed, 238 insertions(+), 3 deletions(-)

diff -puN arch/x86/entry/syscalls/syscall_32.tbl~pkey-allocation-syscalls arch/x86/entry/syscalls/syscall_32.tbl
--- a/arch/x86/entry/syscalls/syscall_32.tbl~pkey-allocation-syscalls	2015-12-03 16:21:32.484982342 -0800
+++ b/arch/x86/entry/syscalls/syscall_32.tbl	2015-12-03 16:21:32.502983159 -0800
@@ -384,3 +384,5 @@
 375	i386	membarrier		sys_membarrier
 376	i386	mlock2			sys_mlock2
 377	i386	pkey_mprotect		sys_pkey_mprotect
+378	i386	pkey_alloc		sys_pkey_alloc
+379	i386	pkey_free		sys_pkey_free
diff -puN arch/x86/entry/syscalls/syscall_64.tbl~pkey-allocation-syscalls arch/x86/entry/syscalls/syscall_64.tbl
--- a/arch/x86/entry/syscalls/syscall_64.tbl~pkey-allocation-syscalls	2015-12-03 16:21:32.485982388 -0800
+++ b/arch/x86/entry/syscalls/syscall_64.tbl	2015-12-03 16:21:32.502983159 -0800
@@ -333,6 +333,8 @@
 324	common	membarrier		sys_membarrier
 325	common	mlock2			sys_mlock2
 326	common	pkey_mprotect		sys_pkey_mprotect
+327	common	pkey_alloc		sys_pkey_alloc
+328	common	pkey_free		sys_pkey_free
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff -puN arch/x86/include/asm/mmu_context.h~pkey-allocation-syscalls arch/x86/include/asm/mmu_context.h
--- a/arch/x86/include/asm/mmu_context.h~pkey-allocation-syscalls	2015-12-03 16:21:32.487982478 -0800
+++ b/arch/x86/include/asm/mmu_context.h	2015-12-03 16:21:32.503983204 -0800
@@ -108,7 +108,12 @@ static inline void enter_lazy_tlb(struct
 static inline int init_new_context(struct task_struct *tsk,
 				   struct mm_struct *mm)
 {
+#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+	/* pkey 0 is the default and always allocated */
+	mm->context.pkey_allocation_map = 0x1;
+#endif
 	init_new_context_ldt(tsk, mm);
+
 	return 0;
 }
 static inline void destroy_context(struct mm_struct *mm)
@@ -333,4 +338,7 @@ static inline bool arch_pte_access_permi
 	return __pkru_allows_pkey(pte_flags_pkey(pte_flags(pte)), write);
 }
 
+extern int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
+		unsigned long init_val);
+
 #endif /* _ASM_X86_MMU_CONTEXT_H */
diff -puN arch/x86/include/asm/mmu.h~pkey-allocation-syscalls arch/x86/include/asm/mmu.h
--- a/arch/x86/include/asm/mmu.h~pkey-allocation-syscalls	2015-12-03 16:21:32.489982569 -0800
+++ b/arch/x86/include/asm/mmu.h	2015-12-03 16:21:32.503983204 -0800
@@ -22,6 +22,13 @@ typedef struct {
 	void __user *vdso;
 
 	atomic_t perf_rdpmc_allowed;	/* nonzero if rdpmc is allowed */
+#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+	/*
+	 * One bit per protection key says whether userspace can
+	 * use it or not.  protected by mmap_sem.
+	 */
+	u16 pkey_allocation_map;
+#endif
 } mm_context_t;
 
 #ifdef CONFIG_SMP
diff -puN arch/x86/include/asm/pgtable.h~pkey-allocation-syscalls arch/x86/include/asm/pgtable.h
--- a/arch/x86/include/asm/pgtable.h~pkey-allocation-syscalls	2015-12-03 16:21:32.490982614 -0800
+++ b/arch/x86/include/asm/pgtable.h	2015-12-03 16:21:32.503983204 -0800
@@ -912,16 +912,17 @@ static inline pte_t pte_swp_clear_soft_d
 
 #define PKRU_AD_BIT 0x1
 #define PKRU_WD_BIT 0x2
+#define PKRU_BITS_PER_PKEY 2
 
 static inline bool __pkru_allows_read(u32 pkru, u16 pkey)
 {
-	int pkru_pkey_bits = pkey * 2;
+	int pkru_pkey_bits = pkey * PKRU_BITS_PER_PKEY;
 	return !(pkru & (PKRU_AD_BIT << pkru_pkey_bits));
 }
 
 static inline bool __pkru_allows_write(u32 pkru, u16 pkey)
 {
-	int pkru_pkey_bits = pkey * 2;
+	int pkru_pkey_bits = pkey * PKRU_BITS_PER_PKEY;
 	/*
 	 * Access-disable disables writes too so we need to check
 	 * both bits here.
diff -puN arch/x86/include/asm/pkeys.h~pkey-allocation-syscalls arch/x86/include/asm/pkeys.h
--- a/arch/x86/include/asm/pkeys.h~pkey-allocation-syscalls	2015-12-03 16:21:32.492982705 -0800
+++ b/arch/x86/include/asm/pkeys.h	2015-12-03 16:21:32.504983249 -0800
@@ -7,6 +7,61 @@
 
 #define ARCH_VM_PKEY_FLAGS (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | VM_PKEY_BIT3)
 
+#define mm_pkey_allocation_map(mm)	(mm->context.pkey_allocation_map)
+#define mm_set_pkey_allocated(mm, pkey) do {		\
+	mm_pkey_allocation_map(mm) |= (1 << pkey);	\
+} while (0)
+#define mm_set_pkey_free(mm, pkey) do {			\
+	mm_pkey_allocation_map(mm) &= ~(1 << pkey);	\
+} while (0)
+
+static inline
+bool mm_pkey_is_allocated(struct mm_struct *mm, unsigned long pkey)
+{
+	if (!arch_validate_pkey(pkey))
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
+	if (!pkey || !arch_validate_pkey(pkey))
+		return -EINVAL;
+	if (!mm_pkey_is_allocated(mm, pkey))
+		return -EINVAL;
+
+	mm_set_pkey_free(mm, pkey);
+
+	return 0;
+}
+
 #endif /*_ASM_X86_PKEYS_H */
 
 
diff -puN arch/x86/kernel/fpu/xstate.c~pkey-allocation-syscalls arch/x86/kernel/fpu/xstate.c
--- a/arch/x86/kernel/fpu/xstate.c~pkey-allocation-syscalls	2015-12-03 16:21:32.494982796 -0800
+++ b/arch/x86/kernel/fpu/xstate.c	2015-12-03 16:21:32.504983249 -0800
@@ -5,6 +5,8 @@
  */
 #include <linux/compat.h>
 #include <linux/cpu.h>
+#include <linux/mman.h>
+#include <linux/pkeys.h>
 
 #include <asm/fpu/api.h>
 #include <asm/fpu/internal.h>
@@ -775,6 +777,7 @@ const void *get_xsave_field_ptr(int xsav
 	return get_xsave_addr(&fpu->state.xsave, xsave_state);
 }
 
+#ifdef CONFIG_ARCH_HAS_PKEYS
 
 /*
  * Set xfeatures (aka XSTATE_BV) bit for a feature that we want
@@ -855,6 +858,78 @@ out:
 	 * and (possibly) move the fpstate back in to the fpregs.
 	 */
 	fpu__current_fpstate_write_end();
+}
+
+#define NR_VALID_PKRU_BITS (CONFIG_NR_PROTECTION_KEYS * 2)
+#define PKRU_VALID_MASK (NR_VALID_PKRU_BITS - 1)
+
+/*
+ * This will go out and modify the XSAVE buffer so that PKRU is
+ * set to a particular state for access to 'pkey'.
+ *
+ * PKRU state does affect kernel access to user memory.  We do
+ * not modfiy PKRU *itself* here, only the XSAVE state that will
+ * be restored in to PKRU when we return back to userspace.
+ */
+int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
+		unsigned long init_val)
+{
+	struct xregs_state *xsave = &tsk->thread.fpu.state.xsave;
+	struct pkru_state *old_pkru_state;
+	struct pkru_state new_pkru_state;
+	int pkey_shift = (pkey * PKRU_BITS_PER_PKEY);
+	u32 new_pkru_bits = 0;
+
+	if (!arch_validate_pkey(pkey))
+		return -EINVAL;
+	/*
+	 * This check implies XSAVE support.  OSPKE only gets
+	 * set if we enable XSAVE and we enable PKU in XCR0.
+	 */
+	if (!boot_cpu_has(X86_FEATURE_OSPKE))
+		return -EINVAL;
+
+	/* Set the bits we need in PKRU  */
+	if (init_val & PKEY_DISABLE_ACCESS)
+		new_pkru_bits |= PKRU_AD_BIT;
+	if (init_val & PKEY_DISABLE_WRITE)
+		new_pkru_bits |= PKRU_WD_BIT;
+
+	/* Shift the bits in to the correct place in PKRU for pkey. */
+	new_pkru_bits <<= pkey_shift;
+
+	/* Locate old copy of the state in the xsave buffer */
+	old_pkru_state = get_xsave_addr(xsave, XFEATURE_MASK_PKRU);
+
+	/*
+	 * When state is not in the buffer, it is in the init
+	 * state, set it manually.  Otherwise, copy out the old
+	 * state.
+	 */
+	if (!old_pkru_state)
+		new_pkru_state.pkru = 0;
+	else
+		new_pkru_state.pkru = old_pkru_state->pkru;
+
+	/* mask off any old bits in place */
+	new_pkru_state.pkru &= ~((PKRU_AD_BIT|PKRU_WD_BIT) << pkey_shift);
+	/* Set the newly-requested bits */
+	new_pkru_state.pkru |= new_pkru_bits;
+
+	/*
+	 * We could theoretically live without zeroing pkru.pad.
+	 * The current XSAVE feature state definition says that
+	 * only bytes 0->3 are used.  But we do not want to
+	 * chance leaking kernel stack out to userspace in case a
+	 * memcpy() of the whole xsave buffer was done.
+	 *
+	 * They're in the same cacheline anyway.
+	 */
+	new_pkru_state.pad = 0;
+
+	fpu__xfeature_set_state(XFEATURE_MASK_PKRU, &new_pkru_state,
+			sizeof(new_pkru_state));
 
 	return 0;
 }
+#endif /* CONFIG_ARCH_HAS_PKEYS */
diff -puN include/linux/pkeys.h~pkey-allocation-syscalls include/linux/pkeys.h
--- a/include/linux/pkeys.h~pkey-allocation-syscalls	2015-12-03 16:21:32.495982841 -0800
+++ b/include/linux/pkeys.h	2015-12-03 16:21:32.504983249 -0800
@@ -23,6 +23,29 @@ static inline int vma_pkey(struct vm_are
 {
 	return 0;
 }
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
diff -puN include/uapi/asm-generic/mman-common.h~pkey-allocation-syscalls include/uapi/asm-generic/mman-common.h
--- a/include/uapi/asm-generic/mman-common.h~pkey-allocation-syscalls	2015-12-03 16:21:32.497982932 -0800
+++ b/include/uapi/asm-generic/mman-common.h	2015-12-03 16:21:32.505983295 -0800
@@ -71,4 +71,9 @@
 #define MAP_HUGE_SHIFT	26
 #define MAP_HUGE_MASK	0x3f
 
+#define PKEY_DISABLE_ACCESS	0x1
+#define PKEY_DISABLE_WRITE	0x2
+#define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
+				 PKEY_DISABLE_WRITE)
+
 #endif /* __ASM_GENERIC_MMAN_COMMON_H */
diff -puN mm/mprotect.c~pkey-allocation-syscalls mm/mprotect.c
--- a/mm/mprotect.c~pkey-allocation-syscalls	2015-12-03 16:21:32.498982977 -0800
+++ b/mm/mprotect.c	2015-12-03 16:21:32.505983295 -0800
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
@@ -355,6 +357,8 @@ static int do_mprotect_pkey(unsigned lon
 	struct vm_area_struct *vma, *prev;
 	int error = -EINVAL;
 	const int grows = prot & (PROT_GROWSDOWN|PROT_GROWSUP);
+	int plain_mprotect = (pkey == -1);
+
 	prot &= ~(PROT_GROWSDOWN|PROT_GROWSUP);
 	if (grows == (PROT_GROWSDOWN|PROT_GROWSUP)) /* can't be both */
 		return -EINVAL;
@@ -379,6 +383,14 @@ static int do_mprotect_pkey(unsigned lon
 
 	down_write(&current->mm->mmap_sem);
 
+	/*
+	 * If userspace did not allocate the pkey, do not let
+	 * them use it here.
+	 */
+	error = -EINVAL;
+	if (!plain_mprotect && !mm_pkey_is_allocated(current->mm, pkey))
+		goto out;
+
 	vma = find_vma(current->mm, start);
 	error = -ENOMEM;
 	if (!vma)
@@ -420,7 +432,7 @@ static int do_mprotect_pkey(unsigned lon
 		 * If this is a vanilla, non-pkey mprotect, inherit the
 		 * pkey from the VMA we are working on.
 		 */
-		if (pkey == -1)
+		if (plain_mprotect)
 			newflags = calc_vm_prot_bits(prot, vma_pkey(vma));
 		else
 			newflags = calc_vm_prot_bits(prot, pkey);
@@ -474,3 +486,48 @@ SYSCALL_DEFINE4(pkey_mprotect, unsigned
 
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
